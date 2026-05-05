if not LibRange then LibRange = {} end
local LibRange = LibRange

LibRange.TargetRange = {
	MIN_RANGE					= 0,
	MAX_RANGE					= 65535,
}
local rangeTable = { [1] = {}, ["selfhostiletarget"] = {}, ["selffriendlytarget"] = {}, ["formation"] = {} }
LibRange.RangeTable = rangeTable
local mapPointsTable = {}
LibRange.MapPointsTable = mapPointsTable

local MapPointSortOrder  = {}
MapPointSortOrder[ SystemData.MapPips.GROUP_MEMBER ]                        = 1 --32
MapPointSortOrder[ SystemData.MapPips.WARBAND_MEMBER ]                      = 1 --33
MapPointSortOrder[ SystemData.MapPips.ORDER_ARMY ]                          = 1 --34
MapPointSortOrder[ SystemData.MapPips.DESTRUCTION_ARMY ]                    = 1 --35
local NUM_SORTED_MAP_POINT_TYPES = 1--4 --41
local FORMATION_INDEX = 1

local GetMapPointData = GetMapPointData
local TargetObjectType = SystemData.TargetObjectType
local TargetTypes = GameData.TargetTypes

local table_insert = table.insert
local table_remove = table.remove
local ipairs = ipairs
local pairs = pairs
local next = next
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local type = type

local playerMaxRange
local losCache = false
local playersName = L""
local function GetPlayersName()
	if (playersName == L"") then
	    playersName = (GameData.Player.name)--:match(L"([^^]+)^?([^^]*)")
	end	
	return playersName	
end

--local playerGroup
local friendlyTargetName = L""
local hostileTargetName = L""
--local scIndex = 0

local timeSinceUpdate = 0.0
local UPDATE_FREQ_MISSING = 0.6
local UPDATE_FREQ_NOMISSING = 0.3
local UPDATE_FREQ = 0.4
--local timeSinceFullScan = 0.0
--local fullScanThrottle = 2.3	-- safety net
local fullScanState = 0
local numMissing = 0

-- maximal range the player has on friendly target; unused
local function getMaxRange(targetType)
	-- First step: get current abilities
	local CurrentAbilities = GetAbilityTable(GameData.AbilityType.STANDARD)

	local Result_max = 0 -- = LibRange.TargetRange.MAX_RANGE

	for abilityId, abilityData in pairs(CurrentAbilities) do
		if abilityData.targetType == targetType then
			local minRange, maxRange = GetAbilityRanges(abilityId)
			if maxRange ~= 0 then
				Result_max = math_max(Result_max, maxRange)--math.min(Result_max, maxRange)
			end
		end
	end

	-- Final step: return result
	return Result_max
end


--------------------------------------------------------------------------------
--								Event System								  --
--------------------------------------------------------------------------------
local EventCallbacks = {
	["formation"] = {},
	["selffriendlytarget"] = {},
	["selffriendlytargetLOS"] = {},
	["selfhostiletarget"] = {}
}
--LibRange.EventCallbacks = EventCallbacks -- for debugging

local function BroadcastRangeEvent(Event,...)
	local events = EventCallbacks[Event]
	if events == nil then return end
	for callbck, userData in pairs(events) do
		callbck(userData,...)
	end
end

--- Register for a LibRange event
function LibRange.RegisterEventHandler(Event, CallbackFunction, arbObj, RawName)
	local events = EventCallbacks[Event]
	if next(events) == nil then
		if Event == "formation" then
			WindowRegisterCoreEventHandler("LibRangeUpdate", "OnUpdate", "LibRange.OnUpdate")
		elseif ((next(EventCallbacks["selffriendlytargetLOS"]) == nil) and (next(EventCallbacks["selffriendlytarget"]) == nil) and next(EventCallbacks["selfhostiletarget"]) == nil) then
			RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "LibRange.OnPlayerTargetUpdated")
			RegisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_ENABLED_STATE_CHANGED, "LibRange.OnPlayerHotBarEnabledStateChanged")
		end
	end
	
	if Event == "formation" then
		if not events[RawName] then
			events[RawName] = {}
			mapPointsTable[RawName] = -1
			rangeTable[RawName] = -1
		end
		events[RawName][CallbackFunction] = arbObj or "nil"
	else
		--table_insert(events, {UserData = arbObj, Func = CallbackFunction})
		events[CallbackFunction] = arbObj
	end
end

--- Unregister a LibRange event
function LibRange.UnregisterEventHandler(Event, CallbackFunction, arbObj, RawName)
	local events = EventCallbacks[Event]
	if Event == "formation" then
		local eventsForRawName = events[RawName]
		if not eventsForRawName then return end
		eventsForRawName[CallbackFunction] = nil
		if next(eventsForRawName) == nil then
			-- no one cares about this poor guy anymore
			events[RawName] = nil
			mapPointsTable[RawName] = nil
			rangeTable[RawName] = nil
			if (next(events) == nil) then WindowUnregisterCoreEventHandler("LibRangeUpdate", "OnUpdate") end
		end
	else	
		events[CallbackFunction] = nil
		if (next(EventCallbacks["selffriendlytargetLOS"]) == nil) and (next(EventCallbacks["selffriendlytarget"]) == nil) and (next(EventCallbacks["selfhostiletarget"]) == nil) then
			-- this is the very last event register that is interested in targets
			UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "LibRange.OnPlayerTargetUpdated")
			UnregisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_ENABLED_STATE_CHANGED, "LibRange.OnPlayerHotBarEnabledStateChanged")
		end
	end
end

--
-- Minimap
--
--[[local function adjustDistance(distance)
	local roundTo
	if ( SystemData.Territory.KOREA ) then
		roundTo = 5       -- 5 meters
		--local footToMeter = 0.3048							
		distance = distance * 0.3048 --footToMeter
	else
		roundTo = 10      -- 10 feet
	end
	return math_floor(distance / roundTo + 0.5) * roundTo
end]]--

local function conditionalBroadcast(rawname, distance)	-- Event == sortIndex
	-- Adjust distance
	--local adjustedDistance = adjustDistance(distance)
	if ( SystemData.Territory.KOREA ) then
		distance = math_floor(distance * 0,0554181818181818) * 5
	else
		distance = math_floor(distance * 0.0952380952380952) * 10
	end

	if rangeTable[rawname] ~= distance then
		--DEBUG(L"conditionalBroadcast: "..rawname..L" "..distance)
		rangeTable[rawname] = distance
		--BroadcastRangeEvent(Event, rawname, adjustedDistance)
		-- "BroadcastMapRangeEvent"
		local events = EventCallbacks.formation[rawname]
		if events == nil then
			DEBUG(L"conditionalBroadcast: events == nil!")
			return
		end
		for callbck, userData in pairs(events) do
			callbck(userData, rawname, distance)
		end
		if rawname == friendlyTargetName then
			BroadcastRangeEvent("selffriendlytarget", rawname, distance)
		end
	end
end

local stepTable = {0,50,100,150,200,250,300,350,400,450,511}
function LibRange.FullScan()
	for ptIndex = stepTable[fullScanState] + 1, stepTable[fullScanState+1] do
        local ptData = GetMapPointData( "EA_Window_OverheadMapMapDisplay", ptIndex )
        if (ptData ~= nil) then
			local name = ptData.name
			if name ~= nil and mapPointsTable[name] ~= nil then 
				--if mapPointsTable[name].pointIndex == nil then
				if mapPointsTable[name] == -1 then
					--ptData.pointIndex = ptIndex
					
					--[[if LibRange.highestPointIndex < ptIndex then	-- find out more about the range
						LibRange.highestPointIndex = ptIndex
					elseif LibRange.lowestPointIndex > ptIndex then
						LibRange.lowestPointIndex = ptIndex
					end]]--
				
					mapPointsTable[name] = ptIndex
					numMissing = numMissing - 1
				end
				conditionalBroadcast(name, ptData.distance) -- while we´re here...
				if numMissing == 0 then
					break 
				end
			end
			--[[local sortIndex = MapPointSortOrder[ptData.pointType]
			if (sortIndex ~= nil) then				
				local name = ptData.name
				if mapPointsTable[sortIndex][name] ~= nil then 
					if mapPointsTable[sortIndex][name].pointIndex == nil then
						ptData.pointIndex = ptIndex
						mapPointsTable[sortIndex][name] = ptData
						numMissing = numMissing - 1
					end
					conditionalBroadcast(sortIndex, name, ptData.distance) -- while we´re here...
					if numMissing == 0 then
						break 
					end
				end
			end]]--
		end
    end

	if numMissing == 0 then
		--DEBUG(L"MapPointsTable refreshed")
		--EA_ChatWindow.Print(L"MapPointsTable refreshed")
		fullScanState = 0
		UPDATE_FREQ = UPDATE_FREQ_NOMISSING
	else
		--DEBUG(L"Not every member has been found!")
		--EA_ChatWindow.Print(L"Not every member has been found!")
		if fullScanState < #stepTable - 1 then -- or next? difference?
			fullScanState = fullScanState + 1
		else
			fullScanState = 1
		end
	end
end

function LibRange.ParseMouseOverPoints()--( mapDisplay, points)
	--DEBUG(L"Parsing MouseOverPoints")
	
	numMissing = 0
	--for sortIndex = 1, NUM_SORTED_MAP_POINT_TYPES do
	for name, pointIndex in pairs(mapPointsTable) do	--(mapPointsTable[sortIndex]) do	
		--if ptData then			
		--if (ptData.) then
		local point = GetMapPointData("EA_Window_OverheadMapMapDisplay", pointIndex)
		if (point and (point.name == name)) then
			conditionalBroadcast(name, point.distance)
		else
			--ptData.pointIndex = nil
			mapPointsTable[name] = -1
			numMissing = numMissing + 1
			--DEBUG(name..L" not found in Cache")
		end
		--end
		
		--if (not ptData.pointIndex) then
		--if mapPointsTable[name] == -1 then
			--DEBUG(L"No cached value for "..name..L" ...refreshing")
			
		--end
		--end
	end
	--end
	if numMissing == 0 then
		fullScanState = 0
	elseif fullScanState == 0 then 
		fullScanState = 1
		UPDATE_FREQ = UPDATE_FREQ_MISSING
	end
end


--
-- Hotbar range info
--
local function computeRange(targetType)

	-- First step: get current abilities
	-- TODO: (MrAngel) have to link some morales too
	local CurrentAbilities = GetAbilityTable(GameData.AbilityType.STANDARD)

	local Result_min = LibRange.TargetRange.MIN_RANGE
	local Result_max = LibRange.TargetRange.MAX_RANGE

	for abilityId, abilityData in pairs(CurrentAbilities) do
		if abilityData.targetType == targetType then
			local isValid, hasTarget = IsTargetValid(abilityId)
			local minRange, maxRange = GetAbilityRanges(abilityId)
			if isValid and maxRange ~= 0 then
				Result_max = math_min(Result_max, maxRange)
				Result_min = math_max(Result_min, minRange)
			end
		end
	end

	-- Final step: return result
	return Result_min, Result_max
end

local function getRange(targetType)
	if	targetType == TargetObjectType.ALLY_PLAYER or
			targetType == TargetObjectType.ALLY_NON_PLAYER or
			targetType == TargetObjectType.STATIC then
		return computeRange(TargetTypes.TARGET_ALLY)
	elseif	targetType == TargetObjectType.ENEMY_PLAYER or
			targetType == TargetObjectType.ENEMY_NON_PLAYER or
			targetType == TargetObjectType.STATIC_ATTACKABLE then
		return computeRange(TargetTypes.TARGET_ENEMY)
	elseif	targetType == 2 then
		return computeRange(TargetTypes.TARGET_PET)
	end
end

local function ComputeLosEvent(range)
	if range < playerMaxRange then -- in range
		local Min, Max = getRange(TargetInfo:UnitType("selffriendlytarget"))
		if Max == LibRange.TargetRange.MAX_RANGE and losCache == true then -- out of sight
			losCache = false
		elseif Max ~= LibRange.TargetRange.MAX_RANGE and losCache == false then -- in sight
			losCache = true
		elseif losCache == nil then -- first run
			losCache = (Max ~= LibRange.TargetRange.MAX_RANGE)
		else
			return
		end
		--DEBUG(L"Broadcasting selffriendlytargetLOS event")
		BroadcastRangeEvent("selffriendlytargetLOS", friendlyTargetName, losCache)
	end
end

-- there could be efficiency improvements here: make sure it does not get triggered too often
local isLastTargetInMap = false
local buttonThrottle = {}
function LibRange.OnPlayerHotBarEnabledStateChanged(buttonId, _, isTargetValid, _)--(buttonId, isSlotEnabled, isTargetValid, isSlotBlocked)
	
	-- range seems to be determined by isTargetValid
	if buttonThrottle[buttonId] == isTargetValid then
		return -- filter enabled and blocked changes
	end
	buttonThrottle[buttonId] = isTargetValid
	--d(L"Hotbar enabled changed: "..buttonId, isTargetValid)
	
	-- First step: check for current friendly targetId
	if friendlyTargetName and friendlyTargetName ~= L"" then
		if friendlyTargetName == GetPlayersName() then
			losCache = true
			BroadcastRangeEvent("selffriendlytargetLOS", friendlyTargetName, losCache)
		else
			local range = rangeTable[friendlyTargetName] --rangeTable[1][friendlyTargetName] or rangeTable[2][friendlyTargetName] or rangeTable[3][friendlyTargetName] or rangeTable[4][friendlyTargetName]
			if range then	-- range is provided by Map data already, compute LOS instead
				ComputeLosEvent(range)
				isLastTargetInMap = true
			else
				local rangeTable = rangeTable["selffriendlytarget"]
				local Min, Max = getRange(TargetInfo:UnitType("selffriendlytarget"))
				if isLastTargetInMap or rangeTable.RangeMin ~= Min or rangeTable.RangeMax ~= Max then
					rangeTable.RangeMin = Min
					rangeTable.RangeMax = Max
					isLastTargetInMap = false
					BroadcastRangeEvent("selffriendlytarget", friendlyTargetName, Max, Min)
				end
			end
		end
	end

	-- Second step: check for current hostile targetId
	if hostileTargetName and hostileTargetName ~= L"" then
		local range = rangeTable["selfhostiletarget"]
		local Min, Max = getRange(TargetInfo:UnitType("selfhostiletarget"))
		if range.RangeMin ~= Min or range.RangeMax ~= Max then
			range.RangeMin	= Min
			range.RangeMax	= Max
			BroadcastRangeEvent("selfhostiletarget", hostileTargetName, Max, Min)
		end
	end
end

function LibRange.OnPlayerTargetUpdated(targetType)
	if targetType == "mouseovertarget" then return end
	TargetInfo:UpdateFromClient()
	if targetType == "selffriendlytarget" then
		friendlyTargetName = TargetInfo:UnitName("selffriendlytarget")
	else
		hostileTargetName = TargetInfo:UnitName("selfhostiletarget")
	end
	LibRange.OnPlayerHotBarEnabledStateChanged()
end

local pause = false
function LibRange.PauseNextFrame()
	pause = true
end

function LibRange.OnUpdate(elapsed)
	--if not (isInitialized and isLoaded) then return end
	timeSinceUpdate = timeSinceUpdate + elapsed
	if pause then
		pause = false
		return
	elseif timeSinceUpdate < UPDATE_FREQ then 
		if fullScanState > 0 then
			LibRange.FullScan()
		end
	else
		LibRange.ParseMouseOverPoints()
		timeSinceUpdate = 0.0
	end
end

function LibRange.Initialize()
	RegisterEventHandler(SystemData.Events.LOADING_END, "LibRange.OnLoad")
	CreateWindowFromTemplate("LibRangeUpdate", "EA_Window_Default", "Root")		-- wild template guessing olé olé; I think this one has a sound onshow -.-
	WindowSetShowing("LibRangeUpdate", true)
end

function LibRange.OnLoad()
	UnregisterEventHandler(SystemData.Events.LOADING_END, "LibRange.OnLoad")
	playerMaxRange = getMaxRange(TargetTypes.TARGET_ALLY)
end

function LibRange.Shutdown()
end

function LibRange.SetUpdateFreq(newUpdateFreq)
	UPDATE_FREQ = newUpdateFreq
end

function LibRange.GetUpdateFreq(newUpdateFreq)
	return UPDATE_FREQ
end

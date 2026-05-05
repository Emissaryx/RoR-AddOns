local wstring_gsub					= wstring.gsub
local IsWarBandActive				= IsWarBandActive
local pairs							= pairs
local ipairs						= ipairs
local GetMapPointData				= GetMapPointData
local GetAbilityTable				= GetAbilityTable
local IsTargetValid					= IsTargetValid
local GetAbilityRanges				= GetAbilityRanges
local math_min						= math.min
local math_max						= math.max
local table_insert					= table.insert
local table_remove					= table.remove

RVAPI_Range							= {}
local RVAPI_Range					= RVAPI_Range

local RVName						= "Range API"
local RVCredits						= "finalfatex, Philosound"
local RVLicense						= "MIT License"
local RVProjectURL					= "http://www.returnofreckoning.com/forum/viewtopic.php?f=11&t=4534"
local RVRecentUpdates				= 
"09.07.2015 - v2.04 Release\n"..
"\t- Project official site location has been changed\n"..
"\n"..
"24.11.2010 - v2.03 Release\n"..
"\t- RVAPI_Range should gather distances information on-demand now\n"..
"\n"..
"12.09.2010 - v2.02 Release\n"..
"\t- Default update delay changed to zero\n"..
"\t- Fixed an issue then a second addon registration won't hit callbacks\n"..
"\n"..
"06.09.2010 - v2.01 Release\n"..
"\t- Small improvements and optimizations been made\n"..
"\n"..
"25.08.2010 - v2.00 Release\n"..
"\t- Max range has been changed to the 32bit number\n"..
"\t- Map distances idea has been implemented\n"..
"\t- API functions list has been changed\n"..
"\t- GUI settings\n"..
"\n"..
"24.02.2010 - v1.02 Release\n"..
"\t- Code clearance\n"..
"\t- Adapted to work with the RV Mods Manager v0.99"

local WindowRangeSettings			= "RVAPI_RangeSettingsWindow"

local TargetCallbacks				= {}
local TargetIndexes					= {}

local TargetFH						= {
	selffriendlytarget				= {
		name						= L"",
	},
	selfhostiletarget				= {
		name						= L"",
	},
}

local CurrentPlayerPositionX		= 0
local CurrentPlayerPositionY		= 0

local OnUpdateTimer					= 0
local DistancesLastUpdateDelay		= 0
local IndexesUpdateRequired			= false

local RegisterEventHandlersCounter	= 0

-- : distances min and max values
RVAPI_Range.Ranges					= {
	MIN_RANGE						= 0,
	MAX_RANGE						= 4294967295,
}

-- : range types
RVAPI_Range.RangeType				= {
	RANGE_TYPE_MAP					= 1,
	RANGE_TYPE_SPELLS				= 2,
}

-- : delay types
RVAPI_Range.DelayType				= {
	DELAY_EXACT_TIME				= 1,
	DELAY_DIFFERENCE_DETECTED		= 2,
}

-------------------------------------------------------------
-- var DefaultConfiguration
-- Description: default module configuration
-------------------------------------------------------------
RVAPI_Range.DefaultConfiguration =
{
--	Enabled					= true,

	MapDistancesEnabled		= true,
	MapDistancesUpdateDelay	= 0,
}

-------------------------------------------------------------
-- var CurrentConfiguration
-- Description: current module configuration
-------------------------------------------------------------
RVAPI_Range.CurrentConfiguration =
{
	-- should stay empty, will load in the InitializeConfiguration() function
}

-------------------------------------------------------------
-- function Initialize()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.Initialize()

	-- First step: load configuration
	RVAPI_Range.InitializeConfiguration()

	-- Second step: define event handlers
	RegisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED,					"RVAPI_Range.OnAllModulesInitialized")
--[[
	RegisterEventHandler(SystemData.Events.LOADING_END,								"RVAPI_Range.OnLoadingEnd")
	RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED,						"RVAPI_Range.OnPlayerZoneChanged")
	RegisterEventHandler(SystemData.Events.PLAYER_POSITION_UPDATED,					"RVAPI_Range.OnPlayerPositionUpdated")
	RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED,					"RVAPI_Range.OnPlayerTargetUpdated")
	RegisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_ENABLED_STATE_CHANGED,	"RVAPI_Range.OnPlayerHotBarEnabledStateChanged")
	RegisterEventHandler(SystemData.Events.GROUP_UPDATED,							"RVAPI_Range.OnGroupUpdated")
	RegisterEventHandler(SystemData.Events.BATTLEGROUP_UPDATED,						"RVAPI_Range.OnBattlegroupUpdated")
	RegisterEventHandler(SystemData.Events.SCENARIO_PLAYERS_LIST_UPDATED,			"RVAPI_Range.OnScenarioPlayersListUpdated")
]]
end

-------------------------------------------------------------
-- function Shutdown()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.Shutdown()

	-- First step: destroy settings window
	if DoesWindowExist(WindowRangeSettings) then
		DestroyWindow(WindowRangeSettings)
	end

	-- Final step: unregister all events
	UnregisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED,				"RVAPI_Range.OnAllModulesInitialized")
--[[
	UnregisterEventHandler(SystemData.Events.LOADING_END,							"RVAPI_Range.OnLoadingEnd")
	UnregisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED,					"RVAPI_Range.OnPlayerZoneChanged")
	UnregisterEventHandler(SystemData.Events.PLAYER_POSITION_UPDATED,				"RVAPI_Range.OnPlayerPositionUpdated")
	UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED,					"RVAPI_Range.OnPlayerTargetUpdated")
	UnregisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_ENABLED_STATE_CHANGED,	"RVAPI_Range.OnPlayerHotBarEnabledStateChanged")
	UnregisterEventHandler(SystemData.Events.GROUP_UPDATED,							"RVAPI_Range.OnGroupUpdated")
	UnregisterEventHandler(SystemData.Events.BATTLEGROUP_UPDATED,					"RVAPI_Range.OnBattlegroupUpdated")
	UnregisterEventHandler(SystemData.Events.SCENARIO_PLAYERS_LIST_UPDATED,			"RVAPI_Range.OnScenarioPlayersListUpdated")
]]
end

-------------------------------------------------------------
-- function InitializeConfiguration()
-- Description: loads current configuration
-------------------------------------------------------------
function RVAPI_Range.InitializeConfiguration()

	-- First step: move default value to the CurrentConfiguration variable
	for k,v in pairs(RVAPI_Range.DefaultConfiguration) do
		if(RVAPI_Range.CurrentConfiguration[k]==nil) then
			RVAPI_Range.CurrentConfiguration[k]=v
		end
	end
end

-------------------------------------------------------------
-- function OnAllModulesInitialized()
-- Description: event ALL_MODULES_INITIALIZED
-- We can start working with the RVAPI just then we sure they are all initialized
-- and ready to provide their services
-------------------------------------------------------------
function RVAPI_Range.OnAllModulesInitialized()

	-- First step: set IndexesUpdateRequired flag
	IndexesUpdateRequired = true

	-- Final step: register in the RV Mods Manager
	-- Please note the folowing:
	-- 1. always do this ON SystemData.Events.ALL_MODULES_INITIALIZED event
	-- 2. you don't need to add RVMOD_Manager to the dependency list
	-- 3. the registration code should be same as below, with your own function parameters
	-- 4. for more information please follow by project official site
	if RVMOD_Manager then
		RVMOD_Manager.API_RegisterAddon("RVAPI_Range", RVAPI_Range, RVAPI_Range.OnRVManagerCallback)
	end
end

-------------------------------------------------------------
-- function OnRVManagerCallback
-- Description:
-------------------------------------------------------------
function RVAPI_Range.OnRVManagerCallback(Self, Event, EventData)

	if		Event == RVMOD_Manager.Events.NAME_REQUESTED then

		return RVName

	elseif	Event == RVMOD_Manager.Events.CREDITS_REQUESTED then

		return RVCredits

	elseif	Event == RVMOD_Manager.Events.LICENSE_REQUESTED then

		return RVLicense

	elseif	Event == RVMOD_Manager.Events.PROJECT_URL_REQUESTED then

		return RVProjectURL

	elseif	Event == RVMOD_Manager.Events.RECENT_UPDATES_REQUESTED then

		return RVRecentUpdates

	elseif	Event == RVMOD_Manager.Events.PARENT_WINDOW_UPDATED then

		if not DoesWindowExist(WindowRangeSettings) then
			RVAPI_Range.InitializeSettingsWindow()
		end

		WindowSetParent(WindowRangeSettings, EventData.ParentWindow)
		WindowClearAnchors(WindowRangeSettings)
		WindowAddAnchor(WindowRangeSettings, "topleft", EventData.ParentWindow, "topleft", 0, 0)
		WindowAddAnchor(WindowRangeSettings, "bottomright", EventData.ParentWindow, "bottomright", 0, 0)

		RVAPI_Range.UpdateSettingsWindow()

		return true

	end
end

-------------------------------------------------------------
-- function InitializeSettingsWindow()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.InitializeSettingsWindow()

	-- First step: create main window
	CreateWindow(WindowRangeSettings, true)

	-- Second step: define strings
	LabelSetText(WindowRangeSettings.."LabelMapDistancesEnabled", L"Use Map Distances Information")
	LabelSetTextColor(WindowRangeSettings.."LabelMapDistancesEnabled", 255, 255, 255)

	LabelSetText(WindowRangeSettings.."SliderBarMapDelayMinLabel", L"0 sec")
	LabelSetText(WindowRangeSettings.."SliderBarMapDelayMidLabel", L"5 sec")
	LabelSetText(WindowRangeSettings.."SliderBarMapDelayMaxLabel", L"10 sec")

	LabelSetText(WindowRangeSettings.."LabelImportantInformation", L"ATTENTION!!! For better performance untick the \"Use Map Distances Information\" or increase the \"delay\" timer.")
	LabelSetTextColor(WindowRangeSettings.."LabelImportantInformation", DefaultColor.RED.r, DefaultColor.RED.g, DefaultColor.RED.b)
end

-------------------------------------------------------------
-- function UpdateSettingsWindow()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.UpdateSettingsWindow()

	-- First step:
	ButtonSetPressedFlag(WindowRangeSettings.."CheckBoxMapDistancesEnabled", RVAPI_Range.CurrentConfiguration.MapDistancesEnabled)

	-- Second step:
	SliderBarSetCurrentPosition(WindowRangeSettings.."SliderBarMapDelay", RVAPI_Range.CurrentConfiguration.MapDistancesUpdateDelay / 10)
end

-------------------------------------------------------------
-- function OnLoadingEnd()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.OnLoadingEnd()

	-- Final step: set IndexesUpdateRequired flag
	IndexesUpdateRequired = true
end

-------------------------------------------------------------
-- function OnPlayerZoneChanged()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.OnPlayerZoneChanged()

	-- Final step: set IndexesUpdateRequired flag
	IndexesUpdateRequired = true
end

-------------------------------------------------------------
-- function OnPlayerPositionUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.OnPlayerPositionUpdated(X, Y)

	-- First step: we shoud not do anything if in scenario 
	if not GameData.Player.isInScenario then

		-- Second step: define locals
		local PositionX	= math.floor(X / 1000)
		local PositionY	= math.floor(Y / 1000)

		-- Third step: check for the position difference
		if	PositionX ~= CurrentPlayerPositionX or
			PositionY ~= CurrentPlayerPositionY then

			-- : update a player position
			CurrentPlayerPositionX	= PositionX
			CurrentPlayerPositionY	= PositionY

			-- : mark indexes for saving
			IndexesUpdateRequired	= true
		end
	end
end

-------------------------------------------------------------
-- function OnPlayerTargetUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.OnPlayerTargetUpdated(targetClassification, targetId, targetType)
	-- |targetClassification: selfhostiletarget,selffriendlytarget,mouseovertarget | --
	-- |targetId: unique id for target in zone | --
	-- |targetType: 0 = No Target, 1 = Player, 2 = Player's Pet, 3 = Friendly PC, 4 = Friendly NPC/Pet, 5 = Hostile Player, 6 = Hostile NPC/Pet

	-- First step: check for the target classification
	if targetClassification == "selffriendlytarget" or targetClassification == "selfhostiletarget" then

		-- Second step: get an old target name
		local OLDTargetName = wstring_gsub(TargetFH[targetClassification].name, L"(^.)", L"")

		-- Third step: we have to remember the current friendly and hostile targets, so let's do it
		TargetFH[targetClassification] = GetUpdatedTargets()[targetClassification]

		-- Fourth step: get a new target name
		local NEWTargetName = wstring_gsub(TargetFH[targetClassification].name, L"(^.)", L"")

		-- Fifth step: compare names
		if	OLDTargetName ~= NEWTargetName then

			-- : target has been changed, update old target
			RVAPI_Range.UpdateBySpellsRange(OLDTargetName)

			-- : update new target
			RVAPI_Range.UpdateBySpellsRange(NEWTargetName)
		end
	end
end

-------------------------------------------------------------
-- function OnPlayerHotBarEnabledStateChanged()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.OnPlayerHotBarEnabledStateChanged(buttonId, isSlotEnabled, isTargetValid, isSlotBlocked)

	-- : update friendly target
	RVAPI_Range.UpdateBySpellsRange(wstring_gsub(TargetFH.selffriendlytarget.name, L"(^.)", L""))

	-- : update hostile target
	RVAPI_Range.UpdateBySpellsRange(wstring_gsub(TargetFH.selfhostiletarget.name, L"(^.)", L""))
end

-------------------------------------------------------------
-- function OnGroupUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.OnGroupUpdated()

	-- First step: check warband is not active and scenario is not active
	if not IsWarBandActive() and not GameData.Player.isInScenario then

		-- Second step: set IndexesUpdateRequired flag
		IndexesUpdateRequired = true
	end
end

-------------------------------------------------------------
-- function OnBattlegroupUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.OnBattlegroupUpdated()

	-- First step: check warband is active and not in scenario
	if IsWarBandActive() and not GameData.Player.isInScenario then

		-- Second step: set IndexesUpdateRequired flag
		IndexesUpdateRequired = true
	end
end

-------------------------------------------------------------
-- function OnScenarioPlayersListUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.OnScenarioPlayersListUpdated()

	-- First step: check if in scenario
	-- TODO: (MrAngel) are we really need that check???
	if GameData.Player.isInScenario then

		-- Second step: set IndexesUpdateRequired flag
		IndexesUpdateRequired = true
	end
end

-------------------------------------------------------------
-- function OnUpdate()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.OnUpdate(timePassed)

	-- First step: update local timer
	OnUpdateTimer = OnUpdateTimer + timePassed

	-- Second step: check if map distances calculation is enabled
	if RVAPI_Range.CurrentConfiguration.MapDistancesEnabled and RegisterEventHandlersCounter > 0 then

		-- Third step: update indexes if required
		if IndexesUpdateRequired then

			-- : mark indexes are updated
			IndexesUpdateRequired = false

			-- : save all available indexes
			RVAPI_Range.UpdateIndexes()
		end

		-- Fourth step: update distances
		if OnUpdateTimer - DistancesLastUpdateDelay  >= RVAPI_Range.CurrentConfiguration.MapDistancesUpdateDelay then

			-- : update timer
			DistancesLastUpdateDelay = OnUpdateTimer

			-- : update all registered targets
			RVAPI_Range.UpdateTargets()
		end
	end
end

-------------------------------------------------------------
-- function UpdateTargets()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.UpdateTargets()

	-- First step: list all the registered names for tracking
	for TargetName, CallbackFunctions in pairs(TargetCallbacks) do

		-- Second step: update all target distances
		RVAPI_Range.UpdateTargetDistances(TargetName)
	end
end

-------------------------------------------------------------
-- function UpdateTargetDistances()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.UpdateTargetDistances(TargetName)

	-- : check if indexes list is set
	-- : if this is not set, we will use the spells information instead
	if TargetIndexes[TargetName] and RVAPI_Range.CurrentConfiguration.MapDistancesEnabled then

		-- : set a distances type
		TargetCallbacks[TargetName].RangeType = RVAPI_Range.RangeType.RANGE_TYPE_MAP

		-- : update a map distance for the target
		RVAPI_Range.UpdateByMapDistance(TargetName)

	-- : check for the spells data type
	elseif	not TargetCallbacks[TargetName].RangeType or
				TargetCallbacks[TargetName].RangeType ~= RVAPI_Range.RangeType.RANGE_TYPE_SPELLS then

		-- : switch to the spells distances type
		TargetCallbacks[TargetName].RangeType = RVAPI_Range.RangeType.RANGE_TYPE_SPELLS

		-- : update a spells range for the target
		RVAPI_Range.UpdateBySpellsRange(TargetName)
	end
end

-------------------------------------------------------------
-- function UpdateByMapDistance()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.UpdateByMapDistance(TargetName)

	-- : define locals
	local PointData						= nil
	local PointRangeMin					= 0
	local PointRangeMax					= 0
	local Indexes						= TargetIndexes[TargetName] or {}
	local Distances						= TargetCallbacks[TargetName].Distances or {}

	local TargetStatusReceived			= false
	local DistanceChanged				= false

	-- : list all the calback functions are registered for monitoring this name
	for CallbackIndex, CallbackData in ipairs(TargetCallbacks[TargetName].Callbacks) do

		-- : check if update required
		if	(OnUpdateTimer - CallbackData.Timer  >= CallbackData.Delay) or
			(DistanceChanged and CallbackData.DelayType == RVAPI_Range.DelayType.DELAY_DIFFERENCE_DETECTED) then

			-- : check if statuses already set
			if not TargetStatusReceived then

				-- : list all known indices at the moment
				for IndexNumber, IndexData in ipairs(Indexes) do

					-- : get a point data
					PointData = GetMapPointData("EA_Window_WorldMapZoneViewMapDisplay", IndexData.PointIndex);

					-- : check for lost point
					if	(PointData) and
						(PointData.pointType == IndexData.PointType) and
						(wstring_gsub(PointData.name, L"(^.)", L"") == TargetName) then

						-- : save distances in the temporary variable
						PointRangeMin = PointData.distance
						PointRangeMax = PointData.distance
					else

						-- : we got a lost index lets do the total TargetIndexes variable update
						-- : set IndexesUpdateRequired flag
						IndexesUpdateRequired = true

						-- : save distances in the temporary variable
						PointRangeMin = RVAPI_Range.Ranges.MIN_RANGE
						PointRangeMax = RVAPI_Range.Ranges.MAX_RANGE
					end

					-- : check if range been updated
					if	not Distances[IndexNumber] or
						Distances[IndexNumber].RangeMin ~= PointRangeMin or
						Distances[IndexNumber].RangeMax ~= PointRangeMax or
						Indexes[IndexNumber].RangeMin ~= PointRangeMin or
						Indexes[IndexNumber].RangeMax ~= PointRangeMax then

						-- : set new range
						Indexes[IndexNumber].RangeMin = PointRangeMin
						Indexes[IndexNumber].RangeMax = PointRangeMax

						-- : set a distance status
						DistanceChanged = true
					end
				end

				-- : check for the count of distances and DistanceChanged flag
				if  DistanceChanged or #Indexes ~= #Distances then

					-- : set a new distances list
					TargetCallbacks[TargetName].Distances = Indexes

					-- : set a distance status
					DistanceChanged = true
				end
			end

			-- : check for the DistanceChanged flag and timer
			if DistanceChanged or CallbackData.Timer <= 0 then

				-- : raise update event
				CallbackData.Func(CallbackData.Owner, TargetCallbacks[TargetName].Distances, TargetCallbacks[TargetName].RangeType, CallbackData.UserData)
			end

			-- : update Timer
			CallbackData.Timer = OnUpdateTimer
		end
	end
end

-------------------------------------------------------------
-- function UpdateBySpellsRange()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.UpdateBySpellsRange(TargetName)

	-- : check for the TargetName length
	if TargetName:len() <= 0 then

		return
	end

	-- : check for the registered target name
	if not TargetCallbacks[TargetName] then

		return
	end

	-- : check for the distance type
	if TargetCallbacks[TargetName].RangeType and TargetCallbacks[TargetName].RangeType ~= RVAPI_Range.RangeType.RANGE_TYPE_SPELLS then

		return
	end

	-- : define locals
	local ObjectType		= SystemData.TargetObjectType.NONE
	local TargetType		= GameData.TargetTypes.TARGET_NONE
	local ResultMin			= RVAPI_Range.Ranges.MIN_RANGE
	local ResultMax			= RVAPI_Range.Ranges.MAX_RANGE
	local Distances			= TargetCallbacks[TargetName].Distances
	local DistanceChanged	= false

	-- : set a distance type
	TargetCallbacks[TargetName].RangeType = RVAPI_Range.RangeType.RANGE_TYPE_SPELLS

	-- : calculate new range values
	if TargetName == wstring_gsub(GameData.Player.name, L"(^.)", L"") then

		-- : set distance for SELF
		ResultMin	= 0
		ResultMax	= 0
	else

		-- : calculate ObjectType
		if TargetName == wstring_gsub(TargetFH.selffriendlytarget.name, L"(^.)", L"") then
	
			ObjectType = TargetFH.selffriendlytarget.type
	
		elseif TargetName == wstring_gsub(TargetFH.selfhostiletarget.name, L"(^.)", L"") then
	
			ObjectType = TargetFH.selfhostiletarget.type
	
		end
	
		-- : convert ObjectType to the TargetType
		if	ObjectType == SystemData.TargetObjectType.ALLY_PLAYER or
			ObjectType == SystemData.TargetObjectType.ALLY_NON_PLAYER or
			ObjectType == SystemData.TargetObjectType.STATIC then
	
			TargetType	= GameData.TargetTypes.TARGET_ALLY
	
		elseif	ObjectType == SystemData.TargetObjectType.ENEMY_PLAYER or
			ObjectType == SystemData.TargetObjectType.ENEMY_NON_PLAYER or
			ObjectType == SystemData.TargetObjectType.STATIC_ATTACKABLE then
	
			TargetType	= GameData.TargetTypes.TARGET_ENEMY
	
		elseif	ObjectType == 2 then
	
			TargetType	= GameData.TargetTypes.TARGET_PET
	
		end

		-- : define more locals
		local CurrentAbilities	= GetAbilityTable(GameData.AbilityType.STANDARD)

		-- : check for every available ability and calculate the range
		for abilityId, abilityData in pairs(CurrentAbilities) do
			if abilityData.targetType == TargetType then
				local isValid, hasTarget = IsTargetValid(abilityId)
				local minRange, maxRange = GetAbilityRanges(abilityId)
				if isValid and maxRange~=0 then
					ResultMax = math_min(ResultMax, maxRange)
					ResultMin = math_max(ResultMin, minRange)
				end
			end
		end
	end

	-- : check for the count of distances
	if  not Distances or
		not Distances[1] or
			Distances[1].RangeMin ~= ResultMin or
			Distances[1].RangeMax ~= ResultMax or
			#Distances > 1 then

		-- : set a new distances list
		TargetCallbacks[TargetName].Distances	= {
			[1]									= {
				RangeMin						= ResultMin,
				RangeMax						= ResultMax,
			}
		}

		-- : set a distance status
		DistanceChanged	= true
	end

	-- : list all the calback functions are registered for monitoring this name
	for CallbackIndex, CallbackData in ipairs(TargetCallbacks[TargetName].Callbacks) do

		-- : check for the DistanceChanged flag and timer
		if DistanceChanged or CallbackData.Timer <= 0 then

			-- : raise update event
			CallbackData.Func(CallbackData.Owner, TargetCallbacks[TargetName].Distances, TargetCallbacks[TargetName].RangeType, CallbackData.UserData)

			-- : update Timer
			CallbackData.Timer = OnUpdateTimer
		end
	end
end

-------------------------------------------------------------
-- function UpdateIndexes()
-- Description:
-------------------------------------------------------------
function RVAPI_Range.UpdateIndexes()

	-- : define locals
	local PointData			= nil
	local PointName			= nil
	local PointIndexData	= nil

	-- : clear the old point indexes
	TargetIndexes			= {}

	-- : list through all the map points
	-- TODO: (MrAngel) keep an eye on this (500) number.
	for PointIndex = 1, 500 do

		-- : get a first map point
		PointData = GetMapPointData("EA_Window_WorldMapZoneViewMapDisplay", PointIndex);

		-- : check for the PointData
		if	(PointData) then

			-- : get a correct point name
			PointName = wstring_gsub(PointData.name, L"(^.)", L"")

			-- : check for the point name length
			if PointName:len() > 0 then

				-- : check for the TargetIndexes[PointName]
				if TargetIndexes[PointName] == nil then
					TargetIndexes[PointName] = {}
				end

				-- : define new point information
				PointIndexData			= {
					PointIndex			= PointIndex,
					PointType			= PointData.pointType,
					RangeMin			= PointData.distance,
					RangeMax			= PointData.distance,
				}

				-- : update cash of indexes
				table_insert(TargetIndexes[PointName], PointIndexData)
			end
		end
	end
end

-------------------------------------------------------------
-- function GetEventHandlerIndex
-- Description:
-------------------------------------------------------------
function RVAPI_Range.GetEventHandlerIndex(CallbackOwner, CallbackFunction, TargetName)

	-- First step: define locals
	local Result = 0

	-- Second step: find a callback index
	if TargetCallbacks[TargetName] then
		for k, callbck in ipairs(TargetCallbacks[TargetName].Callbacks) do
			if callbck.Owner == CallbackOwner and callbck.Func == CallbackFunction then
				Result = k
				break
			end
		end
	end

	-- Final step: return result
	return Result
end

--------------------------------------------------------------
-- function RegisterEventHandlers
-- Description:
--------------------------------------------------------------
function RVAPI_Range.RegisterEventHandlers()

	-- : check if system event handlers are activated
	if	RegisterEventHandlersCounter <= 0 then

		-- : register all events are needed to start the system
		RegisterEventHandler(SystemData.Events.LOADING_END,								"RVAPI_Range.OnLoadingEnd")
		RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED,						"RVAPI_Range.OnPlayerZoneChanged")
		RegisterEventHandler(SystemData.Events.PLAYER_POSITION_UPDATED,					"RVAPI_Range.OnPlayerPositionUpdated")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED,					"RVAPI_Range.OnPlayerTargetUpdated")
		RegisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_ENABLED_STATE_CHANGED,	"RVAPI_Range.OnPlayerHotBarEnabledStateChanged")
		RegisterEventHandler(SystemData.Events.GROUP_UPDATED,							"RVAPI_Range.OnGroupUpdated")
		RegisterEventHandler(SystemData.Events.BATTLEGROUP_UPDATED,						"RVAPI_Range.OnBattlegroupUpdated")
		RegisterEventHandler(SystemData.Events.SCENARIO_PLAYERS_LIST_UPDATED,			"RVAPI_Range.OnScenarioPlayersListUpdated")
	end

	-- : save the new amount of cals from the addOns
	RegisterEventHandlersCounter = RegisterEventHandlersCounter + 1
end

--------------------------------------------------------------
-- function UnregisterEventHandlers
-- Description:
--------------------------------------------------------------
function RVAPI_Range.UnregisterEventHandlers()

	-- : check if system event handlers are activated and addOn event handler counter is ZERO
	-- : in other words check if anybody still wants to be that system ON
	if	RegisterEventHandlersCounter == 1 then

		-- : unregister all events are needed to work the system
		UnregisterEventHandler(SystemData.Events.LOADING_END,							"RVAPI_Range.OnLoadingEnd")
		UnregisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED,					"RVAPI_Range.OnPlayerZoneChanged")
		UnregisterEventHandler(SystemData.Events.PLAYER_POSITION_UPDATED,				"RVAPI_Range.OnPlayerPositionUpdated")
		UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED,					"RVAPI_Range.OnPlayerTargetUpdated")
		UnregisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_ENABLED_STATE_CHANGED,	"RVAPI_Range.OnPlayerHotBarEnabledStateChanged")
		UnregisterEventHandler(SystemData.Events.GROUP_UPDATED,							"RVAPI_Range.OnGroupUpdated")
		UnregisterEventHandler(SystemData.Events.BATTLEGROUP_UPDATED,					"RVAPI_Range.OnBattlegroupUpdated")
		UnregisterEventHandler(SystemData.Events.SCENARIO_PLAYERS_LIST_UPDATED,			"RVAPI_Range.OnScenarioPlayersListUpdated")
	end

	-- : save the new amount of cals from the addOns
	RegisterEventHandlersCounter = RegisterEventHandlersCounter - 1
	if RegisterEventHandlersCounter < 0 then
		RegisterEventHandlersCounter = 0
	end
end

-------------------------------------------------------------
-- function 
-- Description: events
-------------------------------------------------------------

function RVAPI_Range.OnCheckBoxMapDistancesEnabled()

	-- First step: get checkbox name
	local CheckBoxName = SystemData.MouseOverWindow.name

	-- Second step: invert flag status
	RVAPI_Range.CurrentConfiguration.MapDistancesEnabled = not RVAPI_Range.CurrentConfiguration.MapDistancesEnabled
	ButtonSetPressedFlag(CheckBoxName, RVAPI_Range.CurrentConfiguration.MapDistancesEnabled)

	-- Final step: update all registered targets
	RVAPI_Range.UpdateTargets()
end

function RVAPI_Range.OnSlideMapDelay(sliderPos)

	-- First step: set new delay value
	RVAPI_Range.CurrentConfiguration.MapDistancesUpdateDelay = sliderPos * 10
end


-------------------------------------------------------------------------------
--								RVAPI_Range API								 --
-------------------------------------------------------------------------------

-------------------------------------------------------------
-- function API_RegisterTarget
-- Description:
-------------------------------------------------------------
function RVAPI_Range.API_RegisterTarget(CallbackOwner, CallbackFunction, TargetName, Delay, DelayType, UserData)

	-- First step: define locals
	local TargetName = wstring_gsub((TargetName or L""), L"(^.)", L"")

	-- Second step: check for input data
	if	CallbackOwner == nil or CallbackFunction == nil or TargetName:len() <= 0 then
		return 
	end

	-- Third step: initialize TargetCallbacks if needed
	if TargetCallbacks[TargetName] == nil then
		TargetCallbacks[TargetName] = {}
	end

	-- Fourth step: initialize Callbacks list if needed
	if TargetCallbacks[TargetName].Callbacks == nil then
		TargetCallbacks[TargetName].Callbacks = {}
	end

	-- Fifth step: define locals
	local CallbackIndex	= RVAPI_Range.GetEventHandlerIndex(CallbackOwner, CallbackFunction, TargetName)
	local LDelay		= Delay		or 0
	local LDelayType	= DelayType	or RVAPI_Range.DelayType.DELAY_EXACT_TIME

	-- Sixth step: check if handler already registered
	if CallbackIndex > 0 then

		-- : update user defined delay
		TargetCallbacks[TargetName].Callbacks[CallbackIndex].Delay			= LDelay
		TargetCallbacks[TargetName].Callbacks[CallbackIndex].DelayType		= LDelayType
--		TargetCallbacks[TargetName].Callbacks[CallbackIndex].Timer			= 0

		-- : update user defined data if needed
		if UserData ~= nil then
			TargetCallbacks[TargetName].Callbacks[CallbackIndex].UserData	= UserData
		end
	else

		-- : turn the system ON
		RVAPI_Range.RegisterEventHandlers()

		-- : add new event handler for the specific TargetName
		table_insert(TargetCallbacks[TargetName].Callbacks, {Owner = CallbackOwner, Func = CallbackFunction, Delay = LDelay, DelayType = LDelayType, Timer = 0, UserData = UserData})
	end

	-- Seventh step:	clear the range type value
	--					it should force target update for the new registered callback function
	TargetCallbacks[TargetName].RangeType = nil

	-- Final step: update target distances "out of turn"
	RVAPI_Range.UpdateTargetDistances(TargetName)
end

-------------------------------------------------------------
-- function API_UnregisterTarget
-- Description:
-------------------------------------------------------------
function RVAPI_Range.API_UnregisterTarget(CallbackOwner, CallbackFunction, TargetName)

	-- First step: define locals
	local TargetName				= 	wstring_gsub((TargetName or L""), L"(^.)", L"")
	local DeleteCallbackFunction	=	function (CallbackOwner, CallbackFunction, TargetName)
											local CallbackIndex = RVAPI_Range.GetEventHandlerIndex(CallbackOwner, CallbackFunction, TargetName)
											if CallbackIndex > 0 then
												table_remove(TargetCallbacks[TargetName].Callbacks, CallbackIndex)
												if #TargetCallbacks[TargetName].Callbacks <= 0 then
													TargetCallbacks[TargetName] = nil
												end

												-- : turn the system OFF
												RVAPI_Range.UnregisterEventHandlers()
											end
										end

	-- Second step: find and remove event handler(s)
	if TargetName:len() > 0 then

		-- : delete callback function for the specific name
		DeleteCallbackFunction(CallbackOwner, CallbackFunction, TargetName)
	else

		-- : delete all callback functions
		for TargetName, __ in pairs(TargetCallbacks) do

			-- : delete callback function for the specific name
			DeleteCallbackFunction(CallbackOwner, CallbackFunction, TargetName)
		end
	end
end
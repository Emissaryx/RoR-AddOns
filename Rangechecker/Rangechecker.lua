Rangechecker = {}
Rangechecker = {
	MIN_RANGE					= 0,
	MAX_RANGE					= 65535,
}
RangecheckerSettings = {}
BRWL = {L"must", L"needs", L"only usable", L"costs", L"cannot", L"requires"} --BlackReqWorldList

RCSettingsColor = {
					{r = 254, g = 254, b = 254,},
					{r =   6, g = 242, b =  18,},
					{r = 232, g = 237, b =  12,},
					{r = 227, g = 165, b =  60,},
					{r = 254, g =   0, b =   0,},
					}
RCSettingsColor.iColor = 5

local RangeText = L""
local HADRL = {}  -- HostileAbilityDiffRangeList
local FADRL = {}  -- friendlyAbilityDiffRangeList
local rcBlackNum = 6 -- for Shadow Warriors - 5

local function pprint(text)
    if "string" == type(text) then
        EA_ChatWindow.Print(StringToWString(text))
    else
        EA_ChatWindow.Print(text)
    end
	return
end

-- This function Writes range in the window's label
function Rangechecker.WriteLabel(txt)
    -- Write text in the label
    LabelSetText("RangecheckerWindowLabel", towstring(txt))
    -- Changes the color
    LabelSetTextColor("RangecheckerWindowLabel",
						RCSettingsColor[RCSettingsColor.iColor].r,
						RCSettingsColor[RCSettingsColor.iColor].g,
						RCSettingsColor[RCSettingsColor.iColor].b)
	return
end

function Rangechecker.GetRange(targetType)
	-- STOLEN FROM RVAPI_RANGE
	-- First step: get current abilities
	-- TODO: (MrAngel) have to link some morales too
	local CurrentAbilities = GetAbilityTable(GameData.AbilityType.STANDARD)
	local Result_min = Rangechecker.MIN_RANGE
	local Result_max = Rangechecker.MAX_RANGE

	for abilityId, abilityData in pairs(CurrentAbilities) do
		if abilityData.targetType == targetType then
			local isValid, hasTarget = IsTargetValid(abilityId)
			local minRange, maxRange = GetAbilityRanges(abilityId)
			--if isValid and maxRange~=0 then
			if maxRange~=0 then
				if isValid then
					Result_max = math.min(Result_max, maxRange)
					Result_min = math.max(Result_min, minRange)
				else
					--Result_max = math.min(Result_max, maxRange)
					Result_min = math.max(Result_min, maxRange)
				end
				
			end
		end
	end

	for abilityId, abilityData in pairs(GetAbilityTable(GameData.AbilityType.GRANTED)) do
		if abilityData.targetType == targetType then
			local isValid, hasTarget = IsTargetValid(abilityId)
			local minRange, maxRange = GetAbilityRanges(abilityId)
			if isValid and maxRange~=0 then
				Result_max = math.min(Result_max, maxRange)
				Result_min = math.max(Result_min, minRange)
			end
		end
	end

	for abilityId, abilityData in pairs(GetAbilityTable(GameData.AbilityType.MORALE)) do
		if abilityData.targetType == targetType then
			local isValid, hasTarget = IsTargetValid(abilityId)
			local minRange, maxRange = GetAbilityRanges(abilityId)
			if isValid and maxRange~=0 then
				Result_max = math.min(Result_max, maxRange)
				Result_min = math.max(Result_min, minRange)
			end
		end
	end

	-- Final step: return result
	return Result_min, Result_max
end

function Rangechecker.GetDiffRange()

    local ltable = Player.GetAbilityTable(Player.AbilityType.ABILITY)
	local i_count = 0
	local diff0
	local r_min, r_max
	local abilityData
	--pprint(L"GetDiffRange called")
	HADRL = {}

	if GameData.Player.career.line == GameData.CareerLine.WARRIOR_PRIEST or GameData.Player.career.line == GameData.CareerLine.BLOOD_PRIEST then
		if RangecheckerSettings.targetType == 2 then
			rcBlackNum = 5
		else
			rcBlackNum = 6
		end
	end
	--r_min, r_max = Rangechecker.GetRange(RangecheckerSettings.targetType)
	
    for abilityId in pairs(ltable) do

		--pprint(L"ID:" .. abilityId)
		r_min, r_max = GetAbilityRanges(abilityId)
		abilityData = GetAbilityData (abilityId)
		local reqs = {}
		local reqsPresent = false
		reqs[1], reqs[2], reqs[3] = GetAbilityRequirements (abilityData.id)

		for reqsIndex = 1, 3 do
			if reqs[reqsIndex] ~= L"" then
				--pprint(L"req"..reqsIndex..L": "..reqs[reqsIndex])
				for wordIndex = 1,rcBlackNum do
					if string.find(string.lower(WStringToString(reqs[reqsIndex])), WStringToString(BRWL[wordIndex])) ~= nil then
						reqsPresent = true
					end
					--pprint(L"brwl"..wordIndex..L": "..BRWL[wordIndex])
				end
			end
		end

		--pprint(L"range: " .. r_min .. L"-" .. r_max)
		if reqsPresent == false then

			--pprint(L"reqsPresent=0")
			if abilityData.targetType == RangecheckerSettings.targetType then

				--pprint(L"targetType == 1")
				if r_max ~= 0 then

					--pprint(L"r_max ~= 0")
					diff0 = 1
					for i in pairs(HADRL) do
						if HADRL[i].min_range == r_min then
							if HADRL[i].max_range == r_max then
								diff0 = 0
							end
						end
					end

					--pprint(L"diff0 " .. diff0)
					if diff0 == 1 then
						i_count = i_count + 1

						--pprint(L"i_count " .. i_count)
						HADRL[i_count] = {abilityId = abilityId, min_range = r_min, max_range = r_max}
						--EA_ChatWindow.Print(i_count .. L": (E) "..HADRL[i_count].abilityId .. L" : "..HADRL[i_count].min_range .. L"-"..HADRL[i_count].max_range)
						local iNum = i_count
						while iNum > 1 do
							if HADRL[iNum].max_range < HADRL[iNum - 1].max_range then
								HADRL[iNum], HADRL[iNum - 1] = HADRL[iNum - 1], HADRL[iNum]
							elseif HADRL[iNum].max_range == HADRL[iNum - 1].max_range then
								if HADRL[iNum].min_range < HADRL[iNum - 1].min_range then
									HADRL[iNum], HADRL[iNum - 1] = HADRL[iNum - 1], HADRL[iNum]
								end
							end
							iNum = iNum - 1
						end
					end
				end
			end
		end

	end

--	for i in pairs(HADRL) do
--		EA_ChatWindow.Print(L"i = " .. i)
--		local min_r, max_r = GetAbilityRanges(HADRL[i].abilityId)
--		EA_ChatWindow.Print (HADRL[i].abilityId .. L":" .. L"Ability_Range: " .. min_r .. L"-" .. max_r)
--	end
	return
end

function Rangechecker.OnTargetUpdated()

	if (RangecheckerSettings.Enabled == false) then
		WindowSetShowing("RangecheckerWindowLabel", false)
		WindowSetShowing("RangecheckerWindowClass", false)
		return
	end

	--local targetName = L""
	--local targetCareer = L""
	local targetMain = {}

	if RangecheckerSettings.targetType == 1 then
		targetMain = TargetInfo.m_Units.selfhostiletarget
	end

	if RangecheckerSettings.targetType == 2 then
		targetMain = TargetInfo.m_Units.selffriendlytarget
	end

	if (targetMain == nil) then
		return
	end

	--targetName = TargetInfo.m_Units.selfhostiletarget.name
	--targetCareer = TargetInfo.m_Units.selfhostiletarget.careerName

	if (targetMain.name == L"") then --targetName
		WindowSetShowing("RangecheckerWindowLabel", false)
		WindowSetShowing("RangecheckerWindowClass", false)
		return
	else
		WindowSetShowing("RangecheckerWindowLabel", true)
	end

	if (targetMain.careerName == L"") then --targetCareer
		WindowSetShowing("RangecheckerWindowClass", false)
	else
		LabelSetText("RangecheckerWindowClass", towstring(targetMain.careerName)) --targetCareer
		WindowSetShowing("RangecheckerWindowClass", RangecheckerSettings.ShowCareer)
	end

	if (targetMain.healthPercent ~= 0) then --TargetInfo.m_Units.selfhostiletarget

		local lmin_r, lmax_r = 0, 500
		RCSettingsColor.iColor = 5
		lmin_r, lmax_r = Rangechecker.GetRange(RangecheckerSettings.targetType)
		if lmax_r > 500 then
			RangeText = L"N/A"
			--pprint(L"color: " .. RCSettingsColor.iColor)
		else
			RangeText = lmin_r .. L"-" .. lmax_r
			--pprint(L""..RCSettingsColor.iColor)
		end
		--[[
		for i in pairs(HADRL) do

			local valid, selected = IsTargetValid(HADRL[i].abilityId)

			if valid then
				if lmin_r < HADRL[i].min_range then
					lmin_r = HADRL[i].min_range
				end

				if lmax_r > HADRL[i].max_range then
					lmax_r = HADRL[i].max_range
				end
				if RCSettingsColor.iColor == 5 then
					RCSettingsColor.iColor = i
				end
			end
		end
			--pprint(L"Not in LoS " .. GameData.AbilityResult.NOTVISIBLECLIENT)
			--pprint(L"DEAD " .. GameData.AbilityResult.DEAD)

		if lmax_r == 500 then
			RangeText = L"Out of range"
			--pprint(L"color: " .. RCSettingsColor.iColor)
		else
			RangeText = lmin_r .. L"-" .. lmax_r
			--pprint(L""..RCSettingsColor.iColor)
		end
		]]

	else
		RangeText = L"Dead"
		RCSettingsColor.iColor = 5
	end

	Rangechecker.WriteLabel(RangeText)

	--RangecheckerSettings.HADRL = HADRL
	RangecheckerSettings.target = TargetInfo.m_Units
	return
end

function Rangechecker.Initialize()

    RegisterEventHandler(SystemData.Events.PLAYER_POSITION_UPDATED, "Rangechecker.OnTargetUpdated")
	RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "Rangechecker.OnTargetUpdated")
	RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "Rangechecker.GetDiffRange")
	RegisterEventHandler(SystemData.Events.ENTER_WORLD, "Rangechecker.GetDiffRange")

	if GameData.Player.career.line == GameData.CareerLine.SHADOW_WARRIOR then
		rcBlackNum = 5
		RegisterEventHandler(SystemData.Events.PLAYER_STANCE_UPDATED, "Rangechecker.StanceChanged")
	end

	if GameData.Player.career.line == GameData.CareerLine.SQUIG_HERDER then
		RangecheckerSettings.LastPetName = GameData.Player.Pet.name
		RegisterEventHandler(SystemData.Events.PLAYER_PET_UPDATED, "Rangechecker.PetUpdate")
	end

	CreateWindow("RangecheckerWindow", true)
    LayoutEditor.RegisterWindow( "RangecheckerWindow",
                                L"Distance",
                                L"Displays the distance to enemy target.",
                                false, false,
                                true, nil )

	pprint("Rangechecker version 1.01 has loaded. Press \/rchelp for help.")

	local success = LibSlash.RegisterSlashCmd("rchelp", function() Rangechecker.Help() end)
	if (success ~= true) then
		pprint(L"Could not register rchelp")
	end

	success = LibSlash.RegisterSlashCmd("rctoggle", function() Rangechecker.Toggle() end)
	if (success ~= true) then
		pprint(L"Could not register rctoggle")
	end

	success = LibSlash.RegisterSlashCmd("rcshowcareer", function() Rangechecker.ShowCareer() end)
	if (success ~= true) then
		pprint(L"Could not register rcshowcareer")
	end

	success = LibSlash.RegisterSlashCmd("rchostile", function() Rangechecker.Hostile() end)
	if (success ~= true) then
		pprint(L"Could not register rchostile")
	end

	success = LibSlash.RegisterSlashCmd("rcfriendly", function() Rangechecker.friendly() end)
	if (success ~= true) then
		pprint(L"Could not register rcfriendly")
	end

	if RangecheckerSettings.Enabled == nil then
		RangecheckerSettings.Enabled = true
	end

	if RangecheckerSettings.targetType == nil then
		RangecheckerSettings.targetType = 1
	end

	if RangecheckerSettings.ShowCareer == nil then
		RangecheckerSettings.ShowCareer = true
	end

	return
end

function Rangechecker.StanceChanged(StanceID, StanceToggle)
	if RangecheckerSettings.LastStance ~= StanceID then
		if RangecheckerSettings.LastStance == 9080 or StanceID == 9080 then
			RangecheckerSettings.LastStance = StanceID
			Rangechecker.GetDiffRange()
			pprint(L"Distance updated")
		end
	end
	return
end

function Rangechecker.PetUpdate()
	if RangecheckerSettings.LastPetName ~= GameData.Player.Pet.name then
		if RangecheckerSettings.LastPetName == L"Horned Squig" or GameData.Player.Pet.name == L"Horned Squig" then
			RangecheckerSettings.LastPetName = GameData.Player.Pet.name
			Rangechecker.GetDiffRange()
			pprint(L"Distance updated")
		end
	end
	return
end

-- Display help message
function Rangechecker.Help()
	pprint("- - - - - - - - - - -")
	pprint("Welcome to Rangechecker Help Menu")
	pprint("Rangechecker displays the distance to enemy target.")
	if (RangecheckerSettings.Enabled == false) then
		pprint("Rangechecker is currently turned OFF")
	else
		pprint("Rangechecker is currently ON")
	end
	pprint("To toggle this mod on or off, use \/rctoggle")
	pprint("To enable/disable show enemy career, use \/rcshowcareer")
	pprint("To show distance to hostile target, use \/rchostile")
	pprint("To show distance to friendly target, use \/rcfriendly")
	pprint("- - - - - - - - - - -")
	return
end

-- Toggle this mod on or off
function Rangechecker.Toggle()
	RangecheckerSettings.Enabled = not RangecheckerSettings.Enabled
	if (RangecheckerSettings.Enabled == false) then
		pprint("Rangechecker is currently turned OFF")
	else
		pprint("Rangechecker is currently ON")
	end
	return
end

function Rangechecker.Hostile()
	RangecheckerSettings.targetType = 1
	Rangechecker.GetDiffRange()
	pprint("Show distance to hostile target")
	LabelSetText("RangecheckerWindowClass", L"")
	Rangechecker.WriteLabel(L"")
	return
end

function Rangechecker.friendly()
	RangecheckerSettings.targetType = 2
	Rangechecker.GetDiffRange()
	pprint("Show distance to friendly target")
	LabelSetText("RangecheckerWindowClass", L"")
	Rangechecker.WriteLabel(L"")
	return
end

-- Toggle Show Career on or off
function Rangechecker.ShowCareer()
	RangecheckerSettings.ShowCareer = not RangecheckerSettings.ShowCareer
	if (RangecheckerSettings.ShowCareer == false) then
		pprint("Show Career is currently turned OFF")
	else
		pprint("Show Career is currently ON")
	end
	return
end

----------------------------------------------------------------
-- WarTriage.lua 
----------------------------------------------------------------

----------------------------------------------------------------
-- Local variables 
----------------------------------------------------------------

local VERSION = 1.07
local WARTRIAGE_MACRO_NAME = "WarTriage"
local WARTRIAGE_MACRO_TEXT = "/wartriage"
local WARTRIAGE_MACRO_ICON = 20087
local MAX_HEAL_DISTANCE = 150
local MAX_RESS_DISTANCE = 100
local DISTANCE_FIX_COEFFICIENT = 1 / 1.06
local MAX_MAP_POINTS = 511
local TIME_DELAY = 0.5
local HEALER = L"HEALER"
local DPS = L"DPS"
local TANK = L"TANK"

-- Localized functions
local mathFloor = math.floor
local pairs = pairs
local ipairs = ipairs

local timeLeft = TIME_DELAY

local EMPTY_TARGET = { name = L"", health = 100, distance = 999999, inMyParty = false }

local MapPointTypeFilter = {
	[SystemData.MapPips.PLAYER] = true,
	[SystemData.MapPips.GROUP_MEMBER] = true,
	[SystemData.MapPips.WARBAND_MEMBER] = true,
	[SystemData.MapPips.DESTRUCTION_ARMY] = true,
	[SystemData.MapPips.ORDER_ARMY] = true
}

local ArcheType = {
	[GameData.CareerLine.ZEALOT] 			= HEALER,
	[GameData.CareerLine.ARCHMAGE] 			= HEALER,
	[GameData.CareerLine.SHAMAN] 			= HEALER,
	[GameData.CareerLine.RUNE_PRIEST] 		= HEALER,
	[GameData.CareerLine.WARRIOR_PRIEST] 	= HEALER,
	[GameData.CareerLine.DISCIPLE] 			= HEALER,
	[GameData.CareerLine.ENGINEER] 			= DPS,
	[GameData.CareerLine.SLAYER] 			= DPS,
	[GameData.CareerLine.MARAUDER] 			= DPS,
	[GameData.CareerLine.SHADOW_WARRIOR] 	= DPS,
	[GameData.CareerLine.CHOPPA] 			= DPS,
	[GameData.CareerLine.SQUIG_HERDER] 		= DPS,
	[GameData.CareerLine.WHITE_LION] 		= DPS,
	[GameData.CareerLine.WITCH_ELF] 		= DPS,
	[GameData.CareerLine.SORCERER] 			= DPS,
	[GameData.CareerLine.WITCH_HUNTER] 		= DPS,
	[GameData.CareerLine.MAGUS] 			= DPS,
	[GameData.CareerLine.BRIGHT_WIZARD] 	= DPS,
	[GameData.CareerLine.IRON_BREAKER] 		= TANK,
	[GameData.CareerLine.KNIGHT] 			= TANK,
	[GameData.CareerLine.SWORDMASTER] 		= TANK,
	[GameData.CareerLine.BLACKGUARD] 		= TANK,
	[GameData.CareerLine.CHOSEN] 			= TANK,
	[GameData.CareerLine.BLACK_ORC] 		= TANK,
}
local CareerIDsToLines = {
	[20]	= GameData.CareerLine.IRON_BREAKER,
	[100]	= GameData.CareerLine.SWORDMASTER,
	[64]	= GameData.CareerLine.CHOSEN,
	[24]	= GameData.CareerLine.BLACK_ORC,
	[60]	= GameData.CareerLine.WITCH_HUNTER,
	[102]	= GameData.CareerLine.WHITE_LION,
	[65]	= GameData.CareerLine.MARAUDER,
	[105]	= GameData.CareerLine.WITCH_ELF,
	[62]	= GameData.CareerLine.BRIGHT_WIZARD,
	[67]	= GameData.CareerLine.MAGUS,
	[107]	= GameData.CareerLine.SORCERER,
	[23]	= GameData.CareerLine.ENGINEER,
	[101]	= GameData.CareerLine.SHADOW_WARRIOR,
	[27]	= GameData.CareerLine.SQUIG_HERDER,
	[63]	= GameData.CareerLine.WARRIOR_PRIEST,
	[106]	= GameData.CareerLine.DISCIPLE,
	[103]	= GameData.CareerLine.ARCHMAGE,
	[26]	= GameData.CareerLine.SHAMAN,
	[22]	= GameData.CareerLine.RUNE_PRIEST,
	[66]	= GameData.CareerLine.ZEALOT,
	[104]	= GameData.CareerLine.BLACKGUARD,
	[61]	= GameData.CareerLine.KNIGHT,
	[25]	= GameData.CareerLine.CHOPPA,
	[21]	= GameData.CareerLine.SLAYER,
}

local LosCheckAbiliyId = {
	[GameData.CareerLine.SHAMAN]			= {healID = 1898, ressID = 1908}, -- Gork'll Fix It, Gedup!
	[GameData.CareerLine.RUNE_PRIEST]		= {healID = 1587, ressID = 1598}, -- Grungni's Gift, Rune of Life
	[GameData.CareerLine.DISCIPLE]			= {healID = 9548, ressID = 9558}, -- Restore Essence, Stand, Coward!
	[GameData.CareerLine.ARCHMAGE]			= {healID = 9236, ressID = 9246}, -- Healing Energy, Gift of Life
	[GameData.CareerLine.WARRIOR_PRIEST]	= {healID = 8238, ressID = 8248}, -- Divine Aid, Breath of Sigmar
	[GameData.CareerLine.ZEALOT]			= {healID = 8569, ressID = 8555}, -- Flash Of Chaos, Tzeentch Shall Remake You
}

local function fixString(str)
    if not str then return nil end

    local pos = str:find(L"^", 1, true)
    if pos then
        return str:sub(1, pos - 1)
    end

    return str
end

local function hasBuff(target, id)
    local buffData = GetBuffs(target)
    if not buffData then return false end

    for _, b in ipairs(buffData) do
        if b.abilityId == id then
            return true
        end
    end

    return false
end

----------------------------------------------------------------
-- WarTriage
----------------------------------------------------------------
WarTriage = {}
WarTriage.Player = {}
WarTriage.Players = {}
WarTriage.PlayerTarget = L""

function WarTriage.Initialize()

    -- Safe settings copy (prevents corrupt defaults)
    if not WarTriage.Settings
    or not WarTriage.Settings.version
    or WarTriage.Settings.version ~= VERSION then

        WarTriage.Settings = {}
        for k, v in pairs(WarTriage.DefaultSettings) do
            WarTriage.Settings[k] = v
        end
    end

    -- Safer slash commands (prevents hard crash if config file fails to load)
    LibSlash.RegisterSlashCmd("wartriage", function(input)
        if WarTriage_Config and WarTriage_Config.Slash then
            WarTriage_Config.Slash(input)
        end
    end)

    LibSlash.RegisterSlashCmd("wt", function(input)
        if WarTriage_Config and WarTriage_Config.Slash then
            WarTriage_Config.Slash(input)
        end
    end)

    WarTriage.CheckCareer()

    if not WarTriage.Settings.isHealer then return end

    if not WarTriage.UpdateMacro(WARTRIAGE_MACRO_NAME, WARTRIAGE_MACRO_TEXT, WARTRIAGE_MACRO_ICON) then
        TextLogAddEntry("Chat", 0, towstring("<icon20087> WarTriage failed to create macro!"))
        return
    end

    TextLogAddEntry("Chat", 0, towstring("<icon20087> WarTriage macro created"))

    -- Cache macro info (performance improvement)
	WarTriage._macroId = nil
	WarTriage._macroSlots = nil
	WarTriage._macroId = WarTriage.GetMacroId(WARTRIAGE_MACRO_NAME)
	WarTriage._macroSlots = WarTriage.GetMacroSlots(WarTriage._macroId)

    WarTriage.PrintSettings()
end

function WarTriage.OnShutdown()
    WarTriage._macroId = nil
    WarTriage._macroSlots = nil
    WarTriage._lastTarget = nil
end


WarTriage.DefaultSettings = {
		version = VERSION,
		enabled = true,
		ignoreDead = false,
		glowEffects = true,
		selfTargetPct = 75,
		healerTargetPct = 75,
		dpsTargetPct = 50,
		tankTargetPct = 25,
		playerTargetPct = 100,
		isHealer = false,
		macroCreated = false,
		losCheck = true,
		rangeCheck = true,
		ownPartyOnly = false,
}

function WarTriage.OnUpdate(elapsed)
    timeLeft = timeLeft - elapsed
    if timeLeft > 0 then return end
    timeLeft = TIME_DELAY

    if not WarTriage.Settings.enabled then return end
    if not WarTriage.Settings.isHealer then return end

    WarTriage.PlayerTarget = WarTriage.GetFriendlyTarget()
    WarTriage.Players = WarTriage.GetFriendlyPlayers()

    local newTarget = WarTriage.GetHurtPlayer()
    if not newTarget or not newTarget.name then return end

    WarTriage._lastTarget = WarTriage._lastTarget or L""

    if newTarget.name ~= WarTriage._lastTarget then
        WarTriage.TargetPlayer(newTarget)
        WarTriage._lastTarget = newTarget.name
    end
end

function WarTriage.CheckCareer()
    local line = CareerIDsToLines[GameData.Player.career.id]
    local arche = line and ArcheType[line]

    WarTriage.Settings.isHealer = (arche == HEALER)
end

function WarTriage.PrintSettings()

    TextLogAddEntry("Chat", 0, towstring("<icon20087> WarTriage v" .. tostring(WarTriage.Settings.version) .. " settings: /wartriage"))

    local function PrintFlag(enabled, label)
        if enabled then
            TextLogAddEntry("Chat", 0, L"--- <icon57> " .. label)
        else
            TextLogAddEntry("Chat", 0, L"--- <icon58> " .. label)
        end
    end

    PrintFlag(WarTriage.Settings.enabled,      L"Enabled")
    PrintFlag(WarTriage.Settings.losCheck,     L"Check LOS")
    PrintFlag(WarTriage.Settings.rangeCheck,   L"Check Range")
    PrintFlag(WarTriage.Settings.ownPartyOnly, L"Own Party Only")
    PrintFlag(WarTriage.Settings.ignoreDead,   L"Ignore Dead")
    PrintFlag(WarTriage.Settings.glowEffects,  L"Glow Effects")
end

function WarTriage.GetFriendlyTarget()

    -- Tick-based throttle (stable under lag)
	WarTriage._targetTick = (WarTriage._targetTick or 1) + 1
	if WarTriage._targetTick >= 2 then
        TargetInfo:UpdateFromClient()
        WarTriage._targetTick = 0
    end

    local target = TargetInfo.m_Units[TargetInfo.FRIENDLY_TARGET]

    if target and not target.isNPC and target.name ~= L"" then
        return fixString(target.name)
    end

    if target and target.entityid == 0 then
        return fixString(GameData.Player.name)
    end

    return L""
end

function WarTriage.UpdateMacro(macroName, macroText, macroIcon)

    local name = towstring(macroName)
    local text = towstring(macroText)

    local macros = GetMacrosData()
    local macroSlot

    for i = 1, #macros do
        local m = macros[i]

        if m.name == name then
            macroSlot = i
            break
        elseif m.iconNum == 0 and not macroSlot then
            macroSlot = i
        end
    end

    if not macroSlot then
        WarTriage.Settings.macroCreated = false
        return false
    end

    SetMacroData(name, text, macroIcon, macroSlot)
    WarTriage.Settings.macroCreated = true
    return true
end

function WarTriage.GetFriendlyPlayers()

    WarTriage._playersCache = WarTriage._playersCache or {}
    local players = WarTriage._playersCache

    for i = 1, #players do
        players[i] = nil
    end

    -- Self
    local selfName   = fixString(GameData.Player.name)
    local selfHealth = mathFloor(100 * GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum)
    local selfLine   = GameData.Player.career.line
    local selfType   = ArcheType[selfLine]

    WarTriage.Player.name = selfName
    WarTriage.Player.health = selfHealth
    WarTriage.Player.archeType = selfType
    WarTriage.Player.inMyParty = true

    players[1] = {
        name = selfName,
        health = selfHealth,
        archeType = selfType,
        inMyParty = true
    }

    local count = 1

    -- Scenario / Siege
    if GameData.Player.isInScenario or GameData.Player.isInSiege then
        local data = GameData.GetScenarioPlayerGroups()
        for _, p in ipairs(data) do
            local name = fixString(p.name)
            count = count + 1
            players[count] = {
                name = name,
                health = p.health,
                archeType = ArcheType[CareerIDsToLines[p.careerId]],
                inMyParty = GroupWindow.IsPlayerInGroup(name)
            }
        end

    -- Warband
    elseif IsWarBandActive() then
        local data = PartyUtils.GetWarbandData()
        for _, group in ipairs(data) do
            for _, p in ipairs(group.players) do
                local name = fixString(p.name)
                count = count + 1
                players[count] = {
                    name = name,
                    health = p.healthPercent,
                    archeType = ArcheType[p.careerLine],
                    inMyParty = GroupWindow.IsPlayerInGroup(name)
                }
            end
        end

    -- Solo / Party
    else
        local data = PartyUtils.GetPartyData()
        for _, p in ipairs(data) do
            if p.name ~= L"" then
                local name = fixString(p.name)
                count = count + 1
                players[count] = {
                    name = name,
                    health = p.healthPercent,
                    archeType = ArcheType[p.careerLine],
                    inMyParty = GroupWindow.IsPlayerInGroup(name)
                }
            end
        end
    end

    -- Range
    if WarTriage.Settings.rangeCheck then
        players = WarTriage.SetPlayersDistance(players)
    else
        for i = 1, #players do
            players[i].distance = 0
        end
    end

    -- LOS
    if WarTriage.Settings.losCheck then
        players = WarTriage.SetPlayersLOS(players)
    else
        for i = 1, #players do
            players[i].hasLOS = true
        end
    end

    return players
end

function WarTriage.SetPlayersDistance(players)

    -- Fast exit if range check disabled
    if not WarTriage.Settings.rangeCheck then
        for i = 1, #players do
            players[i].distance = 0
        end
        return players
    end

    -- Reuse distance cache instead of allocating new table every update
    WarTriage._distanceCache = WarTriage._distanceCache or {}
    local playerDistances = WarTriage._distanceCache

    -- wipe previous values
    for k in pairs(playerDistances) do
        playerDistances[k] = nil
    end

    local defaultDistance = 999999

    -- Build distance lookup table
    for i = 1, MAX_MAP_POINTS do
        local mpd = GetMapPointData("EA_Window_OverheadMapMapDisplay", i)

        if mpd and mpd.name and MapPointTypeFilter[mpd.pointType] then
            playerDistances[fixString(mpd.name)] =
                mathFloor(mpd.distance * DISTANCE_FIX_COEFFICIENT)
        end
    end

    -- Assign distances to players
    for i = 1, #players do
        players[i].distance = playerDistances[players[i].name] or defaultDistance
    end

    return players
end

function WarTriage.SetPlayersLOS(players)

    if not WarTriage.Settings.losCheck then
        return players
    end

    local check = LosCheckAbiliyId[GameData.Player.career.line]
    if not check then return players end

    local isTargetValid = IsTargetValid
    local isAbilityEnabled = IsAbilityEnabled

    local target = WarTriage.PlayerTarget
    if target == L"" then
        target = fixString(GameData.Player.name)
    end

    -- Default everyone to true to prevent stale state
    for i = 1, #players do
        players[i].hasLOS = true
    end

    -- Only evaluate actual target
    for i = 1, #players do
        if players[i].name == target then

            if players[i].health > 0 then
                players[i].hasLOS = isTargetValid(check.healID)
            else
                players[i].hasLOS = isAbilityEnabled(check.ressID) and isTargetValid(check.ressID)
            end

            break
        end
    end

    return players
end

function WarTriage.GetHurtPlayer()

    local players = WarTriage.Players
    if not players or #players == 0 then
        return EMPTY_TARGET
    end

    local settings = WarTriage.Settings
    local ownPartyOnly = settings.ownPartyOnly
    local ignoreDead   = settings.ignoreDead
    local rangeCheck   = settings.rangeCheck

    local selfPct   = settings.selfTargetPct
    local healPct   = settings.healerTargetPct
    local dpsPct    = settings.dpsTargetPct
    local tankPct   = settings.tankTargetPct
    local playerPct = settings.playerTargetPct

    local selfName = WarTriage.Player.name
    local selfHealth = WarTriage.Player.health

    local bestHealth = 100
    local bestDist = 999999
    local bestPlayer = nil

    local foundHealer = false
    local foundDPS = false
    local foundTank = false

    if selfHealth < selfPct then
        return WarTriage.Player
    end

    local canRess = (not ignoreDead) and (GameData.Player.level >= 10) and (not hasBuff(GameData.BuffTargetType.SELF, 5968))

    for i = 1, #players do
        local p = players[i]

        if ownPartyOnly and not p.inMyParty then
            goto continue
        end

        local hp = p.health
        if hp < 0 then hp = 0 end

        local inRangeHeal = (not rangeCheck or p.distance < MAX_HEAL_DISTANCE)
        local inRangeRess = (not rangeCheck or p.distance < MAX_RESS_DISTANCE)

        if p.archeType == HEALER
        and p.name ~= selfName
        and p.hasLOS
        and inRangeHeal
        and hp > 0
        and hp < healPct
        and hp < bestHealth then

            foundHealer = true
            bestPlayer = p
            bestHealth = hp

        elseif p.archeType == DPS
        and not foundHealer
        and p.hasLOS
        and inRangeHeal
        and hp > 0
        and hp < dpsPct
        and hp < bestHealth then

            foundDPS = true
            bestPlayer = p
            bestHealth = hp

        elseif p.archeType == TANK
        and not foundHealer
        and not foundDPS
        and p.hasLOS
        and inRangeHeal
        and hp > 0
        and hp < tankPct
        and hp < bestHealth then

            foundTank = true
            bestPlayer = p
            bestHealth = hp

        elseif canRess
        and not foundHealer
        and not foundDPS
        and not foundTank
        and p.hasLOS
        and inRangeRess
        and hp == 0
        and p.distance < bestDist then

            bestPlayer = p
            bestDist = p.distance

        elseif not foundHealer
        and not foundDPS
        and not foundTank
        and p.hasLOS
        and inRangeHeal
        and hp > 0
        and hp < playerPct
        and hp < bestHealth then

            bestPlayer = p
            bestHealth = hp
        end

        ::continue::
    end

    return bestPlayer or EMPTY_TARGET
end

function WarTriage.TargetPlayer(player)

    WarTriage._lastTarget = WarTriage._lastTarget or L""
    WarTriage._lastGlow   = WarTriage._lastGlow   or 0

    local name = player and player.name or L""
    local glow = 0

    if name ~= L"" and name ~= WarTriage.PlayerTarget then
        glow = 4 - mathFloor(player.health / 25)
    end

    -- Only update if something actually changed
    if name ~= WarTriage._lastTarget or glow ~= WarTriage._lastGlow then
        WarTriage.SetMacroTarget(WARTRIAGE_MACRO_NAME, name, glow)
        WarTriage._lastTarget = name
        WarTriage._lastGlow = glow
    end
end

function WarTriage.GetMacroSlots(macroId)
	if not macroId then return {} end
	
    -- Return cached result if we already scanned
    if WarTriage._macroSlots and #WarTriage._macroSlots > 0 then
        return WarTriage._macroSlots
    end

    local slots = {}

    for i = 1, #ActionBars.m_Bars do
        local bar = ActionBars.m_Bars[i]
        for j = 1, #bar.m_Buttons do
            local btn = bar.m_Buttons[j]
            if btn.m_ActionType == 4 and btn.m_ActionId == macroId then
                slots[#slots + 1] = btn.m_HotBarSlot
            end
        end
    end

    WarTriage._macroSlots = slots
    return slots
end

function WarTriage.GetMacroId(macroName)

    -- Return cached id if available
    if WarTriage._macroId then
        return WarTriage._macroId
    end

    local macros = GetMacrosData()
    local name = towstring(macroName)

    for i = 1, #macros do
        if macros[i].name == name then
            WarTriage._macroId = i
            return i
        end
    end

    return nil
end

function WarTriage.SetMacroTarget(macroName, playerName, glowLevel)

    local macroSlots = WarTriage._macroSlots
    if not macroSlots or #macroSlots == 0 then return end

    local wName = towstring(playerName)

    for i = 1, #macroSlots do
        local hbar, buttonid = ActionBars:BarAndButtonIdFromSlot(macroSlots[i])
        local button = hbar.m_Buttons[buttonid]

        WarTriage.SetButtonGlow(button, glowLevel)
        WindowSetGameActionData(
            button.m_Name .. "Action",
            GameData.PlayerActions.SET_TARGET,
            0,
            wName
        )
    end
end

function WarTriage.SetButtonGlow(button, glowLevel)

    if not WarTriage.Settings.glowEffects or glowLevel <= 0 then
        button.m_Windows[6]:StopAnimation(true)
        return
    end

    if glowLevel > 4 then glowLevel = 4 end

    local anim = button.m_Windows[6]
    anim:StopAnimation(true)
    anim:SetAnimationTexture("anim_fury_" .. glowLevel)
    anim:StartAnimation(0, true, false, 0)
end
GCDsaver = GCDsaver or {}

-- Local data
local VERSION = 1.24
local TIME_DELAY = 1.5
local timeLeft = TIME_DELAY
local MAX_STACK = 3
local IMMOVABLE = 4
local UNSTOPPABLE = 5
local CAREER_RESOURCE = 6
local MAX_BUTTONS = 60
local eventsRegistered = false
local loadingEnd = false

-- Localized functions
local pairs = pairs
local tostring = tostring
local towstring = towstring
local GetBuffs = GetBuffs
local GetHotbarCooldown = GetHotbarCooldown
local GetAbilityData = GetAbilityData
local GetCareerResource    = GetCareerResource
local GetHotbarData = GetHotbarData
local GetNumGroupmates     = GetNumGroupmates
local IsAbilityEnabled     = IsAbilityEnabled
local BroadcastEvent = BroadcastEvent
local TextLogAddEntry = TextLogAddEntry
local RegisterEventHandler = RegisterEventHandler
local UnregisterEventHandler = UnregisterEventHandler

-- 🔧 Localized standard Lua functions
local type        = type
local ipairs      = ipairs
local tonumber    = tonumber
local string_fmt  = string.format
local TargetInfo      = TargetInfo
local RegisterSlash   = LibSlash.RegisterSlashCmd
local ActionBars      = ActionBars
local WindowUtils     = WindowUtils


--Local functions

-- Define this near the top of your gcdsaver.lua or in an appropriate place
local CareerCheckFunctions = {
    [GameData.CareerLine.SWORDMASTER] = SwordmasterChecks.isAbilityBlocked,
    [GameData.CareerLine.WITCH_HUNTER] = WitchhunterChecks.isAbilityBlocked,
    [GameData.CareerLine.WITCH_ELF] = WitchelfChecks.isAbilityBlocked,
    [GameData.CareerLine.IRON_BREAKER] = IronbreakerChecks.isAbilityBlocked,
	[GameData.CareerLine.BLACKGUARD] = BlackguardChecks.isAbilityBlocked,
	[GameData.CareerLine.BLACK_ORC] = BlackOrcChecks.isAbilityBlocked,
	[GameData.CareerLine.DISCIPLE] = DiscipleChecks.isAbilityBlocked,
	[GameData.CareerLine.WARRIOR_PRIEST] = WarriorpriestChecks.isAbilityBlocked
    -- Add other careers as necessary
}

function isAbilityBlocked(actionId, slot)
    if not GCDsaver.Settings.Enabled or GCDsaver.Settings.DisableSlotChecks[slot] then
        return false
    end

    if GCDsaver.Settings.DebugMessages then
        d("[GCDsaver] Checking if ability is blocked for ID: " .. tostring(actionId))
    end

    local abilityCheck = GCDsaver.Settings.Abilities[actionId]
    if not abilityCheck then
        return false
    end

    local abilityData = GCDsaverAPI.GetCachedAbilityData(actionId)
    local currentMechanic = tonumber(GetCareerResource(GameData.BuffTargetType.SELF) or "0")
    local currentResources = currentMechanic -- cached for CAREER_RESOURCE check
    local currentActionPoints = GameData.Player.actionPoints.current
    local myCareer = GameData.Player.career.line

    -- 🔹 Career-specific logic
    local checkFunction = CareerCheckFunctions[myCareer]
    if checkFunction and checkFunction(actionId, currentActionPoints, currentMechanic, abilityData, abilityCheck) then
        return true
    end

    -- 🔹 Snare logic (cheap and early)
    if GCDsaverAPI.hasSnareBuffOnHostileTarget() and Emissary.Snares[actionId] then
        return true
    end

    -- 🔹 Simple direct flag checks (very cheap)
    if abilityCheck == IMMOVABLE and GCDsaver.TargetImmovable then
        return true
    elseif abilityCheck == UNSTOPPABLE and GCDsaver.TargetUnstoppable then
        return true
    elseif abilityCheck == CAREER_RESOURCE and currentResources < GCDsaver.Settings.MaxResources then
        return true
    end

    -- 🔹 Buff presence check (expensive, last)
    if GCDsaverAPI.hasBuff(GCDsaverAPI.getTargetType(abilityData.targetType), abilityData, abilityCheck) then
        return true
    end

    return false
end

-- Block WindowGameAction
local orgWindowGameAction = WindowGameAction
local function blockedWindowGameAction(windowName)
	-- Do nothing
end

-- GCDsaver
GCDsaver = GCDsaver or {}
GCDsaver.FriendlyTargetId = 0
GCDsaver.HostileTargetId = 0
GCDsaver.TargetImmovable = false
GCDsaver.TargetUnstoppable = false
GCDsaver.SelfTargetEffects = {}
GCDsaver.FriendlyTargetEffects = {}
GCDsaver.HostileTargetEffects = {}
GCDsaver.EnabledStatesNeedUpdate = true -- Throttle calls to GCDsaver.UpdateButtonsEnabledStates()
GCDsaver.CheckResources = true
GCDsaver.ButtonIconsNeedUpdate = true -- Throttle calls to GCDsaver.UpdateButtonIcons()

GCDsaver.DefaultSettings = {
	Version = VERSION,
	Enabled = true,
	Symbols = true,
	ErrorMessages = true,
	BlockPlayerBuffs = false,          -- New setting for blocking player buffs
    BlockFriendlyBuffs = false,        -- New setting for blocking friendly buffs
    BlockHostileBuffs = false,         -- New setting for blocking hostile buffs
	DebugMessages = false,
	Abilities = {
		-- Ironbreaker
		[1384] = UNSTOPPABLE,	-- Cave-In
		[1369] = UNSTOPPABLE,	-- Shield of Reprisal
		[1365] = IMMOVABLE,		-- Away With Ye
		-- Slayer
		[1443] = UNSTOPPABLE,	-- Incapacitate
		-- Runepriest
		[1613] = UNSTOPPABLE,	-- Rune of Binding
		[1607] = UNSTOPPABLE,	-- Spellbinding Rune
		-- Engineer
		[1536] = UNSTOPPABLE,	-- Crack Shot
		[1531] = IMMOVABLE,		-- Concussion Grenade
		-- Black Orc
		[1688] = UNSTOPPABLE,	-- Down Ya Go
		[1683] = UNSTOPPABLE,	-- Shut Yer Face
		-- Choppa
		[1755] = UNSTOPPABLE,	-- Sit Down!
		-- Shaman
		[1929] = IMMOVABLE,		-- Geddoff!
		[1917] = UNSTOPPABLE,	-- You Got Nuthin!
		-- Squig Herder
		[1839] = UNSTOPPABLE,	-- Choking Arrer
		[1837] = UNSTOPPABLE,	-- Drop That!!
		[1835] = UNSTOPPABLE,	-- Not So Fast!
		-- Witch Hunter
		[8110] = UNSTOPPABLE,	-- Dragon Gun
		[8086] = UNSTOPPABLE,	-- Confess!
		[8115] = UNSTOPPABLE,	-- Pistol Whip
		[8100] = UNSTOPPABLE,	-- Silence The Heretic
		[8094] = UNSTOPPABLE,	-- Declare Anathema
		-- Knight of the Blazing Sun
		[8018] = UNSTOPPABLE,	-- Smashing Counter
		[8017] = IMMOVABLE,		-- Repel Darkness
		-- Bright Wizard
		[8186] = UNSTOPPABLE,	-- Stop, Drop, and Roll
		[8174] = UNSTOPPABLE,	-- Choking Smoke
		-- Warrior Priest
		[8256] = UNSTOPPABLE,	-- Vow of Silence
		-- Chosen
		[8346] = UNSTOPPABLE,	-- Downfall
		[8329] = IMMOVABLE,		-- Repel
		-- Marauder
		[8412] = UNSTOPPABLE,	-- Mutated Energy
		[8405] = UNSTOPPABLE,	-- Death Grip
		[8410] = IMMOVABLE,		-- Terrible Embrace
		-- Zealot
		[8571] = UNSTOPPABLE,	-- Aethyric Shock
		[8565] = UNSTOPPABLE,	-- Tzeentch's Lash
		-- Magus
		[8495] = UNSTOPPABLE,	-- Perils of The Warp
		[8483] = IMMOVABLE,		-- Warping Blast
		-- Swordmaster
		[9032] = IMMOVABLE,		-- Redirected Force
		-- [9030] = UNSTOPPABLE,	-- Whispering Window
		[9028] = UNSTOPPABLE,	-- Chrashing Wave
		-- Shadow Warrior
		[9096] = UNSTOPPABLE,	-- Eye Shot
		[9108] = UNSTOPPABLE,	-- Exploit Weakness
		[9098] = UNSTOPPABLE,	-- Opportunistic Strike
		-- White Lion
		[9193] = UNSTOPPABLE,	-- Brutal Pounce
		[9177] = UNSTOPPABLE,	-- Throat Bite
		[9178] = IMMOVABLE,		-- Fetch!
		-- Archmage
		[9266] = IMMOVABLE,		-- Cleansing Flare
		[9253] = UNSTOPPABLE,	-- Law of Gold
		-- Blackguard
		[2888] = UNSTOPPABLE,	-- Malignant Strike!
		[9321] = UNSTOPPABLE,	-- Spiteful Slam
		[9328] = IMMOVABLE,		-- Exile
		-- Witch Elf
		[9422] = UNSTOPPABLE,	-- On Your Knees!
		[9400] = UNSTOPPABLE,	-- Sever Limb
		[9427] = UNSTOPPABLE,	-- Heart Seeker
		[9409] = UNSTOPPABLE,	-- Throat Slitter
		[9396] = UNSTOPPABLE,	-- Agile Escape
		-- Disciple of Khaine
		[9565] = UNSTOPPABLE,	-- Consume Thought
		-- Sorcerer
		[9482] = UNSTOPPABLE,	-- Frostbite
		[9489] = UNSTOPPABLE,	-- Stricken Voices
	},
	DisableSlotChecks = {},
	MaxResources = 5
}

function GCDsaver.Initialize()
--GCDsaver.DebugObject(SystemData)

	-- No old settings use default settings
	if not GCDsaver.Settings then
		GCDsaver.Settings = GCDsaver.DefaultSettings
	
	-- Import old settings
	elseif GCDsaver.Settings then
		GCDsaver.Settings.Version = GCDsaver.DefaultSettings.Version
		GCDsaver.Settings.Enabled = GCDsaver.Settings.Enabled or GCDsaver.DefaultSettings.Enabled
		GCDsaver.Settings.Symbols = GCDsaver.Settings.Symbols or GCDsaver.DefaultSettings.Symbols
		GCDsaver.Settings.ErrorMessages = GCDsaver.Settings.ErrorMessages or GCDsaver.DefaultSettings.ErrorMessages
		GCDsaver.Settings.Abilities = GCDsaver.Settings.Abilities or GCDsaver.DefaultSettings.Abilities
		GCDsaver.Settings.DisableSlotChecks = GCDsaver.Settings.DisableSlotChecks or GCDsaver.DefaultSettings.DisableSlotChecks
		-- Changed below here
		-- Initialize new settings
        GCDsaver.Settings.BlockPlayerBuffs = GCDsaver.Settings.BlockPlayerBuffs or GCDsaver.DefaultSettings.BlockPlayerBuffs
        GCDsaver.Settings.BlockFriendlyBuffs = GCDsaver.Settings.BlockFriendlyBuffs or GCDsaver.DefaultSettings.BlockFriendlyBuffs
        GCDsaver.Settings.BlockHostileBuffs = GCDsaver.Settings.BlockHostileBuffs or GCDsaver.DefaultSettings.BlockHostileBuffs
		-- Changed Above here
	end

	if not GCDsaver.Settings.MaxResources then
		if GameData.Player.career.line == GameData.CareerLine.CHOPPA or GameData.Player.career.line == GameData.CareerLine.SLAYER then
			GCDsaver.Settings.MaxResources = 65
		else
			GCDsaver.Settings.MaxResources = 5
		end
	end
	
	RegisterSlash("GCDsaver", function(input) GCDsaver_Config.Slash(input) end)
	RegisterSlash("gcdsaverdebug", function(input) GCDsaver.ToggleDebugMessages() end)
	
	if GCDsaver.Settings.Enabled then GCDsaver.RegisterEvents()	end
	
	TextLogAddEntry("Chat", 0, towstring("<icon57> GCDsaver loaded. Type /GCDsaver for settings."))
end

function GCDsaver.DebugObject(obj, objName)
	if (obj == nil)
	then
		return
	end
	d("--------------------")
	if (objName ~= nil)
	then
		d("object name=" .. tostring(objName))
	end
	for name, val in pairs(obj) do
		d("  name=" .. tostring(name) .. ", value=" .. tostring(val))
	end
end

function GCDsaver.OnShutdown()
	GCDsaver.UnregisterEvents()
end

function GCDsaver.RegisterEvents()
	if not eventsRegistered then
		RegisterEventHandler(SystemData.Events.ENTER_WORLD, "GCDsaver.ENTER_WORLD")
		RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "GCDsaver.PLAYER_ZONE_CHANGED")
		RegisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "GCDsaver.INTERFACE_RELOADED")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "GCDsaver.PLAYER_TARGET_UPDATED")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_IS_IMMUNE_TO_MOVEMENT_IMPARING, "GCDsaver.PLAYER_TARGET_IS_IMMUNE_TO_MOVEMENT_IMPARING")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_IS_IMMUNE_TO_DISABLES, "GCDsaver.PLAYER_TARGET_IS_IMMUNE_TO_DISABLES")
		RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "GCDsaver.PLAYER_EFFECTS_UPDATED")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "GCDsaver.PLAYER_TARGET_EFFECTS_UPDATED")
		RegisterEventHandler(SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED, "GCDsaver.PLAYER_CAREER_RESOURCE_UPDATED")
		RegisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_UPDATED, "GCDsaver.PLAYER_HOT_BAR_UPDATED")
		RegisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_PAGE_UPDATED, "GCDsaver.PLAYER_HOT_BAR_PAGE_UPDATED")
	end
	eventsRegistered = true
end

function GCDsaver.UnregisterEvents()
	if eventsRegistered then
		UnregisterEventHandler(SystemData.Events.ENTER_WORLD, "GCDsaver.ENTER_WORLD")
		UnregisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "GCDsaver.PLAYER_ZONE_CHANGED")
		UnregisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "GCDsaver.INTERFACE_RELOADED")
		UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "GCDsaver.PLAYER_TARGET_UPDATED")
		UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_IS_IMMUNE_TO_MOVEMENT_IMPARING, "GCDsaver.PLAYER_TARGET_IS_IMMUNE_TO_MOVEMENT_IMPARING")
		UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_IS_IMMUNE_TO_DISABLES, "GCDsaver.PLAYER_TARGET_IS_IMMUNE_TO_DISABLES")
		UnregisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "GCDsaver.PLAYER_EFFECTS_UPDATED")
		UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "GCDsaver.PLAYER_TARGET_EFFECTS_UPDATED")
		UnRegisterEventHandler(SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED, "GCDsaver.PLAYER_CAREER_RESOURCE_UPDATED")
		UnregisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_UPDATED, "GCDsaver.PLAYER_HOT_BAR_UPDATED")
		UnRegisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_PAGE_UPDATED, "GCDsaver.PLAYER_HOT_BAR_PAGE_UPDATED")
	end
	eventsRegistered = false
end

-- Event handlers
function GCDsaver.ENTER_WORLD()
	loadingEnd = true
	GCDsaver.ButtonIconsNeedUpdate = true
end

function GCDsaver.PLAYER_ZONE_CHANGED()
	loadingEnd = true
	GCDsaver.ButtonIconsNeedUpdate = true
end

function GCDsaver.INTERFACE_RELOADED()
	loadingEnd = true
	GCDsaver.ButtonIconsNeedUpdate = true
end

function GCDsaver.ToggleDebugMessages()
    GCDsaver.Settings.DebugMessages = not GCDsaver.Settings.DebugMessages
    local state = GCDsaver.Settings.DebugMessages and "ON" or "OFF"
    TextLogAddEntry("Chat", 0, towstring("Debug messages are now " .. state))
end

function GCDsaver.PLAYER_TARGET_UPDATED(targetClassification, targetId, targetType)
    if targetClassification == "mouseovertarget" then return end

    if GCDsaver.Settings.DebugMessages then
        d(string_fmt("PLAYER_TARGET_UPDATED: targetClassification = %s, targetId = %s, targetType = %s", targetClassification, targetId, targetType))
    end

    -- 🧠 Friendly Target Changed
    if targetClassification == TargetInfo.FRIENDLY_TARGET and GCDsaver.FriendlyTargetId ~= targetId then
        GCDsaver.FriendlyTargetId = targetId
        GCDsaverAPI.clearBuffCache("FRIENDLY")
        GCDsaver.FriendlyTargetEffects = {}
        GCDsaver.EnabledStatesNeedUpdate = true

        local buffs = GetBuffs(GameData.BuffTargetType.TARGET_FRIENDLY) or {}
        for _, buff in ipairs(buffs) do
            GCDsaver.FriendlyTargetEffects[buff.iconNum] = buff
        end

        if GCDsaver.Settings.DebugMessages then
            d("🧼 Friendly target updated. ID: " .. targetId .. " - Cache cleared.")
        end
    end

    -- 🔒 BlockHostileBuffs check
    if targetClassification == TargetInfo.HOSTILE_TARGET and GCDsaver.HostileTargetId ~= targetId then
        if GCDsaver.Settings.BlockHostileBuffs then
            if GCDsaver.Settings.DebugMessages then
                d("⛔ Hostile target update skipped due to settings. ID: " .. targetId)
            end
            return
        end

        GCDsaver.HostileTargetId = targetId
        GCDsaverAPI.clearBuffCache("HOSTILE")
        GCDsaver.HostileTargetEffects = {}
        GCDsaver.EnabledStatesNeedUpdate = true

        local buffs = GetBuffs(GameData.BuffTargetType.TARGET_HOSTILE) or {}
        for _, buff in ipairs(buffs) do
            GCDsaver.HostileTargetEffects[buff.iconNum] = buff
        end

        if GCDsaver.Settings.DebugMessages then
            d("🧼 Hostile target updated. ID: " .. targetId .. " - Cache cleared.")
        end
    end
end

function GCDsaver.PLAYER_TARGET_IS_IMMUNE_TO_DISABLES(state)
	GCDsaver.TargetUnstoppable = state
	GCDsaver.EnabledStatesNeedUpdate = true
end

function GCDsaver.PLAYER_TARGET_IS_IMMUNE_TO_MOVEMENT_IMPARING(state)
	GCDsaver.TargetImmovable = state
	GCDsaver.EnabledStatesNeedUpdate = true
end

function GCDsaver.PLAYER_CAREER_RESOURCE_UPDATED(previous, resources)
	GCDsaver.CheckResources = true
end

function GCDsaver.PLAYER_EFFECTS_UPDATED(updatedEffects, isFullList)
	-- Changed below here
   -- Skip updating player effects if "Block Player Buffs" is enabled
    if GCDsaver.Settings.BlockPlayerBuffs then
        return
    end
	-- Changed Above here
	if not updatedEffects then return end
	
	    -- Clear cache since effects have changed
    GCDsaverAPI.clearBuffCache()
	
	for k, v in pairs(updatedEffects) do
		if v.castByPlayer then
			GCDsaver.SelfTargetEffects[k] = v.abilityId
			GCDsaver.EnabledStatesNeedUpdate = true
		elseif GCDsaver.SelfTargetEffects[k] then
			GCDsaver.SelfTargetEffects[k] = nil
			GCDsaver.EnabledStatesNeedUpdate = true
		end
	end
end

function GCDsaver.PLAYER_TARGET_EFFECTS_UPDATED(updateType, updatedEffects, isFullList)
    if not updatedEffects then
        d("No updated effects.")
        return
    end
	
	    -- Clear cache since target effects have changed
    if updateType == GameData.BuffTargetType.TARGET_HOSTILE then
        GCDsaverAPI.clearBuffCache("HOSTILE")
    elseif updateType == GameData.BuffTargetType.TARGET_FRIENDLY then
        GCDsaverAPI.clearBuffCache("FRIENDLY")
    end
    
    -- Skipping buff checks and storage for hostile target based on settings
    if updateType == GameData.BuffTargetType.TARGET_HOSTILE and GCDsaver.Settings.BlockHostileBuffs then
			if GCDsaver.Settings.DebugMessages then
			d("Skipping hostile target buff checks and storage.")
			end
        GCDsaver.HostileTargetEffects = {}  -- Clearing any existing hostile target effects
        return
    end
	
    -- Skipping buff checks and storage for friendly target based on settings
    if updateType == GameData.BuffTargetType.TARGET_FRIENDLY and GCDsaver.Settings.BlockFriendlyBuffs then
			if GCDsaver.Settings.DebugMessages then
			d("Skipping friendly target buff checks and storage.")
			end
        GCDsaver.FriendlyTargetEffects = {}  -- Clearing any existing friendly target effects
        return
    end

    -- Processing effects
    for k, v in pairs(updatedEffects) do
        if updateType == GameData.BuffTargetType.TARGET_HOSTILE then
				if GCDsaver.Settings.DebugMessages then
				d("Processing hostile target effect: " .. tostring(v.abilityId))
				end
            -- Effect cast by player applied on hostile target
            if v.castByPlayer then
                GCDsaver.HostileTargetEffects[k] = v.abilityId
                GCDsaver.EnabledStatesNeedUpdate = true
            -- Effect cast by player removed from hostile target
            elseif GCDsaver.HostileTargetEffects[k] then
                GCDsaver.HostileTargetEffects[k] = nil
                GCDsaver.EnabledStatesNeedUpdate = true
            end
        elseif updateType == GameData.BuffTargetType.TARGET_FRIENDLY then
				if GCDsaver.Settings.DebugMessages then
				d("Processing friendly target effect: " .. tostring(v.abilityId))
				end
            -- Effect cast by player applied on friendly target
            if v.castByPlayer then
                GCDsaver.FriendlyTargetEffects[k] = v.abilityId
                GCDsaver.EnabledStatesNeedUpdate = true
            -- Effect cast by player removed from friendly target
            elseif GCDsaver.FriendlyTargetEffects[k] then
                GCDsaver.FriendlyTargetEffects[k] = nil
                GCDsaver.EnabledStatesNeedUpdate = true
            end
        end
    end
end


function GCDsaver.PLAYER_HOT_BAR_PAGE_UPDATED(...)
		if GCDsaver.Settings.DebugMessages then
		d("PLAYER_HOT_BAR_PAGE_UPDATED")
		end
	GCDsaver.ButtonIconsNeedUpdate = true
end

function GCDsaver.PLAYER_HOT_BAR_UPDATED(slot, actionType, actionId)
			if GCDsaver.Settings.DebugMessages then
			d("PLAYER_HOT_BAR_UPDATED(" .. tostring(slot) .. "," .. tostring(actionType) .. "," .. tostring(actionId) .. ")")
			end
	--local hbar, buttonid
	--hbar, buttonid = ActionBars:BarAndButtonIdFromSlot(slot)
	--if actionType == 0 or buttonid ~= actionId then
		--d("Clear disable for slot " .. tostring(slot))
		--GCDsaver.Settings.DisableSlotChecks[slot] = nil
	--end
	GCDsaver.UpdateButtonIcon(slot, GCDsaver.Settings.Abilities[actionId])
	GCDsaver.UpdateButtonEnabledState(slot)
end

-- Main update function
function GCDsaver.OnUpdate(elapsed)
    if not loadingEnd or not GCDsaver.Settings.Enabled then return end

    timeLeft = timeLeft - elapsed
    if timeLeft > 0 then return end
    timeLeft = TIME_DELAY

    local currentCareerResource = tonumber(GetCareerResource(GameData.BuffTargetType.SELF) or "0")

    -- 💨 Skip if no icons or states to update
    if not GCDsaver.ButtonIconsNeedUpdate and not GCDsaver.EnabledStatesNeedUpdate and not GCDsaver.CheckResources then
        return
    end

    -- 🖼️ Update icons if flagged (throttled inside function)
    if GCDsaver.ButtonIconsNeedUpdate then
        GCDsaver.UpdateButtonIcons()
        -- ⚠️ DO NOT set ButtonIconsNeedUpdate = false here — it's done internally when all icons are finished
    end

    -- 🔓 Check buffs / stacks / career stuff if flagged
    local shouldUpdate = false

    if GCDsaver.EnabledStatesNeedUpdate then
        shouldUpdate = true
        GCDsaver.EnabledStatesNeedUpdate = false
    end

    if GCDsaver.CheckResources then
        if currentCareerResource >= GCDsaver.Settings.MaxResources then
            shouldUpdate = true
        end
        GCDsaver.CheckResources = false
    end

    if shouldUpdate then
        GCDsaver.UpdateButtonsEnabledStates()
    end
end

function GCDsaver.UpdateSettings()
	if GCDsaver.Settings.Enabled and not eventsRegistered then
		GCDsaver.RegisterEvents()
	elseif not GCDsaver.Settings.Enabled and eventsRegistered then
		GCDsaver.UnregisterEvents()
	end
	
	GCDsaver.UpdateButtonIcons()

	TextLogAddEntry("Chat", 0, towstring("GCDsaver v" .. tostring(GCDsaver.Settings.Version) .. " settings: /gcdsaver"))
	if GCDsaver.Settings.Enabled then
		TextLogAddEntry("Chat", 0, L"--- <icon57> Enabled")
	else
		TextLogAddEntry("Chat", 0, L"--- <icon58> Enabled")
	end
	if GCDsaver.Settings.Symbols then
		TextLogAddEntry("Chat", 0, L"--- <icon57> Show Symbols")
	else
		TextLogAddEntry("Chat", 0, L"--- <icon58> Show Symbols")
	end
	if GCDsaver.Settings.ErrorMessages then
		TextLogAddEntry("Chat", 0, L"--- <icon57> Show Combat Error Messages")
	else
		TextLogAddEntry("Chat", 0, L"--- <icon58> Show Combat Error Messages")
	end
	-- Changed Below Here
	if GCDsaver.Settings.BlockFriendlyBuffs then
		TextLogAddEntry("Chat", 0, L"--- <icon57> Block Self and Friendly Buffs")
	else
		TextLogAddEntry("Chat", 0, L"--- <icon58> Block Self and Friendly Buffs")
	end
	if GCDsaver.Settings.BlockHostileBuffs then
		TextLogAddEntry("Chat", 0, L"--- <icon57> Block Hositle Buffs")
	else
		TextLogAddEntry("Chat", 0, L"--- <icon58> Block Hostile Buffs")
	end
	if GCDsaver.Settings.MaxResources then
		TextLogAddEntry("Chat", 0, L"--- <icon57> Limit Max Resources")
	else
		TextLogAddEntry("Chat", 0, L"--- <icon58> Limit Max Resources")
	end
	if GCDsaver.Settings.DebugMessages then
		TextLogAddEntry("Chat", 0, L"--- <icon57> Toggle Debug Messages")
	else
		TextLogAddEntry("Chat", 0, L"--- <icon58> Toggle Debug Messages")
	end
	--Changed Above Here	
end

local currentIconIndex = 1
local ICONS_PER_FRAME = 10

function GCDsaver.UpdateButtonIcons()
    for _ = 1, ICONS_PER_FRAME do
        if currentIconIndex > MAX_BUTTONS then
            currentIconIndex = 1
            GCDsaver.ButtonIconsNeedUpdate = false -- finished updating
            return
        end

        local actionType, actionId = GetHotbarData(currentIconIndex)
        if GCDsaver.Settings.Enabled and GCDsaver.Settings.Symbols and GCDsaver.Settings.Abilities[actionId] then
            GCDsaver.UpdateButtonIcon(currentIconIndex, GCDsaver.Settings.Abilities[actionId])
        elseif GCDsaver.Settings.Abilities[actionId] then
            GCDsaver.UpdateButtonIcon(currentIconIndex, 0)
        end

        currentIconIndex = currentIconIndex + 1
    end
end

local SaveHotKeySetText

function HotKeySetText(obj, text)
--	d("SetHotKeyText("..obj.m_Name..", "..text..")")
	SaveHotKeySetText(obj, text);
end

function DummyHotKeySetText(obj, text)
--	d("DummyHotKeySetText")
end

-- function GCDsaver.UpdateButtonIcon(slot, check)
	-- local actionType, actionId, isSlotEnabled, isTargetValid, isSlotBlocked
	-- local hbar, buttonid, button
	-- hbar, buttonid = ActionBars:BarAndButtonIdFromSlot(slot)
	-- if hbar and buttonid then
		-- button = hbar.m_Buttons[buttonid]
		-- if not SaveHotKeySetText then
			-- SaveHotKeySetText = button.m_Windows[7].SetText
		-- end
		-- if GCDsaver.Settings.DisableSlotChecks[slot] then
			-- --d("slot " .. tostring(slot) .. " disabled.")
			-- button.m_Windows[7]:Show(true)
			-- button.m_Windows[7]:SetFont("font_default_war_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
			-- button.m_Windows[7]:SetTextColor(255, 255, 0)
			-- --button.m_Windows[7]:SetText("d")
			-- button.m_Windows[7].SetText = DummyHotKeySetText
			-- HotKeySetText(button.m_Windows[7], "d")
		-- elseif check then
			-- if check == IMMOVABLE then
				-- button.m_Windows[7]:Show(true)
				-- --button.m_Windows[7]:SetText("<icon05007>")
				-- button.m_Windows[7].SetText = DummyHotKeySetText
				-- HotKeySetText(button.m_Windows[7], "<icon05007>")
			-- elseif check == UNSTOPPABLE then
				-- button.m_Windows[7]:Show(true)
				-- --button.m_Windows[7]:SetText("<icon05006>")
				-- button.m_Windows[7].SetText = DummyHotKeySetText
				-- HotKeySetText(button.m_Windows[7], "<icon05006>")
			-- elseif check == CAREER_RESOURCE then
				-- button.m_Windows[7]:Show(true)
				-- button.m_Windows[7]:SetFont("font_default_war_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
				-- button.m_Windows[7]:SetTextColor(255, 255, 0)
				-- --button.m_Windows[7]:SetText("RE")
				-- button.m_Windows[7].SetText = DummyHotKeySetText
				-- HotKeySetText(button.m_Windows[7], "RE")
			-- elseif check >= 1 and check <= 3 then
				-- button.m_Windows[7]:Show(true)
				-- button.m_Windows[7]:SetFont("font_default_war_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
				-- button.m_Windows[7]:SetTextColor(255, 255, 0)
				-- --button.m_Windows[7]:SetText(tostring(check).."x")
				-- button.m_Windows[7].SetText = DummyHotKeySetText
				-- HotKeySetText(button.m_Windows[7], tostring(check).."x")
			-- elseif check == 0 then
				-- button.m_Windows[7]:Show(false)
			-- end
		-- end
	-- end
-- end

function GCDsaver.UpdateButtonIcon(slot, check)
	local hbar, buttonid = ActionBars:BarAndButtonIdFromSlot(slot)
	if not (hbar and buttonid) then return end

	local button = hbar.m_Buttons[buttonid]
	local label = button.m_Windows[7]

	if not SaveHotKeySetText then
		SaveHotKeySetText = label.SetText
	end

	label:SetFont("font_default_war_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	label:SetTextColor(255, 255, 0)

	if GCDsaver.Settings.DisableSlotChecks[slot] then
		label:Show(true)
		label.SetText = DummyHotKeySetText
		HotKeySetText(label, "d")
		return
	end

	if not check or check == 0 then
		label:Show(false)
		return
	end

	label:Show(true)
	label.SetText = DummyHotKeySetText

	if check == IMMOVABLE then
		HotKeySetText(label, "<icon05007>")
	elseif check == UNSTOPPABLE then
		HotKeySetText(label, "<icon05006>")
	elseif check == CAREER_RESOURCE then
		HotKeySetText(label, "RE")
	elseif check >= 1 and check <= 3 then
		HotKeySetText(label, tostring(check) .. "x")
	end
end


-- Split 60 slots across 6 frames = 10 per frame
local currentSlotIndex = 1
local BUTTONS_PER_FRAME = 10

function GCDsaver.UpdateButtonsEnabledStates()
    for _ = 1, BUTTONS_PER_FRAME do
        if currentSlotIndex > MAX_BUTTONS then
            currentSlotIndex = 1
        end

        GCDsaver.UpdateButtonEnabledState(currentSlotIndex)
        currentSlotIndex = currentSlotIndex + 1
    end
end

-- function GCDsaver.UpdateButtonsEnabledStates()
	-- for slot = 1, MAX_BUTTONS do
		-- GCDsaver.UpdateButtonEnabledState(slot)
	-- end
-- end

function GCDsaver.UpdateButtonEnabledState(slot)
	local actionType, actionId, isSlotEnabled, isTargetValid, isSlotBlocked = GetHotbarData(slot)
	--if actionId ~= 0 then
	if GCDsaver.Settings.Abilities[actionId] then
		ActionBars.UpdateSlotEnabledState(slot, isSlotEnabled, isTargetValid, isSlotBlocked)
	end
end

-- Hooked Functions
-- local orgActionButtonOnLButtonDown = ActionButton.OnLButtonDown
-- function ActionButton.OnLButtonDown(self, flags, x, y)

	-- if flags == SystemData.ButtonFlags.SHIFT and self.m_ActionId ~= 0 then
		-- local action = GCDsaver.Settings.Abilities[self.m_ActionId];
		-- if not action then
			-- GCDsaver.Settings.Abilities[self.m_ActionId] = 1
		-- elseif action < 6 then
			-- action = action + 1
			-- GCDsaver.Settings.Abilities[self.m_ActionId] = action
		-- else
			-- GCDsaver.Settings.Abilities[self.m_ActionId] = nil
		-- end

		-- GCDsaver.UpdateButtonIcon(self.m_HotBarSlot, GCDsaver.Settings.Abilities[self.m_ActionId] or 0)
		-- GCDsaver.UpdateButtonEnabledState(self.m_HotBarSlot)
		-- GCDsaverAPI.chatInfo(self.m_ActionId, self.m_HotBarSlot)

		-- -- Block WindowGameAction
		-- WindowGameAction = blockedWindowGameAction
		
	-- elseif flags == SystemData.ButtonFlags.CONTROL and self.m_ActionId ~= 0 then
		-- if GCDsaver.Settings.DisableSlotChecks[self.m_HotBarSlot] then
			-- GCDsaver.Settings.DisableSlotChecks[self.m_HotBarSlot] = nil
		-- else
			-- GCDsaver.Settings.DisableSlotChecks[self.m_HotBarSlot] = 1
		-- end

		-- GCDsaver.UpdateButtonIcon(self.m_HotBarSlot, GCDsaver.Settings.Abilities[self.m_ActionId] or 0)
		-- GCDsaver.UpdateButtonEnabledState(self.m_HotBarSlot)
		-- GCDsaverAPI.chatInfo(self.m_ActionId, self.m_HotBarSlot)

		-- -- Block WindowGameAction
		-- WindowGameAction = blockedWindowGameAction		

	-- elseif self.m_ActionId ~= 0
	-- and GCDsaver.Settings.Abilities[self.m_ActionId]
	-- and isAbilityBlocked(self.m_ActionId, self.m_HotBarSlot) then
		-- -- Block WindowGameAction
		-- WindowGameAction = blockedWindowGameAction

	-- else
		-- -- Restore WindowGameAction
		-- WindowGameAction = orgWindowGameAction

		-- orgActionButtonOnLButtonDown(self, flags, x, y)
	-- end
-- end

local orgActionButtonOnLButtonDown = ActionButton.OnLButtonDown

function ActionButton.OnLButtonDown(self, flags, x, y)
	local actionId = self.m_ActionId
	local slot = self.m_HotBarSlot

	if actionId == 0 then
		WindowGameAction = orgWindowGameAction
		orgActionButtonOnLButtonDown(self, flags, x, y)
		return
	end

	if flags == SystemData.ButtonFlags.SHIFT then
		local state = GCDsaver.Settings.Abilities[actionId]
		if not state then
			GCDsaver.Settings.Abilities[actionId] = 1
		elseif state < 6 then
			GCDsaver.Settings.Abilities[actionId] = state + 1
		else
			GCDsaver.Settings.Abilities[actionId] = nil
		end

		GCDsaver.UpdateButtonIcon(slot, GCDsaver.Settings.Abilities[actionId] or 0)
		GCDsaver.UpdateButtonEnabledState(slot)
		GCDsaverAPI.chatInfo(actionId, slot)
		WindowGameAction = blockedWindowGameAction
		return
	end

	if flags == SystemData.ButtonFlags.CONTROL then
		if GCDsaver.Settings.DisableSlotChecks[slot] then
			GCDsaver.Settings.DisableSlotChecks[slot] = nil
		else
			GCDsaver.Settings.DisableSlotChecks[slot] = 1
		end

		GCDsaver.UpdateButtonIcon(slot, GCDsaver.Settings.Abilities[actionId] or 0)
		GCDsaver.UpdateButtonEnabledState(slot)
		GCDsaverAPI.chatInfo(actionId, slot)
		WindowGameAction = blockedWindowGameAction
		return
	end

	if GCDsaver.Settings.Abilities[actionId] and isAbilityBlocked(actionId, slot) then
		WindowGameAction = blockedWindowGameAction
	else
		WindowGameAction = orgWindowGameAction
		orgActionButtonOnLButtonDown(self, flags, x, y)
	end
end

local orgActionBarsUpdateSlotEnabledState = ActionBars.UpdateSlotEnabledState
function ActionBars.UpdateSlotEnabledState(slot, isSlotEnabled, isTargetValid, isSlotBlocked)

    if GCDsaver.Settings.DisableSlotChecks[slot] then
        orgActionBarsUpdateSlotEnabledState(slot, isSlotEnabled, isTargetValid, isSlotBlocked)
        return
    end

    local hbar, buttonid = ActionBars:BarAndButtonIdFromSlot(slot)
    if not (hbar and buttonid) then
        orgActionBarsUpdateSlotEnabledState(slot, isSlotEnabled, isTargetValid, isSlotBlocked)
        return
    end

    local button = hbar.m_Buttons[buttonid]
    local actionId = button.m_ActionId
    local abilityCheck = GCDsaver.Settings.Abilities[actionId]

    if not abilityCheck then
        orgActionBarsUpdateSlotEnabledState(slot, isSlotEnabled, isTargetValid, isSlotBlocked)
        return
    end

    local abilityData = GCDsaverAPI.GetCachedAbilityData(actionId)

    if abilityCheck == IMMOVABLE and GCDsaver.TargetImmovable then
        isSlotEnabled = false

    elseif abilityCheck == UNSTOPPABLE and GCDsaver.TargetUnstoppable then
        isSlotEnabled = false

    elseif abilityCheck == CAREER_RESOURCE then
        local resources = tonumber(GetCareerResource(GameData.BuffTargetType.SELF) or "0")
        if resources < GCDsaver.Settings.MaxResources then
            isSlotEnabled = false
        end

    elseif GCDsaverAPI.hasBuff(GCDsaverAPI.getTargetType(abilityData.targetType), abilityData, abilityCheck) then
        isSlotEnabled = false

    elseif isAbilityBlocked(actionId, slot) then
        isSlotEnabled = false
    end

    orgActionBarsUpdateSlotEnabledState(slot, isSlotEnabled, isTargetValid, isSlotBlocked)
end

local orgActionButtonUpdateInventory = ActionButton.UpdateInventory
function ActionButton.UpdateInventory(self)
	if not GCDsaver.Settings.Abilities[self.m_ActionId] then
		orgActionButtonUpdateInventory(self)
	end
end
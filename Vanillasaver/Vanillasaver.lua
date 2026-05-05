-- Local data
local VERSION = 1.07
local TIME_DELAY = 0.1
local timeLeft = TIME_DELAY
local MAX_STACK = 3
local IMMOVABLE = 4
local UNSTOPPABLE = 5
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
local GetHotbarData = GetHotbarData
local BroadcastEvent = BroadcastEvent
local TextLogAddEntry = TextLogAddEntry
local RegisterEventHandler = RegisterEventHandler
local UnregisterEventHandler = UnregisterEventHandler

-- Local functions
local function hasFriendlyTarget()
	local target = TargetInfo.m_Units[TargetInfo.FRIENDLY_TARGET]
	if target and target.entityid ~= 0 then
		return true
	end
	return false
end

local function hasHostileTarget()
	local target = TargetInfo.m_Units[TargetInfo.HOSTILE_TARGET]
	if target and target.entityid ~= 0 then
		return true
	end
	return false
end

local function hasBuff(target, abilityData, stackCount)
	if not target then
		return false
	end

	local buffData = GetBuffs(target)
	if not buffData then
		return false
	end

	for _, buff in pairs(buffData) do
		if buff.castByPlayer
		and buff.iconNum == abilityData.iconNum
		and buff.stackCount >= stackCount then
			return true
		end
	end

	return false
end

local function getTargetType(targetType)
	if targetType == 0 then
		return GameData.BuffTargetType.SELF
	elseif targetType == 1 and hasHostileTarget() then
		return GameData.BuffTargetType.TARGET_HOSTILE
	elseif targetType == 1 then
		return nil -- Ugly workaround to correct for incorrect buffs when no hostile target
	elseif targetType == 2 and hasFriendlyTarget() then
		return GameData.BuffTargetType.TARGET_FRIENDLY
	elseif targetType == 2 then
		return GameData.BuffTargetType.SELF
	else
		return GameData.BuffTargetType.SELF
	end
end

local function alertText(text)
	if SettingsWindowTabInterface.SavedMessageSettings.combat then
		SystemData.AlertText.VecType = {SystemData.AlertText.Types.COMBAT}
		SystemData.AlertText.VecText = {towstring(text)}
		BroadcastEvent(SystemData.Events.SHOW_ALERT_TEXT)
	end
end

local function chatInfo(actionId, state)
	local name = tostring(GetAbilityData(actionId).name)
	local icon = "<icon".. tostring(GetAbilityData(actionId).iconNum) .. ">"
	if not state then
		TextLogAddEntry("Chat", 0, towstring("Vanillasaver: Clearing check for " .. icon .. " " .. name))
	elseif state >= 1 and state <= 3 then
		TextLogAddEntry("Chat", 0, towstring("Vanillasaver: Setting (" .. state ..  "x) Stack check for " .. icon .. " " .. name))
	elseif state == IMMOVABLE then
		TextLogAddEntry("Chat", 0, towstring("Vanillasaver: Setting <icon05007> Immovable check for " .. icon .. " " .. name))
	elseif state == UNSTOPPABLE then
		TextLogAddEntry("Chat", 0, towstring("Vanillasaver: Setting <icon05006> Unstoppable check for " .. icon .. " " .. name))
	end
end

local function isAbilityBlocked(actionId)
	if Vanillasaver.Settings.Enabled then
		local abilityData = GetAbilityData(actionId)
		
		if Vanillasaver.TargetImmovable and Vanillasaver.Settings.Abilities[actionId] and Vanillasaver.Settings.Abilities[actionId] == IMMOVABLE then
			if Vanillasaver.Settings.ErrorMessages then alertText("Target is Immovable") end
			return true
		elseif Vanillasaver.TargetUnstoppable and Vanillasaver.Settings.Abilities[actionId] and Vanillasaver.Settings.Abilities[actionId] == UNSTOPPABLE then
			if Vanillasaver.Settings.ErrorMessages then alertText("Target is Unstoppable") end
			return true
		elseif Vanillasaver.Settings.Abilities[actionId] and hasBuff(getTargetType(abilityData.targetType), abilityData, Vanillasaver.Settings.Abilities[actionId]) then
			if Vanillasaver.Settings.ErrorMessages then alertText("Target already has that effect") end
			return true
		else
			return false
		end
	else
		return false
	end

end

-- Block WindowGameAction
local orgWindowGameAction = WindowGameAction
local function blockedWindowGameAction(windowName)
	-- Do nothing
end

-- Vanillasaver
Vanillasaver = Vanillasaver or {}
Vanillasaver.FriendlyTargetId = 0
Vanillasaver.HostileTargetId = 0
Vanillasaver.TargetImmovable = false
Vanillasaver.TargetUnstoppable = false
Vanillasaver.SelfTargetEffects = {}
Vanillasaver.FriendlyTargetEffects = {}
Vanillasaver.HostileTargetEffects = {}
Vanillasaver.EnabledStatesNeedUpdate = true -- Throttle calls to Vanillasaver.UpdateButtonsEnabledStates()
Vanillasaver.ButtonIconsNeedUpdate = true -- Throttle calls to Vanillasaver.UpdateButtonIcons()

Vanillasaver.DefaultSettings = {
	Version = VERSION,
	Enabled = true,
	Symbols = true,
	ErrorMessages = true,
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
		[1686] = IMMOVABLE,	-- Git Out
		-- Choppa
		[1755] = UNSTOPPABLE,	-- Sit Down!
		-- Shaman
		[1929] = IMMOVABLE,		-- Geddoff!
		[1917] = UNSTOPPABLE,	-- You Got Nuthin!
		-- Squig Herder
		[1839] = UNSTOPPABLE,	-- Choking Arrer
		[1837] = UNSTOPPABLE,	-- Drop That!!
		--[1835] = UNSTOPPABLE,	-- Not So Fast!
		-- Witch Hunter
		[8110] = UNSTOPPABLE,	-- Dragon Gun
		[8086] = UNSTOPPABLE,	-- Confess!
		[8115] = UNSTOPPABLE,	-- Pistol Whip
		[8100] = UNSTOPPABLE,	-- Silence The Heretic
		--[8094] = UNSTOPPABLE,	-- Declare Anathema
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
		--[9032] = IMMOVABLE,		-- Redirected Force
		[9024] = IMMOVABLE,		-- Mighty Gale
		[9028] = UNSTOPPABLE,	-- Chrashing Wave
		-- Shadow Warrior
		--[9096] = UNSTOPPABLE,	-- Eye Shot
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
		--[9396] = UNSTOPPABLE,	-- Agile Escape
		-- Disciple of Khaine
		[9565] = UNSTOPPABLE,	-- Consume Thought
		-- Sorcerer
		[9482] = UNSTOPPABLE,	-- Frostbite
		[9489] = UNSTOPPABLE,	-- Stricken Voices
	},
}

function Vanillasaver.Initialize()
	-- No old settings use default settings
	if not Vanillasaver.Settings then
		Vanillasaver.Settings = Vanillasaver.DefaultSettings
	
	-- Import old settings
	elseif Vanillasaver.Settings then
		Vanillasaver.Settings.Version = Vanillasaver.DefaultSettings.Version
		Vanillasaver.Settings.Enabled = Vanillasaver.Settings.Enabled or Vanillasaver.DefaultSettings.Enabled
		Vanillasaver.Settings.Symbols = Vanillasaver.Settings.Symbols or Vanillasaver.DefaultSettings.Symbols
		Vanillasaver.Settings.ErrorMessages = Vanillasaver.Settings.ErrorMessages or Vanillasaver.DefaultSettings.ErrorMessages
		Vanillasaver.Settings.Abilities = Vanillasaver.Settings.Abilities or Vanillasaver.DefaultSettings.Abilities
	end
	
	LibSlash.RegisterSlashCmd("Vanillasaver", function(input) Vanillasaver_Config.Slash(input) end)
	
	if Vanillasaver.Settings.Enabled then Vanillasaver.RegisterEvents()	end
	
	TextLogAddEntry("Chat", 0, towstring("<icon57> Vanillasaver loaded. Type /Vanillasaver for settings."))
end

function Vanillasaver.OnShutdown()
	Vanillasaver.UnregisterEvents()
end

function Vanillasaver.RegisterEvents()
	if not eventsRegistered then
		RegisterEventHandler(SystemData.Events.ENTER_WORLD, "Vanillasaver.ENTER_WORLD")
		RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "Vanillasaver.PLAYER_ZONE_CHANGED")
		RegisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "Vanillasaver.INTERFACE_RELOADED")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "Vanillasaver.PLAYER_TARGET_UPDATED")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_IS_IMMUNE_TO_MOVEMENT_IMPARING, "Vanillasaver.PLAYER_TARGET_IS_IMMUNE_TO_MOVEMENT_IMPARING")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_IS_IMMUNE_TO_DISABLES, "Vanillasaver.PLAYER_TARGET_IS_IMMUNE_TO_DISABLES")
		RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "Vanillasaver.PLAYER_EFFECTS_UPDATED")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "Vanillasaver.PLAYER_TARGET_EFFECTS_UPDATED")
		RegisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_UPDATED, "Vanillasaver.PLAYER_HOT_BAR_UPDATED")
	end
	eventsRegistered = true
end

function Vanillasaver.UnregisterEvents()
	if eventsRegistered then
		UnregisterEventHandler(SystemData.Events.ENTER_WORLD, "Vanillasaver.ENTER_WORLD")
		UnregisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "Vanillasaver.PLAYER_ZONE_CHANGED")
		UnregisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "Vanillasaver.INTERFACE_RELOADED")
		UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "Vanillasaver.PLAYER_TARGET_UPDATED")
		UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_IS_IMMUNE_TO_MOVEMENT_IMPARING, "Vanillasaver.PLAYER_TARGET_IS_IMMUNE_TO_MOVEMENT_IMPARING")
		UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_IS_IMMUNE_TO_DISABLES, "Vanillasaver.PLAYER_TARGET_IS_IMMUNE_TO_DISABLES")
		UnregisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "Vanillasaver.PLAYER_EFFECTS_UPDATED")
		UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "Vanillasaver.PLAYER_TARGET_EFFECTS_UPDATED")
		UnregisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_UPDATED, "Vanillasaver.PLAYER_HOT_BAR_UPDATED")
	end
	eventsRegistered = false
end

-- Event handlers
function Vanillasaver.ENTER_WORLD()
	loadingEnd = true
	Vanillasaver.ButtonIconsNeedUpdate = true
end

function Vanillasaver.PLAYER_ZONE_CHANGED()
	loadingEnd = true
	Vanillasaver.ButtonIconsNeedUpdate = true
end

function Vanillasaver.INTERFACE_RELOADED()
	loadingEnd = true
	Vanillasaver.ButtonIconsNeedUpdate = true
end

function Vanillasaver.PLAYER_TARGET_UPDATED(targetClassification, targetId, targetType)
	-- Ignore mouseover target changes
	if targetClassification == TargetInfo.FRIENDLY_TARGET and Vanillasaver.FriendlyTargetId ~= targetId then
		Vanillasaver.FriendlyTargetId = targetId
		Vanillasaver.FriendlyTargetEffects = {}
		Vanillasaver.TargetImmovable = false
		Vanillasaver.TargetUnstoppable = false
		Vanillasaver.EnabledStatesNeedUpdate = true
	elseif targetClassification == TargetInfo.HOSTILE_TARGET and Vanillasaver.HostileTargetId ~= targetId then
		Vanillasaver.HostileTargetId = targetId
		Vanillasaver.HostileTargetEffects = {}
		Vanillasaver.TargetImmovable = false
		Vanillasaver.TargetUnstoppable = false
		Vanillasaver.EnabledStatesNeedUpdate = true
	end
end

function Vanillasaver.PLAYER_TARGET_IS_IMMUNE_TO_DISABLES(state)
	Vanillasaver.TargetUnstoppable = state
	Vanillasaver.EnabledStatesNeedUpdate = true
end

function Vanillasaver.PLAYER_TARGET_IS_IMMUNE_TO_MOVEMENT_IMPARING(state)
	Vanillasaver.TargetImmovable = state
	Vanillasaver.EnabledStatesNeedUpdate = true
end

function Vanillasaver.PLAYER_EFFECTS_UPDATED(updatedEffects, isFullList)
	if not updatedEffects then return end
	for k, v in pairs(updatedEffects) do
		if v.castByPlayer then
			Vanillasaver.SelfTargetEffects[k] = v.abilityId
			Vanillasaver.EnabledStatesNeedUpdate = true
		elseif Vanillasaver.SelfTargetEffects[k] then
			Vanillasaver.SelfTargetEffects[k] = nil
			Vanillasaver.EnabledStatesNeedUpdate = true
		end
	end
end

function Vanillasaver.PLAYER_TARGET_EFFECTS_UPDATED(updateType, updatedEffects, isFullList)
	if not updatedEffects then return end
	for k, v in pairs(updatedEffects) do
		if updateType == GameData.BuffTargetType.TARGET_HOSTILE then
			-- Effect cast by player applied on hostile target
			if v.castByPlayer then
				Vanillasaver.HostileTargetEffects[k] = v.abilityId
				Vanillasaver.EnabledStatesNeedUpdate = true
			-- Effect cast by player removed from hostile target
			elseif Vanillasaver.HostileTargetEffects[k] then
				Vanillasaver.HostileTargetEffects[k] = nil
				Vanillasaver.EnabledStatesNeedUpdate = true
			end
		elseif updateType == GameData.BuffTargetType.TARGET_FRIENDLY then
			-- Effect cast by player applied on friendly target
			if v.castByPlayer then
				Vanillasaver.FriendlyTargetEffects[k] = v.abilityId
				Vanillasaver.EnabledStatesNeedUpdate = true
			-- Effect cast by player removed from friendly target
			elseif Vanillasaver.FriendlyTargetEffects[k] then
				Vanillasaver.FriendlyTargetEffects[k] = nil
				Vanillasaver.EnabledStatesNeedUpdate = true
			end
		end
	end
end

function Vanillasaver.PLAYER_HOT_BAR_UPDATED(slot, actionType, actionId)
	Vanillasaver.UpdateButtonIcon(slot, Vanillasaver.Settings.Abilities[actionId])
	Vanillasaver.UpdateButtonEnabledState(slot)
end

-- Main update function
function Vanillasaver.OnUpdate(elapsed)
	if not loadingEnd then return end
	if not Vanillasaver.Settings.Enabled then return end
	
	timeLeft = timeLeft - elapsed
    if timeLeft > 0 then
        return
    end
    timeLeft = TIME_DELAY
	
	if Vanillasaver.ButtonIconsNeedUpdate then
		Vanillasaver.UpdateButtonIcons()
		Vanillasaver.ButtonIconsNeedUpdate = false
	end
	
	if Vanillasaver.EnabledStatesNeedUpdate then
		Vanillasaver.UpdateButtonsEnabledStates()
		Vanillasaver.EnabledStatesNeedUpdate = false
	end
end

function Vanillasaver.UpdateSettings()
	if Vanillasaver.Settings.Enabled and not eventsRegistered then
		Vanillasaver.RegisterEvents()
	elseif not Vanillasaver.Settings.Enabled and eventsRegistered then
		Vanillasaver.UnregisterEvents()
	end
	
	Vanillasaver.UpdateButtonIcons()

	TextLogAddEntry("Chat", 0, towstring("Vanillasaver v" .. tostring(Vanillasaver.Settings.Version) .. " settings: /Vanillasaver"))
	if Vanillasaver.Settings.Enabled then
		TextLogAddEntry("Chat", 0, L"--- <icon57> Enabled")
	else
		TextLogAddEntry("Chat", 0, L"--- <icon58> Enabled")
	end
	if Vanillasaver.Settings.Symbols then
		TextLogAddEntry("Chat", 0, L"--- <icon57> Show Symbols")
	else
		TextLogAddEntry("Chat", 0, L"--- <icon58> Show Symbols")
	end
	if Vanillasaver.Settings.ErrorMessages then
		TextLogAddEntry("Chat", 0, L"--- <icon57> Show Combat Error Messages")
	else
		TextLogAddEntry("Chat", 0, L"--- <icon58> Show Combat Error Messages")
	end
end

function Vanillasaver.UpdateButtonIcons()
	local actionType, actionId, isSlotEnabled, isTargetValid, isSlotBlocked
	for i = 1, MAX_BUTTONS do
		actionType, actionId, isSlotEnabled, isTargetValid, isSlotBlocked = GetHotbarData(i)
		if Vanillasaver.Settings.Enabled and Vanillasaver.Settings.Symbols and Vanillasaver.Settings.Abilities[actionId] then
			Vanillasaver.UpdateButtonIcon(i, Vanillasaver.Settings.Abilities[actionId])
		elseif (not Vanillasaver.Settings.Enabled or not Vanillasaver.Settings.Symbols) and Vanillasaver.Settings.Abilities[actionId] then
			Vanillasaver.UpdateButtonIcon(i, 0)
		end
	end
end

function Vanillasaver.UpdateButtonIcon(slot, check)
	local hbar, buttonid, button
	local buttonActionId
	hbar, buttonid = ActionBars:BarAndButtonIdFromSlot(slot)
	if hbar and buttonid then
		button = hbar.m_Buttons[buttonid]
		if not check then
			--button.m_Windows[7]:Show(false)
		elseif check == IMMOVABLE then
			button.m_Windows[7]:Show(true)
			button.m_Windows[7]:SetText("<icon05007>")
		elseif check == UNSTOPPABLE then
			button.m_Windows[7]:Show(true)
			button.m_Windows[7]:SetText("<icon05006>")
		elseif check >= 1 and check <= 3 then
			button.m_Windows[7]:Show(true)
			button.m_Windows[7]:SetFont("font_default_war_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
			button.m_Windows[7]:SetTextColor(255, 255, 0)
			button.m_Windows[7]:SetText(tostring(check).."x")
		elseif check == 0 then
			button.m_Windows[7]:Show(false)
		end
	end
end

function Vanillasaver.UpdateButtonsEnabledStates()
	for i = 1, MAX_BUTTONS do
		Vanillasaver.UpdateButtonEnabledState(i)
	end
end

function Vanillasaver.UpdateButtonEnabledState(slot)
	local actionType, actionId, isSlotEnabled, isTargetValid, isSlotBlocked = GetHotbarData(slot)
	--if actionId ~= 0 then
	if Vanillasaver.Settings.Abilities[actionId] then
		ActionBars.UpdateSlotEnabledState(slot, isSlotEnabled, isTargetValid, isSlotBlocked)
	end
end

-- Hooked Functions
local orgActionButtonOnLButtonDown = ActionButton.OnLButtonDown
function ActionButton.OnLButtonDown(self, flags, x, y)
	if flags == SystemData.ButtonFlags.SHIFT and self.m_ActionId ~= 0 then
		if not Vanillasaver.Settings.Abilities[self.m_ActionId] then
			Vanillasaver.Settings.Abilities[self.m_ActionId] = 1
		elseif Vanillasaver.Settings.Abilities[self.m_ActionId] < 5 then
			Vanillasaver.Settings.Abilities[self.m_ActionId] = Vanillasaver.Settings.Abilities[self.m_ActionId] + 1
		else
			Vanillasaver.Settings.Abilities[self.m_ActionId] = nil
		end

		Vanillasaver.UpdateButtonIcon(self.m_HotBarSlot, Vanillasaver.Settings.Abilities[self.m_ActionId] or 0)
		Vanillasaver.UpdateButtonEnabledState(self.m_HotBarSlot)
		chatInfo(self.m_ActionId, Vanillasaver.Settings.Abilities[self.m_ActionId])

		-- Block WindowGameAction
		WindowGameAction = blockedWindowGameAction

	elseif self.m_ActionId ~= 0
	and Vanillasaver.Settings.Abilities[self.m_ActionId]
	and isAbilityBlocked(self.m_ActionId) then
		-- Block WindowGameAction
		WindowGameAction = blockedWindowGameAction

	else
		-- Restore WindowGameAction
		WindowGameAction = orgWindowGameAction

		orgActionButtonOnLButtonDown(self, flags, x, y)
	end
end

local orgActionBarsUpdateSlotEnabledState = ActionBars.UpdateSlotEnabledState
function ActionBars.UpdateSlotEnabledState(slot, isSlotEnabled, isTargetValid, isSlotBlocked)
	local hbar, buttonid = ActionBars:BarAndButtonIdFromSlot(slot)
	if hbar and buttonid then
		local button = hbar.m_Buttons[buttonid]
		local abilityData = GetAbilityData(button.m_ActionId)
		
		if Vanillasaver.Settings.Abilities[button.m_ActionId]
		and Vanillasaver.Settings.Abilities[button.m_ActionId] == IMMOVABLE
		and Vanillasaver.TargetImmovable
		then
			isSlotEnabled = false
		elseif Vanillasaver.Settings.Abilities[button.m_ActionId]
		and Vanillasaver.Settings.Abilities[button.m_ActionId] == UNSTOPPABLE
		and Vanillasaver.TargetUnstoppable
		then
			isSlotEnabled = false
		elseif Vanillasaver.Settings.Abilities[button.m_ActionId]
		and hasBuff(getTargetType(abilityData.targetType), abilityData, Vanillasaver.Settings.Abilities[button.m_ActionId])
		then
			isSlotEnabled = false
		end
	end
	orgActionBarsUpdateSlotEnabledState(slot, isSlotEnabled, isTargetValid, isSlotBlocked)
end

local orgActionButtonUpdateInventory = ActionButton.UpdateInventory
function ActionButton.UpdateInventory(self)
	if not Vanillasaver.Settings.Abilities[self.m_ActionId] then
		orgActionButtonUpdateInventory(self)
	end
end
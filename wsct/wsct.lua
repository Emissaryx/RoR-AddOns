--[[
  ****************************************************************
  Warhammer Scrolling Combat Text

  Author: Grayhoof
  ****************************************************************

  Official Site:
    http://grayhoof.wowinterface.com

  ****************************************************************]]
WSCT = {}
local WSCT = WSCT
local db

WSCT.title = "WSCT"
WSCT.Version = L"1.40"
WSCT.LowHpTime = 0

-- local constants
local last_hp_percent = 0
local last_morale_level = 0
local last_hp_time = 0
local last_ap_amount = (GameData.Player and GameData.Player.actionPoints and GameData.Player.actionPoints.current) or 0
local last_resource_amount = 0
local career_strings = {}
local global_cooldown = 1.4
local preBuffs = {}
local foundBuffs = {}
local eventCountMax = 500
WSCT._eventCount = 0
WSCT._lastUpdate = 0
WSCT._fps = 0
WSCT._throttleIdealFPS = 60
local EVENT_COUNT_MAX = 500

--LUA calls
local pairs = pairs
local towstring = towstring
local string_gsub = wstring.gsub
local string_match = wstring.match
local string_format = wstring.format
local string_len = wstring.len
local string_sub = wstring.sub
local GetMoraleCooldown = GetMoraleCooldown
local GetBuffs = GetBuffs
local math_floor = math.floor

local GetFormatStringFromTable = GetFormatStringFromTable
local RegisterEventHandler = RegisterEventHandler
local UnregisterEventHandler = UnregisterEventHandler
local AlertTextWindow_AddLine = AlertTextWindow.AddLine
local DataUtils_GetAbilityTypeText = DataUtils.GetAbilityTypeText
local DataUtils_GetAbilityTypeTextureAndColor = DataUtils.GetAbilityTypeTextureAndColor
local WStringToString = WStringToString

local GetAbilityData = GetAbilityData
local GetAbilityName = GetAbilityName
local GetIconData = GetIconData

local PlaySound = PlaySound
local GetComputerTime = GetComputerTime

--combat events
local COMBAT_EVENTS = {
  [GameData.CombatEvent.CRITICAL] = "DAMAGE",
  [GameData.CombatEvent.ABILITY_CRITICAL] = "DAMAGE",
  [GameData.CombatEvent.HIT] = "DAMAGE",
  [GameData.CombatEvent.ABILITY_HIT] = "DAMAGE",
  [GameData.CombatEvent.DISRUPT] = "MISS",
  [GameData.CombatEvent.EVADE] = "MISS",
  [GameData.CombatEvent.IMMUNE] = "MISS",
  [GameData.CombatEvent.PARRY] = "MISS",
  [GameData.CombatEvent.BLOCK] = "MISS",
  [GameData.CombatEvent.ABSORB] = "MISS",
}

local BUFF_TYPE_DURATION = 1
local BUFF_TYPE_PERMANENT_UNTIL_DISPELLED = 2
WSCT._buffsPermanentUntilDispelledKeep = {}
WSCT._buffsPermanentUntilDispelledKeepDuration = 5

local COMBAT_DAMAGE_EVENTS = {
  [GameData.CombatEvent.CRITICAL] = "SHOWHIT",
  [GameData.CombatEvent.ABILITY_CRITICAL] = "SHOWSPELL",
  [GameData.CombatEvent.HIT] = "SHOWHIT",
  [GameData.CombatEvent.ABILITY_HIT] = "SHOWSPELL",
}

local COMBAT_MISS_EVENTS = {
  [GameData.CombatEvent.DISRUPT] = { event="SHOWRESIST", text=GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_DISRUPT)},
  [GameData.CombatEvent.EVADE] = { event="SHOWDODGE", text=GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_EVADE)},
  [GameData.CombatEvent.IMMUNE] = { event="SHOWABSORB", text=GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_IMMUNE)},
  [GameData.CombatEvent.PARRY] = { event="SHOWPARRY", text=GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_PARRY)},
  [GameData.CombatEvent.BLOCK] = { event="SHOWBLOCK", text=GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_BLOCK)},
  [GameData.CombatEvent.ABSORB] = { event="SHOWABSORB", text=GetStringFromTable("CombatEvents", StringTables.CombatEvents.LABEL_ABSORB)},
}

-------------------------
--clean a single level table
local function del(t)
  for k in pairs(t) do
    t[k] = nil
  end
end

-------------------------
--copy new defaults if they aren't already there.
local function inheritdefaults(t, defaults)
  for k,v in pairs(defaults) do
    if type(v) == "table" then
      if type(t[k]) ~= "table" then
        t[k] = {}
      end
      inheritdefaults(t[k], v)
    elseif t[k] == nil then
      t[k] = v
    end
  end
  return t
end

-------------------------
--determine buff type
local function bufftype(buff)
  local frame = DataUtils_GetAbilityTypeTextureAndColor(buff)
  if frame == "Debuff-Frame" then
    return "SHOWDEBUFF"
  else
    return "SHOWBUFF"
  end
end

-------------------------
--Print to screen
function WSCT:Print(txt)
  EA_ChatWindow.Print(L"[WSCT]:"..towstring(txt))
end



-------------------------
--Regsiter WSCT with all events
function WSCT:RegisterSelfEvents()
  UnregisterEventHandler( SystemData.Events.WORLD_OBJ_COMBAT_EVENT, "EA_System_EventText.AddCombatEventText")
  UnregisterEventHandler( SystemData.Events.WORLD_OBJ_XP_GAINED, "EA_System_EventText.AddXpText")
  UnregisterEventHandler( SystemData.Events.WORLD_OBJ_RENOWN_GAINED, "EA_System_EventText.AddRenownText")
  UnregisterEventHandler( SystemData.Events.WORLD_OBJ_INFLUENCE_GAINED, "EA_System_EventText.AddInfluenceText")

  RegisterEventHandler(SystemData.Events.WORLD_OBJ_COMBAT_EVENT, "WSCT.OnCombatEvent")
  RegisterEventHandler(SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "WSCT.PLAYER_COMBAT_FLAG_UPDATED")
  RegisterEventHandler(SystemData.Events.WORLD_OBJ_XP_GAINED, "WSCT.WORLD_OBJ_XP_GAINED")
  RegisterEventHandler(SystemData.Events.WORLD_OBJ_RENOWN_GAINED, "WSCT.WORLD_OBJ_RENOWN_GAINED")
  RegisterEventHandler(SystemData.Events.WORLD_OBJ_INFLUENCE_GAINED, "WSCT.WORLD_OBJ_INFLUENCE_GAINED")
  RegisterEventHandler(SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED, "WSCT.PLAYER_CUR_HIT_POINTS_UPDATED")
  RegisterEventHandler(SystemData.Events.PLAYER_MORALE_UPDATED, "WSCT.PLAYER_MORALE_UPDATED")
  RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "WSCT.PLAYER_EFFECTS_UPDATED")
  RegisterEventHandler(SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED, "WSCT.PLAYER_CUR_ACTION_POINTS_UPDATED")
  RegisterEventHandler(SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED, "WSCT.PLAYER_CAREER_RESOURCE_UPDATED")
end

-------------------------
--Unregsiter WSCT with all events
function WSCT:UnregisterSelfEvents()
  UnregisterEventHandler(SystemData.Events.WORLD_OBJ_COMBAT_EVENT, "WSCT.OnCombatEvent")
  UnregisterEventHandler(SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "WSCT.PLAYER_COMBAT_FLAG_UPDATED")
  UnregisterEventHandler(SystemData.Events.WORLD_OBJ_XP_GAINED, "WSCT.WORLD_OBJ_XP_GAINED")
  UnregisterEventHandler(SystemData.Events.WORLD_OBJ_RENOWN_GAINED, "WSCT.WORLD_OBJ_RENOWN_GAINED")
  UnregisterEventHandler(SystemData.Events.WORLD_OBJ_INFLUENCE_GAINED, "WSCT.WORLD_OBJ_INFLUENCE_GAINED")
  UnregisterEventHandler(SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED, "WSCT.PLAYER_CUR_HIT_POINTS_UPDATED")
  UnregisterEventHandler(SystemData.Events.PLAYER_MORALE_UPDATED, "WSCT.PLAYER_MORALE_UPDATED")
  UnregisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "WSCT.PLAYER_EFFECTS_UPDATED")
  UnregisterEventHandler(SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED, "WSCT.PLAYER_CUR_ACTION_POINTS_UPDATED")
  UnregisterEventHandler(SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED, "WSCT.PLAYER_CAREER_RESOURCE_UPDATED")

  RegisterEventHandler( SystemData.Events.WORLD_OBJ_COMBAT_EVENT, "EA_System_EventText.AddCombatEventText")
  RegisterEventHandler( SystemData.Events.WORLD_OBJ_XP_GAINED, "EA_System_EventText.AddXpText")
  RegisterEventHandler( SystemData.Events.WORLD_OBJ_RENOWN_GAINED, "EA_System_EventText.AddRenownText")
  RegisterEventHandler( SystemData.Events.WORLD_OBJ_INFLUENCE_GAINED, "EA_System_EventText.AddInfluenceText")
end

----------------------
--Called when Addon loaded
function WSCT:OnInitialize()
  local self = WSCT

  --setup options
  if not WSCT_CONFIG then
    WSCT_CONFIG = self:GetDefaultConfig()
  else
    WSCT_CONFIG = inheritdefaults(WSCT_CONFIG, self:GetDefaultConfig())
  end
  self.db = WSCT_CONFIG
  db = self.db.profile

  --register slash commands
  if LibSlash then
    LibSlash.RegisterSlashCmd("wsct", function(input) WSCT:SlashHandler(input) end)
  else
    self:HookChatWindow()
  end

  --setup animations
  self:AniInit()

  --register events
  self:RegisterSelfEvents()

  --add main window to Siege Weapon Frame Faders
  SiegeWeaponSniperFireWindow.windows[#SiegeWeaponSniperFireWindow.windows + 1] = { windowName = "WSCTContainer", shouldSetShowing = false }
  SiegeWeaponScorchFireWindow.windows[#SiegeWeaponScorchFireWindow.windows + 1] = { windowName = "WSCTContainer", shouldSetShowing = false }
  SiegeWeaponGolfFireWindow.windows[#SiegeWeaponGolfFireWindow.windows + 1] = { windowName = "WSCTContainer", shouldSetShowing = false }

  --write to chat
  TextLogAddEntry("Chat", 0, WSCT.LOCALS.STARTUP)

  --get buffs on login (since 1.21)
  self.PLAYER_EFFECTS_UPDATED()
end

----------------------
--hooks chat window to look for wsct commands
function WSCT:HookChatWindow()
  local orig_ChatWindow_OnKeyEnter = EA_ChatWindow.OnKeyEnter
  EA_ChatWindow.OnKeyEnter = function(...)

    local input = WStringToString(EA_TextEntryGroupEntryBoxTextInput.Text)
    local cmd, args = input:match("^/([a-zA-Z]+) ?(.*)")

    if cmd then
      if cmd:lower() == "wsct" then
        WSCT:SlashHandler(args)
        EA_TextEntryGroupEntryBoxTextInput.Text = L""
      end
    end

    return orig_ChatWindow_OnKeyEnter(...)
  end
end

----------------------
--Called when Addon unloaded
function WSCT:OnShutdown()
  WSCT:UnregisterSelfEvents()
  WSCT:DestroyWindows()
end

----------------------
--Reset everything to default
function WSCT:ResetProfile()
  local self = WSCT
  WSCT_CONFIG = self:GetDefaultConfig()
  self.db = WSCT_CONFIG
  db = self.db.profile
  self:AniInit()
  self:Print(WSCT.LOCALS.PROFILE_RESET)
end

----------------------
--Reset everything to default
function WSCT:Reset()
  self:ResetProfile()
  self:AniInit()
end

----------------------
--Get a value from player config
function WSCT:Get(option, ttable, ttable2)
  if (ttable) and (ttable2) then
    return db[ttable][ttable2][option]
  elseif (ttable) then
    return db[ttable][option]
  else
    return db[option]
  end
end

----------------------
--Set a value in player config
function WSCT:Set(option, value, ttable, ttable2)
  if (ttable) and (ttable2) then
    db[ttable][ttable2][option] = value
  elseif (ttable) then
    db[ttable][option] = value
  else
    db[option] = value
  end
end

-------------------------
--Create Career Strings
function WSCT:CreateCareerStrings()
  --create career object
  WSCT.CareerData = CareerResourceData:Create(GameData.Player.career.line)

  --cache career strings
  --archmage
  career_strings[GameData.CareerLine.ARCHMAGE] = {}
  career_strings[GameData.CareerLine.ARCHMAGE].HEAL = string_gsub(GetString(StringTables.Default.TEXT_HEALING_ARCHMAGE_POINTS), L":.+", L"")
  career_strings[GameData.CareerLine.ARCHMAGE].DMG = string_gsub(GetString(StringTables.Default.TEXT_DAMAGE_ARCHMAGE_POINTS), L":.+", L"")
  --shaman
  career_strings[GameData.CareerLine.SHAMAN] = {}
  career_strings[GameData.CareerLine.SHAMAN].HEAL = string_gsub(GetString(StringTables.Default.TEXT_CUR_HEALING_WAAAGH), L" .+", L"")
  career_strings[GameData.CareerLine.SHAMAN].DMG = string_gsub(GetString(StringTables.Default.TEXT_CUR_DAMAGE_WAAAGH), L" .+", L"")
  --black orc (in game doesn't show proper values
  career_strings[GameData.CareerLine.BLACK_ORC] = {}
  career_strings[GameData.CareerLine.BLACK_ORC][1] = WSCT.LOCALS.BlackOrc1
  career_strings[GameData.CareerLine.BLACK_ORC][2] = WSCT.LOCALS.BlackOrc2
end

--hack fix for double combat triggers
local combatcount = 0
----------------------
--Player Combat
function WSCT.PLAYER_COMBAT_FLAG_UPDATED()
  combatcount = combatcount + 1
  if combatcount >= 2 then
    combatcount = 0
    if GameData.Player.inCombat then
      WSCT:Display_Event("SHOWCOMBAT", WSCT.LOCALS.Combat)
    else
      WSCT:Display_Event("SHOWCOMBAT", WSCT.LOCALS.NoCombat)
    end
  end
end

----------------------
--Player XP
function WSCT.WORLD_OBJ_XP_GAINED(objectID, amount)
  local msg = GetFormatStringFromTable( "CombatEvents", StringTables.CombatEvents.LABEL_XP_POINT_GAIN, {amount})
  WSCT:Display_Event("SHOWXP", msg)
end

----------------------
--Player Renown
function WSCT.WORLD_OBJ_RENOWN_GAINED(objectID, amount)
  local msg = GetFormatStringFromTable( "CombatEvents", StringTables.CombatEvents.LABEL_RENOWN_POINT_GAIN, {amount})
  WSCT:Display_Event("SHOWRENOWN", msg)
end

----------------------
--Player Influence
function WSCT.WORLD_OBJ_INFLUENCE_GAINED(objectID, amount)
  local msg = GetFormatStringFromTable( "CombatEvents", StringTables.CombatEvents.LABEL_INFLUENCE_POINT_GAIN, {amount})
  WSCT:Display_Event("SHOWINF", msg)
end

----------------------
--Player Morale
function WSCT.PLAYER_MORALE_UPDATED(moralePercent, moraleLevel)
  if (moraleLevel > last_morale_level) and
     ((moraleLevel == 1 and moralePercent == 10) or
      (moraleLevel == 2 and moralePercent == 20) or
      (moraleLevel == 3 and moralePercent == 50) or
      (moraleLevel == 4 and moralePercent == 100))
  then
    local cd, mcd = GetMoraleCooldown(moraleLevel)
    local _, id = GetMoraleBarData (moraleLevel)
    if (cd < global_cooldown) and id then
      WSCT:Display_Event("SHOWMORALE", string_format(WSCT.LOCALS.Morale, moraleLevel))
    end
  end
  last_morale_level = moraleLevel
end

----------------------
--Player HP
function WSCT.PLAYER_CUR_HIT_POINTS_UPDATED()
  local warnlevel = db["LOWHP"] / 100
  local current_hp = GameData.Player.hitPoints.current
  local HPPercent = current_hp / GameData.Player.hitPoints.maximum
  if (HPPercent < warnlevel) and (last_hp_percent >= warnlevel) and (WSCT.LowHpTime == 0) then
    WSCT.LowHpTime = 5
    if (db["PLAYSOUND"] and db["SHOWLOWHP"]) then
      PlaySound(214)
    end
    WSCT:Display_Event("SHOWLOWHP", string_format(WSCT.LOCALS.LowHP, current_hp))
  end
  last_hp_percent = HPPercent
end

----------------------
--Player AP
function WSCT.PLAYER_CUR_ACTION_POINTS_UPDATED()
  local current_ap_amount = GameData.Player.actionPoints.current
  if (last_ap_amount < current_ap_amount) then
    WSCT:Display_Event("SHOWAP", string_format(WSCT.LOCALS.AP, current_ap_amount-last_ap_amount))
  end
  last_ap_amount = current_ap_amount
end

----------------------
--Player Resource
function WSCT.PLAYER_CAREER_RESOURCE_UPDATED(prevResourceValue, currentResourceValue)
  if (currentResourceValue ~= 0 and last_resource_amount ~= currentResourceValue) then
    last_resource_amount = currentResourceValue
    if not WSCT.CareerData then
      WSCT:CreateCareerStrings();
    end
    local career_string = WSCT.CareerData:GetLabelString()
    if GameData.Player.career.line == GameData.CareerLine.SHAMAN or GameData.Player.career.line == GameData.CareerLine.ARCHMAGE then
      if currentResourceValue >  WSCT.CareerData:GetMaximum() then
        career_string = career_strings[GameData.Player.career.line].HEAL
        currentResourceValue = currentResourceValue - WSCT.CareerData:GetMaximum()
      else
        career_string = career_strings[GameData.Player.career.line].DMG
      end
    elseif GameData.Player.career.line == GameData.CareerLine.BLACK_ORC then
      career_string = career_strings[GameData.Player.career.line][currentResourceValue]
    elseif GameData.Player.career.line == GameData.CareerLine.SWORDMASTER then
      career_string = WSCT.CareerData:GetPointsString()
    end
    WSCT:Display_Event("SHOWRESOURCE", towstring(currentResourceValue)..L" - "..career_string)
  end

end

----------------------
--Player Buffs
function WSCT.PLAYER_EFFECTS_UPDATED()
  local curBuffs = GetBuffs(GameData.BuffTargetType.SELF)
  local buffdisplay
  local bufftypename
  local buffShortDisplayFPS = WSCT._throttleIdealFPS / 2
  del(foundBuffs)

  --look for new buffs
  for k,v in pairs(curBuffs) do
    if not preBuffs[v.name] and not WSCT._buffsPermanentUntilDispelledKeep[v.name] then
      --[[
        Only show short duration buffs showing when the fps is high enough.
        If we are already to limited do not display the event.
      --]]
      if WSCT._fps >= buffShortDisplayFPS or v.duration > 10 then
        -- FIXME do the same for fade
        --new buff
        buffdisplay = L"["..WSCT.ShortenString(v.name)..L"]"
        --get type
        bufftypename = DataUtils_GetAbilityTypeText(v)
        --see if type
        if db["BUFFTYPE"] and bufftypename and bufftypename ~= L"" then
          buffdisplay = buffdisplay..L" ("..bufftypename..L")"
        end
        --get icon
	local icon
	if v.iconNum then
		icon = GetIconData(v.iconNum)
	if icon == "icon000000" then
		icon = nil
	end
	end
	WSCT:Display_Event(bufftype(v), buffdisplay, nil, nil, icon)
      end
    else
      --Flag as found
      foundBuffs[v.name] = 1
    end
    -- Found permanent buff again no need to track the time to delay notification
    if WSCT._buffsPermanentUntilDispelledKeep[v.name] then
      WSCT._buffsPermanentUntilDispelledKeep[v.name] = nil
    end
  end

  --remove found buffs
  for k in pairs(foundBuffs) do
    preBuffs[k] = nil
  end
  local timeNow = GetComputerTime()

  --any buff still left over are lost buffs
  for k,v in pairs(preBuffs) do
    if preBuffs[k] == BUFF_TYPE_PERMANENT_UNTIL_DISPELLED then
      --[[
        Track permanent buffs Commands/Auras to avoid spam when moving to or away
        from the source
      ]]--
      WSCT._buffsPermanentUntilDispelledKeep[k] = timeNow
    end
    --buff lost
    WSCT:Display_Event(v.."FADE", L"-["..WSCT.ShortenString(k)..L"]")
    preBuffs[k] = nil
  end

  --copy current buffs to old buffs table
  for k,v in pairs(curBuffs) do
    -- Safe buff type into prebuffs table
    if v.permanentUntilDispelled then
      -- Remove old cached permanent buff from notification delay table if present
      if WSCT._buffsPermanentUntilDispelledKeep[v.name] then
        WSCT._buffsPermanentUntilDispelledKeep[v.name] = nil
      end
      preBuffs[v.name] = BUFF_TYPE_PERMANENT_UNTIL_DISPELLED
    else
      preBuffs[v.name] = BUFF_TYPE_DURATION
    end
  end
end

function WSCT.OnCombatEvent(objectID, amount, combatEvent, abilityID)
  if objectID == 0 then
    return
  end

  local etype, event, msg
  local data = GetAbilityData(abilityID) or {}

  local crit =
    combatEvent == GameData.CombatEvent.CRITICAL or
    combatEvent == GameData.CombatEvent.ABILITY_CRITICAL

  local player = (objectID == GameData.Player.worldObjNum)
  local pet = (GameData.Player.Pet and objectID == GameData.Player.Pet.objNum) or false

  -- Determine event type early
  if amount > 0 and
     (combatEvent == GameData.CombatEvent.HIT or
      combatEvent == GameData.CombatEvent.ABILITY_HIT or
      combatEvent == GameData.CombatEvent.CRITICAL or
      combatEvent == GameData.CombatEvent.ABILITY_CRITICAL)
  then
    etype = "HEAL"
  else
    etype = COMBAT_EVENTS[combatEvent]
    if not etype then
      return
    end
  end

  -- FPS hard stop
  if WSCT._fps < math_floor(WSCT._throttleIdealFPS * 0.15) then
    return
  end

  -- Throttle incoming damage spam
  if etype == "DAMAGE" then
    if player or pet or data.isBlessing or data.permanentUntilDispelled then
      if WSCT._eventCount > math_floor(WSCT._fps * 0.75) then
        return
      end
    end
  end

  -- Icon lookup
  local icon
  if data.iconNum then
    icon = GetIconData(data.iconNum)
    if icon == "icon000000" then
      icon = nil
    end
  end

  -- DAMAGE
  if etype == "DAMAGE" then
    amount = -amount
    if amount < db["DMGFILTER"] then return end

    msg = towstring(amount)
    event = COMBAT_DAMAGE_EVENTS[combatEvent]
    if not event then return end

    if player or pet then
      msg = L"-" .. msg
      if db["INDMGNAME"] then
        msg = WSCT.AddName(msg, abilityID)
      end
    else
      event = event .. "OUT"
      if db["FLAGDAMAGE"] then
        msg = L"-" .. msg
      end
      if db["OUTDMGNAME"] then
        msg = WSCT.AddName(msg, abilityID)
      end
    end

  -- HEAL
  elseif etype == "HEAL" then
    if amount < db["HEALFILTER"] then return end

    msg = L"+" .. towstring(amount)
    event = "SHOWHEAL"

    if not (player or pet) then
      event = "SHOWHEALOUT"
      if db["OUTHEALNAME"] then
        msg = WSCT.AddName(msg, abilityID)
      end
    else
      if db["INHEALNAME"] then
        msg = WSCT.AddName(msg, abilityID)
      end
    end

  -- MISS
  elseif etype == "MISS" then
    if combatEvent == GameData.CombatEvent.ABSORB and amount == 0 and not (player or pet) then
      return
    end

    local missData = COMBAT_MISS_EVENTS[combatEvent]
    if not missData then
      return
    end

    msg = missData.text
    event = missData.event

    if not (player or pet) then
      event = event .. "OUT"
      if db["OUTDMGNAME"] then
        msg = WSCT.AddName(msg, abilityID)
      end
    else
      if db["INDMGNAME"] then
        msg = WSCT.AddName(msg, abilityID)
      end
    end

  else
    return
  end

  -- Pet prefix
  if pet and db["PETFLAG"] then
    msg = WSCT.LOCALS.Pet .. msg
  end

  -- Count + display
  if WSCT._eventCount < EVENT_COUNT_MAX
 then
    WSCT._eventCount = WSCT._eventCount + 1
  end

  WSCT:Display_Event(event, msg, crit, objectID, icon)
end

----------------------
--Add name to text
function WSCT.AddName(text, id)
  local ability = WSCT.ShortenString(GetAbilityName(id))
  if ability and ability ~= L"" then
    text = text..L" ("..ability..L")"
  end
  return text
end


----------------------
--Display for mainly combat events
--Mainly used for short messages
function WSCT:Display_Event(option, msg1, crit, objectID, icon)
	if not db[option] then
		return
	end

	local rbgcolor, showcrit, showmsg, event
	if (db[option]) then
    --get options
    rbgcolor = db[self.COLORS_TABLE][option]
    showcrit = db[self.CRITS_TABLE][option]
    showmsg = db[self.FRAMES_TABLE][option] or 1

    if showmsg == WSCT.MSG then
      self:DisplayMessage( msg1, rbgcolor)
    else
      event = "event"
      --set event type
      if (option == "SHOWHIT" or option == "SHOWSPELL" or option == "SHOWHEAL") then
        event = "damage"
      end
      --see if crit override
      if (showcrit) then crit = 1 end
      --display
      self:DisplayText(msg1, rbgcolor, crit, event, showmsg, nil, objectID, icon)
    end
  end
end

----------------------
--Displays a message at the top of the screen
function WSCT:DisplayMessage(msg, color)
  AlertTextWindow_AddLine(SystemData.AlertText.Types.DEFAULT, msg)
end

------------------------------
---Shorten a spell/buff
function WSCT.ShortenString(strString)
  if db["TRUNCATE"] and string_len(strString) > db["TRUNCATESIZE"] then
    if db["TRUNCATETYPE"] == 1 then
      strString = string_sub(strString, 1, db["TRUNCATESIZE"])..L"..."
    else
      strString = string_match(string_gsub(string_gsub(string_gsub(strString,L" of ", L"O"), L"%s",L""), L"%l*", L""), L"([^^]+)^?.*")
    end
  end
  return strString
end

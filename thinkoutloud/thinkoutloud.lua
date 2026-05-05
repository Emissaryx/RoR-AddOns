-- ThinkOutLoud - Announces to specified chat channels when you use abilities
--
-- Author: Thanners 20080917
-- vim:ts=4:sw=4:sts=4:et:
--

local tinsert = table.insert
local VERSION = {major=1,minor=3,patch=4}

ThinkOutLoud = {
    CMD_SAY = 1,
    CMD_TELL = 2,
    CMD_PARTY = 3,
    CMD_EMOTE = 4,
    CMD_SHOUT = 5,
    CMD_GUILD = 6,
    CMD_OFFICER = 7,
    CMD_ALLIANCE = 8,
    CMD_AOFFICER = 9,
    CMD_REGION = 10,
    CMD_REGION_RVR = 11,
    CMD_WARBAND= 12,
    CMD_SCENARIO = 13,
    CMD_SCENPARTY = 14,
    CMD_SMART = 15,
    CMD_SMART_PARTY = 16,

    CHANNELS = {
        [1] = "SAY",
        [2] = "TELL",
        [3] = "PARTY",
        [4] = "EMOTE",
        [5] = "SHOUT",
	[6] = "GUILD",
	[7] = "OFFICER",
	[8] = "ALLIANCE",
	[9] = "ALLIANCE OFFICER",
        [10] = "REGION",
        [11] = "REGION RVR",
        [12] = "WARBAND",
        [13] = "SCENARIO",
        [14] = "SCENPARTY",
        [15] = "SMARTCHANNEL",
        [16] = "SMARTCHANNEL (PARTY)",
    },

    -- events we could (potentially) handle, as shown to a user.
    USER_EVENTS = {
        L"SPELLCAST",
    },

    -- current time
    timenow=nil,
    -- last time we spoke for a particular skill use.
    skillLastSpeakTime={},
    -- minimum time before we speak again for the same skill.
    skillThrottleTime=1.4,
    -- last time we spoke anything.
    lastSpeakTime=nil,

    -- If we're not valid, don't save settings or we might overwrite settings
    -- that just didn't load properly.
    valid=false,
    isDefault=false,
}

local EVENTS = {
    [SystemData.Events.PLAYER_BEGIN_CAST] = "ThinkOutLoud.OnCast",
}

ThinkOutLoud.CHANNEL_SWITCHER = {
    [ThinkOutLoud.CMD_SAY] = L"/s",
    [ThinkOutLoud.CMD_TELL] = L"/t %F",
    [ThinkOutLoud.CMD_PARTY] = L"/p",
    [ThinkOutLoud.CMD_EMOTE] = L"/em",
    [ThinkOutLoud.CMD_SHOUT] = L"/sh",
    [ThinkOutLoud.CMD_GUILD] = L"/g",
    [ThinkOutLoud.CMD_OFFICER] = L"/o",
    [ThinkOutLoud.CMD_ALLIANCE] = L"/a",
    [ThinkOutLoud.CMD_AOFFICER] = L"/ao",
    [ThinkOutLoud.CMD_REGION] = L"/1",
    [ThinkOutLoud.CMD_REGION_RVR] = L"/2",
    [ThinkOutLoud.CMD_WARBAND] = L"/wb",
    [ThinkOutLoud.CMD_SCENARIO] = L"/sc",
    [ThinkOutLoud.CMD_SCENPARTY] = L"/sp",
}



local function Print(txt)
    if "string" == type(txt) then
        EA_ChatWindow.Print(L"TOL:"..StringToWString(txt))
    else
        EA_ChatWindow.Print(L"TOL:"..txt)
    end
end

local function SendChat(phrase, target, friend, targetprof, targeticon, friendprof, friendicon)
    local s = ThinkOutLoud.ReplaceVariables(phrase.text, target, friend, targetprof, targeticon, friendprof, friendicon)
    local channel = phrase.channel
    if ThinkOutLoud.CMD_SMART == channel then
        AutoChannel.sendChatBandSay(s)
        return;
    elseif ThinkOutLoud.CMD_SMART_PARTY == channel then
        AutoChannel.sendChatPartySay(s)
        return;
    end
    if AutoChannel.isScenario() then
        if (channel == ThinkOutLoud.CMD_PARTY) then
            channel = ThinkOutLoud.CMD_SCENPARTY
        elseif (channel == ThinkOutLoud.CMD_WARBAND) then
            channel = ThinkOutLoud.CMD_SCENARIO
        end
    end
    local switcher = ThinkOutLoud.CHANNEL_SWITCHER[channel]
    if channel == ThinkOutLoud.CMD_TELL then
        switcher = replaceMulti(switcher, {"%%[Ff]"}, {friend})
    end

    if ThinkOutLoud.Settings.isMute then
        Print(L"[muted] "..switcher..L" "..s)
        return
    end

   message = tostring(switcher).." "..tostring(s)
   SendChatText(towstring(message), L"")
end 


-- This one is only to try to prevent speech triggered by the same skill
-- within some short time.
function ThinkOutLoud.IsDoubleCast(skill)
    local now = ThinkOutLoud.timenow
    local earlier = ThinkOutLoud.skillLastSpeakTime[skill.name]
    if not now then return end
    if earlier and (now - earlier) < ThinkOutLoud.skillThrottleTime then
        return true
    else
        return false
    end
end


-- This one is for the user to prevent themselves from spamming too
-- many times in a short time. isUrgent skills will bypass this one.
function ThinkOutLoud.IsTooSoon()
    local now = ThinkOutLoud.timenow
    local earlier = ThinkOutLoud.lastSpeakTime
    if not now then return end
    if earlier and (now - earlier) < ThinkOutLoud.Settings.throttleTime then
        return true
    else
        return false
    end
end


function ThinkOutLoud.SkillSpeakChance(skill)
    if ThinkOutLoud.IsDoubleCast(skill) then
        return 0.00
    elseif skill.isUrgent then
        return 1.00
    elseif ThinkOutLoud.IsTooSoon() then
        return 0.00
    else
        return skill.speakChance or ThinkOutLoud.Settings.speakChance
    end
end

function replaceMulti(input, searches, replaces)
    if replaces == nil then
        replaces = {}
    end
    for i=1,table.getn(searches) do
        input  = tostring(input)
        d("Replacing "..tostring(searches[i]).." with "..tostring(replaces[i] or ""))
        input = input:gsub(tostring(searches[i]), tostring(replaces[i] or ""));
    end
    return input
end
function ThinkOutLoud.ReplaceVariables(s, target, friend, targetprof, targeticon, friendprof, friendicon)
    d(friendprof)
    if target ~= L"" then
        target = replaceMulti(target, {"-GunbadBossPQ", "-SideBoss", "-GunbadLairBoss"})
    end
    return replaceMulti(s, {"%%[Tt]", "%%[Pp]", "%%[Ee]", "%%[Ff]", "%%[Cc]", "%%[Ii]"}, {target, targetprof, targeticon, friend, friendprof, friendicon})
end


function ThinkOutLoud.OnCast(actionId, isChannel, desiredCastTime, averageLatency)
    local target = TargetInfo:UnitName("selfhostiletarget")
    local targetprof = TargetInfo:UnitCareerName("selfhostiletarget")
    local targetcareer = TargetInfo:UnitCareer("selfhostiletarget")
    local targeticon = L""

    if targetcareer then
        local iconId = Icons.GetCareerIconIDFromCareerLine(tonumber(targetcareer))
        if iconId then
            targeticon = L"<icon"..towstring(iconId)..L">"
        end
    end

    local playername = GameData.Player.name:match(L"(.*)\^(.*)")

    local friend = TargetInfo:UnitName("selffriendlytarget")
    local friendprof = TargetInfo:UnitCareerName("selffriendlytarget")
    local careerLine = TargetInfo:UnitCareer("selffriendlytarget")
    local friendicon = L""

    if careerLine then
        local iconId = Icons.GetCareerIconIDFromCareerLine(tonumber(careerLine))
        if iconId then
            friendicon = L"<icon"..towstring(iconId)..L">"
        end
    end

    local isTargettingSelf = (friend == playername)
    if isTargettingSelf then
        friendprof = GameData.Player.career.name
    end

    local data = Player.GetAbilityData(actionId)
    if not data then return end
    local name = data.name:match(L"(.*)\^(.*)")
    local skill = ThinkOutLoud.Settings.skills[name]
    if skill then
        local r = math.random()
        if r > ThinkOutLoud.SkillSpeakChance(skill) then
            return
        end
        local phrase = skill:randomPhrase(
            ThinkOutLoud.Settings.tags,
            isTargettingSelf
        )
        if phrase then
            SendChat(phrase, target, friend, targetprof, targeticon, friendprof, friendicon)
            ThinkOutLoud.skillLastSpeakTime[skill.name] = ThinkOutLoud.timenow
            ThinkOutLoud.lastSpeakTime = ThinkOutLoud.timenow
        end
    end
end


-------
-- Annoying stuff
------------------

function ThinkOutLoud.SetMute(isMute)
    ThinkOutLoud.Settings.isMute = isMute
    if isMute then
        Print("mute: ON")
    else
        Print("mute: OFF")
    end
end


function ThinkOutLoud.SetSpeakChance(speakChance)
    speakChance = tonumber(speakChance)
    if speakChance < 0 or speakChance > 1 then
        Print("speakchance must be between 0.0 and 1.0 (ideally less than 0.10)")
        return
    end
    ThinkOutLoud.Settings.speakChance = speakChance
    Print("speakchance: "..speakChance)
    if speakChance > 0.10 then
        Print("WARNING. speakchance greater than 10% can become Very Spammy.")
    end
end


function ThinkOutLoud.HandleSlashCommands(args)
    local opt, val = args:match("([a-zA-Z0-9]+)[ ]?(.*)")
    if "resetallsettings" == opt then
        ThinkOutLoud.InitSettings()
        ThinkOutLoud.LoadSettings(TOL_CONFIGS["DEFAULT"])
        Print("All settings and skills reset to default")
    elseif "loadtest" == opt then
        ThinkOutLoud.InitSettings()
        ThinkOutLoud.LoadSettings(TOL_CONFIGS["thanners-shaman"])
    elseif "config" == opt then
        TOLSettingsUI.SetShowing(true)
    elseif "hide" == opt then
        TOLSettingsUI.SetShowing(false)
    elseif "mute" == opt then
        ThinkOutLoud.SetMute(true)
    elseif "unmute" == opt then
        ThinkOutLoud.SetMute(false)
    elseif "speakchance" == opt then
        if val ~= "" then
            ThinkOutLoud.SetSpeakChance(val)
        else
            Print("speakchance: "..ThinkOutLoud.Settings.speakChance)
        end
    elseif "throttle" == opt then
        if val ~= "" then
            ThinkOutLoud.Settings.throttleTime = tonumber(val) or 0
            Print("throttle set to "..ThinkOutLoud.Settings.throttleTime)
        else
            Print("throttle: "..ThinkOutLoud.Settings.throttleTime)
        end
    else
        Print("Usage:")
        Print(" You may use /tol or /thinkoutloud")
        Print(" /tol resetallsettings   (reload settings from config.lua)")
        Print(" /tol mute|unmute")
        Print(" /tol speakchance CHANCE  (default: 0.05)")
        Print(" /tol throttle TIME       (default: 0 seconds)")
        Print(" /tol config  (open up the configuration GUI)")
    end
end
    

function ThinkOutLoud.RegisterEventHandlers()
    for e,h in pairs(EVENTS) do
        RegisterEventHandler(e, h)
    end
end


function ThinkOutLoud.UnregisterEventHandlers()
    for e,h in pairs(EVENTS) do
        UnregisterEventHandler(e, h)
    end
end


function ThinkOutLoud.SetSetting(key, value)
    local player = WStringToString(GameData.Player.name)
    local settings = ThinkOutLoud.Settings[player]
    settings[key] = value
end


function ThinkOutLoud.GetSetting(key)
    local player = WStringToString(GameData.Player.name)
    local settings = ThinkOutLoud.Settings[player]
    if settings[key] ~= nil then
        return settings[key]
    else
        if ThinkOutLoud.DefaultSettings[key] ~= nil then
            settings = ThinkOutLoud.DefaultSettings[key]
            return settings[key]
        else
            return nil
        end
    end
end


function ThinkOutLoud.InitSettings()
    ThinkOutLoud.Settings = {
        version = VERSION,
        speakChance = 0.05,
        isMute = false,
        skills = {},
        tags = {},
        throttleTime=0,
    }
    -- all tags on by default.
    ThinkOutLoud.Settings.tags = TOLSet.new(ThinkOutLoud.CHANNELS)
end


-- TODO: Write functions for handling the version comparison
function ThinkOutLoud.LoadSettings(loadSettings)
    -- fill in other Settings
    if loadSettings.speakChance then
        ThinkOutLoud.Settings.speakChance = loadSettings.speakChance
    end
    if loadSettings.throttleTime then
        ThinkOutLoud.Settings.throttleTime = loadSettings.throttleTime
    end

    -- populate skills table
    for _,v in pairs(loadSettings.skills) do
        local skill = TOLSkill.new(v.name, v.isUrgent, v.speakChance)
        for _, phrase in pairs(v.phrases) do
            skill:insertPhrase(phrase)
        end
        ThinkOutLoud.Settings.skills[v.name] = skill
    end
    ThinkOutLoud.valid = true
end

function ThinkOutLoud.SaveSettings()
    if ThinkOutLoud.isDefault then
        return
    end
    if not ThinkOutLoud.valid then
        Print("Failed to save, due to loading broken!")
        return
    end
    local settings = ThinkOutLoud.Settings
    local save = {}
    save.version = settings.version
    save.speakChance = settings.speakChance
    save.throttleTime = settings.throttleTime
    save.skills = {}
    for k,v in pairs(settings.skills) do
        tinsert(save.skills, v:save())
    end
    ThinkOutLoud.PersistentSettings = save
end

function ThinkOutLoud.Initialize()

    ThinkOutLoud = ThinkOutLoud or {}

    if type(ThinkOutLoud.PersistentSettings) ~= "table" then
        ThinkOutLoud.PersistentSettings = {}
    end

    ThinkOutLoud.RegisterEventHandlers()

    local slashes = {"tol", "thinkoutloud"}
    for _, s in pairs(slashes) do
        local r = LibSlash.RegisterSlashCmd(s, ThinkOutLoud.HandleSlashCommands)
        if not r then
            Print("Failed to register '"..s.."'")
        end
    end

    d("Initialising")
    ThinkOutLoud.InitSettings()

    if next(ThinkOutLoud.PersistentSettings) == nil then
        ThinkOutLoud.LoadSettings(TOL_CONFIGS["DEFAULT"])
        ThinkOutLoud.isDefault = true
    else
        ThinkOutLoud.LoadSettings(ThinkOutLoud.PersistentSettings)
    end

    TOLSettingsUI.Initialize()
    d("Initialised.")
end

function ThinkOutLoud.Update(elapsed)
    if not ThinkOutLoud.timenow then
        ThinkOutLoud.timenow = 0
    end
    ThinkOutLoud.timenow = ThinkOutLoud.timenow + elapsed
end


function ThinkOutLoud.Shutdown()
    ThinkOutLoud.SaveSettings()
    TOLSettingsUI.Shutdown()
    ThinkOutLoud.UnregisterEventHandlers()
end


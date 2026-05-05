-- ============================================================================
-- AutoChannel
-- Automatically selects the most appropriate chat channel
-- ============================================================================

AutoChannel = AutoChannel or {
    VERSION = { major = 1, minor = 0, patch = 5 }
}

-- Channel prefixes
local CHANNEL_WARBAND = "/wb"
local CHANNEL_PARTY   = "/p"
local CHANNEL_SC_PARTY= "/sp"
local CHANNEL_SCENARIO= "/sc"
local CHANNEL_SAY     = "/s"

-- ----------------------------------------------------------------------------
-- Helpers
-- ----------------------------------------------------------------------------
local function HasPartyMembers()
    local groupData = GetGroupData()
    for _, member in pairs(groupData) do
        if member and member.name and member.name ~= L"" then
            return true
        end
    end
    return false
end

local function GetSmartPartyChannel()
    if HasPartyMembers() then
        return CHANNEL_PARTY
    end
    return CHANNEL_SAY
end

function AutoChannel.IsScenario()
    if GameData.Player.isInScenario then
        return true
    end

    if GameData.Player.isInSiege then
        return true
    end

    -- Hardcoded city siege zones
    if GameData.Player.zone == 167 then return true end -- IC
    if GameData.Player.zone == 168 then return true end -- Altdorf

    return false
end

local function GetSmartBandChannel()
    if AutoChannel.IsScenario() then
        return CHANNEL_SCENARIO
    end

    if IsWarBandActive() then
        return CHANNEL_WARBAND
    end

    return GetSmartPartyChannel()
end

-- ----------------------------------------------------------------------------
-- Chat sending
-- ----------------------------------------------------------------------------
local function Send(channel, message, allowSay)
    if channel == CHANNEL_SAY and not allowSay then
        return
    end

    -- Party becomes scenario party inside scenarios
    if channel == CHANNEL_PARTY and AutoChannel.IsScenario() then
        channel = CHANNEL_SC_PARTY
    end

    if type(message) == "wstring" then
        message = tostring(message)
    end

    SendChatText(
        towstring(channel .. " " .. message),
        L""
    )
end

-- ----------------------------------------------------------------------------
-- Public API
-- ----------------------------------------------------------------------------
function AutoChannel.SendBand(phrase)
    Send(GetSmartBandChannel(), phrase, false)
end

function AutoChannel.SendParty(phrase)
    Send(GetSmartPartyChannel(), phrase, false)
end

function AutoChannel.SendBandSay(phrase)
    Send(GetSmartBandChannel(), phrase, true)
end

function AutoChannel.SendPartySay(phrase)
    Send(GetSmartPartyChannel(), phrase, true)
end

-- ----------------------------------------------------------------------------
-- Initialization
-- ----------------------------------------------------------------------------
function AutoChannel.Initialize()
    LibSlash.RegisterSlashCmd("acp",  AutoChannel.SendParty)
    LibSlash.RegisterSlashCmd("acb",  AutoChannel.SendBand)
    LibSlash.RegisterSlashCmd("acps", AutoChannel.SendPartySay)
    LibSlash.RegisterSlashCmd("acbs", AutoChannel.SendBandSay)
end

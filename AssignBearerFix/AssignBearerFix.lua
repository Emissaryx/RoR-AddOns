-- ============================================================================
-- AssignBearerFix
-- Queues standard bearer commands to avoid spam / throttling issues
-- ============================================================================

AssignBearerFix = AssignBearerFix or {}

AssignBearerFix.CommandQueue = {}
AssignBearerFix.Elapsed = 0

local UPDATE_THROTTLE = 0.5
local lastUpdate = 0

local tinsert  = table.insert
local tremove  = table.remove
local pairs    = pairs

-- ----------------------------------------------------------------------------
-- Initialization / shutdown
-- ----------------------------------------------------------------------------
function AssignBearerFix.Initialize()
    AssignBearerFix.OldCommandAssignBearer =
        GuildWindowTabRoster.CommandAssignBearer

    GuildWindowTabRoster.CommandAssignBearer =
        AssignBearerFix.CommandAssignBearer
end

function AssignBearerFix.OnShutdown()
    GuildWindowTabRoster.CommandAssignBearer =
        AssignBearerFix.OldCommandAssignBearer
end

-- ----------------------------------------------------------------------------
-- Update handler (throttled command sender)
-- ----------------------------------------------------------------------------
function AssignBearerFix.OnUpdate(elapsed)
    AssignBearerFix.Elapsed = AssignBearerFix.Elapsed + elapsed

    if (AssignBearerFix.Elapsed - lastUpdate) < UPDATE_THROTTLE then
        return
    end

    lastUpdate = AssignBearerFix.Elapsed

    if #AssignBearerFix.CommandQueue > 0 then
        local cmd = tremove(AssignBearerFix.CommandQueue, 1)
        SendChatText(cmd, L"")
    end
end

-- ----------------------------------------------------------------------------
-- Replacement for CommandAssignBearer
-- ----------------------------------------------------------------------------
function AssignBearerFix.CommandAssignBearer()
    local MAX_STANDARD_BEARERS = 5
    local existingBearers = {}

    local members = GetGuildMemberData()

    -- Collect active standard bearers in-zone
    for _, member in pairs(members) do
        if member.bearerStatus == 1 and member.zoneID == 0 then
            tinsert(existingBearers, member.name)
        end
    end

    -- Remove existing bearers if cap is reached
    if #existingBearers >= MAX_STANDARD_BEARERS then
        for _, name in pairs(existingBearers) do
            tinsert(
                AssignBearerFix.CommandQueue,
                L"/guildremovestandardbearer " .. name
            )
        end
    end

    -- Assign selected member as bearer
    tinsert(
        AssignBearerFix.CommandQueue,
        L"/guildaddstandardbearer " ..
        GuildWindowTabRoster.SelectedGuildMemberName
    )
end

-- ----------------------------------------------------------------------------
-- Utility
-- ----------------------------------------------------------------------------
function AssignBearerFix.GuildInvolve()
    SendChatText(L"/GuildInvolve", L"")
end

StopRes = StopRes or {}
StopRes.Settings = StopRes.Settings or {}

StopRes.Settings.ressingstatus = false
StopRes.Settings.ResList =
{
    [1598] = L"Rune Of Life",
    [1908] = L"Gedup!",
    [8248] = L"Breath Of Sigmar",
    [8555] = L"Tzeentch Shall Remake You",
    [9246] = L"Gift Of Life",
    [9558] = L"Stand, Coward!",
}

function StopRes.Initialize()
    RegisterEventHandler(SystemData.Events.PLAYER_END_CAST,   "StopRes.EndCast")
    RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "StopRes.BeginCast")
end

function StopRes.Shutdown()
    UnregisterEventHandler(SystemData.Events.PLAYER_END_CAST,   "StopRes.EndCast")
    UnregisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "StopRes.BeginCast")
end

-- If you call this from an OnUpdate somewhere, keep it cheap:
function StopRes.OnTesting()
    if StopRes.Settings.ressingstatus then
        StopRes.ResCheck()
    end
end

function StopRes.ResCheck()
    if not StopRes.Settings.ressingstatus then return end
    if not TargetInfo or not TargetInfo.UnitHealth then return end

    local tarHealth = TargetInfo:UnitHealth("selffriendlytarget")

    -- If we can't read health, don't cancel the cast.
    if tarHealth == nil then
        return
    end

    -- Target is not dead anymore -> stop res
    if tarHealth ~= 0 then
        CancelSpell()
        StopRes.Settings.ressingstatus = false
    end
end

function StopRes.BeginCast(abilityId)
    -- O(1) lookup instead of looping
    if StopRes.Settings.ResList[abilityId] then
        StopRes.Settings.ressingstatus = true
    else
        StopRes.Settings.ressingstatus = false
    end
end

function StopRes.EndCast()
    StopRes.Settings.ressingstatus = false
end

GCDsaver = GCDsaver or {}

GCDsaver.VirtualCooldowns = GCDsaver.VirtualCooldowns or {}
local VCD = GCDsaver.VirtualCooldowns
local Cooldowns = {}

-- ✅ Starts a cooldown for a given ability and target
function VCD.StartCooldown(abilityId, targetId, duration)
    if not abilityId or not targetId or not duration then return end

    Cooldowns[abilityId] = Cooldowns[abilityId] or {}
    Cooldowns[abilityId][targetId] = duration
end

-- ❌ Stops a cooldown manually for a given ability and target
function VCD.StopCooldown(abilityId, targetId)
    if Cooldowns[abilityId] then
        Cooldowns[abilityId][targetId] = nil
    end
end

-- ❓ Checks if a cooldown is active
function VCD.IsOnCooldown(abilityId, targetId)
    if not abilityId or not targetId then return false end
    return Cooldowns[abilityId] and Cooldowns[abilityId][targetId] ~= nil
end

-- ⏳ Updates cooldown timers
function VCD.Update(elapsed)
    for abilityId, targets in pairs(Cooldowns) do
        for targetId, timeLeft in pairs(targets) do
            Cooldowns[abilityId][targetId] = timeLeft - elapsed
            if Cooldowns[abilityId][targetId] <= 0 then
                Cooldowns[abilityId][targetId] = nil
            end
        end
    end
end

-- 🔧 Cleanup function for complete reset (useful on reload or logout)
function VCD.ResetAllCooldowns()
    Cooldowns = {}
end
-- IronbreakerChecks.lua
IronbreakerChecks = {}

-- 🔧 Ability ID Constants
local GRUDGE_UNLEASHED = 1373
local STONE_BREAKER    = 1371

-- 🎯 Local Buff Target Constants
local SELF = GameData.BuffTargetType.SELF

-- 🛡️ Abilities that should be blocked if buff is already active
local BuffBlockedAbilities = {
    [1364] = true, -- Inspiring Attack
    [1357] = true, -- Vengeful Strike
    [1356] = true  -- Guarded Attack
}

--- 🔍 Check if the Ironbreaker ability should be blocked
-- @param actionId number - The ability ID being evaluated
-- @param currentAP number - Current action points
-- @param currentMechanic number - Current mechanic (grudge) value
-- @param abilityData table - Cached ability data
-- @param stackCount number | nil - Optional stack count for buff checking
function IronbreakerChecks.isAbilityBlocked(actionId, currentAP, currentMechanic, abilityData, stackCount)
    local abilitySetting = GCDsaver.Settings.Abilities[actionId]
    local targetType = GCDsaverAPI.getTargetType(abilityData.targetType)

    -- ✅ Handle universal IMMOVABLE / UNSTOPPABLE checks
    if abilitySetting == 4 and GCDsaver.TargetImmovable then -- IMMOVABLE
        return true
    elseif abilitySetting == 5 and GCDsaver.TargetUnstoppable then -- UNSTOPPABLE
        return true
    end

    -- 🧱 Block Stone Breaker if grudge too low
    if actionId == STONE_BREAKER and currentMechanic < 74 then
        return true
    end

    -- 💥 Block Grudge Unleashed if too much AP
    if actionId == GRUDGE_UNLEASHED and currentAP > 50 then
        return true
    end

    -- 🛡️ Block these if the buff is already active on target or self
    if BuffBlockedAbilities[actionId] then
        if GCDsaverAPI.hasBuff(targetType, abilityData, stackCount)
        or GCDsaverAPI.hasBuff(SELF, abilityData, stackCount) then
            return true
        end
    end

    return false
end

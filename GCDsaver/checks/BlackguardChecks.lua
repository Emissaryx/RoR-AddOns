-- BlackguardChecks.lua
BlackguardChecks = {}

-- 🔧 Lua stdlib
local tonumber = tonumber
local tostring = tostring

-- 🎯 Buff Target Type
local SELF = GameData.BuffTargetType.SELF

-- 🆔 Named Ability Constants
local HATE_STRIKE      = 9329
local SEETHING_HATRED  = 9319
local ENRAGED_BLOW     = 3073
local VICIOUS_SLASH    = 3480

-- 💡 Abilities that should not be reapplied if already buffed
local BuffBlockers = {
    [ENRAGED_BLOW] = true,
    [VICIOUS_SLASH] = true
}

--- 🔍 Determines if a Blackguard ability should be blocked based on AP, mechanic, and active buffs.
-- @param actionId number
-- @param currentAP number
-- @param currentMechanic number
-- @param abilityData table
-- @param stackCount number|nil
-- @return boolean
function BlackguardChecks.isAbilityBlocked(actionId, currentAP, currentMechanic, abilityData, stackCount)
    -- 🛠 Fallback in case abilityData is not passed
    local ability = abilityData or GCDsaverAPI.GetCachedAbilityData(actionId)
    if not ability then return false end

    local abilitySetting = GCDsaver.Settings.Abilities[actionId]
    local targetType = GCDsaverAPI.getTargetType(ability.targetType)

    -- ✅ Handle universal IMMOVABLE / UNSTOPPABLE checks
    if abilitySetting == 4 and GCDsaver.TargetImmovable then -- IMMOVABLE
        return true
    elseif abilitySetting == 5 and GCDsaver.TargetUnstoppable then -- UNSTOPPABLE
        return true
    end

    -- 🧱 Block HATE_STRIKE if mechanic is too low
    if actionId == HATE_STRIKE and currentMechanic < 74 then
        return true
    end

    -- 💥 Block SEETHING_HATRED if AP is too high
    if actionId == SEETHING_HATRED and currentAP > 50 then
        return true
    end

    -- 🛡️ Block rebuffing ENRAGED_BLOW or VICIOUS_SLASH
    if BuffBlockers[actionId] then
        if GCDsaverAPI.hasBuff(targetType, ability, stackCount)
        or GCDsaverAPI.hasBuff(SELF, ability, stackCount) then
            if GCDsaver.Settings.ErrorMessages then
                GCDsaverAPI.alertText("Blocked: " .. tostring(ability.name or actionId) .. " — buff already active.")
            end
            return true
        end
    end

    return false
end

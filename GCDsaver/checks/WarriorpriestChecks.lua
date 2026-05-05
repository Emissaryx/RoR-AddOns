-- WarriorpriestChecks.lua
WarriorpriestChecks = {}

-- 🧠 Lua stdlib
local tonumber = tonumber
local tostring = tostring

-- 🎯 Buff Target Types
local SELF    = GameData.BuffTargetType.SELF
local HOSTILE = GameData.BuffTargetType.TARGET_HOSTILE

-- 🆔 Named Ability IDs
local SMITE           = 8250
local SOULFIRE        = 8271
local SIGMARS_FIST    = 8253
local SIGMARS_VISION  = 8268

-- 🛡️ Abilities that should not be re-applied on self if buff is active
local BuffOnSelf = {
    [SIGMARS_FIST]   = true,
    [SIGMARS_VISION] = true
}

--- 🔍 Determines whether a Warrior Priest ability should be blocked
-- @param actionId number
-- @param currentAP number
-- @param currentMechanic number
-- @param abilityData table
-- @param stackCount number|nil
-- @return boolean
function WarriorpriestChecks.isAbilityBlocked(actionId, currentAP, currentMechanic, abilityData, stackCount)
    local isErrorMsg = GCDsaver.Settings.ErrorMessages
    local ability    = abilityData or GCDsaverAPI.GetCachedAbilityData(actionId)
    if not ability then return false end

    local abilitySetting = GCDsaver.Settings.Abilities[actionId]

    -- ✅ Handle universal IMMOVABLE / UNSTOPPABLE
    if abilitySetting == 4 and GCDsaver.TargetImmovable then return true end
    if abilitySetting == 5 and GCDsaver.TargetUnstoppable then return true end

    -- 🧱 Smite blocked if mechanic is too high
    if actionId == SMITE and currentMechanic > 200 then
        return true
    end

    -- 🔥 Soulfire blocked if already on hostile
    if actionId == SOULFIRE and GCDsaverAPI.hasHostileTarget() then
        if GCDsaverAPI.checkBuffByAbility(actionId, HOSTILE) then
            if isErrorMsg then
                GCDsaverAPI.alertText("Soulfire is already active on the enemy.")
            end
            return true
        end
    end

    -- ✋ Block Sigmar buffs if already present on self
    if BuffOnSelf[actionId] and GCDsaverAPI.hasBuff(SELF, ability, stackCount) then
        if isErrorMsg then
            GCDsaverAPI.alertText((ability.name or tostring(actionId)) .. " is already active on you.")
        end
        return true
    end

    return false
end

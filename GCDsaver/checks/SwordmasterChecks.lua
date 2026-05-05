-- SwordmasterChecks.lua
SwordmasterChecks = {}

-- 🔧 Action ID Constants
local ENSORCELLED_BLOW    = 9010
local GRACEFUL_STRIKE     = 9002
local GRYPHONS_LASH       = 9031
local PROTECTION_OF_HOETH = 9029
local WRATH_OF_HOETH      = 9017
local EAGLES_FLIGHT       = 9007

-- 🔁 Local Buff Target Constants
local SELF    = GameData.BuffTargetType.SELF
local HOSTILE = GameData.BuffTargetType.TARGET_HOSTILE

--- 🔍 Swordmaster ability blocking logic
-- @param actionId number
-- @param currentAP number
-- @param currentMechanic number
-- @param abilityData table
-- @param stackCount number | nil
-- @return boolean
function SwordmasterChecks.isAbilityBlocked(actionId, currentAP, currentMechanic, abilityData, stackCount)
    local ability = abilityData or GCDsaverAPI.GetCachedAbilityData(actionId)
    if not ability then return false end

    local abilitySetting = GCDsaver.Settings.Abilities[actionId]
    local targetType = GCDsaverAPI.getTargetType(ability.targetType)
    local errorMsgEnabled = GCDsaver.Settings.ErrorMessages

    -- ✅ Global IMMOVABLE / UNSTOPPABLE logic
    if abilitySetting == 4 and GCDsaver.TargetImmovable then return true end
    if abilitySetting == 5 and GCDsaver.TargetUnstoppable then return true end

    -- ❌ Prevent basic builders if mechanic is active
    if currentMechanic > 0 and (
        actionId == ENSORCELLED_BLOW or
        actionId == GRACEFUL_STRIKE or
        actionId == GRYPHONS_LASH or
        actionId == PROTECTION_OF_HOETH
    ) then
        return true
    end

    -- ❌ Prevent casting Wrath of Hoeth if buff already active
    if actionId == WRATH_OF_HOETH then
        local hasTargetBuff = GCDsaverAPI.hasBuff(targetType, ability, stackCount)
        local hostileBuff   = GCDsaverAPI.hasBuff(HOSTILE, ability, stackCount)

        if hasTargetBuff or hostileBuff then
            return true
        end
    end

    -- ❌ Prevent Eagle’s Flight if active on self
    if actionId == EAGLES_FLIGHT and GCDsaverAPI.hasBuff(SELF, ability, nil) then
        if errorMsgEnabled then
            GCDsaverAPI.alertText("🛑 Eagle's Flight is already active.")
        end
        return true
    end

    return false
end
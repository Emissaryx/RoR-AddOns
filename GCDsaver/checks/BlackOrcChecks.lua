-- BlackOrcChecks.lua
BlackOrcChecks = {}

-- Localized built-in functions for performance
local tonumber = tonumber
local tostring = tostring

-- Constant for SELF target
local TARGET_SELF = GameData.BuffTargetType.SELF

-- Named ability IDs for clarity
local CLOBBER       	 = 1664
local WOT_ARMOR  = 1666
local FOLLOW_ME_LEAD     = 1667
local DA_BEST_DEFENSE    = 1677

--- Checks if a Black Orc ability should be blocked based on mechanic and buff presence.
-- @param actionId number - The ability ID to be validated.
-- @param currentActionPoints number - Player's current AP (unused here).
-- @param currentMechanic number - Player's current career mechanic.
-- @param abilityData table - Metadata about the ability.
-- @param stackCount number | nil - Stack count to compare against.
-- @return boolean - True if the ability is blocked, false otherwise.
function BlackOrcChecks.isAbilityBlocked(actionId, currentActionPoints, currentMechanic, abilityData, stackCount)
    local ability = abilityData or GCDsaverAPI.GetCachedAbilityData(actionId)
    if not ability then return false end

    local abilitySetting = GCDsaver.Settings.Abilities[actionId]
    local targetType = GCDsaverAPI.getTargetType(ability.targetType)

    -- ✅ Handle global IMM/UNSTOPPABLE checks
    if abilitySetting == 4 and GCDsaver.TargetImmovable then return true end
    if abilitySetting == 5 and GCDsaver.TargetUnstoppable then return true end

    -- 🧱 Block builder if mechanic is already up
    currentMechanic = tonumber(GetCareerResource(TARGET_SELF))
    if currentMechanic > 0 and (
        actionId == CLOBBER or 
        actionId == WOT_ARMOR or 
        actionId == FOLLOW_ME_LEAD
    ) then
        return true
    end

    -- 🛡️ Prevent duplicate debuff/buff if already on target or self
    if (actionId == FOLLOW_ME_LEAD or actionId == DA_BEST_DEFENSE) then
        local targetHasBuff = GCDsaverAPI.hasBuff(targetType, ability, stackCount)
        local selfHasBuff   = GCDsaverAPI.hasBuff(TARGET_SELF, ability, stackCount)

        if targetHasBuff or selfHasBuff then
            return true
        end
    end

    return false
end

ArchmageChecks = {}

--- Determines if an Archmage ability should be blocked
-- @param actionId number
-- @param currentActionPoints number
-- @param currentMechanic number
-- @param abilityData table
-- @param stackCount number | nil
-- @return boolean
function ArchmageChecks.isAbilityBlocked(actionId, currentActionPoints, currentMechanic, abilityData, stackCount)
    local ability = abilityData or GCDsaverAPI.GetCachedAbilityData(actionId)
    if not ability then return false end

    local abilitySetting = GCDsaver.Settings.Abilities[actionId]
    local targetType = GCDsaverAPI.getTargetType(ability.targetType)

    -- ✅ Global IMMOVABLE / UNSTOPPABLE blocking
    if abilitySetting == 4 and GCDsaver.TargetImmovable then return true end
    if abilitySetting == 5 and GCDsaver.TargetUnstoppable then return true end

    -- ✋ Block specific ability if already active on self or friendly target
    if actionId == 9252 then  -- Example: Transfer Force or similar HoT
        if GCDsaverAPI.hasBuff(targetType, ability, stackCount) then
            if GCDsaver.Settings.ErrorMessages then
                local targetLabel = (targetType == GameData.BuffTargetType.SELF) and "you" or "that friendly target"
                local name = ability.name or tostring(actionId)
                GCDsaverAPI.alertText("Blocked: " .. name .. " is already active on " .. targetLabel .. ".")
            end
            return true
        end
    end

    return false
end

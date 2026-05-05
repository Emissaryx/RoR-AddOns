-- WitchhunterChecks.lua
WitchhunterChecks = {}

-- Localized built-in functions for better performance
local tonumber = tonumber
local tostring = tostring

-- Constants
local TARGET_SELF = GameData.BuffTargetType.SELF

--- Determines if a Witch Hunter ability is blocked from use.
-- @param actionId number - The ID of the ability being evaluated.
-- @param currentAP number - The player's current action points (unused here).
-- @param currentMechanic number - The player's current career mechanic.
-- @param abilityData table | nil - Optional ability metadata (fallbacks to cached).
-- @param stackCount number | nil - Expected stack count (optional).
-- @return boolean - True if the ability should be blocked, false otherwise.
function WitchhunterChecks.isAbilityBlocked(actionId, currentAP, currentMechanic, abilityData, stackCount)
    local ability = abilityData or GCDsaverAPI.GetCachedAbilityData(actionId)
    if not ability then return false end

    local abilitySetting = GCDsaver.Settings.Abilities[actionId]

    -- ✅ Global IMM/UNSTOPPABLE support
    if abilitySetting == 4 and GCDsaver.TargetImmovable then return true end
    if abilitySetting == 5 and GCDsaver.TargetUnstoppable then return true end

    -- 🔪 Execution check — block if resource is too low
    currentMechanic = tonumber(GetCareerResource(TARGET_SELF))
    if currentMechanic <= 3 and Emissary.Execution[actionId] then
        if GCDsaver.Settings.ErrorMessages then
            local name = ability.name or tostring(actionId)
            GCDsaverAPI.alertText("Blocked: " .. name .. " — insufficient Accusation.")
        end
        return true
    end

    return false
end

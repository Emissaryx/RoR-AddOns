-- WitchelfChecks.lua
WitchelfChecks = {}

-- Localized built-in functions for performance
local tonumber = tonumber
local tostring = tostring

-- Constant for self target
local TARGET_SELF = GameData.BuffTargetType.SELF

--- Determines if a Witch Elf ability should be blocked based on career mechanic or immunity.
-- @param actionId number - The ID of the ability to check.
-- @param currentAP number - Player's current action points (unused)
-- @param currentMechanic number - The player's current career mechanic
-- @param abilityData table | nil - Optional ability metadata
-- @param stackCount number | nil - Stack threshold if applicable
-- @return boolean - True if ability is blocked, false otherwise.
function WitchelfChecks.isAbilityBlocked(actionId, currentAP, currentMechanic, abilityData, stackCount)
    local ability = abilityData or GCDsaverAPI.GetCachedAbilityData(actionId)
    if not ability then return false end

    local abilitySetting = GCDsaver.Settings.Abilities[actionId]

    -- ✅ Global IMMOVABLE / UNSTOPPABLE logic
    if abilitySetting == 4 and GCDsaver.TargetImmovable then return true end
    if abilitySetting == 5 and GCDsaver.TargetUnstoppable then return true end

    -- 💀 Execution logic: block if mechanic too low
    currentMechanic = tonumber(GetCareerResource(TARGET_SELF))
    if currentMechanic <= 3 and Emissary.Execution[actionId] then
        if GCDsaver.Settings.ErrorMessages then
            local name = ability.name or tostring(actionId)
            GCDsaverAPI.alertText("Blocked: " .. name .. " — not enough Blood Lust.")
        end
        return true
    end

    return false
end

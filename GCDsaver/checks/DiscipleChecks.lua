-- DiscipleChecks.lua
DiscipleChecks = {}

-- Localized functions
local tonumber = tonumber
local tostring = tostring

-- Constants
local TARGET_SELF = GameData.BuffTargetType.SELF

-- Named ability constant
local CONSUME_ESSENCE = 9566

--- 🔍 Determines if a Disciple of Khaine ability should be blocked
-- @param actionId number
-- @param currentAP number
-- @param currentMechanic number
-- @param abilityData table
-- @param stackCount number | nil
-- @return boolean
function DiscipleChecks.isAbilityBlocked(actionId, currentAP, currentMechanic, abilityData, stackCount)
    local ability = abilityData or GCDsaverAPI.GetCachedAbilityData(actionId)
    if not ability then return false end

    local abilitySetting = GCDsaver.Settings.Abilities[actionId]

    -- ✅ IMMOVABLE / UNSTOPPABLE check support
    if abilitySetting == 4 and GCDsaver.TargetImmovable then return true end
    if abilitySetting == 5 and GCDsaver.TargetUnstoppable then return true end

    -- 🧱 Disciple-specific: block "Consume Essence" if too much resource
    if actionId == CONSUME_ESSENCE and currentMechanic > 200 then
        return true
    end

    return false
end

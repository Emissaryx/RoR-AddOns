-- creature_proxy.lua

---@class CreatureProxy : UnitProxy
---@field Entry number
local CreatureProxy = {}

--- Sets the state of the creature.
---@param stateName string
---@param state number
function CreatureProxy:SetState(stateName, state) end

--- Gets the state of the creature.
---@param stateName string
---@return number|nil
function CreatureProxy:GetState(stateName) end

--- Sets the ability set of the creature.
---@param abilitySetId number|nil
function CreatureProxy:SetAbilitySet(abilitySetId) end

--- Equips an item on the creature.
---@param slotId number
---@param modelId number
function CreatureProxy:EquipItem(slotId, modelId) end

--- Unequips an item from the creature.
---@param slotId number
function CreatureProxy:UnEquipItem(slotId) end

--- Gets the number of enabled range units for enrage.
---@return number
function CreatureProxy:EnableRangeUnits() end

return CreatureProxy

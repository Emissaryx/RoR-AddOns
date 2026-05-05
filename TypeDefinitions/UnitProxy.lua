-- unit_proxy.lua

---@class UnitProxy : WorldObjectProxy
---@field Health number
---@field HealthPercent number
---@field HealthMax number
---@field IsDead boolean
---@field Realm number
---@field Model number
local UnitProxy = {}

--- Makes the unit say a message.
---@param message string
---@param chatFilter ChatLogFilters
function UnitProxy:Say(message, chatFilter) end

--- Destroys the unit.
function UnitProxy:Destroy() end

--- Casts an ability on a target.
---@param abilityId number
---@param target UnitProxy|nil
---@return boolean
function UnitProxy:CastAbility(abilityId, target) end

--- Checks if the unit has a specific ability.
---@param abilityId number
---@return boolean
function UnitProxy:HasAbility(abilityId) end

--- Summons a creature.
---@param protoId number
---@param x number
---@param y number
---@param z number
---@param o number
---@param summonType SummonCreature.SummonType
---@param despawnTimer number
---@return Creature|nil
function UnitProxy:SummonCreature(protoId, x, y, z, o, summonType, despawnTimer) end

return UnitProxy

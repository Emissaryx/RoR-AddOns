-- game_object_proxy.lua

---@class GameObjectProxy : UnitProxy
---@field Entry number
---@field Interactable boolean
---@field VfxState number
local GameObjectProxy = {}

--- Sets the state of the game object.
---@param stateName string
---@param state number
function GameObjectProxy:SetState(stateName, state) end

--- Gets the state of the game object.
---@param stateName string
---@return number|nil
function GameObjectProxy:GetState(stateName) end

return GameObjectProxy

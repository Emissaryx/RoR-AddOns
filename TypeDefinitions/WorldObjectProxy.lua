-- world_object_proxy.lua

---@class WorldObjectProxy
---@field Name string
---@field PlayersInRange table<number, PlayerProxy>
---@field ObjectsInRange table<number, WorldObjectProxy>
---@field RegionId number
---@field ZoneId number
---@field X number
---@field Y number
---@field Z number
---@field O number
---@field IsPlayer boolean
---@field IsCreature boolean
---@field IsGameObject boolean
---@field IsUnit boolean
---@field AsPlayer PlayerProxy|nil
---@field AsCreature CreatureProxy|nil
---@field AsGameObject GameObjectProxy|nil
---@field AsUnit UnitProxy|nil
local WorldObjectProxy = {}

--- Plays a sound.
---@param soundId number
function WorldObjectProxy:PlaySound(soundId) end

--- Plays an effect.
---@param effectId number
function WorldObjectProxy:PlayEffect(effectId) end

--- Gets players in range within the specified distance.
---@param range number
---@return PlayerProxy[]
function WorldObjectProxy:GetPlayersInRange(range) end

--- Gets game objects in range within the specified distance.
---@param range number
---@param gameObjectEntryId number|nil
---@return GameObjectProxy[]
function WorldObjectProxy:GetGameObjectsInRange(range, gameObjectEntryId) end

--- Gets creatures in range within the specified distance.
---@param range number
---@param creatureEntryId number|nil
---@return CreatureProxy[]
function WorldObjectProxy:GetCreaturesInRange(range, creatureEntryId) end

--- Spawns a game object.
---@param gameObjectProtoId number
---@param x number
---@param y number
---@param z number
---@param o number
---@return GameObjectProxy|nil
function WorldObjectProxy:SpawnGameObject(gameObjectProtoId, x, y, z, o) end

--- Gets the nearest game object within the specified distance.
---@param range number
---@param gameObjectEntryId number|nil
---@return GameObjectProxy|nil
function WorldObjectProxy:GetNearestGameObject(range, gameObjectEntryId) end

--- Gets the nearest creature within the specified distance.
---@param range number
---@param creatureEntryId number|nil
---@return CreatureProxy|nil
function WorldObjectProxy:GetNearestCreature(range, creatureEntryId) end

--- Gets the nearest player within the specified distance.
---@param range number
---@param gameObjectEntryId number|nil
---@return PlayerProxy|nil
function WorldObjectProxy:GetNearestPlayer(range, gameObjectEntryId) end

--- Checks if the world object is within a 3D radius.
---@param worldObject WorldObjectProxy
---@param range number
---@return boolean
function WorldObjectProxy:IsWithin3DRadiusFeet(worldObject, range) end

return WorldObjectProxy

local gameObjectProtoId = 66
local neededItemId1 = 9160 -- First needed item
local neededItemId2 = 9161 -- Second needed item (added for the new requirement)
local spawnCreatureProtoId = 1001074

local function OnInteract(gameObject, player)
  -- Check if the player has both required items
  if not player:HasItem(neededItemId1, 1) or not player:HasItem(neededItemId2, 1) then
    player:SendLocalizeString("You do not have the required items!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    return false
  end

  return true
end

local function OnInteractionComplete(gameObject, player)
  -- Double-check if the player still has both items (to handle edge cases where item state might change)
  if not player:HasItem(neededItemId1, 1) or not player:HasItem(neededItemId2, 1) then
    player:SendLocalizeString("You do not have the required items!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    return
  end

  -- Remove both items from the player's inventory
  player:RemoveItem(neededItemId1, 1)
  player:RemoveItem(neededItemId2, 1)

  -- Spawn the creature at the game object's location
  gameObject:SummonCreature(spawnCreatureProtoId, gameObject.X, gameObject.Y, gameObject.Z, gameObject.O,
    SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
end

RegisterGameObjectScript(gameObjectProtoId, GameObjectScript.OnInteract, OnInteract)
RegisterGameObjectScript(gameObjectProtoId, GameObjectScript.OnInteractionComplete, OnInteractionComplete)

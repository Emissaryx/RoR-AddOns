-- Define SummonType
local SummonType = {
  TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN = 1
}

local gameObjectProtoId = 20020342
local neededItemId = 20034
local spawnCreatureProtoId = 100148

local function OnInteract(gameObject, player)
  if player:HasItem(neededItemId, 1) == false
  then
    player:SendLocalizeString("You do not have the item!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE,
      Localized_text.CHAT_TAG_DEFAULT)
    return false
  end

  return true
end

local function OnInteractionComplete(gameObject, player)
  if player:HasItem(neededItemId, 1) == false
  then
    player:SendLocalizeString("You do not have the item!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE,
      Localized_text.CHAT_TAG_DEFAULT)
    return
  end

  player:RemoveItem(neededItemId, 1)
  gameObject:SummonCreature(spawnCreatureProtoId, gameObject.X, gameObject.Y, gameObject.Z, gameObject.O,
    SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 600000)
end

RegisterGameObjectScript(gameObjectProtoId, GameObjectScript.OnInteract, OnInteract)
RegisterGameObjectScript(gameObjectProtoId, GameObjectScript.OnInteractionComplete, OnInteractionComplete)

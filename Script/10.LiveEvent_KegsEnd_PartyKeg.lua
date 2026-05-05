local function OnSpawn(gameObject)
  gameObject:SetState("USES", 0)
end

local function OnInteractionComplete(gameObject, player)
  if gameObject.Realm ~= player.Realm
  then
    gameObject:Destroy()
    return
  end

  if gameObject.Entry == 233 or gameObject.Entry == 2001702
  then
    if not player:CastAbility(29551)
    then
      return
    end
  end

  return

  --local currentUses = gameObject:GetState("USES")

  --currentUses = currentUses + 1

  --player:SendLocalizeString("Current Uses "..currentUses , SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)

  --if currentUses >= 5
  --then
  --  player:SendLocalizeString("All gone", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
  --  gameObject:Destroy()
  --end

  --gameObject:SetState("USES", currentUses)
end

RegisterGameObjectScript(233, GameObjectScript.OnSpawn, OnSpawn)
RegisterGameObjectScript(233, GameObjectScript.OnInteractionComplete, OnInteractionComplete)
RegisterGameObjectScript(2001700, GameObjectScript.OnSpawn, OnSpawn)
RegisterGameObjectScript(2001700, GameObjectScript.OnInteractionComplete, OnInteractionComplete)
RegisterGameObjectScript(2001701, GameObjectScript.OnSpawn, OnSpawn)
RegisterGameObjectScript(2001701, GameObjectScript.OnInteractionComplete, OnInteractionComplete)
RegisterGameObjectScript(2001702, GameObjectScript.OnSpawn, OnSpawn)
RegisterGameObjectScript(2001702, GameObjectScript.OnInteractionComplete, OnInteractionComplete)
RegisterGameObjectScript(2001703, GameObjectScript.OnSpawn, OnSpawn)
RegisterGameObjectScript(2001703, GameObjectScript.OnInteractionComplete, OnInteractionComplete)
RegisterGameObjectScript(2001704, GameObjectScript.OnSpawn, OnSpawn)
RegisterGameObjectScript(2001704, GameObjectScript.OnInteractionComplete, OnInteractionComplete)

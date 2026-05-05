-- IDs for each brazier and heart
local springBrazierId = 97602
local heartOfSpringId = 15002

local summerBrazierId = 97603
local heartOfSummerId = 15003

local autumnBrazierId = 97604
local heartOfAutumnId = 15004

local winterBrazierId = 97605
local heartOfWinterId = 15005

-- Spring Brazier Functions
local function OnInteractSpring(gameObject, player)
  if player:HasItem(heartOfSpringId, 1) == false then
    player:SendLocalizeString("You do not have the Heart of Spring!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    return false
  end
  return true
end

local function OnInteractionCompleteSpring(gameObject, player)
  if player:HasItem(heartOfSpringId, 1) == false then
    player:SendLocalizeString("You do not have the item!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE,
      Localized_text.CHAT_TAG_DEFAULT)
    return
  end
  player:RemoveItem(heartOfSpringId, 1)
end

RegisterGameObjectScript(springBrazierId, GameObjectScript.OnInteract, OnInteractSpring)
RegisterGameObjectScript(springBrazierId, GameObjectScript.OnInteractionComplete, OnInteractionCompleteSpring)

-- Summer Brazier Functions
local function OnInteractSummer(gameObject, player)
  if player:HasItem(heartOfSummerId, 1) == false then
    player:SendLocalizeString("You do not have the Heart of Summer!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    return false
  end
  return true
end

local function OnInteractionCompleteSummer(gameObject, player)
  if player:HasItem(heartOfSummerId, 1) == false then
    player:SendLocalizeString("You do not have the item!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE,
      Localized_text.CHAT_TAG_DEFAULT)
    return
  end
  player:RemoveItem(heartOfSummerId, 1)
end

RegisterGameObjectScript(summerBrazierId, GameObjectScript.OnInteract, OnInteractSummer)
RegisterGameObjectScript(summerBrazierId, GameObjectScript.OnInteractionComplete, OnInteractionCompleteSummer)

-- Autumn Brazier Functions
local function OnInteractAutumn(gameObject, player)
  if player:HasItem(heartOfAutumnId, 1) == false then
    player:SendLocalizeString("You do not have the Heart of Autumn!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    return false
  end
  return true
end

local function OnInteractionCompleteAutumn(gameObject, player)
  if player:HasItem(heartOfAutumnId, 1) == false then
    player:SendLocalizeString("You do not have the item!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE,
      Localized_text.CHAT_TAG_DEFAULT)
    return
  end
  player:RemoveItem(heartOfAutumnId, 1)
end

RegisterGameObjectScript(autumnBrazierId, GameObjectScript.OnInteract, OnInteractAutumn)
RegisterGameObjectScript(autumnBrazierId, GameObjectScript.OnInteractionComplete, OnInteractionCompleteAutumn)

-- Winter Brazier Functions
local function OnInteractWinter(gameObject, player)
  if player:HasItem(heartOfWinterId, 1) == false then
    player:SendLocalizeString("You do not have the Heart of Winter!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    return false
  end
  return true
end

local function OnInteractionCompleteWinter(gameObject, player)
  if player:HasItem(heartOfWinterId, 1) == false then
    player:SendLocalizeString("You do not have the item!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE,
      Localized_text.CHAT_TAG_DEFAULT)
    return
  end
  player:RemoveItem(heartOfWinterId, 1)
end

RegisterGameObjectScript(winterBrazierId, GameObjectScript.OnInteract, OnInteractWinter)
RegisterGameObjectScript(winterBrazierId, GameObjectScript.OnInteractionComplete, OnInteractionCompleteWinter)

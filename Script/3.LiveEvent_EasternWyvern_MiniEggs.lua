local gameObjectProtoId = 620190
local eggItemId = 609000

local function OnInteract(gameObject, player)
    if gameObject.Interactable == false
    then
        return false
    end

    return true
end

local function OnInteractionComplete(gameObject, player)
    for otherPlayer in gameObject.PlayersInRange
    do
        if player ~= otherPlayer
        then
            otherPlayer:SendLocalizeString(player.Name .. " just cracked " .. gameObject.Name .. "!",
                ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
        end
    end

    player:SendLocalizeString("You acquired an egg!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1,
        Localized_text.CHAT_TAG_DEFAULT)
    player:SendLocalizeString("You acquired an egg!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE,
        Localized_text.CHAT_TAG_DEFAULT)
    player:AddItem(eggItemId, 1)
end

local function OnEnterRange(gameObject, worldObject)
    if worldObject.IsPlayer == false or gameObject.Interactable == false
    then
        return
    end

    player = worldObject.AsPlayer

    player:SendLocalizeString("You smell an Eastern Wyvern Egg nearby!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
    player:SendLocalizeString("You smell an Eastern Wyvern Egg nearby!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
end

local function OnLeaveRange(gameObject, worldObject)
    if worldObject.IsPlayer == false or gameObject.Interactable == false
    then
        return
    end

    player = worldObject.AsPlayer

    player:SendLocalizeString("You no longer smell a Wyvern Egg nearby...",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
    player:SendLocalizeString("You no longer smell a Wyvern Egg nearby...",
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
end

RegisterGameObjectScript(gameObjectProtoId, GameObjectScript.OnInteract, OnInteract)
RegisterGameObjectScript(gameObjectProtoId, GameObjectScript.OnInteractionComplete, OnInteractionComplete)
RegisterGameObjectScript(gameObjectProtoId, GameObjectScript.OnEnterRange, OnEnterRange)
RegisterGameObjectScript(gameObjectProtoId, GameObjectScript.OnLeaveRange, OnLeaveRange)

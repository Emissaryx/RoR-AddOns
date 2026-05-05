local bossSpawnChance = 5
local bossProtoId = 99745
local gameObjectProtoId = 1000
local eggItemId = 609001

local function OnInteract(gameObject, player)
    if gameObject.Interactable == false
    then
        return false
    end

    for otherObject in gameObject.ObjectsInRange
    do
        if otherObject.IsCreature
        then
            otherCreature = otherObject.AsCreature

            if otherCreature.Entry == bossProtoId and
                otherCreature.IsWithin3DRadiusFeet(gameObject, 80) and
                otherCreature.IsDead == false
            then
                player:SendLocalizeString(
                    "You can't shatter " .. gameObject.Name .. " when " .. otherCreature.Name .. " is near!",
                    SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
                player:SendLocalizeString(
                    "You can't shatter " .. gameObject.Name .. " when " .. otherCreature.Name .. " is near!",
                    SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
                return false
            end
        end
    end

    local randomResult = math.random(100)

    if randomResult <= bossSpawnChance
    then
        gameObject:SummonCreature(bossProtoId, gameObject.X, gameObject.Y, gameObject.Z, gameObject.O,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
        player:SendLocalizeString("Terrible stench fills the air! Eastern Wyvern Matriarch has arrived!",
            SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
        player:SendLocalizeString("Terrible stench fills the air! Eastern Wyvern Matriarch has arrived!",
            SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
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
                SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
        end
    end

    player:SendLocalizeString("You found an Egg!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1,
        Localized_text.CHAT_TAG_DEFAULT)
    player:SendLocalizeString("You found an Egg!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE,
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

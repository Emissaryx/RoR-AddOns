-- Utility functions

-- Function to shuffle a list using Fisher-Yates algorithm
local function shuffle(list)
  local n = #list
  for i = n, 2, -1 do
    local j = math.random(1, i)
    list[i], list[j] = list[j], list[i]
  end
end

-- Function to get up to x random elements from a list with no duplicates
local function getRandomElements(list, x)
  local listSize = #list

  if listSize == 0 or x <= 0 then
    return {}
  end

  -- Shuffle the list
  shuffle(list)

  -- Get up to x elements from the shuffled list
  local result = {}
  for i = 1, math.min(x, listSize) do
    table.insert(result, list[i])
  end

  return result
end

-- Ekscremite

local function EkscremiteOnEnterCombat(creature, attacker)
  creature:SetState("STAGE", 0);
end

local function CastCurseOnRandomPlayers(creature, amount)
  -- Get a number of random players
  local players = creature:GetPlayersInRange()
  local randomPlayers = getRandomElements(players, amount)

  for _, randomPlayer in ipairs(randomPlayers) do
    -- Cast Infected Blood on a player
    creature:CastAbility(30230, randomPlayer)

    -- Tell everyone who it was cast on
    for _, player in ipairs(players) do
      player:SendLocalizeString("EKSCREMITE INFECTS " .. randomPlayer.Name .. "!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
    end
  end
end

local CrystalofChange = null
local CrystalofChange2 = null
local CrystalofChange3 = null

local function EkscremiteOnReceiveDamage(creature, attacker, damage)
  local currentStage = creature:GetState("STAGE")

  if currentStage == 0 and creature.HealthPercent < 75
  then
    creature:SetState("STAGE", 1)
    CastCurseOnRandomPlayers(creature, 1)
    CrystalofChange = creature:SpawnGameObject(150001, 1506027, 1048430, 11971, 162)
  elseif currentStage == 1 and creature.HealthPercent < 50
  then
    creature:SetState("STAGE", 2)
    CastCurseOnRandomPlayers(creature, 2)
    CrystalofChange2 = creature:SpawnGameObject(150001, 1506647, 1048971, 11966, 1006)
  elseif currentStage == 2 and creature.HealthPercent < 30
  then
    creature:SetState("STAGE", 3)
    CastCurseOnRandomPlayers(creature, 3)
    CrystalofChange3 = creature:SpawnGameObject(150001, 1505672, 1048989, 11711, 624)
  end
end

local function EkscremiteReset(creature)
  if CrystalofChange ~= null
  then
    CrystalofChange.Destroy()
    CrystalofChange = null
  end
  if CrystalofChange2 ~= null
  then
    CrystalofChange2.Destroy()
    CrystalofChange2 = null
  end
  if CrystalofChange3 ~= null
  then
    CrystalofChange3.Destroy()
    CrystalofChange3 = null
  end
end


RegisterCreatureScript(9992, CreatureScript.OnReceiveDamage, EkscremiteOnReceiveDamage)
RegisterCreatureScript(9992, CreatureScript.OnEnterCombat, EkscremiteOnEnterCombat)
RegisterCreatureScript(9992, CreatureScript.OnLeaveCombat, EkscremiteReset)
RegisterCreatureScript(9992, CreatureScript.OnDie, EkscremiteReset)

-- Crystal of Change

local function CrystalofChangeOnInteract(gameObject, player)
  player:SendLocalizeString("Tzeentch Changes the Infection to be harmless!",
    SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
  player:CastAbility(30232)
end

RegisterGameObjectScript(150001, GameObjectScript.OnInteract, CrystalofChangeOnInteract)

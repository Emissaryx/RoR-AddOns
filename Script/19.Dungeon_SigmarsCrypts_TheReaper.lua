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

-- The Reaper

local function TheReaperOnEnterCombat(creature, attacker)
  creature:SetState("STAGE", 0);
end

local function CastCurseOnRandomPlayers(creature, amount)
  -- Get a number of random players
  local players = creature:GetPlayersInRange()
  local randomPlayers = getRandomElements(players, amount)

  for _, randomPlayer in ipairs(randomPlayers) do
    -- Cast Curse of Darkness on a player
    creature:CastAbility(30222, randomPlayer)

    -- Tell everyone who it was cast on
    for _, player in ipairs(players) do
      player:SendLocalizeString("THE REAPER CURSES " .. randomPlayer.Name .. "!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
    end
  end
end

local empireBrazier = null

local function TheReaperOnReceiveDamage(creature, attacker, damage)
  local currentStage = creature:GetState("STAGE")

  if currentStage == 0 and creature.HealthPercent < 75
  then
    creature:SetState("STAGE", 1)
    CastCurseOnRandomPlayers(creature, 1)
    empireBrazier = creature:SpawnGameObject(150000, 1503552, 219207, 8649, 0)
  elseif currentStage == 1 and creature.HealthPercent < 50
  then
    creature:SetState("STAGE", 2)
    CastCurseOnRandomPlayers(creature, 2)
  elseif currentStage == 2 and creature.HealthPercent < 30
  then
    creature:SetState("STAGE", 3)
    CastCurseOnRandomPlayers(creature, 3)
  end
end

local function TheReaperReset(creature)
  if empireBrazier
  then
    empireBrazier.Destroy()
    empireBrazier = nil
  end
end


RegisterCreatureScript(3221, CreatureScript.OnReceiveDamage, TheReaperOnReceiveDamage)
RegisterCreatureScript(3221, CreatureScript.OnEnterCombat, TheReaperOnEnterCombat)
RegisterCreatureScript(3221, CreatureScript.OnLeaveCombat, TheReaperReset)
RegisterCreatureScript(3221, CreatureScript.OnDie, TheReaperReset)

-- Empire Brazier

local function EmpireBrazierOnInteract(gameObject, player)
  player:SendLocalizeString("Holy Fire Purges the Curse!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1,
    Localized_text.CHAT_TAG_DEFAULT)
  player:CastAbility(30227)
end

RegisterGameObjectScript(150000, GameObjectScript.OnInteract, EmpireBrazierOnInteract)

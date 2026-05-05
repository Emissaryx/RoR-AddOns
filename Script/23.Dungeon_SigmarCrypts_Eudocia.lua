-- Sister Eudocia

local function EudociaOnEnterCombat(creature, attacker)
  creature:SetState("STAGE", 0);
end

local EudociaMemory = nil


local function EudociaOnReceiveDamage(creature, attacker, damage)
  local currentStage = creature:GetState("STAGE")

  if currentStage == 0 and creature.HealthPercent < 30
  then
    creature:SetState("STAGE", 1)
    EudociaMemory = creature:SpawnGameObject(1754, 1493296, 219874, 8616, 3077)
    creature:CastAbility(30259)

    for player in creature.PlayersInRange
    do
      player:SendLocalizeString("A nearby artifact empowers Eudocia's Memory! Her incoming damage is heavily reduced!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
      player:SendLocalizeString("A nearby artifact empowers Eudocia's Memory! Her incoming damage is heavily reduced!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    end
  end
end

local function EudociaReset(creature)
  if EudociaMemory
  then
    EudociaMemory.Destroy()
    EudociaMemory = nil
  end
  creature.CastAbility(30258)
  creature.CastAbility(30257)
end

RegisterCreatureScript(3186, CreatureScript.OnReceiveDamage, EudociaOnReceiveDamage)
RegisterCreatureScript(3186, CreatureScript.OnEnterCombat, EudociaOnEnterCombat)
RegisterCreatureScript(3186, CreatureScript.OnLeaveCombat, EudociaReset)
RegisterCreatureScript(3186, CreatureScript.OnDie, EudociaReset)

-- EudociaMemory

local function EudociaMemoryOnDie(gameObject)
  local boss = gameObject.GetNearestCreature(200, 3186)

  if boss
  then
    boss.CastAbility(30258)
  end

  for player in gameObject.PlayersInRange
  do
    player:SendLocalizeString("Eudocia's memories slip away, and her power weakens!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
    player:SendLocalizeString("Eudocia's memories slip away, and her power weakens!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
  end
end


RegisterGameObjectScript(1754, GameObjectScript.OnDie, EudociaMemoryOnDie)

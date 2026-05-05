local creatureProtoId = 3548

local function OnEnterCombat(creature, attacker)
  creature:Say("Your lands will be razed and all will know the name of the Kraken!",
    SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
  creature:PlaySound(379)
  creature:SetState("STAGE", 0);
end

local function OnReceiveDamage(creature, attacker, damage)
  local currentStage = creature:GetState("STAGE")

  if currentStage == 0 and creature.HealthPercent < 80
  then
    creature:Say("None can stand before the power of the Kraken!", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
    creature:PlaySound(360)
    creature:SetState("STAGE", 1);
  elseif currentStage == 1 and creature.HealthPercent < 40
  then
    creature:Say("Death is all that awaits you on these sands, men of the south.",
      SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
    creature:PlaySound(359)
    creature:SetState("STAGE", 2);
  end
end

local function OnDie(creature)
  creature:PlaySound(361)
end

RegisterCreatureScript(creatureProtoId, CreatureScript.OnReceiveDamage, OnReceiveDamage)
RegisterCreatureScript(creatureProtoId, CreatureScript.OnEnterCombat, OnEnterCombat)
RegisterCreatureScript(creatureProtoId, CreatureScript.OnDie, OnDie)

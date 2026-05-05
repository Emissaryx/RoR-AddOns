local creatureProtoId = 41

local function OnEnterCombat(creature, attacker)
  creature:Say("I'll crush your puny skulls!", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
  creature:PlaySound(21)
  creature:SetState("STAGE", 0);
end

local function OnReceiveDamage(creature, attacker, damage)
  local currentStage = creature:GetState("STAGE")

  if currentStage == 0 and creature.HealthPercent < 80
  then
    creature:Say("Raaargh!  Me's gonna smash yas!", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
    creature:PlaySound(347)
    creature:SetState("STAGE", 1);
  elseif currentStage == 1 and creature.HealthPercent < 60
  then
    creature:Say("Stompy time!  Die!  Smash!", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
    creature:PlaySound(348)
    creature:SetState("STAGE", 2);
  elseif currentStage == 2 and creature.HealthPercent < 20
  then
    creature:Say("Ooo! Me shins!", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
    creature:PlaySound(349)
    creature:SetState("STAGE", 3);
  end
end

local function OnDie(creature)
  creature:PlaySound(350)
end

RegisterCreatureScript(creatureProtoId, CreatureScript.OnReceiveDamage, OnReceiveDamage)
RegisterCreatureScript(creatureProtoId, CreatureScript.OnEnterCombat, OnEnterCombat)
RegisterCreatureScript(creatureProtoId, CreatureScript.OnDie, OnDie)

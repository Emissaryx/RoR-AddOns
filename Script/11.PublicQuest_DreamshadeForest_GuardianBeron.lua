local creatureProtoId = 2956

local function OnEnterCombat(creature, attacker)
  creature:Say("These woods will hold no quarter for you my dark cousin.",
    SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
  creature:PlaySound(250)
  creature:SetState("STAGE", 0);
end

local function OnDie(creature)
  creature:PlaySound(256)
end

RegisterCreatureScript(creatureProtoId, CreatureScript.OnEnterCombat, OnEnterCombat)
RegisterCreatureScript(creatureProtoId, CreatureScript.OnDie, OnDie)

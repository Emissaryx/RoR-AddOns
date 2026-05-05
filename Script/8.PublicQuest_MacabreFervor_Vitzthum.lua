local creatureProtoId = 2449

local function OnEnterCombat(creature, attacker)
  creature:Say("Our doom is at hand. Behold!", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
  creature:PlaySound(842)
  creature:SetState("STAGE", 0);
end

local function OnDie(creature)
  creature:PlaySound(843)
end

RegisterCreatureScript(creatureProtoId, CreatureScript.OnEnterCombat, OnEnterCombat)
RegisterCreatureScript(creatureProtoId, CreatureScript.OnDie, OnDie)

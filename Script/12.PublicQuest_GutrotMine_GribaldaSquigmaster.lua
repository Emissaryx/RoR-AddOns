local creatureProtoId = 1000843

local function OnEnterCombat(creature, attacker)
  creature:Say("Get 'em!  Get 'em, boyz!  Get 'em good!", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
  creature:PlaySound(1278)
  creature:SetState("STAGE", 0);
end

RegisterCreatureScript(creatureProtoId, CreatureScript.OnEnterCombat, OnEnterCombat)

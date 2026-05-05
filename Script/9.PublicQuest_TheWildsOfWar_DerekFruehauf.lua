local creatureProtoId = 23443

local function OnEnterCombat(creature, attacker)
    creature:Say("Have at them boys!", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
    creature:PlaySound(406)
    creature:SetState("STAGE", 0);
end

local function OnReceiveDamage(creature, attacker, damage)
    local currentStage = creature:GetState("STAGE")

    if currentStage == 0 and creature.HealthPercent < 50
    then
        creature:Say("Your flesh is not fit to feed my hounds!", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_SAY)
        creature:PlaySound(407)
        creature:SetState("STAGE", 1);
    end
end

local function OnDie(creature)
    creature:PlaySound(408)
end

RegisterCreatureScript(creatureProtoId, CreatureScript.OnReceiveDamage, OnReceiveDamage)
RegisterCreatureScript(creatureProtoId, CreatureScript.OnEnterCombat, OnEnterCombat)
RegisterCreatureScript(creatureProtoId, CreatureScript.OnDie, OnDie)

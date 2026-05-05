-- Tobias The Fallen

local function TobiasOnEnterCombat(creature, attacker)
    creature:SetState("STAGE", 0);
end

local InvisibleCreature = null
local InvisibleCreature1 = null
local InvisibleCreature2 = null
local InvisibleCreature3 = null
local InvisibleCreature4 = null
local InvisibleCreature5 = null
local InvisibleCreature6 = null

local function TobiasOnReceiveDamage(creature, attacker, damage)
    local currentStage = creature:GetState("STAGE")
    if currentStage == 0 and creature.HealthPercent < 75
    then
        creature:SetState("STAGE", 1)
        InvisibleCreature = creature:SummonCreature(2006154, 1496894, 217670, 8649, 3087,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)

        for player in creature.PlayersInRange
        do
            player:SendLocalizeString("HOLY OILS IN THE CENTER OF THE ROOM IGNITE!",
                SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
            player:SendLocalizeString("Holy oils in the center of the room ignite!",
                SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
        end
    elseif currentStage == 1 and creature.HealthPercent < 50
    then
        creature:SetState("STAGE", 2)
        InvisibleCreature1 = creature:SummonCreature(2006154, 1497024, 217658, 8574, 1984,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
        InvisibleCreature2 = creature:SummonCreature(2006154, 1496757, 217657, 8574, 4019,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
        for player in creature.PlayersInRange
        do
            player:SendLocalizeString("THE FIRE SPREADS FURTHER FROM THE CENTER!",
                SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
            player:SendLocalizeString("The fire spreads further from the center!",
                SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
        end
    elseif currentStage == 2 and creature.HealthPercent < 30
    then
        creature:SetState("STAGE", 3)
        InvisibleCreature3 = creature:SummonCreature(2006154, 1497190, 217601, 8574, 1884,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
        InvisibleCreature4 = creature:SummonCreature(2006154, 1496898, 217476, 8574, 2012,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
        InvisibleCreature5 = creature:SummonCreature(2006154, 1496898, 217868, 8574, 4093,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
        InvisibleCreature6 = creature:SummonCreature(2006154, 1496617, 217739, 8574, 2777,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)

        for player in creature.PlayersInRange
        do
            player:SendLocalizeString("THE FIRES BEGIN TO ENGULF THE ROOM!",
                SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
            player:SendLocalizeString("The fires begin to engulf the room!",
                SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
        end
    end
end

local function TobiasReset(creature)
    if InvisibleCreature ~= null
    then
        InvisibleCreature.Destroy()
        InvisibleCreature = null
    end
    if InvisibleCreature1 ~= null
    then
        InvisibleCreature1.Destroy()
        InvisibleCreature1 = null
    end
    if InvisibleCreature2 ~= null
    then
        InvisibleCreature2.Destroy()
        InvisibleCreature2 = null
    end
    if InvisibleCreature3 ~= null
    then
        InvisibleCreature3.Destroy()
        InvisibleCreature3 = null
    end
    if InvisibleCreature4 ~= null
    then
        InvisibleCreature4.Destroy()
        InvisibleCreature4 = null
    end
    if InvisibleCreature5 ~= null
    then
        InvisibleCreature5.Destroy()
        InvisibleCreature5 = null
    end
    if InvisibleCreature6 ~= null
    then
        InvisibleCreature6.Destroy()
        InvisibleCreature6 = null
    end
end


RegisterCreatureScript(52870, CreatureScript.OnReceiveDamage, TobiasOnReceiveDamage)
RegisterCreatureScript(52870, CreatureScript.OnEnterCombat, TobiasOnEnterCombat)
RegisterCreatureScript(52870, CreatureScript.OnLeaveCombat, TobiasReset)
RegisterCreatureScript(52870, CreatureScript.OnDie, TobiasReset)

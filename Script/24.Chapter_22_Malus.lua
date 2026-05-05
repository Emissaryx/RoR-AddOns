-- Initialization of variables and states
local SpiteMemory = nil
local khaineshrine = nil
local malusbanner = nil
local spiteProtoId = 2001360
local summonedAdds = {}
local championAdds = {}
local spawnThresholds = {95, 90, 85, 80, 55, 40, 35, 30} -- {95, 90, 85, 80, 55, 40, 35, 30} before release

-------------------- Utility function below
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

-------------------- Utility Function above

-- Function called when the creature enters combat
local function MalusOnEnterCombat(creature, attacker)
    creature:SetState("STAGE", 0)
    creature:SetState("NEXT_SPAWN_PERCENT", 95) -- Change to 0 to get no spawns
end

local function CastCurseOnRandomPlayers(creature, amount)
    -- Get a number of random players
    local players = creature:GetPlayersInRange()
    local randomPlayers = getRandomElements(players, amount)

    for _, randomPlayer in ipairs(randomPlayers) do
        -- Cast Infected Blood on a player
        creature:CastAbility(30262, randomPlayer)
        
        -- Tell everyone who it was cast on
        for _, player in ipairs(players) do
                --player:SendLocalizeString("MALUS INFECTS " .. randomPlayer.Name .. "!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
        end
    end
end

-- Function called when the creature receives damage
local function MalusOnReceiveDamage(creature, attacker, damage)
    local currentStage = creature:GetState("STAGE")
    local healthPercent = creature.HealthPercent
    local nextSpawnPercent = creature:GetState("NEXT_SPAWN_PERCENT")

    -- Stage progression based on health percentage
    if currentStage == 0 and healthPercent < 76 then
        creature:SetState("STAGE", 1)
        CastCurseOnRandomPlayers(creature, 12)
        creature.PlaySound(915) --"You consder yourself brave?"

    elseif currentStage == 1 and healthPercent < 71 then
        creature:SetState("STAGE", 2)
        SpiteMemory = creature:SummonCreature(spiteProtoId, 892191, 1657981, 16779, 1020, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 600000)
        creature.PlaySound(918) --Sfx about Spite eating peeps

    elseif currentStage == 2 and healthPercent < 66 then
        creature:SetState("STAGE", 3)
        khaineshrine = creature:SpawnGameObject(1755, 890909, 1657761, 18024, 3095)
        creature:CastAbility(30273)
        creature.PlaySound(913)
        for player in creature.PlayersInRange do
            player:SendLocalizeString("Malus is being consumed by Khaine's Bloodlust! Send a group to use the nearby tower and destroy the Offering!",   
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
            player:SendLocalizeString("Malus is being consumed by Khaine's Bloodlust! Send a group to use the nearby tower and destroy the Offering!", 
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
        end

    elseif currentStage == 3 and healthPercent < 51 then
        creature:SetState("STAGE", 4)
        creature:CastAbility(14642)  -- Ability for blowing the horn
        creature.PlaySound(910) --"Send the Fodder in"
        for player in creature.PlayersInRange do
            player:SendLocalizeString("Malus signals reinforcements to join the fight!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
            player:SendLocalizeString("Malus signals reinforcements to join the fight!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
        end

        local reinforcements = {
            {9012, 890649, 1657506, 16726}, {9012, 890649, 1657606, 16726}, {9012, 890649, 1657706, 16726},
            {9012, 890649, 1657806, 16726}, {9011, 890649, 1657906, 16726}, {9011, 890649, 1658006, 16726},
            {9011, 890649, 1658106, 16726}, {9011, 890649, 1658206, 16726}, {9010, 890649, 1658306, 16726},
            {9010, 890649, 1658406, 16726}, {9010, 890554, 1657506, 16696}, {9010, 890554, 1657606, 16696},
            {9009, 890554, 1657706, 16696}, {9009, 890554, 1657806, 16696}, {9009, 890554, 1657906, 16696},
            {9009, 890554, 1658006, 16696}, {9007, 890554, 1658106, 16696}, {9007, 890554, 1658206, 16696},
            {9007, 890554, 1658306, 16696}, {9007, 890554, 1658406, 16696}
        }

        for _, reinforcement in ipairs(reinforcements) do
            local protoId, x, y, o = table.unpack(reinforcement)
            local champion = creature:SummonCreature(protoId, x, y, o, 3065, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
            table.insert(championAdds, champion)
        end

    elseif currentStage == 4 and healthPercent < 26 then
        creature:SetState("STAGE", 5)
        CastCurseOnRandomPlayers(creature, 24)

    elseif currentStage == 5 and healthPercent < 21 then
        creature:SetState("STAGE", 6)
        malusbanner = creature:SpawnGameObject(1756, 893329, 1657285, 17945, 1512)
        creature:CastAbility(30273)
        creature:CastAbility(30274)
        creature.PlaySound(911)
        for player in creature.PlayersInRange do
            player:SendLocalizeString("Malus sees the banner of his troops and rallies! Send allies to ascend the manor stairs and destroy it!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
            player:SendLocalizeString("Malus sees the banner of his troops and rallies! Send allies to ascend the manor stairs and destroy it!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
        end

    elseif currentStage == 6 and healthPercent < 2 then
        creature:SetState("STAGE", 7)
        if SpiteMemory then
            SpiteMemory:Destroy()
            SpiteMemory = nil
        end
    end

    -- Summon additional creatures based on health percentage thresholds
    for _, percent in ipairs(spawnThresholds) do
        if healthPercent <= nextSpawnPercent and nextSpawnPercent == percent then
            local add1 = creature:SummonCreature(100200, 890598, 1658002, 16710, 3087, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
            local add2 = creature:SummonCreature(9007, 890546, 1657843, 16693, 3157, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
            local add3 = creature:SummonCreature(9008, 890552, 1657680, 16695, 3157, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
            local add4 = creature:SummonCreature(9009, 890547, 1658169, 16693, 3157, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
            local add5 = creature:SummonCreature(9010, 890554, 1658337, 16696, 3157, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
            local add6 = creature:SummonCreature(9011, 890500, 1657996, 16679, 3157, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
            
            summonedAdds[#summonedAdds + 1] = add1
            summonedAdds[#summonedAdds + 1] = add2
            summonedAdds[#summonedAdds + 1] = add3
            summonedAdds[#summonedAdds + 1] = add4
            summonedAdds[#summonedAdds + 1] = add5
            summonedAdds[#summonedAdds + 1] = add6
                       
            -- Broadcast message to players
            local players = creature:GetPlayersInRange()
            if players then
                for _, player in ipairs(players) do
                    --player:SendLocalizeString("To Me My Champions!!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
                    --player:SendLocalizeString("To Me My Champions!!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
                end
            end

            -- Set the next threshold
            for i, threshold in ipairs(spawnThresholds) do
                if nextSpawnPercent == threshold then
                    if i < #spawnThresholds then
                        nextSpawnPercent = spawnThresholds[i + 1]
                    else
                        nextSpawnPercent = 0 -- No more spawns
                    end
                    creature:SetState("NEXT_SPAWN_PERCENT", nextSpawnPercent)
                    break
                end
            end

            break
        end
    end
end

-- Function to reset the creature and cleanup when it leaves combat or dies
local function MalusReset(creature)
    creature:CastAbility(30258) -- Removes Damage Taken Reduction from Malus (Rubius)
    creature:CastAbility(30257) -- Removes Damage bonus from Malus (Rubius)
    creature:CastAbility(30302) -- Removes Damage bonus from Malus because of Spite's death (Emissary)
    if SpiteMemory then
        SpiteMemory:Destroy()
        SpiteMemory = nil
    end
    if khaineshrine then  
        khaineshrine:Destroy() 
        khaineshrine = nil 
    end
    if malusbanner then  
        malusbanner:Destroy() 
        malusbanner = nil 
    end
    for _, add in ipairs(summonedAdds) do
        if add then
            add:Destroy()
        end
    end
    summonedAdds = {}
    -- Destroy all champion mobs
    for _, add in ipairs(championAdds) do
        if add then
            add:Destroy()
        end
    end
    championAdds = {}
end

-- Function called when the creature dies
local function MalusOnDie(creature, killer)
    MalusReset(creature)
end

-- Function called when Spite dies
local function SpiteOnDie(creature, killer)
    if SpiteMemory then
        SpiteMemory:Destroy() -- Despawn Spite's body
        SpiteMemory = nil
    end
    local boss = creature:GetNearestCreature(2000, 1001029)
    if boss then
        boss:CastAbility(30301)
    end
end

-- Register the creature's scripts for different events
RegisterCreatureScript(1001029, CreatureScript.OnReceiveDamage, MalusOnReceiveDamage)
RegisterCreatureScript(1001029, CreatureScript.OnEnterCombat, MalusOnEnterCombat)
RegisterCreatureScript(1001029, CreatureScript.OnLeaveCombat, MalusReset)
RegisterCreatureScript(1001029, CreatureScript.OnDie, MalusOnDie)
RegisterCreatureScript(2001360, CreatureScript.OnDie, SpiteOnDie)


-------------- Khaine's Shrine Code --------------------- Rubius 
-- Function called when the Khaine shrine game object dies
local function khaineshrineOnDie(gameObject, player)
    local boss = gameObject:GetNearestCreature(3000, 1001029)
    if boss then
        boss:CastAbility(30257)
    end
    local players = gameObject:GetPlayersInRange()
    do
        player:SendLocalizeString("Khaine's Bloodlust fades from Malus, and his strength returns to normal!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
        player:SendLocalizeString("Khaine's Bloodlust fades from Malus, and his strength returns to normal!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    end
end

-- Register the Khaine shrine's script for its death event
RegisterGameObjectScript(1755, GameObjectScript.OnDie, khaineshrineOnDie)

-- Function called when the Malus Banner game object dies
local function malusbannerOnDie(gameObject, player)
    local boss = gameObject:GetNearestCreature(5000, 1001029)
    if boss then
        boss:CastAbility(30257)
        boss:CastAbility(30258)
    end
    local players = gameObject:GetPlayersInRange()
    if players then
        for _, player in ipairs(players) do
            player:SendLocalizeString("The Banner of Malus' troops is torn down, and with it, his hopes of rallying are crumpled!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
            player:SendLocalizeString("The Banner of Malus' troops is torn down, and with it, his hopes of rallying are crumpled!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
        end
    end
end

  -- Function to remove creatures when they die
local function SummonedCreatureOnDie(creature, killer)
    creature:Destroy()
end

-- Register the Khaine shrine's script for its death event
RegisterGameObjectScript(1756, GameObjectScript.OnDie, malusbannerOnDie)

-- Register the OnDie event to remove corpses immediately upon death
RegisterCreatureScript(100200, CreatureScript.OnDie, SummonedCreatureOnDie)
RegisterCreatureScript(9007, CreatureScript.OnDie, SummonedCreatureOnDie)
RegisterCreatureScript(9008, CreatureScript.OnDie, SummonedCreatureOnDie)
RegisterCreatureScript(9009, CreatureScript.OnDie, SummonedCreatureOnDie)
RegisterCreatureScript(9010, CreatureScript.OnDie, SummonedCreatureOnDie)
RegisterCreatureScript(9011, CreatureScript.OnDie, SummonedCreatureOnDie)
RegisterCreatureScript(9012, CreatureScript.OnDie, SummonedCreatureOnDie)
-- Gorfang Fight Creature Id# 2001201

local noRepeat = 1                                         -- Set to 1 to enable no-repeat, 0 to allow repeats
local completedEmotes = {}                                 -- List to track players who have performed the correct emote
local currentEmoteHandler = nil                            -- Variable to track the current emote handler function
local usedFunctions = {}                                   -- List to keep track of used functions
local thresholds = { 90, 80, 70, 60, 50, 40, 30, 20 }      -- List of health thresholds to trigger Simon Says commands
local triggeredThresholds = {}                             -- List to track triggered thresholds
local curseThresholds = { 85, 75, 65, 55, 45, 35, 25, 15 } -- List of health thresholds to cast the puddle debuff on a random player
local triggeredCurseThresholds = {}                        -- List to track triggered curse thresholds
local summonedAdds = {}                                    -- List to track summoned additional creatures
local spawnThresholds = { 85, 70, 55, 40, 25, 10 }         -- HP percentages where adds spawn
local MiniBossMemory = nil                                 -- Variable to store the mini-boss instance
local MiniBossProtoId = 2008016                            -- Prototype ID for the mini-boss
local biguninvis = 50043                                   -- Gorfang's Big 'Un Invisible
local bigun = 50066                                        -- Gorfang's Big 'Un
local BossProtoId = 2001201                                -- Gorfang Rotgut
local MoshPitAdds = 50042                                  -- Cheering Big 'Un

-------------------------------------------------------------------------------------------

-- Utility function to shuffle a list using Fisher-Yates algorithm
local function shuffle(list)
    local n = #list
    for i = n, 2, -1 do
        local j = math.random(1, i)
        list[i], list[j] = list[j], list[i]
    end
end

-- Utility function to get up to x random elements from a list with no duplicates
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

-- Function to cast curse on a random player
local function CastCurseOnRandomPlayer(creature)
    local players = creature:GetPlayersInRange()
    local randomPlayer = getRandomElements(players, 1)[1] -- Get one random player

    if randomPlayer then
        creature:CastAbility(30361, randomPlayer)
        for _, player in ipairs(players) do
            player:SendLocalizeString("The Shaman is targeting " .. randomPlayer.Name .. "!",
                SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
            player:SendLocalizeString("The Shaman is targeting " .. randomPlayer.Name .. "!",
                SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
        end
    end
end

-- Function to cast debuff on all players and send a message
local function CastDebuffOnAllPlayers(creature, abilityId, message)
    local players = creature:GetPlayersInRange()
    if players then
        for _, player in ipairs(players) do
            creature:CastAbility(abilityId, player)
            player:SendLocalizeString(message, SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1,
                Localized_text.CHAT_TAG_DEFAULT)
            player:SendLocalizeString(message, SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE,
                Localized_text.CHAT_TAG_DEFAULT)
        end
    else
        d("No players in range.")
    end
end

-- Function to handle Simon Says Stop Running
local function SimonSaysStopRunning(creature)
    local debuffAbilityId = 27000
    local message = "Gork Sez... stop running! If ya move, you'z gonna get it!"

    CastDebuffOnAllPlayers(creature, debuffAbilityId, message)
end

-- Function to handle Simon Says Cheer
local function SimonSaysCheer(creature)
    local debuffAbilityId = 30352
    local cleanseAbilityId = 30342
    local message = "Gork Sez... /Cheer at Gorfang!"

    CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

    currentEmoteHandler = function(eventCreature, player, emoteId)
        if emoteId == 26 then -- Correct emote
            table.insert(completedEmotes, player)
            eventCreature:CastAbility(cleanseAbilityId, player)
        end
    end
end

-- Function to handle Cheer without Simon Says
local function Cheer(creature)
    local debuffAbilityId = 30353 -- Fake ability
    local damageAbilityId = 30350
    local message = "Cheer! /Cheer at Gorfang, or die!"

    CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

    currentEmoteHandler = function(eventCreature, player, emoteId)
        if emoteId == 26 then -- Incorrect emote
            eventCreature:CastAbility(damageAbilityId, player)
        end
    end
end

-- Function to handle Simon Says Cry
local function SimonSaysCry(creature)
    local debuffAbilityId = 30356
    local cleanseAbilityId = 30342
    local message = "Gork Sez... /Cry, becaus' Gorfang is tuffa den you!"

    CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

    currentEmoteHandler = function(eventCreature, player, emoteId)
        if emoteId == 30 then -- Correct emote
            table.insert(completedEmotes, player)
            eventCreature:CastAbility(cleanseAbilityId, player)
        end
    end
end

-- Function to handle Cry without Simon Says
local function Cry(creature)
    local debuffAbilityId = 30357 -- Fake ability
    local damageAbilityId = 30350
    local message = "Cry, do it! /Cry quick, or you'z gonna die!"

    CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

    currentEmoteHandler = function(eventCreature, player, emoteId)
        if emoteId == 30 then -- Incorrect emote
            eventCreature:CastAbility(damageAbilityId, player)
        end
    end
end

-- Function to handle Simon Says Kneel
local function SimonSaysKneel(creature)
    local debuffAbilityId = 30358
    local cleanseAbilityId = 30342
    local message = "Gork Sez Kneel! /Kneel to da tuffest War boss, or die!"

    CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

    currentEmoteHandler = function(eventCreature, player, emoteId)
        if emoteId == 13 then -- Correct emote
            table.insert(completedEmotes, player)
            eventCreature:CastAbility(cleanseAbilityId, player)
        end
    end
end

-- Function to handle Kneel without Simon Says
local function Kneel(creature)
    local debuffAbilityId = 30359 -- Fake ability
    local damageAbilityId = 30350
    local message = "Quick, kneel! /Kneel or you's all ded!"

    CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

    currentEmoteHandler = function(eventCreature, player, emoteId)
        if emoteId == 13 then -- Incorrect emote
            eventCreature:CastAbility(damageAbilityId, player)
        end
    end
end

-- Function to handle Simon Says Beg
local function SimonSaysBeg(creature)
    local debuffAbilityId = 30354
    local cleanseAbilityId = 30342
    local message = "Gork Sez Beg! /Beg for your lives, uglies!"

    CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

    currentEmoteHandler = function(eventCreature, player, emoteId)
        if emoteId == 3 then -- Correct emote
            table.insert(completedEmotes, player)
            eventCreature:CastAbility(cleanseAbilityId, player)
        end
    end
end

-- Function to handle Beg without Simon Says
local function Beg(creature)
    local debuffAbilityId = 30355 -- Fake ability
    local damageAbilityId = 30350
    local message = "Beg! /Beg for your lives, or dey's ours!"

    CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

    currentEmoteHandler = function(eventCreature, player, emoteId)
        if emoteId == 3 then -- Incorrect emote
            eventCreature:CastAbility(damageAbilityId, player)
        end
    end
end

-- Function to handle Simon Says Bow
local function SimonSaysBow(creature)
    local debuffAbilityId = 30341
    local cleanseAbilityId = 30342
    local message = "Gork Sez... bow! /Bow in front of da Greenskin superiorat... superi..-- cuz we'z betta!"

    CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

    currentEmoteHandler = function(eventCreature, player, emoteId)
        if emoteId == 2 then -- Correct emote
            table.insert(completedEmotes, player)
            eventCreature:CastAbility(cleanseAbilityId, player)
        end
    end
end

-- Function to handle Bow without Simon Says
local function Bow(creature)
    local debuffAbilityId = 30349 -- Fake ability
    local damageAbilityId = 30350
    local message = "Bow, 'umies, stunties, and knife-ears! Bow quick or you's gonna get it!"

    CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

    currentEmoteHandler = function(eventCreature, player, emoteId)
        if emoteId == 2 then -- Incorrect emote
            eventCreature:CastAbility(damageAbilityId, player)
        end
    end
end

-- Function to choose and execute a random Simon Says function
local function ExecuteRandomSimonSays(creature)
    -- Clear previous emote states
    completedEmotes = {}
    currentEmoteHandler = nil

    -- List of available functions
    local simonSaysFunctions = { SimonSaysCheer, SimonSaysCry, SimonSaysKneel, SimonSaysBeg, SimonSaysBow, Cheer, Cry,
        Kneel, Beg, Bow, SimonSaysStopRunning }

    if noRepeat == 1 then
        -- Remove used functions if no-repeat is enabled
        for _, usedFunction in ipairs(usedFunctions) do
            for i, func in ipairs(simonSaysFunctions) do
                if func == usedFunction then
                    table.remove(simonSaysFunctions, i)
                    break
                end
            end
        end
    end

    -- Choose a random function from the remaining available functions
    local randomFunction = simonSaysFunctions[math.random(#simonSaysFunctions)]
    randomFunction(creature)

    -- Add the chosen function to the list of used functions
    table.insert(usedFunctions, randomFunction)
end

-- Function to destroy previously summoned mobs
local function DestroySummonedMobs()
    for _, add in ipairs(summonedAdds) do
        if add then
            add:Destroy()
        end
    end
    summonedAdds = {}
end

-- Function to spawn six mobs 200 units to the right of a given coordinate for the 90% phase
local function MoshPit90(creature)
    local startX, startY, startZ, heading = 1420227, 1012775, 13694, 1042
    local offset = 200

    for i = 0, 5 do
        local y = startY - (i * offset) -- Decrease y-coordinate by offset for each iteration
        -- Spawn the biguninvis mob
        local moshpit90a = creature:SummonCreature(biguninvis, startX, y, startZ, heading,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
        if moshpit90a then
            table.insert(summonedAdds, moshpit90a)
        end

        -- Spawn the bigun mob on top of the biguninvis mob
        local moshpit90b = creature:SummonCreature(MoshPitAdds, startX, y, startZ, heading,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
        if moshpit90b then
            table.insert(summonedAdds, moshpit90b)
        end
    end
end

-- Function to spawn six mobs 200 units to the right of a given coordinate for the 70% phase
local function MoshPit70(creature)
    local startX, startY, startZ, heading = 1419533, 1012571, 14058, 984
    local offset = 200

    for i = 0, 5 do
        local y = startY - (i * offset) -- Decrease y-coordinate by offset for each iteration
        -- Spawn the biguninvis mob
        local moshpit70a = creature:SummonCreature(biguninvis, startX, y, startZ, heading,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
        if moshpit70a then
            table.insert(summonedAdds, moshpit70a)
        end

        -- Spawn the bigun mob on top of the biguninvis mob
        local moshpit70b = creature:SummonCreature(MoshPitAdds, startX, y, startZ, heading,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
        if moshpit70b then
            table.insert(summonedAdds, moshpit70b)
        end
    end
end

-- Function to spawn six mobs 200 units to the right of a given coordinate for the 50% phase
local function MoshPit50(creature)
    local startX, startY, startZ, heading = 1419146, 1012553, 14238, 988
    local offset = 200

    for i = 0, 5 do
        local y = startY - (i * offset) -- Decrease y-coordinate by offset for each iteration
        -- Spawn the biguninvis mob
        local moshpit50a = creature:SummonCreature(biguninvis, startX, y, startZ, heading,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
        if moshpit50a then
            table.insert(summonedAdds, moshpit50a)
        end

        -- Spawn the bigun mob on top of the biguninvis mob
        local moshpit50b = creature:SummonCreature(MoshPitAdds, startX, y, startZ, heading,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
        if moshpit50b then
            table.insert(summonedAdds, moshpit50b)
        end
    end
end

-- Function to remove creatures when they die
local function SummonedCreatureOnDie(creature, killer)
    creature:Destroy()
end

-- Function to handle boss receiving damage and triggering the random Simon Says game and curse at specified thresholds
local function BossOnReceiveDamage(creature, attacker, damage)
    local currentStage = creature:GetState("STAGE")                  -- Current stage of the fight
    local healthPercent = creature.HealthPercent
    local nextSpawnPercent = creature:GetState("NEXT_SPAWN_PERCENT") -- Next health percent to trigger mob spawns

    -- Stage transitions and mob spawns
    if currentStage == 0 and healthPercent < 91 then
        creature:SetState("STAGE", 1)
        MoshPit90(creature)
    elseif currentStage == 1 and healthPercent < 71 then
        creature:SetState("STAGE", 2)
        DestroySummonedMobs() -- Destroy mobs spawned at 90%
        MoshPit70(creature)   -- Spawn new mobs at 70% using the MoshPit70 function
    elseif currentStage == 2 and healthPercent < 56 then
        creature:SetState("STAGE", 3)
        MiniBossMemory = creature:SummonCreature(MiniBossProtoId, 1415784, 1011932, 14863, 3499,
            SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
    elseif currentStage == 3 and healthPercent < 51 then
        creature:SetState("STAGE", 4)
        DestroySummonedMobs() -- Destroy mobs spawned at 70%
        MoshPit50(creature)   -- Spawn new mobs at 50% using the MoshPit50 function
    end

    -- Trigger curses at thresholds
    for _, threshold in ipairs(curseThresholds) do
        if healthPercent < threshold + 1 and not triggeredCurseThresholds[threshold] then
            triggeredCurseThresholds[threshold] = true
            CastCurseOnRandomPlayer(creature)
            break
        end
    end

    -- Summon additional creatures based on health percentage thresholds
    for _, percent in ipairs(spawnThresholds) do
        if healthPercent <= nextSpawnPercent and nextSpawnPercent == percent then
            local add1 = creature:SummonCreature(bigun, 1416546, 1011622, 14716, 3489,
                SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
            local add2 = creature:SummonCreature(bigun, 1416417, 1011783, 14759, 3413,
                SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
            local add3 = creature:SummonCreature(bigun, 1416289, 1011954, 14783, 3381,
                SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
            local add4 = creature:SummonCreature(bigun, 1416220, 1012740, 14683, 2981,
                SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
            local add5 = creature:SummonCreature(bigun, 1416359, 1012972, 14640, 2853,
                SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)

            summonedAdds[#summonedAdds + 1] = add1
            summonedAdds[#summonedAdds + 1] = add2
            summonedAdds[#summonedAdds + 1] = add3
            summonedAdds[#summonedAdds + 1] = add4
            summonedAdds[#summonedAdds + 1] = add5

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

-- Function called when the creature enters combat
local function BossOnEnterCombat(creature, attacker)
    creature:SetState("STAGE", 0)
    creature:SetState("NEXT_SPAWN_PERCENT", 85) -- Change to 0 to get no spawns
    -- Clear the list of completed emotes and used functions when combat starts
    completedEmotes = {}
    currentEmoteHandler = nil
    usedFunctions = {}
    triggeredThresholds = {}
    triggeredCurseThresholds = {}
end

-- Function to reset the boss and clean up states
local function BossOnReset(creature)
    -- Clear the list of completed emotes and used functions on reset
    completedEmotes = {}
    currentEmoteHandler = nil
    usedFunctions = {}
    triggeredThresholds = {}
    triggeredCurseThresholds = {}

    -- Destroy all summoned creatures
    for _, add in ipairs(summonedAdds) do
        if add then
            add:Destroy()
        end
    end
    summonedAdds = {}

    -- Destroy mini-boss if it exists
    if MiniBossMemory then
        MiniBossMemory:Destroy()
        MiniBossMemory = nil
    end
end

-- Function called when the creature dies
local function BossOnDie(creature, killer)
    BossOnReset(creature)
end

-- Function called when the creature receives an emote
local function BossOnReceiveEmote(creature, player, emoteId)
    if currentEmoteHandler then
        currentEmoteHandler(creature, player, emoteId)
    end
    -- If currentEmoteHandler is nil, do nothing
end

-- Function called when Black Orc Boss (mini-boss) dies
local function MiniBossOnDie(creature, killer)
    if MiniBossMemory then
        MiniBossMemory:Destroy() -- Despawn Black Orc Boss' body
        MiniBossMemory = nil
    end
    local boss = creature:GetNearestCreature(36000, BossProtoId)
    if boss then
        boss:CastAbility(27003)
    end
end

-- Register the OnDie event to remove corpses immediately upon death
RegisterCreatureScript(biguninvis, CreatureScript.OnDie, SummonedCreatureOnDie)
RegisterCreatureScript(MoshPitAdds, CreatureScript.OnDie, SummonedCreatureOnDie)
RegisterCreatureScript(bigun, CreatureScript.OnDie, SummonedCreatureOnDie)

-- Register the creature's scripts for different events
RegisterCreatureScript(BossProtoId, CreatureScript.OnReceiveDamage, BossOnReceiveDamage)
RegisterCreatureScript(BossProtoId, CreatureScript.OnEnterCombat, BossOnEnterCombat)
RegisterCreatureScript(BossProtoId, CreatureScript.OnLeaveCombat, BossOnReset)
RegisterCreatureScript(BossProtoId, CreatureScript.OnDie, BossOnDie)
RegisterCreatureScript(BossProtoId, CreatureScript.OnReceiveEmote, BossOnReceiveEmote)
RegisterCreatureScript(MiniBossProtoId, CreatureScript.OnDie, MiniBossOnDie)

-- End of script

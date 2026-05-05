-- Gorfang Fight Creature Id# 2001201

local noRepeat = 1                                       -- Set to 1 to enable no-repeat, 0 to allow repeats
local completedEmotes = {}                               -- List to track players who have performed the correct emote
local currentEmoteHandler = nil                          -- Variable to track the current emote handler function
local usedFunctions = {}                                 -- List to keep track of used functions
local thresholds = { 90, 80, 70, 60, 50, 40, 30, 20 }    -- List of health thresholds to trigger Ungrim Says commands
local triggeredThresholds = {}                           -- List to track triggered thresholds
local curseThresholds = { 85, 75, 65, 55, 45, 35, 25, 15 } -- List of health thresholds to cast the puddle debuff on a random player
local triggeredCurseThresholds = {}                      -- List to track triggered curse thresholds
local summonedAdds = {}
local spawnThresholds = { 85, 70, 55, 40, 25, 10 }       -- {85, 70, 55, 40, 25, 10} HP percentages where adds spawn
local BlackOrcBossMemory = nil
local BlackOrcBossProtoId = 2008016

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
  local randomPlayer = getRandomElements(players, 1)[1]   -- Get one random player

  if randomPlayer then
    creature:CastAbility(30361, randomPlayer)
    for _, player in ipairs(players) do
      player:SendLocalizeString("The Dwarf is targeting " .. randomPlayer.Name .. "!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
      player:SendLocalizeString("The Dwarf is targeting " .. randomPlayer.Name .. "!",
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

-- Function to handle Ungrim Says Stop Running
local function UngrimSaysStopRunning(creature)
  local debuffAbilityId = 27000
  local message = "Ungrim Says... stop running! If ya move, you'z gonna get it!"

  CastDebuffOnAllPlayers(creature, debuffAbilityId, message)
end

-- Function to handle Ungrim Says Cheer
local function UngrimSaysCheer(creature)
  local debuffAbilityId = 30352
  local cleanseAbilityId = 30342
  local message = "Ungrim Says... /Cheer at Gorfang!"

  CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

  currentEmoteHandler = function(eventCreature, player, emoteId)
    if emoteId == 26 then     -- Correct emote
      table.insert(completedEmotes, player)
      eventCreature:CastAbility(cleanseAbilityId, player)
    end
  end
end

-- Function to handle Cheer without Ungrim Says
local function Cheer(creature)
  local debuffAbilityId = 30353   -- Fake ability
  local damageAbilityId = 30350
  local message = "Cheer! /Cheer at Gorfang, or die!"

  CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

  currentEmoteHandler = function(eventCreature, player, emoteId)
    if emoteId == 26 then     -- Incorrect emote
      eventCreature:CastAbility(damageAbilityId, player)
    end
  end
end

-- Function to handle Ungrim Says Cry
local function UngrimSaysCry(creature)
  local debuffAbilityId = 30356
  local cleanseAbilityId = 30342
  local message = "Ungrim Says... /Cry, becaus' Gorfang is tuffa den you!"

  CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

  currentEmoteHandler = function(eventCreature, player, emoteId)
    if emoteId == 30 then     -- Correct emote
      table.insert(completedEmotes, player)
      eventCreature:CastAbility(cleanseAbilityId, player)
    end
  end
end

-- Function to handle Cry without Ungrim Says
local function Cry(creature)
  local debuffAbilityId = 30357   -- Fake ability
  local damageAbilityId = 30350
  local message = "Cry, do it! /Cry quick, or you'z gonna die!"

  CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

  currentEmoteHandler = function(eventCreature, player, emoteId)
    if emoteId == 30 then     -- Incorrect emote
      eventCreature:CastAbility(damageAbilityId, player)
    end
  end
end

-- Function to handle Ungrim Says Kneel
local function UngrimSaysKneel(creature)
  local debuffAbilityId = 30358
  local cleanseAbilityId = 30342
  local message = "Ungrim Says Kneel! /Kneel to da tuffest War boss, or die!"

  CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

  currentEmoteHandler = function(eventCreature, player, emoteId)
    if emoteId == 13 then     -- Correct emote
      table.insert(completedEmotes, player)
      eventCreature:CastAbility(cleanseAbilityId, player)
    end
  end
end

-- Function to handle Kneel without Ungrim Says
local function Kneel(creature)
  local debuffAbilityId = 30359   -- Fake ability
  local damageAbilityId = 30350
  local message = "Quick, kneel! /Kneel or you's all ded!"

  CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

  currentEmoteHandler = function(eventCreature, player, emoteId)
    if emoteId == 13 then     -- Incorrect emote
      eventCreature:CastAbility(damageAbilityId, player)
    end
  end
end

-- Function to handle Ungrim Says Beg
local function UngrimSaysBeg(creature)
  local debuffAbilityId = 30354
  local cleanseAbilityId = 30342
  local message = "Ungrim Says Beg! /Beg for your lives, uglies!"

  CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

  currentEmoteHandler = function(eventCreature, player, emoteId)
    if emoteId == 3 then     -- Correct emote
      table.insert(completedEmotes, player)
      eventCreature:CastAbility(cleanseAbilityId, player)
    end
  end
end

-- Function to handle Beg without Ungrim Says
local function Beg(creature)
  local debuffAbilityId = 30355   -- Fake ability
  local damageAbilityId = 30350
  local message = "Beg! /Beg for your lives, or dey's ours!"

  CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

  currentEmoteHandler = function(eventCreature, player, emoteId)
    if emoteId == 3 then     -- Incorrect emote
      eventCreature:CastAbility(damageAbilityId, player)
    end
  end
end

-- Function to handle Ungrim Says Bow
local function UngrimSaysBow(creature)
  local debuffAbilityId = 30341
  local cleanseAbilityId = 30342
  local message = "Ungrim Says... bow! /Bow in front of da Greenskin superiorat... superi..-- cuz we'z betta!"

  CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

  currentEmoteHandler = function(eventCreature, player, emoteId)
    if emoteId == 2 then     -- Correct emote
      table.insert(completedEmotes, player)
      eventCreature:CastAbility(cleanseAbilityId, player)
    end
  end
end

-- Function to handle Bow without Ungrim Says
local function Bow(creature)
  local debuffAbilityId = 30349   -- Fake ability
  local damageAbilityId = 30350
  local message = "Bow, 'umies, stunties, and knife-ears! Bow quick or you's gonna get it!"

  CastDebuffOnAllPlayers(creature, debuffAbilityId, message)

  currentEmoteHandler = function(eventCreature, player, emoteId)
    if emoteId == 2 then     -- Incorrect emote
      eventCreature:CastAbility(damageAbilityId, player)
    end
  end
end

-- Function to choose and execute a random Ungrim Says function
local function ExecuteRandomUngrimSays(creature)
  -- Clear previous emote states
  completedEmotes = {}
  currentEmoteHandler = nil

  -- List of available functions
  local UngrimSaysFunctions = { UngrimSaysCheer, UngrimSaysCry, UngrimSaysKneel, UngrimSaysBeg, UngrimSaysBow, Cheer, Cry,
    Kneel, Beg, Bow, UngrimSaysStopRunning }

  if noRepeat == 1 then
    -- Remove used functions if no-repeat is enabled
    for _, usedFunction in ipairs(usedFunctions) do
      for i, func in ipairs(UngrimSaysFunctions) do
        if func == usedFunction then
          table.remove(UngrimSaysFunctions, i)
          break
        end
      end
    end
  end

  -- Choose a random function from the remaining available functions
  local randomFunction = UngrimSaysFunctions[math.random(#UngrimSaysFunctions)]
  randomFunction(creature)

  -- Add the chosen function to the list of used functions
  table.insert(usedFunctions, randomFunction)
end

-- Function to remove creatures when they die
local function SummonedCreatureOnDie(creature, killer)
  creature:Destroy()
end

-- Function to handle boss receiving damage and triggering the random Ungrim Says game and curse at specified thresholds
local function UngrimOnReceiveDamage(creature, attacker, damage)
  local currentStage = creature:GetState("STAGE")                    -- knows when to set the next stage
  local healthPercent = creature.HealthPercent
  local nextSpawnPercent = creature:GetState("NEXT_SPAWN_PERCENT")   -- Used to keep track of the dmg on the boss so we know when our champs will be spawned

  if currentStage == 0 and healthPercent < 56 then
    creature:SetState("STAGE", 1)
    --BlackOrcBossMemory = creature:SummonCreature(BlackOrcBossProtoId, 1415784, 1011932, 14863, 3499, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
  end

  for _, threshold in ipairs(thresholds) do
    if healthPercent < threshold + 1 and not triggeredThresholds[threshold] then
      triggeredThresholds[threshold] = true
      ExecuteRandomUngrimSays(creature)
      break
    end
  end

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
      local add1 = creature:SummonCreature(15542, 1426431, 850921, 15006, 2747,
        SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
      local add2 = creature:SummonCreature(15542, 1426469, 851000, 15006, 2747,
        SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
      local add3 = creature:SummonCreature(15542, 1426509, 851070, 15006, 2747,
        SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
      local add4 = creature:SummonCreature(15542, 1428177, 850684, 15006, 696,
        SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
      local add5 = creature:SummonCreature(15542, 1427724, 849828, 15006, 658,
        SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)

      summonedAdds[#summonedAdds + 1] = add1
      summonedAdds[#summonedAdds + 1] = add2
      summonedAdds[#summonedAdds + 1] = add3
      summonedAdds[#summonedAdds + 1] = add4
      summonedAdds[#summonedAdds + 1] = add5

      -- Register the OnDie event to remove corpses immediately upon death
      RegisterCreatureScript(15542, CreatureScript.OnDie, SummonedCreatureOnDie)

      -- Set the next threshold
      for i, threshold in ipairs(spawnThresholds) do
        if nextSpawnPercent == threshold then
          if i < #spawnThresholds then
            nextSpawnPercent = spawnThresholds[i + 1]
          else
            nextSpawnPercent = 0             -- No more spawns
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
local function UngrimOnEnterCombat(creature, attacker)
  creature:SetState("STAGE", 0)
  creature:SetState("NEXT_SPAWN_PERCENT", 85)   -- Change to 0 to get no spawns
  -- Clear the list of completed emotes and used functions when combat starts
  completedEmotes = {}
  currentEmoteHandler = nil
  usedFunctions = {}
  triggeredThresholds = {}
  triggeredCurseThresholds = {}
end

-- Function to reset the boss and clean up states
local function UngrimOnReset(creature)
  -- Clear the list of completed emotes and used functions on reset
  completedEmotes = {}
  currentEmoteHandler = nil
  usedFunctions = {}
  triggeredThresholds = {}
  triggeredCurseThresholds = {}

  for _, add in ipairs(summonedAdds) do
    if add then
      add:Destroy()
    end
  end
  summonedAdds = {}

  --if BlackOrcBossMemory then
  -- BlackOrcBossMemory:Destroy()
  --  BlackOrcBossMemory = nil
  -- end
end

-- Function called when the creature dies
local function UngrimOnDie(creature, killer)
  GorfangOnReset(creature)
end

-- Function called when the creature receives an emote
local function UngrimOnReceiveEmote(creature, player, emoteId)
  if currentEmoteHandler then
    currentEmoteHandler(creature, player, emoteId)
  end
  -- If currentEmoteHandler is nil, do nothing
end

-- Function called when Spite dies
local function BlackOrcBossOnDie(creature, killer)
  if BlackOrcBossMemory then
    BlackOrcBossMemory:Destroy()     -- Despawn Black Orc Boss' body
    BlackOrcBossMemory = nil
  end
  local boss = creature:GetNearestCreature(36000, 2001201)
  if boss then
    boss:CastAbility(27003)
  end
end

-- Register the creature's scripts for different events
RegisterCreatureScript(44767, CreatureScript.OnReceiveDamage, UngrimOnReceiveDamage)
RegisterCreatureScript(44767, CreatureScript.OnEnterCombat, UngrimOnEnterCombat)
RegisterCreatureScript(44767, CreatureScript.OnLeaveCombat, UngrimOnReset)
RegisterCreatureScript(44767, CreatureScript.OnDie, UngrimOnDie)
RegisterCreatureScript(44767, CreatureScript.OnReceiveEmote, UngrimOnReceiveEmote)
--RegisterCreatureScript(2008016, CreatureScript.OnDie, BlackOrcBossOnDie)

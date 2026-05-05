-- Initialization of variables and states
local AshtariMemory = nil
local AshtariID = 2008018
local summonedAdds = {}
local championAdds = {}
local spawnThresholds = { 95, 90, 85, 80, 55, 40, 35, 30 }

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
local function CaradryanOnEnterCombat(creature, attacker)
  creature:SetState("STAGE", 0)
  creature:SetState("NEXT_SPAWN_PERCENT", 95)   -- Change to 0 to get no spawns should be 95 though on launch
end

local function CastCurseOnRandomPlayers(creature, amount)
  -- Get a number of random players
  local players = creature:GetPlayersInRange()
  local randomPlayers = getRandomElements(players, amount)

  for _, randomPlayer in ipairs(randomPlayers) do
    -- Cast Infected Blood on a player
    creature:CastAbility(30384, randomPlayer)

    -- Tell everyone who it was cast on
    for _, player in ipairs(players) do
      player:SendLocalizeString("Caradryan INFECTS " .. randomPlayer.Name .. "!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
    end
  end
end

-- Function called when the creature receives damage
local function CaradryanOnReceiveDamage(creature, attacker, damage)
  local currentStage = creature:GetState("STAGE")
  local healthPercent = creature.HealthPercent
  local nextSpawnPercent = creature:GetState("NEXT_SPAWN_PERCENT")

  if currentStage == 0 and healthPercent < 76 then
    creature:SetState("STAGE", 1)
    CastCurseOnRandomPlayers(creature, 12)
  elseif currentStage == 1 and healthPercent < 71 then
    creature:SetState("STAGE", 2)
    AshtariMemory = creature:SummonCreature(AshtariID, 1075241, 1668420, 4908, 1518,
      SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 900000)
  elseif currentStage == 2 and healthPercent < 51 then
    creature:SetState("STAGE", 3)
    creature:CastAbility(14642)     -- Ability for blowing the horn
    -- creature.PlaySound(910) -- "Send the Fodder in"
    for player in creature.PlayersInRange do
      player:SendLocalizeString("Caradryan signals reinforcements to join the fight!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
      player:SendLocalizeString("Caradryan signals reinforcements to join the fight!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    end

    local reinforcements = {
      { 900020, 1074718, 1665856, 3811 }, { 900019, 1074651, 1665801, 3794 }, { 900022, 1074597, 1665893, 3812 },
      { 900020, 1074477, 1665899, 3812 }, { 900019, 1076193, 1666534, 3808 }, { 900022, 1076255, 1666299, 3808 },
      { 900020, 1076203, 1666824, 3808 }, { 900019, 1073202, 1667029, 3808 }, { 900023, 1074534, 4665807, 3796 },
      { 900020, 1076197, 1666743, 3808 }, { 900019, 1073436, 1666901, 3808 }, { 900023, 1073334, 1667235, 3808 },
      { 900020, 1073187, 1666929, 3808 }, { 900019, 1074726, 1665830, 3803 }, { 900023, 1073460, 1667114, 3808 },
      { 900023, 1076193, 1666667, 3808 }, { 900022, 1073241, 1667084, 3808 }, { 900023, 1076303, 1666397, 3808 },
      { 900022, 1076190, 1666606, 3808 }, { 900022, 1073282, 1667162, 3808 }
    }

    for _, reinforcement in ipairs(reinforcements) do
      local protoId, x, y, o = table.unpack(reinforcement)
      local champion = creature:SummonCreature(protoId, x, y, o, 3065, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN,
        900000)
      table.insert(championAdds, champion)
    end
  elseif currentStage == 3 and healthPercent < 26 then
    creature:SetState("STAGE", 4)
    CastCurseOnRandomPlayers(creature, 12)
  elseif currentStage == 4 and healthPercent < 2 then
    creature:SetState("STAGE", 5)
    if AshtariMemory then
      AshtariMemory:Destroy()
      AshtariMemory = nil
    end
  end

  -- Summon additional creatures based on health percentage thresholds
  for _, percent in ipairs(spawnThresholds) do
    if healthPercent <= nextSpawnPercent and nextSpawnPercent == percent then
      local add1 = creature:SummonCreature(900022, 1074718, 1665856, 3811, 4013,
        SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
      local add2 = creature:SummonCreature(900023, 1074651, 1665801, 3794, 4055,
        SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
      local add3 = creature:SummonCreature(900021, 1074597, 1665893, 3812, 4073,
        SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                -- Keeper of the Flame
      local add4 = creature:SummonCreature(900020, 1074534, 4665807, 3796, 4073,
        SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
      local add5 = creature:SummonCreature(900020, 1074477, 1665899, 3812, 4075,
        SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
      local add6 = creature:SummonCreature(900020, 1074788, 1665964, 3997, 3995,
        SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)

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
          -- player:SendLocalizeString("To Me My Champions!!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
          -- player:SendLocalizeString("To Me My Champions!!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
        end
      end

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

-- Function to remove creatures when they die
local function SummonedCreatureOnDie(creature, killer)
  creature:Destroy()
end

-- Function to reset the creature and cleanup when it leaves combat or dies
local function CaradryanReset(creature)
  -- Destroy all regular 6 man mobs
  for _, add in ipairs(summonedAdds) do
    if add then
      add:Destroy()
    end
  end
  summonedAdds = {}

  -- Destroy all 20 champion mobs
  for _, add in ipairs(championAdds) do
    if add then
      add:Destroy()
    end
  end
  championAdds = {}

  if AshtariMemory then
    AshtariMemory:Destroy()
    AshtariMemory = nil
  end
end

-- Function called when the creature dies
local function CaradryanOnDie(creature, killer)
  CaradryanReset(creature)
end

-- Function called when Ashtari dies
local function AshtariOnDie(creature, killer)
  if AshtariMemory then
    AshtariMemory:Destroy()     -- Despawn Ashtari's body
    AshtariMemory = nil
  end
  local boss = creature:GetNearestCreature(36000, 46800)
  if boss then
    -- boss:CastAbility(30301)
  end
end

-- Register the creature's scripts for different events
RegisterCreatureScript(46800, CreatureScript.OnReceiveDamage, CaradryanOnReceiveDamage)
RegisterCreatureScript(46800, CreatureScript.OnEnterCombat, CaradryanOnEnterCombat)
RegisterCreatureScript(46800, CreatureScript.OnLeaveCombat, CaradryanReset)
RegisterCreatureScript(46800, CreatureScript.OnDie, CaradryanOnDie)
RegisterCreatureScript(2008018, CreatureScript.OnDie, AshtariOnDie)

-- Register scripts for summoned creatures
RegisterCreatureScript(900019, CreatureScript.OnDie, SummonedCreatureOnDie) -- Vanguard of Asuryan
RegisterCreatureScript(900020, CreatureScript.OnDie, SummonedCreatureOnDie) -- Phoenix Shrinelord
RegisterCreatureScript(900021, CreatureScript.OnDie, SummonedCreatureOnDie) -- Keeper of the Flame
RegisterCreatureScript(900022, CreatureScript.OnDie, SummonedCreatureOnDie) -- Shrinekeeper of Asuryan
RegisterCreatureScript(900023, CreatureScript.OnDie, SummonedCreatureOnDie) -- Sentinel of Asuryan

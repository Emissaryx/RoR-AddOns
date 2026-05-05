--[[
Lord of Change Script

High-Level Overview:
This script handles the behavior of the Lord of Change boss in the game. It manages different combat stages,
spawns additional creatures at specific health thresholds, and implements various mechanics such as Chaos Marks
and portal spawning.

Key Variables and Constants:
spawnThresholds: Health percentages at which additional creatures are spawned.
spawnLocations: Predefined locations where creatures can be spawned.
summonedAdds: A list to keep track of all summoned creatures for proper cleanup.
]]

-- Utility function to shuffle a list using Fisher-Yates algorithm
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


-- This is the function that starts Stage 0
-- This also sets the spawn percentage to begin the Champions spawns
local function LordOnEnterCombat(creature, attacker)
  creature:SetState("STAGE", 0)
  creature:SetState("NEXT_SPAWN_PERCENT", 90) -- Change 0 to 90 closer to release
end

local chaosmark1 = nil -- book looking object
local chaosmark2 = nil
local chaosmark3 = nil
local chaosmark4 = nil
local chaosmark5 = nil -- not used yet
local chaosmark6 = nil -- Core object when going through portal
local portal = nil     -- Reference to the portal
local herald1 = nil    -- Reference to Heralds
local herald2 = nil    -- Reference to Heralds

-- Initialization of variables and states
local summonedAdds = {}
-- Below is where it is the spawn thresholds that are called way below after all the stages
-- If you want to change when the 6 Champions spawn, this is the line below to do it health is checked on creature id# 1000968 (Lord of Change)
local spawnThresholds = { 90, 80, 70, 60, 50, 40, 30, 20, 10 }
-- called in ResetSpawnLocations
local spawnLocations = {
  { x = 1450025, y = 777621, z = 19619, o = 3367 }, -- #1 Right steps West side
  { x = 1449764, y = 778439, z = 19619, o = 2923 }, -- #2
  { x = 1449911, y = 779269, z = 19619, o = 2693 }, -- #3
  { x = 1450404, y = 779923, z = 19619, o = 2501 }, -- #4
  { x = 1451232, y = 780246, z = 19619, o = 2239 }, -- #5
  { x = 1452086, y = 780106, z = 19619, o = 1730 }, -- #6
  { x = 1452758, y = 779677, z = 19619, o = 1520 }, -- #7
  { x = 1453140, y = 778834, z = 19619, o = 1092 } -- #8 Left steps East side
}
-- this is called in 2 functions below
local availableSpawnLocations = {}

-- After all spawn locations are used this function will be called
local function ResetSpawnLocations()
  availableSpawnLocations = {}
  for i = 1, #spawnLocations do
    table.insert(availableSpawnLocations, spawnLocations[i])
  end
end

-- Randomized spawn location function
local function RandomizeSummonLocation()
  if #availableSpawnLocations == 0 then
    ResetSpawnLocations()
  end

  local index = math.random(#availableSpawnLocations)
  local location = availableSpawnLocations[index]
  table.remove(availableSpawnLocations, index)

  return location
end

-- Function to tell the script to kill the 6 spawned Champions
local function SummonedCreatureOnDie(creature, killer)
  creature:Destroy()
end

-- Function to handle damage received by the Lord of Change
local function LordOnReceiveDamage(creature, attacker, damage)
  -- Stage 0
  local currentStage = creature:GetState("STAGE")                  -- knows when to set the next stage
  local healthPercent = creature
  .HealthPercent                                                   -- watching the health percentage of the boss so the script knows when to work its magic
  local nextSpawnPercent = creature:GetState("NEXT_SPAWN_PERCENT") -- Used to keep track of the dmg on the boss so we know when our champs will be spawned

  -- Stage handling based on health percentages
  -- Stage 1
  if currentStage == 0 and healthPercent < 96 then
    creature:SetState("STAGE", 1)
    chaosmark1 = creature:SpawnGameObject(1758, 1450009, 778008, 19619, 354)
    creature:CastAbility(30285)
    for player in creature.PlayersInRange do
      player:SendLocalizeString(
      "Marks of Chaos begin to appear up the nearby stairs. The Lord grows stronger with each!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
      player:SendLocalizeString(
      "Marks of Chaos begin to appear up the nearby stairs. The Lord grows stronger with each!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    end
    -- Stage 2
  elseif currentStage == 1 and healthPercent < 91 then
    creature:SetState("STAGE", 2)
    chaosmark2 = creature:SpawnGameObject(1757, 1450055, 779167, 19619, 2767)
    creature:CastAbility(30287)
    -- Stage 3
  elseif currentStage == 2 and healthPercent < 86 then
    creature:SetState("STAGE", 3)
    chaosmark3 = creature:SpawnGameObject(1759, 1451669, 780060, 19619, 1982)
    creature:CastAbility(30289)
    -- Stage 4
  elseif currentStage == 3 and healthPercent < 81 then
    creature:SetState("STAGE", 4)
    chaosmark8 = creature:SpawnGameObject(1764, 1452406, 779783, 19619, 1654)
    creature:CastAbility(30285)
    -- Stage 5
  elseif currentStage == 4 and healthPercent < 76 then
    creature:SetState("STAGE", 5)
    chaosmark4 = creature:SpawnGameObject(1760, 1452909, 779168, 19619, 1298)
    creature:CastAbility(30286)
    -- Stage 6
  elseif currentStage == 5 and healthPercent < 71 then
    creature:SetState("STAGE", 6)
    chaosmark7 = creature:SpawnGameObject(1763, 1449877, 778155, 19619, 3207)
    creature:CastAbility(30285)
    -- Stage 7
  elseif currentStage == 6 and healthPercent < 66 then
    creature:SetState("STAGE", 7)
    chaosmark9 = creature:SpawnGameObject(1765, 1450055, 779167, 19619, 2767)
    creature:CastAbility(30287)
    -- Stage 8
  elseif currentStage == 7 and healthPercent < 61 then
    creature:SetState("STAGE", 8)
    chaosmark10 = creature:SpawnGameObject(1766, 1451669, 780060, 19619, 1982)
    creature:CastAbility(30289)
    -- Stage 9
  elseif currentStage == 8 and healthPercent < 56 then
    creature:SetState("STAGE", 9)
    chaosmark11 = creature:SpawnGameObject(1767, 1452406, 779783, 19619, 1654)
    creature:CastAbility(30285)
    -- Stage 10
  elseif currentStage == 9 and healthPercent < 51 then
    creature:SetState("STAGE", 10)
    portal = creature:SpawnGameObject(19699, 1450787, 780224, 19619, 2245)
    chaosmark12 = creature:SpawnGameObject(1768, 1452909, 779168, 19619, 1298)
    creature:CastAbility(30286)   -- Ability Shield of the Warp -- The Lord of Change manipulates even the fabric of time to slow incoming attacks, reducing the damage he takes by 85%.
    chaosmark6 = creature:SpawnGameObject(1762, 1451926, 771860, 13055, 1048)
    creature:CastAbility(30281)   -- Ability Chaotic Wrath -- Stacking enrage buff for the Lord of Change
    -- Text to announce the portal spawning
    for player in creature.PlayersInRange do
      player:SendLocalizeString("A portal opens at the top of the stairs... ",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
      player:SendLocalizeString("A portal opens at the top of the stairs...The Lord of Change grows further empowered!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    end
    -- Stage 11
  elseif currentStage == 10 and healthPercent < 41 then
    creature:SetState("STAGE", 11)
    herald1 = creature:SummonCreature(2008008, 1451269, 776708, 18896, 2755,
      SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
    herald2 = creature:SummonCreature(2008009, 1452872, 777346, 18897, 1846,
      SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)
    -- Text to announce the Heralds arriving
    for player in creature.PlayersInRange do
      player:SendLocalizeString("Heralds of Tzeentch arrive to bolster their lord!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
      player:SendLocalizeString("Heralds of Tzeentch arrive to bolster their lord!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    end
    -- Stage 12
  elseif currentStage == 11 and healthPercent < 20 then
    creature:SetState("STAGE", 12)
    creature:CastAbility(30372)
    for player in creature.PlayersInRange do
      player:SendLocalizeString("The Lord of Change Prepares a final attack!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
      player:SendLocalizeString("The Lord of Change Prepares a final attack! It's all or nothing now!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    end
  end

  -- Summon additional creatures based on health percentage thresholds
  for _, percent in ipairs(spawnThresholds) do
    if healthPercent <= nextSpawnPercent and nextSpawnPercent == percent then
      local location = RandomizeSummonLocation()
      local add1 = creature:SummonCreature(2008012, tonumber(location.x), tonumber(location.y), tonumber(location.z),
        tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                                         -- Exalted Flamer
      local add2 = creature:SummonCreature(2008010, tonumber(location.x), tonumber(location.y) + 50, tonumber(location.z),
        tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                                         -- Exalted Pink Horror
      local add3 = creature:SummonCreature(2008011, tonumber(location.x), tonumber(location.y) - 50, tonumber(location.z),
        tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                                         -- Exalted Blue Horror
      local add4 = creature:SummonCreature(2008011, tonumber(location.x), tonumber(location.y) + 100,
        tonumber(location.z), tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                   -- Exalted Blue Horror
      local add5 = creature:SummonCreature(2008010, tonumber(location.x), tonumber(location.y) - 100,
        tonumber(location.z), tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                   -- Exalted Pink Horror
      local add6 = creature:SummonCreature(2008013, tonumber(location.x), tonumber(location.y) + 150,
        tonumber(location.z), tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                   -- Exalted Screamer

      summonedAdds[#summonedAdds + 1] = add1
      summonedAdds[#summonedAdds + 1] = add2
      summonedAdds[#summonedAdds + 1] = add3
      summonedAdds[#summonedAdds + 1] = add4
      summonedAdds[#summonedAdds + 1] = add5
      summonedAdds[#summonedAdds + 1] = add6

      -- Set the next threshold
      for i, threshold in ipairs(spawnThresholds) do
        if nextSpawnPercent == threshold then
          if i < #spawnThresholds then
            nextSpawnPercent = spawnThresholds[i + 1]
          else
            nextSpawnPercent = 0           -- No more spawns
          end
          creature:SetState("NEXT_SPAWN_PERCENT", nextSpawnPercent)
          break
        end
      end

      break
    end
  end
end

-- Function to reset the Lord of Change and clean up summoned creatures and marks
local function LordReset(creature)
  -- Destroy all summoned adds
  for _, add in ipairs(summonedAdds) do
    if add then
      add:Destroy()
    end
  end
  summonedAdds = {}

  -- Destroy all chaos marks
  if chaosmark1 then
    chaosmark1:Destroy()
    chaosmark1 = nil
  end
  if chaosmark2 then
    chaosmark2:Destroy()
    chaosmark2 = nil
  end
  if chaosmark3 then
    chaosmark3:Destroy()
    chaosmark3 = nil
  end
  if chaosmark4 then
    chaosmark4:Destroy()
    chaosmark4 = nil
  end
  if chaosmark5 then
    chaosmark5:Destroy()
    chaosmark5 = nil
  end
  if chaosmark6 then
    chaosmark6:Destroy()
    chaosmark6 = nil
  end
  if chaosmark7 then
    chaosmark7:Destroy()
    chaosmark7 = nil
  end
  if chaosmark8 then
    chaosmark8:Destroy()
    chaosmark8 = nil
  end
  if chaosmark9 then
    chaosmark9:Destroy()
    chaosmark9 = nil
  end
  if chaosmark10 then
    chaosmark10:Destroy()
    chaosmark10 = nil
  end
  if chaosmark11 then
    chaosmark11:Destroy()
    chaosmark11 = nil
  end
  if chaosmark12 then
    chaosmark12:Destroy()
    chaosmark12 = nil
  end

  -- Destroy portal
  if portal then
    portal:Destroy()
    portal = nil
  end

  -- Destroy heralds
  if herald1 then
    herald1:Destroy()
    herald1 = nil
  end
  if herald2 then
    herald2:Destroy()
    herald2 = nil
  end

  -- Reset the creature's abilities or state as needed
  creature:CastAbility(30258)
  creature:CastAbility(30257)
  creature:CastAbility(30288)
  creature:CastAbility(30298)

  -- Reset creature's state
  creature:SetState("STAGE", 0)
  creature:SetState("NEXT_SPAWN_PERCENT", 96) -- Set this to your initial spawn percent threshold
end

RegisterCreatureScript(1000968, CreatureScript.OnReceiveDamage, LordOnReceiveDamage)
RegisterCreatureScript(1000968, CreatureScript.OnEnterCombat, LordOnEnterCombat)
RegisterCreatureScript(1000968, CreatureScript.OnLeaveCombat, LordReset)
RegisterCreatureScript(1000968, CreatureScript.OnDie, LordReset)

-- Chaos Mark OnDie scripts below here

-- Chaos Mark 1
local function chaosmark1OnDie(gameObject, player)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30257)
  end

  for player in gameObject.PlayersInRange do
    player:SendLocalizeString(
    "The Mark is destroyed, and the power of the Lord of Change falters! Beware, more will soon spawn!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
    player:SendLocalizeString(
    "The Mark is destroyed, and the power of the Lord of Change falters! Beware, more will soon spawn!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
  end
end

RegisterGameObjectScript(1758, GameObjectScript.OnDie, chaosmark1OnDie)

-- Chaos Mark 2
local function chaosmark2OnDie(gameObject)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30288)
  end
end

RegisterGameObjectScript(1757, GameObjectScript.OnDie, chaosmark2OnDie)

-- Chaos Mark 3
local function chaosmark3OnDie(gameObject)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30298)
  end
end

RegisterGameObjectScript(1759, GameObjectScript.OnDie, chaosmark3OnDie)

-- Chaos Mark 4
local function chaosmark4OnDie(gameObject)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30258)
  end
end

RegisterGameObjectScript(1760, GameObjectScript.OnDie, chaosmark4OnDie)

-- Chaos Mark 5 (Books but no text on death)
local function chaosmark5OnDie(gameObject)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30257)
  end
end

RegisterGameObjectScript(1761, GameObjectScript.OnDie, chaosmark5OnDie)

-- Chaos Mark 6 (Object in extra room)
local function chaosmark6OnDie(gameObject)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30257)
  end
end

RegisterGameObjectScript(1762, GameObjectScript.OnDie, chaosmark6OnDie)

-- Chaos Mark 7
local function chaosmark7OnDie(gameObject)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30257)
  end
end

RegisterGameObjectScript(1763, GameObjectScript.OnDie, chaosmark7OnDie)

-- Chaos Mark 8
local function chaosmark8OnDie(gameObject)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30257)
  end
end

RegisterGameObjectScript(1764, GameObjectScript.OnDie, chaosmark8OnDie)

-- Chaos Mark 9
local function chaosmark9OnDie(gameObject)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30288)
  end
end

RegisterGameObjectScript(1765, GameObjectScript.OnDie, chaosmark9OnDie)

-- Chaos Mark 10
local function chaosmark10OnDie(gameObject)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30298)
  end
end

RegisterGameObjectScript(1766, GameObjectScript.OnDie, chaosmark10OnDie)

-- Chaos Mark 11
local function chaosmark11OnDie(gameObject)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30257)
  end
end

RegisterGameObjectScript(1767, GameObjectScript.OnDie, chaosmark11OnDie)

-- Chaos Mark 12
local function chaosmark12OnDie(gameObject)
  local boss = gameObject:GetNearestCreature(12000, 1000968)

  if boss then
    boss:CastAbility(30258)
  end
end

RegisterGameObjectScript(1768, GameObjectScript.OnDie, chaosmark12OnDie)

-- Initialize the spawn locations at the start
ResetSpawnLocations()

-- Register the OnDie event to remove corpses immediately upon death
RegisterCreatureScript(2008012, CreatureScript.OnDie, SummonedCreatureOnDie)
RegisterCreatureScript(2008010, CreatureScript.OnDie, SummonedCreatureOnDie)
RegisterCreatureScript(2008011, CreatureScript.OnDie, SummonedCreatureOnDie)
RegisterCreatureScript(2008013, CreatureScript.OnDie, SummonedCreatureOnDie)

-- Change Log:
-- [07062024] Initial version -- Rubius, Gobtar and Emissary
-- [07062024] Added additional stages and updated spawn mechanics -- Emissary
-- [07062024] Improved randomization of spawn locations and fixed bugs in state handling -- Emissary
-- [07062024] Added the enrage mechanic to Chaos Mark 6. Also created the on die portions for the item and debuff activation -- Emissary

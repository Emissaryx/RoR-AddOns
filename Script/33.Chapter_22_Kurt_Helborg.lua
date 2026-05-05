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
local function KurtOnEnterCombat(creature, attacker)
  creature:SetState("STAGE", 0)
  creature:SetState("NEXT_SPAWN_PERCENT", 90) -- Change 0 to 90 closer to release
end

-- Initialization of variables and states
local summonedAdds = {}
-- Below is where it is the spawn thresholds that are called way below after all the stages
-- If you want to change when the 6 Champions spawn, this is the line below to do it health is checked on creature id# 1000968 (Lord of Change)
local spawnThresholds = { 90, 80, 70, 60, 50, 40, 30, 20, 10 }
-- called in ResetSpawnLocations
local spawnLocations = {
  { x = 1451005, y = 943512, z = 21614, o = 3369 }, -- #1 Left of Kurt Near fountain
  { x = 1452319, y = 944027, z = 21597, o = 3277 }, -- #2 On top of Stairs
  { x = 1453565, y = 942861, z = 21104, o = 3753 }, -- #3 Near Tents
  { x = 1454904, y = 944133, z = 21589, o = 602 }, -- #4 On top of hill behind destro spawning
  { x = 1454177, y = 943069, z = 20960, o = 528 } -- #5 In between Cannons in front of Kurt to his right
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
local function KurtOnReceiveDamage(creature, attacker, damage)
  -- Stage 0
  local currentStage = creature:GetState("STAGE")                  -- knows when to set the next stage
  local healthPercent = creature
  .HealthPercent                                                   -- watching the health percentage of the boss so the script knows when to work its magic
  local nextSpawnPercent = creature:GetState("NEXT_SPAWN_PERCENT") -- Used to keep track of the dmg on the boss so we know when our champs will be spawned

  -- Stage handling based on health percentages
  -- Stage 1
  if currentStage == 0 and healthPercent < 96 then
    creature:SetState("STAGE", 1)
    --chaosmark1 = creature:SpawnGameObject(1758, 1450009, 778008, 19619, 354)
    --creature:CastAbility(30285)
    --for player in creature.PlayersInRange do
    -- player:SendLocalizeString("Marks of Chaos begin to appear up the nearby stairs. The Lord grows stronger with each!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
    --player:SendLocalizeString("Marks of Chaos begin to appear up the nearby stairs. The Lord grows stronger with each!", SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    --end
  end

  -- Summon additional creatures based on health percentage thresholds
  for _, percent in ipairs(spawnThresholds) do
    if healthPercent <= nextSpawnPercent and nextSpawnPercent == percent then
      local location = RandomizeSummonLocation()
      local add1 = creature:SummonCreature(45633, tonumber(location.x), tonumber(location.y), tonumber(location.z),
        tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                                       -- Exalted Flamer
      local add2 = creature:SummonCreature(45633, tonumber(location.x), tonumber(location.y) + 50, tonumber(location.z),
        tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                                       -- Exalted Pink Horror
      local add3 = creature:SummonCreature(45633, tonumber(location.x), tonumber(location.y) - 50, tonumber(location.z),
        tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                                       -- Exalted Blue Horror
      local add4 = creature:SummonCreature(45633, tonumber(location.x), tonumber(location.y) + 100, tonumber(location.z),
        tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                                       -- Exalted Blue Horror
      local add5 = creature:SummonCreature(45633, tonumber(location.x), tonumber(location.y) - 100, tonumber(location.z),
        tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                                       -- Exalted Pink Horror
      local add6 = creature:SummonCreature(45633, tonumber(location.x), tonumber(location.y) + 150, tonumber(location.z),
        tonumber(location.o), SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN, 300000)                                                                                                                       -- Exalted Screamer

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
local function KurtReset(creature)
  -- Destroy all summoned adds
  for _, add in ipairs(summonedAdds) do
    if add then
      add:Destroy()
    end
  end
  summonedAdds = {}

  -- Reset creature's state
  creature:SetState("STAGE", 0)
  creature:SetState("NEXT_SPAWN_PERCENT", 96) -- Set this to your initial spawn percent threshold
end

RegisterCreatureScript(45629, CreatureScript.OnReceiveDamage, KurtOnReceiveDamage)
RegisterCreatureScript(45629, CreatureScript.OnEnterCombat, KurtOnEnterCombat)
RegisterCreatureScript(45629, CreatureScript.OnLeaveCombat, KurtReset)
RegisterCreatureScript(45629, CreatureScript.OnDie, KurtReset)

-- Initialize the spawn locations at the start
ResetSpawnLocations()

-- Register the OnDie event to remove corpses imme

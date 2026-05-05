-- Initialization of variables and states
local objectId = 100618
local creatureId = 35058
local abilityId = 27011

-- Function to get all players in range of the creature
local function getPlayersInRange(creature, range)
  local players = creature:GetPlayersInRange(range)
  return players
end

-- Function to cast the ability on all players in range
local function castAbilityOnPlayers(creature, abilityId)
  local players = getPlayersInRange(creature, 200)
  for _, player in ipairs(players) do
    creature:CastAbility(abilityId, player)
  end
end

-- Function to handle object death and cast ability if within range
local function checkAndCastOnObjectDeath(creature)
  local objects = creature:GetGameObjectsInRange(5000, objectId)
  if objects then
    for _, object in ipairs(objects) do
      local creatureInRange = object:GetNearestCreature(5000, creatureId)
      if creatureInRange then
        castAbilityOnPlayers(creatureInRange, abilityId)
      end
    end
  end
end

-- Function called when any instance of the specified game object dies
local function objectOnDie(gameObject, player)
  local creature = gameObject:GetNearestCreature(5000, creatureId)
  if creature then
    checkAndCastOnObjectDeath(creature)
  end
end

-- Function called when the creature receives damage
local function creatureOnReceiveDamage(creature, attacker, damage)
  -- Perform any necessary actions when the creature receives damage
end

-- Function to reset the creature when it leaves combat or dies
local function creatureReset(creature)
  -- Perform any necessary reset actions here
end

-- Function called when the creature dies
local function creatureOnDie(creature, killer)
  creatureReset(creature)
end

-- Register the game object's script for its death event
RegisterGameObjectScript(objectId, GameObjectScript.OnDie, objectOnDie)

-- Register the creature's scripts for different events
RegisterCreatureScript(creatureId, CreatureScript.OnReceiveDamage, creatureOnReceiveDamage)
RegisterCreatureScript(creatureId, CreatureScript.OnLeaveCombat, creatureReset)
RegisterCreatureScript(creatureId, CreatureScript.OnDie, creatureOnDie)

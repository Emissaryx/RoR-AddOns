-- Function to cast ability on all players in range
local function CastAbilityOnAllPlayers(creature, abilityId)
  local players = creature:GetPlayersInRange()
  if players then
    for _, player in ipairs(players) do
      creature:CastAbility(abilityId, player)
    end
  else
    d("No players in range.")
  end
end

-- Function to handle boss receiving damage and triggering the ability cast at specified thresholds
local function TestingDummyOnReceiveDamage(creature, attacker, damage)
  local healthPercent = creature:GetHealthPercent()
  local currentStage = creature:GetState("STAGE") -- keeps track of the current stage

  -- List of health thresholds to trigger the ability
  local thresholds = { 95, 90, 85, 80, 75, 70, 65, 60, 55, 50, 45, 40, 35, 30, 25, 20, 15, 10, 5 }

  for _, threshold in ipairs(thresholds) do
    if currentStage < threshold and healthPercent < threshold + 1 then
      creature:SetState("STAGE", threshold)
      CastAbilityOnAllPlayers(creature, 30271)
      break
    end
  end
end

-- Function called when the creature enters combat
local function TestingDummyOnEnterCombat(creature, attacker)
  creature:SetState("STAGE", 0)
end

-- Function to reset the boss and clean up states
local function TestingDummyOnReset(creature)
  creature:SetState("STAGE", 0)
end

-- Function called when the creature dies
local function TestingDummyOnDie(creature, killer)
  TestingDummyOnReset(creature)
end

-- Register the creature's scripts for different events
RegisterCreatureScript(900018, CreatureScript.OnReceiveDamage, TestingDummyOnReceiveDamage)
RegisterCreatureScript(900018, CreatureScript.OnEnterCombat, TestingDummyOnEnterCombat)
RegisterCreatureScript(900018, CreatureScript.OnLeaveCombat, TestingDummyOnReset)
RegisterCreatureScript(900018, CreatureScript.OnDie, TestingDummyOnDie)

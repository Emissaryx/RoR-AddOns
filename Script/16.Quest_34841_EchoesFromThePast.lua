local function OnInteractOrbOfAsur(gameObject, player)
  local currentVfxState = gameObject.VfxState;
  local newVfxState = currentVfxState + 1;

  -- 7 is the limit so if we hit 8 we need to set back to 1
  if (newVfxState == 8)
  then
    newVfxState = 1;
  end

  gameObject.VfxState = newVfxState;

  -- This is the correct one
  if (newVfxState == 6)
  then
    player.TriggerQuestObjective(34841, 1);
  end

  return true
end

RegisterGameObjectScript(99289, GameObjectScript.OnInteract, OnInteractOrbOfAsur)

local function OnInteractOrbOfMenlui(gameObject, player)
  local currentVfxState = gameObject.VfxState;
  local newVfxState = currentVfxState + 1;

  -- 7 is the limit so if we hit 8 we need to set back to 1
  if (newVfxState == 8)
  then
    newVfxState = 1;
  end

  gameObject.VfxState = newVfxState;

  -- This is the correct one
  if (newVfxState == 3)
  then
    player.TriggerQuestObjective(34841, 2);
  end

  return true
end

RegisterGameObjectScript(100071, GameObjectScript.OnInteract, OnInteractOrbOfMenlui)

local function OnInteractOrbOfShyish(gameObject, player)
  local currentVfxState = gameObject.VfxState;
  local newVfxState = currentVfxState + 1;

  -- 7 is the limit so if we hit 8 we need to set back to 1
  if (newVfxState == 8)
  then
    newVfxState = 1;
  end

  gameObject.VfxState = newVfxState;

  -- This is the correct one
  if (newVfxState == 2)
  then
    player.TriggerQuestObjective(34841, 3);
  end

  return true
end

RegisterGameObjectScript(99290, GameObjectScript.OnInteract, OnInteractOrbOfShyish)

local function OnInteractOrbOfCadaith(gameObject, player)
  local currentVfxState = gameObject.VfxState;
  local newVfxState = currentVfxState + 1;

  -- 7 is the limit so if we hit 8 we need to set back to 1
  if (newVfxState == 8)
  then
    newVfxState = 1;
  end

  gameObject.VfxState = newVfxState;

  -- This is the correct one
  if (newVfxState == 7)
  then
    player.TriggerQuestObjective(34841, 4);
  end

  return true
end

RegisterGameObjectScript(10106, GameObjectScript.OnInteract, OnInteractOrbOfCadaith)

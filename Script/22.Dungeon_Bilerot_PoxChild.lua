-- Pox Bloated Child

local function PoxOnEnterCombat(creature, attacker)
  creature:SetState("STAGE", 0);
end

local Grandfatherstone = nil
local Poxchildporridge = nil
local Bigstone = nil

local function PoxOnReceiveDamage(creature, attacker, damage)
  local currentStage = creature:GetState("STAGE")

  if currentStage == 0 and creature.HealthPercent < 60
  then
    creature:SetState("STAGE", 1)
    Grandfatherstone = creature:SpawnGameObject(1752, 1495407, 1044515, 10487, 3169)
    creature:CastAbility(30256)

    for player in creature.PlayersInRange
    do
      player:SendLocalizeString(
      "The Pox-Bloated Child gains power from a nearby Blessing of Nurgle! Find and destroy it!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
      player:SendLocalizeString(
      "The Pox-Bloated Child gains power from a nearby Blessing of Nurgle! Find and destroy it!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    end
  elseif currentStage == 1 and creature.HealthPercent < 40
  then
    creature:SetState("STAGE", 2)
    Poxchildporridge = creature:SpawnGameObject(1751, 1499298, 1044472, 10491, 922)
    creature:CastAbility(30255)

    for player in creature.PlayersInRange
    do
      player:SendLocalizeString(
      "The sickly-sweet smell of nearby Porridge empowers the child... his incoming damage is reduced!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
      player:SendLocalizeString(
      "The sickly-sweet smell of nearby Porridge empowers the child... his incoming damage is reduced!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    end
  elseif currentStage == 2 and creature.HealthPercent < 20
  then
    creature:SetState("STAGE", 3)
    Bigstone = creature:SpawnGameObject(1753, 1497394, 1042425, 10486, 4051)
    creature:CastAbility(30255)
    creature:CastAbility(30256)

    for player in creature.PlayersInRange
    do
      player:SendLocalizeString(
      "Nurgle blesses his Child with a special stone that empowers him fully! Destroy it, quickly!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
      player:SendLocalizeString(
      "Nurgle blesses his Child with a special stone that empowers him fully! Destroy it, quickly!",
        SystemData.ChatLogFilters.CHATLOGFILTERS_CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
    end
  end
end

local function PoxReset(creature)
  if Grandfatherstone
  then
    Grandfatherstone.Destroy()
    Grandfatherstone = nil
  end
  if Poxchildporridge
  then
    Poxchildporridge.Destroy()
    Poxchildporridge = nil
  end
  if Bigstone
  then
    Bigstone.Destroy()
    Bigstone = nil
  end
  creature:CastAbility(30258)
  creature:CastAbility(30257)
end


RegisterCreatureScript(9989, CreatureScript.OnReceiveDamage, PoxOnReceiveDamage)
RegisterCreatureScript(9989, CreatureScript.OnEnterCombat, PoxOnEnterCombat)
RegisterCreatureScript(9989, CreatureScript.OnLeaveCombat, PoxReset)
RegisterCreatureScript(9989, CreatureScript.OnDie, PoxReset)

-- Grandfatherstone

local function GrandfatherstoneOnDie(gameObject, player)
  local boss = gameObject.GetNearestCreature(24000, 9989)

  if boss
  then
    boss.CastAbility(30257)
  end

  for player in gameObject.PlayersInRange
  do
    player:SendLocalizeString("With the stone destroyed, The Pox-Bloated Child loses his growing power!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
  end
end

RegisterGameObjectScript(1752, GameObjectScript.OnDie, GrandfatherstoneOnDie)

-- Poxchildporridge

local function PoxchildporridgeOnDie(gameObject)
  local boss = gameObject.GetNearestCreature(24000, 9989)

  if boss
  then
    boss.CastAbility(30258)
  end

  for player in gameObject.PlayersInRange
  do
    player:SendLocalizeString(
    "The Porridge is tipped to the ground, and the Pox-Bloated Child loses his damage reduction!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
  end
end

RegisterGameObjectScript(1751, GameObjectScript.OnDie, PoxchildporridgeOnDie)

-- Bigstone

local function BigstoneOnDie(gameObject)
  local boss = gameObject.GetNearestCreature(24000, 9989)

  if boss
  then
    boss.CastAbility(30258)
    boss.CastAbility(30257)
  end


  for player in gameObject.PlayersInRange
  do
    player:SendLocalizeString("Nurgle's Final Boon is destroyed! Finish the fight!",
      SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
  end
end

RegisterGameObjectScript(1753, GameObjectScript.OnDie, BigstoneOnDie)

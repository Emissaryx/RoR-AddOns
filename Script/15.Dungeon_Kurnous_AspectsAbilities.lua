local function TransformWolf(caster, target, values)
  caster:PlayEffect(1451)    -- BOSS_WHUNT_Transform
  caster:UnEquipItem(10)     -- MainHand
  caster.Model = 1781        -- CRE_Wolf_WH_Elite
  caster:SetAbilitySet(1651) -- Wolf
end

local function TransformLion(caster, target, values)
  caster:PlayEffect(1451)    -- BOSS_WHUNT_Transform
  caster:UnEquipItem(10)     -- MainHand
  caster.Model = 1785        -- CRE_Wlion_Male_Elite
  caster:SetAbilitySet(1652) -- Lion
end

local function TransformHound(caster, target, values)
  caster:PlayEffect(1451)    -- BOSS_WHUNT_Transform
  caster:UnEquipItem(10)     -- MainHand
  caster.Model = 1779        -- CRE_Hound_WH_Elite
  caster:SetAbilitySet(1653) -- Hound
end

RegisterServerCommandScript(32, 41800, ServerCommandTrigger.Start, TransformWolf)
RegisterServerCommandScript(32, 41802, ServerCommandTrigger.Start, TransformLion)
RegisterServerCommandScript(32, 41804, ServerCommandTrigger.Start, TransformHound)

local function OnCalllOfTheWildWolf(caster, target, values)
  caster:Say("Kurnous summons forth a Hallow Wolf", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_EMOTE,
    Localized_text.CHAT_TAG_DEFAULT)
  caster:SummonCreature(2001871, caster.X, caster.Y, caster.Z, caster.O, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN,
    300000)
end

local function OnCalllOfTheWildLion(caster, target, values)
  caster:Say("Kurnous summons forth a Hallow Lion", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_EMOTE,
    Localized_text.CHAT_TAG_DEFAULT)
  caster:SummonCreature(2000746, caster.X, caster.Y, caster.Z, caster.O, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN,
    300000)
end
local function OnCalllOfTheWildHound(caster, target, values)
  caster:Say("Kurnous summons forth a Hallow Hound", SystemData.ChatLogFilters.CHATLOGFILTERS_MONSTER_EMOTE,
    Localized_text.CHAT_TAG_DEFAULT)
  caster:SummonCreature(2000745, caster.X, caster.Y, caster.Z, caster.O, SummonType.TEMPSUMMON_TIMED_OR_CORPSE_DESPAWN,
    300000)
end

RegisterServerCommandScript(32, 41801, ServerCommandTrigger.Start, OnCalllOfTheWildWolf)
RegisterServerCommandScript(32, 41803, ServerCommandTrigger.Start, OnCalllOfTheWildLion)
RegisterServerCommandScript(32, 41805, ServerCommandTrigger.Start, OnCalllOfTheWildHound)

local function OnCalllOfTheWild2(caster, target, values)
  caster:PlayEffect(1451)    -- BOSS_WHUNT_Transform
  caster:EquipItem(10, 8305) -- MainHand - NPC_KurnousSpear_01
  caster.Model = 1783        -- CRE_Kurnous_01
  caster:SetAbilitySet(1650) -- Base
end

RegisterServerCommandScript(32, 41806, ServerCommandTrigger.Start, OnCalllOfTheWild2)

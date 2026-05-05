--[[
  Crafting Info Tooltip v1.50

  Crafting Info Tooltip (CraftValueTip) is an addon for
  Warhammer: Age of Reckoning which displays the hidden stats on
  crafting items as part of the tooltip.

  This file, CraftInfoAPI.lua, defines functions that any addon can use
  to get information about crafting items.
]]--

-- API version info
local API_VERSION        = 1.50
local API_BACKWARDS_FROM = 1.40   -- Earliest version this is fully backward compatible with

CraftItemInfo = {}

-- Map bonus names to indices for readability
CraftItemInfo.bonus = {
  STABILITY        = 1,
  POWER            = 2,
  DURATION         = 3,
  MULTIPLIER       = 4,
  CRAFTING_FAMILY  = 5,
  EFFECT           = 6,
  SLOTS            = 7,
  TYPE             = 8,
  CRAFTING_LEVEL   = 9,
  GROW_TIME        = 10,
  YIELD            = 11,
  CRITICAL_CHANCE  = 12,
  FAIL_CHANCE      = 13,
  SPECIAL_CHANCE   = 14,
  DESTROY_ON_FAIL  = 15,
}

local BONUS         = CraftItemInfo.bonus
local GetPhrase     = CraftValueTip.GetPhrase
local SeedList      = CraftValueTip.SeedList
local ApothEffects  = CraftValueTip.ApothEffectList
local ApothTiers    = CraftValueTip.ApothEffectTier
local TalisEffects  = CraftValueTip.TalEffectList
local TalisTiers    = CraftValueTip.TalEffectTier
local BrokenItems   = CraftValueTip.BrokenItems

local function ShOut(str)
  if str then
    EA_ChatWindow.Print(towstring(str))
  end
end

---------------------------------------------------------------------------
-- Version helpers
---------------------------------------------------------------------------

function CraftItemInfo.GetVersion()
  return API_VERSION
end

-- nMinAware: minimum API version the caller knows
-- nMaxAware: maximum API version the caller knows
-- Returns: true if this API is compatible with the caller's version range
function CraftItemInfo.CheckVersion(nMinAware, nMaxAware)
  if API_VERSION < nMinAware then
    return false
  end

  if API_BACKWARDS_FROM > nMaxAware then
    return false
  end

  return true
end

---------------------------------------------------------------------------
-- Internal helper for broken items
---------------------------------------------------------------------------

function CraftItemInfo.getBrokenItem(itemData)
  if not itemData or not itemData.uniqueID then
    return nil
  end
  return BrokenItems[itemData.uniqueID]
end

---------------------------------------------------------------------------
-- Core bonus extraction
---------------------------------------------------------------------------

-- Returns: table indexed by bonus number, each entry is an array of values
function CraftItemInfo.GetItemBonuses(itemData)
  local result = {}

  -- No bonuses
  if type(itemData) ~= "table" or type(itemData.craftingBonus) ~= "table" then
    return result
  end

  -- Use cached result if present
  if itemData.CraftItemInfo then
    return DataUtils.CopyTable(itemData.CraftItemInfo)
  end

  -- Fold craftingBonus entries into a more usable structure
  for _, v in pairs(itemData.craftingBonus) do
    if v and v.bonusReference and v.bonusValue then
      if not result[v.bonusReference] then
        result[v.bonusReference] = {}
      end

      -- Stored as unsigned 16 bit, convert to signed
      local val = v.bonusValue
      if val > 32767 then
        val = val - 65536
      end

      table.insert(result[v.bonusReference], val)
    end
  end

  -- Broken item support
  local brokenItem = CraftItemInfo.getBrokenItem(itemData)
  if brokenItem then
    if result[BONUS.EFFECT] then
      -- This broken item was already "fixed" and now has a real effect
      ShOut("Broken item has been fixed and needs to be removed: " .. tostring(itemData.uniqueID))
    else
      for bonusIndex, val in pairs(brokenItem) do
        result[bonusIndex] = result[bonusIndex] or {}
        table.insert(result[bonusIndex], val)
      end
    end
  end

  -- Cache the computed bonuses on the item
  itemData.CraftItemInfo = DataUtils.CopyTable(result)

  return result
end

---------------------------------------------------------------------------
-- Item family (crafting skill that uses this item)
---------------------------------------------------------------------------

function CraftItemInfo.GetItemFamily(itemData)
  local data = CraftItemInfo.GetItemBonuses(itemData)
  local out  = nil
  local hasCultivation = false

  if data[BONUS.CRAFTING_FAMILY] then
    for _, v in ipairs(data[BONUS.CRAFTING_FAMILY]) do
      if v == GameData.TradeSkills.CULTIVATION then
        hasCultivation = true
      end

      local profKey = "prof" .. tostring(v)
      local phrase  = GetPhrase("Prof", profKey)

      if phrase then
        if out then
          out = out .. GetString(StringTables.Default.SYMBOL_LIST_SEPARATOR) .. phrase
        else
          out = phrase
        end
      end
    end
  end

  -- Cultivation sometimes does not appear in craftingBonus
  if itemData.cultivationType and itemData.cultivationType > 0 and not hasCultivation then
    local cultKey = "prof" .. tostring(GameData.TradeSkills.CULTIVATION)
    local cultStr = GetPhrase("Prof", cultKey)

    if cultStr then
      if out then
        out = out .. GetString(StringTables.Default.SYMBOL_LIST_SEPARATOR) .. cultStr
      else
        out = cultStr
      end
    end
  end

  if not out then
    out = L""
  end

  return out
end

---------------------------------------------------------------------------
-- Required crafting skill level
---------------------------------------------------------------------------

function CraftItemInfo.GetItemLevelReq(itemData)
  local data = CraftItemInfo.GetItemBonuses(itemData)

  if data[BONUS.CRAFTING_LEVEL] and data[BONUS.CRAFTING_LEVEL][1] then
    return data[BONUS.CRAFTING_LEVEL][1]
  end

  return itemData.craftingSkillRequirement
end

---------------------------------------------------------------------------
-- Item type (localized)
---------------------------------------------------------------------------

function CraftItemInfo.GetItemType(itemData)
  local sTemp = nil

  -- Cultivation type first
  if itemData.cultivationType and itemData.cultivationType > 0 then
    sTemp = GetPhrase("ItemTypes", "cult" .. tostring(itemData.cultivationType), nil, nil, nil, nil, true)
  end

  if not sTemp then
    local data = CraftItemInfo.GetItemBonuses(itemData)
    if data[BONUS.TYPE] and data[BONUS.TYPE][1] then
      sTemp = GetPhrase("ItemTypes", "item" .. tostring(data[BONUS.TYPE][1]), nil, nil, nil, nil, true)
    end
  end

  if not sTemp then
    sTemp = L""
  end

  return sTemp
end

---------------------------------------------------------------------------
-- Item effect (localized)
---------------------------------------------------------------------------

function CraftItemInfo.GetItemEffect(itemData, bNoGrowsPrefix)
  local sTemp
  local data

  -- Cultivation items
  if itemData.cultivationType and itemData.cultivationType > 0 then
    local seedInfo = SeedList[itemData.uniqueID]
    if not seedInfo then
      return L""
    end

    -- seedInfo layout: [1]=type ("std"/...), [2]=isMainIngredient?, [3]=phrase key, [4]=plantID, [5]=pigmentID
    if seedInfo[2] then
      -- Not a main ingredient, show type
      sTemp = GetPhrase("ItemTypes", seedInfo[3])
    else
      -- Main ingredient, show effect
      sTemp = GetPhrase("EffectNames", seedInfo[3])
    end

    if bNoGrowsPrefix then
      return sTemp
    else
      return GetPhrase("Format", "grows", sTemp)
    end
  end

  -- Non cultivation, use crafting bonuses
  data = CraftItemInfo.GetItemBonuses(itemData)
  if data[BONUS.EFFECT] and data[BONUS.CRAFTING_FAMILY] then
    local effectId = data[BONUS.EFFECT][1]
    local family   = data[BONUS.CRAFTING_FAMILY][1]

    if family == GameData.TradeSkills.APOTHECARY and ApothEffects[effectId] then
      sTemp = GetPhrase("EffectNames", ApothEffects[effectId])

      if ApothTiers[effectId] then
        sTemp = GetPhrase("EffectTiers", "tier" .. ApothTiers[effectId], sTemp)
      end

    elseif family == GameData.TradeSkills.TALISMAN and TalisEffects[effectId] then
      sTemp = GetPhrase("EffectNames", TalisEffects[effectId])

      if TalisTiers[effectId] then
        sTemp = GetPhrase("EffectTiers", "tier" .. TalisTiers[effectId], sTemp)
      end

    else
      -- Unknown effect, show raw ID
      sTemp = GetPhrase("Format", "effect", towstring(effectId))
    end

    return sTemp
  end

  return L""
end

---------------------------------------------------------------------------
-- Effect or type
---------------------------------------------------------------------------

function CraftItemInfo.GetItemEffectOrType(itemData, bNoGrowsPrefix)
  local sTemp = CraftItemInfo.GetItemEffect(itemData, bNoGrowsPrefix)

  if sTemp == L"" then
    sTemp = CraftItemInfo.GetItemType(itemData)
  end

  return sTemp
end

---------------------------------------------------------------------------
-- Bonus names and formatting
---------------------------------------------------------------------------

function CraftItemInfo.GetBonusName(nBonusNumber)
  local key   = "bonus" .. tostring(nBonusNumber)
  local sTemp = GetPhrase("Bonuses", key, nil, nil, nil, nil, true)

  if not sTemp then
    sTemp = GetPhrase("Format", "bonus", towstring(nBonusNumber))
  end

  return sTemp
end

-- Returns:
-- 1) formatted localized wstring
-- 2) comment type:
--    0 = normal
--    1 = low priority / optional
--    2 = unknown
--    3 = better retrieved via other functions (family, type, effect)
function CraftItemInfo.FormatBonus(nBonusNumber, nBonusValue)
  local name = CraftItemInfo.GetBonusName(nBonusNumber)
  local sTemp

  if nBonusNumber == BONUS.CRAFTING_FAMILY then
    local profKey = "prof" .. tostring(nBonusValue)
    local profStr = GetPhrase("Prof", profKey, nil, nil, nil, nil, true)

    if profStr then
      sTemp = name .. L" " .. profStr
    else
      sTemp = name .. L" " .. towstring(nBonusValue)
    end
    return sTemp, 3

  elseif nBonusNumber == BONUS.TYPE then
    local typeKey = "item" .. tostring(nBonusValue)
    local typeStr = GetPhrase("ItemTypes", typeKey, nil, nil, nil, nil, true)

    if typeStr then
      sTemp = name .. L" " .. typeStr
    else
      sTemp = name .. L" " .. towstring(nBonusValue)
    end
    return sTemp, 3

  elseif nBonusNumber == BONUS.CRAFTING_LEVEL
      or nBonusNumber == BONUS.EFFECT then
    sTemp = name .. L" " .. towstring(nBonusValue)
    return sTemp, 3

  elseif nBonusNumber == BONUS.SLOTS then
    sTemp = towstring(nBonusValue) .. L" " .. name
    return sTemp, 1

  elseif nBonusNumber == BONUS.DESTROY_ON_FAIL then
    if nBonusValue == 0 then
      return L"", 1
    else
      return name, 1
    end

  elseif nBonusNumber == BONUS.GROW_TIME then
    -- Inverted percent: negative is actually positive reduction
    if nBonusValue <= 0 then
      sTemp = L"+" .. -towstring(nBonusValue) .. L"% " .. name
    else
      sTemp = L"" .. -towstring(nBonusValue) .. L"% " .. name
    end
    return sTemp, 0

  elseif nBonusNumber == BONUS.CRITICAL_CHANCE
      or nBonusNumber == BONUS.SPECIAL_CHANCE
      or nBonusNumber == BONUS.FAIL_CHANCE then
    if nBonusValue < 0 then
      sTemp = towstring(nBonusValue) .. L"% " .. name
    else
      sTemp = L"+" .. towstring(nBonusValue) .. L"% " .. name
    end
    return sTemp, 0

  else
    -- Normal numeric bonus
    if nBonusValue < 0 then
      sTemp = towstring(nBonusValue) .. L" " .. name
    else
      sTemp = L"+" .. towstring(nBonusValue) .. L" " .. name
    end

    local known = GetPhrase("Bonuses", "bonus" .. tostring(nBonusNumber), nil, nil, nil, nil, true)
    if known then
      return sTemp, 0
    else
      return sTemp, 2
    end
  end
end

---------------------------------------------------------------------------
-- Seed / plant / pigment relationships
---------------------------------------------------------------------------

function CraftItemInfo.GetPlantFromSeed(seedID)
  local info = SeedList[seedID]
  if info then
    local plantId      = info[4] or 0
    local reapsToSeed  = (info[1] == "std")
    return plantId, reapsToSeed
  end

  return 0, false
end

function CraftItemInfo.GetPigmentFromSeed(seedID)
  local info = SeedList[seedID]
  if info then
    return info[5] or 0
  end
  return 0
end

function CraftItemInfo.GetSeedFromPlant(plantID)
  for k, v in pairs(SeedList) do
    if v[4] == plantID and v[1] == "std" then
      return k
    end
  end
  return 0
end

function CraftItemInfo.GetSeedsToProduce(uniqueID)
  local result = {}

  for seedId, v in pairs(SeedList) do
    if v[4] == uniqueID or v[5] == uniqueID then
      table.insert(result, seedId)
    end
  end

  return result
end

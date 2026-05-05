--[[
  Crafting Info Tooltip v1.51

  Crafting Info Tooltip (CraftValueTip) is an addon for Warhammer: Age of
  Reckoning which displays the hidden stats on crafting items as part of the
  tooltip.
]]--



CraftValueTip = {}

CraftValueTip.version = 1.51

-- Phrase table (T for text)
CraftValueTip.T = {}

-- Default settings
CraftValueTip.defaultSettings = {
  enable    = true,
  debug     = false,
  language  = 0,
  seedplant = true,
  seeddye   = true,
}

local function ShOut(str)
  if str then
    EA_ChatWindow.Print(towstring(str))
  end
end

---------------------------------------------------------------------------
-- Initialization and shutdown
---------------------------------------------------------------------------

function CraftValueTip.Initialize()
  if not CraftValueTip.settings then
    CraftValueTip.settings = {}
    for k, v in pairs(CraftValueTip.defaultSettings) do
      CraftValueTip.settings[k] = v
    end
  end

  CraftValueTip.SetLanguage(CraftValueTip.settings.language)

  -- Load LibSlash and register commands
  CraftValueTip.LoadAddon("LibSlash")
  if LibSlash then
    LibSlash.RegisterWSlashCmd(
      "craftvaluetip",
      function(args) CraftValueTip.SlashCmd(args) end
    )
    EA_ChatWindow.Print(
      CraftValueTip.T[CraftValueTip.Language].Messages["Greeting"]
    )
  end

  -- Load the crafting database if desired
  -- CraftValueTip.LoadAddon("Crafting DB")

  -- Hook the tooltip processing function
  CraftValueTip.OldFunc = Tooltips.SetItemTooltipData
  Tooltips.SetItemTooltipData = CraftValueTip.SetItemTooltipData

  CraftValueTip.InitConfig()

  -- Copy some phrases for compatibility with older addons that depend on CIT
  for _, localeTable in pairs(CraftValueTip.T) do
    localeTable.ItemTypes.prof3 = {}
    localeTable.ItemTypes.prof4 = {}
    localeTable.ItemTypes.prof5 = localeTable.ItemTypes.prof4

    for key, value in pairs(localeTable.ItemTypes) do
      if type(value) == "wstring" then
        if string.sub(key, 1, 4) == "cult" then
          localeTable.ItemTypes.prof3["item" .. string.sub(key, 5)] = value
        else
          localeTable.ItemTypes.prof4[key] = value
        end
      end
    end

    localeTable.Prof.prof0 = localeTable.Prof.prof6
  end

--[[
  -- If we have the crafting database, hook CreateItemTooltip to add comparison tips
  if CraftDB then
    CraftValueTip.OldCreateTT = Tooltips.CreateItemTooltip
    Tooltips.CreateItemTooltip = CraftValueTip.NewCreateTT
    -- Create comparison windows
    CreateWindow("CraftValueTipCompare", false)
  end
]]--
end

function CraftValueTip.Shutdown()
  if CraftValueTip.OldFunc then
    Tooltips.SetItemTooltipData = CraftValueTip.OldFunc
  end
end

---------------------------------------------------------------------------
-- Language and phrases
---------------------------------------------------------------------------

function CraftValueTip.SetLanguage(langId)
  -- 0 means use game default
  if langId == 0 then
    langId = SystemData.Settings.Language.active
  end

  -- First try specifically requested language
  if CraftValueTip.T[langId] then
    CraftValueTip.Language = langId
    CraftValueTip.vLocal   = CraftValueTip.T[langId]
    return true

  -- Then try current game language
  elseif CraftValueTip.T[SystemData.Settings.Language.active] then
    CraftValueTip.Language = SystemData.Settings.Language.active
    CraftValueTip.vLocal   = CraftValueTip.T[CraftValueTip.Language]
    return false

  -- Fall back to English
  else
    CraftValueTip.Language = 1
    CraftValueTip.vLocal   = CraftValueTip.T[CraftValueTip.Language]
    return false
  end
end

-- sType:       phrase category (Messages, ItemTypes, Prof, etc)
-- sPhraseName: key within that category
-- sSlot1...4:  optional replacements for {1}..{4}
-- bIgnore:     if true, return nil on missing phrase; otherwise log and return L""
function CraftValueTip.GetPhrase(
  sType,
  sPhraseName,
  sSlot1,
  sSlot2,
  sSlot3,
  sSlot4,
  bIgnore
)
  local locale = CraftValueTip.vLocal
  if not locale or not locale[sType] or not locale[sType][sPhraseName] then
    if bIgnore then
      return nil
    else
      d("CraftValueTip: Unknown phrase: " .. tostring(sType) .. "." .. tostring(sPhraseName))
      return L""
    end
  end

  local result = locale[sType][sPhraseName]

  if sSlot1 then
    result = wstring.gsub(result, L"{1}", towstring(sSlot1))
  end
  if sSlot2 then
    result = wstring.gsub(result, L"{2}", towstring(sSlot2))
  end
  if sSlot3 then
    result = wstring.gsub(result, L"{3}", towstring(sSlot3))
  end
  if sSlot4 then
    result = wstring.gsub(result, L"{4}", towstring(sSlot4))
  end

  return result
end

---------------------------------------------------------------------------
-- Module loader
---------------------------------------------------------------------------

function CraftValueTip.LoadAddon(modName)
  if not modName then return end

  local modules = ModulesGetData()
  for _, mod in ipairs(modules) do
    if mod.name == modName then
      if mod.isEnabled and not mod.isLoaded then
        ModuleInitialize(mod.name)
      end
      return
    end
  end
end

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------

function CraftValueTip.SlashCmd(args)
  if args == L"off" then
    ShOut(CraftValueTip.GetPhrase("Messages", "TipOff"))
    CraftValueTip.settings.enable = false

  elseif args == L"on" then
    ShOut(CraftValueTip.GetPhrase("Messages", "TipOn"))
    CraftValueTip.settings.enable = true

  elseif args == L"dev on" then
    ShOut(CraftValueTip.GetPhrase("Messages", "DebugOn"))
    CraftValueTip.settings.debug = true

  elseif args == L"dev off" then
    ShOut(CraftValueTip.GetPhrase("Messages", "DebugOff"))
    CraftValueTip.settings.debug = false

--[[
  elseif args == L"seed off" then
    ShOut(CraftValueTip.GetPhrase("Messages", "SeedPlantOff"))
    ShOut(CraftValueTip.GetPhrase("Messages", "SeedDyeOff"))
    CraftValueTip.settings.seedplant = false
    CraftValueTip.settings.seeddye   = false

  elseif args == L"seed plant" then
    ShOut(CraftValueTip.GetPhrase("Messages", "SeedPlantOn"))
    ShOut(CraftValueTip.GetPhrase("Messages", "SeedDyeOff"))
    CraftValueTip.settings.seedplant = true
    CraftValueTip.settings.seeddye   = false

  elseif args == L"seed pigment" then
    ShOut(CraftValueTip.GetPhrase("Messages", "SeedPlantOff"))
    ShOut(CraftValueTip.GetPhrase("Messages", "SeedDyeOn"))
    CraftValueTip.settings.seedplant = false
    CraftValueTip.settings.seeddye   = true

  elseif args == L"seed both" then
    ShOut(CraftValueTip.GetPhrase("Messages", "SeedPlantOn"))
    ShOut(CraftValueTip.GetPhrase("Messages", "SeedDyeOn"))
    CraftValueTip.settings.seedplant = true
    CraftValueTip.settings.seeddye   = true
]]--

  elseif args == L"dump" then
    if CraftValueTip.LastItem then
      CraftValueTip.CraftDump(CraftValueTip.LastItem)
    end

  elseif args == L"digest" then
    if CraftValueTip.LastItem then
      CraftValueTip.ItemDump(CraftValueTip.LastItem)
    end

  elseif args == L"lookup" then
    if CraftValueTip.LastItem then
      CraftValueTip.LookUpDump(CraftValueTip.LastItem)
    end

  elseif args == L"obj" then
    if CraftValueTip.LastItem then
      CraftValueTip.DumpObjInspector()
    end

  elseif not args or args == L"" then
    CraftValueTip.DoConfig()

  else
    ShOut(CraftValueTip.GetPhrase("Messages", "List0"))
    ShOut(CraftValueTip.GetPhrase("Messages", "List1"))
    ShOut(CraftValueTip.GetPhrase("Messages", "List2"))
    ShOut(CraftValueTip.GetPhrase("Messages", "List3"))
    ShOut(CraftValueTip.GetPhrase("Messages", "List4"))
    ShOut(CraftValueTip.GetPhrase("Messages", "List5"))
    ShOut(CraftValueTip.GetPhrase("Messages", "List6"))
    -- ShOut(CraftValueTip.GetPhrase("Messages","List7"))
  end
end

---------------------------------------------------------------------------
-- Tooltip logic
---------------------------------------------------------------------------

-- Compute data for tooltip
function CraftValueTip.SetItemTooltipData(windowName, itemData, extraText, extraTextColor)
  -- Save itemData for debug dumps and object inspector
  CraftValueTip.LastItem = itemData

  -- Only proceed if this looks like a crafting item
  if CraftValueTip.settings.enable
     and itemData
     and itemData.craftingBonus
     and itemData.craftingBonus[1]
  then
    local vBonuses = CraftItemInfo.GetItemBonuses(itemData)
    local vStats   = {}
    local sType    = nil
    local vTemp
    local nInfo

    -- Build the type line: "<levelReq> <family> - <type>"
    local levelReq = CraftItemInfo.GetItemLevelReq(itemData)
    sType = towstring(levelReq) .. L" " .. CraftItemInfo.GetItemFamily(itemData)

    vTemp = CraftItemInfo.GetItemType(itemData)
    if vTemp ~= L"" then
      sType = sType .. L" - " .. vTemp
    end

    -- Effect line (if any)
    vTemp = CraftItemInfo.GetItemEffect(itemData)
    if vTemp ~= L"" then
      table.insert(vStats, vTemp)
    end

    -- First pass: preferred bonuses
    for _, bonusId in ipairs(CraftValueTip.BonusPreference) do
      local bonusList = vBonuses[bonusId]
      if bonusList and bonusList[1] ~= nil then
        vTemp, nInfo = CraftItemInfo.FormatBonus(bonusId, bonusList[1])
        if vTemp ~= L"" then
          if ((nInfo == 0) and (bonusList[1] ~= 0))
             or ((nInfo < 2) and CraftValueTip.settings.debug)
          then
            table.insert(vStats, vTemp)
          end
        end
        if nInfo ~= 2 then
          bonusList[1] = nil
        end
      end
    end

    -- Second pass: first value of any remaining bonuses
    for bonusId, values in pairs(vBonuses) do
      if values[1] ~= nil then
        vTemp, nInfo = CraftItemInfo.FormatBonus(bonusId, values[1])
        if vTemp ~= L"" then
          if ((nInfo == 0) and (values[1] ~= 0))
             or ((nInfo < 2) and CraftValueTip.settings.debug)
          then
            table.insert(vStats, vTemp)
          end
        end
        if nInfo ~= 2 then
          values[1] = nil
        end
      end
    end

    -- Third pass: everything else, including duplicates
    for bonusId, values in pairs(vBonuses) do
      for idx, value in pairs(values) do
        vTemp, nInfo = CraftItemInfo.FormatBonus(bonusId, value)
        if idx > 1 then
          vTemp = L"#" .. idx .. L"> " .. vTemp
        end
        if vTemp ~= L"" then
          if ((nInfo == 2) and (idx == 1)) or CraftValueTip.settings.debug then
            table.insert(vStats, vTemp)
          end
        end
      end
    end

    -- Call the original tooltip builder
    local result = CraftValueTip.OldFunc(windowName, itemData, extraText, extraTextColor)

    -- Add our custom stat lines
    CraftValueTip.SetTooltipStats(windowName, vStats)

    -- Update type label text and window size
    if sType then
      local _, oldTypeHeight = WindowGetDimensions(windowName .. "Type")
      LabelSetText(windowName .. "Type", sType)
      local _, newTypeHeight = WindowGetDimensions(windowName .. "Type")

      local typeDelta = newTypeHeight - oldTypeHeight
      local winWidth, winHeight = WindowGetDimensions(windowName)
      WindowSetDimensions(windowName, winWidth, winHeight + typeDelta)
    end

    return result
  end

  -- Not a crafting item or disabled
  return CraftValueTip.OldFunc(windowName, itemData, extraText, extraTextColor)
end

-- Add stat lines after tooltip is created
function CraftValueTip.SetTooltipStats(windowName, statLines)
  local count  = 0
  local height = 5
  local width  = 0

  for _, text in ipairs(statLines) do
    count = count + 1
    local labelName = windowName .. "StatBonus" .. count .. "Text"
    local container = windowName .. "StatBonus" .. count

    LabelSetText(labelName, text)

    -- Optional color logic for negative values
    -- if wstring.byte(text) == wstring.byte(L"-") then
    --   LabelSetTextColor(labelName, 255, 0, 0)
    -- end

    local _, rowHeight = WindowGetDimensions(container)
    height = height + rowHeight

    local textWidth, _ = LabelGetTextDimensions(labelName)
    if textWidth > width then
      width = textWidth
    end
  end

  WindowSetDimensions(windowName .. "StatBonus", width, height)

  local winWidth, winHeight = WindowGetDimensions(windowName)
  if winWidth < width then
    winWidth = width
  end
  WindowSetDimensions(windowName, winWidth, winHeight + height)
end

---------------------------------------------------------------------------
-- Utility: open a tooltip window for an itemData
---------------------------------------------------------------------------

function CraftValueTip.ItemWindow(itemData)
  if not itemData or not itemData.uniqueID then
    return
  end

  local itemId     = itemData.uniqueID
  local windowName = "EA_ItemLinkWindow" .. itemId

  -- Only one window per item
  if DoesWindowExist(windowName) then
    WindowSetShowing(windowName, true)
    return
  end

  -- Cache a reference to the data
  EA_ChatWindow.HyperLinks.Items[itemId] = itemData

  -- Create the window
  CreateWindowFromTemplate(windowName, "EA_Window_ItemLinkTemplate", "Root")
  WindowSetId(windowName, itemId)

  -- Set the data
  Tooltips.SetItemTooltipData(windowName .. "Data", itemData, nil, nil)

  -- Size the parent window to the data dimensions
  local w, h = WindowGetDimensions(windowName .. "Data")
  w = w + 12
  h = h + 12
  WindowSetDimensions(windowName, w, h)

  -- Position and show the window
  WindowAddAnchor(windowName, "center", "Root", "center", 0, 0)
  WindowSetShowing(windowName, true)
end

---------------------------------------------------------------------------
-- Debug dump helpers
---------------------------------------------------------------------------

-- Dump a table to chat
function CraftValueTip.CraftDump(thing, prefix)
  if not thing then
    ShOut(L"<nil>")
    return
  end

  prefix = prefix or ""

  for k, v in pairs(thing) do
    local sLine = towstring(prefix .. tostring(k) .. " [" .. type(v) .. "]")

    if type(v) == "number" then
      sLine = sLine .. v
    elseif type(v) == "wstring" then
      sLine = sLine .. v
    elseif type(v) == "boolean" then
      if v then
        sLine = sLine .. L"True"
      else
        sLine = sLine .. L"False"
      end
    end

    ShOut(sLine)

    if type(v) == "table" then
      CraftValueTip.CraftDump(v, "    " .. prefix)
    end
  end
end

-- One line summary of crafting bonuses or normal bonuses
function CraftValueTip.ItemDump(itemData)
  if not itemData then
    ShOut(L"<no item>")
    return
  end

  local sLine = L"[" .. itemData.uniqueID .. L"]"
              .. itemData.name
              .. L" lvl" .. itemData.level
              .. L"/" .. itemData.iLevel

  if itemData.craftingBonus and itemData.craftingBonus[1] then
    sLine = sLine .. L" craftingBonus{"
    for _, v in pairs(itemData.craftingBonus) do
      if v.bonusValue > 32767 then
        sLine = sLine .. v.bonusReference .. L"=-" .. (65536 - v.bonusValue) .. L","
      else
        sLine = sLine .. v.bonusReference .. L"=" .. v.bonusValue .. L","
      end
    end
    sLine = sLine .. L"}"

  elseif itemData.bonus and itemData.bonus[1] then
    sLine = sLine .. L" bonus{"
    for k, v in pairs(itemData.bonus) do
      sLine = sLine
        .. k .. L"={t=" .. v.type
        .. L",v=" .. v.value
        .. L",cTL=" .. (v.cooldownTimeLeft or L"nil")
        .. L",r=" .. v.reference
        .. L",tCT=" .. (v.totalCooldownTime or L"nil")
        .. L"},"
    end
    sLine = sLine .. L"}"
  end

  ShOut(sLine)
end

-- Very short lookup line
function CraftValueTip.LookUpDump(itemData)
  if not itemData then
    ShOut(L"<no item>")
    return
  end

  local sLine = L"[" .. itemData.uniqueID .. L"]"
              .. itemData.name
              .. L" lvl" .. itemData.level
              .. L"/" .. itemData.iLevel

  ShOut(sLine)
end

-- Macro helpers for the current item
function CraftValueTip.Dump()
  if CraftValueTip.LastItem then
    CraftValueTip.CraftDump(CraftValueTip.LastItem)
  else
    ShOut(L"<no last item>")
  end
end

function CraftValueTip.Digest()
  if CraftValueTip.LastItem then
    CraftValueTip.ItemDump(CraftValueTip.LastItem)
  else
    ShOut(L"<no last item>")
  end
end

function CraftValueTip.Lookup()
  if CraftValueTip.LastItem then
    CraftValueTip.LookUpDump(CraftValueTip.LastItem)
  else
    ShOut(L"<no last item>")
  end
end

---------------------------------------------------------------------------
-- Object inspector hook
---------------------------------------------------------------------------

function CraftValueTip.DumpObjInspector()
  if ObjectInspector and CraftValueTip.LastItem then
    ObjectInspector.DisplayObject(
      CraftValueTip.LastItem,
      '' .. CraftValueTip.LastItem.uniqueID
    )
  end
end
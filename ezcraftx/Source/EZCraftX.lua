if EZCraftX == nil then EZCraftX = {} end

local EZCraftX = EZCraftX
local LibGUI = LibStub("LibGUI")

local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local tostring = tostring
local towstring	= towstring

local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local T = LibStub("WAR-AceLocale-3.0") : GetLocale("EZCraftX", debug)

EZCraftX.name = "EZCraftX"
EZCraftX.window = "EZCraftXWindow"
EZCraftX.windowCraftingResult = "EZCraftXWindow.CraftingResult"
EZCraftX.WindowPowerPreview = "EZCraftXWindow.PowerPreview"
EZCraftX.Result = nil
EZCraftX.ShowCraftingResult = nil

EZCraftX.options = {}

EZCraftX.strings = {
  Profession = {
		[0] = L"Salvaging",
		[3] = L"Cultivation",
		[4] = L"Apothecary",
		[5] = L"Talisman Making"
  }
}

EZCraftX.SORT_ASC = 1
EZCraftX.SORT_DESC = 2
EZCraftX.SORT_LEVEL_DEFAULT = EZCraftX.SORT_DESC
EZCraftX.SORT_ITEMS_DEFAULT = EZCraftX.SORT_DESC
EZCraftX.MAX_ITEMS = 5

local items = nil
local items_stacked = nil
local ContainerNames = {}
ContainerNames[GameData.TradeSkills.APOTHECARY] = {
    "ApothecaryWindowContainerSlot",
    "ApothecaryWindowDeterminentSlot",
    "ApothecaryWindowResource1Slot",
    "ApothecaryWindowResource2Slot",
    "ApothecaryWindowResource3Slot"
}
ContainerNames[GameData.TradeSkills.TALISMAN] = {
    "TalismanMakingWindowContainerSlot",
    "TalismanMakingWindowDeterminentSlot",
    "TalismanMakingWindowGoldSlot",
    "TalismanMakingWindowCuriosSlot",
    "TalismanMakingWindowMagicSlot"
}
ContainerNames[GameData.TradeSkills.CULTIVATION] = {
    "CultivationWindowSinglePlotSeedSpore",
    "CultivationWindowSinglePlotSoil",
    "CultivationWindowSinglePlotWater",
    "CultivationWindowSinglePlotNutrient"
}

local cascadingMenus = {}
local cascadingMenu = 0

local getn, ins, rem, sort = table.getn, table.insert, table.remove, table.sort

-- --- stat label helpers -----------------------------------------------
-- === add somewhere near other helpers ===

-- pick the stat/resist/armor entry from a fragment
function EZCraftX.ExtractFragmentStat(item)
  if not item or not item.craftingBonus then return nil, 0 end
  local want = {
    [GameData.BonusTypes.EBONUS_ARMOR]              = true,
    [GameData.BonusTypes.EBONUS_SPIRIT_RESIST]      = true,
    [GameData.BonusTypes.EBONUS_ELEMENTAL_RESIST]   = true,
    [GameData.BonusTypes.EBONUS_CORPOREAL_RESIST]   = true,
    [GameData.BonusTypes.EBONUS_STRENGTH]           = true,
    [GameData.BonusTypes.EBONUS_WILLPOWER]          = true,
    [GameData.BonusTypes.EBONUS_INTELLIGENCE]       = true,
    [GameData.BonusTypes.EBONUS_TOUGHNESS]          = true,
    [GameData.BonusTypes.EBONUS_INITIATIVE]         = true,
    [GameData.BonusTypes.EBONUS_WOUNDS]             = true,
    [GameData.BonusTypes.EBONUS_WEAPONSKILL]        = true,
    [GameData.BonusTypes.EBONUS_BALLISTICSKILL]     = true,
  }
  for _, e in ipairs(item.craftingBonus) do
    if e and e.bonusType and want[e.bonusType] then
      return e.bonusType, (e.bonusValue or 0)
    end
  end
  return nil, 0
end

local function IsResist(bt)
  return bt == GameData.BonusTypes.EBONUS_SPIRIT_RESIST
      or bt == GameData.BonusTypes.EBONUS_ELEMENTAL_RESIST
      or bt == GameData.BonusTypes.EBONUS_CORPOREAL_RESIST
end

-- label from bonusType (uses Mythic’s strings via CraftingUtils table)
function EZCraftX.BonusLabelFromType(bonusType)
  if CraftingUtils and CraftingUtils.SalvagingStatStringLookUp and bonusType then
    return CraftingUtils.SalvagingStatStringLookUp[bonusType] or L""
  end
  return L""
end

-- use bonusType for result math
function EZCraftX.GetResultByPower(power, rarity, _unused_bonusValue, bonusType, tier)
  local result = 0
  if rarity > 2 then result = result + ((rarity - 2) * 4) end
  tier = tier or EZCraftX.GetCraftingTierByPower(power)
  result = result + tier + 2

  if bonusType == GameData.BonusTypes.EBONUS_ARMOR then
    result = math.floor(result * 7.5)
  elseif IsResist(bonusType) then
    result = (result - (rarity - 1)) * 5
  end
  return result
end

function EZCraftX.GetBonusContributionString(result, _unused_bonusValue, bonusType)
  return DataUtils.GetBonusContributionString(result) .. L" " .. EZCraftX.BonusLabelFromType(bonusType)
end

--
--  simple counting function
--
local function count(arr)
  local cnt = 0
  for n in pairs(arr) do cnt = cnt + 1 end
  return cnt
end

--
--  check if value exists in array
--
local function in_array(value, arr)
  local key = nil
  for k, v in pairs(arr) do
    if v == value then
      key = k
      break
    end
  end
  return key
end

--
--  get the current version specified in the .mod-file
--
function EZCraftX.getVersion()
  local mods = ModulesGetData()
  local version = ""
  for modIndex, modData in ipairs(mods) do
    if modData.name == EZCraftX.name then
      version = modData.version
    end
  end
  return version
end

--
--  initialize the program
--
function EZCraftX.OnInitialize()
  EZCraftX.SetHooks()

  if LibSlash and type(EZCraftX.SlashHandler) == "function" then
    if not LibSlash.IsSlashCmdRegistered("ecx") then LibSlash.RegisterSlashCmd("ecx", EZCraftX.SlashHandler) end
  end
  EZCraftX.print(towstring(EZCraftX.name .. " " .. EZCraftX.getVersion() .. " ") .. T['loaded'], nil, nil, false)
  EZCraftX.print(T['type /ecx for options'])

  WindowRegisterEventHandler(EZCraftX.window, SystemData.Events.L_BUTTON_DOWN_PROCESSED, "EZCraftX.OnLButtonDown")

if DoesWindowExist(EZCraftX.window .. ".TitleBarText") then
  LabelSetText(EZCraftX.window .. ".TitleBarText", towstring(EZCraftX.name))
end

  LabelSetText(EZCraftX.window .. ".sortLevel.label", T['Sort order level'])
  ComboBoxAddMenuItem(EZCraftX.window .. ".sortLevel.DD", T['ascending'])
  ComboBoxAddMenuItem(EZCraftX.window .. ".sortLevel.DD", T['descending'])

  LabelSetText(EZCraftX.window .. ".sortItems.label", T['Sort order items'])
  ComboBoxAddMenuItem(EZCraftX.window .. ".sortItems.DD", T['ascending'])
  ComboBoxAddMenuItem(EZCraftX.window .. ".sortItems.DD", T['descending'])

  LabelSetText(EZCraftX.window .. ".maxItems.label", T['Maximum items per level'])

  ButtonSetCheckButtonFlag(EZCraftX.window .. ".useCraftingResult.Selector", true)
  LabelSetText(EZCraftX.window .. ".useCraftingResult.label", T['Show result preview'])

  ButtonSetCheckButtonFlag(EZCraftX.window .. ".usePowerPreview.Selector", true)
  LabelSetText(EZCraftX.window .. ".usePowerPreview.label", T['Show power preview'])

  EZCraftX.Update()
  
  ButtonSetText(EZCraftX.window .. ".Defaults", T['Defaults'])
  ButtonSetText(EZCraftX.window .. ".Cancel", T['Cancel'])
  ButtonSetText(EZCraftX.window .. ".Apply", T['Apply'])
end

--
--  slash handler function
--
function EZCraftX.SlashHandler(input)
  local opt, val = input:match("([^ ]+)[ ]?(.*)")

  if opt == "" or opt == nil then
    WindowUtils.ToggleShowing(EZCraftX.window)
  end
end

--
--  print function
--
function EZCraftX.print(text, chat, color, prefix)
  if chat == nil then chat = "Chat" end
  if color == nil then color = SystemData.ChatLogFilters.SHOUT end
  if prefix == nil then prefix = true end
  if prefix ~= false then
    if prefix == true then
      text = L"[" .. towstring(EZCraftX.name) .. L"]: " .. text
    else
      text = prefix .. text
    end
  end
  TextLogAddEntry(chat, color, text)
end

--
--  debug output function
--
function EZCraftX.d(text)
  if debug or debugx then d(text) end
end

--
--  deep debug ooutput function
--
function EZCraftX.dx(text)
  if debugx then d(text) end
end

--
--  occurs when dropdown or textbox are changed
--
function EZCraftX.OnUpdate()
  EZCraftX.ToggleApplyButton()
end

--
--  check if the apply button needs to be enabled/disabled
--
function EZCraftX.ToggleApplyButton()
  local curSortLevel  = ComboBoxGetSelectedMenuItem(EZCraftX.window .. ".sortLevel.DD")
  local curSortItems  = ComboBoxGetSelectedMenuItem(EZCraftX.window .. ".sortItems.DD")
  local curMaxItems   = tonumber(TextEditBoxGetText(EZCraftX.window .. ".maxItems.Text")) or EZCraftX.MAX_ITEMS
  local curUseResult  = ButtonGetPressedFlag(EZCraftX.window .. ".useCraftingResult.Selector") and true or false
  local curUsePreview = ButtonGetPressedFlag(EZCraftX.window .. ".usePowerPreview.Selector") and true or false

  local b_need_apply =
      EZCraftX.options.sortLevel         ~= curSortLevel
   or EZCraftX.options.sortItems         ~= curSortItems
   or EZCraftX.options.maxItems          ~= curMaxItems
   or EZCraftX.options.useCraftingResult ~= curUseResult
   or EZCraftX.options.usePowerPreview   ~= curUsePreview

  ButtonSetDisabledFlag(EZCraftX.window .. ".Apply", not b_need_apply)
end

--
--  set default values
--
function EZCraftX.OnLButtonUp_Defaults()
  ComboBoxSetSelectedMenuItem(EZCraftX.window .. ".sortLevel.DD", EZCraftX.SORT_LEVEL_DEFAULT)
  ComboBoxSetSelectedMenuItem(EZCraftX.window .. ".sortItems.DD", EZCraftX.SORT_ITEMS_DEFAULT)
  TextEditBoxSetText(EZCraftX.window .. ".maxItems.Text", towstring(EZCraftX.MAX_ITEMS))
  ButtonSetPressedFlag(EZCraftX.window .. ".useCraftingResult.Selector", true)
  ButtonSetPressedFlag(EZCraftX.window .. ".usePowerPreview.Selector", true)
end

--
--  cancelling
--
function EZCraftX.OnLButtonUp_Cancel()
  EZCraftX.OnLButtonUp_Close()
end

--
--  applying the changes
--
function EZCraftX.OnLButtonUp_Apply()
  EZCraftX.options.sortLevel = ComboBoxGetSelectedMenuItem(EZCraftX.window .. ".sortLevel.DD")
  EZCraftX.options.sortItems = ComboBoxGetSelectedMenuItem(EZCraftX.window .. ".sortItems.DD")
  local v = tonumber(TextEditBoxGetText(EZCraftX.window .. ".maxItems.Text")) or EZCraftX.MAX_ITEMS
  if v < 0 then v = 0 end
  EZCraftX.options.maxItems = math.floor(v)
  EZCraftX.options.useCraftingResult = ButtonGetPressedFlag(EZCraftX.window .. ".useCraftingResult.Selector") and true or false
  EZCraftX.options.usePowerPreview   = ButtonGetPressedFlag(EZCraftX.window .. ".usePowerPreview.Selector") and true or false
  EZCraftX.OnLButtonUp_Close()
end

--
--  updating the options with the saved values
--
function EZCraftX.Update()
  if EZCraftX.options.sortLevel == nil then EZCraftX.options.sortLevel = EZCraftX.SORT_LEVEL_DEFAULT end
  ComboBoxSetSelectedMenuItem(EZCraftX.window .. ".sortLevel.DD", EZCraftX.options.sortLevel)

  if EZCraftX.options.sortItems == nil then EZCraftX.options.sortItems = EZCraftX.SORT_ITEMS_DEFAULT end
  ComboBoxSetSelectedMenuItem(EZCraftX.window .. ".sortItems.DD", EZCraftX.options.sortItems)

  if EZCraftX.options.maxItems == nil then EZCraftX.options.maxItems = EZCraftX.MAX_ITEMS end
  TextEditBoxSetText(EZCraftX.window .. ".maxItems.Text", towstring(EZCraftX.options.maxItems))

  if EZCraftX.options.useCraftingResult == nil then EZCraftX.options.useCraftingResult = true end
  ButtonSetPressedFlag(EZCraftX.window .. ".useCraftingResult.Selector", EZCraftX.options.useCraftingResult)
  if not EZCraftX.options.useCraftingResult then EZCraftX.ShowCraftingResult = nil end

  if EZCraftX.options.usePowerPreview == nil then EZCraftX.options.usePowerPreview = true end
  ButtonSetPressedFlag(EZCraftX.window .. ".usePowerPreview.Selector", EZCraftX.options.usePowerPreview)
end

--
--  handles all leftclicks ingame, check to see if the window clicked is specified in ContainerNames
--
function EZCraftX.OnLButtonDown()
  local over = SystemData.MouseOverWindow and SystemData.MouseOverWindow.name
  if not over then return end
  for craftSkill, arrNames in pairs(ContainerNames) do
    for _, slotName in pairs(arrNames) do
      if over == slotName then
        EZCraftX.showMenu(craftSkill, WindowGetId(over))
        return
      end
    end
  end
end

--
--  onmouseover tooltip for power preview
--
function EZCraftX.OnMouseOver_PowerPreview()
  EZCraftX.ShowTooltip()
end

--
--  onmouseover tooltip for regular items in context menu
--
function EZCraftX.OnMouseOver_ContextMenu_Item()
  local name = SystemData.MouseOverWindow.name
  if string.sub(name, 1, 26) == "EZCraftX_ContextMenu_Item_" then
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_2)
  end

  local craftingSkillRequirement, index = name:match("_([0-9]+)_([0-9]+)")
  local item = items[tonumber(craftingSkillRequirement)][tonumber(index)]
  local itemData = DataUtils.FindItem(item.uniqueID)
  if itemData ~= nil then
    Tooltips.CreateItemTooltip(itemData, SystemData.MouseOverWindow.name)
  end
end

--
--  close EZCraft options window
--
function EZCraftX.OnLButtonUp_Close()
  EZCraftX.Update()
  local show = EZCraftX.options.useCraftingResult and WindowGetShowing(TalismanMakingWindow.windowName)
  if show and not WindowGetShowing(EZCraftX.windowCraftingResult) then EZCraftX.CraftingSystem_SetState() end
  EZCraftX.WindowSetShowing(show)
	WindowUtils.ToggleShowing(EZCraftX.window)
end

--
--  click for regular items in context menu
--
function EZCraftX.OnLButtonUp_ContextMenu_Item()
  local name = SystemData.MouseOverWindow.name
  local craftingSkillRequirement, index = name:match("_([0-9]+)_([0-9]+)")
  local item = items[tonumber(craftingSkillRequirement)][tonumber(index)]
  
  EZCraftX.AddItem(item)
  EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_2)
  EA_Window_ContextMenu.Hide()
end

--
--  creates colorized entries for items in context menu
--
function createContextMenu_ItemWindow(index, itemData)
	local windowId = "EZCraftX_ContextMenu_Item" .. index
	
	if not DoesWindowExist(windowId) then
		CreateWindowFromTemplate(windowId, "EZCraftX_ContextMenu_Item", "Root")
	end

	LabelSetText(windowId .. "Count", 	towstring(itemData.stackCount) .. L"x")
	LabelSetText(windowId .. "Name", 	towstring(itemData.name))
	LabelSetTextColor(windowId .. "Name", GameDefs.ItemRarity[itemData.rarity].color.r, GameDefs.ItemRarity[itemData.rarity].color.g, GameDefs.ItemRarity[itemData.rarity].color.b)
  
	return windowId
end

--
--  get items in a backpack
--
function EZCraftX.GetItems(backpack, TradeSkill, Slot)
  local itemsInBackpack = nil
  if backpack == nil
  or backpack == EA_Window_Backpack.TYPE_INVENTORY then
    itemsInBackpack = DataUtils.GetItems();
  elseif backpack == EA_Window_Backpack.TYPE_CRAFTING then
    itemsInBackpack = DataUtils.GetCraftingItems();
  end
  if itemsInBackpack ~= nil then
    for index,itemData in pairs(itemsInBackpack) do
      if EZCraftX.item_allowed_in_slot(TradeSkill, itemData, Slot) then
        if items_stacked[itemData.craftingSkillRequirement] == nil then
          items_stacked[itemData.craftingSkillRequirement] = {}
          items[itemData.craftingSkillRequirement] = {}
        end
        if items_stacked[itemData.craftingSkillRequirement][itemData.uniqueID] == nil then
          items_stacked[itemData.craftingSkillRequirement][itemData.uniqueID] = { uniqueID = itemData.uniqueID, cnt = 0, backpackSlot = index, rarity = itemData.rarity, backpack = backpack }
        end
        items_stacked[itemData.craftingSkillRequirement][itemData.uniqueID].cnt = items_stacked[itemData.craftingSkillRequirement][itemData.uniqueID].cnt + itemData.stackCount
      end
    end
  end
end

function EZCraftX.contextMenuOnClick()
  -- header row. intentional no-op
end

--
--  show context menu for specific trade skill and slot if items can be found
--
function EZCraftX.showMenu(TradeSkill, Slot)
  items = {}
  items_stacked = {}

  EZCraftX.GetItems(EA_Window_Backpack.TYPE_INVENTORY, TradeSkill, Slot)
  EZCraftX.GetItems(EA_Window_Backpack.TYPE_CRAFTING, TradeSkill, Slot)

  if count(items_stacked) == 0 then
    return
  end
  
  for craftingSkillRequirement, arr_data in pairs(items_stacked) do
    for uniqueID, data in pairs(arr_data) do
      data.tradeSkill = TradeSkill
      data.slot = Slot
      ins(items[craftingSkillRequirement], data)
    end
  end
  for craftingSkillRequirement, arr_data in pairs(items) do
    if EZCraftX.options.sortItems == EZCraftX.SORT_ASC then
      table.sort(arr_data, function(a, b) return a.rarity < b.rarity end)
    else
      table.sort(arr_data, function(a, b) return a.rarity > b.rarity end)
    end
  end
  items_stacked = nil

  local arr = {}
  for n in pairs(items) do ins(arr, n) end
  if EZCraftX.options.sortLevel == EZCraftX.SORT_ASC then
    sort(arr)
  else
    table.sort(arr, function(a, b) return a > b end)
  end

  EA_Window_ContextMenu.CreateContextMenu("EZCraftX_contextMenu")

  cascadingMenus = {}
  local row = 1
  
  if EZCraftX.options.maxItems < 0 or
  EZCraftX.options.maxItems == nil then
    EZCraftX.options.maxItems = 0
  end
  for _, craftingSkillRequirement in pairs(arr) do
    local data = items[craftingSkillRequirement]
		if row > 1 then
		  EA_Window_ContextMenu.AddMenuDivider()
	    row = row + 1
		end
		local cnt_data = count(data)
    EA_Window_ContextMenu.AddMenuItem(T['Level'] .. L" " .. craftingSkillRequirement, EZCraftX.contextMenuOnClick, true, true)
    row = row + 1
    if EZCraftX.options.maxItems > 0
    and cnt_data > EZCraftX.options.maxItems then
      cascadingMenus[row] = craftingSkillRequirement
      for index, item in pairs(data) do
        local itemData = DataUtils.FindItem(item.uniqueID)
        itemData.stackCount = item.cnt
        EA_Window_ContextMenu.AddUserDefinedMenuItem(createContextMenu_ItemWindow("_" .. craftingSkillRequirement .. "_" .. index, itemData))
        if index == EZCraftX.options.maxItems then
          break
        end
      end
      local more = cnt_data - EZCraftX.options.maxItems
      local s_more = T['more... (%s)']
      s_more = towstring(string.format(tostring(s_more), tostring(more)))
      EA_Window_ContextMenu.AddCascadingMenuItem(s_more, EZCraftX.SpawnSelectionMenu, false, EA_Window_ContextMenu.CONTEXT_MENU_1)
	    row = row + 1
    else
      for index, item in pairs(data) do
        local itemData = DataUtils.FindItem(item.uniqueID)
        itemData.stackCount = item.cnt
        EA_Window_ContextMenu.AddUserDefinedMenuItem(createContextMenu_ItemWindow("_" .. craftingSkillRequirement .. "_" .. index, itemData))
      end
    end
  end

  EA_Window_ContextMenu.Finalize();
end

--
--  show cascading menu for more items
--
function EZCraftX.SpawnSelectionMenu()
	cascadingMenu = WindowGetId(SystemData.MouseOverWindow.name)
	local craftingSkillRequirement = cascadingMenus[cascadingMenu]
  local data = items[craftingSkillRequirement]

  EA_Window_ContextMenu.CreateContextMenu("", EA_Window_ContextMenu.CONTEXT_MENU_2)

  EA_Window_ContextMenu.AddMenuItem(T['Level'] .. L" " .. craftingSkillRequirement, EZCraftX.contextMenuOnClick, true, true, EA_Window_ContextMenu.CONTEXT_MENU_2)

  for index, item in pairs(data) do
    local itemData = DataUtils.FindItem(item.uniqueID)
    itemData.stackCount = item.cnt
    if index > EZCraftX.options.maxItems then
      EA_Window_ContextMenu.AddUserDefinedMenuItem(createContextMenu_ItemWindow("Cascading_" .. craftingSkillRequirement .. "_" .. index, itemData), EA_Window_ContextMenu.CONTEXT_MENU_2)
    end
  end

  EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_2)
end

--
--  checks wether item is allowed in speficic slot
--
function EZCraftX.item_allowed_in_slot(TradeSkill, itemData, Slot)
  local craftingTypes, resourceType = CraftingSystem.GetCraftingData(itemData)
  if TradeSkill == GameData.TradeSkills.APOTHECARY then
    if Slot == ApothecaryWindow.SLOT_CONTAINER then
		  if resourceType == GameData.CraftingItemType.CONTAINER
		  or resourceType == GameData.CraftingItemType.CONTAINER_DYE then
			  return true
      end
  	elseif Slot == 1
  	and ApothecaryWindow.productType == GameData.CraftingItemType.CONTAINER_DYE then
  		if resourceType == GameData.CraftingItemType.PIGMENT then
  			return true
      end
    elseif Slot == ApothecaryWindow.SLOT_INGREDIENT1
    and ApothecaryWindow.productType == GameData.CraftingItemType.CONTAINER_DYE then
  		if resourceType == GameData.CraftingItemType.FIXER then
        return true
      end
  	else
      return ApothecaryWindow.ItemIsAllowedInSlot(itemData, Slot)
  	end
  elseif TradeSkill == GameData.TradeSkills.TALISMAN then
    return TalismanMakingWindow.ItemIsAllowedInSlot(itemData, Slot)
  elseif TradeSkill == GameData.TradeSkills.CULTIVATION then
    if Slot >= CultivationWindow.plot[GameData.Player.Cultivation.CurrentPlot].StageNum + 1 then
      if itemData.cultivationType == Slot
      or Slot == GameData.CultivationStage.EMPTY + 1
      and itemData.cultivationType == GameData.CultivationTypes.SPORE then
        return true
      end
    end
  end
  return false
end

--
--  add item to specific slot
--
function EZCraftX.AddItem(item)
  local SlotOrPlot = nil
  if item.tradeSkill == GameData.TradeSkills.CULTIVATION then
    SlotOrPlot = GameData.Player.Cultivation.CurrentPlot
  else
    if item.tradeSkill == GameData.TradeSkills.APOTHECARY
    and ApothecaryWindow.craftingData[item.slot] ~= nil
    and ApothecaryWindow.craftingData[item.slot ].sourceSlot ~= nil then
      ApothecaryWindow.RemoveVirtualItemSlot(item.slot)
      RemoveCraftingItem(GameData.TradeSkills.APOTHECARY, ApothecaryWindow.craftingData[item.slot].sourceSlot)
    elseif item.tradeSkill == GameData.TradeSkills.TALISMAN
    and TalismanMakingWindow.craftingData[item.slot] ~= nil
    and TalismanMakingWindow.craftingData[item.slot].sourceSlot ~= nil then
      TalismanMakingWindow.RemoveVirtualItemSlot(item.slot)
      RemoveCraftingItem(GameData.TradeSkills.TALISMAN, TalismanMakingWindow.craftingData[item.slot].sourceSlot)
    end
    SlotOrPlot = item.slot;
  end

  if item.tradeSkill == GameData.TradeSkills.APOTHECARY then
    ApothecaryWindow.AddItem(item.backpackSlot, SlotOrPlot, item.backpack)
  elseif item.tradeSkill == GameData.TradeSkills.TALISMAN then
    TalismanMakingWindow.AddItem(item.backpackSlot, SlotOrPlot, item.backpack)
  elseif item.tradeSkill == GameData.TradeSkills.CULTIVATION then
    AddCraftingItem(item.tradeSkill, SlotOrPlot, item.backpackSlot, item.backpack)
  end
end

--
-- hide all power previews
--
function EZCraftX.PowerPreviewHideAll()
  if not TalismanMakingWindow or not TalismanMakingWindow.slotStrings then return end
  for index in pairs(TalismanMakingWindow.slotStrings) do
    EZCraftX.PowerPreview(index, nil)
  end
  EZCraftX.PowerPreview("total", nil)
end

--
-- show power preview according to container
--
function EZCraftX.PowerPreview(container, power)
  local anchor = container == "total" and "TalismanMakingWindowPowerMeterBackground"
                                   or ContainerNames[GameData.TradeSkills.TALISMAN][container + 1]
  local windowName = EZCraftX.WindowPowerPreview .. "." .. tostring(container)
  if not EZCraftX.options.usePowerPreview then
    if DoesWindowExist(windowName) then DestroyWindow(windowName) end
    return
  end
  if power == nil then
    if DoesWindowExist(windowName) then WindowSetShowing(windowName, false) end
    return
  end
  if not DoesWindowExist(windowName) then
    CreateWindowFromTemplate(windowName, "EZCraftX_Templates.PowerPreview", TalismanMakingWindow.windowName)
    WindowClearAnchors(windowName)
    local breadth = select(1, WindowGetDimensions(anchor))
    if container ~= "total" then
      WindowSetDimensions(windowName, breadth, 24)
      WindowSetDimensions(windowName .. ".label", breadth, 24)
      WindowAddAnchor(windowName, "bottomleft", anchor, "topleft", 0, 0)
    else
      WindowAddAnchor(windowName, "bottomleft", anchor, "topleft", (breadth / 2) - 32, 0)
    end
  else
    WindowSetShowing(windowName, true)
  end
  local s_power = power > 0 and DataUtils.GetBonusContributionString(power) or L"0"
  LabelSetText(windowName .. ".label", s_power)
end

--
--  do hooking
--
function EZCraftX.SetHooks()
	--d(TalismanMakingWindow)
	--d(SystemData.Events)
	
	EZCraftX.TalismanMakingWindow_OnHidden_Hooked = TalismanMakingWindow.OnHidden
	TalismanMakingWindow.OnHidden = EZCraftX.TalismanMakingWindow_OnHidden

	EZCraftX.CraftingSystem_SetState_Hooked = CraftingSystem.SetState
	CraftingSystem.SetState = EZCraftX.CraftingSystem_SetState
	
	TalismanMakingWindow.OnSlotMouseOver = EZCraftX.TalismanMakingWindow_OnSlotMouseOver
end

--
-- replacing the onmouseover function from mythic (thanks to Garkin over at curseforge.com)
--
function EZCraftX.TalismanMakingWindow_OnSlotMouseOver(...)
  local slotNum = WindowGetId( SystemData.ActiveWindow.name )
  
  if (TalismanMakingWindow.craftingData[slotNum] and TalismanMakingWindow.craftingData[slotNum].sourceSlot) then
    local backpackType = TalismanMakingWindow.craftingData[slotNum].backpack 
    local inventory = EA_Window_Backpack.GetItemsFromBackpack(backpackType)
    local itemData = inventory[TalismanMakingWindow.craftingData[slotNum].sourceSlot]
    if ((nil ~= itemData) and (nil ~= itemData.id) and (0 ~= itemData.id)) then     
      Tooltips.CreateItemTooltip(itemData, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT, true, GetString(StringTables.Default.TEXT_R_CLICK_TO_REMOVE), Tooltips.COLOR_WARNING)
    end
  else
    -- Create a tooltip for the empty spot
    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, TalismanMakingWindow.SlotToolTipText[slotNum])
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_RIGHT)
  end
end

--
--  TalismanMakingWindow hidden
--
-- helper: pick the right stat entry from a fragment
local function GetFragBonusEntry(frag)
  if not frag or not frag.craftingBonus then return nil end

  -- determinant slot is usually index 5, but confirm
  local b = frag.craftingBonus[5]
  if b and (b.bonusType or b.bonusValue) then
    return b
  end

  -- fallback: find the first valid entry
  for _, entry in ipairs(frag.craftingBonus) do
    if entry and (entry.bonusType or entry.bonusValue) then
      return entry
    end
  end
  return nil
end

function EZCraftX.CraftingSystem_SetState(...)
  -- run original
  EZCraftX.CraftingSystem_SetState_Hooked(...)

  if not EZCraftX.options.useCraftingResult then return end

  local frag   = nil
  local Result = { Regular = {}, Good = {}, Awesome = {} }

  if CraftingSystem.currentTradeSkill == CraftingSystem.SKILL_TALISMAN then
    local win  = CraftingSystem.currentWindow
    local data = win and win.craftingData or nil

    -- determinant fragment
    local det = data and win and data[win.SLOT_DETERMINENT] or nil
    if det and det.objectId then
      frag = DataUtils.FindItem(det.objectId)
    end

    if frag then
      -- curios rarity
      local curiosRarity = 0
      local curios = data and win and data[win.SLOT_CURIOS] or nil
      if curios and curios.objectId then
        local ci = DataUtils.FindItem(curios.objectId)
        if ci and ci.rarity then curiosRarity = ci.rarity end
      end

      -- use helper to extract correct bonus
      local b = GetFragBonusEntry(frag)
      local bonusValue = b and (b.bonusValue or 0) or 0
      local bonusType  = b and b.bonusType or nil

      -- compute preview rows
      Result.Regular.rarity   = frag.rarity or 0
      Result.Regular.power    = EZCraftX.GetPowerTotal()
      Result.Regular.tier     = EZCraftX.GetCraftingTierByPower(Result.Regular.power)
      Result.Regular.result   = EZCraftX.GetResultByPower(Result.Regular.power, Result.Regular.rarity, bonusValue, bonusType)
      Result.Regular.minlevel = EZCraftX.GetMinimumLevelByPower(Result.Regular.power)

      Result.Good.rarity   = frag.rarity or 0
      Result.Good.power    = Result.Regular.power + 6
      Result.Good.tier     = EZCraftX.GetCraftingTierByPower(Result.Good.power)
      Result.Good.result   = EZCraftX.GetResultByPower(Result.Good.power, Result.Good.rarity, bonusValue, bonusType)
      Result.Good.minlevel = EZCraftX.GetMinimumLevelByPower(Result.Good.power)

      Result.Awesome.rarity   = (frag.rarity or 0) + 1
      Result.Awesome.power    = Result.Regular.power + 1
      Result.Awesome.tier     = EZCraftX.GetCraftingTierByPower(Result.Awesome.power)
      Result.Awesome.result   = EZCraftX.GetResultByPower(Result.Awesome.power, Result.Awesome.rarity, bonusValue, bonusType)
      Result.Awesome.minlevel = EZCraftX.GetMinimumLevelByPower(Result.Awesome.power)

      -- final result table
      EZCraftX.Result = {
        item       = frag,
        type       = T["Talisman"],
        TradeSkill = CraftingSystem.SKILL_TALISMAN,
        window     = "TalismanMakingWindow",
        iconNum    = 394,
        bonusType  = bonusType,
        bonusValue = bonusValue,
        critChance = EZCraftX.GetCritChance(frag.rarity or 0, curiosRarity),
        Regular    = Result.Regular,
        Good       = Result.Good,
        Awesome    = Result.Awesome,
      }
    else
      -- no fragment yet, still recalc power if a container exists
      local container = data and TalismanMakingWindow and data[TalismanMakingWindow.SLOT_CONTAINER] or nil
      if container and container.objectId then EZCraftX.GetPowerTotal() end
    end
  end

  -- update UI
  if frag and EZCraftX.Result and Result.Regular and Result.Regular.result and Result.Regular.result > 0 then
    EZCraftX.PowerPreview("total", EZCraftX.Result.Regular.power)
    EZCraftX.UpdateResult()
    EZCraftX.WindowSetShowing(true)
  else
    EZCraftX.PowerPreview("total", nil)
    EZCraftX.WindowSetShowing(false)
  end
end

--
-- simple SetShowing
--
function EZCraftX.WindowSetShowing(show)
  if DoesWindowExist(EZCraftX.windowCraftingResult) then
    WindowSetShowing(EZCraftX.windowCraftingResult, show)
  end
end

--
-- update the result preview, make sure window exists
--
function EZCraftX.UpdateResult()
	if not DoesWindowExist(EZCraftX.windowCraftingResult) then
    CreateWindowFromTemplate(EZCraftX.windowCraftingResult, EZCraftX.windowCraftingResult, "Root")

    EZCraftX.WindowSetDimensions(EZCraftX.Result.window)
  
    WindowClearAnchors(EZCraftX.windowCraftingResult)
    WindowAddAnchor(EZCraftX.windowCraftingResult, "bottomleft", EZCraftX.Result.window, "topleft", 0, 0)
  
  
    LabelSetText(EZCraftX.windowCraftingResult .. "ButtonRegular.label", T['Regular'])
    LabelSetText(EZCraftX.windowCraftingResult .. "ButtonGood.label", T['Good'])
    LabelSetText(EZCraftX.windowCraftingResult .. "ButtonAwesome.label", T['Awesome'])
  end

  EZCraftX.ShowResult(EZCraftX.ShowCraftingResult)
end

--
-- get total power from all countainers
--
function EZCraftX.GetPowerTotal(TradeSkill, data) 
  local total_power = 0
  local power = 0
  if data == nil then data = CraftingSystem.currentWindow.craftingData end
  if TradeSkill == nil then TradeSkill = CraftingSystem.currentTradeSkill end

  EZCraftX.d("GetPowerTotal")

  if TradeSkill == CraftingSystem.SKILL_TALISMAN then
    for index, name in pairs(TalismanMakingWindow.slotStrings) do
      power = EZCraftX.GetPower(data[index])
      EZCraftX.PowerPreview(index, power)
      if power == nil then power = 0 end
      EZCraftX.d("GetTotalPower > power from " .. name .. " = " .. power)
      total_power = total_power + power
    end
  end
  EZCraftX.d("GetPowerTotal > total power = " .. total_power)
  return total_power
end

--
-- get power from a given item
--
function EZCraftX.GetPower(ContainerItem)
  if not ContainerItem then return nil end
  if ContainerItem.uniqueID and not ContainerItem.objectId then ContainerItem.objectId = ContainerItem.uniqueID end
  local item = ContainerItem.craftingBonus and ContainerItem or DataUtils.FindItem(ContainerItem.objectId)
  if not item or not item.craftingBonus or not item.craftingBonus[4] then return nil end
  return item.craftingBonus[4].bonusValue
end

--
-- returns the tier of an item based on its power
--
function EZCraftX.GetCraftingTierByPower(power)
  if power >= 2 and power <= 8 then return 1
  elseif power >= 9 and power <= 13 then return 2
  elseif power >= 14 and power <= 18 then return 3
  elseif power >= 19 and power <= 24 then return 4
  elseif power >= 25 and power <= 29 then return 5
  elseif power >= 30 and power <= 34 then return 6
  elseif power >= 35 and power <= 39 then return 7
  elseif power >= 40 and power <= 45 then return 8
  elseif power >= 46 and power <= 50 then return 9
  elseif power >= 51 and power <= 52 then return 10
  else
    return 0
  end
end

--
-- returns the min level of an item based on its power
--
function EZCraftX.GetMinimumLevelByPower(power)
  if power >= 2 and power <= 8 then return 1
  elseif power >= 9 and power <= 18 then return 6
  elseif power >= 19 and power <= 29 then return 11
  elseif power >= 30 and power <= 39 then return 21
  elseif power >= 40 and power <= 50 then return 31
  elseif power >= 51 and power <= 52 then return 36
  else
    return 0
  end
end

--
-- returns the crit chance based on the frag and curio given
--
function EZCraftX.GetCritChance(FragRarity, CuriosRarity)
  local critChance = FragRarity - 1
  if CuriosRarity > 2 then
    critChance = critChance + (CuriosRarity - 2) * 5
  elseif CuriosRarity > 0 then
    critChance = critChance + 1
  end
  return critChance
end

-- returns a string with the complete bonus contribution string including the type of bonus
--
function EZCraftX.GetBonusContributionString(result, bonusValue, bonusType)
  local label = L""

  if bonusType and CraftingUtils and CraftingUtils.SalvagingStatStringLookUp then
    local lookup = CraftingUtils.SalvagingStatStringLookUp[bonusType]
    if lookup then
      label = lookup
    end
  end

  if label == L"" then
    local stat = EZCraftX.GetBonusEffectString(bonusValue)
    if stat ~= "" then
      label = T[stat]
    end
  end

  return DataUtils.GetBonusContributionString(result) .. L" " .. label
end

--
-- returns the type of bonus effect based on the bonus value (of an item)
--
function EZCraftX.GetBonusEffectString(bonusValue)
  if bonusValue == nil then return "" end
  if bonusValue >= 1 and bonusValue <= 4 then return "Armor"
  elseif bonusValue >= 5 and bonusValue <= 8 then return "Corporeal Resist"
  elseif bonusValue >= 9 and bonusValue <= 12 then return "Elemental Resist"
  elseif bonusValue >= 13 and bonusValue <= 16 then return "Spirit Resist"
  elseif bonusValue >= 17 and bonusValue <= 20 then return "Toughness"
  elseif (bonusValue >= 21 and bonusValue <= 24) or bonusValue == 49 then return "Ballistics"
  elseif bonusValue >= 25 and bonusValue <= 28 then return "Weapon Skill"
  elseif (bonusValue >= 29 and bonusValue <= 32) or bonusValue == 50 then return "Intelligence"
  elseif (bonusValue >= 33 and bonusValue <= 36) or bonusValue == 51 then return "Willpower"
  elseif (bonusValue >= 37 and bonusValue <= 40) or bonusValue == 52 then return "Strength"
  elseif bonusValue >= 41 and bonusValue <= 44 then return "Initiative"
  elseif bonusValue >= 45 and bonusValue <= 48 then return "Wounds"
  else
    return ""
  end
end

--
-- sets the dimensions of the crafting preview window
--
function EZCraftX.WindowSetDimensions(parent)
  local breadth, height = WindowGetDimensions(parent)
  local Buttons = {"ButtonRegular", "ButtonGood", "ButtonAwesome" }
  WindowSetDimensions(EZCraftX.windowCraftingResult, breadth, 200)
  for _, Button in pairs(Buttons) do
    WindowSetDimensions(EZCraftX.windowCraftingResult .. Button, (breadth - 22) / 3, 25)
  end
  WindowSetDimensions(EZCraftX.windowCraftingResult .. ".ResultCrit.label", breadth, 20)
end

--
-- shows the crafting preview result based on which tab is selected
--
function EZCraftX.ShowResult(ShowCraftingResult)
  local colMouseOver = { r = 0,  g = 0,  b = 0,  a = 1 }
  local colMouseOut  = { r = 25, g = 25, b = 25, a = 1 }
  local Buttons      = { "ButtonRegular", "ButtonGood", "ButtonAwesome" }

  -- default to "Regular"
  if not ShowCraftingResult then ShowCraftingResult = Buttons[1] end
  EZCraftX.ShowCraftingResult = ShowCraftingResult

  -- safety
  if not EZCraftX.Result then return end
  local resultKey = string.sub(ShowCraftingResult, 7) -- "Regular"/"Good"/"Awesome"
  local row       = EZCraftX.Result[resultKey]
  if not row then return end

  -- button highlight
  for _, btn in pairs(Buttons) do
    local col = (ShowCraftingResult == btn) and colMouseOver or colMouseOut
    WindowSetTintColor(EZCraftX.windowCraftingResult .. btn, col.r, col.g, col.b)
    WindowSetAlpha(EZCraftX.windowCraftingResult .. btn, col.a)
  end

  -- icon
  local texture, dx, dy = GetIconData(EZCraftX.Result.iconNum)
  DynamicImageSetTexture(EZCraftX.windowCraftingResult .. "IconFrameIcon", texture, dx, dy)

  -- header with rarity color
  LabelSetText(EZCraftX.windowCraftingResult .. ".ResultHeader.label", T[resultKey .. " Result"])
  local rarityCol = GameDefs.ItemRarity[row.rarity].color
  LabelSetTextColor(EZCraftX.windowCraftingResult .. ".ResultHeader.label", rarityCol.r, rarityCol.g, rarityCol.b)

  -- type label ("Talisman")
  LabelSetText(EZCraftX.windowCraftingResult .. ".ResultType.label", EZCraftX.Result.type)

  -- stats: now uses the stored bonusType + bonusValue
  LabelSetText(
    EZCraftX.windowCraftingResult .. ".ResultStats.label",
    EZCraftX.GetBonusContributionString(row.result, EZCraftX.Result.bonusValue, EZCraftX.Result.bonusType)
  )

  -- minimum level
  LabelSetText(
    EZCraftX.windowCraftingResult .. ".ResultLevel.label",
    T["Minimum Rank:"] .. L" " .. row.minlevel
  )

  -- crit chance
  local s_crit = T["%s chance for critical success"]
  s_crit = towstring(string.format(tostring(s_crit), tostring(EZCraftX.Result.critChance) .. "%"))
  LabelSetText(EZCraftX.windowCraftingResult .. ".ResultCrit.label", s_crit)
end


function EZCraftX.OnMouseOver_ButtonRegular()
  EZCraftX.ShowResult("ButtonRegular")
end

function EZCraftX.OnMouseOver_ButtonGood()
  EZCraftX.ShowResult("ButtonGood")
end

function EZCraftX.OnMouseOver_ButtonAwesome()
  EZCraftX.ShowResult("ButtonAwesome")
end

function EZCraftX.OnMouseOver_Dropdown()
  EZCraftX.ShowTooltip()
end

function EZCraftX.OnMouseOver_Text3Chars()
  EZCraftX.ShowTooltip()
end

function EZCraftX.OnMouseOver_useCraftingResult()
  EZCraftX.ShowTooltip()
end

function EZCraftX.OnMouseOver_usePowerPreview()
  EZCraftX.ShowTooltip()
end

--
-- shows tooltips based on calling window
--
function EZCraftX.ShowTooltip(windowName)
  if windowName == nil then windowName	= SystemData.ActiveWindow.name end
  local parent = nil
  local name = nil
  name = windowName:match(EZCraftX.WindowPowerPreview .. "\.([^.]*)")
  if name ~= nil then
    parent = EZCraftX.WindowPowerPreview
  else
    name = windowName:match(EZCraftX.window .. "\.([^.]*)")
    if name ~= nil then parent = EZCraftX.window end
  end
  local Tooltip = nil

  if parent == EZCraftX.window then
    if name == "sortLevel" then EZCraftX.d("Tooltip missing: "..windowName)
    elseif name == "sortItems" then EZCraftX.d("Tooltip missing: "..windowName)
    elseif name == "maxItems" then EZCraftX.d("Tooltip missing: "..windowName)
    elseif name == "usePreview" then EZCraftX.d("Tooltip missing: "..windowName)
    elseif name == "usePowerPreview" then EZCraftX.d("Tooltip missing: "..windowName)
    elseif name == "maxItems" then EZCraftX.d("Tooltip missing: "..windowName)
    end
  elseif parent == EZCraftX.WindowPowerPreview then
    local power = LabelGetText(windowName .. ".label")
    if name ~= "total" then
      Tooltip = T['%s power added to recipe from this ingredient']
    else
      Tooltip = T['%s power added to recipe from all ingredients']
    end
    Tooltip = towstring(string.format(tostring(Tooltip), tostring(power)))
  end
  --Tooltip = L"Heading\nText"
  if Tooltip ~= nil then
    Tooltips.CreateTextOnlyTooltip(windowName, nil)
    Tooltips.SetTooltipText(1, 1, Tooltip)
    Tooltips.SetTooltipColorDef(1, 1, Tooltips.COLOR_BODY)
    Tooltips.Finalize()
    local anchor = { Point="topright", RelativeTo=windowName, RelativePoint="topleft", XOffset=1, YOffset=0 }
    Tooltips.AnchorTooltip(anchor)
    Tooltips.SetTooltipAlpha(1)
  end
end

function EZCraftX.OnLButtonUp_useCraftingResult()
  EZCraftX.ToggleApplyButton()
end

function EZCraftX.OnLButtonUp_usePowerPreview()
  EZCraftX.ToggleApplyButton()
end

--
-- crafting preview closed by user
--
function EZCraftX.OnLButtonUp_CraftingResult_Close()
  EZCraftX.options.useCraftingResult = false
  EZCraftX.WindowSetShowing(false)
  EZCraftX.Update()
end

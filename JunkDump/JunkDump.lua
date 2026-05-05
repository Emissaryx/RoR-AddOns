JunkDump = JunkDump or {}

local function print(txt)
	EA_ChatWindow.Print(towstring(txt))
end

local langStrings = {}
local JDitemList = {}
local JDreportList = {}
local JDStartMoney = 0
local JDshowMoney = 0
local TestModeList = {}
local TestModeHighLightColor = {r = 255, g = 0, b = 0}
local ClearHighLightColor = {r = 255, g = 255, b = 255}
local AddonVersion = L"1.2.2"

JunkDump.CharacterNameString = "Default" --GameData.Player.name
JunkDump.ServerNameString = "Default" --GameData.Account.ServerName

local TestModeSlotMarker = {}
local TestModeCraftingSlotMarker = {}
local slotMarker = {}
local craftingSlotMarker = {}
local slotHook

local tonumber = tonumber
local pairs = pairs
local tinsert = table.insert
local tremove = table.remove
local math_floor = math.floor
local GetInventoryItemData = GetInventoryItemData
local GetCraftingItemData = GetCraftingItemData
local IsSlotLocked = EA_Window_Backpack.IsSlotLocked

local PlayerGetMoney = Player.GetMoney
local FormatMoney = MoneyFrame.FormatMoneyString
local BroadcastEvent = BroadcastEvent

local defaultsettings =
{
	Version = 1.51, -- Incase I add more options.
	RarityThreshold = 1, -- 1:Grey, 2:White, 3:Green, 4:Blue, 5:Purple, 6:Orange
	ItemExceptions = {}, -- Array of stuff Not to sell
	ItemAdditions = {}, -- Array of stuff to sell thats not in the rarity
	ShowItemsReport = 0, -- Set if you want a list of items sold, to show up in the report.
	ShowGoldReport = 1, -- Set if you want the total amount of gold obtained from the sale to show up.
	BagMode = 0, --Sets it to Bag Mode. Sells an entire bag.
	BagModeBag = 1, --Which bag to process.
	SellApoth = 0, --Sell Apothecary Items
	SellTalisman = 0, --Sell Talisman items
	SellCultivation = 0, --SellCultivation Items
	SellSalvaging = 0, --SellSalvaging
	ApothMax = 250, --Max Level threshold for Apoth
	TalismanMax = 250, --Max Level threshold for Talisman Making
	CultivationMax = 250, --Max Level threshold for Cultivation
	SalvagingMax = 250, --Max Level threshold for Salvaging
	IgnoreProfessionRarity = 0, --Sell all rarities of a profession.
	FirstRun = 0
}

function JunkDump.Initialize()
    JunkDump.CharacterNameString = "Default"
    JunkDump.ServerNameString = "Default"

    -- Ensure settings root exists
    JunkDumpSettings = JunkDumpSettings or {}
    JunkDumpSettings[JunkDump.ServerNameString] = JunkDumpSettings[JunkDump.ServerNameString] or {}
    JunkDumpSettings[JunkDump.ServerNameString][JunkDump.CharacterNameString] =
        JunkDumpSettings[JunkDump.ServerNameString][JunkDump.CharacterNameString] or {}

    local profile = JunkDumpSettings[JunkDump.ServerNameString][JunkDump.CharacterNameString]

    -- Fill missing defaults
    for k, v in pairs(defaultsettings) do
        if profile[k] == nil then
            profile[k] = v
        end
    end

    -- Version upgrade guard
    if profile.Version < defaultsettings.Version then
        for k, v in pairs(defaultsettings) do
            if profile[k] == nil then
                profile[k] = v
            end
        end
        profile.Version = defaultsettings.Version
    end

    -- Slash commands
    if not LibSlash.IsSlashCmdRegistered("jd") then
        LibSlash.RegisterWSlashCmd("jd", function(args) JunkDump.SlashHandler(args) end)
    else
        print(langStrings[1])
    end

    LibSlash.RegisterWSlashCmd("junkdump", function(args) JunkDump.SlashHandler(args) end)

    -- UI Button
    CreateWindow("JunkDumpButtonWin", true)
    WindowClearAnchors("JunkDumpButtonWin")
    WindowAddAnchor("JunkDumpButtonWin", "topright", "EA_Window_InteractionStoreTitleBar", "topright", -35, -10)
    WindowSetParent("JunkDumpButtonWin", "EA_Window_InteractionStore")
    ButtonSetText("JunkDumpButtonWin", L"Sell Junk")

    -- Hook backpack click safely
    if not slotHook then
        slotHook = EA_Window_Backpack.EquipmentLButtonDown
        EA_Window_Backpack.EquipmentLButtonDown = JunkDump.InventoryLButtonDown
    end

    JunkDump.StartListeners()
    JunkDump.resetSlotMarkers()

    d("JunkDump Loaded...")
    langStrings = JunkDumpLocalization.getMainStrings(SystemData.Settings.Language.active)
    print(L"" .. langStrings[2] .. AddonVersion .. langStrings[3])
end

-- function found in moth for gendermarkup removal... 
function JunkDump.RemoveGenderGrammarMarkup(input)
    local pattern

    if type(input) == "string" then
        pattern = "([^^]+)^?([^^]*)"
    elseif type(input) == "wstring" then
        pattern = L"([^^]+)^?([^^]*)"
    else
        return input
    end

    local normal, control = input:match(pattern)
    return control and normal or input
end

function JunkDump.InventoryLButtonDown(slot, flags)
    if flags == 12 then
        JunkDump.ProcessExceptions(slot)
    elseif flags == 40 then
        JunkDump.ProcessAdditions(slot)
    else
        slotHook(slot, flags)
    end
end

function JunkDump.ProcessExceptions(slot)
    local itemData = GetInventoryItemData()
    local itemName = itemData[slot].name

    local settings = JunkDumpSettings[JunkDump.ServerNameString][JunkDump.CharacterNameString]
    local exceptions = settings.ItemExceptions

    if JunkDump.checkExceptions(itemName) then
        JunkDump.removeFromArrayByName(exceptions, itemName)
        print(L"" .. langStrings[4] .. itemName .. langStrings[5])
    else
        tinsert(exceptions, itemName)
        print(L"" .. langStrings[6] .. exceptions[#exceptions] .. langStrings[7])
    end
end

function JunkDump.ProcessAdditions(slot)
    local itemData = GetInventoryItemData()
    local itemName = itemData[slot].name

    local settings = JunkDumpSettings[JunkDump.ServerNameString][JunkDump.CharacterNameString]
    local additions = settings.ItemAdditions

    if JunkDump.checkAdditions(itemName) then
        JunkDump.removeFromArrayByName(additions, itemName)
        print(L"" .. langStrings[4] .. itemName .. langStrings[8])
    else
        tinsert(additions, itemName)
        print(L"" .. langStrings[6] .. additions[#additions] .. langStrings[9])
    end
end

function JunkDump.SlashHandler(args)
    local opt, val = args:match(L"([a-z0-9]+)[ ]?(.*)")

    local settings = JunkDumpSettings[JunkDump.ServerNameString][JunkDump.CharacterNameString]
    local exceptions = settings.ItemExceptions
    local additions  = settings.ItemAdditions

    if not opt then
        print(langStrings[27])
        print(langStrings[28])
        print(langStrings[29])
        print(langStrings[31])
        return
    end

    if opt == L"exceptions" then
        local opt2, val2 = val:match(L"([a-z0-9]+)[ ]?(.*)")

        if opt2 == L"list" or not opt2 then
            print(langStrings[10])
            for k, v in pairs(exceptions) do
                print(k .. L". " .. v)
            end

        elseif opt2 == L"del" then
            print(L"" .. langStrings[4] .. JunkDump.removeFromArray(exceptions, val2) .. langStrings[5])
        end

        return
    end

    if opt == L"additions" then
        local opt2, val2 = val:match(L"([a-z0-9]+)[ ]?(.*)")

        if opt2 == L"list" or not opt2 then
            print(langStrings[11])
            for k, v in pairs(additions) do
                print(k .. L". " .. v)
            end

        elseif opt2 == L"del" then
            print(L"" .. langStrings[4] .. JunkDump.removeFromArray(additions, val2) .. langStrings[8])
        end

        return
    end

    if opt == L"options" then
        JunkDumpOptions.Show()
        return
    end

    print(langStrings[12])
end

function JunkDump.OnShutdown()
	JunkDump.StopListeners()
end

function JunkDump.StartListeners()
    -- Register the handler for when the store interaction starts
    RegisterEventHandler(SystemData.Events.INTERACT_SHOW_STORE, "JunkDump.processBackpack")
    
    -- Register the handler for when the store interaction ends
    RegisterEventHandler(SystemData.Events.INTERACT_DONE, "JunkDump.Finalize")
end

function JunkDump.StopListeners()
    -- Unregister the handler for when the store interaction starts
    UnregisterEventHandler(SystemData.Events.INTERACT_SHOW_STORE, "JunkDump.processBackpack")
    
    -- Unregister the handler for when the store interaction ends
    UnregisterEventHandler(SystemData.Events.INTERACT_DONE, "JunkDump.Finalize")
end

function JunkDump.removeFromArray(array, value)
    local index = tonumber(WStringToString(value))
    if index and index > 0 and index <= #array then
        local temp = array[index]
        tremove(array, index)
        return temp
    end
    return langStrings[22]
end

function JunkDump.removeFromArrayByName(array, value)
    for k, v in pairs(array) do
        if v == value then
            local temp = array[k]
            tremove(array, k)
            return temp
        end
    end
    return langStrings[22]
end

function JunkDump.Finalize()
	if #JDitemList == 0 and JDshowMoney == 1 then
		JunkDump.showMeDaMoney()
	end
	JDshowMoney = 0
	JDitemList = {}
	JDreportList = {}
	JunkDump.resetSlotMarkers()
end

function JunkDump.resetSlotMarkers()
	for i=1,GameData.Player.numBackpackSlots do
		slotMarker[i] = 0
	end
end

function JunkDump.resetCraftingSlotMarkers()
	for i=1,GameData.Player.numCraftingSlots*16+16 do
		craftingSlotMarker[i] = 0
	end
end

function JunkDump.resetTestModeSlotMarkers()
	for i=1,GameData.Player.numBackpackSlots do
		TestModeSlotMarker[i] = 0
		TestModeCraftingSlotMarker[i] = 0
	end
end

function JunkDump.resetTestModeCraftingSlotMarkers()
	for i=1,GameData.Player.numCraftingSlots*16+16 do
		TestModeCraftingSlotMarker[i] = 0
	end
end

function JunkDump.JunkBackpack()
    JDStartMoney = Player.GetMoney()
    JunkDump.doTheSale()
end

function JunkDump.processBackpack()
    local BpData = GetInventoryItemData()
    local CBpData = GetCraftingItemData()

    if #JDitemList > 0 then
        local temp = JDitemList[1]
        tremove(JDitemList, 1)

        if temp[2] == EA_Window_Backpack.TYPE_INVENTORY then
            JunkDump.SellItem(temp[2], temp[1], BpData)
        elseif temp[2] == EA_Window_Backpack.TYPE_CRAFTING then
            JunkDump.SellItem(temp[2], temp[1], CBpData)
        end
    else
        JunkDump.resetSlotMarkers()
        JunkDump.resetCraftingSlotMarkers()
    end
end

function JunkDump.SellItem(backpackType, inventorySlot, BpData)
    local item = BpData[inventorySlot]
    if not item then return end

    GameData.InteractStoreData.CurrentItemIndex = inventorySlot
    GameData.InteractStoreData.NumItems = item.stackCount
    GameData.InteractStoreData.CurrentBackpackIndex = backpackType

    BroadcastEvent(SystemData.Events.INTERACT_SELL_ITEM)
end

function JunkDump.doTheSale()
    local BpData  = GetInventoryItemData()
    local CBpData = GetCraftingItemData()

    local settings = JunkDumpSettings[JunkDump.ServerNameString][JunkDump.CharacterNameString]
    local bagMode = settings.BagMode
    local rarityThreshold = settings.RarityThreshold
    local ignoreProfession = settings.IgnoreProfessionRarity == 1

    -- === Normal Mode ===
    if bagMode == 0 then
        for rarity = rarityThreshold, 1, -1 do
            -- Inventory
            for slot, item in pairs(BpData) do
                if slotMarker[slot] == 0 then
                    local name = item.name

                    if JunkDump.checkAdditions(name) and JunkDump.defaultChecks(item) then
                        tinsert(JDitemList, {slot, EA_Window_Backpack.TYPE_INVENTORY})
                        tinsert(JDreportList, name)
                        slotMarker[slot] = 1

                    elseif ignoreProfession
                        and JunkDump.professionChecks2(item)
                        and not IsSlotLocked(slot)
                        and not JunkDump.dyeCheck(item)
                        and not JunkDump.checkExceptions(name)
                    then
                        tinsert(JDitemList, {slot, EA_Window_Backpack.TYPE_INVENTORY})
                        tinsert(JDreportList, name)
                        slotMarker[slot] = 1

                    elseif JunkDump.runAllChecks(item, rarity)
                        and JunkDump.professionChecks(item)
                        and not IsSlotLocked(slot)
                    then
                        tinsert(JDitemList, {slot, EA_Window_Backpack.TYPE_INVENTORY})
                        tinsert(JDreportList, name)
                        slotMarker[slot] = 1
                    end
                end
            end

            -- Crafting
            for slot, item in pairs(CBpData) do
                if craftingSlotMarker[slot] == 0 then
                    local name = item.name

                    if JunkDump.checkAdditions(name) and JunkDump.defaultChecks(item) then
                        tinsert(JDitemList, {slot, EA_Window_Backpack.TYPE_CRAFTING})
                        tinsert(JDreportList, name)
                        craftingSlotMarker[slot] = 1

                    elseif ignoreProfession
                        and JunkDump.professionChecks2(item)
                        and not IsSlotLocked(slot)
                        and not JunkDump.dyeCheck(item)
                        and not JunkDump.checkExceptions(name)
                    then
                        tinsert(JDitemList, {slot, EA_Window_Backpack.TYPE_CRAFTING})
                        tinsert(JDreportList, name)
                        craftingSlotMarker[slot] = 1

                    elseif JunkDump.runAllChecks(item, rarity)
                        and JunkDump.professionChecks(item)
                        and not IsSlotLocked(slot)
                    then
                        tinsert(JDitemList, {slot, EA_Window_Backpack.TYPE_CRAFTING})
                        tinsert(JDreportList, name)
                        craftingSlotMarker[slot] = 1
                    end
                end
            end
        end
    end

    -- === Bag Mode ===
    if bagMode == 1 then
        local endBagSlot   = settings.BagModeBag * 16
        local startBagSlot = endBagSlot - 15

        for slot = startBagSlot, endBagSlot do
            local item = BpData[slot]
            if item and item.uniqueID ~= 0 and item.sellPrice ~= 0 then
                tinsert(JDitemList, {slot, EA_Window_Backpack.TYPE_INVENTORY})
                tinsert(JDreportList, item.name)
                slotMarker[slot] = 1
            end
        end
    end

    JDshowMoney = 1
    JunkDump.processBackpack()
end

function JunkDump.runAllChecks(itemData, rarity)
	local defaultCheck = false
	local rarityEqual = false
	if (itemData.rarity == rarity) then
		rarityEqual = true
	end
	if JunkDump.defaultChecks(itemData) then
		defaultCheck = true
	end
	if defaultCheck == false then
		return false
	end
	if JunkDump.checkExceptions(itemData.name) and defaultCheck then
		return false
	end
	if JunkDump.checkIfMount(itemData.uniqueID) and defaultCheck then
		return false
	end
	if JunkDump.dyeCheck(itemData) and defaultCheck then
		return false
	end
	if not(rarityEqual) then
		return false
	end
	return true
end

function JunkDump.defaultChecks(itemData)
	if itemData.uniqueID ~= 0 and itemData.sellPrice ~= 0 then
		return true
	end
	return false
end

function JunkDump.professionChecks(itemData)
    local settings = JunkDumpSettings[JunkDump.ServerNameString][JunkDump.CharacterNameString]
    local craftData = CraftingSystem.GetCraftingData(itemData)
    local craftType = craftData[1]
    local req = itemData.craftingSkillRequirement

    -- Apothecary
    if craftType == 4 and (settings.SellApoth == 0 or req > settings.ApothMax) then
        return false
    end

    -- Talisman
    if craftType == 5 and (settings.SellTalisman == 0 or req > settings.TalismanMax) then
        return false
    end

    -- Cultivation
    if itemData.cultivationType > 0 and (settings.SellCultivation == 0 or req > settings.CultivationMax) then
        return false
    end

    -- Salvaging
    if craftType == 6 and (settings.SellSalvaging == 0 or req > settings.SalvagingMax) then
        return false
    end

    return true
end


function JunkDump.professionChecks2(itemData)
    local settings = JunkDumpSettings[JunkDump.ServerNameString][JunkDump.CharacterNameString]
    local craftData = CraftingSystem.GetCraftingData(itemData)
    local craftType = craftData[1]
    local req = itemData.craftingSkillRequirement

    -- Apothecary
    if craftType == 4 and settings.SellApoth == 1 and req <= settings.ApothMax then
        return true
    end

    -- Talisman
    if craftType == 5 and settings.SellTalisman == 1 and req <= settings.TalismanMax then
        return true
    end

    -- Cultivation
    if itemData.cultivationType > 0 and settings.SellCultivation == 1 and req <= settings.CultivationMax then
        return true
    end

    -- Salvaging
    if craftType == 6 and settings.SellSalvaging == 1 and req <= settings.SalvagingMax then
        return true
    end

    return false
end

function JunkDump.dyeCheck(itemData)
    local itemName = WStringToString(itemData.name)
    local _, isDye = itemName:match("(.*)%s(Dye)")
    return isDye == "Dye"
end

function JunkDump.showMeDaMoney()
    local endMoney = PlayerGetMoney()
    local totalMoney = endMoney - JDStartMoney

    local stringMoney
    if totalMoney > 0 then
        stringMoney = FormatMoney(totalMoney) .. L"."
    else
        stringMoney = L"no money."
    end

    local stringOfItems = L""
    local count = #JDreportList

    for i = 1, count do
        if i < count then
            stringOfItems = stringOfItems .. JDreportList[i] .. L", "
        else
            stringOfItems = stringOfItems .. JDreportList[i] .. L"."
        end
    end

    local settings = JunkDumpSettings[JunkDump.ServerNameString][JunkDump.CharacterNameString]

    if settings.ShowItemsReport == 1 then
        print(L"[JunkDump] " .. langStrings[23] .. stringOfItems)
    end

    if settings.ShowGoldReport == 1 then
        print(L"[JunkDump] " .. langStrings[24] .. stringMoney)
    end

    JDreportList = {}
end

function JunkDump.checkExceptions(itemName)
	for i,v in pairs(JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ItemExceptions) do
		if v == itemName then
			return true
		end
	end
	return false
end

function JunkDump.checkAdditions(itemName)
	for i,v in pairs(JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ItemAdditions) do
		if v == itemName then
			return true
		end
	end
	return false
end

-- define once, outside the function
local mountIdTable = {
    -- Boars
    [208017]=true, [208016]=true, [208015]=true, [186818]=true, [186817]=true,
    [186816]=true, [186815]=true, [186814]=true, [186813]=true,

    -- Wolves
    [208011]=true, [208010]=true, [208009]=true, [186812]=true, [186811]=true,
    [186810]=true, [186809]=true, [186808]=true, [186807]=true,

    -- Chaos Horses
    [208028]=true, [208026]=true, [208025]=true, [186830]=true, [186829]=true,
    [186828]=true, [186827]=true, [186826]=true, [186825]=true,

    -- Cold Ones
    [208040]=true, [208039]=true, [208037]=true, [186842]=true, [186841]=true,
    [186840]=true, [186839]=true, [186838]=true, [186837]=true,

    -- Copters
    [208005]=true, [208004]=true, [208003]=true, [186806]=true, [186805]=true,
    [186804]=true, [186803]=true, [186802]=true, [186801]=true,

    -- Horses
    [208023]=true, [208022]=true, [208021]=true, [186824]=true, [186823]=true,
    [186822]=true, [186821]=true, [186820]=true, [186819]=true,

    -- Fancy Horses
    [208034]=true, [208033]=true, [208031]=true, [186836]=true, [186835]=true,
    [186834]=true, [186833]=true, [186832]=true, [186831]=true,

    -- Magus Hoverboards
    [186843]=true, [186844]=true, [186845]=true, [186852]=true, [208045]=true,
    [208046]=true, [208047]=true,

    -- Manticore / Griffon
    [207287]=true, [207388]=true, [207389]=true, [207390]=true, [207391]=true,

    -- Teleport Scroll
    [65825]=true,
}

function JunkDump.checkIfMount(itemId)
    return mountIdTable[itemId] == true
end

function JunkDump.getMaxBags()
    return math_floor(GameData.Player.numBackpackSlots / 16)
end

function JunkDump.OnMouseOverButton()
    if not langStrings or not langStrings[25] then return end

    Tooltips.CreateTextOnlyTooltip("JunkDumpButtonWin")
    Tooltips.SetTooltipText(1, 1, langStrings[25])
    Tooltips.SetTooltipText(2, 1, langStrings[26])
    Tooltips.Finalize()
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_LEFT)
end

function JunkDump.SetTestModeTint(backpackType, slot, passedHighLightColor)
    local pocketNumber = EA_Window_Backpack.GetPocketNumberForSlot(backpackType, slot)
    
    -- Check if pocketNumber is valid
    if pocketNumber == nil then
        d("Error: pocketNumber is nil.")
        return
    end

    -- Ensure the pocket exists in the EA_Window_Backpack.pockets table
    local pocket = EA_Window_Backpack.pockets[pocketNumber]
    if not pocket then
        d("Error: Pocket does not exist for pocketNumber: " .. tostring(pocketNumber))
        return
    end

    local pocketWindowName = EA_Window_Backpack.GetPocketName(pocketNumber)
    local buttonGroupWindowName = pocketWindowName .. "Buttons"
    local buttonIndex = slot - pocket.firstSlotID + 1

    -- Verify the buttonGroupWindow exists before trying to set its color
    if DoesWindowExist(buttonGroupWindowName) then
        ActionButtonGroupSetTintColor(buttonGroupWindowName, buttonIndex, passedHighLightColor.r, passedHighLightColor.g, passedHighLightColor.b)
    else
        d("Error: Window does not exist: " .. buttonGroupWindowName)
    end
end


function JunkDump.TestModeRun()
    local BpData  = GetInventoryItemData()
    local CBpData = GetCraftingItemData()

    local settings = JunkDumpSettings[JunkDump.ServerNameString][JunkDump.CharacterNameString]
    local bagMode = settings.BagMode
    local rarityThreshold = settings.RarityThreshold
    local ignoreProfession = settings.IgnoreProfessionRarity == 1

    -- === Normal Mode ===
    if bagMode == 0 then
        for rarity = rarityThreshold, 1, -1 do

            -- Inventory
            for slot, item in pairs(BpData) do
                if TestModeSlotMarker[slot] == 0 then
                    local name = item.name

                    if JunkDump.checkAdditions(name) and JunkDump.defaultChecks(item) then
                        tinsert(TestModeList, {slot, EA_Window_Backpack.TYPE_INVENTORY})
                        TestModeSlotMarker[slot] = 1

                    elseif ignoreProfession
                        and JunkDump.professionChecks2(item)
                        and not IsSlotLocked(slot)
                        and not JunkDump.dyeCheck(item)
                        and not JunkDump.checkExceptions(name)
                    then
                        tinsert(TestModeList, {slot, EA_Window_Backpack.TYPE_INVENTORY})
                        TestModeSlotMarker[slot] = 1

                    elseif JunkDump.runAllChecks(item, rarity)
                        and JunkDump.professionChecks(item)
                        and not IsSlotLocked(slot)
                    then
                        tinsert(TestModeList, {slot, EA_Window_Backpack.TYPE_INVENTORY})
                        TestModeSlotMarker[slot] = 1
                    end
                end
            end

            -- Crafting
            for slot, item in pairs(CBpData) do
                if TestModeCraftingSlotMarker[slot] == 0 then
                    local name = item.name

                    if JunkDump.checkAdditions(name) and JunkDump.defaultChecks(item) then
                        tinsert(TestModeList, {slot, EA_Window_Backpack.TYPE_CRAFTING})
                        TestModeCraftingSlotMarker[slot] = 1

                    elseif ignoreProfession
                        and JunkDump.professionChecks2(item)
                        and not IsSlotLocked(slot)
                        and not JunkDump.dyeCheck(item)
                        and not JunkDump.checkExceptions(name)
                    then
                        tinsert(TestModeList, {slot, EA_Window_Backpack.TYPE_CRAFTING})
                        TestModeCraftingSlotMarker[slot] = 1

                    elseif JunkDump.runAllChecks(item, rarity)
                        and JunkDump.professionChecks(item)
                        and not IsSlotLocked(slot)
                    then
                        tinsert(TestModeList, {slot, EA_Window_Backpack.TYPE_CRAFTING})
                        TestModeCraftingSlotMarker[slot] = 1
                    end
                end
            end
        end
    end

    -- === Bag Mode ===
    if bagMode == 1 then
        local endBagSlot   = settings.BagModeBag * 16
        local startBagSlot = endBagSlot - 15

        for slot = startBagSlot, endBagSlot do
            local item = BpData[slot]
            if item and item.uniqueID ~= 0 and item.sellPrice ~= 0 then
                tinsert(TestModeList, {slot, EA_Window_Backpack.TYPE_INVENTORY})
                TestModeSlotMarker[slot] = 1
            end
        end
    end

    JunkDump.TestModeHighlight()
end

function JunkDump.TestModeHighlight()
    local list = TestModeList

    for i = 1, #list do
        local entry = list[i]
        JunkDump.SetTestModeTint(entry[2], entry[1], TestModeHighLightColor)
    end

    TestModeList = {}
    JunkDump.resetTestModeSlotMarkers()
    JunkDump.resetTestModeCraftingSlotMarkers()
end


function JunkDump.TestModeClear()
    local invSlots = GameData.Player.numBackpackSlots
    local craftSlots = GameData.Player.numCraftingSlots * 16 + 16

    for i = 1, invSlots do
        JunkDump.SetTestModeTint(EA_Window_Backpack.TYPE_INVENTORY, i, ClearHighLightColor)
    end

    for i = 1, craftSlots do
        JunkDump.SetTestModeTint(EA_Window_Backpack.TYPE_CRAFTING, i, ClearHighLightColor)
    end
end
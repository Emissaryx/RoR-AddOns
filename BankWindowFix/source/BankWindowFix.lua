----------------------------------------------------------------
-- BankWindowFix
----------------------------------------------------------------

BankWindowFix = {}

local WINDOW_NAME = "BankWindow"
local SLOTS_NAME = WINDOW_NAME .. "Slots"
local NUM_COLS, NUM_ROWS = 8, 10
local ENABLE_CTRLRCLICK_DELETE = false

-- Localize frequently used functions for slight performance improvement
local RequestMoveItem = RequestMoveItem
local IsValidItem = DataUtils.IsValidItem
local GetBankData = DataUtils.GetBankData
local GetItems = DataUtils.GetItems
local IsSlotLocked = EA_Window_Backpack.IsSlotLocked

----------------------------------------------------------------
-- Initialization
----------------------------------------------------------------
function BankWindowFix.Initialize()
    -- Hook bank right-click
    BankWindow.EquipmentRButtonDown = BankWindowFix.BankEquipmentRButtonDown

    -- Replace bank slots with fixed version
    DestroyWindow(SLOTS_NAME)
    CreateWindowFromTemplate(SLOTS_NAME, "BankWindowSlotsFixed", WINDOW_NAME)
    ActionButtonGroupSetNumButtons(SLOTS_NAME, NUM_ROWS, NUM_COLS)

    -- Hook backpack right-click for stacking
    EA_Window_Backpack.EquipmentRButtonUp = BankWindowFix.BagEquipmentRButtonUp
end

----------------------------------------------------------------
-- Bank RButton Down Handler
----------------------------------------------------------------
function BankWindowFix.BankEquipmentRButtonDown(buttonIndex, flags)
    local slot = BankWindow.GetSlotNumberForButtonIndex(buttonIndex)
    local itemData = BankWindow.GetItem(slot)

    if not Cursor.IconOnCursor() and IsValidItem(itemData) then
        if (flags == SystemData.ButtonFlags.SHIFT) and itemData.stackCount > 1 then
            ItemStackingWindow.Show(Cursor.SOURCE_BANK, slot)
        else
            local invItems = GetItems()
            BankWindowFix.MoveAndStack(itemData, slot, invItems, Cursor.SOURCE_BANK, Cursor.SOURCE_INVENTORY)
        end
    end
end

----------------------------------------------------------------
-- Move and Stack Logic
----------------------------------------------------------------
function BankWindowFix.MoveAndStack(itemData, slot, invItems, source, target)
    if not invItems then return end

    local startSlot = 1
    if target == Cursor.SOURCE_BANK then
        startSlot = (BankWindow.currentTabNumber - 1) * 80 + 1
    end

    local stackLeft = itemData.stackCount

    -- Try to stack with existing items
    if itemData.capacity > 1 then
        for i = startSlot, #invItems do
            local item = invItems[i]
            if item.uniqueID == itemData.uniqueID and item.capacity > item.stackCount then
                local freeSlots = math.min(item.capacity - item.stackCount, stackLeft)
                RequestMoveItem(source, slot, target, i, freeSlots)
                stackLeft = stackLeft - freeSlots
                if stackLeft < 1 then return end
            end
        end
    end

    -- Place leftovers in empty slot
    for i = startSlot, #invItems do
        if invItems[i].id == 0 then
            RequestMoveItem(source, slot, target, i, stackLeft)
            return
        end
    end
end

----------------------------------------------------------------
-- Backpack RButton Up Handler
----------------------------------------------------------------
function BankWindowFix.BagEquipmentRButtonUp(slot, flags)
    local inventory = EA_Window_Backpack.GetItemsFromBackpack(EA_Window_Backpack.currentMode)
    local itemData = inventory[slot]
    if not itemData or itemData.id == 0 then return end

    local cursorType = EA_Window_Backpack.GetCursorForBackpack(EA_Window_Backpack.currentMode)
    local shiftPressed = (flags == SystemData.ButtonFlags.SHIFT)
    local controlPressed = (flags == SystemData.ButtonFlags.CONTROL)
    local atStore = (EA_Window_InteractionStore and EA_Window_InteractionStore.InteractingWithStore()) or
                    (EA_Window_InteractionLibrarianStore and EA_Window_InteractionLibrarianStore.InteractingWithLibrarianStore())
    local atRepairMan = EA_Window_InteractionStore.InteractingWithRepairMan() or
                        EA_Window_InteractionLibrarianStore.InteractingWithRepairMan()
    local isTrading = EA_Window_Trade.TradeOpen()
    local isMailing = WindowGetShowing("MailWindow") and WindowGetShowing("MailWindowTabSend")
    local isBankOpen = BankWindow.IsShowing()
    local isGuildVaultOpen = GuildVaultWindow.IsVaultOpen()

    -- Handle locked slots
    local slotIsLocked, lockingWindow = IsSlotLocked(slot, EA_Window_Backpack.currentMode)
    if slotIsLocked then
        if lockingWindow.windowName == "EA_Window_Trade" then
            EA_Window_Trade.ClearInventoryItem(slot, EA_Window_Backpack.currentMode)
        elseif itemData.stackCount > 1 then
            EA_Window_Backpack.AutoAddCraftingItemIfPossible(slot)
        end
        return
    end

    -- Stack window if Shift pressed
    if shiftPressed and itemData.stackCount > 1 then
        ItemStackingWindow.Show(cursorType, slot)
        return
    end

    -- Handle interactions
    if not atStore and not atRepairMan then
        BankWindowFix.HandleBackpackItemActions(slot, itemData, cursorType, controlPressed, shiftPressed,
            isTrading, isMailing, isBankOpen, isGuildVaultOpen)
        return
    end

    -- Handle store/repair interactions
    BankWindowFix.HandleStoreAndRepair(itemData, slot, atRepairMan, atStore)
end

----------------------------------------------------------------
-- Backpack Item Action Logic
----------------------------------------------------------------
function BankWindowFix.HandleBackpackItemActions(slot, itemData, cursorType, controlPressed, shiftPressed,
    isTrading, isMailing, isBankOpen, isGuildVaultOpen)

    if isTrading then
        EA_Window_Trade.AddInventoryItem(slot, EA_Window_Backpack.currentMode)
    elseif EA_Window_Backpack.AutoAddCraftingItemIfPossible(slot) then
        return
    elseif EquipmentUpgradeWindow and EquipmentUpgradeWindow.AddItem(EA_Window_Backpack.currentMode, slot) then
        return
    elseif EA_Window_Backpack.IsRefinable(itemData) then
        if controlPressed then
            EA_Window_Backpack.ConfirmThenRefine(slot, EA_Window_Backpack.currentMode)
        elseif DataUtils.IsTradeSkillItem(itemData) or itemData.type == GameData.ItemTypes.CURRENCY then
            TransferBetweenBackpacks(slot, EA_Window_Backpack.currentMode)
        end
    elseif controlPressed and ENABLE_CTRLRCLICK_DELETE then
        BankWindowFix.ConfirmDestroyItem(cursorType, slot, itemData)
    elseif isBankOpen then
        BankWindowFix.MoveAndStack(itemData, slot, GetBankData(), cursorType, Cursor.SOURCE_BANK)
    elseif isGuildVaultOpen then
        GuildVaultWindow.OnRButtonUpBackpack(slot)
    elseif isMailing then
        MailWindowTabSend.AttachItem(slot)
    elseif (itemData.numEnhancementSlots > 0) and shiftPressed then
        BeginItemEnhancement(slot)
    elseif itemData.equipSlot > 0 or itemData.type == GameData.ItemTypes.TROPHY then
        CharacterWindow.AutoEquipItem(slot)
    elseif DataUtils.IsTradeSkillItem(itemData) or itemData.type == GameData.ItemTypes.CURRENCY then
        TransferBetweenBackpacks(slot, EA_Window_Backpack.currentMode)
    else
        BankWindowFix.UseItem(itemData, cursorType, slot)
    end
end

----------------------------------------------------------------
-- Confirm Destroy Item
----------------------------------------------------------------
function BankWindowFix.ConfirmDestroyItem(cursorType, slot, itemData)
    if IsValidItem(itemData) then
        local text = GetStringFormat(StringTables.Default.LABEL_TEXT_DESTROY_ITEM_CONFIRM, { itemData.name })
        DialogManager.MakeTwoButtonDialog(
            text,
            GetString(StringTables.Default.LABEL_YES),
            function() DestroyItem(cursorType, slot) end,
            GetString(StringTables.Default.LABEL_NO),
            nil, nil, nil, nil, nil, nil,
            DIALOGID_DESTROY_ITEM
        )
    end
end

----------------------------------------------------------------
-- Use Item Helper
----------------------------------------------------------------
function BankWindowFix.UseItem(itemData, cursorType, slot)
    local isHandled = UseItemTargeting.HandleUseItemChangeTargetCursor(cursorType, slot)
    if not isHandled and not ItemUtils.ShowUseOptions(itemData, GameData.ItemLocs.INVENTORY, slot) then
        SendUseItem(GameData.ItemLocs.INVENTORY, slot, 0, 0, 0)
    end
end

----------------------------------------------------------------
-- Handle Store and Repair
----------------------------------------------------------------
function BankWindowFix.HandleStoreAndRepair(itemData, slot, atRepairMan, atStore)
    if atRepairMan and itemData.broken and itemData.repairPrice > 0 and itemData.repairedName and itemData.repairedName ~= L"" then
        if GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_DEFAULT then
            EA_Window_InteractionStore.ConfirmThenRepairItem(slot)
        else
            EA_Window_InteractionLibrarianStore.ConfirmThenRepairItem(slot)
        end
    elseif atStore and itemData.sellPrice > 0 and not itemData.flags[GameData.Item.EITEMFLAG_NO_SELL] and
        (not EA_Window_InteractionStore.repairModeOn or not EA_Window_InteractionLibrarianStore.repairModeOn) then
        if GameData.InteractStoreData.LibrarianType == GameData.InteractStoreData.STORE_TYPE_DEFAULT then
            EA_Window_InteractionStore.ConfirmThenSellItem(slot, itemData.stackCount)
        else
            EA_Window_InteractionLibrarianStore.ConfirmThenSellItem(slot, itemData.stackCount)
        end
    end
end

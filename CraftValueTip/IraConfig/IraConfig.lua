--[[
  IraConfig ((Lib) Ira Config) version 1.06
  by Irinia of Volkmar

  This library manages a configuration window for add-ons and provides
  utility functions for controls.

  This file handles the main window and addon registration.
--]]

IraConfig = IraConfig or {}
local ic = IraConfig

local bIsOpen = false

ic.CALLBACK_SHOWN   = 1
ic.CALLBACK_HIDDEN  = 2
ic.CALLBACK_SAVE    = 3
ic.CALLBACK_CLOSE   = 4
ic.CALLBACK_RESET   = 5
ic.CALLBACK_OPEN    = 6
ic.CALLBACK_RESIZE  = 7

ic.vAddons    = ic.vAddons or {}
ic.nNextPane  = ic.nNextPane or 1

-- Internal helper to send a message to all registered addons
local function BroadcastMessage(messageId)
    for index, addon in pairs(ic.vAddons) do
        local callback = addon.callback
        if callback then
            callback(messageId, index)
        end
    end
end

-- Internal helper to safely fetch an addon entry
local function GetAddon(index)
    local addon = ic.vAddons[index]
    if addon and type(addon.callback) == "function" then
        return addon
    end
    return nil
end

function ic.Initialize()
    if ic.initialized then
        return
    end
    ic.initialized = true

    CreateWindow("IraConfig", false)
    WindowSetShowing("IraConfig", false)

    ic.CreateTabSet("IraConfigTabs", 550, 50)

    if StringTables.Pregame ~= nil and StringTables.Pregame.LABEL_UI_MOD_SETTINGS ~= nil then
        LabelSetText("IraConfigTitleBarText", GetPregameString(StringTables.Pregame.LABEL_UI_MOD_SETTINGS))
    else
        LabelSetText("IraConfigTitleBarText", L"Mod Settings")
    end

    ButtonSetText("IraConfigOkayButton",   GetString(StringTables.Default.LABEL_OKAY))
    ButtonSetText("IraConfigApplyButton",  GetString(StringTables.Default.LABEL_APPLY))
    ButtonSetText("IraConfigResetButton",  GetString(StringTables.Default.LABEL_RESET))
    ButtonSetText("IraConfigCancelButton", GetString(StringTables.Default.LABEL_CANCEL))

    ic.HelpInit()
end

function ic.Open(tabIndex)
    WindowSetShowing("IraConfig", true)

    if not bIsOpen then
        bIsOpen = true

        BroadcastMessage(ic.CALLBACK_OPEN)
        ic.UpdateScrollBars()
        BroadcastMessage(ic.CALLBACK_RESET)
    end

    if tabIndex then
        ic.SetActiveTab("IraConfigTabs", tabIndex)
    end
end

function ic.Close()
    if not bIsOpen then
        WindowSetShowing("IraConfig", false)
        return
    end

    bIsOpen = false
    BroadcastMessage(ic.CALLBACK_CLOSE)
    WindowSetShowing("IraConfig", false)
end

function ic.OnOkay()
    BroadcastMessage(ic.CALLBACK_SAVE)
    BroadcastMessage(ic.CALLBACK_CLOSE)
    bIsOpen = false
    WindowSetShowing("IraConfig", false)
end

function ic.OnApply()
    BroadcastMessage(ic.CALLBACK_SAVE)
end

function ic.OnReset()
    BroadcastMessage(ic.CALLBACK_RESET)
end

function ic.UpdateScrollBars()
    for index, addon in pairs(ic.vAddons) do
        local callback = addon.callback
        if callback then
            callback(ic.CALLBACK_RESIZE, index)
        end

        local pane = addon.pane
        if pane then
            ScrollWindowUpdateScrollRect(pane)
        end
    end
end

local function TabCallback(messageId, tabIndex)
    local addon = GetAddon(tabIndex)
    if not addon then
        return
    end

    addon.callback(messageId, tabIndex)

    if messageId == ic.CALLBACK_SHOWN and addon.pane then
        ScrollWindowUpdateScrollRect(addon.pane)
    end
end

-- Register addon with scrolling pane
function ic.RegisterAddon(tabText, tipText, panelName, callback)
    if type(callback) ~= "function" then
        ERROR(L"RegisterAddon: callback must be a function")
        return nil
    end

    local width, height = WindowGetDimensions(panelName)
    if not width or not height then
        ERROR(L"RegisterAddon: invalid panel window name")
        return nil
    end

    local paneName = "IraConfigPane" .. ic.nNextPane
    ic.nNextPane = ic.nNextPane + 1

    CreateWindowFromTemplate(paneName, "IraConfigScrollTab", "IraConfigClient")
    WindowSetShowing(paneName, false)

    local tabIndex = ic.AddTab("IraConfigTabs", tabText, tipText, paneName, TabCallback)

    ic.vAddons[tabIndex] = {
        callback = callback,
        pane     = paneName,
    }

    WindowSetDimensions(paneName .. "Child", width, height)
    WindowSetParent(panelName, paneName .. "Child")
    WindowClearAnchors(panelName)
    WindowSetShowing(panelName, true)

    ic.UpdateScrollBars()
    return tabIndex
end

-- Register addon without scroll
-- The client area can shrink. If you need scroll, you must handle it yourself.
function ic.RegisterAddonNoScroll(tabText, tipText, panelName, callback)
    if type(callback) ~= "function" then
        ERROR(L"RegisterAddonNoScroll: callback must be a function")
        return nil
    end

    WindowSetShowing(panelName, false)

    local width, height = WindowGetDimensions(panelName)
    if not width or not height then
        ERROR(L"RegisterAddonNoScroll: invalid panel window name")
        return nil
    end

    local tabIndex = ic.AddTab("IraConfigTabs", tabText, tipText, panelName, TabCallback)

    ic.vAddons[tabIndex] = {
        callback = callback,
        pane     = nil,  -- no scroll pane
    }

    WindowSetParent(panelName, "IraConfigClient")
    WindowClearAnchors(panelName)
    WindowAddAnchor(panelName, "topleft",     "IraConfigClient", "topleft",     0, 0)
    WindowAddAnchor(panelName, "bottomright", "IraConfigClient", "bottomright", 0, 0)

    ic.UpdateScrollBars()
    return tabIndex
end
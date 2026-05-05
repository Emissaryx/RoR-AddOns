--[[
  IraConfig ((Lib) Ira Config) version 1.07
  by Irinia of Volkmar

  This file handles tabsets.
--]]

IraConfig = IraConfig or {}
local ic = IraConfig

ic.vTabsets = ic.vTabsets or {}

local TIP_ANCHOR = {
    Point         = "left",
    RelativeTo    = "",
    RelativePoint = "left",
    XOffset       = 10,
    YOffset       = -3,
}

-- nLine is the window number, nLineNum is the position on screen
local function AnchorTabLine(container, lineIndex, linePosition)
    local lineName = container .. "Line" .. lineIndex

    WindowClearAnchors(lineName)
    WindowAddAnchor(lineName, "bottomleft",  container, "bottomleft",  0, (linePosition - 1) * -29)
    WindowAddAnchor(lineName, "bottomright", container, "bottomright", 0, (linePosition - 1) * -29)

    DynamicImageSetTextureDimensions(lineName .. "LeftDoink",  9, 14)
    DynamicImageSetTextureDimensions(lineName .. "RightDoink", 9, 14)

    local layer = 5 - linePosition
    if layer < 0 then
        layer = 0
    end
    WindowSetLayer(lineName, layer)
end

local function CreateTabLine(container, lineIndex)
    local lineName = container .. "Line" .. lineIndex

    CreateWindowFromTemplate(lineName, "IraConfigTabLine", container)

    local tabset = ic.vTabsets[container]
    WindowSetDimensions(lineName .. "SepLeft", tabset.margin, 5)

    WindowAddAnchor(lineName .. "LeftDoink",  "bottomleft",  container, "bottomleft",  0, 14)
    WindowAddAnchor(lineName .. "RightDoink", "bottomright", container, "bottomright", 0, 14)

    WindowSetId(lineName, lineIndex)

    local width, height = WindowGetDimensions(container)
    WindowSetDimensions(container, width, lineIndex * 29 + 10)
end

local function ArrangeLines(container)
    local tabset = ic.vTabsets[container]
    if not tabset then
        return
    end

    local displayPos = 1

    for lineIndex = tabset.firstline, tabset.lines do
        AnchorTabLine(container, lineIndex, displayPos)
        displayPos = displayPos + 1
    end

    if tabset.firstline ~= 1 then
        for lineIndex = 1, tabset.firstline - 1 do
            AnchorTabLine(container, lineIndex, displayPos)
            displayPos = displayPos + 1
        end
    end
end

-- Only show window if name is valid
local function SetShowing(windowName, show)
    if windowName and windowName ~= "" then
        WindowSetShowing(windowName, show)
    end
end

-- Perform callback if set
local function Callback(container, tabNumber, code)
    local tabset = ic.vTabsets[container]
    if not tabset or not tabset.tabs or not tabset.tabs[tabNumber] then
        return
    end

    local fn = tabset.tabs[tabNumber].callback
    if fn then
        fn(code, tabNumber)
    end
end

local function SetActiveTabInternal(container, newTabNumber)
    local tabset = ic.vTabsets[container]
    if not tabset or not tabset.tabs or not tabset.tabs[newTabNumber] then
        return
    end

    local tabName = container .. "Tab" .. newTabNumber
    local lineNumber = WindowGetId(WindowGetParent(tabName))

    local oldTab = tabset.selected or 1
    tabset.selected = newTabNumber
    tabset.firstline = lineNumber

    if oldTab == newTabNumber then
        return
    end

    -- Deactivate old tab
    local oldTabName = container .. "Tab" .. oldTab
    ButtonSetPressedFlag(oldTabName, false)
    ButtonSetStayDownFlag(oldTabName, false)
    SetShowing(tabset.tabs[oldTab].window, false)
    Callback(container, oldTab, ic.CALLBACK_HIDDEN)

    -- Activate new tab
    ButtonSetPressedFlag(tabName, true)
    ButtonSetStayDownFlag(tabName, true)
    SetShowing(tabset.tabs[newTabNumber].window, true)
    Callback(container, newTabNumber, ic.CALLBACK_SHOWN)

    ArrangeLines(container)
end

function ic.OnLButtonUpTab()
    local tabName   = SystemData.MouseOverWindow.name
    local tabNumber = WindowGetId(tabName)
    local container = WindowGetParent(WindowGetParent(tabName))

    SetActiveTabInternal(container, tabNumber)
end

function ic.OnMouseOverTab()
    local tabName   = SystemData.MouseOverWindow.name
    local tabNumber = WindowGetId(tabName)
    local container = WindowGetParent(WindowGetParent(tabName))
    local tabset    = ic.vTabsets[container]

    if not tabset or not tabset.tabs or not tabset.tabs[tabNumber] then
        return
    end

    local tip = tabset.tabs[tabNumber].desc
    if tip and tip ~= L"" then
        Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, tip)
        Tooltips.AnchorTooltip(TIP_ANCHOR)
    end
end

function ic.CreateTabSet(container, width, leftMargin)
    if not container or container == "" then
        return
    end

    leftMargin = leftMargin or 1

    ic.vTabsets[container] = {
        width     = width,
        margin    = leftMargin,
        tabs      = {},
        lines     = 1,
        firstline = 1,
        tabcount  = 0,
        selected  = 1,
        linelen   = 0,
    }

    CreateTabLine(container, 1)
    AnchorTabLine(container, 1, 1)
end

function ic.DestroyTabSet(container)
    local tabset = ic.vTabsets[container]
    if not tabset then
        return
    end

    for lineIndex = 1, tabset.lines do
        DestroyWindow(container .. "Line" .. lineIndex)
    end

    ic.vTabsets[container] = nil
end

function ic.AddTab(container, tabText, tabDescription, toggleWindow, callback)
    local tabset = ic.vTabsets[container]
    if not tabset then
        return nil
    end

    tabset.tabcount = tabset.tabcount + 1
    local index = tabset.tabcount

    tabset.tabs[index] = {
        text    = tabText,
        desc    = tabDescription,
        window  = toggleWindow,
        callback = callback,
    }

    local tabName = container .. "Tab" .. index

    CreateWindowFromTemplate(tabName, "IraConfigTab", container)
    WindowSetId(tabName, index)
    ButtonSetText(tabName, tabText)

    local textWidth = ButtonGetTextDimensions(tabName)
    local width = textWidth + 40

    tabset.tabs[index].width = width
    WindowSetDimensions(tabName, width, 35)

    local newLineNeeded = (tabset.linelen + tabset.margin + width + 16) > tabset.width

    if newLineNeeded then
        tabset.lines   = tabset.lines + 1
        tabset.linelen = 0

        CreateTabLine(container, tabset.lines)
        ArrangeLines(container)

        WindowSetParent(tabName, container .. "Line" .. tabset.lines)
        WindowAddAnchor(tabName, "bottomright", container .. "Line" .. tabset.lines .. "SepLeft", "bottomleft", 0, 0)
        SetShowing(toggleWindow, false)
    else
        WindowSetParent(tabName, container .. "Line" .. tabset.lines)

        if index == 1 then
            WindowAddAnchor(tabName, "bottomright", container .. "Line" .. tabset.lines .. "SepLeft", "bottomleft", 0, 0)

            ButtonSetPressedFlag(tabName, true)
            ButtonSetStayDownFlag(tabName, true)
            SetShowing(toggleWindow, true)
            Callback(container, 1, ic.CALLBACK_SHOWN)
        else
            SetShowing(toggleWindow, false)
            WindowAddAnchor(tabName, "bottomright", container .. "Tab" .. (index - 1), "bottomleft", 0, 0)
        end
    end

    tabset.linelen = tabset.linelen + width

    local sepRight = container .. "Line" .. tabset.lines .. "SepRight"
    WindowClearAnchors(sepRight)
    WindowAddAnchor(sepRight, "bottomright", tabName, "bottomleft", 0, 0)
    WindowAddAnchor(sepRight, "bottomright", container .. "Line" .. tabset.lines, "bottomright", -8, 0)

    tabset.tabs[index].line = tabset.lines

    return index
end

function ic.SetActiveTab(container, tabNumber)
    SetActiveTabInternal(container, tabNumber)
end

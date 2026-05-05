--[[
  IraConfig ((Lib) Ira Config) version 1.05
  by Irinia of Volkmar

  This file handles the context help system.
--]]

IraConfig = IraConfig or {}
local ic = IraConfig

ic.vHelpWindows  = ic.vHelpWindows  or {}
ic.vHelpWinIndex = ic.vHelpWinIndex or {}

local function IsWindowVisible(windowName)
    local current = windowName
    while current ~= "Root" do
        if not WindowGetShowing(current) then
            return false
        end
        current = WindowGetParent(current)
        if not current then
            return false
        end
    end
    return true
end

local function AnchorWindow(windowName, anchorList)
    if type(anchorList) ~= "table" or #anchorList == 0 then
        -- Default to full parent coverage
        WindowClearAnchors(windowName)
        WindowAddAnchor(windowName, "topleft", WindowGetParent(windowName), "topleft", 0, 0)
        WindowAddAnchor(windowName, "bottomright", WindowGetParent(windowName), "bottomright", 0, 0)
        return
    end

    WindowClearAnchors(windowName)

    for index, anchor in ipairs(anchorList) do
        local base = {}

        if index == 1 then
            base.point         = "topleft"
            base.relativePoint = "topleft"
        else
            base.point         = "bottomright"
            base.relativePoint = "bottomright"
        end

        base.relativeTo = WindowGetParent(windowName)
        base.x          = 0
        base.y          = 0

        WindowAddAnchor(
            windowName,
            anchor.point         or base.point,
            anchor.relativeTo    or base.relativeTo,
            anchor.relativePoint or base.relativePoint,
            anchor.x             or base.x,
            anchor.y             or base.y
        )
    end
end

function ic.HelpInit()
    if ic.helpInitialized then
        return
    end
    ic.helpInitialized = true

    CreateWindow("IraConfigHelpTip", false)
    WindowSetShowing("IraConfigHelpTip", false)
end

function ic.HelpCreateContext(parentWindow)
    if not parentWindow or parentWindow == "" then
        d("HelpCreateContext called with invalid parent window")
        return
    end

    if ic.vHelpWindows[parentWindow] then
        -- Context already exists, just return
        return
    end

    local contextId = #ic.vHelpWinIndex + 1

    ic.vHelpWindows[parentWindow] = {
        index       = contextId,
        areas       = {},
        showingtext = false,
    }

    ic.vHelpWinIndex[contextId] = parentWindow

    local canvasName = "IraConfigHelpCanvas" .. contextId
    CreateWindowFromTemplate(canvasName, "IraConfigHelpCanvas", parentWindow)
    WindowSetId(canvasName, contextId)
    WindowSetShowing(canvasName, false)
end

function ic.HelpShow(parentWindow)
    local context = ic.vHelpWindows[parentWindow]
    if not context then
        d("Help context " .. tostring(parentWindow) .. " does not exist")
        return
    end

    if ic.sActiveContext then
        ic.HelpHide(ic.sActiveContext)
    end

    local canvasName = "IraConfigHelpCanvas" .. context.index

    for areaIndex, area in ipairs(context.areas) do
        local areaWindow = canvasName .. "Area" .. areaIndex
        WindowSetShowing(areaWindow, IsWindowVisible(area.ref))
    end

    ic.sActiveContext = parentWindow
    WindowSetShowing(canvasName, true)
end

function ic.HelpHide(parentWindow)
    if not parentWindow then
        return
    end

    local context = ic.vHelpWindows[parentWindow]
    if not context then
        d("Help context " .. tostring(parentWindow) .. " does not exist")
        return
    end

    if ic.sActiveContext ~= parentWindow then
        return
    end

    ic.sActiveContext = nil
    context.showingtext = false

    local canvasName = "IraConfigHelpCanvas" .. context.index
    WindowSetShowing(canvasName, false)
    WindowSetShowing("IraConfigHelpTip", false)
end

function ic.HelpToggle(parentWindow)
    local context = ic.vHelpWindows[parentWindow]
    if not context then
        d("Help context " .. tostring(parentWindow) .. " does not exist")
        return
    end

    if ic.sActiveContext == parentWindow then
        ic.HelpHide(parentWindow)
    else
        ic.HelpShow(parentWindow)
    end
end

function ic.HelpCreateSimpleArea(parentWindow, referenceWindow, level, textCallback, param1, param2, param3, param4)
    local anchors = {
        [1] = { relativeTo = referenceWindow },
        [2] = { relativeTo = referenceWindow },
    }

    ic.HelpCreateComplexArea(parentWindow, referenceWindow, anchors, level, textCallback, param1, param2, param3, param4)
end

function ic.HelpCreateComplexArea(parentWindow, referenceWindow, anchors, level, textCallback, param1, param2, param3, param4)
    local context = ic.vHelpWindows[parentWindow]
    if not context then
        d("Help context " .. tostring(parentWindow) .. " does not exist")
        return
    end

    if type(textCallback) ~= "function" then
        d("HelpCreateComplexArea called with invalid text callback for " .. tostring(parentWindow))
        return
    end

    if type(anchors) ~= "table" then
        anchors = {}
    end

    if level < 1 then
        level = 1
    elseif level > 4 then
        level = 4
    end

    local areaId = #context.areas + 1

    context.areas[areaId] = {
        ref     = referenceWindow,
        callback = textCallback,
        param1  = param1,
        param2  = param2,
        param3  = param3,
        param4  = param4,
    }

    local canvasName = "IraConfigHelpCanvas" .. context.index
    local areaName   = canvasName .. "Area" .. areaId

    CreateWindowFromTemplate(areaName, "IraConfigHelpSpot", canvasName)
    AnchorWindow(areaName, anchors)
    WindowSetLayer(areaName, level)
    WindowSetId(areaName, areaId)

    if level == 1 then
        WindowSetTintColor(areaName, 192, 255, 128)
    elseif level == 2 then
        WindowSetTintColor(areaName, 255, 128, 192)
    elseif level == 3 then
        WindowSetTintColor(areaName, 128, 192, 255)
    else
        WindowSetTintColor(areaName, 255, 255, 255)
    end
end

function ic.HelpClickedCanvas()
    local canvasName   = SystemData.MouseOverWindow.name
    local canvasIndex  = WindowGetId(canvasName)
    local parentWindow = ic.vHelpWinIndex[canvasIndex]

    if parentWindow and parentWindow == WindowGetParent(canvasName) then
        ic.HelpHide(parentWindow)
    end
end

function ic.HelpClickedSpot()
    local spotName    = SystemData.MouseOverWindow.name
    local spotIndex   = WindowGetId(spotName)
    local canvasName  = WindowGetParent(spotName)
    local canvasIndex = WindowGetId(canvasName)
    local contextName = ic.vHelpWinIndex[canvasIndex]

    if not contextName or contextName ~= WindowGetParent(canvasName) then
        return
    end

    local context = ic.vHelpWindows[contextName]
    if not context then
        return
    end

    local area = context.areas[spotIndex]
    if not area or type(area.callback) ~= "function" then
        ic.HelpHide(contextName)
        return
    end

    local helpText = area.callback(area.param1, area.param2, area.param3, area.param4)

    if type(helpText) == "wstring" then
        local canvasPrefix = "IraConfigHelpCanvas" .. canvasIndex .. "Area"

        for index, _ in ipairs(context.areas) do
            if index ~= spotIndex then
                WindowSetShowing(canvasPrefix .. index, false)
            end
        end

        ic.HelpTip(contextName, spotName, helpText)
    else
        ic.HelpHide(contextName)
    end
end

function ic.HelpTip(contextName, areaWindow, text)
    -- hide and reset tip first
    WindowSetShowing("IraConfigHelpTip", false)
    WindowClearAnchors("IraConfigHelpTip")

    -- set tip text and size
    LabelSetText("IraConfigHelpTipLabel", text)
    local labelWidth, labelHeight = LabelGetTextDimensions("IraConfigHelpTipLabel")
    WindowSetDimensions("IraConfigHelpTip", 300, labelHeight + 20)

    -- find top level ancestor of context
    local current = contextName
    local nextParent = WindowGetParent(current)
    while nextParent ~= "Root" do
        current = nextParent
        nextParent = WindowGetParent(current)
    end

    local rootWidth, rootHeight = WindowGetDimensions("Root")
    local rootScale = WindowGetScale("Root")
    rootHeight = rootHeight * rootScale

    local bindWidth, bindHeight = WindowGetDimensions(current)
    local bindScale = WindowGetScale(current)
    bindHeight = bindHeight * bindScale

    local tipWidth, tipHeight = WindowGetDimensions("IraConfigHelpTip")
    local tipScale = WindowGetScale("IraConfigHelpTip")
    tipWidth  = tipWidth  * tipScale
    tipHeight = tipHeight * tipScale

    local areaX, areaY = WindowGetScreenPosition(areaWindow)
    local bindX, bindY = WindowGetScreenPosition(current)

    local placeRight = (bindX < tipWidth)

    if tipHeight > bindHeight then
        -- tip taller than ancestor
        if (bindY + tipHeight) > rootHeight then
            -- would hang off bottom if anchored to top
            if placeRight then
                WindowAddAnchor("IraConfigHelpTip", "bottomright", current, "bottomleft", 0, 0)
            else
                WindowAddAnchor("IraConfigHelpTip", "bottomleft", current, "bottomright", 0, 0)
            end
        else
            if placeRight then
                WindowAddAnchor("IraConfigHelpTip", "topright", current, "topleft", 0, 0)
            else
                WindowAddAnchor("IraConfigHelpTip", "topleft", current, "topright", 0, 0)
            end
        end
    elseif (areaY + tipHeight) > (bindY + bindHeight) then
        -- tip would hang off if positioned by area
        if placeRight then
            WindowAddAnchor("IraConfigHelpTip", "bottomright", current, "bottomleft", 0, 0)
        else
            WindowAddAnchor("IraConfigHelpTip", "bottomleft", current, "bottomright", 0, 0)
        end
    else
        -- tip fits when aligned to the area
        local offsetY = (areaY - bindY) / WindowGetScale(current)
        if placeRight then
            WindowAddAnchor("IraConfigHelpTip", "topright", current, "topleft", 0, offsetY)
        else
            WindowAddAnchor("IraConfigHelpTip", "topleft", current, "topright", 0, offsetY)
        end
    end

    WindowSetShowing("IraConfigHelpTip", true)
    ic.sActiveArea = areaWindow
    ic.vHelpWindows[contextName].showingtext = true
end

function ic.HelpCheckMouseOut()
    if ic.sActiveArea and SystemData.MouseOverWindow.name ~= ic.sActiveArea then
        ic.HelpHide(ic.sActiveContext)
    end
end

function ic.HelpBtnInit()
    local buttonName = SystemData.ActiveWindow.name
    ButtonSetText(buttonName, L"?")
    for state = 0, 5 do
        ButtonSetTextColor(buttonName, state, 128, 0, 0)
    end
end

----------------------------------------------------------------
-- VerticalMorale.lua (rewrite, feature complete)
----------------------------------------------------------------

VerticalMorale = VerticalMorale or {}
VerticalMorale.side = VerticalMorale.side or "left"

local barName, barWidth, barHeight
local anchorX, anchorY

-- Cache globals (perf and safety)
local DoesWindowExist = DoesWindowExist
local DestroyWindow = DestroyWindow
local CreateWindowFromTemplate = CreateWindowFromTemplate

local WindowGetDimensions = WindowGetDimensions
local WindowSetDimensions = WindowSetDimensions
local WindowSetShowing = WindowSetShowing
local WindowGetShowing = WindowGetShowing
local WindowClearAnchors = WindowClearAnchors
local WindowAddAnchor = WindowAddAnchor
local WindowGetAnchor = WindowGetAnchor
local WindowGetScale = WindowGetScale
local WindowSetScale = WindowSetScale

local DynamicImageSetRotation = DynamicImageSetRotation
local DynamicImageSetTextureOrientation = DynamicImageSetTextureOrientation

local StatusBarGetCurrentValue = StatusBarGetCurrentValue
local EA_ChatWindow_Print = EA_ChatWindow and EA_ChatWindow.Print

-- Saved originals so we can restore cleanly
VerticalMorale._orig = VerticalMorale._orig or {}

local function Chat(msg)
    if EA_ChatWindow_Print then
        EA_ChatWindow_Print(msg)
    end
end

local function SwapDimsIfNeeded(win)
    if not DoesWindowExist(win) then return end
    local x, y = WindowGetDimensions(win)
    if x > y then
        WindowSetDimensions(win, y, x)
    end
end

function VerticalMorale.Initialize()

    -- Hook anchors (must keep originals to restore)
    if not VerticalMorale._orig.MoraleButton_SetAnchor then
        VerticalMorale._orig.MoraleButton_SetAnchor = MoraleButton.SetAnchor
    end
    if not VerticalMorale._orig.MoraleDot_SetAnchor then
        VerticalMorale._orig.MoraleDot_SetAnchor = MoraleSlottedIndicator.SetAnchor
    end

    MoraleButton.SetAnchor = VerticalMorale.MoraleButtonSetAnchor
    MoraleSlottedIndicator.SetAnchor = VerticalMorale.MoraleDotSetAnchor

    -- Hook MoraleBar.Create
    if not VerticalMorale._orig.MoraleBar_Create then
        VerticalMorale._orig.MoraleBar_Create = MoraleBar.Create
    end

    MoraleBar.Create = function(self, windowName)
        local ret = VerticalMorale._orig.MoraleBar_Create(self, windowName)

        -- Make the base window vertical (swap dims)
        SwapDimsIfNeeded(windowName)

        -- Hide default horizontal parts
        WindowSetShowing(windowName.."ContentsStatus", false)
        WindowSetShowing(windowName.."ContentsBackground", false)
        WindowSetShowing(windowName.."ContentsOverlay", false)

        -- Create vertical visuals
        if not DoesWindowExist(windowName.."VerticalBackground") then
            CreateWindowFromTemplate(windowName.."VerticalBackground", "VerticalMoraleBarBackground", windowName)
        end
        if not DoesWindowExist(windowName.."VerticalOverlay") then
            CreateWindowFromTemplate(windowName.."VerticalOverlay", "VerticalMoraleBarOverlay", windowName)
        end

        barName = windowName.."VerticalBar"
        if not DoesWindowExist(barName) then
            CreateWindowFromTemplate(barName, "VerticalMoraleBar", windowName)
        end

        -- Use the original status bar dimensions as the basis
        local by, bx = WindowGetDimensions(windowName.."ContentsStatus")
        barWidth, barHeight = bx, by
        WindowSetDimensions(barName, bx, by)

        -- Capture original anchor so Shutdown can restore it
        local _, _, _, ax, ay = WindowGetAnchor(windowName.."ContentsStatus", 1)
        anchorX, anchorY = ax, ay
        WindowClearAnchors(windowName.."ContentsStatus")

        -- Anchor our 3-part bar and rotate background/overlay
        VerticalMorale.AnchorBar(windowName, by, ax, ay)

        return ret
    end

    -- Hook ShowGainedMorale (your original behavior)
    if not VerticalMorale._orig.MoraleBar_ShowGainedMorale then
        VerticalMorale._orig.MoraleBar_ShowGainedMorale = MoraleBar.ShowGainedMorale
    end

    MoraleBar.ShowGainedMorale = function(self, show)
        local ret = VerticalMorale._orig.MoraleBar_ShowGainedMorale(self, show)
        if show == false then
            VerticalMorale.SetBarValue(0)
        end
        return ret
    end

    -- Hook SetMorale (updates gained morale overlay)
    if not VerticalMorale._orig.MoraleBar_SetMorale then
        VerticalMorale._orig.MoraleBar_SetMorale = MoraleBar.SetMorale
    end

    MoraleBar.SetMorale = function(self, moralePercent, moraleLevel)
        local ret = VerticalMorale._orig.MoraleBar_SetMorale(self, moralePercent, moraleLevel)

        if self.m_ShowGainedMorale and self.m_StatusBar then
            local fillAmount = StatusBarGetCurrentValue(self.m_StatusBar:GetName())
            VerticalMorale.SetBarValue(fillAmount)
        end

        return ret
    end

    -- Slash command
    if LibSlash then
        LibSlash.RegisterSlashCmd("verticalmorale", function(args)
            local side = args and args:match("^side%s+(left|right)$")
            if side then
                VerticalMorale.side = side
                Chat(L"[VerticalMorale]: Reload UI for this change to take effect.")
            else
                Chat(L"[VerticalMorale]: Valid options:\n side [left|right]")
            end
        end)
    end

    Chat(L"<! Vertical Morale initialized. Use /verticalmorale side left|right")
end

function VerticalMorale.Shutdown()

    -- Restore hooks
    if VerticalMorale._orig.MoraleBar_Create then
        MoraleBar.Create = VerticalMorale._orig.MoraleBar_Create
    end
    if VerticalMorale._orig.MoraleBar_ShowGainedMorale then
        MoraleBar.ShowGainedMorale = VerticalMorale._orig.MoraleBar_ShowGainedMorale
    end
    if VerticalMorale._orig.MoraleBar_SetMorale then
        MoraleBar.SetMorale = VerticalMorale._orig.MoraleBar_SetMorale
    end
    if VerticalMorale._orig.MoraleButton_SetAnchor then
        MoraleButton.SetAnchor = VerticalMorale._orig.MoraleButton_SetAnchor
    end
    if VerticalMorale._orig.MoraleDot_SetAnchor then
        MoraleSlottedIndicator.SetAnchor = VerticalMorale._orig.MoraleDot_SetAnchor
    end

    -- Restore base morale bar dimensions if vertical
    if DoesWindowExist("EA_MoraleBar") then
        local x, y = WindowGetDimensions("EA_MoraleBar")
        if y > x then
            WindowSetDimensions("EA_MoraleBar", y, x)
        end
    end

    -- Restore contents window if vertical
    if DoesWindowExist("EA_MoraleBarContents") then
        local x, y = WindowGetDimensions("EA_MoraleBarContents")
        if y > x then
            WindowSetDimensions("EA_MoraleBarContents", y, x)
        end

        -- Restore original status bar anchors and visibility
        if not WindowGetShowing("EA_MoraleBarContentsStatus") then
            WindowClearAnchors("EA_MoraleBarContentsStatus")
            WindowAddAnchor("EA_MoraleBarContentsStatus", "bottomleft", "EA_MoraleBar", "bottomleft", anchorX or 0, anchorY or 0)
            WindowSetShowing("EA_MoraleBarContentsStatus", true)
        end

        WindowSetShowing("EA_MoraleBarContentsBackground", true)
        WindowSetShowing("EA_MoraleBarContentsOverlay", true)
    end

    -- Destroy our created windows
    if barName and DoesWindowExist(barName) then
        DestroyWindow(barName)
    end
    if DoesWindowExist("EA_MoraleBarVerticalBackground") then
        DestroyWindow("EA_MoraleBarVerticalBackground")
    end
    if DoesWindowExist("EA_MoraleBarVerticalOverlay") then
        DestroyWindow("EA_MoraleBarVerticalOverlay")
    end

    barName, barWidth, barHeight = nil, nil, nil
    anchorX, anchorY = nil, nil
end

function VerticalMorale.AnchorBar(windowName, by, ax, ay)

    -- Clear any existing anchors on our templates
    WindowClearAnchors(barName)
    WindowClearAnchors(barName.."1")
    WindowClearAnchors(barName.."2")
    WindowClearAnchors(barName.."3")
    WindowClearAnchors(windowName.."VerticalBackground")
    WindowClearAnchors(windowName.."VerticalOverlay")

    local x, y = WindowGetDimensions(windowName)

    if VerticalMorale.side == "right" then
        WindowAddAnchor(barName, "bottomright", windowName, "bottomright", (ay or 0) - 1, -(ax or 0))
        WindowAddAnchor(barName.."1", "bottomright", barName, "bottomright", 0, 0)
        WindowAddAnchor(barName.."2", "bottomright", barName, "bottomright", 0, -by/2)
        WindowAddAnchor(barName.."3", "bottomright", barName, "bottomright", 0, -by*0.75)

        WindowAddAnchor(windowName.."VerticalBackground", "bottomright", windowName, "bottomright", y/2, -y/2)
        WindowAddAnchor(windowName.."VerticalOverlay", "bottomright", windowName, "bottomright", y/2, -y/2)

        DynamicImageSetRotation(windowName.."VerticalBackground", 270)
        DynamicImageSetRotation(windowName.."VerticalOverlay", 270)
    else
        WindowAddAnchor(barName, "bottomleft", windowName, "bottomleft", -(ay or 0) - 1, -(ax or 0))
        WindowAddAnchor(barName.."1", "bottomleft", barName, "bottomleft", 0, 0)
        WindowAddAnchor(barName.."2", "bottomleft", barName, "bottomleft", 0, -by/2)
        WindowAddAnchor(barName.."3", "bottomleft", barName, "bottomleft", 0, -by*0.75)

        WindowAddAnchor(windowName.."VerticalBackground", "bottomleft", windowName, "bottomleft", -y/2, -y/2)
        WindowAddAnchor(windowName.."VerticalOverlay", "bottomleft", windowName, "bottomleft", -y/2, -y/2)

        DynamicImageSetRotation(windowName.."VerticalBackground", 90)
        DynamicImageSetRotation(windowName.."VerticalOverlay", 90)
        DynamicImageSetTextureOrientation(windowName.."VerticalBackground", true)
        DynamicImageSetTextureOrientation(windowName.."VerticalOverlay", true)
    end
end

function VerticalMorale.SetBarValue(value)

    if not barName or not barWidth or not barHeight then return end
    if not DoesWindowExist(barName.."1") then return end

    if value >= 75 then
        value = value - 75
        WindowSetDimensions(barName.."1", barWidth/3, barHeight/2)
        WindowSetDimensions(barName.."2", barWidth*2/3, barHeight/4)
        WindowSetDimensions(barName.."3", barWidth, barHeight*value/100)
    elseif value >= 50 then
        value = value - 50
        WindowSetDimensions(barName.."1", barWidth/3, barHeight/2)
        WindowSetDimensions(barName.."2", barWidth*2/3, barHeight*value/100)
        WindowSetDimensions(barName.."3", barWidth, 0)
    else
        WindowSetDimensions(barName.."1", barWidth/3, barHeight*value/100)
        WindowSetDimensions(barName.."2", barWidth*2/3, 0)
        WindowSetDimensions(barName.."3", barWidth, 0)
    end
end

function VerticalMorale.MoraleButtonSetAnchor(self, anchor)

    local x = anchor.XOffset

    if VerticalMorale.side == "right" then
        anchor.Point = "bottomright"
        anchor.RelativePoint = "bottomright"
        anchor.XOffset = anchor.YOffset
        anchor.YOffset = -x
    else
        anchor.XOffset = -anchor.YOffset
        anchor.YOffset = -x
    end

    Frame.SetAnchor(self, anchor)
end

function VerticalMorale.MoraleDotSetAnchor(self, anchor)

    local x = anchor.XOffset

    if VerticalMorale.side == "right" then
        anchor.Point = "right"
        anchor.RelativePoint = "right"
        anchor.XOffset = anchor.YOffset
        anchor.YOffset = -x
    else
        anchor.Point = "left"
        anchor.RelativePoint = "left"
        anchor.XOffset = -anchor.YOffset
        anchor.YOffset = -x
    end

    Frame.SetAnchor(self, anchor)
end
HideHiddenFrames = HideHiddenFrames or {}

local begin
local toggle

-- localize globals (performance)
local pairs = pairs
local WindowGetId = WindowGetId
local WindowGetParent = WindowGetParent
local ListBoxGetDataIndex = ListBoxGetDataIndex

function HideHiddenFrames.Initialize()
    begin = LayoutEditor.Begin
    LayoutEditor.Begin = HideHiddenFrames.Begin

    toggle = LayoutEditor.OnToggleHidden
    LayoutEditor.OnToggleHidden = HideHiddenFrames.OnToggleHidden
end

function HideHiddenFrames.Begin()
    begin()

    local frames = LayoutEditor.framesList
    if not frames then return end

    for _, frame in pairs(frames) do
        local data = frame.m_windowData
        if data and data.isUserHidden then
            frame:Show(false)
        end
    end
end

function HideHiddenFrames.OnToggleHidden()
    local active = SystemData.ActiveWindow
    if not active or not active.name then
        toggle()
        return
    end

    local parent = WindowGetParent(active.name)
    if not parent then
        toggle()
        return
    end

    local rowIndex = WindowGetId(parent)
    local dataIndex = ListBoxGetDataIndex("LayoutEditorWindowControlScreenBrowserWindowsList", rowIndex)

    local frame = LayoutEditor.windowBrowserDataList and LayoutEditor.windowBrowserDataList[dataIndex]

    toggle()

    if frame then
        frame:Show(not frame:IsHidden())
    end
end

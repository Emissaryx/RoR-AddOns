----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

EA_Window_Macro = EA_Window_Macro or {}

EA_Window_Macro.NUM_MACROS = 48
EA_Window_Macro.NUM_MACRO_ICONS = 36
EA_Window_Macro.MACRO_ICONS_ID_BASE = 200

EA_Window_Macro.activeId = 1
EA_Window_Macro.iconNum = 0

local MacroIcons = {}
local macroId = EA_Window_Macro.MACRO_ICONS_ID_BASE
local oldId   = macroId
local reset   = false

local MAX_ICON = 25000
local STEP     = EA_Window_Macro.NUM_MACRO_ICONS

-- math
local math_floor = math.floor
local math_max   = math.max
local math_min   = math.min

-- icon / texture hot path
local GetIconData             = GetIconData
local DynamicImageSetTexture  = DynamicImageSetTexture

-- window queries used often
local WindowGetId             = WindowGetId
local WindowGetShowing        = WindowGetShowing
local WindowSetShowing        = WindowSetShowing
local DoesWindowExist         = DoesWindowExist

-- scrollbar hot path
local VerticalScrollbarGetScrollPosition = VerticalScrollbarGetScrollPosition
local VerticalScrollbarSetScrollPosition = VerticalScrollbarSetScrollPosition

----------------------------------------------------------------
-- EA_Window_Macro Functions
----------------------------------------------------------------
function EA_Window_Macro.Initialize()
    ----------------------------------------------------------------
    -- Default Macro Window Initialization (EA / Mythic)
    ----------------------------------------------------------------

    LabelSetText("EA_Window_MacroTitleBarText",        GetString(StringTables.Default.LABEL_MACROS))
    ButtonSetText("EA_Window_MacroDetailsSave",       GetString(StringTables.Default.LABEL_SAVE))
    LabelSetText("EA_Window_MacroDetailsNameTitle",   GetString(StringTables.Default.LABEL_MACROS_NAME))
    LabelSetText("EA_Window_MacroDetailsTextTitle",   GetString(StringTables.Default.LABEL_MACROS_TEXT))
    LabelSetText("MacroIconSelectionWindowTitleBarText",
                                                    GetString(StringTables.Default.LABEL_SELECT_ICON))

    -- Initial icon load (immediately replaced by MacroIcons paging)
    for slot = 1, EA_Window_Macro.NUM_MACRO_ICONS do
        local tex, x, y = GetIconData(EA_Window_Macro.MACRO_ICONS_ID_BASE + slot)
        DynamicImageSetTexture("MacroIconSelectionWindowIconSlot"..slot.."IconBase", tex, x, y)
    end

    -- Macro slot buttons
    for slot = 1, EA_Window_Macro.NUM_MACROS do
        ButtonSetCheckButtonFlag("EA_Window_MacroIconSlot"..slot, true)
    end

    -- Macro events
    WindowRegisterEventHandler("EA_Window_Macro", SystemData.Events.MACRO_UPDATED, "EA_Window_Macro.OnMacroUpdated")
    WindowRegisterEventHandler("EA_Window_Macro", SystemData.Events.MACROS_LOADED,  "EA_Window_Macro.UpdateMacros")

    EA_Window_Macro.UpdateMacros()
    EA_Window_Macro.UpdateDetails(1)

    ----------------------------------------------------------------
    -- Emissary: MacroIcons Extension
    ----------------------------------------------------------------

    -- Disable the stock scrollbar
    WindowSetShowing("IconsScrollbar", false)

    -- FIX: Create MacroIcons container but DON'T show it initially
    if not DoesWindowExist("MacroIcons") then
        CreateWindow("MacroIcons", false)  -- CHANGED: false instead of true
    end
    
    -- FIX: Immediately hide it to prevent showing at screen origin
    WindowSetShowing("MacroIcons", false)

    -- Derive scrollbar page range from real icon limits
    local lastPage = math_floor( (MAX_ICON - EA_Window_Macro.MACRO_ICONS_ID_BASE) / STEP )
    if lastPage < 0 then lastPage = 0 end

    VerticalScrollbarSetMaxScrollPosition("MacroIconsScrollBar", lastPage)
    VerticalScrollbarSetScrollPosition("MacroIconsScrollBar", 0)

    ----------------------------------------------------------------
    -- Mouse wheel handling (WAR quirk)
    ----------------------------------------------------------------

    WindowRegisterCoreEventHandler("MacroIconSelectionWindow", "OnMouseWheel", "MacroIcons.MouseWheel")
    WindowRegisterCoreEventHandler("IconsScrollChild",        "OnMouseWheel", "MacroIcons.MouseWheel")

    for k = 1, EA_Window_Macro.NUM_MACRO_ICONS do
        WindowRegisterCoreEventHandler(
            "MacroIconSelectionWindowIconSlot"..k,
            "OnMouseWheel",
            "MacroIcons.MouseWheel"
        )
    end

    ----------------------------------------------------------------
    -- Initial page sync (but MacroIcons stays hidden until needed)
    ----------------------------------------------------------------

    MacroIcons.RefreshIcons()
end

function EA_Window_Macro.Shutdown()
    -- Cleanup: hide MacroIcons window if it exists
    if DoesWindowExist("MacroIcons") then
        WindowSetShowing("MacroIcons", false)
    end
end

function EA_Window_Macro.OnHidden()
    WindowUtils.OnHidden()
    EA_Window_Macro.HideMacroIconSelectionWindow()
end

function EA_Window_Macro.OnShown()
    WindowUtils.OnShown(EA_Window_Macro.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

function EA_Window_Macro.Hide()
    WindowSetShowing("EA_Window_Macro", false)
    EA_Window_Macro.HideMacroIconSelectionWindow()
end

function EA_Window_Macro.OnMacroUpdated(macroId)
    if macroId == EA_Window_Macro.activeId then
        EA_Window_Macro.UpdateDetails(macroId)
    end

    local macros = DataUtils.GetMacros()
    local tex, x, y = GetIconData(macros[macroId].iconNum)
    DynamicImageSetTexture("EA_Window_MacroIconSlot"..macroId.."IconBase", tex, x, y)
end

function EA_Window_Macro.UpdateMacros()
    local macros = DataUtils.GetMacros()
    for slot = 1, EA_Window_Macro.NUM_MACROS do
        local tex, x, y = GetIconData(macros[slot].iconNum)
        DynamicImageSetTexture("EA_Window_MacroIconSlot"..slot.."IconBase", tex, x, y)
    end
end

function EA_Window_Macro.DetailIconLButtonDown()
    local showing = WindowGetShowing("MacroIconSelectionWindow")

    if not showing then
        -- FIX: Ensure MacroIcons exists and is properly set up
        if not DoesWindowExist("MacroIcons") then
            CreateWindow("MacroIcons", false)  -- Create hidden
        end

        -- Parent MacroIcons to the Select Icon window
        WindowSetParent("MacroIcons", "MacroIconSelectionWindow")

        -- Clear any previous anchors to avoid inherited positioning
        WindowClearAnchors("MacroIcons")
        WindowAddAnchor("MacroIcons","topright","MacroIconSelectionWindow","topright",0,0)
        WindowAddAnchor("MacroIcons","bottomright","MacroIconSelectionWindow","bottomright",0,0)

        -- FIX: Now show MacroIcons (it's properly parented and anchored)
        WindowSetShowing("MacroIcons", true)
    else
        -- FIX: Hide MacroIcons when closing the selection window
        WindowSetShowing("MacroIcons", false)
    end

    WindowSetShowing("MacroIconSelectionWindow", not showing)
end

function EA_Window_Macro.DetailIconMouseOver()
    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, GetString(StringTables.Default.TEXT_SELECT_ICON_BUTTON))
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_LEFT)
end

function EA_Window_Macro.IconLButtonUp()
    local slot = WindowGetId(SystemData.ActiveWindow.name)
    if EA_Window_Macro.activeId == slot then
        local macros = DataUtils.GetMacros()
        Cursor.PickUp(Cursor.SOURCE_MACRO, slot, slot, macros[slot].iconNum, false)
    else
        EA_Window_Macro.UpdateDetails(slot)
    end
end

function EA_Window_Macro.IconMouseDrag()
    if Cursor.IconOnCursor() then return end
    local slot = WindowGetId(SystemData.ActiveWindow.name)
    local macros = DataUtils.GetMacros()
    Cursor.PickUp(Cursor.SOURCE_MACRO, slot, slot, macros[slot].iconNum, false)
    EA_Window_Macro.UpdateDetails(slot)
end

function EA_Window_Macro.OnSave()
    SetMacroData(
        TextEditBoxGetText("EA_Window_MacroDetailsName"),
        TextEditBoxGetText("EA_Window_MacroDetailsText"),
        EA_Window_Macro.iconNum,
        EA_Window_Macro.activeId
    )

    local tex, x, y = GetIconData(EA_Window_Macro.iconNum)
    DynamicImageSetTexture("EA_Window_MacroIconSlot"..EA_Window_Macro.activeId.."IconBase", tex, x, y)

    Sound.Play(Sound.BUTTON_CLICK)
end

function EA_Window_Macro.UpdateDetails(slot)
    local macros = DataUtils.GetMacros()
    local macro = macros[slot]

    EA_Window_Macro.activeId = slot
    EA_Window_Macro.iconNum = macro.iconNum

    TextEditBoxSetText("EA_Window_MacroDetailsName", macro.name)
    TextEditBoxSetText("EA_Window_MacroDetailsText", macro.text)

    local tex, x, y = GetIconData(macro.iconNum)
    DynamicImageSetTexture("EA_Window_MacroDetailsIconIconBase", tex, x, y)

    for index = 1, EA_Window_Macro.NUM_MACROS do
        ButtonSetPressedFlag("EA_Window_MacroIconSlot"..index, index == slot)
    end
end

function EA_Window_Macro.SelectionIconLButtonDown()
    local slot = WindowGetId(SystemData.ActiveWindow.name) -- Emissary: use paged icon base

    EA_Window_Macro.iconNum = macroId + slot

    local tex, x, y = GetIconData(EA_Window_Macro.iconNum)
    DynamicImageSetTexture("EA_Window_MacroDetailsIconIconBase", tex, x, y)

    WindowSetShowing("MacroIconSelectionWindow", false)
    
    -- FIX: Also hide MacroIcons when closing
    WindowSetShowing("MacroIcons", false)
end

function EA_Window_Macro.HideMacroIconSelectionWindow()
    if WindowGetShowing("MacroIconSelectionWindow") then
        WindowSetShowing("MacroIconSelectionWindow", false)
    end
    
    -- FIX: Also hide MacroIcons scrollbar
    if DoesWindowExist("MacroIcons") and WindowGetShowing("MacroIcons") then
        WindowSetShowing("MacroIcons", false)
    end
end

-- MacroIcons integrated below here by Emissary

local MacroIcons_OriginalSelectionIconLButtonDown =
    EA_Window_Macro.SelectionIconLButtonDown

function EA_Window_Macro.SelectionIconLButtonDown(...)
    MacroIcons_OriginalSelectionIconLButtonDown(...)
    MacroIcons.UpdateSelectedIcon()
end

function MacroIcons.UpdateSelectedIcon()
    local slot = WindowGetId(SystemData.ActiveWindow.name)
    EA_Window_Macro.iconNum = macroId + slot

    local tex, x, y = GetIconData(EA_Window_Macro.iconNum)
    DynamicImageSetTexture("EA_Window_MacroDetailsIconIconBase", tex, x, y)
end

function MacroIcons.GetPage()
    return math_floor((macroId - EA_Window_Macro.MACRO_ICONS_ID_BASE) / STEP)
end

function MacroIcons.ScrollPos()
    if reset then return end

    local page = math_floor(VerticalScrollbarGetScrollPosition("MacroIconsScrollBar"))
    local newMacroId = EA_Window_Macro.MACRO_ICONS_ID_BASE + (page * STEP)

    if newMacroId == macroId then return end

    macroId = newMacroId
    MacroIcons.RefreshIcons()
end

function MacroIcons.RefreshIcons()
    -- Clamp to valid range
    macroId = math_max(EA_Window_Macro.MACRO_ICONS_ID_BASE, math_min(MAX_ICON, macroId))

    -- Validate icon range has valid textures
    local tries = 0
    while tries < 10 do
        local t1 = GetIconData(macroId + 1)
        local t2 = GetIconData(macroId + STEP)

        if t1 ~= "icon-00001" or t2 ~= "icon-00001" then
            break
        end

        macroId = (macroId > oldId) and (macroId + STEP) or (macroId - STEP)
        tries = tries + 1
    end

    oldId = macroId

    -- Update all icon slots
    for slot = 1, EA_Window_Macro.NUM_MACRO_ICONS do
        local tex, x, y = GetIconData(macroId + slot)
        DynamicImageSetTexture(
            "MacroIconSelectionWindowIconSlot"..slot.."IconBase",
            tex, x, y
        )
    end

    -- Update scrollbar position
    reset = true
    VerticalScrollbarSetScrollPosition(
        "MacroIconsScrollBar",
        MacroIcons.GetPage()
    )
    reset = false
end

function MacroIcons.MouseWheel(x, y, delta)
    if delta > 0 then
        macroId = macroId - STEP
    elseif delta < 0 then
        macroId = macroId + STEP
    end

    MacroIcons.RefreshIcons()
end

----------------------------------------------------------------
-- Stub functions (required by XML event handlers)
----------------------------------------------------------------

function EA_Window_Macro.DetailIconLButtonUp()
end

function EA_Window_Macro.DetailIconRButtonDown()
end

function EA_Window_Macro.DetailIconMouseOver()
    local text = GetString( StringTables.Default.TEXT_SELECT_ICON_BUTTON )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_LEFT)
end

function EA_Window_Macro.IconRButtonDown()
end

function EA_Window_Macro.IconMouseOver()
    -- intentionally empty / debug only
end

function EA_Window_Macro.SelectionIconLButtonUp()
end

function EA_Window_Macro.SelectionIconRButtonDown()
end

function EA_Window_Macro.SelectionIconMouseOver()
end

----------------------------------------------------------------
-- Export to global scope
----------------------------------------------------------------

_G.MacroIcons = MacroIcons
AutoBandWindow = {}

AutoBandWindow.name = "AutoBandWindow"
AutoBandWindow.mapicon_name = "AutoBandMapIcon"

AutoBandWindow.SelectedTab = AB_const.TABS_TOOLS

AutoBandWindow.Tabs = {}
AutoBandWindow.Tabs[ AB_const.TABS_TEMPLATE] = { button = "AutoBandWindowTabsTemplate", name = AutoBandWindowTemplate.name,
                            label = "Templates", show = AutoBandWindowTemplate.Show, hide = AutoBandWindowTemplate.Hide}
AutoBandWindow.Tabs[ AB_const.TABS_TOOLS] = { button = "AutoBandWindowTabsTools", name = AutoBandWindowTools.name,
                            label = "Tools", show = AutoBandWindowTools.Show, hide = AutoBandWindowTools.Hide}
AutoBandWindow.Tabs[ AB_const.TABS_CONFIG] = { button = "AutoBandWindowTabsConfig", name = AutoBandWindowConfig.name,
                            label = "Config", show = AutoBandWindowConfig.Show, hide = AutoBandWindowConfig.Hide}


function AutoBandWindow.Initialize()
    -- Header text
    LabelSetText(AutoBandWindow.name .. "TitleBarText", L"AutoBand")

    -- Tab Text
    AutoBandWindow.SetTabLabels()

    -- Show SelectedTab by default
    AutoBandWindow.show_selected_tab()

    -- display icon ?
    WindowSetShowing(AutoBandWindow.mapicon_name, AutoBand.saved.displayicon)
end

function AutoBandWindow.Hide()
    WindowSetShowing(AutoBandWindow.name, false)
end

function AutoBandWindow.Show()
    WindowSetShowing(AutoBandWindow.name, true)
    AutoBandWindow.show_selected_tab()
end

function AutoBandWindow.ShowConfigTab()
    AutoBandWindow.SelectedTab = AB_const.TABS_CONFIG
    if AutoBandWindow.showing() then
        AutoBandWindow.show_selected_tab()
        return
    end
    AutoBandWindow.Show()
end

function AutoBandWindow.showing()
    return WindowGetShowing(AutoBandWindow.name)
end

function AutoBandWindow.show_selected_tab()
    AutoBandWindow.HideTabAllElements()
    AutoBandWindow.Tabs[AutoBandWindow.SelectedTab].show()
    AutoBandWindow.SetHighlightedTabText(AutoBandWindow.SelectedTab)
end

function AutoBandWindow.toggle_mapicon(value)
    if (value == nil) then
        AutoBand.saved.displayicon = not WindowGetShowing(AutoBandWindow.mapicon_name)
    else
        AutoBand.saved.displayicon = value
    end
    WindowSetShowing(AutoBandWindow.mapicon_name, AutoBand.saved.displayicon)
end


---------------------------------------
-- Tab Controls
---------------------------------------

function AutoBandWindow.SetTabLabels()
    for _, tab in ipairs(AutoBandWindow.Tabs) do
        ButtonSetText(tab.button, towstring(tab.label))
    end
end

function AutoBandWindow.OnLButtonUpTab()
    local windowIndex = WindowGetId(SystemData.ActiveWindow.name)
    AutoBandWindow.SelectedTab = windowIndex
    AutoBandWindow.show_selected_tab()
end

function AutoBandWindow.HideTabAllElements()
    for _, tab in ipairs(AutoBandWindow.Tabs) do
        tab.hide()
    end
end

function AutoBandWindow.SetHighlightedTabText(tabNumber)
    for index, tab in ipairs(AutoBandWindow.Tabs) do
        ButtonSetPressedFlag(tab.button, not(index ~= tabNumber))
    end
end

wbLeadHelperConfigWindow = {}

wbLeadHelperConfigWindow.name = "wbLeadHelperConfigWindow"

wbLeadHelperConfigWindow.SelectedTab = 1

wbLeadHelperConfigWindow.Tabs = {}
wbLeadHelperConfigWindow.Tabs[1] = { button = "wbLeadHelperConfigWindowTabsMessages", name = wbLeadHelperMessagesTab.name,
							label = "Messages", show = wbLeadHelperMessagesTab.Show, hide = wbLeadHelperMessagesTab.Hide}
wbLeadHelperConfigWindow.Tabs[2] = { button = "wbLeadHelperConfigWindowTabsConfig", name = wbLeadHelperConfigTab.name,
							label = "Config", show = wbLeadHelperConfigTab.Show, hide = wbLeadHelperConfigTab.Hide}

function wbLeadHelperConfigWindow.Initialize()
	-- Header text
	LabelSetText(wbLeadHelperConfigWindow.name .. "TitleBarText", L"wbLeadHelper config")

	-- Tab Text
	wbLeadHelperConfigWindow.SetTabLabels()

	-- Show SelectedTab by default
	wbLeadHelperConfigWindow.ShowActiveTab()
end

function wbLeadHelperConfigWindow.Hide()
	WindowSetShowing(wbLeadHelperConfigWindow.name, false)
end

function wbLeadHelperConfigWindow.Show()
	WindowSetShowing(wbLeadHelperConfigWindow.name, true)
end



---------------------------------------
-- Tab Controls
---------------------------------------

function wbLeadHelperConfigWindow.SetTabLabels()
	for _, tab in ipairs(wbLeadHelperConfigWindow.Tabs) do
		ButtonSetText(tab.button, towstring(tab.label))
	end
end

function wbLeadHelperConfigWindow.ShowActiveTab()
	wbLeadHelperConfigWindow.HideTabAllContent()
	wbLeadHelperConfigWindow.Tabs[wbLeadHelperConfigWindow.SelectedTab].show()
	wbLeadHelperConfigWindow.SetHighlightedTabText(wbLeadHelperConfigWindow.SelectedTab)
end

function wbLeadHelperConfigWindow.OnLButtonUpTab()
	local windowIndex = WindowGetId(SystemData.ActiveWindow.name)
	wbLeadHelperConfigWindow.SelectedTab = windowIndex
	wbLeadHelperConfigWindow.ShowActiveTab()
end

function wbLeadHelperConfigWindow.HideTabAllContent()
	for _, tab in ipairs(wbLeadHelperConfigWindow.Tabs) do
		tab.hide()
	end
end

function wbLeadHelperConfigWindow.SetHighlightedTabText(tabNumber)
	for index, tab in ipairs(wbLeadHelperConfigWindow.Tabs) do
		ButtonSetPressedFlag(tab.button, not(index ~= tabNumber))
	end
end
DevHelperConfigWindow = {}

DevHelperConfigWindow.name = "DevHelperConfigWindow"

DevHelperConfigWindow.SelectedTab = 1

DevHelperConfigWindow.Tabs = {}
DevHelperConfigWindow.Tabs[1] = { button = "DevHelperConfigWindowTabsMessages", name = DevHelperMessagesTab.name,
							label = "Messages", show = DevHelperMessagesTab.Show, hide = DevHelperMessagesTab.Hide}
DevHelperConfigWindow.Tabs[2] = { button = "DevHelperConfigWindowTabsConfig", name = DevHelperConfigTab.name,
							label = "Config", show = DevHelperConfigTab.Show, hide = DevHelperConfigTab.Hide}

function DevHelperConfigWindow.Initialize()
	-- Header text
	LabelSetText(DevHelperConfigWindow.name .. "TitleBarText", L"DevHelper config")

	-- Tab Text
	DevHelperConfigWindow.SetTabLabels()

	-- Show SelectedTab by default
	DevHelperConfigWindow.ShowActiveTab()
end

function DevHelperConfigWindow.Hide()
	WindowSetShowing(DevHelperConfigWindow.name, false)
end

function DevHelperConfigWindow.Show()
	WindowSetShowing(DevHelperConfigWindow.name, true)
end



---------------------------------------
-- Tab Controls
---------------------------------------

function DevHelperConfigWindow.SetTabLabels()
	for _, tab in ipairs(DevHelperConfigWindow.Tabs) do
		ButtonSetText(tab.button, towstring(tab.label))
	end
end

function DevHelperConfigWindow.ShowActiveTab()
	DevHelperConfigWindow.HideTabAllContent()
	DevHelperConfigWindow.Tabs[DevHelperConfigWindow.SelectedTab].show()
	DevHelperConfigWindow.SetHighlightedTabText(DevHelperConfigWindow.SelectedTab)
end

function DevHelperConfigWindow.OnLButtonUpTab()
	local windowIndex = WindowGetId(SystemData.ActiveWindow.name)
	DevHelperConfigWindow.SelectedTab = windowIndex
	DevHelperConfigWindow.ShowActiveTab()
end

function DevHelperConfigWindow.HideTabAllContent()
	for _, tab in ipairs(DevHelperConfigWindow.Tabs) do
		tab.hide()
	end
end

function DevHelperConfigWindow.SetHighlightedTabText(tabNumber)
	for index, tab in ipairs(DevHelperConfigWindow.Tabs) do
		ButtonSetPressedFlag(tab.button, not(index ~= tabNumber))
	end
end
DevHelperMessagesTab = {}

local tinsert = table.insert

DevHelperMessagesTab.name = "DevHelperMessagesTabContent"

function DevHelperMessagesTab.Initialize()

	DevHelperMessagesTab.messagesListData = {}

	-- Content setup
	LabelSetText(DevHelperMessagesTab.name .. "Label", L"Messages")

	WindowSetTintColor (DevHelperMessagesTab.name.."ListBackground", 100, 100, 100)
	WindowSetAlpha (DevHelperMessagesTab.name.."ListBackground", 0.5)
	ButtonSetText (DevHelperMessagesTab.name.."AddButton", L"Add")
	ButtonSetText (DevHelperMessagesTab.name.."EditButton", L"Edit")
	ButtonSetText (DevHelperMessagesTab.name.."DeleteButton", L"Delete")
	ButtonSetText (DevHelperMessagesTab.name.."UpButton", L"Up")
	ButtonSetText (DevHelperMessagesTab.name.."DownButton", L"Down")

	-- Bottom buttons
	ButtonSetDisabledFlag(DevHelperConfigTab.name .. "SaveButton", true)
	ButtonSetText(DevHelperMessagesTab.name .. "SaveButton", L"Save")
	ButtonSetText(DevHelperMessagesTab.name .. "ResetButton", L"Reset")
	ButtonSetText(DevHelperMessagesTab.name .. "ApplyButton", L"Preview")

	DevHelperMessagesTab.OnLoad()
end

function DevHelperMessagesTab.Hide()
	WindowSetShowing(DevHelperMessagesTab.name, false)
end
function DevHelperMessagesTab.Show()
	WindowSetShowing(DevHelperMessagesTab.name, true)
end

function DevHelperMessagesTab.OnLoad ()
	DevHelperMessagesTab.isLoaded = false
	DevHelperMessagesTab.MessagesListSelectedIndex = nil
	DevHelperMessagesTab.isLoaded = true

	DevHelperMessagesTab.OnMessagesListUpdate()
end

function DevHelperMessagesTab.OnMessagesListPopulate ()

	local list = _G[DevHelperMessagesTab.name.."List"]
	if (list.PopulatorIndices == nil) then return end

	local row_window_name
	local data
	local label

	for k, v in ipairs (list.PopulatorIndices) do
		row_window_name = DevHelperMessagesTab.name.."ListRow"..k
		data = DevHelperMessagesTab.messagesListData[v]

		if not data.submenu then 
			data.submenu = "None";
		end

		if (v == DevHelperMessagesTab.MessagesListSelectedIndex) then
			WindowSetShowing (row_window_name.."Background", true)
			WindowSetAlpha (row_window_name.."Background", 0.5)
			WindowSetTintColor (row_window_name.."Background", 150, 150, 150)
		else
			WindowSetShowing (row_window_name.."Background", false)
		end

		label = data.label
		if data.isNotEnabled then
			label = label .. " [disabled]"
			if (v ~= DevHelperMessagesTab.MessagesListSelectedIndex) then
				WindowSetShowing (row_window_name.."Background", true)
				WindowSetAlpha (row_window_name.."Background", 0.5)
				WindowSetTintColor (row_window_name.."Background", 20, 20, 20)
			end
		end
		if data.submenu == "Parent" then
			label = "     " .. label
		end
		if data.submenu ~= "None" then
			label = label .. " [sub: " .. data.submenu .. "]"
		end
		LabelSetText (row_window_name.."Text", towstring(label))

		local color = DevHelper.Colors[data.labelColor] or DevHelper.Colors["white"]
		LabelSetTextColor(row_window_name.."Text", color[1], color[2], color[3])

	end
end

function DevHelperMessagesTab.OnMessagesListUpdate ()

	if (table.getn(DevHelperMessagesTab.messagesListData) == 0) then
		for i=1, #DevHelper.activeSettings.messages do
			local data = DevHelper.activeSettings.messages[i]
			tinsert (DevHelperMessagesTab.messagesListData, data)
		end
	end
	DevHelperMessagesTab.messagesListIndexes = {}
	for i=1, #DevHelperMessagesTab.messagesListData do
		tinsert (DevHelperMessagesTab.messagesListIndexes, i)
	end

	ListBoxSetDisplayOrder (DevHelperMessagesTab.name.."List", DevHelperMessagesTab.messagesListIndexes)
end

function DevHelperMessagesTab.OnListLButtonUp ()

	local dataIndex = ListBoxGetDataIndex (DevHelperMessagesTab.name.."List", WindowGetId (SystemData.MouseOverWindow.name))

	if (dataIndex == nil) then
		DevHelperMessagesTab.MessagesListSelectedIndex = nil
	else
		DevHelperMessagesTab.MessagesListSelectedIndex = DevHelperMessagesTab.messagesListIndexes[dataIndex]
	end

	DevHelperMessagesTab.ListSelChanged ()
end

function DevHelperMessagesTab.ListSelChanged ()

	if (not DevHelperMessagesTab.isLoaded) then return end

	local data = DevHelperMessagesTab.messagesListData[DevHelperMessagesTab.MessagesListSelectedIndex]
	if (not data) then
		DevHelperMessagesTab.MessagesListSelectedIndex = nil
	end

	DevHelperMessagesTab.OnMessagesListUpdate ()
	ButtonSetDisabledFlag (DevHelperMessagesTab.name.."EditButton", DevHelperMessagesTab.MessagesListSelectedIndex == nil)
	ButtonSetDisabledFlag (DevHelperMessagesTab.name.."DeleteButton", DevHelperMessagesTab.MessagesListSelectedIndex == nil)
	ButtonSetDisabledFlag (DevHelperMessagesTab.name.."UpButton", DevHelperMessagesTab.MessagesListSelectedIndex == nil or DevHelperMessagesTab.MessagesListSelectedIndex == 1)
	ButtonSetDisabledFlag (DevHelperMessagesTab.name.."DownButton", DevHelperMessagesTab.MessagesListSelectedIndex == nil or DevHelperMessagesTab.MessagesListSelectedIndex == #DevHelperMessagesTab.messagesListData)
	--ButtonSetDisabledFlag (DevHelperMessagesTab.name.."ExportButton", DevHelperMessagesTab.MessagesListSelectedIndex == nil)

	if (data and data.isNotEnabled)
	then
		ButtonSetText (DevHelperMessagesTab.name.."EnableButton", L"Enable")
	else
		ButtonSetText (DevHelperMessagesTab.name.."EnableButton", L"Disable")
	end

	ButtonSetDisabledFlag (DevHelperMessagesTab.name.."EnableButton", DevHelperMessagesTab.MessagesListSelectedIndex == nil)
end

function DevHelperMessagesTab.MessageAdd ()

	local obj = DevHelperMessage.New ()

	obj:Edit (function (message)
		tinsert (DevHelperMessagesTab.messagesListData, message)

		DevHelperMessagesTab.MessagesListSelectedIndex = #DevHelperMessagesTab.messagesListData
		DevHelperMessagesTab.ListSelChanged ()
		ButtonSetDisabledFlag(DevHelperMessagesTab.name .. "SaveButton", false)
	end)
end

function DevHelperMessagesTab.MessageEdit ()

	if (not DevHelperMessagesTab.isLoaded
		or not DevHelperMessagesTab.MessagesListSelectedIndex
		or ButtonGetDisabledFlag (DevHelperMessagesTab.name.."EditButton")) then return end

	local data = DevHelperMessagesTab.messagesListData[DevHelperMessagesTab.MessagesListSelectedIndex]
	local obj = DevHelperMessage.New (data)
	obj:Edit (function (message)
		DevHelperMessagesTab.messagesListData[DevHelperMessagesTab.MessagesListSelectedIndex] = message
		DevHelperMessagesTab.ListSelChanged ()
		ButtonSetDisabledFlag(DevHelperMessagesTab.name .. "SaveButton", false)
	end)
end

function DevHelperMessagesTab.ListDelete ()

	if (not DevHelperMessagesTab.isLoaded
		or not DevHelperMessagesTab.MessagesListSelectedIndex
		or ButtonGetDisabledFlag (DevHelperMessagesTab.name.."DeleteButton")) then return end

	DialogManager.MakeTwoButtonDialog (
		L"Delete Message '".. towstring(DevHelperMessagesTab.messagesListData[DevHelperMessagesTab.MessagesListSelectedIndex].label)..L"' ?",
		L"Yes", 
		function ()
			table.remove (DevHelperMessagesTab.messagesListData, DevHelperMessagesTab.MessagesListSelectedIndex)
			DevHelperMessagesTab.MessagesListSelectedIndex = nil
			DevHelperMessagesTab.ListSelChanged ()
			ButtonSetDisabledFlag(DevHelperMessagesTab.name .. "SaveButton", false)
		end,
		L"No")
end

function DevHelperMessagesTab.ListUp ()

	if (not DevHelperMessagesTab.isLoaded
		or not DevHelperMessagesTab.MessagesListSelectedIndex
		or ButtonGetDisabledFlag (DevHelperMessagesTab.name.."UpButton")) then return end

	local index = DevHelperMessagesTab.MessagesListSelectedIndex

	local tmp = DevHelperMessagesTab.messagesListData[index - 1]
	DevHelperMessagesTab.messagesListData[index - 1] = DevHelperMessagesTab.messagesListData[index]
	DevHelperMessagesTab.messagesListData[index] = tmp

	DevHelperMessagesTab.MessagesListSelectedIndex = index - 1
	DevHelperMessagesTab.ListSelChanged()
	ButtonSetDisabledFlag(DevHelperMessagesTab.name .. "SaveButton", false)
end

function DevHelperMessagesTab.ListDown ()

	if (not DevHelperMessagesTab.isLoaded
		or not DevHelperMessagesTab.MessagesListSelectedIndex
		or ButtonGetDisabledFlag (DevHelperMessagesTab.name.."DownButton")) then return end

	local index = DevHelperMessagesTab.MessagesListSelectedIndex

	local tmp = DevHelperMessagesTab.messagesListData[index + 1]
	DevHelperMessagesTab.messagesListData[index + 1] = DevHelperMessagesTab.messagesListData[index]
	DevHelperMessagesTab.messagesListData[index] = tmp

	DevHelperMessagesTab.MessagesListSelectedIndex = index + 1
	DevHelperMessagesTab.ListSelChanged()
	ButtonSetDisabledFlag(DevHelperMessagesTab.name .. "SaveButton", false)
end

function DevHelperMessagesTab.ListEnable ()

	if (not DevHelperMessagesTab.isLoaded
		or not DevHelperMessagesTab.MessagesListSelectedIndex
		or ButtonGetDisabledFlag (DevHelperMessagesTab.name.."EnableButton")) then return end

	local data = DevHelperMessagesTab.messagesListData[DevHelperMessagesTab.MessagesListSelectedIndex]
	data.isNotEnabled = not data.isNotEnabled

	DevHelperMessagesTab.ListSelChanged()
	ButtonSetDisabledFlag(DevHelperMessagesTab.name .. "SaveButton", false)
end

function DevHelperMessagesTab.OnMouseOverSaveButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Permanently save the changes made above.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperMessagesTab.OnMouseOverResetButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Reset everything above to the default values.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperMessagesTab.OnMouseOverApplyButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Preview and test the changes made above before you save them.\nAlso notice, while the config window is open, your messages will not be posted to the normal chat, so you can test without annoying other people.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperMessagesTab.OnResetMessages ()
	DialogManager.MakeTwoButtonDialog (
	L"Reset all messages? This will delete your changes and load the default messages.",
	L"Yes",
	function ()
		DevHelperMessagesTab.messagesListData = DevHelper.DefaultSettings.messages
		DevHelperMessagesTab.OnMessagesListUpdate()
		ButtonSetDisabledFlag(DevHelperMessagesTab.name .. "SaveButton", false)
	end,
	L"No")
end

function DevHelperMessagesTab.OnPreviewMessages ()
	DevHelper.activeSettings.messages = DevHelperMessagesTab.messagesListData
	DevHelper.createDevHelperWindow()
end

function DevHelperMessagesTab.OnSaveMessages ()
	DialogManager.MakeTwoButtonDialog (
	L"Save all messages? This makes your changes persistent and cannot be undone?",
	L"Yes",
	function ()
		DevHelper.Settings.messages = DevHelperMessagesTab.messagesListData
		DevHelper.setActiveSettings(DevHelper.Settings)
		DevHelper.createDevHelperWindow()

		ButtonSetDisabledFlag(DevHelperMessagesTab.name .. "SaveButton", true)
		ModulesSaveSettings() -- Write SavedVariables.lua to disk
	end,
	L"No")
end

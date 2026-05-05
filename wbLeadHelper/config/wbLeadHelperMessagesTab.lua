wbLeadHelperMessagesTab = {}

local tinsert = table.insert

wbLeadHelperMessagesTab.name = "wbLeadHelperMessagesTabContent"

local function stripCloneSuffix(label)
	label = tostring(label or "")
	if label == "" then return "", nil end

	local base, suffix = label:match("^(.-)%s%((%d+)%)$")
	if base and base ~= "" then
		return base, tonumber(suffix)
	end
	return label, nil
end

local function buildCloneLabel(originalLabel)
	local base, suffix = stripCloneSuffix(originalLabel)
	local highest = suffix or 0

	for _, entry in ipairs(wbLeadHelperMessagesTab.messagesListData) do
		local entryBase, entrySuffix = stripCloneSuffix(entry.label or "")
		if entryBase == base then
			highest = math.max(highest, entrySuffix or 0)
		end
	end

	return base .. " (" .. (highest + 1) .. ")"
end

function wbLeadHelperMessagesTab.Initialize()

	wbLeadHelperMessagesTab.messagesListData = {}

	-- Content setup
	LabelSetText(wbLeadHelperMessagesTab.name .. "Label", L"Messages")

	WindowSetTintColor (wbLeadHelperMessagesTab.name.."ListBackground", 100, 100, 100)
	WindowSetAlpha (wbLeadHelperMessagesTab.name.."ListBackground", 0.5)
	ButtonSetText (wbLeadHelperMessagesTab.name.."AddButton", L"Add")
	ButtonSetText (wbLeadHelperMessagesTab.name.."EditButton", L"Edit")
	ButtonSetText (wbLeadHelperMessagesTab.name.."CloneButton", L"Clone")
	ButtonSetText (wbLeadHelperMessagesTab.name.."DeleteButton", L"Delete")
	ButtonSetText (wbLeadHelperMessagesTab.name.."UpButton", L"Up")
	ButtonSetText (wbLeadHelperMessagesTab.name.."DownButton", L"Down")

	-- Bottom buttons
	ButtonSetDisabledFlag(wbLeadHelperConfigTab.name .. "SaveButton", true)
	ButtonSetDisabledFlag(wbLeadHelperMessagesTab.name .. "CloneButton", true)
	ButtonSetText(wbLeadHelperMessagesTab.name .. "SaveButton", L"Save")
	ButtonSetText(wbLeadHelperMessagesTab.name .. "ResetButton", L"Reset")
	ButtonSetText(wbLeadHelperMessagesTab.name .. "ApplyButton", L"Preview")

	wbLeadHelperMessagesTab.OnLoad()
end

function wbLeadHelperMessagesTab.Hide()
	WindowSetShowing(wbLeadHelperMessagesTab.name, false)
end
function wbLeadHelperMessagesTab.Show()
	WindowSetShowing(wbLeadHelperMessagesTab.name, true)
end

function wbLeadHelperMessagesTab.OnLoad ()
	wbLeadHelperMessagesTab.isLoaded = false
	wbLeadHelperMessagesTab.MessagesListSelectedIndex = nil
	wbLeadHelperMessagesTab.isLoaded = true

	wbLeadHelperMessagesTab.OnMessagesListUpdate()
end

function wbLeadHelperMessagesTab.OnMessagesListPopulate ()

	local list = _G[wbLeadHelperMessagesTab.name.."List"]
	if (list.PopulatorIndices == nil) then return end

	local row_window_name
	local data
	local label

	for k, v in ipairs (list.PopulatorIndices) do
		row_window_name = wbLeadHelperMessagesTab.name.."ListRow"..k
		data = wbLeadHelperMessagesTab.messagesListData[v]

		if not data.submenu then 
			data.submenu = "None";
		end

		if (v == wbLeadHelperMessagesTab.MessagesListSelectedIndex) then
			WindowSetShowing (row_window_name.."Background", true)
			WindowSetAlpha (row_window_name.."Background", 0.5)
			WindowSetTintColor (row_window_name.."Background", 150, 150, 150)
		else
			WindowSetShowing (row_window_name.."Background", false)
		end

		label = data.label
		if data.isNotEnabled then
			label = label .. " [disabled]"
			if (v ~= wbLeadHelperMessagesTab.MessagesListSelectedIndex) then
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

		local color = wbLeadHelper.Colors[data.labelColor] or wbLeadHelper.Colors["white"]
		LabelSetTextColor(row_window_name.."Text", color[1], color[2], color[3])

	end
end

function wbLeadHelperMessagesTab.OnMessagesListUpdate ()

	if (table.getn(wbLeadHelperMessagesTab.messagesListData) == 0) then
		for i=1, #wbLeadHelper.activeSettings.messages do
			local data = wbLeadHelper.activeSettings.messages[i]
			tinsert (wbLeadHelperMessagesTab.messagesListData, data)
		end
	end
	wbLeadHelperMessagesTab.messagesListIndexes = {}
	for i=1, #wbLeadHelperMessagesTab.messagesListData do
		tinsert (wbLeadHelperMessagesTab.messagesListIndexes, i)
	end

	ListBoxSetDisplayOrder (wbLeadHelperMessagesTab.name.."List", wbLeadHelperMessagesTab.messagesListIndexes)
end

function wbLeadHelperMessagesTab.OnListLButtonUp ()

	local dataIndex = ListBoxGetDataIndex (wbLeadHelperMessagesTab.name.."List", WindowGetId (SystemData.MouseOverWindow.name))

	if (dataIndex == nil) then
		wbLeadHelperMessagesTab.MessagesListSelectedIndex = nil
	else
		wbLeadHelperMessagesTab.MessagesListSelectedIndex = wbLeadHelperMessagesTab.messagesListIndexes[dataIndex]
	end

	wbLeadHelperMessagesTab.ListSelChanged ()
end

function wbLeadHelperMessagesTab.ListSelChanged ()

	if (not wbLeadHelperMessagesTab.isLoaded) then return end

	local data = wbLeadHelperMessagesTab.messagesListData[wbLeadHelperMessagesTab.MessagesListSelectedIndex]
	if (not data) then
		wbLeadHelperMessagesTab.MessagesListSelectedIndex = nil
	end

	wbLeadHelperMessagesTab.OnMessagesListUpdate ()
	ButtonSetDisabledFlag (wbLeadHelperMessagesTab.name.."EditButton", wbLeadHelperMessagesTab.MessagesListSelectedIndex == nil)
	ButtonSetDisabledFlag (wbLeadHelperMessagesTab.name.."CloneButton", wbLeadHelperMessagesTab.MessagesListSelectedIndex == nil)
	ButtonSetDisabledFlag (wbLeadHelperMessagesTab.name.."DeleteButton", wbLeadHelperMessagesTab.MessagesListSelectedIndex == nil)
	ButtonSetDisabledFlag (wbLeadHelperMessagesTab.name.."UpButton", wbLeadHelperMessagesTab.MessagesListSelectedIndex == nil or wbLeadHelperMessagesTab.MessagesListSelectedIndex == 1)
	ButtonSetDisabledFlag (wbLeadHelperMessagesTab.name.."DownButton", wbLeadHelperMessagesTab.MessagesListSelectedIndex == nil or wbLeadHelperMessagesTab.MessagesListSelectedIndex == #wbLeadHelperMessagesTab.messagesListData)
	--ButtonSetDisabledFlag (wbLeadHelperMessagesTab.name.."ExportButton", wbLeadHelperMessagesTab.MessagesListSelectedIndex == nil)

	if (data and data.isNotEnabled)
	then
		ButtonSetText (wbLeadHelperMessagesTab.name.."EnableButton", L"Enable")
	else
		ButtonSetText (wbLeadHelperMessagesTab.name.."EnableButton", L"Disable")
	end

	ButtonSetDisabledFlag (wbLeadHelperMessagesTab.name.."EnableButton", wbLeadHelperMessagesTab.MessagesListSelectedIndex == nil)
end

function wbLeadHelperMessagesTab.MessageAdd ()

	local obj = WbLeadHelperMessage.New ()

	obj:Edit (function (message)
		tinsert (wbLeadHelperMessagesTab.messagesListData, message)

		wbLeadHelperMessagesTab.MessagesListSelectedIndex = #wbLeadHelperMessagesTab.messagesListData
		wbLeadHelperMessagesTab.ListSelChanged ()
		ButtonSetDisabledFlag(wbLeadHelperMessagesTab.name .. "SaveButton", false)
	end)
end

function wbLeadHelperMessagesTab.MessageEdit ()

	if (not wbLeadHelperMessagesTab.isLoaded
		or not wbLeadHelperMessagesTab.MessagesListSelectedIndex
		or ButtonGetDisabledFlag (wbLeadHelperMessagesTab.name.."EditButton")) then return end

	local data = wbLeadHelperMessagesTab.messagesListData[wbLeadHelperMessagesTab.MessagesListSelectedIndex]
	local obj = WbLeadHelperMessage.New (data)
	obj:Edit (function (message)
		wbLeadHelperMessagesTab.messagesListData[wbLeadHelperMessagesTab.MessagesListSelectedIndex] = message
		wbLeadHelperMessagesTab.ListSelChanged ()
		ButtonSetDisabledFlag(wbLeadHelperMessagesTab.name .. "SaveButton", false)
	end)
end

function wbLeadHelperMessagesTab.MessageClone ()

	if (not wbLeadHelperMessagesTab.isLoaded
		or not wbLeadHelperMessagesTab.MessagesListSelectedIndex
		or ButtonGetDisabledFlag (wbLeadHelperMessagesTab.name.."CloneButton")) then return end

	local source = wbLeadHelperMessagesTab.messagesListData[wbLeadHelperMessagesTab.MessagesListSelectedIndex]
	if not source then return end

	local clone = {}
	for key, value in pairs(source) do
		clone[key] = value
	end
	clone.label = buildCloneLabel(source.label or "")

	local insertIndex = wbLeadHelperMessagesTab.MessagesListSelectedIndex + 1
	tinsert(wbLeadHelperMessagesTab.messagesListData, insertIndex, clone)

	wbLeadHelperMessagesTab.MessagesListSelectedIndex = insertIndex
	wbLeadHelperMessagesTab.ListSelChanged()
	ButtonSetDisabledFlag(wbLeadHelperMessagesTab.name .. "SaveButton", false)
end

function wbLeadHelperMessagesTab.ListDelete ()

	if (not wbLeadHelperMessagesTab.isLoaded
		or not wbLeadHelperMessagesTab.MessagesListSelectedIndex
		or ButtonGetDisabledFlag (wbLeadHelperMessagesTab.name.."DeleteButton")) then return end

	DialogManager.MakeTwoButtonDialog (
		L"Delete Message '".. towstring(wbLeadHelperMessagesTab.messagesListData[wbLeadHelperMessagesTab.MessagesListSelectedIndex].label)..L"' ?",
		L"Yes", 
		function ()
			table.remove (wbLeadHelperMessagesTab.messagesListData, wbLeadHelperMessagesTab.MessagesListSelectedIndex)
			wbLeadHelperMessagesTab.MessagesListSelectedIndex = nil
			wbLeadHelperMessagesTab.ListSelChanged ()
			ButtonSetDisabledFlag(wbLeadHelperMessagesTab.name .. "SaveButton", false)
		end,
		L"No")
end

function wbLeadHelperMessagesTab.ListUp ()

	if (not wbLeadHelperMessagesTab.isLoaded
		or not wbLeadHelperMessagesTab.MessagesListSelectedIndex
		or ButtonGetDisabledFlag (wbLeadHelperMessagesTab.name.."UpButton")) then return end

	local index = wbLeadHelperMessagesTab.MessagesListSelectedIndex

	local tmp = wbLeadHelperMessagesTab.messagesListData[index - 1]
	wbLeadHelperMessagesTab.messagesListData[index - 1] = wbLeadHelperMessagesTab.messagesListData[index]
	wbLeadHelperMessagesTab.messagesListData[index] = tmp

	wbLeadHelperMessagesTab.MessagesListSelectedIndex = index - 1
	wbLeadHelperMessagesTab.ListSelChanged()
	ButtonSetDisabledFlag(wbLeadHelperMessagesTab.name .. "SaveButton", false)
end

function wbLeadHelperMessagesTab.ListDown ()

	if (not wbLeadHelperMessagesTab.isLoaded
		or not wbLeadHelperMessagesTab.MessagesListSelectedIndex
		or ButtonGetDisabledFlag (wbLeadHelperMessagesTab.name.."DownButton")) then return end

	local index = wbLeadHelperMessagesTab.MessagesListSelectedIndex

	local tmp = wbLeadHelperMessagesTab.messagesListData[index + 1]
	wbLeadHelperMessagesTab.messagesListData[index + 1] = wbLeadHelperMessagesTab.messagesListData[index]
	wbLeadHelperMessagesTab.messagesListData[index] = tmp

	wbLeadHelperMessagesTab.MessagesListSelectedIndex = index + 1
	wbLeadHelperMessagesTab.ListSelChanged()
	ButtonSetDisabledFlag(wbLeadHelperMessagesTab.name .. "SaveButton", false)
end

function wbLeadHelperMessagesTab.ListEnable ()

	if (not wbLeadHelperMessagesTab.isLoaded
		or not wbLeadHelperMessagesTab.MessagesListSelectedIndex
		or ButtonGetDisabledFlag (wbLeadHelperMessagesTab.name.."EnableButton")) then return end

	local data = wbLeadHelperMessagesTab.messagesListData[wbLeadHelperMessagesTab.MessagesListSelectedIndex]
	data.isNotEnabled = not data.isNotEnabled

	wbLeadHelperMessagesTab.ListSelChanged()
	ButtonSetDisabledFlag(wbLeadHelperMessagesTab.name .. "SaveButton", false)
end

function wbLeadHelperMessagesTab.OnMouseOverSaveButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Permanently save the changes made above.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function wbLeadHelperMessagesTab.OnMouseOverResetButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Reset everything above to the default values.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function wbLeadHelperMessagesTab.OnMouseOverApplyButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Preview and test the changes made above before you save them.\nAlso notice, while the config window is open, your messages will not be posted to the normal chat, so you can test without annoying other people.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function wbLeadHelperMessagesTab.OnResetMessages ()
	DialogManager.MakeTwoButtonDialog (
	L"Reset all messages? This will delete your changes and load the default messages.",
	L"Yes",
	function ()
		wbLeadHelperMessagesTab.messagesListData = wbLeadHelper.DefaultSettings.messages
		wbLeadHelperMessagesTab.OnMessagesListUpdate()
		ButtonSetDisabledFlag(wbLeadHelperMessagesTab.name .. "SaveButton", false)
	end,
	L"No")
end

function wbLeadHelperMessagesTab.OnPreviewMessages ()
	wbLeadHelper.activeSettings.messages = wbLeadHelperMessagesTab.messagesListData
	wbLeadHelper.createWbLeadHelperWindow()
end

function wbLeadHelperMessagesTab.OnSaveMessages ()
	DialogManager.MakeTwoButtonDialog (
	L"Save all messages? This makes your changes persistent and cannot be undone?",
	L"Yes",
	function ()
		wbLeadHelper.EnsureSettingsTable()
		wbLeadHelper.Settings.messages = wbLeadHelperMessagesTab.messagesListData
		wbLeadHelper.setActiveSettings(wbLeadHelper.Settings)
		wbLeadHelper.createWbLeadHelperWindow()

		ButtonSetDisabledFlag(wbLeadHelperMessagesTab.name .. "SaveButton", true)
		ModulesSaveSettings() -- Write SavedVariables.lua to disk
	end,
	L"No")
end

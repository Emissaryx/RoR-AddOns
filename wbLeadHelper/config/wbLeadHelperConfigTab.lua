wbLeadHelperConfigTab = {}

wbLeadHelperConfigTab.name = "wbLeadHelperConfigTabContent"

local config_dlg = {
	colors = {},
	showLfgIcons = false,
	disableAltSpecCheck = false,
	disableAltSpecCheckForRunePriestZealot = false,
}

local function GetLabelTooltipAnchor()
	return Tooltips.ANCHOR_CURSOR_LEFT or { Point = "topleft", RelativeTo = "CursorWindow", RelativePoint = "topright", XOffset = 0, YOffset = 0 }
end

local function GetCheckboxTooltipAnchor()
	return Tooltips.ANCHOR_CURSOR or { Point = "bottomleft", RelativeTo = "CursorWindow", RelativePoint = "topleft", XOffset = 0, YOffset = 0 }
end

function wbLeadHelperConfigTab.Initialize()

	-- Content setup
	LabelSetText(wbLeadHelperConfigTab.name .. "MessageLabel", L"Message")
	ButtonSetText(wbLeadHelperConfigTab.name .. "ChooseIconButtonMessageStart", L"Icon")
	LabelSetText(wbLeadHelperConfigTab.name .. "MessageStartLabel", L"Start:")
	LabelSetText(wbLeadHelperConfigTab.name .. "MessageEndLabel", L"End:")
	ButtonSetText(wbLeadHelperConfigTab.name .. "ChooseIconButtonMessageEnd", L"Icon")
	LabelSetText(wbLeadHelperConfigTab.name .. "MessageTextColorLabel", L"Text color:")
	local i = 1
	for k,v in pairs(wbLeadHelper.Colors) do
		ComboBoxAddMenuItem (wbLeadHelperConfigTab.name .."MessageTextColorCombobox", towstring(k))
		config_dlg.colors[i] = k
		i = i + 1
	end
	LabelSetText(wbLeadHelperConfigTab.name .. "LfgIconsLabel", L"LfG Icons:")
	LabelSetText(wbLeadHelperConfigTab.name .. "DisableAltSpecCheckLabel", L"Disable alt-spec:")
	LabelSetText(wbLeadHelperConfigTab.name .. "DisableAltSpecCheckForRunePriestZealotLabel", wbLeadHelperConfigTab.GetRpZealotDisableLabel())

	-- Bottom buttons
	ButtonSetDisabledFlag(wbLeadHelperConfigTab.name .. "SaveButton", true)
	ButtonSetText(wbLeadHelperConfigTab.name .. "SaveButton", L"Save")
	ButtonSetText(wbLeadHelperConfigTab.name .. "ResetButton", L"Reset")
	ButtonSetText(wbLeadHelperConfigTab.name .. "ApplyButton", L"Preview")

	wbLeadHelperConfigTab.OnLoad()
	wbLeadHelperChooseIcon.Initialize()

end

function wbLeadHelperConfigTab.OnLoad ()
	wbLeadHelperConfigTab.isLoaded = false

	-- Load the current effective settings into the form.
	config_dlg.messageStart = wbLeadHelper.activeSettings.messageStart
	TextEditBoxSetText (wbLeadHelperConfigTab.name .. "MessageStartText", towstring( config_dlg.messageStart))
	config_dlg.messageEnd = wbLeadHelper.activeSettings.messageEnd
	TextEditBoxSetText (wbLeadHelperConfigTab.name .. "MessageEndText", towstring( config_dlg.messageEnd))

	config_dlg.textColor = wbLeadHelper.activeSettings.textColor
	if type(config_dlg.textColor) ~= "number" then
		config_dlg.textColor = wbLeadHelper.indexOf(config_dlg.colors, config_dlg.textColor)
	end
	ComboBoxSetSelectedMenuItem (wbLeadHelperConfigTab.name .. "MessageTextColorCombobox", config_dlg.textColor)

	config_dlg.showLfgIcons = wbLeadHelper.activeSettings.showLfgIcons
    ButtonSetPressedFlag(wbLeadHelperConfigTab.name .. "LfgIconsCheckBox", config_dlg.showLfgIcons)

	config_dlg.disableAltSpecCheck = wbLeadHelper.activeSettings.disableAltSpecCheck and true or false
	ButtonSetPressedFlag(wbLeadHelperConfigTab.name .. "DisableAltSpecCheckCheckBox", config_dlg.disableAltSpecCheck)

	config_dlg.disableAltSpecCheckForRunePriestZealot = wbLeadHelper.activeSettings.disableAltSpecCheckForRunePriestZealot and true or false
	ButtonSetPressedFlag(wbLeadHelperConfigTab.name .. "DisableAltSpecCheckForRunePriestZealotCheckBox", config_dlg.disableAltSpecCheckForRunePriestZealot)

	wbLeadHelperConfigTab.isLoaded = true
end

function wbLeadHelperConfigTab.Hide()
	WindowSetShowing(wbLeadHelperConfigTab.name, false)
end
function wbLeadHelperConfigTab.Show()
	WindowSetShowing(wbLeadHelperConfigTab.name, true)
end

function wbLeadHelperConfigTab.OnChanged()
	ButtonSetDisabledFlag(wbLeadHelperConfigTab.name .. "SaveButton", false)
end

function wbLeadHelperConfigTab.OnLfgIconsCheckBoxUp()
    config_dlg.showLfgIcons = not config_dlg.showLfgIcons
    ButtonSetPressedFlag(wbLeadHelperConfigTab.name .. "LfgIconsCheckBox", config_dlg.showLfgIcons)
	ButtonSetDisabledFlag(wbLeadHelperConfigTab.name .. "SaveButton", false)
end

function wbLeadHelperConfigTab.OnDisableAltSpecCheckCheckBoxUp()
	config_dlg.disableAltSpecCheck = not config_dlg.disableAltSpecCheck
	ButtonSetPressedFlag(wbLeadHelperConfigTab.name .. "DisableAltSpecCheckCheckBox", config_dlg.disableAltSpecCheck)
	ButtonSetDisabledFlag(wbLeadHelperConfigTab.name .. "SaveButton", false)
end

function wbLeadHelperConfigTab.OnDisableAltSpecCheckForRunePriestZealotCheckBoxUp()
	config_dlg.disableAltSpecCheckForRunePriestZealot = not config_dlg.disableAltSpecCheckForRunePriestZealot
	ButtonSetPressedFlag(wbLeadHelperConfigTab.name .. "DisableAltSpecCheckForRunePriestZealotCheckBox", config_dlg.disableAltSpecCheckForRunePriestZealot)
	ButtonSetDisabledFlag(wbLeadHelperConfigTab.name .. "SaveButton", false)
end

function wbLeadHelperConfigTab.ChooseIconMessageStart ()
	wbLeadHelperChooseIcon.Open (function (iconId)
		local text = TextEditBoxGetText (wbLeadHelperConfigTab.name .. "MessageStartText")
		TextEditBoxSetText (wbLeadHelperConfigTab.name .. "MessageStartText", text .. L"<icon" .. iconId .. L">")
	end)
end

function wbLeadHelperConfigTab.ChooseIconMessageEnd ()
	wbLeadHelperChooseIcon.Open (function (iconId)
		local text = TextEditBoxGetText (wbLeadHelperConfigTab.name .. "MessageEndText")
		TextEditBoxSetText (wbLeadHelperConfigTab.name .. "MessageEndText", text .. L"<icon" .. iconId .. L">")
	end)
end

function wbLeadHelperConfigTab.OnMouseOverMessageStartLabel()
	-- just a tooltip
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"This text will be added in front of each message.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( GetLabelTooltipAnchor() )
end

function wbLeadHelperConfigTab.OnMouseOverMessageEndLabel()
	-- just a tooltip
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"This text will be added after of each message.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( GetLabelTooltipAnchor() )
end

function wbLeadHelperConfigTab.OnMouseOverMessageTextColorLabel()
	-- just a tooltip
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"The color used for 'Permanent colored chat' mode.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( GetLabelTooltipAnchor() )
end

function wbLeadHelperConfigTab.OnMouseOverLfgIconsLabel()
	-- just a tooltip
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Use career icons in LFM messages.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( GetLabelTooltipAnchor() )
end

function wbLeadHelperConfigTab.OnMouseOverLfgIconsCheckBox()
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Use career icons in LFM messages.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( GetCheckboxTooltipAnchor() )
end

function wbLeadHelperConfigTab.GetRpZealotDisableLabel()
	if (GameData and GameData.Player and GameData.Realm and GameData.Player.realm == GameData.Realm.ORDER) then
		return L"Ignore RP alt-spec:"
	end

	if (GameData and GameData.Player and GameData.Realm and GameData.Player.realm ~= nil) then
		return L"Ignore Zealot alt-spec:"
	end

	return L"Ignore RP/Zealot alt-spec:"
end

function wbLeadHelperConfigTab.GetRpZealotDisableTooltip()
	if (GameData and GameData.Player and GameData.Realm and GameData.Player.realm == GameData.Realm.ORDER) then
		return L"Ignore alt-spec flags for Rune Priests when building AUTO LFM role counts."
	end

	if (GameData and GameData.Player and GameData.Realm and GameData.Player.realm ~= nil) then
		return L"Ignore alt-spec flags for Zealots when building AUTO LFM role counts."
	end

	return L"Ignore alt-spec flags for Rune Priests and Zealots when building AUTO LFM role counts."
end

function wbLeadHelperConfigTab.OnMouseOverDisableAltSpecCheckLabel()
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Disable all alt-spec checks when AUTO LFM counts missing roles.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( GetLabelTooltipAnchor() )
end

function wbLeadHelperConfigTab.OnMouseOverDisableAltSpecCheckCheckBox()
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Disable all alt-spec checks when AUTO LFM counts missing roles.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( GetCheckboxTooltipAnchor() )
end

function wbLeadHelperConfigTab.OnMouseOverDisableAltSpecCheckForRunePriestZealotLabel()
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, wbLeadHelperConfigTab.GetRpZealotDisableTooltip())
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( GetLabelTooltipAnchor() )
end

function wbLeadHelperConfigTab.OnMouseOverDisableAltSpecCheckForRunePriestZealotCheckBox()
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, wbLeadHelperConfigTab.GetRpZealotDisableTooltip())
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( GetCheckboxTooltipAnchor() )
end

function wbLeadHelperConfigTab.OnMouseOverSaveButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Permanently save the changes made above.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function wbLeadHelperConfigTab.OnMouseOverResetButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Reset everything above to the default values.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function wbLeadHelperConfigTab.OnMouseOverApplyButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Preview and test the changes made above before you save them.\nAlso notice, while the config window is open, your messages will not be posted to the normal chat, so you can test without annoying other people.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function wbLeadHelperConfigTab.OnReset ()
	DialogManager.MakeTwoButtonDialog (
	L"Reset changes? This will delete your current and load the default settings.",
	L"Yes",
	function ()
		config_dlg.messageStart = wbLeadHelper.DefaultSettings.messageStart
		TextEditBoxSetText (wbLeadHelperConfigTab.name .. "MessageStartText", towstring( config_dlg.messageStart))
		config_dlg.messageEnd = wbLeadHelper.DefaultSettings.messageEnd
		TextEditBoxSetText (wbLeadHelperConfigTab.name .. "MessageEndText", towstring( config_dlg.messageEnd))

		config_dlg.textColor = wbLeadHelper.DefaultSettings.textColor
		if type(config_dlg.textColor) ~= "number" then
			config_dlg.textColor = wbLeadHelper.indexOf(config_dlg.colors, config_dlg.textColor)
		end
		ComboBoxSetSelectedMenuItem (wbLeadHelperConfigTab.name .. "MessageTextColorCombobox", config_dlg.textColor)

		config_dlg.showLfgIcons = wbLeadHelper.DefaultSettings.showLfgIcons
	    ButtonSetPressedFlag(wbLeadHelperConfigTab.name .. "LfgIconsCheckBox", config_dlg.showLfgIcons)

		config_dlg.disableAltSpecCheck = wbLeadHelper.DefaultSettings.disableAltSpecCheck
	    ButtonSetPressedFlag(wbLeadHelperConfigTab.name .. "DisableAltSpecCheckCheckBox", config_dlg.disableAltSpecCheck)

		config_dlg.disableAltSpecCheckForRunePriestZealot = wbLeadHelper.DefaultSettings.disableAltSpecCheckForRunePriestZealot
	    ButtonSetPressedFlag(wbLeadHelperConfigTab.name .. "DisableAltSpecCheckForRunePriestZealotCheckBox", config_dlg.disableAltSpecCheckForRunePriestZealot)

		ButtonSetDisabledFlag(wbLeadHelperConfigTab.name .. "SaveButton", false)
	end,
	L"No")
end

function wbLeadHelperConfigTab.OnPreview ()
	wbLeadHelperConfigTab.locallyStoreFormData()

	wbLeadHelper.activeSettings.messageStart = config_dlg.messageStart
	wbLeadHelper.activeSettings.messageEnd = config_dlg.messageEnd
	wbLeadHelper.activeSettings.textColor = config_dlg.textColor
	wbLeadHelper.activeSettings.showLfgIcons = config_dlg.showLfgIcons
	wbLeadHelper.activeSettings.disableAltSpecCheck = config_dlg.disableAltSpecCheck
	wbLeadHelper.activeSettings.disableAltSpecCheckForRunePriestZealot = config_dlg.disableAltSpecCheckForRunePriestZealot

	wbLeadHelper.createWbLeadHelperWindow()
end

function wbLeadHelperConfigTab.locallyStoreFormData ()
	config_dlg.messageStart = tostring(TextEditBoxGetText (wbLeadHelperConfigTab.name .. "MessageStartText"))
	config_dlg.messageEnd = tostring(TextEditBoxGetText (wbLeadHelperConfigTab.name .. "MessageEndText"))
	config_dlg.textColor = ComboBoxGetSelectedMenuItem (wbLeadHelperConfigTab.name .. "MessageTextColorCombobox")
	config_dlg.textColor = config_dlg.colors[config_dlg.textColor]
    config_dlg.showLfgIcons = ButtonGetPressedFlag(wbLeadHelperConfigTab.name .. "LfgIconsCheckBox")
	config_dlg.disableAltSpecCheck = ButtonGetPressedFlag(wbLeadHelperConfigTab.name .. "DisableAltSpecCheckCheckBox")
	config_dlg.disableAltSpecCheckForRunePriestZealot = ButtonGetPressedFlag(wbLeadHelperConfigTab.name .. "DisableAltSpecCheckForRunePriestZealotCheckBox")
end

function wbLeadHelperConfigTab.OnSave ()
	DialogManager.MakeTwoButtonDialog (
	L"Save changes?",
	L"Yes",
	function ()
		wbLeadHelperConfigTab.locallyStoreFormData()
		wbLeadHelper.EnsureSettingsTable()

		wbLeadHelper.Settings.messageStart = config_dlg.messageStart
			wbLeadHelper.Settings.messageEnd = config_dlg.messageEnd
			wbLeadHelper.Settings.textColor = config_dlg.textColor
			wbLeadHelper.Settings.showLfgIcons = config_dlg.showLfgIcons
			wbLeadHelper.Settings.disableAltSpecCheck = config_dlg.disableAltSpecCheck
			wbLeadHelper.Settings.disableAltSpecCheckForRunePriestZealot = config_dlg.disableAltSpecCheckForRunePriestZealot

			wbLeadHelper.setActiveSettings(wbLeadHelper.Settings)
		
		ButtonSetDisabledFlag(wbLeadHelperConfigTab.name .. "SaveButton", true)
		wbLeadHelper.createWbLeadHelperWindow()
		ModulesSaveSettings() -- Write SavedVariables.lua to disk
	end,
	L"No")
end

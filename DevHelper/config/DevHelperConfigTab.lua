DevHelperConfigTab = {}

DevHelperConfigTab.name = "DevHelperConfigTabContent"

local config_dlg = {
	colors = {},
	showLfgIcons = false,
}

function DevHelperConfigTab.Initialize()

	DevHelperConfigTab.messagesListData = {}

	-- Content setup
	LabelSetText(DevHelperConfigTab.name .. "MessageLabel", L"Message")
	ButtonSetText(DevHelperConfigTab.name .. "ChooseIconButtonMessageStart", L"Icon")
	LabelSetText(DevHelperConfigTab.name .. "MessageStartLabel", L"Start:")
	LabelSetText(DevHelperConfigTab.name .. "MessageEndLabel", L"End:")
	ButtonSetText(DevHelperConfigTab.name .. "ChooseIconButtonMessageEnd", L"Icon")
	LabelSetText(DevHelperConfigTab.name .. "MessageTextColorLabel", L"Text color:")
	local i = 1
	for k,v in pairs(DevHelper.Colors) do
		ComboBoxAddMenuItem (DevHelperConfigTab.name .."MessageTextColorCombobox", towstring(k))
		config_dlg.colors[i] = k
		i = i + 1
	end
	LabelSetText(DevHelperConfigTab.name .. "LfgIconsLabel", L"LfG Icons:")

	-- Bottom buttons
	ButtonSetDisabledFlag(DevHelperConfigTab.name .. "SaveButton", true)
	ButtonSetText(DevHelperConfigTab.name .. "SaveButton", L"Save")
	ButtonSetText(DevHelperConfigTab.name .. "ResetButton", L"Reset")
	ButtonSetText(DevHelperConfigTab.name .. "ApplyButton", L"Preview")

	DevHelperConfigTab.OnLoad()
	DevHelperChooseIcon.Initialize()

end

function DevHelperConfigTab.OnLoad ()
    DevHelperConfigTab.isLoaded = false

    -- Load saved settings here
    config_dlg.messageStart = DevHelper.activeSettings.messageStart
    TextEditBoxSetText (DevHelperConfigTab.name .. "MessageStartText", towstring(config_dlg.messageStart))
    config_dlg.messageEnd = DevHelper.activeSettings.messageEnd
    TextEditBoxSetText (DevHelperConfigTab.name .. "MessageEndText", towstring(config_dlg.messageEnd))

    config_dlg.textColor = DevHelper.activeSettings.textColor
    if type(config_dlg.textColor) ~= "number" then
        config_dlg.textColor = DevHelper.indexOf(config_dlg.colors, config_dlg.textColor)
    end
    
    -- Debugging the value before setting the selected combobox item
    d("Debug - Selected color index: " .. tostring(config_dlg.textColor))
    
    if not config_dlg.textColor or config_dlg.textColor < 1 or config_dlg.textColor > #config_dlg.colors then
        config_dlg.textColor = 1 -- Fallback to the first item if the index is invalid
        d("Debug - Color index was invalid, fallback to default")
    end
    
    ComboBoxSetSelectedMenuItem (DevHelperConfigTab.name .. "MessageTextColorCombobox", config_dlg.textColor)

    config_dlg.showLfgIcons = DevHelper.activeSettings.showLfgIcons
    ButtonSetPressedFlag(DevHelperConfigTab.name .. "LfgIconsCheckBox", config_dlg.showLfgIcons)

    DevHelperConfigTab.isLoaded = true
end

function DevHelperConfigTab.Hide()
	WindowSetShowing(DevHelperConfigTab.name, false)
end
function DevHelperConfigTab.Show()
	WindowSetShowing(DevHelperConfigTab.name, true)
end

function DevHelperConfigTab.OnChanged()
	ButtonSetDisabledFlag(DevHelperConfigTab.name .. "SaveButton", false)
end

function DevHelperConfigTab.OnLfgIconsCheckBoxUp()
    config_dlg.showLfgIcons = not config_dlg.showLfgIcons
    ButtonSetPressedFlag(DevHelperConfigTab.name .. "LfgIconsCheckBox", config_dlg.showLfgIcons)
	ButtonSetDisabledFlag(DevHelperConfigTab.name .. "SaveButton", false)
end

function DevHelperConfigTab.ChooseIconMessageStart ()
	DevHelperChooseIcon.Open (function (iconId)
		local text = TextEditBoxGetText (DevHelperConfigTab.name .. "MessageStartText")
		TextEditBoxSetText (DevHelperConfigTab.name .. "MessageStartText", text .. L"<icon" .. iconId .. L">")
	end)
end

function DevHelperConfigTab.ChooseIconMessageEnd ()
	DevHelperChooseIcon.Open (function (iconId)
		local text = TextEditBoxGetText (DevHelperConfigTab.name .. "MessageEndText")
		TextEditBoxSetText (DevHelperConfigTab.name .. "MessageEndText", text .. L"<icon" .. iconId .. L">")
	end)
end

function DevHelperConfigTab.OnMouseOverMessageStartLabel()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"This text will be added in front of each message.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperConfigTab.OnMouseOverMessageEndLabel()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"This text will be added after of each message.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperConfigTab.OnMouseOverMessageTextColorLabel()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"The color used for 'Permanent colored chat' mode.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperConfigTab.OnMouseOverLfgIconsLabel()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Little career icons will be added to the other messages, instead of the basic ones.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperConfigTab.OnMouseOverSaveButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Permanently save the changes made above.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperConfigTab.OnMouseOverResetButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Reset everything above to the default values.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperConfigTab.OnMouseOverApplyButton()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Preview and test the changes made above before you save them.\nAlso notice, while the config window is open, your messages will not be posted to the normal chat, so you can test without annoying other people.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperConfigTab.OnReset ()
	DialogManager.MakeTwoButtonDialog (
	L"Reset changes? This will delete your current and load the default settings.",
	L"Yes",
	function ()
		config_dlg.messageStart = DevHelper.DefaultSettings.messageStart
		TextEditBoxSetText (DevHelperConfigTab.name .. "MessageStartText", towstring( config_dlg.messageStart))
		config_dlg.messageEnd = DevHelper.DefaultSettings.messageEnd
		TextEditBoxSetText (DevHelperConfigTab.name .. "MessageEndText", towstring( config_dlg.messageEnd))

		config_dlg.textColor = DevHelper.DefaultSettings.textColor
		--------------------------
		if type(config_dlg.textColor) ~= "number" or config_dlg.textColor == nil or config_dlg.textColor < 1 or config_dlg.textColor > #config_dlg.colors then
		config_dlg.textColor = 1 -- Fallback to the first item if the index is invalid
		end
		ComboBoxSetSelectedMenuItem (DevHelperConfigTab.name .. "MessageTextColorCombobox", config_dlg.textColor)
		-------------------------------
		
		-- if type(config_dlg.textColor) ~= "number" then
			-- config_dlg.textColor = DevHelper.indexOf(config_dlg.colors, config_dlg.textColor)
		-- end
		-- ComboBoxSetSelectedMenuItem (DevHelperConfigTab.name .. "MessageTextColorCombobox", config_dlg.textColor)

		config_dlg.showLfgIcons = DevHelper.DefaultSettings.showLfgIcons
	    ButtonSetPressedFlag(DevHelperConfigTab.name .. "LfgIconsCheckBox", config_dlg.showLfgIcons)

		ButtonSetDisabledFlag(DevHelperConfigTab.name .. "SaveButton", false)
	end,
	L"No")
end

function DevHelperConfigTab.OnPreview ()
	DevHelperConfigTab.locallyStoreFormData()

	DevHelper.activeSettings.messageStart = config_dlg.messageStart
	DevHelper.activeSettings.messageEnd = config_dlg.messageEnd
	DevHelper.activeSettings.textColor = config_dlg.textColor
	DevHelper.activeSettings.showLfgIcons = config_dlg.showLfgIcons

	DevHelper.createDevHelperWindow()
end

function DevHelperConfigTab.locallyStoreFormData ()
	config_dlg.messageStart = tostring(TextEditBoxGetText (DevHelperConfigTab.name .. "MessageStartText"))
	config_dlg.messageEnd = tostring(TextEditBoxGetText (DevHelperConfigTab.name .. "MessageEndText"))
	config_dlg.textColor = ComboBoxGetSelectedMenuItem (DevHelperConfigTab.name .. "MessageTextColorCombobox")
	config_dlg.textColor = config_dlg.colors[config_dlg.textColor]
    config_dlg.showLfgIcons = ButtonGetPressedFlag(DevHelperConfigTab.name .. "LfgIconsCheckBox")
end

function DevHelperConfigTab.OnSave ()
	DialogManager.MakeTwoButtonDialog (
	L"Save changes?",
	L"Yes",
	function ()
		DevHelperConfigTab.locallyStoreFormData()

		DevHelper.Settings.messageStart = config_dlg.messageStart
		DevHelper.Settings.messageEnd = config_dlg.messageEnd
		DevHelper.Settings.textColor = config_dlg.textColor
		DevHelper.Settings.showLfgIcons = config_dlg.showLfgIcons

		DevHelper.setActiveSettings(DevHelper.Settings)
		
		ButtonSetDisabledFlag(DevHelperConfigTab.name .. "SaveButton", true)
		DevHelper.createDevHelperWindow()
		ModulesSaveSettings() -- Write SavedVariables.lua to disk
	end,
	L"No")
end
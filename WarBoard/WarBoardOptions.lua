if not WarBoard.Options then WarBoard.Options = {} end
local WarBoardOptions = WarBoard.Options
local LabelSetText, ButtonSetText, ButtonSetPressedFlag, ComboAddMenuItem, SliderBarSetCurrentPosition, ComboBoxSetSelectedMenuItem,
	  ButtonGetPressedFlag, DoesWindowExist, CreateWindow, WindowSetAlpha, WindowSetTintColor, WindowClearAnchors, WindowAddAnchor,
	  DestroyWindow, WindowSetShowing, MakeOneButtonDialog, ipairs, sfind, format, towstring =
	  LabelSetText, ButtonSetText, ButtonSetPressedFlag, ComboAddMenuItem, SliderBarSetCurrentPosition, ComboBoxSetSelectedMenuItem,
	  ButtonGetPressedFlag, DoesWindowExist, CreateWindow, WindowSetAlpha, WindowSetTintColor, WindowClearAnchors, WindowAddAnchor,
	  DestroyWindow, WindowSetShowing, DialogManager.MakeOneButtonDialog, ipairs, string.find, string.format, towstring

local Board = "Top"

function WarBoardOptions.Initialize()
	CreateWindow("WarBoardOptions", false)
	WarBoardOptions.SetUp()
end

function WarBoardOptions.SetUp()
	LabelSetText("WarBoardOptionsTitleBarText", L"WarBoard Options")
	LabelSetText("WarBoardButtonCheckBoxLabel", L"Corner Buttons Enabled")
	--TABS
	ButtonSetText("WarBoardOptionsTabsTopBoardTab", L"Top Board")
	ButtonSetPressedFlag("WarBoardOptionsTabsTopBoardTab", true)
	ButtonSetText("WarBoardOptionsTabsBottomBoardTab", L"Bottom Board")
	--MAIN SETTINGS
	LabelSetText("WarBoardBgName", L"WarBoard Background")
	LabelSetText("WarBoardBgRedName", L"Red")
	LabelSetText("WarBoardBgGreenName", L"Green")
	LabelSetText("WarBoardBgBlueName", L"Blue")
	LabelSetText("WarBoardBgAlphaName", L"Alpha")
	--MODS SETTINGS
	LabelSetText("WarBoardModsName", L"Mod Backgrounds")
	LabelSetText("WarBoardModsRedName", L"Red")
	LabelSetText("WarBoardModsGreenName", L"Green")
	LabelSetText("WarBoardModsBlueName", L"Blue")
	LabelSetText("WarBoardModsAlphaName", L"Alpha")
	--ROW ALIGNMENT
	LabelSetText("WarBoardAlignOptionsName", L"Row Alignment Options")
	for i=1, 4 do
		LabelSetText("WarBoardComboAlignRow"..i.."Name", towstring("Row "..i))
		ComboBoxAddMenuItem("WarBoardComboAlignRow"..i, L"left")
		ComboBoxAddMenuItem("WarBoardComboAlignRow"..i, L"center")
		ComboBoxAddMenuItem("WarBoardComboAlignRow"..i, L"right")
	end
	ButtonSetText("ApplyRowAlignButton", L"Apply Row Alignments")
	--PADDING OPTIONS
	LabelSetText("WarBoardHorizontalPaddingName", L"Horizontal space between mods")
	LabelSetText("WarBoardVerticalPaddingName", L"Vertical space between rows")
	--BUTTONS
	ButtonSetText("ToggleLayoutButton", L"Toggle Layout Mode")
	ButtonSetText("OpenUiModWindowButton", L"UI Mod Settings Window")
	--Toggler Manager
	ButtonSetText("WBTogglerManagerButton", L"Togglers")
	WindowSetShowing("WBTogglerManagerButton", false)
end

function WarBoardOptions.ShowTopOptions()
	ButtonSetPressedFlag("WarBoardOptionsTabsTopBoardTab", true)
	ButtonSetPressedFlag("WarBoardOptionsTabsBottomBoardTab", false)
	--change labels, slider positions, combobox selections and checks for top board
	SliderBarSetCurrentPosition("WarBoardBgRedSlider", WarBoardSettings.Top.Board.Red / 255)
	SliderBarSetCurrentPosition("WarBoardBgGreenSlider", WarBoardSettings.Top.Board.Green / 255)
	SliderBarSetCurrentPosition("WarBoardBgBlueSlider", WarBoardSettings.Top.Board.Blue / 255)
	SliderBarSetCurrentPosition("WarBoardBgAlphaSlider", WarBoardSettings.Top.Board.Alpha)

	SliderBarSetCurrentPosition("WarBoardModsRedSlider", WarBoardSettings.Top.Mods.Red / 255)
	SliderBarSetCurrentPosition("WarBoardModsGreenSlider", WarBoardSettings.Top.Mods.Green / 255)
	SliderBarSetCurrentPosition("WarBoardModsBlueSlider", WarBoardSettings.Top.Mods.Blue / 255)
	SliderBarSetCurrentPosition("WarBoardModsAlphaSlider", WarBoardSettings.Top.Mods.Alpha)
	--MAIN SETTINGS
	LabelSetText("WarBoardBgRedValue", towstring(WarBoardSettings.Top.Board.Red))
	LabelSetText("WarBoardBgGreenValue", towstring(WarBoardSettings.Top.Board.Green))
	LabelSetText("WarBoardBgBlueValue", towstring(WarBoardSettings.Top.Board.Blue))
	LabelSetText("WarBoardBgAlphaValue", towstring(format("%.2f", WarBoardSettings.Top.Board.Alpha)))
	--MODS SETTINGS
	LabelSetText("WarBoardModsRedValue", towstring(WarBoardSettings.Top.Mods.Red))
	LabelSetText("WarBoardModsGreenValue", towstring(WarBoardSettings.Top.Mods.Green))
	LabelSetText("WarBoardModsBlueValue", towstring(WarBoardSettings.Top.Mods.Blue))
	LabelSetText("WarBoardModsAlphaValue", towstring(format("%.2f", WarBoardSettings.Top.Mods.Alpha)))

	ComboBoxSetSelectedMenuItem("WarBoardComboAlignRow1", WarBoardSettings.Top.RowAlign[ 1 ])
	ComboBoxSetSelectedMenuItem("WarBoardComboAlignRow2", WarBoardSettings.Top.RowAlign[ 2 ])
	ComboBoxSetSelectedMenuItem("WarBoardComboAlignRow3", WarBoardSettings.Top.RowAlign[ 3 ])
	ComboBoxSetSelectedMenuItem("WarBoardComboAlignRow4", WarBoardSettings.Top.RowAlign[ 4 ])

	LabelSetText("WarBoardHorizontalPaddingValue", towstring(WarBoardSettings.Top.Board.HorizSpace))
	LabelSetText("WarBoardVerticalPaddingValue", towstring(WarBoardSettings.Top.Board.VertSpace))

	ButtonSetPressedFlag("WarBoardButtonCheckBoxButton", WarBoardSettings.Top.Board.ButtonsOn)
	LabelSetText("WarBoardButtonCheckBoxEnabledLabel", L"Top Board Enabled")
	ButtonSetPressedFlag("WarBoardButtonCheckBoxEnabledButton", WarBoardSettings.Top.Board.Enabled)
	LabelSetText("WarBoardButtonCheckBoxDefaultLabel", L"Top Board Default")
	if WarBoardSettings.DefaultBoard == "Top" then
		ButtonSetPressedFlag("WarBoardButtonCheckBoxDefaultButton", true)
	else
		ButtonSetPressedFlag("WarBoardButtonCheckBoxDefaultButton", false)
	end

	Board = "Top"
end

function WarBoardOptions.ShowBottomOptions()
	ButtonSetPressedFlag("WarBoardOptionsTabsTopBoardTab", false)
	ButtonSetPressedFlag("WarBoardOptionsTabsBottomBoardTab", true)
	--change labels, slider positions, combobox selections and checks for bottom board
	SliderBarSetCurrentPosition("WarBoardBgRedSlider", WarBoardSettings.Bottom.Board.Red / 255)
	SliderBarSetCurrentPosition("WarBoardBgGreenSlider", WarBoardSettings.Bottom.Board.Green / 255)
	SliderBarSetCurrentPosition("WarBoardBgBlueSlider", WarBoardSettings.Bottom.Board.Blue / 255)
	SliderBarSetCurrentPosition("WarBoardBgAlphaSlider", WarBoardSettings.Bottom.Board.Alpha)

	SliderBarSetCurrentPosition("WarBoardModsRedSlider", WarBoardSettings.Bottom.Mods.Red / 255)
	SliderBarSetCurrentPosition("WarBoardModsGreenSlider", WarBoardSettings.Bottom.Mods.Green / 255)
	SliderBarSetCurrentPosition("WarBoardModsBlueSlider", WarBoardSettings.Bottom.Mods.Blue / 255)
	SliderBarSetCurrentPosition("WarBoardModsAlphaSlider", WarBoardSettings.Bottom.Mods.Alpha)
	--MAIN SETTINGS
	LabelSetText("WarBoardBgRedValue", towstring(WarBoardSettings.Bottom.Board.Red))
	LabelSetText("WarBoardBgGreenValue", towstring(WarBoardSettings.Bottom.Board.Green))
	LabelSetText("WarBoardBgBlueValue", towstring(WarBoardSettings.Bottom.Board.Blue))
	LabelSetText("WarBoardBgAlphaValue", towstring(format("%.2f", WarBoardSettings.Bottom.Board.Alpha)))
	--MODS SETTINGS
	LabelSetText("WarBoardModsRedValue", towstring(WarBoardSettings.Bottom.Mods.Red))
	LabelSetText("WarBoardModsGreenValue", towstring(WarBoardSettings.Bottom.Mods.Green))
	LabelSetText("WarBoardModsBlueValue", towstring(WarBoardSettings.Bottom.Mods.Blue))
	LabelSetText("WarBoardModsAlphaValue", towstring(format("%.2f", WarBoardSettings.Bottom.Mods.Alpha)))

	ComboBoxSetSelectedMenuItem("WarBoardComboAlignRow1", WarBoardSettings.Bottom.RowAlign[ 1 ])
	ComboBoxSetSelectedMenuItem("WarBoardComboAlignRow2", WarBoardSettings.Bottom.RowAlign[ 2 ])
	ComboBoxSetSelectedMenuItem("WarBoardComboAlignRow3", WarBoardSettings.Bottom.RowAlign[ 3 ])
	ComboBoxSetSelectedMenuItem("WarBoardComboAlignRow4", WarBoardSettings.Bottom.RowAlign[ 4 ])

	LabelSetText("WarBoardHorizontalPaddingValue", towstring(WarBoardSettings.Bottom.Board.HorizSpace))
	LabelSetText("WarBoardVerticalPaddingValue", towstring(WarBoardSettings.Bottom.Board.VertSpace))

	ButtonSetPressedFlag("WarBoardButtonCheckBoxButton", WarBoardSettings.Bottom.Board.ButtonsOn )
	LabelSetText("WarBoardButtonCheckBoxEnabledLabel", L"Bottom Board Enabled")
	ButtonSetPressedFlag("WarBoardButtonCheckBoxEnabledButton", WarBoardSettings.Bottom.Board.Enabled)
	LabelSetText("WarBoardButtonCheckBoxDefaultLabel", L"Bottom Board Default")
	if WarBoardSettings.DefaultBoard == "Bottom" then
		ButtonSetPressedFlag("WarBoardButtonCheckBoxDefaultButton", true)
	else
		ButtonSetPressedFlag("WarBoardButtonCheckBoxDefaultButton", false)
	end

	Board = "Bottom"
end

function WarBoardOptions.OnLButtonUpTab()
	local windowName = SystemData.ActiveWindow.name
	if windowName == "WarBoardOptionsTabsTopBoardTab" then
		WarBoardOptions.ShowTopOptions()
	else
		WarBoardOptions.ShowBottomOptions()
	end
end

function WarBoardOptions.ToggleBar()
	if ButtonGetPressedFlag("WarBoardButtonCheckBoxEnabledButton") then
		WarBoardOptions.DisableBoard()
	else
		WarBoardOptions.EnableBoard()
	end
end

function WarBoardOptions.DisableBoard()
	if Board == "Top" then
		if DoesWindowExist("BottomBoard") then --The button was pressed so they are disabling the board
			if WarBoardSettings.DefaultBoard == "Top" then --If this board is default, set bottom board to default
				WarBoardSettings.DefaultBoard = "Bottom"
				ButtonSetPressedFlag("WarBoardButtonCheckBoxDefaultButton", false)
			end --If bottom buttons are disabled and libslash not installed, enable bottom buttons
			if not LibSlash and not WarBoardSettings.Bottom.Board.ButtonsOn then
				WarBoardSettings.Bottom.Board.ButtonsOn = true
				WarBoardOptions.CreateBottomButtons()
			end
			if #WarBoardSettings.Top.ModRows[ 1 ] > 0 then--Move any mods in this board to bottom
				for i=1, #WarBoardSettings.Top.ModRows do
					local row = WarBoardSettings.Top.ModRows[ i ]
					for i = #row, 1, -1 do
						WarBoard.ChangeModBoard(row[ i ]) -- Insert all mods from top  board into WarBoard.LoadedMods
					end
				end
			end
			DestroyWindow("WarBoard") --Destroy top board 
			if DoesWindowExist("WarBoardOptionsButtonWindow") then
				WarBoardOptions.DestroyTopButtons() -- and buttons
			end
			WarBoardSettings.Top.Board.Enabled = false --Set top board enabled false and update the check box
			ButtonSetPressedFlag("WarBoardButtonCheckBoxEnabledButton", false)
		else
			MakeOneButtonDialog(L"You must enable the bottom board before disabling the top board", L"OK")
			return
		end
	end

	if Board == "Bottom" then
		if DoesWindowExist("WarBoard") then
			if WarBoardSettings.DefaultBoard == "Bottom" then --If this board is default, set top board to default
				WarBoardSettings.DefaultBoard = "Top"
				ButtonSetPressedFlag("WarBoardButtonCheckBoxDefaultButton", false)
			end --If top buttons are disabled and libslash not installed, enable top buttons
			if not LibSlash and not WarBoardSettings.Top.Board.ButtonsOn then
				WarBoardSettings.Top.Board.ButtonsOn = true
				WarBoardOptions.CreateTopButtons()
			end
			if #WarBoardSettings.Bottom.ModRows[ 1 ] > 0 then --Move any mods in this board to top
				for i=1, #WarBoardSettings.Bottom.ModRows do
					local row = WarBoardSettings.Bottom.ModRows[ i ]
					for i=#row, 1, -1 do
						WarBoard.ChangeModBoard(row[ i ]) -- Insert all mods from bottom board into WarBoard.LoadedMods
					end
				end
			end
			DestroyWindow("BottomBoard") --Destroy bottom board and buttons
			if DoesWindowExist("WarBoardBottomOptionsButtonWindow") then
				WarBoardOptions.DestroyBottomButtons()
			end
			WarBoardSettings.Bottom.Board.Enabled = false --Set bottom board enabled false and update the check box
			ButtonSetPressedFlag("WarBoardButtonCheckBoxEnabledButton", false)
		else
			MakeOneButtonDialog(L"You must enable the top board before disabling the bottom board", L"OK")
			return
		end
	end
end

function WarBoardOptions.EnableBoard()
	if Board == "Top" then
		CreateWindow("WarBoard", true)
		WindowSetTintColor ("WarBoardBackground", WarBoardSettings.Top.Board.Red, WarBoardSettings.Top.Board.Green, WarBoardSettings.Top.Board.Blue)
		WindowSetAlpha ("WarBoardBackground", WarBoardSettings.Top.Board.Alpha)
		WarBoardSettings.Top.Board.Enabled = true
		ButtonSetPressedFlag("WarBoardButtonCheckBoxEnabledButton", true)
		if WarBoardSettings.Top.Board.ButtonsOn then
			WarBoardOptions.CreateTopButtons()
		end
	end
	if Board == "Bottom" then
		CreateWindowFromTemplate("BottomBoard", "WarBoard", "Root")
		WindowClearAnchors("BottomBoard")
		WindowAddAnchor ("BottomBoard", "bottomleft", "Root", "bottomleft", -1, -1)
		WindowAddAnchor ("BottomBoard", "bottomright", "Root", "bottomright", 0, -1)
		WindowSetTintColor ("BottomBoardBackground", WarBoardSettings.Bottom.Board.Red, WarBoardSettings.Bottom.Board.Green, WarBoardSettings.Bottom.Board.Blue)
		WindowSetAlpha ("BottomBoardBackground", WarBoardSettings.Bottom.Board.Alpha)
		WarBoardSettings.Bottom.Board.Enabled = true
		ButtonSetPressedFlag("WarBoardButtonCheckBoxEnabledButton", true)
		if WarBoardSettings.Bottom.Board.ButtonsOn then
			WarBoardOptions.CreateBottomButtons()
		end
	end
end

function WarBoardOptions.SetBarDefault()
	if Board == "Top" then
		WarBoardSettings.DefaultBoard = "Top"
		ButtonSetPressedFlag("WarBoardButtonCheckBoxDefaultButton", true)
	end
	if Board == "Bottom" then
		WarBoardSettings.DefaultBoard = "Bottom"
		ButtonSetPressedFlag("WarBoardButtonCheckBoxDefaultButton", true)
	end
end

function WarBoardOptions.CreateTopButtons()
	CreateWindow("WarBoardOptionsButtonWindow", true)
	CreateWindow("WarBoardLayoutModeButtonWindow", true)
	WindowSetAlpha("WarBoardOptionsButton", 0)
	WindowSetAlpha("WarBoardLayoutModeButton", 0)
end

function WarBoardOptions.CreateBottomButtons()
	CreateWindow("WarBoardBottomOptionsButtonWindow", true)
	CreateWindow("WarBoardBottomLayoutModeButtonWindow", true)
	WindowSetAlpha("BottomBoardOptionsButton", 0)
	WindowSetAlpha("BottomBoardLayoutModeButton", 0)
end

function WarBoardOptions.DestroyTopButtons()
	DestroyWindow("WarBoardOptionsButtonWindow")
	DestroyWindow("WarBoardLayoutModeButtonWindow")
end

function WarBoardOptions.DestroyBottomButtons()
	DestroyWindow("WarBoardBottomOptionsButtonWindow")
	DestroyWindow("WarBoardBottomLayoutModeButtonWindow")
end

function WarBoardOptions.OpenUiModWindow()
	WindowSetShowing("UiModWindow", not WindowGetShowing("UiModWindow"))
end

function WarBoardOptions.PlusVertPad()
	WarBoardSettings[ Board ].Board.VertSpace = WarBoardSettings[ Board ].Board.VertSpace + 1
	LabelSetText("WarBoardVerticalPaddingValue", towstring(WarBoardSettings[ Board ].Board.VertSpace))
	WarBoard.AnchorMods()
end

function WarBoardOptions.MinusVertPad()
	WarBoardSettings[ Board ].Board.VertSpace = WarBoardSettings[ Board ].Board.VertSpace - 1
	LabelSetText("WarBoardVerticalPaddingValue", towstring(WarBoardSettings[ Board ].Board.VertSpace))
	WarBoard.AnchorMods()
end

function WarBoardOptions.PlusHorPad()
	WarBoardSettings[ Board ].Board.HorizSpace = WarBoardSettings[ Board ].Board.HorizSpace + 1
	local rowOk = true
	for k, v in ipairs(WarBoardSettings[ Board ].ModRows) do
		if not WarBoard.CheckLength(WarBoardSettings[ Board ], k) then
			rowOk = false
			break
		end
	end
	if rowOk then
		LabelSetText("WarBoardHorizontalPaddingValue", towstring(WarBoardSettings[ Board ].Board.HorizSpace))
		WarBoard.AnchorMods()
	else
		WarBoardSettings[ Board ].Board.HorizSpace = WarBoardSettings[ Board ].Board.HorizSpace - 1
		MakeOneButtonDialog(L"There is not enough room to add more space between mods", L"OK")
	end
end

function WarBoardOptions.MinusHorPad()
	WarBoardSettings[ Board ].Board.HorizSpace = WarBoardSettings[ Board ].Board.HorizSpace - 1
	LabelSetText("WarBoardHorizontalPaddingValue", towstring(WarBoardSettings[ Board ].Board.HorizSpace))
	WarBoard.AnchorMods()
end

function WarBoardOptions.DisableCornerButtons()
	if not LibSlash then --At least one button must be enabled since LibSlash is not installed
		if Board == "Top" and not DoesWindowExist("WarBoardBottomOptionsButtonWindow") then
			MakeOneButtonDialog(L"You must have LibSlash installed in order to disable the corner buttons", L"OK")
			return
		end
		if Board == "Bottom" and not DoesWindowExist("WarBoardOptionsButtonWindow") then
			MakeOneButtonDialog(L"You must have LibSlash installed in order to disable the corner buttons", L"OK")
			return
		end
	end

	if WarBoardSettings[ Board ].Board.ButtonsOn then
		if Board == "Top" then
			if DoesWindowExist("WarBoardOptionsButtonWindow") then
				DestroyWindow("WarBoardOptionsButtonWindow")
				DestroyWindow("WarBoardLayoutModeButtonWindow")
			end
		end
		if Board == "Bottom" then
			if DoesWindowExist("WarBoardBottomOptionsButtonWindow") then
				DestroyWindow("WarBoardBottomOptionsButtonWindow")
				DestroyWindow("WarBoardBottomLayoutModeButtonWindow")
			end
		end
		WarBoardSettings[ Board ].Board.ButtonsOn = false
		ButtonSetPressedFlag("WarBoardButtonCheckBoxButton", false)
	else
		if Board == "Top" and DoesWindowExist("WarBoard") then
			CreateWindow("WarBoardOptionsButtonWindow", true)
			CreateWindow("WarBoardLayoutModeButtonWindow", true)
			WindowSetAlpha("WarBoardOptionsButton", 0)
			WindowSetAlpha("WarBoardLayoutModeButton", 0)
		end
		if Board == "Bottom" and DoesWindowExist("BottomBoard") then
			CreateWindow("WarBoardBottomOptionsButtonWindow", true)
			CreateWindow("WarBoardBottomLayoutModeButtonWindow", true)
			WindowSetAlpha("BottomBoardOptionsButton", 0)
			WindowSetAlpha("BottomBoardLayoutModeButton", 0)
		end

		WarBoardSettings[ Board ].Board.ButtonsOn = true
		ButtonSetPressedFlag("WarBoardButtonCheckBoxButton", true)
	end
end

function WarBoardOptions.SetRowAlign()
	WarBoardSettings[ Board ].RowAlign[ 1 ] = ComboBoxGetSelectedMenuItem("WarBoardComboAlignRow1")
	WarBoardSettings[ Board ].RowAlign[ 2 ] = ComboBoxGetSelectedMenuItem("WarBoardComboAlignRow2")
	WarBoardSettings[ Board ].RowAlign[ 3 ] = ComboBoxGetSelectedMenuItem("WarBoardComboAlignRow3")
	WarBoardSettings[ Board ].RowAlign[ 4 ] = ComboBoxGetSelectedMenuItem("WarBoardComboAlignRow4")
	WarBoard.AnchorMods()
end

function WarBoardOptions.OnSlide()
	local windowName = SystemData.ActiveWindow.name
	local Bg = sfind(windowName, "Bg")
	local Mods = sfind(windowName, "Mod")
	local AdjustWindow = nil
	local remainder = 0

	if Board == "Top" then
		AdjustWindow = "WarBoardBackground"
	end
	if Board == "Bottom" then
		AdjustWindow = "BottomBoardBackground"
	end

	if Bg then
		WarBoardSettings[ Board ].Board.Red, remainder = math.modf(SliderBarGetCurrentPosition("WarBoardBgRedSlider") * 255)
		WarBoardSettings[ Board ].Board.Green, remainder = math.modf(SliderBarGetCurrentPosition("WarBoardBgGreenSlider") * 255)
		WarBoardSettings[ Board ].Board.Blue, remainder = math.modf(SliderBarGetCurrentPosition("WarBoardBgBlueSlider") * 255)
		WarBoardSettings[ Board ].Board.Alpha = SliderBarGetCurrentPosition("WarBoardBgAlphaSlider")
		
		LabelSetText("WarBoardBgRedValue", towstring(WarBoardSettings[ Board ].Board.Red))
		LabelSetText("WarBoardBgGreenValue", towstring(WarBoardSettings[ Board ].Board.Green))
		LabelSetText("WarBoardBgBlueValue", towstring(WarBoardSettings[ Board ].Board.Blue))
		LabelSetText("WarBoardBgAlphaValue", towstring(format("%.2f", WarBoardSettings[ Board ].Board.Alpha)))
		if DoesWindowExist(AdjustWindow) then
			WindowSetTintColor(AdjustWindow, WarBoardSettings[ Board ].Board.Red, WarBoardSettings[ Board ].Board.Green, WarBoardSettings[ Board ].Board.Blue)
			WindowSetAlpha(AdjustWindow, WarBoardSettings[ Board ].Board.Alpha)
		end
	end

	if Mods then
		WarBoardSettings[ Board ].Mods.Red, remainder = math.modf(SliderBarGetCurrentPosition("WarBoardModsRedSlider") * 255)
		WarBoardSettings[ Board ].Mods.Green, remainder = math.modf(SliderBarGetCurrentPosition("WarBoardModsGreenSlider") * 255)
		WarBoardSettings[ Board ].Mods.Blue, remainder = math.modf(SliderBarGetCurrentPosition("WarBoardModsBlueSlider") * 255)
		WarBoardSettings[ Board ].Mods.Alpha = SliderBarGetCurrentPosition("WarBoardModsAlphaSlider")
		LabelSetText("WarBoardModsRedValue", towstring(WarBoardSettings[ Board ].Mods.Red))
		LabelSetText("WarBoardModsGreenValue", towstring(WarBoardSettings[ Board ].Mods.Green))
		LabelSetText("WarBoardModsBlueValue", towstring(WarBoardSettings[ Board ].Mods.Blue))
		LabelSetText("WarBoardModsAlphaValue", towstring(format("%.2f", WarBoardSettings[ Board ].Mods.Alpha)))
		if DoesWindowExist(AdjustWindow) then
			for k, v in ipairs(WarBoardSettings[ Board ].ModRows) do
				local currentRowNum = k
				for k, v in ipairs(WarBoardSettings[ Board ].ModRows[ currentRowNum ]) do
					local background = v.."Background"			
					WindowSetTintColor(background, WarBoardSettings[ Board ].Mods.Red, WarBoardSettings[ Board ].Mods.Green, WarBoardSettings[ Board ].Mods.Blue)
					WindowSetAlpha(background, WarBoardSettings[ Board ].Mods.Alpha)
				end
			end
		end
	end
end

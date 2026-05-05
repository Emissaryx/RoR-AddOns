if not WarBoard_FPSOptions then WarBoard_FPSOptions = {} end
local WarBoard_FPSOptions = WarBoard_FPSOptions
local WarBoard_FPSOptions_Table = {}
local Ready = false
local windowName = "WarBoard_FPSOptions"
CmbSel = {}
local LabelSetText, WindowGetParent, ButtonSetPressedFlag, TextEditBoxSetText, WindowSetShowing,  WindowSetDimensions,
	  TextEditBoxGetText, tonumber, towstring, SliderBarSetCurrentPosition, ComboBoxAddMenuItem, SliderBarGetCurrentPosition,
	  ComboBoxClearMenuItems, floor = 
	  LabelSetText, WindowGetParent, ButtonSetPressedFlag, TextEditBoxSetText, WindowSetShowing,  WindowSetDimensions,
	  TextEditBoxGetText, tonumber, towstring, SliderBarSetCurrentPosition, ComboBoxAddMenuItem, SliderBarGetCurrentPosition,
	  ComboBoxClearMenuItems, math.floor

local function UpdateLabels()
	if Ready then
		TextEditBoxSetText(windowName.."_edtRefreshRate", towstring(WarBoard_FPSSettings.RefreshRate))
		TextEditBoxSetText(windowName.."_edtFPSCounterLow", towstring(WarBoard_FPSSettings.FPSCounter.Low))
		TextEditBoxSetText(windowName.."_edtFPSCounterMed", towstring(WarBoard_FPSSettings.FPSCounter.Med))
		TextEditBoxSetText(windowName.."_edtAvgCounterLow", towstring(WarBoard_FPSSettings.AvgCounter.Low))
		TextEditBoxSetText(windowName.."_edtAvgCounterMed", towstring(WarBoard_FPSSettings.AvgCounter.Med))
		LabelSetText(windowName.."_lblRColor", towstring("R: "..CmbSel.R))
		LabelSetText(windowName.."_lblGColor", towstring("G: "..CmbSel.G))
		LabelSetText(windowName.."_lblBColor", towstring("B: "..CmbSel.B))
	end
end

function WarBoard_FPSOptions.Initialize()
	WarBoard_FPSOptions_Table = {WarBoard_FPSSettings.FPSLow, WarBoard_FPSSettings.AvgLow,
								 WarBoard_FPSSettings.FPSMed, WarBoard_FPSSettings.AvgMed,
								 WarBoard_FPSSettings.FPSHigh, WarBoard_FPSSettings.AvgHigh}
	CreateWindow("WarBoard_FPSOptions", true)
	LabelSetText(windowName.."TitleBarText", L"WarBoard FPS Options")
	LabelSetText(windowName.."_lblShowAvg", L"Show Average:")
	LabelSetText(windowName.."_lblRefreshRate", L"Refresh Rate:")
	LabelSetText(windowName.."_lblColor", L"Coloring:")
	LabelSetText(windowName.."_lblMiscSettings", L"Miscellaneous Settings")
	LabelSetText(windowName.."_lblCounter", L"Counters:")
	LabelSetText(windowName.."_lblLName", L"Meter Type:")
	LabelSetText(windowName.."_lblFPSCounterLow", L"FPS Low:")
	LabelSetText(windowName.."_lblFPSCounterMed", L"FPS Med:")
	LabelSetText(windowName.."_lblAvgCounterLow", L"Avg Low:")
	LabelSetText(windowName.."_lblAvgCounterMed", L"Avg Med:")

	ComboBoxClearMenuItems(windowName.."_cmbLName")
	ComboBoxAddMenuItem(windowName.."_cmbLName", L"FPSLow")
	ComboBoxAddMenuItem(windowName.."_cmbLName", L"AvgLow")
	ComboBoxAddMenuItem(windowName.."_cmbLName", L"FPSMed")
	ComboBoxAddMenuItem(windowName.."_cmbLName", L"AvgMed")
	ComboBoxAddMenuItem(windowName.."_cmbLName", L"FPSHigh")
	ComboBoxAddMenuItem(windowName.."_cmbLName", L"AvgHigh")
	ComboBoxSetSelectedMenuItem(windowName.."_cmbLName", 1)
	WarBoard_FPSOptions.OnCmbChange(1)

	ButtonSetPressedFlag(windowName.."_chkShowAvg", WarBoard_FPSSettings.ShowAvg)
	Ready = true

	WindowSetShowing(windowName, false)
end

function WarBoard_FPSOptions.OnToggleAvg()
	WarBoard_FPSSettings.ShowAvg = not WarBoard_FPSSettings.ShowAvg
	WindowSetShowing("WarBoard_FPSLabelAvg", WarBoard_FPSSettings.ShowAvg)

	if not WarBoard_FPSSettings.ShowAvg then WindowSetDimensions("WarBoard_FPS", 78, 30)
	else WindowSetDimensions("WarBoard_FPS", 150, 30) 
	end
	ButtonSetPressedFlag(windowName.."_chkShowAvg", WarBoard_FPSSettings.ShowAvg)
end

function WarBoard_FPSOptions.OnEnterKeyPressed()
	if windowName == WindowGetParent(SystemData.ActiveWindow.name) then
		WarBoard_FPSSettings.RefreshRate = tonumber(TextEditBoxGetText(windowName.."_edtRefreshRate"))
		WarBoard_FPSSettings.FPSCounter.Low = tonumber(TextEditBoxGetText(windowName.."_edtFPSCounterLow"))
		WarBoard_FPSSettings.FPSCounter.Med = tonumber(TextEditBoxGetText(windowName.."_edtFPSCounterMed"))
		WarBoard_FPSSettings.AvgCounter.Low = tonumber(TextEditBoxGetText(windowName.."_edtAvgCounterLow"))
		WarBoard_FPSSettings.AvgCounter.Med = tonumber(TextEditBoxGetText(windowName.."_edtAvgCounterMed"))
	end
end

function WarBoard_FPSOptions.OnSlidingColor()
	CmbSel.R = floor(SliderBarGetCurrentPosition(windowName.."_SliderR")*255)
	CmbSel.G = floor(SliderBarGetCurrentPosition(windowName.."_SliderG")*255)
	CmbSel.B = floor(SliderBarGetCurrentPosition(windowName.."_SliderB")*255)
	UpdateLabels()
end

function WarBoard_FPSOptions.OnCmbChange(choiceIndex)
	CmbSel = WarBoard_FPSOptions_Table[choiceIndex]
	SliderBarSetCurrentPosition(windowName.."_SliderR", CmbSel.R / 255)
	SliderBarSetCurrentPosition(windowName.."_SliderG", CmbSel.G / 255)
	SliderBarSetCurrentPosition(windowName.."_SliderB", CmbSel.B / 255)
	UpdateLabels()
end

function WarBoard_FPSOptions.OnShown()
	UpdateLabels()
end

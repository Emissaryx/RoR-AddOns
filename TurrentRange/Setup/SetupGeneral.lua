TurretRange = TurretRange or {};
TurretRange.Setup = TurretRange.Setup or {};
TurretRange.Setup.General = 
{
	WindowName = "TurretRangeSetupGeneralWindow",
};

local UPDATE_DELAY = { 0.01, 0.1, 0.5, 1, 2 };

local windowName = TurretRange.Setup.General.WindowName;
local localization = TurretRange.Localization.GetMapping();

local function GetDelayValue(value, valueList)

	local index = 1;
	
	for k, v in ipairs(valueList) do
		if (value == v) then
			return k;
		elseif (value > v) then
			index = k;
		end
	end

	return index;

end

function TurretRange.Setup.General.Initialize()

	LabelSetText(windowName .. "TitleLabel", localization["Setup.General.Title"]);
	LabelSetText(windowName .. "EnableCheckboxLabel", localization["Setup.General.Enable"]);
	LabelSetText(windowName .. "UpdateDelayLabel", localization["Setup.General.UpdateDelay"]);
	
	TurretRange.Setup.General.LoadSettings();
	
end

function TurretRange.Setup.General.LoadSettings()

	local settings = TurretRange.Settings.General;
	
	ButtonSetPressedFlag(windowName .. "Enable" .. "Button", settings.Enabled);
	
	SliderBarSetCurrentPosition(windowName .. "UpdateDelaySlider", math.max(math.min(1, (GetDelayValue(settings.UpdateDelay, UPDATE_DELAY) - 1) / (#UPDATE_DELAY - 1)), 0));
	TurretRange.Setup.General.OnSlideUpdateDelay();
	
end

function TurretRange.Setup.General.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TurretRange.Setup.General.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TurretRange.Setup.General.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TurretRange.Setup.General.OnHidden()

	TurretRange.Setup.SetActiveWindow();

end

function TurretRange.Setup.General.OnCloseLUp()

	TurretRange.Setup.General.Hide();

end

function TurretRange.Setup.General.OnEnableLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "Enable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "Enable" .. "Button", isChecked);
	
	TurretRange.Settings.General.Enabled = isChecked;
	TurretRange.OnSettingsChanged();
	
end

function TurretRange.Setup.General.OnSlideUpdateDelay()

	local value = UPDATE_DELAY[1 + math.floor(SliderBarGetCurrentPosition(windowName .. "UpdateDelaySlider") * (#UPDATE_DELAY - 1))];
	
	local stringValue = "%.2fs";
	LabelSetText(windowName .. "UpdateDelayValue", towstring(stringValue:format(value)));
	
	TurretRange.Settings.General.UpdateDelay = value;
	
end
TurretRange = TurretRange or {};
TurretRange.Setup = TurretRange.Setup or {};
TurretRange.Setup.Distance = 
{
	WindowName = "TurretRangeSetupDistanceWindow",
};

local windowName = TurretRange.Setup.Distance.WindowName;
local localization = TurretRange.Localization.GetMapping();

local existingDistance = nil;

local function ShowTooltip(text)

	local windowName = SystemData.ActiveWindow.name;
	Tooltips.CreateTextOnlyTooltip(windowName, nil);
	Tooltips.SetTooltipText(1, 1, text);
	Tooltips.Finalize();
	
	local anchor = { Point = "topleft", RelativeTo = windowName, RelativePoint = "bottomleft", XOffset = 10, YOffset = -10 };
	Tooltips.AnchorTooltip(anchor);
	Tooltips.SetTooltipAlpha(1);
			
end

local function ShowButtons(showApply, showCreate)

	if (WindowGetShowing(windowName .. "ApplyButton") == showApply and WindowGetShowing(windowName .. "CreateButton") == showCreate) then return end

	WindowSetShowing(windowName .. "ApplyButton", showApply);
	WindowSetShowing(windowName .. "CreateButton", showCreate);
	
	if (showCreate) then
		WindowClearAnchors(windowName .. "CreateButton");
		if (showApply) then
			WindowAddAnchor(windowName .. "CreateButton", "topleft", windowName .. "ApplyButton", "topright", 0, 0);
		else
			WindowAddAnchor(windowName .. "CreateButton", "bottomright", windowName, "bottomright", -20, -20);
		end
	end

end

local function LoadDistance(index)

	local distance = nil;
	existingDistance = { Index = index };
	
	if (index) then
		distance = TurretRange.Settings.Distance[index];
	end
	
	local color = { R = 255, G = 255, B = 255 };
	local range = 0;
	local hide = false;
	
	if (distance) then
		--existing
		range = distance.Distance or range;
		color = distance.Color or color;
		hide = distance.Hide or false;
	else
		--new
	end
	
	TextEditBoxSetText(windowName .. "DistanceEditBox", towstring(range));
	ButtonSetPressedFlag(windowName .. "Hide" .. "Button", (hide == true));
	
	SliderBarSetCurrentPosition(windowName .. "ColorTintRedSlider", color.R / 255);
	SliderBarSetCurrentPosition(windowName .. "ColorTintGreenSlider", color.G / 255);
	SliderBarSetCurrentPosition(windowName .. "ColorTintBlueSlider", color.B / 255);
	
	TurretRange.Setup.Distance.OnSlideTint();
	
	if (distance) then
		ShowButtons(true, true);
	else
		ShowButtons(false, true);
	end
	
end

function TurretRange.Setup.Distance.Initialize()

	LabelSetText(windowName .. "TitleLabel", localization["Setup.Distance.Title"]);
	LabelSetText(windowName .. "DistanceLabel", localization["Setup.Distance.Distance"]);
	LabelSetText(windowName .. "ColorLabel", localization["Setup.Distance.Color"]);
	LabelSetText(windowName .. "ColorTintRed", localization["Setup.Distance.Color.R"]);
	LabelSetText(windowName .. "ColorTintGreen", localization["Setup.Distance.Color.G"]);
	LabelSetText(windowName .. "ColorTintBlue", localization["Setup.Distance.Color.B"]);
	LabelSetText(windowName .. "HideCheckboxLabel", localization["Setup.Distance.Hide"]);
	
	ButtonSetText(windowName .. "CreateButton", localization["Setup.Distance.Create"]);
	ButtonSetText(windowName .. "ApplyButton", localization["Setup.Distance.Apply"]);
	
	ShowButtons(false, true);
	
end

function TurretRange.Setup.Distance.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TurretRange.Setup.Distance.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TurretRange.Setup.Distance.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TurretRange.Setup.Distance.OnHidden()

	TurretRange.Setup.SetActiveWindow();

end

function TurretRange.Setup.Distance.OnCloseLUp()

	TurretRange.Setup.Distance.Hide();
	TurretRange.Setup.SetActiveWindow(TurretRange.Setup.Distances);

end

function TurretRange.Setup.Distance.ShowNew(type)

	LoadDistance(nil);
	TurretRange.Setup.Distance.Show();

end

function TurretRange.Setup.Distance.ShowEdit(index)

	LoadDistance(index);
	TurretRange.Setup.Distance.Show();

end

function TurretRange.Setup.Distance.GetActiveDistance()
	return existingDistance or {};
end

function TurretRange.Setup.Distance.OnSlideTint()

	local r = math.floor(SliderBarGetCurrentPosition(windowName .. "ColorTintRedSlider") * 255);
	local g = math.floor(SliderBarGetCurrentPosition(windowName .. "ColorTintGreenSlider") * 255);
	local b = math.floor(SliderBarGetCurrentPosition(windowName .. "ColorTintBlueSlider") * 255);
	
	TextEditBoxSetText(windowName .. "ColorTintRedEditBox", towstring(r));
	TextEditBoxSetText(windowName .. "ColorTintGreenEditBox", towstring(g));
	TextEditBoxSetText(windowName .. "ColorTintBlueEditBox", towstring(b));
	
end

function TurretRange.Setup.Distance.OnTintChanged()

	local r = tonumber(TextEditBoxGetText(windowName .. "ColorTintRedEditBox"));
	local g = tonumber(TextEditBoxGetText(windowName .. "ColorTintGreenEditBox"));
	local b = tonumber(TextEditBoxGetText(windowName .. "ColorTintBlueEditBox"));
	
	SliderBarSetCurrentPosition(windowName .. "ColorTintRedSlider", r / 255);
	SliderBarSetCurrentPosition(windowName .. "ColorTintGreenSlider", g / 255);
	SliderBarSetCurrentPosition(windowName .. "ColorTintBlueSlider", b / 255);
	
	WindowSetTintColor(windowName .. "ColorExample", r, g, b);
	
end

local function CompareDistances(distanceA, distanceB)

	if (distanceB == nil) then
		return false;
	end
	
	return (distanceA.Distance > distanceB.Distance);

end

local function SaveDistance()

	local r = tonumber(TextEditBoxGetText(windowName .. "ColorTintRedEditBox"));
	local g = tonumber(TextEditBoxGetText(windowName .. "ColorTintGreenEditBox"));
	local b = tonumber(TextEditBoxGetText(windowName .. "ColorTintBlueEditBox"));
	local color = { R = r, G = g, B = b };
	
	local range = tonumber(TextEditBoxGetText(windowName .. "DistanceEditBox"));
	local hide = ButtonGetPressedFlag(windowName .. "Hide" .. "Button");
	
	local distance = 
	{
		Distance = range,
		Color = color,
		Hide = hide,
	};
	
	return distance;
	
end

function TurretRange.Setup.Distance.OnCreateLClick()
	
	local distance = SaveDistance();
	if (not distance) then return end
	
	table.insert(TurretRange.Settings.Distance, distance);
	table.sort(TurretRange.Settings.Distance, CompareDistances);
	
	TurretRange.Setup.Distances.Update();
	TurretRange.Setup.Distance.Hide();
	TurretRange.Setup.SetActiveWindow(TurretRange.Setup.Distances);

end

function TurretRange.Setup.Distance.OnApplyLClick()
	
	local distance = SaveDistance();
	if (not distance) then return end
	
	TurretRange.Settings.Distance[existingDistance.Index] = distance;
	table.sort(TurretRange.Settings.Distance, CompareDistances);
	
	TurretRange.Setup.Distances.Update();
	TurretRange.Setup.Distance.Hide();
	TurretRange.Setup.SetActiveWindow(TurretRange.Setup.Distances);

end
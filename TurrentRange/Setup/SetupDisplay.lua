TurretRange = TurretRange or {};
TurretRange.Setup = TurretRange.Setup or {};
TurretRange.Setup.Display = 
{
	WindowName = "TurretRangeSetupDisplayWindow",
};

local MIN_DISTANCE_SCALE_SLIDER = 0.5;
local MAX_DISTANCE_SCALE_SLIDER = 2;
local MAX_WIDTH = 1000;

local windowName = TurretRange.Setup.Display.WindowName;
local localization = TurretRange.Localization.GetMapping();

local fonts = 
{
	{ Font = "font_journal_body", Name = "Cronos Pro - Small" },
	{ Font = "font_journal_text", Name = "Cronos Pro - Medium" },
	{ Font = "font_default_text_small", Name = "Age of Reckoning - Small" },
	{ Font = "font_default_text_large", Name = "Age of Reckoning - Large" },
	{ Font = "font_clear_tiny", Name = "Myriad Pro - Very Small" },
	{ Font = "font_clear_small", Name = "Myriad Pro - Small" },
	{ Font = "font_clear_medium", Name = "Myriad Pro - Medium" },
	{ Font = "font_clear_large", Name = "Myriad Pro - Large" },
	{ Font = "font_clear_small_bold", Name = "Myriad Pro SemiExt - Small" },
	{ Font = "font_clear_medium_bold", Name = "Myriad Pro SemiExt - Medium" },
	{ Font = "font_clear_large_bold", Name = "Myriad Pro SemiExt - Large" },
};

local modeInfo =
{
	localization["Setup.Display.Circle.Mode.Hide.Info"], localization["Setup.Display.Circle.Mode.Sticky.Info"], localization["Setup.Display.Circle.Mode.Show.Info"]
}

local elements =
{
	"Distance", "Graphic", "Circle",
}

local lockSettings = false;
local colorLock = false;

local activeColorIcon = nil;
local activeColorSettings = nil;
local activeElement = nil;

local function SetupTypeComboBox(combo)
	ComboBoxClearMenuItems(windowName .. combo);
	ComboBoxAddMenuItem(windowName .. combo, localization["Setup.Display.Type.Hidden"]);
	ComboBoxAddMenuItem(windowName .. combo, localization["Setup.Display.Type.ColorByDistance"]);
	ComboBoxAddMenuItem(windowName .. combo, localization["Setup.Display.Type.ColorCustom"]);
end

local function UpdateExample(part)

	local settings = TurretRange.Settings.Display;
	
	if (not part or part == "Distance") then
		local name = windowName .. "ExampleDistance";
		local color = {};
		if (settings.Distance.Type == TurretRange.ColorType.Custom) then
			color = settings.Distance.Color or {};
		end
		LabelSetTextColor(name, color.R or 255, color.G or 255, color.B or 255);
		WindowSetScale(name, InterfaceCore.GetScale() * (settings.Distance.Scale or 1));
		LabelSetFont(name, settings.Distance.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
		WindowSetDimensions(name, 150, 80);
		local _, height = LabelGetTextDimensions(name);
		WindowSetDimensions(name, 150, height);
		WindowClearAnchors(name);
		if (settings.Distance.Layout == TurretRange.Layout.Distance.Bottom) then
			WindowAddAnchor(name, "bottom", windowName .. "Example", "top", 0 + (settings.Distance.Offset.X or 0), -5 + (settings.Distance.Offset.Y or 0));
		elseif (settings.Distance.Layout == TurretRange.Layout.Distance.Center) then
			WindowAddAnchor(name, "center", windowName .. "Example", "center", (settings.Distance.Offset.X or 0), (settings.Distance.Offset.Y or 0));
		else -- TurretRange.Layout.Distance.InnerBottom
			WindowAddAnchor(name, "bottom", windowName .. "Example", "bottom", (settings.Distance.Offset.X or 0), -25 + (settings.Distance.Offset.Y or 0));
		end
	end
	
	if (not part or part == "Graphic") then
		local name = windowName .. "ExampleGraphic";
		local color = {};
		if (settings.Graphic.Type == TurretRange.ColorType.Custom) then
			color = settings.Graphic.Color or {};
		end
		WindowSetTintColor(name, color.R or 255, color.G or 255, color.B or 255);
	end
	
	if (not part or part == "Circle") then
		local name = windowName .. "ExampleCircle";
		local color = {};
		if (settings.Circle.Type == TurretRange.ColorType.Custom) then
			color = settings.Circle.Color or {};
		end
		WindowSetTintColor(name, color.R or 255, color.G or 255, color.B or 255);
	end

end

local function ShowElement(name)

	if (activeElement and activeElement ~= name) then
		WindowSetShowing(windowName .. activeElement, false);
	end
	
	local elementAlpha = {};
	for index, name in ipairs(elements) do
		elementAlpha[name] = 0.3;
	end
	elementAlpha[name] = 1;
	
	WindowSetFontAlpha(windowName .. "ExampleDistance", elementAlpha["Distance"] or 0);
	WindowSetAlpha(windowName .. "ExampleGraphic", elementAlpha["Graphic"] or 0);
	WindowSetAlpha(windowName .. "ExampleCircle", elementAlpha["Circle"] or 0);
	
	activeElement = name;
	WindowSetShowing(windowName .. activeElement, true);

end

function TurretRange.Setup.Display.Initialize()

	WindowSetShowing(windowName .. "SelectColor", false);
	WindowSetTintColor(windowName .. "SelectColorBackground", 0, 0, 0);
	WindowSetAlpha(windowName .. "SelectColorBackground", 0.8);
	
	WindowSetShowing(windowName .. "Distance", false);
	WindowSetShowing(windowName .. "Graphic", false);
	WindowSetShowing(windowName .. "Circle", false);

	local greatestWidth = 0;

	for index, font in ipairs(fonts) do
        CreateWindowFromTemplate("TurretRangeContextMenuItemFontMenuItem" .. index, "TurretRangeContextMenuItemFontSelection", "Root");
        LabelSetFont("TurretRangeContextMenuItemFontMenuItem" .. index .. "Label", font.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
        LabelSetText("TurretRangeContextMenuItemFontMenuItem" .. index .. "Label", towstring(font.Name));
		
        WindowSetDimensions("TurretRangeContextMenuItemFontMenuItem" .. index .. "Label", MAX_WIDTH, 90);
        local x, y = LabelGetTextDimensions("TurretRangeContextMenuItemFontMenuItem" .. index .. "Label");
		if (x > greatestWidth) then
			greatestWidth = x;
		end
        WindowRegisterCoreEventHandler("TurretRangeContextMenuItemFontMenuItem" .. index, "OnLButtonUp", "TurretRange.Setup.Distance.SetFont");
        WindowSetShowing("TurretRangeContextMenuItemFontMenuItem" .. index, false);
        WindowSetId("TurretRangeContextMenuItemFontMenuItem" .. index, index);
	end
	
	greatestWidth = math.min(MAX_WIDTH, greatestWidth);
	
	for index, font in ipairs(fonts) do
        local _, y = LabelGetTextDimensions("TurretRangeContextMenuItemFontMenuItem" .. index .. "Label");
        WindowSetDimensions("TurretRangeContextMenuItemFontMenuItem" .. index, greatestWidth, y);
        WindowSetDimensions("TurretRangeContextMenuItemFontMenuItem" .. index .. "Label", greatestWidth, y);
	end

	LabelSetText(windowName .. "TitleLabel", localization["Setup.Display.Title"]);
	LabelSetText(windowName .. "ExampleDistance", L"0");
	LabelSetText(windowName .. "ElementLabel", localization["Setup.Display.Element"]);
	LabelSetText(windowName .. "DistanceLabel", localization["Setup.Display.Distance"]);
	LabelSetText(windowName .. "DistanceTypeLabel", localization["Setup.Display.Type"]);
	LabelSetText(windowName .. "DistanceLayoutLabel", localization["Setup.Display.Layout"]);
	LabelSetText(windowName .. "DistanceFontLabel", localization["Setup.Display.Font"]);
	LabelSetText(windowName .. "DistanceScaleLabel", localization["Setup.Display.Scale"]);
	LabelSetText(windowName .. "DistanceOffsetLabel", localization["Setup.Display.Offset"]);
	LabelSetText(windowName .. "DistanceOffsetXLabel", localization["Setup.Display.Offset.X"]);
	LabelSetText(windowName .. "DistanceOffsetYLabel", localization["Setup.Display.Offset.Y"]);
	
	LabelSetText(windowName .. "GraphicLabel", localization["Setup.Display.Graphic"]);
	LabelSetText(windowName .. "GraphicTypeLabel", localization["Setup.Display.Type"]);
	LabelSetText(windowName .. "GraphicLimitLabel", localization["Setup.Display.Graphic.Limit"]);
	
	LabelSetText(windowName .. "CircleLabel", localization["Setup.Display.Circle"]);
	LabelSetText(windowName .. "CircleTypeLabel", localization["Setup.Display.Type"]);
	LabelSetText(windowName .. "CircleModeLabel", localization["Setup.Display.Mode"]);
	LabelSetText(windowName .. "CircleInvertCheckboxLabel", localization["Setup.Display.Circle.Invert"]);

	LabelSetText(windowName .. "SelectColorTintRed", localization["Setup.Display.Color.R"]);
	LabelSetText(windowName .. "SelectColorTintGreen", localization["Setup.Display.Color.G"]);
	LabelSetText(windowName .. "SelectColorTintBlue", localization["Setup.Display.Color.B"]);

	SetupTypeComboBox("DistanceTypeComboBox");
	SetupTypeComboBox("GraphicTypeComboBox");
	SetupTypeComboBox("CircleTypeComboBox");
	
	ComboBoxClearMenuItems(windowName .. "DistanceLayoutComboBox");
	ComboBoxAddMenuItem(windowName .. "DistanceLayoutComboBox", localization["Setup.Display.Distance.Layout.InnerBottom"]);
	ComboBoxAddMenuItem(windowName .. "DistanceLayoutComboBox", localization["Setup.Display.Distance.Layout.Bottom"]);
	ComboBoxAddMenuItem(windowName .. "DistanceLayoutComboBox", localization["Setup.Display.Distance.Layout.Center"]);
	
	ComboBoxClearMenuItems(windowName .. "CircleModeComboBox");
	ComboBoxAddMenuItem(windowName .. "CircleModeComboBox", localization["Setup.Display.Circle.Mode.Hide"]);
	ComboBoxAddMenuItem(windowName .. "CircleModeComboBox", localization["Setup.Display.Circle.Mode.Sticky"]);
	ComboBoxAddMenuItem(windowName .. "CircleModeComboBox", localization["Setup.Display.Circle.Mode.Show"]);
	
	ComboBoxClearMenuItems(windowName .. "ElementComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Display.Distance"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Display.Graphic"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Display.Circle"]);
	
	ComboBoxSetSelectedMenuItem(windowName .. "ElementComboBox", 1);
	ShowElement(elements[1]);
	
	TurretRange.Setup.Display.LoadSettings();
	
end

local function GetFontName(f)

	for index, font in pairs(fonts) do
		if (font.Font == f) then
			return font.Name;
		end
	end
	
	return f;

end

function TurretRange.Setup.Display.LoadSettings()
	
	lockSettings = true;
	
	local settings = TurretRange.Settings.Display;
	
	local font = settings.Distance.Font or fonts[1].Font;
	LabelSetText(windowName .. "DistanceFontExampleLabel", towstring(GetFontName(font)));
	LabelSetFont(windowName .. "DistanceFontExampleLabel", font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	
	local offset = settings.Distance.Offset or {};
	TextEditBoxSetText(windowName .. "DistanceOffsetXEditBox", towstring(offset.X or 0));
	TextEditBoxSetText(windowName .. "DistanceOffsetYEditBox", towstring(offset.Y or 0));
	
	TextEditBoxSetText(windowName .. "GraphicLimitEditBox", towstring(settings.Graphic.Limit));
	ButtonSetPressedFlag(windowName .. "CircleInvert" .. "Button", (settings.Circle.Inverted == true));
	
	ComboBoxSetSelectedMenuItem(windowName .. "DistanceTypeComboBox", settings.Distance.Type);
	ComboBoxSetSelectedMenuItem(windowName .. "DistanceLayoutComboBox", settings.Distance.Layout);
	ComboBoxSetSelectedMenuItem(windowName .. "GraphicTypeComboBox", settings.Graphic.Type);
	ComboBoxSetSelectedMenuItem(windowName .. "CircleTypeComboBox", settings.Circle.Type);
	ComboBoxSetSelectedMenuItem(windowName .. "CircleModeComboBox", settings.Circle.Mode);
	
	SliderBarSetCurrentPosition(windowName .. "DistanceScaleSlider", math.max(math.min(1, (settings.Distance.Scale - MIN_DISTANCE_SCALE_SLIDER) / (MAX_DISTANCE_SCALE_SLIDER - MIN_DISTANCE_SCALE_SLIDER)), 0));
	
	TurretRange.Setup.Display.OnDistanceTypeChanged();
	TurretRange.Setup.Display.OnGraphicTypeChanged();
	TurretRange.Setup.Display.OnCircleTypeChanged();
	TurretRange.Setup.Display.OnSlideDistanceScale();
	TurretRange.Setup.Display.OnCircleModeChanged();
	
	UpdateExample();
	
	lockSettings = false;
	
end

function TurretRange.Setup.Display.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TurretRange.Setup.Display.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TurretRange.Setup.Display.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TurretRange.Setup.Display.OnHidden()

	WindowSetShowing(windowName .. "SelectColor", false);
	TurretRange.Setup.SetActiveWindow();

end

function TurretRange.Setup.Display.OnCloseLUp()

	TurretRange.Setup.Display.Hide();

end

function TurretRange.Setup.Display.OnElementChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementComboBox");
	if (elements[value]) then
		ShowElement(elements[value]);
	end
	
	WindowSetShowing(windowName .. "SelectColor", false);
	
end

local function SetType(settings, name)

	local value = ComboBoxGetSelectedMenuItem(windowName .. name .. "TypeComboBox");
	
	if (value == TurretRange.ColorType.Custom) then
		local color = settings.Color or {};
		WindowSetTintColor(windowName .. name .. "ColorExample", color.R or 255, color.G or 255, color.B or 255);
	else
		if (activeColorIcon == windowName .. name .. "ColorExample") then
			WindowSetShowing(windowName .. "SelectColor", false);
		end
	end
	WindowSetShowing(windowName .. name .. "ColorExample", (value == TurretRange.ColorType.Custom));
	
	if (not lockSettings) then
		settings.Type = value;
		TurretRange.OnSettingsChanged();
	end

end

function TurretRange.Setup.Display.OnDistanceTypeChanged()

	SetType(TurretRange.Settings.Display.Distance, "Distance");
	UpdateExample(activeElement);

end

function TurretRange.Setup.Display.OnDistanceOffsetXChanged()

	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "DistanceOffsetXEditBox"));
	
	local offset = TurretRange.Settings.Display.Distance.Offset or {};
	TurretRange.Settings.Display.Distance.Offset = { X = value, Y = offset.Y or 0 };
	TurretRange.OnSettingsChanged();
	UpdateExample(activeElement);

end

function TurretRange.Setup.Display.OnDistanceOffsetYChanged()

	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "DistanceOffsetYEditBox"));
	
	local offset = TurretRange.Settings.Display.Distance.Offset or {};
	TurretRange.Settings.Display.Distance.Offset = { X = offset.X or 0, Y = value};
	TurretRange.OnSettingsChanged();
	UpdateExample(activeElement);

end

function TurretRange.Setup.Display.OnDistanceLayoutChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "DistanceLayoutComboBox");
	
	TurretRange.Settings.Display.Distance.Layout = value;	
	TurretRange.OnSettingsChanged();
	UpdateExample(activeElement);
	
end

function TurretRange.Setup.Distance.SetFont()
	local menu = 1;
	local index = WindowGetId(SystemData.ActiveWindow.name);
	if (index) then
		local font = fonts[index];
		if (font) then
			local label = windowName .. "DistanceFontExampleLabel";
			TurretRange.Settings.Display.Distance.Font = font.Font;
			
			if (label) then
				LabelSetText(label, towstring(font.Name));
				LabelSetFont(label, font.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
				UpdateExample("Distance");
			end
			
		end
	end
	EA_Window_ContextMenu.Hide(menu)
	TurretRange.OnSettingsChanged();
end

local function ShowFontSelection()
	local menu = 1;
	
	EA_Window_ContextMenu.CreateContextMenu(SystemData.ActiveWindow.name, menu);
	for index, font in ipairs(fonts) do
       EA_Window_ContextMenu.AddUserDefinedMenuItem("TurretRangeContextMenuItemFontMenuItem" .. index, menu);
	end
	EA_Window_ContextMenu.Finalize(menu);
end

function TurretRange.Setup.Display.OnSlideTint()

	local r = math.floor(SliderBarGetCurrentPosition(windowName .. "SelectColorTintRedSlider") * 255);
	local g = math.floor(SliderBarGetCurrentPosition(windowName .. "SelectColorTintGreenSlider") * 255);
	local b = math.floor(SliderBarGetCurrentPosition(windowName .. "SelectColorTintBlueSlider") * 255);
	
	colorLock = true;
	TextEditBoxSetText(windowName .. "SelectColorTintRedEditBox", towstring(r));
	TextEditBoxSetText(windowName .. "SelectColorTintGreenEditBox", towstring(g));
	TextEditBoxSetText(windowName .. "SelectColorTintBlueEditBox", towstring(b));
	colorLock = false;
	
	TurretRange.Setup.Display.OnTintChanged(true);

end

function TurretRange.Setup.Display.OnTintChanged(value)

	if (lockSettings or colorLock) then return end

	local r = tonumber(TextEditBoxGetText(windowName .. "SelectColorTintRedEditBox"));
	local g = tonumber(TextEditBoxGetText(windowName .. "SelectColorTintGreenEditBox"));
	local b = tonumber(TextEditBoxGetText(windowName .. "SelectColorTintBlueEditBox"));
	
	if (value ~= true) then
		SliderBarSetCurrentPosition(windowName .. "SelectColorTintRedSlider", r / 255);
		SliderBarSetCurrentPosition(windowName .. "SelectColorTintGreenSlider", g / 255);
		SliderBarSetCurrentPosition(windowName .. "SelectColorTintBlueSlider", b / 255);
	end
	
	if (activeColorIcon) then
		WindowSetTintColor(activeColorIcon, r, g, b);
		activeColorSettings.Color = { R = r, G = g, B = b };
		UpdateExample(activeElement);
	end

end

local function ToggleColorSelection(colorIcon, settings)

	if (WindowGetShowing(windowName .. "SelectColor") and activeColorIcon == colorIcon) then
		WindowSetShowing(windowName .. "SelectColor", false);
		return;
	end

	activeColorIcon = colorIcon;
	activeColorSettings = settings;
	
	settings.Color = settings.Color or {};
	lockSettings = true;
	TextEditBoxSetText(windowName .. "SelectColorTintRedEditBox", towstring(settings.Color.R or 255));
	TextEditBoxSetText(windowName .. "SelectColorTintGreenEditBox", towstring(settings.Color.G or 255));
	TextEditBoxSetText(windowName .. "SelectColorTintBlueEditBox", towstring(settings.Color.B or 255));
	lockSettings = false;
	TurretRange.Setup.Display.OnTintChanged();
	
	WindowClearAnchors(windowName .. "SelectColor");
	WindowAddAnchor(windowName .. "SelectColor", "topleft", colorIcon, "topright", 0, 0);
	
	WindowSetShowing(windowName .. "SelectColor", true);
	
end

function TurretRange.Setup.Display.OnDistanceColorLUp()

	ToggleColorSelection(windowName .. "DistanceColorExample", TurretRange.Settings.Display.Distance);

end

function TurretRange.Setup.Display.OnDistanceFontMouseOver()

	LabelSetTextColor(windowName .. "DistanceFontExampleLabel", 255, 110, 10);

end

function TurretRange.Setup.Display.OnDistanceFontMouseOut()

	LabelSetTextColor(windowName .. "DistanceFontExampleLabel", 255, 255, 255);

end

function TurretRange.Setup.Display.OnDistanceFontLUp()

	ShowFontSelection();
	
end

function TurretRange.Setup.Display.OnSlideDistanceScale()

	local value = MIN_DISTANCE_SCALE_SLIDER + math.floor(SliderBarGetCurrentPosition(windowName .. "DistanceScaleSlider") * (MAX_DISTANCE_SCALE_SLIDER - MIN_DISTANCE_SCALE_SLIDER) * 100) / 100;
	LabelSetText(windowName .. "DistanceScaleValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		TurretRange.Settings.Display.Distance.Scale = value;
		TurretRange.OnSettingsChanged();
		UpdateExample(activeElement);
	end
	
end

function TurretRange.Setup.Display.OnGraphicTypeChanged()

	SetType(TurretRange.Settings.Display.Graphic, "Graphic");
	UpdateExample(activeElement);

end

function TurretRange.Setup.Display.OnGraphicColorLUp()

	ToggleColorSelection(windowName .. "GraphicColorExample", TurretRange.Settings.Display.Graphic);

end

function TurretRange.Setup.Display.OnGraphicLimitChanged()

	if (lockSettings) then return end

	local value = tonumber(TextEditBoxGetText(windowName .. "GraphicLimitEditBox"));
	TurretRange.Settings.Display.Graphic.Limit = value;
	
end

function TurretRange.Setup.Display.OnCircleTypeChanged()

	SetType(TurretRange.Settings.Display.Circle, "Circle");
	UpdateExample(activeElement);

end

function TurretRange.Setup.Display.OnCircleColorLUp()

	ToggleColorSelection(windowName .. "CircleColorExample", TurretRange.Settings.Display.Circle);

end

function TurretRange.Setup.Display.OnCircleModeChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "CircleModeComboBox");
	LabelSetText(windowName .. "CircleModeInfoLabel", modeInfo[value]);
	
	if (not lockSettings) then
		TurretRange.Settings.Display.Circle.Mode = value;	
		TurretRange.OnSettingsChanged();
	end

end

function TurretRange.Setup.Display.OnCircleInvertLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "CircleInvert" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "CircleInvert" .. "Button", isChecked);
	
	TurretRange.Settings.Display.Circle.Inverted = isChecked;

end
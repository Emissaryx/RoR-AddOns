TurretRange = TurretRange or {};
TurretRange.Display = 
{
	WindowName = "TurretRangeDisplay",
	IsShowing = false,
	IsHidden = false,
	Layout =
	{
		Distance =
		{
			Visible = true,
			Value = L"",
			Color = { R = 255, G = 255, B = 255 },
			Offset = { X = 0, Y = 0 },
		},
		Graphic =
		{
			Visible = true,
			Color = { R = 255, G = 255, B = 255 },
		},
		Circle =
		{
			Visible = true,
			Color = { R = 255, G = 255, B = 255 },
			Showing = true, -- for hiding when out of range
		},
		Position =
		{
			Scale = nil,
			X = nil,
			Y = nil,
		},
	}
};

local this = TurretRange.Display;
local windowName = TurretRange.Display.WindowName;

local LOCATION_TO_DISTANCE = 0.084; -- modifier for changing [x, y] points to distance (calculated based on Mythic's distances)
local PIXELS_TO_DISPLAY_EDGE = 42 - 5; -- center to edge, minus 1/2 circle width;
local PIXELS_TO_MAX_THRESHOLD = 60 + 5;
local FADE_DURATION = 0.1;
local UPDATE_DELAY = 0.1; -- only used if settings fail

local nextUpdate = 0;
local hideAt = nil;

local distanceChecks = nil; -- holds color information for distances

local function IsColorEqual(colorA, colorB)

	if (not colorA or not colorB) then
		return false;
	end

	return (colorA.R == colorB.R and colorA.G == colorB.G and colorA.B == colorB.B);

end

local function GetDistanceCheckFor(index)

	local settings = TurretRange.Settings.Distance;
	local distanceSettings = settings[index];
	if (not distanceSettings) then
		return { Threshold = 0, Index = 0, Settings = nil, Next = nil, Count = 0 };
	end
	
	local nextThreshold = nil;
	if (index > 1 and settings[index - 1]) then
		nextThreshold = settings[index - 1].Distance;
	end
	
	return { Threshold = distanceSettings.Distance, Index = index, Settings = distanceSettings, Next = nextThreshold, Count = #TurretRange.Settings.Distance };
	
end

local function UpdateDistanceChecks(distance)

	if (not distanceChecks) then
		return false;
	end

	local settingsChanged = false;

	while (distanceChecks.Next and distance >= distanceChecks.Next) do
		distanceChecks = GetDistanceCheckFor(distanceChecks.Index - 1);
		settingsChanged = true;
	end
	
	while (distance < distanceChecks.Threshold and distanceChecks.Index < distanceChecks.Count) do
		distanceChecks = GetDistanceCheckFor(distanceChecks.Index + 1);
		settingsChanged = true;
	end
	
	return settingsChanged;

end

local function GetDistanceColor()

	local color = nil;

	if (distanceChecks.Settings) then
		color = distanceChecks.Settings.Color;
	end
	
	return (color or { R = 255, G = 255, B = 255 });

end

local function GetColorFor(settings, distance)

	local colorType = settings.Type;

	if (colorType == TurretRange.ColorType.Distance) then
		return GetDistanceColor();
	elseif (colorType == TurretRange.ColorType.Custom) then
		return settings.Color or { R = 255, G = 255, B = 255 };
	else
		return { R = 255, G = 255, B = 255 };
	end

end

local function KeepDistanceInRangeOf(distance, maxDistance)

	if (distance < 0) then
		return math.max(distance, -maxDistance);
	else
		return math.min(distance, maxDistance);
	end

end

local function UpdateDisplay()

	local layout = this.Layout;
	local location = TurretRange.Location;
	if (not location.Player) then return end
	location.Pet = location.Pet or location.Player; -- casted a pet without moving, use the current player's position
	
	local playerX, playerY = location.Player.X, location.Player.Y;
	local petX, petY = location.Pet.X, location.Pet.Y;
	local dX, dY = playerX - petX, playerY - petY;
	
	local distance = math.floor(math.sqrt(math.pow(dX, 2) + math.pow(dY, 2))) * LOCATION_TO_DISTANCE;
	local displayValue = towstring(string.format("%d", distance));
	local displaySettings = TurretRange.Settings.Display;
	
	UpdateDistanceChecks(distance);
	
	local hide = false;
	if (distanceChecks and distanceChecks.Settings) then
		hide = distanceChecks.Settings.Hide or false;
	end
	if (this.IsHidden ~= hide) then
		this.IsHidden = hide;
		WindowSetShowing(windowName, (hide == false));
	end
	if (hide) then
		return;
	end
	
	if (layout.Distance.Visible and layout.Distance.Value ~= displayValue) then
		layout.Distance.Value = displayValue;
		LabelSetText(windowName .. "Distance", displayValue);		
		local color = GetColorFor(displaySettings.Distance, distance);
		if (not IsColorEqual(color, layout.Distance.Color)) then
			layout.Distance.Color = color;
			LabelSetTextColor(windowName .. "Distance", color.R or 255, color.G or 255, color.B or 255);
		end
	end
	
	if (layout.Graphic.Visible) then
		local color = GetColorFor(displaySettings.Graphic, distance);
		if (not IsColorEqual(color, layout.Graphic.Color)) then
			layout.Graphic.Color = color;
			WindowSetTintColor(windowName .. "Graphic", color.R or 255, color.G or 255, color.B or 255);
			WindowSetTintColor(windowName .. "BG", color.R or 255, color.G or 255, color.B or 255);
		end
	end
	if (layout.Circle.Visible) then
		local color = GetColorFor(displaySettings.Circle, distance);
		if (not IsColorEqual(color, layout.Circle.Color)) then
			layout.Circle.Color = color;
			WindowSetTintColor(windowName .. "Circle", color.R or 255, color.G or 255, color.B or 255);
			WindowSetTintColor(windowName .. "Circle2", color.R or 255, color.G or 255, color.B or 255);
		end
		
		local lengthToEdge = PIXELS_TO_DISPLAY_EDGE;
		local showCircle = true;
		local distanceLimit = displaySettings.Graphic.Limit or 30;
		
		local xOffset = ((dX * LOCATION_TO_DISTANCE) / distanceLimit) * lengthToEdge;
		local yOffset = ((dY * LOCATION_TO_DISTANCE) / distanceLimit) * lengthToEdge;
	--	WindowSetAlpha(windowName .. "Name",1)
	--	LabelSetText(windowName .. "Name", towstring(GameData.Player.name))
	--	WindowSetShowing(windowName .. "Name", showCircle);
		if (displaySettings.Circle.Inverted) then
	--	WindowSetAlpha(windowName .. "Name",1)
		--LabelSetText(windowName .. "Name", L"Turret")
	--	WindowSetShowing(windowName .. "Name", showCircle);

			xOffset = -xOffset;
			yOffset = -yOffset;
		end
		
		if (layout.Circle.Mode == TurretRange.Layout.Circle.Sticky) then
			local lengthToMaxThreshold = PIXELS_TO_MAX_THRESHOLD;
			xOffset = KeepDistanceInRangeOf(xOffset, lengthToMaxThreshold);
			yOffset = KeepDistanceInRangeOf(yOffset, lengthToMaxThreshold);
		elseif (layout.Circle.Mode == TurretRange.Layout.Circle.Hide) then
			local lengthToMaxThreshold = PIXELS_TO_MAX_THRESHOLD;
			if (math.abs(xOffset) > lengthToMaxThreshold or math.abs(yOffset) > lengthToMaxThreshold) then
				showCircle = false;
			end
		end
		
		if (layout.Circle.Showing ~= showCircle) then
			layout.Circle.Showing = showCircle;
			WindowSetShowing(windowName .. "Circle", showCircle);
			WindowSetShowing(windowName .. "Circle2", showCircle);
			WindowSetShowing(windowName .. "Name", showCircle);
		end
		
		if (showCircle) then
			WindowClearAnchors(windowName .. "Circle");
			WindowAddAnchor(windowName .. "Circle", "center", windowName, "center", xOffset, yOffset);
			
			WindowClearAnchors(windowName .. "Circle2");
			WindowAddAnchor(windowName .. "Circle2", "center", "TurretRangeDisplay", "center", 0, 0);
		end
	end

end

function TurretRange.Display.Initialize()

	LayoutEditor.RegisterWindow(windowName, L"TurretRange", L"TurretRange", false, false, true);
	TurretRange.Display.UpdateLayout();
	
end

function TurretRange.Display.Unload()

	LayoutEditor.UnregisterWindow(windowName);
	this.Show(false, true);

end

function TurretRange.Display.UpdateLayout()

	local settings = TurretRange.Settings;
	local displaySettings = settings.Display;
	local layout = this.Layout;
	
	distanceChecks = { Threshold = 0, Index = 0, Settings = nil, Next = nil };
	if (#settings.Distance > 0) then
		distanceChecks = GetDistanceCheckFor(#settings.Distance);
	end
	
	if (settings.Position) then
		local interfaceScale = InterfaceCore.GetScale();
		local scale = (settings.Position.Scale or 1);
		
		if (layout.Position.Scale ~= scale) then
			layout.Position.Scale = scale;
			WindowSetScale(windowName, scale * interfaceScale);
		end
		
		if (layout.Position.X ~= settings.Position.X or layout.Position.Y ~= settings.Position.Y) then
			layout.Position.X, layout.Position.Y = settings.Position.X, settings.Position.Y;
			WindowClearAnchors(windowName);
			WindowAddAnchor(windowName, "topleft", "Root", "topleft", settings.Position.X, settings.Position.Y);
		end
	end

	layout.Scale = WindowGetScale(windowName);
	
	local visible = (displaySettings.Distance.Type ~= TurretRange.ColorType.Hide);
	if (layout.Distance.Visible ~= visible) then
		layout.Distance.Visible = visible;
		WindowSetShowing(windowName .. "Distance", visible);
	end
	if (visible) then
		if (layout.Distance.Scale ~= displaySettings.Distance.Scale) then
			layout.Distance.Scale = displaySettings.Distance.Scale;
			WindowSetScale(windowName .. "Distance", layout.Distance.Scale * layout.Scale);
		end
		if (layout.Distance.Font ~= displaySettings.Distance.Font) then
			layout.Distance.Font = displaySettings.Distance.Font;
			LabelSetFont(windowName .. "Distance", displaySettings.Distance.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
			WindowSetDimensions(windowName .. "Distance", 150, 80);
			local _, height = LabelGetTextDimensions(windowName .. "Distance");
			WindowSetDimensions(windowName .. "Distance", 150, height);
		end
		if (layout.Distance.Layout ~= displaySettings.Distance.Layout or layout.Distance.Offset.X ~= displaySettings.Distance.Offset.X or layout.Distance.Offset.Y ~= displaySettings.Distance.Offset.Y) then
			layout.Distance.Layout = displaySettings.Distance.Layout;
			layout.Distance.Offset = displaySettings.Distance.Offset;
			WindowClearAnchors(windowName .. "Distance");
			if (layout.Distance.Layout == TurretRange.Layout.Distance.Bottom) then
				WindowAddAnchor(windowName .. "Distance", "bottom", windowName, "top", (layout.Distance.Offset.X or 0), -5 + (layout.Distance.Offset.Y or 0));
			elseif (layout.Distance.Layout == TurretRange.Layout.Distance.Center) then
				WindowAddAnchor(windowName .. "Distance", "center", windowName, "center", (layout.Distance.Offset.X or 0), (layout.Distance.Offset.Y or 0));
			else -- TurretRange.Layout.Distance.InnerBottom
				WindowAddAnchor(windowName .. "Distance", "bottom", windowName, "bottom", (layout.Distance.Offset.X or 0), -25 + (layout.Distance.Offset.Y or 0));
			end
		end
		if (displaySettings.Distance.Type == TurretRange.ColorType.Custom and not IsColorEqual(layout.Distance.Color, displaySettings.Distance.Color)) then
			layout.Distance.Color = displaySettings.Distance.Color;
			local color = displaySettings.Distance.Color or {};
			LabelSetTextColor(windowName .. "Distance", color.R or 255, color.G or 255, color.B or 255);
		end
	end
	
	visible = (displaySettings.Graphic.Type ~= TurretRange.ColorType.Hide);
	if (layout.Graphic.Visible ~= visible) then
		layout.Graphic.Visible = visible;
		WindowSetShowing(windowName .. "Graphic", visible);
	end
	if (visible) then
	
	end
	
	visible = (displaySettings.Circle.Type ~= TurretRange.ColorType.Hide);
	if (layout.Circle.Visible ~= visible) then
		layout.Circle.Visible = visible;
		WindowSetShowing(windowName .. "Circle", visible);
			WindowSetShowing(windowName .. "Circle2", visible);
		WindowSetShowing(windowName .. "Name", visible);
	end
	if (visible) then
		layout.Circle.Mode = displaySettings.Circle.Mode;
	end

end

function TurretRange.Display.SetAlpha(alpha)

	if (this.Layout.Alpha == alpha) then return end
	this.Layout.Alpha = alpha;

	if (hideAt) then
		hideAt = nil;
		WindowStopAlphaAnimation(windowName);
	end

	WindowSetAlpha(windowName, alpha);
	WindowSetFontAlpha(windowName .. "Distance", alpha);
	WindowSetAlpha(windowName .. "Graphic", alpha);
	WindowSetAlpha(windowName .. "Circle", alpha);
	WindowSetAlpha(windowName .. "Circle2", alpha);
	WindowSetAlpha(windowName .. "Name",alpha);
end

function TurretRange.Display.FadeOut(duration)
	
	this.Layout.Alpha = 0;
	WindowStartAlphaAnimation(windowName, Window.AnimationType.EASE_OUT, 1, 0, math.max(duration, 0.1), false, 0, 0);
	hideAt = TurretRange.SystemTime + duration;
	
end

function TurretRange.Display.Show(isShowing, force)

	if (this.IsShowing ~= isShowing or force) then
		this.IsShowing = isShowing;
		if (isShowing) then
			UpdateDisplay();
			if (this.IsHidden) then
				return;
			end
			this.SetAlpha(1);
		elseif (not force) then
			this.FadeOut(FADE_DURATION);
			return;
		end
		WindowSetShowing(windowName, isShowing);
	end

end

local function GetUpdateDelay()

	return TurretRange.Settings.General.UpdateDelay or UPDATE_DELAY;

end

function TurretRange.Display.Update(elapsed)
	
	if (hideAt and TurretRange.SystemTime > hideAt) then
		hideAt = nil;
		this.Show(false, true);
	end
	
	if (this.IsShowing and not hideAt and TurretRange.SystemTime > nextUpdate) then
		nextUpdate = TurretRange.SystemTime + GetUpdateDelay();
		UpdateDisplay();
	end


end
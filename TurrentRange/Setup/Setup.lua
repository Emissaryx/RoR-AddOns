TurretRange = TurretRange or {};
TurretRange.Setup = TurretRange.Setup or {};
TurretRange.Setup.WindowName = "TurretRangeSetupMenuWindow";
TurretRange.Setup.ActiveWindow = nil;

local windowName = TurretRange.Setup.WindowName;

local localization = TurretRange.Localization.GetMapping();

function TurretRange.Setup.Initialize()

	TurretRange.Setup.Distances.Initialize();
	TurretRange.Setup.Distance.Initialize();
	TurretRange.Setup.Display.Initialize();
	TurretRange.Setup.General.Initialize();

	LabelSetText(windowName .. "Label", localization["Setup.Menu.Title"]);
	ButtonSetText(windowName .. "DistancesSetupButton", localization["Setup.Menu.Distances"]);
	ButtonSetText(windowName .. "DisplaySetupButton", localization["Setup.Menu.Display"]);
	ButtonSetText(windowName .. "GeneralSetupButton", localization["Setup.Menu.General"]);

end

function TurretRange.Setup.LoadSettings()

	TurretRange.Setup.General.LoadSettings();
	TurretRange.Setup.Display.LoadSettings();
	
end

function TurretRange.Setup.SetActiveWindow(setupWindow)
	
	if (TurretRange.Setup.ActiveWindow == setupWindow) then return end

	if (TurretRange.Setup.ActiveWindow and TurretRange.Setup.ActiveWindow.WindowName) then
		TurretRange.Setup.ActiveWindow.Hide();
	end
	
	TurretRange.Setup.ActiveWindow = setupWindow;
	
	if (setupWindow and setupWindow.WindowName) then
		TurretRange.Setup.ActiveWindow.Show();
		
		local x, y = WindowGetScreenPosition(windowName);
		if (x == TurretRange.Setup.DefaultPosition.X and y == TurretRange.Setup.DefaultPosition.Y) then
			local width, height = WindowGetDimensions(setupWindow.WindowName);
			WindowClearAnchors(windowName);
			WindowAddAnchor(windowName, "center", "Root", "topright", -(width / 2), -(height / 2));
		end
		
		WindowClearAnchors(setupWindow.WindowName);
		WindowAddAnchor(setupWindow.WindowName, "topright", windowName, "topleft", 0, 0);
	else
	
	end

end

function TurretRange.Setup.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowClearAnchors(windowName);
	WindowAddAnchor(windowName, "center", "Root", "center", 0, 0);

	local x, y = WindowGetScreenPosition(windowName);
	TurretRange.Setup.DefaultPosition = { X = x, Y = y };
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TurretRange.Setup.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TurretRange.Setup.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TurretRange.Setup.OnHidden()

	TurretRange.Setup.SetActiveWindow();

end

function TurretRange.Setup.OnCloseLUp()

	TurretRange.Setup.Hide();

end

function TurretRange.Setup.OnGeneralSetupLUp()

	TurretRange.Setup.SetActiveWindow(TurretRange.Setup.General);

end

function TurretRange.Setup.OnDistancesSetupLUp()

	TurretRange.Setup.SetActiveWindow(TurretRange.Setup.Distances);

end

function TurretRange.Setup.OnDisplaySetupLUp()

	TurretRange.Setup.SetActiveWindow(TurretRange.Setup.Display);

end

TurretRange = TurretRange or {};
if (not TurretRange.Localization) then
	TurretRange.Localization = {};
	TurretRange.Localization.Language = {};
end

TurretRange.Localization.Language[SystemData.Settings.Language.ENGLISH] = 
{
	["Setup.Menu.Title"] = L"TurretRange",
	["Setup.Menu.Distances"] = L"Distances",
	["Setup.Menu.Display"] = L"Display",
	["Setup.Menu.General"] = L"General",
	
	["Setup.Distances.Title"] = L"Distances",
	["Setup.Distances.Distances"] = L"Coloring for distances",
	["Setup.Distances.DistanceGreaterEqualThan"] = L"Distance is >= %d",
	["Setup.Distances.Hide"] = L", hidden",
	["Setup.Distances.Add"] = L"Add Distance",
	["Setup.Distances.Remove"] = L"Remove",
	
	["Setup.Distance.Title"] = L"Distance",
	["Setup.Distance.Distance"] = L"When the distance is greater or equal to",
	["Setup.Distance.Color"] = L"Color",
	["Setup.Distance.Color.R"] = L"Red",
	["Setup.Distance.Color.G"] = L"Green",
	["Setup.Distance.Color.B"] = L"Blue",
	["Setup.Distance.Hide"] = L"Hide when in this range",
	["Setup.Distance.Create"] = L"Create",
	["Setup.Distance.Apply"] = L"Apply Changes",
	
	["Setup.Display.Title"] = L"Display Settings",
	["Setup.Display.Element"] = L"Element",
	["Setup.Display.Layout"] = L"Layout",
	["Setup.Display.Type"] = L"Type",
	["Setup.Display.Type.Hidden"] = L"Hidden",
	["Setup.Display.Type.ColorByDistance"] = L"Color by distance",
	["Setup.Display.Type.ColorCustom"] = L"Custom color",
	["Setup.Display.Offset"] = L"Offset",
	["Setup.Display.Offset.X"] = L"X",
	["Setup.Display.Offset.Y"] = L"Y",
	["Setup.Display.Color.R"] = L"Red",
	["Setup.Display.Color.G"] = L"Green",
	["Setup.Display.Color.B"] = L"Blue",
	["Setup.Display.Font"] = L"Font",
	["Setup.Display.Scale"] = L"Scale",
	["Setup.Display.Mode"] = L"Mode",
	["Setup.Display.Font.Select"] = L"Select",
	["Setup.Display.Distance"] = L"Distance",
	["Setup.Display.Graphic"] = L"Graphic",
	["Setup.Display.Circle"] = L"Circle",
	["Setup.Display.Circle.Mode.Sticky"] = L"Sticky",
	["Setup.Display.Circle.Mode.Show"] = L"Show",
	["Setup.Display.Circle.Mode.Hide"] = L"Hide",
	["Setup.Display.Circle.Mode.Sticky.Info"] = L"Sticks to the edge when the limit is reached",
	["Setup.Display.Circle.Mode.Show.Info"] = L"Always visible",
	["Setup.Display.Circle.Mode.Hide.Info"] = L"Hides when the limit is reached",
	["Setup.Display.Circle.Invert"] = L"Invert (will represent the pet's location)",
	["Setup.Display.Distance.Layout.InnerBottom"] = L"Inner Bottom",
	["Setup.Display.Distance.Layout.Bottom"] = L"Bottom",
	["Setup.Display.Distance.Layout.Center"] = L"Center",
	["Setup.Display.Graphic.Limit"] = L"Distance from the center to the edge",
	
	["Setup.General.Title"] = L"General Settings",
	["Setup.General.Enable"] = L"Enable TurretRange",
	["Setup.General.UpdateDelay"] = L"Update delay",
};


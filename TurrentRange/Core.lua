
TurretRange = TurretRange or {};
TurretRange.IsLoaded = false;
TurretRange.SystemTime = 0;
TurretRange.Location = 
{
	Player = nil, 
	Pet = nil,
};
TurretRange.ColorType =
{
	Hide = 1,
	Distance = 2,
	Custom = 3,
};
TurretRange.Layout =
{
	Distance = { InnerBottom = 1, Bottom = 2, Center = 3 },
	Circle = { Hide = 1, Sticky = 2, Show = 3 }, 
};

local VERSION_SETTINGS = 1;

local repositionSpells = -- spells that cause the pet to be reposition
{
	[1532] = true,
	[8542] = true,
}

local PetCasts = {[1511]=true,[1518]=true,[1526]=true,[8474]=true,[8476]=true,[8478]=true,}

local positionUpdated = false;
local isEnabled = true;
local layoutDirty = false;

local isLibSlashRegistered = false;
local isLibAddonButtonRegistered = false;

local localization = TurretRange.Localization.GetMapping();

local function RegisterLibs()
	if (not isLibSlashRegistered) then
		if (LibSlash) then
			LibSlash.RegisterWSlashCmd("turretrange", function(args) TurretRange.SlashCommand(args) end);
			isLibSlashRegistered = true;
		end
	end

	if (not isLibAddonButtonRegistered) then
		if (LibAddonButton) then
			LibAddonButton.Register("fx");
			LibAddonButton.AddMenuItem("fx", "TurretRange", TurretRange.Setup.Show);
			isLibAddonButtonRegistered = true;
		end
	end
end

local function ShowDisplay(isShowing)

	if (isEnabled) then
		TurretRange.Display.Show(isShowing);
	end

end

local function UpdatePetLocation()

	local location = TurretRange.Location;
	location.Pet = location.Player;
	positionUpdated = true;
		
end

function TurretRange.Initialize()

MapNumber = math.random(1,100)

	if (TurretRange.IsLoaded) then return end
	TurretRange.IsLoaded = true;
	
	TurretRange.LoadSettings();
	TurretRange.Setup.Initialize();
	TurretRange.Display.Initialize();

	RegisterEventHandler(SystemData.Events.PLAYER_PET_UPDATED, "TurretRange.OnPetUpdated");
	RegisterEventHandler(SystemData.Events.PLAYER_POSITION_UPDATED, "TurretRange.OnPlayerPositionUpdated");
	RegisterEventHandler(SystemData.Events.LOADING_END, "TurretRange.OnLoadComplete");
	RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "TurretRange.OnLoadComplete");
	RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "TurretRange.OnBeginCast");
	RegisterEventHandler(SystemData.Events.PLAYER_END_CAST, "TurretRange.OnCastEnd");
	table.insert(LayoutEditor.EventHandlers, TurretRange.OnLayoutEditorFinished);
	
end

function TurretRange.Unload()

	if (not TurretRange.IsLoaded) then return end
	TurretRange.IsLoaded = false;
	
	TurretRange.Display.Unload();

	UnregisterEventHandler(SystemData.Events.PLAYER_PET_UPDATED, "TurretRange.OnPetUpdated");
	UnregisterEventHandler(SystemData.Events.PLAYER_POSITION_UPDATED, "TurretRange.OnPlayerPositionUpdated");
	UnregisterEventHandler(SystemData.Events.LOADING_END, "TurretRange.OnLoadComplete");
	UnregisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "TurretRange.OnLoadComplete");
	UnregisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "TurretRange.OnBeginCast");
	
	ShowDisplay(false);

end

function TurretRange.OnLoadComplete()

	if (GameData.Player.career.line ~= GameData.CareerLine.ENGINEER and GameData.Player.career.line ~= GameData.CareerLine.MAGUS) then
		TurretRange.Unload();
		return;
	end

		CreateWindowFromTemplate("Map"..MapNumber, "TurretMap", "Root" )
		--	CreateWindow("Map49",true)
		CreateMapInstance("Map"..MapNumber.."Display", SystemData.MapTypes.OVERHEAD)
		
		MapSetMapView( "Map"..MapNumber.."Display", GameDefs.MapLevel.ZONE_MAP, GameData.Player.zone)
	
	
	for i=1,56 do
	
	    MapSetPinFilter("Map"..MapNumber.."Display", i, false) 
		MapSetPinGutter("Map"..MapNumber.."Display", i, false)  		
	end
 MapSetPinFilter("Map"..MapNumber.."Display", 15, true) 
	
	
		RegisterLibs();
	ShowDisplay(false);
	
end

function TurretRange.OnLayoutEditorFinished(exitCode)
	
	if (exitCode ~= LayoutEditor.EDITING_END) then return end
	if (not TurretRange.IsLoaded) then return end
	
	local windowName = TurretRange.Display.WindowName;
	if (not DoesWindowExist(windowName)) then return end
	
	local interfaceScale = InterfaceCore.GetScale();
	local x, y = WindowGetScreenPosition(windowName);
	local windowScale = WindowGetScale(windowName);
	
	TurretRange.Settings.Position = 
	{
		Scale = windowScale / interfaceScale,
		X = x / interfaceScale,
		Y = y / interfaceScale,
	};
	
	TurretRange.Display.UpdateLayout();

end

local function UpdateSettings()

	local settings = TurretRange.Settings;
	local version = settings.Version;
	
	if (version == 1) then
		version = 2;
	end
	
end

function TurretRange.LoadSettings()

	if (not TurretRange.Settings) then
		TurretRange.Settings = {};
	else
		UpdateSettings();
	end
	
	local settings = TurretRange.Settings;
	settings.Version = VERSION_SETTINGS;
	
	if (not settings.Distance) then
		settings.Distance = 
		{
			{ Distance = 81, Color = { R = 255, G = 0, B = 0 }, },
			{ Distance = 41, Color = { R = 255, G = 255, B = 0 }, },
			{ Distance = 0, Color = { R = 0, G = 255, B = 0 }, },
		};
	end
	
	if (not settings.General) then
		settings.General =
		{
			Enabled = true,
			UpdateDelay = 0.01,
		};
	end
	
	if (not settings.Display) then
		settings.Display =
		{
			Distance =
			{
				Type = TurretRange.ColorType.Distance,
				Layout = TurretRange.Layout.Distance.InnerBottom,
				Offset = { X = 0, Y = 0 },
				Font = "font_clear_small_bold",
				Scale = 1,
			},
			Graphic =
			{
				Type = TurretRange.ColorType.Distance,
				Limit = 20,
			},
			Circle =
			{
				Type = TurretRange.ColorType.Distance,
				Mode = TurretRange.Layout.Circle.Sticky,
				Inverted = false,
			},
		};
	end

	TurretRange.OnSettingsChanged();

end

function TurretRange.SlashCommand(args)

	TurretRange.Setup.Show();

end

function TurretRange.OnBeginCast(spellId, channel, castTime)

	if (repositionSpells[spellId]) then
		UpdatePetLocation();
	end
	
	
		if (PetCasts[spellId]) then
		SummonPet = true
		SummonID = spellId
	--	UpdatePetLocation();
		else
		SummonPet = false
		SummonID = nil
		end

--8474 Pink
--8476 Blue
--8478 flamer
end

function TurretRange.OnCastEnd()
if SummonPet == true then
	if not TurretRange.Settings.Position then 

	local windowName = TurretRange.Display.WindowName;
--	if (not DoesWindowExist(windowName)) then return end
	
	local interfaceScale = InterfaceCore.GetScale();
	local x, y = WindowGetScreenPosition(windowName);
	local windowScale = WindowGetScale(windowName);
	
	TurretRange.Settings.Position = 
	{
		Scale = windowScale / interfaceScale,
		X = x / interfaceScale,
		Y = y / interfaceScale,
	};
	
	TurretRange.Display.UpdateLayout();
	
	end



if SummonID == 8478 or SummonID == 1518 then
		TurretRange.Settings.Display.Graphic.Limit = 55	
		TurretRange.Settings.Distance[1].Distance = 50
		TurretRange.Settings.Distance[2].Distance = 30
else
		TurretRange.Settings.Display.Graphic.Limit = 55
		TurretRange.Settings.Distance[1].Distance = 50
		TurretRange.Settings.Distance[2].Distance = 30
end
d("Pet summoned")
SummonPet = false
end

end

function TurretRange.OnPetUpdated()

	local hasPet = (GameData.Player.Pet.name ~= L"");
	
	if (hasPet) then
		UpdatePetLocation();
	MapSetMapView( "Map"..MapNumber.."Display", GameDefs.MapLevel.ZONE_MAP, GameData.Player.zone)
	 MapSetPinFilter("Map"..MapNumber.."Display", 15, true) 
	
		
		
	end
	ShowDisplay(hasPet);

end

function TurretRange.OnPlayerPositionUpdated(x, y)

	TurretRange.Location.Player = { X = x, Y = y };
	positionUpdated = true;

end

function TurretRange.OnSettingsChanged()

	local settings = TurretRange.Settings;
	
	if (not settings.General.Enabled) then
		if (isEnabled) then
			isEnabled = false;
			TurretRange.Display.Show(false, true);
		end
		return;
	end
	
	isEnabled = true;
	layoutDirty = true;

end

function TurretRange.OnUpdate(elapsed)

	if (not TurretRange.IsLoaded) then return end
	TurretRange.SystemTime = TurretRange.SystemTime + elapsed;
	
	if (not isEnabled) then return end
	
	if (layoutDirty) then
		layoutDirty = false;
		TurretRange.Display.UpdateLayout();
	end
	
	if (positionUpdated) then
		positionUpdated = false;
		TurretRange.Display.Update(elapsed);
TurretRange.Display.UpdateLayout()				
		local mapscale = InterfaceCore.GetScale()	
local mapX,mapY = WindowGetScreenPosition("TurretRangeDisplayCircle")


if (TurretRange.Settings.Display.Circle.Inverted) then

WindowSetScale("Map"..MapNumber,TurretRange.Settings.Position.Scale)
WindowClearAnchors("Map"..MapNumber)
WindowSetParent("Map"..MapNumber,"TurretRangeDisplayCircle2")
WindowAddAnchor("Map"..MapNumber, "center", "TurretRangeDisplayCircle2", "center", 0, 0)
--WindowSetOffsetFromParent("Map"..MapNumber,(mapX+2)/mapscale,(mapY+2)/mapscale)
CircleImageSetTexture( "TurretPortrait", "render_scene_pet_portrait", 40, 54 )

WindowSetScale("TurretPortrait",TurretRange.Settings.Position.Scale)
WindowClearAnchors("TurretPortrait")
WindowSetParent("TurretPortrait","TurretRangeDisplayCircle")
WindowAddAnchor("TurretPortrait", "center", "TurretRangeDisplayCircle", "center", 0, 0)
WindowSetTintColor("TurretPortrait",255, 255,255)


else
WindowSetScale("Map"..MapNumber,TurretRange.Settings.Position.Scale)
WindowClearAnchors("Map"..MapNumber)
WindowSetParent("Map"..MapNumber,"TurretRangeDisplayCircle")
WindowAddAnchor("Map"..MapNumber, "center", "TurretRangeDisplayCircle", "center", 0, 0)
--WindowSetOffsetFromParent("Map"..MapNumber,(mapX+2)/mapscale,(mapY+2)/mapscale)
CircleImageSetTexture( "TurretPortrait", "render_scene_pet_portrait", 40, 54 )
-- 45, 46 
WindowSetScale("TurretPortrait",TurretRange.Settings.Position.Scale)
WindowClearAnchors("TurretPortrait")
WindowSetParent("TurretPortrait","TurretRangeDisplayCircle2")
WindowAddAnchor("TurretPortrait", "center", "TurretRangeDisplayCircle2", "center", 0, 0)
WindowSetTintColor("TurretPortrait",255, 255,255)
	end	
		
	end




end
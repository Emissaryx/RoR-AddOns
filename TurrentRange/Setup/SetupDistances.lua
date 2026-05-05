TurretRange = TurretRange or {};
TurretRange.Setup = TurretRange.Setup or {};
TurretRange.Setup.Distances = 
{
	WindowName = "TurretRangeSetupDistancesWindow",
	Entries = {},
};

local windowName = TurretRange.Setup.Distances.WindowName;
local localization = TurretRange.Localization.GetMapping();

local activeType = nil;
local activeRow = nil;
local activeItem = nil;

local function SetupEntries()

	local entriesOrdered = {};
	TurretRange.Setup.Distances.Entries = {};
	
	for index, distance in ipairs(TurretRange.Settings.Distance) do
		local displayText = towstring(tostring(localization["Setup.Distances.DistanceGreaterEqualThan"]):format(distance.Distance));
		if (distance.Hide) then
			displayText = displayText .. localization["Setup.Distances.Hide"];
		end
		
		table.insert(TurretRange.Setup.Distances.Entries, {
			Text = displayText,
			Color = distance.Color,
			Index = index,
		});
		table.insert(entriesOrdered, #TurretRange.Setup.Distances.Entries);
	end
	
	ListBoxSetDisplayOrder(windowName .. "DistancesList", entriesOrdered);
	
end


local function TintRow(rowName, isActive)

	local id = WindowGetId(rowName);
	local entry = TurretRange.Setup.Distances.Entries[id];
		
	if (isActive) then
		WindowSetTintColor(rowName .. "Background", 12, 47, 158);
		WindowSetAlpha(rowName .. "Background", 0.4);
	else
		WindowSetAlpha(rowName .. "Background", 0);
	end

end

local function TintRows()
	indexToRow = {};
	for rowIndex, dataIndex in ipairs(TurretRangeSetupDistancesWindowDistancesList.PopulatorIndices) do
	
		local rowName = windowName .. "DistancesListRow" .. rowIndex;
		WindowSetId(rowName, dataIndex);
		indexToRow[dataIndex] = rowIndex;
		
		local entry = TurretRange.Setup.Distances.Entries[dataIndex];
		
		LabelSetTextColor(rowName .. "Text", entry.Color.R, entry.Color.G, entry.Color.B);
		
		TintRow(rowName, (rowName == activeRow));
	
	end
end

function TurretRange.Setup.Distances.Initialize()

	LabelSetText(windowName .. "TitleLabel", localization["Setup.Distances.Title"]);
	LabelSetText(windowName .. "DistancesLabel", localization["Setup.Distances.Distances"]);
	ButtonSetText(windowName .. "AddButton", localization["Setup.Distances.Add"]);
	
end

function TurretRange.Setup.Distances.Show()

	if (WindowGetShowing(windowName)) then return end
	
	SetupEntries();
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TurretRange.Setup.Distances.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TurretRange.Setup.Distances.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TurretRange.Setup.Distances.OnHidden()

	TurretRange.Setup.SetActiveWindow();

end

function TurretRange.Setup.Distances.OnCloseLUp()

	TurretRange.Setup.Distances.Hide();

end


local function CreateContextMenu()
	
	if (not activeItem) then return end
	
	EA_Window_ContextMenu.CreateContextMenu(activeRow);
	EA_Window_ContextMenu.AddMenuItem(localization["Setup.Distances.Remove"], TurretRange.Setup.Distances.OnContextMenuRemoveLUp, false, true);
	EA_Window_ContextMenu.Finalize();
	
end

function TurretRange.Setup.Distances.OnContextMenuRemoveLUp()

	if (activeItem) then
		table.remove(TurretRange.Settings.Distance, activeItem.Index);
		TurretRange.OnSettingsChanged();
	
		activeItem = nil;
		SetupEntries();
	end
	
end

function TurretRange.Setup.Distances.OnRowMouseOver()
	
	if (activeRow) then
		TintRow(activeRow, false);
	end
	
	activeRow = SystemData.MouseOverWindow.name;
	TintRow(activeRow, true);
		
end

function TurretRange.Setup.Distances.OnRowMouseOut()

	if (activeRow) then
		TintRow(activeRow, false);
		activeRow = nil;
	end
		
end

function TurretRange.Setup.Distances.OnRowLDown()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = TurretRange.Setup.Distances.Entries[id];
	if (not entry) then return end
	
	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
	
end

function TurretRange.Setup.Distances.OnRowLUp()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = TurretRange.Setup.Distances.Entries[id];
	if (not entry) then return end
	
	TurretRange.Setup.Distance.ShowEdit(entry.Index);
	TurretRange.Setup.SetActiveWindow(TurretRange.Setup.Distance);
	
	if (activeRow) then
		TintRow(activeRow, true);
	end
	
end

function TurretRange.Setup.Distances.OnRowRDown()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = TurretRange.Setup.Distances.Entries[id];
	if (not entry) then return end
	
	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
	
end

function TurretRange.Setup.Distances.OnRowRUp()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = TurretRange.Setup.Distances.Entries[id];
	if (not entry) then return end
	
	activeItem = entry;
	CreateContextMenu();
	
	if (activeRow) then
		TintRow(activeRow, true);
	end
		
end

function TurretRange.Setup.Distances.OnPopulate()

	if (not TurretRangeSetupDistancesWindowDistancesList.PopulatorIndices) then
		return;
	end

	TintRows();
	
end

function TurretRange.Setup.Distances.Update()

	SetupEntries();
	TurretRange.OnSettingsChanged();
	
end

function TurretRange.Setup.Distances.OnAddLClick()

	TurretRange.Setup.Distance.ShowNew(activeType);
	TurretRange.Setup.SetActiveWindow(TurretRange.Setup.Distance);

end
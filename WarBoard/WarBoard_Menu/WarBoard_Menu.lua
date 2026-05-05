WarBoard_Menu = {}
local debugEnabled = false  -- Set to true only if debugging is needed


WarBoard_Menu_ElementTable = {}
	
--[[
function WarBoard_Menu.addelement(name, template, openingwindow, highlighticon)
	table.insert(WarBoard_Menu_ElementTable, {name = name, template = template, openingwindow = openingwindow, highlighticon = highlighticon})
end
--]]

--[[
function WarBoard_Menu.addelement(position, name, template, openingwindow, highlighticon)
	table.insert(WarBoard_Menu_ElementTable, {position = position, name = name, template = template, openingwindow = openingwindow, highlighticon = highlighticon})
end

function WarBoard_Menu.addelement(position, name, template, openingwindow, highlighticon, friendlytext)
	table.insert(WarBoard_Menu_ElementTable, {position = position, name = name, template = template, openingwindow = openingwindow, highlighticon = highlighticon, friendlytext = friendlytext})
end
--]]

function WarBoard_Menu.addelement(position, name, template, openingwindow, highlighticon, friendlytext, shown)
	table.insert(WarBoard_Menu_ElementTable, {position = position, name = name, template = template, openingwindow = openingwindow, highlighticon = highlighticon, friendlytext = friendlytext, shown = shown})
end

function WarBoard_Menu.removeelement(name)
	WarBoard_Menu.DestroyElements()
	for i,v in ipairs(WarBoard_Menu_ElementTable) do
		if (v.name == name) then
			table.remove(WarBoard_Menu_ElementTable, i)
			
			break
		end
	end
	WarBoard_Menu.buildelements()
end

function WarBoard_Menu.CountShownElements()
	local cnt = 0
	for k, v in ipairs( WarBoard_Menu_ElementTable ) do
		if ( v.shown ) then
			cnt = cnt + 1
		end
	end
	return cnt
end

function WarBoard_Menu.buildelements()
	local tblsize = WarBoard_Menu.CountShownElements()
	local spacing = 5 
	local size = ((tblsize) * (30))+(spacing)
	WindowSetDimensions("WarBoard_Menu", size, 30)
	
	local xOffSet = 0		
	for k, v in ipairs( WarBoard_Menu_ElementTable ) do
		if debugEnabled then
		d("k: "..k.." Name: "..v.name.." Template: "..v.template.." OpeningWindow: "..v.openingwindow.." XOffSet: "..xOffSet.." showing: "..towstring(v.shown))
		end
		if (v.shown) then
			WarBoard_Menu.BuildElement(v.name, v.template, xOffSet+spacing)
			xOffSet = xOffSet + 30
		end
	end
end

--[[ 
function WarBoard_Menu.BuildElement(name, coreName, xOffSet)
	if debugEnabled then
	d( "BuildElement: "..name.." "..coreName)
	end
	CreateWindowFromTemplate( name, "WarBoard_MenuElement", "Root" )
	WindowSetShowing(name, true)
	WindowSetParent(name, "WarBoard_Menu")
	WindowSetDimensions(name, 30, 30)
	DynamicImageSetTexture(name.."Icon", "EA_Texture_Menu01", 0, 0)
	DynamicImageSetTextureSlice(name.."Icon", coreName.."-Button")
	DynamicImageSetTextureScale(name.."Icon", 0.5)
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOver", "WarBoard_Menu.OnMouseOver")
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOverEnd", "WarBoard_Menu.OnMouseOverEnd")
	WindowAddAnchor(name, "left", "WarBoard_Menu", "left", xOffSet+30, 0)
end
--]]
--[[
function WarBoard_Menu.SpawnContextMenu()
    EA_Window_ContextMenu.CreateContextMenu( WarBoard_Menu ) 
    --local movable = WindowGetMovable( EA_Window_ContextMenu.activeWindow )
    --local canAutoHide = EA_ChatWindowGroups[wndGroupId].canAutoHide
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_TO_LOCK ), EA_ChatWindow.OnLock, not movable, true )
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_TO_UNLOCK ), EA_ChatWindow.OnUnlock, movable, true )   
    EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_SET_OPACITY ), EA_ChatWindow.OnWindowOptionsSetAlpha, false, true )
    ButtonSetPressedFlag("ChatWindowContextAutoHideCheckBox", canAutoHide)
    EA_Window_ContextMenu.AddUserDefinedMenuItem("ChatWindowContextAutoHide")
    EA_Window_ContextMenu.Finalize()
end
--]]
    
function WarBoard_Menu.SpawnContextMenu()
		EA_Window_ContextMenu.CreateContextMenu("WarBoard_Menu", EA_Window_ContextMenu.CONTEXT_MENU_1)
		d("creating context menu ")
		for k, v in ipairs( WarBoard_Menu_ElementTable ) do
			d(v.name.." bool "..towstring(v.shown))
			if ( v.shown ) then
				d("Showing")
				--EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_SET_OPACITY ), EA_ChatWindow.OnWindowOptionsSetAlpha, false, true )
				EA_Window_ContextMenu.AddMenuItem(L"Hide "..towstring(v.friendlytext), WarBoard_Menu.ToggleShow, false, true)
			else
				d("Not showing")
				EA_Window_ContextMenu.AddMenuItem(L"Show "..towstring(v.friendlytext), WarBoard_Menu.ToggleShow, false, true)
			end
		end
		EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_1)
end

function WarBoard_Menu.ToggleShow()
	WarBoard_Menu.DestroyElements()
	d("wish to toggle ")
	
	local clickedWindowName = SystemData.ActiveWindow.name
	local windowId = WindowGetId(clickedWindowName)
	
	d(clickedWindowName.." "..windowId)
	d(WarBoard_Menu_ElementTable[windowId].shown)
	WarBoard_Menu_ElementTable[windowId].shown = not WarBoard_Menu_ElementTable[windowId].shown  
	d(WarBoard_Menu_ElementTable[windowId].shown)
	
	WarBoard_Menu.buildelements()
end




function WarBoard_Menu.Initialize()
	if ( WarBoard.AddMod( "WarBoard_Menu" ) ) then
		--Add your initialize stuff here. 
		--WarBoard creates the window if it is not disabled and anchors it where it needs to be so do not call CreateWindow()
		
		d( "WarBoard_Menu Module Loaded" )
		
		WindowRegisterCoreEventHandler("WarBoard_Menu", "OnRButtonUp", "WarBoard_Menu.SpawnContextMenu")
		
		
		--WarBoard_Menu_ElementTable = {}
		
		
		--WarBoard_Menu.BuildElement("Backpack", "Bag", spacing)
		if not (WarBoard_Menu_ElementTable) or (table.getn(WarBoard_Menu_ElementTable) == 0) then
			WarBoard_Menu.addelement(1, "Abilities", "Spellbook", "AbilitiesWindow", nil, "Abilities", true)
			WarBoard_Menu.addelement(2, "BackPack", "Bag", "EA_Window_Backpack", nil, "Backpack", true)
			WarBoard_Menu.addelement(3, "Character", "PaperDoll", "CharacterWindow", "PaperDoll-Button-Selected-Highlighted", "Character", true)
			WarBoard_Menu.addelement(4, "ToK", "Tome", "TomeWindow", nil, "Tome of Knowledge", true)
			WarBoard_Menu.addelement(5, "MainMenu", "MainMenu", "MainMenuWindow", nil, "Main Menu", true)
			WarBoard_Menu.addelement(6, "OpenParty", "Scenario-Grouping", "EA_Window_OpenParty", nil, "Parties and Warbands", true)
			WarBoard_Menu.addelement(7, "CustomizeInterface", "CustomizeInterface", "SettingsWindowTabbed", nil, "Customize UI", true)
			WarBoard_Menu.addelement(8, "Guild", "Guild", "GuildWindow", nil, "Guild", true)
			WarBoard_Menu.addelement(9, "HelpElement", "Help", "EA_Window_Help", nil, "Help", true)
		end
		
		WarBoard_Menu.buildelements()
	--[[			
		local tblsize = table.getn(WarBoard_Menu_ElementTable)
		local xOffSet = 0		
		for k, v in ipairs( WarBoard_Menu_ElementTable ) do
			d("k: "..k.." Name: "..v.name.." Template: "..v.template.." OpeningWindow: "..v.openingwindow.." XOffSet: "..xOffSet)
			WarBoard_Menu.BuildElement(v.name, v.template, xOffSet+spacing)
			xOffSet = xOffSet + 30
		end
--]]
	-- Abilities Window
	--[[
	CreateWindowFromTemplate( "Abilities", "WarBoard_MenuElement", "Root" )
	WindowSetShowing("Abilities", true)
	WindowSetParent("Abilities", "WarBoard_Menu")
	WindowSetDimensions("Abilities", 30, 30)
	DynamicImageSetTexture("AbilitiesIcon", "EA_Texture_Menu01", 0, 0)
	DynamicImageSetTextureSlice("AbilitiesIcon", "Spellbook-Button")
	DynamicImageSetTextureScale("AbilitiesIcon", 0.5)
	WindowRegisterCoreEventHandler("Abilities", "OnMouseOver", "WarBoard_Menu.OnMouseOver")
	WindowRegisterCoreEventHandler("Abilities", "OnMouseOverEnd", "WarBoard_Menu.OnMouseOverEnd")
	WindowAddAnchor("Abilities", "left", "WarBoard_Menu", "left", spacing, 0)
	--]]
	
	-- Backpack Window
	--CreateWindowFromTemplate( "Backpack", "WarBoard_MenuElement", "Root" )
--	WindowSetShowing("Backpack", true)
--	WindowSetParent("Backpack", "WarBoard_Menu")
--	WindowSetDimensions("Backpack", 30, 30)
--	DynamicImageSetTexture("BackpackIcon", "EA_Texture_Menu01", 0, 0)
--	DynamicImageSetTextureSlice("BackpackIcon", "Bag-Button")
--	DynamicImageSetTextureScale("BackpackIcon", 0.5)
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOver", "WarBoard_Menu.OnMouseOver")
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOverEnd", "WarBoard_Menu.OnMouseOverEnd")
--	WindowAddAnchor("Backpack", "left", "WarBoard_Menu", "left", spacing+30, 0)
	--[[
	-- Character Window
	CreateWindowFromTemplate( "Character", "WarBoard_MenuElement", "Root" )
	WindowSetShowing("Character", true)
	WindowSetParent("Character", "WarBoard_Menu")
	WindowSetDimensions("Character", 30, 30)
	DynamicImageSetTexture("CharacterIcon", "EA_Texture_Menu01", 0, 0)
	DynamicImageSetTextureSlice("CharacterIcon", "PaperDoll-Button")
	DynamicImageSetTextureScale("CharacterIcon", 0.5)
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOver", "WarBoard_Menu.OnMouseOver")
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOverEnd", "WarBoard_Menu.OnMouseOverEnd")
	WindowAddAnchor("Character", "left", "WarBoard_Menu", "left", spacing+60, 0)
	
	-- ToK Window
	CreateWindowFromTemplate( "ToK", "WarBoard_MenuElement", "Root" )
	WindowSetShowing("ToK", true)
	WindowSetParent("ToK", "WarBoard_Menu")
	WindowSetDimensions("ToK", 30, 30)
	DynamicImageSetTexture("ToKIcon", "EA_Texture_Menu01", 0, 0)
	DynamicImageSetTextureSlice("ToKIcon", "Tome-Button")
	DynamicImageSetTextureScale("ToKIcon", 0.5)
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOver", "WarBoard_Menu.OnMouseOver")
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOverEnd", "WarBoard_Menu.OnMouseOverEnd")
	WindowAddAnchor("ToK", "left", "WarBoard_Menu", "left", spacing+90, 0)
	
	-- Main Menu Window
	CreateWindowFromTemplate( "MainMenu", "WarBoard_MenuElement", "Root" )
	WindowSetShowing("MainMenu", true)
	WindowSetParent("MainMenu", "WarBoard_Menu")
	WindowSetDimensions("MainMenu", 30, 30)
	DynamicImageSetTexture("MainMenuIcon", "EA_Texture_Menu01", 0, 0)
	DynamicImageSetTextureSlice("MainMenuIcon", "MainMenu-Button")
	DynamicImageSetTextureScale("MainMenuIcon", 0.5)
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOver", "WarBoard_Menu.OnMouseOver")
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOverEnd", "WarBoard_Menu.OnMouseOverEnd")
	WindowAddAnchor("MainMenu", "left", "WarBoard_Menu", "left", spacing+120, 0)
	
	-- Cuztomize UI Window
	CreateWindowFromTemplate( "CustomizeInterface", "WarBoard_MenuElement", "Root" )
	WindowSetShowing("CustomizeInterface", true)
	WindowSetParent("CustomizeInterface", "WarBoard_Menu")
	WindowSetDimensions("CustomizeInterface", 30, 30)
	DynamicImageSetTexture("CustomizeInterfaceIcon", "EA_Texture_Menu01", 0, 0)
	DynamicImageSetTextureSlice("CustomizeInterfaceIcon", "CustomizeInterface-Button")
	DynamicImageSetTextureScale("CustomizeInterfaceIcon", 0.5)
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOver", "WarBoard_Menu.OnMouseOver")
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOverEnd", "WarBoard_Menu.OnMouseOverEnd")
	WindowAddAnchor("CustomizeInterface", "left", "WarBoard_Menu", "left", spacing+150, 0)
	
	-- Guild Window
	CreateWindowFromTemplate( "Guild", "WarBoard_MenuElement", "Root" )
	WindowSetShowing("Guild", true)
	WindowSetParent("Guild", "WarBoard_Menu")
	WindowSetDimensions("Guild", 30, 30)
	DynamicImageSetTexture("GuildIcon", "EA_Texture_Menu01", 0, 0)
	DynamicImageSetTextureSlice("GuildIcon", "Guild-Button")
	DynamicImageSetTextureScale("GuildIcon", 0.5)
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOver", "WarBoard_Menu.OnMouseOver")
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOverEnd", "WarBoard_Menu.OnMouseOverEnd")
	WindowAddAnchor("Guild", "left", "WarBoard_Menu", "left", spacing+180, 0)
	
	-- Help Window
	CreateWindowFromTemplate( "HelpElement", "WarBoard_MenuElement", "Root" )
	WindowSetShowing("HelpElement", true)
	WindowSetParent("HelpElement", "WarBoard_Menu")
	WindowSetDimensions("HelpElement", 30, 30)
	DynamicImageSetTexture("HelpElementIcon", "EA_Texture_Menu01", 0, 0)
	DynamicImageSetTextureSlice("HelpElementIcon", "Help-Button")
	DynamicImageSetTextureScale("HelpElementIcon", 0.5)
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOver", "WarBoard_Menu.OnMouseOver")
	--WindowRegisterCoreEventHandler("Backpack", "OnMouseOverEnd", "WarBoard_Menu.OnMouseOverEnd")
	WindowAddAnchor("HelpElement", "left", "WarBoard_Menu", "left", spacing+210, 0)	
	--]]
 --
 --		CreateWindowFromTemplate( "Test2", "WarBoard_MenuElement", "Root" )
 --		WindowSetShowing("Test2", true)
 --		WindowSetParent("Test2", "WarBoard_Menu")
 --		WindowSetDimensions("Test2", 100, 30)
 		
 --		local texture, x, y = GetIconData(00854)
 --     DynamicImageSetTexture("Test2Icon", texture, x, y)
 --     DynamicImageSetTextureScale("Test2Icon", 0.3)
      
 --     WindowAddAnchor("Test2", "left", "WarBoard_Menu", "left", 100, 0)
  --    
 -- 		CreateWindowFromTemplate( "Test3", "WarBoard_MenuElement", "Root" )
 -- 		WindowSetShowing("Test3", true)
 -- 		WindowSetParent("Test3", "WarBoard_Menu")
 -- 		WindowSetDimensions("Test3", 100, 30)
  		
 -- 		local texture, x, y = GetIconData(00308)
 --     DynamicImageSetTexture("Test3Icon", texture, x, y)
 --     DynamicImageSetTextureScale("Test3Icon", 0.5)
      
 --     WindowAddAnchor("Test3", "left", "WarBoard_Menu", "left", 150, 0)
 --     
      
      --	Menu.Abilities:SetIcon(00854);
		--	Menu.Abilities:SetIconScale(0.32);
--	Menu.Abilities:SetIcon(00308);
		
		--	Menu.Abilities = Menu.Waaagh:NewElement("Abilities", spacing, L"", white)
		--	Menu.Abilities:SetIcon(00064);
		--	Menu.Abilities:SetIconScale(0.7);
		--	Menu.Abilities:SetIcon(00854);
		--	Menu.Abilities:SetIconScale(0.32);
		--	Menu.Abilities:SetIcon(00308);
		--	Menu.Abilities:SetIconScale(0.34);
			--WindowRegisterCoreEventHandler(Menu.Abilities.name, "OnLButtonUp", "WaaaghBar.Menu.OnAbilitiesLButton")
			--WindowRegisterCoreEventHandler(Menu.Abilities.name, "OnMouseOver", "WaaaghBar.Menu.OnAbilitiesMouseOver")
		--WarBoard_Menu.BuildElement("Backpack", "Bag", spacing)
	end
end

function WarBoard_Menu.DestroyElements()
	for i,v in ipairs(WarBoard_Menu_ElementTable) do
		DestroyWindow(v.name)
	end
end

function WarBoard_Menu.BuildElement(name, coreName, xOffSet)
	if debugEnabled then
	d( "BuildElement: "..name.." "..coreName)
	end
	CreateWindowFromTemplate( name, "WarBoard_MenuElement", "Root" )
	WindowSetShowing(name, true)
	WindowSetParent(name, "WarBoard_Menu")
	WindowSetDimensions(name, 30, 30)
	DynamicImageSetTexture(name.."Icon", "EA_Texture_Menu01", 0, 0)
	DynamicImageSetTextureSlice(name.."Icon", coreName.."-Button")
	DynamicImageSetTextureScale(name.."Icon", 0.5)
	WindowRegisterCoreEventHandler(name, "OnMouseOver", "WarBoard_Menu.OnMouseOver")
	WindowRegisterCoreEventHandler(name, "OnMouseOverEnd", "WarBoard_Menu.OnMouseOverEnd")
	WindowRegisterCoreEventHandler(name, "OnLButtonUp", "WarBoard_Menu.OnLButtonUp")
	WindowAddAnchor(name, "left", "WarBoard_Menu", "left", xOffSet, 0)
end

function WarBoard_Menu.OnMouseOver()
	--d("MouseOver hit")
	--d("MouseOver: "..SystemData.ActiveWindow.name)
	
	for k, element in ipairs( WarBoard_Menu_ElementTable ) do
		if (element.name == SystemData.ActiveWindow.name) then
			createTooltip(towstring(element.friendlytext))
			if (element.highlighticon ~= nil) then
				DynamicImageSetTextureSlice(element.name.."Icon", element.highlighticon)
			else
				DynamicImageSetTextureSlice(element.name.."Icon", element.template.."-Button-Highlighted")
			end
			DynamicImageSetTextureScale(element.name.."Icon", 0.42)
			break
		end
		--d("k: "..k.." Name: "..v.name.." Template: "..v.template.." OpeningWindow: "..v.openingwindow.." XOffSet: "..xOffSet)
		--WarBoard_Menu.BuildElement(v.name, v.template, xOffSet+spacing)
	end	
	--createTooltip(name)
	--DynamicImageSetTextureSlice("AbilitiesIcon", "Spellbook-Button-Highlighted")
	--DynamicImageSetTextureScale("AbilitiesIcon", 0.42)
end

function WarBoard_Menu.OnMouseOverEnd()
	--d("MouseOverEND hit")
	--d("MouseOverEND: "..SystemData.ActiveWindow.name)
	--d("MOUSEEND: "..flags)
	
	for k, element in ipairs( WarBoard_Menu_ElementTable ) do
		if (element.name == SystemData.ActiveWindow.name) then
			DynamicImageSetTextureSlice(element.name.."Icon", element.template.."-Button")
			DynamicImageSetTextureScale(element.name.."Icon", 0.5)
			break
		end
		--d("k: "..k.." Name: "..v.name.." Template: "..v.template.." OpeningWindow: "..v.openingwindow.." XOffSet: "..xOffSet)
		--WarBoard_Menu.BuildElement(v.name, v.template, xOffSet+spacing)
	end	
	--]]
	--DynamicImageSetTextureSlice("AbilitiesIcon", "Spellbook-Button")
	--DynamicImageSetTextureScale("AbilitiesIcon", 0.5)
end

function WarBoard_Menu.OnLButtonUp()
	for k, element in ipairs( WarBoard_Menu_ElementTable ) do
		if (element.name == SystemData.ActiveWindow.name) then
			WindowSetShowing(element.openingwindow, not WindowGetShowing(element.openingwindow))
			if (element.name == "CustomizeInterface") then
			    SettingsWindowTabbed.SelectTab(SettingsWindowTabbed.TABS_INTERFACE)
			end
			break
		end
		--d("k: "..k.." Name: "..v.name.." Template: "..v.template.." OpeningWindow: "..v.openingwindow.." XOffSet: "..xOffSet)
		--WarBoard_Menu.BuildElement(v.name, v.template, xOffSet+spacing)
	end	
end

function createTooltip(text)
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil )
	Tooltips.SetTooltipText(1, 1, text)
	Tooltips.Finalize()
	Tooltips.AnchorTooltip( WarBoard.GetModToolTipAnchor("WarBoard_Menu") )
end


----------------------------------------------------------------
-- Layout Mode Functions, argument is the name of the window.
----------------------------------------------------------------
function WarBoard_Menu.OnDisable()
	WarBoard.DisableMod("WarBoard_Menu")
end

function WarBoard_Menu.MoveRight()
	WarBoard.MoveModRight("WarBoard_Menu")
end

function WarBoard_Menu.MoveLeft()
	WarBoard.MoveModLeft("WarBoard_Menu")
end
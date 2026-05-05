GMT2 = {}
--(Git Management Tools)
local version = "0.7g"
local PlayerName = wstring.sub( GameData.Player.name,1,-3 )
local C_GETLOG = false

local LISTEN_BEGIN = 1
local LISTEN_FINISH = 2
GMT2.StateTimer = 0.6

local RegisterEventHandler = RegisterEventHandler
local TextLogAddEntry      = TextLogAddEntry
local TimedStateMachine    = TimedStateMachine
local wstring              = wstring

function GMT2.OnInitialize()
GMT2.GetLog_Wnd = {}
TextLogAddEntry("Chat", 0, L"<icon00057> GMT2 "..towstring(version)..L" Loaded.")

--Menu hooks
GMT2.ShowMenuHook	= PlayerMenuWindow.ShowMenu
PlayerMenuWindow.ShowMenu 	= GMT2.ShowMenu

GMT2.OnRButtonUpProcessedHook = PlayerMenuWindow.OnRButtonUpProcessed
PlayerMenuWindow.OnRButtonUpProcessed 	= GMT2.FriendlyMenu

--Tooltip Hooks
GMT2.original_Tooltips_CreateItemTooltip = Tooltips.CreateItemTooltip
GMT2.original_Tooltips_CreateAbilityTooltip = Tooltips.CreateAbilityTooltip

GMT2.origOnKeyEnter = EA_ChatWindow.OnKeyEnter
EA_ChatWindow.OnKeyEnter = GMT2.ChatHookHandler
	
	
Tooltips.CreateItemTooltip = GMT2.Tooltips_CreateItemTooltip	
Tooltips.CreateAbilityTooltip = GMT2.Tooltips_CreateAbilityTooltip

GMT2.stateMachineName = "GMT2"
GMT2.state = {[LISTEN_BEGIN] = { handler=GMT2.ToggleListen,time=GMT2.StateTimer,nextState=LISTEN_FINISH } , [LISTEN_FINISH] = { handler=GMT2.ToggleListen,time=TimedStateMachine.TIMER_OFF,nextState=LISTEN_BEGIN, } , }
    RegisterEventHandler(SystemData.Events.LOADING_END,"GMT2.OnLoadingEnd")

GMT2.Cache_Name = nil

GMT2.Destinations = {"Altdorf-Blowhole","Altdorf-Market","Altdorf-Palace","Altdorf-Temple","Altdorf-WarQuarter","BlackCrag-DestroWarcamp","BlackCrag-NorthKeep","ButchersPass","Caledor","ChaosWastes-NorthKeep","ChaosWastes-SouthKeep","Dragonwake-DestroWarcamp",
					 "Dragonwake-MidKeep","Dragonwake-OrderWarcamp","Eataine","FellLanding","IC-Apex","IC-Arena","IC-Citadel","IC-Monolith","IC-Undercroft","KadrinValley-NorthKeep","KadrinValley-SouthKeep","Praag-NorthKeep","Praag-SouthKeep","Reikland-NorthKeep",
					 "Reikland-SouthKeep","ReikWald","ShinigWay","Stonewatch","TheMaw","ThunderMountain-DestroWarcamp","ThunderMountain-OrderWarcamp"}
					 

	GMT2.SafeZones = {{id=101,x=15595,y=51874,z=7020,name=L"<icon22731>Order Start Area (Nordland CH 1)"},
	{id=162,x=25516,y=34015,z=12600,name=L"<icon22731>Order City (Altdorf)"},
	{id=100,x=29423,y=11230,z=7900,name=L"<icon22665>Destro Start Area (Norsca CH 1)"},
	{id=161,x=30580,y=32900,z=16900,name=L"<icon22665>Destro City (Inevitable City)"}
	}					 
	
GMT2.Command = {checklog=0,getchar=0,ability=0,getstats=0,info=0,findip=0,findoffip=0}
GMT2.CheckLogs = {}
GMT2.SearchName = ""
GMT2.Searching = false
GMT2.Map.OnInitialize()
GM_Ticket.init()
end

function GMT2:RegisterSelfEvents()
WindowRegisterEventHandler ("TargetWindow", SystemData.Events.R_BUTTON_UP_PROCESSED, "GMT2.EnemyMenu")
	if Pure == true then
		WindowRegisterEventHandler ("PureTargetUnitFrameHostile", SystemData.Events.R_BUTTON_UP_PROCESSED, "GMT2.EnemyMenu")
	end
RegisterEventHandler(TextLogGetUpdateEventId("System"), "GMT2.OnSystemLogUpdated")
RegisterEventHandler(TextLogGetUpdateEventId("Chat"), "GMT2.OnChatLogUpdated")
RegisterEventHandler(SystemData.Events.CHAT_TEXT_ARRIVED, "GMT2.TextArrived")

LibSlash.RegisterSlashCmd("getstats", GMT2.GetStats.SlashCommand)
LibSlash.RegisterSlashCmd("findip", function(input)  GMT2.FindIp.SlashCommand(input)end)
LibSlash.RegisterSlashCmd("findofflineip", function(input)  GMT2.FindOffIp.SlashCommand(input)end)

LibSlash.RegisterSlashCmd("listbuffs", GMT2.ListBuffs.SlashCommand)
end

function GMT2:OnLoadingEnd()
  --register events
  GMT2:RegisterSelfEvents()
  UnregisterEventHandler(SystemData.Events.LOADING_END,"GMT2.OnLoadingEnd")
end

function GMT2.ChatHookHandler(...)
    local input = EA_TextEntryGroupEntryBoxTextInput.Text
	if input:find(L"]checklog") then 
	local Input_Name = input:match(L"%.checklog (.+)")
				GMT2.SearchName = tostring(Input_Name)
				GMT2.Command["checklog"] = 1 --start the Checklog chat search							
				TextLogAddEntry("Chat", 0, L"GMT2: CheckLog: "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Input_Name),towstring(Input_Name), {175,175,175}, {} )))
	elseif input:find(L"]findip") then 
				GMT2.Command["findip"] = 1
				GMT2.StartMachine()
	elseif input:find(L"]findofflineip") then 
				GMT2.Command["findoffip"] = 1
				GMT2.StartMachine()				
	end
	
	GMT2.origOnKeyEnter(...)
end

function GMT2.StartMachine()
	local stateMachine = TimedStateMachine.New( GMT2.state,LISTEN_BEGIN)
	TimedStateMachineManager.AddStateMachine( GMT2.stateMachineName, stateMachine )
end

function GMT2.ToggleListen()
--toggle the searcing
GMT2.Searching = not GMT2.Searching

	if GMT2.Searching == false then --turn off search command
		GMT2.Command["ability"] = 0
		GMT2.Command["getstats"] = 0		
		GMT2.Command["info"] = 0		
		GMT2.Command["findip"] = 0	
		GMT2.Command["findoffip"] = 0			
			if GMT2.AbilityList ~= nil then 
			GMT2.ListBuffs.Input(GMT2.AbilityList,GMT2.AbilityList.IsNPC)
			GMT2.AbilityList = nil 
			end --if Ability list then send it to it's script

			if GMT2.StatsList ~= nil then 
			--d(GMT2.StatsList.IsNPC)
			GMT2.GetStats.Input(GMT2.StatsList,GMT2.StatsList.IsNPC)
			GMT2.StatsList = nil 
			end --if StatsList list then send it to it's script

			if GMT2.IPSearch  ~= nil then 
			--d(GMT2.StatsList.IsNPC)
			GMT2.FindIp.Input(GMT2.IPSearch)
			GMT2.IPSearch = nil 
			end --if StatsList list then send it to it's script

			if GMT2.OffIPSearch ~= nil then 
			--d(GMT2.StatsList.IsNPC)
			GMT2.FindOffIp.Input(GMT2.OffIPSearch)
			GMT2.OffIPSearch = nil 
			end --
			
	end
end

--Friendly Player rightclick Menu
function GMT2.FriendlyMenu()
if string.match(SystemData.MouseOverWindow.name,"FriendlyTargetWindow") or string.match(SystemData.MouseOverWindow.name,"PureTargetUnitFrameFriendly") then
	if (TargetInfo:UnitType( "selffriendlytarget" ) == SystemData.TargetObjectType.ALLY_PLAYER)   then
		PlayerMenuWindow.ShowMenu( TargetInfo:UnitName( "selffriendlytarget" ), TargetInfo:UnitEntityId( "selffriendlytarget" ) )
	end
	
	if TargetInfo:UnitType("selffriendlytarget") == 1 then
		PlayerMenuWindow.ShowMenu( PlayerName, GameData.Player.worldObjNum)
	end
end
end

--Enemy Player rightclick Menu
function GMT2.EnemyMenu()
	if WindowGetParent(SystemData.MouseOverWindow.name) == "TargetWindowStatus" or SystemData.MouseOverWindow.name == "PureTargetUnitFrameHostile" then
		if TargetInfo:UnitEntityId( "selfhostiletarget" ) ~= 0 then
			if TargetInfo:UnitType( "selfhostiletarget" ) == SystemData.TargetObjectType.ENEMY_PLAYER then
				local Target_Name = TargetInfo:UnitName ("selfhostiletarget")
				PlayerMenuWindow.curPlayer.name = towstring(Target_Name)
				EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name, EA_Window_ContextMenu.CONTEXT_MENU_1, GetStringFormat( StringTables.Default.LABEL_PLAYER_MENU_TITLE, {towstring(Target_Name)} ) )
				EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_TALK ), PlayerMenuWindow.OnTalk, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )				
				GMT2.GMT2Menu(GMT2.FixString(Target_Name))
				EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_CANCEL ), PlayerMenuWindow.OnCancel, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )        
				EA_Window_ContextMenu.Finalize()
			end	
		end
	end		
end

--Friendly Player rightclick Menu
function GMT2.ShowMenu( playerName, playerObjNum, customItems)
	GMT2.ShowMenuHook( playerName, playerObjNum, customItems)
	local Target_Name = GMT2.FixString(playerName)
	GMT2.GMT2Menu(Target_Name)
end

--GMTools Menu
function GMT2.GMT2Menu(Target_Name)

	local function New_Menu(Target_Name)
		return function() GMT2.CreateMainContextMenu(Target_Name) end
	end		

	EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )
	EA_Window_ContextMenu.AddCascadingMenuItem( L"<icon42>GM-Tools..", New_Menu(Target_Name), false, 1 )
	EA_Window_ContextMenu.Finalize()
end

--Main menu
function GMT2.CreateMainContextMenu(Target_Name)
	--teleport sub menu function
	local function New_Menu(Target_Name)
		return function() GMT2.CreateTeleportContextMenu(Target_Name) end
	end		

	--Sanction sub menu function
	local function Sanction_Menu(Target_Name)
		return function() GMT2.CreateSanctionContextMenu(Target_Name) end
	end		

	--Instance sub menu function
	local function Instance_Menu(Target_Name)
		return function() GMT2.CreateInstanceContextMenu(Target_Name) end
	end		
	
	--Cache Name function
	local function Cache_Name(Target_Name)
		return function()
			GMT2.Cache_Name = (Target_Name) 
			TextLogAddEntry("Chat", 0, L"GMT2: Set Cache Name: "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))
		end
	end			

	local function SendCommand(Command,Target_Name)
		return function()
			if Command == "checklog" then
				GMT2.SearchName = tostring(Target_Name)
				GMT2.Command[Command] = 1 --start the Checklog chat search			
				SendChatText(L"]csr "..towstring(Command)..L" "..towstring(Target_Name), ChatSettings.Channels[0].serverCmd)		
				TextLogAddEntry("Chat", 0, L"GMT2: CheckLog: "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))
				
			elseif Command == "getchar" then
				GMT2.SearchName = tostring(Target_Name)
				GMT2.Command[Command] = 1 --start the Checklog chat search			
				SendChatText(L"]csr "..towstring(Command)..L" "..towstring(Target_Name), ChatSettings.Channels[0].serverCmd)		
				TextLogAddEntry("Chat", 0, L"GMT2: GetChar: "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))	
				
			elseif Command == "info" then
				GMT2.SearchName = tostring(Target_Name)
				GMT2.Command[Command] = 1 --start the Ability list chat search
				GMT2.StartMachine()
				SendPlayerSearchRequest(towstring(Target_Name),L"",L"",{-1},1,40,false)
				SendChatText(L"]"..towstring(Command)..L" "..towstring(Target_Name), ChatSettings.Channels[0].serverCmd)		
				TextLogAddEntry("Chat", 0, L"GMT2: Info: "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))				

			elseif Command == "ability" then
				GMT2.SearchName = tostring(Target_Name)
				GMT2.Command[Command] = 1 --start the Ability list chat search
				GMT2.AbilityList = {index=1,table={},IsNPC = false}
				GMT2.StartMachine()
				SendChatText(L"]"..towstring(Command)..L" list "..towstring(Target_Name), ChatSettings.Channels[0].serverCmd)		
				TextLogAddEntry("Chat", 0, L"GMT2: ListBuff: "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))						
		
			elseif Command == "getstats" then
				GMT2.SearchName = tostring(Target_Name)
				GMT2.Command[Command] = 1 --start the Ability list chat search
				GMT2.StatsList = {index=1,IsNPC = false,table={}}
				GMT2.StartMachine()
				SendChatText(L"]"..towstring(Command)..L" "..towstring(Target_Name), ChatSettings.Channels[0].serverCmd)		
				TextLogAddEntry("Chat", 0, L"GMT2: Getstats: "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))						
			
			elseif Command == "getinventory" then
				GMT2.SearchName = tostring(Target_Name)
				SendChatText(L"]player inventory "..towstring(Target_Name), ChatSettings.Channels[0].serverCmd)		
				TextLogAddEntry("Chat", 0, L"GMT2: GetInventory: "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))						
												
			end			
		end
	end		

	EA_Window_ContextMenu.CreateContextMenu( "GM-ToolsMenu", 2, L"<icon42>GM-Tools: "..towstring(Target_Name))
		--teleport sub menu
	EA_Window_ContextMenu.AddCascadingMenuItem( L"<icon2433>Teleports..", New_Menu(Target_Name), false, 2 )
		--Sanction sub menu
	EA_Window_ContextMenu.AddCascadingMenuItem( L"<icon30457>Sanctions..", Sanction_Menu(Target_Name), false, 2 )	
		--Instance sub menu
	EA_Window_ContextMenu.AddCascadingMenuItem( L"<icon0797>Sc/Instance..", Instance_Menu(Target_Name), false, 2 )
	EA_Window_ContextMenu.AddMenuItem( L"CheckLog",SendCommand("checklog",Target_Name), false, true,2 )
	EA_Window_ContextMenu.AddMenuItem( L"GetChar",SendCommand("getchar",Target_Name), false, true,2 )  
	--Checks for valid targets (prio Enemy player target)
	local ValidTarget_Name = (TargetInfo:UnitType( "selfhostiletarget" ) == SystemData.TargetObjectType.ENEMY_PLAYER and GMT2.FixString(TargetInfo:UnitName( "selfhostiletarget" )) == Target_Name) or (TargetInfo:UnitType( "selfhostiletarget" ) ~= SystemData.TargetObjectType.ENEMY_PLAYER and (GMT2.FixString(TargetInfo:UnitName( "selffriendlytarget" )) == Target_Name or GMT2.FixString(TargetInfo:UnitName( "selffriendlytarget" )) == Target_Name))
	EA_Window_ContextMenu.AddMenuItem( L"Info",SendCommand("info",Target_Name),false, true,2 ) 	   	
	EA_Window_ContextMenu.AddMenuItem( L"ListBuff",SendCommand("ability",Target_Name), not ValidTarget_Name, true,2 )   
	EA_Window_ContextMenu.AddMenuItem( L"GetStats",SendCommand("getstats",Target_Name), not ValidTarget_Name, true,2 ) 	
	EA_Window_ContextMenu.AddMenuItem( L"GetInventory",SendCommand("getinventory",Target_Name), false, true,2 ) 			
	EA_Window_ContextMenu.AddMenuItem( L"<icon23056>Cache Player Name", Cache_Name(Target_Name), GMT2.Cache_Name == Target_Name, true,2 )        			
	EA_Window_ContextMenu.AddMenuDivider( 2 )
	EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_CANCEL ), PlayerMenuWindow.OnCancel, false, true,2 )        			
	EA_Window_ContextMenu.Finalize( 2, nil )
end

--Teleport Menu
function GMT2.CreateTeleportContextMenu(Target_Name)
	local function New_Menu(Target_Name,arg,arg2)
		return function() GMT2.Teleport(Target_Name,arg,arg2) end 
	end	

	local function InputSelect2(SelectText)
		GMT2.Teleport(Target_Name,8,SelectText)
	end		
	
	local function InputSelect()
		DialogManager.MakeTextEntryDialog( L"Teleport Input",L"Teleport "..towstring(Target_Name)..L" to..",L"", InputSelect2, nil, 100, false,1)
	end	

	EA_Window_ContextMenu.CreateContextMenu( "Teleports", 3, L"<icon2433>Teleports")
		EA_Window_ContextMenu.AddMenuItem( L"<icon2433>"..towstring(Target_Name)..L" >> "..L"INPUT...",InputSelect, false, true, 3 )	
		
	if PlayerMenuWindow.curPlayer.name ~= PlayerName then
		
		EA_Window_ContextMenu.AddMenuItem( L"<icon2433>You >> "..towstring(Target_Name),New_Menu(Target_Name,1), false, true, 3 )
		EA_Window_ContextMenu.AddMenuItem( L"<icon2433>"..towstring(Target_Name)..L" >> You",New_Menu(Target_Name,2), false, true, 3 )

		if GMT2.Cache_Name ~= nil then			
			EA_Window_ContextMenu.AddMenuItem( L"<icon2433> "..towstring(Target_Name)..L" >> <icon23056>"..towstring(GMT2.Cache_Name),New_Menu(Target_Name,6), false, true, 3 )			
			EA_Window_ContextMenu.AddMenuItem( L"<icon2433> <icon23056>"..towstring(GMT2.Cache_Name)..L" >> "..towstring(Target_Name) ,New_Menu(Target_Name,7), false, true, 3 )						
		end

		EA_Window_ContextMenu.AddMenuDivider( 3 )

		EA_Window_ContextMenu.AddMenuItem( L"              Safe Location",nil, true, false, 3 )
		ButtonSetTextColor("EA_Window_ContextMenu3DefaultItem3", Button.ButtonState.DISABLED, 255, 255, 255)
		
		for k,v in pairs(GMT2.SafeZones) do
			EA_Window_ContextMenu.AddMenuItem( towstring(v.name),New_Menu(Target_Name,5,k), false, true, 3 )
		end					
		
		if GMT2.Map.Cache ~= nil then
			EA_Window_ContextMenu.AddMenuItem (L"<icon59>Teleport To Cached Location", New_Menu(Target_Name,4,{GMT2.Map.Cache.id,GMT2.Map.Cache.x,GMT2.Map.Cache.y,GMT2.Map.Cache.z}),false, true,3)	
		end
	else
		EA_Window_ContextMenu.AddMenuItem( L"              Destinations",nil, true, false, 3 )
		ButtonSetTextColor("EA_Window_ContextMenu3DefaultItem1", Button.ButtonState.DISABLED, 255, 255, 255)
		for k,v in pairs(GMT2.Destinations) do
			EA_Window_ContextMenu.AddMenuItem( L"<icon2433>"..towstring(v),New_Menu(Target_Name,3,k), false, true, 3 )
		end	
		EA_Window_ContextMenu.AddMenuDivider( 3 )
		EA_Window_ContextMenu.AddMenuItem( L"            Cached Teleport",nil, true, false, 3 )
			ButtonSetTextColor("EA_Window_ContextMenu3DefaultItem35", Button.ButtonState.DISABLED, 255, 255, 255)
		if GMT2.Cache_Name ~= nil then
			EA_Window_ContextMenu.AddMenuItem( L"<icon2433>You >> <icon23056>"..towstring(GMT2.Cache_Name),New_Menu(GMT2.Cache_Name,1), false, true, 3 )
			EA_Window_ContextMenu.AddMenuItem( L"<icon2433> <icon23056>"..towstring(GMT2.Cache_Name)..L" >> You",New_Menu(GMT2.Cache_Name,2), false, true, 3 )							
		end
		if GMT2.Map.Cache ~= nil then
			EA_Window_ContextMenu.AddMenuItem (L"<icon59>Teleport To Cached Location", New_Menu(Target_Name,4,{GMT2.Map.Cache.id,GMT2.Map.Cache.x,GMT2.Map.Cache.y,GMT2.Map.Cache.z}),false, true,3)	
		end
	end		
		EA_Window_ContextMenu.AddMenuDivider( 3 )		
		EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_CANCEL ), PlayerMenuWindow.OnCancel, false, true, 3 )        
	EA_Window_ContextMenu.Finalize( 3, nil )
end

--Teleport Function
function GMT2.Teleport(Target_Name,arg,arg2)
	local TargetName = towstring(Target_Name)
	local state = tonumber(arg)
	local destination = arg2

	if TargetName == nil then 
		TextLogAddEntry("Chat", 0, L"GMT2: Error in Teleport, No Target name") 
		return
	end
	if state == 1 then --you to target
		SendChatText(L"]teleport appear "..TargetName,ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]teleport appear "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))		
	elseif state == 2 then --target to you
		SendChatText(L"]teleport summon "..TargetName,ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]teleport summon "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))	
	elseif state == 3 then --you to pre defined destination
		SendChatText(L"]teleport destination "..towstring(GMT2.Destinations[destination]),ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]t destination "..towstring(GMT2.Destinations[destination]))	
	elseif state == 4 then --Set map destination		
		SendChatText(L"]teleport set "..towstring(Target_Name)..L" "..towstring(destination[1])..L" "..towstring(destination[2])..L" "..towstring(destination[3])..L" "..towstring(destination[4]), ChatSettings.Channels[0].serverCmd)		
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]teleport set "..towstring(towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))..L" "..towstring(destination[1])..L" "..towstring(destination[2])..L" "..towstring(destination[3])..L" "..towstring(destination[4]))
	elseif state == 5 then --Safe Location		
		SendChatText(L"]teleport set "..towstring(Target_Name)..L" "..towstring(GMT2.SafeZones[destination].id)..L" "..towstring(GMT2.SafeZones[destination].x)..L" "..towstring(GMT2.SafeZones[destination].y)..L" "..towstring(GMT2.SafeZones[destination].z), ChatSettings.Channels[0].serverCmd)		
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run][Safe Location]: ]teleport set "..towstring(towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))..L" "..towstring(GMT2.SafeZones[destination].id)..L" "..towstring(GMT2.SafeZones[destination].x)..L" "..towstring(GMT2.SafeZones[destination].y)..L" "..towstring(GMT2.SafeZones[destination].z))
	elseif state == 6 then --target to cache
		SendChatText(L"]teleport summonto "..TargetName..L" "..towstring(GMT2.Cache_Name),ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]teleport summonto "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} ))..L" "..towstring(CreateHyperLink(L"PLAYER:"..towstring(GMT2.Cache_Name),towstring(GMT2.Cache_Name), {175,175,175}, {} )))	
	elseif state == 7 then --cache to target
		SendChatText(L"]teleport summonto "..towstring(GMT2.Cache_Name)..L" "..TargetName,ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]teleport summonto "..towstring(CreateHyperLink(L"PLAYER:"..towstring(GMT2.Cache_Name),towstring(GMT2.Cache_Name), {175,175,175}, {} ))..L" "..towstring(CreateHyperLink(L"PLAYER:"..towstring(TargetName),towstring(TargetName), {175,175,175}, {} )))			
	elseif state == 8 then --target to select
		SendChatText(L"]teleport summonto "..TargetName..L" "..towstring(destination),ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]teleport summonto "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} ))..L" "..towstring(CreateHyperLink(L"PLAYER:"..towstring(destination),towstring(destination), {175,175,175}, {} )))	
	else
		TextLogAddEntry("Chat", 0, L"GMT2: Error in Teleport, No valid State")
		return
	end
end

--Sanctions Menu
function GMT2.CreateSanctionContextMenu(Target_Name)
	local function New_Menu(Target_Name,arg,arg2)
		return function() GMT2.Sanctions(Target_Name,arg,arg2) end
	end
	EA_Window_ContextMenu.CreateContextMenu( "Sanctions", 3, L"<icon30457>Sanctions")			
	EA_Window_ContextMenu.AddMenuItem( L"Add SC Quiter ("..towstring(Target_Name)..L")",New_Menu(Target_Name,5), false, true, 3 )		
	EA_Window_ContextMenu.AddMenuItem( L"Remove Quitter ("..towstring(Target_Name)..L")",New_Menu(Target_Name,1), false, true, 3 )
	EA_Window_ContextMenu.AddMenuItem( L"Allow Surname ("..towstring(Target_Name)..L")",New_Menu(Target_Name,2), false, true, 3 )	
	EA_Window_ContextMenu.AddMenuItem( L"No Surname ("..towstring(Target_Name)..L")",New_Menu(Target_Name,3), false, true, 3 )		
	EA_Window_ContextMenu.AddMenuItem( L"Add Note ("..towstring(Target_Name)..L")",New_Menu(Target_Name,4), false, true, 3 )
	EA_Window_ContextMenu.AddMenuItem( L"Sever ("..towstring(Target_Name)..L")",New_Menu(Target_Name,6), false, true, 3 )	
	EA_Window_ContextMenu.AddMenuDivider( 3 )		
	EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_CANCEL ), PlayerMenuWindow.OnCancel, false, true, 3 )        
	EA_Window_ContextMenu.Finalize( 3, nil )
end

--Sanctions Function
function GMT2.Sanctions(Target_Name,arg,arg2)
	local TargetName = towstring(Target_Name)
	local state = arg
	local ARGUMENT = arg2	
	local function Add_Note(Note_Text)
		SendChatText(L"]csr note "..TargetName..L" "..towstring(Note_Text),ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]csr note "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} ))..L" "..towstring(Note_Text))						
	end	
	local function Rank_Quit(TIME)
		SendChatText(L"]scenario addQuitter "..TargetName..L" "..towstring(TIME),ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]scenario addquitter "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} ))..L" "..towstring(TIME))						
	end	
	if TargetName == nil then 
		TextLogAddEntry("Chat", 0, L"GMT2: Error in Sanctions, No Target name") 
		return
	end
	if state == 1 then --Quitter remove
		SendChatText(L"]scenario removeQuitter "..TargetName,ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]scenario removequitter "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))		
	elseif state == 2 then --Allow Surname
		SendChatText(L"]allowsurname "..TargetName..L" Allowing Surname",ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]allowsurname "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} ))..L" Allowing Surname")		
	elseif state == 3 then --No Surname
		SendChatText(L"]nosurname "..TargetName..L" Remowing Surname",ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]nosurname "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} ))..L" Remowing Surname")		
	elseif state == 4 then --Add Note
			DialogManager.MakeTextEntryDialog( L"Add Note", L"Add a note to: "..towstring(TargetName), L"", Add_Note, nil, 1000, true)
	elseif state == 5 then --Ranked Quiter
			DialogManager.MakeTextEntryDialog( L"SC Quitter", L"Lockout from Scenarios (in sec) on: "..towstring(TargetName), L"600", Rank_Quit, nil, 20, false)			
	elseif state == 6 then --Sever
		SendChatText(L"]sever "..TargetName,ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]sever "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))		
	else
		TextLogAddEntry("Chat", 0, L"GMT2: Error in Sanctions, No valid State")
		return
	end
end

--Instance Menu
function GMT2.CreateInstanceContextMenu(Target_Name)
	local function New_Menu(Target_Name,arg,arg2)
		return function() GMT2.Instance(Target_Name,arg,arg2) end
	end	
	local function InputSelect2(SelectText)
		GMT2.Instance(Target_Name,3,SelectText)
	end		
	local function InputSelect()
		DialogManager.MakeTextEntryDialog( L"Instance add Player",L"Add player "..towstring(Target_Name)..L" to..",L"", InputSelect2, nil, 100, false,1)
	end	
	local function Rank_Quit2(TIME)
		SendChatText(L"]scenario setQueueQuitter "..Target_Name..L" "..towstring(TIME),ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]scenario setQueueQuitter "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} ))..L" "..towstring(TIME))						
	end	
	local function Rank_Quit()
		DialogManager.MakeTextEntryDialog( L"Rank Quiter", L"Lockout from ranked (in sec) on: "..towstring(Target_Name), L"600", Rank_Quit2, nil, 20, false)			
	end	
	EA_Window_ContextMenu.CreateContextMenu( "Sc/Instance", 3, L"<icon0797>Sc/Instance")	
	EA_Window_ContextMenu.AddMenuItem( L"Set Ranked Quiter ("..towstring(Target_Name)..L")",Rank_Quit, false, true, 3 )
	EA_Window_ContextMenu.AddMenuItem( L"Remove Quitter ("..towstring(Target_Name)..L")",New_Menu(Target_Name,1), false, true, 3 )
	EA_Window_ContextMenu.AddMenuItem( L"<icon0797>Add "..towstring(Target_Name)..L" to Your Instance",New_Menu(Target_Name,2), false, true, 3 )
	EA_Window_ContextMenu.AddMenuItem( L"<icon0797>Add "..towstring(Target_Name)..L" to Player Intance...",InputSelect, false, true, 3 )		
	EA_Window_ContextMenu.AddMenuDivider( 3 )		
	EA_Window_ContextMenu.AddMenuItem( GetString( StringTables.Default.LABEL_PLAYER_MENU_CANCEL ), PlayerMenuWindow.OnCancel, false, true, 3 )        
	EA_Window_ContextMenu.Finalize( 3, nil )
end

--Instance Function
function GMT2.Instance(Target_Name,arg,arg2)
	local TargetName = towstring(Target_Name)
	local state = arg
	local ARGUMENT = arg2
	if TargetName == nil then 
		TextLogAddEntry("Chat", 0, L"GMT2: Error in Sanctions, No Target name") 
		return
	end
	if state == 1 then --Quitter remove
		SendChatText(L"]scenario removequitter "..TargetName,ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]scenario removequitter "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))		
	elseif state == 2 then -- Instance addplayer to you
		SendChatText(L"]scenario addplayer "..TargetName,ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]scenario addplayer "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))	
	elseif state == 3 then --Instance addplayer to Input
		SendChatText(L"]scenario addplayer "..TargetName..L" "..towstring(ARGUMENT),ChatSettings.Channels[0].serverCmd)
		TextLogAddEntry("Chat", 0, L"GMT2: [Command run]: ]scenario addplayer "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} ))..L" "..towstring(CreateHyperLink(L"PLAYER:"..towstring(ARGUMENT),towstring(ARGUMENT), {175,175,175}, {} )))		
	else
		TextLogAddEntry("Chat", 0, L"GMT2: Error in Sanctions, No valid State")
		return
	end
end		

function GMT2.OnSystemLogUpdated(updateType, filterType)
	if( updateType == SystemData.TextLogUpdate.ADDED ) then 
		local _, filterId, text = TextLogGetEntry( "System", TextLogGetNumEntries("System") - 1 ) 		
			--GETLOG, Sets up and grabs the Checklog
			if text:find(L"Sanction") and GMT2.Command["checklog"] == 0 then GMT2.Command["checklog"] = 1 end
			if GMT2.Command["checklog"] > 0 then
				if text:find(L"======") then
					if GMT2.Command["checklog"] == 1 then
						GMT2.CheckLogs[GMT2.SearchName] = {}
					elseif GMT2.Command["checklog"] > 2 then
						GMT2.GetLog(GMT2.CheckLogs[GMT2.SearchName]) --pass the tables on to another Script
						GMT2.Command["checklog"] = 0
						GMT2.SearchName = ""
						return
					end
				end
			if (GMT2.SearchName ~= nil) and (GMT2.Command["checklog"] ~= nil) and (GMT2.CheckLogs ~= nil) then	
				GMT2.CheckLogs[GMT2.SearchName][GMT2.Command["checklog"]] = text
				GMT2.Command["checklog"] = GMT2.Command["checklog"] +1	
			end
		end			
			--FINDIP, Sets up and grabs the IP range
			if text:find(L"IP matches for") and GMT2.Command["findip"] == 0 then GMT2.Command["findip"] = 1 end
			if GMT2.Command["findip"] > 0 then				
					if GMT2.Command["findip"] == 1 then
						GMT2.IPSearch = {}
					end				
			if (GMT2.Command["findip"] ~= nil) and (GMT2.IPSearch ~= nil) then	
				GMT2.IPSearch[GMT2.Command["findip"]] = text
				GMT2.Command["findip"] = GMT2.Command["findip"] +1	
			end
		end				
				--GETCHAR
		if text:find(L"Player '") then
			GMT2.GetChar.Input(text)
		end	
	end
end

function GMT2.OnChatLogUpdated(updateType, filterType)
	if( updateType == SystemData.TextLogUpdate.ADDED ) then 	
	if filterType == SystemData.ChatLogFilters.CHANNEL_9 then	
		local _, _, Blarp =  TextLogGetEntry( "Chat", TextLogGetNumEntries("Chat") - 1 )
		if Blarp:find(L"INVENTORY:") then
			GMT2.GetInventory.List(Blarp)
		end
	end	
	end
end

function GMT2.TextArrived()
if GMT2.Searching == true then 
	if (  GameData.ChatData.type == 3) then
	local Message = GameData.ChatData.text	
				--Buff List
				if GMT2.Command["ability"] == 1 then--start the Checklog chat search					
					GMT2.AbilityList.table[GMT2.AbilityList.index] = Message
					GMT2.AbilityList.index = GMT2.AbilityList.index+1
				end
	elseif GameData.ChatData.type == SystemData.ChatLogFilters.EMOTE then
	local Message =	GameData.ChatData.text 
					if GMT2.Command["info"] == 1 then--start the Getstats chat search
						GMT2.Info.Input(GMT2.SearchName,GameData.ChatData.text)
					end	
	elseif (  GameData.ChatData.type == SystemData.ChatLogFilters.TELL_RECEIVE) then
	local Message = GameData.ChatData.text	
				if GMT2.Command["getstats"] == 1 then--start the Getstats chat search	
					GMT2.StatsList.table[GMT2.StatsList.index] = Message
					GMT2.StatsList.index = GMT2.StatsList.index+1						
				end
	end
end
end

--Removes the hidden ^M,^F from charnames
function GMT2.FixString (str)
	if (str == nil) then return nil end
	local str = str
	local pos = str:find (L"^", 1, true)
	if (pos) then str = str:sub (1, pos - 1) end	
	return str
end

--Selectable texts (text to editbox selection)
function GMT2.EditBox(something)
	local ContextID = WindowGetId( SystemData.ActiveWindow.name )
	local WinParent = tostring(WindowGetParent(SystemData.MouseOverWindow.name))
	local WindowName = tostring(SystemData.MouseOverWindow.name)
	local ActiveWinParent = tostring(WindowGetParent(SystemData.ActiveWindow.name))
	if ContextID == 51 then
		local Parrents =  tostring(WindowGetParent(ActiveWinParent))
		if WindowGetShowing(WindowName) == false or something == nil then
		
			for k,v in ipairs(GMT2.GetLog_Wnd) do
				if DoesWindowExist(Parrents..v) then 
					WindowSetShowing(Parrents..v.."EditBox",false)
					WindowSetShowing(Parrents..v.."Text",true) 
				end
				
			end
		end
	elseif ContextID == 221 or ContextID == 222 then
		local Parrents = ""
		if ContextID == 221 then Parrents = WindowName
		elseif ContextID == 222 then Parrents = WinParent end
				for k,v in ipairs(GMT2.GetLog_Wnd) do
				if DoesWindowExist(Parrents..v) then 
					WindowSetShowing(Parrents..v.."EditBox",false)
					WindowSetShowing(Parrents..v.."Text",true) 
				end				
			end
	else
		local Parrents =  tostring(WindowGetParent(WinParent))
			for k,v in ipairs(GMT2.GetLog_Wnd) do
				if DoesWindowExist(Parrents..v) then 
					WindowSetShowing(Parrents..v.."EditBox",false)
					WindowSetShowing(Parrents..v.."Text",true) 
				end				
			end	
			if DoesWindowExist(WinParent.."EditBox") then
				TextEditBoxSetText(WinParent.."EditBox",towstring(LabelGetText(WinParent.."Text")))	
				WindowSetShowing(WinParent.."EditBox",not WindowGetShowing(WinParent.."EditBox"))
				WindowSetShowing(WinParent.."Text",not WindowGetShowing(WinParent.."Text"))
				WindowAssignFocus(WinParent.."EditBox",true)
			end
	end	
end

-- Close ONLY the parent window of the clicked control
function GMT2.DestroyWindow()
  -- prefer active (the close button), fall back to mouseover
  local w = SystemData.ActiveWindow.name
  if (not w or w=="") then w = SystemData.MouseOverWindow.name end
  if (not w or w=="" or not DoesWindowExist(w)) then return end

  -- your close button sits directly under the window you want to kill
  local top = WindowGetParent(w)
  if (not top or top=="" or not DoesWindowExist(top)) then return end

  -- optional: make sure we only close our GetLog window(s)
  -- if not string.find(top, "GetLogWindow_", 1, true) then return end

  -- drop any focus to avoid deferred-destroy
  local active = SystemData.ActiveWindow.name
  if active and active~="" and DoesWindowExist(active) then
    WindowAssignFocus(active, false)
  end
  if DoesWindowExist(top.."EditBox") then
    WindowAssignFocus(top.."EditBox", false)
  end

  WindowSetShowing(top, false)
  DestroyWindow(top)
end

--Item Tooltips
function GMT2.Tooltips_CreateItemTooltip(itemData, mouseoverWindow, anchor, disableComparison, extraText, extraTextColor, ignoreBroken)
	local ext = L"uniqueID: " .. itemData.uniqueID .. L"<br>itemID: " .. itemData.id.. L"<br>Icon: " .. itemData.iconNum
	if (extraText) then
		extraText = extraText .. L"<br>" .. ext
	else
		extraText = ext	
	end
	return GMT2.original_Tooltips_CreateItemTooltip(itemData, mouseoverWindow, anchor, disableComparison, extraText, extraTextColor, ignoreBroken)
end	

--Ability Tooltips
function GMT2.Tooltips_CreateAbilityTooltip( abilityData, mouseoverWindow, anchor, extraText, extraTextColor)
	local ext = L"AbilityID: " .. abilityData.id .. L" Icon: " .. abilityData.iconNum
	if (extraText) then
		extraText = extraText .. L"<br>" .. ext
	else
		extraText = ext	
	end
	return GMT2.original_Tooltips_CreateAbilityTooltip( abilityData, mouseoverWindow, anchor, extraText, extraTextColor )
end	
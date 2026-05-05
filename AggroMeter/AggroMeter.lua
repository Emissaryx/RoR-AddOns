AggroMeter = {}
local Version = "1.4"
local PlayerName = wstring.sub(GameData.Player.name,1,-3)


local SocialColors = {
		["Friend"]=ChatSettings.Channels[10].defaultColor,
		["Guild"]=ChatSettings.Channels[8].defaultColor,
		["None"]=ChatSettings.Channels[7].defaultColor,
		["Ignore"]={r=255,g=25,b=25},
		["Warband"]=ChatSettings.Channels[14].defaultColor,
		["Party"]=ChatSettings.Channels[4].defaultColor
}


function AggroMeter.Initialize()
	ror_PacketHandling.Register("NPC_AGGRO:",AggroMeter.AggroUpdate)
	AggroMeter.Enabled = true
	CreateWindow("AggroMeter_Toggler", true)	
	CreateWindow("AggroSliders", false)


	AggroMeter.PlayersAggro = {}
	AggroMeter.AggroHolder = {}
	AggroMeter.MobID = {}
	AggroMeter.MobName = {}
	AggroMeter.MobRank	= {}
	AggroMeter.MobHealth	= {}
	AggroMeter.MaxAggro = {}
	AggroMeter.Timers = {}
	AggroMeter.Stacks = {}
	AggroMeter.CombatTime = {}	
	AggroMeter.Fader = {}
	AggroMeter.Listdata = {}
	AggroMeter.SelectedTab = 1
	
	AggroMeter.Color = {DefaultColor.YELLOW,DefaultColor.ORANGE,DefaultColor.RED}
	--AggroMeter.Unit = {L"(C)",L"(H)",L"(L)"}
	AggroMeter.Unit = {L"<icon29981>",L"<icon29981><icon29981>",L"<icon29981><icon29981><icon29981>"}

	if  AggroMeter.Settings == nil then AggroMeter.Settings = {} end
	if  AggroMeter.Settings.Style == nil then AggroMeter.Settings.Style = 1 end
	if  AggroMeter.Settings.ShowRank == nil then AggroMeter.Settings.ShowRank = {false,true,true} end
	if  AggroMeter.Settings.Players == nil then AggroMeter.Settings.Players = 6 end
	if  AggroMeter.Settings.List == nil then AggroMeter.Settings.List = {White={},Black={},Gray={}} end
		
	CreateWindow("AggroMeterGrayWindow", false)
	ButtonSetText("AggroMeterGrayWindowListTab", L"List")
	ButtonSetText("AggroMeterGrayWindowWhiteTab", L"Whitelist")
	ButtonSetText("AggroMeterGrayWindowBlackTab", L"Blacklist")
	ButtonSetPressedFlag( "AggroMeterGrayWindowListTab",true)		
	ButtonSetPressedFlag( "AggroMeterGrayWindowWhiteTab",false)			
	ButtonSetPressedFlag( "AggroMeterGrayWindowBlackTab",false)	
	LabelSetText("AggroMeterGrayWindowLabel",L"AggroMeter Priority List")
	LabelSetText("AggroSlidersText", L"Players")
	AggroMeter.Update()
end

function AggroMeter.Shutdown()

end


function AggroMeter.AggroUpdate(text)

local text = string.gsub(text,"NPC_AGGRO:","")
local AggroList = json.decode(text)

	if AggroMeter.Settings.Debug == true then d(AggroList) end

	local MobID = tostring(AggroList.oid)
	local MobRank = tostring(AggroList.rank)	
	local MobName = string.gsub(tostring(AggroList.name),"u0027","'")
	local MobHealth = tonumber(AggroList.healthPct)
	local TargetList = AggroList.targets
	local Targets = #TargetList

	local IsInLists = ""
		
		for k,v in pairs(AggroMeter.Settings.List) do
			for a,b in pairs(v) do
				if b.Name == towstring(MobName) then
					IsInLists = tostring(k)					
					break
				end		
			end
		end

		if IsInLists == "" then		
		if (#AggroMeter.Settings.List.Gray) >= 20 then
			table.remove (AggroMeter.Settings.List.Gray,1)
		end
			if MobName ~= "nil" then
				table.insert (AggroMeter.Settings.List.Gray,{Name=towstring(MobName),Rank=MobRank,RankN=towstring(AggroMeter.Unit[tonumber(MobRank)])})
				AggroMeter.Update()
			end
		end

if AggroMeter.Enabled == false then return end

if (AggroMeter.Settings.ShowRank[tonumber(MobRank)] == true or IsInLists == "White") and IsInLists ~= "Black" then
		
		if DoesWindowExist("AggroMeterWindow"..MobID) == false then
		CreateWindowFromTemplate("AggroMeterWindow"..MobID, "AggroMeterWindow", "Root")
			for i=1,6 do	
			
				local LabelW,LabelH = WindowGetDimensions("AggroMeterWindow"..MobID.."_AggroWindow"..i.."TimerBarText")			
				WindowSetDimensions("AggroMeterWindow"..MobID.."_AggroWindow"..i.."TimerBarText",100,LabelH)
				LabelSetText("AggroMeterWindow"..MobID.."_AggroWindow"..i.."Label",L"Aggro"..towstring(i))					
				DynamicImageSetTexture("AggroMeterWindow"..MobID.."_AggroWindow"..i.."Tactic","icon022709",0,0)		
				StatusBarSetMaximumValue("AggroMeterWindow"..MobID.."_AggroWindow"..i.."TimerBar", 100  )
				StatusBarSetForegroundTint( "AggroMeterWindow"..MobID.."_AggroWindow"..i.."TimerBar", DefaultColor.GREEN.r, DefaultColor.GREEN.g, DefaultColor.GREEN.b )
				StatusBarSetBackgroundTint( "AggroMeterWindow"..MobID.."_AggroWindow"..i.."TimerBar", DefaultColor.BLACK.r, DefaultColor.BLACK.g, DefaultColor.BLACK.b )	
				LabelSetText("AggroMeterWindow"..MobID.."_AggroWindow"..i.."TimerBarText",L"")	
			end	
			LabelSetText("AggroMeterWindow"..MobID.."NameLabel",L"MobName "..towstring(MobID))				
			StatusBarSetMaximumValue("AggroMeterWindow"..MobID.."Health", 100)
			AggroMeter.Stacks[MobID] = 1
			AggroMeter.CombatTime[MobID] = 0
		end
		
		AggroMeter.MobID[MobID] = MobID	
		AggroMeter.MobRank[MobID] = MobRank
		AggroMeter.MobName[MobID] = MobName
		AggroMeter.MobHealth[MobID] = MobHealth
		AggroMeter.PlayersAggro[MobID] = tonumber(Targets)
		AggroMeter.AggroHolder[MobID] = {}
		AggroMeter.Fader[MobID] = false
		local Players = 0
		if AggroMeter.PlayersAggro[MobID] < AggroMeter.Settings.Players then Players = AggroMeter.PlayersAggro[MobID] else Players = AggroMeter.Settings.Players end
		
		for i=1,6 do
			LabelSetText("AggroMeterWindow"..MobID.."_AggroWindow"..i.."Label",L"")
			WindowSetShowing("AggroMeterWindow"..MobID.."_AggroWindow"..i,false)			
		end

		AggroMeter.MaxAggro[MobID] = 0

		for i=1,(Players) do
			AggroMeter.AggroHolder[MobID][i] = {}
			AggroMeter.AggroHolder[MobID][i].name = tostring(TargetList[i].name)
			AggroMeter.AggroHolder[MobID][i].aggro = tonumber(TargetList[i].hatred)
			AggroMeter.AggroHolder[MobID][i].tactic = tonumber(TargetList[i].buffId)	
			AggroMeter.AggroHolder[MobID][i].career = tonumber(TargetList[i].career)				
			AggroMeter.MaxAggro[MobID] = AggroMeter.AggroHolder[MobID][1].aggro
		end

		for i=1,(Players) do
			LabelSetText("AggroMeterWindow"..MobID.."_AggroWindow"..i.."Label",towstring(AggroMeter.AggroHolder[MobID][i].name))	
			StatusBarSetForegroundTint( "AggroMeterWindow"..MobID.."_AggroWindow"..i.."TimerBar", 255*(((AggroMeter.AggroHolder[MobID][i].aggro/AggroMeter.MaxAggro[MobID])*100)/100), 255*(1-(((AggroMeter.AggroHolder[MobID][i].aggro/AggroMeter.MaxAggro[MobID])*100)/100)), 0)
			StatusBarSetCurrentValue("AggroMeterWindow"..MobID.."_AggroWindow"..i.."TimerBar", (AggroMeter.AggroHolder[MobID][i].aggro/AggroMeter.MaxAggro[MobID])*100 )
			WindowSetShowing("AggroMeterWindow"..MobID.."_AggroWindow"..i.."Border",wstring.sub(TargetInfo:UnitName("selffriendlytarget"),1,-3) == towstring(AggroMeter.AggroHolder[MobID][i].name))
				if towstring(AggroMeter.AggroHolder[MobID][i].name) == PlayerName then
						LabelSetTextColor("AggroMeterWindow"..MobID.."_AggroWindow"..i.."Label", 255, 215, 50)
				else
					social = "None"

		if GuildWindowTabRoster.IsPlayerInGuild(towstring(AggroMeter.AggroHolder[MobID][i].name)) == true then --check if guild
			social = "Guild"
		end
		
		if SocialWindowTabFriends.IsPlayerFriend(towstring(AggroMeter.AggroHolder[MobID][i].name)) == true then --check if friend
			social = "Friend"
		end

		if IsWarBandActive() and PartyUtils.IsPlayerInWarband(towstring(AggroMeter.AggroHolder[MobID][i].name)) then --check if wb
			social = "Warband"
		end


				for a=1,5 do	--check if party
					local member = PartyUtils.GetPartyMember(a)
					if( member ~= nil and member.name ~= nil and member.name ~= L"" )
					then
						if towstring(AggroMeter.AggroHolder[MobID][i].name) == member.name then 
							social = "Party"
							break						
						end

					end
				end

			

		if SocialWindowTabIgnore.IsPlayerIgnored(towstring(AggroMeter.AggroHolder[MobID][i].name)) == true then --check if Ignored
			social = "Ignore"
		end


						LabelSetTextColor("AggroMeterWindow"..MobID.."_AggroWindow"..i.."Label", SocialColors[social].r, SocialColors[social].g, SocialColors[social].b)
				end
			
				if AggroMeter.Settings.Style == 1 then
					if	AggroMeter.AggroHolder[MobID][i].aggro > 0 then
						LabelSetText("AggroMeterWindow"..MobID.."_AggroWindow"..i.."TimerBarText",wstring.format(L"%.01f",(AggroMeter.AggroHolder[MobID][i].aggro/AggroMeter.MaxAggro[MobID])*100)..L"%")
					else
						LabelSetText("AggroMeterWindow"..MobID.."_AggroWindow"..i.."TimerBarText",L"0%")
					end
				else
					LabelSetText("AggroMeterWindow"..MobID.."_AggroWindow"..i.."TimerBarText",towstring(AggroMeter.AggroHolder[MobID][i].aggro))
				end
		
			WindowSetShowing("AggroMeterWindow"..MobID.."_AggroWindow"..i,true)	
			WindowSetShowing("AggroMeterWindow"..MobID.."_AggroWindow"..i.."Tactic",AggroMeter.AggroHolder[MobID][i].tactic > 0)	
			WindowSetShowing("AggroMeterWindow"..MobID.."_AggroWindow"..i.."Timer",(LabelGetText("AggroMeterWindow"..MobID.."_AggroWindow"..i.."Label") ~= ""))
			
			local txtr, x, y, disabledTexture = GetIconData (Icons.GetCareerIconIDFromCareerLine(tonumber(AggroMeter.AggroHolder[MobID][i].career)))	

			CircleImageSetTexture("AggroMeterWindow"..MobID.."_AggroWindow"..i.."ButtonIcon",txtr, 16, 16)
				
						
		end
		
		local Unit = AggroMeter.Unit[tonumber(AggroMeter.MobRank[MobID])]
		LabelSetText("AggroMeterWindow"..MobID.."UnitLabel",Unit)
		LabelSetText("AggroMeterWindow"..MobID.."NameLabel",towstring(AggroMeter.MobName[MobID]))
		local Color = AggroMeter.Color[tonumber(AggroMeter.MobRank[MobID])]
		LabelSetTextColor("AggroMeterWindow"..MobID.."NameLabel",Color.r,Color.g,Color.b)		
		StatusBarSetForegroundTint("AggroMeterWindow"..MobID.."Health", Color.r*0.5,Color.g*0.5,Color.b*0.5 )
		StatusBarSetCurrentValue("AggroMeterWindow"..MobID.."Health", AggroMeter.MobHealth[MobID] )		
		AggroMeter.Timers[MobID] = 3
		WindowSetDimensions("AggroMeterWindow"..MobID,310,45+(30*Players))		
		local StackHeight = 33

		for  k,v in pairs(AggroMeter.Stacks) do
		local width,height = WindowGetDimensions("AggroMeterWindow"..k)
			WindowClearAnchors("AggroMeterWindow"..k)
			WindowAddAnchor("AggroMeterWindow"..k, "topright", "AggroMeter_Toggler", "topright",0,StackHeight)		
			StackHeight = StackHeight + (height+10)
		end	
	end
end


function AggroMeter.OnMouseOverStart()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)
	local WindowName = towstring(SystemData.MouseOverWindow.name)
	
	if WindowName:match(L"Timer") then
		local MobNumber = 	tostring(WindowName:match(L"AggroMeterWindow([%d.]+)."))
		local TimerNumber = tonumber(WindowName:match(L"_AggroWindow([^%.]+)Timer"))
		local Ttip = L""
			Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name,nil)
			Tooltips.SetTooltipText( 1, 1,towstring(AggroMeter.AggroHolder[tostring(MobNumber)][tonumber(TimerNumber)].name))
			Tooltips.SetTooltipColorDef( 1, 1, Tooltips.MAP_DESC_TEXT_COLOR )
			if AggroMeter.AggroHolder[tostring(MobNumber)][tonumber(TimerNumber)].aggro > 0 then
				Ttip =  wstring.format(L"%.01f",(AggroMeter.AggroHolder[tostring(MobNumber)][tonumber(TimerNumber)].aggro/AggroMeter.MaxAggro[tostring(MobNumber)])*100)..L"%"
			else
				Ttip = L"0%"
			end
			Tooltips.SetTooltipText( 1, 3, Ttip)
			Tooltips.SetTooltipText( 2, 1, L"Hatred: "..towstring(AggroMeter.AggroHolder[tostring(MobNumber)][TimerNumber].aggro)..L" / "..towstring(AggroMeter.MaxAggro[tostring(MobNumber)]))		
	elseif WindowName:match(L"Tactic") then
		local MobNumber = 	tostring(WindowName:match(L"AggroMeterWindow([%d.]+)."))
		local TacticNumber = tonumber(WindowName:match(L"_AggroWindow([^%.]+)Tactic"))
		Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name,nil)
		Tooltips.SetTooltipText( 1, 1,L"This player is using "..towstring(GetAbilityName(tonumber(AggroMeter.AggroHolder[tostring(MobNumber)][tonumber(TacticNumber)].tactic)))..L" Tactic")
		Tooltips.SetTooltipColorDef( 1, 1, Tooltips.MAP_DESC_TEXT_COLOR )
	elseif WindowName:match(L"AggroMeter_Toggler") then
			Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name,nil)
			Tooltips.SetTooltipText( 1, 1,L"AggroMeter")
			Tooltips.SetTooltipColorDef( 1, 1, Tooltips.MAP_DESC_TEXT_COLOR )
			Tooltips.SetTooltipText( 1, 3, L"Ver: "..towstring(Version))
			Tooltips.SetTooltipText( 2, 1, L"RightClick for options")					
	elseif WindowName:match(L"Button") then
		local MobNumber = 	tostring(WindowName:match(L"AggroMeterWindow([%d.]+)."))
		local CareerNumber = tonumber(WindowName:match(L"_AggroWindow([^%.]+)Button"))
		Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name,nil)
		Tooltips.SetTooltipText( 1, 1,towstring(GetCareerLine(AggroMeter.AggroHolder[tostring(MobNumber)][tonumber(CareerNumber)].career)))
		Tooltips.SetTooltipColorDef( 1, 1, Tooltips.MAP_DESC_TEXT_COLOR )		
	
	elseif WindowName:match(L"ListTab") then
		Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name,nil)
		Tooltips.SetTooltipText( 1, 1,L"List of the 20 latest engagement")
		Tooltips.SetTooltipColorDef( 1, 1, Tooltips.MAP_DESC_TEXT_COLOR )
	elseif WindowName:match(L"WhiteTab") then
		Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name,nil)
		Tooltips.SetTooltipText( 1, 1,L"These will ALWAYS show when engaged")
		Tooltips.SetTooltipColorDef( 1, 1, Tooltips.MAP_DESC_TEXT_COLOR )
	elseif WindowName:match(L"BlackTab") then
		Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name,nil)
		Tooltips.SetTooltipText( 1, 1,L"These will NEVER show when engaged")
		Tooltips.SetTooltipColorDef( 1, 1, Tooltips.MAP_DESC_TEXT_COLOR )		
	end
	
	Tooltips.Finalize()    
	Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP )
	
end

function AggroMeter.SelectChar()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)
	local WindowName = towstring(SystemData.MouseOverWindow.name)
	local MobNumber = 	tostring(WindowName:match(L"AggroMeterWindow([%d.]+)."))
	local LabelNumber = tonumber(WindowName:match(L"_AggroWindow([^%.]+)Label"))
		
	WindowSetGameActionData(tostring(WindowName),GameData.PlayerActions.SET_TARGET,0,towstring(AggroMeter.AggroHolder[tostring(MobNumber)][tonumber(LabelNumber)].name))	
end

function AggroMeter.TaskTip()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)
	local WindowName = towstring(SystemData.MouseOverWindow.name)
	local MobNumber = 	tostring(WindowName:match(L"AggroMeterWindow([%d.]+)."))
	local LabelNumber = tonumber(WindowName:match(L"_AggroWindow([^%.]+)Label"))
		
	PlayerMenuWindow.ShowMenu( towstring(AggroMeter.AggroHolder[tostring(MobNumber)][tonumber(LabelNumber)].name), 0)
	
end


function AggroMeter.OnTabRBU()

local function MakeCallBack( SelectedOption )
		    return function() AggroMeter.ToggleShow(SelectedOption) end
		end

	EA_Window_ContextMenu.CreateContextMenu( SystemData.MouseOverWindow.name, EA_Window_ContextMenu.CONTEXT_MENU_1,L"Options")
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )	
	if AggroMeter.Enabled == true then  
		EA_Window_ContextMenu.AddMenuItem( L"<icon00057> Enabled" , AggroMeter.ToggeEnable, false, true )
	else
		EA_Window_ContextMenu.AddMenuItem( L"<icon00058> Disabled" , AggroMeter.ToggeEnable, false, true )
	end

	if AggroMeter.Settings.ShowRank[1] == true then
		EA_Window_ContextMenu.AddMenuItem( L"     <icon00057> Champions" , MakeCallBack(1), not AggroMeter.Enabled, true )	
	else
		EA_Window_ContextMenu.AddMenuItem( L"     <icon00058> Champions" , MakeCallBack(1), not AggroMeter.Enabled, true )	
	end
	
	if AggroMeter.Settings.ShowRank[2] == true then
		EA_Window_ContextMenu.AddMenuItem( L"     <icon00057> Heroes" , MakeCallBack(2), not AggroMeter.Enabled, true )	
	else
		EA_Window_ContextMenu.AddMenuItem( L"     <icon00058> Heroes" , MakeCallBack(2), not AggroMeter.Enabled, true )	
	end	

	if AggroMeter.Settings.ShowRank[3] == true then
		EA_Window_ContextMenu.AddMenuItem( L"     <icon00057> Lords" , MakeCallBack(3), not AggroMeter.Enabled, true )	
	else
		EA_Window_ContextMenu.AddMenuItem( L"     <icon00058> Lords" , MakeCallBack(3), not AggroMeter.Enabled, true )	
	end
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )	
		
	EA_Window_ContextMenu.AddCascadingMenuItem( L"Players", AggroMeter.SelectPlayers, false,EA_Window_ContextMenu.CONTEXT_MENU_1 )
			
	EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )	
	if AggroMeter.Settings.Style == 1 then
		EA_Window_ContextMenu.AddMenuItem( L"Draw Numbers" , AggroMeter.ToggeBar, false, true )	
	else
		EA_Window_ContextMenu.AddMenuItem( L"Draw Percentage" , AggroMeter.ToggeBar, false, true )	
	end
	EA_Window_ContextMenu.AddMenuItem( L"Open Priority List.." , AggroMeter.Close, false, true )	
	
	EA_Window_ContextMenu.Finalize()	
end

function AggroMeter.SelectPlayers()
EA_Window_ContextMenu.CreateContextMenu( "AggroSlidersMenu", 2, L"" )

SliderBarSetCurrentPosition("AggroSlidersPlayers", (AggroMeter.Settings.Players-1)/5)
LabelSetText("AggroSlidersValue",towstring(AggroMeter.Settings.Players))

EA_Window_ContextMenu.AddUserDefinedMenuItem("AggroSliders",2)
EA_Window_ContextMenu.Finalize( 2, nil )
end

function AggroMeter.OnSetPlayers(idx)
local CalcNum = (tonumber(string.format("%.1f", idx))*5)+1
LabelSetText("AggroSlidersValue",towstring(CalcNum))
AggroMeter.Settings.Players = CalcNum


end



function AggroMeter.ToggeEnable()
	AggroMeter.Enabled = not AggroMeter.Enabled
	AggroMeter.OnTabRBU()	
end

function AggroMeter.ToggeBar()
	if AggroMeter.Settings.Style == 1 then 
		AggroMeter.Settings.Style = 2 
	else 
		AggroMeter.Settings.Style = 1 
	end
end

function AggroMeter.ToggleShow(SelectedOption)
	AggroMeter.Settings.ShowRank[tonumber(SelectedOption)] = not AggroMeter.Settings.ShowRank[tonumber(SelectedOption)]	
end

function AggroMeter.OnUpdate(timeElapsed)
	for  k,v in pairs(AggroMeter.Timers) do
		LabelSetText("AggroMeterWindow"..k.."CombatLabel",towstring(TimeUtils.FormatClock(AggroMeter.CombatTime[k])))	
			
		AggroMeter.Timers[k] = v - timeElapsed
		AggroMeter.CombatTime[k] = AggroMeter.CombatTime[k] + timeElapsed
		
		if (v <= 0.6) and (AggroMeter.Fader[k] == false) then
			AggroMeter.Fader[k] = true
		end

		if (v <= 0) then
			DestroyWindow( "AggroMeterWindow"..k )
			AggroMeter.Timers[k] = nil
			AggroMeter.Stacks[k] = nil	
			AggroMeter.CombatTime[k] = nil	

			AggroMeter.MobID[k] = nil	
			AggroMeter.MobRank[k] = nil
			AggroMeter.MobName[k] = nil
			AggroMeter.MobHealth[k] = nil
			AggroMeter.PlayersAggro[k] = nil
			AggroMeter.AggroHolder[k] = nil
			AggroMeter.MaxAggro[k] = nil

		AggroMeter.Fader[k] = nil			
		end
	end
end

function AggroMeter.Update()
	 AggroMeter.DisplayOrder = {} 
	 if AggroMeter.SelectedTab == 1 then
		AggroMeter.Listdata = AggroMeter.Settings.List.Gray
	 elseif AggroMeter.SelectedTab == 2 then
		AggroMeter.Listdata = AggroMeter.Settings.List.White
	 elseif AggroMeter.SelectedTab == 3 then
		AggroMeter.Listdata = AggroMeter.Settings.List.Black
	 end
	 
	 
	local shtcount = 1
	for k, v in pairs(  AggroMeter.Listdata) do

	table.insert(AggroMeter.DisplayOrder, shtcount)
		shtcount = shtcount+1
	end
	ListBoxSetDisplayOrder("AggroMeterGrayListBox", AggroMeter.DisplayOrder)
	return
end

function AggroMeter.Close()
  WindowSetShowing("AggroMeterGrayWindow",not WindowGetShowing("AggroMeterGrayWindow"))  
  AggroMeter.Update()
end

function AggroMeter.PickedListMenu()
if string.find(SystemData.MouseOverWindow.name,"ListBoxRow") then

local _index = ListBoxGetDataIndex("AggroMeterGrayListBox", WindowGetId(SystemData.MouseOverWindow.name))
local function MakeCallBack( SelectedOption,RowNumber )
		    return function() AggroMeter.AddList(SelectedOption,RowNumber) end
		end
	EA_Window_ContextMenu.CreateContextMenu( SystemData.MouseOverWindow.name, EA_Window_ContextMenu.CONTEXT_MENU_1,L"Options")
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )	
	if AggroMeter.SelectedTab == 1 then
		EA_Window_ContextMenu.AddMenuItem( L"Add to WhiteList" , MakeCallBack(1,_index), false, true )		
		EA_Window_ContextMenu.AddMenuItem( L"Add to BlackList" , MakeCallBack(2,_index), false, true )			
		EA_Window_ContextMenu.AddMenuItem( L"Remove from List" , MakeCallBack(7,_index), false, true )					
	elseif AggroMeter.SelectedTab == 2 then
		EA_Window_ContextMenu.AddMenuItem( L"Remove from Whitelist" , MakeCallBack(3,_index), false, true )		
		EA_Window_ContextMenu.AddMenuItem( L"Move to BlackList" , MakeCallBack(4,_index), false, true )			
	elseif AggroMeter.SelectedTab == 3 then
		EA_Window_ContextMenu.AddMenuItem( L"Remove from BlackList" , MakeCallBack(5,_index), false, true )		
		EA_Window_ContextMenu.AddMenuItem( L"Move to WhiteList" , MakeCallBack(6,_index), false, true )			
	end
	
	EA_Window_ContextMenu.Finalize()
end	
end

--moving stuff from Priority Lists
function AggroMeter.AddList(SelectedOption,RowNumber)
	if SelectedOption == 1 then
		table.insert (AggroMeter.Settings.List.White,AggroMeter.Settings.List.Gray[tonumber(RowNumber)])
		table.remove (AggroMeter.Settings.List.Gray,RowNumber)	
	elseif SelectedOption == 2 then
		table.insert (AggroMeter.Settings.List.Black,AggroMeter.Settings.List.Gray[tonumber(RowNumber)])
		table.remove (AggroMeter.Settings.List.Gray,RowNumber)	
	elseif SelectedOption == 3 then
		table.remove (AggroMeter.Settings.List.White,RowNumber)
	elseif SelectedOption == 4 then
		table.insert (AggroMeter.Settings.List.Black,AggroMeter.Settings.List.White[tonumber(RowNumber)])
		table.remove (AggroMeter.Settings.List.White,RowNumber)
	elseif SelectedOption == 5 then
		table.remove (AggroMeter.Settings.List.Black,RowNumber)	
	elseif SelectedOption == 6 then
		table.insert (AggroMeter.Settings.List.White,AggroMeter.Settings.List.Black[tonumber(RowNumber)])
		table.remove (AggroMeter.Settings.List.Black,RowNumber)
	elseif SelectedOption == 7 then		
		table.remove (AggroMeter.Settings.List.Gray,RowNumber)	
	end

AggroMeter.Update()
return
end

function AggroMeter.OnTabLBU()
	local tabNumber	= WindowGetId (SystemData.ActiveWindow.name)
	AggroMeter.SelectedTab = tabNumber
	ButtonSetPressedFlag( "AggroMeterGrayWindowListTab",tabNumber==1)		
	ButtonSetPressedFlag( "AggroMeterGrayWindowWhiteTab",tabNumber==2)
	ButtonSetPressedFlag( "AggroMeterGrayWindowBlackTab",tabNumber==3)	
	AggroMeter.Update()
end

function AggroMeter.OnClearUp()

		local function MakeCallBack()
		    return function() AggroMeter.Settings.List.Gray = {}; AggroMeter.Update() end
		end
	EA_Window_ContextMenu.CreateContextMenu( SystemData.MouseOverWindow.name, EA_Window_ContextMenu.CONTEXT_MENU_1,L"Options")
    EA_Window_ContextMenu.AddMenuDivider( EA_Window_ContextMenu.CONTEXT_MENU_1 )	

	EA_Window_ContextMenu.AddMenuItem( L"Clear List" , MakeCallBack(), false, true )		
	
	EA_Window_ContextMenu.Finalize()
	AggroMeter.Update()
end

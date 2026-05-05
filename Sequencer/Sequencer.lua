local version = "1.0.5"
local PlayerName
local ResetNames = {["combat"]=1,["Enemy Target Changed"]=2,["friendlytarget"]=3,["timer"]=4,["cooldown"]=5,[1]="combat",[2]="enemytarget",[3]="friendlytarget",[4]="timer",[5]="cooldown"}
local ResetNumbers = {["combat"]=1,["enemytarget"]=2,["friendlytarget"]=4,["timer"]=8,["cooldown"]=16,[1]="combat",[2]="enemytarget",[4]="friendlytarget",[8]="timer",[16]="cooldown"}
local TooltipStrings = {[1]=L"Leaving Combat",[2]=L"Enemy Target Changed",[3]=L"Friendly Target Changed",[4]=L"Seconds After Last Used",[5]=L"Skip Ability on Cooldown"}
local SelectedText,SelectedAbility = L"",0
local SEND_BEGIN = 1
local SEND_FINISH = 2
local StateTimer = 8
local isLoaded = false

Sequencer = {}
Sequencer.TempSeq = {}
Sequencer.PageBars = {[1]=1,[2]=2,[3]=3,[4]=4,[5]=5}

local _hookCreateAbilityTooltip
local _hookABRBD

function Sequencer.OnInitialize()
	PlayerName = wstring.sub(GameData.Player.name,1,-3)
	isLoaded = false
    RegisterEventHandler (SystemData.Events.PLAYER_HOT_BAR_UPDATED,                 "Sequencer.UpdateAbility")
    RegisterEventHandler (SystemData.Events.PLAYER_HOT_BAR_PAGE_UPDATED,            "Sequencer.UpdatePage")
	RegisterEventHandler(TextLogGetUpdateEventId("Chat"), 						"Sequencer.OnChatLogUpdated")
	RegisterEventHandler( SystemData.Events.ENTER_WORLD, "Sequencer.Loaded" )
	RegisterEventHandler( SystemData.Events.INTERFACE_RELOADED, "Sequencer.Loaded" )
	RegisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "Sequencer.Loaded")


	
	_hookCreateAbilityTooltip = Tooltips.CreateAbilityTooltip
	Tooltips.CreateAbilityTooltip = Sequencer.CreateAbilityTooltip
	
	_hookABRBD=ActionButton.OnRButtonDown
    ActionButton.OnRButtonDown=Sequencer.hookABRBD
	
	
	CreateWindow("Sequencer_Window",false)
	
	ButtonSetText("Sequencer_WindowClearButton",L"Remove")			
	ButtonSetText("Sequencer_WindowSaveButton",L"Save")			
	ButtonSetText("Sequencer_WindowLoadButton",L"Reload")			
	LabelSetText("Sequencer_WindowTitleBarText",L"Cast Sequencer")
	LabelSetText("Sequencer_WindowResetText",L"Sequence Reset:")
	LabelSetText("Sequencer_WindowCDText",L"<icon29957>")	
	
	
	Sequencer.stateMachineName = "Sequencer"
	Sequencer.state = {[SEND_BEGIN] = { handler=nil,time=StateTimer,nextState=SEND_FINISH } , [SEND_FINISH] = { handler=Sequencer.Send,time=TimedStateMachine.TIMER_OFF,nextState=SEND_BEGIN, } , }

end

function Sequencer.Loaded()
	Sequencer.StartMachine()	
end

function Sequencer.Send()
if isLoaded == false then
	SendChatText(L".castsequence list", L"")	
	--d(L"sending")
end	
end

function testflag(set, flag)
  return set % (2*flag) >= flag
  --[[
            LeaveCombat = 1,
            HostileTargetSwitched = 2,
            FriendlyTargetSwitched = 4,
            Timer = 8,
			Cooldown = 16
--]]
end

function Sequencer.StartMachine()
	local stateMachine = TimedStateMachine.New( Sequencer.state,SEND_BEGIN)
	TimedStateMachineManager.AddStateMachine( Sequencer.stateMachineName, stateMachine )
end

function Sequencer.CreateAbilityTooltip(abilityData, mouseoverWindow, anchor, extraText, extraTextColor)
	local SlotName = tostring(mouseoverWindow)
	if Sequencer.Tooltip ~= nil and Sequencer.Tooltip[SlotName] ~= nil then
		local SlotNumber = Sequencer.Tooltip[SlotName]
		local Cp_Page = math.ceil(SlotNumber/12)
		local SlotOnPage = SlotNumber-(12*(Cp_Page-1))
		
			local SQ_List = L"\n"
			for k,v in ipairs(Sequencer.Slots[tonumber(SlotNumber)]) do
				local Ability_Info = GetAbilityData(tonumber(v))		
				local FormatedIcon = L"<icon"..towstring(Ability_Info.iconNum)..L">"
				SQ_List = SQ_List..FormatedIcon..L"»"
			end
			SQ_List = wstring.sub(SQ_List,0,-2)
		extraText = extraText..L"\n+CastSequence ("..towstring(SlotNumber)..L") "..SQ_List
	end
	_hookCreateAbilityTooltip(abilityData, mouseoverWindow, anchor, extraText, extraTextColor)
end


function Sequencer.hookABRBD (btns, flags, x, y)
	local slot,_ = btns.m_HotBarSlot
	local FrameInfo = FrameManager:GetMouseOverWindow ()	

	if string.find(FrameInfo.m_Name,"EA_ActionBar")	then

	
		local CP,_ = ActionBars:BarAndButtonIdFromSlot(slot)
		--local Page = CP.m_PageSelectorWindow.m_DisplayPage
		--local Page = CP.m_PageSelectorWindow.m_LogicalPage
		local Page = Sequencer.PageBars[math.ceil(slot/12)]
		
		local SlotNumber = tonumber(slot)
		local OrgPage = CP.m_ActionPage
		--local SlotOnPage = SlotNumber-(12*(Page-1))
		local SlotOnPage = SlotNumber-((OrgPage-1)*12)
		local SlotToPage = ((Page-1)*12)+SlotOnPage
		
	
  if ((SystemData.Settings.Interface.lockActionBars == false) and (flags == SystemData.ButtonFlags.SHIFT)) then
            if Sequencer.Slots[SlotToPage] == nil then
				SetHotbarData (slot, 0, 0)  
			end
   else		
		
		--d(L"Button: "..towstring(SlotOnPage)..L" On Page: "..towstring(Page)..L". (Slot: "..towstring(SlotToPage)..L")")
		SelectedAbility = 0
					
		if FrameInfo.m_ActionId ~= 0 and FrameInfo.m_ActionType == 1 then
			SelectedAbility = FrameInfo.m_ActionId
		end
		
		
		SelectedText = L"Button: "..towstring(SlotOnPage)..L" On Page: "..towstring(Page)..L". (Slot: "..towstring(SlotToPage)..L")"
		
		if Sequencer.Slots ~= nil and Sequencer.Slots[SlotToPage] ~= nil then
			Sequencer.TempSeq.Slot =SlotToPage
			Sequencer.TempSeq.Button =SlotOnPage
		Sequencer.ReLoad()
		else
			Sequencer.Load(SlotToPage,SlotOnPage)
		end

		WindowSetShowing("Sequencer_Window",true)
		
		end
end
end

function Sequencer.ReLoad()
--if ButtonGetDisabledFlag("Sequencer_WindowLoadButton") == true then return end
	SendChatText(L".castsequence get "..towstring(Sequencer.TempSeq.Slot), L"")	
end

function Sequencer.OnChatLogUpdated(updateType, filterType)
	if updateType ~= SystemData.TextLogUpdate.ADDED then return end
	if filterType ~= SystemData.ChatLogFilters.CHANNEL_9 then return end
	local _, filterId, text = TextLogGetEntry( "Chat", TextLogGetNumEntries("Chat") - 1 )
	if text:find(L"CASTSEQUENCE_LIST") then
		Sequencer.UpdateList(text)
		isLoaded = true
	end
	if text:find(L"CASTSEQUENCE_GET_EMPTY") then
		return 
	end
	if text:find(L"CASTSEQUENCE_GET") then
		Sequencer.UpdateSingleList(text)
	end
	
end

function Sequencer.UpdateList(text)
	Sequencer.Slots = {}	
	Sequencer.BarInfo = {}
	
	local LIST_INFO
	local LIST_SPLIT_TEXT
	if text:find(L"CASTSEQUENCE_LIST") then
		LIST_INFO = text:match(L"CASTSEQUENCE_LIST=(.+)")
		LIST_SPLIT_TEXT = StringSplit(tostring(LIST_INFO), "|")	
	end
	if LIST_SPLIT_TEXT[1] ~= "nil" then
	--d(LIST_SPLIT_TEXT)
	--Slot; ResetType; Timer;Ability Id's...
	--ResetType: 1=enemytarget, 2=friendlytarget
		for k,v in pairs(LIST_SPLIT_TEXT) do
			local Split_List = StringSplit(tostring(v), ";")	
			local Split_Abilitys = StringSplit(tostring(Split_List[4]), ",")	
			local Num_Abilitys = #Split_Abilitys
			local index = (Split_List[1])
			Sequencer.Slots[tonumber(index)] = {}
			Sequencer.Slots[tonumber(index)].Reset = {}	
			local Resets = Split_List[2]
			--d(Split_List)
				for i=1,5 do
					--Sequencer.Slots[tonumber(index)].Reset[ResetNames[i]] = testflag(tonumber(Resets), i)
					Sequencer.Slots[tonumber(index)].Reset[ResetNames[i]] = testflag(tonumber(Resets),tonumber(ResetNumbers[ResetNames[i]]))					
				end
								
			Sequencer.Slots[tonumber(index)].Timer = Split_List[3]
			for i = 1,Num_Abilitys do
				Sequencer.Slots[tonumber(index)][i] = Split_Abilitys[i]
			end		
		end
	end	
	Sequencer.UpdateMacros()
end

function Sequencer.UpdateSingleList(text)
	local LIST_INFO
	if text:find(L"CASTSEQUENCE_GET") then
		LIST_INFO = text:match(L"CASTSEQUENCE_GET=(.+)")
	end
	--d(LIST_SPLIT_TEXT)
	--Slot; ResetType; Timer;Ability Id's...
	--ResetType: 1=enemytarget, 2=friendlytarget

			local Split_List = StringSplit(tostring(LIST_INFO), ";")	
			local Split_Abilitys = StringSplit(tostring(Split_List[4]), ",")	
			local Num_Abilitys = #Split_Abilitys
			local index = (Split_List[1])			
			Sequencer.Slots[tonumber(index)] = {}
			Sequencer.Slots[tonumber(index)].Reset = {}	
			local Resets = Split_List[2]
--			d(Split_List)
				for i=1,5 do
					--Sequencer.Slots[tonumber(index)].Reset[ResetNames[i]] = testflag(tonumber(Resets), i)
					Sequencer.Slots[tonumber(index)].Reset[ResetNames[i]] = testflag(tonumber(Resets),tonumber(ResetNumbers[ResetNames[i]]))					
				end
								
			Sequencer.Slots[tonumber(index)].Timer = Split_List[3]
			for i = 1,Num_Abilitys do
				Sequencer.Slots[tonumber(index)][i] = Split_Abilitys[i]
			end		
	--Sequencer.UpdateMacros()
	Sequencer.Load(tonumber(index))
end


function Sequencer.OnMouseOver()
	local WinName = SystemData.MouseOverWindow.name
	local IDNumber	= tonumber(WindowGetId (WinName))
	local TempSlot = Sequencer.TempSeq.Slot
	local TempButton = Sequencer.TempSeq.Button
	local TempReset = Sequencer.TempSeq.Reset
	local TempTimer = Sequencer.TempSeq.Timer	
	local anchor = { Point = "top", RelativeTo = SystemData.MouseOverWindow.name, RelativePoint = "bottom", XOffset = 0, YOffset = -64 };
	if string.find(WinName,"Sequencer_WindowButton") then
	if IDNumber ~= 0 then
	
	
	
		local abilityData = GetAbilityData(tonumber(Sequencer.TempSeq[IDNumber]))
		if (abilityData) then
			local text = AbilitiesWindow.AbilityTypeDesc[AbilitiesWindow.Modes.MODE_ACTION_ABILITIES];
			Tooltips.CreateAbilityTooltip(abilityData, SystemData.MouseOverWindow.name, anchor, text);
		end
		
		else
	Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name, nil);
	Tooltips.SetTooltipText(1, 1, L"Drop Abilities Here");
	Tooltips.SetTooltipColorDef(1, 1, Tooltips.COLOR_HEADING);
	Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_RIGHT)
	Tooltips.Finalize();		
end
elseif string.find(WinName,"CheckBox") then
	Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name, nil);
	Tooltips.SetTooltipText(1, 1,towstring(TooltipStrings[IDNumber]));
	Tooltips.SetTooltipColorDef(1, 1, Tooltips.COLOR_HEADING);
	Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_RIGHT)
	Tooltips.Finalize();	

end

end


function Sequencer.AbilityCursorSwap(flags, x, y)
	local WinName = SystemData.MouseOverWindow.name
	local IDNumber	= tonumber(WindowGetId (WinName))
	local TempSlot = Sequencer.TempSeq.Slot
	local TempButton = Sequencer.TempSeq.Button
	local TempReset = Sequencer.TempSeq.Reset
	local TempTimer = Sequencer.TempSeq.Timer	
	--d(IDNumber)
	
	if Cursor.IconOnCursor() then

        local abilityData = GetAbilityData(Cursor.Data.ObjectId)	
	       if (abilityData.abilityType == GameData.AbilityType.MORALE) 
        then
			AlertTextWindow.AddLine (SystemData.AlertText.Types.DEFAULT, GetString (StringTables.Default.TEXT_MORALE_DROP_ERROR))
			return
		end  
            
        if (abilityData.abilityType == GameData.AbilityType.TACTIC) 
        then
			AlertTextWindow.AddLine (SystemData.AlertText.Types.DEFAULT, GetString (StringTables.Default.TEXT_TACTIC_DROP_ERROR))
            return 
        end
		
		if abilityData.abilityType ~= 1 then return end  
		
		if IDNumber == 0 then
			Sequencer.TempSeq[#Sequencer.TempSeq+1] = tostring(abilityData.id)
			Cursor.Clear()
		else			
		local abData = GetAbilityData(tonumber(Sequencer.TempSeq[IDNumber]))
		Sequencer.TempSeq[IDNumber] = tostring(abilityData.id)
		Cursor.Clear()
		       Cursor.PickUp( Cursor.SOURCE_ACTION_LIST, Cursor.SOURCE_ACTION_LIST, abData.id, 
                       abData.iconNum, false )
		end
		
			Sequencer.TempSeq.Slot = TempSlot
			Sequencer.TempSeq.Button = TempButton
			Sequencer.TempSeq.Reset = TempReset
			Sequencer.TempSeq.Timer = TempTimer
	     
		Sequencer.Load()     

	else
		if IDNumber ~= 0 then
	       local abilityData = GetAbilityData(tonumber(Sequencer.TempSeq[IDNumber]))	
	       Cursor.PickUp( Cursor.SOURCE_ACTION_LIST, Cursor.SOURCE_ACTION_LIST, abilityData.id, 
                       abilityData.iconNum, false )
	
			table.remove(Sequencer.TempSeq,IDNumber)	
			Sequencer.Load()
		end
	--pickup from window
		
    end

end

function Sequencer.AbilityCursorClear(flags, x, y)
	local WinName = SystemData.MouseOverWindow.name
	local IDNumber	= tonumber(WindowGetId (WinName))
	local TempSlot = Sequencer.TempSeq.Slot
	local TempButton = Sequencer.TempSeq.Button
	local TempReset = Sequencer.TempSeq.Reset
	local TempTimer = Sequencer.TempSeq.Timer	
	if IDNumber == 0 then return end
	table.remove(Sequencer.TempSeq,IDNumber)	
	Sequencer.Load()
end


function Sequencer.Load(Slot,Button)
	local TempSlot = Sequencer.TempSeq.Slot
	local TempButton = Sequencer.TempSeq.Button
	local TempReset = Sequencer.TempSeq.Reset
	local TempTimer = Sequencer.TempSeq.Timer
	
if type(Slot) == "number" then
Sequencer.TempSeq = {}
if Sequencer.Slots ~= nil and Sequencer.Slots[Slot] ~= nil then
for k,v in ipairs(Sequencer.Slots[Slot]) do
Sequencer.TempSeq[k] = v
end
Sequencer.TempSeq.Reset = Sequencer.Slots[Slot].Reset
Sequencer.TempSeq.Timer = Sequencer.Slots[Slot].Timer
--ComboBoxSetSelectedMenuItem( "Sequencer_WindowCombo", Sequencer.TempSeq.Reset )
--d(L"sequenced button rightclicked")
ButtonSetPressedFlag("Sequencer_WindowCheckBoxCombat",Sequencer.TempSeq.Reset["combat"])
ButtonSetPressedFlag("Sequencer_WindowCheckBoxEnemy",Sequencer.TempSeq.Reset["enemytarget"])
ButtonSetPressedFlag("Sequencer_WindowCheckBoxFriend",Sequencer.TempSeq.Reset["friendlytarget"])
ButtonSetPressedFlag("Sequencer_WindowCheckBoxTimer",Sequencer.TempSeq.Reset["timer"])
ButtonSetPressedFlag("Sequencer_WindowCheckBoxCooldown",Sequencer.TempSeq.Reset["cooldown"])
ButtonSetDisabledFlag("Sequencer_WindowLoadButton",false)
ButtonSetDisabledFlag("Sequencer_WindowClearButton",false)

	if Sequencer.TempSeq.Reset["timer"] == false then
		TextEditBoxSetText("Sequencer_WindowTimerBox",L"0") 
	else
		TextEditBoxSetText("Sequencer_WindowTimerBox",towstring(Sequencer.TempSeq.Timer))	
	end


else
	--d(L"non sequenced button rightclicked")
		if SelectedAbility ~= 0 then
		Sequencer.TempSeq[1] = tostring(SelectedAbility)
		else
		DynamicImageSetTexture("Sequencer_WindowButton1ActionIcon", "Seq_Add", 0, 0)
		end
		Sequencer.TempSeq.Reset = {["combat"]=true,
			["enemytarget"] = false,
			["friendlytarget"] = false,
			["timer"] = false,
			["cooldown"] = true
		}
		Sequencer.TempSeq.Timer = 0
		--["combat"]=1,["enemytarget"]=2,["friendlytarget"]=3,["timer"]=4
		--ComboBoxSetSelectedMenuItem( "Sequencer_WindowCombo", Sequencer.TempSeq.Reset )
		ButtonSetPressedFlag("Sequencer_WindowCheckBoxCombat",Sequencer.TempSeq.Reset["combat"])
		ButtonSetPressedFlag("Sequencer_WindowCheckBoxEnemy",Sequencer.TempSeq.Reset["enemytarget"])
		ButtonSetPressedFlag("Sequencer_WindowCheckBoxFriend",Sequencer.TempSeq.Reset["friendlytarget"])
		ButtonSetPressedFlag("Sequencer_WindowCheckBoxTimer",Sequencer.TempSeq.Reset["timer"])
		ButtonSetPressedFlag("Sequencer_WindowCheckBoxCooldown",Sequencer.TempSeq.Reset["cooldown"])		
		TextEditBoxSetText("Sequencer_WindowTimerBox",towstring(Sequencer.TempSeq.Timer))
		ButtonSetDisabledFlag("Sequencer_WindowLoadButton",true)
		ButtonSetDisabledFlag("Sequencer_WindowClearButton",true)
end
else
Sequencer.TempSeq.Slot = TempSlot
Sequencer.TempSeq.Button = TempButton
Sequencer.TempSeq.Reset = TempReset
Sequencer.TempSeq.Timer = TempTimer
--d(L"no slot")

end

Sequencer.TempSeq.Slot = TempSlot
Sequencer.TempSeq.Button = TempButton


local index
for i=2,14 do
			index = 16-i
			if DoesWindowExist("Sequencer_WindowButton"..index) then
			DestroyWindow("Sequencer_WindowButton"..index)
			end
end

local NumSlots = #Sequencer.TempSeq
			for k,v in ipairs(Sequencer.TempSeq) do
				if k<13 then
				local Ability_Info = GetAbilityData(tonumber(v))		
				local icon,x,y = GetIconData(Ability_Info.iconNum)		
				local WindowName = "Sequencer_WindowButton"..k+1
				if not DoesWindowExist(WindowName) then
					CreateWindowFromTemplate(WindowName, "Sequencer_Button", "Sequencer_Window")
				end
				WindowSetId("Sequencer_WindowButton"..k.."Action",k)
				DynamicImageSetTexture("Sequencer_WindowButton"..(k).."ActionIcon", icon, x, y)
				WindowClearAnchors(WindowName)
				WindowAddAnchor(WindowName,"topleft", "Sequencer_Window","topleft",12+(40*k),40)

				end
			end
			
if NumSlots < 12 then
WindowSetDimensions("Sequencer_WindowBG3",7+((#Sequencer.TempSeq+1)*40),48)
else
WindowSetDimensions("Sequencer_WindowBG3",7+((12)*40),48)			
end			

--WindowSetShowing( "Sequencer_WindowTimerBox", ComboBoxGetSelectedMenuItem("Sequencer_WindowCombo")==4 )				
LabelSetText("Sequencer_WindowText",SelectedText)

				if DoesWindowExist("Sequencer_WindowButton13") then
					WindowSetShowing("Sequencer_WindowButton13",false)
				end


DynamicImageSetTexture("Sequencer_WindowButton"..(#Sequencer.TempSeq+1).."ActionIcon", "Seq_Add", 0, 0)
WindowSetId("Sequencer_WindowButton"..(#Sequencer.TempSeq+1).."Action",0)


if Slot~=nil then Sequencer.TempSeq.Slot = Slot end
if Button~=nil then Sequencer.TempSeq.Button = Button end
	
	
if WindowGetShowing("Sequencer_Window") == true then
Sequencer.HelpSlot()
end

end

function Sequencer.Save(num)
--d(ResetNames[ComboBoxGetSelectedMenuItem("Sequencer_WindowCombo")])
	local function SetReturn()
		local Value = 0
		local Timer = 0
		if Sequencer.TempSeq.Reset["combat"] == true then Value = Value+1 end
		if Sequencer.TempSeq.Reset["enemytarget"] == true then Value = Value+2 end
		if Sequencer.TempSeq.Reset["friendlytarget"] == true then Value = Value+4 end
		if Sequencer.TempSeq.Reset["timer"] == true then 
			Value = Value+8
			if TextEditBoxGetText("Sequencer_WindowTimerBox") == L"" then 
				Timer = 1
				TextEditBoxSetText("Sequencer_WindowTimerBox",L"1") 
			else
				Timer = TextEditBoxGetText("Sequencer_WindowTimerBox") 
			end			
		end
		if Sequencer.TempSeq.Reset["cooldown"] == true then Value = Value+16 end
		return towstring(Value)..L" "..towstring(Timer)
	end	

if #Sequencer.TempSeq > 1 then
local Build_sequence = L".castsequence add "..towstring(Sequencer.TempSeq.Slot)..L" "..SetReturn()..L" "
local Ability_list = L""
for k,v in ipairs(Sequencer.TempSeq) do
Ability_list = Ability_list..towstring(v)..L","
end
Ability_list = wstring.sub(Ability_list,0,-2)
Build_sequence = Build_sequence..Ability_list

SendChatText(Build_sequence, L"")	
--d(Build_sequence)
else
return

end

end

function Sequencer.Clear(num)

if ButtonGetDisabledFlag("Sequencer_WindowClearButton") == true then return end

	local TempSlot = Sequencer.TempSeq.Slot
	local TempButton = Sequencer.TempSeq.Button
	local TempReset = Sequencer.TempSeq.Reset
	
SendChatText(L".castsequence delete "..towstring(Sequencer.TempSeq.Slot), L"")

		DynamicImageSetTexture("Sequencer_WindowButton1ActionIcon", "Seq_Add", 0, 0)
		Sequencer.TempSeq.Reset = {["combat"]=true,
			["enemytarget"] = false,
			["friendlytarget"] = false,
			["timer"] = false
		}
		Sequencer.TempSeq.Timer = 0
		--ComboBoxSetSelectedMenuItem( "Sequencer_WindowCombo", Sequencer.TempSeq.Reset )
		Sequencer.TempSeq.Slot = TempSlot
		Sequencer.TempSeq.Button = TempButton
		Sequencer.Slots[TempSlot] = nil
		Sequencer.Load(TempSlot,TempButton)
end

function Sequencer.UpdatePage(bar,page)
Sequencer.PageBars[bar] = page

Sequencer.UpdateMacros(bar,page)

end

function Sequencer.UpdateAbility(a,b,c)
--Too much lag from PLAYER_HOT_BAR_UPDATED
--it runs this stuff 130+ times, so just run it once at the last slot
if a == 130 then
Sequencer.UpdateMacros(a,b,c)
end
end

function Sequencer.Cast()
Sequencer.UpdateMacros()
end



function Sequencer.UpdateMacros(...)
if Sequencer.Slots then 

Sequencer.Tooltip = {}
for i=1,5 do
		local SlotsOnBar = ActionBars.m_Bars[i].m_ButtonCount
for a=1,SlotsOnBar do
local CP,_ = ActionBars:BarAndButtonIdFromSlot(i*12)
if CP == nil then return end
if CP.m_Buttons[a].m_ActionType < 2 then
CP.m_Buttons[a].m_Windows[7]:SetText(L"")
--CP.m_Buttons[a].m_Windows[7]:Show(false)
end
end
end

	for k,v in pairs(Sequencer.Slots) do
		local Cp_Page = math.ceil(k/12)
		local SlotOnPage = k-(12*(Cp_Page-1))
		for i=1,5 do
			local CP,_ = ActionBars:BarAndButtonIdFromSlot(i*12)
			--local Page = CP.m_PageSelectorWindow.m_LogicalPage
			local Page = Sequencer.PageBars[i]			
			--local Page = CP.m_PageSelectorWindow.m_DisplayPage

			if Cp_Page == Page then
				CP.m_Buttons[SlotOnPage].m_Windows[7]:SetText(L"<icon29958>")
				CP.m_Buttons[SlotOnPage].m_Windows[7]:Show(true)
				Sequencer.Tooltip[tostring(CP.m_Buttons[SlotOnPage].m_Name).."Action"] = k
			else
				--CP.m_Buttons[SlotOnPage].m_Windows[7]:Show(false)
			end
		end
	end
		
end	
	
if WindowGetShowing("Sequencer_Window") == true then
	Sequencer.HelpSlot()
end
Sequencer.Load(Sequencer.TempSeq.Slot,Sequencer.TempSeq.Button)
end

function Sequencer.ToggleShowing()
WindowSetShowing("Sequencer_Window",false)
end

function Sequencer.ComboSelect(idx)
	PlaySound(313)
	ComboBoxSetSelectedMenuItem( "Sequencer_WindowCombo", idx )
	
	--WindowSetShowing( "Sequencer_WindowTimerBox", idx==4 )	
end

function Sequencer.HelpSlot()

	for i=1,5 do
		local SlotsOnBar = ActionBars.m_Bars[i].m_ButtonCount
		for a=1,SlotsOnBar do
		local CP,_ = ActionBars:BarAndButtonIdFromSlot(i*12)
			if CP == nil then return end
			WindowSetShowing(CP.m_Buttons[a].m_Windows[5].m_Name,CP.m_Buttons[a].m_Windows[5].m_Showing)
			WindowSetTintColor(CP.m_Buttons[a].m_Windows[5].m_Name,255,255,255)
		if WindowGetShowing("Sequencer_Window") == true then
			if CP.m_Buttons[a].m_ActionType < 2 then
					--local Page = CP.m_PageSelectorWindow.m_DisplayPage
--					local Page = CP.m_PageSelectorWindow.m_LogicalPage
					local Page = Sequencer.PageBars[i]							
					local SlotNumber = tonumber(slot)
					local OrgPage = CP.m_ActionPage
					--local SlotOnPage = SlotNumber-(12*(Page-1))
					local SlotOnPage = a
					local SlotToPage = ((Page-1)*12)+SlotOnPage
					if SlotToPage == Sequencer.TempSeq.Slot then
						WindowSetShowing(CP.m_Buttons[a].m_Windows[5].m_Name,true)
						WindowSetTintColor(CP.m_Buttons[a].m_Windows[5].m_Name,20,255,75)
					end
			end
		end
		end
	end
end

function Sequencer.ToggleReset()
	local WinName = SystemData.MouseOverWindow.name
	local IDNumber	= tonumber(WindowGetId (WinName))
	local TempSlot = Sequencer.TempSeq.Slot
	local TempButton = Sequencer.TempSeq.Button
	local TempReset = Sequencer.TempSeq.Reset
	local TempTimer = Sequencer.TempSeq.Timer
	
	Sequencer.TempSeq.Reset[ResetNames[IDNumber]] = not Sequencer.TempSeq.Reset[ResetNames[IDNumber]]
	
		ButtonSetPressedFlag("Sequencer_WindowCheckBoxCombat",Sequencer.TempSeq.Reset["combat"])
		ButtonSetPressedFlag("Sequencer_WindowCheckBoxEnemy",Sequencer.TempSeq.Reset["enemytarget"])
		ButtonSetPressedFlag("Sequencer_WindowCheckBoxFriend",Sequencer.TempSeq.Reset["friendlytarget"])
		ButtonSetPressedFlag("Sequencer_WindowCheckBoxTimer",Sequencer.TempSeq.Reset["timer"])
		ButtonSetPressedFlag("Sequencer_WindowCheckBoxCooldown",Sequencer.TempSeq.Reset["cooldown"])	
	
	if Sequencer.TempSeq.Reset["timer"] == false then
		TextEditBoxSetText("Sequencer_WindowTimerBox",L"0") 
	end

end
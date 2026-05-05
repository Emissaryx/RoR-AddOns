GMT2.ListBuffs = {}

function GMT2.ListBuffs.Input(Table,IsNPC)
local Table = Table
local IsNPC = IsNPC
local Char_Name = wstring.match(Table.table[1],L"%List of buffs on (.+)")

GMT2.ListBuffs[tostring(Char_Name)] = {}

for i=2,#Table.table do
	local Entry,Name,Level,Stacks,Type,OrgLevel,CastType,Caster = wstring.match( Table.table[i],L"Buff Entry: (.+) Name: (.+) Level: (.+) Stacks: (.+) Type: (.+) OriginalLevel: (.+) Caster: (.+) \"(.+)\"")
	GMT2.ListBuffs[tostring(Char_Name)][i-1] = {ID=tonumber(Entry),NAME=Name,LEVEL=Level,STACKS=Stacks,TYPE=Type,CASTER=Caster}

end

local ListStuff = "CheckBuffs_"..tostring(Char_Name)	

if DoesWindowExist(ListStuff) == false then CreateWindowFromTemplate(ListStuff,"CheckBuffs_Window_Template", "Root") end
local Char_Name_Link = towstring(CreateHyperLink(L"PLAYER:"..towstring(Char_Name),towstring(Char_Name), {100,100,255}, {} ))
if IsNPC then Char_Name_Link = towstring(Char_Name) end

	LabelSetText (ListStuff.."Name",L"GMT2 ListBuffs")	
	LabelSetText(ListStuff.."Item1Title",L"Character:")
	LabelSetText(ListStuff.."Item1Text",Char_Name_Link)
	WindowSetShowing(ListStuff.."Item1EditBox",false)
	ButtonSetText( ListStuff.."NameButton",  L"Buff Name")
	ButtonSetText( ListStuff.."IDButton",  L"ID")	
	ButtonSetText( ListStuff.."LevelButton",  L"LvL")	
	ButtonSetText( ListStuff.."StackButton",  L"#")
	ButtonSetText( ListStuff.."TypeButton",  L"Type")
	ButtonSetText( ListStuff.."CasterButton",  L"Caster")			

	for row = 1, #GMT2.ListBuffs[tostring(Char_Name)] do
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        local targetRowWindow = ListStuff.."ListBoxRow"..row.."BG"
        WindowSetTintColor(ListStuff.."ListBoxRow"..row.."BG", color.r, color.g, color.b )
        WindowSetAlpha(ListStuff.."ListBoxRow"..row.."BG", color.a )
    end
	
	  for row, data in ipairs( GMT2.ListBuffs[tostring(Char_Name)])  do
  --      if row < GMTools.GetChars[Table_Name].Slots+1 then
        local rowName   = ListStuff.."ListBoxRow"..row
		local RowNumber = 	ListBoxGetDataIndex(ListStuff.."ListBox",row)
		local CasterName = towstring(GMT2.ListBuffs[tostring(Char_Name)][row].CASTER)
				
		LabelSetText(rowName.."Buff_Name", towstring(GMT2.ListBuffs[tostring(Char_Name)][row].NAME))
		LabelSetText(rowName.."ID", towstring(GMT2.ListBuffs[tostring(Char_Name)][row].ID))			
		LabelSetText(rowName.."Stack", towstring(GMT2.ListBuffs[tostring(Char_Name)][row].STACKS))		
		LabelSetText(rowName.."Level", towstring(GMT2.ListBuffs[tostring(Char_Name)][row].LEVEL))			
		LabelSetText(rowName.."Type", towstring(GMT2.ListBuffs[tostring(Char_Name)][row].TYPE))			
		LabelSetText(rowName.."Caster", CasterName)			
		if CasterName ~= Char_Name then LabelSetTextColor(rowName.."Caster",125,255,125) end
		
--end
end
	
	for i=#GMT2.ListBuffs[tostring(Char_Name)]+1 , 50 do
		if DoesWindowExist(ListStuff.."ListBoxRow"..i) then
			WindowSetShowing(ListStuff.."ListBoxRow"..i,false)
		end	
	end
		WindowSetDimensions(ListStuff,575,91+(#GMT2.ListBuffs[tostring(Char_Name)]*22))

end

function GMT2.CheckBuffs_Hoover()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name	
	local _index = WindowGetId(WindowName)	
	local SubString = string.gsub(WindowGetParent(WinParent),"CheckBuffs_","")
		Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, nil)
		local AbilityId = tonumber(GMT2.ListBuffs[tostring(SubString)][_index].ID)
		Tooltips.SetTooltipText( 1, 1, towstring(GetAbilityName(AbilityId)))
		Tooltips.SetTooltipText( 2, 1, towstring(GetAbilityDesc(AbilityId)))
		Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT)
		Tooltips.SetTooltipColor (1, 1, 155, 255, 155)	
		Tooltips.Finalize()    
		
end

function GMT2.CheckBuffs_Click()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name	
	local _index = WindowGetId(WindowName)	
	local SubString = string.gsub(WindowGetParent(WinParent),"CheckBuffs_","")
		local CasterName = GMT2.ListBuffs[tostring(SubString)][_index].CASTER
		d(CasterName)
		PlayerMenuWindow.ShowMenu(towstring(CasterName))
		
end

function GMT2.ListBuffs.LClic()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name	
	local _index = WindowGetId(WindowName)	
	local SubString = string.gsub(WindowGetParent(WinParent),"ListBuffs_","")
	PlayerMenuWindow.ShowMenu(towstring(GMT2.ListBuffs[SubString][_index].Char_Name))
end


function GMT2.ListBuffs.SlashCommand()
local Target_Name = L""
local NPC = false
if TargetInfo:UnitType( "selfhostiletarget" ) ~= 0 then
Target_Name = GMT2.FixString(TargetInfo:UnitName( "selfhostiletarget" ))
NPC = not(TargetInfo:UnitType( "selfhostiletarget" ) == 5)
	if NPC then Target_Name = Target_Name end
elseif TargetInfo:UnitType( "selfhostiletarget" ) == 0 then
 if TargetInfo:UnitName("selffriendlytarget") ~= 0 then
	Target_Name = GMT2.FixString(TargetInfo:UnitName( "selffriendlytarget" ))
	NPC = not(TargetInfo:UnitType( "selffriendlytarget" ) == 3 or TargetInfo:UnitType( "selffriendlytarget" ) == 1) 
	if NPC then Target_Name = Target_Name end
	
end
end



				GMT2.SearchName = tostring(Target_Name)
				GMT2.Command["ability"] = 1 --start the Ability list chat search
				GMT2.AbilityList = {index=1,table={},IsNPC = NPC}
				GMT2.StartMachine()
				SendChatText(L"]ability list "..towstring(Target_Name), ChatSettings.Channels[0].serverCmd)		
				TextLogAddEntry("Chat", 0, L"GMT2: ListBuff: "..towstring(CreateHyperLink(L"PLAYER:"..towstring(Target_Name),towstring(Target_Name), {175,175,175}, {} )))	

end
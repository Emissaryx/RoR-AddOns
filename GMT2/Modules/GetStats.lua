GMT2.GetStats = {}

function GMT2.GetStats.Input(Table,IsNPC)

local Table = Table
local IsNPC = IsNPC
--d(Table)
local Char_Name = GMT2.SearchName --wstring.match(Table.table[2],L"%[Stats for (.+)%]")
GMT2.GetStats[tostring(Char_Name)] = {}



for i=3,#Table.table do
	
	local Formula = wstring.match(Table.table[i],L"%[(.+)%]") or L""
	Table.table[i] = wstring.gsub(Table.table[i], L"%[.+%]","")
	local Value = wstring.match(Table.table[i],L"%d+") or L""
	Table.table[i] = wstring.gsub(Table.table[i],L"%d+","")
	GMT2.GetStats[tostring(Char_Name)][i-2] = {FORMULA=Formula,NAME=Table.table[i],VALUE=Value}
	--GMT2.GetStats[tostring(Char_Name)][i-2] = Table.table[i]	

--	GMT2.ListBuffs[tostring(Char_Name)][i-1] = {ID=tonumber(Entry),NAME=Name,STACKS=Stacks}

end



local ListStuff = "GetStats_"..tostring(Char_Name)	

if DoesWindowExist(ListStuff) == false then CreateWindowFromTemplate(ListStuff,"GetStats_Window_Template", "Root") end
local Char_Name_Link = towstring(CreateHyperLink(L"PLAYER:"..towstring(Char_Name),towstring(Char_Name), {100,100,255}, {} ))

if IsNPC then Char_Name_Link = towstring(Char_Name) end

	LabelSetText (ListStuff.."Name",L"GMT2 GetStats")	
	LabelSetText(ListStuff.."Item1Title",L"Character:")
	LabelSetText(ListStuff.."Item1Text",Char_Name_Link)
	WindowSetShowing(ListStuff.."Item1EditBox",false)
	ButtonSetText( ListStuff.."NameButton",  L"Stat Name")
	ButtonSetText( ListStuff.."IDButton",  L"Value")	
	ButtonSetText( ListStuff.."StackButton",  L"Formula")		

	for row = 1, #GMT2.GetStats[tostring(Char_Name)] do
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        local targetRowWindow = ListStuff.."ListBoxRow"..row.."BG"
        WindowSetTintColor(ListStuff.."ListBoxRow"..row.."BG", color.r, color.g, color.b )
        WindowSetAlpha(ListStuff.."ListBoxRow"..row.."BG", color.a )
    end
	
	  for row, data in ipairs( GMT2.GetStats[tostring(Char_Name)])  do
  --      if row < GMTools.GetChars[Table_Name].Slots+1 then
        local rowName   = ListStuff.."ListBoxRow"..row
		local RowNumber = 	ListBoxGetDataIndex(ListStuff.."ListBox",row)
		
		
		LabelSetText(rowName.."Buff_Name", towstring(GMT2.GetStats[tostring(Char_Name)][row].NAME))
		LabelSetText(rowName.."ID", towstring(GMT2.GetStats[tostring(Char_Name)][row].VALUE))			
		LabelSetText(rowName.."Stack", towstring(GMT2.GetStats[tostring(Char_Name)][row].FORMULA))		
		
--end
end
	
	for i=#GMT2.GetStats[tostring(Char_Name)]+1 , 50 do
		if DoesWindowExist(ListStuff.."ListBoxRow"..i) then
			WindowSetShowing(ListStuff.."ListBoxRow"..i,false)
		end	
	end
		WindowSetDimensions(ListStuff,370,91+(#GMT2.GetStats[tostring(Char_Name)]*22))

end

function GMT2.GetStats.SlashCommand()
local Target_Name = L""
local NPC = false
if TargetInfo:UnitType( "selfhostiletarget" ) ~= 0 then
Target_Name = GMT2.FixString(TargetInfo:UnitName( "selfhostiletarget" ))
NPC = not(TargetInfo:UnitType( "selfhostiletarget" ) == 5)
	if NPC then Target_Name = Target_Name..L" "..TargetInfo:UnitEntityId( "selfhostiletarget" ) end
elseif TargetInfo:UnitType( "selfhostiletarget" ) == 0 then
 if TargetInfo:UnitName("selffriendlytarget") ~= 0 then
	Target_Name = GMT2.FixString(TargetInfo:UnitName( "selffriendlytarget" ))
	NPC = not(TargetInfo:UnitType( "selffriendlytarget" ) == 3 or TargetInfo:UnitType( "selffriendlytarget" ) == 1) 
	if NPC then Target_Name = Target_Name..L" "..TargetInfo:UnitEntityId( "selffriendlytarget" ) end
	
end
end
				GMT2.SearchName = tostring(Target_Name)
				GMT2.Command["getstats"] = 1 --start the Ability list chat search
				GMT2.StatsList = {index=1,IsNPC = NPC,table={}}
				GMT2.StartMachine()
				SendChatText(L"]getstats "..towstring(Target_Name), ChatSettings.Channels[0].serverCmd)		

end


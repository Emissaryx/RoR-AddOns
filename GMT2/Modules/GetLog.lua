
Check_Log_Notes = {}
GMT2.NoteTypes = {Text={["Default"]=1,["User Note"]=2,["Name Change"]=3,["Warning"]=4,["Lift Ban"]=5},Color={[1]={r=255,g=255,b=255},[2]={r=255,g=255,b=255},[3]={r=0,g=175,b=175},[4]={r=255,g=200,b=77},[5]={r=20,g=200,b=20}}}
GMT2.GetLog_Wnd = {"Item1","Item2","Item3","Item4","Item5","Item6","Item7","Item8","Item9","Item10"}

--GMT2.GetLog(GMT2.CheckLogs[GMT2.SearchName])		GMT2.GetLog(tostring(Char_Name))
function GMT2.GetLog(Table_Name,ForcedExpand)
local GetLog_Table = Table_Name
local Char_Name = string.gsub(tostring(GetLog_Table[3]), "Character: ","")
local Formerly_Name = ""
local Sur_Name = string.gsub(tostring(GetLog_Table[4]), "Surname: ","")
local Account_Name = string.gsub(tostring(GetLog_Table[5]), "Account: ","")
local ListStuff = "GMT2_GetLog_"..Account_Name
local IP_Number = L""
local BanStatus = L""

	if GetLog_Table[6]~= nil then
		IP_Number = string.match(tostring(GetLog_Table[6]),"Last IP used: (.+)")
		BanStatus = string.match(tostring(GetLog_Table[7]),"Ban status: (.+)")
	else
		Account_Name = string.gsub(tostring(GetLog_Table[4]), "Account: ","")
		Sur_Name = L""
	end

	if Char_Name:find("formerly") then
		Formerly_Name = Char_Name:match("%(formerly:(.+)%)")
		Char_Name = Char_Name:match("(.+) %(formerly.")	
	end	


local Char_Name_Link = towstring(CreateHyperLink(L"PLAYER:"..towstring(Char_Name),towstring(Char_Name), {100,100,255}, {} ))

if DoesWindowExist(ListStuff) == false then CreateWindowFromTemplate(ListStuff,"GetLogWindow_Template", "Root") end
LabelSetText(ListStuff.."Title",L"GMT2 CheckLog")
LabelSetText(ListStuff.."Item1Title",L"Account:")
LabelSetText(ListStuff.."Item2Title",L"Character:")
LabelSetText(ListStuff.."Item3Title",L"SurName:")
LabelSetText(ListStuff.."Item4Title",L"IP:")
LabelSetText(ListStuff.."Item5Title",L"Status:")

--TextEditBoxSetText(ListStuff.."AccountEditBox",towstring(Account_Name))
WindowSetShowing(ListStuff.."Item1EditBox",false)
WindowSetShowing(ListStuff.."Item2EditBox",false)
WindowSetShowing(ListStuff.."Item3EditBox",false)
WindowSetShowing(ListStuff.."Item4EditBox",false)
WindowSetShowing(ListStuff.."Item5EditBox",false)

LabelSetText(ListStuff.."Item1Text",towstring(Account_Name))
LabelSetText(ListStuff.."Item2Text",towstring(Char_Name_Link)..towstring(Formerly_Name))
LabelSetText(ListStuff.."Item3Text",towstring(Sur_Name))
LabelSetText(ListStuff.."Item4Text",towstring(IP_Number))
LabelSetText(ListStuff.."Item5Text",towstring(BanStatus))

WindowSetShowing(ListStuff.."PlusButton",GetLog_Table[6] ~= nil)
WindowSetShowing(ListStuff.."MinusButton",GetLog_Table[6] ~= nil)
WindowSetShowing(ListStuff.."Icon",GetLog_Table[6]~= nil)
WindowSetShowing(ListStuff.."Item3Title",GetLog_Table[6]~= nil)
WindowSetShowing(ListStuff.."Item4Title",GetLog_Table[6]~= nil)
WindowSetShowing(ListStuff.."Item5Title",GetLog_Table[6]~= nil)


if not Check_Log_Notes[Account_Name] then Check_Log_Notes[Account_Name] = {} end

local Index_Counter = 1
local Notes_Total_Height = 0

if #Table_Name > 7 then
local NotesWindow = ListStuff.."Notes"
	for i=8,#Table_Name do
	local TestText = ""
		Check_Log_Notes[Account_Name][Index_Counter]={}
		if DoesWindowExist(NotesWindow..i) == false then CreateWindowFromTemplate(NotesWindow..i,"GetLogWindow_NoteTemplate", ListStuff) end
		Check_Log_Notes[Account_Name][Index_Counter].Header = string.match(tostring(Table_Name[i]),"([^%.]+) issued by") 		
		Check_Log_Notes[Account_Name][Index_Counter].Arthor,Check_Log_Notes[Account_Name][Index_Counter].Text = string.match(tostring(Table_Name[i]),"issued by ([%a%d]+) (.+)") 			
		local NoteType = string.match(tostring(Table_Name[i])," : ([^%.]+) issued by") or "Default"
		local NoteColor = GMT2.NoteTypes.Color[GMT2.NoteTypes.Text[tostring(NoteType)]] or {r=255,g=0,b=0}
		WindowSetTintColor(NotesWindow..i.."BorderCheck",NoteColor.r,NoteColor.g,NoteColor.b)
		--Check_Log_Notes[Account_Name][Index_Counter].Text = string.match(tostring(Table_Name[i]),"%(([^%.]+)%)") 
		if ForcedExpand ~= nil then Check_Log_Notes[Account_Name][Index_Counter].Expanded = ForcedExpand
		else
			if not Check_Log_Notes[Account_Name][Index_Counter].Expanded then Check_Log_Notes[Account_Name][Index_Counter].Expanded = false end
		end

		LabelSetText(NotesWindow..i.."Header",towstring(Check_Log_Notes[Account_Name][Index_Counter].Header))
		LabelSetText(NotesWindow..i.."Arthor",towstring(CreateHyperLink(towstring(Check_Log_Notes[Account_Name][Index_Counter].Arthor),towstring(Check_Log_Notes[Account_Name][Index_Counter].Arthor), {220,55,255}, {} )))

			
			local W,H = LabelGetTextDimensions(NotesWindow..i.."Header")			
			local Text_W,Text_H = 0,0
			
			Notes_Total_Height = (Notes_Total_Height + H) + 15
			if 	Check_Log_Notes[Account_Name][Index_Counter].Expanded == true then	
					LabelSetText(NotesWindow..i.."Text",towstring(Check_Log_Notes[Account_Name][Index_Counter].Text))
					Text_W,Text_H = LabelGetTextDimensions(NotesWindow..i.."Text")					
					Notes_Total_Height = Notes_Total_Height + Text_H +5
					H = H+5
			else
				LabelSetText(NotesWindow..i.."Text",L"")
			end		
						
			WindowClearAnchors( NotesWindow..i )
			WindowAddAnchor( NotesWindow..i , "topleft", ListStuff.."Item5", "bottomleft", 3,20+Notes_Total_Height)			
			WindowSetDimensions(NotesWindow..i,407,H+5+Text_H)
			
			WindowSetShowing(NotesWindow..i.."PlusButton",not Check_Log_Notes[Account_Name][Index_Counter].Expanded)
			WindowSetShowing(NotesWindow..i.."MinusButton",Check_Log_Notes[Account_Name][Index_Counter].Expanded)
			
		Index_Counter = Index_Counter +1	
	
	end
	
	WindowSetDimensions(ListStuff,425,100+Notes_Total_Height+50)
end
end


--Recalc the stack when expanding/contracting Items
function GMT2.GetLog_OnLButtonUp()


local WinParent = tostring(WindowGetParent(SystemData.MouseOverWindow.name))
local WindowName = tostring(SystemData.MouseOverWindow.name)
local AccName =  string.match(WinParent,"GMT2_GetLog_(.+)Notes.")		
local Number =  string.match(WinParent,"Notes(%d+)")	
local ListStuff = "GMT2_GetLog_"..AccName

Check_Log_Notes[tostring(AccName)][Number-7].Expanded = not Check_Log_Notes[tostring(AccName)][Number-7].Expanded


local Index_Counter = 1
local Notes_Total_Height = 0
local NotesWindow = ListStuff.."Notes"
for i=8,7+#Check_Log_Notes[tostring(AccName)] do
			local W,H = LabelGetTextDimensions(NotesWindow..i.."Header")			
			local Text_W,Text_H = 0,0
			
			Notes_Total_Height = (Notes_Total_Height + H) + 15
			if 	Check_Log_Notes[tostring(AccName)][Index_Counter].Expanded == true then	
					LabelSetText(NotesWindow..i.."Text",towstring(Check_Log_Notes[tostring(AccName)][Index_Counter].Text))
					Text_W,Text_H = LabelGetTextDimensions(NotesWindow..i.."Text")					
					Notes_Total_Height = Notes_Total_Height + Text_H +5
					H = H+5
			else
				LabelSetText(NotesWindow..i.."Text",L"")			
			end		
						
			WindowClearAnchors( NotesWindow..i )
			WindowAddAnchor( NotesWindow..i , "topleft", ListStuff.."Item5", "bottomleft", 3,20+Notes_Total_Height)			
			WindowSetDimensions(NotesWindow..i,407,H+5+Text_H)
			
			WindowSetShowing(NotesWindow..i.."PlusButton",not Check_Log_Notes[tostring(AccName)][Index_Counter].Expanded)
			WindowSetShowing(NotesWindow..i.."MinusButton",Check_Log_Notes[tostring(AccName)][Index_Counter].Expanded)
			
		Index_Counter = Index_Counter +1	



end
	WindowSetDimensions(ListStuff,425,100+Notes_Total_Height+50)
end

function GMT2.GetLog_CheckIP()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)		
	GMT2.FindIp.SlashCommand(LabelGetText(WinParent.."Item4Text"))

end

--string.match(tostring(LabelGetText(WindowGetParent(SystemData.MouseOverWindow.name).."CharacterText")),"([%a%d]+) .")
function GMT2.GetLog_ToggleExpand()
	local ContextID = WindowGetId( SystemData.MouseOverWindow.name )
	local WinParent = tostring(WindowGetParent(SystemData.MouseOverWindow.name))	
	local Character = string.match(tostring(LabelGetText(WindowGetParent(SystemData.MouseOverWindow.name).."Item2Text")),"([%a%d]+)")
	d(Character)
	GMT2.GetLog(GMT2.CheckLogs[tostring(Character)], ContextID == 1)
end

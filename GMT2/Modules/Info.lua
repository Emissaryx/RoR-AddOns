GMT2.Info = {}

function GMT2.Info.Input(CharName,Text)
local Char_Data = GetSearchList()
local Char_Name = tostring(CharName)
local Text = Text
local Ip = wstring.match(Text,L"Ip=(.+) ClientId") or L""
		if Ip ~= L"" then Ip = wstring.match(Ip,L"(.+):") end
local ClientId = wstring.match(Text,L"ClientId (.+)%(OffX") or L""
local Cords = wstring.match(Text,L"Active= True%)%((.+)%)") or L""
Cords = StringSplit(tostring(Cords), ", ")
GMT2.Info[tostring(Char_Name)] = {IP=Ip,ClientID=ClientId,Guild=Char_Data[1].guildName or L"none",Zone=Char_Data[1].zoneID,X=tonumber(Cords[1]),Y=tonumber(Cords[2]),Z=tonumber(Cords[3])}

local Char_Name_Link = towstring(CreateHyperLink(L"PLAYER:"..towstring(Char_Name),towstring(Char_Name), {100,100,255}, {} ))
local ListStuff = "GMT2_Info_"..Char_Name
	if DoesWindowExist(ListStuff) == false then CreateWindowFromTemplate(ListStuff,"InfoWindow_Template", "Root") end

	LabelSetText (ListStuff.."Title",L"GMT2 Info")	
	LabelSetText(ListStuff.."Item1Title",L"Character:")
	LabelSetText(ListStuff.."Item1Text",Char_Name_Link)
	WindowSetShowing(ListStuff.."Item1EditBox",false)
	
	LabelSetText(ListStuff.."Item2Title",L"IP:")
	LabelSetText(ListStuff.."Item2Text",GMT2.Info[tostring(Char_Name)].IP)
	WindowSetShowing(ListStuff.."Item2EditBox",false)
	
	LabelSetText(ListStuff.."Item3Title",L"ClientID:")
	LabelSetText(ListStuff.."Item3Text",GMT2.Info[tostring(Char_Name)].ClientID)
	WindowSetShowing(ListStuff.."Item3EditBox",false)	
	
	LabelSetText(ListStuff.."Item4Title",L"Guild:")
	LabelSetText(ListStuff.."Item4Text",GMT2.Info[tostring(Char_Name)].Guild)
	WindowSetShowing(ListStuff.."Item4EditBox",false)		
	
	LabelSetText(ListStuff.."Item5Title",L"Location:")
	LabelSetText(ListStuff.."Item5Text",L"("..towstring(GMT2.Info[tostring(Char_Name)].Zone)..L") "..GetZoneName(tonumber(GMT2.Info[tostring(Char_Name)].Zone)))
	WindowSetShowing(ListStuff.."Item5EditBox",false)			

	LabelSetText(ListStuff.."Item6Title",L"")
	LabelSetText(ListStuff.."Item6Text",towstring(GMT2.Info[tostring(Char_Name)].X)..L","..towstring(GMT2.Info[tostring(Char_Name)].Y)..L","..towstring(GMT2.Info[tostring(Char_Name)].Z))
	WindowSetShowing(ListStuff.."Item6EditBox",false)			

end

function GMT2.Info_Map()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name
	if DoesWindowExist(WinParent) == true then
	local Char_Name = wstring.match(towstring(WinParent),L"GMT2_Info_(.+)") or L""

	GMT2.Map.TargetPin = {Zone = tonumber(GMT2.Info[tostring(Char_Name)].Zone),X=tonumber(GMT2.Info[tostring(Char_Name)].X),Y=tonumber(GMT2.Info[tostring(Char_Name)].Y),Name=towstring(Char_Name)}


	d(Char_Name)
	WindowSetShowing("EA_Window_WorldMap",true)
	EA_Window_WorldMap.currentMap = tonumber(GMT2.Info[tostring(Char_Name)].Zone)
	EA_Window_WorldMap.ShowZone( tonumber(GMT2.Info[tostring(Char_Name)].Zone) )
	GMT2.Map.UpdatePinCoordinates()
	end
end

function GMT2.Info.CheckIP()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)		
	GMT2.FindIp.SlashCommand(LabelGetText(WinParent.."Item2Text"))

end

function GMT2.Info.LClic()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name	
	local _index = WindowGetId(WindowName)	
	local SubString = string.gsub(WindowGetParent(WinParent),"Info_","")
	PlayerMenuWindow.ShowMenu(towstring(GMT2.Info[SubString][_index].Char_Name))
end



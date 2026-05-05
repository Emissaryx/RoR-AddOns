GMT2.GetChar = {}
GMT2.GetChar.CareerToIcon = {IronBreaker=1,Slayer=2,RunePriest=3,Engineer=4,BlackOrc=5,Choppa=6,Shaman=7,SquigHerder=8,WitchHunter=9,KnightOfTheBlazingSun=10,BrightWizard=11,WarriorPriest=12,Chosen=13,Marauder=14,Zealot=15,Magus=16,SwordMaster=17,ShadowWarrior=18,WhiteLion=19,Archmage=20,BlackGuard=21,WitchElf=22,DiscipleOfKhaine=23,Sorceress=24}

function GMT2.GetChar.Input(text)
local Splitted_Table = StringSplit(tostring(text), "\n")
local Account_Name = string.match(Splitted_Table[1],"%account='(.+)%'.")
GMT2.GetChar[Account_Name] = {}
GMT2.GetChar[Account_Name].Account = Splitted_Table[1]:match("%account='(.+)%'.")	
GMT2.GetChar[Account_Name].Slots = tonumber(Splitted_Table[1]:match("%has (.+)% characters."))
	for i = 2 , GMT2.GetChar[Account_Name].Slots + 1 do
	GMT2.GetChar[Account_Name][i-1] = {}
		--checks if the char is online
		if Splitted_Table[i]:find("--ONLINE") then
			Splitted_Table[i] = Splitted_Table[i]:gsub("--ONLINE","")
			GMT2.GetChar[Account_Name][i-1].IsOnline = 1
		else	
			GMT2.GetChar[Account_Name][i-1].IsOnline = 0
		end
		--checks for the faction
		if Splitted_Table[i]:find("ORDER") then
			GMT2.GetChar[Account_Name][i-1].Faction = 1
		elseif Splitted_Table[i]:find("DESTRO") then
			GMT2.GetChar[Account_Name][i-1].Faction = 2
		end
		--checks misc info
		GMT2.GetChar[Account_Name][i-1].Char_Name = Splitted_Table[i]:match("%NAME:(.+)% LEVEL.")			
		GMT2.GetChar[Account_Name][i-1].Level = tonumber(Splitted_Table[i]:match("%LEVEL:(.+)% RENOWN."))	
		GMT2.GetChar[Account_Name][i-1].Renown = tonumber(Splitted_Table[i]:match("%RENOWN:(.+)% CLASS."))		
		GMT2.GetChar[Account_Name][i-1].Class = Splitted_Table[i]:match("%CLASS:(.+)")		
	end
local ListStuff = "GetChar_"..GMT2.GetChar[Account_Name].Account	
if DoesWindowExist(ListStuff) == false then CreateWindowFromTemplate(ListStuff,"GetCharWindow_Template", "Root") end
	LabelSetText (ListStuff.."Name",L"GMT2 Getchar")	
	LabelSetText (ListStuff.."Item1Title",L"Account: ")
	LabelSetText (ListStuff.."Item1Text",towstring(GMT2.GetChar[Account_Name].Account))	
	WindowSetShowing(ListStuff.."Item1EditBox",false)
	ButtonSetText( ListStuff.."OnlineButton",  L"<icon57>")
	ButtonSetText( ListStuff.."IconButton",  L"<icon43>")	
	ButtonSetText( ListStuff.."NameButton",  L"Name")	
	ButtonSetText( ListStuff.."LevelButton",  L"<icon52>")		
	ButtonSetText( ListStuff.."RenownButton",  L"<icon45>")	
	for row = 1, GMT2.GetChar[Account_Name].Slots+1 do
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        local targetRowWindow = ListStuff.."ListBoxRow"..row.."BG"
        WindowSetTintColor(ListStuff.."ListBoxRow"..row.."BG", color.r, color.g, color.b )
        WindowSetAlpha(ListStuff.."ListBoxRow"..row.."BG", color.a )
    end
for row, data in ipairs(GMT2.GetChar[Account_Name]) do
    if row < GMT2.GetChar[Account_Name].Slots + 1 then
        local rowName = ListStuff .. "ListBoxRow" .. row
        local Faction = GMT2.GetChar[Account_Name][row].Faction or 0
        --local class = tostring(GMT2.GetChar[Account_Name][row].Class)
        local class = tostring(GMT2.GetChar[Account_Name][row].Class):gsub("^%s*(.-)%s*$", "%1")       
        local careerIconMapping = GMT2.GetChar.CareerToIcon[class]      
        if careerIconMapping then
            local careerIconID = Icons.GetCareerIconIDFromCareerLine(careerIconMapping)
            if not careerIconID or (type(careerIconID) ~= "number" and type(careerIconID) ~= "string") then
            else
                local texture, x, y, disabledTexture = GetIconData(tonumber(careerIconID))
                if not texture then
                else
                    -- Continue with the rest of your logic here...
                WindowSetShowing(rowName .. "Online", false)
                LabelSetText(rowName .. "Char_Name", towstring(GMT2.GetChar[Account_Name][row].Char_Name))
                LabelSetText(rowName .. "Renown", towstring(GMT2.GetChar[Account_Name][row].Renown))
                LabelSetText(rowName .. "Level", towstring(GMT2.GetChar[Account_Name][row].Level))
                CircleImageSetTexture(rowName .. "ButtonIcon", texture, 16, 16)
                LabelSetTextColor(rowName .. "Char_Name", DefaultColor.RealmColors[Faction].r, DefaultColor.RealmColors[Faction].g, DefaultColor.RealmColors[Faction].b)
                WindowSetTintColor(rowName .. "Button", DefaultColor.RealmColors[Faction].r, DefaultColor.RealmColors[Faction].g, DefaultColor.RealmColors[Faction].b)
                WindowSetTintColor(rowName .. "ButtonIcon", 255, 255, 255)
                WindowSetShowing(rowName .. "Online", GMT2.GetChar[Account_Name][row].IsOnline > 0)
                
                if GMT2.GetChar[Account_Name][row].IsOnline > 0 then
                    WindowSetTintColor(ListStuff .. "ListBoxRow" .. row .. "BG", 30, 128, 30)
                    WindowSetAlpha(ListStuff .. "ListBoxRow" .. row .. "BG", 0.35)
                end
            end
		end
        else
        end
    end
end

for i=GMT2.GetChar[Account_Name].Slots+1 , 24 do
WindowSetShowing(ListStuff.."ListBoxRow"..i,false)
end
WindowSetDimensions(ListStuff,345,95+(#GMT2.GetChar[Account_Name]*32))

return
end

function GMT2.GetChar.LClic()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name	
	local _index = WindowGetId(WindowName)	
	local SubString = string.gsub(WindowGetParent(WinParent),"GetChar_","")
	local NameSplit = StringSplit(tostring(GMT2.GetChar[SubString][_index].Char_Name), " ")	
	PlayerMenuWindow.ShowMenu(towstring(NameSplit[1]))
end
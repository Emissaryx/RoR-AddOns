GMT2.FindIp = {}
GMT2.FindIp.IpTable = {}

local MAX_IP_ROWS    = 50
local ROW_PIXEL_H    = 22
local WINDOW_BASE_H  = 90
local WINDOW_BASE_W  = 320

local CreateWindowFromTemplate  = CreateWindowFromTemplate
local LabelSetText              = LabelSetText
local TextEditBoxSetText        = TextEditBoxSetText
local ButtonSetText             = ButtonSetText
local WindowSetShowing          = WindowSetShowing
local WindowSetTintColor        = WindowSetTintColor
local WindowSetAlpha            = WindowSetAlpha
local DoesWindowExist           = DoesWindowExist
local ListUtils_GetAltRowColor  = DataUtils.GetAlternatingRowColor



function GMT2.FindIp.Input(Table)

GMT2.FindIp.IpTable = Table
local IPNumber = wstring.match(towstring(Table[1]),L"IP matches for (.+):") 
local ListStuff = "GMT2_FindIp"
if DoesWindowExist(ListStuff) == false then CreateWindowFromTemplate(ListStuff,"CheckIPFind_Window_Template", "Root") end

	LabelSetText (ListStuff.."Title",L"GMT2 FindIP")
	LabelSetText (ListStuff.."IPFindLabel",L"IP Range: ")
	TextEditBoxSetText (ListStuff.."EditBox",towstring(IPNumber))
	
	ButtonSetText( ListStuff.."NameButton",  L"Character Name")
	for row = 1, #Table do
        local row_mod = math.mod(row, 2)
        color = ListUtils_GetAltRowColor( row_mod )
        
        local targetRowWindow = ListStuff.."ListBoxRow"..row.."BG"
        WindowSetTintColor(ListStuff.."ListBoxRow"..row.."BG", color.r, color.g, color.b )
        WindowSetAlpha(ListStuff.."ListBoxRow"..row.."BG", color.a )
    end

   for i=1, #Table-1 do
  --      if row < GMTools.GetChars[Table_Name].Slots+1 then
        local rowName   = ListStuff.."ListBoxRow"..i
		WindowSetShowing(ListStuff.."ListBoxRow"..i,true)
		LabelSetText(rowName.."Buff_Name", towstring(Table[i+1]) or L"")
	
		
--end
end


for i=#Table , MAX_IP_ROWS do
WindowSetShowing(ListStuff.."ListBoxRow"..i,false)
end
WindowSetDimensions(ListStuff,WINDOW_BASE_W,WINDOW_BASE_H+((#Table-1)*ROW_PIXEL_H))


end

function GMT2.FindIp.UpdateBox()
local ListStuff = "GMT2_FindIp"
GMT2.FindIp.SlashCommand(TextEditBoxGetText(ListStuff.."EditBox"))

end

function GMT2.FindIp.SlashCommand(range)

				GMT2.Command["findip"] = 1
				GMT2.StartMachine()
				SendChatText(L"]csr findip "..towstring(range), ChatSettings.Channels[0].serverCmd)		

end

function GMT2.FindIp.LClic()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name	
	local _index = WindowGetId(WindowName)	
	local SubString = string.gsub(WindowGetParent(WinParent),"GMT2_FindIp","")
	PlayerMenuWindow.ShowMenu(towstring(GMT2.FindIp.IpTable[_index+1]))
end
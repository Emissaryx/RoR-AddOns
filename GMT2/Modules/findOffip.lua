GMT2.FindOffIp = {}
GMT2.FindOffIp.IpTable = {}
GMT2.FindOffIp.Range = nil

local MAX_ROWS = 50
local ROW_H   = 22
local BASE_W  = 320
local BASE_H  = 90
local CWFT    = CreateWindowFromTemplate
local LST     = LabelSetText
local WEBT    = TextEditBoxSetText
local WSS     = WindowSetShowing
local WSTD    = WindowSetDimensions


function GMT2.FindOffIp.Input(Table)
GMT2.FindOffIp.IpTable = Table
local IPNumber = GMT2.FindOffIp.Range --wstring.match(towstring(Table[1]),L"IP matches for (.+):") 
local ListStuff = "GMT2_FindOffIp"
if DoesWindowExist(ListStuff) == false then CWFT(ListStuff,"CheckIPFind_Window_Template", "Root") end

	LST (ListStuff.."Title",L"GMT2 FindOffIp")
	LST (ListStuff.."IPFindLabel",L"IP Range: ")
	WEBT (ListStuff.."EditBox",towstring(IPNumber))
	
	ButtonSetText( ListStuff.."NameButton",  L"Character Name")
	for row = 1, #Table do
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        local targetRowWindow = ListStuff.."ListBoxRow"..row.."BG"
        WindowSetTintColor(ListStuff.."ListBoxRow"..row.."BG", color.r, color.g, color.b )
        WindowSetAlpha(ListStuff.."ListBoxRow"..row.."BG", color.a )
    end

   for i=1, #Table-1 do
  --      if row < GMTools.GetChars[Table_Name].Slots+1 then
        local rowName   = ListStuff.."ListBoxRow"..i
		WSS(ListStuff.."ListBoxRow"..i,true)
		LST(rowName.."Buff_Name", towstring(Table[i+1]) or L"")
	
		
--end
end


for i=#Table , MAX_ROWS do
WSS(ListStuff.."ListBoxRow"..i,false)
end
WSTD(ListStuff,BASE_W,BASE_H+((#Table-1)*ROW_H))


end

function GMT2.FindOffIp.UpdateBox()
local ListStuff = "GMT2_FindOffIp"
GMT2.FindOffIp.SlashCommand(TextEditBoxGetText(ListStuff.."EditBox"))

end


function GMT2.FindOffIp.SlashCommand(range)

				GMT2.Command["findoffip"] = 1
				GMT2.FindOffIp.Range = range
				GMT2.StartMachine()
				SendChatText(L"]csr findipoffline "..towstring(range), ChatSettings.Channels[0].serverCmd)
				d(L"findoffip")

end

function GMT2.FindOffIp.LClic()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)	
	local WindowName = SystemData.MouseOverWindow.name	
	local _index = WindowGetId(WindowName)	
	local SubString = string.gsub(WindowGetParent(WinParent),"GMT2_FindOffIp","")
	PlayerMenuWindow.ShowMenu(towstring(GMT2.FindOffIp.IpTable[_index+1]))
end
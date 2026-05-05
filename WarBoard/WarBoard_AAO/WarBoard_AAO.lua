if not WarBoard_AAO then 
	WarBoard_AAO = {} 
end

local WarBoard_AAO = WarBoard_AAO
local ModName = "WarBoard_AAO"
local LabelSetTextColor, LabelSetText, WindowSetAlpha, Tooltips, WindowGetShowing, towstring, string, pairs = LabelSetTextColor, LabelSetText, WindowSetAlpha, Tooltips, WindowSetShowing, towstring, string, pairs
local TimeLeft = 1
local TimeDelay = 1
local AAO = 0
local Apathy = 0

-- local functions
local function NumberPercent(value)
	return towstring(value)..L"%"
end

local function GetData()
	Tooltips.SetTooltipText(3, 1, L"Current Zone:")
	Tooltips.SetTooltipText(3, 3, GetZoneName(GameData.Player.zone))
	Tooltips.SetTooltipText(4, 1, L"AAO:")
	Tooltips.SetTooltipText(4, 3, NumberPercent(AAO))
	Tooltips.SetTooltipText(5, 1, L"Apathy:")
	Tooltips.SetTooltipText(5, 3, NumberPercent(Apathy))
	Tooltips.Finalize()
end

local function LabelSetTextAAO()
	LabelSetText(ModName.."Title2", NumberPercent(AAO)..L" / "..NumberPercent(Apathy))
end

-- gloabl functions
function WarBoard_AAO.Initialize()
	if WarBoard.AddMod(ModName) then
		WindowSetAlpha(ModName.."Background",0.25)
		LabelSetTextColor(ModName.."Title",255,200,0)
		LabelSetText(ModName.."Title", L"AAO / Apathy")
		LabelSetTextColor(ModName.."Title2",255,255,255)		
		LabelSetTextAAO()
		RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "WarBoard_AAO.PlayerZoneChanged")
	end
end

function WarBoard_AAO.OnShutdown()
	UnRegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "WarBoard_AAO.PlayerZoneChanged")
end

function WarBoard_AAO.OnUpdate(elapsedTime)
	TimeLeft = TimeLeft - elapsedTime;
	if (TimeLeft > 0) then
	    return
	end
	AAO = 0
	Apathy = 0
	local allEffects = GetBuffs(GameData.BuffTargetType.SELF)
	for _, effect in pairs(allEffects) do
		if effect.abilityId == 26006 then
			local percent = effect.effectText:match(L"%d+")
			local direction = effect.effectText:find(L"increased")
			if direction ~= nil then
				direction = L""
			else
				direction = L"-"
			end
			Apathy = direction..percent
		end
		if effect.abilityId == 24658 then
			local percent = effect.effectText:match(L"%d+")			
			AAO = percent
		end
	end
	LabelSetTextAAO()
	TimeLeft = TimeDelay;
end

function WarBoard_AAO.OnMouseOver()
	Tooltips.CreateTextOnlyTooltip("WarBoard_AAO", nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_AAO"))
	local text = GetStringFromTable("CurrentEventsStrings", StringTables.CurrentEvents.MAP_BUTTON_TOOLTIP)
	Tooltips.SetTooltipText(1, 1, L"AAO / Apathy Tracker")
	Tooltips.SetUpdateCallback(GetData)
end

function WarBoard_AAO.PlayerZoneChanged()
	AAO = 0
	Apathy = 0
end
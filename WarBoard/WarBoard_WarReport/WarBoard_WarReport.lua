if not WarBoard_WarReport then 
	WarBoard_WarReport = {} 
end

local WarBoard_WarReport = WarBoard_WarReport
local ModName = "WarBoard_WarReport"
local LabelSetTextColor, LabelSetText, WindowSetAlpha, Tooltips, WindowGetShowing, WindowSetShowing, towstring, string, tonumber, math = LabelSetTextColor, LabelSetText, WindowSetAlpha, Tooltips, WindowGetShowing, WindowSetShowing, towstring, string, tonumber, math
local m_playerCurJumpCooldownTimerSeconds = 0
local TimeLeft = 1;
local TimeDelay = 1;
local ReadyLabel = L"Ready"

--local functions
local function UpdateCooldownTimer(secondsPassed)
    if (m_playerCurJumpCooldownTimerSeconds > 0) then
        m_playerCurJumpCooldownTimerSeconds = m_playerCurJumpCooldownTimerSeconds - secondsPassed
        if(m_playerCurJumpCooldownTimerSeconds < 0) then
            m_playerCurJumpCooldownTimerSeconds = 0       
        end        
		LabelSetText(ModName.."Title2",WarBoard_WarReport.FormatSeconds(m_playerCurJumpCooldownTimerSeconds))
    else
		LabelSetText(ModName.."Title2", ReadyLabel);
	end
end

local function OnJumpTimerUpdated(playerCurrentTimerSeconds, jumpCooldownTimerSeconds)
    m_playerCurJumpCooldownTimerSeconds = playerCurrentTimerSeconds
	UpdateCooldownTimer(1)
end

local function GetData()
	if (m_playerCurJumpCooldownTimerSeconds > 0) then
		Tooltips.SetTooltipText(3, 1, towstring(GetString(StringTables.Default.TEXT_QUEST_TIME_REMAINING)))
		Tooltips.SetTooltipText(3, 3, WarBoard_WarReport.FormatSeconds(m_playerCurJumpCooldownTimerSeconds))
	end
	Tooltips.Finalize()
end

local function ToolTip()
	local text = GetStringFromTable("CurrentEventsStrings", StringTables.CurrentEvents.MAP_BUTTON_TOOLTIP)
	Tooltips.SetTooltipText(1, 1, text)
	Tooltips.SetTooltipText(1, 3, L"("..KeyUtils.GetFirstBindingNameForAction("TOGGLE_CURRENT_EVENTS_WINDOW")..L")")
	Tooltips.SetTooltipColor(1, 3, 140, 100, 0)
	Tooltips.SetTooltipActionText(L"Left Mouse to open the War Report window")
end

-- global functions
function WarBoard_WarReport.Initialize()
	if WarBoard.AddMod(ModName) then
		OnJumpTimerUpdated(CurrentEventsGetTimers())    
		WindowSetAlpha(ModName.."Background",0.25)
		LabelSetTextColor(ModName.."Title",255,200,0)
		LabelSetText(ModName.."Title", L"War Report")
		LabelSetTextColor(ModName.."Title2",255,255,255)		
		LabelSetText(ModName.."Title2", ReadyLabel)
		WarBoard_WarReport.OldOnMouseOverCurrentEvents = EA_Window_OverheadMap.OnMouseOverCurrentEvents
		EA_Window_OverheadMap.OnMouseOverCurrentEvents = WarBoard_WarReport.OnMouseOverCurrentEvents
	end
end

function WarBoard_WarReport.OnShutdown()
	EA_Window_OverheadMap.OnMouseOverCurrentEvents = WarBoard_WarReport.OldOnMouseOverCurrentEvents
end

function WarBoard_WarReport.OnClick()
	local Wn = "EA_Window_CurrentEvents"
	WindowSetShowing(Wn, not WindowGetShowing(Wn))
end

function WarBoard_WarReport.OnUpdate(elapsedTime)
	TimeLeft = TimeLeft - elapsedTime;
	if (TimeLeft > 0) then
	    return
	end
	if m_playerCurJumpCooldownTimerSeconds == 0 then 
		CurrentEventsUpdate()
	end
	OnJumpTimerUpdated(CurrentEventsGetTimers())  
	TimeLeft = TimeDelay;
end

function WarBoard_WarReport.OnMouseOver()
	Tooltips.CreateTextOnlyTooltip("WarBoard_WarReport", nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_WarReport"))
	ToolTip()
	Tooltips.Finalize()
end

function WarBoard_WarReport.OnMouseOverCurrentEvents()
	Tooltips.CreateTextOnlyTooltip(SystemData.MouseOverWindow.name, nil) 
	ToolTip()
	Tooltips.SetUpdateCallback(GetData)
	Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_LEFT)
end

-- ToDO: Create default Warboard function
function WarBoard_WarReport.FormatSeconds(seconds)
	local seconds = tonumber(seconds)
	if seconds <= 0 then
		return ReadyLabel;
	else
		local hours = string.format("%02.f", math.floor(seconds/3600));
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return towstring(mins..":"..secs)
	end
end
WarBoard_Marks = WarBoard_Marks or {}
WarBoard_Marks_Settings = WarBoard_Marks_Settings or {}

local towstring, Tooltips = towstring, Tooltips

local defaults = {
	crestId = 12500,
	goalCount = 0,
	version = 1,
}

local settings = nil
local session = nil

local function applyDefaults(dst, src)
	for k, v in pairs(src) do
		if dst[k] == nil then
			dst[k] = v
		end
	end
end

local function newSession()
	return {
		initialCrestCount = 0,
		currentCrestCount = 0,
		displayMode = 1, -- 1=current, 2=earned, 3=remaining
	}
end

local function getEarnedCount()
	return (session.currentCrestCount or 0) - (session.initialCrestCount or 0)
end

local function chat(msg)
	EA_ChatWindow.Print(L"[Marks]: " .. msg)
end

local function getGoalStatus()
	local goal = tonumber(settings.goalCount) or 0
	local current = tonumber(session.currentCrestCount) or 0

	if goal <= 0 then
		return "none", nil
	end

	local diff = goal - current

	if diff > 0 then
		return "remaining", diff
	elseif diff == 0 then
		return "met", 0
	else
		return "over", math.abs(diff)
	end
end

function WarBoard_Marks.getMarksCount()
	local data = DataUtils.GetCurrencyItems()
	local MarksCount = 0

	for _, v in ipairs(data) do
		if v.uniqueID == settings.crestId then
			MarksCount = MarksCount + (tonumber(v.stackCount) or 0)
		end
	end

	return MarksCount
end

function WarBoard_Marks.Initialize()
	if not WarBoard.AddMod("WarBoard_Marks") then
		return
	end

	WarBoard_Marks_Settings = WarBoard_Marks_Settings or {}
	applyDefaults(WarBoard_Marks_Settings, defaults)
	settings = WarBoard_Marks_Settings

	-- purge junk from older versions
	settings.initialCrestCount = nil
	settings.currentCrestCount = nil
	settings.amount = nil
	settings.displayOption = nil
	settings.displayMode = nil

	-- hard reset session every load/login
	session = newSession()

	local texture, x, y = GetIconData(15441)
	DynamicImageSetTexture("WarBoard_MarksIcon", texture, x, y)

	RegisterEventHandler(SystemData.Events.PLAYER_CURRENCY_SLOT_UPDATED, "WarBoard_Marks.updateMarks")

	if LibSlash and not LibSlash.IsSlashCmdRegistered("Marks") then
		LibSlash.RegisterWSlashCmd("Marks", WarBoard_Marks.SlashHandler)
	end

	-- seed current count immediately
	session.currentCrestCount = WarBoard_Marks.getMarksCount()

	-- old reliable baseline logic
	if session.initialCrestCount == 0 and session.currentCrestCount > 0 then
		session.initialCrestCount = session.currentCrestCount
	end

	WarBoard_Marks.updateLabel()
end

function WarBoard_Marks.updateMarks()
	session.currentCrestCount = WarBoard_Marks.getMarksCount()

	-- old reliable baseline logic
	if session.initialCrestCount == 0 and session.currentCrestCount > 0 then
		session.initialCrestCount = session.currentCrestCount
	end

	WarBoard_Marks.updateLabel()
end

function WarBoard_Marks.updateLabel()
	local current = tonumber(session.currentCrestCount) or 0
	local earned = getEarnedCount()
	local mode = session.displayMode or 1

	if mode == 1 then
		LabelSetText("WarBoard_MarksText", towstring(current))
		LabelSetTextColor("WarBoard_MarksText", 255, 200, 0)

	elseif mode == 2 then
		LabelSetText("WarBoard_MarksText", towstring(earned))
		LabelSetTextColor("WarBoard_MarksText", 0, 180, 255)

	else
		local status, value = getGoalStatus()

		if status == "none" then
			LabelSetText("WarBoard_MarksText", L"-")
			LabelSetTextColor("WarBoard_MarksText", 255, 0, 0)
		elseif status == "remaining" then
			LabelSetText("WarBoard_MarksText", towstring(value))
			LabelSetTextColor("WarBoard_MarksText", 255, 0, 0)
		elseif status == "met" then
			LabelSetText("WarBoard_MarksText", L"0")
			LabelSetTextColor("WarBoard_MarksText", 0, 255, 0)
		elseif status == "over" then
			LabelSetText("WarBoard_MarksText", towstring(value))
			LabelSetTextColor("WarBoard_MarksText", 0, 255, 0)
		end
	end
end

function WarBoard_Marks.OnUpdate()
end

function WarBoard_Marks.OnLClick()
	session.initialCrestCount = session.currentCrestCount or 0
	WarBoard_Marks.updateLabel()
	chat(L"earned baseline reset")
end

function WarBoard_Marks.OnRClick()
	session.displayMode = (session.displayMode or 1) + 1
	if session.displayMode > 3 then
		session.displayMode = 1
	end

	WarBoard_Marks.updateLabel()

	if session.displayMode == 1 then
		chat(L"display mode: current")
	elseif session.displayMode == 2 then
		chat(L"display mode: earned")
	else
		chat(L"display mode: remaining")
	end
end

function WarBoard_Marks.OnMClick()
	settings.goalCount = 0
	WarBoard_Marks.updateLabel()
	chat(L"goal cleared")
end

function WarBoard_Marks.SlashHandler(input)
	local strInput = WStringToString(input or L"")
	local goal = tonumber(strInput)

	if not goal then
		chat(L"usage /Marks 5000")
		return
	end

	if goal < 0 then
		goal = 0
	end

	settings.goalCount = goal
	WarBoard_Marks.updateLabel()
	chat(L"goal set to " .. towstring(goal))
end

function WarBoard_Marks.OnMouseOver()
	local earned = getEarnedCount()
	local current = session.currentCrestCount or 0
	local goal = settings.goalCount or 0
	local mode = session.displayMode or 1
	local modeText = L"Current"

	if mode == 2 then
		modeText = L"Earned"
	elseif mode == 3 then
		modeText = L"Remaining"
	end

	local status, value = getGoalStatus()

	Tooltips.CreateTextOnlyTooltip("WarBoard_Marks", nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_Marks"))
	Tooltips.SetTooltipText(1, 1, L"Mentor's Marks")
	Tooltips.SetTooltipText(2, 1, L"Mode: " .. modeText)
	Tooltips.SetTooltipText(3, 1, L"Current: " .. towstring(current))
	Tooltips.SetTooltipText(4, 1, L"Earned: " .. towstring(earned))

	if status == "remaining" then
		Tooltips.SetTooltipText(5, 1, L"Remaining: " .. towstring(value))
		Tooltips.SetTooltipText(6, 1, L"Goal: " .. towstring(goal))
	elseif status == "met" then
		Tooltips.SetTooltipText(5, 1, L"Over Goal")
		Tooltips.SetTooltipText(6, 1, L"Goal: " .. towstring(goal))
	elseif status == "over" then
		Tooltips.SetTooltipText(5, 1, L"Over Goal: " .. towstring(value))
		Tooltips.SetTooltipText(6, 1, L"Goal: " .. towstring(goal))
	else
		Tooltips.SetTooltipText(5, 1, L"Goal: " .. towstring(goal))
	end

	Tooltips.SetTooltipText(7, 1, L"Left-click: reset session earned")
	Tooltips.SetTooltipText(8, 1, L"Right-click: cycle current/earned/remaining")
	Tooltips.SetTooltipText(9, 1, L"Middle-click: clear goal")
	Tooltips.SetTooltipText(10, 1, L"/Marks <number>: set goal")
	Tooltips.Finalize()
end
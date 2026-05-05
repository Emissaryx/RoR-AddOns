WarBoard_Tokens = WarBoard_Tokens or {}
WarBoard_Tokens_Settings = WarBoard_Tokens_Settings or {}

local towstring, Tooltips = towstring, Tooltips

local defaults = {
	crestId = 129838871,
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
	EA_ChatWindow.Print(L"[Tokens]: " .. msg)
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

function WarBoard_Tokens.getTokensCount()
	local data = DataUtils.GetCurrencyItems()
	local TokensCount = 0

	for _, v in ipairs(data) do
		if v.uniqueID == settings.crestId then
			TokensCount = TokensCount + (tonumber(v.stackCount) or 0)
		end
	end

	return TokensCount
end

function WarBoard_Tokens.Initialize()
	if not WarBoard.AddMod("WarBoard_Tokens") then
		return
	end

	WarBoard_Tokens_Settings = WarBoard_Tokens_Settings or {}
	applyDefaults(WarBoard_Tokens_Settings, defaults)
	settings = WarBoard_Tokens_Settings

	-- purge junk from older versions
	settings.initialCrestCount = nil
	settings.currentCrestCount = nil
	settings.amount = nil
	settings.displayOption = nil
	settings.displayMode = nil

	-- hard reset session every load/login
	session = newSession()

	local texture, x, y = GetIconData(25024)
	DynamicImageSetTexture("WarBoard_TokensIcon", texture, x, y)

	RegisterEventHandler(SystemData.Events.PLAYER_CURRENCY_SLOT_UPDATED, "WarBoard_Tokens.updateTokens")

	if LibSlash and not LibSlash.IsSlashCmdRegistered("Tokens") then
		LibSlash.RegisterWSlashCmd("Tokens", WarBoard_Tokens.SlashHandler)
	end

	-- seed current count immediately
	session.currentCrestCount = WarBoard_Tokens.getTokensCount()

	-- old reliable baseline logic
	if session.initialCrestCount == 0 and session.currentCrestCount > 0 then
		session.initialCrestCount = session.currentCrestCount
	end

	WarBoard_Tokens.updateLabel()
end

function WarBoard_Tokens.updateTokens()
	session.currentCrestCount = WarBoard_Tokens.getTokensCount()

	-- old reliable baseline logic
	if session.initialCrestCount == 0 and session.currentCrestCount > 0 then
		session.initialCrestCount = session.currentCrestCount
	end

	WarBoard_Tokens.updateLabel()
end

function WarBoard_Tokens.updateLabel()
	local current = tonumber(session.currentCrestCount) or 0
	local earned = getEarnedCount()
	local mode = session.displayMode or 1

	if mode == 1 then
		LabelSetText("WarBoard_TokensText", towstring(current))
		LabelSetTextColor("WarBoard_TokensText", 255, 200, 0)

	elseif mode == 2 then
		LabelSetText("WarBoard_TokensText", towstring(earned))
		LabelSetTextColor("WarBoard_TokensText", 0, 180, 255)

	else
		local status, value = getGoalStatus()

		if status == "none" then
			LabelSetText("WarBoard_TokensText", L"-")
			LabelSetTextColor("WarBoard_TokensText", 255, 0, 0)
		elseif status == "remaining" then
			LabelSetText("WarBoard_TokensText", towstring(value))
			LabelSetTextColor("WarBoard_TokensText", 255, 0, 0)
		elseif status == "met" then
			LabelSetText("WarBoard_TokensText", L"0")
			LabelSetTextColor("WarBoard_TokensText", 0, 255, 0)
		elseif status == "over" then
			LabelSetText("WarBoard_TokensText", towstring(value))
			LabelSetTextColor("WarBoard_TokensText", 0, 255, 0)
		end
	end
end

function WarBoard_Tokens.OnUpdate()
end

function WarBoard_Tokens.OnLClick()
	session.initialCrestCount = session.currentCrestCount or 0
	WarBoard_Tokens.updateLabel()
	chat(L"earned baseline reset")
end

function WarBoard_Tokens.OnRClick()
	session.displayMode = (session.displayMode or 1) + 1
	if session.displayMode > 3 then
		session.displayMode = 1
	end

	WarBoard_Tokens.updateLabel()

	if session.displayMode == 1 then
		chat(L"display mode: current")
	elseif session.displayMode == 2 then
		chat(L"display mode: earned")
	else
		chat(L"display mode: remaining")
	end
end

function WarBoard_Tokens.OnMClick()
	settings.goalCount = 0
	WarBoard_Tokens.updateLabel()
	chat(L"goal cleared")
end

function WarBoard_Tokens.SlashHandler(input)
	local strInput = WStringToString(input or L"")
	local goal = tonumber(strInput)

	if not goal then
		chat(L"usage /Tokens 5000")
		return
	end

	if goal < 0 then
		goal = 0
	end

	settings.goalCount = goal
	WarBoard_Tokens.updateLabel()
	chat(L"goal set to " .. towstring(goal))
end

function WarBoard_Tokens.OnMouseOver()
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

	Tooltips.CreateTextOnlyTooltip("WarBoard_Tokens", nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_Tokens"))
	Tooltips.SetTooltipText(1, 1, L"War Tokens")
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
	Tooltips.SetTooltipText(10, 1, L"/Tokens <number>: set goal")
	Tooltips.Finalize()
end
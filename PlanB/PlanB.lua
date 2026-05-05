-- =========================
-- PlanB (Clean Rewrite)
-- =========================

if not PlanB then PlanB = {} end

PlanB.data      = PlanB.data or {}
PlanB.data.page = PlanB.data.page or {}
PlanB.careerOK  = false

-- =========================
-- Local Caches (Performance)
-- =========================
local StringToWString      = StringToWString
local TextLogAddEntry      = TextLogAddEntry
local RegisterEventHandler = RegisterEventHandler
local SetHotbarPage        = SetHotbarPage
local tonumber             = tonumber
local tostring             = tostring
local string_lower         = string.lower
local string_find          = string.find
local string_gsub          = string.gsub
local string_match         = string.match

-- =========================
-- Utility
-- =========================
local function ChatPrint(text)
	EA_ChatWindow.Print(StringToWString(text))
end

local function PrintColor(text, color)
	local wtext = StringToWString(text)
	color = color or 3

	if color > 4 then
		TextLogAddEntry("Combat", SystemData.ChatLogFilters.COMBAT_DEFAULT, wtext)
	else
		TextLogAddEntry("Chat", color, wtext)
	end
end

local function DisplayAlert(text)
	SystemData.AlertText.VecType = { SystemData.AlertText.Types.ABILITY }
	SystemData.AlertText.VecText = { StringToWString(text) }
	AlertTextWindow.AddAlert()
end

-- =========================
-- Initialize
-- =========================
function PlanB.Initialize()
	if PlanB._initialized then return end
	PlanB._initialized = true

	if not LibSlash then
		PrintColor("Warning: PlanB couldn't find LibSlash!")
		return
	end

	if LibSlash.IsSlashCmdRegistered("planb") then
		PrintColor("Warning: /planb already registered by another addon.")
		return
	end

	LibSlash.RegisterSlashCmd("planb", function(input) PlanB.Command(input or "") end)

	-- Hard enforced defaults (always overwrite to safe config)
	PlanB.data.active  = PlanB.data.active ~= false
	PlanB.data.hotbar  = 1
	PlanB.data.silent  = PlanB.data.silent or false
	PlanB.data.pagemax = 7

	PlanB.data.page[0] = 1
	PlanB.data.page[1] = 6
	PlanB.data.page[2] = 7

	RegisterEventHandler(SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED, "PlanB.SetPage")
	RegisterEventHandler(SystemData.Events.PLAYER_DEATH,                   "PlanB.SetPage")
	RegisterEventHandler(SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED,     "PlanB.SetPage")
	RegisterEventHandler(SystemData.Events.LOADING_END,                    "PlanB.HandleLoading")
	RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE,               "PlanB.HandleLoading")
end

-- =========================
-- Slash Command
-- =========================
function PlanB.Command(input)
	if string_find(input, "%S") == nil then
		PlanB.data.active = not PlanB.data.active
		PlanB.HandleLoading()
		if not PlanB.data.silent then PlanB.DisplaySettings() end
		return
	end

	input = string_lower(input)
	input = string_gsub(input, "(%s+)", " ")
	input = string_gsub(input, "%s*([=,])%s*", "%1")

	for token in input:gmatch("([%w%p=]+)") do
		local command = string_match(token, "(%w+)=?")
		local value   = string_match(token, "=([%d,]+)")

		if command == "usage" or command == "help" then
			PlanB.Usage()
			return

		elseif command == "settings" then
			PlanB.DisplaySettings()
			return

		elseif command == "silent" then
			PlanB.data.silent = not PlanB.data.silent
			PrintColor(PlanB.data.silent and "PlanB is now silent" or "PlanB is no longer silent")
			return

		elseif command == "hotbar" and value then
			local bar = tonumber(value)
			if bar ~= 1 then
			PrintColor("Warning: PlanB is only safe on hotbar 1 due to anti-NerfedButton checks.", 4)
		else
			PlanB.data.hotbar = 1
		end

		elseif command == "pages" and value then
			local i = 0
			for num in value:gmatch("(%d+)") do
				local page = tonumber(num)
				if page and page >= 1 and page <= 9 then
					PlanB.data.page[i] = page
				else
					PrintColor("Invalid page: " .. tostring(page), 4)
				end
				i = i + 1
				if i > 2 then break end
			end

		elseif command == "pagemax" and value then
			local max = tonumber(value)
			if max and max >= 5 and max <= 9 then
				PlanB.data.pagemax = max
				PlanB.SetPageMax()
				PrintColor("Max pages set to " .. tostring(max), 4)
			else
				PrintColor("Warning - pagemax must be 5-9", 4)
			end
		end
	end

	PlanB.SetPage()
	PlanB.DisplaySettings()
end

-- =========================
-- Career Validation
-- =========================
function PlanB.ValidCareer()
	if not GameData or not GameData.Player or not GameData.Player.career then
		return false
	end

	local line = GameData.Player.career.line
	return (line == GameData.CareerLine.SWORDMASTER or line == GameData.CareerLine.BLACK_ORC)
end

-- =========================
-- Core Logic
-- =========================
function PlanB.SetPage()
	if not PlanB.data.active then return end
	if not PlanB.careerOK then return end

	if not CareerResource then return end
	local res = CareerResource:GetCurrent()
	local page = PlanB.data.page[res]

	if page then
		SetHotbarPage(PlanB.data.hotbar, page)
	end
end

function PlanB.HandleLoading()
	-- Always enforce safe config
	PlanB.data.hotbar  = 1
	PlanB.data.pagemax = 7
	PlanB.data.page[0] = 1
	PlanB.data.page[1] = 6
	PlanB.data.page[2] = 7

	PlanB.careerOK = PlanB.ValidCareer()

	if PlanB.careerOK then
		PlanB.SetPageMax()
	end

	PlanB.SetPage()
end

-- =========================
-- Output
-- =========================
function PlanB.DisplaySettings()
	if not PlanB.data.active then
		PrintColor("PlanB deactivated.")
		return
	end

	PrintColor("PlanB activated.", 4)

	if not PlanB.careerOK then
		PrintColor("PlanB does not work with your current career.")
		return
	end

	PrintColor("Using hotbar " .. PlanB.data.hotbar ..
		", cycling pages " ..
		PlanB.data.page[0] .. " -> " ..
		PlanB.data.page[1] .. " -> " ..
		PlanB.data.page[2], 4)

	PrintColor("Showing " .. GameData.HOTBAR_SWAPPABLE_PAGE_COUNT .. " pages on each hotbar", 4)
end

function PlanB.Usage()
	PrintColor("Planned Balance (PlanB)")
	PrintColor("/planb [hotbar=#] [pages=#,#,#]")
	PrintColor("Defaults: hotbar=1 pages=1,6,7")
	PrintColor("This avoids anti-NerfedButton restrictions.", 4)
	PrintColor("ex: /planb pages=1,6,7 hotbar=1", 4)
	PrintColor("/planb settings - show current config")
	PrintColor("/planb silent - toggle chat output")
	PrintColor("/planb pagemax=# - set page cap (5-9)")
end

function PlanB.SetPageMax()
	GameData.HOTBAR_SWAPPABLE_PAGE_COUNT = PlanB.data.pagemax
end

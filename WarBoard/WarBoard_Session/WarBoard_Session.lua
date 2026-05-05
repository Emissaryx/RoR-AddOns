if not WarBoard_Session then 
	WarBoard_Session = {} 
end

local WarBoard_Session = WarBoard_Session
local GetGameTime, towstring, FormatClock, Tooltips, LabelSetTextColor, LabelSetText = GetGameTime, towstring, TimeUtils.FormatClock, Tooltips, LabelSetTextColor, LabelSetText

local settings = {
	initialXP = 0,
	initialRenown = 0,
	initialClock = 0,
	initialKills = 0,
	initialDBs = 0,
	initialDeaths = 0,
	sessionXP = 0,
	sessionRenown = 0,
	sessionKills = 0,
	sessionDBs = 0,
	sessionDeaths = 0,
	sessionXPTotal = 0,
	sessionRenownTotal = 0,
	initialClockTotal = 0,
	initialMoney = 0,
	sessionGold = 0,
	sessionSilver = 0,
	sessionBrass = 0,
	initialWarCrest = 0,
	sessionWarCrest = 0,
	LoginEnd = true,
	timeToRank = L"-",
	timeToRenown = L"-",
	xpInUse = false,
	renownInUse = false,
}

-- local functions
local function updateSessionTime()
	return GetGameTime() - settings.initialClock
end

local function cappedRenown()
	if GameData.Player.Renown.curRank == 255 or GameData.Player.Renown.curRenownNeeded == nil then
		settings.renownInUse = false
		return true
	end
	return false
end

local function cappedExp()
	if GameData.Player.level == 40 or GameData.Player.Experience.curXpNeeded == nil then
		settings.xpInUse = false
		return true
	end
	return false
end

local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function showTimeToRank()
	settings.xpInUse = not cappedExp()
	local timeDiff = updateSessionTime()
	if timeDiff == 0 or settings.sessionXP == 0 or not settings.xpInUse then
		settings.timeToRank = L"-"
		return
	end
	local xpNeeded = GameData.Player.Experience.curXpNeeded - GameData.Player.Experience.curXpEarned
	local xpPerSecond = settings.sessionXP / timeDiff
	local secToLevel = 0
	if (xpPerSecond > 0) then		
		secToLevel = xpNeeded / xpPerSecond
	end
	secToLevel = round(secToLevel, 0)
	local ltime, _, _ = FormatClock(secToLevel)
	if (secToLevel == 0 or secToLevel >= 360000) then
		settings.timeToRank = towstring(L"-")
	else
		local ltime, _, _ = FormatClock(secToLevel)
		settings.timeToRank = towstring(L""..ltime)
	end
end

local function showTimeToRenown()
	settings.renownInUse = not cappedRenown()
	local timeDiff = updateSessionTime()
	if timeDiff == 0 or settings.sessionRenown == 0 or not settings.renownInUse then
		settings.timeToRenown = L"-"
		return
	end
	local renownNeeded = GameData.Player.Renown.curRenownNeeded - GameData.Player.Renown.curRenownEarned
	local renownPerSecond = settings.sessionRenown / timeDiff
	local secToLevel = renownNeeded / renownPerSecond
	secToLevel = round(secToLevel, 0)
	local ltime, _, _ = FormatClock(secToLevel)
	if (secToLevel == 0 or secToLevel >= 360000) then
		settings.timeToRenown = towstring(L"-")
	else
		local ltime, _, _ = FormatClock(secToLevel)
		settings.timeToRenown = towstring(L""..ltime)
	end
end

local function ResetStats()
	settings.initialClock = GetGameTime()
	settings.timeToRank = L"-"
	settings.timeToRenown = L"-"
	settings.initialXP = GameData.Player.Experience.curXpEarned
	settings.initialRenown = GameData.Player.Renown.curRenownEarned
	settings.initialKills = GameData.Player.RvRStats.LifetimeKills
	settings.initialDBs = GameData.Player.RvRStats.LifetimeDeathBlows
	settings.initialDeaths = GameData.Player.RvRStats.LifetimeDeaths
	settings.sessionKills = 0
	settings.sessionDBs = 0
	settings.sessionDeaths = 0
	settings.sessionXP = 0
	settings.sessionRenown = 0
	settings.initialMoney = GameData.Player.money
	settings.sessionGold = 0
	settings.sessionSilver = 0
	settings.sessionBrass = 0
	settings.initialWarCrest = 0
	local inventory = EA_Window_Backpack.GetItemsFromBackpack(EA_Window_Backpack.TYPE_CURRENCY)
	if inventory ~= nil then
		for inventorySlot = 1, EA_Window_Backpack.numberOfSlots[EA_Window_Backpack.TYPE_CURRENCY] do
			local itemData = inventory[inventorySlot]
			if EA_Window_Backpack.ValidItem(itemData) then
				if (itemData.name == L"War Crest") then
					settings.initialWarCrest = settings.initialWarCrest + itemData.stackCount
				end
			end
		end
	end
	settings.sessionWarCrest = 0
	showTimeToRank()
	showTimeToRenown()
end

local function ResetStatsAll()
	ResetStats()
	settings.initialClockTotal = GetGameTime()
	settings.sessionXPTotal = 0
	settings.sessionRenownTotal = 0
end

local function updateTotalTime()
	return GetGameTime() - settings.initialClockTotal
end
  
local function UpdateStuff()
	settings.renownInUse = not cappedRenown()
	settings.xpInUse = not cappedExp()
    -- Update session stats
	settings.sessionKills = GameData.Player.RvRStats.LifetimeKills-settings.initialKills
	settings.sessionDBs = GameData.Player.RvRStats.LifetimeDeathBlows-settings.initialDBs
	settings.sessionDeaths = GameData.Player.RvRStats.LifetimeDeaths-settings.initialDeaths
    -- more stats here !
	local floor, mod = math.floor, math.mod
	local curMoney = GameData.Player.money - settings.initialMoney
	local g = floor(curMoney / 10000) 
	local s = floor((curMoney - (g * 10000)) / 100)
	local b = mod(curMoney, 100)
	settings.sessionGold = g
	settings.sessionSilver = s
	settings.sessionBrass = b
	settings.sessionWarCrest = 0 
	local inventory = EA_Window_Backpack.GetItemsFromBackpack(EA_Window_Backpack.TYPE_CURRENCY)
	if inventory ~= nil then
		for inventorySlot = 1, EA_Window_Backpack.numberOfSlots[EA_Window_Backpack.TYPE_CURRENCY] do
			local itemData = inventory[inventorySlot]
			if EA_Window_Backpack.ValidItem(itemData) then
				if (itemData.name == L"War Crest") then
					settings.sessionWarCrest = settings.sessionWarCrest + itemData.stackCount
				end
			end
		end
	end
	settings.sessionWarCrest = settings.sessionWarCrest - settings.initialWarCrest
end

-- global functions
function WarBoard_Session.Initialize()
	if (WarBoard.AddMod("WarBoard_Session")) then
	    LabelSetTextColor("WarBoard_SessionText", 255, 200, 0)
	    LabelSetText("WarBoard_SessionText", L"Session Stats")
		settings.renownInUse = not cappedRenown()
		settings.xpInUse = not cappedExp()
        if settings.xpInUse or settings.renownInUse then
            if settings.xpInUse then
				RegisterEventHandler(SystemData.Events.WORLD_OBJ_XP_GAINED, "WarBoard_Session.addXP")
		    end
		    if settings.renownInUse then
				RegisterEventHandler(SystemData.Events.WORLD_OBJ_RENOWN_GAINED, "WarBoard_Session.addRenown")
		    end
        end
		RegisterEventHandler(SystemData.Events.LOADING_END, "WarBoard_Session.LoadingEnd")
		RegisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "WarBoard_Session.LoadingEnd")	
	end
end

function WarBoard_Session.LoadingEnd()
	ResetStatsAll()
	UnregisterEventHandler(SystemData.Events.LOADING_END, "WarBoard_Session.LoadingEnd")
	UnregisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "WarBoard_Session.LoadingEnd")
end

function WarBoard_Session.addXP(_, amount)
	settings.sessionXP = settings.sessionXP + amount
	settings.sessionXPTotal = settings.sessionXPTotal + amount
end

function WarBoard_Session.addRenown(_,amount)
	settings.sessionRenown = settings.sessionRenown + amount
	settings.sessionRenownTotal = settings.sessionRenownTotal + amount
end

function WarBoard_Session.OnLClick()
    ResetStats()
end

function WarBoard_Session.OnRClick()
    ResetStatsAll()
end

function WarBoard_Session.OnMouseOver()
	Tooltips.CreateTextOnlyTooltip("WarBoard_Session", nil)
	Tooltips.AnchorTooltip( WarBoard.GetModToolTipAnchor("WarBoard_Session"))
	Tooltips.SetUpdateCallback(WarBoard_Session.GetSessionData)
end

function WarBoard_Session.GetSessionData()
	local Divider = L"------------------------------"
	if settings.xpInUse then
		showTimeToRank()
	end
	if settings.renownInUse then
		showTimeToRenown()
	end
	UpdateStuff()
	local timeDiff = updateSessionTime()
	local xpPerSecond = 0
	if timeDiff > 0 then
		xpPerSecond = settings.sessionXP / timeDiff
	end	
	local xpPerHour = round(xpPerSecond * 3600,0)
	local renownPerSecond = 0
	if timeDiff > 0 then
		renownPerSecond = settings.sessionRenown / timeDiff
	end
	local renownPerHour = round(renownPerSecond * 3600,0)
	local timeDiffTotal = updateTotalTime()
	local xpPerSecondTotal = settings.sessionXPTotal / timeDiffTotal
	local xpPerHourTotal = round(xpPerSecondTotal * 3600,0)
	local renownPerSecondTotal = settings.sessionRenownTotal / timeDiffTotal
	local renownPerHourTotal = round(renownPerSecondTotal * 3600,0)
	local ltime, _, _ = FormatClock(timeDiff)
	if (timeDiff == 0 or timeDiff >= 360000) then
		ltime = "-"
	end
	local ltimeTotal, _, _ = FormatClock(timeDiffTotal)
	if (timeDiffTotal == 0 or timeDiffTotal >= 360000) then
		ltimeTotal = "-"
	end
	local row = 1
	Tooltips.SetTooltipText(row,1,L"Session Stats")
	row = row + 1
	Tooltips.SetTooltipText(row, 1, L"Session time:")
	Tooltips.SetTooltipText(row, 3, towstring(ltime))
	row = row + 1
	Tooltips.SetTooltipText(row, 1, L"Playtime:")
	Tooltips.SetTooltipText(row, 3, towstring(ltimeTotal))
	row = row + 1
	Tooltips.SetTooltipText(row, 1, Divider)
	if settings.xpInUse then
		local xpNeeded = GameData.Player.Experience.curXpNeeded - GameData.Player.Experience.curXpEarned
		row = row + 1
		Tooltips.SetTooltipText(row, 1, L"XP Session:\nXP per hour:\nXP to level:\nTime to rank:\nXP Playtime:\nXP per hour:")
		Tooltips.SetTooltipText(row, 3, towstring(settings.sessionXP)..L"\n"..towstring(xpPerHour)..L"\n"..towstring(xpNeeded)..L"\n"..towstring(settings.timeToRank)..L"\n"..towstring(settings.sessionXPTotal)..L"\n"..towstring(xpPerHourTotal))
		row = row + 1
		Tooltips.SetTooltipText(row, 1, Divider)
	end
	if settings.renownInUse then
		local renownNeeded = GameData.Player.Renown.curRenownNeeded - GameData.Player.Renown.curRenownEarned
		row = row + 1
		Tooltips.SetTooltipText(row, 1, L"RP Session:\nRP per hour:\nRP to level:\nTime to Renown rank:\nRP Playtime:\nRP per hour:")
		Tooltips.SetTooltipText(row, 3, towstring(settings.sessionRenown)..L"\n"..towstring(renownPerHour)..L"\n"..towstring(renownNeeded)..L"\n"..towstring(settings.timeToRenown)..L"\n"..towstring(settings.sessionRenownTotal)..L"\n"..towstring(renownPerHourTotal))
		row = row + 1
		Tooltips.SetTooltipText(row, 1, Divider)
	end
	row = row + 1
	Tooltips.SetTooltipText(row, 1, L"Session Kills:\nSession DBs:\nSession Deaths:")
	Tooltips.SetTooltipText(row, 3, towstring(settings.sessionKills)..L"\n"..towstring(settings.sessionDBs)..L"\n"..towstring(settings.sessionDeaths))
	row = row + 1
	Tooltips.SetTooltipText(row, 1, Divider)
	row = row + 1
	Tooltips.SetTooltipText(row, 1, L"Session Gold:\nSession Silver:\nSession Brass:")
	Tooltips.SetTooltipText(row, 3, towstring(settings.sessionGold)..L"\n"..towstring(settings.sessionSilver)..L"\n"..towstring(settings.sessionBrass))
	row = row + 1
	Tooltips.SetTooltipText(row, 1, Divider)
	local WarCrestPerHour = 0
	if (settings.sessionWarCrest > 0) then 
		local WarCrestPerSecond = settings.sessionWarCrest / timeDiff
		WarCrestPerHour = round(WarCrestPerSecond * 3600,0)
	end
	row = row + 1
	Tooltips.SetTooltipText(row, 1, L"War Crest Session:\nWar Crest per hour:")
	Tooltips.SetTooltipText(row, 3, towstring(settings.sessionWarCrest)..L"\n"..towstring(WarCrestPerHour))
	Tooltips.SetTooltipActionText(L"Left Mouse resets session\nRight Mouse resets all")
	Tooltips.Finalize()
end
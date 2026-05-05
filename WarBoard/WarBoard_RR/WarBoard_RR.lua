if not WarBoard_RR then WarBoard_RR = {} end

local WarBoard_RR = WarBoard_RR
local WindowSetAlpha, LabelSetTextColor, LabelSetText, StatusBarSetCurrentValue, StatusBarSetMaximumValue, Tooltips, format, tostring,
	  towstring =
	  WindowSetAlpha, LabelSetTextColor, LabelSetText, StatusBarSetCurrentValue, StatusBarSetMaximumValue, Tooltips, string.format, tostring,
	  towstring

-- Saved variable table (persisted via .mod SavedVariables)
WarBoard_RR_Saved = WarBoard_RR_Saved or {}

-- Track last seen rank; initialize lazily in OnPlayerRpUpdate
local previousRR = nil

-- Toggle: auto-broadcast on rank-up (default ON if not set)
WarBoard_RR.broadcastEnabled = (WarBoard_RR_Saved.broadcastEnabled ~= nil) and WarBoard_RR_Saved.broadcastEnabled or true

local function SetBroadcastEnabled(state)
	WarBoard_RR.broadcastEnabled = state and true or false
	WarBoard_RR_Saved.broadcastEnabled = WarBoard_RR.broadcastEnabled

	if WarBoard_RR.broadcastEnabled then
		EA_ChatWindow.Print(L"RR auto-broadcast: ON")
	else
		EA_ChatWindow.Print(L"RR auto-broadcast: OFF")
	end
end


function WarBoard_RR.Initialize()
	if WarBoard.AddMod("WarBoard_RR") then
		StatusBarSetForegroundTint("WarBoard_RRPercentBar", 204, 126, 201)
		WindowSetAlpha("WarBoard_RRBarBackground", 0.25)
		LabelSetTextColor("WarBoard_RRStat", 200, 50, 200)

		-- Re-apply saved toggle into runtime and announce once on load
		SetBroadcastEnabled(WarBoard_RR.broadcastEnabled)

		RegisterEventHandler(SystemData.Events.PLAYER_RENOWN_UPDATED, "WarBoard_RR.OnPlayerRpUpdate")
		WarBoard_RR.OnPlayerRpUpdate()
	end
end

function WarBoard_RR.OnPlayerRpUpdate()
	local curRR = GameData.Player.Renown.curRank or 0
	local RpEarned = GameData.Player.Renown.curRenownEarned or 0
	local RpNeeded = GameData.Player.Renown.curRenownNeeded or 1
	local percent = (RpEarned / math.max(RpNeeded, 1)) * 100

	-- Initialize on first run
	if previousRR == nil then
		previousRR = curRR
	end

	-- Only send on rank-up, respect toggle, and only from RR 20+
	if WarBoard_RR.broadcastEnabled and curRR > previousRR then
		if curRR == 80 then
			local message = towstring(string.format("I FINALLY made it to Renown Rank %d!!", curRR))
			SendChatText(message, L"/g")
		elseif curRR >= 30 then
			local message = towstring(string.format("I just hit Renown Rank %d!!", curRR))
			SendChatText(message, L"/g")
		end
	end

	-- Always update previousRR to current after all comparisons
	previousRR = curRR

	-- Update UI
	if curRR < 255 then
		LabelSetText("WarBoard_RRName", towstring(format("RR: %s", tostring(curRR))))
		LabelSetText("WarBoard_RRStat", towstring(format("%.2f%%", percent)))
		LabelSetText("WarBoard_RRTitle", L"")
		LabelSetText("WarBoard_RRTitle2", L"")

		StatusBarSetCurrentValue("WarBoard_RRPercentBar", RpEarned)
		StatusBarSetMaximumValue("WarBoard_RRPercentBar", math.max(RpNeeded, 1))
	else
		LabelSetText("WarBoard_RRTitle", L"Renown Rank")
		LabelSetText("WarBoard_RRTitle2", L"255")
		LabelSetText("WarBoard_RRName", L"")
		LabelSetText("WarBoard_RRStat", L"")
		LabelSetTextColor("WarBoard_RRTitle", 200, 500, 200)
		WindowSetAlpha("WarBoard_RRBarBackground", 0)
	end
end

function WarBoard_RR.OnMouseOver()
	local RpEarned = GameData.Player.Renown.curRenownEarned or 0
	local RpNeeded = GameData.Player.Renown.curRenownNeeded or 0
	local curRR = GameData.Player.Renown.curRank or 0
	local curTitle = GameData.Player.Renown.curTitle 
	Tooltips.CreateTextOnlyTooltip("WarBoard_RR", nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_RR"))
	Tooltips.SetTooltipColor(1, 1, 255, 255, 255)
	Tooltips.SetTooltipColor(4, 3, 0, 200, 0)
	Tooltips.SetTooltipColor(5, 3, 247, 194, 088)
	Tooltips.SetTooltipText(1, 1, towstring(format("Renown Rank: %s", tostring(curRR))))
	Tooltips.SetTooltipText(2, 1, towstring(format("Renown Title: %s", tostring(curTitle))))
	Tooltips.SetTooltipText(3, 1, towstring(format("Total required for rank %s: ", tostring(curRR + 1))))
	Tooltips.SetTooltipText(3, 3, towstring(RpNeeded))

	Tooltips.SetTooltipText(4, 1, towstring(format("Earned toward rank %s: ", tostring(curRR + 1))))
	Tooltips.SetTooltipText(4, 3, towstring(RpEarned))

	Tooltips.SetTooltipText(5, 1, towstring(format("Needed for rank %s: ", tostring(curRR + 1))))
	Tooltips.SetTooltipText(5, 3, towstring(RpNeeded-RpEarned))
	Tooltips.Finalize()
end

function WarBoard_RR.OnLButtonUp()
	EA_Window_ContextMenu.CreateContextMenu("RRChatContext")

	EA_Window_ContextMenu.AddMenuItem(L"Send Renown Rank to Region",   WarBoard_RR.SendToRegion, false, true)
	EA_Window_ContextMenu.AddMenuItem(L"Send Renown Rank to RvR",      WarBoard_RR.SendToRvR, false, true)
	EA_Window_ContextMenu.AddMenuItem(L"Send Renown Rank to Guild",    WarBoard_RR.SendToGuild, false, true)
	EA_Window_ContextMenu.AddMenuItem(L"Send Renown Rank to Alliance", WarBoard_RR.SendToAlliance, false, true)

	if IsWarBandActive() then
		EA_Window_ContextMenu.AddMenuItem(L"Send Renown Rank to Warband", WarBoard_RR.SendToWarband, false, true)
	else
		EA_Window_ContextMenu.AddMenuItem(L"Send Renown Rank to Party", WarBoard_RR.SendToParty, false, true)
	end

	EA_Window_ContextMenu.Finalize()
end

-- Right-click: toggle auto-broadcast ON/OFF and show status via print()
function WarBoard_RR.OnRButtonUp()
	EA_Window_ContextMenu.CreateContextMenu("RRBroadcastToggle")

	local statusText = WarBoard_RR.broadcastEnabled and L"ON" or L"OFF"
	EA_Window_ContextMenu.AddMenuItem(L"Broadcast on rank-up: " .. statusText,
		function()
			SetBroadcastEnabled(not WarBoard_RR.broadcastEnabled)
		end,
		false, true
	)

	EA_Window_ContextMenu.Finalize()
end

function WarBoard_RR.BuildRenownMessage()
	local rr = GameData.Player.Renown.curRank or 0
	local rp = GameData.Player.Renown.curRenownEarned or 0
	local rMax = GameData.Player.Renown.curRenownNeeded or 1
	local percent = 0

	if rMax > 0 then
		percent = (rp / rMax) * 100
	end

	return towstring(string.format("I am Renown Rank %.2f", rr + (percent / 100)))
end

function WarBoard_RR.SendToRegion()
	SendChatText(WarBoard_RR.BuildRenownMessage(), L"/1")
end

function WarBoard_RR.SendToRvR()
	SendChatText(WarBoard_RR.BuildRenownMessage(), L"/2")
end

function WarBoard_RR.SendToGuild()
	SendChatText(WarBoard_RR.BuildRenownMessage(), L"/g")
end

function WarBoard_RR.SendToAlliance()
	SendChatText(WarBoard_RR.BuildRenownMessage(), L"/a")
end

function WarBoard_RR.SendToParty()
	SendChatText(WarBoard_RR.BuildRenownMessage(), L"/p")
end

function WarBoard_RR.SendToWarband()
	SendChatText(WarBoard_RR.BuildRenownMessage(), L"/war")
end

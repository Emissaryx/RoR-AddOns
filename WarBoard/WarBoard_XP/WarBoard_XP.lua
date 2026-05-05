if not WarBoard_XP then WarBoard_XP = {} end
local WarBoard_XP = WarBoard_XP
local LabelSetTextColor, LabelSetText, StatusBarSetCurrentValue, StatusBarSetMaximumValue, WindowSetAlpha, towstring, format, tostring,
	  Tooltips =
	  LabelSetTextColor, LabelSetText, StatusBarSetCurrentValue, StatusBarSetMaximumValue, WindowSetAlpha, towstring, string.format, tostring,
	  Tooltips

function WarBoard_XP.Initialize()
	if WarBoard.AddMod("WarBoard_XP") then
		StatusBarSetForegroundTint("WarBoard_XPPercentBar", 247, 194, 088)
		StatusBarSetForegroundTint("WarBoard_XPRestedBar", 100, 200, 200)
		WindowSetAlpha("WarBoard_XPBarBackground", 0.25)
		LabelSetTextColor("WarBoard_XPStat", 255, 200, 0)
		LabelSetTextColor("WarBoard_XPTitle", 255, 200, 0)
		RegisterEventHandler(SystemData.Events.PLAYER_EXP_UPDATED, "WarBoard_XP.OnPlayerXpUpdate")
		WarBoard_XP.OnPlayerXpUpdate()
	end
end

function WarBoard_XP.OnPlayerXpUpdate()
	if GameData.Player.level < 40 then
		local XpEarned = GameData.Player.Experience.curXpEarned
		local XpNeeded = GameData.Player.Experience.curXpNeeded
		local XpPercent = XpEarned / XpNeeded * 100
		local curLVL = GameData.Player.level
		local XpRest = GameData.Player.Experience.restXp
		local XpRestedBar = XpRest + XpEarned
		LabelSetText("WarBoard_XPName", towstring(format("CR: %s", tostring(curLVL))))
		LabelSetText("WarBoard_XPStat", towstring(format("%.2f%%", XpPercent)))
		LabelSetText("WarBoard_XPTitle", L"")
		LabelSetText("WarBoard_XPTitle2", L"")

		StatusBarSetCurrentValue("WarBoard_XPRestedBar", XpRestedBar)
		StatusBarSetMaximumValue("WarBoard_XPRestedBar", XpNeeded)

		StatusBarSetCurrentValue("WarBoard_XPPercentBar", XpEarned)
		StatusBarSetMaximumValue("WarBoard_XPPercentBar", XpNeeded)
	else 
		-- We've reached the maximum level.
		LabelSetText("WarBoard_XPTitle", L"Career Rank")
		LabelSetText("WarBoard_XPTitle2", L"40")
		LabelSetText("WarBoard_XPName", L"")
		LabelSetText("WarBoard_XPStat", L"")
		WindowSetAlpha("WarBoard_XPBarBackground", 0)
	end
end

function WarBoard_XP.OnClick()
	CharacterWindow.ToggleShowing() 
end

function WarBoard_XP.OnMouseOver()
	local XpEarned = GameData.Player.Experience.curXpEarned
	local XpNeeded = GameData.Player.Experience.curXpNeeded
	local XpRest = GameData.Player.Experience.restXp
	local curLVL = GameData.Player.level
	Tooltips.CreateTextOnlyTooltip("WarBoard_XP", nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_XP"))
	Tooltips.SetTooltipColor(1, 1, 255, 255, 255)
	Tooltips.SetTooltipColor(3, 3, 0, 200, 0)
	Tooltips.SetTooltipColor(4, 3, 247, 194, 088)
	Tooltips.SetTooltipColor(5, 1, 255, 220, 0)
	Tooltips.SetTooltipText(1, 1, towstring(format("Career Rank: %s", tostring(curLVL))))
	Tooltips.SetTooltipText(2, 1, towstring(format("Total required for rank %s: ", tostring(curLVL + 1))))
	Tooltips.SetTooltipText(2, 3, towstring(XpNeeded))

	Tooltips.SetTooltipText(3, 1, towstring(format("Earned toward rank %s: ", tostring(curLVL + 1))))
	Tooltips.SetTooltipText(3, 3, towstring(XpEarned))

	Tooltips.SetTooltipText(4, 1, towstring(format("Needed for rank %s: ",  tostring(curLVL + 1))))
	Tooltips.SetTooltipText(4, 3, towstring(XpNeeded-XpEarned))

	if XpRest > 0 then
		Tooltips.SetTooltipText(5, 1, towstring(format("Rested: %s", tostring(XpRest))))
	end
	Tooltips.Finalize()
end

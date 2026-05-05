if not WarBoard_GP then WarBoard_GP = {} end
local WarBoard_GP = WarBoard_GP
local LabelSetTextColor, LabelSetText, WindowSetAlpha, StatusBarSetCurrentValue, StatusBarSetMaximumValue, Tooltips, towstring, format, 
	  tostring =
	  LabelSetTextColor, LabelSetText, WindowSetAlpha, StatusBarSetCurrentValue, StatusBarSetMaximumValue, Tooltips, towstring, string.format,
	  tostring

function WarBoard_GP.Initialize()
	if WarBoard.AddMod("WarBoard_GP") then
		LabelSetTextColor("WarBoard_GPStat", 255, 225, 025)
		LabelSetTextColor("WarBoard_GPTitle2", 0, 200, 0)

		RegisterEventHandler(SystemData.Events.GUILD_EXP_UPDATED, "WarBoard_GP.OnGuildXpUpdate")
		WarBoard_GP.OnGuildXpUpdate()
	end
end

function WarBoard_GP.OnGuildXpUpdate()

	local GpRank = GameData.Guild.m_GuildRank
	local GpTotal = GameData.Guild.m_GuildExpCurrent
	local GpInLevel = GameData.Guild.m_GuildExpInCurrentLevel
	local GpNextLevel = GameData.Guild.m_GuildExpNeeded
	local GpNeeded = GpNextLevel - GpInLevel
	local GpPrevLevel = GpTotal - GpInLevel
	local denom = GpNextLevel - GpPrevLevel
	local GpPercent = 0
	if denom ~= 0 then
		GpPercent = GpInLevel/ denom*100

		LabelSetText("WarBoard_GPName", towstring(format("GR: %s", tostring(GpRank))))
		LabelSetText("WarBoard_GPStat", towstring(format("%.2f%%", GpPercent)))
		LabelSetText("WarBoard_GPTitle", L"")
		LabelSetText("WarBoard_GPTitle2", L"")
		LabelSetText("WarBoard_GPTitle3", L"")
		LabelSetText("WarBoard_GPTitle4", L"")
		WindowSetAlpha("WarBoard_GPBarBackground", 0.25)
	else
		LabelSetText("WarBoard_GPTitle", L"WarBoard")
		LabelSetText("WarBoard_GPTitle2", L"Guild")
		LabelSetText("WarBoard_GPTitle3", L"")
		LabelSetText("WarBoard_GPTitle4", L"")
		LabelSetText("WarBoard_GPName", L"")
		LabelSetText("WarBoard_GPStat", L"")
		WindowSetAlpha("WarBoard_GPBarBackground", 0)
	end

	StatusBarSetCurrentValue("WarBoard_GPPercentBar", GpInLevel)
	StatusBarSetMaximumValue("WarBoard_GPPercentBar", GpNextLevel-GpPrevLevel)
end

function WarBoard_GP.OnClick()
	GuildWindow.ToggleShowing()
end

function WarBoard_GP.OnMouseOver()
	if GameData.Guild.m_GuildID ~= 0 then
		local GpRenown = GameData.Guild.m_GuildRenown
		local GpRank = GameData.Guild.m_GuildRank
		local GpName = GameData.Guild.m_GuildName
		local GpTotal = GameData.Guild.m_GuildExpCurrent
		local GpInLevel = GameData.Guild.m_GuildExpInCurrentLevel
		local GpNextLevel = GameData.Guild.m_GuildExpNeeded
		local GpNeeded = GpNextLevel - GpInLevel
		local GpPrevLevel= GpTotal - GpInLevel

		Tooltips.CreateTextOnlyTooltip("WarBoard_GP", nil)
		Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_GP"))
		Tooltips.SetTooltipColor(1, 1, 0, 155, 255)
		Tooltips.SetTooltipColor(3, 3, 247, 194, 088)
		Tooltips.SetTooltipColor(4, 3, 0, 200, 0)
		Tooltips.SetTooltipColor(5, 3, 255, 0, 0)
		Tooltips.SetTooltipColor(6, 3, 247, 194, 088)
		Tooltips.SetTooltipColor(7, 3, 190, 0, 255)
		Tooltips.SetTooltipText(1, 1, towstring(format("%s", tostring(GpName))))
		Tooltips.SetTooltipText(2, 1, towstring(format("Guild Rank: %s", tostring(GpRank))))
		Tooltips.SetTooltipText(3, 1, L"Total XP required for next rank:")
		Tooltips.SetTooltipText(3, 3, towstring(GpNextLevel))
		Tooltips.SetTooltipText(4, 1, L"Current total XP earned:")
		Tooltips.SetTooltipText(4, 3, towstring(GpTotal))
		Tooltips.SetTooltipText(5, 1, towstring(format("XP left until rank: %s  ", tostring(GpRank + 1))))
		Tooltips.SetTooltipText(5, 3, towstring((GpNextLevel -GpPrevLevel)-(GpInLevel)))
		Tooltips.SetTooltipText(6, 1, towstring(format("Earned toward rank %s: ", tostring(GpRank + 1))))
		Tooltips.SetTooltipText(6, 3, towstring((GpInLevel).."/"..tostring(GpNextLevel -GpPrevLevel))) 
		Tooltips.SetTooltipText(7, 1, L"Guild's total renown earned:")
		Tooltips.SetTooltipText(7, 3, towstring(GpRenown))

		Tooltips.Finalize()
	end
end

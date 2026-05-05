if not WarBoard_GuildF then WarBoard_GuildF = {} end
local WarBoard_GuildF = WarBoard_GuildF
local tinsert, format, LabelSetText, WindowSetShowing, Tooltips, ipairs, tostring, towstring, unpack, GetGuildMemberData =
	  table.insert, string.format, LabelSetText, WindowSetShowing, Tooltips, ipairs, tostring, towstring, unpack, GetGuildMemberData

function WarBoard_GuildF.Initialize()
	if WarBoard.AddMod("WarBoard_GuildF") then
		WarBoard_GuildF.SetIcon("WarBoard_GuildFIcon", 00166)
		RegisterEventHandler(SystemData.Events.GUILD_MEMBER_UPDATED, "WarBoard_GuildF.OnGuildMemberUpdated")
		WarBoard_GuildF.OnGuildMemberUpdated()
	end
end

function WarBoard_GuildF.OnGuildMemberUpdated()
	local members, online = GetGuildMemberData(), 0
	local total = #members
	for i = 1, total do if (members[i].zoneID ~= 0) then online = online+1 end end
	LabelSetText("WarBoard_GuildFLabel", towstring(format(online.."/"..total)))
end

function WarBoard_GuildF.OnClick()
	GuildWindow.ToggleShowing()
end

function WarBoard_GuildF.OnMouseOver()
	local members, membersOn, line, lvl_col = GetGuildMemberData(), {}, 1
	for i = 1, #members do
		if members[i].zoneID ~= 0 then
			tinsert(membersOn, members[i])
		end
	end
	Tooltips.CreateTextOnlyTooltip("WarBoard_GuildF", nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_GuildF"))
	Tooltips.SetTooltipText(1, 1, GameData.Guild.m_GuildName)
	for k, v in ipairs(membersOn) do
		line = line + 1
		local rank = membersOn[k].rank
		local career = membersOn[k].careerString
		local loc = GetZoneName(membersOn[ k ].zoneID)
		if rank > GameData.Player.level + 5 then lvl_col = {255,200,150}
		elseif rank < GameData.Player.level - 5 then lvl_col = {150,250,100}
		else lvl_col = {250,250,20} end
		Tooltips.SetTooltipColor(line, 1, unpack(lvl_col))
		Tooltips.SetTooltipText(line, 1, towstring("["..tostring(rank).."] "..tostring(membersOn[k].name)))
		Tooltips.SetTooltipText(line, 3, towstring("- "..tostring(career).." - "..tostring(loc)))
	end
	Tooltips.Finalize()
end

function WarBoard_GuildF.SetIcon(dynamicImageTitle, icon)
	local texture, x, y = GetIconData(icon)
	DynamicImageSetTexture(dynamicImageTitle, texture, x, y)
end

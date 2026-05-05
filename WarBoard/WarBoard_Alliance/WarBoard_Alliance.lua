if not WarBoard_Alliance then WarBoard_Alliance = {} end
local WarBoard_Alliance = WarBoard_Alliance
local ipairs, GetAllianceMemberData, LabelSetText, towstring, format, getn, tostring, tinsert, Tooltips, SendPlayerSearchRequest =
	  ipairs, GetAllianceMemberData, LabelSetText, towstring, string.format, table.getn, tostring, table.insert, Tooltips, SendPlayerSearchRequest

function WarBoard_Alliance.Initialize()
	if WarBoard.AddMod("WarBoard_Alliance") then
 		WarBoard_Alliance.SetIcon("WarBoard_AllianceIcon", 00100)
		RegisterEventHandler(SystemData.Events.ALLIANCE_UPDATED, "WarBoard_Alliance.OnSocialAllianceUpdated")
		WarBoard_Alliance.OnSocialAllianceUpdated()
	end
end

function WarBoard_Alliance.OnSocialAllianceUpdated()
	local guilds = GetAllianceMemberData()
	local total_online, total_offline = 0, 0

	for rowIndex, rowData in ipairs(guilds) do
		local online, offline = GetAllianceMemberCounts(rowData.id)
		total_online = total_online + online
		total_offline = total_offline + offline
	end

	local total = total_online + total_offline
	LabelSetText("WarBoard_AllianceLabel", towstring(format(total_online.."/"..total)))
end

function WarBoard_Alliance.OnClick()
    local guilds = GetAllianceMemberData()

    for guildIndex = 1, getn(guilds) do
        local guildName = towstring(guilds[guildIndex].name or "")
        -- This searches by guild name only
        SendPlayerSearchRequest(L"", guildName, L"", {}, 1, 40, true)
    end

    if DoesWindowExist("SocialWindow") then
        WindowSetShowing("SocialWindow", true)
    end
end

function WarBoard_Alliance.OnMouseOver()
	guildsListBox = {}

	local guilds = GetAllianceMemberData()
	local nextRow = 1

	for guildIndex = 1, getn(guilds) do
		-- Push the guild itself into the data table.
		local text = GetFormatStringFromTable("guildstrings", StringTables.Guild.TEXT_ROSTER_X_OF_Y_GUILD_MEMBERS_ONLINE, { guilds[guildIndex].online, guilds[guildIndex].online + guilds[guildIndex].offline })
		local guildEntry = { isGuild = true, guildname = guilds[guildIndex].name, guildID = guilds[guildIndex].id, online = text }
		tinsert(guildsListBox, nextRow, guildEntry)

		nextRow = nextRow + 1

		-- Step 1b: Add all the Alliance Officers from all the Guilds (including your own)
		for playerIndex = 1, getn(guilds[guildIndex].players) do
			local playerEntry = 
			{		isGuild = false, name = guilds[guildIndex].players[playerIndex].name,
					allianceMemberRank=guilds[guildIndex].players[playerIndex].rank,
					guildID = guildEntry.guildID,
					rank = guilds[guildIndex].players[playerIndex].rank,
		--			zoneID =  guilds[guildIndex].players[playerIndex].zoneID
			}
			tinsert(guildsListBox, nextRow, playerEntry)
			nextRow = nextRow + 1
		end
	end

	Tooltips.CreateTextOnlyTooltip("WarBoard_Alliance", nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_Alliance"))
	Tooltips.SetTooltipColor(1, 1, 217, 50, 50)
	Tooltips.SetTooltipText(1, 1, towstring(tostring(GameData.Guild.Alliance.Name)))
	local line = 1
	for k, v in ipairs(guildsListBox) do
		if guildsListBox[k].isGuild then
			line = line + 1
			Tooltips.SetTooltipColor(line, 1, 186,147,80)
			Tooltips.SetTooltipText(line, 1, towstring(tostring(guildsListBox[k].guildname)))
			Tooltips.SetTooltipText(line, 3, towstring(guildsListBox[k].online))
		end
	end
	Tooltips.Finalize()
end

function WarBoard_Alliance.SetIcon(dynamicImageTitle, icon)
	local texture, x, y = GetIconData(icon)
	DynamicImageSetTexture(dynamicImageTitle, texture, x, y)
end

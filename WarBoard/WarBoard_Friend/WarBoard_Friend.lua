if not WarBoard_Friend then WarBoard_Friend = {} end
local WarBoard_Friend = WarBoard_Friend
local LabelSetText, tinsert, Tooltips, ipairs, tostring, towstring, format, GetFriendsList =
	  LabelSetText, table.insert, Tooltips, ipairs, tostring, towstring, string.format, GetFriendsList

function WarBoard_Friend.Initialize()
	if (WarBoard.AddMod("WarBoard_Friend")) then
		WarBoard_Friend.SetIcon("WarBoard_FriendIcon", 00162)
		RegisterEventHandler(SystemData.Events.SOCIAL_FRIENDS_UPDATED, "WarBoard_Friend.OnSocialFriendsUpdated")
		RegisterEventHandler(SystemData.Events.TARGET_SELF, "WarBoard_Friend.OnSocialFriendsUpdated")
		WarBoard_Friend.OnSocialFriendsUpdated()
	end

end

function WarBoard_Friend.OnSocialFriendsUpdated()
	local fr_list, online = GetFriendsList(), 0
	local total = #fr_list
	for ndx = 1, total do
		if (fr_list[ndx].zoneID ~= 0) then online = online+1 end 
	end
	LabelSetText("WarBoard_FriendLabel", towstring(format(online.."/"..total)))
end

function WarBoard_Friend.OnClick()
    SocialWindowBuddyList.ToggleSocialWindows()
end

function WarBoard_Friend.OnMouseOver()
	local friends, friendsOn, line = GetFriendsList(), {}, 1
	for i = 1, #friends do
		if friends[ i ].zoneID ~= 0 then
		tinsert(friendsOn, friends[ i ])
		end
	end
	Tooltips.CreateTextOnlyTooltip("WarBoard_Friend", nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_Friend"))
	Tooltips.SetTooltipColor(1, 1, 0, 255, 255)
	Tooltips.SetTooltipText(1, 1, L"Friends Online")
	for k, v in ipairs(friendsOn) do
		line = line + 1
		local rank = friendsOn[k].rank
		Tooltips.SetTooltipColor(line, 1, 54, 176, 255)
		Tooltips.SetTooltipText(line, 1, towstring("["..tostring(rank).."] "..tostring(friendsOn[k].name)))
		Tooltips.SetTooltipText(line, 3, GetZoneName(friendsOn[ k ].zoneID))
	end
	Tooltips.Finalize()
end

function WarBoard_Friend.SetIcon(dynamicImageTitle, icon)
	local texture, x, y = GetIconData(icon)
	DynamicImageSetTexture(dynamicImageTitle, texture, x, y)
end

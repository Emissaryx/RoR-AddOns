-- TargetsUnitFrame.lua

-- locals (hot path + handlers)
local DoesWindowExist            = DoesWindowExist
local GetFrame                   = GetFrame
local StatusBarSetMaximumValue   = StatusBarSetMaximumValue
local StatusBarSetCurrentValue   = StatusBarSetCurrentValue
local WindowSetGameActionData    = WindowSetGameActionData
local WindowSetAlpha             = WindowSetAlpha
local LabelSetText               = LabelSetText
local LabelSetTextColor          = LabelSetTextColor
local LabelGetText               = LabelGetText
local DynamicImageSetTexture     = DynamicImageSetTexture
local GetIconData                = GetIconData
local towstring                  = towstring
local BroadcastEvent             = BroadcastEvent
local Icons                      = Icons
local SystemData                 = SystemData
local GameData                   = GameData

TargetsUnitFrame = Frame:Subclass("TargetsUnitFrame")

TargetsUnitFrame.priority_color = {
	[TargetList.PRIO_DEFAULT] = { 200, 200, 200 },
	[TargetList.PRIO_LOCKED]  = { 200, 0, 0 },
	[TargetList.PRIO_FAV]     = { 200, 0, 200 },
}

function TargetsUnitFrame:new(groupname, id)
	local wndname = "TargetsList_" .. groupname .. "_" .. id
	local unitframe

	if DoesWindowExist(wndname) then
		unitframe = GetFrame(wndname)
	else
		unitframe = self:CreateFromTemplate(wndname)
	end
	if not unitframe then return nil end

	StatusBarSetMaximumValue(wndname .. "HPBar", 100)

	unitframe:Show(false)
	unitframe.visible = true
	unitframe.slash_targeting = false

	-- cached state
	unitframe.last_name   = nil
	unitframe.last_hp     = nil
	unitframe.last_rank   = nil
	unitframe.last_prio   = nil
	unitframe.last_career = nil
	unitframe.last_action_target = nil

	return unitframe
end

function TargetsUnitFrame.UnitRClick(flag)
	local wndname   = SystemData.MouseOverWindow.name
	local framename = wndname:sub(1, wndname:find("Action") - 1)
	local unitframe = GetFrame(framename)
	if not unitframe or not unitframe.player then return end

	local p = unitframe.player

	-- toggle lock
	if p.prio == TargetList.PRIO_DEFAULT then
		p.prio = TargetList.PRIO_LOCKED
	else
		p.prio = TargetList.PRIO_DEFAULT
	end

	-- shift = favorite
	if flag == SystemData.ButtonFlags.SHIFT then
		if Targets.saved.favorites[p.name] then
			Targets.saved.favorites[p.name] = nil
			p.prio = TargetList.PRIO_DEFAULT
		else
			Targets.saved.favorites[p.name] = true
			p.prio = TargetList.PRIO_FAV
		end
	end

	-- force resort
	if unitframe.list then
		unitframe.list.dirty = true
	end
end

function TargetsUnitFrame.UnitLClick()
	local wndname   = SystemData.MouseOverWindow.name
	local unitframe = GetFrame(wndname:sub(1, wndname:find("Action") - 1))
	if unitframe and unitframe.slash_targeting then
		SystemData.UserInput.ChatText =
			L"/target " .. LabelGetText(unitframe:GetName() .. "LabelName")
		BroadcastEvent(SystemData.Events.SEND_CHAT_TEXT)
	end
end

function TargetsUnitFrame:update(player, list)
	local show = (player ~= nil) and self.visible
	self:Show(show)
	if not show then return end

	local wndname = self:GetName()
	self.player = player
	self.list   = list

	-- set game action only if target changed
	if not self.slash_targeting and self.last_action_target ~= player.name then
		WindowSetGameActionData(
			wndname .. "Action",
			GameData.PlayerActions.SET_TARGET,
			0,
			player.name
		)
		self.last_action_target = player.name
	end

	-- name
	if self.last_name ~= player.name then
		LabelSetText(wndname .. "LabelName", towstring(player.name))
		self.last_name = player.name
	end

	-- hp
	if self.last_hp ~= player.hp then
		LabelSetText(wndname .. "LabelHealth", towstring(player.hp) .. L"%")
		StatusBarSetCurrentValue(wndname .. "HPBar", player.hp)
		self.last_hp = player.hp
	end

	-- rank
	if self.last_rank ~= player.rank then
		LabelSetText(wndname .. "LabelRank", towstring(player.rank))
		self.last_rank = player.rank
	end

	-- career icon
	if self.last_career ~= player.career then
		local texture, x, y =
			GetIconData(Icons.GetCareerIconIDFromCareerLine(player.career))
		DynamicImageSetTexture(wndname .. "CareerIcon", texture, x, y)
		self.last_career = player.career
	end

	-- decay alpha always changes
	WindowSetAlpha(
		wndname .. "HPBar",
		player.decay / TargetList.DEFAULT_DECAY
	)

	-- priority color
	if self.last_prio ~= player.prio then
		local color = TargetsUnitFrame.priority_color[player.prio]
		LabelSetTextColor(
			wndname .. "LabelName",
			color[1], color[2], color[3]
		)
		self.last_prio = player.prio
	end
end

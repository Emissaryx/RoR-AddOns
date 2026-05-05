-- Targets.lua (Allies-only, 4×4 grid)

Targets = {}
Targets.VERSION = "1.00"
Targets.UPDATE_PERIOD = 0.2

-- locals
local ipairs       = ipairs
local table_insert = table.insert
local math_floor   = math.floor

function Targets.init()
	-- persistent data
	Targets.saved = Targets.saved or {}
	Targets.saved.allies = Targets.saved.allies or {}
	Targets.saved.allies.filters = Targets.saved.allies.filters or {}
	Targets.saved.favorites = Targets.saved.favorites or {}

	-- main event
	RegisterEventHandler(
		SystemData.Events.PLAYER_TARGET_UPDATED,
		"Targets.on_target_updated"
	)
	Targets.update_timeout = Targets.UPDATE_PERIOD

	-- list of targets
	Targets.targets = {}

	-- create allies list
	Targets.allies = Targets.create_playerlist(
		"Friendly",
		SystemData.TargetObjectType.ALLY_PLAYER
	)

	Targets.allies.filters = {
		{ id = "keymod", desc = "Key modifier", f = Targets.filter_key_modifier, enabled = false },
		{ id = "group",  desc = "Group",        f = Targets.filter_group,        enabled = true  },
		{ id = "wb",     desc = "Warband",      f = Targets.filter_warband,      enabled = true  },
		{ id = "sc",     desc = "Scenario",     f = Targets.filter_scenario,     enabled = true  }
	}

	Targets.allies.list.remove_full_hp = true
	Targets.restore()

	-- register anchor
	LayoutEditor.RegisterWindow(
		"TargetsAnchor",
		L"Targets",
		L"Targets Window",
		false, false, true, nil
	)

	-- register slash commands
	TargetsSlashCmd.register()

	d("Targets " .. Targets.VERSION .. " loaded")
end

-- Restore settings for allies-only
function Targets.restore()
	local plist = Targets.allies
	local saved = Targets.saved.allies or {}

	-- filters
	if saved.filters then
		for _, filter in ipairs(plist.filters) do
			if saved.filters[filter.id] ~= nil then
				filter.enabled = saved.filters[filter.id]
			end
		end
	end

	-- visibility
	if saved.visible ~= nil then
		plist.visible = saved.visible
		for _, frame in ipairs(plist.frames) do
			frame.visible = plist.visible
		end
	end

	-- sorting
	if saved.sort_players ~= nil then
		plist.list.sort_players = saved.sort_players
	end

	-- max players
	plist.list.max_players = saved.max_players or TargetList.MAX_PLAYERS
end

-- Filters (unchanged logic)
function Targets.filter_scenario(_list, _name)
	if GameData.Player.isInScenario then
		local scdata = GameData.GetScenarioPlayerGroups()
		for _, player in ipairs(scdata) do
			local scname = player.name:sub(1, -3)
			if scname == _name and player.sgroupindex > 0 then
				return true
			end
		end
	end
	return false
end

function Targets.filter_warband(_list, _name)
	if GameData.Player.isInScenario or not IsWarBandActive() then
		return false
	end
	for _, grp in ipairs(GetBattlegroupMemberData()) do
		for _, player in ipairs(grp.players) do
			if player.name == _name then
				return true
			end
		end
	end
	return false
end

function Targets.filter_group(_list, _name)
	if GameData.Player.isInScenario then return false end
	local group = GetGroupData()
	if not group then return false end
	for _, player in ipairs(group) do
		if player.name == _name then
			return true
		end
	end
	return false
end

function Targets.filter_key_modifier(_list, _name)
	return false
end

-- 4×4 grid layout, max 16 allies
function Targets.create_playerlist(_name, _player_type)
	local tl = {}
	tl.list    = TargetList:new()
	tl.list.max_players = TargetList.MAX_PLAYERS
	tl.ptype   = _player_type
	tl.name    = _name
	tl.frames  = {}
	tl.filters = {}
	tl.visible = true

	local frameWidth, frameHeight = 100, 55

	for i = 1, TargetList.MAX_PLAYERS do
		local col = math_floor((i - 1) / 4)
		local row = (i - 1) % 4
		local frame = TargetsUnitFrame:new(_name, i)

		frame:SetAnchor({
			Point         = "topleft",
			RelativeTo    = "TargetsAnchor",
			RelativePoint = "topleft",
			XOffset       = col * frameWidth,
			YOffset       = row * frameHeight,
		})

		table_insert(tl.frames, frame)
	end

	table_insert(Targets.targets, tl)
	return tl
end

function Targets.update(_elapsed)
	Targets.update_timeout = Targets.update_timeout + _elapsed
	if Targets.update_timeout < Targets.UPDATE_PERIOD then
		return
	end

	for _, targetgroup in ipairs(Targets.targets) do
		local changed = targetgroup.list:update(Targets.update_timeout)
		if changed then
			for i, frame in ipairs(targetgroup.frames) do
				frame:update(targetgroup.list.players[i], targetgroup.list)
			end
		end
	end

	Targets.update_timeout = 0
end

function Targets.on_target_updated(_unit, _id, _type)
	TargetInfo:UpdateFromClient()

	local rawname = TargetInfo:UnitName(_unit)
	if not rawname then return end

	local name   = rawname:sub(1, -3)
	local hp     = TargetInfo:UnitHealth(_unit)
	local career = TargetInfo:UnitCareer(_unit)
	local rank   = TargetInfo:UnitLevel(_unit)

	for _, targetgroup in ipairs(Targets.targets) do
		if targetgroup.ptype == _type then
			local filtered = false
			for _, filter in ipairs(targetgroup.filters) do
				if filter.enabled and filter.f(targetgroup, name) then
					filtered = true
					break
				end
			end
			if not filtered then
				targetgroup.list:put_player(name, hp, career, rank)
			end
		end
	end
end

function Targets.alert(_text, _type)
	_type = _type or SystemData.AlertText.Types.DEFAULT
	AlertTextWindow.AddLine(_type, towstring(_text))
	PlaySound(Sound.RVR_FLAG_OFF)
end

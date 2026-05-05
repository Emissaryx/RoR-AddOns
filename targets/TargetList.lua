-- TargetList maintains a sorted list of players
-- Each player contains: name, hp, career, rank and decay

TargetList = {}
TargetList.DEFAULT_DECAY = 60
TargetList.DEFAULT_MAXPLAYERS = 6
TargetList.MAX_PLAYERS = 16

TargetList.PRIO_DEFAULT = 0
TargetList.PRIO_LOCKED  = 1
TargetList.PRIO_FAV     = 2

local ipairs        = ipairs
local pairs         = pairs
local setmetatable  = setmetatable

local table_insert  = table.insert
local table_remove  = table.remove
local table_sort    = table.sort

local Targets       = Targets
local L             = L

local Targets_saved     = Targets and Targets.saved
local Targets_favorites = Targets_saved and Targets_saved.favorites
local Targets_alert     = Targets and Targets.alert


-- default ctor
function TargetList:new(t)
	t = t or {}
	setmetatable(t, self)
	self.__index = self

	t.players        = t.players or {}
	t.max_players    = TargetList.DEFAULT_MAXPLAYERS
	t.remove_dead    = false
	t.remove_full_hp = false
	t.sort_players   = true
	t.require_key    = false
	t.dirty          = true 

	return t
end


-- returns false if the player was already inserted
function TargetList:put_player(_name, _hp, _career, _rank)
	for _, p in ipairs(self.players) do
		if p.name == _name then
			-- update existing player
			if p.hp ~= _hp then
				p.hp = _hp
				self.dirty = true
			end
			p.decay = TargetList.DEFAULT_DECAY
			return false
		end
	end

	-- determine priority
	local pprio = TargetList.PRIO_DEFAULT
	if Targets_favorites and Targets_favorites[_name] then
		pprio = TargetList.PRIO_FAV
		if Targets_alert then
			Targets_alert(_name .. L" spotted !")
		end
	end

	-- insert new player
	table_insert(self.players, 1, {
		name    = _name,
		hp      = _hp,
		career  = _career,
		rank    = _rank,
		decay   = TargetList.DEFAULT_DECAY,
		prio    = pprio,
		alerted = true, -- debounce alert
	})

	self.dirty = true
	return true
end


function TargetList:update(_elapsed)
	local dirty = false

	-- decay and removal
	local i = 1
	while i <= #self.players do
		local p = self.players[i]

		if p.prio == TargetList.PRIO_DEFAULT then
			p.decay = p.decay - _elapsed
		end

		if (p.decay <= 0)
		or (self.remove_dead and p.hp == 0 and p.prio == TargetList.PRIO_DEFAULT)
		or (self.remove_full_hp and p.hp == 100 and p.prio == TargetList.PRIO_DEFAULT) then
			table_remove(self.players, i)
			dirty = true
		else
			i = i + 1
		end
	end

	-- trim excess
	while #self.players > self.max_players do
		table_remove(self.players)
		dirty = true
	end

	if not (self.dirty or dirty) then
		return false
	end

	-- assign ids for stable sorting
	for i, p in ipairs(self.players) do
		p.id = i
	end

	-- sort only when needed
	if self.sort_players then
		table_sort(self.players, function(a, b)
			if a.prio == b.prio then
				if a.hp == b.hp then
					return a.id < b.id
				else
					return a.hp < b.hp
				end
			else
				return a.prio > b.prio
			end
		end)
	else
		table_sort(self.players, function(a, b)
			if a.prio == b.prio then
				return a.id < b.id
			else
				return a.prio > b.prio
			end
		end)
	end

	self.dirty = false
	return true
end
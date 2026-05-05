if not wbLeadHelper then wbLeadHelper = {} end

-- You can get the numbers for the colors here: https://www.rapidtables.com/web/color/RGB_Color.html
wbLeadHelper.Colors = {
	white = {255, 255, 255},
    red = {240, 60, 60},
    green = {0, 150, 50},
    blue = {60, 120, 200},
    yellow = {255, 170, 70},
    grey = {150, 150, 150},
    black = {0, 0, 0}    
}

wbLeadHelper.DefaultSettings = {
	settingsVersion = 1,
	messageStart = "<icon49>", -- Will be added to the start of the message. Don't use >> it won't work!
	messageEnd = "<icon49>", -- Will be added to the end of the message.
	textColor = "white",
	windowSize = 0.65, -- scales the size of the window (doh..) 0.5 is 50% for example
	showLfgIcons = false,
	disableAltSpecCheck = false,
	disableAltSpecCheckForRunePriestZealot = false,
	showMiscBoColumn = true, -- show a right-hand column with MiscBoNames
	messages = {
		-- First value is the message label which is shown in the overview. Second is the message that is put in chat.
		{ label = "*Count*<nl>*down*", labelColor = "white", message = "This is the countdown menu, don't rename it!", messageColor ="white", type = "Countdown" },
		{ label = "Check buffs", labelColor = "white", message = "Check your buffs, guard and potions", messageColor ="white", type = "Normal" },
		{ label = "kick<nl>explain", labelColor = "white", message = "This is an organized warband, please understand that you will be kicked in 1 minute if you are not close to <GL> by then. Thanks", messageColor ="white", type = "Normal"},
		{ label = "*LFM*", labelColor = "white", message = "Organized warband looking for - <LFM> - in - <LFMZ> - Please message <GL>", messageColor ="white", type = "LFM" },
		{ label = "AUTO<nl>(8/8/8)", labelColor = "white", message = "<autoRoles8>", messageColor ="white", type = "LFM", submenu = "Parent" },
		{ label = "<healer> / <tank> / <dps>", labelColor = "white", message = "<healer> / <tank> / <dps>", messageColor ="white", type = "LFM", submenu = "LFM" },
		{ label = "<healer> / <tank>", labelColor = "white", message = "<healer> / <tank>", messageColor ="white", type = "LFM", submenu = "LFM" },
		{ label = "<healer>", labelColor = "white", message = "<healer>", messageColor ="white", type = "LFM", submenu = "LFM" },
		{ label = "<tank>", labelColor = "white", message = "<tank>", messageColor ="white", type = "LFM", submenu = "LFM" },
		{ label = "<dps>", labelColor = "white", message = "<dps>", messageColor ="white", type = "LFM", submenu = "LFM" },

		{ label = "*LFM*<nl>*Group*", labelColor = "white", message = "Looking for - <LFM> - Please message <GL>", messageColor ="white", type = "LFM", isNotEnabled = true},
		{ label = "AUTO<nl>(2/2/2)", labelColor = "white", message = "<autoRoles2>", messageColor ="white", type = "LFM", submenu = "Parent", isNotEnabled = true},

		{ label = "Ready to move", labelColor = "green", message = "Get ready to move, GATHER at my position and MOUNT UP FAST!", messageColor ="green", type = "Normal" },
		{ label = "Moving, follow", labelColor = "green", message = "MOVING, follow me!", messageColor ="green", type = "Normal" },
		{ label = "*Move*<nl>*to BO*", labelColor = "green", message = "MOVING! Go to BO - <B>", messageColor ="green", type = "Bos" },
		{ label = "*Relocate*<nl>*to Zone*", labelColor = "green", message = "RELOCATION! Go to zone - <Z>!", messageColor ="green", type = "Zones" },

		{ label = "Regroup", labelColor = "blue", message = "Regroup at my position", messageColor ="blue", type = "Normal" },
		{ label = "Rel & Reg", labelColor = "blue", message = "RELEASE and regroup on me", messageColor ="blue", type = "Normal" },
		{ label = "Stay", labelColor = "yellow", message = "STAY at my position!", messageColor ="yellow", type = "Normal" },
		{ label = "Hold, no attack", labelColor = "yellow", message = "Hold position, DON'T attack!", messageColor ="yellow", type = "Normal" },
		{ label = "Get R<nl>to push", labelColor = "yellow", message = "GET READY TO PUSH!", messageColor ="yellow", type = "Normal" },
		{ label = "Attack", labelColor = "red", message = "Attack in my direction!", messageColor ="red", type = "Normal" },
		{ label = "Enemy Behind", labelColor = "red", message = "ENEMY BEHIND", messageColor ="red", type = "Normal" },
		{ label = "OIL", labelColor = "red", message = "OIL OIL OIL", messageColor ="red", type = "Normal" },
	},
}

wbLeadHelper.messageTypes = {
	"Normal",
	"Countdown",
	"LFM",
	"Bos",
	"Zones",
};

-- templates
wbLeadHelper.Templates = {
	[1] = {
		titleWidth = 262,
		buttonWidth = 130,
		buttonHeight = 60,
		buttonsPerRow = 8,
	},
	[2] = {
		titleWidth = 400,
		buttonWidth = 220,
		buttonHeight = 40,
		buttonsPerRow = 14,
	},	
}

wbLeadHelper.CareerLineById = {
	[GameData.CareerLine.ENGINEER] = {["type"] = "rdps", ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20187>"},
	[GameData.CareerLine.BRIGHT_WIZARD] = {["type"] = "rdps", ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20183>"},
	[GameData.CareerLine.SORCERER] = {["type"] = "rdps", ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20196>"},
	[GameData.CareerLine.SQUIG_HERDER] = {["type"] = "rdps", ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20197>"},
	[GameData.CareerLine.MAGUS] = {["type"] = "rdps", ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20191>"},
	[GameData.CareerLine.SHADOW_WARRIOR] = {["type"] = "rdps", ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20194>"},
	[GameData.CareerLine.WITCH_ELF] = {["type"] = "mdps", ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20201>"},
	[GameData.CareerLine.WHITE_LION] = {["type"] = "mdps", ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20200>"},
	[GameData.CareerLine.SLAYER] = {["type"] = "mdps", ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20188>"},
	[GameData.CareerLine.WITCH_HUNTER] = {["type"] = "mdps", ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20202>"},
	[GameData.CareerLine.CHOPPA] = {["type"] = "mdps", ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20184>"},
	[GameData.CareerLine.MARAUDER] = {["type"] = "mdps", ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20192>"},
	[GameData.CareerLine.IRON_BREAKER] = {["type"] = "tank",  ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20189>"},
	[GameData.CareerLine.CHOSEN] = {["type"] = "tank",  ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20185>"},
	[GameData.CareerLine.BLACK_ORC] = {["type"] = "tank",  ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20182>"},
	[GameData.CareerLine.KNIGHT] = {["type"] = "tank",  ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20190>"},
	[GameData.CareerLine.SWORDMASTER] = {["type"] = "tank",  ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20198>"},
	[GameData.CareerLine.BLACKGUARD] = {["type"] = "tank",  ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20181>"},
	[GameData.CareerLine.ZEALOT] = {["type"] = "healer", ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20203>"},
	[GameData.CareerLine.WARRIOR_PRIEST] = {["type"] = "healer", ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20199>"},
	[GameData.CareerLine.RUNE_PRIEST] = {["type"] = "healer", ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20193>"},
	[GameData.CareerLine.ARCHMAGE] = {["type"] = "healer", ["faction"] = GameData.Realm.ORDER, ["icon"] = "<icon20180>"},
	[GameData.CareerLine.SHAMAN] = {["type"] = "healer", ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20195>"},
	[GameData.CareerLine.DISCIPLE] = {["type"] = "healer", ["faction"] = GameData.Realm.DESTRUCTION, ["icon"] = "<icon20186>"},
}

wbLeadHelper.ZoneIds = {
	--Dwarfs vs Greenskins
	--6, -- L"Ekrund",
	--11, -- L"Mount Bloodhorn",
	7, -- L"Barak Varr",
	1, -- L"Marshes of Madness",
	2, -- L"The Badlands",
	8, -- L"Black Fire Pass",
	9, -- L"Kadrin Valley",
	5, -- L"Thunder Mountain",
	3, -- L"Black Crag",

	-- Forts
	--4, -- L"Butcher's Pass",
	--10, -- L"Stonewatch",

	--Chaos vs Empire
	--100, -- L"Norsca",
	--106, -- L"Nordland",
	107, -- L"Ostland",
	101, -- L"Troll Country",
	102, -- L"High Pass",
	108, -- L"Talabecland",
	103, -- L"Chaos Wastes",
	105, -- L"Praag",
	109, -- L"Reikland",

	-- Forts
	--104, -- L"The Maw",
	--110, -- L"Reikwald",

	--Cities
	--161, -- L"The Inevitable City",
	--162, -- L"Altdorf",

	--Land of the Dead
	--191, -- L"Necropolis of Zandri",

	--High Elves vs Dark Elves
	--200, -- L"The Blighted Isle",
	--206, -- L"Chrace",
	201, -- L"The Shadowlands",
	207, -- L"Ellyrion",
	202, -- L"Avelorn",
	208, -- L"Saphery",
	203, -- L"Caledor",
	205, -- L"Dragonwake",
	209, -- L"Eataine"

	-- Forts
	--204, -- L"Fell Landing"
	--210, -- L"Shining Way"
};

wbLeadHelper.MoveTo = {
	--Dwarfs vs Greenskins
	--6, -- L"Ekrund",
	--11, -- L"Mount Bloodhorn",
	7, -- L"Barak Varr",
	1, -- L"Marshes of Madness",
	2, -- L"The Badlands",
	8, -- L"Black Fire Pass",
	9, -- L"Kadrin Valley",
	5, -- L"Thunder Mountain",
	3, -- L"Black Crag",

	-- Forts
	4, -- L"Butcher's Pass",
	10, -- L"Stonewatch",

	--Chaos vs Empire
	--100, -- L"Norsca",
	--106, -- L"Nordland",
	107, -- L"Ostland",
	101, -- L"Troll Country",
	102, -- L"High Pass",
	108, -- L"Talabecland",
	103, -- L"Chaos Wastes",
	105, -- L"Praag",
	109, -- L"Reikland",

	-- Forts
	104, -- L"The Maw",
	110, -- L"Reikwald",

	--Cities
	--161, -- L"The Inevitable City",
	--162, -- L"Altdorf",

	--Land of the Dead
	191, -- L"Necropolis of Zandri",

	--High Elves vs Dark Elves
	--200, -- L"The Blighted Isle",
	--206, -- L"Chrace",
	201, -- L"The Shadowlands",
	207, -- L"Ellyrion",
	202, -- L"Avelorn",
	208, -- L"Saphery",
	203, -- L"Caledor",
	205, -- L"Dragonwake",
	209, -- L"Eataine"

	-- Forts
	204, -- L"Fell Landing"
	210, -- L"Shining Way"
};


wbLeadHelper.BosByZoneId = {
	[6]   = {"Cannon Battery", "Stonemine Tower", "MB - Ironmane Outpost", "MB - The Lookout"}, -- L"Ekrund",
	[11]  = {"Ironmane Outpost", "The Lookout", "Ekrund - Cannon Battery", "Ekrund - Stonemine Tower"}, -- L"Mount Bloodhorn",
	[7]   = {"The Lighthouse", "The Ironclad", "Marshes - Alcadizaar's Tomb", "Marshes - Goblin Armory"}, -- L"Barak Varr"
	[1]   = {"Alcadizaar's Tomb", "Goblin Armory", "Barak Varr - The Lighthouse", "Barak Varr - The Ironclad"}, -- L"Marshes of Madness",
	[2]   = {"Goblin Artillery Range", "Karagaz", "Black Fire - Bugman's Brewery", "Black Fire - Furrig's Fall"}, -- L"The Badlands",
	[8]   = {"Bugman's Brewery", "Furrig's Fall", "Badlands - Goblin Artillery Range", "Badlands - Karagaz"}, -- L"Black Fire Pass",
	[9]   = {"Hardwater Falls", "Icehearth Crossing", "Gromril Junction", "Dolgrund's Cairn"}, -- L"Kadrin Valley",
	[5]   = {"Thargrim's Headwall", "Doomstriker Vein", "Karak Palik", "Gromril Kruk"}, -- L"Thunder Mountain",
	[3]   = {"Squiggly Beast Pens", "Rottenpike Ravine", "Madcap Pickins", "Lobba Mill"}, -- L"Black Crag",
	[106] = {"Festenplatz", "The Harvest Shrine", "The Nordland XI"}, -- L"Nordland",		
	[107] = {"Kinschel's Stronghold", "Crypt of Weapons", "TC - Ruins of Greystone Keep", "TC - Monastery of Morr"}, -- L"Ostland",
	[101] = {"Ruins of Greystone Keep", "Monastery of Morr", "Ostland - Kinschel's Stronghold", "Ostland - Crypt of Weapons"}, -- L"Troll Country",
	[102] = {"Hallenfurt Manor", "Ogrund's Tavern", "Feiten's Lock", "Talabecland - Verentane's Tower"}, -- L"High Pass",
	[108] = {"Verentane's Tower", "High Pass - Feiten's Lock", "High Pass - Hallenfurt Manor", "High Pass - Ogrund's Tavern"}, -- L"Talabecland",
	[103] = {"Chokethorn Bramble", "Thaugamond Massif", "The Statue of Everchosen", "The Shrine of Time"}, -- L"Chaos Wastes",
	[105] = {"Kurlov's Armory", "Martyr's Square", "Manor of Ortel von Zaris", "Russenscheller Graveyard"}, -- L"Praag",
	[109] = {"Frostbeard's Quarry", "Reikwatch", "Runehammer Gunworks", "Schwenderhalle Manor"}, -- L"Reikland",
	[200] = {"The Altar of Khaine", "The House of Lorendyth", "Chrace - The Shard of Grief", "Chrace - The Tower of Nightflame"}, -- L"The Blighted Isle",
	[206] = {"The Shard of Grief", "The Tower of Nightflame", "Blighted Isle - The Altar of Khaine", "Blighted Isle - The House of Lorendyth"}, -- L"Chrace",		
	[201] = {"The Unicorn Siege Camp", "The Shadow Spire", "Ellyrion - The Needle of Ellyrion", "Ellyrion - The Reaver Stables"}, -- L"The Shadowlands",
	[207] = {"The Needle of Ellyrion", "The Reaver Stables", "SL - The Unicorn Siege Camp", "SL - The Shadow Spire"}, -- L"Ellyrion",
	[202] = {"Maiden's Landing", "The Wood Choppaz", "Saphery - Sari' Daroir", "Saphery - The Spire of Teclis"}, -- L"Avelorn",
	[208] = {"Sari' Daroir", "The Spire of Teclis", "Avelorn - The Wood Choppaz", "Avelorn - Maiden's Landing"}, -- L"Saphery",
	[203] = {"Druchii Barracks", "Shrine of the Conqueror", "Sarathanan Vale", "Senlathain Stand"}, -- L"Caledor",
	[205] = {"Fireguard Spire", "Mournfire's Approach", "Pelgorath's Ember", "Milaith's Memory"}, -- L"Dragonwake",
	[209] = {"Chillwind Manor", "Bel-Korhadris' Solitude", "Sanctuary of Dreams", "Ulthorin Siege Camp"}, -- L"Eataine"
	[4]   = {"Northwestern BO", "Northeastern BO", "Southeastern BO", "Southern BO", "Southwestern BO"}, -- L"Butcher's Pass",
	[10]  = {"Northern BO", "Eastern BO", "Southeastern BO", "Southwestern BO", "Western BO"}, -- L"Stonewatch",
	[104] = {"Eastern BO", "Southeastern BO", "Southern BO", "Southwestern BO", "Northwestern BO"}, -- L"The Maw",
	[110] = {"Northeastern BO", "Southeastern BO", "Southern BO", "Southwestern BO", "Northwestern BO"}, -- L"Reikwald",
	[204] = {"Northern BO", "Northeastern BO", "Southeastern BO", "Southwestern BO", "Northwestern BO"}, -- L"Fell Landing"
	[210] = {"Northern BO", "Eastern BO", "Southern BO", "Southwestern BO", "Northwestern BO"}, -- L"Shining Way"		
	[161] = {"Emissary of the Changer", "Khorne War Quaters", "Slaanesh Chambers", "Temple of the Damned", "The Lyceum", "The Outcrop"}, -- L"The Inevitable City",
	[162] = {"Emperor's Circle", "The Armory", "The Library", "The North Dock", "The South Dock", "The Siege Workshop"}, -- L"Altdorf",		
	[191] = {"Quay of Seftu", "Reflecting Pool", "Temple of Ualatp", "Pit of Kem Senef", "Tombs of the Bitter Winds", "Tomb of Burasut", "Tomb of the Moon", "The Library of Zandri", "The Quarry of Bone", "The Carrion Nest", "Nikosi Temple", "Pit of Asaph", "Tomb of the Sun", "Hall of the Heavens", "Forbidden Vaults", "Tomb of Rakmose", "Aerie of Death", "Obelisk of Judgement", "Sedjeht Temple"}, --L"Land of the Dead",	
};


wbLeadHelper.MiscBoNames = {
	"Destro Keep",
	"Order Keep",
	"North Postern",
	"East Postern",
	"South Postern",
	"West Postern"
};

-- ===== Whitelist Gate for MiscBoNames (keeps/posterns) =====
-- Build a fast lookup set from ZoneIds
wbLeadHelper._AllowedZoneSet = {}
do
    local _zids = wbLeadHelper.ZoneIds or {}
    for i = 1, #_zids do
        wbLeadHelper._AllowedZoneSet[_zids[i]] = true
    end
end

-- Utility to get current zone id (best-effort)
function wbLeadHelper.GetCurrentZoneId()
    local ok, id = pcall(function()
        if GameData and GameData.Player and GameData.Player.zone then return GameData.Player.zone end
        if GameData and GameData.Player and GameData.Player.zoneId then return GameData.Player.zoneId end
        if GetZoneId then return GetZoneId() end
        return nil
    end)
    if ok and id then return id end
    return nil
end

-- Check whitelist
function wbLeadHelper.IsZoneAllowed(zoneId)
    return zoneId ~= nil and wbLeadHelper._AllowedZoneSet[zoneId] == true
end

-- Preserve original MiscBoNames so we can restore it in allowed zones
local function _wbLH_shallow_copy(t)
    local r = {}
    if type(t) == "table" then
        for k, v in pairs(t) do r[k] = v end
    end
    return r
end
wbLeadHelper._OriginalMiscBoNames = wbLeadHelper._OriginalMiscBoNames or _wbLH_shallow_copy(wbLeadHelper.MiscBoNames)

-- Public accessor that respects ZoneIds without touching BosByZoneId
function wbLeadHelper.GetMiscBoNamesForZone(zoneId)
    if not wbLeadHelper.IsZoneAllowed(zoneId) then
        return {}
    end
    return wbLeadHelper._OriginalMiscBoNames or {}
end

-- Protect legacy callers that read wbLeadHelper.MiscBoNames directly
function wbLeadHelper._ApplyMiscWhitelistGate()
    local zid = wbLeadHelper.GetCurrentZoneId()
    if wbLeadHelper.IsZoneAllowed(zid) then
        wbLeadHelper.MiscBoNames = _wbLH_shallow_copy(wbLeadHelper._OriginalMiscBoNames)
    else
        wbLeadHelper.MiscBoNames = {}
    end
end

-- Apply now and on key lifecycle events
wbLeadHelper._ApplyMiscWhitelistGate()

if RegisterEventHandler and SystemData and SystemData.Events then
    pcall(function()
        RegisterEventHandler(SystemData.Events.LOADING_END, "wbLeadHelper._ApplyMiscWhitelistGate")
    end)
    pcall(function()
        RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "wbLeadHelper._ApplyMiscWhitelistGate")
    end)
end
-- ===== End Whitelist Gate =====


wbLeadHelper.CountdownSteps = {
	5,
	10,
	20,
	30,
	60,
	120,
	180,
};

-- fake data for debugging
wbLeadHelper.FakeWbData = {
	-- group 1
	{
		["players"] = {
			{
				["isGroupLeader"] = true,
				["name"] = "Shaman1",
				["careerLine"] = 7,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Zealot 1",
				["careerLine"] = 15,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Black Orc 1",
				["careerLine"] = 5,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Choppa 1",
				["careerLine"] = 6,
			}
		}
	},
	-- group 2
	{
		["players"] = {
			{
				["isGroupLeader"] = false,
				["name"] = "Choppa 1",
				["careerLine"] = 6,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Choppa 1",
				["careerLine"] = 6,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Choppa 2",
				["careerLine"] = 6,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Choosen 1",
				["careerLine"] = 13,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Choosen 1",
				["careerLine"] = 13,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Choosen 1",
				["careerLine"] = 13,
			}
		}
	},
	-- group 3
	{
		["players"] = {
			{
				["isGroupLeader"] = false,
				["name"] = "Choosen 1",
				["careerLine"] = 13,
			},				{
				["isGroupLeader"] = false,
				["name"] = "Choosen 1",
				["careerLine"] = 13,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Choppa 2",
				["careerLine"] = 6,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Zealot 1",
				["careerLine"] = 15,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Zealot 1",
				["careerLine"] = 15,
			}
		}
	},
		-- group 4
	{
		["players"] = {
			{
				["isGroupLeader"] = false,
				["name"] = "Choosen 1",
				["careerLine"] = 13,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Zealot 1",
				["careerLine"] = 15,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Zealot 1",
				["careerLine"] = 15,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Zealot 1",
				["careerLine"] = 15,
			},
			{
				["isGroupLeader"] = false,
				["name"] = "Zealot 1",
				["careerLine"] = 15,
			},{
				["isGroupLeader"] = false,
				["name"] = "Choosen 1",
				["careerLine"] = 13,
			}
		}
	}
};

wbLeadHelper.FakeGroupData = {
	{
		["isGroupLeader"] = true,
		["online"] = true,
		["name"] = "Choosen 1",
		["careerLine"] = 13,
	},				{
		["isGroupLeader"] = false,
		["online"] = true,
		["name"] = "Choosen 2",
		["careerLine"] = 13,
	},
	{
		["isGroupLeader"] = false,
		["online"] = true,
		["name"] = "Choppa 1",
		["careerLine"] = 6,
	},
	{
		["isGroupLeader"] = false,
		["online"] = true,
		["name"] = "Zealot 1",
		["careerLine"] = 15,
	}
};

wbLeadHelper.FakeGroupData2 = {
	{
		["isGroupLeader"] = true,
		["online"] = true,
		["name"] = "Choppay",
		["careerLine"] = 6,
	},
	{
		["isGroupLeader"] = false,
		["online"] = true,
		["name"] = "ChoppaChop",
		["careerLine"] = 6,
	},
};

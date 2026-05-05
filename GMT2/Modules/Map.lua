GMT2.Map = {}

local table_insert = table.insert
local string_format = string.format
local math_ceil = math.ceil
local ipairs = ipairs


local PlayerName = wstring.sub( GameData.Player.name,1,-3 )

function GMT2.Map.OnInitialize()
	WindowRegisterEventHandler("EA_Window_WorldMapZoneViewMapDisplay", SystemData.Events.R_BUTTON_DOWN_PROCESSED, "GMT2.Map.OnClickMap")
	WindowRegisterCoreEventHandler("EA_Window_WorldMapZoneViewMapDisplay", "OnShown", "GMT2.Map.WorldMapOnShown")
	WindowRegisterCoreEventHandler("EA_Window_WorldMapZoneViewMapDisplay", "OnHidden", "GMT2.Map.WorldMapOnHidden")

	CreateWindowFromTemplate("GMT2Xpin", "GMT2Marker", "EA_Window_WorldMapZoneViewMapDisplay")
	CreateWindowFromTemplate("GMT2TargetPin", "GMT2Marker", "EA_Window_WorldMapZoneViewMapDisplay")
	CreateWindowFromTemplate("GMT2.Map_ZoneSelect", "GMT2.MapZoneSelect", "EA_Window_WorldMapZoneView")

	WindowSetShowing("GMT2Xpin", false)
	WindowSetTintColor("GMT2XpinX_0", 200, 255, 200)
	WindowSetShowing("GMT2TargetPin", false)
	WindowSetTintColor("GMT2TargetPinX_0", 240, 55, 55)

	GMT2.Map.CurrentSelectedZone = GameData.Player.zone
	GMT2.Map.DropBoxSelect = 1
	GMT2.Map.SelectedSearchZoneList = {}
	GMT2.Map.ZoneID = {}
	GMT2.Map.ZoneID[1] = -1

	GMT2.Map.UpdateZoneList()

	CreateWindowFromTemplate("GMT2.MapBossTeleport", "GMT2.MapBossTeleport", "EA_Window_WorldMapZoneView")

	-- Correct order: build portals first, then populate bosses
	GMT2.Map.BuildPortalStart()
	GMT2.Map.PopulateBossList()

	WindowRegisterEventHandler("Root", SystemData.Events.LOADING_END, "GMT2.Map.HandleZoneChange")
	WindowRegisterEventHandler("Root", SystemData.Events.PLAYER_ZONE_CHANGED, "GMT2.Map.HandleZoneChange")
	WindowRegisterEventHandler("GMT2.MapBossTeleport_BossList", SystemData.Events.USER_SETTINGS_CHANGED, "GMT2.Map.OnBossSelected")
end

GMT2.Map.ZoneInfo = {}

-- Dwarves vs Greenskins --
---------------------------
GMT2.Map.ZoneInfo[6]  = { offsetX  = 737280,  offsetY  = 843776,  -- Ekrund
                            mapsizeX = 65536,   mapsizeY = 65536,
                            sharedWorld  = { [11] = true,
											 [6]  = true, }, }
GMT2.Map.ZoneInfo[11] = { offsetX  = 802816,  offsetY  = 843776, -- Mount Bloodhorn
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [11] = true, 
											 [6]  = true, }, }
GMT2.Map.ZoneInfo[7]  = { offsetX  = 1032192, offsetY  = 794624,  -- Barak Varr 
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [1] = true,
											 [7] = true, }, }
GMT2.Map.ZoneInfo[1]  = { offsetX  = 1032192, offsetY  = 860160,  -- Marshes of Madness
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [1] = true,
											 [7] = true, }, }
GMT2.Map.ZoneInfo[8]  = { offsetX  = 1236992,  offsetY  = 827392,  -- Black Fire Pass
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [2] = true,
											 [8] = true, }, }
GMT2.Map.ZoneInfo[2]  = { offsetX  = 1236992,  offsetY  = 892928,  -- The Badlands
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [2] = true,
											 [8] = true, }, }
GMT2.Map.ZoneInfo[10] = { offsetX  = 1368064, offsetY  = 761856,  -- Stonewatch
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [10] = true,
											[9]  = true,
											[5]  = true,
											[26] = true,
											[27] = true,
											[3]  = true,
											[4]  = true, }, }
GMT2.Map.ZoneInfo[9]  = { offsetX = 1368064,  offsetY  = 827392,  -- Kadrin Valley
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [10] = true,
											[9]  = true,
											[5]  = true,
											[26] = true,
											[27] = true,
											[3]  = true,
											[4]  = true, }, }
GMT2.Map.ZoneInfo[5]  = { offsetX  = 1368064, offsetY  = 892928,  -- Thunder Mountain
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [10] = true,
											[9]  = true,
											[5]  = true,
											[26] = true,
											[27] = true,
											[3]  = true,
											[4]  = true, }, }
GMT2.Map.ZoneInfo[26] = { offsetX = 1302528,  offsetY  = 892928,  -- Cinderfall
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [10] = true,
											[9]  = true,
											[5]  = true,
											[26] = true,
											[27] = true,
											[3]  = true,
											[4]  = true, }, }
GMT2.Map.ZoneInfo[27] = { offsetX = 1433600,  offsetY  = 892928,  -- Death Peak
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [10] = true,
											[9]  = true,
											[5]  = true,
											[26] = true,
											[27] = true,
											[3]  = true,
											[4]  = true, }, }
GMT2.Map.ZoneInfo[3]  = { offsetX = 1368064,  offsetY  = 958464,  -- Black Crag
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [10] = true,
											[9]  = true,
											[5]  = true,
											[26] = true,
											[27] = true,
											[3]  = true,
											[4]  = true, }, }
GMT2.Map.ZoneInfo[4]  = { offsetX = 1368064,  offsetY  = 1024000, -- Butchers Pass
                            mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [10] = true,
											[9]  = true,
											[5]  = true,
											[26] = true,
											[27] = true,
											[3]  = true,
											[4]  = true, }, }

-- Empire vs Chaos --
---------------------
GMT2.Map.ZoneInfo[100] = { offsetX  = 819200,  offsetY  = 819200, -- Norsca
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [100] = true,
											 [106] = true, }, }
GMT2.Map.ZoneInfo[106] = { offsetX  = 819200,  offsetY  = 884736, -- Nordland
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [100] = true,
											 [106] = true, }, }
GMT2.Map.ZoneInfo[101] = { offsetX  = 1015808, offsetY  = 819200, -- Troll Country
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [101] = true,
											 [107] = true, }, }
GMT2.Map.ZoneInfo[107] = { offsetX  = 1015808, offsetY  = 884736, -- Ostland
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [101] = true,
											 [107] = true, }, }
GMT2.Map.ZoneInfo[102] = { offsetX  = 1212416, offsetY  = 819200, -- High Pass
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [102] = true,
											 [108] = true, }, }
GMT2.Map.ZoneInfo[108] = { offsetX  = 1212416, offsetY  = 884736, -- Talabecland
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [102] = true,
											 [108] = true, }, }
GMT2.Map.ZoneInfo[104] = { offsetX  = 1409024, offsetY  = 688128, -- The Maw
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [103] = true,
											 [104] = true,
											 [105] = true,
											 [120] = true,
											 [109] = true,
											 [110] = true, }, }
GMT2.Map.ZoneInfo[103] = { offsetX  = 1409024, offsetY  = 753664, -- Chaos Wastes
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [103] = true,
											 [104] = true,
											 [105] = true,
											 [120] = true,
											 [109] = true,
											 [110] = true, }, }
GMT2.Map.ZoneInfo[105] = { offsetX  = 1409024, offsetY  = 819200, -- Praag
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [103] = true,
											 [104] = true,
											 [105] = true,
											 [120] = true,
											 [109] = true,
											 [110] = true, }, }
GMT2.Map.ZoneInfo[120] = { offsetX  = 1343488, offsetY  = 819200, -- West Praag
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [103] = true,
											 [104] = true,
											 [105] = true,
											 [120] = true,
											 [109] = true,
											 [110] = true, }, }
GMT2.Map.ZoneInfo[109] = { offsetX  = 1409024, offsetY  = 884736, -- Reikland
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [103] = true,
											 [104] = true,
											 [105] = true,
											 [120] = true,
											 [109] = true,
											 [110] = true, }, }
GMT2.Map.ZoneInfo[110] = { offsetX  = 1409024, offsetY  = 950272, -- Reikwald
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [103] = true,
											 [104] = true,
											 [105] = true,
											 [120] = true,
											 [109] = true,
											 [110] = true, }, }

-- High Elf vs Dark Elf --
--------------------------
GMT2.Map.ZoneInfo[200] = { offsetX  = 1015808, offsetY  = 1015808, -- The Blighted Isle
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [200] = true,
											 [206] = true, }, }
GMT2.Map.ZoneInfo[206] = { offsetX  = 1015808, offsetY  = 1081344, -- Chrace
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [200] = true,
											 [206] = true, }, }
GMT2.Map.ZoneInfo[201] = { offsetX  = 819200,  offsetY  = 1212416, -- The Shadowlands
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [201] = true,
											 [207] = true, }, }
GMT2.Map.ZoneInfo[207] = { offsetX  = 819200,  offsetY  = 1277952, -- Ellyrion
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [201] = true,
											 [207] = true, }, }
GMT2.Map.ZoneInfo[202] = { offsetX  = 1409024, offsetY  = 1409024, -- Avelorn
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [202] = true,
											 [208] = true, }, }
GMT2.Map.ZoneInfo[208] = { offsetX  = 1409024, offsetY  = 1474560, -- Saphery
                             mapsizeX = 65536,   mapsizeY = 65536,
							sharedWorld  = { [202] = true,
											 [208] = true, }, }
GMT2.Map.ZoneInfo[204] = { offsetX  = 819200,  offsetY  = 1605632, -- Fell Landing
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [203] = true,
											 [204] = true,
											 [205] = true,
											 [220] = true,
											 [209] = true,
											 [210] = true, }, }
GMT2.Map.ZoneInfo[203] = { offsetX  = 884736,  offsetY  = 1605632, -- Caledor
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [203] = true,
											 [204] = true,
											 [205] = true,
											 [220] = true,
											 [209] = true,
											 [210] = true, }, }

GMT2.Map.ZoneInfo[191] = { offsetX  = 196532,  offsetY  = 1490883, -- Land of the dead --offsetX  = 196866,  offsetY  = 1490741, WarCommander data
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [203] = true,
											 [204] = true,
											 [205] = true,
											 [220] = true,
											 [209] = true,
											 [210] = true, }, }

GMT2.Map.ZoneInfo[205] = { offsetX  = 950272,  offsetY  = 1605632, -- Dragonwake
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [203] = true,
											 [204] = true,
											 [205] = true,
											 [220] = true,
											 [209] = true,
											 [210] = true, }, }
GMT2.Map.ZoneInfo[220] = { offsetX  = 950272,  offsetY  = 1474560, -- Isle of the Dead
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [203] = true,
											 [204] = true,
											 [205] = true,
											 [220] = true,
											 [209] = true,
											 [210] = true, }, }
GMT2.Map.ZoneInfo[209] = { offsetX  = 1015808, offsetY  = 1605632, -- Eataine
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [203] = true,
											 [204] = true,
											 [205] = true,
											 [220] = true,
											 [209] = true,
											 [210] = true, }, }
GMT2.Map.ZoneInfo[210] = { offsetX  = 1081344, offsetY  = 1605632, -- Shining Way
                             mapsizeX = 65536,   mapsizeY = 65536,
                             sharedWorld  = { [203] = true,
											 [204] = true,
											 [205] = true,
											 [220] = true,
											 [209] = true,
											 [210] = true, }, }

-- Capital City --
------------------
GMT2.Map.ZoneInfo[161] = {offsetX=439365,offsetY=130714,mapsizeX=44064,mapsizeY=44064,mapStartOffsetX=10816,mapStartOffsetY=15712} -- Inevitable City
GMT2.Map.ZoneInfo[162] = {offsetX=104857,offsetY=112264,mapsizeX=41760,mapsizeY=41760,mapStartOffsetX=6318,mapStartOffsetY=14108}-- Altdorf

-- Capital City At War --
--[[GMT2.Map.ZoneInfo[167] = { offsetX  = 420300,  offsetY  = 114032, -- The Inevitable City
                             mapsizeX = 44064,   mapsizeY = 44064, }]]--
GMT2.Map.ZoneInfo[167] = { offsetX  = 19103,  offsetY  = 220590, -- IC	-- from WARCommander
                             mapsizeX = 44000,   mapsizeY = 44000,mapStartOffsetX=10816,mapStartOffsetY=15712 }
--[[GMT2.Map.ZoneInfo[168] = { offsetX  = 104857,  offsetY  = 112264, -- Altdorf
                             mapsizeX = 41760,   mapsizeY = 41760, }]]--
GMT2.Map.ZoneInfo[168] = { offsetX  = 14439,  offsetY  = 743177, -- Altdorf	-- from WARCommander
                             mapsizeX = 41760,   mapsizeY = 41760,mapStartOffsetX=6318,mapStartOffsetY=14108 }
-- Capital City Scenario --
GMT2.Map.ZoneInfo[42]  = { offsetX  = 420300,  offsetY  = 114032, -- The Undercroft
                             mapsizeX = 44064,   mapsizeY = 44064, }
--[[WARCommander_ZoneInfo[42] = { offsetX  = 19198,  offsetY  = 28296, -- Undercroft
                             mapsizeX = 40178,   mapsizeY = 40178, }]]--
GMT2.Map.ZoneInfo[41]  = { offsetX  = 104857,  offsetY  = 112264, -- Altdorf War Quarter
                             mapsizeX = 41760,   mapsizeY = 41760, }
--[[WARCommander_ZoneInfo[41]  = { offsetX  = 17253,  offsetY  = 293432, -- Altdorf War Quarter
                            mapsizeX = 32620,   mapsizeY = 32620, }]]--
-- Zones in the capital --
GMT2.Map.ZoneInfo[178] = { noMap = true } -- The Viper Pit
GMT2.Map.ZoneInfo[198] = { noMap = true } -- Sigmar's Hammer
GMT2.Map.ZoneInfo[172] = { noMap = true } -- The Eternal Citadel
GMT2.Map.ZoneInfo[170] = { noMap = true } -- Altdorf Palace

-- Orc City --
GMT2.Map.ZoneInfo[61] = {offsetX=1375917,offsetY=1040577,mapsizeX=49648,mapsizeY=46097,mapStartOffsetX=341,mapStartOffsetY=257}-- Karak Eight Peaks
GMT2.Map.ZoneInfo[96] = {offsetX=1375429,offsetY=910101,mapsizeX=53048,mapsizeY=51147,mapStartOffsetX=340,mapStartOffsetY=227}-- Karak Eight Peaks Da Deeps

-- Dwarf City --
GMT2.Map.ZoneInfo[62] = {offsetX=196534,offsetY=1474399,mapsizeX=47268,mapsizeY=50464,mapStartOffsetX=6318,mapStartOffsetY=14108}-- Karak-a-Karak
GMT2.Map.ZoneInfo[97] = {offsetX=196572,offsetY=196502,mapsizeX=56915,mapsizeY=62452,mapStartOffsetX=6318,mapStartOffsetY=14108}-- Karak-a-Karak Middle Deeps

-- Scenarios --
----------------
-- Tier 1 --
GMT2.Map.ZoneInfo[30]  = {offsetX=32346,offsetY=32346,mapsizeX=13952,mapsizeY=13952,chunkX=65536,chunkY=65536,mapStartOffsetX=24752,mapStartOffsetY=24231}  -- Gates of Ekrund
GMT2.Map.ZoneInfo[130] = {offsetX=30811,offsetY=29564,mapsizeX=16032,mapsizeY=16032,chunkX=65536,chunkY=65536,mapStartOffsetX=22610,mapStartOffsetY=21390} -- Nordenwatch
GMT2.Map.ZoneInfo[230] = {offsetX=37863,offsetY=38574,mapsizeX=14528,mapsizeY=14528,chunkX=65536,chunkY=65536,mapStartOffsetX=29680,mapStartOffsetY=30458} -- Khaine's Embrace
-- Tier 2 --
GMT2.Map.ZoneInfo[31]  = {offsetX=39025,offsetY=30143,mapsizeX=12192,mapsizeY=12192,chunkX=65536,chunkY=65536,mapStartOffsetX=30830,mapStartOffsetY=21974} -- Mourkain Temple
GMT2.Map.ZoneInfo[131] = {offsetX=28507,offsetY=31902,mapsizeX=17856,mapsizeY=17856,chunkX=65536,chunkY=65536,mapStartOffsetX=20340,mapStartOffsetY=23724} -- Stonetroll Crossing
GMT2.Map.ZoneInfo[231] = {offsetX=28239,offsetY=32041,mapsizeX=17760,mapsizeY=17760,chunkX=65536,chunkY=65536,mapStartOffsetX=20052,mapStartOffsetY=23852} -- Phoenix Gate
-- Tier 3 --
GMT2.Map.ZoneInfo[33]  = {offsetX=32652,offsetY=34113,mapsizeX=13119,mapsizeY=13119,chunkX=65536,chunkY=65536,mapStartOffsetX=25775,mapStartOffsetY=24489} -- Doomfist Crater
GMT2.Map.ZoneInfo[38]  = {offsetX=33244,offsetY=28354,mapsizeX=19552,mapsizeY=19552,chunkX=65536,chunkY=65536,mapStartOffsetX=25046,mapStartOffsetY=20141} -- Black Fire Basin
GMT2.Map.ZoneInfo[132] = {offsetX=28487,offsetY=29289,mapsizeX=21440,mapsizeY=21440,chunkX=65536,chunkY=65536,mapStartOffsetX=20280,mapStartOffsetY=21134} -- Talabec Dam
GMT2.Map.ZoneInfo[139] = {offsetX=422498,offsetY=423594,mapsizeX=33687,mapsizeY = 34706,mapStartOffsetX=103,mapStartOffsetY=103} -- High Pass Cemetery
GMT2.Map.ZoneInfo[232] = {offsetX=26146,offsetY=34407,mapsizeX=20448,mapsizeY=20448,chunkX=65536,chunkY=65536,mapStartOffsetX=20439,mapStartOffsetY=23748}	-- Tor Anroc
GMT2.Map.ZoneInfo[236] = {offsetX =753773,offsetY=361059,mapsizeX=42289,mapsizeY=43064} -- Temple of Isha
-- Tire 4 --
GMT2.Map.ZoneInfo[43]  = {offsetX=327937,offsetY=524599,mapsizeX=33818,mapsizeY=34647,mapStartOffsetX=80,mapStartOffsetY=128} -- Gromril Crossing
GMT2.Map.ZoneInfo[44]  = {offsetX=453186,offsetY=522041,mapsizeX=36224,mapsizeY=38852,mapStartOffsetX=110,mapStartOffsetY=127} -- Howling Gorge
GMT2.Map.ZoneInfo[134] = {offsetX=29635,offsetY=35702,mapsizeX=18880,mapsizeY=18880,chunkX=65536,chunkY=65536,mapStartOffsetX=21429,mapStartOffsetY=27490} -- Reikland Hills
GMT2.Map.ZoneInfo[136] = {offsetX=35309,offsetY=34963,mapsizeX=19744,mapsizeY=19744,chunkX=65536,chunkY=65536,mapStartOffsetX=27126,mapStartOffsetY=26797} -- Battle for Praag
GMT2.Map.ZoneInfo[234] = {offsetX=37009,offsetY=36096,mapsizeX=16704,mapsizeY=16704,chunkX=65536,chunkY=65536,mapStartOffsetX=28787,mapStartOffsetY=27920} -- Serpent's Passage
GMT2.Map.ZoneInfo[235] = {offsetX=29340,offsetY=33540,mapsizeX=22848,mapsizeY=22848,chunkX=65536,chunkY=65536,mapStartOffsetX=21209,mapStartOffsetY=25327} -- Dragon's Bane
-- Unknown --
GMT2.Map.ZoneInfo[133] = {offsetX=31417,offsetY=36843,mapsizeX=16512,mapsizeY=16512,chunkX=65536,chunkY=65536,mapStartOffsetX=23186,mapStartOffsetY=28669} -- Maw of Madness
GMT2.Map.ZoneInfo[34]  = {offsetX=34610,offsetY=554266,mapsizeX=20832,mapsizeY=20832,chunkX=65536,chunkY=65536,mapStartOffsetX=26391,mapStartOffsetY=21774} -- Thunder Valley
GMT2.Map.ZoneInfo[137] = {offsetX=828961,offsetY=358042,mapsizeX=49257,mapsizeY=38332,mapStartOffsetX=33806,mapStartOffsetY=22829} -- Grovod Caverns
GMT2.Map.ZoneInfo[237] = {offsetX=22913,offsetY=30567,mapsizeX=20608,mapsizeY=20608,chunkX=65536,chunkY=65536,mapStartOffsetX=14711,mapStartOffsetY=22528} -- Caledor Woods
GMT2.Map.ZoneInfo[238] = {offsetX=23588,offsetY=31368,mapsizeX=18688,mapsizeY=18688,chunkX=65536,chunkY=65536,mapStartOffsetX=15445,mapStartOffsetY=23052} -- Blood of the Black Cairn
GMT2.Map.ZoneInfo[39]  = {offsetX=585282,offsetY=357200,mapsizeX=33582,mapsizeY=41219,mapStartOffsetX=142,mapStartOffsetY=87} -- Logrin's Forge

-- Live Event --
----------------
GMT2.Map.ZoneInfo[138] = {offsetX=32167,offsetY=35398,mapsizeX=14368,mapsizeY=14368,chunkX=65536,chunkY=65536,mapStartOffsetX=23984,mapStartOffsetY=27210} -- Reikland Factory

-- Scenario List --
GMT2.Map.ZoneInfo[230] = {offsetX=327682,offsetY=327682,mapsizeX=44095,mapsizeY=44889,mapStartOffsetX=88,mapStartOffsetY=88} -- Kaine's Embrace
GMT2.Map.ZoneInfo[414] = {offsetX=438984,offsetY=438984,mapsizeX=37364,mapsizeY=36456,mapStartOffsetX=112,mapStartOffsetY=112} -- Garden of Morr
GMT2.Map.ZoneInfo[30] = {offsetX=194500,offsetY=198891,mapsizeX=38564,mapsizeY=38106,mapStartOffsetX=47,mapStartOffsetY=48} -- Gates of Ekrund

-- LOTD --
GMT2.Map.ZoneInfo[413] = {offsetX=269570,offsetY=251535,mapsizeX=51849,mapsizeY=30764,mapStartOffsetX=65,mapStartOffsetY=61} -- Garden of Qu'aph

-- Hunter's Vale --
GMT2.Map.ZoneInfo[50] = {offsetX=328147,offsetY=524630,mapsizeX=49043,mapsizeY=49065,mapStartOffsetX=80,mapStartOffsetY=128} -- Hunter's Vale

--Bastion Stair -- Good Luck :)

GMT2.Map.ZoneInfo[160] = { noMap = true } -- Bastion Stair

--Map cordiantes function

GMT2.Map.Zone = {}
GMT2.Map.Zone[1] = {WorldTopX = 1032192,WorldTopY = 860160,worldTopZ = 151}
GMT2.Map.Zone[2] = {WorldTopX = 1237000,WorldTopY = 892930,worldTopZ = 151}
GMT2.Map.Zone[3] = {WorldTopX = 1368064,WorldTopY = 958466,worldTopZ = 151}
GMT2.Map.Zone[4] = {WorldTopX = 1368064,WorldTopY = 1024000,worldTopZ = 151}
GMT2.Map.Zone[5] = {WorldTopX = 1368064,WorldTopY = 892930,worldTopZ = 151}
GMT2.Map.Zone[6] = {WorldTopX = 737283,WorldTopY = 843781,worldTopZ = 151,WorldEndX = 802816,WorldEndY = 909300} -- Ekrund
GMT2.Map.Zone[7] = {WorldTopX = 1032192,WorldTopY = 794626,worldTopZ = 151}
GMT2.Map.Zone[8] = {WorldTopX = 1237000,WorldTopY = 827402,worldTopZ = 151}
GMT2.Map.Zone[9] = {WorldTopX = 1368064,WorldTopY = 827402,worldTopZ = 151}
GMT2.Map.Zone[10] = {WorldTopX = 1368064,WorldTopY = 761868,worldTopZ = 151}
GMT2.Map.Zone[11] = {WorldTopX = 802821,WorldTopY = 843780,worldTopZ = 151}--MT bloodhorn
GMT2.Map.Zone[26] = {WorldTopX = 1302537,WorldTopY = 892935,worldTopZ = 151}--cinderfall
GMT2.Map.Zone[27] = {WorldTopX = 1433618,WorldTopY = 892935,worldTopZ = 151}--deathpeak
GMT2.Map.Zone[50] = {WorldTopX = 294979,WorldTopY = 491317,worldTopZ = 5465}--Hunter's Vale
GMT2.Map.Zone[61] = {WorldTopX = 1367954,WorldTopY = 1024004,worldTopZ = 12000}--Karak Eight Peaks
GMT2.Map.Zone[62] = {WorldTopX = 196534,WorldTopY = 1474399,worldTopZ = 14000}--Karaz-a-Karak
GMT2.Map.Zone[96] = {WorldTopX = 1367940,WorldTopY = 892926,worldTopZ = 12700}--Karak Eight Peaks Da Deeps
GMT2.Map.Zone[97] = {WorldTopX = 196572,WorldTopY = 196502,worldTopZ = 10000}--Karaz-a-Karak Middle Deeps

--37 dont!!
GMT2.Map.Zone[100] = {WorldTopX = 819213,WorldTopY = 819206,worldTopZ = 151}--norsca
GMT2.Map.Zone[101] = {WorldTopX = 1015811,WorldTopY = 819206,worldTopZ = 151}--troll country
GMT2.Map.Zone[102] = {WorldTopX = 1212418,WorldTopY = 819206,worldTopZ = 151}--high pass
GMT2.Map.Zone[103] = {WorldTopX = 1409024,WorldTopY = 753664,worldTopZ = 151}--choas waste
GMT2.Map.Zone[104] = {WorldTopX = 1409026,WorldTopY = 688140,worldTopZ = 151}--the maw
GMT2.Map.Zone[105] = {WorldTopX = 1409026,WorldTopY = 819206,worldTopZ = 14912}--Praag
GMT2.Map.Zone[106] = {WorldTopX = 819213,WorldTopY = 884743,worldTopZ = 151}--Nordland
GMT2.Map.Zone[107] = {WorldTopX = 1015811,WorldTopY = 884767,worldTopZ = 151}--Ostland
GMT2.Map.Zone[108] = {WorldTopX = 1212418,WorldTopY = 884736,worldTopZ = 151}--Talabectland
GMT2.Map.Zone[109] = {WorldTopX = 1409026,WorldTopY = 884736,worldTopZ = 151}--Reikland
GMT2.Map.Zone[110] = {WorldTopX = 1409026,WorldTopY = 950276,worldTopZ = 151}--Reikwald
--117 is strange :D
GMT2.Map.Zone[120] = {WorldTopX = 1343500,WorldTopY = 819208,worldTopZ = 151}--West Praag
GMT2.Map.Zone[160] = {WorldTopX = 983017,WorldTopY = 983414,worldTopZ = 14326}--Bastion Stair
GMT2.Map.Zone[260] = {WorldTopX = 1376342,WorldTopY = 1540055,worldTopZ = 9000}-- Lost Vale
GMT2.Map.Zone[161] = {WorldTopX = 409609,WorldTopY = 98304,worldTopZ = 18230}--IC , need heigh cords here, because IC is built upon a void
GMT2.Map.Zone[162] = {WorldTopX = 98318,WorldTopY = 98321,worldTopZ = 14328}--Altdorf


GMT2.Map.Zone[200] = {WorldTopX = 1015808,WorldTopY = 1015808,worldTopZ = 151}--Blighted
GMT2.Map.Zone[201] = {WorldTopX = 819200,WorldTopY = 1212416,worldTopZ = 151}--shadowlands
GMT2.Map.Zone[202] = {WorldTopX = 1409024,WorldTopY = 1409024,worldTopZ = 151}--Avelorn
GMT2.Map.Zone[203] = {WorldTopX = 884736,WorldTopY = 1605632,worldTopZ = 151}--Calendor
GMT2.Map.Zone[204] = {WorldTopX = 819200,WorldTopY = 1605632,worldTopZ = 151}--Fell landing
GMT2.Map.Zone[205] = {WorldTopX = 950272,WorldTopY = 1605632,worldTopZ = 151}--Dragonwake
GMT2.Map.Zone[206] = {WorldTopX = 1015808,WorldTopY = 1081344,worldTopZ = 151}--Charce
GMT2.Map.Zone[207] = {WorldTopX = 819200,WorldTopY = 1277952,worldTopZ = 151}--Ellyrion
GMT2.Map.Zone[208] = {WorldTopX = 1409024,WorldTopY = 1474560,worldTopZ = 151}--Saphery
GMT2.Map.Zone[209] = {WorldTopX = 1015808,WorldTopY = 1605632,worldTopZ = 151}--Eataine
GMT2.Map.Zone[210] = {WorldTopX = 1081344,WorldTopY = 1605632,worldTopZ = 151}--Shining Way
GMT2.Map.Zone[220] = {WorldTopX = 950272,WorldTopY = 1474560,worldTopZ = 151}--Island of the Dead


GMT2.Map.Zone[191] = {WorldTopX = 196532,WorldTopY = 1490883,worldTopZ = 7000}--Land of the Dead

GMT2.Map.Zone[130] = {WorldTopX = 327682,WorldTopY = 327682,worldTopZ = 151}--Nordenwatch
GMT2.Map.Zone[136] = {WorldTopX = 35309,WorldTopY = 34963,worldTopZ = 151}-- Battle for Praag
GMT2.Map.Zone[137] = {WorldTopX = 786471,WorldTopY = 327634,worldTopZ = 8668}-- Grovod Caverns
GMT2.Map.Zone[138] = {WorldTopX = 32167,WorldTopY = 35398,worldTopZ = 151}-- Reikland Factory
GMT2.Map.Zone[139] = {WorldTopX = 393177,WorldTopY = 393208,worldTopZ = 15855}-- High Pass Cemetery


GMT2.Map.Zone[230] = {WorldTopX = 327682,WorldTopY = 327682,worldTopZ = 151}--Kaines embrace
GMT2.Map.Zone[231] = {WorldTopX = 28239,WorldTopY = 32041,worldTopZ = 151}-- Phoenix Gate
GMT2.Map.Zone[232] = {WorldTopX = 26146,WorldTopY = 34407,worldTopZ = 151}-- Tor Anroc
GMT2.Map.Zone[234] = {WorldTopX = 37009,WorldTopY = 36096,worldTopZ = 151}-- Serpent's Passage
GMT2.Map.Zone[235] = {WorldTopX = 29340,WorldTopY = 33540,worldTopZ = 151}-- Dragon's Bane
GMT2.Map.Zone[236] = {WorldTopX = 720895,WorldTopY = 327651,worldTopZ = 12500}-- Temple of Isha
GMT2.Map.Zone[237] = {WorldTopX = 22913,WorldTopY = 30567,worldTopZ = 151}-- Caledor Woods
GMT2.Map.Zone[238] = {WorldTopX = 23588,WorldTopY = 31368,worldTopZ = 151}-- Blood of the Black Cairn
GMT2.Map.Zone[413] = {WorldTopX = 229329,WorldTopY = 229286,worldTopZ = 9029}-- Garden of Qu'aph
GMT2.Map.Zone[414] = {WorldTopX = 425994,WorldTopY = 426005,worldTopZ = 5847}-- Garden of Morr

GMT2.Map.Zone[30] = {WorldTopX = 163878,WorldTopY = 163878,worldTopZ = 10190}--Gates of ekerund
GMT2.Map.Zone[31] = {WorldTopX = 295005,WorldTopY = 163844,worldTopZ = 151}--Mourkain Temple
GMT2.Map.Zone[33] = {WorldTopX = 32652,WorldTopY = 34113,worldTopZ = 151}-- Doomfist Crater
GMT2.Map.Zone[34] = {WorldTopX = 34610,WorldTopY = 554266,worldTopZ = 151}-- Thunder Valley
GMT2.Map.Zone[38] = {WorldTopX = 33244,WorldTopY = 28354,worldTopZ = 151}-- Black Fire Basin
GMT2.Map.Zone[39] = {WorldTopX = 557043,WorldTopY = 327680,worldTopZ = 9150}-- Logrin's Forge
GMT2.Map.Zone[43] = {WorldTopX = 294890,WorldTopY = 491433,worldTopZ = 9628}-- Gromril Crossing
GMT2.Map.Zone[44] = {WorldTopX = 425947,WorldTopY = 491444,worldTopZ = 6615}-- Howling Gorge

GMT2.Map.TeleportOverrides = {}

--Dwarf Safe Center Spots
GMT2.Map.TeleportOverrides[1] = {x = 1050833, y = 891329, z = 6972} -- Black Grag Safe Center
GMT2.Map.TeleportOverrides[3] = {x = 1405924, y = 996616, z = 9856} -- Black Grag Safe Center
GMT2.Map.TeleportOverrides[7] = {x = 1073415, y = 815744, z = 8976} -- Barak Varr Safe Center
GMT2.Map.TeleportOverrides[26] = {x = 1337711, y = 922770, z = 9056} -- Cinderfall Safe Center
GMT2.Map.TeleportOverrides[62] = {x = 225208, y = 1506397, z = 10933} -- Karaz-a-Karak Safe Center
GMT2.Map.TeleportOverrides[97] = {x = 221228, y = 227339, z = 9749} -- Karaz-a-Karak Middle Deeps Safe Center

--Empire Safe Center Spots
GMT2.Map.TeleportOverrides[103] = {x = 1452951, y = 782392, z = 20725} -- Chaos Wastes Safe Center
GMT2.Map.TeleportOverrides[162] = {x = 124132, y = 131931, z = 12715} -- Altdorf Safe Center

--High Elf Safe Center Spots
GMT2.Map.TeleportOverrides[202] = {x = 1446885, y = 1442742, z = 10187} -- Altdorf Safe Center
GMT2.Map.TeleportOverrides[203] = {x = 920895, y = 1644377, z = 13588} -- Caledor Safe Center
GMT2.Map.TeleportOverrides[204] = {x = 875124, y = 1629609, z = 8725} -- Fell Landing Safe Center
GMT2.Map.TeleportOverrides[205] = {x = 985496, y = 1628028, z = 9403} -- Dragonwake Safe Center
GMT2.Map.TeleportOverrides[207] = {x = 854871, y = 1319636, z = 11059} -- Ellyrion Safe Center
GMT2.Map.TeleportOverrides[209] = {x = 1048554, y = 1650597, z = 5962} -- Eataine Safe Center
GMT2.Map.TeleportOverrides[220] = {x = 982338, y = 1495462, z = 5760} -- Isle of the Dead Safe Center

--Chaos Safe Center Spots
GMT2.Map.TeleportOverrides[161] = {x = 440232, y = 135835, z = 17555} -- Chaos Wastes Safe Center

-- Scenario Safe Center Spots
GMT2.Map.TeleportOverrides[30] = {x = 194178, y = 194222, z = 9810} -- Gates of Ekrund Safe Center
GMT2.Map.TeleportOverrides[39] = {x = 581462, y = 359205, z = 9107} -- Logrin's Forge Safe Center
GMT2.Map.TeleportOverrides[43] = {x = 318962, y = 516422, z = 8806} -- Gromril Crossing Safe Center
GMT2.Map.TeleportOverrides[44] = {x = 453427, y = 522239, z = 5852} -- Howling Gorge Safe Center
GMT2.Map.TeleportOverrides[137] = {x = 828797, y = 358154, z = 8124} -- Grovod Caverns Safe Center
GMT2.Map.TeleportOverrides[139] = {x = 422282, y = 423512, z = 15623} -- High Pass Cemetery Safe Center
GMT2.Map.TeleportOverrides[230] = {x = 364664, y = 360556, z = 11322} -- Khaine's Embrace Safe Center
GMT2.Map.TeleportOverrides[236] = {x = 753996, y = 361995, z = 11563} -- Lost Temple of Isha Safe Center
GMT2.Map.TeleportOverrides[414] = {x = 458830, y = 458781, z = 5688} -- Garden of Morr Safe Center

-- Hunter's Vale --
GMT2.Map.TeleportOverrides[50] = {x = 316348, y = 528114, z = 4328} -- Hunter's Vale Safe Port to Entrance

-- Emissary Changes below
-----------------------------------------------
-- -- Teleports to Boss Locations in Dungeons --
GMT2.Map.Bosses = {
    -- Bastion Stair --
    {name = "BS L1 - Borzhar Rageborn", zone = 160, x = 1003194, y = 996601, z = 7343},
    {name = "BS L2 - Gahlvoth Darkrage", zone = 160, x = 998081, y = 994573, z = 6407},
	{name = "BS L3 - Azuk'Thul", zone = 160, x = 993984, y = 994216, z = 7464},
	{name = "BS L4 - Thar'lgnan", zone = 160, x = 998977, y = 989200, z = 8347},
	{name = "BS R1 - Urlf Dameonblessed", zone = 160, x = 1042659, y = 995059, z = 13689},
	{name = "BS R2 - Garithex the Mountain", zone = 160, x = 1035160, y = 998174, z = 14326},
	{name = "BS R3 - Chorek", zone = 160, x = 1028607, y = 997079, z = 14645},
	{name = "BS R4 - Lord Slaurith", zone = 160, x = 1020787, y = 998570, z = 14598},
	{name = "BS M - Wrackspite", zone = 160, x = 1013487, y = 1023609, z = 7832},
	{name = "BS M1 - Doomspike", zone = 160, x = 1013223, y = 1017885, z = 11940},
	{name = "BS M2 - Zekaraz the Bloodcaller", zone = 160, x = 1015900, y = 1013714, z = 17869},
	{name = "BS M3 - Kaarn the Vanquisher", zone = 160, x = 1013257, y = 1014136, z = 17849},
	{name = "BS M4 - Skull Lord Var'Ithrok", zone = 160, x = 1011456, y = 1013677, z = 17989},
	{name = "Murr Deyng", zone = 160, x = 1027766, y = 1000339, z = 6427, o = 1058 },
		-- Lost Vale --
	{ name = "LV L1 - Ahzranok", zone = 260, x = 1396271, y = 1582912, z = 5861 },
	{ name = "LV L2 - Malghor",                   zone = 260, x = 1398948, y = 1582142, z = 7901 },
	{ name = "LV L3 - Darkpromise Beast",         zone = 260, x = 1394286, y = 1569510, z = 6912 },
	{ name = "LV L4 - Dralel",                    zone = 260, x = 1398229, y = 1561130, z = 6308 },
	{ name = "LV R1 - Chul",                      zone = 260, x = 1429046, y = 1576073, z = 6924 },
	{ name = "LV R2 - Larg",                      zone = 260, x = 1426433, y = 1588462, z = 7985 },
	{ name = "LV R3 - Butcher Gutbeater",         zone = 260, x = 1421747, y = 1586435, z = 8415 },
	{ name = "LV R4 - Gorak",                     zone = 260, x = 1419073, y = 1573874, z = 7944 },
	{ name = "LV R5 - Sarthain",                  zone = 260, x = 1422504, y = 1566188, z = 8272 },
	{ name = "LV M1 - Zaar",                      zone = 260, x = 1410375, y = 1549918, z = 7612 },
	{ name = "LV M2 - Horgulul",                  zone = 260, x = 1415991, y = 1543725, z = 8296 },
	{ name = "LV M3 - Sechar",                    zone = 260, x = 1424037, y = 1548563, z = 10397 },
	{ name = "LV M4 - Nkari",                     zone = 260, x = 1432504, y = 1548121, z = 11002 },
	-- Gunbad --
	{name = "GB L1 - Griblik da Stinka", zone = 60, x = 858328, y = 851102, z = 28543},
	{name = "GB L2 - Bilebane the Rager", zone = 60, x = 862042, y = 853993, z = 26201},
	{name = "GB L3 - Garrolath da Poxbearer", zone = 60, x = 864350, y = 854470, z = 26133},
	{name = "GB L4 - Kurga da Squig-Maker", zone = 60, x = 860408, y = 860029, z = 26842},
	{name = "GB L5 - Foul Mouf da'ungry", zone = 60, x = 861164, y = 861659, z = 26570},
	{name = "GB L6 - Glomp", zone = 60, x = 862919, y = 864129, z = 26957},
	{name = "GB R1 - Brood Mother Szikalax", zone = 60, x = 845286, y = 857332, z = 28754},
	{name = "GB R2 - Masta Wrangla Glix", zone = 60, x = 842164, y = 854088, z = 26242},
	{name = "GB R3 - Elder Kizzig da Waaagha", zone = 60, x = 838917, y = 857695, z = 25867},
	{name = "GB R4 - Herald of Solithex", zone = 60, x = 841409, y = 859788, z = 25616},
	{name = "GB R5 - Masta Mixa", zone = 60, x = 845348, y = 861538, z = 26350},
	{name = "GB M1 - Redeye Big Oaf", zone = 60, x = 851510, y = 864343, z = 24287},
	{name = "GB M2 - Blaze da Tamin' Masta", zone = 60, x = 851107, y = 870036, z = 18649},
	{name = "GB M3 - Arathremia", zone = 60, x = 851780, y = 859556, z = 19533},
	{name = "GB M4 - Wight Lord Solithex", zone = 60, x = 849612, y = 859603, z = 19491},
	{name = "GB M5 - 'Ard ta Feed", zone = 60, x = 852046, y = 855165, z = 20362},
	-- Hunter Vale --
	{name = "HV 1st - Durthu-Wood Treekin", zone = 50, x = 318501, y = 534068, z = 3104},
	{name = "HV 2nd - Spellbiter", zone = 50, x = 323953, y = 533207, z = 3992},
	{name = "HV 3rd - Thanan Tree Lord", zone = 50, x = 326630, y = 531646, z = 4152},
	{name = "HV 4th - Peregra the Hound-Mother", zone = 50, x = 324365, y = 524687, z = 3689},
	{name = "HV 5th - Vorasyx the Wolf-Mother", zone = 50, x = 322236, y = 518745, z = 4784},
	{name = "HV 6th - Donapex the Lion-Mother", zone = 50, x = 331008, y = 524261, z = 4327},
	{name = "HV 7th - Cadaithaine Lion", zone = 50, x = 331256, y = 526151, z = 4384},
	{name = "HV 8th - Spirit of Kurnous", zone = 50, x = 326318, y = 525142, z = 7930},
	-- Crypts and Tunnels --
	{name = "CNT Auct - BOSS", zone = 177, x = 1596925, y = 208679, z = 8209},
	{name = "CNT Bank - BOSS", zone = 154, x = 219463, y = 204880, z = 7773},
	{name = "1st Crypts - Cryptweb Queen", zone = 176, x = 1501001, y = 220446, z = 8744},
	{name = "2nd Crypts - The Reaper", zone = 176, x = 1503057, y = 219566, z = 8556},
	{name = "3rd Crypts - Necromancer", zone = 176, x = 1504635, y = 215126, z = 8228},
	{name = "4th Crypts - Seraphine", zone = 176, x = 1497474, y = 222260, z = 8556},
	{name = "5th Crypts - Tobias The Fallen", zone = 176, x = 1496907, y = 217714, z = 8649},
	{name = "6th Crypts - Sister Eudocia", zone = 176, x = 1495300, y = 219952, z = 8556},
	{name = "7th Crypts - Twins", zone = 176, x = 1499452, y = 217168, z = 8612},
	-- Bilerot Burrow --
	{name = "BB 1st - Maggotfiend Urhil", zone = 196, x = 1503272, y = 1046353, z = 11960},
	{name = "BB 2nd - Ssrydian Morbidae", zone = 196, x = 1508002, y = 1043176, z = 11966},
	{name = "BB 3rd - Bartholomeus the Sickly", zone = 196, x = 1497369, y = 1047085, z = 10486},
	{name = "BB 4th - The Pox-Bloated Child", zone = 196, x = 1497382, y = 1045194, z = 10498},
	{name = "BB 5th - Ekscremite the Septic", zone = 196, x = 1506588, y = 1048907, z = 11963},
	{name = "BB Final - Bile Lord", zone = 196, x = 1502556, y = 1048473, z = 11398},
	-- Blood River Canyon --
	{name = "BRC 1st - Rune Priest", zone = 91, x = 855256, y = 838762, z = 10098, o = 982},
	{name = "BRC 2nd - Iron Breaker", zone = 91, x = 859156, y = 837215, z = 11639, o = 4079},
	{name = "BRC 3rd - Slayer", zone = 91, x = 869871, y = 838672, z = 11616, o = 2022},
	{name = "BRC 4th - Hammerer", zone = 91, x = 861692, y = 847010, z = 13016, o = 1914},
	{name = "BRC 5th - Miner", zone = 91, x = 872343, y = 855969, z = 11692, o = 3951},
	{name = "BRC 6th - Tinkerer", zone = 91, x = 861780, y = 851900, z = 13744, o = 3197},
	-- Bloodwrought Enclave --
	{name = "BE Left 1 - Korthuk the Raging", zone = 195, x = 1575674, y = 1047004, z = 11271},
	{name = "BE Right All", zone = 195, x = 1567391, y = 1047998, z = 11593},
	{name = "BE Straight", zone = 195, x = 1570009, y = 109283, z = 11116}
}

-- This is to make sure when you are on order you do not see the dungeons in zoneid 161 -- The Inevitable City
-- and when you are on Destro you do not see the dungeons in zoneid 162 -- Altdorf

GMT2.Map.CareerToFaction = {
    [GameData.CareerLine.IRON_BREAKER]   = "order",  -- 1
    [GameData.CareerLine.SLAYER]         = "order",  -- 2
    [GameData.CareerLine.RUNE_PRIEST]    = "order",  -- 3
    [GameData.CareerLine.ENGINEER]       = "order",  -- 4
    [GameData.CareerLine.BLACK_ORC]      = "destro", -- 5
    [GameData.CareerLine.CHOPPA]         = "destro", -- 6
    [GameData.CareerLine.SHAMAN]         = "destro", -- 7
    [GameData.CareerLine.SQUIG_HERDER]   = "destro", -- 8
    [GameData.CareerLine.WITCH_HUNTER]   = "order",  -- 9
    [GameData.CareerLine.KNIGHT]         = "order",  -- 10
    [GameData.CareerLine.BRIGHT_WIZARD]  = "order",  -- 11
    [GameData.CareerLine.WARRIOR_PRIEST] = "order",  -- 12
    [GameData.CareerLine.CHOSEN]         = "destro", -- 13
    [GameData.CareerLine.MARAUDER]       = "destro", -- 14
    [GameData.CareerLine.ZEALOT]         = "destro", -- 15
    [GameData.CareerLine.MAGUS]          = "destro", -- 16
    [GameData.CareerLine.SWORDMASTER]    = "order",  -- 17
    [GameData.CareerLine.SHADOW_WARRIOR] = "order",  -- 18
    [GameData.CareerLine.WHITE_LION]      = "order",  -- 19
    [GameData.CareerLine.ARCHMAGE]       = "order",  -- 20
    [GameData.CareerLine.BLACKGUARD]     = "destro", -- 21
    [GameData.CareerLine.WITCH_ELF]      = "destro", -- 22
    [GameData.CareerLine.DISCIPLE]       = "destro", -- 23
    [GameData.CareerLine.SORCERER]       = "destro"  -- 24
}

-- Dungeon Starting Points --
-- NOTE: This will port you right outside the dungeons (This is so you can have bosses spawned).
-- Entering without going through the portal will not spawn mobs
function GMT2.Map.BuildPortalStart()
	local faction = GMT2.Map.GetPlayerFaction()

	local lvStart
	if faction == "destro" then
		lvStart = { name = "LV - Start", zone = 202, x = 1412018, y = 1454332, z = 3561 }
	else
		lvStart = { name = "LV - Start", zone = 202, x = 1449923, y = 1459610, z = 3511, o = 550 }
	end

	GMT2.Map.PortalStart = {
		{ name = "Dragonback - Start", zone = 6,   x = 790864,  y = 864518,  z = 7756 },
		{ name = "BRC - Start",        zone = 61,  x = 1415253, y = 1067759,  z = 8964 },
		{ name = "GB - Start",         zone = 2,   x = 1241229, y = 896808,  z = 7510 },
		{ name = "HV - Start",         zone = 207, x = 876150,  y = 1331953, z = 8289 },
		{ name = "Crypts - Start",     zone = 162, x = 111532,  y = 137863,  z = 12272 },
		{ name = "Bilerot - Start",    zone = 161, x = 431503,  y = 133711,  z = 16214 },
		{ name = "BS - Start",         zone = 103, x = 1472467, y = 814024,  z = 16055 },
		lvStart -- Injected Lost Vale entry depending on faction
	}
end

function GMT2.Map.HandleZoneChange()
    GMT2.Map.BuildPortalStart()      -- Update faction-sensitive portal list
    GMT2.Map.PopulateBossList()      -- Rebuild boss dropdown
end

function GMT2.Map.OnBossSelected()
    local comboBox = "GMT2.MapBossTeleport_BossList"
    local selected = ComboBoxGetSelectedMenuItem(comboBox)

    -- Handle the "Current Dungeon" selection
    if selected == 1 then
        return
    end

    local selectedItem = GMT2.Map.CombinedList[selected]
    if not selectedItem then return end

    -- Default worldO to 0 if not provided
    local worldO = selectedItem.worldO or 0

    -- Construct the teleport command based on the selected item type
    local command = ""
    if selectedItem.type == "portal" or selectedItem.type == "boss" then
        command = string_format("]teleport map %d %d %d %d %d", selectedItem.zone, selectedItem.x, selectedItem.y, selectedItem.z, worldO)
    end

    if command ~= "" then
        local wstringCommand = towstring(command)
        SendChatText(wstringCommand, L"")
        ComboBoxSetSelectedMenuItem(comboBox, 1)
    end
end

function GMT2.Map.GetPlayerFaction()
    local careerLine = GameData.Player.career.line
    local faction = GMT2.Map.CareerToFaction[careerLine]
    
    if faction then
       -- d("Player Faction: " .. faction)
        return faction
    else
        --d("Career Line not found in faction mapping: " .. tostring(careerLine))
        return nil
    end
end

function GMT2.Map.PopulateBossList()
    local currentZone = GameData.Player.zone
    local faction = GMT2.Map.GetPlayerFaction() -- Determine the player's faction
    local comboBox = "GMT2.MapBossTeleport_BossList"
    ComboBoxClearMenuItems(comboBox)
    ComboBoxAddMenuItem(comboBox, L"Current Dungeon")

    GMT2.Map.CombinedList = {}
    table_insert(GMT2.Map.CombinedList, {name = L"Current Dungeon", type = "placeholder"})

    for _, portal in ipairs(GMT2.Map.PortalStart) do
        local addPortal = true -- Default to adding the portal
        -- Check faction-specific logic
        --if faction == "order" and (portal.zone == 161 or portal.zone == 61) then -- make this work after we go live with this
		if faction == "order" and (portal.zone == 161) then
            addPortal = false
           -- d("Hiding portal for Order: " .. tostring(portal.name))
        elseif faction == "destro" and portal.zone == 162 then
            addPortal = false
          --  d("Hiding portal for Destro: " .. tostring(portal.name))
        end

        if addPortal then
            table_insert(GMT2.Map.CombinedList, {name = towstring(portal.name), zone = portal.zone, x = portal.x, y = portal.y, z = portal.z, worldO = portal.worldO or portal.o, type = "portal"})
            ComboBoxAddMenuItem(comboBox, towstring(portal.name))
            --d("Adding portal: " .. tostring(portal.name))
        end
    end

    -- Add bosses next, filtered by currentZone
    for _, boss in ipairs(GMT2.Map.Bosses) do
        if boss.zone == currentZone then
            table_insert(GMT2.Map.CombinedList, {name = towstring(boss.name), zone = boss.zone, x = boss.x, y = boss.y, z = boss.z, worldO = boss.worldO or boss.o, type = "boss"})
            ComboBoxAddMenuItem(comboBox, towstring(boss.name))
        end
    end

    ComboBoxSetSelectedMenuItem(comboBox, 1)
end

-------------------

-- Emissary Changes above
------------------------

local function TeleportToCenter()
    local zoneInfo = GMT2.Map.ZoneInfo[EA_Window_WorldMap.currentMap]
    local zoneData = GMT2.Map.Zone[EA_Window_WorldMap.currentMap]
    local command = ""

    if GMT2.Map.TeleportOverrides[EA_Window_WorldMap.currentMap] then
        local override = GMT2.Map.TeleportOverrides[EA_Window_WorldMap.currentMap]
        local worldO = override.worldO or 0
        command = string_format("]teleport map %d %d %d %d %d", EA_Window_WorldMap.currentMap, override.x, override.y, override.z, worldO)
    elseif zoneInfo and zoneData then
        local centerX = zoneInfo.offsetX + (zoneInfo.mapsizeX / 2)
        local centerY = zoneInfo.offsetY + (zoneInfo.mapsizeY / 2)
        local centerZ = zoneData.worldTopZ or 8000
        local worldO = 0  -- Default to 0 if not provided
        command = string_format("]teleport map %d %d %d %d %d", EA_Window_WorldMap.currentMap, math.floor(centerX), math.floor(centerY), math.floor(centerZ), worldO)
    end

    if command ~= "" then
        local wstringCommand = towstring(command)
        SendChatText(wstringCommand, L"")
    end
end

function GMT2.Map.OnClickMap(flags)
if GMT2.Map.Zone[EA_Window_WorldMap.currentMap] == nil then return end

	for windowIndex, openWindowName in ipairs( WindowUtils.openWindowList ) do
		if ( openWindowName == "EA_Window_WorldMap" ) then


		if WindowGetShowing("EA_Window_WorldMapZoneView") == true then
		if SystemData.MouseOverWindow.name == "EA_Window_WorldMapZoneViewMapDisplay" then
		if flags ~= SystemData.ButtonFlags.SHIFT then

GMT2.Map.MAPX,GMT2.Map.MAPY = GMT2.Map.UpdateCoordinates(x,y)
GMT2.Map.ZoneWorldX = GMT2.Map.Zone[EA_Window_WorldMap.currentMap].WorldTopX + GMT2.Map.MAPX
GMT2.Map.ZoneWorldY = GMT2.Map.Zone[EA_Window_WorldMap.currentMap].WorldTopY + GMT2.Map.MAPY
GMT2.Map.ZoneWorldZ = GMT2.Map.Zone[EA_Window_WorldMap.currentMap].worldTopZ


local function MakeCallBack( Target_Name,arg,arg2 )
		    return function() GMT2.Teleport(Target_Name,arg,arg2) end
		end		
		
-- Create the context menu
local custom_menu_items = {}
EA_Window_ContextMenu.CreateContextMenu("GMTOOLSMAPTOOLS", 1, L"GMTools: " .. towstring(GetStringFromTable("ZoneNames", EA_Window_WorldMap.currentMap)))
EA_Window_ContextMenu.AddMenuDivider(EA_Window_ContextMenu.CONTEXT_MENU_1)
EA_Window_ContextMenu.AddMenuItem(L"<icon42>Teleport to this location", MakeCallBack(PlayerName, 4, {EA_Window_WorldMap.currentMap, GMT2.Map.ZoneWorldX, GMT2.Map.ZoneWorldY, GMT2.Map.ZoneWorldZ}), false, true)
EA_Window_ContextMenu.AddMenuItem(L"<icon42>Teleport to center " .. towstring(GetStringFromTable("ZoneNames", EA_Window_WorldMap.currentMap)), TeleportToCenter, false, true)	
EA_Window_ContextMenu.AddMenuItem(L"<icon59>Cache This Location", function() GMT2.Map.Cache = {id=EA_Window_WorldMap.currentMap, x=GMT2.Map.ZoneWorldX, y=GMT2.Map.ZoneWorldY, z=GMT2.Map.Zone[EA_Window_WorldMap.currentMap].worldTopZ} end, false, true)	
if GMT2.Cache_Name ~= nil then
    EA_Window_ContextMenu.AddMenuItem(L"<icon59>Teleport <icon23056>"..towstring(GMT2.Cache_Name)..L" Here", MakeCallBack(GMT2.Cache_Name,4,{EA_Window_WorldMap.currentMap,GMT2.Map.ZoneWorldX,GMT2.Map.ZoneWorldY,GMT2.Map.ZoneWorldZ}),false, true)	
end
EA_Window_ContextMenu.Finalize()

    MapUtils.ClickMap( "EA_Window_WorldMapZoneViewMapDisplay", EA_Window_WorldMapZoneViewMapDisplay.MouseoverPoints )  
d(L"ZoneName: "..towstring(GetStringFromTable("ZoneNames", EA_Window_WorldMap.currentMap ))..L", ZoneID: "..towstring(EA_Window_WorldMap.currentMap)..L", Cords: "..towstring(GMT2.Map.MAPX)..L","..towstring(GMT2.Map.MAPY))	
GMT2.Map.MarkedMap = EA_Window_WorldMap.currentMap



			WindowSetShowing("GMT2Xpin",true)	
			WindowSetOffsetFromParent("GMT2Xpin",GMT2.Map.XCordX,GMT2.Map.XCordY)

end
end	
end
end
end
end

function GMT2.Map.UpdateCoordinates()
    local mapPositionX, mapPositionY = WindowGetScreenPosition("EA_Window_WorldMapZoneViewMapDisplay")
	local UIScale = InterfaceCore.GetScale()
    local resolutionScale = InterfaceCore.GetResolutionScale()
    local x, y = MapGetCoordinatesForPoint("EA_Window_WorldMapZoneViewMapDisplay",
                                           (SystemData.MousePosition.x - mapPositionX) / resolutionScale,
                                           (SystemData.MousePosition.y - mapPositionY) / resolutionScale)
										  
	GMT2.Map.MapZoneID = EA_Window_WorldMap.currentMap	
			
			
	GMT2.Map.XCordX = ((SystemData.MousePosition.x - mapPositionX) / UIScale)-10
	GMT2.Map.XCordY = ((SystemData.MousePosition.y - mapPositionY) / UIScale)-10
	return x,y
end

function GMT2.Map.UpdatePinCoordinates()


	if GMT2.Map.TargetPin.Zone == EA_Window_WorldMap.currentMap then
		WindowSetShowing("GMT2TargetPin",true)
	else
		WindowSetShowing("GMT2TargetPin",false)
	end
	
	if GMT2.Map.ZoneInfo[EA_Window_WorldMap.currentMap] == nil then return end
	
    local mapPositionX, mapPositionY = WindowGetScreenPosition("EA_Window_WorldMapZoneViewMapDisplay")
	local UIScale = InterfaceCore.GetScale()
    --local resolutionScale = InterfaceCore.GetResolutionScale()
	local resolutionScale = WindowGetScale("EA_Window_WorldMapZoneView")

	local windowX, windowY = WindowGetDimensions("EA_Window_WorldMapZoneViewMapDisplay") -- 1000, 1000

	if GMT2.Map.ZoneInfo[EA_Window_WorldMap.currentMap].mapsizeX == nil or GMT2.Map.ZoneInfo[EA_Window_WorldMap.currentMap].mapsizeY == nil then return end


	local xPosUnit = (((math_ceil(windowX/resolutionScale))-40)/GMT2.Map.ZoneInfo[EA_Window_WorldMap.currentMap].mapsizeX)
	local yPosUnit = (((math_ceil(windowY/resolutionScale))-40)/GMT2.Map.ZoneInfo[EA_Window_WorldMap.currentMap].mapsizeY)


	local anchorX = ((GMT2.Map.TargetPin.X-(GMT2.Map.ZoneInfo[EA_Window_WorldMap.currentMap].mapStartOffsetX or 0)) * xPosUnit)/resolutionScale
	local anchorY = ((GMT2.Map.TargetPin.Y-(GMT2.Map.ZoneInfo[EA_Window_WorldMap.currentMap].mapStartOffsetY or 0)) * yPosUnit)/resolutionScale
	d(anchorX/resolutionScale)
	d(anchorY/resolutionScale)

	WindowSetOffsetFromParent("GMT2TargetPin",anchorX/resolutionScale,anchorY/resolutionScale)
	LabelSetText("GMT2TargetPinCords",GMT2.Map.TargetPin.Name)



end

function GMT2.Map.UpdateZoneList()
    -- Clear ComboBox before populating to avoid duplicates
    ComboBoxClearMenuItems("GMT2.Map_ZoneSelect_ComboBox")

    -- add the all zones option
  --  ComboBoxAddMenuItem("GMToolsWndComboBoxZoneNames", GetString( StringTables.Default.TEXT_ALL_ZONES ))
	ComboBoxAddMenuItem("GMT2.Map_ZoneSelect_ComboBox",  L"Current Zone")
  
    local tempZoneNameRef = {} -- we will use this to make sure we don't have duplicate names in the list
    -- start the count at 2 so that it will skip over the all zones option
    local iCount = 1

    local zoneIDs = GetZoneIDList()
    -- loop over all the zone names, some are blank, some are "Dangerous Territory"
    for index, zoneID in ipairs( zoneIDs )
    do
	
        -- get the zone name for this zoneID
        zoneName = GMT2.FixString(GetZoneName(zoneID))
		
        if tempZoneNameRef[zoneName] == nil and not (zoneName == nil or zoneName == L"")
        then
            tempZoneNameRef[zoneName] = iCount
            -- we need to sort this so we will add it to the list
            GMT2.Map.SelectedSearchZoneList[iCount] = {}
            GMT2.Map.SelectedSearchZoneList[iCount].index = {}
            table_insert(GMT2.Map.SelectedSearchZoneList[iCount].index, zoneID)
            GMT2.Map.SelectedSearchZoneList[iCount].name = zoneName
            -- increment the count
            iCount = iCount + 1
        else
			if not (zoneName == nil or zoneName == L"") then
            table_insert(GMT2.Map.SelectedSearchZoneList[tempZoneNameRef[zoneName]].index, zoneID)
			end
        end
    end

    table.sort( GMT2.Map.SelectedSearchZoneList, DataUtils.AlphabetizeByNames )
    -- loop over the sorted zone list
    for index, zoneData in pairs( GMT2.Map.SelectedSearchZoneList )
    do
        -- and put the name into the combo box
        ComboBoxAddMenuItem("GMT2.Map_ZoneSelect_ComboBox", zoneData.name)
    end

    ComboBoxSetSelectedMenuItem("GMT2.Map_ZoneSelect_ComboBox", 1)
end

function GMT2.Map.OnFilterSelChanged( curSel )
d("# "..curSel)
GMT2.Map.DropBoxSelect = curSel
    -- clear out the array
    GMT2.Map.ZoneID = {}
    -- if we are on the first selection or for some reason we are past the zone list index we will search all the zones
    if (((curSel - 1) == 0) or (curSel > #GMT2.Map.SelectedSearchZoneList))
    then
        -- this is set to -1 when all the zones should be searched
        GMT2.Map.ZoneID[1] = GameData.Player.zone
		
		GMT2.Map.CurrentSelectedZone = GMT2.Map.ZoneID[1]
		
		--	d(GMT2.Map.CurrentSelectedZone)
		--	d(towstring(GetZoneName(GMT2.Map.CurrentSelectedZone)))
		
    -- otherwise we will only search the zone selected
EA_Window_WorldMap.currentMap = GMT2.Map.CurrentSelectedZone 
EA_Window_WorldMap.ShowZone( GMT2.Map.CurrentSelectedZone )
	
    else
	
	
        for row = 1, #GMT2.Map.SelectedSearchZoneList[curSel].index
        do
            GMT2.Map.ZoneID[row] = GMT2.Map.SelectedSearchZoneList[curSel-1].index[row]
			GMT2.Map.CurrentSelectedZone = GMT2.Map.ZoneID[row]
		--	d(GMT2.Map.SelectedSearchZoneList[curSel].index[row])
		--	d(towstring(GetZoneName(GMT2.Map.ZoneID[row])))
			
			EA_Window_WorldMap.currentMap = GMT2.Map.CurrentSelectedZone 
			EA_Window_WorldMap.ShowZone( GMT2.Map.CurrentSelectedZone )
        end
    end
	WindowSetShowing("GMT2Xpin",false)
	
	GMT2.Map.UpdatePinCoordinates()
	if GMT2.Map.TargetPin.Zone == EA_Window_WorldMap.currentMap then
		WindowSetShowing("GMT2TargetPin",true)		
	else
		WindowSetShowing("GMT2TargetPin",false)
	end
	--d(GMTools.CurrentSelectedZone)
end

	
function GMT2.Map.WorldMapOnShown()
if not GMT2.Map.TargetPin then return end
ComboBoxSetSelectedMenuItem("GMT2.Map_ZoneSelect_ComboBox", 1)
	if GMT2.Map.TargetPin.Zone == EA_Window_WorldMap.currentMap  then
		WindowSetShowing("GMT2TargetPin",true)		
	else
		WindowSetShowing("GMT2TargetPin",false)
	end
GMT2.Map.UpdatePinCoordinates()

		-- Dynamically populate the boss list based on the current zone
		-- Fetch the current zone ID or name. Assuming GameData.Player.zone fetches the current zone ID
	local currentZone = GameData.Player.zone -- Emissary Changes
	    -- Show the boss teleport window when the map is shown
	WindowSetShowing("GMT2.MapBossTeleport", true) -- Emissary Changes
	GMT2.Map.PopulateBossList() -- Emissary Changes test

end

function GMT2.Map.WorldMapOnHidden()
	ComboBoxSetSelectedMenuItem("GMT2.Map_ZoneSelect_ComboBox", 1)
	WindowSetShowing("GMT2Xpin",false)
	WindowSetShowing("GMT2TargetPin",false)

    -- Hide the boss teleport window when the map is hidden
    WindowSetShowing("GMT2.MapBossTeleport", true) -- Emissary Changes

end
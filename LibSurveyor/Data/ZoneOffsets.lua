-- LibSurveyor Zone Offsets
-- @author Jim 'Ninjas' D
-- Original author Ian 'Nevir' MacLeod
--
-- You're welcome to borrow or modify this code provided you give credit to the original author!
-- 
-- LibSurveyor uses the "raw" world coordinates to map values.  Unfortunately, zones provide a 
-- "human readable" coordinate system that is offset from the world coordinates.
-- 
-- Currently, the only known way to determine a zone's offset (top left) is to travel to that zone
-- and guess based on the map offset that you can find while mousing over the player on the world
-- map, and the world coordinates given by LibSurveyor.  Zone offsets are usually (always?) some
-- factor of 65536 - usually 65536 * (# * 0.125)
-- 
-- Please, please: if you find a better way to determine these values in game or without, contribute
-- it back!  Also, some of these offsets are bound to be off; let me know so I can fix them!
-- 
-- Finally, if you use these values within your own addon, and for some reason don't use the utility
-- functions provided by LibSurveyor - *please* give credit!  These took a great deal of running
-- around to figure out.

local LibSurveyor = LibStub:GetLibrary("LibSurveyor")
if ( not LibSurveyor or LibSurveyor.VERSION.minor ~= 1 ) then
    return
end

LibSurveyor.Data.ZoneOffsets = {}

-- Dwarves vs Greenskins --
---------------------------
LibSurveyor.Data.ZoneOffsets[6]   = {x =  742880, y = 845576,  h = 65536, w = 65536} -- Ekrund
LibSurveyor.Data.ZoneOffsets[11]  = {x =  803316, y = 845776,  h = 65536, w = 65536} -- Mount Bloodhorn
LibSurveyor.Data.ZoneOffsets[7]   = {x = 1034892, y = 798324,  h = 65536, w = 65536} -- Barak Varr
LibSurveyor.Data.ZoneOffsets[1]   = {x = 1035892, y = 863860,  h = 65536, w = 65536} -- Marshes of Madness
LibSurveyor.Data.ZoneOffsets[8]   = {x = 1240692, y = 829324,  h = 65536, w = 65536} -- Black Fire Pass	
LibSurveyor.Data.ZoneOffsets[2]   = {x = 1240992, y = 896428,  h = 65536, w = 65536} -- The Badlands
LibSurveyor.Data.ZoneOffsets[10]  = {x = 1371264, y = 766906,  h = 65536, w = 65536} -- Stonewatch
LibSurveyor.Data.ZoneOffsets[9]   = {x = 1371364, y = 830592,  h = 65536, w = 65536} -- Kadrin Valley
LibSurveyor.Data.ZoneOffsets[5]   = {x = 1371164, y = 896428,  h = 65536, w = 65536} -- Thunder Mountain
LibSurveyor.Data.ZoneOffsets[26]  = {x = 1308528, y = 895128,  h = 65536, w = 65536} -- Cinderfall
LibSurveyor.Data.ZoneOffsets[27]  = {x = 1434100, y = 895828,  h = 65536, w = 65536} -- Death Peak
LibSurveyor.Data.ZoneOffsets[3]   = {x = 1371864, y = 962064,  h = 65536, w = 65536} -- Black Crag
LibSurveyor.Data.ZoneOffsets[4]   = {x = 1371304, y = 1025900, h = 65536, w = 65536} -- Butchers Pass
LibSurveyor.Data.ZoneOffsets[62]  = {x =  199132, y = 1477283, h = 44064, w = 44064} -- Karaz-a-Karak
LibSurveyor.Data.ZoneOffsets[61]  = {x = 1369904, y = 1025900, h = 44064, w = 44064} -- Karak Eight Peaks


-- Empire vs Chaos --
---------------------
LibSurveyor.Data.ZoneOffsets[100] = {x =  823300, y = 823900, h = 65536, w = 65536} -- Norsca
LibSurveyor.Data.ZoneOffsets[106] = {x =  822200, y = 887736, h = 65536, w = 65536} -- Nordland
LibSurveyor.Data.ZoneOffsets[101] = {x = 1019108, y = 822800, h = 65536, w = 65536} -- Troll Country
LibSurveyor.Data.ZoneOffsets[107] = {x = 1018908, y = 887236, h = 65536, w = 65536} -- Ostland
LibSurveyor.Data.ZoneOffsets[102] = {x = 1216416, y = 822800, h = 65536, w = 65536} -- High Pass
LibSurveyor.Data.ZoneOffsets[108] = {x = 1210716, y = 888036, h = 65536, w = 65536} -- Talabecland
LibSurveyor.Data.ZoneOffsets[161] = {x =  411300, y =  99932, h = 44064, w = 44064} -- Inevitable City
LibSurveyor.Data.ZoneOffsets[104] = {x = 1411024, y = 692928, h = 65536, w = 65536} -- The Maw
LibSurveyor.Data.ZoneOffsets[103] = {x = 1412824, y = 757464, h = 65536, w = 65536} -- Chaos Wastes
LibSurveyor.Data.ZoneOffsets[105] = {x = 1411524, y = 822900, h = 65536, w = 65536} -- Praag
LibSurveyor.Data.ZoneOffsets[120] = {x = 1349488, y = 822460, h = 65536, w = 65536} -- West Praag
LibSurveyor.Data.ZoneOffsets[109] = {x = 1411024, y = 889036, h = 65536, w = 65536} -- Reikland
LibSurveyor.Data.ZoneOffsets[110] = {x = 1411024, y = 952272, h = 65536, w = 65536} -- Reikwald
LibSurveyor.Data.ZoneOffsets[162] = {x =  100857, y = 100264, h = 65536, w = 65536} -- Altdorf

-- High Elf vs Dark Elf --
--------------------------
LibSurveyor.Data.ZoneOffsets[200] = {x = 1020508, y = 1021008, h = 65536, w = 65536} -- The Blighted Isle
LibSurveyor.Data.ZoneOffsets[206] = {x = 1020008, y = 1083944, h = 65536, w = 65536} -- Chrace
LibSurveyor.Data.ZoneOffsets[201] = {x =  823500, y = 1216416, h = 65536, w = 65536} -- The Shadowlands
LibSurveyor.Data.ZoneOffsets[207] = {x =  824000, y = 1282152, h = 65536, w = 65536} -- Ellyrion
LibSurveyor.Data.ZoneOffsets[202] = {x = 1413624, y = 1412724, h = 65536, w = 65536} -- Avelorn
LibSurveyor.Data.ZoneOffsets[208] = {x = 1413924, y = 1477560, h = 65536, w = 65536} -- Saphery
LibSurveyor.Data.ZoneOffsets[204] = {x =  823900, y = 1608732, h = 65536, w = 65536} -- Fell Landing
LibSurveyor.Data.ZoneOffsets[203] = {x =  887436, y = 1609232, h = 65536, w = 65536} -- Caledor
LibSurveyor.Data.ZoneOffsets[205] = {x =  953472, y = 1609032, h = 65536, w = 65536} -- Dragonwake
LibSurveyor.Data.ZoneOffsets[220] = {x =  953272, y = 1478260, h = 65536, w = 65536} -- Isle of the Dead
LibSurveyor.Data.ZoneOffsets[209] = {x = 1019808, y = 1608132, h = 65536, w = 65536} -- Eataine
LibSurveyor.Data.ZoneOffsets[210] = {x = 1083844, y = 1608832, h = 65536, w = 65536} -- Shining Way

-- Land of the dead --
----------------------
LibSurveyor.Data.ZoneOffsets[191] = {x =  202932, y = 1495383, h = 65536, w = 65536} -- Land of the dead



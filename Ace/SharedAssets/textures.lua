--if not LSA then return end

local ipairs = ipairs

local LSA = LibStub("LibSharedAssets")

local textures = {
	[1]="amethystSharedMediaFlat",
	[2]="amethystSharedMediaSmoothv2",
	[3]="amethystSharedMediaMinimalist",
	[4]="PureGraphite",
	--[5]="PureBar",
	--[6]="FoghladhaBar",	
}

local displaynames = {
	[1]="amethystSM-Flat",
	[2]="amethystSM-Minimalist",
	[3]="amethystSM-Smoothv2",
	[4]="PureGraphite",	
	--[5]="PureBar",
	--[6]="FoghladhaBar",	
}

local tiled = {
}

local dims = {
	["amethystSharedMediaFlat"] 		= {256,32},
	["amethystSharedMediaSmoothv2"] 	= {256,32},
	["amethystSharedMediaMinimalist"] 	= {256,32},
	["PureGraphite"] 					= {256,32},	
	--["PureBar"] 						= {256,32},
	--["FoghladhaBar"] 					= {256,32},
}

local tags = {
	["amethystSharedMediaFlat"] 		= {statusbar=true},
	["amethystSharedMediaSmoothv2"] 	= {statusbar=true},
	["amethystSharedMediaMinimalist"] 	= {statusbar=true},
	["PureGraphite"] 					= {statusbar=true},	
	--["PureBar"] 						= {statusbar=true},
	--["FoghladhaBar"] 					= {statusbar=true},
}

for k,texName in ipairs(textures) do
	local metadata = {
			displayname = displaynames[k],
			size = dims[texName],
			tiled = tiled[texName] or false,
			tags = tags[texName],
		}
	local result = LSA:RegisterTexture(texName, metadata)
	if not result then
		LSA:AddMetadata(texName, {displayname = displaynames[k]})
	end
end
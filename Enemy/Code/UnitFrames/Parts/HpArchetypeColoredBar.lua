local Enemy = Enemy
local g
local tinsert = table.insert
local tsort = table.sort
local ipairs = ipairs
local pairs = pairs
local tostring = tostring
local string_lower = string.lower
local type = type

local properties =
{
	texture =			{ key = "texture",				order = 1,		name = L"Texture",				type = "select",						default = "default",			values = Enemy.UnitFramePart_GetTexturesSelectValues },
	vertical =			{ key = "vertical",				order = 2,		name = L"Vertical mode",		type = "bool",							default = false },
	textureFullResize =	{ key = "textureFullResize",	order = 3,		name = L"Full resize",		type = "bool",							default = false },
	tankColor =			{ key = "tankColor",			order = 4,		name = L"Tanks color",			type = "color",			size = 3,		default = {150, 190, 255},		min = {0, 0, 0},			max = {255, 255, 255} },
	dpsColor =			{ key = "dpsColor",				order = 5,		name = L"Dps color",			type = "color",			size = 3,		default = {255, 190, 100},		min = {0, 0, 0},			max = {255, 255, 255} },
	healColor =			{ key = "healColor",			order = 6,		name = L"Healers color",		type = "color",			size = 3,		default = {190, 255, 100},		min = {0, 0, 0},			max = {255, 255, 255} }
}

local function ToNameString (name)
	if (not name) then return nil end

	if (Enemy and Enemy.FixString) then
		name = Enemy.FixString (name)
	end

	if (type (name) ~= "string" and WStringToString) then
		name = WStringToString (name)
	end

	if (type (name) ~= "string") then
		name = tostring (name)
	end

	return name
end

local function NormalizeNameKey (name)
	local asString = ToNameString (name)
	if (not asString) then return nil end
	return string_lower (asString)
end

local function GetPlayerArchetypeForColor (player, nameKey, altSpecSet)

	local archetype = Enemy.careerArchetypes[player.career]

	if (archetype and archetype ~= Enemy.Archetypes.Tank and altSpecSet and nameKey)
	then
		if (altSpecSet[nameKey]) then
			archetype = Enemy.Archetypes.Dps
		end
	end

	return archetype
end

function Enemy.UnitFramesParts_HpArchetypeColoredBarInitialize ()
	g = Enemy.unitFramesParts
	
	g.archetypeToPropertyName =
	{
		[Enemy.Archetypes.Tank] = "tankColor",
		[Enemy.Archetypes.Dps] = "dpsColor",
		[Enemy.Archetypes.Healer] = "healColor"
	}
	
	g.types["hpacbar"] =
	{
		key = "hpacbar",
		name = L"HP Bar (archetype colored)",
		properties = properties,
		
		CreateConfigurationWindow = function (wn, root)
			Enemy.CreateConfigurationWindow (wn, root, properties, Enemy.UnitFramesUI_UnitFramePartDialog_UpdateExample)
		end,
		
		LoadConfigurationWindow = function (wn, part)
			Enemy.ConfigurationWindowLoadData (wn, part.data)
		end,
		
		SaveConfigurationWindow = function (wn, part)
			Enemy.ConfigurationWindowSaveData (wn, part.data)
		end,
		
		OnRemove = Enemy.UnitFramePart_OnRemove,
		
		OnBind = function (part)
		
			local t = part._t
			local data = part.data
			
			t.cache = {}
		
			t.windowName = part._frame.windowName..Enemy.NewId ()
			CreateWindowFromTemplate (t.windowName, "EA_DynamicImage_DefaultSeparatorRight", part._frame.windowName)

			Enemy.UnitFramePart_OnUpdate_ProceedWindowInitialization (part, player)
			Enemy.UnitFramePart_ApplyTexture (data.texture, t.windowName)
		end,
		
		OnUpdate = function (part, player)
		
			local t = part._t
			local data = part.data
			local cache = t.cache
			local altSpecSet = Enemy.unitFrames and Enemy.unitFrames.altSpecDpsSet
			local altSpecSignature = Enemy.unitFrames and Enemy.unitFrames._altSpecSignature
			
			if (cache.hp ~= player.hp)
			then
				cache.hp = player.hp
				
				if (cache.hp == 0)
				then
					cache.hideByDefult = true
					WindowSetShowing (t.windowName, false)
				else
					cache.hideByDefult = false
					WindowSetShowing (t.windowName, true)
					
					Enemy.UnitFramePart_ApplyTexturePercentResize (part, 0.01 * cache.hp)
				end
			end
			
			if (cache.playerName ~= player.name)
			then
				cache.playerName = player.name
				cache.nameKey = NormalizeNameKey (cache.playerName)
			end

			if (cache.career ~= player.career or cache.altSpecSignature ~= altSpecSignature)
			then
				cache.career = player.career
				cache.altSpecSignature = altSpecSignature

				local archetype = GetPlayerArchetypeForColor (player, cache.nameKey, altSpecSet)
				if (cache.archetype ~= archetype)
				then
					cache.archetype = archetype

					local color = archetype and data[g.archetypeToPropertyName[archetype]]
					if (color) then
						WindowSetTintColor (t.windowName, color[1], color[2], color[3])
					end
				end
			end
			
			Enemy.UnitFramePart_OnUpdate_ProceedStateExceptColor (part, player, cache.hideByDefult)
		end
	}
end




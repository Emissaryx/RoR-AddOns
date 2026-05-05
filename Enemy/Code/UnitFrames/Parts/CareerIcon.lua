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

local function GetScoreboardSource ()
	local inScenario = GameData and GameData.Player and (GameData.Player.isInScenario or GameData.Player.isInSiege)

	if (inScenario and ScenarioSummaryWindow and ScenarioSummaryWindow.playersData and ScenarioSummaryWindow.ArchetypeIcons) then
		return ScenarioSummaryWindow.playersData, ScenarioSummaryWindow.ArchetypeIcons
	end

	if (RoRGroupScoreboard and RoRGroupScoreboard.playersDataRaw and RoRGroupScoreboard.ArchTypeIcons) then
		return RoRGroupScoreboard.playersDataRaw, RoRGroupScoreboard.ArchTypeIcons
	end

	return nil, nil
end

local function TryGetScoreboardAltSpecIcon (memberName)
	if (not memberName or not Enemy.unitFrames) then return nil end

	local map = Enemy.unitFrames.altSpecIconByKey
	if (not map) then return nil end

	local key = NormalizeNameKey (memberName)
	return key and map[key] or nil
end


local function SyncAltIconLayout (part)
	local t = part._t
	local data = part.data

	if (not t or not data or not t.altIconWindowName or not t.windowName) then
		return
	end

	local cache = t.cache or {}

	if (not cache.altIconAnchored) then
		WindowClearAnchors (t.altIconWindowName)
		WindowAddAnchor (t.altIconWindowName, "center", t.windowName, "center", 0, 0)
		cache.altIconAnchored = true
	end

	local width = data.size and data.size[1] or 0
	local height = data.size and data.size[2] or 0
	if (cache.altIconWidth ~= width or cache.altIconHeight ~= height) then
		cache.altIconWidth = width
		cache.altIconHeight = height
		WindowSetDimensions (t.altIconWindowName, width, height)
		DynamicImageSetTextureDimensions (t.altIconWindowName, width, height)
	end

	local scale = WindowGetScale (t.windowName) or 1
	if (cache.altIconScale ~= scale) then
		cache.altIconScale = scale
		WindowSetScale (t.altIconWindowName, scale)
	end

	t.cache = cache
end


function Enemy.UnitFramesParts_CareerIconInitialize ()
	g = Enemy.unitFramesParts
	
	g.types["careerIcon"] =
	{
		key = "careerIcon",
		name = L"Career icon",
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
		
		OnRemove = function (part)
			local t = part._t
			if (t and t.altIconWindowName and DoesWindowExist (t.altIconWindowName)) then
				DestroyWindow (t.altIconWindowName)
			end
			Enemy.UnitFramePart_OnRemove (part)
		end,
		
		OnBind = function (part)
		
			local t = part._t
			local data = part.data
			
			t.cache = {}
			
			t.windowName = part._frame.windowName..Enemy.NewId ()
			CreateWindowFromTemplate (t.windowName, "EA_DynamicImage_DefaultSeparatorRight", part._frame.windowName)

			Enemy.UnitFramePart_OnUpdate_ProceedWindowInitialization (part, player)
			DynamicImageSetTextureDimensions (t.windowName, 32, 32)

			t.altIconWindowName = t.windowName.."AltSpec"
			CreateWindowFromTemplate (t.altIconWindowName, "EA_DynamicImage_DefaultSeparatorRight", part._frame.windowName)
			WindowSetHandleInput (t.altIconWindowName, false)
			WindowSetLayer (t.altIconWindowName, Window.Layers.OVERLAY)
			WindowSetAlpha (t.altIconWindowName, 1)
			WindowSetShowing (t.altIconWindowName, false)

			SyncAltIconLayout (part)
		end,
		
		OnUpdate = function (part, player)
		
			local t = part._t
			local data = part.data
			local cache = t.cache

			SyncAltIconLayout (part)
			
			if (cache.career ~= player.career and player.career > 0)
			then
				cache.career = player.career

				local icon, icon_x, icon_y = GetIconData (Icons.GetCareerIconIDFromCareerLine (cache.career))
				DynamicImageSetTexture (t.windowName, icon, icon_x, icon_y)
			end

			local altSpecIcon = TryGetScoreboardAltSpecIcon (player.name)
			if (altSpecIcon ~= cache.altSpecIcon)
			then
				cache.altSpecIcon = altSpecIcon

				if (cache.altSpecIcon and t.altIconWindowName)
				then
					local tex, tex_x, tex_y = GetIconData (cache.altSpecIcon)
					if (tex) then
						DynamicImageSetTexture (t.altIconWindowName, tex, tex_x, tex_y)
					else
						cache.altSpecIcon = nil
					end
				end
			end
			
			Enemy.UnitFramePart_OnUpdate_ProceedState (part, player)

			if (t.altIconWindowName) then
				local showAlt = (cache.altSpecIcon ~= nil) and WindowGetShowing (t.windowName)
				WindowSetShowing (t.altIconWindowName, showAlt)
			end
		end
	}
end




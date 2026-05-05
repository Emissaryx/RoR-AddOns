nRarity.Border = {}
local Border = nRarity.Border

-- constants
local COLOUR_HIGHLIGHT = { r = 255, g = 255, b = 0 }

-- local (static)
local nextBorderId = 1

-- constructor
function Border:new(anchorName, parentName)

	-- OO init
	local o = {}
	setmetatable(o, self)
	self.__index = self

	-- initialise members
	o.name = "nRarity"..nextBorderId
	nextBorderId = nextBorderId + 1

	if not DoesWindowExist(o.name) and DoesWindowExist(anchorName) and DoesWindowExist(parentName) then
		-- create the window
		CreateWindowFromTemplate(o.name, "nRarityBorder", parentName)
		WindowAddAnchor(o.name, "center", anchorName, "center", 0, 0)
		WindowSetScale(o.name, WindowGetDimensions(anchorName) / WindowGetDimensions(o.name) * WindowGetScale(anchorName))
		WindowSetLayer(o.name, WindowGetLayer(anchorName) + 1) --~ added +1 so that the border is always shown above the original
		WindowSetShowing(o.name, true)
		--WindowSetHandleInput(o.name, false) --~ commented this because setting handled input is no longer needed (false by default)
	--d(anchorName)
	end

	return o
end

-- destructor
function Border:delete()
	if DoesWindowExist(self.name) then
		DestroyWindow(self.name)
	end
end

-- set the colour to rarity
function Border:setRarity(itemData)
	local id = (itemData and itemData.id) or -1; --~ added these 3 lines to not update the color when this border is already set to the item
	if (self.itemId == id) then return end
	self.itemData = id;
	
	if DoesWindowExist(self.name) then
		local colour = DataUtils.GetItemRarityColor(itemData)
		WindowSetTintColor(self.name, colour.r, colour.g, colour.b)
		WindowSetTintColor(tostring(self.name).."CareerIcon", 255,255, 255)	
					local careerIconNum
		
	local IsDye = (itemData and itemData.type) or 0
		
			if itemData ~= nil then
				local careers = itemData.careers
				local itemCareer = careers[1]							
				if( careers[2] ~= nil ) then
					for _, careerLine in ipairs(careers) do
						if( careerLine == GameData.Player.career.line ) then
							itemCareer = careerLine
							break
						end
					end
				end
			careerIconNum = Icons.GetCareerIconIDFromCareerLine( itemCareer )
--[[
			if careers[1] == nil then 
			local itemRaces = itemData.races
				if itemRaces[1] == 6 then
					careerIconNum = 23006	
				end			
			end			
	--]]
			if careers[1] == nil then 
			
			
			local races = itemData.races
			local itemRaces = races[1]

				if( races[2] ~= nil ) then
					for _, raceLine in ipairs(races) do
						if( raceLine == GameData.Player.race.id ) then
							itemRaces = raceLine
							break
						end
					end
				end		
				if itemRaces == 1 then
					careerIconNum = 23005	--Dwarw
				elseif itemRaces == 2 then
					careerIconNum = 23008	--Orc
				elseif itemRaces == 3 then
					careerIconNum = 23008	--Gobbo
				elseif itemRaces == 4 then
					careerIconNum = 23011	--HightElf					
				elseif itemRaces == 5 then
					careerIconNum = 23002	--DarkElf					
				elseif itemRaces == 6 then
					careerIconNum = 23007	--Empre
				elseif itemRaces == 7 then
				careerIconNum = 23000		-- Chaos
				end		

				
			end			
--end of race test


	
			else
	
			
				careerIconNum = 0
			end
				



	
	if( careerIconNum and careerIconNum > 0 ) then
						local texture, x, y = GetIconData( careerIconNum )			
				
	DynamicImageSetTexture(tostring(self.name).."CareerIcon",texture, x, y)	
		WindowSetShowing(tostring(self.name).."CareerIcon",true)
		WindowSetShowing(tostring(self.name).."CareerIconBG",true)
		WindowSetTintColor(tostring(self.name).."CareerIconBG",0,0,0)
	else
	WindowSetShowing(tostring(self.name).."CareerIcon",false)
	WindowSetShowing(tostring(self.name).."CareerIconBG",false)
	end

	
if IsDye == 27 then
	local texture, x, y = GetIconData(625)
	local TintData = nRarity.TintData[itemData.tintA]
	if TintData == nil then TintData = {Red=255,Green=255,Blue=255} 
	DynamicImageSetTexture(tostring(self.name).."CareerIcon","EA_HUD_01", 10, 10)	
	DynamicImageSetTextureSlice(tostring(self.name).."CareerIcon","LootOptOut-X")
	else
	DynamicImageSetTexture(tostring(self.name).."CareerIcon","EA_HUD_01", 0, 0)	
	DynamicImageSetTextureSlice(tostring(self.name).."CareerIcon","Rank-Circle-ConTintable")	
	end

	
	WindowSetShowing(tostring(self.name).."CareerIcon",true)
	WindowSetShowing(tostring(self.name).."CareerIconBG",true)
	WindowSetTintColor(tostring(self.name).."CareerIcon",TintData.Red,TintData.Green,TintData.Blue)
	WindowSetTintColor(tostring(self.name).."CareerIconBG",0,0,0)
	

end

local CountStack = L""



	local Pocket,Slot = WindowGetParent(self.name):match("Section([0-9]+)ButtonsButton([0-9]+)")
	if Pocket ~= nil and Slot ~= nil then
		if itemData ~= nil and itemData.stackCount > 1 then
			CountStack = itemData.stackCount
		end		
		ActionButtonGroupSetText( EA_Window_Backpack.GetPocketName((tonumber(Pocket-1))+EA_Window_Backpack.GetPocketNumberForSlot(EA_Window_Backpack.currentMode, 1 )).."Buttons", tonumber(Slot), L"" )
	end
	
	LabelSetText(tostring(self.name).."Name",towstring(CountStack))
	LabelSetText(tostring(self.name).."NameBG",towstring(CountStack))

end

end

-- set the colour to highlighted or rarity
function Border:setHighlight()
	WindowSetTintColor(self.name, COLOUR_HIGHLIGHT.r, COLOUR_HIGHLIGHT.g, COLOUR_HIGHLIGHT.b)

end

-- set the handle input property on the border
function Border:setHandleInput(handleInput)
	WindowSetHandleInput(self.name, handleInput)
end

-- set window id
function Border:setId(id)
	WindowSetId(self.name, id)
end

-- register a core event handler
function Border:registerCoreEventHandler(event, handler)
	WindowUnregisterCoreEventHandler(self.name, event)
	WindowRegisterCoreEventHandler(self.name, event, handler)
end

-- set the border's parent
function Border:setParent(parentName)
	WindowSetParent(self.name, parentName)
end

-- set the border's visibility
function Border:setShowing(showing)
	WindowSetShowing(self.name, showing)
end

--[[
	This application is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The applications is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with the applications.  If not, see <http://www.gnu.org/licenses/>.
--]]

if not AuraTexture then AuraTexture = {} end

AuraTexture.Window 					= "AuraTexture"

AuraTexture.WindowIcons				= AuraTexture.Window .. "Icons"
AuraTexture.WindowAuras				= AuraTexture.Window .. "Auras"
AuraTexture.WindowCustom			= AuraTexture.Window .. "Custom"

AuraTexture.listIconData			= {}
AuraTexture.listAuraData			= {}
AuraTexture.listCustomData			= {}

AuraTexture.listIconDisplayData	= {}
AuraTexture.listAuraDisplayData		= {}
AuraTexture.listCustomDisplayData	= {}

AuraTexture.iconDisplayOrder		= {}

AuraTexture.TabWindows = {}
AuraTexture.TabWindows[1] = { name=AuraTexture.WindowIcons, 		buttontext=L"Icons",		button= AuraTexture.Window .. "TabsIcons" }
--AuraTexture.TabWindows[2] = { name=AuraTexture.WindowAuras, 		buttontext=L"Auras", 		button= AuraTexture.Window .. "TabsAuras" }
--AuraTexture.TabWindows[3] = { name=AuraTexture.WindowCustom, 		buttontext=L"Custom", 		button= AuraTexture.Window .. "TabsCustom" }

AuraTexture.NUM_ICONS_PER_ROW		= 8

function AuraTexture.OnLoad()

	WindowClearAnchors( AuraTexture.Window )
	WindowAddAnchor( AuraTexture.Window, "bottomright", AuraConfig.Window, "bottomleft", 0, 0 )
		
	-- Setup our tab buttons and hide corresponding windows
	for index, window in ipairs( AuraTexture.TabWindows )
	do
		ButtonSetText( window.button, window.buttontext )
		ButtonSetStayDownFlag( window.button, true )
		
		WindowSetShowing( window.name, index == 1 )
		ButtonSetPressedFlag( window.button, index == 1 )
	end
	
	-- Initialize our icons
	AuraTexture.InitializeIcons()
end

function AuraTexture.OnShown()


end

function AuraTexture.OnRaceTabSelected()
	local tabId = WindowGetId( SystemData.ActiveWindow.name )
	
	for index, window in ipairs( AuraTexture.TabWindows )
	do
		ButtonSetPressedFlag( window.button, index == tabId )
		WindowSetShowing( window.name, index == tabId )
	end
end

function AuraTexture.OnClose()
	WindowSetShowing( AuraTexture.Window, false )
end

function AuraTexture.InitializeIcons()

	-- Claer our our current icon data
	AuraTexture.listIconData			= {}
	
	-- Clear our current display data
	AuraTexture.listIconDisplayData	= {}
	
	-- Clear our current display order
	AuraTexture.iconDisplayOrder = {}
	
	-- Retrieve the icons we need for (this removes the non defined icons)
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 2100, 2999 )  -- Greenskins
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 4100, 4999 )  -- Dwarf
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 5100, 5999 )  -- Chaos
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 7900, 8799 )  -- Empire
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 10900, 11199 )  -- Dark Elf
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 13300, 13699 )  -- High Elf
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 20250, 22249 )  -- Crafting Icons
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 22250, 22649 )  -- Renown Icons
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 22650, 22999 )  -- Tactic Icons
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 23150, 23399 )  -- Archtype Icons (morale)
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 20065, 20179 )  -- Illuminated Letters
	AuraTexture.ProcessInternalIcons( AuraTexture.listIconData, 1, 80000 ) 
	
	-- Calculate how many slots our list box will have
	local slots = AuraHelpers.roundUp( ( #AuraTexture.listIconData / AuraTexture.NUM_ICONS_PER_ROW ), 1 )
	
	-- Iterate over each of the slots and populate the icons in each
	for slot = 1, slots, 1
	do
		local listViewItem 	= {}
		local baseIdx		= ( slot * AuraTexture.NUM_ICONS_PER_ROW ) - AuraTexture.NUM_ICONS_PER_ROW + 1
		
		listViewItem.slotNum	= slot
	    listViewItem.Icon1		= AuraTexture.listIconData[baseIdx]
	    listViewItem.Icon2		= AuraTexture.listIconData[baseIdx + 1]
	    listViewItem.Icon3		= AuraTexture.listIconData[baseIdx + 2]
	    listViewItem.Icon4		= AuraTexture.listIconData[baseIdx + 3]
	    listViewItem.Icon5		= AuraTexture.listIconData[baseIdx + 4]
	    listViewItem.Icon6		= AuraTexture.listIconData[baseIdx + 5]
	    listViewItem.Icon7		= AuraTexture.listIconData[baseIdx + 6]
	    listViewItem.Icon8		= AuraTexture.listIconData[baseIdx + 7]
	    
	    AuraTexture.listIconDisplayData[slot] = listViewItem	
	end
	
	-- Create the list we will use to display
    for index, auraData in ipairs( AuraTexture.listIconDisplayData )
    do
    	table.insert( AuraTexture.iconDisplayOrder, index )
    end
    
	ListBoxSetDisplayOrder( AuraTexture.Window .. "IconsIcons", AuraTexture.iconDisplayOrder )
end

function AuraTexture.ProcessInternalIcons( data, min, max )
	for iconId = min, max, 1
	do
		-- Get the icon
		local texture, x, y, disabledTexture = GetIconData( iconId )
		
		-- See if the texture received is valid.
		if( texture ~= L"" and texture ~= "icon-00001" ) then
			table.insert( data, iconId )
		end
	end
end

function AuraTexture.OnIconLButtonUp()
	-- If the button is disabled, get out of here	
	if( ButtonGetDisabledFlag( SystemData.ActiveWindow.name ) == true ) then return end
    
    -- Attempt to find out which type of icon was clicked (ability/aura/custom/etc)
    local parentWindow = ( WindowGetParent( WindowGetParent( WindowGetParent( SystemData.ActiveWindow.name ) ) ) )
	
	if( parentWindow == AuraTexture.WindowIcons ) then
		local iconId = AuraTexture.GetIconFromClick()
		
		AuraConfig.OnTextureChanged( Aura.TEXTURE_TYPE_ICON, iconId )
	elseif( parentWindow == AuraTexture.WindowAuras ) then
	
	elseif( parentWindow == AuraTexture.WindowCustom ) then
	
	end
end

function AuraTexture.PopulateIconsListDisplay()
	local window = AuraTexture.WindowIcons .. "Icons"
	
	for rowIndex, dataIndex in ipairs( AuraTextureIconsIcons.PopulatorIndices )
	do
		local data = AuraTexture.listIconDisplayData[dataIndex]
		for i = 1, 8, 1
		do
			local icon = "Icon" .. i
			
			if( data[icon] ~= nil ) then
				local texture, x, y, disabledTexture = GetIconData( data[icon] )
				DynamicImageSetTexture( window .."Row" .. rowIndex .. "Icon" .. i .. "Icon", texture, x, y )
				ButtonSetDisabledFlag( window .."Row" .. rowIndex .. "Icon" .. i, false )
			else
				ButtonSetDisabledFlag( window .."Row" .. rowIndex .. "Icon" .. i, true )
				DynamicImageSetTexture( window .."Row" .. rowIndex .. "Icon" .. i .. "Icon", "", 0, 0 )
			end	
		end
	end
end

function AuraTexture.PopulateAuraListDisplay()

end

function AuraTexture.PopulateCustomListDisplay()
	
end

function AuraTexture.GetIconFromClick()
	local iconIdx = SystemData.ActiveWindow.name:match( "(%d+)$" )
	local icon = "Icon" .. iconIdx
	
	local rowIdx = WindowGetId( SystemData.ActiveWindow.name ) 
	local dataIdx = ListBoxGetDataIndex ( AuraTexture.WindowIcons .. "Icons" , rowIdx )
	
    return AuraTexture.listIconDisplayData[dataIdx][icon]
end
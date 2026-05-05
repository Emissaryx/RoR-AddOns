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

if not AuraShares then AuraShares = {} end

local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local T 		= LibStub( "WAR-AceLocale-3.0" ) : GetLocale( "Aura", debug )

local MAX_VISIBLE_ROWS 		= 5
local windowId 				= "AuraShares"

local impexpBase			= "AuraSharesImportExport"
local importWindow			= "AuraSharesImport"
local exportWindow			= "AuraSharesExport"

local filterSameNameAuras	= true
local filterCharactersAuras	= true

local auraList				= {}

local sortColumnNum 		= 0				
local sortColumnName 		= ""		
local shouldSortIncreasing 	= true

local displayOrder 			= {}
local reverseDisplayOrder 	= {}

-- This isnt local so the listbox can see it
AuraShares.listDisplayData = {}

-- Column Headers
local textureHeader			= L""
local characterHeader		= T["Character"]
local typeHeader   			= T["Type"]
local nameHeader   			= T["Aura Name"]

local function characterComparator( a, b )			return( WStringsCompare( a.Character, b.Character ) == -1 ) end
local function typeComparator( a, b )				return( WStringsCompare( a.Type, b.Type ) == -1 ) end
local function nameComparator( a, b )				return( WStringsCompare( a.Name, b.Name ) == -1 ) end

local sortHeaderData =
{
	[0] = { sortFunc=nameComparator, },
	{ column = "Texture",		text=textureHeader,			sortFunc=nameComparator,		},
	{ column = "Character",		text=characterHeader,		sortFunc=characterComparator,	},
    { column = "Type",			text=typeHeader,			sortFunc=typeComparator,		},
    { column = "Name",			text=nameHeader,			sortFunc=nameComparator,		},
}

function AuraShares.GetWindowName() return windowId end

function AuraShares.OnLoad()
	-- Create our import/export windows
	if( not DoesWindowExist( importWindow ) ) then 
		CreateWindowFromTemplate( importWindow, impexpBase, "Root" )
	end
	WindowSetShowing( importWindow, false )
	LabelSetText( importWindow .. "TitleBarText", T["Aura - Import"] )
	ButtonSetText( importWindow .. "OkButton", T["Ok"] )
	
	if( not DoesWindowExist( exportWindow ) ) then 
		CreateWindowFromTemplate( exportWindow, impexpBase, "Root" )
	end
	WindowSetShowing( exportWindow, false )
	LabelSetText( exportWindow .. "TitleBarText", T["Aura - Export"] )
	ButtonSetText( exportWindow .. "OkButton", T["Ok"] )
	
	-- Set our configuration title
	LabelSetText( windowId .. "TitleBarText", T["Aura - Shares"] )
	
	-- Initialize our aura list
	for i, data in ipairs( sortHeaderData ) do
        local buttonName = windowId .. data.column
        ButtonSetText( buttonName, data.text )
        WindowSetShowing( buttonName .. "DownArrow", false )
        WindowSetShowing( buttonName .. "UpArrow", false )
    end
    DataUtils.SetListRowAlternatingTints( windowId .. "AuraList", MAX_VISIBLE_ROWS )
	
	-- Setup our Import Aura Button
	ButtonSetText( windowId .. "ImportAuraButton", T["Import Aura"] )
	
	LabelSetText( windowId .. "FilterCharactersAurasLabel", T["Filter this characters auras"] )
	ButtonSetPressedFlag( windowId .. "FilterCharactersAurasButton", filterCharactersAuras )
	
	LabelSetText( windowId .. "FilterSameNameToggleLabel", T["Filter auras with the same name"] )
	ButtonSetPressedFlag( windowId .. "FilterSameNameToggleButton", filterSameNameAuras )
	
	-- Refresh our UI
	AuraShares.Refresh()
end

function AuraShares.OnHidden()
	if( DoesWindowExist( importWindow ) ) then WindowSetShowing( importWindow, false ) end
	if( DoesWindowExist( exportWindow ) ) then WindowSetShowing( exportWindow, false ) end
end

function AuraShares.CreateListDisplayData()
	local currChar		= AuraProfile.GetCurrentCharacter()
	local config 		= AuraAddon.GetAuraConfiguration()
	local characters 	= AuraProfile.GetProfileTypeList( config, AuraProfile.PROFILE_TYPE_CHARACTER )
	
	-- Clear our current aura list
	auraList = {}
	
	-- Clear our current display data
	AuraShares.listDisplayData = {}
	
	-- Get the aura of each character
	for index, char in ipairs( characters )
	do
		-- Check our character name filter
		if( filterCharactersAuras and ( WStringsCompare( currChar, char ) == 0 ) ) then continue end

		local data = AuraProfile.GetProfileData( config, AuraProfile.PROFILE_TYPE_CHARACTER, char )
		
		if( data ~= nil ) then
			
			for _, aura in pairs( data.Auras )
			do
				-- Create the new aura object
				local auraDisplay = {}
			
				auraDisplay.aura = Aura.Create( aura )
				auraDisplay.char = char
			
				-- Check the filter after creating the aura, so we can treat it as an object
				if( filterSameNameAuras and AuraShares.CheckIfAuraExists( auraDisplay.aura, auraList ) ) then continue end
				
				-- Store it
				table.insert( auraList, auraDisplay )
			end
		end
	end
	
	for slotNum, auraDisplay in pairs( auraList ) 
	do
		AuraShares.SetListDisplayItem( slotNum, auraDisplay )
    end
end

function AuraShares.CheckIfAuraExists( aura, auraList )
	local auraName 	= aura:Get( "general-name" )
	local found		= false
	for k,v in pairs( auraList )
	do
		if( WStringsCompare( v.aura:Get( "general-name" ), auraName ) == 0 ) then
			found = true
			break
		end
	end
	
	return found	
end

function AuraShares.SetListDisplayItem( slotNum, auraDisplay )

	local listDisplayItem = {}
	
	local triggerType 			= auraDisplay.aura:Get( "general-triggertype" )
	
	listDisplayItem.slotNum 	= slotNum
	listDisplayItem.Character	= towstring( auraDisplay.char )
	listDisplayItem.Type		= AuraConstants.Trigger[triggerType].Name or L"Unknown" 
	listDisplayItem.Name		= auraDisplay.aura:Get( "general-name" )
    
    AuraShares.listDisplayData[slotNum] = listDisplayItem
end

function AuraShares.ShowCurrentList()
	-- Clear our current display data
	displayOrder = {}
    reverseDisplayOrder = {}
    
	-- Sort before displaying
    AuraShares.Sort()
    
    -- Create the list we will use to display
    for index,_ in ipairs( AuraShares.listDisplayData )
    do
    	-- Add this to the end of our display
    	table.insert( displayOrder, index )
    	
    	-- Add this to the beginning of our display
    	table.insert( reverseDisplayOrder, 1, index )
    end
    
    -- Display the sorted data
    AuraShares.DisplaySortedData()
end

function AuraShares.DisplaySortedData()
	if( shouldSortIncreasing ) then
        ListBoxSetDisplayOrder( windowId .. "AuraList", displayOrder )
    else
        ListBoxSetDisplayOrder( windowId .. "AuraList", reverseDisplayOrder )
    end 
end

function AuraShares.Refresh()
	-- Create a new list display data
    AuraShares.CreateListDisplayData()
    
    -- Display the newly generated list
	AuraShares.ShowCurrentList()
end

function AuraShares.PopulateDisplay()
	local slotNum, aura
	 
	-- Iterate the list of the currently displayed items 
	for row, data in ipairs( AuraSharesAuraList.PopulatorIndices ) 
	do
		local rowName = windowId .. "AuraListRow".. row
		
		-- Get the original data slot number for this item
		slotNum = AuraShares.listDisplayData[data].slotNum
		
		-- Get the original data
		aura = auraList[slotNum].aura
		
		-- Use the date to update the row
		AuraShares.UpdateRow( aura, rowName )
	end
end

function AuraShares.UpdateRow( aura, rowName )
	if( aura ~= nil and rowName ~= nil ) then
		-- Set the texture
		local texture, slice, dx, dy = aura:GetTextureData()
		
		if( texture ~= nil  ) then
			AuraHelpers.SetDynamicImageTexture( rowName .. "TextureIcon", texture, slice, dx, dy,
				aura:Get( "texture-tintr" ), aura:Get( "texture-tintg" ), aura:Get( "texture-tintb" ), 1, 0, false ) 
		end
		
		-- Nothing else to set here, as the text columns are set via the ListColumns in the list box
	end
end

function AuraShares.ChangeSorting()
	if( sortColumnName == SystemData.ActiveWindow.name ) then
		if shouldSortIncreasing then
			shouldSortIncreasing = ( not shouldSortIncreasing )
		else
			AuraShares.ClearSortButton()
		end
    else
        AuraShares.ClearSortButton()
        sortColumnName = SystemData.ActiveWindow.name
        sortColumnNum = WindowGetId( SystemData.ActiveWindow.name )
    end

	if( sortColumnNum > 0 ) then
		WindowSetShowing( sortColumnName.."DownArrow", shouldSortIncreasing )
		WindowSetShowing( sortColumnName.."UpArrow", not shouldSortIncreasing )
	end
	
    AuraShares.ShowCurrentList()
end

function AuraShares.Sort()
	if( sortColumnNum >= 0 ) then
        local comparator = sortHeaderData[sortColumnNum].sortFunc
        table.sort( AuraShares.listDisplayData, comparator )
    end
end

function AuraShares.ClearSortButton()
    
    if( sortColumnName ~= "" ) then
        WindowSetShowing( sortColumnName.."DownArrow", false )
        WindowSetShowing( sortColumnName.."UpArrow", false )
        
        sortColumnName = "" 
        sortColumnNum = 0
        shouldSortIncreasing = true
    end
end

function AuraShares.GetSlotRowNumForActiveListRow()
	local rowNumber, slowNumber, aura 
	
	-- Get the row within the window
	rowNumber = WindowGetId( SystemData.ActiveWindow.name ) 

	-- Get the data index from the list box
    local dataIndex = ListBoxGetDataIndex( windowId .. "AuraList" , rowNumber )
    
    -- Get the slot from the data
    if( dataIndex ~= nil ) then
    	slotNumber = AuraShares.listDisplayData[dataIndex].slotNum
    
	    -- Get the data
	    if( slotNumber ~= nil ) then
	    	aura = auraList[slotNumber].aura
	    end
	end
    
	return slotNumber, rowNumber, aura
end

function AuraShares.DisplayTooltip()
	local slotNum, rowIndex, aura  = AuraShares.GetSlotRowNumForActiveListRow()
	
	if( aura ~= nil ) then
		-- Create the tooltip
		AuraTooltip.CreateShareTooltip( aura, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT )
	end
end

function AuraShares.OnMouseOverAuraList()
	AuraShares.DisplayTooltip()
end

function AuraShares.OnLButtonUpAuraList( flags )
	if( flags == SystemData.ButtonFlags.SHIFT ) then
		local slotNum, rowIndex, aura  = AuraShares.GetSlotRowNumForActiveListRow()
	
		if( aura ~= nil ) then
			-- Create the new aura
			local newAura = Aura.Create( {} )
			
			if( newAura:ImportAura( aura:ExportAura() ) ) then
				-- Disable the aura before adding it to the users list
				newAura:Set( "general-enabled", false )
			
				-- Add the aura to the users list
				AuraAddon.AddAura( newAura )
			end
		end
	end
end

function AuraShares.OnRButtonUpAuraList( flags )
	if( flags == SystemData.ButtonFlags.SHIFT ) then
		local slotNum, rowIndex, aura  = AuraShares.GetSlotRowNumForActiveListRow()
	
		if( aura ~= nil ) then
			AuraShares.OnExportAura( aura )
		end
	end
end

function AuraShares.OnClose()
	WindowSetShowing( windowId, false )
end

function AuraShares.OnFilterSameNameToggle()
	local enabled = not filterSameNameAuras
	ButtonSetPressedFlag( windowId .. "FilterSameNameToggleButton", enabled )
	filterSameNameAuras = enabled
	AuraShares.Refresh()
end

function AuraShares.OnFilterCharactersAurasToggle()
	local enabled = not filterCharactersAuras
	ButtonSetPressedFlag( windowId .. "FilterCharactersAurasButton", enabled )
	filterCharactersAuras = enabled
	AuraShares.Refresh()
end

function AuraShares.OnExportAura( aura )
	local wstr = aura:ExportAura()
	
	if( wstr ~= nil ) then
		-- Display our export window
	    WindowSetShowing( exportWindow, true )
	    
	    --
		WindowAssignFocus( exportWindow .. "AuraText", true )
		
		-- Set the text to the default for import
		TextEditBoxSetText( exportWindow .. "AuraText", wstr )
		
		-- Highlight the text
		TextEditBoxSelectAll( exportWindow .. "AuraText" )
	end
end

function AuraShares.OnImportAura()
	-- Display our import window
    WindowSetShowing( importWindow, true )
    
	--
	WindowAssignFocus( importWindow .. "AuraText", true )
	
	-- Set the text to the default for import
	TextEditBoxSetText( importWindow .. "AuraText", T["Replace this text with an Aura export and click Ok"] )
	
	-- Highlight the text
	TextEditBoxSelectAll( importWindow .. "AuraText" )
end

function AuraShares.OnCloseAuraSharesImportExportWindow()
	if( SystemData.ActiveWindow.name:find( importWindow ) ~= nil ) then
		WindowSetShowing( importWindow, false )	
	elseif( SystemData.ActiveWindow.name:find( exportWindow ) ~= nil ) then
		WindowSetShowing( exportWindow, false )
	end
end

function AuraShares.OnImportExportOkButton()
	if( SystemData.ActiveWindow.name:find( importWindow ) ~= nil ) then
		-- Get the text from the edit box
		local wstr = TextEditBoxGetText( importWindow .. "AuraText" )
		
		-- Verify the text atleast looks valid
		if( wstr:len() > 0 and WStringsCompare( wstr, T["Replace this text with an Aura export and click Ok"] ) ~= 0 ) then
			-- Create a new aura
			local aura = Aura.Create( {} )
	
			-- Import the aura
			if( aura:ImportAura( wstr ) ) then
				-- Disable the aura before adding it to the users list
				aura:Set( "general-enabled", false )
			
				-- Add the aura to the users list
				AuraAddon.AddAura( aura )

				-- Close the import window				
				WindowSetShowing( importWindow, false )
			else
				DialogManager.MakeOneButtonDialog(
            		T["An error occurred attempting to load the Aura.  Verify you have entered the correct data."],
            		L"Ok", nil )
			end
		end
			
	elseif( SystemData.ActiveWindow.name:find( exportWindow ) ~= nil ) then
		WindowSetShowing( exportWindow, false )
	end
end
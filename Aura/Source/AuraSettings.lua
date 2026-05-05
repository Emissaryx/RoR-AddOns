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

if not AuraSettings then AuraSettings = {} end

local T = LibStub( "WAR-AceLocale-3.0" ) : GetLocale( "Aura" )

local MAX_VISIBLE_ROWS 		= 7
local windowId 				= "AuraSettings"

local sortColumnNum 		= 0				
local sortColumnName 		= ""		
local shouldSortIncreasing 	= true

local normalDisplayList 	= {}
local reverseDisplayList 	= {}

-- This isnt local so the listbox can see it
AuraSettings.listDisplayData = {}

local editAura				= nil
local editAuraIndex			= nil

local deleteAura			= nil
local deleteAuraIndex		= nil

-- Column Headers
local enabledHeader			= L""
local nameHeader   			= L"Name"

local function originalOrderComparator( a, b )		return( a.slotNum < b.slotNum )  end
local function nameComparator( a, b )				return( WStringsCompare( a.Name, b.Name ) == -1 ) end 
local function enabledComparator( a, b )			return( a.Enabled ) end

local sortHeaderData =
{
	[0] = { sortFunc=originalOrderComparator, },
    { column = "Enabled",		text=enabledHeader,			sortFunc=enabledComparator,		},
    { column = "Name",			text=nameHeader,			sortFunc=nameComparator,		},
}

function AuraSettings.GetWindowName() return windowId end

function AuraSettings.OnLoad()

	-- Set our configuration title
	LabelSetText( windowId .. "TitleBarText", towstring( "Aura - " .. AuraAddon.GetDisplayVersion() ) )
	
	-- Initialize our aura list
	for i, data in ipairs( sortHeaderData ) do
        local buttonName = windowId .. data.column
        ButtonSetText( buttonName, data.text )
        WindowSetShowing( buttonName .. "DownArrow", false )
        WindowSetShowing( buttonName .. "UpArrow", false )
    end
    	
	DataUtils.SetListRowAlternatingTints( windowId .. "AuraList", MAX_VISIBLE_ROWS )
	
	-- Setup our Enable Addon button
	LabelSetText( windowId .. "EnableAddonToggleLabel", towstring( "Enable Addon" ) )
	ButtonSetPressedFlag( windowId .. "EnableAddonToggleButton", AuraAddon.RuntimeConfiguration.Enabled )
	
	-- Setup our Enable Debugging button
	LabelSetText( windowId .. "EnableDebuggingToggleLabel", towstring( "Debug Mode" ) )
	ButtonSetPressedFlag( windowId .. "EnableDebuggingToggleButton", AuraAddon.RuntimeConfiguration.Debug )
	
	-- Setup our Profile Button
	ButtonSetText( windowId .. "SharesButton", T["Share Auras"] )
	
	-- Setup our Add Button
	ButtonSetText( windowId .. "AddButton", towstring( "Add Aura" ) )
		
	-- Setup our Close Button
	ButtonSetText( windowId .. "CloseButton", towstring( "Close" ) )
	
	-- Update our UI
	AuraSettings.Refresh()
end

function AuraSettings.OnShutdown()
	AuraSettings.OnClose()
end

function AuraSettings.SetListDisplayItem( slotNum, aura )

	local listDisplayItem = {}
	
	listDisplayItem.slotNum 	= slotNum
    listDisplayItem.Name	 	= aura:Get( "general-name" )
    listDisplayItem.Enabled		= aura:Get( "general-enabled" )
    
    AuraSettings.listDisplayData[slotNum] = listDisplayItem
end

function AuraSettings.CreateListDisplayData()
	AuraSettings.listDisplayData = {}
	
	for slotNum, aura in pairs( AuraAddon.RuntimeAuras ) 
	do
		AuraSettings.SetListDisplayItem( slotNum, aura )
    end
end

function AuraSettings.UpdateCurrentList()
	-- Create a new list display data
    AuraSettings.CreateListDisplayData()
    
    -- Display the newly generated list
	AuraSettings.ShowCurrentList()
end

function AuraSettings.ShowCurrentList()
	-- Clear our display data
	displayOrder = {}
    reverseDisplayOrder = {}
    
	-- Sort before displaying
    AuraSettings.Sort()
    
    -- Create the list we will use to display
    for index,_ in ipairs( AuraSettings.listDisplayData )
    do
    	-- Add this to the end of our display
    	table.insert( displayOrder, index )
    	
    	-- Add this to the beginning of our display
    	table.insert( reverseDisplayOrder, 1, index )
    end
    
    -- Display the sorted data
    AuraSettings.DisplaySortedData()
end

function AuraSettings.DisplaySortedData()
	if( shouldSortIncreasing ) then
        ListBoxSetDisplayOrder( windowId .. "AuraList", displayOrder )
    else
        ListBoxSetDisplayOrder( windowId .. "AuraList", reverseDisplayOrder )
    end 
end

function AuraSettings.Refresh()
	AuraSettings.UpdateCurrentList()
end

function AuraSettings.PopulateDisplay()
	local slotNum, aura
	 
	for row, data in ipairs( AuraSettingsAuraList.PopulatorIndices ) 
	do
		local rowName = windowId .. "AuraListRow".. row
		
		slotNum = AuraSettings.listDisplayData[data].slotNum
		
		aura = AuraAddon.RuntimeAuras[slotNum]
		
		AuraSettings.UpdateRow( aura, rowName )
	end
end

function AuraSettings.UpdateRow( aura, rowName )
	if( aura ~= nil and rowName ~= nil ) then
		-- Set the texture
		local texture, slice, dx, dy = aura:GetTextureData()
		
		if( texture ~= nil  ) then
			AuraHelpers.SetDynamicImageTexture( rowName .. "AuraTextureIcon", texture, slice, dx, dy,
				aura:Get( "texture-tintr" ), aura:Get( "texture-tintg" ), aura:Get( "texture-tintb" ), 1, 0, false ) 
		end
		
		if( aura:IsEditWindowDisplayed() ) then
			ButtonSetStayDownFlag( rowName .. "AuraTexture", true )
			ButtonSetPressedFlag( rowName .. "AuraTexture", true )
		else
			ButtonSetStayDownFlag( rowName .. "AuraTexture", false )
			ButtonSetPressedFlag(  rowName .. "AuraTexture", false )
		end
				
		-- Set the color of the label based upon the enabled state
		if( aura:IsEnabled() ) then
			LabelSetTextColor( rowName .. "Name", DefaultColor.GREEN.r, DefaultColor.GREEN.g, DefaultColor.GREEN.b )
		else
			LabelSetTextColor( rowName .."Name", DefaultColor.RED.r, DefaultColor.RED.g, DefaultColor.RED.b )
		end
	end
end

function AuraSettings.ClearSortButton()
    
    if( sortColumnName ~= "" ) then
        WindowSetShowing( sortColumnName.."DownArrow", false )
        WindowSetShowing( sortColumnName.."UpArrow", false )
        
        sortColumnName = "" 
        sortColumnNum = 0
        shouldSortIncreasing = true
    end
end

function AuraSettings.ChangeSorting()
    
    if( sortColumnName == SystemData.ActiveWindow.name ) then
		if shouldSortIncreasing then
			shouldSortIncreasing = ( not shouldSortIncreasing )
		else
			AuraSettings.ClearSortButton()
		end
    else
        AuraSettings.ClearSortButton()
        sortColumnName = SystemData.ActiveWindow.name
        sortColumnNum = WindowGetId( SystemData.ActiveWindow.name )
    end

	if( sortColumnNum > 0 ) then
		WindowSetShowing( sortColumnName.."DownArrow", shouldSortIncreasing )
		WindowSetShowing( sortColumnName.."UpArrow", not shouldSortIncreasing )
	end
	
    AuraSettings.ShowCurrentList()
end

function AuraSettings.Sort()
	if( sortColumnNum >= 0 ) then
        local comparator = sortHeaderData[sortColumnNum].sortFunc
        table.sort( AuraSettings.listDisplayData, comparator )
    end
end

function AuraSettings.ConfigChange_EnableAddon()
	local enabled = not AuraAddon.RuntimeConfiguration.Enabled
	ButtonSetPressedFlag( windowId .. "EnableAddonToggleButton", enabled )
	AuraAddon.RuntimeConfiguration.Enabled = enabled
end

function AuraSettings.ConfigChange_EnableDebugging()
	local debug = not AuraAddon.RuntimeConfiguration.Debug
	ButtonSetPressedFlag(windowId .. "EnableDebuggingToggleButton", debug )
	AuraAddon.RuntimeConfiguration.Debug = debug
end

function AuraSettings.OnClose()
	WindowSetShowing( windowId, false )
	WindowSetShowing( AuraShares.GetWindowName(), false )
end

function AuraSettings.OnShare()
	if( DoesWindowExist( AuraShares.GetWindowName() ) ) then
		WindowSetShowing( AuraShares.GetWindowName(), not WindowGetShowing( AuraShares.GetWindowName() ) )
	end
end

function AuraSettings.OnHidden()
	-- If the config is showing, save and hide
	if( WindowGetShowing( AuraConfig.Window ) ) then
		-- The user isnt trying to edit a new one, so we save and close
		AuraConfig.BuildAuraDataFromDialog( editAura )
		
		-- Clear our edit aura
		editAura				= nil
		editAuraIndex			= nil
		
		-- Update our display list
		AuraSettings.Refresh()
		
		-- Hide the config window
		WindowSetShowing( AuraConfig.Window, false )	
	end
	
	-- Let the settings know we are hidden
	AuraAddon.OnSettingsHidden()
end

function AuraSettings.OnLButtonUpAuraList( flags )
	local slotNum, rowIndex, aura = AuraSettings.GetSlotRowNumForActiveListRow()
	
	if( aura == nil ) then return end
	
	-- Shift Click toggles the enabled state of the aura
	if( flags == SystemData.ButtonFlags.SHIFT ) then
		-- Change the enabled state
	    aura:Toggle( "general-enabled" )
	    
	    -- Update the tooltip
	    AuraSettings.DisplayTooltip()
	    
		-- Refresh the updated row	
		AuraSettings.UpdateRow( aura, SystemData.ActiveWindow.name )
	-- Control Click prompts to delete the aura
	elseif( flags == SystemData.ButtonFlags.CONTROL ) then
		-- Set the deletion aura info
		deleteAura				= aura
		deleteAuraIndex		= slotNum

		local promptText = string.format( "%s %q", "Are you sure you wish to delete the following Aura? ", tostring( deleteAura ) )
	
		DialogManager.MakeTwoButtonDialog(  towstring(promptText), 
                                            GetString( StringTables.Default.LABEL_YES ), AuraSettings.ConfirmAuraDeletion, 
                                            GetString( StringTables.Default.LABEL_NO ),  AuraSettings.DenyAuraDeletion,
											nil, nil, nil, nil, DialogManager.TYPE_MODAL )
	else
		-- Toggle the display of the aura 
		aura:ToggleEditWindow()
		
		-- Refresh the updated row	
		AuraSettings.UpdateRow( aura, SystemData.ActiveWindow.name )
	end
end

function AuraSettings.OnRButtonUpAuraList()
	local slotNum, rowIndex, aura = AuraSettings.GetSlotRowNumForActiveListRow()
	
	-- See if we are already editing an aura
	if( WindowGetShowing( AuraConfig.Window ) and editAura ~= nil ) then
		-- Verify the user is trying to edit a different aura before changing
		if( editAura ~= aura ) then
			-- Save the old aura
			AuraConfig.BuildAuraDataFromDialog( editAura )
			
			-- Update our edit aura
			editAura				= aura
			editAuraIndex			= slotNum
		
			-- Build the dialog for this data
			AuraConfig.BuildDialogFromAuraData( aura )
			
			-- Display the new one
			WindowSetShowing( AuraConfig.Window, true )
			
			-- Update our display list
			AuraSettings.Refresh()
			AuraShares.Refresh()
		else
			-- The user isnt trying to edit a new one, so we save and close
			AuraConfig.BuildAuraDataFromDialog( editAura )
			
			-- Update our edit aura
			editAura				= nil
			editAuraIndex			= nil
			
			-- Hide the window
			WindowSetShowing( AuraConfig.Window, false )	
		end
	else 
		-- Update our edit aura
		editAura				= aura
		editAuraIndex			= slotNum
		
		-- Build the dialog for this data
		AuraConfig.BuildDialogFromAuraData( aura )
		
		-- Display the new one
		WindowSetShowing( AuraConfig.Window, true )	
	end
end

function AuraSettings.OnConfigHidden()
	
	if( editAura ~= nil ) then
		-- Save the new data to the aura
		AuraConfig.BuildAuraDataFromDialog( editAura )
		
		-- Clear our edit aura
		editAura				= nil
		editAuraIndex			= nil
	end

	-- Only refresh if we are showing	
	if( WindowGetShowing( windowId ) ) then	
		AuraSettings.Refresh()
		AuraShares.Refresh()
	end
end

function AuraSettings.OnAddAura()
	local aura = {}
	
	local auraObj = Aura.Create( aura )
	
	-- Add the aura
	AuraAddon.AddAura( auraObj )
end

function AuraSettings.ConfirmAuraDeletion()
	if( deleteAura ~= nil and deleteAuraIndex ~= nil ) then
		AuraDebug( "Delete Request:  " .. tostring( deleteAura ) )
		
		-- If the user is currently editing the aura they are looking to delete, clean up
		if( editAura == deleteAura ) then
			-- Clear our edit aura
			editAura				= nil
			editAuraIndex			= nil
			
			-- Hide the window
			WindowSetShowing( AuraConfig.Window, false )
		end
		
		-- Remove the entry from our table
		AuraAddon.RemoveAura( deleteAura, deleteAuraIndex )
		
		-- Unset our deleted information
		deleteAura = nil
		deleteAuraIndex = nil
		
		-- Update our display
		AuraSettings.Refresh()
	end
end

function AuraSettings.DenyAuraDeletion()
	-- The user denied deletion, so reset our deletion members
	deletionAuraIndex = nil
	deletionAura = nil
end

function AuraSettings.GetSlotRowNumForActiveListRow()
	local rowNumber, slowNumber, aura 
	
	-- Get the row within the window
	rowNumber = WindowGetId( SystemData.ActiveWindow.name ) 

	-- Get the data index from the list box
    local dataIndex = ListBoxGetDataIndex( windowId .. "AuraList" , rowNumber )
    
    -- Get the slot from the data
    if( dataIndex ~= nil ) then
    	slotNumber = AuraSettings.listDisplayData[dataIndex].slotNum
    
	    -- Get the data
	    if( slotNumber ~= nil ) then
	    	aura = AuraAddon.RuntimeAuras[slotNumber]
	    end
	end
    
	return slotNumber, rowNumber, aura
end

function AuraSettings.OnMouseOverAuraList()
	AuraSettings.DisplayTooltip()
end

function AuraSettings.DisplayTooltip()
	local slotNum, rowIndex, aura  = AuraSettings.GetSlotRowNumForActiveListRow()
	
	if( aura ~= nil ) then
		-- Create the tooltip
		AuraTooltip.CreateAuraTooltip( aura, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_RIGHT )
	end
end

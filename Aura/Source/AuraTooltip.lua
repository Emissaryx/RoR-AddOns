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

if not AuraTooltip then AuraTooltip = {} end

local windowId		= "AuraTooltip"
local shareWindowId	= "AuraShareTooltip"

function AuraTooltip.OnInitialize()
	-- Create our window
	CreateWindow( windowId, false )
    WindowSetTintColor( windowId .. "BackgroundInner", 0, 0, 0 )
    WindowSetAlpha( windowId .. "BackgroundInner", .9 )
    
    CreateWindow( shareWindowId, false )
    WindowSetTintColor( shareWindowId .. "BackgroundInner", 0, 0, 0 )
    WindowSetAlpha( shareWindowId .. "BackgroundInner", .9 )
end

function AuraTooltip.CreateAuraTooltip( aura, window, anchor )
	if( aura == nil or window == nil or anchor == nil) then return end
	
	-- Retrieve the data we need for a tooltip
	local enabledColor = AuraHelpers.fif( aura:Get( "general-enabled" ), DefaultColor.GREEN, DefaultColor.RED )	
	local enabledText = AuraHelpers.fif( aura:Get( "general-enabled" ), "disable", "enable" )
	local enabledText = string.format( "Shift-L-Click to %s.", enabledText )
	
	-- Create the tooltip window
	Tooltips.CreateCustomTooltip( window, windowId )
	
	-- Populate the tooltip
	LabelSetText( windowId .. "Name", aura:Get( "general-name" ) )
	LabelSetTextColor( windowId .. "Name", enabledColor.r, enabledColor.g, enabledColor.b )
	
	LabelSetText( windowId .. "Desc", L"This space intentionally left blank!" )
	LabelSetText( windowId .. "Preview", L"L-Click to preview." )
	LabelSetText( windowId .. "Edit", L"R-Click to edit." )
	LabelSetText( windowId .. "Enable", towstring( enabledText ) )
	LabelSetText( windowId .. "Delete", L"Control-L-Click to delete." )
	
	-- Anchor the tooltip
	Tooltips.AnchorTooltip( anchor )
end

function AuraTooltip.CreateShareTooltip( aura, window, anchor )
	if( aura == nil or window == nil or anchor == nil) then return end
	
	-- Create the tooltip window
	Tooltips.CreateCustomTooltip( window, shareWindowId )
	
	-- Populate the tooltip
	LabelSetText( shareWindowId .. "Name", aura:Get( "general-name" ) )
	
	LabelSetText( shareWindowId .. "Desc", L"This space intentionally left blank!" )
	LabelSetText( shareWindowId .. "Share", L"Shift-L-Click to copy this aura." )
	LabelSetText( shareWindowId .. "Export", L"Shift-R-Click to export this aura." )
	
	-- Anchor the tooltip
	Tooltips.AnchorTooltip( anchor )
end
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

if not PureConfig then return end

--
-- TODO: You will need to provide your own localization files as well as name here should you wish to use localization 
--
local T = LibStub( "WAR-AceLocale-3.0" ) : GetLocale( "PureCareerBar", debug )

local LibGUI 	= LibStub( "LibGUI" )

local initialized		= false
local col1Red, col1Green, col1Blue
local col2Red, col2Green, col2Blue
local col3Red, col3Green, col3Blue


local InitializeWindow, ApplyConfigSettings, RevertConfigSettings
local window	= {
	Name		= T["Careerbar"],
	display		= {},
	W			= {},
}
local textures			= PureConstants.Textures
local textureNames		= PureConstants.TextureNames

function InitializeWindow()
	-- If our window already exists, we are all set
	if initialized then return W end
    
    currentVersion = Pure.Get( "version" )
	
	local w
	local e	
    
    	
  	-- Colors Window
	w = LibGUI( "window", nil, "PureWindowDefault" )
    w:Resize( 400, 500 )
	w:Show( true )
	window.W.Colors = w    

    -- Version Window
	w = LibGUI( "window", nil, "PureWindowDefault" )
    w:Resize( 400, 50 )
	w:Show( true )    
	window.W.Version = w     
    
    table.insert( window.display, window.W.Colors )
    table.insert( window.display, window.W.Version )

    
   	--
	-- COLORS WINDOW ELEMENTS
	--
	-- Colors - Subsection Title
    e = window.W.Colors( "Label" )
    e:Resize( 550 )
    e:Align( "leftcenter" )
    e:AnchorTo( window.W.Colors, "topleft", "topleft", 15, 10 )
    e:Font( "font_clear_medium_bold" )
    e:SetText( T["Colors"] )
    window.W.Colors.Title_Label = e

    -- Colors - Color1 Texture Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 450 )
    e:Align( "center" )
    e:AnchorTo( window.W.Colors, "top", "top", 0, 30 )
    e:Font( "font_chat_text" )
    e:SetText( T["Color1 Texture Color"] )
    window.W.Colors.Color1TextureColor_Label = e
        
    -- Colors - Color1  Red Color Slider
    e = window.W.Colors( "Slider" )
    e:AnchorTo( window.W.Colors.Color1TextureColor_Label, "bottom", "top", 0, 5 )
    e:SetRange( 0,255 )
    window.W.Colors.Color1Red_Slider = e
    
    -- Colors - Color1  Red Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 200 )
    e:AnchorTo( window.W.Colors.Color1Red_Slider, "left", "right", -15, 0)
    e:Font( "font_chat_text" )
    e:Align( "rightcenter" )
    e:SetText( T["Red"] )
    window.W.Colors.Color1Red_Label = e
    
    -- Colors - Color1  Red Color Textbox
    e = window.W.Colors( "Textbox" )
    e:Resize( 65 )
    e:AnchorTo( window.W.Colors.Color1Red_Slider, "right", "left", 10, 0 )
    e:SetText( 255 )
    window.W.Colors.Color1Red_Textbox = e
    
    -- Colors - Color1  Green Color Slider
    e = window.W.Colors( "Slider" )
    e:AnchorTo( window.W.Colors.Color1Red_Slider, "bottom", "top", 0, 5 )
    e:SetRange( 0,255 )
    window.W.Colors.Color1Green_Slider = e
    
    -- Colors - Color1  Green Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 200 )
    e:AnchorTo( window.W.Colors.Color1Green_Slider, "left", "right", -15, 0)
    e:Font( "font_chat_text" )
    e:Align( "rightcenter" )
    e:SetText( T["Green"] )
    window.W.Colors.Color1Green_Label = e
    
    -- Colors - Color1  Green Color Textbox
    e = window.W.Colors( "Textbox" )
    e:Resize( 65 )
    e:AnchorTo( window.W.Colors.Color1Green_Slider, "right", "left", 10, 0 )
    e:SetText( 255 )
    window.W.Colors.Color1Green_Textbox = e
    
    -- Colors - Color1  Blue Color Slider
    e = window.W.Colors( "Slider" )
    e:AnchorTo( window.W.Colors.Color1Green_Slider, "bottom", "top", 0, 5 )
    e:SetRange( 0,255 )
    window.W.Colors.Color1Blue_Slider = e
	
	-- Colors - Color1  Blue Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 200 )
    e:AnchorTo( window.W.Colors.Color1Blue_Slider, "left", "right", -15, 0)
    e:Font( "font_chat_text" )
    e:Align( "rightcenter" )
    e:SetText( T["Blue"] )
    window.W.Colors.Color1Blue_Label = e
    
    -- Colors - Color1  Blue Color Textbox
    e = window.W.Colors( "Textbox" )
    e:Resize( 65 )
    e:AnchorTo( window.W.Colors.Color1Blue_Slider, "right", "left", 10, 0 )
    e:SetText( 255 )
    window.W.Colors.Color1Blue_Textbox = e   


    -- Colors - Color2 Texture Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 450 )
    e:Align( "center" )
    e:AnchorTo( window.W.Colors.Color1Blue_Slider, "bottom", "top", 0, 10 )
    e:Font( "font_chat_text" )
    e:SetText( T["Color2 Texture Color"] )
    window.W.Colors.Color2TextureColor_Label = e
        
    -- Colors - Color2  Red Color Slider
    e = window.W.Colors( "Slider" )
    e:AnchorTo( window.W.Colors.Color2TextureColor_Label, "bottom", "top", 0, 5 )
    e:SetRange( 0,255 )
    window.W.Colors.Color2Red_Slider = e
    
    -- Colors - Color2  Red Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 200 )
    e:AnchorTo( window.W.Colors.Color2Red_Slider, "left", "right", -15, 0)
    e:Font( "font_chat_text" )
    e:Align( "rightcenter" )
    e:SetText( T["Red"] )
    window.W.Colors.Color2Red_Label = e
    
    -- Colors - Color2  Red Color Textbox
    e = window.W.Colors( "Textbox" )
    e:Resize( 65 )
    e:AnchorTo( window.W.Colors.Color2Red_Slider, "right", "left", 10, 0 )
    e:SetText( 255 )
    window.W.Colors.Color2Red_Textbox = e
    
    -- Colors - Color2  Green Color Slider
    e = window.W.Colors( "Slider" )
    e:AnchorTo( window.W.Colors.Color2Red_Slider, "bottom", "top", 0, 5 )
    e:SetRange( 0,255 )
    window.W.Colors.Color2Green_Slider = e
    
    -- Colors - Color2  Green Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 200 )
    e:AnchorTo( window.W.Colors.Color2Green_Slider, "left", "right", -15, 0)
    e:Font( "font_chat_text" )
    e:Align( "rightcenter" )
    e:SetText( T["Green"] )
    window.W.Colors.Color2Green_Label = e
    
    -- Colors - Color2  Green Color Textbox
    e = window.W.Colors( "Textbox" )
    e:Resize( 65 )
    e:AnchorTo( window.W.Colors.Color2Green_Slider, "right", "left", 10, 0 )
    e:SetText( 255 )
    window.W.Colors.Color2Green_Textbox = e
    
    -- Colors - Color2  Blue Color Slider
    e = window.W.Colors( "Slider" )
    e:AnchorTo( window.W.Colors.Color2Green_Slider, "bottom", "top", 0, 5 )
    e:SetRange( 0,255 )
    window.W.Colors.Color2Blue_Slider = e
	
	-- Colors - Color2  Blue Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 200 )
    e:AnchorTo( window.W.Colors.Color2Blue_Slider, "left", "right", -15, 0)
    e:Font( "font_chat_text" )
    e:Align( "rightcenter" )
    e:SetText( T["Blue"] )
    window.W.Colors.Color2Blue_Label = e
    
    -- Colors - Color2  Blue Color Textbox
    e = window.W.Colors( "Textbox" )
    e:Resize( 65 )
    e:AnchorTo( window.W.Colors.Color2Blue_Slider, "right", "left", 10, 0 )
    e:SetText( 255 )
    window.W.Colors.Color2Blue_Textbox = e        
    

    -- Colors - Color3 Texture Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 450 )
    e:Align( "center" )
    e:AnchorTo( window.W.Colors.Color2Blue_Slider, "bottom", "top", 0, 10 )
    e:Font( "font_chat_text" )
    e:SetText( T["Color3 Texture Color"] )
    window.W.Colors.Color3TextureColor_Label = e
        
    -- Colors - Color3  Red Color Slider
    e = window.W.Colors( "Slider" )
    e:AnchorTo( window.W.Colors.Color3TextureColor_Label, "bottom", "top", 0, 5 )
    e:SetRange( 0,255 )
    window.W.Colors.Color3Red_Slider = e
    
    -- Colors - Color3  Red Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 200 )
    e:AnchorTo( window.W.Colors.Color3Red_Slider, "left", "right", -15, 0)
    e:Font( "font_chat_text" )
    e:Align( "rightcenter" )
    e:SetText( T["Red"] )
    window.W.Colors.Color3Red_Label = e
    
    -- Colors - Color3  Red Color Textbox
    e = window.W.Colors( "Textbox" )
    e:Resize( 65 )
    e:AnchorTo( window.W.Colors.Color3Red_Slider, "right", "left", 10, 0 )
    e:SetText( 255 )
    window.W.Colors.Color3Red_Textbox = e
    
    -- Colors - Color3  Green Color Slider
    e = window.W.Colors( "Slider" )
    e:AnchorTo( window.W.Colors.Color3Red_Slider, "bottom", "top", 0, 5 )
    e:SetRange( 0,255 )
    window.W.Colors.Color3Green_Slider = e
    
    -- Colors - Color3  Green Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 200 )
    e:AnchorTo( window.W.Colors.Color3Green_Slider, "left", "right", -15, 0)
    e:Font( "font_chat_text" )
    e:Align( "rightcenter" )
    e:SetText( T["Green"] )
    window.W.Colors.Color3Green_Label = e
    
    -- Colors - Color3  Green Color Textbox
    e = window.W.Colors( "Textbox" )
    e:Resize( 65 )
    e:AnchorTo( window.W.Colors.Color3Green_Slider, "right", "left", 10, 0 )
    e:SetText( 255 )
    window.W.Colors.Color3Green_Textbox = e
    
    -- Colors - Color3  Blue Color Slider
    e = window.W.Colors( "Slider" )
    e:AnchorTo( window.W.Colors.Color3Green_Slider, "bottom", "top", 0, 5 )
    e:SetRange( 0,255 )
    window.W.Colors.Color3Blue_Slider = e
	
	-- Colors - Color3  Blue Color Label
    e = window.W.Colors( "Label" )
    e:Resize( 200 )
    e:AnchorTo( window.W.Colors.Color3Blue_Slider, "left", "right", -15, 0)
    e:Font( "font_chat_text" )
    e:Align( "rightcenter" )
    e:SetText( T["Blue"] )
    window.W.Colors.Color3Blue_Label = e
    
    -- Colors - Color3  Blue Color Textbox
    e = window.W.Colors( "Textbox" )
    e:Resize( 65 )
    e:AnchorTo( window.W.Colors.Color3Blue_Slider, "right", "left", 10, 0 )
    e:SetText( 255 )
    window.W.Colors.Color3Blue_Textbox = e   
    
    e = window.W.Version( "Label" )
    e:Resize( 550 )
    e:Align( "leftcenter" )
    e:AnchorTo( window.W.Version, "topleft", "topleft", 15, 10 )
    e:Font( "font_clear_small_bold" )
    e:SetText( "PureCareerBar - v. 0.8" )
    window.W.Version.Title_Label = e    
    
    initialized = true
end

function ApplyConfigSettings()
	PureCareerBar.Set( "color1", { col1Red, col1Green, col1Blue } )
	PureCareerBar.Set( "color2", { col2Red, col2Green, col2Blue } )
	PureCareerBar.Set( "color3", { col3Red, col3Green, col3Blue } )
end

function RevertConfigSettings()
	--	
	-- Color Settings
	--
	col1Red, col1Green, col1Blue = unpack( PureCareerBar.Get( "color1" ) )
	window.W.Colors.Color1TextureColor_Label:Color( col1Red, col1Green, col1Blue )
	window.W.Colors.Color1Red_Slider:SetValue( col1Red )
	window.W.Colors.Color1Red_Textbox:SetText( towstring( col1Red ) )
	window.W.Colors.Color1Green_Slider:SetValue( col1Green )
    window.W.Colors.Color1Green_Textbox:SetText( towstring( col1Green ) )
    window.W.Colors.Color1Blue_Slider:SetValue( col1Blue )
    window.W.Colors.Color1Blue_Textbox:SetText( towstring( col1Blue ) )
    
	col2Red, col2Green, col2Blue = unpack( PureCareerBar.Get( "color2" ) )
	window.W.Colors.Color2TextureColor_Label:Color( col2Red, col2Green, col2Blue )
	window.W.Colors.Color2Red_Slider:SetValue( col2Red )
	window.W.Colors.Color2Red_Textbox:SetText( towstring( col2Red ) )
	window.W.Colors.Color2Green_Slider:SetValue( col2Green )
    window.W.Colors.Color2Green_Textbox:SetText( towstring( col2Green ) )
    window.W.Colors.Color2Blue_Slider:SetValue( col2Blue )
    window.W.Colors.Color2Blue_Textbox:SetText( towstring( col2Blue ) )

	col3Red, col3Green, col3Blue = unpack( PureCareerBar.Get( "color3" ) )
	window.W.Colors.Color3TextureColor_Label:Color( col3Red, col3Green, col3Blue )
	window.W.Colors.Color3Red_Slider:SetValue( col3Red )
	window.W.Colors.Color3Red_Textbox:SetText( towstring( col3Red ) )
	window.W.Colors.Color3Green_Slider:SetValue( col3Green )
    window.W.Colors.Color3Green_Textbox:SetText( towstring( col3Green ) )
    window.W.Colors.Color3Blue_Slider:SetValue( col3Blue )
    window.W.Colors.Color3Blue_Textbox:SetText( towstring( col3Blue ) )    
end

function PureConfig_Careerbar_OnUpdate()
	-- Only update if pure config is showing and we are the active panel
	if( PureConfig.IsShowing() and ( PureConfig.GetActiveConfigWindowIndex() ==  window.Index ) and initialized ) then
		local updated = false
		local ret = false
        
		--
		-- Color Colors
		--
		-- 	Get the slider values
		ret, col1Red = PureConfig.UpdateColorSelection( col1Red, window.W.Colors.Color1Red_Slider, window.W.Colors.Color1Red_Textbox )
		updated = updated or ret
		
		ret, col1Green = PureConfig.UpdateColorSelection( col1Green, window.W.Colors.Color1Green_Slider, window.W.Colors.Color1Green_Textbox )
		updated = updated or ret
		
		ret, col1Blue = PureConfig.UpdateColorSelection( col1Blue, window.W.Colors.Color1Blue_Slider, window.W.Colors.Color1Blue_Textbox )
		updated = updated or ret
		
		-- Update our preview color
		if( updated ) then
			window.W.Colors.Color1TextureColor_Label:Color( col1Red, col1Green, col1Blue )
			updated = false
		end
        
		-- 	Get the slider values
		ret, col2Red = PureConfig.UpdateColorSelection( col2Red, window.W.Colors.Color2Red_Slider, window.W.Colors.Color2Red_Textbox )
		updated = updated or ret
		
		ret, col2Green = PureConfig.UpdateColorSelection( col2Green, window.W.Colors.Color2Green_Slider, window.W.Colors.Color2Green_Textbox )
		updated = updated or ret
		
		ret, col2Blue = PureConfig.UpdateColorSelection( col2Blue, window.W.Colors.Color2Blue_Slider, window.W.Colors.Color2Blue_Textbox )
		updated = updated or ret
		
		-- Update our preview color
		if( updated ) then
			window.W.Colors.Color2TextureColor_Label:Color( col2Red, col2Green, col2Blue )
			updated = false
		end

		-- 	Get the slider values
		ret, col3Red = PureConfig.UpdateColorSelection( col3Red, window.W.Colors.Color3Red_Slider, window.W.Colors.Color3Red_Textbox )
		updated = updated or ret
		
		ret, col3Green = PureConfig.UpdateColorSelection( col3Green, window.W.Colors.Color3Green_Slider, window.W.Colors.Color3Green_Textbox )
		updated = updated or ret
		
		ret, col3Blue = PureConfig.UpdateColorSelection( col3Blue, window.W.Colors.Color3Blue_Slider, window.W.Colors.Color3Blue_Textbox )
		updated = updated or ret
		
		-- Update our preview color
		if( updated ) then
			window.W.Colors.Color3TextureColor_Label:Color( col3Red, col3Green, col3Blue )
			updated = false
		end        
    end   
end        

window.Initialize	= InitializeWindow
window.Apply		= ApplyConfigSettings
window.Revert		= RevertConfigSettings
window.Index		= PureConfig.RegisterWindow( window )
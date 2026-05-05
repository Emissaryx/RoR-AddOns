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

if not Aura then Aura = {} end

local Serializer 	= LibStub:GetLibrary( "LibPickle-0.2" )
local serialize 	= Serializer.pickle
local deserialize 	= Serializer.unpickle

local WINDOW_RUNTIME_PREFIX				= "AuraRuntime_"
local WINDOW_EDIT_PREFIX				= "AuraEdit_"

local WINDOW_RUNTIME_TIMER_PREFIX		= "AuraRuntimeTimer_"
local WINDOW_EDIT_TIMER_PREFIX			= "AuraEditTimer_"

Aura.__index = Aura

--
-- DEFAULT DATA
--
local DefaultAura		=
{
	-- All underscore members are used internally by Aura to maintain
	-- state and ease codability
	["internal-activated"]					= false,
	["internal-runtimewindowid"]			= nil,
	["internal-runtimetimerwindowid"]		= nil,
	["internal-runtimeflashwindowid"]		= nil,
	["internal-editwindowid"]				= nil,
	["internal-edittimerwindowid"]			= nil,
	["internal-effect-timer-id"]			= -1,
	["internal-effect-names"]				= {},
	["internal-effect-id"]					= {},
	["internal-effect-whitelist"]			= {},
	["internal-effect-blacklist"]			= {},
	
	-- These members are used to hold which effectIds triggered an aura
	["internal-effect-self"]			    = {},
	["internal-effect-friendly"]			= {},
	["internal-effect-enemy"]			    = {},
	
	-- General Members
	["general-name"]						= L"New Aura",
	["general-enabled"]						= false,
	["general-triggertype"]					= AuraConstants.TRIGGER_TYPE_EFFECTS,
	["general-version"]                     = AuraAddon.GetVersion(),
	
	-- Texture Members
	["texture-type"]						= AuraConstants.TEXTURE_TYPE_ICON,
	["texture-id"]							= "00000",
	["texture-tintr"]						= 255,
	["texture-tintg"]						= 255,
	["texture-tintb"]						= 255,
	["texture-alpha"]						= 1.0,
	["texture-offsetx"]						= 0,
	["texture-offsety"]						= -200,
	["texture-scale"]						= 1,
	["texture-rotation"]					= 0,
	["texture-circledimage"]				= false,
	["texture-hideimage"]					= false,
	["texture-mirrorimage"]					= false,
	
	-- Trigger Members
	["trigger-onlyincombat"]				= false,
	["trigger-onlyoutofcombat"]				= false,
	["trigger-onlyingroup"]					= false,
	["trigger-onlyinwarparty"]				= false,
	["trigger-rvrflagged"]					= false,
	["trigger-notrvrflagged"]				= false,
	
	-- Ability Members
	["ability-abilityid"]					= 0,
	["ability-showwhennotactive"]			= false,
	["ability-requireexplicitactivecheck"]	= false,
	["ability-requirevaliditycheck"]		= false,
	
	-- Action Point Members
	["actionpoints-value"]					= 1,
	["actionpoints-operator"]				= AuraConstants.OPERATOR_EQUAL,
	["actionpoints-enablesecondary"]		= false,
	["actionpoints-secondaryconditional"]	= true,						-- True = AND (index 1), False = OR (index 2)
	["actionpoints-secondaryvalue"]			= 1,
	["actionpoints-secondaryoperator"]		= AuraConstants.OPERATOR_EQUAL,
	
	-- Career Members
	["career-value"]						= 1,
	["career-operator"]						= AuraConstants.OPERATOR_EQUAL,
	["career-enablesecondary"]				= false,
	["career-secondaryconditional"]			= true,						-- True = AND (index 1), False = OR (index 2)
	["career-secondaryvalue"]				= 1,
	["career-secondaryoperator"]			= AuraConstants.OPERATOR_EQUAL,
	
	-- Effect Members
	["effect-name"]							= L"",
	["effect-type"]							= 1,
	["effect-enablestacks"]					= false,
	["effect-stackoperator"]				= AuraConstants.OPERATOR_EQUAL,
	["effect-stackcount"]					= 0,
	["effect-showwhennotactive"]			= false,
	["effect-self"]							= true,
	["effect-friendly"]						= false,
	["effect-enemy"]						= false,
	["effect-exactmatch"]					= false,
	["effect-selfcast"]						= false,
	
	-- Hit Point Members
	["hitpoints-type"]						= AuraConstants.HIT_POINT_TYPE_SELF,
	["hitpoints-value"]						= 1,
	["hitpoints-operator"]					= AuraConstants.OPERATOR_EQUAL,
	["hitpoints-enablesecondary"]			= false,
	["hitpoints-secondaryconditional"]		= true,						-- True = AND (index 1), False = OR (index 2)
	["hitpoints-secondaryvalue"]			= 1,
	["hitpoints-secondaryoperator"]			= AuraConstants.OPERATOR_EQUAL,
	
	-- Morale Members
	["morale-type"]							= AuraConstants.HIT_POINT_TYPE_SELF,
	["morale-value"]						= 1,
	["morale-operator"]						= AuraConstants.OPERATOR_EQUAL,
	["morale-enablesecondary"]				= false,
	["morale-secondaryconditional"]			= true,						-- True = AND (index 1), False = OR (index 2)
	["morale-secondaryvalue"]				= 1,
	["morale-secondaryoperator"]			= AuraConstants.OPERATOR_EQUAL,
	
	-- Activation Members
	["activation-animation"]				= 1,
	["activation-sound"]					= 1,
	["activation-alerttext"]				= L"",
	["activation-alerttexttype"]			= 1,
	["activation-screenflash"]				= 1,
	
	-- Deactivation Members
	["deactivation-animation"]				= 1,
	["deactivation-sound"]					= 1,
	["deactivation-alerttext"]				= L"",
	["deactivation-alerttexttype"]			= 1,
	["deactivation-screenflash"]			= 1,
	
	-- Timer Members
	["timer-enabled"]						= false,
	["timer-offsetx"]						= 0,
	["timer-offsety"]						= 0,
	["timer-scale"]							= 1,
	["timer-tintr"]						= 255,
	["timer-tintg"]						= 255,
	["timer-tintb"]						= 255,
	["timer-alpha"]						= 1.0,
}

--
-- CTOR
--
function Aura.Create( data )
	local aura = {}
	if( data ~= nil ) then 
		aura = data
	end
	if( aura.Data == nil ) then aura.Data = {} end
	setmetatable( aura, Aura )
	return aura
end

function Aura:__towstring()
	return self:Get( "general-name" )
end

function Aura:__tostring()
	return WStringToString( self:__towstring() )
end

--
-- PRIMARY AURA FUNCTIONS
--
function Aura:Activate()
	if( not self:IsActivated() ) then
		AuraDebug( "Activating Aura: " .. tostring( self ) )
		
		-- Mark the aura as activated, so we dont end up double processing
		self:Set( "internal-activated", true )
		
		-- If the aura has a sound play it
		if( self:Get( "activation-sound" ) > 1 ) then
			Sound.Play( AuraConstants.Sounds[self:Get( "activation-sound" )].SoundID )
		end
		
		-- Play the activaton alert text if its been configured
		if( self:Get( "activation-alerttexttype" ) > 1 and self:Get( "activation-alerttext" ) ~= L"" ) then
			AlertTextWindow.AddLine( AuraConstants.AlertText[self:Get( "activation-alerttexttype" )].type, self:Get( "activation-alerttext" ) );
		end
		
		-- Play the screen flash if its been configured
		if( self:Get( "activation-screenflash" ) > 1 ) then
			local anim = AuraConstants.ActivationScreenFlash[self:Get( "activation-screenflash" )]
			if( anim ~= nil ) then
				WindowSetShowing( self:Get( "internal-runtimeflashwindowid" ), true )
				WindowStartAlphaAnimation( self:Get( "internal-runtimeflashwindowid" ), anim.type, anim.startAlpha, self:Get( "texture-alpha"), anim.duration, anim.setStartBeforeDelay, anim.delay, anim.loopCount )
			end
		end
		
		-- Display the window, if we arent hiding the image
		WindowSetShowing( self:Get( "internal-runtimewindowid" ), not self:Get( "texture-hideimage" ) )
		
		-- Perform our start animation, only if we arent hiding the image
		if( not self:Get( "texture-hideimage" ) and self:Get( "activation-animation" ) > 1 ) then
			local anim = AuraConstants.ActivationAnimations[self:Get( "activation-animation" )]
			if( anim ~= nil ) then
				WindowStartAlphaAnimation( self:Get( "internal-runtimewindowid" ), anim.type, anim.startAlpha, anim.endAlpha, anim.duration, anim.setStartBeforeDelay, anim.delay, anim.loopCount )
			end
		end
	end
end

function Aura:CleanInternalMembers()
	-- Iterate the rest of our data and if any keys begin with "internal" set the values to nil
	for k,v in pairs( self.Data )
	do
	   -- If this is a window member, delete the window
	   if( k:match( "^internal.*window.*" ) ) then
	       	self:DeleteWindow( self:Get( k ) )
	   end
	   
	   -- Set the member to nil
	   if( k:match( "^internal.*" ) ) then
	       self:Set( k, nil )   
	   end
	end
end

function Aura:CleanOldMembers()
	for k, v in pairs( self.Data )
	do
		if( DefaultAura[k] == nil ) then
            -- Remove settings in an aura that no longer exist in the default
			self:Set( k, nil )
		else
		    -- Remove settings in a aura that are not different than the default
            self:Set( k, v )   
		end
	end
end

function Aura:CreateEditWindows()
	self:Set( "internal-editwindowid", WINDOW_EDIT_PREFIX .. EA_IdGenerator:GetNewId() )
	self:Set( "internal-edittimerwindowid", WINDOW_EDIT_TIMER_PREFIX .. EA_IdGenerator:GetNewId() )
		
	CreateWindowFromTemplate( self:Get( "internal-editwindowid" ), "AuraFrame", "Root" )
	CreateWindowFromTemplate( self:Get( "internal-edittimerwindowid" ), "AuraTimerFrame", "Root" )
	
	WindowSetShowing( self:Get( "internal-editwindowid" ), false )
	WindowSetShowing( self:Get( "internal-edittimerwindowid" ), false )
	return true
end

function Aura:CreateRuntimeWindows()
	self:Set( "internal-runtimewindowid", WINDOW_RUNTIME_PREFIX .. EA_IdGenerator:GetNewId() )
	self:Set( "internal-runtimetimerwindowid", WINDOW_RUNTIME_TIMER_PREFIX .. EA_IdGenerator:GetNewId() )
	self:Set( "internal-runtimeflashwindowid", WINDOW_RUNTIME_PREFIX .. EA_IdGenerator:GetNewId() )
	
	CreateWindowFromTemplate( self:Get( "internal-runtimewindowid" ), "AuraFrame", "Root" )
	CreateWindowFromTemplate( self:Get( "internal-runtimetimerwindowid" ), "AuraTimerFrame", "Root" )
	CreateWindowFromTemplate( self:Get( "internal-runtimeflashwindowid" ), "AuraScreenFlashFrame", "Root" )
	
	WindowSetShowing( self:Get( "internal-runtimewindowid" ), false )
	WindowSetShowing( self:Get( "internal-runtimetimerwindowid" ), false )
	WindowSetShowing( self:Get( "internal-runtimeflashwindowid" ), false )
	
	return true
end

function Aura:Deactivate( nodeactivationevents )
	if( nodeactivationevents == nil ) then nodeactivationevents = false end
	
	if( self:IsActivated() ) then	
		AuraDebug( "Deactivating Aura: " .. tostring( self ) )
		-- If we are shutting down, we do not want to perform deactivation animiations/sounds
		if( not nodeactivationevents ) then
			-- Process our deactivation animation
			if( not self:Get( "texture-hideimage" ) and self:Get( "deactivation-animation" ) > 1 ) then
				local anim = AuraConstants.DeactivationAnimations[self:Get( "deactivation-animation" )]
				if( anim ~= nil ) then
					WindowStartAlphaAnimation( self:Get( "internal-runtimewindowid" ), anim.type, anim.startAlpha, anim.endAlpha, anim.duration, anim.setStartBeforeDelay, anim.delay, anim.loopCount )
					
					if( self:HasTimer() ) then
						WindowStartAlphaAnimation( self:Get( "internal-runtimetimerwindowid" ), anim.type, anim.startAlpha, anim.endAlpha, anim.duration, anim.setStartBeforeDelay, anim.delay, anim.loopCount )
					end
					
					--
					-- TODO:  At some point after this animation is finished, we should hide the window
					-- however, at this time we do not, we just leave it with alpha of 0.0
					--
					-- There are a few default UI windows that do this, so this shouldnt hurt anything
					--
				end
			else
				WindowStopAlphaAnimation( self:Get( "internal-runtimewindowid" ) )
				WindowStopAlphaAnimation( self:Get( "internal-runtimetimerwindowid" ) )
				WindowSetShowing( self:Get( "internal-runtimewindowid" ), false )
				WindowSetShowing( self:Get( "internal-runtimetimerwindowid" ), false )
			end
		
			-- If the aura has a sound play it
			if( self:Get( "deactivation-sound" ) > 1 ) then
				Sound.Play( AuraConstants.Sounds[self:Get( "deactivation-sound" )].SoundID )
			end
			
			-- Play the deactivation alert text if its been configured
			if( self:Get( "deactivation-alerttexttype" ) > 1 and self:Get( "deactivation-alerttext" ) ~= L"" ) then
				AlertTextWindow.AddLine( AuraConstants.AlertText[self:Get( "deactivation-alerttexttype" )].type, self:Get( "deactivation-alerttext" ) );
			end
			
			-- Play the screen flash if its been configured
			if( self:Get( "deactivation-screenflash" ) > 1 ) then
				local anim = AuraConstants.DeactivationAnimations[self:Get( "deactivation-screenflash" )]
				if( anim ~= nil ) then
					WindowSetShowing( self:Get( "internal-runtimeflashwindowid" ), true )
					WindowStartAlphaAnimation( self:Get( "internal-runtimeflashwindowid" ), anim.type, anim.startAlpha, anim.endAlpha, anim.duration, anim.setStartBeforeDelay, anim.delay, anim.loopCount )
				end
			elseif( self:Get( "activation-screenflash" ) > 1 ) then
				WindowStopAlphaAnimation( self:Get( "internal-runtimeflashwindowid" ) )
				WindowSetShowing( self:Get( "internal-runtimeflashwindowid" ), false )
			end
		else
			WindowStopAlphaAnimation( self:Get( "internal-runtimewindowid" ) )
			WindowStopAlphaAnimation( self:Get( "internal-runtimetimerwindowid" ) )
			WindowStopAlphaAnimation( self:Get( "internal-runtimeflashwindowid" ) )
			WindowSetShowing( self:Get( "internal-runtimewindowid" ), false )
			WindowSetShowing( self:Get( "internal-runtimetimerwindowid" ), false )
			WindowSetShowing( self:Get( "internal-runtimeflashwindowid" ), false )
		end
		
		-- Mark the aura as deactivated
		self:Set( "internal-activated", false )
	end
end

function Aura:DeleteEditWindows()
	self:DeleteWindow( self:Get( "internal-editwindowid" ) )
	self:DeleteWindow( self:Get( "internal-edittimerwindowid" ) )
end

function Aura:DeleteRuntimeWindows()
	self:DeleteWindow( self:Get( "internal-runtimewindowid" ) )
	self:DeleteWindow( self:Get( "internal-runtimetimerwindowid" ) )
	self:DeleteWindow( self:Get( "internal-runtimeflashwindowid" ) )
end

function Aura:DeleteWindow( windowId )
	if( windowId ~= nil and DoesWindowExist( windowId ) ) then 
		DestroyWindow( windowId )
		return true 
	end
		
	return false
end

function Aura:GetTextureData()
	return AuraAddon.GetTextureData( self:Get( "texture-type" ), self:Get( "texture-id" ) )
end

function Aura:HasTimer()
	if( self:Get( "timer-enabled" ) ) then 
		if( self:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_EFFECTS ) then return true end
		if( self:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_ABILITY and self:Get( "ability-showwhennotactive" ) ) then return true end
	end
	return false
end

function Aura:HasRuntimeWindows()
	local window = self:Get( "internal-runtimewindowid" )
	return window ~= nil and DoesWindowExist( window )
end

function Aura:HasEditWindows()
	local window = self:Get( "internal-editwindowid" )
	return window ~= nil and DoesWindowExist( window )
end

function Aura:HideEditWindows()
	if( self:HasEditWindows() ) then 
		WindowSetShowing( self:Get( "internal-editwindowid" ), false )
		WindowSetShowing( self:Get( "internal-edittimerwindowid" ), false )
	end
end

function Aura:IsActivated()
	return self:Get( "internal-activated" )
end

function Aura:IsEditWindowDisplayed()
	local window = self:Get( "internal-editwindowid" )
	if( window ~= nil and DoesWindowExist( window ) and WindowGetShowing( window ) ) then return true end
	return false
end

function Aura:IsEnabled()
	return self:Get( "general-enabled" )
end

function Aura:IsRuntimeWindowDisplayed()
	local window = self:Get( "internal-runtimewindowid" )
	if( window ~= nil and DoesWindowExist( window ) and WindowGetShowing( window ) ) then return true end
	return false
end

function Aura:PrepareForRuntime()
	-- If we have a previous runtime window, clean it up
	if( self:HasRuntimeWindows() ) then
		self:DeleteRuntimeWindows()	
	end 
	
	-- Create the runtime window
	self:CreateRuntimeWindows()
	
	-- Update the runtime window
	self:UpdateWindow( self:Get( "internal-runtimewindowid" ) )
	
	-- Tint the flash screen
	WindowSetTintColor( self:Get( "internal-runtimeflashwindowid" ) .. "Image", self:Get( "texture-tintr" ), self:Get( "texture-tintg" ), self:Get( "texture-tintb" ) )
	
	-- Update the timer window
	if( self:HasTimer() ) then
		self:UpdateTimerWindow( self:Get( "internal-runtimetimerwindowid" ) )
	end
	
	-- Create our internal effect tables
	self:Set( "internal-effect-self" , {} )
	self:Set( "internal-effect-friendly" , {} )
	self:Set( "internal-effect-enemy" , {} )
	self:Set( "internal-effect-names" , {} )
	self:Set( "internal-effect-id" , {} )
	self:Set( "internal-effect-whitelist" , {} )
	self:Set( "internal-effect-blacklist" , {} )
end

function Aura:SetTexture( type, texture )
	self:Set( "texture-id", texture )
	self:Set( "texture-type", type )
end

function Aura:SetTextureColor( r, g, b )
	self:Set( "texture-tintr", r )
	self:Set( "texture-tintg", g )
	self:Set( "texture-tintb", b )
end

function Aura:SetTimerColor( r, g, b )
	self:Set( "timer-tintr", r )
	self:Set( "timer-tintg", g )
	self:Set( "timer-tintb", b )
end

function Aura:ShowEditWindows()
	-- If the aura does not have a window, create one
	if( not self:HasEditWindows() ) then
		-- Create the aura window
		self:CreateEditWindows()
	end
	
	-- Update the runtime window
	self:UpdateWindow( self:Get( "internal-editwindowid" ) )
	
	-- Update the timer window
	self:UpdateTimerWindow( self:Get( "internal-edittimerwindowid" ) )
	
	-- Set some default text to our timer window
	LabelSetText( self:Get( "internal-edittimerwindowid" ) .. "Time", L"12.5" )
	
	-- Display the window
	WindowSetShowing( self:Get( "internal-editwindowid" ), true )
	
	-- Display our timer window if configured for it
	WindowSetShowing( self:Get( "internal-edittimerwindowid" ), self:Get( "timer-enabled" ) )
end

function Aura:ToggleEditWindow()
	if( self:IsEditWindowDisplayed() ) then
		self:HideEditWindows()
	else
		self:ShowEditWindows()
	end
end

function Aura:TriggerStatusCheck()
	if( not GameData.Player.inCombat and self:Get( "trigger-onlyincombat" ) ) then return false end
	if( GameData.Player.inCombat and self:Get( "trigger-onlyoutofcombat" ) ) then return false end
	if( not AuraHelpers.IsGroupActive() and self:Get( "trigger-onlyingroup" ) ) then return false end
	if( not IsWarBandActive() and self:Get( "trigger-onlyinwarparty" )  ) then return false end
	if( not ( GameData.Player.rvrZoneFlagged or GameData.Player.rvrPermaFlagged ) and self:Get( "trigger-rvrflagged" ) ) then return false end
	if( ( GameData.Player.rvrZoneFlagged or GameData.Player.rvrPermaFlagged ) and self:Get( "trigger-notrvrflagged" ) ) then return false end
	return true
end

function Aura:UpdateTimerWindow( windowId )
	-- Clear any anchors the window has
	WindowClearAnchors( windowId )
	
	-- Set the anchor for its position on the screen
	WindowAddAnchor( windowId, "center", "Root", "center", self:Get( "timer-offsetx"), self:Get( "timer-offsety" ) )
	
	LabelSetTextColor( windowId .."Time", self:Get( "timer-tintr" ), self:Get( "timer-tintg" ), self:Get( "timer-tintb" ) )
	WindowSetAlpha( windowId, self:Get( "timer-alpha") )
	
	-- Set the windows scale
	WindowSetScale( windowId, self:Get( "timer-scale" ) )
end

function Aura:UpdateTimerWindowTime( duration )
	if( duration > 0 ) then
		local labelTime = TimeUtils.FormatSeconds( duration, true )
		-- Removes S from timer
		function removeS(s)
			local result = s.sub(s, 1, -2)
			 return result
		end
		local labelTimeWithoutS = removeS(labelTime)
		LabelSetText( self:Get( "internal-runtimetimerwindowid" ) .. "Time", labelTimeWithoutS )
	end
	
	WindowSetShowing( self:Get( "internal-runtimetimerwindowid" ), duration > 0 )
end

function Aura:UpdateWindow( windowId )
	-- Clear any anchors the window has
	WindowClearAnchors( windowId )
	
	-- Set the anchor for its position on the screen
	WindowAddAnchor( windowId, "center", "Root", "center", self:Get( "texture-offsetx" ), self:Get( "texture-offsety" ) )
	
	local texture, slice, dx, dy = self:GetTextureData()
	
	if( texture ~= nil  ) then
		-- Resize the window to match the size of the texture
		WindowSetDimensions( windowId, dx * 2, dy * 2 )
		
		-- Update our display
		AuraHelpers.SetDynamicImageTexture( windowId .. "ImageSquare", texture, slice, dx, dy, 
			self:Get( "texture-tintr" ), self:Get( "texture-tintg" ), self:Get( "texture-tintb" ), self:Get( "texture-alpha" ), self:Get( "texture-rotation" ), self:Get( "texture-mirrorimage" ) )
		
		AuraHelpers.SetCircleImageTexture( windowId .. "ImageCircle", texture, slice, dx, dy, 
				self:Get( "texture-tintr" ), self:Get( "texture-tintg" ), self:Get( "texture-tintb" ), self:Get( "texture-alpha" ), self:Get( "texture-rotation" ), self:Get( "texture-mirrorimage" ) )
		
		WindowSetShowing( windowId .. "ImageSquare", not self:Get( "texture-circledimage" ) )
		WindowSetShowing( windowId .. "ImageCircle", self:Get( "texture-circledimage" ) )
	end
	
	-- Set the windows scale
	WindowSetScale( windowId, self:Get( "texture-scale" ) )
end

--
-- SETTING FUNCTIONS
--
function Aura:Get( key )
	if( self.Data[key] ~= nil ) then
		return self.Data[key]
	else
		if( DefaultAura[key] ~= nil ) then
			return AuraHelpers.CopyTable( DefaultAura[key] )
		else
			if( not key:match( "^internal.*" ) ) then
				AuraDebug( "Key not found: " .. tostring( key ) )
			end
			return nil
		end	
	end
end

function Aura:Set( key, value )
	if( not key:match( "^internal.*" ) and DefaultAura[key] ~= nil and DefaultAura[key] == value ) then
        self.Data[key] = nil 
        return 
    end
    self.Data[key] = value
end

function Aura:Toggle( key )
	local value = self:Get( key )
	
	if( value ~= nil and type( value ) == "boolean" ) then
		self:Set( key, not value )
		return not value
	end
	return nil
end

function Aura:ExportAura()
	-- Create a copy of this auras data table
	local copy = AuraHelpers.CopyTable( self.Data )

	-- Clean the data of variables we do not need to export
	for k,v in pairs( copy )
	do
		-- We do not want to export internal members
		if( k:match( "^internal.*" ) ) then
			copy[k] = nil
		end
	end
	
	return serialize( copy )
end

function Aura:ImportAura( wstr )
	self.Data = deserialize( wstr )
	return self.Data ~= nil
end
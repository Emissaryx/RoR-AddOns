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

if not AuraAddon then AuraAddon = {} end

local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local alpha = false
--[===[@alpha@
alpha = true
--@end-alpha@]===]

local firstLoad = true

local VERSION 			= { MAJOR = 2, MINOR = 7, REV = 2 }
--AuraAddon.VERSION		= VERSION
local DisplayVersion 	= string.format( "%d.%d.%d", VERSION.MAJOR, VERSION.MINOR, VERSION.REV )

if( debug ) then
	DisplayVersion 			= DisplayVersion .. " Dev"
else
	DisplayVersion 			= DisplayVersion .. " r" .. tonumber( "108" )
	
	if( alpha ) then
		DisplayVersion = DisplayVersion .. "-alpha"
	end
end

AuraAddon.DefaultConfiguration =
{
	Version 	= VERSION,
	Enabled 	= true,
	Debug		= false,
	Settings 	= {},
	Auras		= {}
}

AuraAddon.DefaultSettings 	=
{
	["general-gcd"]					= 1.6,
	["general-effect-timers"]		= .4,
	["general-ability-timers"]		= .4,
}

-- This table holds all internal and custom textures
AuraAddon.AllTextures		= {}

-- This table holds the settings loaded up from the users profile
AuraAddon.RuntimeConfiguration	= {}

-- This holds the individual settings
AuraAddon.RuntimeSettings	= {}
AuraAddon.RuntimeAuras		= {}

function AuraAddon.OnInitialize()
	-- Create an initial runtime configuration
	if( AuraAddon.RuntimeConfiguration == nil ) then
		AuraAddon.RuntimeConfiguration = AuraHelpers.CopyTable( AuraAddon.DefaultConfiguration )
	end
	
	if( AuraAddon.RuntimeSettings == nil ) then 
		AuraAddon.RuntimeSettings = AuraHelpers.CopyTable( AuraAddon.DefaultSettings )
	end
	
	if( AuraAddon.RuntimeAuras == nil )then
		AuraAddon.RuntimeAuras = {}
	end
	
	-- Register our slash commands with LibSlash
	AuraDebug( "Registering slash commands" )
	
	-- Attempt to register one of our handlers
	LibSlash.RegisterSlashCmd( "aura", AuraAddon.Slash )
	LibSlash.RegisterSlashCmd( "auraconfig", AuraAddon.Slash )
	LibSlash.RegisterSlashCmd( "showaura", AuraAddon.Slash )
	
	-- Print our initialization usage
	AuraPrint( "Aura " .. AuraAddon.GetDisplayVersion() .. " initialized.  Use /aura to configure." )
	
	-- Register an event for reload ui
	RegisterEventHandler( SystemData.Events.RELOAD_INTERFACE, "AuraAddon.OnLoad" )
	RegisterEventHandler( SystemData.Events.LOADING_END, "AuraAddon.OnLoad" )
end

function AuraAddon.OnShutdown()
	-- Shutdown the Aura Engine
	AuraEngine.Stop()
end

function AuraAddon.OnLoad()
	-- The following things we only want to do the first time we finish loading the UI,
	-- as by that point our configuration settings have been loaded, so we can prepare
	-- our engine/UI to use them.
	if( firstLoad ) then
		-- If our windows exists, hide them
		if( AuraConfig and DoesWindowExist( AuraConfig.Window ) ) then WindowSetShowing( AuraConfig.Window, false ) end
		if( AuraProfiles and DoesWindowExist( AuraShares.GetWindowName() ) ) then WindowSetShowing( AuraShares.GetWindowName(), false ) end
		
		-- Check to see if we have a pre-1.0.0 config that we need to convert to post-1.0.0 setup
		if( Aura.Settings ~= nil ) then
			local tempConfig = Aura.Settings
			
			-- Save our old settings using the new storage method
			AuraAddon.Configuration = AuraProfile.SaveCharacterSettings( AuraAddon.Configuration, tempConfig, AuraProfile.PROFILE_TYPE_CHARACTER )
			
			-- Set the old config to nil, so that this processing never takes place again
			AuraAddon.Settings = nil
		end
		
		-- Check if we have a pre-2.0.0 configuration variable name
		if( Aura.Configuration ~= nil ) then
			AuraAddon.Configuration = AuraHelpers.CopyTable( Aura.Configuration )
			-- Set the old config to nil, so that this processing never takes place again
			Aura.Configuration = nil
		end
		
		-- Load the user settings
		AuraAddon.Configuration, AuraAddon.RuntimeConfiguration = AuraProfile.LoadCharacterSettings( AuraAddon.Configuration, AuraAddon.DefaultConfiguration, AuraProfile.PROFILE_TYPE_CHARACTER )
		
		-- Set our runtime members
		AuraAddon.RuntimeAuras 		= AuraAddon.RuntimeConfiguration.Auras
		AuraAddon.RuntimeSettings 	= AuraAddon.RuntimeConfiguration.Settings
		
		-- If this is nil we have a pre-2.0.0 configuration, so migrate the values over
		if( AuraAddon.RuntimeSettings == nil ) then
			-- Copy the table
			AuraAddon.RuntimeConfiguration.Settings = AuraHelpers.CopyTable( AuraAddon.DefaultSettings )
			AuraAddon.RuntimeSettings = AuraAddon.RuntimeConfiguration.Settings
		end
		
		-- Build our textures
		AuraAddon.BuildTextures()
		
		-- After our settings have been brought up to date prepare them for runtime
		AuraAddon.PrepareSettingsForRuntime()
		
		-- Update our settings
		AuraAddon.UpdateSettings()
		
		-- Let our dialogs know that they can load up
		AuraColorPicker.OnLoad()
		AuraTexture.OnLoad()
		AuraSettings.OnLoad()
		AuraShares.OnLoad()
		
		firstLoad = false
	end
	
	-- We call this every time, as we need to update the data if the character has changed
	AuraConfig.OnLoad()

	-- We only want to start the engine if the AuraSettings window is not showing
	if( not WindowGetShowing( AuraSettings.GetWindowName() ) and not AuraEngine.IsRunning() ) then AuraEngine.Start() end
end

function AuraAddon.GetAuraConfiguration()
	return AuraAddon.Configuration
end

function AuraAddon.UpdateSettings()
	
    for index, aura in ipairs( AuraAddon.RuntimeAuras )
	do
        AuraAddon.UpdateIndividualAura( aura )		
	end
	
	-- Mark the new version
	AuraAddon.RuntimeConfiguration.Version = VERSION
end

function AuraAddon.UpdateIndividualAura( aura )
    local version = aura:Get( "general-version" )
    
    --
	-- Set the version of the aura
	--
	aura:Set( "general-version", VERSION )
end

function AuraAddon.PrepareSettingsForRuntime()
	-- Create our classes for each aura
	for index, aura in ipairs( AuraAddon.RuntimeAuras )
	do
		-- Create the new aura object
		local auraObj = Aura.Create( aura )
		
		-- Store it
		aura = auraObj
		
		-- Tell it to clean any old members
		aura:CleanOldMembers()
	end
end

function AuraAddon.CleanInternalMembers()
	for index, aura in ipairs( AuraAddon.RuntimeAuras )
	do
		-- Clean their internal members
		aura:CleanInternalMembers()
	end
end

function AuraAddon.AddAura( aura )
    -- Update the aura to make sure its the latest version
	AuraAddon.UpdateIndividualAura( aura )
	
	-- Add the aura to our settings
	table.insert( AuraAddon.RuntimeAuras, aura )
	
	-- Update our display
	AuraSettings.Refresh()
	AuraShares.Refresh()
end

function AuraAddon.RemoveAura( aura, index )
	-- Clean the aura before removing it
	aura:CleanInternalMembers()
	
	-- Remove the aura
	table.remove( AuraAddon.RuntimeAuras, index )
end

function AuraAddon.GetTextureData( type, id )
	local texture, slice, dx, dy = nil, nil, nil, nil
	
	if( type == AuraConstants.TEXTURE_TYPE_ICON ) then
		texture, dx, dy = GetIconData( tonumber( id ) )
		slice = ""
	else
		--[[
		--
		-- TODO:  Fix this code once custom textures come in
		--
		if( AuraAddon.AllTextures[name] ~= nil ) then 
			texture = AuraAddon.Textures[name].name 
			slice = AuraAddon.Textures[name].slice
			dx = AuraAddon.Textures[name].dx
			dy = AuraAddon.Textures[name].dy
		end
		--]]
	end
	return texture, slice, dx, dy
end

function AuraAddon.BuildTextures()
	AuraAddon.AllTextures						= {}
	--[[
		-- Add our internal textures
		for index, texture in pairs( AuraAddon.Textures )
		do
			AuraAddon.AllTextures[index] = texture
		end
		
		--
		-- Add our custom textures second, incase the user wants to overwrite one of
		-- the default texture names
		--
		for index, texture in pairs( AuraAddon.CustomTextures )
		do
			AuraAddon.AllTextures[index] = texture
		end
	--]]
end

function AuraAddon.OnSettingsHidden()
	-- Start the aura engine
	AuraEngine.Start()
end

local recursions = {}
local function better_toString(data, depth)
    if type(data) == "string" then
        return ("%q"):format(data)
    elseif type(data) == "wstring" then
        return ("w%q"):format(WStringToString(data))
    elseif type(data) ~= "table" then
        return ("%s"):format(tostring(data))
    else
        if recursions[data] then
            return "{<recursive table>}"
        end
        recursions[data] = true
        if next(data) == nil then
            return "{}"
        elseif next(data, next(data)) == nil then
            return "{ [" .. better_toString(next(data), depth) .. "] = " .. better_toString(select(2, next(data)), depth) .. " }"
        else
            local t = {}
            t[#t+1] = "{\n"
            local keys = {}
            for k in pairs(data) do
                keys[#keys+1] = k
            end
            table.sort(keys, mysort)
            for _, k in ipairs(keys) do
                local v = data[k]
                for i = 1, depth do
                    t[#t+1] = "    "
                end
                t[#t+1] = "["
                t[#t+1] = better_toString(k, depth+1)
                t[#t+1] = "] = "
                t[#t+1] = better_toString(v, depth+1)
                t[#t+1] = ",\n"
            end
            
            for i = 1, depth do
                t[#t+1] = "    "
            end
            t[#t+1] = "}"
            return table.concat(t)
        end
    end
end

local function pformat(...)
    local n = select('#', ...)
    local t = {'value: '}
    for i = 1, n do
        if i > 1 then
            t[#t+1] = ", "
        end
        t[#t+1] = better_toString((select(i, ...)), 0)
    end
    for k in pairs(recursions) do
        recursions[k] = nil
    end
    return table.concat(t), n
end

function AuraAddon.Slash( input )
	if( input == nil ) then input = "" end
	
	local opt, val = input:match("([a-z0-9_-]+)[ ]?(.*)")
	
	if( opt ) then
		-- options handler
        if opt == "options" then
        	local optString = nil
            for k,_ in pairs(AuraAddon.RuntimeSettings) do
                if( not val or val == "" or k:find(val) ) then
                    if optString then
                        optString = optString .. ", " .. k
                    else
                        optString = k
                    end
                end
            end
            if optString then
                if not val or val == "" then
                    AuraPrint("[aura] Currently known options: "..optString.." (Use '/aura options <searchtext>' to filter.)")
                else
                    AuraPrint("[aura] Currently known options matching '"..val.."': "..optString)
                end
            else
                AuraPrint("[aura] No options have been modified from defaults.")
            end
            return
        end
		
		if( not val or val == "" ) then
			AuraPrint( "[aura] '" .. opt .. "' has " .. pformat( AuraAddon.Get( opt ) ) .. "'" )
		else
			local oldSetting = AuraAddon.Get(opt)
            if type(oldSetting) == "number" then
                val = tonumber(val)
                if val then AuraAddon.Set(opt, val) end
            elseif type(oldSetting) == "boolean" then
                if val == "true" or val == "1" or val == "yes" or val == "on" then
                    AuraAddon.Set(opt, true)
                elseif val == "toggle" then
                    AuraAddon.Set(opt, not oldSetting)
                else
                    AuraAddon.Set(opt, false)
                end
            elseif type(oldSetting) == "wstring" then
                AuraAddon.Set(opt, towstring(val))
            elseif type(oldSetting) == "string" then
                AuraAddon.Set(opt, val)
            elseif type(oldSetting) == "table" then
                local tab = {}
                for word in val:gmatch("%w+") do
                    if tonumber(word) then
                        table.insert(tab, tonumber(word))
                    else
                        table.insert(tab, word)
                    end
                end
                AuraAddon.Set(opt, tab)
            else
                -- if we can't figure out something else, then see if the input could be a number, if so set it that way
                -- otherwise, set it to just the string
                if tonumber(val) then
                    AuraAddon.Set(opt, tonumber(val))
                else
                    AuraAddon.Set(opt, val)
                end
            end
            
            AuraPrint( "[aura] '" ..opt.. "' set ".. pformat( AuraAddon.Get( opt ) ) )
		end
	else
		if( DoesWindowExist( AuraSettings.GetWindowName() ) ) then
			local showing = WindowGetShowing( AuraSettings.GetWindowName() )
			
			if( showing ) then
				-- We are hiding the window, so start the engine
				AuraEngine.Start()
			else
				-- We are displaying so stop the engine
				AuraEngine.Stop()
				
				-- Refresh the settings display
				AuraSettings.Refresh()
				AuraShares.Refresh()
			end
			
			WindowSetShowing( AuraSettings.GetWindowName(), not showing )
		end
	end
end

function AuraAddon.Get( key )
	if( AuraAddon.RuntimeSettings[key] ~= nil ) then
		return AuraAddon.RuntimeSettings[key]
	else
		if( AuraAddon.DefaultSettings[key] ~= nil ) then
			AuraAddon.RuntimeSettings[key] = AuraAddon.DefaultSettings[key]
			return AuraAddon.RuntimeSettings[key]
		else
			return nil
		end	
	end
end

function AuraAddon.Set(key, value)
	AuraAddon.RuntimeSettings[key] = value
end

function AuraAddon.GetDisplayVersion()
	return DisplayVersion
end	

function AuraAddon.GetVersion()
    return VERSION
end

function AuraDebug( str )
	if( AuraAddon.RuntimeConfiguration.Debug ) then
		d( towstring( str ) )
	end
end

function AuraPrint( str )
	EA_ChatWindow.Print( towstring( str ) )
end
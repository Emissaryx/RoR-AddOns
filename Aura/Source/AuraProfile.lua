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

AuraProfile = {}

AuraProfile.PROFILE_TYPE_DEFAULT		= 1
AuraProfile.PROFILE_TYPE_CHARACTER		= 2
AuraProfile.PROFILE_TYPE_SERVER			= 3
AuraProfile.PROFILE_TYPE_CLASS			= 4

function AuraProfile.LoadCharacterSettings( addonSettings, defaultSettings, profileType )

	-- If we didnt receive any default settings, return nil
	if( defaultSettings == nil ) then return nil end
	
	-- If we didnt receive a valid profile type, return nil
	if( profileType ~= AuraProfile.PROFILE_TYPE_DEFAULT and
		profileType ~= AuraProfile.PROFILE_TYPE_CHARACTER and
		profileType ~= AuraProfile.PROFILE_TYPE_SERVER and
		profileType ~= AuraProfile.PROFILE_TYPE_CLASS ) then return nil end
	
	-- If we didnt receive any addon settings, create the base structure
	if( addonSettings == nil ) 				then addonSettings 				= {} end
	if( addonSettings.Default == nil ) 		then addonSettings.Default		= {} end
	if( addonSettings.Characters == nil ) 	then addonSettings.Characters	= {} end
	if( addonSettings.Servers == nil ) 		then addonSettings.Servers		= {} end
	if( addonSettings.Classes == nil ) 		then addonSettings.Classes		= {} end
	
	-- Retrieve the settings based upon the requested type
	if( profileType == AuraProfile.PROFILE_TYPE_SERVER ) then
		local serverName = AuraProfile.cleanString( WStringToString( SystemData.Server.Name ) )
		
		-- Check to see if the server exists
		if( addonSettings.Servers[serverName] == nil ) then
		
			-- Set the server to the passed in default settings
			addonSettings.Servers[serverName] = defaultSettings
		end
		
		-- Return the new settings
		return addonSettings, addonSettings.Servers[serverName]
		
	elseif( profileType == AuraProfile.PROFILE_TYPE_CLASS ) then
		local careerName = AuraProfile.cleanString( WStringToString( GameData.Player.career.name ) )
		
		-- Check to see if the class exists
		if( addonSettings.Classes[careerName] == nil ) then
		
			-- Set the class to the passed in default settings
			addonSettings.Classes[careerName] = defaultSettings
		end
		
		-- Return the new settings
		return addonSettings, addonSettings.Classes[careerName]
		
	elseif( profileType == AuraProfile.PROFILE_TYPE_CHARACTER ) then
		local key = AuraProfile.GetCurrentCharacter()
		
		-- Check to see if the class exists
		if( addonSettings.Characters[key] == nil ) then
		
			-- Set the class to the passed in default settings
			addonSettings.Characters[key] = defaultSettings
		end
		
		-- Return the new settings
		return addonSettings, addonSettings.Characters[key]
	elseif( profileType == AuraProfile.PROFILE_TYPE_DEFAULT ) then
		return addonSettings, addonSettings.Default
	end
end

function AuraProfile.SaveCharacterSettings( addonSettings, saveSettings, profileType )
	-- If we didnt receive any save settings, return false
	if( saveSettings == nil ) then return nil end
	
	-- If we didnt receive a valid profile type, return nil
	if( profileType ~= AuraProfile.PROFILE_TYPE_DEFAULT and
		profileType ~= AuraProfile.PROFILE_TYPE_CHARACTER and
		profileType ~= AuraProfile.PROFILE_TYPE_SERVER and
		profileType ~= AuraProfile.PROFILE_TYPE_CLASS ) then return nil end
	
	-- If we didnt receive any addon settings, create the base structure
	if( addonSettings == nil ) 				then addonSettings 				= {} end
	if( addonSettings.Default == nil ) 		then addonSettings.Default		= {} end
	if( addonSettings.Characters == nil ) 	then addonSettings.Characters	= {} end
	if( addonSettings.Servers == nil ) 		then addonSettings.Servers		= {} end
	if( addonSettings.Classes == nil ) 		then addonSettings.Classes		= {} end
		
	-- Retrieve the settings based upon the requested type
	if( profileType == AuraProfile.PROFILE_TYPE_SERVER ) then
		local serverName = AuraProfile.cleanString( WStringToString( SystemData.Server.Name ) )
		
		-- Update the settings
		addonSettings.Servers[serverName] = saveSettings
		
		return addonSettings
	elseif( profileType == AuraProfile.PROFILE_TYPE_CLASS ) then
		local careerName = AuraProfile.cleanString( WStringToString( GameData.Player.career.name ) )
		
		-- Update the settings
		addonSettings.Classes[careerName] = saveSettings
		
		return addonSettings
	elseif( profileType == AuraProfile.PROFILE_TYPE_CHARACTER ) then
		local key = AuraProfile.GetCurrentCharacter()
		
		-- Return the new settings
		addonSettings.Characters[key] = saveSettings
		return addonSettings
	elseif( profileType == AuraProfile.PROFILE_TYPE_DEFAULT ) then
		addonSettings.Default = saveSettings
		return addonSettings
	end
	
	return nil
end

function AuraProfile.GetProfileTypeList( addonSettings, profileType )
	local settings = {}
	local data
	
	if( profileType == AuraProfile.PROFILE_TYPE_SERVER ) then
		data = addonSettings.Servers
	elseif( profileType == AuraProfile.PROFILE_TYPE_CLASS ) then
		data = addonSettings.Classes
	elseif( profileType == AuraProfile.PROFILE_TYPE_CHARACTER ) then
		data = addonSettings.Characters
	elseif( profileType == AuraProfile.PROFILE_TYPE_DEFAULT ) then
		data = addonSettings.Default
	end

	if( profileType == AuraProfile.PROFILE_TYPE_DEFAULT ) then
		settings = addonSettings.Default
	else
		for k,v in pairs( data )
		do
			table.insert( settings, k )
		end
	end
	
	return settings
end

function AuraProfile.GetProfileData( addonSettings, profileType, profile )
	if( profileType == AuraProfile.PROFILE_TYPE_SERVER ) then
		return addonSettings.Servers[profile]
	elseif( profileType == AuraProfile.PROFILE_TYPE_CLASS ) then
		return addonSettings.Classes[profile]
	elseif( profileType == AuraProfile.PROFILE_TYPE_CHARACTER ) then
		return addonSettings.Characters[profile]
	elseif( profileType == AuraProfile.PROFILE_TYPE_DEFAULT ) then
		return addonSettings.Default
	end	
	
	return nil
end

function AuraProfile.GetCurrentCharacter()
	local playerName = AuraProfile.cleanString( WStringToString( GameData.Player.name ) )
	local serverName = AuraProfile.cleanString( WStringToString( SystemData.Server.Name ) )
	local ret = serverName .. "/" .. playerName
	return ret
end

function AuraProfile.cleanString( str )
	return string.match( str, "([^\^]+).*" )
end

--[[]
function AuraProfile.fif(condition, if_true, if_false)
  if condition then return if_true else return if_false end
end

function AuraProfile.CopyTable (source)
    --
    -- This function was pulled from DataUtils in the Mythic client.
    --
    -- So I do not have to create a dependency upon an addon for a single function
    --
	if (source == nil) 
    then
        d (L"AuraProfile.CopyTable (source): Source table was nil.")
        return nil
    end
    
    if (type (source) ~= "table") 
    then        
        d (L"AuraProfile.CopyTable (source): Source is not a table, it was a ="..towstring(type(source)))
        return nil
    end

    local newTable = {}

    for k, v in pairs (source) 
    do
        if (type (v) == "table")
        then
            newTable[k] = AuraProfile.CopyTable (v)
        else
            newTable[k] = v
        end
    end
    
    return newTable
end
--]]
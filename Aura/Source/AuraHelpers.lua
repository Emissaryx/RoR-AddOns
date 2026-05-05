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

if not AuraHelpers then AuraHelpers = {} end

function AuraHelpers.IsGroupActive()
	local gd = GetGroupData()
	if( gd[1] ~= nil and gd[1].name ~= nil and gd[1].name ~= L"" ) then	
		return true
	end 
	return false
end

function AuraHelpers.fif(condition, if_true, if_false)
  if condition then return if_true else return if_false end
end

--[[
	This function assists in the setting of an windows texture information
--]]
function AuraHelpers.SetDynamicImageTexture( window, texture, slice, dx, dy, r, g, b, a, rotation, mirror )
	
	if( DoesWindowExist( window ) ) then
		
		DynamicImageSetTexture( window, texture, dx, dy )	
		
		if( string.len( slice ) > 0 ) then
			DynamicImageSetTextureSlice( window, slice )
		end
		
		DynamicImageSetRotation( window, rotation )
		DynamicImageSetTextureOrientation( window, mirror )
		
		WindowSetTintColor( window, r, g, b )
		WindowSetAlpha( window, a )
		
		return true	
	end
	
	return false
end

function AuraHelpers.SetCircleImageTexture( window, texture, slice, dx, dy, r, g, b, a, rotation, mirror )
	
	if( DoesWindowExist( window ) ) then
		local winX, winY = WindowGetDimensions( window )
		
		CircleImageSetTexture( window, texture, dx + winX/2, dy + winY/2 )	
		
		if( string.len( slice ) > 0 ) then
			CircleImageSetTextureSlice( window, slice )
		end
		
		CircleImageSetRotation( window, rotation )
		
		-- Seems circle images do not have an orientation
		--CircleImageSetTextureOrientation( window, mirror )
		
		WindowSetTintColor( window, r, g, b )
		WindowSetAlpha( window, a )
		
		return true	
	end
	
	return false
end

function AuraHelpers.GetCareerResourceLimits( career )
	local min 		= 0
	local max		= 0
	local minDesc 	= L""
	local maxDesc 	= L"" 
	
	-- There are 2 specialty cases for careers:
		-- Archmage:  Ranges from 0 to 10, however, it gets converted to -5 to 5 client side
		-- Shaman:  See Archmage
	if( career == GameData.CareerLine.ARCHMAGE ) then
		min = -5
		minDesc = L"Tranquility"
		maxDesc = L"Force"
	elseif( career == GameData.CareerLine.SHAMAN ) then
		min = -5
		minDesc = L"Gork's"
		maxDesc = L"Mork's"
	end
	
	if( EA_CareerResourceData[career] ~= nil ) then
		max = EA_CareerResourceData[career].maxPool
	end
	
	return min, max, minDesc, maxDesc
end

function AuraHelpers.ConvertValueToSlider( value, min, max, round )
	local unit = 1 / ( max - min )
	return ( value - min ) * unit
end

function AuraHelpers.ConvertSliderToValue( value, min, max, round )
	local unit = 1 / ( max - min )
	return min + ( value / unit )
end

function AuraHelpers.round(n, precision)
  local m = 10^(precision or 0)
  return math.floor(m*n + 0.5)/m
end

function AuraHelpers.roundUp( n, idp )
	return AuraHelpers.round( n, idp ) + ( 1 /( 10 * idp ) )
end

function AuraHelpers.cleanString( str )
	return string.match( str, "([^\^]+).*" )
end

function AuraHelpers.cleanWString( wstr )
	return wstring.match( wstr, L"([^\^]+).*" )
end

--[[
	This function is a direct copy from DataUtils.lua in the Mythic Default UI
	with changes to only reflect its new name
--]]
function AuraHelpers.CopyTable( source )
	 if (source == nil) 
    then
        d (L"AuraHelpers.CopyTable (source): Source table was nil.")
        return nil
    end
    
    if (type (source) ~= "table") 
    then  
		local value
		value = source      
        return value
    end

    local newTable = {}

    for k, v in pairs (source) 
    do
        if (type (v) == "table")
        then
            newTable[k] = AuraHelpers.CopyTable (v)
        else
            newTable[k] = v
        end
    end
    
    return newTable
end

--[[
	This function takes one of the aura combo tables and returns a new table sorted by name,
	keyed by the combo insertion
--]]
local function comboNameComparator( a, b ) return( WStringsCompare( a.Name, b.Name ) == -1 ) end

function AuraHelpers.CreateComboDisplay( data )
	local copy = AuraHelpers.CopyTable( data )
	
	-- Mark the index in the table
	for k,v in ipairs( copy )
	do
		copy[k]["Index"] = k
	end
	
	table.sort( copy, comboNameComparator )
	
	return copy
end


-- Lua gmatch implementation from:
-- http://code.google.com/p/kahlua/
function AuraHelpers.gmatch( str, pattern )
    local init = 1
    local function gmatch_it()
        if init <= str:len() then 
            local s, e = str:find(pattern, init)
            if s then
                local res = {str:match(pattern, init)}
                init = e+1
                return unpack(res)
            end
        end
    end
    return gmatch_it
end
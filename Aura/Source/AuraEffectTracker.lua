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

local pairs						= pairs
local ipairs					= ipairs
local tonumber					= tonumber
local tinsert					= table.insert
local tsort						= table.sort

local function IsValidEffect( effectData )
    return ( effectData ~= nil and effectData.effectIndex ~= nil )
end

local function CopyTable( source )
	local newTable = {}
	for k, v in pairs (source) 
    do
        if( type (v) == "table" ) then
            newTable[k] = CopyTable (v)
        else
            newTable[k] = v
        end
    end
    return newTable
end

AuraEffectTracker = {}
AuraEffectTracker.__index = AuraEffectTracker

function AuraEffectTracker:Create( effectTargetType )
	local tracker = {
		m_effectData      		= {},
		m_effectTargetType		= effectTargetType,
    }
	
	tracker = setmetatable( tracker, self )
    tracker.__index = self
    
    return tracker
end

function AuraEffectTracker:ClearEffects()
	self:UpdateEffects( {}, true )
end

function AuraEffectTracker:GetEffects()
	return self.m_effectData
end

function AuraEffectTracker:RefreshEffects()
    self:UpdateEffects( GetBuffs( self.m_effectTargetType ), true )
end

function AuraEffectTracker:Update( elapsedTime )
	for effectId, effect in pairs( self.m_effectData )
    do
        if( IsValidEffect( effect ) ) then
            if( effect.duration >= elapsedTime ) then
                effect.duration = effect.duration - elapsedTime
            else
                effect.duration = 0
            end
        end
    end
end

function AuraEffectTracker:UpdateEffects( effects, isFullList )
	if( effects == nil ) then return end
	
	if( isFullList ) then 
		for k,_ in pairs( self.m_effectData )
		do
			self.m_effectData[k] = nil
		end
	end

	for effectId, effect in pairs( effects )
    do
        if( IsValidEffect( effect ) ) then
        	self.m_effectData[effectId] = CopyTable( effect )
        else
            self.m_effectData[effectId] = nil
        end
    end
end
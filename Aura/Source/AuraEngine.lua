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

if not AuraEngine then AuraEngine = {} end

local engineRunning				= false

local c_HOSTILE_TARGET          = "selfhostiletarget"
local c_FRIENDLY_TARGET         = "selffriendlytarget"
local c_MOUSEOVER_TARGET        = "mouseovertarget"

--
-- These members assist with event throttling
--
local _Event_PLAYER_MORALE_UPDATED_PreviousLevel 			= -1

local _Event_UPDATE_PROCESSED_RefreshTime					= 0
local _Event_UPDATE_PROCESSED_NextRefreshTime				= 0

local _Event_UPDATE_PROCESSED_updateAuras					= {}

local bInGroup												= false
local bInWarParty											= false

local effectTrackers										= {}

local lastHostileTargetId									= -1
local lastFriendlyTargetId									= -1

local tinsert = table.insert

--
-- These are used by the effects handler to know which effects are
-- currently processing
--
local Events = {}
Events[SystemData.Events.BATTLEGROUP_UPDATED] 						= { Auras = {}, func = "AuraEngine.Event_BATTLEGROUP_UPDATED" }
Events[SystemData.Events.GROUP_UPDATED] 							= { Auras = {}, func = "AuraEngine.Event_GROUP_UPDATED" }
Events[SystemData.Events.LOADING_END] 								= { Auras = {}, func = "AuraEngine.Event_LOADING_END" }
Events[SystemData.Events.PLAYER_ACTIVE_TACTICS_UPDATED] 			= { Auras = {}, func = "AuraEngine.Event_PLAYER_ACTIVE_TACTICS_UPDATED" }
Events[SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED] 			= { Auras = {}, func = "AuraEngine.Event_PLAYER_CAREER_RESOURCE_UPDATED" }
Events[SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED] 			= { Auras = {}, func = "AuraEngine.Event_PLAYER_CUR_ACTION_POINTS_UPDATED" }
Events[SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED] 			= { Auras = {}, func = "AuraEngine.Event_PLAYER_CUR_HIT_POINTS_UPDATED" }
Events[SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED] 				= { Auras = {}, func = "AuraEngine.Event_PLAYER_COMBAT_FLAG_UPDATED" }
Events[SystemData.Events.PLAYER_EFFECTS_UPDATED] 					= { Auras = {}, func = "AuraEngine.Event_PLAYER_EFFECTS_UPDATED" }
Events[SystemData.Events.PLAYER_MORALE_UPDATED]						= { Auras = {}, func = "AuraEngine.Event_PLAYER_MORALE_UPDATED" }
Events[SystemData.Events.PLAYER_RVR_FLAG_UPDATED] 					= { Auras = {}, func = "AuraEngine.Event_PLAYER_RVR_FLAG_UPDATED" }
Events[SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED] 			= { Auras = {}, func = "AuraEngine.Event_PLAYER_TARGET_EFFECTS_UPDATED" }
Events[SystemData.Events.PLAYER_TARGET_UPDATED] 					= { Auras = {}, func = "AuraEngine.Event_PLAYER_TARGET_UPDATED" }
Events[SystemData.Events.PLAYER_PET_UPDATED] 					= { Auras = {}, func = "AuraEngine.Event_PLAYER_PET_UPDATED" }

-- This set does not have a handling function, as we sub to this event in the .mod file
Events[SystemData.Events.UPDATE_PROCESSED]							= { Auras = {}, func = nil }

-- We use this ability internally to help assist ability triggers
Events[SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED] 			= { Auras = {}, func = "AuraEngine.Event_PLAYER_SINGLE_ABILITY_UPDATED" }

-- This table holds the auras that wish to receive cooldown timer notifications
local Event_AbilityType_AbilityAuras 	= {}
local Event_AbilityType_MoraleAuras 	= {}

local function rev_iter(t, key)
  if (key <= 1) then
    return nil
  else
    local nkey = key - 1
    return nkey, t[nkey]
  end
end

local function ripairs(t)
  return rev_iter, t, (1 + table.getn(t))
end

local function errorchecker(success, ...)
	if not success then
        d(...)
        return nil
    else
        return ...
    end
end
 
local function safecall(func, ...)
	if type(func) == "function" then
		return errorchecker(pcall(func, ...))
	end
end

function AuraEngine.Start()
	if( AuraAddon.RuntimeConfiguration.Enabled and not AuraEngine.IsRunning() ) then
		
		AuraDebug( "Starting Aura Engine..." )
		
		-- Flag we are running
		engineRunning = true
		AuraDebug( "Engine Running..." )
		-- Initialize the internal members of each aura
		AuraAddon.CleanInternalMembers()
    AuraDebug( "clean internal members..." )
		
		-- Generate our internal sets from the enabled auras
		AuraEngine.GenerateEventAuraSets()
    AuraDebug( "generate event aura sets..." )
		
		-- Register our event handlers
		AuraEngine.RegisterEventHandlers()
    AuraDebug( "register event handlers..." )
		
		-- Jump start our event based auras
		AuraEngine.JumpStartEventBasedAuras()	
	end
end

function AuraEngine.Stop()
	if( AuraEngine.IsRunning() ) then
		
		AuraDebug( "Stopping Aura Engine..." )
		
		-- Unregister our event handlers
		AuraEngine.UnregisterEventHandlers()
		
		-- Clean our internal members
		AuraAddon.CleanInternalMembers()
		
		-- Flag we are not longer running
		engineRunning = false
	end
end

function AuraEngine.RestartEngine()
	-- Only restart if we are running
	if( AuraEngine.IsRunning() ) then
		-- Stop the engine
		AuraEngine.Stop()
	end
	
	-- Restart the engine
	AuraEngine.Start()
end

function AuraEngine.IsRunning()
	return engineRunning
end

function AuraEngine.GenerateEventAuraSets()
	AuraDebug( "Generating Event Aura Sets")
	
	-- Clear the events aura lists
	for index, event in pairs( Events )
	do
		event.Auras = {}
	end
	
	Event_AbilityType_AbilityAuras 	= {}
	Event_AbilityType_MoraleAuras 	= {}
	
	-- Set these to their inverse so they will process immediately at startup
	bInWarParty = not IsWarBandActive()
	bInGroup = not AuraHelpers.IsGroupActive()
	
	for index, aura in ipairs( AuraAddon.RuntimeAuras )
	do
		-- Mark the aura as deactivated
		aura:Deactivate( true )
		
		-- We only want our active auras our handlers
		if( aura:IsEnabled() ) then
			AuraDebug( "Processing Aura: " .. tostring( aura ) )
			
			-- Have the aura prepare for runtime
			aura:PrepareForRuntime()
			
			-- Handle our activation type subscriptions
			if( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_ABILITY ) then
			
				local abilityData = Player.GetAbilityData( aura:Get( "ability-abilityid" ) )
				
				-- Only process if we received ability information. 
				if( abilityData ~= nil ) then
					if( abilityData.abilityType == Player.AbilityType.ABILITY ) then
						AuraEngine.RegisterAbilityTimerAura( aura )
					elseif( abilityData.abilityType == Player.AbilityType.MORALE ) then
						AuraEngine.RegisterMoraleTimerAura( aura )
					elseif( abilityData.abilityType == Player.AbilityType.TACTIC ) then
						tinsert( Events[SystemData.Events.PLAYER_ACTIVE_TACTICS_UPDATED].Auras, aura )
					end
				else
					-- We were not able to retrieve the data we need to classify the ability, so add is here
					-- and once we receive the data we can process it accordingly
					AuraDebug( "Ability data not retrieved, adding ability to single update queue[" .. tostring( aura ) .. "]" )
					tinsert( Events[SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED].Auras, aura )
				end
			elseif( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_ACTIONPOINTS ) then
				tinsert( Events[SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED].Auras, aura )
			elseif( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_CAREER ) then
				-- Register for the career resource 
				tinsert( Events[SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED].Auras, aura )
			elseif( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_PET ) then
				--register pet
				tinsert( Events[SystemData.Events.PLAYER_PET_UPDATED].Auras, aura )
			elseif( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_EFFECTS ) then
				local effectsRegistered = false
				local effectNames = {}
				local effectIds	= {}
					
				-- Escape any single quotes
				local _auraEffectName, _ = aura:Get( "effect-name" ) 
				
				if( _auraEffectName:len() > 0 ) then
				
					-- Escape any single quotes/dashes quotes
					_auraEffectName = _auraEffectName : gsub( L"'", L"\'" ) : gsub( L"-", L"\-" )
					
					-- Break effect names into parts
					for word in AuraHelpers.gmatch( _auraEffectName, L"[^/]+" )
					do
						local num = tonumber( word )
						if( num ~= nil and num > 0 ) then
							tinsert( effectIds, num )	
						else
							tinsert( effectNames, word ) 
						end
					end
				end
				
				-- Set the list of effect names/ids
				aura:Set( "internal-effect-names", effectNames )
				aura:Set( "internal-effect-ids", effectIds )
				
				-- Handle an effect on our self
				if( aura:Get( "effect-self" ) ) then
					if( effectTrackers[GameData.BuffTargetType.SELF] == nil ) then
						effectTrackers[GameData.BuffTargetType.SELF] = AuraEffectTracker:Create( GameData.BuffTargetType.SELF )
						effectTrackers[GameData.BuffTargetType.SELF]:RefreshEffects()
					end
				
					tinsert( Events[SystemData.Events.PLAYER_EFFECTS_UPDATED].Auras, aura )
					tinsert( Events[SystemData.Events.LOADING_END].Auras, aura )

					effectsRegistered = true
				end	
				
				-- Handle an effect on a friendly/enemy target
				if( aura:Get( "effect-friendly" ) or aura:Get( "effect-enemy" ) ) then
				    tinsert( Events[SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED].Auras, aura )
					tinsert( Events[SystemData.Events.PLAYER_TARGET_UPDATED].Auras, aura )
					
				    if( aura:Get( "effect-friendly" ) ) then
				    	if( effectTrackers[GameData.BuffTargetType.TARGET_FRIENDLY] == nil ) then
							effectTrackers[GameData.BuffTargetType.TARGET_FRIENDLY] = AuraEffectTracker:Create( GameData.BuffTargetType.TARGET_FRIENDLY )
						end
				    end
				    
				    if( aura:Get( "effect-enemy" ) ) then
				    	if( effectTrackers[GameData.BuffTargetType.TARGET_HOSTILE] == nil ) then
							effectTrackers[GameData.BuffTargetType.TARGET_HOSTILE] = AuraEffectTracker:Create( GameData.BuffTargetType.TARGET_HOSTILE )
						end
				    end
				    
                    effectsRegistered = true
				end	
				
				-- If this effects aura has a timer, subscribe to UPDATE_PROCESSED
				if( effectsRegistered and aura:HasTimer() ) then
					tinsert( Events[SystemData.Events.UPDATE_PROCESSED].Auras, aura )
				end
			elseif( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_HITPOINTS ) then
				if( aura:Get( "hitpoints-type" ) == 1 ) then
					tinsert( Events[SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED].Auras, aura )
				else
					tinsert( Events[SystemData.Events.PLAYER_TARGET_UPDATED].Auras, aura )
				end
			elseif( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_MORALE ) then
				tinsert( Events[SystemData.Events.PLAYER_MORALE_UPDATED].Auras, aura )
			else
				AuraDebug( "Received TriggerType not handled in: AuraEngine.GenerateEventAuraSets [" .. tostring( aura:Get( "general-triggertype" ) ) .. "]" )
			end
			
			-- Handle our trigger status subscriptions
			if( aura:Get( "trigger-onlyincombat" ) or aura:Get( "trigger-onlyoutofcombat" ) ) then
				tinsert( Events[SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED].Auras, aura )
			end
			
			if( aura:Get( "trigger-rvrflagged" ) or aura:Get( "trigger-notrvrflagged" ) ) then
				tinsert( Events[SystemData.Events.PLAYER_RVR_FLAG_UPDATED].Auras, aura )
			end
			
			if( aura:Get( "trigger-onlyingroup" ) ) then
				tinsert( Events[SystemData.Events.GROUP_UPDATED].Auras, aura )
			end
			
			if( aura:Get( "trigger-onlyinwarparty" ) ) then
				tinsert( Events[SystemData.Events.BATTLEGROUP_UPDATED].Auras, aura )
			end
		end
	end
end

function AuraEngine.JumpStartEventBasedAuras()
	AuraDebug( "Jumpstarting event based auras")
	
	-- Set these to their inverse so they will process immediately at startup
	bInWarParty = not IsWarBandActive()
	bInGroup = not AuraHelpers.IsGroupActive()
	
	for index, aura in ipairs( AuraAddon.RuntimeAuras )
	do
		-- We only want our active auras our handlers
		if( aura:IsEnabled() ) then
			AuraDebug( "Processing Aura: " .. tostring( aura ) )
			
			-- Handle our activation type subscriptions
			if( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_ABILITY ) then
			
				local abilityData = Player.GetAbilityData( aura:Get( "ability-abilityid" ) )
				
				-- Only process if we received ability information. 
				if( abilityData ~= nil ) then
					if( abilityData.abilityType == Player.AbilityType.ABILITY ) then
						AuraEngine.HandleTriggerType_Ability( aura, 0, 0, false )
					elseif( abilityData.abilityType == Player.AbilityType.MORALE ) then
						AuraEngine.HandleTriggerType_Ability( aura, 0, 0, true )
					elseif( abilityData.abilityType == Player.AbilityType.TACTIC ) then
						AuraEngine.HandleTriggerType_Ability_Tactic( aura:Get( "ability-abilityid" ), aura )
					end
				end
			elseif( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_ACTIONPOINTS ) then
				AuraEngine.HandleTriggerType_ActionPoints( aura )
			elseif( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_CAREER ) then
				AuraEngine.HandleTriggerType_Career( GetCareerResource( GameData.BuffTargetType.SELF ), aura )
			elseif( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_EFFECTS ) then
				-- Handle an effect on our self
				if( aura:Get( "effect-self" ) ) then
					effectTrackers[GameData.BuffTargetType.SELF]:RefreshEffects()
					AuraEngine.HandleTriggerType_Effect( aura, GameData.BuffTargetType.SELF, GetBuffs( GameData.BuffTargetType.SELF ), true )
				end	
				
				-- Handle an effect on a friendly/enemy target
				if( aura:Get( "effect-friendly" ) or aura:Get( "effect-enemy" ) ) then
				    if( aura:Get( "effect-friendly" ) ) then
				    	effectTrackers[GameData.BuffTargetType.TARGET_FRIENDLY]:RefreshEffects()
				        AuraEngine.HandleTriggerType_Effect( aura, GameData.BuffTargetType.TARGET_FRIENDLY, effectTrackers[GameData.BuffTargetType.TARGET_FRIENDLY]:GetEffects(), true )
				    end
				    
				    if( aura:Get( "effect-enemy" ) ) then
				    	effectTrackers[GameData.BuffTargetType.TARGET_HOSTILE]:RefreshEffects()
				        AuraEngine.HandleTriggerType_Effect( aura, GameData.BuffTargetType.TARGET_HOSTILE, effectTrackers[GameData.BuffTargetType.TARGET_HOSTILE]:GetEffects(), true )
				    end
				end	
			elseif( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_HITPOINTS ) then
				AuraEngine.HandleTriggerType_HitPoints( aura )
			elseif( aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_MORALE ) then
				AuraEngine.HandleTriggerType_Morale( GetPlayerMoraleLevel(), aura )
			elseif(aura:Get( "general-triggertype" ) == AuraConstants.TRIGGER_TYPE_PET ) then
				AuraEngine.HandleTriggerType_PetStatus( aura )
			else
				AuraDebug( "Received TriggerType not handled in: AuraEngine.JumpStartEventBasedAuras [" .. tostring( aura:Get( "general-triggertype" ) ) .. "]" )
			end
		end
	end
	
	-- Fire off our one of handlers
	safecall( Events[SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED].func )
	safecall( Events[SystemData.Events.PLAYER_RVR_FLAG_UPDATED].func )
	safecall( Events[SystemData.Events.GROUP_UPDATED].func )
	safecall( Events[SystemData.Events.BATTLEGROUP_UPDATED].func )
end

function AuraEngine.RegisterEventHandlers()
	AuraDebug( "Registering Event Handlers" )
	for index, event in pairs( Events )
	do
		-- The event has to have atleast one aura to be registered
		if( #event.Auras > 0 ) then
			if( event.func ~= nil ) then
				AuraDebug( "Registering: " .. event.func )
				RegisterEventHandler( index, event.func )
			end	
		end
	end
end

function AuraEngine.UnregisterEventHandlers()
	AuraDebug( "Unregistering Event Handlers" )
	for index, event in pairs( Events )
	do
		if( #event.Auras > 0 ) then
			if( event.func ~= nil ) then
				AuraDebug( "Unregstering: " .. event.func )
				UnregisterEventHandler( index, event.func )
			end	
		end
	end
	
	Event_AbilityType_AbilityAuras = {}
	Event_AbilityType_MoraleAuras = {}
end

function AuraEngine.Event_BATTLEGROUP_UPDATED()
	AuraDebug( "Event_BATTLEGROUP_UPDATED" )
	
	-- Only process if our status changed
	if( IsWarBandActive() ~= bInWarParty ) then
		bInWarParty = IsWarBandActive()
		
		for index, aura in ipairs( Events[SystemData.Events.BATTLEGROUP_UPDATED].Auras )
		do
			local triggerType = aura:Get( "general-triggertype" )
			
			if( triggerType == AuraConstants.TRIGGER_TYPE_ABILITY ) then
				--
				-- Due to how abilities are handled, this call no longer needs to happen
				--
			elseif( triggerType == AuraConstants.TRIGGER_TYPE_ACTIONPOINTS ) then
				AuraEngine.HandleTriggerType_ActionPoints( aura )
			elseif( triggerType == AuraConstants.TRIGGER_TYPE_CAREER ) then		
				AuraEngine.HandleTriggerType_Career( GetCareerResource( GameData.BuffTargetType.SELF ) , aura )
			elseif( triggerType == AuraConstants.TRIGGER_TYPE_EFFECTS ) then
				AuraEngine.HandleTriggerType_Effect( aura )
			elseif( triggerType == AuraConstants.TRIGGER_TYPE_HITPOINTS ) then		
				AuraEngine.HandleTriggerType_HitPoints( aura )
			elseif( triggerType == AuraConstants.TRIGGER_TYPE_MORALE ) then
				AuraEngine.HandleTriggerType_Morale( GetPlayerMoraleLevel(), aura )
      elseif( triggerType == AuraConstants.TRIGGER_TYPE_PET ) then
        AuraEngine.HandleTriggerType_PetStatus( aura )
			else
				AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_BATTLEGROUP_UPDATED" )
			end
		end
	end
end

function AuraEngine.Event_GROUP_UPDATED()
	AuraDebug( "Event_GROUP_UPDATED" )
	
	-- Only process if our status changed
	if(	AuraHelpers.IsGroupActive() ~= bInGroup ) then
		bInGroup = AuraHelpers.IsGroupActive()
		for index, aura in ipairs( Events[SystemData.Events.GROUP_UPDATED].Auras )
		do
			local triggerType = aura:Get( "general-triggertype" )
			
			if( triggerType == AuraConstants.TRIGGER_TYPE_ABILITY ) then
				--
				-- Due to how abilities are handled, this call no longer needs to happen
				--
			elseif( triggerType == AuraConstants.TRIGGER_TYPE_ACTIONPOINTS ) then
				AuraEngine.HandleTriggerType_ActionPoints( aura )
			elseif( triggerType == AuraConstants.TRIGGER_TYPE_CAREER ) then		
				AuraEngine.HandleTriggerType_Career( GetCareerResource( GameData.BuffTargetType.SELF ) , aura )
			elseif( triggerType == AuraConstants.TRIGGER_TYPE_EFFECTS ) then
				AuraEngine.HandleTriggerType_Effect( aura )
			elseif( triggerType == AuraConstants.TRIGGER_TYPE_HITPOINTS ) then		
				AuraEngine.HandleTriggerType_HitPoints( aura )
			elseif( triggerType == AuraConstants.TRIGGER_TYPE_MORALE ) then
				AuraEngine.HandleTriggerType_Morale( GetPlayerMoraleLevel(), aura )
      elseif( triggerType == AuraConstants.TRIGGER_TYPE_PET ) then
        AuraEngine.HandleTriggerType_PetStatus( aura )
			else
				AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_GROUP_UPDATED" )
			end
		end
	end
end

function AuraEngine.Event_LOADING_END()
	if( effectTrackers[GameData.BuffTargetType.SELF] ~= nil ) then
		
		-- Refresh our effects after loading
		effectTrackers[GameData.BuffTargetType.SELF]:RefreshEffects()
		
		for index, aura in ipairs( Events[SystemData.Events.LOADING_END].Auras )
		do
		   local triggerType = aura:Get( "general-triggertype" )
				
		   if( triggerType == AuraConstants.TRIGGER_TYPE_EFFECTS ) then
		   		if( aura:Get( "effect-self" ) ) then
		   			AuraEngine.HandleTriggerType_Effect( aura, GameData.BuffTargetType.SELF, effectTrackers[GameData.BuffTargetType.SELF]:GetEffects(), true )
		   		end
			else
				AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_PLAYER_EFFECTS_UPDATED" )
			end
		end
	end
end

function AuraEngine.Event_PLAYER_ACTIVE_TACTICS_UPDATED()
	for index, aura in ipairs( Events[SystemData.Events.PLAYER_ACTIVE_TACTICS_UPDATED].Auras )
	do
		local triggerType = aura:Get( "general-triggertype" )
		
		if( triggerType == AuraConstants.TRIGGER_TYPE_ABILITY ) then
			AuraEngine.HandleTriggerType_Ability_Tactic( aura:Get( "ability-abilityid" ), aura )
		else
			AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_PLAYER_ACTIVE_TACTICS_UPDATED")
		end
	end
end

function AuraEngine.Event_PLAYER_CAREER_RESOURCE_UPDATED( previous, current )
	for index, aura in ipairs( Events[SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED].Auras )
	do
		local triggerType = aura:Get( "general-triggertype" )
		
		if( triggerType == AuraConstants.TRIGGER_TYPE_CAREER ) then
			AuraEngine.HandleTriggerType_Career( current, aura )
		else
			AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_PLAYER_CAREER_RESOURCE_UPDATED")
		end
	end
end

function AuraEngine.Event_PLAYER_CUR_ACTION_POINTS_UPDATED()
	for index, aura in ipairs( Events[SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED].Auras )
	do
		local triggerType = aura:Get( "general-triggertype" )
		
		if( triggerType == AuraConstants.TRIGGER_TYPE_ACTIONPOINTS ) then
			AuraEngine.HandleTriggerType_ActionPoints( aura )
		else
			AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_PLAYER_CUR_ACTION_POINTS_UPDATED" )
		end
	end
end

function AuraEngine.Event_PLAYER_CUR_HIT_POINTS_UPDATED( curHitPoints )
	for index, aura in ipairs( Events[SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED].Auras )
	do
		local triggerType = aura:Get( "general-triggertype" )
		
		if( triggerType == AuraConstants.TRIGGER_TYPE_HITPOINTS ) then
			AuraEngine.HandleTriggerType_HitPoints( aura )
		else
			AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_PLAYER_CUR_HIT_POINTS_UPDATED" )
		end
	end
end

function AuraEngine.Event_PLAYER_COMBAT_FLAG_UPDATED()
	for index, aura in ipairs( Events[SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED].Auras )
	do
		local triggerType = aura:Get( "general-triggertype" )
		
		if( triggerType == AuraConstants.TRIGGER_TYPE_ABILITY ) then
			--
			-- Due to how abilities are handled, this call no longer needs to happen
			--
		elseif( triggerType == AuraConstants.TRIGGER_TYPE_ACTIONPOINTS ) then
			AuraEngine.HandleTriggerType_ActionPoints( aura )
		elseif( triggerType == AuraConstants.TRIGGER_TYPE_CAREER ) then		
			AuraEngine.HandleTriggerType_Career( GetCareerResource( GameData.BuffTargetType.SELF ) , aura )
		elseif( triggerType == AuraConstants.TRIGGER_TYPE_EFFECTS ) then
			AuraEngine.HandleTriggerType_Effect( aura )
		elseif( triggerType == AuraConstants.TRIGGER_TYPE_HITPOINTS ) then		
			AuraEngine.HandleTriggerType_HitPoints( aura )
		elseif( triggerType == AuraConstants.TRIGGER_TYPE_MORALE ) then
			AuraEngine.HandleTriggerType_Morale( GetPlayerMoraleLevel(), aura )
		else
			AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_PLAYER_COMBAT_FLAG_UPDATED" )
		end
	end
end

function AuraEngine.Event_PLAYER_EFFECTS_UPDATED( changedEffects, isFullList )
	AuraDebug( "Event_PLAYER_EFFECTS_UPDATED" )
	
	if( changedEffects == nil ) then return end
	
	effectTrackers[GameData.BuffTargetType.SELF]:UpdateEffects( changedEffects, isFullList )
	
	for index, aura in ipairs( Events[SystemData.Events.PLAYER_EFFECTS_UPDATED].Auras )
	do
	   local triggerType = aura:Get( "general-triggertype" )
			
	   if( triggerType == AuraConstants.TRIGGER_TYPE_EFFECTS ) then
	   		AuraEngine.HandleTriggerType_Effect( aura, GameData.BuffTargetType.SELF, changedEffects, isFullList )
		else
			AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_PLAYER_EFFECTS_UPDATED" )
		end
	end
end

function AuraEngine.Event_PLAYER_MORALE_UPDATED( moralePercent, moraleLevel )
	if( _Event_PLAYER_MORALE_UPDATED_PreviousLevel ~= moraleLevel ) then
		_Event_PLAYER_MORALE_UPDATED_PreviousLevel = moraleLevel
		for index, aura in ipairs( Events[SystemData.Events.PLAYER_MORALE_UPDATED].Auras )
		do
			local triggerType = aura:Get( "general-triggertype" )
			
			if( triggerType == AuraConstants.TRIGGER_TYPE_MORALE ) then
				AuraEngine.HandleTriggerType_Morale( moraleLevel, aura )
			else
				AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_PLAYER_MORALE_UPDATED" )
			end
		end
	end
end

function AuraEngine.Event_PLAYER_RVR_FLAG_UPDATED()
	for index, aura in ipairs( Events[SystemData.Events.PLAYER_RVR_FLAG_UPDATED].Auras )
	do
		local triggerType = aura:Get( "general-triggertype" )
		
		if( triggerType == AuraConstants.TRIGGER_TYPE_ABILITY ) then
			--
			-- Due to how abilities are handled, this call no longer needs to happen
			--
		elseif( triggerType == AuraConstants.TRIGGER_TYPE_ACTIONPOINTS ) then
			AuraEngine.HandleTriggerType_ActionPoints( aura )
		elseif( triggerType == AuraConstants.TRIGGER_TYPE_CAREER ) then		
			AuraEngine.HandleTriggerType_Career( GetCareerResource( GameData.BuffTargetType.SELF ) , aura )
		elseif( triggerType == AuraConstants.TRIGGER_TYPE_EFFECTS ) then
			AuraEngine.HandleTriggerType_Effect( aura )
		elseif( triggerType == AuraConstants.TRIGGER_TYPE_HITPOINTS ) then		
			AuraEngine.HandleTriggerType_HitPoints( aura )
		elseif( triggerType == AuraConstants.TRIGGER_TYPE_MORALE ) then
			AuraEngine.HandleTriggerType_Morale( GetPlayerMoraleLevel(), aura )
		else
			AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_PLAYER_RVR_FLAG_UPDATED" )
		end
	end
end

function AuraEngine.Event_PLAYER_PET_UPDATED()
  for index, aura in ipairs( Events[SystemData.Events.PLAYER_PET_UPDATED].Auras )
	do
    AuraEngine.HandleTriggerType_PetStatus(aura)
  end
end

function AuraEngine.Event_PLAYER_SINGLE_ABILITY_UPDATED( abilityId )
	-- Get the ability data
	local abilityData = Player.GetAbilityData( abilityId )
	
	for index, aura in ipairs( Events[SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED].Auras )
	do
		local triggerType = aura:Get( "general-triggertype" )
		
		-- Sanity check the auras type, and check to see if this aura is configured for this ability
		if( triggerType == AuraConstants.TRIGGER_TYPE_ABILITY and aura:Get( "ability-abilityid" ) == abilityId ) then
			-- Subscribe accordingly
			if( abilityData.abilityType == Player.AbilityType.ABILITY ) then
				AuraEngine.RegisterAbilityTimerAura( aura )
			elseif( abilityData.abilityType == Player.AbilityType.MORALE ) then
				AuraEngine.RegisterMoraleTimerAura( aura )
			elseif( abilityData.abilityType == Player.AbilityType.TACTIC ) then
				-- Get the starting number of tactics
				local numTactics = #Events[SystemData.Events.PLAYER_ACTIVE_TACTICS_UPDATED].Auras
				
				-- Add to its proper table
				tinsert( Events[SystemData.Events.PLAYER_ACTIVE_TACTICS_UPDATED].Auras, aura )
				
				-- Get the current tactics
				local currentTactics = #Events[SystemData.Events.PLAYER_ACTIVE_TACTICS_UPDATED].Auras
	
				-- Process the aura to see if there are any cases that are already fullfilled that
				-- we wont receive an update event on
				AuraEngine.HandleTriggerType_Ability_Tactic( aura:Get( "ability-abilityid" ), aura )
				
				-- If tactics has been added to, and not subscribed, we need to subscribe
				if( currentTactics > numTactics and numTactics == 0 ) then
					RegisterEventHandler( SystemData.Events.PLAYER_ACTIVE_TACTICS_UPDATED, Events[SystemData.Events.PLAYER_ACTIVE_TACTICS_UPDATED].func )
				end
			end	
		end
	end
end

function AuraEngine.Event_PLAYER_TARGET_EFFECTS_UPDATED( targetType, changedEffects, isFullList )
	AuraDebug( "Event_PLAYER_TARGET_EFFECTS_UPDATED" )
	
	if( changedEffects == nil ) then return end
	
	if( effectTrackers[targetType] ~= nil ) then
		effectTrackers[targetType]:UpdateEffects( changedEffects, isFullList )
	end
	
	for index, aura in ipairs( Events[SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED].Auras )
	do
		local triggerType = aura:Get( "general-triggertype" )
		
		if( triggerType == AuraConstants.TRIGGER_TYPE_EFFECTS ) then
			AuraEngine.HandleTriggerType_Effect( aura, targetType, changedEffects, isFullList )
        else
			AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_PLAYER_TARGET_EFFECTS_UPDATED" )
		end
	end
end

function AuraEngine.Event_PLAYER_TARGET_UPDATED( targetClassification, targetId, targetType )
	-- We do not want to handle mouse over targets
	if( targetClassification ~= c_MOUSEOVER_TARGET ) then
		AuraDebug( "Event_PLAYER_TARGET_UPDATED" )

		local processEffectsTrigger = false

		-- Assume this is a friendly target to start
		local effectTargetType 	= GameData.BuffTargetType.TARGET_FRIENDLY
		local lastTargetId		= lastFriendlyTargetId
		local isFriendly 		= true
		
		-- If this is a hostile target, prep the variables accordingly
		if( targetClassification == c_HOSTILE_TARGET ) then
			effectTargetType 	= GameData.BuffTargetType.TARGET_HOSTILE
			lastTargetId		= lastHostileTargetId
			isFriendly			= false
		end
		
		-- If we have a tracker for this type
		if( effectTrackers[effectTargetType] ~= nil ) then
			-- Process based upon having a no target, or a new target
			if( targetType == SystemData.TargetObjectType.NONE ) then
				effectTrackers[effectTargetType]:ClearEffects()
				processEffectsTrigger = true
			elseif( lastTargetId ~= targetId ) then
				effectTrackers[effectTargetType]:RefreshEffects()
				processEffectsTrigger = true
			end
		end	
		
		for index, aura in ipairs( Events[SystemData.Events.PLAYER_TARGET_UPDATED].Auras )
		do
			local triggerType = aura:Get( "general-triggertype" )
			
			if( triggerType == AuraConstants.TRIGGER_TYPE_EFFECTS ) then
				-- If we no longer have a target or our target has changed
				if( processEffectsTrigger ) then
					AuraEngine.HandleTriggerType_Effect( aura, effectTargetType, effectTrackers[effectTargetType]:GetEffects(), true )
				end
			elseif( triggerType == AuraConstants.TRIGGER_TYPE_HITPOINTS ) then
				AuraEngine.HandleTriggerType_HitPoints( aura )
			else
				AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_PLAYER_TARGET_UPDATED" )
			end
		end
		
		if( isFriendly ) then
			lastFriendlyTargetId = targetId
		else
			lastHostileTargetId = targetId
		end
	end
end

function AuraEngine.Event_UPDATE_PROCESSED( elapsedTime )
	if( not AuraEngine.IsRunning() ) then return end
	
	for k, v in pairs( effectTrackers )
	do
		v:Update( elapsedTime )
	end
	
	-- Update our refresh timers
	_Event_UPDATE_PROCESSED_RefreshTime	= _Event_UPDATE_PROCESSED_RefreshTime + elapsedTime
		
	-- Check our general updates
	if( _Event_UPDATE_PROCESSED_RefreshTime > _Event_UPDATE_PROCESSED_NextRefreshTime ) then
		for index, aura in ipairs( Events[SystemData.Events.UPDATE_PROCESSED].Auras )
		do
			if( aura:IsActivated() ) then
				-- Add the aura to our update table
				tinsert( _Event_UPDATE_PROCESSED_updateAuras, aura )
			end
		end
		_Event_UPDATE_PROCESSED_NextRefreshTime = _Event_UPDATE_PROCESSED_RefreshTime + AuraAddon.Get( "general-effect-timers" )
	end
	
	-- Process any auras that need updating
	for index, aura in ripairs( _Event_UPDATE_PROCESSED_updateAuras )
	do
		local triggerType = aura:Get( "general-triggertype" )
		
		if( triggerType == AuraConstants.TRIGGER_TYPE_EFFECTS ) then
			AuraEngine.HandleTriggerType_Effect_TimerUpdate( aura )
		else
			AuraDebug( "Received TriggerType not handled in: AuraEngine.Event_UPDATE_PROCESSED" )
		end

		-- Clear the index as we iterate		
		_Event_UPDATE_PROCESSED_updateAuras[index] = nil
	end
end

function AuraEngine.HandleTriggerType_Ability_Tactic( actionId, aura )
	-- If the action id received and the aura ability id are not the same, do nothing
	if( actionId == aura:Get( "ability-abilityid" ) ) then
		if( aura:TriggerStatusCheck() ) then
			local isEnabled = AuraEngine.IsAbilityEnabled( aura:Get( "ability-abilityid" ) )
			if( aura:Get( "ability-showwhennotactive" ) and isEnabled == false ) then aura:Activate() return end
			if( not aura:Get( "ability-showwhennotactive" ) and isEnabled == true ) then aura:Activate() return end
		end
		--	If we get here, deactivate the aura
		aura:Deactivate()
	end
end

function AuraEngine.HandleTriggerType_Ability( aura, cooldown, maxCooldown, requireEnabled )	
	if( aura:TriggerStatusCheck() ) then
		local validityCheck = true
		
		-- We want the aura to drop just before its available
		cooldown = cooldown - .3
		
		local isOnCooldown = cooldown > 0 and maxCooldown > 0
		
		if( aura:Get( "ability-showwhennotactive" ) and isOnCooldown ) then
			-- Check to see if this is a true cooldown or a GCD
			if( maxCooldown > AuraAddon.Get( "general-gcd" ) ) then
				aura:Activate()
				
				-- Set our timer after activating the aura
				if( aura:HasTimer() ) then 
					aura:UpdateTimerWindowTime( cooldown )
				end
				
				return
			end
		elseif( aura:Get( "ability-showwhennotactive" ) ) then
			-- Check the validity check bit
			if( aura:Get( "ability-requirevaliditycheck" ) ) then
				if( not IsTargetValid( aura:Get( "ability-abilityid" ) ) ) then
					aura:Activate()
					return
				end
			end
		elseif( not aura:Get( "ability-showwhennotactive" ) ) then
			if( maxCooldown <= AuraAddon.Get( "general-gcd" ) ) then
				-- Check the validity check bit
				if( aura:Get( "ability-requirevaliditycheck" )  ) then
					-- Perform the check
					validityCheck = IsTargetValid( aura:Get( "ability-abilityid" ) )
				end
			
				if( requireEnabled or aura:Get( "ability-requireexplicitactivecheck" ) ) then
					if( AuraEngine.IsAbilityEnabled( aura:Get( "ability-abilityid" ) ) and validityCheck ) then
						aura:Activate()
						return
					end
				else
					if( validityCheck ) then
						aura:Activate()
						return
					end
				end
			end
		end
	end
	
	--	If we get here, deactivate the aura
	aura:Deactivate()
end

function AuraEngine.HandleTriggerType_ActionPoints( aura )

	if( aura:TriggerStatusCheck() ) then
		local actionPoints = GameData.Player.actionPoints.current
		
		local primary = AuraEngine.ValueComparison( GameData.Player.actionPoints.current, aura:Get( "actionpoints-operator" ), aura:Get( "actionpoints-value" ) )
		
		-- See if we are taking the secondary in to account	
		if( aura:Get( "actionpoints-enablesecondary" ) ) then
			
			local secondary = AuraEngine.ValueComparison( GameData.Player.actionPoints.current, aura:Get( "actionpoints-secondaryoperator" ), aura:Get( "actionpoints-secondaryvalue" ) )
			
			--
			-- Remember:  -- True = AND (index 1), False = OR (index 2)
			--
			if( aura:Get( "actionpoints-secondaryconditional" ) ) then
				if( primary and secondary ) then aura:Activate() return end
			else
				if( primary or secondary ) then aura:Activate() return end
			end
		else
			if( primary ) then aura:Activate() return end
		end
	end
	
	--	If we get here, deactivate the aura
	aura:Deactivate()
end

function AuraEngine.HandleTriggerType_Career( current, aura )
	if( aura:TriggerStatusCheck() ) then
	
		-- This code normalizes the current value we receive
		if( EA_CareerResourceData[GameData.Player.career.line] ~= nil and EA_CareerResourceData[GameData.Player.career.line].ConvertCurrentPoints ~= nil ) then
			current = EA_CareerResourceData[GameData.Player.career.line]:ConvertCurrentPoints( current )
		end
		
		local primary = AuraEngine.ValueComparison( current, aura:Get( "career-operator" ), aura:Get( "career-value" ) ) 
		
		-- See if we are taking the secondary in to account	
		if( aura:Get( "career-enablesecondary" ) ) then
			
			local secondary = AuraEngine.ValueComparison( current, aura:Get( "career-secondaryoperator" ), aura:Get( "career-secondaryvalue" ) )
			
			--
			-- Remember:  -- True = AND (index 1), False = OR (index 2)
			--
			if( aura:Get( "career-secondaryconditional" ) ) then
				if( primary and secondary ) then aura:Activate() return end
			else
				if( primary or secondary ) then aura:Activate() return end
			end
		else
			if( primary ) then aura:Activate() return end
		end
	end
	
	--	If we get here, deactivate the aura
	aura:Deactivate()
end

function AuraEngine.HandleTriggerType_Effect( aura, effectsFrom, changedEffects, isFullList )
	local result
	local effectData
	
	local hasSelf			= false
	local hasFriendly		= false
	local hasHostile		= false
	
	if( effectsFrom == GameData.BuffTargetType.SELF and aura:Get( "effect-self" ) ) then
		local trigEffects = {}
        
        if( isFullList == false ) then
		 	trigEffects = aura:Get( "internal-effect-self" )
		end
	
	  	for effectIndex, effect in pairs( changedEffects )
    	do
    		if( effect.name == nil ) then
    			trigEffects[effectIndex] = nil
    			AuraDebug( "Removing index:" .. tostring( effectIndex ) )
    		else
                if( AuraEngine.Effect_Compare( aura, effect ) ) then
                    tinsert( trigEffects, effectIndex, effect.name )
                    AuraDebug( "Adding index:" .. tostring( effectIndex ) )
    			else
    				AuraDebug( "Removing index that did not pass comparison:" .. tostring( effectIndex ) )
    			    trigEffects[effectIndex] = nil
    			end
    		end
    	end
        aura:Set( "internal-effect-self", trigEffects )
    elseif( effectsFrom == GameData.BuffTargetType.TARGET_FRIENDLY and aura:Get( "effect-friendly" ) ) then
		-- If we checked ourself already, and we are targetting ourself, we do not need to check again
		if( not( aura:Get( "effect-self" ) and TargetInfo:UnitEntityId( c_FRIENDLY_TARGET ) == GameData.Player.worldObjNum ) ) then
	    	local trigEffects = {}
        
            if( isFullList == false ) then 
			 	trigEffects = aura:Get( "internal-effect-friendly" )
			end
    
            for effectIndex, effect in pairs( changedEffects )
        	do
        		if( effect.name == nil ) then
        			trigEffects[effectIndex] = nil
        		else
        			if( AuraEngine.Effect_Compare( aura, effect ) ) then
        				tinsert( trigEffects, effectIndex, effect.name )
        			else
                        trigEffects[effectIndex] = nil
        			end
        		end
        	end
           
            aura:Set( "internal-effect-friendly", trigEffects )
    	end
	elseif( effectsFrom == GameData.BuffTargetType.TARGET_HOSTILE and aura:Get( "effect-enemy" ) ) then
		local trigEffects = {}
        
        if( isFullList == false ) then 
		 	trigEffects = aura:Get( "internal-effect-enemy" )
		end
		
		for effectIndex, effect in pairs( changedEffects )
    	do
    		if( effect.name == nil ) then
    			trigEffects[effectIndex] = nil
    		else
    			if( AuraEngine.Effect_Compare( aura, effect ) ) then
    				tinsert( trigEffects, effectIndex, effect.name )
    			else
                    trigEffects[effectIndex] = nil
        		end
    		end
    	end
        aura:Set( "internal-effect-enemy", trigEffects )
	end
		
	if( aura:TriggerStatusCheck() ) then		
		if( aura:Get( "effect-self" ) ) then
			hasSelf = next( aura:Get( "internal-effect-self" ) ) ~= nil
			AuraDebug( "EffectSelf:  " .. tostring( hasSelf ) )
			if( aura:Get( "effect-showwhennotactive" ) ) then hasSelf = not hasSelf end
		end
		
		if( aura:Get( "effect-friendly" ) ) then
			hasFriendly = next( aura:Get( "internal-effect-friendly" ) ) ~= nil
			if( aura:Get( "effect-showwhennotactive" ) ) then hasFriendly = not hasFriendly end
		end
		
		if( aura:Get( "effect-enemy" ) ) then
			hasHostile = next( aura:Get( "internal-effect-enemy" ) ) ~= nil
			if( aura:Get( "effect-showwhennotactive" ) ) then hasHostile = not hasHostile end
		end
				
		-- See if we should be activating this aura
		if( hasSelf or hasFriendly or hasHostile ) then
            aura:Activate()
            return
        end
	end	

	--	If we get here, deactivate the aura
	aura:Deactivate()
end

function AuraEngine.HandleTriggerType_Effect_TimerUpdate( aura )
	local effectIndex		= nil
	local effects			= {}
	local effect
	
	if( aura:Get( "effect-self" ) ) then
		effectIndex = next( aura:Get( "internal-effect-self" ) )
		effects = effectTrackers[GameData.BuffTargetType.SELF]:GetEffects()
	end
	
	if( aura:Get( "effect-friendly" ) and effectIndex == nil ) then
		effectIndex = next( aura:Get( "internal-effect-friendly" ) )
		effects = effectTrackers[GameData.BuffTargetType.TARGET_FRIENDLY]:GetEffects()
	end
	
	if( aura:Get( "effect-enemy" ) and effectIndex == nil ) then
		effectIndex = next( aura:Get( "internal-effect-enemy" ) )
		effects = effectTrackers[GameData.BuffTargetType.TARGET_HOSTILE]:GetEffects()
	end
	
	if( effectIndex ~= nil and effects ~= nil ) then
		effect = effects[effectIndex]
		
		if( effect ~= nil ) then
			aura:UpdateTimerWindowTime( effect.duration )
			return
		end
	end
	
	-- If we couldnt find the effect, set it to 0
	aura:UpdateTimerWindowTime( 0 )
end

function AuraEngine.HandleTriggerType_HitPoints( aura )
	if( aura:TriggerStatusCheck() ) then
		local percentHitPoints
		
		local hpType = aura:Get( "hitpoints-type" )
		
		-- Get the percent hit points we need
		if( hpType == 1 ) then
			percentHitPoints = ( GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum ) * 100
		else
			local target = AuraConstants.HitPointTypes[hpType].target
			
			TargetInfo:UpdateFromClient()
			
			-- Get the hit points only if we have a target
			if( TargetInfo:UnitEntityId( target ) > 0 ) then
				percentHitPoints = TargetInfo:UnitHealth( target )
			else
				aura:Deactivate()
				return
			end
		end
		
		local primary = AuraEngine.ValueComparison( percentHitPoints, aura:Get( "hitpoints-operator" ), aura:Get( "hitpoints-value" ) ) 
		
		-- See if we are taking the secondary in to account	
		if( aura:Get( "hitpoints-enablesecondary" ) ) then
			
			local secondary = AuraEngine.ValueComparison( percentHitPoints, aura:Get( "hitpoints-secondaryoperator" ), aura:Get( "hitpoints-secondaryvalue" ) )
			
			--
			-- Remember:  -- True = AND (index 1), False = OR (index 2)
			--
			if( aura:Get( "hitpoints-secondaryconditional" ) ) then
				if( primary and secondary ) then aura:Activate() return end
			else
				if( primary or secondary ) then aura:Activate() return end
			end
		else
			if( primary ) then aura:Activate() return end
		end
	end
	
	--	If we get here, deactivate the aura
	aura:Deactivate()
end

function AuraEngine.HandleTriggerType_PetStatus( aura )
  if( aura:TriggerStatusCheck() ) then
    local petStatus = PetWindow.HasPet()
    
    if(petStatus) then
      aura:Deactivate() return
    else
      aura:Activate() return
    end
    
    --if(petStatus) then
      --if(aura:Get( "effect-showwhennotactive")) then
        --aura:Deactivate() return

      --else
        --aura:Activate() return

      --end
    --else
      --if(aura:Get( "effect-showwhennotactive")) then
        --aura:Activate() return
      --else
        --aura:Deactivate() return
      --end
    --end
  end
end

function AuraEngine.HandleTriggerType_Morale( morale, aura )
	if( aura:TriggerStatusCheck() ) then
		
		local primary = AuraEngine.ValueComparison( morale, aura:Get( "morale-operator" ), aura:Get( "morale-value" ) ) 
		
		-- See if we are taking the secondary in to account	
		if( aura:Get( "morale-enablesecondary" ) ) then
			
			local secondary = AuraEngine.ValueComparison( morale, aura:Get( "morale-secondaryoperator" ), aura:Get( "morale-secondaryvalue" ) )
			
			--
			-- Remember:  -- True = AND (index 1), False = OR (index 2)
			--
			if( aura:Get( "morale-secondaryconditional" ) ) then
				if( primary and secondary ) then aura:Activate() return end
			else
				if( primary or secondary ) then aura:Activate() return end
			end
		else
			if( primary ) then aura:Activate() return end
		end
	end
	
	--	If we get here, deactivate the aura
	aura:Deactivate()
end

function AuraEngine.Effect_Compare( aura, effect )
    local foundEffect       = false
	local selfCastPass		= true
	local stackCheckPass	= true
	
	--
	-- Perform our self cast check
	--
	if( aura:Get( "effect-selfcast" ) ) then selfCastPass = effect.castByPlayer end
	
    -- Perform the stack check
	if( aura:Get( "effect-enablestacks" ) ) then stackCheckPass = AuraEngine.Effect_HasExactStack( aura, effect ) end
	
	-- Add our self check cast first
	if( selfCastPass and stackCheckPass ) then
		
		-- If the effect ID is in our black list, return false
		local blackList = aura:Get( "internal-effect-blacklist" )
		if( blackList[effect.abilityId] ~= nil ) then return false end
		
		local whiteList = aura:Get( "internal-effect-whitelist" )
		if( whiteList[effect.abilityId] ~= nil ) then return true end
			
		-- Check to see if the effect is the proper type
		if( AuraEngine.Effect_IsProperType( aura, effect ) ) then
			local effectIds = aura:Get( "internal-effect-ids" )
			
			-- Check the IDs first
			if( #effectIds > 0 ) then
				for _, id in ipairs( effectIds )
				do
					if( id == effect.abilityId ) then
						foundEffect = true
						break
					end
				end
			end
			
			if( not foundEffect ) then
				local effectNames = aura:Get( "internal-effect-names" )
				
				if( #effectNames > 0 ) then
					local cleanedEffectName = AuraHelpers.cleanWString( effect.name )
				
					for _, auraEffectName in ipairs( effectNames )
					do
						if( ( not exactMatch and cleanedEffectName:find( auraEffectName, 1 ) ) or 
							( exactMatch and WStringsCompare( cleanedEffectName, auraEffectName ) == 0 ) ) then
							foundEffect = true
							break	
						end	
					end
				else
					-- If there were no names configured, flag as a found effect, as we have passed all other checks
					foundEffect = true
				end
			end	
		end
		
		-- If we found the effect, add it to our whitelist, otherwise add it to our blacklist
		if( foundEffect ) then
			whiteList[effect.abilityId] = true
			aura:Set( "internal-effect-whitelist", whiteList )
			AuraDebug( "Aura: " .. tostring( aura ) .. "   Whitelisting:  " .. tostring( effect.name ) )
		else
			blackList[effect.abilityId] = true
			aura:Set( "internal-effect-blacklist", blackList )
			AuraDebug( "Aura: " .. tostring( aura ) .. "   Blacklisting:  " .. tostring( effect.name ) )
		end
	end
	
	return foundEffect
end

function AuraEngine.Effect_IsProperType( aura, effect )
    -- This is our catch Any clause, check it first
	if( aura:Get( "effect-type" ) == 1 ) then return true end

	if( AuraConstants.Effects[aura:Get( "effect-type" )] ~= nil ) then
		local key = AuraConstants.Effects[aura:Get( "effect-type" )].key
		if( effect[key] ~= nil ) then
			return effect[key]
		end
	end
	
	return false
end

function AuraEngine.Effect_HasExactStack( aura, effect )
	return AuraEngine.ValueComparison( effect.stackCount, aura:Get( "effect-stackoperator" ), aura:Get( "effect-stackcount" ) )
end

function AuraEngine.IsAbilityEnabled( abilityId )
	local abilityData = Player.GetAbilityData( abilityId )
	
	if( abilityData == nil ) then
		return false
	elseif( abilityData.abilityType == GameData.AbilityType.STANDARD or 
					abilityData.abilityType == GameData.AbilityType.MORALE ) then
		return IsAbilityEnabled( abilityId )
	elseif( abilityData.abilityType == GameData.AbilityType.TACTIC ) then
		local tactics 	= GetActiveTactics()
		
		-- Check to see whether the tactic is active or not
		for index, tacticId in pairs( tactics ) 
		do
			if( tacticId == abilityId ) then
				return true
			end
		end
	end
	
	return false			
end

function AuraEngine.ValueComparison( current, operator, comparator )
	if( operator == AuraConstants.OPERATOR_EQUAL ) then
		if( current == comparator ) then return true end
	elseif( operator == AuraConstants.OPERATOR_LESSTHAN ) then
		if( current < comparator ) then return true end
	elseif( operator == AuraConstants.OPERATOR_GREATERTHAN ) then
		if( current > comparator ) then return true end
	elseif( operator == AuraConstants.OPERATOR_NOT ) then
		if( current ~= comparator ) then return true end
	end
	
	return false
end

function AuraEngine.UpdateAbilityCooldownTimer( ... )
	local self, timeElapsed = ...
	
	-- Call the original function
	AuraEngine.__ActionButton_UpdateCooldownAnimation( ... )
	
	-- Check to see if we have an ability for this action
	if( Event_AbilityType_AbilityAuras[self.m_ActionId] ~= nil ) then
		local abilityAuras = Event_AbilityType_AbilityAuras[self.m_ActionId]
		
		abilityAuras._RefreshTime = abilityAuras._RefreshTime + timeElapsed
		
		if( abilityAuras._NextRefreshTime < abilityAuras._RefreshTime ) then
			
			local maxCooldown = tonumber( string.format( "%0.1f", math.abs( self.m_MaxCooldown or 0 ) ) )
			local cooldown = tonumber( string.format( "%0.1f", math.abs( self.m_Cooldown  or 0 ) ) )
			
			for index, aura in pairs( abilityAuras.Auras )
			do
				AuraEngine.HandleTriggerType_Ability( aura, cooldown, maxCooldown, false )
			end
			
			-- Set our refresh members
			abilityAuras._NextRefreshTime = AuraAddon.Get( "general-ability-timers" )
			abilityAuras._RefreshTime = 0
		end
	end
end

function AuraEngine.UpdateMoraleCooldownTimer( ... )
	local self, timeElapsed = ...
	-- Call the original function
	AuraEngine.__MoraleButton_Update( ... )
	
	-- Check to see if we have an ability for this action
	if( Event_AbilityType_MoraleAuras[self.m_AbilityId] ~= nil ) then
		
		local moraleAuras = Event_AbilityType_MoraleAuras[self.m_AbilityId]
		
		moraleAuras._RefreshTime = moraleAuras._RefreshTime + timeElapsed
		
		if( moraleAuras._NextRefreshTime < moraleAuras._RefreshTime ) then
			
			local maxCooldown = tonumber( string.format( "%0.1f", math.abs( self.m_MaxCooldown or 0 ) ) )
			local cooldown = tonumber( string.format( "%0.1f", math.abs( self.m_Cooldown  or 0 ) ) )
			
			for index, aura in pairs( moraleAuras.Auras )
			do
				AuraEngine.HandleTriggerType_Ability( aura, cooldown, maxCooldown, true )
			end
			
			-- Set our refresh members
			moraleAuras._NextRefreshTime = AuraAddon.Get( "general-ability-timers" )
			moraleAuras._RefreshTime = 0
		end
	end
end

function AuraEngine.RegisterAbilityTimerAura( aura )
	local ability = aura:Get( "ability-abilityid" )
	if( Event_AbilityType_AbilityAuras[ability] == nil ) then
		Event_AbilityType_AbilityAuras[ability] = {}
		Event_AbilityType_AbilityAuras[ability].Auras = {}
		Event_AbilityType_AbilityAuras[ability]._RefreshTime = 1
		Event_AbilityType_AbilityAuras[ability]._NextRefreshTime = 0
	end
	AuraDebug( "Adding: " .. tostring( aura ) .. " to ability timer table." )
	tinsert( Event_AbilityType_AbilityAuras[ability].Auras, aura )
end

function AuraEngine.RegisterMoraleTimerAura( aura )
	local ability = aura:Get( "ability-abilityid" )
	if( Event_AbilityType_MoraleAuras[ability] == nil ) then
		Event_AbilityType_MoraleAuras[ability] = {}
		Event_AbilityType_MoraleAuras[ability].Auras = {}
		Event_AbilityType_MoraleAuras[ability]._RefreshTime = 1
		Event_AbilityType_MoraleAuras[ability]._NextRefreshTime = 0
	end
	AuraDebug( "Adding: " .. tostring( aura ) .. " to morale timer table." )
	tinsert( Event_AbilityType_MoraleAuras[ability].Auras, aura )
end

--
-- In order for us to get ability cooldown timers, we need to snag this function for the data
--
AuraEngine.__ActionButton_UpdateCooldownAnimation					= ActionButton.UpdateCooldownAnimation
ActionButton.UpdateCooldownAnimation 								= AuraEngine.UpdateAbilityCooldownTimer

--
-- In order for us to get morale level timers, we need to snag this function for the data
--
AuraEngine.__MoraleButton_Update									= MoraleButton.Update
MoraleButton.Update					 								= AuraEngine.UpdateMoraleCooldownTimer


RVAPI_Entities = {}
local RVAPI_Entities							= RVAPI_Entities

local RVName									= "Entities API"
local RVCredits									= "silverq"
local RVLicense									= "MIT License"
local RVProjectURL								= "http://www.returnofreckoning.com/forum/viewtopic.php?f=11&t=4534"
local RVRecentUpdates							= 
"09.07.2015 - v0.74 Beta\n"..
"\t- Project official site location has been changed\n"..
"\n"..
"24.11.2010 - v0.73 Beta\n"..
"\t- RVAPI_Entities should gather entities information on-demand now\n"..
"\n"..
"06.09.2010 - v0.72 Beta\n"..
"\t- Fixed an issue with the scenario formation. This fix affects on the distances information\n"..
"\n"..
"25.08.2010 - v0.71 Beta\n"..
"\t- Fixed issue with the SELF targets, it should calculate distances correctly now\n"..
"\t- Range API v2.0 support\n"..
"\n"..
"25.07.2010 - v0.7 Beta\n"..
"\t- Effects support has been added\n"..
"\t- Small code improvements are implemented\n"..
"\t- Distances are based on the map information\n"..
"\n"..
"24.02.2010 - v0.61 Beta\n"..
"\t- Code clearance\n"..
"\t- Adapted to work with the RV Mods Manager v0.99"

-- : entities list
RVAPI_Entities.Entities							= {}

-- : objects list in the 3D world
RVAPI_Entities.Objects							= {
	mouseovertarget								= 0,
	selffriendlytarget							= 0,
	selfhostiletarget							= 0,
	self										= 0,
	pet											= 0,

	-- : TODO (MrAngel) should we place formation members here too?
	-- : TODO (MrAngel) probably just group members. Revolution incoming!
	groupmembers								= {0, 0, 0, 0, 0, 0},
}

local Entities									= RVAPI_Entities.Entities
local Objects									= RVAPI_Entities.Objects
local FormationMembers							= {}
local WindowEntitiesSettings					= "RVAPI_EntitiesSettingsWindow"

local EventCallbacks							= {}

local GroupUpdateRequired						= false
local BattlegroupUpdateRequired					= false
local PetUpdateRequired							= false
local EffectsSelfUpdateRequired					= false
local EffectsFriendlyUpdateRequired				= false
local EffectsHostileUpdateRequired				= false
local EffectsMember1UpdateRequired				= false
local EffectsMember2UpdateRequired				= false
local EffectsMember3UpdateRequired				= false
local EffectsMember4UpdateRequired				= false
local EffectsMember5UpdateRequired				= false
local EffectsMember6UpdateRequired				= false
local EntitiesBroadcastRequired					=
{
	isRequired									= false,
	Entities									= {},
}

local RegisterEventHandlersCounter				= 0

--------------------------------------------------------------
-- var DefaultConfiguration
-- Description: default module configuration
--------------------------------------------------------------
RVAPI_Entities.DefaultConfiguration =
{

	-- TODO: (MrAngel) So! should we allow end-users to change this value?
	DistanceUpdateDelay				= 0,
}

--------------------------------------------------------------
-- var CurrentConfiguration
-- Description: current module configuration
--------------------------------------------------------------
RVAPI_Entities.CurrentConfiguration =
{
	-- should stay empty, will load in the InitializeConfiguration() function
}

--------------------------------------------------------------
-- var Events
-- Description: build in events
--------------------------------------------------------------
RVAPI_Entities.Events =
{
	ENTITY_UPDATED								= 1,
	ENTITY_PARAM_UPDATED						= 2,

	ENTITY_LOADING_BEGIN						= 3,
	ENTITY_LOADING_END							= 4,
	ENTITY_PLAYER_TARGET_UPDATED				= 5,
	ENTITY_GROUP_UPDATED						= 6,
	ENTITY_GROUP_MEMBER_UPDATED					= 7,
	ENTITY_BATTLEGROUP_UPDATED					= 8,
	ENTITY_BATTLEGROUP_MEMBER_UPDATED			= 9,
	ENTITY_FORMATION_UPDATED					= 10,
	ENTITY_FORMATION_MEMBER_UPDATED				= 11,
	ENTITY_PLAYER_PET_UPDATED					= 12,
	ENTITY_PLAYER_PET_HEALTH_UPDATED			= 13,
	ENTITY_PLAYER_PET_STATE_UPDATED				= 14,
}

--------------------------------------------------------------
-- function Initialize()
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.Initialize()

	-- First step: load configuration
	RVAPI_Entities.InitializeConfiguration()

	-- Second step: define event handlers
	RegisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED,					"RVAPI_Entities.OnAllModulesInitialized")
--[[
	RegisterEventHandler(SystemData.Events.LOADING_BEGIN,							"RVAPI_Entities.OnLoadingBegin")
	RegisterEventHandler(SystemData.Events.LOADING_END,								"RVAPI_Entities.OnLoadingEnd")
	RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED,					"RVAPI_Entities.OnPlayerTargetUpdated")
]]
--[[
	TODO: (MrAngel) will be implemented in the next release
	RegisterEventHandler(SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED,		"RVAPI_Entities.OnPlayerCurActionPointsUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_MAX_ACTION_POINTS_UPDATED,		"RVAPI_Entities.OnPlayerMaxActionPointsUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED,			"RVAPI_Entities.OnPlayerCurHitPointsUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED,			"RVAPI_Entities.OnPlayerMaxHitPointsUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED,						"RVAPI_Entities.OnPlayerZoneChangedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_BATTLE_LEVEL_UPDATED,				"RVAPI_Entities.OnPlayerBattleLevelUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_RVR_FLAG_UPDATED,					"RVAPI_Entities.OnPlayerRvRFlagUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_CAREER_RANK_UPDATED,				"RVAPI_Entities.OnPlayerCareerRankUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_MORALE_UPDATED,					"RVAPI_Entities.OnPlayerMoraleUpdatedProxy")
--	RegisterEventHandler(SystemData.Events.PLAYER_PET_HEALTH_UPDATED,				"RVAPI_Entities.OnPlayerPetHealthUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_GROUP_LEADER_STATUS_UPDATED,		"RVAPI_Entities.OnPlayerGroupLeaderStatusUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_MAIN_ASSIST_UPDATED,				"RVAPI_Entities.OnPlayerMainAssistUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_CAREER_LINE_UPDATED,				"RVAPI_Entities.OnPlayerCareerLineUpdatedProxy")
	RegisterEventHandler(SystemData.Events.GROUP_SETTINGS_UPDATED,					"RVAPI_Entities.OnGroupSettingsUpdatedProxy")
]]
--[[
	RegisterEventHandler(SystemData.Events.GROUP_UPDATED,							"RVAPI_Entities.OnGroupUpdatedProxy")
	RegisterEventHandler(SystemData.Events.GROUP_STATUS_UPDATED,					"RVAPI_Entities.OnGroupStatusUpdated")
	RegisterEventHandler(SystemData.Events.BATTLEGROUP_UPDATED,						"RVAPI_Entities.OnBattlegroupUpdatedProxy")
	RegisterEventHandler(SystemData.Events.BATTLEGROUP_MEMBER_UPDATED,				"RVAPI_Entities.OnBattlegroupMemberUpdated")
	RegisterEventHandler(SystemData.Events.PLAYER_PET_UPDATED,						"RVAPI_Entities.OnPlayerPetUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_PET_HEALTH_UPDATED,				"RVAPI_Entities.OnPlayerPetHealthUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_PET_STATE_UPDATED,				"RVAPI_Entities.OnPlayerPetStateUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED,					"RVAPI_Entities.OnPlayerEffectsUpdatedProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED,			"RVAPI_Entities.OnEffectsUpdatedProxy")
	RegisterEventHandler(SystemData.Events.GROUP_EFFECTS_UPDATED,					"RVAPI_Entities.OnEffectsUpdatedProxy")
]]
-- PLAYER_TARGET_EFFECTS_UPDATED
-- PLAYER_TARGET_HIT_POINTS_UPDATED
-- PLAYER_TARGET_STATE_UPDATED
-- PLAYER_PET_UPDATED
-- PLAYER_PET_HEALTH_UPDATED
-- PLAYER_PET_STATE_UPDATED
-- PLAYER_PET_TARGET_HEALTH_UPDATED
-- PLAYER_PET_TARGET_UPDATED
-- PLAYER_EFFECTS_UPDATED
-- PLAYER_POSITION_UPDATED 
-- SIEGE_WEAPON_SNIPER_AIM_TARGET_LOS_UPDATED
-- SIEGE_WEAPON_SNIPER_AIM_TARGET_UPDATED 
-- TARGET_GROUP_MEMBER_1
-- TARGET_GROUP_MEMBER_2
-- TARGET_GROUP_MEMBER_3
-- TARGET_GROUP_MEMBER_4
-- TARGET_GROUP_MEMBER_5
-- TARGET_GROUP_MEMBER_6
-- TARGET_SELF 
-- BATTLEGROUP_UPDATED
-- BATTLEGROUP_MEMBER_UPDATED
-- GROUP_UPDATED
-- GROUP_EFFECTS_UPDATED
-- SCENARIO_PLAYERS_LIST_GROUPS_UPDATED
-- SCENARIO_PLAYERS_LIST_RESERVATIONS_UPDATED
-- SCENARIO_PLAYERS_LIST_STATS_UPDATED
-- SCENARIO_PLAYERS_LIST_UPDATED
end

--------------------------------------------------------------
-- function Shutdown()
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.Shutdown()

	-- First step: destroy settings window
	if DoesWindowExist(WindowEntitiesSettings) then
		DestroyWindow(WindowEntitiesSettings)
	end

	-- First step: unregister all events
	UnregisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED,					"RVAPI_Entities.OnAllModulesInitialized")
--[[
	UnregisterEventHandler(SystemData.Events.LOADING_BEGIN,								"RVAPI_Entities.OnLoadingBegin")
	UnregisterEventHandler(SystemData.Events.LOADING_END,								"RVAPI_Entities.OnLoadingEnd")
	UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED,						"RVAPI_Entities.OnPlayerTargetUpdated")
]]
--[[
	TODO: (MrAngel) will be implemented in the next release
	UnregisterEventHandler(SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED,			"RVAPI_Entities.OnPlayerCurActionPointsUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_MAX_ACTION_POINTS_UPDATED,			"RVAPI_Entities.OnPlayerMaxActionPointsUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED,				"RVAPI_Entities.OnPlayerCurHitPointsUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED,				"RVAPI_Entities.OnPlayerMaxHitPointsUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED,						"RVAPI_Entities.OnPlayerZoneChangedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_BATTLE_LEVEL_UPDATED,				"RVAPI_Entities.OnPlayerBattleLevelUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_RVR_FLAG_UPDATED,					"RVAPI_Entities.OnPlayerRvRFlagUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_CAREER_RANK_UPDATED,				"RVAPI_Entities.OnPlayerCareerRankUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_MORALE_UPDATED,						"RVAPI_Entities.OnPlayerMoraleUpdatedProxy")
--	UnregisterEventHandler(SystemData.Events.PLAYER_PET_HEALTH_UPDATED,					"RVAPI_Entities.OnPlayerPetHealthUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_GROUP_LEADER_STATUS_UPDATED,		"RVAPI_Entities.OnPlayerGroupLeaderStatusUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_MAIN_ASSIST_UPDATED,				"RVAPI_Entities.OnPlayerMainAssistUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_CAREER_LINE_UPDATED,				"RVAPI_Entities.OnPlayerCareerLineUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.GROUP_SETTINGS_UPDATED,					"RVAPI_Entities.OnGroupSettingsUpdatedProxy")
]]
--[[
	UnregisterEventHandler(SystemData.Events.GROUP_UPDATED,								"RVAPI_Entities.OnGroupUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.GROUP_STATUS_UPDATED,						"RVAPI_Entities.OnGroupStatusUpdated")
	UnregisterEventHandler(SystemData.Events.BATTLEGROUP_UPDATED,						"RVAPI_Entities.OnBattlegroupUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.BATTLEGROUP_MEMBER_UPDATED,				"RVAPI_Entities.OnBattlegroupMemberUpdated")
	UnregisterEventHandler(SystemData.Events.PLAYER_PET_UPDATED,						"RVAPI_Entities.OnPlayerPetUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_PET_HEALTH_UPDATED,					"RVAPI_Entities.OnPlayerPetHealthUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_PET_STATE_UPDATED,					"RVAPI_Entities.OnPlayerPetStateUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED,					"RVAPI_Entities.OnPlayerEffectsUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED,				"RVAPI_Entities.OnEffectsUpdatedProxy")
	UnregisterEventHandler(SystemData.Events.GROUP_EFFECTS_UPDATED,						"RVAPI_Entities.OnEffectsUpdatedProxy")
]]
end

--------------------------------------------------------------
-- function InitializeConfiguration()
-- Description: loads current configuration
--------------------------------------------------------------
function RVAPI_Entities.InitializeConfiguration()

	-- First step: move default value to the CurrentConfiguration variable
	for k,v in pairs(RVAPI_Entities.DefaultConfiguration) do
		if(RVAPI_Entities.CurrentConfiguration[k]==nil) then
			RVAPI_Entities.CurrentConfiguration[k]=v
		end
	end
end

--------------------------------------------------------------
-- function OnAllModulesInitialized()
-- Description: event ALL_MODULES_INITIALIZED
-- We can start working with the RVAPI just then we sure they are all initialized
-- and ready to provide their services
--------------------------------------------------------------
function RVAPI_Entities.OnAllModulesInitialized()

	-- Final step: register in the RV Mods Manager
	-- Please note the folowing:
	-- 1. always do this ON SystemData.Events.ALL_MODULES_INITIALIZED event
	-- 2. you don't need to add RVMOD_Manager to the dependency list
	-- 3. the registration code should be same as below, with your own function parameters
	-- 4. for more information please follow by project official site
	if RVMOD_Manager then
		RVMOD_Manager.API_RegisterAddon("RVAPI_Entities", RVAPI_Entities, RVAPI_Entities.OnRVManagerCallback)
	end
end

--------------------------------------------------------------
-- function OnRVManagerCallback
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.OnRVManagerCallback(Self, Event, EventData)

	if		Event == RVMOD_Manager.Events.NAME_REQUESTED then

		return RVName

	elseif	Event == RVMOD_Manager.Events.CREDITS_REQUESTED then

		return RVCredits

	elseif	Event == RVMOD_Manager.Events.LICENSE_REQUESTED then

		return RVLicense

	elseif	Event == RVMOD_Manager.Events.PROJECT_URL_REQUESTED then

		return RVProjectURL

	elseif	Event == RVMOD_Manager.Events.RECENT_UPDATES_REQUESTED then

		return RVRecentUpdates

	end
end

--------------------------------------------------------------
-- function BroadcastEvent()
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.BroadcastEvent(Event, EventData)

	-- First step: broadcast events to its handlers
	if EventCallbacks[Event] ~= nil then
		for k, callbck in ipairs(EventCallbacks[Event]) do
			callbck.Func(callbck.Owner, EventData)
		end
	end
end

--------------------------------------------------------------
-- function GetDefaultEntity()
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.GetDefaultEntity(entityId)

	-- First step: get default table
	local EntityData = {
		EntityId = entityId,
		EntityType = 0,
		Name = L"",
		Title = L"",
		CareerName = L"",
		CareerLine = 0,
		Level = 0,
		Tier = 0,
		DifficultyMask = 0,
		IsNPC = false,
		IsPet = false,
		IsPVP = false,
		ShowHealthBar = false,
		HitPointPercent = 0,
		ActionPointPercent = 0,
		MoraleLevel = 0,
		RelationshipColor = {r=0,g=0,b=0},
		Online = false,
		ZoneNumber = 0,
		IsDistant = false,
		IsInSameRegion = false,
		IsGroupLeader = false,
		IsAssistant = false,
		IsMainAssist = false,
		IsMasterLooter = false,
		IsSelf = false,
		IsGroupMember = false,
		IsScenarioGroupMember = false,
		IsWarbandMember = false,
		IsTargeted = false,
		IsMouseOvered = false,
		Pet = {healthPercent = 0},
		ConType = 0,
		MapPinType = 0,
		MapPointIndex = 0,
		SigilEntryId = 0,
		Effects = {},
		RangeMin = RVAPI_Range.Ranges.MIN_RANGE,
		RangeMax = RVAPI_Range.Ranges.MAX_RANGE,
		GroupIndex = 0,
		MemberIndex = 0,
	}

	-- Final step: return new table
	return EntityData
end

--------------------------------------------------------------
-- function GetFormationData()
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.GetFormationData()

	-- First step: check if warband is not active and player is in scenario
	if not IsWarBandActive() or GameData.Player.isInScenario then

		-- : get a group players list
		local Players					= PartyUtils.GetPartyData()
		local PlayerData				= GameData.Player

--[[
		TODO: (MrAngel) will be implemented in the next release
		-- : add a SELF player to the list
		Players[6]						= {}
		Players[6].zoneNum				= PlayerData.zone															--* PLAYER_ZONE_CHANGED
		Players[6].battleLevel			= PlayerData.battleLevel													--* PLAYER_BATTLE_LEVEL_UPDATED
		Players[6].isRVRFlagged			= PlayerData.rvrZoneFlagged													--* PLAYER_RVR_FLAG_UPDATED, PLAYER_COMBAT_FLAG_UPDATED
		Players[6].isInSameRegion		= true																		--
		Players[6].level				= PlayerData.level															--* PLAYER_CAREER_RANK_UPDATED
		Players[6].isDistant			= false																		--
		Players[6].healthPercent		= PlayerData.hitPoints.current * 100 / PlayerData.hitPoints.maximum			--*
		Players[6].moraleLevel			= 0																			--* PLAYER_MORALE_UPDATED, PLAYER_MORALE_BAR_UPDATED ???
		Players[6].online				= true																		--
		Players[6].Pet					= {}																		--
		Players[6].Pet.healthPercent	= PlayerData.Pet.healthPercent												--* PLAYER_PET_HEALTH_UPDATED
		Players[6].actionPointPercent	= PlayerData.actionPoints.current * 100 / PlayerData.actionPoints.maximum	--*
		Players[6].isAssistant			= PlayerData.isWarbandAssistant												--* GROUP_SETTINGS_UPDATED ???
		Players[6].isGroupLeader		= PlayerData.isGroupLeader													--* PLAYER_GROUP_LEADER_STATUS_UPDATED
		Players[6].name					= PlayerData.name															--
		Players[6].isMainAssist			= IsPlayerMainAssist()														--* PLAYER_MAIN_ASSIST_UPDATED ???
		Players[6].worldObjNum			= PlayerData.worldObjNum													--
		Players[6].careerName			= PlayerData.career.name													--
		Players[6].careerLine			= PlayerData.career.line													--* PLAYER_CAREER_LINE_UPDATED
		Players[6].isMasterLooter		= PlayerData.Group.Settings.playerIsMasterLooter							--* GROUP_SETTINGS_UPDATED
]]
		-- Second step: return group information
		return { {players = Players}, {players = {}}, {players = {}}, {players = {}} }
	else

		-- Third step: get warband information
		return PartyUtils.GetWarbandData()
	end
end

--------------------------------------------------------------
-- function GetFormationMember()
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.GetFormationMember(GroupIndex, MemberIndex)

	local MemberData

	-- First step: check if warband is not active and player is in scenario
	if not IsWarBandActive() or GameData.Player.isInScenario then

		-- Second step: get a group member data
		MemberData = PartyUtils.GetPartyMember( MemberIndex )
	else

		-- Third step: get a warband member data
		MemberData = PartyUtils.GetWarbandMember( GroupIndex, MemberIndex )
	end

	-- Final step: return result
	return MemberData
end

--------------------------------------------------------------
-- function UpdateFormationEntities()
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.UpdateFormationEntities()

	-- First step: define local variables
	local FormationData		= RVAPI_Entities.GetFormationData()
	local EntityData		= nil
	local MemberData		= nil
	local MemberName		= L""
	local Members			= {}

	-- Second step: loop through all members
	for GroupIndex = 1, 4, 1 do
		for MemberIndex = 1, 6, 1 do

			-- : get a MemberData
			MemberData = FormationData[GroupIndex].players[MemberIndex]

			-- : update member entity
			RVAPI_Entities.UpdateFormationMemberEntity(GroupIndex, MemberIndex, MemberData)

			-- : check for the MemberData and it's EntityId
			if MemberData ~= nil and MemberData.worldObjNum > 0 then

				-- : get a member name
				MemberName = wstring.gsub((MemberData.name or L""), L"(^.)", L"")

				-- : this member is registered, remove from the old list
				FormationMembers[MemberName] = nil

				-- : form new members list
				Members[MemberName] = MemberData.worldObjNum
			end
		end
	end

	-- : process lost entities. By the "lost" we are meaning members left from the
	-- : formation as well as not used entities in the 3D world
	for MemberName, EntityId in pairs(FormationMembers) do

		-- : check for the EntityId
		if EntityId > 0 then

			-- : get the EntityData
			EntityData	= RVAPI_Entities.API_GetEntityData(EntityId)

			-- : update formation related information
			EntityData.IsGroupLeader			= false
			EntityData.IsAssistant				= false
			EntityData.IsMainAssist				= false
			EntityData.IsMasterLooter			= false
			EntityData.IsGroupMember			= false
			EntityData.IsScenarioGroupMember	= false
			EntityData.IsWarbandMember			= false
			EntityData.GroupIndex				= 0
			EntityData.MemberIndex				= 0

			-- : check if entity is targeted
			if not EntityData.IsTargeted then

				-- : unregister target from the RVAPI_Range
				RVAPI_Range.API_UnregisterTarget(RVAPI_Entities, RVAPI_Entities.OnTargetRangeUpdated, MemberName)

				-- : set default distance to the entity
				if not EntityData.IsSelf then
					EntityData.RangeMin			= RVAPI_Range.Ranges.MIN_RANGE
					EntityData.RangeMax			= RVAPI_Range.Ranges.MAX_RANGE
				end
			end

			-- : set everything to the entities DB
			RVAPI_Entities.API_SetEntityData(EntityId, EntityData)
		else

			-- : unregister target from the RVAPI_Range
			RVAPI_Range.API_UnregisterTarget(RVAPI_Entities, RVAPI_Entities.OnTargetRangeUpdated, MemberName)
		end
	end

	-- : save new members in the list
	FormationMembers = Members

	-- Final step: generate ENTITY_FORMATION_UPDATED event
	RVAPI_Entities.BroadcastEvent(RVAPI_Entities.Events.ENTITY_FORMATION_UPDATED, {FormationData = FormationData})
end

--------------------------------------------------------------
-- function UpdateFormationMemberEntity()
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.UpdateFormationMemberEntity(GroupIndex, MemberIndex, MemberData)

	-- First step: check for MemberData, it might be nil in some cases
	if MemberData ~= nil then

		-- Second step: get a member name
		local MemberName = wstring.gsub((MemberData.name or L""), L"(^.)", L"")

		-- Third step: check for entityId
		if MemberData.worldObjNum > 0 then

			-- : get locals
			local EntityData					= RVAPI_Entities.API_GetEntityData(MemberData.worldObjNum)
			local GroupPlayers					= PartyUtils.GetPartyData()
			local GroupMemberIndex				= 0

			-- : calculate GroupMemberIndex
			-- NOTE: (MrAngel) Please note that Group and Warband indexes are different
			for PlayerIndex, PlayerData in ipairs(GroupPlayers) do
				if PlayerData.worldObjNum == MemberData.worldObjNum then
					GroupMemberIndex = PlayerIndex
					break
				end
			end

			-- : save member data to the EntityData
			EntityData.EntityType				= SystemData.TargetObjectType.ALLY_PLAYER
			EntityData.Name						= MemberName
			EntityData.CareerName				= MemberData.careerName
			EntityData.CareerLine				= MemberData.careerLine
			EntityData.Level					= MemberData.level
			EntityData.IsNPC					= false
			EntityData.IsPVP					= MemberData.isRVRFlagged
			EntityData.HitPointPercent			= MemberData.healthPercent
			EntityData.ActionPointPercent		= MemberData.actionPointPercent
			EntityData.MoraleLevel				= MemberData.moraleLevel
			EntityData.Online					= MemberData.online
			EntityData.ZoneNumber				= MemberData.zoneNum
			EntityData.Pet						= MemberData.Pet
			EntityData.IsDistant				= MemberData.isDistant
			EntityData.IsInSameRegion			= MemberData.isInSameRegion
			EntityData.IsSelf					= MemberData.worldObjNum == GameData.Player.worldObjNum
			EntityData.IsGroupLeader			= MemberData.isGroupLeader
			EntityData.IsAssistant				= MemberData.isAssistant
			EntityData.IsMainAssist				= MemberData.isMainAssist
			EntityData.IsMasterLooter			= MemberData.isMasterLooter
			EntityData.IsGroupMember			= GroupMemberIndex > 0 or
												  EntityData.IsSelf
			EntityData.IsScenarioGroupMember	= GameData.Player.isInScenario
			EntityData.IsWarbandMember			= IsWarBandActive()
			EntityData.GroupIndex				= GroupIndex
			EntityData.MemberIndex				= MemberIndex

			-- : define effects information
			--	 current player should not be targeted
			if MemberData.worldObjNum ~= Objects.selffriendlytarget then

				-- : check for group member
				-- : group member index range is 1..5
				if GroupMemberIndex > 0 then

					-- : check if member been changed
					if Objects.groupmembers[GroupMemberIndex] > 0 and
					   Objects.groupmembers[GroupMemberIndex] ~= MemberData.worldObjNum and 
					   Objects.groupmembers[GroupMemberIndex] ~= Objects.selffriendlytarget then

						-- : clear old member effects
						RVAPI_Entities.API_SetEntityData(Objects.groupmembers[GroupMemberIndex], {Effects = {}})
					end

					-- : update current group member EntityId
					Objects.groupmembers[GroupMemberIndex] = MemberData.worldObjNum

					-- : set new effects list
					EntityData.Effects = GetBuffs(GroupMemberIndex-1)

				-- : we have to clear effects if this is not IsSelf
				elseif not EntityData.IsSelf then

					-- : set empty effects list
					EntityData.Effects = {}
				end
			end

			-- : set everything to the entities DB
			RVAPI_Entities.API_SetEntityData(MemberData.worldObjNum, EntityData)

			-- : cool, now check for the EntityId's difference
			if FormationMembers[MemberName] ~= EntityData.EntityId then

				-- : register/update target for tracking in the RVAPI_Range
				RVAPI_Range.API_RegisterTarget(RVAPI_Entities, RVAPI_Entities.OnTargetRangeUpdated, MemberName, RVAPI_Entities.CurrentConfiguration.DistanceUpdateDelay, RVAPI_Range.DelayType.DELAY_EXACT_TIME, {EntityId = EntityData.EntityId})
				FormationMembers[MemberName] = EntityData.EntityId
			end

		-- Fifth step: we dont know the right EntityId, check if member is still registered in the RVAPI_Range
		elseif MemberName:len() > 0 and FormationMembers[MemberName] then

			-- : unregister target from the RVAPI_Range
			RVAPI_Range.API_UnregisterTarget(RVAPI_Entities, RVAPI_Entities.OnTargetRangeUpdated, MemberName)
			FormationMembers[MemberName] = nil
		end
	end

	-- Final step: generate ENTITY_FORMATION_MEMBER_UPDATED event
	RVAPI_Entities.BroadcastEvent(RVAPI_Entities.Events.ENTITY_FORMATION_MEMBER_UPDATED, {GroupIndex = GroupIndex, MemberIndex = MemberIndex, MemberData = MemberData})
end

--------------------------------------------------------------
-- function OnLoadingBegin()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnLoadingBegin()

	-- First step:	we have to clear all collected data related with the previous 3D world
	--				so lets do that!
	RVAPI_Entities.API_ResetSystem()

	-- Final step: generate ENTITY_LOADING_BEGIN event
	RVAPI_Entities.BroadcastEvent(RVAPI_Entities.Events.ENTITY_LOADING_BEGIN, {})
end

--------------------------------------------------------------
-- function OnLoadingBegin()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnLoadingEnd()

	-- First step:  update/load using all possible ways
	RVAPI_Entities.API_UpdateSystem()

	-- Final step: generate ENTITY_LOADING_END event
	RVAPI_Entities.BroadcastEvent(RVAPI_Entities.Events.ENTITY_LOADING_END, {})
end

--------------------------------------------------------------
-- function OnUpdate()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnUpdate(timePassed)

	-- : update group if required
	if GroupUpdateRequired then
		RVAPI_Entities.OnGroupUpdated()
	end

	-- : update battle group if required
	if BattlegroupUpdateRequired then
		RVAPI_Entities.OnBattlegroupUpdated()
	end

	-- : update pet if required
	if PetUpdateRequired then
		RVAPI_Entities.OnPlayerPetUpdated()
	end

	-- : update effects SELF
	if EffectsSelfUpdateRequired then
		RVAPI_Entities.OnEffectsUpdated(GameData.BuffTargetType.SELF)
	end

	-- : update effects TARGET_FRIENDLY
	if EffectsFriendlyUpdateRequired then
		RVAPI_Entities.OnEffectsUpdated(GameData.BuffTargetType.TARGET_FRIENDLY)
	end

	-- : update effects TARGET_HOSTILE
	if EffectsHostileUpdateRequired then
		RVAPI_Entities.OnEffectsUpdated(GameData.BuffTargetType.TARGET_HOSTILE)
	end

	-- : update effects GROUP_MEMBER
	if EffectsMember1UpdateRequired then
		RVAPI_Entities.OnEffectsUpdated(GameData.BuffTargetType.GROUP_MEMBER_START)
	end

	-- : update effects GROUP_MEMBER
	if EffectsMember2UpdateRequired then
		RVAPI_Entities.OnEffectsUpdated(GameData.BuffTargetType.GROUP_MEMBER_START+1)
	end

	-- : update effects GROUP_MEMBER
	if EffectsMember3UpdateRequired then
		RVAPI_Entities.OnEffectsUpdated(GameData.BuffTargetType.GROUP_MEMBER_START+2)
	end

	-- : update effects GROUP_MEMBER
	if EffectsMember4UpdateRequired then
		RVAPI_Entities.OnEffectsUpdated(GameData.BuffTargetType.GROUP_MEMBER_START+3)
	end

	-- : update effects GROUP_MEMBER
	if EffectsMember5UpdateRequired then
		RVAPI_Entities.OnEffectsUpdated(GameData.BuffTargetType.GROUP_MEMBER_START+4)
	end

	-- : update effects GROUP_MEMBER
	if EffectsMember6UpdateRequired then
		RVAPI_Entities.OnEffectsUpdated(GameData.BuffTargetType.GROUP_MEMBER_START+5)
	end

	-- : broadcast entities
	if EntitiesBroadcastRequired.isRequired then
		RVAPI_Entities.OnEntitiesUpdated()
	end
end

--------------------------------------------------------------
-- function OnPlayerTargetUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnPlayerTargetUpdated(targetClassification, targetId, targetType)
	-- |targetClassification: selfhostiletarget,selffriendlytarget,mouseovertarget | --
	-- |targetId: unique id for target in zone | --
	-- |targetType: 0 = No Target, 1 = Player, 2 = Player's Pet, 3 = Friendly PC, 4 = Friendly NPC/Pet, 5 = Hostile Player, 6 = Hostile NPC/Pet

	-- First step: save old entityId
	local OldTargetId = Objects[targetClassification]

	-- Second step: update objects data
	Objects[targetClassification] = targetId

	-- Third step: update old entity data
	if OldTargetId > 0 and OldTargetId ~= targetId then

		-- : get entity data
		local EntityData = RVAPI_Entities.API_GetEntityData(OldTargetId)

		-- : update entity data
		EntityData.IsMouseOvered	= OldTargetId == RVAPI_Entities.Objects.mouseovertarget
		if	(targetClassification == "selffriendlytarget" or targetClassification == "selfhostiletarget")
		then
			-- : set targeted flag
			EntityData.IsTargeted	= OldTargetId == Objects[targetClassification]

			-- : clear effects list if not a group member
			if not (EntityData.IsGroupMember) then
				EntityData.Effects	= {}
			end

			-- : set default range values if not in the formation
			if not (EntityData.IsGroupMember or EntityData.IsWarbandMember) then 

				-- : unregister target
				RVAPI_Range.API_UnregisterTarget(RVAPI_Entities, RVAPI_Entities.OnTargetRangeUpdated, EntityData.Name)

				-- : set unlimited range to the entity
				EntityData.RangeMin	= RVAPI_Range.Ranges.MIN_RANGE
				EntityData.RangeMax	= RVAPI_Range.Ranges.MAX_RANGE
			end
		end

		-- Sixth step: set everything to the entities DB
		RVAPI_Entities.API_SetEntityData(OldTargetId, EntityData)
	end

	-- Third step: check for provided entityId
	if targetId > 0 then

		-- Fourth step: start collecting data
		local targetData				= GetUpdatedTargets()[targetClassification]
		local EntityData				= RVAPI_Entities.API_GetEntityData(targetId)

		EntityData.IsNPC				= targetData.isNPC
		EntityData.IsPVP				= targetData.isPvP
		EntityData.IsSelf				= targetType == SystemData.TargetObjectType.SELF
		EntityData.IsPet				= targetType == 2
		EntityData.ConType				= targetData.conType
		EntityData.Title				= targetData.npcTitle
		EntityData.ShowHealthBar		= targetData.showHealthBar
		EntityData.CareerLine			= targetData.career
		EntityData.Tier					= targetData.tier
		EntityData.Level				= targetData.level
		EntityData.EntityType			= targetData.type
		EntityData.HitPointPercent		= targetData.healthPercent

		if EntityData.IsSelf then
			EntityData.ActionPointPercent	= GameData.Player.actionPoints.current*100/GameData.Player.actionPoints.maximum
		end

		EntityData.RelationshipColor	= targetData.relationshipColor
		EntityData.MapPinType			= targetData.mapPinType
		EntityData.SigilEntryId			= targetData.sigilEntryId
		EntityData.CareerName			= targetData.careerName
		EntityData.DifficultyMask		= targetData.difficultyMask
		EntityData.Name					= wstring.gsub(targetData.name, L"(^.)", L"")
		EntityData.IsMouseOvered		= targetId == RVAPI_Entities.Objects.mouseovertarget
		if targetClassification == "selffriendlytarget" or targetClassification == "selfhostiletarget" then

			-- : set the targeted flag
			EntityData.IsTargeted		= targetId == Objects[targetClassification]

			-- : check if Entity is not in the formation and this is a new target
			if not (EntityData.IsGroupMember or EntityData.IsWarbandMember) and OldTargetId ~= targetId then

				-- : track the target distance
				RVAPI_Range.API_RegisterTarget(RVAPI_Entities, RVAPI_Entities.OnTargetRangeUpdated, EntityData.Name, RVAPI_Entities.CurrentConfiguration.DistanceUpdateDelay, RVAPI_Range.DelayType.DELAY_EXACT_TIME, {EntityId = EntityData.EntityId})
			end
		end

		-- Sixth step: set everything to the entities DB
		RVAPI_Entities.API_SetEntityData(targetId, EntityData)
	end

	-- Final step: generate ENTITY_PLAYER_TARGET_UPDATED event
	RVAPI_Entities.BroadcastEvent(RVAPI_Entities.Events.ENTITY_PLAYER_TARGET_UPDATED, {TargetClassification = targetClassification, OldTargetId = OldTargetId, NewTargetId = targetId, TargetType = targetType})
end

--------------------------------------------------------------
-- function OnTargetRangeUpdated()
-- Description: 
--------------------------------------------------------------
function RVAPI_Entities.OnTargetRangeUpdated(Self, Distances, RangeType, UserData)

	-- First step: check for the UserData
	if UserData.EntityId > 0 then

		-- Second step: get an EntityData
		local EntityData	= RVAPI_Entities.API_GetEntityData(UserData.EntityId)
		local RangeMin		= RVAPI_Range.Ranges.MIN_RANGE
		local RangeMax		= RVAPI_Range.Ranges.MAX_RANGE

		-- Third step: check for the range type
		if RangeType == RVAPI_Range.RangeType.RANGE_TYPE_SPELLS then

			-- : update range values
			RangeMin		= Distances[1].RangeMin
			RangeMax		= Distances[1].RangeMax

		elseif RangeType == RVAPI_Range.RangeType.RANGE_TYPE_MAP then

			-- : list all available targets
			for DistanceIndex, DistanceData in ipairs(Distances) do

				-- : get the most close distance to the named target
				-- TODO: (MrAngel)	it won't work correctly in some cases, for example if we have
				--					two and more "Mailboxes" in the area. Probably will do a better
				--					calculation here later
				RangeMax	= math.min(DistanceData.RangeMax, RangeMax)
				RangeMin	= RangeMax
			end
		end

		-- Fourth step: update the entity range
		EntityData.RangeMin	= RangeMin
		EntityData.RangeMax	= RangeMax

		-- Final step: set everything to the entities DB
		RVAPI_Entities.API_SetEntityData(UserData.EntityId, EntityData)
	end
end
--[[
TODO: (MrAngel) will be implemented in the next release
function RVAPI_Entities.OnPlayerCurActionPointsUpdatedProxy()
end

function RVAPI_Entities.OnPlayerMaxActionPointsUpdatedProxy()
end

function RVAPI_Entities.OnPlayerCurHitPointsUpdatedProxy()
end

function RVAPI_Entities.OnPlayerMaxHitPointsUpdatedProxy()
end

function RVAPI_Entities.OnPlayerZoneChangedProxy()
end

function RVAPI_Entities.OnPlayerBattleLevelUpdatedProxy()
end

function RVAPI_Entities.OnPlayerRvRFlagUpdatedProxy()
end

function RVAPI_Entities.OnPlayerCareerRankUpdatedProxy()
end

function RVAPI_Entities.OnPlayerMoraleUpdatedProxy(moralePercent, moraleLevel)

	d(moralePercent.." : "..moraleLevel)
end

function RVAPI_Entities.OnPlayerPetHealthUpdatedProxy()
end

function RVAPI_Entities.OnPlayerGroupLeaderStatusUpdatedProxy()
end

function RVAPI_Entities.OnPlayerMainAssistUpdatedProxy(playerIsMainAssist)
end

function RVAPI_Entities.OnPlayerCareerLineUpdatedProxy()
end

function RVAPI_Entities.OnGroupSettingsUpdatedProxy()
end
]]

--------------------------------------------------------------
-- function OnGroupUpdatedProxy()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnGroupUpdatedProxy()

	-- First step: set update required
	GroupUpdateRequired = true
end

--------------------------------------------------------------
-- function OnGroupUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnGroupUpdated()

	-- First step: set update is not required anymore
	GroupUpdateRequired = false

	-- Second step: check warband is not active and for scenario is active
	if not IsWarBandActive() or GameData.Player.isInScenario then

		-- Third step: update formation entities
		RVAPI_Entities.UpdateFormationEntities()
	end

	-- Final step: generate GROUP_UPDATED event
	RVAPI_Entities.BroadcastEvent(RVAPI_Entities.Events.ENTITY_GROUP_UPDATED, {})
end

--------------------------------------------------------------
-- function OnGroupStatusUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnGroupStatusUpdated(MemberIndex)

	-- First step: check for scenario is active
	if not IsWarBandActive() or GameData.Player.isInScenario then

		-- Second step: get member data from the first group
		local MemberData = RVAPI_Entities.GetFormationMember(1, MemberIndex)

		-- Third step: update member entity in the first group
		RVAPI_Entities.UpdateFormationMemberEntity(1, MemberIndex, MemberData)
	end

	-- Final step: generate ENTITY_GROUP_MEMBER_UPDATED event
	RVAPI_Entities.BroadcastEvent(RVAPI_Entities.Events.ENTITY_GROUP_MEMBER_UPDATED, {MemberIndex = MemberIndex})
end

--------------------------------------------------------------
-- function OnBattlegroupUpdatedProxy()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnBattlegroupUpdatedProxy()

	-- First step: set update required
	BattlegroupUpdateRequired = true
end

--------------------------------------------------------------
-- function OnBattlegroupUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnBattlegroupUpdated()

	-- First step: set update is not required anymore
	BattlegroupUpdateRequired = false

	-- Second step: check for warband is active
	if IsWarBandActive() and not GameData.Player.isInScenario then

		-- Third step: update formation entities
		RVAPI_Entities.UpdateFormationEntities()
	end

	-- Final step: generate ENTITY_BATTLEGROUP_UPDATED event
	RVAPI_Entities.BroadcastEvent(RVAPI_Entities.Events.ENTITY_BATTLEGROUP_UPDATED, {})
end

--------------------------------------------------------------
-- function OnBattlegroupMemberUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnBattlegroupMemberUpdated(PartyIndex, MemberIndex)

	-- First step: check for warband is active
	if IsWarBandActive() and not GameData.Player.isInScenario then

		-- Second step: get member data
		local MemberData = RVAPI_Entities.GetFormationMember(PartyIndex, MemberIndex)

		-- Third step: update member entity
		RVAPI_Entities.UpdateFormationMemberEntity(PartyIndex, MemberIndex, MemberData)
	end

	-- Final step: generate ENTITY_BATTLEGROUP_MEMBER_UPDATED event
	RVAPI_Entities.BroadcastEvent(RVAPI_Entities.Events.ENTITY_BATTLEGROUP_MEMBER_UPDATED, {PartyIndex = PartyIndex, MemberIndex = MemberIndex})
end

--------------------------------------------------------------
-- function OnPlayerPetUpdatedProxy()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnPlayerPetUpdatedProxy()

	-- First step: set update required
	PetUpdateRequired = true
end

--------------------------------------------------------------
-- function OnPlayerPetHealthUpdatedProxy()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnPlayerPetHealthUpdatedProxy()

	-- First step: set update required
	PetUpdateRequired = true
end

--------------------------------------------------------------
-- function OnPlayerPetStateUpdatedProxy()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnPlayerPetStateUpdatedProxy()

	-- First step: set update required
	PetUpdateRequired = true
end

--------------------------------------------------------------
-- function OnPlayerPetUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnPlayerPetUpdated()

	-- First step: set update is not required anymore
	PetUpdateRequired = false

	-- Second step: set locals
	local PetData = GameData.Player.Pet

	-- Third step: set pet entityId
	RVAPI_Entities.Objects.pet = PetData.objNum

	-- Fourth step: check for provided entityId
	if PetData.objNum > 0 then

		-- Fifth step: start collecting data
		local EntityData = RVAPI_Entities.API_GetEntityData(PetData.objNum)

		EntityData.EntityType		= 2
		EntityData.Name				= wstring.gsub(PetData.name, L"(^.)", L"")
		EntityData.Level			= PetData.level
		EntityData.Tier				= PetData.tier
		EntityData.IsNPC			= true
		EntityData.IsPet			= true
		EntityData.HitPointPercent	= PetData.healthPercent
		EntityData.IsDistant		= false
		EntityData.IsInSameRegion	= true
		EntityData.ConType			= PetData.conType

		-- Sixth step: set everything to the entities DB
		RVAPI_Entities.API_SetEntityData(PetData.objNum, EntityData)
	end

	-- Final step: generate ENTITY_PLAYER_PET_UPDATED event
	RVAPI_Entities.BroadcastEvent(RVAPI_Entities.Events.ENTITY_PLAYER_PET_UPDATED, {PetData = PetData})
end

--------------------------------------------------------------
-- function OnPlayerEffectsUpdatedProxy()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnPlayerEffectsUpdatedProxy(updatedEffects, isFullList)

	-- First step: emulate effects updated event
	RVAPI_Entities.OnEffectsUpdatedProxy(GameData.BuffTargetType.SELF, updatedEffects, isFullList)
end

--------------------------------------------------------------
-- function OnEffectsUpdatedProxy()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnEffectsUpdatedProxy(updateType, updatedEffects, isFullList)
	-- updatedEffects can either be a full or differential table (i.e. contain all buffs, or only contain entries that have changed).
	-- isFullList will be true if it is a full table, or false if it is differential.
	-- updatedEffects will take the form (for each buff): updatedEffects[ EFFECT INDEX ] = { EFFECT DATA }
	-- For differential "remove" entries, [ EFFECT DATA ] will be an empty table.

	-- : define update flags
	if (updateType == GameData.BuffTargetType.SELF) then

		EffectsSelfUpdateRequired		= true

	elseif (updateType == GameData.BuffTargetType.TARGET_FRIENDLY) then

		EffectsFriendlyUpdateRequired	= true

	elseif (updateType == GameData.BuffTargetType.TARGET_HOSTILE) then

		EffectsHostileUpdateRequired	= true

	elseif (updateType == GameData.BuffTargetType.GROUP_MEMBER_START) then

		EffectsMember1UpdateRequired	= true

	elseif (updateType == GameData.BuffTargetType.GROUP_MEMBER_START+1) then

		EffectsMember2UpdateRequired	= true

	elseif (updateType == GameData.BuffTargetType.GROUP_MEMBER_START+2) then

		EffectsMember3UpdateRequired	= true

	elseif (updateType == GameData.BuffTargetType.GROUP_MEMBER_START+3) then

		EffectsMember4UpdateRequired	= true

	elseif (updateType == GameData.BuffTargetType.GROUP_MEMBER_START+4) then

		EffectsMember5UpdateRequired	= true

	elseif (updateType == GameData.BuffTargetType.GROUP_MEMBER_START+5) then

		EffectsMember6UpdateRequired	= true

	end
end

--------------------------------------------------------------
-- function OnEffectsUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnEffectsUpdated(UpdateType)

	-- First step: define locals
	local EntityId = 0

	-- Second step: calculate EntityId
	if (UpdateType == GameData.BuffTargetType.SELF) then

		EffectsSelfUpdateRequired		= false
		EntityId						= Objects.self

	elseif (UpdateType == GameData.BuffTargetType.TARGET_FRIENDLY) then

		EffectsFriendlyUpdateRequired	= false
		EntityId						= Objects.selffriendlytarget

	elseif (UpdateType == GameData.BuffTargetType.TARGET_HOSTILE) then

		EffectsHostileUpdateRequired	= false
		EntityId						= Objects.selfhostiletarget

	elseif (UpdateType == GameData.BuffTargetType.GROUP_MEMBER_START) then

		EffectsMember1UpdateRequired	= false
		EntityId						= Objects.groupmembers[UpdateType + 1]

	elseif (UpdateType == GameData.BuffTargetType.GROUP_MEMBER_START+1) then

		EffectsMember2UpdateRequired	= false
		EntityId						= Objects.groupmembers[UpdateType + 1]

	elseif (UpdateType == GameData.BuffTargetType.GROUP_MEMBER_START+2) then

		EffectsMember3UpdateRequired	= false
		EntityId						= Objects.groupmembers[UpdateType + 1]

	elseif (UpdateType == GameData.BuffTargetType.GROUP_MEMBER_START+3) then

		EffectsMember4UpdateRequired	= false
		EntityId						= Objects.groupmembers[UpdateType + 1]

	elseif (UpdateType == GameData.BuffTargetType.GROUP_MEMBER_START+4) then

		EffectsMember5UpdateRequired	= false
		EntityId						= Objects.groupmembers[UpdateType + 1]

	elseif (UpdateType == GameData.BuffTargetType.GROUP_MEMBER_START+5) then

		EffectsMember6UpdateRequired	= false
		EntityId						= Objects.groupmembers[UpdateType + 1]

	end

	-- Third step: set affects for a specific EntityId
	if (EntityId > 0) then

		-- : get entity data
		local EntityData = RVAPI_Entities.API_GetEntityData(EntityId)

		-- : set new effects list
		EntityData.Effects = GetBuffs(UpdateType)

		-- : save entity data
		RVAPI_Entities.API_SetEntityData(EntityId, EntityData)
	end
end

--------------------------------------------------------------
-- function OnEntitiesUpdated()
-- Description:
-------------------------------------------------------------
function RVAPI_Entities.OnEntitiesUpdated()

	-- First step: set update is not required anymore
	EntitiesBroadcastRequired.isRequired = false

	-- Second step: list all entities for broadcasting
	for EntityId, EntityBroadcastRequired in pairs(EntitiesBroadcastRequired.Entities) do

		-- : check if its realy need to broadcast
		if EntityBroadcastRequired then

			-- : get entity data
			local EntityData = RVAPI_Entities.API_GetEntityData(EntityId)

			-- : generate ENTITY_UPDATED event
			RVAPI_Entities.BroadcastEvent(RVAPI_Entities.Events.ENTITY_UPDATED, {EntityId = EntityId, EntityData = EntityData})
		end
	end

	-- Third step: clear entities list
	EntitiesBroadcastRequired.Entities = {}
end

--------------------------------------------------------------
-- function GetEventHandlerIndex
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.GetEventHandlerIndex(Event, CallbackOwner, CallbackFunction)

	-- First step: try to find event handler
	if EventCallbacks[Event] ~= nil then
		for k, callbck in ipairs(EventCallbacks[Event]) do
			if callbck.Owner == CallbackOwner and callbck.Func == CallbackFunction then

				-- : return found index
				return k
			end
		end
	end

	-- Final step: return unsuccessful index
	return 0
end


--------------------------------------------------------------------------------
--								RVAPI_Entities API							  --
--------------------------------------------------------------------------------

--------------------------------------------------------------
-- function API_RegisterEventHandler
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.API_RegisterEventHandler(Event, CallbackOwner, CallbackFunction)

	-- First step: initialize event base if needed
	if EventCallbacks[Event] == nil then
		EventCallbacks[Event] = {}
	end

	-- Second step: find event handler index
	local EventHandlerIndex = RVAPI_Entities.GetEventHandlerIndex(Event, CallbackOwner, CallbackFunction)

	-- Final step: check if handler does not exists yet
	if EventHandlerIndex <= 0 then

		-- : insert new event handler
		table.insert(EventCallbacks[Event], {Owner = CallbackOwner, Func = CallbackFunction})

		-- : turn the system ON
		RVAPI_Entities.API_StartSystem()
	end
end

--------------------------------------------------------------
-- function API_UnregisterEventHandler
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.API_UnregisterEventHandler(Event, CallbackOwner, CallbackFunction)

	-- First step: find event handler index
	local EventHandlerIndex = RVAPI_Entities.GetEventHandlerIndex(Event, CallbackOwner, CallbackFunction)

	-- Second step: remove event handler if needed
	if EventHandlerIndex > 0 then

		-- : remove event handler from the system
		table.remove(EventCallbacks[Event], EventHandlerIndex)

		-- : turn the system OFF
		RVAPI_Entities.API_StopSystem()
	end
end

--------------------------------------------------------------
-- function API_GetEntityData
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.API_GetEntityData(entityId)

	-- First step: check for provided entityId
	if entityId < 1 then
		return nil
	end

	-- Second step: check for existing record
	if Entities[entityId] == nil then
		Entities[entityId] = RVAPI_Entities.GetDefaultEntity(entityId)
	end

	-- Final step: return result
	return Entities[entityId]
end

--------------------------------------------------------------
-- function API_SetEntityData
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.API_SetEntityData(entityId, entityData)

	-- First step: check for input data
	if entityId < 1 or entityData == nil then
		return
	end

	-- Second step: get existing record
	local CurrentEntityData = RVAPI_Entities.API_GetEntityData(entityId)

	-- Third step: check for provided table
	if CurrentEntityData ~= entityData then

		-- Fourth step: list all data and save them one by one
		for k,v in pairs(CurrentEntityData) do

			if entityData[k] ~= nil then
				CurrentEntityData[k] = entityData[k]
			end
		end
	end

	-- Final step: mark entity for broadcasting
	EntitiesBroadcastRequired.isRequired			= true
	EntitiesBroadcastRequired.Entities[entityId]	= true
end

--------------------------------------------------------------
-- function API_UpdateSystem
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.API_UpdateSystem()

	-- First step: set the current player EntityId
	--			   the rest objects should be set automaticaly
	Objects.self = GameData.Player.worldObjNum

	-- TODO: (MrAngel) place "update all entities" code here
end

--------------------------------------------------------------
-- function API_ResetSystem
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.API_ResetSystem()

	-- First step: reset all known entities
	for k, entity in pairs(Entities) do

		-- : clear entity data
		Entities[k] = nil
	end

	-- Second step: clear all objects information
	-- for k, object in pairs(Objects) do

		-- : crear object information
	-- 	Objects[k] = 0
	-- end

	-- Final step:	unregister all targets from the RVAPI_Range addon, since
	--				we don't need to track the names anymore
	RVAPI_Range.API_UnregisterTarget(RVAPI_Entities, RVAPI_Entities.OnTargetRangeUpdated, nil)
end

--------------------------------------------------------------
-- function API_StartSystem
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.API_StartSystem()

	-- : check if system event handlers are activated
	if	RegisterEventHandlersCounter <= 0 then

		-- : it is time to re-collect all available information from the game
		-- : we should do that just before the activating the system
		RVAPI_Entities.API_UpdateSystem()

		-- : register all events are needed to start the system
		RegisterEventHandler(SystemData.Events.LOADING_BEGIN,							"RVAPI_Entities.OnLoadingBegin")
		RegisterEventHandler(SystemData.Events.LOADING_END,								"RVAPI_Entities.OnLoadingEnd")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED,					"RVAPI_Entities.OnPlayerTargetUpdated")
--[[
		TODO: (MrAngel) will be implemented in the next release
		RegisterEventHandler(SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED,		"RVAPI_Entities.OnPlayerCurActionPointsUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_MAX_ACTION_POINTS_UPDATED,		"RVAPI_Entities.OnPlayerMaxActionPointsUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED,			"RVAPI_Entities.OnPlayerCurHitPointsUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED,			"RVAPI_Entities.OnPlayerMaxHitPointsUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED,						"RVAPI_Entities.OnPlayerZoneChangedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_BATTLE_LEVEL_UPDATED,				"RVAPI_Entities.OnPlayerBattleLevelUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_RVR_FLAG_UPDATED,					"RVAPI_Entities.OnPlayerRvRFlagUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_CAREER_RANK_UPDATED,				"RVAPI_Entities.OnPlayerCareerRankUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_MORALE_UPDATED,					"RVAPI_Entities.OnPlayerMoraleUpdatedProxy")
--		RegisterEventHandler(SystemData.Events.PLAYER_PET_HEALTH_UPDATED,				"RVAPI_Entities.OnPlayerPetHealthUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_GROUP_LEADER_STATUS_UPDATED,		"RVAPI_Entities.OnPlayerGroupLeaderStatusUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_MAIN_ASSIST_UPDATED,				"RVAPI_Entities.OnPlayerMainAssistUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_CAREER_LINE_UPDATED,				"RVAPI_Entities.OnPlayerCareerLineUpdatedProxy")
		RegisterEventHandler(SystemData.Events.GROUP_SETTINGS_UPDATED,					"RVAPI_Entities.OnGroupSettingsUpdatedProxy")
]]
		RegisterEventHandler(SystemData.Events.GROUP_UPDATED,							"RVAPI_Entities.OnGroupUpdatedProxy")
		RegisterEventHandler(SystemData.Events.GROUP_STATUS_UPDATED,					"RVAPI_Entities.OnGroupStatusUpdated")
		RegisterEventHandler(SystemData.Events.BATTLEGROUP_UPDATED,						"RVAPI_Entities.OnBattlegroupUpdatedProxy")
		RegisterEventHandler(SystemData.Events.BATTLEGROUP_MEMBER_UPDATED,				"RVAPI_Entities.OnBattlegroupMemberUpdated")
		RegisterEventHandler(SystemData.Events.PLAYER_PET_UPDATED,						"RVAPI_Entities.OnPlayerPetUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_PET_HEALTH_UPDATED,				"RVAPI_Entities.OnPlayerPetHealthUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_PET_STATE_UPDATED,				"RVAPI_Entities.OnPlayerPetStateUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED,					"RVAPI_Entities.OnPlayerEffectsUpdatedProxy")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED,			"RVAPI_Entities.OnEffectsUpdatedProxy")
		RegisterEventHandler(SystemData.Events.GROUP_EFFECTS_UPDATED,					"RVAPI_Entities.OnEffectsUpdatedProxy")
	end

	-- : save the new amount of cals from the addOns
	RegisterEventHandlersCounter = RegisterEventHandlersCounter + 1

-- PLAYER_TARGET_EFFECTS_UPDATED
-- PLAYER_TARGET_HIT_POINTS_UPDATED
-- PLAYER_TARGET_STATE_UPDATED
-- PLAYER_PET_UPDATED
-- PLAYER_PET_HEALTH_UPDATED
-- PLAYER_PET_STATE_UPDATED
-- PLAYER_PET_TARGET_HEALTH_UPDATED
-- PLAYER_PET_TARGET_UPDATED
-- PLAYER_EFFECTS_UPDATED
-- PLAYER_POSITION_UPDATED 
-- SIEGE_WEAPON_SNIPER_AIM_TARGET_LOS_UPDATED
-- SIEGE_WEAPON_SNIPER_AIM_TARGET_UPDATED 
-- TARGET_GROUP_MEMBER_1
-- TARGET_GROUP_MEMBER_2
-- TARGET_GROUP_MEMBER_3
-- TARGET_GROUP_MEMBER_4
-- TARGET_GROUP_MEMBER_5
-- TARGET_GROUP_MEMBER_6
-- TARGET_SELF 
-- BATTLEGROUP_UPDATED
-- BATTLEGROUP_MEMBER_UPDATED
-- GROUP_UPDATED
-- GROUP_EFFECTS_UPDATED
-- SCENARIO_PLAYERS_LIST_GROUPS_UPDATED
-- SCENARIO_PLAYERS_LIST_RESERVATIONS_UPDATED
-- SCENARIO_PLAYERS_LIST_STATS_UPDATED
-- SCENARIO_PLAYERS_LIST_UPDATED
end

--------------------------------------------------------------
-- function API_StopSystem
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.API_StopSystem()

	-- : check if system event handlers are activated and addOn event handler counter is ZERO
	-- : in other words check if anybody still wants to be that system ON
	if	RegisterEventHandlersCounter == 1 then

		-- : unregister all events are needed to work the system
		UnregisterEventHandler(SystemData.Events.LOADING_BEGIN,								"RVAPI_Entities.OnLoadingBegin")
		UnregisterEventHandler(SystemData.Events.LOADING_END,								"RVAPI_Entities.OnLoadingEnd")
		UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED,						"RVAPI_Entities.OnPlayerTargetUpdated")
--[[
		TODO: (MrAngel) will be implemented in the next release
		UnregisterEventHandler(SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED,			"RVAPI_Entities.OnPlayerCurActionPointsUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_MAX_ACTION_POINTS_UPDATED,			"RVAPI_Entities.OnPlayerMaxActionPointsUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED,				"RVAPI_Entities.OnPlayerCurHitPointsUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED,				"RVAPI_Entities.OnPlayerMaxHitPointsUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED,						"RVAPI_Entities.OnPlayerZoneChangedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_BATTLE_LEVEL_UPDATED,				"RVAPI_Entities.OnPlayerBattleLevelUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_RVR_FLAG_UPDATED,					"RVAPI_Entities.OnPlayerRvRFlagUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_CAREER_RANK_UPDATED,				"RVAPI_Entities.OnPlayerCareerRankUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_MORALE_UPDATED,						"RVAPI_Entities.OnPlayerMoraleUpdatedProxy")
--		UnregisterEventHandler(SystemData.Events.PLAYER_PET_HEALTH_UPDATED,					"RVAPI_Entities.OnPlayerPetHealthUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_GROUP_LEADER_STATUS_UPDATED,		"RVAPI_Entities.OnPlayerGroupLeaderStatusUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_MAIN_ASSIST_UPDATED,				"RVAPI_Entities.OnPlayerMainAssistUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_CAREER_LINE_UPDATED,				"RVAPI_Entities.OnPlayerCareerLineUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.GROUP_SETTINGS_UPDATED,					"RVAPI_Entities.OnGroupSettingsUpdatedProxy")
]]
		UnregisterEventHandler(SystemData.Events.GROUP_UPDATED,								"RVAPI_Entities.OnGroupUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.GROUP_STATUS_UPDATED,						"RVAPI_Entities.OnGroupStatusUpdated")
		UnregisterEventHandler(SystemData.Events.BATTLEGROUP_UPDATED,						"RVAPI_Entities.OnBattlegroupUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.BATTLEGROUP_MEMBER_UPDATED,				"RVAPI_Entities.OnBattlegroupMemberUpdated")
		UnregisterEventHandler(SystemData.Events.PLAYER_PET_UPDATED,						"RVAPI_Entities.OnPlayerPetUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_PET_HEALTH_UPDATED,					"RVAPI_Entities.OnPlayerPetHealthUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_PET_STATE_UPDATED,					"RVAPI_Entities.OnPlayerPetStateUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED,					"RVAPI_Entities.OnPlayerEffectsUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED,				"RVAPI_Entities.OnEffectsUpdatedProxy")
		UnregisterEventHandler(SystemData.Events.GROUP_EFFECTS_UPDATED,						"RVAPI_Entities.OnEffectsUpdatedProxy")

		-- : remove all collected information from the system
		RVAPI_Entities.API_ResetSystem()
	end

	-- : save the new amount of cals from the addOns
	RegisterEventHandlersCounter = RegisterEventHandlersCounter - 1
	if RegisterEventHandlersCounter < 0 then
		RegisterEventHandlersCounter = 0
	end
end

--------------------------------------------------------------
-- function API_IsSystemActive
-- Description:
--------------------------------------------------------------
function RVAPI_Entities.API_IsSystemActive()

	-- : return the current system status
	return RegisterEventHandlersCounter > 0
end
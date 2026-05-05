RVMOD_Targets				= {}



local pairs = pairs
local ipairs = ipairs



local RVMOD_Targets			= RVMOD_Targets

local RVName				= "Targets / Frames"
local RVCredits				= "silverq, rozbuska"
local RVLicense				= "MIT License"
local RVProjectURL			= "http://www.returnofreckoning.com/forum/viewtopic.php?f=11&t=4534"
local RVRecentUpdates		= 
"09.07.2015 - v1.13 Release\n"..
"\t- Project official site location has been changed\n"..
"\n"..
"25.07.2010 - v1.12 Release\n"..
"\t- Small code improvements\n"..
"\n"..
"24.02.2010 - v1.11 Release\n"..
"\t- Code clearance\n"..
"\t- Adapted to work with the RV Mods Manager v0.99"

local CONDITION_ALLY_PLAYER				= 1
local CONDITION_ALLY_NON_PLAYER			= 2
local CONDITION_ENEMY_PLAYER			= 3
local CONDITION_ENEMY_NON_PLAYER		= 4
local CONDITION_STATIC					= 5
local CONDITION_STATIC_ATTACKABLE		= 6
local CONDITION_SELF					= 7
local CONDITION_PET						= 8
local CONDITION_GROUP_MEMBERS			= 9
local CONDITION_WARBAND_MEMBERS			= 10
local CONDITION_SCENARIO_GROUP_MEMBERS	= 11
local CONDITION_LEADERS					= 12
local CONDITION_ASSISTANTS				= 13
local CONDITION_MAINASSISTS				= 14
local CONDITION_MASTERLOOTERS			= 15
local CONDITION_DONT_SHOW_TARGETED		= 16
local CONDITION_DONT_SHOW_MOUSEOVERED	= 17

local CLASS_MOUSEOVERTARGET				= 1
local CLASS_SELFFRIENDLYTARGET			= 2
local CLASS_SELFHOSTILETARGET			= 3
local CLASS_FORMATION					= 4
local CLASS_PET							= 5

local FRAMES_PER_MOUSEOVERTARGET		= 1
local FRAMES_PER_FRIENDLYTARGET			= 1
local FRAMES_PER_HOSTILETARGET			= 1
local FRAMES_PER_GROUP					= PartyUtils.PLAYERS_PER_PARTY
local FRAMES_PER_FORMATION				= PartyUtils.PARTIES_PER_WARBAND * PartyUtils.PLAYERS_PER_PARTY
local FRAMES_PER_PET					= 1

local LastComboBoxName		= "" -- : hack, but no other way to do that at the moment
local WindowSettings		= "RVMOD_TargetsSettingsWindow"
local WindowFrame			= "RVMOD_TargetsFrame"
local Templates				= {}
local LastFrameId			= 1
local Frames				= {}
local RuleTypes				= {}
RuleTypes[CLASS_MOUSEOVERTARGET]		= {
	MaxFrames							= FRAMES_PER_MOUSEOVERTARGET,
	Conditions							= {
		{
			Name						= "Ally players",
			Condition					= CONDITION_ALLY_PLAYER,
		},
		{
			Name						= "Ally NPC's",
			Condition					= CONDITION_ALLY_NON_PLAYER,
		},
		{
			Name						= "Enemy players",
			Condition					= CONDITION_ENEMY_PLAYER,
		},
		{
			Name						= "Enemy NPC's / Monsters",
			Condition					= CONDITION_ENEMY_NON_PLAYER,
		},
		{
			Name						= "Static objects",
			Condition					= CONDITION_STATIC,
		},
		{
			Name						= "Attackable static",
			Condition					= CONDITION_STATIC_ATTACKABLE,
		},
		{
			Name						= "Self",
			Condition					= CONDITION_SELF,
		},
		{
			Name						= "Pet",
			Condition					= CONDITION_PET,
		},
		{
			Name						= "Hide when targeted",
			Condition					= CONDITION_DONT_SHOW_TARGETED,
		},
	},
}
RuleTypes[CLASS_SELFFRIENDLYTARGET]		= {
	MaxFrames							= FRAMES_PER_FRIENDLYTARGET,
	Conditions							= {
		{
			Name						= "Ally players",
			Condition					= CONDITION_ALLY_PLAYER,
		},
		{
			Name						= "Ally NPC's",
			Condition					= CONDITION_ALLY_NON_PLAYER,
		},
		{
			Name						= "Static objects",
			Condition					= CONDITION_STATIC,
		},
		{
			Name						= "Self",
			Condition					= CONDITION_SELF,
		},
		{
			Name						= "Pet",
			Condition					= CONDITION_PET,
		},
		{
			Name						= "Hide when mouseovered",
			Condition					= CONDITION_DONT_SHOW_MOUSEOVERED,
		},
	},
}
RuleTypes[CLASS_SELFHOSTILETARGET]		= {
	MaxFrames							= FRAMES_PER_HOSTILETARGET,
	Conditions							= {
		{
			Name						= "Enemy players",
			Condition					= CONDITION_ENEMY_PLAYER,
		},
		{
			Name						= "Enemy NPC's / Monsters",
			Condition					= CONDITION_ENEMY_NON_PLAYER,
		},
		{
			Name						= "Static objects",
			Condition					= CONDITION_STATIC,
		},
		{
			Name						= "Attackable static",
			Condition					= CONDITION_STATIC_ATTACKABLE,
		},
		{
			Name						= "Hide when mouseovered",
			Condition					= CONDITION_DONT_SHOW_MOUSEOVERED,
		},
	},
}
RuleTypes[CLASS_FORMATION]				= {
	MaxFrames							= FRAMES_PER_FORMATION,
	Conditions							= {
		{
			Name						= "Group members",
			Condition					= CONDITION_GROUP_MEMBERS,
		},
		{
			Name						= "Warband members",
			Condition					= CONDITION_WARBAND_MEMBERS,
		},
		{
			Name						= "Scenario group members",
			Condition					= CONDITION_SCENARIO_GROUP_MEMBERS,
		},
		{
			Name						= "Leaders",
			Condition					= CONDITION_LEADERS,
		},
		{
			Name						= "Assistants",
			Condition					= CONDITION_ASSISTANTS,
		},
		{
			Name						= "Main assists",
			Condition					= CONDITION_MAINASSISTS,
		},
		{
			Name						= "Master looters",
			Condition					= CONDITION_MASTERLOOTERS,
		},
		{
			Name						= "Self",
			Condition					= CONDITION_SELF,
		},
		{
			Name						= "Hide when targeted",
			Condition					= CONDITION_DONT_SHOW_TARGETED,
		},
		{
			Name						= "Hide when mouseovered",
			Condition					= CONDITION_DONT_SHOW_MOUSEOVERED,
		},
	},
}
RuleTypes[CLASS_PET]					= {
	MaxFrames							= FRAMES_PER_PET,
	Conditions							= {
		{
			Name						= "Hide when targeted",
			Condition					= CONDITION_DONT_SHOW_TARGETED,
		},
		{
			Name						= "Hide when mouseovered",
			Condition					= CONDITION_DONT_SHOW_MOUSEOVERED,
		},
	},
}

--------------------------------------------------------------
-- var DefaultConfiguration
-- Description: default module configuration
--------------------------------------------------------------
RVMOD_Targets.DefaultConfiguration	=
{
	Rules						= {
		{
			Classification		= CLASS_MOUSEOVERTARGET,
			TemplateName		= "RVF_Classic",									-- optional
			Conditions			= {
				CONDITION_ALLY_PLAYER,
				CONDITION_ALLY_NON_PLAYER,
				CONDITION_ENEMY_PLAYER,
				CONDITION_ENEMY_NON_PLAYER,
				CONDITION_STATIC,
				CONDITION_STATIC_ATTACKABLE,
				CONDITION_SELF,
				CONDITION_PET,
--					CONDITION_DONT_SHOW_TARGETED,
			},
			Settings			= {},												-- required as {} by default
		},
		{
			Classification		= CLASS_SELFFRIENDLYTARGET,
			TemplateName		= "RVF_Classic",									-- optional
			Conditions			= {
				CONDITION_ALLY_PLAYER,
				CONDITION_ALLY_NON_PLAYER,
				CONDITION_STATIC,
				CONDITION_SELF,
				CONDITION_PET,
				CONDITION_DONT_SHOW_MOUSEOVERED,
			},
			Settings			= {},												-- required as {} by default
		},
		{
			Classification		= CLASS_SELFHOSTILETARGET,
			TemplateName		= "RVF_Classic",									-- optional
			Conditions			= {
				CONDITION_ENEMY_PLAYER,
				CONDITION_ENEMY_NON_PLAYER,
				CONDITION_STATIC,
				CONDITION_STATIC_ATTACKABLE,
				CONDITION_DONT_SHOW_MOUSEOVERED,
			},
			Settings			= {},												-- required as {} by default
		},
		{
			Classification		= CLASS_FORMATION,
			TemplateName		= "RVF_Classic",									-- optional
			Conditions			= {
				CONDITION_GROUP_MEMBERS,
				CONDITION_WARBAND_MEMBERS,
				CONDITION_SCENARIO_GROUP_MEMBERS,
				CONDITION_LEADERS,
				CONDITION_ASSISTANTS,
				CONDITION_MAINASSISTS,
				CONDITION_MASTERLOOTERS,
--					CONDITION_SELF,
				CONDITION_DONT_SHOW_TARGETED,
				CONDITION_DONT_SHOW_MOUSEOVERED,
			},
			Settings			= {},												-- required as {} by default
		},
		{
			Classification		= CLASS_PET,
			TemplateName		= "RVF_Classic",									-- optional
			Conditions			= {
				CONDITION_DONT_SHOW_TARGETED,
				CONDITION_DONT_SHOW_MOUSEOVERED,
			},
			Settings			= {},												-- required as {} by default
		},
	}
}

--------------------------------------------------------------
-- var CurrentConfiguration
-- Description: current module configuration
--------------------------------------------------------------
RVMOD_Targets.CurrentConfiguration =
{
	-- should stay empty, will load in the InitializeConfiguration() function
}

--------------------------------------------------------------
-- function Initialize()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.Initialize()

	-- First step: load configuration
	RVMOD_Targets.InitializeConfiguration()

	-- Second step: define event handlers
	RegisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "RVMOD_Targets.OnAllModulesInitialized")
end

--------------------------------------------------------------
-- function Shutdown()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.Shutdown()

	-- First step: destroy settings window
	if DoesWindowExist(WindowSettings) then
		DestroyWindow(WindowSettings)
	end

	-- Second step: unregister events
	RVAPI_Entities.API_UnregisterEventHandler(RVAPI_Entities.Events.ENTITY_PLAYER_TARGET_UPDATED, RVMOD_Targets, RVMOD_Targets.OnPlayerTargetUpdated)
	RVAPI_Entities.API_UnregisterEventHandler(RVAPI_Entities.Events.ENTITY_FORMATION_MEMBER_UPDATED, RVMOD_Targets, RVMOD_Targets.OnFormationMemberUpdated)
	RVAPI_Entities.API_UnregisterEventHandler(RVAPI_Entities.Events.ENTITY_PLAYER_PET_UPDATED, RVMOD_Targets, RVMOD_Targets.OnPlayerPetUpdated)
	UnregisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "RVMOD_Targets.OnAllModulesInitialized")

	-- Final step: disable rules
	for RuleIndex, Rule in ipairs(RVMOD_Targets.CurrentConfiguration.Rules) do
		RVMOD_Targets.DisableRule(RuleIndex)
	end

	-- NOTE (MrAngel) we won't clear the Frames list, it will become empty anyway
end

--------------------------------------------------------------
-- function InitializeConfiguration()
-- Description: loads current configuration
--------------------------------------------------------------
function RVMOD_Targets.InitializeConfiguration()

	-- First step: move default value to the CurrentConfiguration variable
	for k,v in pairs(RVMOD_Targets.DefaultConfiguration) do
		if(RVMOD_Targets.CurrentConfiguration[k]==nil) then
			RVMOD_Targets.CurrentConfiguration[k]=v
		end
	end
end

--------------------------------------------------------------
-- function InitializeSettingsWindow()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.InitializeSettingsWindow()

	-- First step: create main window
	CreateWindow(WindowSettings, true)

	LabelSetText(WindowSettings.."TCMouseOverTitle", L"Mouse Over")
	LabelSetTextColor(WindowSettings.."TCMouseOverTitle", 255, 255, 255)
	ButtonSetText(WindowSettings.."TCMouseOverAddToList", L"Add")
	WindowRegisterCoreEventHandler(WindowSettings.."TCMouseOverAddToList", "OnLButtonUp", "RVMOD_Targets.OnAddMouseOverRule")

	LabelSetText(WindowSettings.."TCSelfFriendlyTitle", L"Friendly")
	LabelSetTextColor(WindowSettings.."TCSelfFriendlyTitle", 255, 255, 255)
	ButtonSetText(WindowSettings.."TCSelfFriendlyAddToList", L"Add")
	WindowRegisterCoreEventHandler(WindowSettings.."TCSelfFriendlyAddToList", "OnLButtonUp", "RVMOD_Targets.OnAddSelfFriendlyRule")

	LabelSetText(WindowSettings.."TCSelfHostileTitle", L"Hostile")
	LabelSetTextColor(WindowSettings.."TCSelfHostileTitle", 255, 255, 255)
	ButtonSetText(WindowSettings.."TCSelfHostileAddToList", L"Add")
	WindowRegisterCoreEventHandler(WindowSettings.."TCSelfHostileAddToList", "OnLButtonUp", "RVMOD_Targets.OnAddSelfHostileRule")

	LabelSetText(WindowSettings.."TCFormationTitle", L"Formation")
	LabelSetTextColor(WindowSettings.."TCFormationTitle", 255, 255, 255)
	ButtonSetText(WindowSettings.."TCFormationAddToList", L"Add")
	WindowRegisterCoreEventHandler(WindowSettings.."TCFormationAddToList", "OnLButtonUp", "RVMOD_Targets.OnAddFormationRule")

	LabelSetText(WindowSettings.."TCPetTitle", L"Pet")
	LabelSetTextColor(WindowSettings.."TCPetTitle", 255, 255, 255)
	ButtonSetText(WindowSettings.."TCPetAddToList", L"Add")
	WindowRegisterCoreEventHandler(WindowSettings.."TCPetAddToList", "OnLButtonUp", "RVMOD_Targets.OnAddPetRule")
end

--------------------------------------------------------------
-- function OnRVManagerCallback
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.OnRVManagerCallback(Self, Event, EventData)

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

	elseif	Event == RVMOD_Manager.Events.PARENT_WINDOW_UPDATED then

		if not DoesWindowExist(WindowSettings) then
			RVMOD_Targets.InitializeSettingsWindow()
		end

		WindowSetParent(WindowSettings, EventData.ParentWindow)
		WindowClearAnchors(WindowSettings)
		WindowAddAnchor(WindowSettings, "topleft", EventData.ParentWindow, "topleft", 0, 0)
		WindowAddAnchor(WindowSettings, "bottomright", EventData.ParentWindow, "bottomright", 0, 0)

		RVMOD_Targets.UpdateSettingsWindow()

		return true

	end
end

--------------------------------------------------------------
-- function OnAllModulesInitialized()
-- Description: event ALL_MODULES_INITIALIZED
-- We can start working with the RVAPI just then we sure they are all initialized
-- and ready to provide their services
--------------------------------------------------------------
function RVMOD_Targets.OnAllModulesInitialized()

	-- First step: enable rules
	for RuleIndex, Rule in ipairs(RVMOD_Targets.CurrentConfiguration.Rules) do

		-- : create a frames table in the Frames list
		table.insert(Frames, {})

		-- : enable rule
		RVMOD_Targets.EnableRule(RuleIndex)

		-- : update rule
		-- TODO (MrAngel) do we need that at all?
--		RVMOD_Targets.UpdateByRuleIndex(RuleIndex)
	end

	-- Second step: register event handlers
	RVAPI_Entities.API_RegisterEventHandler(RVAPI_Entities.Events.ENTITY_PLAYER_TARGET_UPDATED, RVMOD_Targets, RVMOD_Targets.OnPlayerTargetUpdated)
	RVAPI_Entities.API_RegisterEventHandler(RVAPI_Entities.Events.ENTITY_FORMATION_MEMBER_UPDATED, RVMOD_Targets, RVMOD_Targets.OnFormationMemberUpdated)
	RVAPI_Entities.API_RegisterEventHandler(RVAPI_Entities.Events.ENTITY_PLAYER_PET_UPDATED, RVMOD_Targets, RVMOD_Targets.OnPlayerPetUpdated)

	-- Final step: register in the RV Mods Manager
	-- Please note the folowing:
	-- 1. always do this ON SystemData.Events.ALL_MODULES_INITIALIZED event
	-- 2. you don't need to add RVMOD_Manager to the dependency list
	-- 3. the registration code should be same as below, with your own function parameters
	-- 4. for more information please follow by project official site
	if RVMOD_Manager then
		RVMOD_Manager.API_RegisterAddon("RVMOD_Targets", RVMOD_Targets, RVMOD_Targets.OnRVManagerCallback)
	end
end

--------------------------------------------------------------
-- function UpdateSettingsWindow()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.UpdateSettingsWindow()

	-- First step: setup locals
	local TemplateList	= RVAPI_Frames.API_GetTemplatesList()
	local Rules			= RVMOD_Targets.CurrentConfiguration.Rules

	-- Second step: update Templates list, template comboboxes will be based on that list
	while table.remove(Templates) do end
	for TemplateIndex, TemplateData in pairs(TemplateList) do
		table.insert(Templates, TemplateData)
	end

	-- Third step: destroy frame rows, we will create them again
	local Index = 1
	while DoesWindowExist(WindowSettings.."FramesScrollChild"..Index) do
		DestroyWindow(WindowSettings.."FramesScrollChild"..Index)
		Index = Index + 1
	end

	-- Fourth step: loop through all rules
	for RuleIndex, Rule in ipairs(Rules) do

		-- : calculate frame and parent window names
		local frameWindow = WindowSettings.."FramesScrollChild"..RuleIndex
		local parentWindow = WindowSettings.."FramesScrollChild"

		-- : create new row
		CreateWindowFromTemplate( frameWindow, "RVMOD_TargetsFrameRowTemplate", parentWindow )
		if( RuleIndex == 1 )
		then
		    WindowAddAnchor( frameWindow, "topleft", parentWindow, "topleft", 0, 0 )
		    WindowAddAnchor( frameWindow, "topright", parentWindow, "topright", 0, 0 )
		else
		    WindowAddAnchor( frameWindow, "bottomleft", parentWindow..(RuleIndex-1), "topleft", 0, 0 )
		    WindowAddAnchor( frameWindow, "bottomright", parentWindow..(RuleIndex-1), "topright", 0, 0 )
		end
		WindowSetId( frameWindow, RuleIndex )

		-- : define background based on the Rule.Classification
		if	Rule.Classification == CLASS_MOUSEOVERTARGET then
			DynamicImageSetTexture( frameWindow.."Background", "TextureTypeMouseOver", 0, 0 )
		elseif	Rule.Classification == CLASS_SELFFRIENDLYTARGET then
			DynamicImageSetTexture( frameWindow.."Background", "TextureTypeFriendly", 0, 0 )
		elseif	Rule.Classification == CLASS_SELFHOSTILETARGET then
			DynamicImageSetTexture( frameWindow.."Background", "TextureTypeHostile", 0, 0 )
		elseif	Rule.Classification == CLASS_FORMATION then
			DynamicImageSetTexture( frameWindow.."Background", "TextureTypeFormation", 0, 0 )
		elseif	Rule.Classification == CLASS_PET then
			DynamicImageSetTexture( frameWindow.."Background", "TextureTypePet", 0, 0 )
		end

		-- : set default index for the Templates combobox
		ComboBoxAddMenuItem( frameWindow.."Templates", towstring("Select..."))
		ComboBoxSetSelectedMenuItem(frameWindow.."Templates", 1)

		-- : fill Templates combobox with Template names
		for TemplateIndex, TemplateData in ipairs(Templates) do

			-- : add new template in the list
			ComboBoxAddMenuItem( frameWindow.."Templates", towstring(TemplateData.TemplateName))

			-- : select current Template name
			if Rule.TemplateName == TemplateData.TableName then
				ComboBoxSetSelectedMenuItem(frameWindow.."Templates", TemplateIndex+1)
			end
		end

		-- : fill combobox with conditions
		RVMOD_Targets.RelistComboboxConditions(RuleIndex, frameWindow.."Types")

		-- : set labels
		LabelSetText(frameWindow.."LabelTemplates", L"Template:")
		LabelSetText(frameWindow.."LabelTypes", L"Filter:")

		-- : set buttons
		ButtonSetText(frameWindow.."Edit", L"Edit")
		ButtonSetText(frameWindow.."Delete", L"Delete")

		-- : set buttons disabled flag
		ButtonSetDisabledFlag(frameWindow.."Edit", Rule.TemplateName == nil)
	end

	-- Final step: hide and show list to update its contents
--    WindowSetShowing( WindowSettings.."Frames", false )
--    WindowSetShowing( WindowSettings.."Frames", true )
	ScrollWindowUpdateScrollRect(WindowSettings.."Frames")
--	ScrollWindowSetOffset(WindowSettings.."Frames", 100000)
end

--------------------------------------------------------------
-- function RelistComboboxConditions()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.RelistComboboxConditions(RuleIndex, ComboboxName)

	-- First step: define locals
	local CHECKBOX_CHECKED_ICON		= 57
	local CHECKBOX_UNCHECKED_ICON	= 58
	local ConditionFoundInList		= false
	local ComboboxTitleString		= ""
	local Rule						= RVMOD_Targets.CurrentConfiguration.Rules[RuleIndex]

	-- Second step: list all possible conditions
	for ConditionIndex, ConditionData in pairs(RuleTypes[Rule.Classification].Conditions) do

		-- Third step: find if its checked
		ConditionFoundInList = false
		for k, ConditionValue in pairs(Rule.Conditions) do
			if ConditionData.Condition == ConditionValue then
				ConditionFoundInList = true
				break
			end
		end

		-- Fourth step: add new item
		if ConditionFoundInList then
			if ComboboxTitleString == "" then
				ComboboxTitleString = ConditionData.Name
			else
				ComboboxTitleString = ComboboxTitleString..", "..ConditionData.Name
			end
			ComboBoxAddMenuItem( ComboboxName, towstring("<icon"..CHECKBOX_CHECKED_ICON..">  "..ConditionData.Name))
		else
			ComboBoxAddMenuItem( ComboboxName, towstring("<icon"..CHECKBOX_UNCHECKED_ICON..">  "..ConditionData.Name))
		end
	end

	-- Final step: set combobox title value
	ButtonSetText(ComboboxName.."SelectedButton", towstring(ComboboxTitleString))
end

--------------------------------------------------------------
-- function OnPlayerTargetUpdated()
-- Description: event PLAYER_TARGET_UPDATED
-- Basicaly we can have two targets only, friendly and hostile,
-- so we have to work with the targetClassification to define right target first and avoid additional calculation
--------------------------------------------------------------
function RVMOD_Targets.OnPlayerTargetUpdated(self, EventData)
	-- |targetClassification: selfhostiletarget,selffriendlytarget,mouseovertarget | --
	-- |targetId: unique id for target in zone | --
	-- |targetType: 0 = No Target, 1 = Player, 2 = Player's Pet, 3 = Friendly PC, 4 = Friendly NPC/Pet, 5 = Hostile Player, 6 = Hostile NPC/Pet

	-- First step: get rules
	local Rules = RVMOD_Targets.CurrentConfiguration.Rules
	local CurrentClass

	-- Second step: check for rules
	if Rules == nil then
		return
	end

	-- Third step: loop through all rules
	for RuleIndex, Rule in ipairs(Rules) do

		-- : start working with targets
		if	Rule.Classification == CLASS_MOUSEOVERTARGET then

			-- : update mouseovertarget target
			if EventData.TargetClassification == "mouseovertarget" then

				RVMOD_Targets.UpdatePlayerTargetFrame(RuleIndex, EventData.TargetClassification, EventData.NewTargetId, EventData.TargetType)
			end

		elseif	Rule.Classification == CLASS_SELFFRIENDLYTARGET then

			-- : update selffriendlytarget target
			if EventData.TargetClassification == "selffriendlytarget" then

				RVMOD_Targets.UpdatePlayerTargetFrame(RuleIndex, EventData.TargetClassification, EventData.NewTargetId, EventData.TargetType)

			elseif EventData.TargetClassification == "mouseovertarget" and RVAPI_Entities.Objects.selffriendlytarget > 0 then

				-- : get entity data
				local EntityData = RVAPI_Entities.API_GetEntityData(RVAPI_Entities.Objects.selffriendlytarget)

				-- : update target
				RVMOD_Targets.UpdatePlayerTargetFrame(RuleIndex, "selffriendlytarget", RVAPI_Entities.Objects.selffriendlytarget, EntityData.EntityType)
			end

		elseif	Rule.Classification == CLASS_SELFHOSTILETARGET then

			-- : update selfhostiletarget target
			if EventData.TargetClassification == "selfhostiletarget" then

				RVMOD_Targets.UpdatePlayerTargetFrame(RuleIndex, EventData.TargetClassification, EventData.NewTargetId, EventData.TargetType)

			elseif EventData.TargetClassification == "mouseovertarget" and RVAPI_Entities.Objects.selfhostiletarget > 0 then

				-- : get entity data
				local EntityData = RVAPI_Entities.API_GetEntityData(RVAPI_Entities.Objects.selfhostiletarget)

				-- : update target
				RVMOD_Targets.UpdatePlayerTargetFrame(RuleIndex, "selfhostiletarget", RVAPI_Entities.Objects.selfhostiletarget, EntityData.EntityType)
			end

		elseif	Rule.Classification == CLASS_FORMATION then

			-- : update formation member with OldTargetId
			if EventData.OldTargetId ~= EventData.NewTargetId and EventData.OldTargetId > 0 then

				-- : get entity information and check if it's a formation member
				local EntityData = RVAPI_Entities.API_GetEntityData(EventData.OldTargetId)
				if EntityData.GroupIndex > 0 and EntityData.MemberIndex > 0 then

					-- : get member data and update frame
					local MemberData = RVAPI_Entities.GetFormationMember(EntityData.GroupIndex, EntityData.MemberIndex)
					RVMOD_Targets.UpdateFormationMemberFrame(RuleIndex, EntityData.GroupIndex, EntityData.MemberIndex, MemberData)
				end
			end

			-- : update formation member with NewTargetId
			if EventData.NewTargetId > 0 then

				-- : get entity information and check if it's a formation member
				local EntityData = RVAPI_Entities.API_GetEntityData(EventData.NewTargetId)
				if EntityData.GroupIndex > 0 and EntityData.MemberIndex > 0 then

					-- : get member data and update frame
					local MemberData = RVAPI_Entities.GetFormationMember(EntityData.GroupIndex, EntityData.MemberIndex)
					RVMOD_Targets.UpdateFormationMemberFrame(RuleIndex, EntityData.GroupIndex, EntityData.MemberIndex, MemberData)
				end
			end

		elseif	Rule.Classification == CLASS_PET then

			-- : update player pet
			local PetData = GameData.Player.Pet
			if PetData.objNum == EventData.OldTargetId or PetData.objNum == EventData.NewTargetId then
				RVMOD_Targets.UpdatePlayerPetFrame(RuleIndex, PetData)
			end
		end
	end
end

--------------------------------------------------------------
-- function OnFormationMemberUpdated()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.OnFormationMemberUpdated(self, EventData)

	-- First step: get rules
	local Rules = RVMOD_Targets.CurrentConfiguration.Rules

	-- Second step: check for rules
	if Rules == nil then
		return
	end

	-- Third step: loop through all rules
	for RuleIndex, Rule in ipairs(Rules) do

		-- Fourth step: check for rule classification
		if Rule.Classification == CLASS_FORMATION then

			-- Final step: update formation member
			RVMOD_Targets.UpdateFormationMemberFrame(RuleIndex, EventData.GroupIndex, EventData.MemberIndex, EventData.MemberData)
		end
	end
end

--------------------------------------------------------------
-- function OnPlayerPetUpdated()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.OnPlayerPetUpdated(self, EventData)

	-- First step: get rules
	local Rules = RVMOD_Targets.CurrentConfiguration.Rules

	-- Second step: check for rules
	if Rules == nil then
		return
	end

	-- Third step: loop through all rules
	for RuleIndex, Rule in ipairs(Rules) do

		-- Fourth step: check for rule classification
		if Rule.Classification == CLASS_PET then

			-- Final step: update player pet
			RVMOD_Targets.UpdatePlayerPetFrame(RuleIndex, EventData.PetData)
		end
	end
end

--------------------------------------------------------------
-- function UpdateByRuleIndex()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.UpdateByRuleIndex(RuleIndex)

	-- First step: get rule
	local Rule = RVMOD_Targets.CurrentConfiguration.Rules[RuleIndex]

	-- Second step: check for rule classification
	if Rule.Classification == CLASS_MOUSEOVERTARGET then

		if RVAPI_Entities.Objects.mouseovertarget > 0 then

			-- : get entity data
			local EntityData = RVAPI_Entities.API_GetEntityData(RVAPI_Entities.Objects.mouseovertarget)

			-- : update target
			RVMOD_Targets.UpdatePlayerTargetFrame(RuleIndex, Rule.Classification, RVAPI_Entities.Objects.mouseovertarget, EntityData.EntityType)
		end

	elseif Rule.Classification == CLASS_SELFFRIENDLYTARGET then

		if RVAPI_Entities.Objects.selffriendlytarget > 0 then

			-- : get entity data
			local EntityData = RVAPI_Entities.API_GetEntityData(RVAPI_Entities.Objects.selffriendlytarget)

			-- : update target
			RVMOD_Targets.UpdatePlayerTargetFrame(RuleIndex, Rule.Classification, RVAPI_Entities.Objects.selffriendlytarget, EntityData.EntityType)
		end

	elseif Rule.Classification == CLASS_SELFHOSTILETARGET then

		if RVAPI_Entities.Objects.selfhostiletarget > 0 then

			-- : get entity data
			local EntityData = RVAPI_Entities.API_GetEntityData(RVAPI_Entities.Objects.selfhostiletarget)

			-- : update target
			RVMOD_Targets.UpdatePlayerTargetFrame(RuleIndex, Rule.Classification, RVAPI_Entities.Objects.selfhostiletarget, EntityData.EntityType)
		end

	elseif Rule.Classification == CLASS_FORMATION then

		-- : define local variables
		local FormationData = RVAPI_Entities.GetFormationData()

		-- : loop through all members
		for GroupIndex = 1, 4, 1 do
			for MemberIndex = 1, 6, 1 do

				-- : update member frame
				RVMOD_Targets.UpdateFormationMemberFrame(RuleIndex, GroupIndex, MemberIndex, FormationData[GroupIndex].players[MemberIndex])
			end
		end

	elseif Rule.Classification == CLASS_PET then

		-- : update player pet frame
		local PetData = GameData.Player.Pet
		RVMOD_Targets.UpdatePlayerPetFrame(RuleIndex, PetData)
	end
end

--------------------------------------------------------------
-- function UpdatePlayerTargetFrame()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.UpdatePlayerTargetFrame(RuleIndex, TargetClassification, TargetId, TargetType)

	-- : set local variables
	local EntityId
	local CalculatedConditions

	-- : get rule
	local Rule = RVMOD_Targets.CurrentConfiguration.Rules[RuleIndex]

	-- : check rule is active
	if Rule.TemplateName == nil then
		return
	end

	-- : set default entityId
	EntityId = 0

	-- : check for TargetId is provided
	if TargetId > 0 then

		-- : get entity data
		local EntityData = RVAPI_Entities.API_GetEntityData(TargetId)

		-- : define CalculatedConditions table
		CalculatedConditions = {}

		-- : calculate EntityId
		for ConditionIndex, Condition in ipairs(Rule.Conditions) do

			-- : include ALLY_PLAYER
			if		(Condition == CONDITION_ALLY_PLAYER and TargetType == SystemData.TargetObjectType.ALLY_PLAYER) then
				CalculatedConditions[Condition] = true

			-- : include ALLY_NON_PLAYER
			elseif	(Condition == CONDITION_ALLY_NON_PLAYER and TargetType == SystemData.TargetObjectType.ALLY_NON_PLAYER) then
				CalculatedConditions[Condition] = true

			-- : include ENEMY_PLAYER
			elseif	(Condition == CONDITION_ENEMY_PLAYER and TargetType == SystemData.TargetObjectType.ENEMY_PLAYER) then
				CalculatedConditions[Condition] = true

			-- : include ENEMY_NON_PLAYER
			elseif	(Condition == CONDITION_ENEMY_NON_PLAYER and TargetType == SystemData.TargetObjectType.ENEMY_NON_PLAYER) then
				CalculatedConditions[Condition] = true

			-- : include STATIC
			elseif	(Condition == CONDITION_STATIC and TargetType == SystemData.TargetObjectType.STATIC) then
				CalculatedConditions[Condition] = true

			-- : include STATIC_ATTACKABLE
			elseif	(Condition == CONDITION_STATIC_ATTACKABLE and TargetType == SystemData.TargetObjectType.STATIC_ATTACKABLE) then
				CalculatedConditions[Condition] = true

			-- : include SELF
			elseif	(Condition == CONDITION_SELF and TargetType == SystemData.TargetObjectType.SELF) then
				CalculatedConditions[Condition] = true

			-- : include PET
			elseif	(Condition == CONDITION_PET and TargetType == 2) then
				CalculatedConditions[Condition] = true

			-- : exclude when targeted
			elseif (Condition == CONDITION_DONT_SHOW_TARGETED and EntityData.IsTargeted) then
				CalculatedConditions[Condition] = true

			-- : exclude when mouseovered
			elseif (Condition == CONDITION_DONT_SHOW_MOUSEOVERED and EntityData.IsMouseOvered) then
				CalculatedConditions[Condition] = true

			end
		end

		-- : set EntityId
		if (CalculatedConditions[CONDITION_ALLY_PLAYER] or
			CalculatedConditions[CONDITION_ALLY_NON_PLAYER] or
			CalculatedConditions[CONDITION_ENEMY_PLAYER] or
			CalculatedConditions[CONDITION_ENEMY_NON_PLAYER] or
			CalculatedConditions[CONDITION_STATIC] or
			CalculatedConditions[CONDITION_STATIC_ATTACKABLE] or
			CalculatedConditions[CONDITION_SELF] or
			CalculatedConditions[CONDITION_PET]) and not
			(CalculatedConditions[CONDITION_DONT_SHOW_TARGETED] or CalculatedConditions[CONDITION_DONT_SHOW_MOUSEOVERED])
		then
			EntityId = TargetId
		end
	end

	-- Final step: update frame
	RVAPI_Frames.API_UpdateFrameTarget(Frames[RuleIndex][1], EntityId, true)
end

--------------------------------------------------------------
-- function UpdateFormationMemberFrame()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.UpdateFormationMemberFrame(RuleIndex, GroupIndex, MemberIndex, MemberData)

	-- : set local variables
	local EntityId
	local CalculatedConditions

	-- : get rule
	local Rule = RVMOD_Targets.CurrentConfiguration.Rules[RuleIndex]

	-- : check rule is active
	if Rule.TemplateName == nil then
		return
	end

	-- : set default entityId
	EntityId = 0

	-- : check for MemberData is provided
	if MemberData ~= nil and MemberData.worldObjNum > 0 then

		-- : get entity data
		local EntityData = RVAPI_Entities.API_GetEntityData(MemberData.worldObjNum)

		-- : define CalculatedConditions table
		CalculatedConditions = {}

		-- : loop every condition and calculate all conditions
		for ConditionIndex, Condition in ipairs(Rule.Conditions) do

			-- : include group members, exclude self
			if Condition == CONDITION_GROUP_MEMBERS and EntityData.IsGroupMember and
					not EntityData.IsSelf and
					not EntityData.IsScenarioGroupMember and
					not EntityData.IsGroupLeader and
					not EntityData.IsAssistant and
					not EntityData.IsMainAssist and
					not EntityData.IsMasterLooter then
				CalculatedConditions[Condition] = true

			-- : include warband members and exclude self, group members, scenario members, leaders, assistants, main assists, master looters
			elseif Condition == CONDITION_WARBAND_MEMBERS and EntityData.IsWarbandMember and
					not EntityData.IsSelf and
					not EntityData.IsGroupMember and
					not EntityData.IsScenarioGroupMember and
					not EntityData.IsGroupLeader and
					not EntityData.IsAssistant and
					not EntityData.IsMainAssist and
					not EntityData.IsMasterLooter then
				CalculatedConditions[Condition] = true

			-- : include scenario group members
			elseif Condition == CONDITION_SCENARIO_GROUP_MEMBERS and EntityData.IsScenarioGroupMember and
					not EntityData.IsSelf then
				CalculatedConditions[Condition] = true

			-- : include self
			elseif (Condition == CONDITION_SELF and EntityData.IsSelf) then
				CalculatedConditions[Condition] = true

			-- : include leaders and exclude self
			elseif Condition == CONDITION_LEADERS and EntityData.IsGroupLeader and
					not EntityData.IsSelf then
				CalculatedConditions[Condition] = true

			-- : include mainassists and exclude self, leaders
			elseif Condition == CONDITION_MAINASSISTS and EntityData.IsMainAssist and
					not EntityData.IsSelf and 
					not EntityData.IsGroupLeader then
				CalculatedConditions[Condition] = true

			-- : include assistants and exclude self, leaders, main assists
			elseif Condition == CONDITION_ASSISTANTS and EntityData.IsAssistant and
					not EntityData.IsSelf and 
					not EntityData.IsGroupLeader and
					not EntityData.IsMainAssist then
				CalculatedConditions[Condition] = true

			-- : include master looters and exclude self, leaders, main assists, assistants
			elseif Condition == CONDITION_MASTERLOOTERS and EntityData.IsMasterLooter and
					not EntityData.IsSelf and
					not EntityData.IsGroupLeader and
					not EntityData.IsMainAssist and
					not EntityData.IsAssistant then
				CalculatedConditions[Condition] = true

			-- : exclude when targeted
			elseif (Condition == CONDITION_DONT_SHOW_TARGETED and EntityData.IsTargeted) then
				CalculatedConditions[Condition] = true

			-- : exclude when mouseovered
			elseif (Condition == CONDITION_DONT_SHOW_MOUSEOVERED and EntityData.IsMouseOvered) then
				CalculatedConditions[Condition] = true

			end
		end

		-- : set EntityId
		if (CalculatedConditions[CONDITION_GROUP_MEMBERS] or
			CalculatedConditions[CONDITION_WARBAND_MEMBERS] or
			CalculatedConditions[CONDITION_SCENARIO_GROUP_MEMBERS] or
			CalculatedConditions[CONDITION_LEADERS] or
			CalculatedConditions[CONDITION_ASSISTANTS] or
			CalculatedConditions[CONDITION_MAINASSISTS] or
			CalculatedConditions[CONDITION_MASTERLOOTERS] or
			CalculatedConditions[CONDITION_SELF]) and not
			(CalculatedConditions[CONDITION_DONT_SHOW_TARGETED] or CalculatedConditions[CONDITION_DONT_SHOW_MOUSEOVERED])
		then
			EntityId = EntityData.EntityId
		end
	end

	-- : update frame
	RVAPI_Frames.API_UpdateFrameTarget(Frames[RuleIndex][(GroupIndex-1)*FRAMES_PER_GROUP+MemberIndex], EntityId, true)
end

--------------------------------------------------------------
-- function UpdatePlayerPetFrame()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.UpdatePlayerPetFrame(RuleIndex, PetData)

	-- : set local variables
	local EntityId
	local CalculatedConditions

	-- : get rule
	local Rule = RVMOD_Targets.CurrentConfiguration.Rules[RuleIndex]

	-- : check rule is active
	if Rule.TemplateName == nil then
		return
	end

	-- : set default entityId
	EntityId = 0

	-- : check for PetData is provided
	if PetData ~= nil and PetData.objNum > 0 then

		-- : get entity data
		local EntityData = RVAPI_Entities.API_GetEntityData(PetData.objNum)

		-- : define CalculatedConditions table
		CalculatedConditions = {}

		-- : loop every condition and calculate all conditions
		for ConditionIndex, Condition in ipairs(Rule.Conditions) do

			-- : exclude when targeted
			if (Condition == CONDITION_DONT_SHOW_TARGETED and EntityData.IsTargeted) then
				CalculatedConditions[Condition] = true

			-- : exclude when mouseovered
			elseif (Condition == CONDITION_DONT_SHOW_MOUSEOVERED and EntityData.IsMouseOvered) then
				CalculatedConditions[Condition] = true

			end
		end

		-- : set EntityId
		if not
			(CalculatedConditions[CONDITION_DONT_SHOW_TARGETED] or	CalculatedConditions[CONDITION_DONT_SHOW_MOUSEOVERED])
		then
			EntityId = EntityData.EntityId
		end
	end

	-- : update frame
	RVAPI_Frames.API_UpdateFrameTarget(Frames[RuleIndex][1], EntityId, true)
end

--------------------------------------------------------------
-- function GenerateFrameName()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.GenerateFrameName()

	-- First step: get new frame Id
	while RVAPI_Frames.API_IsFrameExists(WindowFrame..LastFrameId) do
		LastFrameId = LastFrameId + 1
	end

	-- Second step: return result
	return WindowFrame..LastFrameId
end

--------------------------------------------------------------
-- function EnableRule()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.EnableRule(RuleIndex)

	-- : get local variables
	local Rule = RVMOD_Targets.CurrentConfiguration.Rules[RuleIndex]
	local FramesList
	local FrameName

	-- : is rule enabled
	if Rule.TemplateName ~= nil then

		-- : get frames list
		FramesList = Frames[RuleIndex]

		-- : check for frames count
		if #FramesList < 1 then

			-- : register new frames
			for i = 1, RuleTypes[Rule.Classification].MaxFrames, 1 do

				-- : get new frame name
				FrameName = RVMOD_Targets.GenerateFrameName()

				-- : register frame
				RVAPI_Frames.API_RegisterFrame(FrameName, Rule.TemplateName)

				-- : check for the first frame
				if i == 1 then

					-- : set frame settings stored before (or NIL if this is the initial call)
					RVAPI_Frames.API_SetFrameSettings(FrameName, Rule.Settings[Rule.TemplateName])
				else

					-- : link settings to the first/parent frame
					RVAPI_Frames.API_LinkFrameSettings(FramesList[1], FrameName)
				end

				-- : save frame name
				table.insert(FramesList, FrameName)
			end
		end
	end
end

--------------------------------------------------------------
-- function DisableRule()
-- Description:
--------------------------------------------------------------
function RVMOD_Targets.DisableRule(RuleIndex)

	-- First step: get rule
	local Rule = RVMOD_Targets.CurrentConfiguration.Rules[RuleIndex]

	-- Second step: check is rule enabled
	if Rule.TemplateName ~= nil then

		-- Third step: get first frame settings
		Rule.Settings[Rule.TemplateName] = RVAPI_Frames.API_GetFrameSettings(Frames[RuleIndex][1])
	end

	-- Final step: unregister frames and empty frames list
	if Frames[RuleIndex] ~= nil then
		FrameName = table.remove(Frames[RuleIndex])
		while FrameName do
			RVAPI_Frames.API_UnRegisterFrame(FrameName)
			FrameName = table.remove(Frames[RuleIndex])
		end
	end
end

--------------------------------------------------------------
-- function 
-- Description: 
--------------------------------------------------------------

function RVMOD_Targets.OnComboBoxConditionClick( choiceIndex )

	-- First step: get button name
	local WindowName = SystemData.ActiveWindow.name

	-- Second step: get frame id
	local RuleIndex = WindowGetId(WindowGetParent(WindowName))

	-- Third step: get rule data
	local Rule		= RVMOD_Targets.CurrentConfiguration.Rules[RuleIndex]

	-- Fourth step: get checked condition
	local CheckedCondition = RuleTypes[Rule.Classification].Conditions[choiceIndex].Condition

	-- Fifth step: find checked condition in the list
	local ConditionRemoved = false
	for ConditionIndex, ConditionValue in pairs(Rule.Conditions) do

		if CheckedCondition == ConditionValue then

			table.remove(Rule.Conditions, ConditionIndex)
			ConditionRemoved = true
		end
	end

	-- Sixth step: check if condition has been removed from the Rule.Conditions list
	if not ConditionRemoved then

		-- : add condition to the Rule.Conditions list
		table.insert(Rule.Conditions, CheckedCondition)
	end

	-- Seventh step: relist combobox items to update checkboxes
	ComboBoxClearMenuItems(WindowName)
	RVMOD_Targets.RelistComboboxConditions(RuleIndex, WindowName)

	-- Eight step: update by RuleIndex
	RVMOD_Targets.UpdateByRuleIndex(RuleIndex)

	-- Final step: reopen combobox
	LastComboBoxName = WindowName
	WindowRegisterEventHandler(LastComboBoxName, SystemData.Events.L_BUTTON_UP_PROCESSED, "RVMOD_Targets.ReopenComboBox")
end

-- : hack, but no other way to do that at the moment
function RVMOD_Targets.ReopenComboBox()

	ComboBoxExternalOpenMenu(LastComboBoxName)
	WindowUnregisterEventHandler(LastComboBoxName, SystemData.Events.L_BUTTON_UP_PROCESSED)
end

function RVMOD_Targets.OnToggleRowSettings()

	-- First step: get button name
	local ButtonName = SystemData.ActiveWindow.name

	-- Second step: get rul index
	local RuleIndex = WindowGetId(WindowGetParent(ButtonName))

	-- Third step: get frame settings
	local Rule = RVMOD_Targets.CurrentConfiguration.Rules[RuleIndex]

	-- Fourth step: check for frame enabled
	if Rule.TemplateName ~= nil then

		-- Final step: toggle frame settings window
		if RVAPI_Frames.API_IsFrameShowingSettings(Frames[RuleIndex][1]) then
			RVAPI_Frames.API_CloseFrameSettings(Frames[RuleIndex][1])
		else
			RVAPI_Frames.API_OpenFrameSettings(Frames[RuleIndex][1])
		end
	end
end

function RVMOD_Targets.OnDeleteRow()

	-- First step: get button name
	local ButtonName = SystemData.ActiveWindow.name

	-- Second step: get rule index
	local RuleIndex = WindowGetId(WindowGetParent(ButtonName))

	-- Third step: disable rule
	RVMOD_Targets.DisableRule(RuleIndex)

	-- Fourth step: remove frames from the Frames list
	table.remove(Frames, RuleIndex)

	-- Fifth step: remove rule
	table.remove(RVMOD_Targets.CurrentConfiguration.Rules, RuleIndex)

	-- Final step: update all settings
	RVMOD_Targets.UpdateSettingsWindow()
end

function RVMOD_Targets.OnComboBoxTemplateChange( choiceIndex )

	-- First step: get button name
	local WindowName	= SystemData.ActiveWindow.name
	local ParentWindow	= WindowGetParent(WindowName)

	-- Second step: get frame id
	local RuleIndex		= WindowGetId(ParentWindow)

	-- Third step: get rule data
	local Rule			= RVMOD_Targets.CurrentConfiguration.Rules[RuleIndex]

	-- Fourth step: disable current fule
	RVMOD_Targets.DisableRule(RuleIndex)

	-- Fifth step: set actual Template index and check if its more than zero
	choiceIndex = choiceIndex - 1
	if choiceIndex > 0 then

		-- Sixth step: change template
		Rule.TemplateName = Templates[choiceIndex].TableName

		-- Seventh step: enable and update new frame with a new settings
		RVMOD_Targets.EnableRule(RuleIndex)

		-- : set enabled flag on Edit button
		ButtonSetDisabledFlag(ParentWindow.."Edit", false)
	else

		-- Final step: set template to a nil and exit
		Rule.TemplateName = nil

		-- : set disabled flag on Edit button
		ButtonSetDisabledFlag(ParentWindow.."Edit", true)
	end

	-- Final step: update by RuleIndex
	RVMOD_Targets.UpdateByRuleIndex(RuleIndex)
end

function RVMOD_Targets.OnAddMouseOverRule()

	-- First step: create new rule table
	local Rule = {
		Classification		= CLASS_MOUSEOVERTARGET,
		TemplateName		= nil,
		Conditions			= {
			CONDITION_ALLY_PLAYER,
			CONDITION_ALLY_NON_PLAYER,
			CONDITION_ENEMY_PLAYER,
			CONDITION_ENEMY_NON_PLAYER,
			CONDITION_STATIC,
			CONDITION_STATIC_ATTACKABLE,
			CONDITION_SELF,
			CONDITION_PET,
--			CONDITION_DONT_SHOW_TARGETED,
		},
		Settings			= {},
	}

	-- Second step: register new table in the Frames list
	table.insert(Frames, {})

	-- Third step: add rule to the rules list
	table.insert(RVMOD_Targets.CurrentConfiguration.Rules, Rule)

	-- Final step: update settings window
	RVMOD_Targets.UpdateSettingsWindow()
end

function RVMOD_Targets.OnAddSelfFriendlyRule()

	-- First step: create new rule table
	local Rule = {
		Classification		= CLASS_SELFFRIENDLYTARGET,
		TemplateName		= nil,
		Conditions			= {
			CONDITION_ALLY_PLAYER,
			CONDITION_ALLY_NON_PLAYER,
			CONDITION_STATIC,
			CONDITION_SELF,
			CONDITION_PET,
			CONDITION_DONT_SHOW_MOUSEOVERED,
		},
		Settings			= {},
	}

	-- Second step: register new table in the Frames list
	table.insert(Frames, {})

	-- Third step: add rule to the rules list
	table.insert(RVMOD_Targets.CurrentConfiguration.Rules, Rule)

	-- Final step: update settings window
	RVMOD_Targets.UpdateSettingsWindow()
end

function RVMOD_Targets.OnAddSelfHostileRule()

	-- First step: create new rule table
	local Rule = {
		Classification		= CLASS_SELFHOSTILETARGET,
		TemplateName		= nil,
		Conditions			= {
			CONDITION_ENEMY_PLAYER,
			CONDITION_ENEMY_NON_PLAYER,
			CONDITION_STATIC,
			CONDITION_STATIC_ATTACKABLE,
			CONDITION_DONT_SHOW_MOUSEOVERED,
		},
		Settings			= {},
	}

	-- Second step: register new table in the Frames list
	table.insert(Frames, {})

	-- Third step: add rule to the rules list
	table.insert(RVMOD_Targets.CurrentConfiguration.Rules, Rule)

	-- Final step: update settings window
	RVMOD_Targets.UpdateSettingsWindow()
end

function RVMOD_Targets.OnAddFormationRule()

	-- First step: create new rule table
	local Rule = {
		Classification		= CLASS_FORMATION,
		TemplateName		= nil,
		Conditions			= {
			CONDITION_GROUP_MEMBERS,
			CONDITION_WARBAND_MEMBERS,
			CONDITION_SCENARIO_GROUP_MEMBERS,
			CONDITION_LEADERS,
			CONDITION_ASSISTANTS,
			CONDITION_MAINASSISTS,
			CONDITION_MASTERLOOTERS,
--			CONDITION_SELF,
			CONDITION_DONT_SHOW_TARGETED,
			CONDITION_DONT_SHOW_MOUSEOVERED,
		},
		Settings			= {},
	}

	-- Second step: register new table in the Frames list
	table.insert(Frames, {})

	-- Third step: add rule to the rules list
	table.insert(RVMOD_Targets.CurrentConfiguration.Rules, Rule)

	-- Final step: update settings window
	RVMOD_Targets.UpdateSettingsWindow()
end

function RVMOD_Targets.OnAddPetRule()

	-- First step: create new rule table
	local Rule = {
		Classification		= CLASS_PET,
		TemplateName		= nil,
		Conditions			= {
			CONDITION_DONT_SHOW_TARGETED,
			CONDITION_DONT_SHOW_MOUSEOVERED,
		},
		Settings			= {},
	}

	-- Second step: register new table in the Frames list
	table.insert(Frames, {})

	-- Third step: add rule to the rules list
	table.insert(RVMOD_Targets.CurrentConfiguration.Rules, Rule)

	-- Final step: update settings window
	RVMOD_Targets.UpdateSettingsWindow()
end
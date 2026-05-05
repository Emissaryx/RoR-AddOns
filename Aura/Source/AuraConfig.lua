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

----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

if not AuraConfig then AuraConfig = {} end

AuraConfig.Window 					= "AuraConfig"
AuraConfig.WindowGeneral 			= AuraConfig.Window 		.. "General"
AuraConfig.WindowTrigger 			= AuraConfig.Window 		.. "Trigger"
AuraConfig.WindowAbility 			= AuraConfig.WindowTrigger 	.. "Ability"
AuraConfig.WindowActionPoints		= AuraConfig.WindowTrigger 	.. "ActionPoints"
AuraConfig.WindowCareer 			= AuraConfig.WindowTrigger 	.. "Career"
AuraConfig.WindowEffect				= AuraConfig.WindowTrigger	.. "Effect"
AuraConfig.WindowHitPoints			= AuraConfig.WindowTrigger	.. "HitPoints"
AuraConfig.WindowMorale 			= AuraConfig.WindowTrigger 	.. "Morale"

AuraConfig.WindowActivation			= AuraConfig.Window 		.. "Activation"
AuraConfig.WindowDeactivation		= AuraConfig.Window 		.. "Deactivation"
AuraConfig.WindowTimer 				= AuraConfig.Window 		.. "Timer"

AuraConfig.ColorPicker				= "AuraColorPicker"

AuraConfig.ConfigurationWindows = {}
AuraConfig.ConfigurationWindows[1] = { name=AuraConfig.WindowTrigger, 		buttontext=L"Trigger", 		button="AuraConfigTabsTriggerView" }
AuraConfig.ConfigurationWindows[2] = { name=AuraConfig.WindowActivation, 	buttontext=L"Activation", 	button="AuraConfigTabsActivationView"  }
AuraConfig.ConfigurationWindows[3] = { name=AuraConfig.WindowDeactivation, 	buttontext=L"Deactivation",	button="AuraConfigTabsDeactivationView"  }
AuraConfig.ConfigurationWindows[4] = { name=AuraConfig.WindowTimer, 		buttontext=L"Timer", 		button="AuraConfigTabsTimerView"  }

-- One entry for every trigger type, to make showing/hiding config options easier
AuraConfig.TriggerTypeWindows = {}
AuraConfig.TriggerTypeWindows[AuraConstants.TRIGGER_TYPE_ABILITY] 		= AuraConfig.WindowAbility
AuraConfig.TriggerTypeWindows[AuraConstants.TRIGGER_TYPE_ACTIONPOINTS] 	= AuraConfig.WindowActionPoints
AuraConfig.TriggerTypeWindows[AuraConstants.TRIGGER_TYPE_CAREER] 		= AuraConfig.WindowCareer
AuraConfig.TriggerTypeWindows[AuraConstants.TRIGGER_TYPE_EFFECTS] 		= AuraConfig.WindowEffect
AuraConfig.TriggerTypeWindows[AuraConstants.TRIGGER_TYPE_HITPOINTS]		= AuraConfig.WindowHitPoints
AuraConfig.TriggerTypeWindows[AuraConstants.TRIGGER_TYPE_MORALE] 		= AuraConfig.WindowMorale

local AbilityTypeComboIndexToAbilityType 		= {}
local AbilityTypeToAbilityTypeComboIndex 		= {}
local TriggerTypeComboIndexToTriggerType 		= {}
local TriggerTypeToTriggerTypeComboIndex 		= {}
local EffectTypeComboIndexToEffectType 			= {}
local EffectTypeToEffectTypeComboIndex 			= {}
local SoundTypeComboIndexToSoundType			= {}
local SoundTypeToSoundTypeComboIndex			= {}

local ActivationAnimationTypeComboIndexToActivationAnimationType 		= {}
local ActivationAnimationTypeToActivationAnimationTypeComboIndex		= {}
local DeactivationAnimationTypeComboIndexToDeactivationAnimationType 	= {}
local DeactivationAnimationTypeToDeactivationAnimationTypeComboIndex	= {}
local AlertTextTypeComboIndexToAlertTextType							= {}
local AlertTextTypeToAlertTextTypeComboIndex							= {}

local ActivationScreenFlashTypeComboIndexToScreenFlashType 				= {}
local ActivationScreenFlashTypeToScreenFlashTypeComboIndex				= {}
local DectivationScreenFlashTypeComboIndexToScreenFlashType 			= {}
local DeactivationScreenFlashTypeToScreenFlashTypeComboIndex			= {}

local HitPointsTypeComboIndexToHitPointsType			= {}
local HitPointsTypeToHitPointsTypeComboIndex			= {}

local editAura 										= nil

local textureTintWindowVisible	= false
local timerTintWindowVisible 	= false

function AuraConfig.OnInitialize()
	-- Hide our activation type windows
	for index,window in ipairs( AuraConfig.TriggerTypeWindows )
	do
		WindowSetShowing( window, false )
	end
	
	-- Setup our tab button and hide corresponding windows
	for index, window in ipairs( AuraConfig.ConfigurationWindows )
	do
		ButtonSetText( window.button, window.buttontext )
		ButtonSetStayDownFlag( window.button, true )
		
		WindowSetShowing( window.name, index == 1 )
		ButtonSetPressedFlag( window.button, index == 1 )
	end
	
	-- Set our configuration title
	LabelSetText( AuraConfig.Window .. "TitleBarText", L"Modify Aura" )
	
	-- GENERAL CONFIG AREA
	LabelSetText( AuraConfig.WindowGeneral .. "NameTitle", L"Aura Name:" )
	LabelSetText( AuraConfig.WindowGeneral .. "CircledImageLabel", L"Circle Image" )
	LabelSetText( AuraConfig.WindowGeneral .. "MirrorImageLabel", L"Mirror Image" )
	LabelSetText( AuraConfig.WindowGeneral .. "HideImageLabel", L"Hide Image" )
	LabelSetText( AuraConfig.WindowGeneral .. "OffsetXTitle", L"X:" )
	LabelSetText( AuraConfig.WindowGeneral .. "OffsetYTitle", L"Y:" )
	LabelSetText( AuraConfig.WindowGeneral .. "TextureScaleTitle", L"Scale:" )
	LabelSetText( AuraConfig.WindowGeneral .. "TextureScaleMinTitle", towstring( AuraConstants.TEXTURE_MIN_SCALE * 100 ) .. L"%" )
	LabelSetText( AuraConfig.WindowGeneral .. "TextureScaleMaxTitle", towstring( AuraConstants.TEXTURE_MAX_SCALE * 100 ) .. L"%" )
	LabelSetText( AuraConfig.WindowGeneral .. "TextureRotationTitle", L"Rotation:" )
	LabelSetText( AuraConfig.WindowGeneral .. "TextureRotationMinTitle", L"0" )
	LabelSetText( AuraConfig.WindowGeneral .. "TextureRotationMaxTitle", L"360" )
	
	-- TRIGGER CONFIG AREA
	LabelSetText( AuraConfig.WindowTrigger .. "TypeTitle", L"Aura Triggered By:" )
	LabelSetText( AuraConfig.WindowTrigger .. "GeneralOnlyInCombatLabel", L"Only In Combat" )
	LabelSetText( AuraConfig.WindowTrigger .. "GeneralOnlyOutOfCombatLabel", L"Only Out Of Combat" )
	LabelSetText( AuraConfig.WindowTrigger .. "GeneralOnlyInGroupLabel", L"Only In Group" )
	LabelSetText( AuraConfig.WindowTrigger .. "GeneralOnlyInWarPartyLabel", L"Only In War Party" )
	LabelSetText( AuraConfig.WindowTrigger .. "GeneralRvRFlaggedLabel", L"RvR Flagged" )
	LabelSetText( AuraConfig.WindowTrigger .. "GeneralNotRvRFlaggedLabel", L"Not RvR Flagged" )
	AuraConfig.BuildTriggerTypeCombo()
	
	-- ABILITY CONFIG AREA
	LabelSetText( AuraConfig.WindowAbility .. "DragAndDropNote", L"Drag and Drop an ability here to set it" )
	LabelSetText( AuraConfig.WindowAbility .. "ShowWhenNotActiveLabel", L"Show When Not Active" )
	WindowSetShowing( AuraConfig.WindowAbility .. "WrapperButtonCircleIcon", false )
	LabelSetText( AuraConfig.WindowAbility .. "RequireExplicitActiveCheckLabel", L"Require Explicit Active Check" )
	LabelSetText( AuraConfig.WindowAbility .. "RequireValidityCheckLabel", L"Require LoS/Range/Valid Target Check" )
	
	-- ACTION POINT CONFIG AREA
	LabelSetText( AuraConfig.WindowActionPoints .. "OperatorTitle", L"Operator:" )
	LabelSetText( AuraConfig.WindowActionPoints .. "ValueTitle", L"Action Points:" )
	LabelSetText( AuraConfig.WindowActionPoints .. "EnableSecondaryLabel", L"Enable Secondary:" )
	AuraConfig.BuildOperatorCombo( AuraConfig.WindowActionPoints .. "OperatorCombo" )
	AuraConfig.BuildOperatorCombo( AuraConfig.WindowActionPoints .. "SecondaryOperatorCombo" )
	AuraConfig.BuildSecondaryConditionalCombo( AuraConfig.WindowActionPoints .. "SecondaryConditionalOperatorCombo" )
	
	-- CAREER CONFIG AREA
	LabelSetText( AuraConfig.WindowCareer .. "OperatorTitle", L"Operator:" )
	LabelSetText( AuraConfig.WindowCareer .. "ValueTitle", L"Resource Amount:" )
	LabelSetText( AuraConfig.WindowCareer .. "EnableSecondaryLabel", L"Enable Secondary:" )
	AuraConfig.BuildOperatorCombo( AuraConfig.WindowCareer .. "OperatorCombo" )
	AuraConfig.BuildOperatorCombo( AuraConfig.WindowCareer .. "SecondaryOperatorCombo" )
	AuraConfig.BuildSecondaryConditionalCombo( AuraConfig.WindowCareer .. "SecondaryConditionalOperatorCombo" )
	
	-- EFFECTS CONFIG AREA
	LabelSetText( AuraConfig.WindowEffect .. "NameTitle", L"Effect Name:" )
	LabelSetText( AuraConfig.WindowEffect .. "TypeTitle", L"Type:" )
	LabelSetText( AuraConfig.WindowEffect .. "EnableStacksLabel", L"Stack(s):" )
	LabelSetText( AuraConfig.WindowEffect .. "ShowWhenNotActiveLabel", L"Show When Not Active" )
	LabelSetText( AuraConfig.WindowEffect .. "ExactMatchLabel", L"Exact Match" )
	LabelSetText( AuraConfig.WindowEffect .. "SelfCastLabel", L"Self Cast" )
	LabelSetText( AuraConfig.WindowEffect .. "TargetSelfLabel", L"On Yourself" )
	LabelSetText( AuraConfig.WindowEffect .. "TargetFriendlyLabel", L"Target Friendly" )
	LabelSetText( AuraConfig.WindowEffect .. "TargetEnemyLabel", L"Target Enemy" )
	AuraConfig.BuildEffectTypeCombo()
	AuraConfig.BuildOperatorCombo( AuraConfig.WindowEffect .. "StackOperatorCombo" )
	
	-- HIT POINTS AREA
	LabelSetText( AuraConfig.WindowHitPoints .. "TypeTitle", L"Unit Type:" )
	LabelSetText( AuraConfig.WindowHitPoints .. "OperatorTitle", L"Operator:" )
	LabelSetText(AuraConfig.WindowHitPoints .. "ValueTitle", L"% Hit Points:" )
	LabelSetText( AuraConfig.WindowHitPoints .. "EnableSecondaryLabel", L"Enable Secondary:" )
	AuraConfig.BuildHitPointsTypeCombo()
	AuraConfig.BuildOperatorCombo( AuraConfig.WindowHitPoints .. "OperatorCombo" )
	AuraConfig.BuildOperatorCombo( AuraConfig.WindowHitPoints .. "SecondaryOperatorCombo" )
	AuraConfig.BuildSecondaryConditionalCombo( AuraConfig.WindowHitPoints .. "SecondaryConditionalOperatorCombo" )
	
	-- MORALE CONFIG AREA
	LabelSetText( AuraConfig.WindowMorale .. "OperatorTitle", L"Operator:" )
	LabelSetText(AuraConfig.WindowMorale .. "ValueTitle", L"Morale Level:" )
	LabelSetText( AuraConfig.WindowMorale .. "EnableSecondaryLabel", L"Enable Secondary:" )
	AuraConfig.BuildOperatorCombo( AuraConfig.WindowMorale .. "OperatorCombo" )
	AuraConfig.BuildOperatorCombo( AuraConfig.WindowMorale .. "SecondaryOperatorCombo" )
	AuraConfig.BuildSecondaryConditionalCombo( AuraConfig.WindowMorale .. "SecondaryConditionalOperatorCombo" )
	
	-- ACTIVATION AREA
	LabelSetText( AuraConfig.WindowActivation .. "AnimationTitle", L"Animation:" )
	LabelSetText( AuraConfig.WindowActivation .. "SoundTitle", L"Sound:" )
	LabelSetText( AuraConfig.WindowActivation .. "AlertTextTypeTitle", L"Alert Text Type:" )
	LabelSetText( AuraConfig.WindowActivation .. "AlertTextTitle", L"Alert Text:" )
	ButtonSetText( AuraConfig.WindowActivation .. "AlertTextTestButton", towstring( "Test" ) )
	AuraConfig.BuildActivationAnimationTypeCombo()
	AuraConfig.BuildActivationScreenFlashTypeCombo()
	LabelSetText( AuraConfig.WindowActivation .. "ScreenFlashTitle", L"Screen Flash:" )
	
	-- DEACTIVATION AREA
	LabelSetText( AuraConfig.WindowDeactivation .. "AnimationTitle", L"Animation:" )
	LabelSetText( AuraConfig.WindowDeactivation .. "SoundTitle", L"Sound:" )
	LabelSetText( AuraConfig.WindowDeactivation .. "AlertTextTypeTitle", L"Alert Text Type:" )
	LabelSetText( AuraConfig.WindowDeactivation .. "AlertTextTitle", L"Alert Text:" )
	ButtonSetText( AuraConfig.WindowDeactivation .. "AlertTextTestButton", towstring( "Test" ) )
	AuraConfig.BuildDeactivationAnimationTypeCombo()
	AuraConfig.BuildDeactivationScreenFlashTypeCombo()
	LabelSetText( AuraConfig.WindowDeactivation .. "ScreenFlashTitle", L"Screen Flash:" )
	
	-- ACTIVATION/DEACTIVATION SHARED AREA
	AuraConfig.BuildSoundTypeCombos()
	AuraConfig.BuildAlertTextCombos()
	
	-- TIMER AREA
	LabelSetText( AuraConfig.WindowTimer .. "DisplayTimerLabel", L"Display Timer" )
	LabelSetText( AuraConfig.WindowTimer .. "OffsetXTitle", L"X:" )
	LabelSetText( AuraConfig.WindowTimer .. "OffsetYTitle", L"Y:" )
	LabelSetText( AuraConfig.WindowTimer .. "ScaleTitle", L"Scale:" )
	LabelSetText( AuraConfig.WindowTimer .. "ScaleMinTitle", towstring( AuraConstants.TIMER_MIN_SCALE * 100 ) .. L"%" )
	LabelSetText( AuraConfig.WindowTimer .. "ScaleMaxTitle", towstring( AuraConstants.TIMER_MAX_SCALE * 100 ) .. L"%" )
end

function AuraConfig.OnLoad()
	-- We initialize these UI elements here, because the client never reinitializes an addon
	-- when a player changes characters, so every time we load, update this information
	
	-- ACTION POINT SETTINGS
	LabelSetText( AuraConfig.WindowActionPoints .. "MaximumActionPoints", L"Maximum: " .. towstring( GameData.Player.actionPoints.maximum ) )
	
	-- CAREER SETTINGS
	LabelSetText( AuraConfig.WindowCareer .. "Class", L"Limits for your class ( " .. CareerNames[GameData.Player.career.line].name .. L" ):" )
	
	local min, max, minDesc, maxDesc = AuraHelpers.GetCareerResourceLimits( GameData.Player.career.line )
	
	if( minDesc == L"" ) then
		LabelSetText( AuraConfig.WindowCareer .. "LimitMinimum", L"Minimum:  " .. towstring( min ) )
	else
		LabelSetText( AuraConfig.WindowCareer .. "LimitMinimum", L"Minimum:  " .. towstring( min ) .. L" (" .. minDesc .. L")" )
	end
	if( maxDesc == L"" ) then
		LabelSetText( AuraConfig.WindowCareer .. "LimitMaximum", L"Maximum:  " .. towstring( max ) )
	else
		LabelSetText( AuraConfig.WindowCareer .. "LimitMaximum", L"Maximum:  " .. towstring( max ) .. L" (" .. maxDesc .. L")" )
	end
end

function AuraConfig.BuildAuraDataFromDialog( aura )
	local _x, _y, _stackCount, _value
	local r, g, b
	-- General Settings
	aura:Set( "general-name", 						TextEditBoxGetText( AuraConfig.WindowGeneral .. "Name" ) )
	
	aura:Set( "texture-id", 						editAura:Get( "texture-id" ) )
	aura:Set( "texture-type", 						editAura:Get( "texture-type" ) )
	aura:Set( "texture-circledimage", 				ButtonGetPressedFlag( AuraConfig.WindowGeneral .. "CircledImageButton" ) )
	aura:Set( "texture-hideimage", 					ButtonGetPressedFlag( AuraConfig.WindowGeneral .. "HideImageButton" ) )
	aura:Set( "texture-mirrorimage", 				ButtonGetPressedFlag( AuraConfig.WindowGeneral .. "MirrorImageButton" ) )
	aura:SetTextureColor( WindowGetTintColor( AuraConfig.WindowGeneral .. "TintColor" ) )
	aura:Set( "texture-alpha", 						WindowGetAlpha( AuraConfig.WindowGeneral .. "TintColor" ) ) 
	_x 												= tonumber( TextEditBoxGetText( AuraConfig.WindowGeneral .. "OffsetX" ) )
	aura:Set( "texture-offsetx", 					AuraHelpers.fif( _x ~= nil, _x, 0 ) )
	_y 												= tonumber( TextEditBoxGetText( AuraConfig.WindowGeneral .. "OffsetY" ) )
	aura:Set( "texture-offsety", 					AuraHelpers.fif( _y ~= nil, _y, 0 ) )
	aura:Set( "texture-rotation",					AuraHelpers.ConvertSliderToValue( SliderBarGetCurrentPosition( AuraConfig.WindowGeneral .. "TextureRotationSlider" ), 0, 360, AuraConstants.TEXTURE_ROUND ) )
	aura:Set( "texture-scale",						AuraHelpers.ConvertSliderToValue( SliderBarGetCurrentPosition( AuraConfig.WindowGeneral .. "TextureScaleSlider" ), AuraConstants.TEXTURE_MIN_SCALE, AuraConstants.TEXTURE_MAX_SCALE, AuraConstants.TEXTURE_ROUND ) )
	
	-- Trigger Settings
	aura:Set( "general-triggertype", 				AuraConfig.ConvertTriggerTypeComboIndexToTriggerType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowTrigger .. "TypeCombo" ) ) )
	
	-- Trigger General Settings
	aura:Set( "trigger-onlyincombat", 				ButtonGetPressedFlag( AuraConfig.WindowTrigger .. "GeneralOnlyInCombatButton" )	)
	aura:Set( "trigger-onlyoutofcombat",			ButtonGetPressedFlag( AuraConfig.WindowTrigger .. "GeneralOnlyOutOfCombatButton" ) )
	aura:Set( "trigger-onlyingroup", 				ButtonGetPressedFlag( AuraConfig.WindowTrigger .. "GeneralOnlyInGroupButton" ) )
	aura:Set( "trigger-onlyinwarparty", 			ButtonGetPressedFlag( AuraConfig.WindowTrigger .. "GeneralOnlyInWarPartyButton" ) )
	aura:Set( "trigger-rvrflagged", 				ButtonGetPressedFlag( AuraConfig.WindowTrigger .. "GeneralRvRFlaggedButton" ) )
	aura:Set( "trigger-notrvrflagged",				ButtonGetPressedFlag( AuraConfig.WindowTrigger .. "GeneralNotRvRFlaggedButton" ) )
	
	-- Ability Settings
	aura:Set( "ability-abilityid",					editAura:Get( "ability-abilityid" ) )
	aura:Set( "ability-showwhennotactive",			ButtonGetPressedFlag( AuraConfig.WindowAbility .. "ShowWhenNotActiveButton" ) )
	aura:Set( "ability-requireexplicitactivecheck", ButtonGetPressedFlag( AuraConfig.WindowAbility .. "RequireExplicitActiveCheckButton" ) )
	aura:Set( "ability-requirevaliditycheck",		ButtonGetPressedFlag( AuraConfig.WindowAbility .. "RequireValidityCheckButton" ))
	
	-- Action Points Settings
	aura:Set( "actionpoints-operator", 				ComboBoxGetSelectedMenuItem( AuraConfig.WindowActionPoints .. "OperatorCombo" ) )
	_value 											= tonumber( TextEditBoxGetText( AuraConfig.WindowActionPoints .. "Value" ) )
	aura:Set( "actionpoints-value",					AuraHelpers.fif( _value ~= nil, _value, 0 ) )
	aura:Set( "actionpoints-enablesecondary",		ButtonGetPressedFlag( AuraConfig.WindowActionPoints .. "EnableSecondaryButton" ) )
	aura:Set( "actionpoints-secondaryconditional",	ComboBoxGetSelectedMenuItem( AuraConfig.WindowActionPoints .. "SecondaryConditionalOperatorCombo" ) == 1 )
	aura:Set( "actionpoints-secondaryoperator",		ComboBoxGetSelectedMenuItem( AuraConfig.WindowActionPoints .. "SecondaryOperatorCombo" ) )
	_value 											= tonumber( TextEditBoxGetText( AuraConfig.WindowActionPoints .. "SecondaryValue" ) )
	aura:Set( "actionpoints-secondaryvalue",		AuraHelpers.fif( _value ~= nil, _value, 0 ) )
	
	-- Career Settings
	aura:Set( "career-operator", 					ComboBoxGetSelectedMenuItem( AuraConfig.WindowCareer .. "OperatorCombo" ) )
	_value 											= tonumber( TextEditBoxGetText( AuraConfig.WindowCareer .. "Value" ) )
	aura:Set( "career-value",						AuraHelpers.fif( _value ~= nil, _value, 0 ) )
	aura:Set( "career-enablesecondary",				ButtonGetPressedFlag( AuraConfig.WindowCareer .. "EnableSecondaryButton" ) )
	aura:Set( "career-secondaryconditional",		ComboBoxGetSelectedMenuItem( AuraConfig.WindowCareer .. "SecondaryConditionalOperatorCombo" ) == 1 )
	aura:Set( "career-secondaryoperator",			ComboBoxGetSelectedMenuItem( AuraConfig.WindowCareer .. "SecondaryOperatorCombo" ) )
	_value 											= tonumber( TextEditBoxGetText( AuraConfig.WindowCareer .. "SecondaryValue" ) )
	aura:Set( "career-secondaryvalue",				AuraHelpers.fif( _value ~= nil, _value, 0 ) )
	
	-- Effects Settings
	aura:Set( "effect-name",						TextEditBoxGetText( AuraConfig.WindowEffect .. "Name" ) )
	aura:Set( "effect-type",						AuraConfig.ConvertEffectTypeComboIndexToEffectType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowEffect .. "TypeCombo" ) ) )
	aura:Set( "effect-enablestacks",				ButtonGetPressedFlag( AuraConfig.WindowEffect .. "EnableStacksButton" ) )
	aura:Set( "effect-stackoperator",				ComboBoxGetSelectedMenuItem( AuraConfig.WindowEffect .. "StackOperatorCombo" ) )
	_stackCount 									= tonumber( TextEditBoxGetText(  AuraConfig.WindowEffect .. "StackCount" ) )
	aura:Set( "effect-stackcount",					AuraHelpers.fif( _stackCount ~= nil, _stackCount, 0 ) )
	aura:Set( "effect-showwhennotactive",			ButtonGetPressedFlag( AuraConfig.WindowEffect .. "ShowWhenNotActiveButton" ) )
	aura:Set( "effect-exactmatch",					ButtonGetPressedFlag( AuraConfig.WindowEffect .. "ExactMatchButton" ) )
	aura:Set( "effect-selfcast",					ButtonGetPressedFlag( AuraConfig.WindowEffect .. "SelfCastButton" ) )
	aura:Set( "effect-self",						ButtonGetPressedFlag( AuraConfig.WindowEffect .. "TargetSelfButton" ) )
	aura:Set( "effect-friendly",					ButtonGetPressedFlag( AuraConfig.WindowEffect .. "TargetFriendlyButton" ) )
	aura:Set( "effect-enemy",						ButtonGetPressedFlag( AuraConfig.WindowEffect .. "TargetEnemyButton" ) )
	
	-- Hit Point Settings
	aura:Set( "hitpoints-type",						AuraConfig.ConvertHitPointsTypeComboIndexToHitPointsType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowHitPoints .. "TypeCombo" ) ) )
	aura:Set( "hitpoints-operator", 				ComboBoxGetSelectedMenuItem( AuraConfig.WindowHitPoints .. "OperatorCombo" ) )
	_value 											= tonumber( TextEditBoxGetText( AuraConfig.WindowHitPoints .. "Value" ) )
	aura:Set( "hitpoints-value",					AuraHelpers.fif( _value ~= nil, _value, 0 ) )
	aura:Set( "hitpoints-enablesecondary",			ButtonGetPressedFlag( AuraConfig.WindowHitPoints .. "EnableSecondaryButton" ) )
	aura:Set( "hitpoints-secondaryconditional",		ComboBoxGetSelectedMenuItem( AuraConfig.WindowHitPoints .. "SecondaryConditionalOperatorCombo" ) == 1 )
	aura:Set( "hitpoints-secondaryoperator",		ComboBoxGetSelectedMenuItem( AuraConfig.WindowHitPoints .. "SecondaryOperatorCombo" ) )
	_value 											= tonumber( TextEditBoxGetText( AuraConfig.WindowHitPoints .. "SecondaryValue" ) )
	aura:Set( "hitpoints-secondaryvalue",			AuraHelpers.fif( _value ~= nil, _value, 0 ) )
	
	-- Morale Settings
	aura:Set( "morale-operator", 					ComboBoxGetSelectedMenuItem( AuraConfig.WindowMorale .. "OperatorCombo" ) )
	_value 											= tonumber( TextEditBoxGetText( AuraConfig.WindowMorale .. "Value" ) )
	aura:Set( "morale-value",						AuraHelpers.fif( _value ~= nil, _value, 0 ) )
	aura:Set( "morale-enablesecondary",				ButtonGetPressedFlag( AuraConfig.WindowMorale .. "EnableSecondaryButton" ) )
	aura:Set( "morale-secondaryconditional",		ComboBoxGetSelectedMenuItem( AuraConfig.WindowMorale .. "SecondaryConditionalOperatorCombo" ) == 1 )
	aura:Set( "morale-secondaryoperator",			ComboBoxGetSelectedMenuItem( AuraConfig.WindowMorale .. "SecondaryOperatorCombo" ) )
	_value 											= tonumber( TextEditBoxGetText( AuraConfig.WindowMorale .. "SecondaryValue" ) )
	aura:Set( "morale-secondaryvalue",				AuraHelpers.fif( _value ~= nil, _value, 0 ) )
	
	-- Activation Settings
	aura:Set( "activation-animation",				AuraConfig.ConvertActivationAnimationTypeComboIndexToActivationAnimationType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowActivation .. "AnimationCombo" ) ) )
	aura:Set( "activation-sound",					AuraConfig.ConvertSoundTypeComboIndexToSoundType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowActivation .. "SoundCombo" ) ) )
	aura:Set( "activation-alerttexttype",			AuraConfig.ConvertAlertTextTypeComboIndexToAlertType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowActivation .. "AlertTextTypeCombo" ) ) )	
	aura:Set( "activation-alerttext",				TextEditBoxGetText( AuraConfig.WindowActivation .. "AlertTextText" ) )
	aura:Set( "activation-screenflash",				AuraConfig.ConvertActivationScreenFlashTypeComboIndexToActivationScreenFlashType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowActivation .. "ScreenFlashCombo" ) ) )
	
	-- Deactivation Settings
	aura:Set( "deactivation-animation",				AuraConfig.ConvertDeactivationAnimationTypeComboIndexToDeactivationAnimationType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowDeactivation .. "AnimationCombo" ) ) )
	aura:Set( "deactivation-sound",					AuraConfig.ConvertSoundTypeComboIndexToSoundType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowDeactivation .. "SoundCombo" ) ) )
	aura:Set( "deactivation-alerttexttype",			AuraConfig.ConvertAlertTextTypeComboIndexToAlertType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowDeactivation .. "AlertTextTypeCombo" ) ) )	
	aura:Set( "deactivation-alerttext",				TextEditBoxGetText( AuraConfig.WindowDeactivation .. "AlertTextText" ) )
	aura:Set( "deactivation-screenflash",			AuraConfig.ConvertDeactivationScreenFlashTypeComboIndexToDeactivationScreenFlashType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowDeactivation .. "ScreenFlashCombo" ) ) )
	
	-- Timer Settings
	aura:Set( "timer-enabled",						ButtonGetPressedFlag( AuraConfig.WindowTimer .. "DisplayTimerButton" ) )
	_x 												= tonumber( TextEditBoxGetText( AuraConfig.WindowTimer .. "OffsetX" ) )
	aura:Set( "timer-offsetx",						AuraHelpers.fif( _x ~= nil, _x, 0 ) )
	_y 												= tonumber( TextEditBoxGetText( AuraConfig.WindowTimer .. "OffsetY" ) )
	aura:Set( "timer-offsety",						AuraHelpers.fif( _y ~= nil, _y, 0 ) )
	aura:Set( "timer-scale",						AuraHelpers.ConvertSliderToValue( SliderBarGetCurrentPosition( AuraConfig.WindowTimer .. "ScaleSlider" ), AuraConstants.TIMER_MIN_SCALE, AuraConstants.TIMER_MAX_SCALE, AuraConstants.TIMER_ROUND ) )
	aura:SetTimerColor( WindowGetTintColor( AuraConfig.WindowTimer .. "TintColorColor" ) )
	aura:Set( "texture-alpha", 						WindowGetAlpha( AuraConfig.WindowTimer .. "TintColorColor" ) ) 
	
	return aura
end

function AuraConfig.BuildDialogFromAuraData( aura )
	AuraDebug("Building Dialog From Aura")
	
	-- Store the aura we are displaying
	editAura = aura

	-- General Settings
	AuraConfig.UpdateAuraConfigTextureDisplay( aura )
	
	TextEditBoxSetText( AuraConfig.WindowGeneral .. "Name", aura:Get( "general-name" ) )
	
	ButtonSetPressedFlag( AuraConfig.WindowGeneral .. "CircledImageButton", aura:Get( "texture-circledimage" ) )
	ButtonSetPressedFlag( AuraConfig.WindowGeneral .. "MirrorImageButton", aura:Get( "texture-mirrorimage" ) )
	ButtonSetPressedFlag( AuraConfig.WindowGeneral .. "HideImageButton", aura:Get( "texture-hideimage" ) )
	WindowSetTintColor( AuraConfig.WindowGeneral .. "TintColor", aura:Get( "texture-tintr" ), aura:Get( "texture-tintg" ), aura:Get( "texture-tintb" ) )
	WindowSetAlpha( AuraConfig.WindowGeneral .. "TintColor", aura:Get( "texture-alpha" ) )
	
	TextEditBoxSetText( AuraConfig.WindowGeneral .. "OffsetX", towstring( aura:Get( "texture-offsetx" ) ) )
	TextEditBoxSetText( AuraConfig.WindowGeneral .. "OffsetY", towstring( aura:Get( "texture-offsety" ) ) )
	
	local rotationPos = AuraHelpers.ConvertValueToSlider( aura:Get( "texture-rotation" ), 0, 360, AuraConstants.TEXTURE_ROUND )
	SliderBarSetCurrentPosition( AuraConfig.WindowGeneral .. "TextureRotationSlider", rotationPos )
	AuraConfig.OnTextureRotationSlide( rotationPos, true )
	
	local scalePos = AuraHelpers.ConvertValueToSlider( aura:Get( "texture-scale" ), AuraConstants.TEXTURE_MIN_SCALE, AuraConstants.TEXTURE_MAX_SCALE, AuraConstants.TEXTURE_ROUND )
	SliderBarSetCurrentPosition( AuraConfig.WindowGeneral .. "TextureScaleSlider", scalePos )
	AuraConfig.OnTextureScaleSlide( scalePos, true )
	
	-- Trigger Settings
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowTrigger .. "TypeCombo", AuraConfig.ConvertTriggerTypeToTriggerTypeComboIndex( aura:Get( "general-triggertype" ) ) )

	-- General Settings
	ButtonSetPressedFlag( AuraConfig.WindowTrigger .. "GeneralOnlyInCombatButton",		aura:Get( "trigger-onlyincombat" ) )
	ButtonSetPressedFlag( AuraConfig.WindowTrigger .. "GeneralOnlyOutOfCombatButton", 	aura:Get( "trigger-onlyoutofcombat" ) )
	ButtonSetPressedFlag( AuraConfig.WindowTrigger .. "GeneralOnlyInGroupButton", 		aura:Get( "trigger-onlyingroup" ) )
	ButtonSetPressedFlag( AuraConfig.WindowTrigger .. "GeneralOnlyInWarPartyButton", 	aura:Get( "trigger-onlyinwarparty" ) )
	ButtonSetPressedFlag( AuraConfig.WindowTrigger .. "GeneralRvRFlaggedButton", 		aura:Get( "trigger-rvrflagged" ) )
	ButtonSetPressedFlag( AuraConfig.WindowTrigger .. "GeneralNotRvRFlaggedButton", 	aura:Get( "trigger-notrvrflagged" ) )
	
	-- Ability Settings
	ButtonSetPressedFlag( AuraConfig.WindowAbility .. "ShowWhenNotActiveButton", aura:Get( "ability-showwhennotactive" ) )
	AuraConfig.UpdateAbilityDisplay( aura:Get( "ability-abilityid" ) )
	ButtonSetPressedFlag( AuraConfig.WindowAbility .. "RequireExplicitActiveCheckButton", aura:Get( "ability-requireexplicitactivecheck" ) )
	ButtonSetPressedFlag( AuraConfig.WindowAbility .. "RequireValidityCheckButton", aura:Get( "ability-requirevaliditycheck" ) )
	
	-- Action Points Settings
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowActionPoints .. "OperatorCombo", aura:Get( "actionpoints-operator" ) )
	TextEditBoxSetText( AuraConfig.WindowActionPoints .. "Value", towstring( aura:Get( "actionpoints-value" ) ) )
	ButtonSetPressedFlag( AuraConfig.WindowActionPoints .. "EnableSecondaryButton", aura:Get( "actionpoints-enablesecondary" ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowActionPoints .. "SecondaryConditionalOperatorCombo", AuraHelpers.fif( aura:Get( "actionpoints-secondaryconditional" ) == true, 1, 2 ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowActionPoints .. "SecondaryOperatorCombo", aura:Get( "actionpoints-secondaryoperator" ) )
	TextEditBoxSetText( AuraConfig.WindowActionPoints .. "SecondaryValue", towstring( aura:Get( "actionpoints-secondaryvalue" ) ) )
	
	-- Career Settings
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowCareer .. "OperatorCombo", aura:Get( "career-operator" ) )
	TextEditBoxSetText( AuraConfig.WindowCareer .. "Value", towstring( aura:Get( "career-value" ) ) )
	ButtonSetPressedFlag( AuraConfig.WindowCareer .. "EnableSecondaryButton", aura:Get( "career-enablesecondary" ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowCareer .. "SecondaryConditionalOperatorCombo", AuraHelpers.fif( aura:Get( "career-secondaryconditional" ) == true, 1, 2 ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowCareer .. "SecondaryOperatorCombo", aura:Get( "career-secondaryoperator" ) )
	TextEditBoxSetText( AuraConfig.WindowCareer .. "SecondaryValue", towstring( aura:Get( "career-secondaryvalue" ) ) )
			
	-- Effects Settings				
	TextEditBoxSetText( AuraConfig.WindowEffect .. "Name", aura:Get( "effect-name" ) )	
	ButtonSetPressedFlag( AuraConfig.WindowEffect .. "EnableStacksButton", aura:Get( "effect-enablestacks" ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowEffect .. "TypeCombo", AuraConfig.ConvertEffectTypeToEffectTypeComboIndex( aura:Get( "effect-type" ) ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowEffect .. "StackOperatorCombo", aura:Get( "effect-stackoperator" ) )
	TextEditBoxSetText( AuraConfig.WindowEffect .. "StackCount", towstring( aura:Get( "effect-stackcount" ) ) )
	ButtonSetPressedFlag( AuraConfig.WindowEffect .. "ShowWhenNotActiveButton", aura:Get( "effect-showwhennotactive" ) )
	ButtonSetPressedFlag( AuraConfig.WindowEffect .. "ExactMatchButton", aura:Get( "effect-exactmatch" ) )
	ButtonSetPressedFlag( AuraConfig.WindowEffect .. "SelfCastButton", aura:Get( "effect-selfcast" ) )
	ButtonSetPressedFlag( AuraConfig.WindowEffect .. "TargetSelfButton", aura:Get( "effect-self" ) )
	ButtonSetPressedFlag( AuraConfig.WindowEffect .. "TargetFriendlyButton", aura:Get( "effect-friendly" ) )
	ButtonSetPressedFlag( AuraConfig.WindowEffect .. "TargetEnemyButton", aura:Get( "effect-enemy" ) )
	
	-- Hit Points Settings
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowHitPoints .. "TypeCombo", AuraConfig.ConvertHitPointsTypeToHitPointsTypeComboIndex( aura:Get( "hitpoints-type" ) ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowHitPoints .. "OperatorCombo", aura:Get( "hitpoints-operator" ) )
	TextEditBoxSetText( AuraConfig.WindowHitPoints .. "Value", towstring( aura:Get( "hitpoints-value" ) ) )
	ButtonSetPressedFlag( AuraConfig.WindowHitPoints .. "EnableSecondaryButton", aura:Get( "hitpoints-enablesecondary" ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowHitPoints .. "SecondaryConditionalOperatorCombo", AuraHelpers.fif( aura:Get( "hitpoints-secondaryconditional" ) == true, 1, 2 ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowHitPoints .. "SecondaryOperatorCombo", aura:Get( "hitpoints-secondaryoperator" ) )
	TextEditBoxSetText( AuraConfig.WindowHitPoints .. "SecondaryValue", towstring( aura:Get( "hitpoints-secondaryvalue" ) ) )
	
	-- Morale Settings
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowMorale .. "OperatorCombo", aura:Get( "morale-operator" ) )
	TextEditBoxSetText( AuraConfig.WindowMorale .. "Value", towstring( aura:Get( "morale-value" ) ) )
	ButtonSetPressedFlag( AuraConfig.WindowMorale .. "EnableSecondaryButton", aura:Get( "morale-enablesecondary" ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowMorale .. "SecondaryConditionalOperatorCombo", AuraHelpers.fif( aura:Get( "morale-secondaryconditional" ) == true, 1, 2 ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowMorale .. "SecondaryOperatorCombo", aura:Get( "morale-secondaryoperator" ) )
	TextEditBoxSetText( AuraConfig.WindowMorale .. "SecondaryValue", towstring( aura:Get( "morale-secondaryvalue" ) ) )

	-- Activation Settings
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowActivation .. "AnimationCombo", AuraConfig.ConvertActivationAnimationTypeToActivationAnimationTypeComboIndex( aura:Get( "activation-animation" ) ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowActivation .. "SoundCombo", AuraConfig.ConvertSoundTypeToSoundTypeComboIndex( aura:Get( "activation-sound" ) ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowActivation .. "AlertTextTypeCombo", AuraConfig.ConvertAlertTypeToAlertTextTypeComboIndex( aura:Get( "activation-alerttexttype" ) ) )
	TextEditBoxSetText( AuraConfig.WindowActivation .. "AlertTextText", towstring( aura:Get( "activation-alerttext" ) ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowActivation .. "ScreenFlashCombo", AuraConfig.ConvertActivationScreenFlashTypeToActivationScreenFlashTypeComboIndex( aura:Get( "activation-screenflash" ) ) )
	
	-- Deactivation Settings		
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowDeactivation .. "AnimationCombo", AuraConfig.ConvertDeactivationAnimationTypeToDeactivationAnimationTypeComboIndex( aura:Get( "deactivation-animation" ) ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowDeactivation .. "SoundCombo", AuraConfig.ConvertSoundTypeToSoundTypeComboIndex( aura:Get( "deactivation-sound" ) ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowDeactivation .. "AlertTextTypeCombo", AuraConfig.ConvertAlertTypeToAlertTextTypeComboIndex( aura:Get( "deactivation-alerttexttype" ) ) )
	TextEditBoxSetText( AuraConfig.WindowDeactivation .. "AlertTextText", towstring( aura:Get( "deactivation-alerttext" ) ) )
	ComboBoxSetSelectedMenuItem( AuraConfig.WindowDeactivation .. "ScreenFlashCombo", AuraConfig.ConvertDeactivationScreenFlashTypeToDeactivationScreenFlashTypeComboIndex( aura:Get( "deactivation-screenflash" ) ) )

	-- Timer Settings
	ButtonSetPressedFlag( AuraConfig.WindowTimer .. "DisplayTimerButton", aura:Get( "timer-enabled" ) )
	TextEditBoxSetText( AuraConfig.WindowTimer .. "OffsetX", towstring( aura:Get( "timer-offsetx" ) ) )
	TextEditBoxSetText( AuraConfig.WindowTimer .. "OffsetY", towstring( aura:Get( "timer-offsety" ) ) )
	WindowSetTintColor( AuraConfig.WindowTimer .. "TintColorColor", aura:Get( "timer-tintr" ), aura:Get( "timer-tintg" ), aura:Get( "timer-tintb" ) )
	WindowSetAlpha( AuraConfig.WindowTimer .. "TintColorColor", aura:Get( "timer-alpha" ) )
	
	
	local scalePos = AuraHelpers.ConvertValueToSlider( aura:Get( "timer-scale" ), AuraConstants.TIMER_MIN_SCALE, AuraConstants.TIMER_MAX_SCALE, AuraConstants.TIMER_ROUND )
	SliderBarSetCurrentPosition( AuraConfig.WindowTimer .. "ScaleSlider", scalePos )
	AuraConfig.OnTimerScaleSlide( scalePos, true )

	-- Let our color picker know of the initial color
	AuraColorPicker.SetColor( aura:Get( "texture-tintr" ), aura:Get( "texture-tintg" ), aura:Get( "texture-tintb" ), aura:Get( "texture-alpha" ) )
	
	-- Fire our selection change event
	AuraConfig.OnTriggerTypeSelChanged()
end

function AuraConfig.OnTriggerTypeSelChanged()
	-- Get the selected activation type
	local triggerType = AuraConfig.ConvertTriggerTypeComboIndexToTriggerType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowTrigger .. "TypeCombo" ) )
	
	if( triggerType ~= nil ) then
		--
		for index,window in ipairs( AuraConfig.TriggerTypeWindows )
		do
			WindowSetShowing( AuraConfig.TriggerTypeWindows[index], false )
		end
		
		-- Show our selected effects window	
		WindowSetShowing( AuraConfig.TriggerTypeWindows[triggerType], true)	
	end
end

function AuraConfig.OnClose()
	WindowSetShowing( AuraConfig.Window, false )
end

function AuraConfig.OnHidden()
	WindowSetShowing( AuraColorPicker.Window, false )
	WindowSetShowing( AuraTexture.Window, false )
	
	-- Let settings know we are being hidden, if we have an aura we were editing
	if( editAura ~= nil ) then AuraSettings.OnConfigHidden() end
end

function AuraConfig.OnActivationSoundComboChanged()
	local soundIdx  = AuraConfig.ConvertSoundTypeComboIndexToSoundType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowActivation .. "SoundCombo" ) )
	if( AuraConstants.Sounds[soundIdx] ~= nil and AuraConstants.Sounds[soundIdx].SoundID ~= 0 ) then
		Sound.Play( AuraConstants.Sounds[soundIdx].SoundID )
	end
end

function AuraConfig.OnDeactivationSoundComboChanged()
	local soundIdx  = AuraConfig.ConvertSoundTypeComboIndexToSoundType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowDeactivation .. "SoundCombo" ) )
	if( AuraConstants.Sounds[soundIdx] ~= nil and AuraConstants.Sounds[soundIdx].SoundID ~= 0 ) then
		Sound.Play( AuraConstants.Sounds[soundIdx].SoundID )
	end
end

function AuraConfig.OnLButtonUpTextureTintColor()
	if( timerTintWindowVisible == true) then
		AuraConfig.OnLButtonUpTimerTintColor()
	end
	
	if( not WindowGetShowing( AuraColorPicker.Window ) ) then
		textureTintWindowVisible = true
		WindowClearAnchors( AuraConfig.ColorPicker )
		WindowAddAnchor( AuraConfig.ColorPicker, "bottomright", "AuraConfigTitleBar", "topleft", 0, 4 )
		WindowSetShowing( AuraConfig.ColorPicker, true )
		WindowSetTintColor( AuraConfig.WindowGeneral .. "TintColorFrame", 255, 85, 0 )
	    
	    AuraColorPicker.SetColor( editAura:Get( "texture-tintr" ), editAura:Get( "texture-tintg" ), editAura:Get( "texture-tintb" ), editAura:Get( "texture-alpha" ) )
	else
		WindowSetShowing( AuraConfig.ColorPicker, false )
		WindowSetTintColor( AuraConfig.WindowGeneral .. "TintColorFrame", 255, 255, 255 )
		textureTintWindowVisible = false
	end
end

function AuraConfig.OnLButtonUpTimerTintColor()
	if(textureTintWindowVisible == true) then
		AuraConfig.OnLButtonUpTextureTintColor()
	end 
	
	if( not WindowGetShowing( AuraColorPicker.Window ) ) then
		timerTintWindowVisible = true
		WindowClearAnchors( AuraConfig.ColorPicker )
		WindowAddAnchor( AuraConfig.ColorPicker, "bottomright", "AuraConfigTitleBar", "topleft", 0, 300 )
		WindowSetShowing( AuraConfig.ColorPicker, true )
		WindowSetTintColor( AuraConfig.WindowTimer  .. "TintColorFrame", 255, 85, 0 )
	    
	    AuraColorPicker.SetColor( editAura:Get( "timer-tintr" ), editAura:Get( "timer-tintg" ), editAura:Get( "timer-tintb" ), editAura:Get( "timer-alpha" ) )
	else
		WindowSetShowing( AuraConfig.ColorPicker, false )
		WindowSetTintColor( AuraConfig.WindowTimer .. "TintColorFrame", 255, 255, 255 )
		timerTintWindowVisible = false
	end
end

function AuraConfig.OnIconMouseOver()
    local text = GetString( StringTables.Default.TEXT_SELECT_ICON_BUTTON )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_RIGHT )
end

function AuraConfig.HandleAuraColorPickerChange( r, g, b, a )
	if(timerTintWindowVisible == true) then
		-- Update the aura members for texture color
		WindowSetTintColor( AuraConfig.WindowTimer .. "TintColorColor", r, g, b)
		WindowSetAlpha( AuraConfig.WindowTimer .. "TintColorColor", a )
		
		-- Store the values
		editAura:SetTimerColor( r, g, b )
		editAura:Set( "timer-alpha", a )
	else
		-- Update the aura members for texture color
		WindowSetTintColor( AuraConfig.WindowGeneral .. "TintColor", r, g, b)
		WindowSetAlpha( AuraConfig.WindowGeneral .. "TintColor", a )
		
		-- Store the values
		editAura:SetTextureColor( r, g, b )
		editAura:Set( "texture-alpha", a )
	end
	
	-- Update the display
	AuraConfig.UpdateAuraConfigTextureDisplay( editAura )
	AuraConfig.UpdateAuraConfigTimerDisplay( editAura )
end

function AuraConfig.OnAbilityIconLButtonUp()
	if( Cursor.IconOnCursor() ) then
		-- If the cursor data came from the action list	
		if( Cursor.Data.Source == Cursor.SOURCE_ACTION_LIST ) then
			local abilityData = nil
			
			-- Attempt to retrieve the ability data
			local abilityData = Player.GetAbilityData( Cursor.Data.ObjectId )
			
			if( abilityData == nil ) then
				return
			elseif( abilityData.abilityType == GameData.AbilityType.STANDARD or 
					abilityData.abilityType == GameData.AbilityType.MORALE or
					abilityData.abilityType == GameData.AbilityType.TACTIC ) then
				
				-- Update the display with the proper icon
				AuraConfig.UpdateAbilityDisplay( abilityData.id )
				
				-- Clear the cursor
				Cursor.Clear()
			end
		end
	end
end

function AuraConfig.OnTextureChangeButton()
	if( Cursor.IconOnCursor() ) then
		-- If the cursor data came from the action list	
		if( Cursor.Data.Source == Cursor.SOURCE_ACTION_LIST ) then
			local abilityData = nil
			
			-- Attempt to retrieve the ability data
			local abilityData = Player.GetAbilityData( Cursor.Data.ObjectId )
			
			if( abilityData == nil ) then
				return
			elseif( abilityData.abilityType == GameData.AbilityType.STANDARD or 
					abilityData.abilityType == GameData.AbilityType.MORALE or
					abilityData.abilityType == GameData.AbilityType.TACTIC ) then
				
				-- Set the texture to that of the ability dropped on us
				AuraConfig.OnTextureChanged( AuraConstants.TEXTURE_TYPE_ICON, abilityData.iconNum )
				
				-- Clear the cursor
				Cursor.Clear()
			end
		end
	else
		if( DoesWindowExist( AuraTexture.Window ) ) then
			WindowSetShowing( AuraTexture.Window, not WindowGetShowing( AuraTexture.Window ) )
		end
	end
end

function AuraConfig.OnCircledImageChanged()
	-- Call our base function so the toggle takes place
	EA_LabelCheckButton.Toggle()
	
	-- Retrieve the circled image value
	local checked = ButtonGetPressedFlag( AuraConfig.WindowGeneral .. "CircledImageButton" )
	
	if( editAura:Get( "texture-circledimage" ) ~= checked ) then
		editAura:Set( "texture-circledimage", checked )
		-- Update the display
		AuraConfig.UpdateAuraConfigTextureDisplay( editAura )
	end
end

function AuraConfig.OnMirrorImageChanged()
	-- Call our base function so the toggle takes place
	EA_LabelCheckButton.Toggle()
	
	-- Retrieve the circled image value
	local checked = ButtonGetPressedFlag( AuraConfig.WindowGeneral .. "MirrorImageButton" )
	
	if( editAura:Get( "texture-mirrorimage" ) ~= checked ) then
		editAura:Set( "texture-mirrorimage", checked )
		-- Update the display
		AuraConfig.UpdateAuraConfigTextureDisplay( editAura )
	end
end

function AuraConfig.OnTextureChanged( type, texture )
	if( editAura:Get( "texture-type" ) ~= type or editAura:Get( "texture-id" ) ~= texture ) then
		editAura:SetTexture( type, texture )
		AuraConfig.UpdateAuraConfigTextureDisplay( editAura )
	end
end

function AuraConfig.OnTextureOffsetXChanged( text )
	local _value = tonumber( text )
	
	-- If the value entered in isnt valid, set it to zero
	if( _value == nil ) then 
		_value = 0
	end
	
	if( editAura:Get( "texture-offsetx" ) ~= _value ) then
		editAura:Set( "texture-offsetx", _value )
	
		AuraConfig.UpdateAuraConfigTextureDisplay( editAura )
	end
end

function AuraConfig.OnTextureOffsetYChanged( text )
	local _value = tonumber( text )
	
	-- If the value entered in isnt valid, set it to zero
	if( _value == nil ) then 
		_value = 0
	end
	
	if( editAura:Get( "texture-offsety" ) ~= _value ) then
		editAura:Set( "texture-offsety", _value )
	
		AuraConfig.UpdateAuraConfigTextureDisplay( editAura )
	end
end

function AuraConfig.OnTextureScaleSlide( pos, forceUpdate )
	local _value = AuraHelpers.ConvertSliderToValue( pos, AuraConstants.TEXTURE_MIN_SCALE, AuraConstants.TEXTURE_MAX_SCALE, 3 )
	
	-- Prevent needless updates	
	if( editAura:Get( "texture-scale" ) ~= _value or ( forceUpdate ~= nil and forceUpdate ) ) then
		
		editAura:Set( "texture-scale", _value )
		
		AuraConfig.UpdateAuraConfigTextureDisplay( editAura )
		
		-- Update our scale display
		local display = string.format( "%s:  %d%%", "Scale", _value * 100 )
		LabelSetText( AuraConfig.WindowGeneral .. "TextureScaleTitle", towstring( display ) )
	end
end

function AuraConfig.OnTextureRotationSlide( pos, forceUpdate )
	local _value = AuraHelpers.ConvertSliderToValue( pos, 0, 360, 3 )
	
	-- Prevent needless updates	
	if( editAura:Get( "texture-rotation" ) ~= _value or ( forceUpdate ~= nil and forceUpdate ) ) then
		
		editAura:Set( "texture-rotation", _value )
	
		AuraConfig.UpdateAuraConfigTextureDisplay( editAura )
		
		-- Update our scale display
		local display = string.format( "%s:  %d", "Rotation", _value )
		LabelSetText( AuraConfig.WindowGeneral .. "TextureRotationTitle", towstring( display ) )
	end
end

function AuraConfig.OnActivationAlertTextTestButton()
	local alertType, alertText
	
	alertType = AuraConfig.ConvertAlertTextTypeComboIndexToAlertType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowActivation .. "AlertTextTypeCombo" ) )
	alertText = TextEditBoxGetText( AuraConfig.WindowActivation .. "AlertTextText" )
	
	if( alertType ~= 1 and alertText ~= L"" ) then
		AlertTextWindow.AddLine( AuraConstants.AlertText[alertType].type, alertText );
	end
end

function AuraConfig.OnDeactivationAlertTextTestButton()
	local alertType, alertText
	
	alertType = AuraConfig.ConvertAlertTextTypeComboIndexToAlertType( ComboBoxGetSelectedMenuItem( AuraConfig.WindowDeactivation .. "AlertTextTypeCombo" ) )
	alertText = TextEditBoxGetText( AuraConfig.WindowDeactivation .. "AlertTextText" )
	
	if( alertType ~= 1 and alertText ~= L"" ) then
		AlertTextWindow.AddLine( AuraConstants.AlertText[alertType].type, alertText );
	end
end

function AuraConfig.OnDisplayTimerChanged()
	-- Call our base function so the toggle takes place
	EA_LabelCheckButton.Toggle()
	
	-- Retrieve the circled image value
	local checked = ButtonGetPressedFlag( AuraConfig.WindowTimer .. "DisplayTimerButton" )
	
	if( editAura:Get( "timer-enabled" ) ~= checked ) then
		editAura:Set( "timer-enabled", checked )
		-- Update the display
		AuraConfig.UpdateAuraConfigTimerDisplay( editAura )
	end
end

function AuraConfig.OnTimerOffsetXChanged( text )
	local _value = tonumber( text )
	
	-- If the value entered in isnt valid, set it to zero
	if( _value == nil ) then 
		_value = 0
	end
	
	if( editAura:Get( "timer-offsetx" ) ~= _value ) then
		editAura:Set( "timer-offsetx", _value )
	
		AuraConfig.UpdateAuraConfigTimerDisplay( editAura )
	end
end

function AuraConfig.OnTimerOffsetYChanged( text )
	local _value = tonumber( text )
	
	-- If the value entered in isnt valid, set it to zero
	if( _value == nil ) then 
		_value = 0
	end
	
	if( editAura:Get( "timer-offsety" ) ~= _value ) then
		editAura:Set( "timer-offsety", _value )
	
		AuraConfig.UpdateAuraConfigTimerDisplay( editAura )
	end
end

function AuraConfig.OnTimerScaleSlide( pos, forceUpdate )
	local _value = AuraHelpers.ConvertSliderToValue( pos, AuraConstants.TIMER_MIN_SCALE, AuraConstants.TIMER_MAX_SCALE, AuraConstants.TIMER_ROUND )
	
	-- Prevent needless updates	
	if( editAura:Get( "timer-scale" ) ~= _value or ( forceUpdate ~= nil and forceUpdate ) ) then
		
		editAura:Set( "timer-scale", _value )
		
		AuraConfig.UpdateAuraConfigTimerDisplay( editAura )
		
		-- Update our scale display
		local display = string.format( "%s:  %d%%", "Scale", _value * 100 )
		LabelSetText( AuraConfig.WindowTimer .. "ScaleTitle", towstring( display ) )
	end
end

function AuraConfig.UpdateAuraConfigTextureDisplay( aura )

	local texture, slice, dx, dy =  aura:GetTextureData()
		
	if( texture ~= nil  ) then
		-- Update the configuration texture
		AuraHelpers.SetDynamicImageTexture( AuraConfig.WindowGeneral .. "IconButtonIcon", texture, slice, dx, dy, 
			aura:Get( "texture-tintr" ), aura:Get( "texture-tintg" ), aura:Get( "texture-tintb" ), aura:Get( "texture-alpha" ), 0, aura:Get( "texture-mirrorimage" ) )
				
		-- If the user is viewing the texture for placement purposes, update that one too
		if( aura:IsEditWindowDisplayed() ) then
			aura:ShowEditWindows()
		end
	else
		AuraHelpers.SetDynamicImageTexture( AuraConfig.WindowGeneral .. "IconButtonIcon", "", "", 0, 0, 255, 255, 255, 255, 0, false ) 
	end
end

function AuraConfig.UpdateAuraConfigTimerDisplay( aura )
	if( aura:IsEditWindowDisplayed() ) then
		aura:ShowEditWindows()
	end
end

function AuraConfig.UpdateAbilityDisplay( abilityId )
	-- Store the id of the action we are displaying
	editAura:Set( "ability-abilityid", abilityId )
	
	local window = AuraConfig.WindowAbility .. "WrapperButton"

	if( abilityId ~= nil and abilityId > 0 ) then
		-- Retireve the ability data
		local abilityData = Player.GetAbilityData( abilityId )
		
		if( abilityData ~= nil ) then
			-- Retrieve the ability texture information
			local texture, x, y, disabledTexture = GetIconData( abilityData.iconNum )
			
			-- Display the texture	
			DynamicImageSetTexture( window .. "SquareIcon", texture, 64, 64 )
			
			local texture, x, y = GetIconData( abilityData.iconNum )
	        
			-- Set the text information
	        LabelSetText( window .."Desc", GetStringFormat( StringTables.Default.LABEL_ABILITIES_WINDOW_ABILITY_NAME_FORMAT, {abilityData.name} ) )
	        LabelSetText( window .."DescPath", DataUtils.GetAbilitySpecLine( abilityData ) )
	        
	        local abilityTypeText = DataUtils.GetAbilityTypeText( abilityData )
	        LabelSetText( window .. "DescType", abilityTypeText )
	        local _, _, _, r, g, b = DataUtils.GetAbilityTypeTextureAndColor( abilityData )
	        
	        LabelSetTextColor( window .. "DescType", r, g, b)
	    end
	else
		-- No ability given, clear the display
		AuraDebug( "Attempting to clear ablity trigger texture display" )
		DynamicImageSetTexture( window .. "SquareIcon", "EA_Abilities01_d5", 32, 32 )
		DynamicImageSetTextureSlice( window .. "SquareIcon" , "AbilityIconFrame" )
        
		LabelSetText( window .."Desc", L"" )
        LabelSetText( window .."DescPath", L"" )
        LabelSetText( window .. "DescType", L"" )
    end
end

function AuraConfig.OnConfigTabSelected()
	local tabId = WindowGetId( SystemData.ActiveWindow.name )
	
	for index, window in ipairs( AuraConfig.ConfigurationWindows )
	do
		ButtonSetPressedFlag( window.button, index == tabId )
		WindowSetShowing( window.name, index == tabId )
	end
end

function AuraConfig.BuildOperatorCombo( window )
	ComboBoxAddMenuItem( window, L"=" )
	ComboBoxAddMenuItem( window, L"<" )
	ComboBoxAddMenuItem( window, L">" )
	ComboBoxAddMenuItem( window, L"!=" )
end

function AuraConfig.BuildSecondaryConditionalCombo( window )
	ComboBoxAddMenuItem( window, L"AND" )
	ComboBoxAddMenuItem( window, L"OR" )
end

function AuraConfig.BuildTriggerTypeCombo()
	local display = AuraHelpers.CreateComboDisplay( AuraConstants.Trigger )
	
	for index, data in ipairs( display )
	do
		ComboBoxAddMenuItem( AuraConfig.WindowTrigger .. "TypeCombo", data.Name )
		TriggerTypeComboIndexToTriggerType[index] = data.Index
		TriggerTypeToTriggerTypeComboIndex[data.Index] = index
	end
end

function AuraConfig.BuildEffectTypeCombo()
	local display = AuraHelpers.CreateComboDisplay( AuraConstants.Effects )
	
	for index, data in ipairs( display )
	do
		ComboBoxAddMenuItem( AuraConfig.WindowEffect .. "TypeCombo", data.Name )
		EffectTypeComboIndexToEffectType[index] = data.Index
		EffectTypeToEffectTypeComboIndex[data.Index] = index
	end
end

function AuraConfig.BuildActivationAnimationTypeCombo()
	local display = AuraHelpers.CreateComboDisplay( AuraConstants.ActivationAnimations )
	
	for index, data in ipairs( display )
	do
		ComboBoxAddMenuItem( AuraConfig.WindowActivation .. "AnimationCombo", data.Name )
		ActivationAnimationTypeComboIndexToActivationAnimationType[index] = data.Index
		ActivationAnimationTypeToActivationAnimationTypeComboIndex[data.Index] = index
	end
end

function AuraConfig.BuildActivationScreenFlashTypeCombo()
	local display = AuraHelpers.CreateComboDisplay( AuraConstants.ActivationScreenFlash )
	
	for index, data in ipairs( display )
	do
		ComboBoxAddMenuItem( AuraConfig.WindowActivation .. "ScreenFlashCombo", data.Name )
		ActivationScreenFlashTypeComboIndexToScreenFlashType[index] = data.Index
		ActivationScreenFlashTypeToScreenFlashTypeComboIndex[data.Index] = index
	end
end

function AuraConfig.BuildDeactivationAnimationTypeCombo()
	local display = AuraHelpers.CreateComboDisplay( AuraConstants.DeactivationAnimations )
	
	for index, data in ipairs( display )
	do
		ComboBoxAddMenuItem( AuraConfig.WindowDeactivation .. "AnimationCombo", data.Name )
		DeactivationAnimationTypeComboIndexToDeactivationAnimationType[index] = data.Index
		DeactivationAnimationTypeToDeactivationAnimationTypeComboIndex[data.Index] = index
	end
end

function AuraConfig.BuildDeactivationScreenFlashTypeCombo()
	local display = AuraHelpers.CreateComboDisplay( AuraConstants.DeactivationAnimations )
	
	for index, data in ipairs( display )
	do
		ComboBoxAddMenuItem( AuraConfig.WindowDeactivation .. "ScreenFlashCombo", data.Name )
		DectivationScreenFlashTypeComboIndexToScreenFlashType[index] = data.Index
		DeactivationScreenFlashTypeToScreenFlashTypeComboIndex[data.Index] = index
	end
end


function AuraConfig.BuildSoundTypeCombos()
	local display = AuraHelpers.CreateComboDisplay( AuraConstants.Sounds )
	
	for index, data in ipairs( display )
	do
		ComboBoxAddMenuItem( AuraConfig.WindowActivation .. "SoundCombo", data.Name )
		ComboBoxAddMenuItem( AuraConfig.WindowDeactivation .. "SoundCombo", data.Name )
		SoundTypeComboIndexToSoundType[index] = data.Index
		SoundTypeToSoundTypeComboIndex[data.Index] = index
	end
end

function AuraConfig.BuildAlertTextCombos()
	local display = AuraHelpers.CreateComboDisplay( AuraConstants.AlertText )
	
	for index, data in ipairs( display )
	do
		ComboBoxAddMenuItem( AuraConfig.WindowActivation .. "AlertTextTypeCombo", data.Name )
		ComboBoxAddMenuItem( AuraConfig.WindowDeactivation .. "AlertTextTypeCombo", data.Name )
		AlertTextTypeComboIndexToAlertTextType[index] = data.Index
		AlertTextTypeToAlertTextTypeComboIndex[data.Index] = index
	end
end

function AuraConfig.BuildHitPointsTypeCombo()
	local display = AuraHelpers.CreateComboDisplay( AuraConstants.HitPointTypes )
	
	for index, data in ipairs( display )
	do
		ComboBoxAddMenuItem( AuraConfig.WindowHitPoints .. "TypeCombo", data.Name )
		HitPointsTypeComboIndexToHitPointsType[index] = data.Index
		HitPointsTypeToHitPointsTypeComboIndex[data.Index] = index
	end
end

function AuraConfig.ConvertTriggerTypeComboIndexToTriggerType( index )
	return TriggerTypeComboIndexToTriggerType[index]
end

function AuraConfig.ConvertTriggerTypeToTriggerTypeComboIndex( index )
	return TriggerTypeToTriggerTypeComboIndex[index]
end

function AuraConfig.ConvertEffectTypeComboIndexToEffectType( index )
	return EffectTypeComboIndexToEffectType[index]
end

function AuraConfig.ConvertEffectTypeToEffectTypeComboIndex( index )
	return EffectTypeToEffectTypeComboIndex[index]
end

function AuraConfig.ConvertActivationAnimationTypeComboIndexToActivationAnimationType( index )
	return ActivationAnimationTypeComboIndexToActivationAnimationType[index]
end

function AuraConfig.ConvertActivationAnimationTypeToActivationAnimationTypeComboIndex( index )
	return ActivationAnimationTypeToActivationAnimationTypeComboIndex[index]
end

function AuraConfig.ConvertDeactivationAnimationTypeComboIndexToDeactivationAnimationType( index )
	return DeactivationAnimationTypeComboIndexToDeactivationAnimationType[index]
end

function AuraConfig.ConvertDeactivationAnimationTypeToDeactivationAnimationTypeComboIndex( index )
	return DeactivationAnimationTypeToDeactivationAnimationTypeComboIndex[index]
end

function AuraConfig.ConvertActivationScreenFlashTypeComboIndexToActivationScreenFlashType( index )
	return ActivationScreenFlashTypeComboIndexToScreenFlashType[index]
end

function AuraConfig.ConvertActivationScreenFlashTypeToActivationScreenFlashTypeComboIndex( index )
	return ActivationScreenFlashTypeToScreenFlashTypeComboIndex[index]
end

function AuraConfig.ConvertDeactivationScreenFlashTypeComboIndexToDeactivationScreenFlashType( index )
	return DectivationScreenFlashTypeComboIndexToScreenFlashType[index]
end

function AuraConfig.ConvertDeactivationScreenFlashTypeToDeactivationScreenFlashTypeComboIndex( index )
	return DeactivationScreenFlashTypeToScreenFlashTypeComboIndex[index]
end

function AuraConfig.ConvertSoundTypeComboIndexToSoundType( index )
	return SoundTypeComboIndexToSoundType[index]
end

function AuraConfig.ConvertSoundTypeToSoundTypeComboIndex( index )
	return SoundTypeToSoundTypeComboIndex[index]
end

function AuraConfig.ConvertAlertTextTypeComboIndexToAlertType( index )
	return AlertTextTypeComboIndexToAlertTextType[index]
end

function AuraConfig.ConvertAlertTypeToAlertTextTypeComboIndex( index )
	return AlertTextTypeToAlertTextTypeComboIndex[index]
end

function AuraConfig.ConvertHitPointsTypeComboIndexToHitPointsType( index )
	return HitPointsTypeComboIndexToHitPointsType[index]
end

function AuraConfig.ConvertHitPointsTypeToHitPointsTypeComboIndex( index )
	return HitPointsTypeToHitPointsTypeComboIndex[index]
end
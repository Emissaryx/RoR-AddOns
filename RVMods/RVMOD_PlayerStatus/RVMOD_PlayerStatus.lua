local mmin = math.min
local mmax = math.max
local WindowGetDimensions = WindowGetDimensions
local WindowSetDimensions = WindowSetDimensions
local pairs = pairs
local DestroyWindow = DestroyWindow


RVMOD_PlayerStatus = {}
local RVMOD_PlayerStatus		= RVMOD_PlayerStatus

local RVName					= "Player Status"
local RVCredits					= "silverq"
local RVLicense					= "MIT License"
local RVProjectURL				= "http://www.returnofreckoning.com/forum/viewtopic.php?f=11&t=4534"
local RVRecentUpdates			= 
"09.07.2015 - v1.12 Release\n"..
"\t- Project official site location has been changed\n"..
"\n"..
"24.02.2010 - v1.11 Release\n"..
"\t- Code clearance\n"..
"\t- Adapted to work with the RV Mods Manager v0.99"

local isFaded

local WindowNameSettings		= "RVMOD_PlayerStatusSettings"
local WindowNameBars			= "RVMOD_PlayerStatus"
local HealthBarCurrentValue		= 0
local HealthBarDisplayedValue	= 0
local HealthBarMaximumValue		= 100
local HealthBarInterpTime		= nil
local HealthBarIsInterpolating	= false
local ActionBarCurrentValue		= 0
local ActionBarDisplayedValue	= 0
local ActionBarMaximumValue		= 100
local ActionBarInterpTime		= nil
local ActionBarIsInterpolating	= false

--------------------------------------------------------------
-- var DefaultConfiguration
-- Description: default module configuration
--------------------------------------------------------------
RVMOD_PlayerStatus.DefaultConfiguration =
{
	EnableBars				= true,		-- show bar
	BarsPositionPoint		= "center",	-- 
	BarsPositionRelPoint	= "center",	-- 
	BarsPositionRelWin		= "Root",	-- 
	BarsPositionX			= 100,		-- 
	BarsPositionY			= 120,		-- 

	HEALTH_RED				= 0,		-- health color R
	HEALTH_GREEN			= 1,		-- health color G
	HEALTH_BLUE				= 0,		-- health color B
	HEALTH_ALPHA			= 0.5,		-- health color A
	ACTION_RED				= 1,		-- action color R
	ACTION_GREEN			= 1,		-- action color G
	ACTION_BLUE				= 0,		-- action color B
	ACTION_ALPHA			= 0.5,		-- action color A
}

--------------------------------------------------------------
-- var CurrentConfiguration
-- Description: current module configuration
--------------------------------------------------------------
RVMOD_PlayerStatus.CurrentConfiguration =
{
	-- should stay empty, will load in the InitializeConfiguration() function
}

--------------------------------------------------------------
-- function Initialize()
-- Description:
--------------------------------------------------------------
function RVMOD_PlayerStatus.Initialize()

	-- First step: load configuration
	RVMOD_PlayerStatus.InitializeConfiguration()

	-- Second step: define event handlers
	RegisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "RVMOD_PlayerStatus.OnAllModulesInitialized")

	-- Third step: update bar with the current configuration/settings
	if RVMOD_PlayerStatus.CurrentConfiguration.EnableBars then
		RVMOD_PlayerStatus.EnableBars()
	else
		RVMOD_PlayerStatus.DisableBars()
	end

	-- Final step: start tracking changes in the LayoutEditor
	table.insert(LayoutEditor.EventHandlers, RVMOD_PlayerStatus.OnSaveBarsWindowPosition)
end

--------------------------------------------------------------
-- function Shutdown()
-- Description:
--------------------------------------------------------------
function RVMOD_PlayerStatus.Shutdown()

	-- First step: unregister all events
	UnregisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "RVMOD_PlayerStatus.OnAllModulesInitialized")

	-- Second step: disable all bars
	RVMOD_PlayerStatus.DisableBars()

	-- Final step: destroy settings window
	if DoesWindowExist(WindowNameSettings) then
		DestroyWindow(WindowNameSettings)
	end
end

--------------------------------------------------------------
-- function EnableBars()
-- Description:
--------------------------------------------------------------
function RVMOD_PlayerStatus.EnableBars()

	-- First step: create and show the RVMOD_PlayerStatus window
	if not DoesWindowExist(WindowNameBars) then
		CreateWindow(WindowNameBars, true)
	end

	-- Second step: position RVMOD_PlayerStatus window
	WindowClearAnchors(WindowNameBars)
	WindowAddAnchor(
		WindowNameBars,
		RVMOD_PlayerStatus.CurrentConfiguration.BarsPositionRelPoint,
		RVMOD_PlayerStatus.CurrentConfiguration.BarsPositionRelWin,
		RVMOD_PlayerStatus.CurrentConfiguration.BarsPositionPoint,
		RVMOD_PlayerStatus.CurrentConfiguration.BarsPositionX,
		RVMOD_PlayerStatus.CurrentConfiguration.BarsPositionY
	)

	-- Third step: register RVMOD_PlayerStatus window in the LayoutEditor
	LayoutEditor.RegisterWindow(WindowNameBars, L"RVMOD_PlayerStatus", L"Displays player health and AP", false, true, true, nil)

	-- Fourth step: create frames (RV_VerticalBar based on Frame class)
	WindowRegisterCoreEventHandler(WindowNameBars.."HealthBar", "OnUpdate", "RVMOD_PlayerStatus.OnUpdateHealthBar")
	WindowRegisterCoreEventHandler(WindowNameBars.."ActionBar", "OnUpdate", "RVMOD_PlayerStatus.OnUpdateActionBar")
	HealthBarCurrentValue	= 0
	HealthBarDisplayedValue	= 0
	HealthBarMaximumValue	= 100
	ActionBarCurrentValue	= 0
	ActionBarDisplayedValue	= 0
	ActionBarMaximumValue	= 100

	-- Fifth step: set frames data
	RVMOD_PlayerStatus.UpdateMaximumActionPoints()
	RVMOD_PlayerStatus.UpdateCurrentActionPoints()
	RVMOD_PlayerStatus.UpdateMaximumHitPoints()
	RVMOD_PlayerStatus.UpdateCurrentHitPoints()

	-- Sixth step: define event handlers
	WindowRegisterEventHandler(WindowNameBars, SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED,	"RVMOD_PlayerStatus.UpdateCurrentActionPoints")
	WindowRegisterEventHandler(WindowNameBars, SystemData.Events.PLAYER_MAX_ACTION_POINTS_UPDATED,	"RVMOD_PlayerStatus.UpdateMaximumActionPoints")
	WindowRegisterEventHandler(WindowNameBars, SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED,		"RVMOD_PlayerStatus.UpdateCurrentHitPoints")
	WindowRegisterEventHandler(WindowNameBars, SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED,		"RVMOD_PlayerStatus.UpdateMaximumHitPoints")
	WindowRegisterEventHandler(WindowNameBars, SystemData.Events.LOADING_END,						"RVMOD_PlayerStatus.UpdateFade")

	-- Final step: set frames with colors
	RVMOD_PlayerStatus.UpdateBar()
end

--------------------------------------------------------------
-- function DisableBars()
-- Description:
--------------------------------------------------------------
function RVMOD_PlayerStatus.DisableBars()

	-- First step: unregister events
	if DoesWindowExist(WindowNameBars) then
		WindowUnregisterEventHandler(WindowNameBars, SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED)
		WindowUnregisterEventHandler(WindowNameBars, SystemData.Events.PLAYER_MAX_ACTION_POINTS_UPDATED)
		WindowUnregisterEventHandler(WindowNameBars, SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED)
		WindowUnregisterEventHandler(WindowNameBars, SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED)
		WindowUnregisterEventHandler(WindowNameBars, SystemData.Events.LOADING_END)

		WindowUnregisterCoreEventHandler(WindowNameBars.."HealthBar", "OnUpdate")
		WindowUnregisterCoreEventHandler(WindowNameBars.."ActionBar", "OnUpdate")
	end

	-- Second step: unregister window in the LayoutEditor
	LayoutEditor.UnregisterWindow(WindowNameBars)

	-- Final step: destroy RVMOD_PlayerStatus window
	if DoesWindowExist(WindowNameBars) then
		DestroyWindow(WindowNameBars)
	end
end

--------------------------------------------------------------
-- function InitializeConfiguration()
-- Description: loads current configuration
--------------------------------------------------------------
function RVMOD_PlayerStatus.InitializeConfiguration()

	-- First step: move default values to the CurrentConfiguration variable
	for k,v in pairs(RVMOD_PlayerStatus.DefaultConfiguration) do
		if(RVMOD_PlayerStatus.CurrentConfiguration[k]==nil) then
			RVMOD_PlayerStatus.CurrentConfiguration[k]=v
		end
	end
end

--------------------------------------------------------------
-- function OnAllModulesInitialized()
-- Description: event ALL_MODULES_INITIALIZED
-- We can start working with the RVAPI just then we sure they are all initialized
-- and ready to provide their services
--------------------------------------------------------------
function RVMOD_PlayerStatus.OnAllModulesInitialized()

	-- Final step: register in the RV Mods Manager
	-- Please note the folowing:
	-- 1. always do this ON SystemData.Events.ALL_MODULES_INITIALIZED event
	-- 2. you don't need to add RVMOD_Manager to the dependency list
	-- 3. the registration code should be same as below, with your own function parameters
	-- 4. for more information please follow by project official site
	if RVMOD_Manager then
		RVMOD_Manager.API_RegisterAddon("RVMOD_PlayerStatus", RVMOD_PlayerStatus, RVMOD_PlayerStatus.OnRVManagerCallback)
	end
end

--------------------------------------------------------------
-- function OnRVManagerCallback
-- Description:
--------------------------------------------------------------
function RVMOD_PlayerStatus.OnRVManagerCallback(Self, Event, EventData)

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

		if not DoesWindowExist(WindowNameSettings) then
			RVMOD_PlayerStatus.InitializeSettingsWindow()
		end

		WindowSetParent(WindowNameSettings, EventData.ParentWindow)
		WindowClearAnchors(WindowNameSettings)
		WindowAddAnchor(WindowNameSettings, "topleft", EventData.ParentWindow, "topleft", 0, 0)
		WindowAddAnchor(WindowNameSettings, "bottomright", EventData.ParentWindow, "bottomright", 0, 0)

		RVMOD_PlayerStatus.UpdateWindowSettings()

		return true

	end
end

--------------------------------------------------------------
-- function InitializeSettingsWindow()
-- Description:
--------------------------------------------------------------
function RVMOD_PlayerStatus.InitializeSettingsWindow()

	-- First step: create main window
	CreateWindow(WindowNameSettings, true)
--	WindowSetParent(WindowNameSettings, ParentWindow.name)
--	WindowClearAnchors(WindowNameSettings)
--	WindowAddAnchor(WindowNameSettings, "topleft", ParentWindow.name, "topleft", 0, 0)
--	WindowAddAnchor(WindowNameSettings, "bottomright", ParentWindow.name, "bottomright", 0, 0)

	-- Second step: define strings
	LabelSetText(WindowNameSettings.."LabelEnable", L"Enabled")
	LabelSetTextColor(WindowNameSettings.."LabelEnable", 255, 255, 255)

	LabelSetText(WindowNameSettings.."HPBarColorCaption", L"Health Bar Color")
	LabelSetTextColor(WindowNameSettings.."LabelEnable", 255, 255, 255)

	LabelSetText(WindowNameSettings.."APBarColorCaption", L"Action Bar Color")
	LabelSetTextColor(WindowNameSettings.."LabelEnable", 255, 255, 255)
end

--------------------------------------------------------------
-- function OnSaveBarsWindowPosition()
-- Description:
--------------------------------------------------------------
function RVMOD_PlayerStatus.OnSaveBarsWindowPosition(eventId)

	-- First step: check event
	if eventId == LayoutEditor.EDITING_END then

		-- Second step: check for window exist
		if DoesWindowExist(WindowNameBars) then

			-- Final step: set position
			RVMOD_PlayerStatus.CurrentConfiguration.BarsPositionPoint,
			RVMOD_PlayerStatus.CurrentConfiguration.BarsPositionRelPoint,
			RVMOD_PlayerStatus.CurrentConfiguration.BarsPositionRelWin,
			RVMOD_PlayerStatus.CurrentConfiguration.BarsPositionX,
			RVMOD_PlayerStatus.CurrentConfiguration.BarsPositionY = WindowGetAnchor(WindowNameBars, 1)
		end
	end
end

--------------------------------------------------------------
-- function UpdateWindowSettings()
-- Description:
--------------------------------------------------------------
function RVMOD_PlayerStatus.UpdateWindowSettings()

	-- First step:
	ButtonSetPressedFlag(WindowNameSettings.."CheckBoxEnable", RVMOD_PlayerStatus.CurrentConfiguration.EnableBars)

	-- Second step: update Health bar information
	WindowSetTintColor(WindowNameSettings.."HPBarColorBorderForeground", RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_RED*255, RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_GREEN*255, RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_BLUE*255) 

	-- Third step: update Action bar information
	WindowSetTintColor(WindowNameSettings.."APBarColorBorderForeground", RVMOD_PlayerStatus.CurrentConfiguration.ACTION_RED*255, RVMOD_PlayerStatus.CurrentConfiguration.ACTION_GREEN*255, RVMOD_PlayerStatus.CurrentConfiguration.ACTION_BLUE*255) 
end

--------------------------------------------------------------
-- function UpdateBar()
-- Description:
--------------------------------------------------------------
function RVMOD_PlayerStatus.UpdateBar()

	local DisplayedValue

	-- First step: get colors
	local HealthRed		= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_RED*255)
	local HealthGreen	= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_GREEN*255)
	local HealthBlue	= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_BLUE*255)
	local HealthAlpha	= RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_ALPHA

	-- Second step: set colors
	WindowSetTintColor(WindowNameBars.."HealthBarForeground", HealthRed, HealthGreen, HealthBlue)
	WindowSetAlpha(WindowNameBars.."HealthBarForeground", HealthAlpha)
	LabelSetTextColor(WindowNameBars.."HealthText", HealthRed, HealthGreen, HealthBlue)
	DisplayedValue = HealthBarDisplayedValue
	RVMOD_PlayerStatus.SetHealthBarDisplayedValue(0)
	RVMOD_PlayerStatus.SetHealthBarDisplayedValue(DisplayedValue)

	-- Third step: get colors
	local ActionRed		= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.ACTION_RED*255)
	local ActionGreen	= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.ACTION_GREEN*255)
	local ActionBlue	= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.ACTION_BLUE*255)
	local ActionAlpha	= RVMOD_PlayerStatus.CurrentConfiguration.ACTION_ALPHA

	-- Fourth step: set colors
	WindowSetTintColor(WindowNameBars.."ActionBarForeground", ActionRed, ActionGreen, ActionBlue)
	WindowSetAlpha(WindowNameBars.."ActionBarForeground", ActionAlpha)
	LabelSetTextColor(WindowNameBars.."ActionText", ActionRed, ActionGreen, ActionBlue)
	DisplayedValue = ActionBarDisplayedValue
	RVMOD_PlayerStatus.SetActionBarDisplayedValue(0)
	RVMOD_PlayerStatus.SetActionBarDisplayedValue(DisplayedValue)

	-- Final step: temporaly show updates
	isFaded = false
	RVMOD_PlayerStatus.UpdateFade()
end

--------------------------------------------------------------
-- function 
-- Description: 
--------------------------------------------------------------
function RVMOD_PlayerStatus.SetEnable()

	-- First step: invert flag status
	local checkBoxName = SystemData.MouseOverWindow.name
	RVMOD_PlayerStatus.CurrentConfiguration.EnableBars = not RVMOD_PlayerStatus.CurrentConfiguration.EnableBars
	ButtonSetPressedFlag(checkBoxName, RVMOD_PlayerStatus.CurrentConfiguration.EnableBars)

	-- Final step: enable/disable bar
	if RVMOD_PlayerStatus.CurrentConfiguration.EnableBars then
		RVMOD_PlayerStatus.EnableBars()
	else
		RVMOD_PlayerStatus.DisableBars()
	end
end

function RVMOD_PlayerStatus.OnLButtonUpHPBarColor()

	-- First step: get locals
	local Red	= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_RED*255)
	local Green	= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_GREEN*255)
	local Blue	= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_BLUE*255)
	local Alpha	= RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_ALPHA
	local ColorDialogOwner, ColorDialogFunction = RVAPI_ColorDialog.API_GetLink()

	-- Second step: check for the current color dialog link
	if ColorDialogOwner ~= RVMOD_PlayerStatus or ColorDialogFunction ~= RVMOD_PlayerStatus.OnColorDialogCallbackHPBar then

		-- Third step: open color dialog
		RVAPI_ColorDialog.API_OpenDialog(RVMOD_PlayerStatus, RVMOD_PlayerStatus.OnColorDialogCallbackHPBar, true, Red, Green, Blue, Alpha, Window.Layers.SECONDARY)
	else

		-- Fourth step: close color dialog
		RVAPI_ColorDialog.API_CloseDialog(true)
	end
end

function RVMOD_PlayerStatus.OnColorDialogCallbackHPBar(Object, Event, EventData)

	-- First step: check for the right event
	if Event == RVAPI_ColorDialog.Events.COLOR_EVENT_UPDATED then

		-- : set color box value
		WindowSetTintColor(WindowNameSettings.."HPBarColorBorderForeground", EventData.Red, EventData.Green, EventData.Blue) 

		-- : set new color values
		RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_RED		= EventData.Red / 255
		RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_GREEN	= EventData.Green / 255
		RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_BLUE		= EventData.Blue / 255
		RVMOD_PlayerStatus.CurrentConfiguration.HEALTH_ALPHA	= EventData.Alpha

		-- : update health bar
		if DoesWindowExist(WindowNameBars) then
			RVMOD_PlayerStatus.UpdateBar()
		end
	end
end

function RVMOD_PlayerStatus.OnLButtonUpAPBarColor()

	-- First step: get locals
	local Red	= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.ACTION_RED*255)
	local Green	= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.ACTION_GREEN*255)
	local Blue	= math.floor(RVMOD_PlayerStatus.CurrentConfiguration.ACTION_BLUE*255)
	local Alpha	= RVMOD_PlayerStatus.CurrentConfiguration.ACTION_ALPHA
	local ColorDialogOwner, ColorDialogFunction = RVAPI_ColorDialog.API_GetLink()

	-- Second step: check for the current color dialog link
	if ColorDialogOwner ~= RVMOD_PlayerStatus or ColorDialogFunction ~= RVMOD_PlayerStatus.OnColorDialogCallbackAPBar then

		-- Third step: open color dialog
		RVAPI_ColorDialog.API_OpenDialog(RVMOD_PlayerStatus, RVMOD_PlayerStatus.OnColorDialogCallbackAPBar, true, Red, Green, Blue, Alpha, Window.Layers.SECONDARY)
	else

		-- Fourth step: close color dialog
		RVAPI_ColorDialog.API_CloseDialog(true)
	end
end

function RVMOD_PlayerStatus.OnColorDialogCallbackAPBar(Object, Event, EventData)

	-- First step: check for the right event
	if Event == RVAPI_ColorDialog.Events.COLOR_EVENT_UPDATED then

		-- : set color box value
		WindowSetTintColor(WindowNameSettings.."APBarColorBorderForeground", EventData.Red, EventData.Green, EventData.Blue) 

		-- : set new color values
		RVMOD_PlayerStatus.CurrentConfiguration.ACTION_RED		= EventData.Red / 255
		RVMOD_PlayerStatus.CurrentConfiguration.ACTION_GREEN	= EventData.Green / 255
		RVMOD_PlayerStatus.CurrentConfiguration.ACTION_BLUE		= EventData.Blue / 255
		RVMOD_PlayerStatus.CurrentConfiguration.ACTION_ALPHA	= EventData.Alpha

		-- : update health bar
		if DoesWindowExist(WindowNameBars) then
			RVMOD_PlayerStatus.UpdateBar()
		end
	end
end


function RVMOD_PlayerStatus.OnSizeUpdatedHealthBar()
	local Width, Height = WindowGetDimensions(WindowNameBars.."HealthBar")
	local h = Height*HealthBarCurrentValue/HealthBarMaximumValue
	WindowSetDimensions(WindowNameBars.."HealthBarForeground", Width, h)
	WindowSetDimensions(WindowNameBars.."HealthBarBackground", Width, Height - h)
end

function RVMOD_PlayerStatus.OnSizeUpdatedActionBar()
	local Width, Height = WindowGetDimensions(WindowNameBars.."ActionBar")
	local h = Height*ActionBarCurrentValue/ActionBarMaximumValue
	WindowSetDimensions(WindowNameBars.."ActionBarForeground", Width, h)
	WindowSetDimensions(WindowNameBars.."ActionBarBackground", Width, Height - h)
end

--------------------------------------------------------------
-- function 
-- Description: events
--------------------------------------------------------------
function RVMOD_PlayerStatus.UpdateCurrentActionPoints()
	ActionBarCurrentValue	= GameData.Player.actionPoints.current
	ActionBarInterpTime		= 0
	LabelSetText(WindowNameBars.."ActionText", L""..GameData.Player.actionPoints.current)
	RVMOD_PlayerStatus.UpdateFade()
end

function RVMOD_PlayerStatus.UpdateMaximumActionPoints()

	ActionBarMaximumValue = GameData.Player.actionPoints.maximum
	if ActionBarCurrentValue > ActionBarMaximumValue then
		ActionBarCurrentValue	= ActionBarCurrentValue
		ActionBarInterpTime		= 0
	end
	RVMOD_PlayerStatus.UpdateFade()
end

function RVMOD_PlayerStatus.UpdateCurrentHitPoints()
	HealthBarCurrentValue	= GameData.Player.hitPoints.current
	HealthBarInterpTime		= 0
	LabelSetText(WindowNameBars.."HealthText", L""..GameData.Player.hitPoints.current)
	RVMOD_PlayerStatus.UpdateFade()
end

function RVMOD_PlayerStatus.UpdateMaximumHitPoints()

	HealthBarMaximumValue = GameData.Player.hitPoints.maximum
	if HealthBarCurrentValue > HealthBarMaximumValue then
		HealthBarCurrentValue	= HealthBarCurrentValue
		HealthBarInterpTime		= 0
	end

	RVMOD_PlayerStatus.UpdateFade()
end

function RVMOD_PlayerStatus.UpdateFade()

	-- First step: check if bar is enabled
	if RVMOD_PlayerStatus.CurrentConfiguration.EnableBars then

		-- Second step:
		if GameData.Player.actionPoints.current ~= GameData.Player.actionPoints.maximum or
			GameData.Player.hitPoints.current ~= GameData.Player.hitPoints.maximum
		then
			if isFaded then
				WindowStopAlphaAnimation(WindowNameBars)
				WindowStartAlphaAnimation(WindowNameBars, Window.AnimationType.SINGLE_NO_RESET, 0.0, 1, 0.2, false, 0, 0)
				isFaded = false
			end

		-- Third step:
		elseif not isFaded then

			-- stop animation
			WindowStopAlphaAnimation(WindowNameBars)

			-- forse labes to show before animation
			WindowSetAlpha(WindowNameBars, 1)

			-- start animation
			WindowStartAlphaAnimation(WindowNameBars, Window.AnimationType.SINGLE_NO_RESET, 1-0.000001, 0.0, 1, true, 1, 0)
			isFaded = true
		end
	end
end

function RVMOD_PlayerStatus.OnUpdateHealthBar(Elapsed)

	local self = GetFrame(SystemData.ActiveWindow.name)
	if not HealthBarInterpTime then
		return
	end
	HealthBarInterpTime = mmin(HealthBarInterpTime+Elapsed, 0.2)
	RVMOD_PlayerStatus.SetHealthBarDisplayedValue(HealthBarDisplayedValue + HealthBarInterpTime*(HealthBarCurrentValue-HealthBarDisplayedValue)/0.2)
	if HealthBarInterpTime == 0.2 then
		HealthBarInterpTime = nil
	end
end

function RVMOD_PlayerStatus.SetHealthBarDisplayedValue(v)
	HealthBarDisplayedValue = v
	local h = v/HealthBarMaximumValue
	local Width, Height = WindowGetDimensions(WindowNameBars.."HealthBar")
	WindowSetDimensions(WindowNameBars.."HealthBarForeground", Width, Height*h)
	WindowSetDimensions(WindowNameBars.."HealthBarBackground", Width, Height*(1-h))
end

function RVMOD_PlayerStatus.OnUpdateActionBar(Elapsed)

	local self = GetFrame(SystemData.ActiveWindow.name)
	if not ActionBarInterpTime then
		return
	end
	ActionBarInterpTime = mmin(ActionBarInterpTime+Elapsed, 0.2)
	RVMOD_PlayerStatus.SetActionBarDisplayedValue(ActionBarDisplayedValue + ActionBarInterpTime*(ActionBarCurrentValue-ActionBarDisplayedValue)/0.2)
	if ActionBarInterpTime == 0.2 then
		ActionBarInterpTime = nil
	end
end

function RVMOD_PlayerStatus.SetActionBarDisplayedValue(v)
	ActionBarDisplayedValue = v
	local h = v/ActionBarMaximumValue
	local Width, Height = WindowGetDimensions(WindowNameBars.."ActionBar")
	WindowSetDimensions(WindowNameBars.."ActionBarForeground", Width, Height*h)
	WindowSetDimensions(WindowNameBars.."ActionBarBackground", Width, Height*(1-h))
end
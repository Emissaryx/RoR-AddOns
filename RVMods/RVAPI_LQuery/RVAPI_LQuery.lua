RVAPI_LQuery						= {}
local RVAPI_LQuery					= RVAPI_LQuery

local RVName						= "LQuery API"
local RVCredits						= nil
local RVLicense						= "MIT License"
local RVProjectURL					= "http://www.returnofreckoning.com/forum/viewtopic.php?f=11&t=4534"
local RVRecentUpdates				= 
"09.07.2015 - v0.02 Pre Alpha\n"..
"\t- Project official site location has been changed\n"..
"\n"..
"22.11.2010 - v0.01 Pre Alpha\n"..
"\t- Initial upload"

local WindowLQuerySettings			= "RVAPI_LQuerySettingsWindow"

local OnUpdateTimer					= 0
local WindowAnimateAlphaUpdate		= {}
local WindowAnimateScaleUpdate		= {}

-------------------------------------------------------------
-- var DefaultConfiguration
-- Description: default module configuration
-------------------------------------------------------------
RVAPI_LQuery.DefaultConfiguration	=
{
	Enabled							= true,
}

-------------------------------------------------------------
-- var CurrentConfiguration
-- Description: current module configuration
-------------------------------------------------------------
RVAPI_LQuery.CurrentConfiguration	=
{
	-- should stay empty, will load in the InitializeConfiguration() function
}

-------------------------------------------------------------
-- function Initialize()
-- Description:
-------------------------------------------------------------
function RVAPI_LQuery.Initialize()

	-- First step: load configuration
	RVAPI_LQuery.InitializeConfiguration()

	-- Second step: define event handlers
	RegisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED,		"RVAPI_LQuery.OnAllModulesInitialized")
end

-------------------------------------------------------------
-- function Shutdown()
-- Description:
-------------------------------------------------------------
function RVAPI_LQuery.Shutdown()

	-- First step: destroy settings window
	if DoesWindowExist(WindowLQuerySettings) then
		DestroyWindow(WindowLQuerySettings)
	end

	-- Final step: unregister all events
	UnregisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED,	"RVAPI_LQuery.OnAllModulesInitialized")
end

-------------------------------------------------------------
-- function InitializeConfiguration()
-- Description: loads current configuration
-------------------------------------------------------------
function RVAPI_LQuery.InitializeConfiguration()

	-- First step: move default value to the CurrentConfiguration variable
	for k,v in pairs(RVAPI_LQuery.DefaultConfiguration) do
		if(RVAPI_LQuery.CurrentConfiguration[k]==nil) then
			RVAPI_LQuery.CurrentConfiguration[k]=v
		end
	end
end

-------------------------------------------------------------
-- function OnAllModulesInitialized()
-- Description: event ALL_MODULES_INITIALIZED
-- We can start working with the RVAPI just then we sure they are all initialized
-- and ready to provide their services
-------------------------------------------------------------
function RVAPI_LQuery.OnAllModulesInitialized()

	-- Final step: register in the RV Mods Manager
	-- Please note the folowing:
	-- 1. always do this ON SystemData.Events.ALL_MODULES_INITIALIZED event
	-- 2. you don't need to add RVMOD_Manager to the dependency list
	-- 3. the registration code should be same as below, with your own function parameters
	-- 4. for more information please follow by project official site
	if RVMOD_Manager then
		RVMOD_Manager.API_RegisterAddon("RVAPI_LQuery", RVAPI_LQuery, RVAPI_LQuery.OnRVManagerCallback)
	end
end

-------------------------------------------------------------
-- function OnRVManagerCallback
-- Description:
-------------------------------------------------------------
function RVAPI_LQuery.OnRVManagerCallback(Self, Event, EventData)

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

		if not DoesWindowExist(WindowLQuerySettings) then
			RVAPI_LQuery.InitializeSettingsWindow()
		end

		WindowSetParent(WindowLQuerySettings, EventData.ParentWindow)
		WindowClearAnchors(WindowLQuerySettings)
		WindowAddAnchor(WindowLQuerySettings, "topleft", EventData.ParentWindow, "topleft", 0, 0)
		WindowAddAnchor(WindowLQuerySettings, "bottomright", EventData.ParentWindow, "bottomright", 0, 0)

		RVAPI_LQuery.UpdateSettingsWindow()

		return true

	end
end

-------------------------------------------------------------
-- function InitializeSettingsWindow()
-- Description:
-------------------------------------------------------------
function RVAPI_LQuery.InitializeSettingsWindow()

	-- First step: create main window
	CreateWindow(WindowLQuerySettings, true)

	-- Second step: define strings
	LabelSetText(WindowLQuerySettings.."LabelEnabled", L"Enabled")
	LabelSetTextColor(WindowLQuerySettings.."LabelEnabled", 255, 255, 255)
--[[
	LabelSetText(WindowLQuerySettings.."LabelImportantInformation", L"ATTENTION!!! If you For better performance untick the \"Use Map Distances Information\" or increase the \"delay\" timer.")
	LabelSetTextColor(WindowLQuerySettings.."LabelImportantInformation", DefaultColor.RED.r, DefaultColor.RED.g, DefaultColor.RED.b)
]]
end

-------------------------------------------------------------
-- function UpdateSettingsWindow()
-- Description:
-------------------------------------------------------------
function RVAPI_LQuery.UpdateSettingsWindow()

	-- First step: 
	ButtonSetPressedFlag(WindowLQuerySettings.."CheckBoxEnabled", RVAPI_LQuery.CurrentConfiguration.Enabled)
end

-------------------------------------------------------------
-- function OnUpdate()
-- Description:
-------------------------------------------------------------
function RVAPI_LQuery.OnUpdate(timePassed)

	-- First step: update local timer
	OnUpdateTimer = OnUpdateTimer + timePassed

	-- Second step: process API_WindowAnimateAlpha
	for WindowName, WindowData in pairs(WindowAnimateAlphaUpdate) do

		-- : check if animation still in progress
		if OnUpdateTimer - WindowData.StartTimer >= WindowData.Duration then

			-- : remove window fom the hiding list
			WindowAnimateAlphaUpdate[WindowName] = nil
			WindowSetAlpha(WindowName, WindowData.AlphaFactor)
			WindowSetShowing(WindowName, not (WindowData.AlphaFactor == 0 and WindowData.CanHide))

			-- : call CallbackFunction if needed
			if WindowData.CallbackFunction and WindowData.CallbackOwner then
				WindowData.CallbackFunction(WindowData.CallbackOwner, WindowName)
			end
		end
	end

	-- Third step: process API_WindowAnimateScale
	for WindowName, WindowData in pairs(WindowAnimateScaleUpdate) do

		-- : check if animation still in progress
		if OnUpdateTimer - WindowData.StartTimer >= WindowData.Duration then

			-- : remove window fom the list
			WindowAnimateScaleUpdate[WindowName] = nil
			WindowSetScale(WindowName, WindowData.ScaleFactor)

			-- : call CallbackFunction if needed
			if WindowData.CallbackFunction and WindowData.CallbackOwner then
				WindowData.CallbackFunction(WindowData.CallbackOwner, WindowName)
			end
		end
	end
end

-------------------------------------------------------------
-- function 
-- Description: events
-------------------------------------------------------------

function RVAPI_LQuery.OnCheckBoxEnabled()

	-- First step: get checkbox name
	local CheckBoxName = SystemData.MouseOverWindow.name

	-- Second step: invert flag status
	RVAPI_LQuery.CurrentConfiguration.Enabled = not RVAPI_LQuery.CurrentConfiguration.Enabled
	ButtonSetPressedFlag(CheckBoxName, RVAPI_LQuery.CurrentConfiguration.Enabled)
end


-------------------------------------------------------------------------------
--								RVAPI_LQuery API							 --
-------------------------------------------------------------------------------

--------------------------------------------------------------
-- function API_WindowAnimateAlpha
-- Description:
--------------------------------------------------------------
function RVAPI_LQuery.API_WindowAnimateAlpha(WindowName, AlphaFactor, CanHide, Duration, CallbackOwner, CallbackFunction)

	-- First step: stop animation and calculate current value
	WindowStopAlphaAnimation(WindowName)
	local StartValue = WindowGetAlpha(WindowName)

	-- Second step: recalculate Duration
	if not RVAPI_LQuery.CurrentConfiguration.Enabled or Duration <= 0 then

		-- : since API is not enabled we have to avoid any animation (to short animation) while calling this function
		Duration = 0.001
	end

	-- Third step: show window
	WindowSetShowing(WindowName, true)

	-- Fourth step: start animation
	WindowStartAlphaAnimation(WindowName, Window.AnimationType.SINGLE_NO_RESET, StartValue, AlphaFactor, Duration, false, 0, 0)

	-- Final step: save information about the window
	WindowAnimateAlphaUpdate[WindowName] = {
		StartTimer			= OnUpdateTimer,
		AlphaFactor			= AlphaFactor,
		CanHide				= CanHide,
		Duration			= Duration,
		CallbackOwner		= CallbackOwner,
		CallbackFunction	= CallbackFunction,
	}
end

--------------------------------------------------------------
-- function API_WindowAnimateScale
-- Description:
--------------------------------------------------------------
function RVAPI_LQuery.API_WindowAnimateScale(WindowName, ScaleFactor, Duration, CallbackOwner, CallbackFunction)

	-- First step: stop animation and calculate current value
	WindowStopScaleAnimation(WindowName)
	local StartValue = WindowGetScale(WindowName)

	-- Second step: recalculate Duration
	if not RVAPI_LQuery.CurrentConfiguration.Enabled or Duration <= 0 then

		-- : since API is not enabled we have to avoid any animation (to short animation) while calling this function
		Duration = 0.001
	end

	-- Third step: start animation
	WindowStartScaleAnimation(WindowName, Window.AnimationType.SINGLE_NO_RESET, StartValue, ScaleFactor, Duration, false, 0, 0)

	-- Final step: save information about the window
	WindowAnimateScaleUpdate[WindowName] = {
		StartTimer			= OnUpdateTimer,
		ScaleFactor			= ScaleFactor,
		Duration			= Duration,
		CallbackOwner		= CallbackOwner,
		CallbackFunction	= CallbackFunction,
	}
end
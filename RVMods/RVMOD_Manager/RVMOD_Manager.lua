RVMOD_Manager				= {}
local RVMOD_Manager			= RVMOD_Manager

local RVName				= "RV Mods Manager"
local RVCredits				= "silverq"
local RVLicense				= "MIT License"
local RVProjectURL			= "http://www.returnofreckoning.com/forum/viewtopic.php?f=11&t=4534"
local RVVersion				= "1.11"
local RVBuild				= "003"
local RVRecentUpdates		= 
"09.07.2015 - v1.11 Build 003\n"..
"\t- Project official site location has been changed\n"..
"\t- Version number should not disappear anymore\n"..
"\n"..
"24.11.2010 - v1.1 Build 002\n"..
"\t- Attention! This build is packed with a set of RVAPI modules. Please follow by official site for more information\n"..
"\t- Entities and Range API's should gather information on demand now\n"..
"\n"..
"22.11.2010 - v1.1 Build 001\n"..
"\t- Attention! This build is packed with a set of RVAPI modules. Please follow by official site for more information\n"..
"\t- RV Mods Manager have an options now\n"..
"\t- Tiny visual effects are now available. You can use the settings window if you wish to turn them off\n"..
"\t- Now the General information area should show scrollbar correctly\n"..
"\n"..
"27.06.2010 - v1.01 Release\n"..
"\t- Fixed an issue then fresh installation showed addon information part incorrectly (blank window, crappy strings, etc.)\n"..
"\t- Settings tab is now active by default\n"..
"\n"..
"14.03.2010 - v1.0 Release\n"..
"\t- Date field has been added to the general information tab\n"..
"\t- API_ToggleAddon function has been implemented\n"..
"\t- Command line has more options now. Please follow by project URL for more information\n"..
"\t- Sort destination control has been implemented\n"..
"\n"..
"24.02.2010 - v0.99 Pre-Release\n"..
"\t- Addons collection logic has been rewrited\n"..
"\t- Added overal addon information\n"..
"\t- Filter has been added\n"..
"\t- Sort options has been added"

local TAB_GENERAL			= 1
local TAB_SETTINGS			= 2

local SORT_ORDER_ASC		= 1
local SORT_ORDER_DESC		= 2

local SORT_BY_NAME			= 1
local SORT_BY_RV			= 2
local SORT_BY_TYPE			= 3
local SORT_BY_STATUS		= 4
local SORT_BY_ENABLED		= 5

local FILTER_BY_ALL			= 1
local FILTER_BY_RV			= 2
local FILTER_BY_EA			= 3

local WindowToggleButton	= "RVMOD_ManagerToggleButtonWindow"
local WindowManager			= "RVMOD_ManagerWindow"
local WindowManagerSettings	= "RVMOD_ManagerSettingsWindow"

local ScaleFactorUpdated	= false

local RegisteredRVAddons	= {}
RVMOD_Manager.AddonsList	= {}
RVMOD_Manager.AddonsOrder	= {}

RVMOD_Manager.SortByChoices	= {
	{
		Name	= "Name",
		Value	= SORT_BY_NAME,
	},
	{
		Name	= "RV",
		Value	= SORT_BY_RV,
	},
	{
		Name	= "Type",
		Value	= SORT_BY_TYPE,
	},
	{
		Name	= "Status",
		Value	= SORT_BY_STATUS,
	},
	{
		Name	= "Enabled",
		Value	= SORT_BY_ENABLED,
	},
}

local function BooleanToNumber(Value)

	if Value then
		return 1
	else
		return 0
	end
end

local function CompareAddons(AddonIndex1, AddonIndex2)

	-- First step: get locals
	local Addon1 = RVMOD_Manager.AddonsList[AddonIndex1]
	local Addon2 = RVMOD_Manager.AddonsList[AddonIndex2]

	-- : sort by RV (addons with setings)
	if RVMOD_Manager.CurrentConfiguration.SortBy == SORT_BY_RV and Addon1.IsRVAddon ~= Addon2.IsRVAddon then
		if RVMOD_Manager.CurrentConfiguration.SortOrder == SORT_ORDER_ASC then
			return Addon1.IsRVAddon
		else
			return Addon2.IsRVAddon
		end
	end

	-- : sort by Type
	if RVMOD_Manager.CurrentConfiguration.SortBy == SORT_BY_TYPE then
		if RVMOD_Manager.CurrentConfiguration.SortOrder == SORT_ORDER_ASC and Addon1.moduleType ~= Addon2.moduleType then
			return Addon1.moduleType < Addon2.moduleType
		else
			return Addon1.moduleType > Addon2.moduleType
		end
	end

	-- : sort by status (loaded, not loaded, failed etc.)
	if RVMOD_Manager.CurrentConfiguration.SortBy == SORT_BY_STATUS and Addon1.loadStatus ~= Addon2.loadStatus then
		if RVMOD_Manager.CurrentConfiguration.SortOrder == SORT_ORDER_ASC then
			return Addon1.loadStatus < Addon2.loadStatus
		else
			return Addon1.loadStatus > Addon2.loadStatus
		end
	end

	-- : sort by enabled
	if RVMOD_Manager.CurrentConfiguration.SortBy == SORT_BY_ENABLED and Addon1.isEnabled ~= Addon2.isEnabled then
		if RVMOD_Manager.CurrentConfiguration.SortOrder == SORT_ORDER_ASC then
			return Addon1.isEnabled
		else
			return Addon2.isEnabled
		end
	end

	-- : sort by name
	return StringUtils.SortByString(Addon1.RVName, Addon2.RVName, RVMOD_Manager.CurrentConfiguration.SortOrder)
end

--------------------------------------------------------------
-- var DefaultConfiguration
-- Description: default module configuration
--------------------------------------------------------------
RVMOD_Manager.DefaultConfiguration	=
{
	IsShowing						= false,

	ActiveAddon						= "",
	ActiveTAB						= TAB_SETTINGS,

	SortOrder						= SORT_ORDER_ASC,
	SortBy							= SORT_BY_NAME,
	FilterBy						= {
		[FILTER_BY_ALL]	= false,
		[FILTER_BY_RV]	= true,
		[FILTER_BY_EA]	= false,
	},

	UseGlobalScale					= true,
	ScaleFactor						= 1,

	FadeInOutDelay					= 0.2,
	ZoomInOutDelay					= 0.2,
}

--------------------------------------------------------------
-- var CurrentConfiguration
-- Description: current module configuration
--------------------------------------------------------------
RVMOD_Manager.CurrentConfiguration	=
{
	-- should stay empty, will load in the InitializeConfiguration() function
}

--------------------------------------------------------------
-- var Events
-- Description: build in events
--------------------------------------------------------------
RVMOD_Manager.Events =
{

	-- (Optional) : RVMOD_Manager requested an alternative name
	NAME_REQUESTED				= 1,

	-- (Optional) : RVMOD_Manager requested credits information
	CREDITS_REQUESTED			= 2,

	-- (Optional) : RVMOD_Manager requested license incormation
	LICENSE_REQUESTED			= 3,

	-- (Optional) : RVMOD_Manager requested project url
	PROJECT_URL_REQUESTED		= 4,

	-- (Optional) : RVMOD_Manager requested recent updates list
	RECENT_UPDATES_REQUESTED	= 5,

	-- (Optional) : RVMOD_Manager regerated a new settings container
	PARENT_WINDOW_UPDATED		= 6,
}

--------------------------------------------------------------
-- function Initialize
-- Description: RVMOD_Manager
--------------------------------------------------------------
function RVMOD_Manager.Initialize()

	-- First step: load configuration
	RVMOD_Manager.InitializeConfiguration()

	-- Second step: define event handlers
	RegisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED,		"RVMOD_Manager.OnAllModulesInitialized")
	RegisterEventHandler(SystemData.Events.L_BUTTON_UP_PROCESSED,		"RVMOD_Manager.OnLButtonUpProcessed")
	RegisterEventHandler(SystemData.Events.USER_SETTINGS_CHANGED,		"RVMOD_Manager.OnUserSettingsChanged")

	-- Third step: register toggle button window on the layout field
	LayoutEditor.RegisterWindow(WindowToggleButton, L"RVMOD_Manager", L"Toggle button for RVMOD_Manager", false, false, true)

	-- Fourth step:
	RVMOD_Manager.InitializeManagerWindow()
	RVMOD_Manager.UpdateTabs()
	RVMOD_Manager.UpdateReloadUIButton()
	RVMOD_Manager.UpdateManagerWindowVisibility()
end

--------------------------------------------------------------
-- function Shutdown
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.Shutdown()

	-- First step: unregister all events
	UnregisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED,	"RVMOD_Manager.OnAllModulesInitialized")
	UnregisterEventHandler(SystemData.Events.L_BUTTON_UP_PROCESSED,		"RVMOD_Manager.OnLButtonUpProcessed")
	UnregisterEventHandler(SystemData.Events.USER_SETTINGS_CHANGED,		"RVMOD_Manager.OnUserSettingsChanged")

	-- Second step: destroy settings window
	if DoesWindowExist(WindowManagerSettings) then
		DestroyWindow(WindowManagerSettings)
	end

	-- Final step: unregister toggle button
	LayoutEditor.UnregisterWindow(WindowToggleButton)
end

--------------------------------------------------------------
-- function InitializeConfiguration()
-- Description: loads current configuration
--------------------------------------------------------------
function RVMOD_Manager.InitializeConfiguration()

	-- First step: move default value to the CurrentConfiguration variable
	for k,v in pairs(RVMOD_Manager.DefaultConfiguration) do
		if(RVMOD_Manager.CurrentConfiguration[k]==nil) then
			RVMOD_Manager.CurrentConfiguration[k]=v
		end
	end
end

--------------------------------------------------------------
-- function OnAllModulesInitialized
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.OnAllModulesInitialized()

	-- First step: get new modules list
	RVMOD_Manager.AddonsList = ModulesGetData()

	-- Second step: fill list with more information
	RVMOD_Manager.UpdateRVVariables()

	-- Third step: filter list
	RVMOD_Manager.FilterAddonsList()

	-- Fourth step: update content windows
	RVMOD_Manager.UpdateContentWindows()

	-- Fifth step: sort list
	RVMOD_Manager.SortAddonsList()

	-- Sixth step:	recalculate current addon name
	--				we have to do that step in case if selected addon disappeared, for instance user deactivated it
	RVMOD_Manager.CurrentConfiguration.ActiveAddon = RVMOD_Manager.CalculateActiveAddon()

	-- Seventh step: show addon information in the manager
	RVMOD_Manager.ShowAddon(RVMOD_Manager.CurrentConfiguration.ActiveAddon)

	-- Eight step: register self in the RegisteredRVAddons list
	-- Please note the folowing:
	-- 1. always do this ON SystemData.Events.ALL_MODULES_INITIALIZED event
	-- 2. you don't need to add RVMOD_Manager to the dependency list
	-- 3. the registration code should be the same as below, with your own function parameters
	-- 4. for more information please follow by project official site
	if RVMOD_Manager then
		RVMOD_Manager.API_RegisterAddon("RVMOD_Manager", RVMOD_Manager, RVMOD_Manager.OnRVManagerCallback)
	end

	-- : register slash command
	if LibSlash then
		LibSlash.RegisterSlashCmd("rvmod", RVMOD_Manager.CmdHandler)
		LibSlash.RegisterSlashCmd("rv", RVMOD_Manager.CmdHandler)
	end

	-- Final step: inform about the cmd system
	EA_ChatWindow.Print(L"[RV Mods Manager]: Use \"/rvmod\" or \"/rv\" to launch UI. For more information use the \"help\" option.")
end

--------------------------------------------------------------
-- function OnUserSettingsChanged
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.OnUserSettingsChanged()

	-- Final step: set window scale
	RVMOD_Manager.UpdateWindowScale(WindowManager)
end

--------------------------------------------------------------
-- function OnRVManagerCallback
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.OnRVManagerCallback(Self, Event, EventData)

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

		if not DoesWindowExist(WindowManagerSettings) then
			RVMOD_Manager.InitializeSettingsWindow()
		end

		WindowSetParent(WindowManagerSettings, EventData.ParentWindow)
		WindowClearAnchors(WindowManagerSettings)
		WindowAddAnchor(WindowManagerSettings, "topleft", EventData.ParentWindow, "topleft", 0, 0)
		WindowAddAnchor(WindowManagerSettings, "bottomright", EventData.ParentWindow, "bottomright", 0, 0)

		RVMOD_Manager.UpdateWindowSettings()

		return true

	end
end

--------------------------------------------------------------
-- function InitializeSettingsWindow()
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.InitializeSettingsWindow()

	-- First step: create settings window
	CreateWindow(WindowManagerSettings, true)

	-- Second step: set slider texts
	LabelSetText(WindowManagerSettings.."LabelFadeInOutDelay", L"Fade In Out Delay:")
	LabelSetTextColor(WindowManagerSettings.."LabelFadeInOutDelay", 255, 255, 255)
	LabelSetText(WindowManagerSettings.."SliderFadeInOutDelayMinLabel", L"0")
	LabelSetText(WindowManagerSettings.."SliderFadeInOutDelayMidLabel", L"0.5")
	LabelSetText(WindowManagerSettings.."SliderFadeInOutDelayMaxLabel", L"1")

	LabelSetText(WindowManagerSettings.."LabelZoomInOutDelay", L"Zoom In Out Delay:")
	LabelSetTextColor(WindowManagerSettings.."LabelZoomInOutDelay", 255, 255, 255)
	LabelSetText(WindowManagerSettings.."SliderZoomInOutDelayMinLabel", L"0")
	LabelSetText(WindowManagerSettings.."SliderZoomInOutDelayMidLabel", L"0.5")
	LabelSetText(WindowManagerSettings.."SliderZoomInOutDelayMaxLabel", L"1")

	LabelSetText(WindowManagerSettings.."LabelUseGlobalScale", L"Magnifier Power:")
	LabelSetTextColor(WindowManagerSettings.."LabelUseGlobalScale", 255, 255, 255)
	LabelSetText(WindowManagerSettings.."SliderScaleMinLabel", L"0.5")
	LabelSetText(WindowManagerSettings.."SliderScaleMidLabel", L"1")
	LabelSetText(WindowManagerSettings.."SliderScaleMaxLabel", L"1.5")
end

--------------------------------------------------------------
-- function UpdateWindowSettings()
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.UpdateWindowSettings()

	-- : show information
	SliderBarSetCurrentPosition(WindowManagerSettings.."SliderFadeInOutDelay",	RVMOD_Manager.CurrentConfiguration.FadeInOutDelay)
	SliderBarSetCurrentPosition(WindowManagerSettings.."SliderZoomInOutDelay",	RVMOD_Manager.CurrentConfiguration.ZoomInOutDelay)
	SliderBarSetCurrentPosition(WindowManagerSettings.."SliderScale",			RVMOD_Manager.CurrentConfiguration.ScaleFactor - 0.5)
end

--------------------------------------------------------------
-- function CmdHandler
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.CmdHandler(InputString)

	-- : split InputString onto pieces
	local Options = {InputString:match("([^ ]+)[ ]?(.*)")}

	-- : show help
	if	string.lower(Options[1] or "") == "help" or
		string.lower(Options[1] or "") == "h" then

		EA_ChatWindow.Print(L"Syntax:")
		EA_ChatWindow.Print(L"    /rvmod [Addon name] [Tab number]")
		EA_ChatWindow.Print(L"    [Addon name] - case insensitive string")
		EA_ChatWindow.Print(L"    [Tab number] - starts from \"1\" and counts from right to left")
		EA_ChatWindow.Print(L"Examples:")
		EA_ChatWindow.Print(L"    /rvmod")
		EA_ChatWindow.Print(L"    /rvmod rvmod_manager 2")
		EA_ChatWindow.Print(L"    /rvmod ea_chatsystem")

	-- : toggle addon
	else

		RVMOD_Manager.API_ToggleAddon(Options[1], tonumber(Options[2]))

	end
end

--------------------------------------------------------------
-- function UpdateManagerWindowVisibility
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.UpdateManagerWindowVisibility()

	-- First step: start alpha animation
	RVAPI_LQuery.API_WindowAnimateAlpha(WindowManager, BooleanToNumber(RVMOD_Manager.CurrentConfiguration.IsShowing), true, RVMOD_Manager.CurrentConfiguration.FadeInOutDelay)
end

--------------------------------------------------------------
-- function InitializeManagerWindow
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.InitializeManagerWindow()

	-- First step: define title
	LabelSetText(WindowManager.."TitleBarText", L"RV Mods Manager")
	LabelSetText(WindowManager.."VersionText", L"v"..towstring(RVVersion)..L" Build "..towstring(RVBuild))

	-- Second step: define tab strings
	ButtonSetText(WindowManager.."TabSettings", L"Settings")
	ButtonSetText(WindowManager.."TabGeneral", L"General")

	-- Third step: define reload UI button text
	ButtonSetText(WindowManager.."ContentButtonReloadUI", L"Enable / Disable")

	-- Fourth step: 
	LabelSetText(WindowManager.."FilterLabel", L"Filter:")
	RVMOD_Manager.UpdateFilterControls()

	-- Fifth step: 
	LabelSetText(WindowManager.."SortByLabel", L"Sort By:")
	ComboBoxClearMenuItems(WindowManager.."SortBy")
	for ChoiceIndex, ChoiceData in ipairs(RVMOD_Manager.SortByChoices) do
		ComboBoxAddMenuItem(WindowManager.."SortBy", towstring(ChoiceData.Name))
		if ChoiceData.Value == RVMOD_Manager.CurrentConfiguration.SortBy then
			ComboBoxSetSelectedMenuItem(WindowManager.."SortBy", ChoiceIndex)
		end
	end
	RVMOD_Manager.UpdateSortByControls()

	-- Sixth step: customize the UiModWindow information window
	LabelSetText(WindowManager.."ContentRVGeneralScrollChildCreditsLabel", L"Credits:")
	LabelSetText(WindowManager.."ContentRVGeneralScrollChildDateLabel", L"Date:")
	LabelSetText(WindowManager.."ContentRVGeneralScrollChildLicenseLabel", L"License:")
	LabelSetText(WindowManager.."ContentRVGeneralScrollChildProjectURLLabel", L"Project URL:")
	LabelSetText(WindowManager.."ContentRVGeneralScrollChildRecentUpdatesLabel", L"Recent Updates:")
	local ScrollChildWidth = 665
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChild", ScrollChildWidth, 0)
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChildAuthorText", ScrollChildWidth-230, 0)
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChildCreditsText", ScrollChildWidth-230, 0)
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChildVersionText", ScrollChildWidth-230, 0)
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChildGameVersionText", ScrollChildWidth-230, 0)
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChildDateText", ScrollChildWidth-230, 0)
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChildLicenseText", ScrollChildWidth-230, 0)
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChildCategoriesText", ScrollChildWidth-230, 0)
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChildCareersText", ScrollChildWidth-230, 0)
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChildDescriptionText", ScrollChildWidth-20, 0)
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChildProjectURLText", ScrollChildWidth-20, 30)
	WindowSetDimensions(WindowManager.."ContentRVGeneralScrollChildRecentUpdatesText", ScrollChildWidth-20, 0)
	UiModWindow.InitModDetails(WindowManager.."ContentRVGeneral")

	-- Final step: set window scale
	RVMOD_Manager.UpdateWindowScale(WindowManager)
end

--------------------------------------------------------------
-- function UpdateWindowScale
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.UpdateWindowScale(WindowName)

	-- First step: calculate ScaleFactor
	local ScaleFactor
	if RVMOD_Manager.CurrentConfiguration.UseGlobalScale then
		ScaleFactor = InterfaceCore.GetScale()
	else
		ScaleFactor = RVMOD_Manager.CurrentConfiguration.ScaleFactor or 1
	end

	-- Final step: set a new scale value to the WindowName
	RVAPI_LQuery.API_WindowAnimateScale(WindowName, ScaleFactor, RVMOD_Manager.CurrentConfiguration.ZoomInOutDelay, RVMOD_Manager, RVMOD_Manager.WindowAnimateScaleCallback)
end

--------------------------------------------------------------
-- function WindowAnimateScaleCallback
-- Description: this function will hit at the end of the scale animation
--------------------------------------------------------------
function RVMOD_Manager.WindowAnimateScaleCallback(Self, WindowName)

	-- : we have to do updates only if we are working with the main window
	if WindowManager == WindowName then

		-- : update scroll window
		ScrollWindowUpdateScrollRect(WindowManager.."ContentListBox")
		ScrollWindowSetOffset(WindowManager.."ContentListBox", 0)

		-- : update content scroll window
		ScrollWindowUpdateScrollRect(WindowManager.."ContentRVGeneral")
		ScrollWindowSetOffset(WindowManager.."ContentRVGeneral", 0)
	end
end

--------------------------------------------------------------
-- function UpdateFilterControls
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.UpdateFilterControls()

	if RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_ALL] then
		DynamicImageSetTexture(WindowManager.."FilterAllIcon", "RVMOD_ManagerFilterAllIcon1Texture", 0, 0 )
	else
		DynamicImageSetTexture(WindowManager.."FilterAllIcon", "RVMOD_ManagerFilterAllIcon2Texture", 0, 0 )
	end

	if RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_RV] then
		DynamicImageSetTexture(WindowManager.."FilterRVIcon", "RVMOD_ManagerFilterRVIcon1Texture", 0, 0 )
	else
		DynamicImageSetTexture(WindowManager.."FilterRVIcon", "RVMOD_ManagerFilterRVIcon2Texture", 0, 0 )
	end

	if RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_EA] then
		DynamicImageSetTexture(WindowManager.."FilterEAIcon", "RVMOD_ManagerFilterEAIcon1Texture", 0, 0 )
	else
		DynamicImageSetTexture(WindowManager.."FilterEAIcon", "RVMOD_ManagerFilterEAIcon2Texture", 0, 0 )
	end
end

--------------------------------------------------------------
-- function UpdateSortByControls
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.UpdateSortByControls()

	-- Final step: show ASC or DESC arrows
	if RVMOD_Manager.CurrentConfiguration.SortOrder == SORT_ORDER_ASC then
		DynamicImageSetTexture(WindowManager.."SortByIcon", "RVMOD_ManagerSortByIcon2Texture", 0, 0 )
	else
		DynamicImageSetTexture(WindowManager.."SortByIcon", "RVMOD_ManagerSortByIcon1Texture", 0, 0 )
	end
end

--------------------------------------------------------------
-- function UpdateTabs
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.UpdateTabs()

	-- First step: update tabs
	ButtonSetPressedFlag(WindowManager.."TabSettings", RVMOD_Manager.CurrentConfiguration.ActiveTAB == TAB_SETTINGS)
	ButtonSetPressedFlag(WindowManager.."TabGeneral", RVMOD_Manager.CurrentConfiguration.ActiveTAB == TAB_GENERAL)

	-- Second step: update windows visibility
	RVAPI_LQuery.API_WindowAnimateAlpha(WindowManager.."ContentRVSettings", BooleanToNumber(RVMOD_Manager.CurrentConfiguration.ActiveTAB == TAB_SETTINGS), true, RVMOD_Manager.CurrentConfiguration.FadeInOutDelay)
	RVAPI_LQuery.API_WindowAnimateAlpha(WindowManager.."ContentRVGeneral", BooleanToNumber(RVMOD_Manager.CurrentConfiguration.ActiveTAB == TAB_GENERAL), true, RVMOD_Manager.CurrentConfiguration.FadeInOutDelay)
end

--------------------------------------------------------------
-- function UpdateContentWindows
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.UpdateContentWindows()

	-- First step: set content window visibility
	RVAPI_LQuery.API_WindowAnimateAlpha(WindowManager.."Content", BooleanToNumber(#RVMOD_Manager.AddonsOrder > 0), true, RVMOD_Manager.CurrentConfiguration.FadeInOutDelay)

	-- Second step: set tabs visibility
	RVAPI_LQuery.API_WindowAnimateAlpha(WindowManager.."Tab", BooleanToNumber(#RVMOD_Manager.AddonsOrder > 0), true, RVMOD_Manager.CurrentConfiguration.FadeInOutDelay)
end

--------------------------------------------------------------
-- function UpdateRVVariables
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.UpdateRVVariables()

	-- First step: list all modules
	for AddonIndex, AddonData in ipairs(RVMOD_Manager.AddonsList) do

		-- Second step: get registered RV addon 
		local RegisteredRVAddon			= RegisteredRVAddons[AddonData.name]

		-- Third step: add more information
		AddonData.RVSwitchRequired		= false
		AddonData.RVSettingsWindow		= WindowManager.."ContentRVSettings"..AddonIndex

		-- Fourth step: create settings container window
		if not DoesWindowExist(AddonData.RVSettingsWindow) then
			CreateWindowFromTemplate(AddonData.RVSettingsWindow, "RVMOD_ManagerRVSettingsTemplate", WindowManager.."ContentRVSettings")
			RVAPI_LQuery.API_WindowAnimateAlpha(AddonData.RVSettingsWindow, BooleanToNumber(AddonData.name==RVMOD_Manager.CurrentConfiguration.ActiveAddon), true, RVMOD_Manager.CurrentConfiguration.FadeInOutDelay)
		end

		-- Fifth step: update window scale
		RVMOD_Manager.UpdateWindowScale(AddonData.RVSettingsWindow)

		-- Sixth step: add more information
		if RegisteredRVAddon ~= nil then
			AddonData.RVName			= towstring(RegisteredRVAddon.CallbackFunction(RegisteredRVAddon.CallbackOwner, RVMOD_Manager.Events.NAME_REQUESTED, {}) or AddonData.name)
			AddonData.RVCredits			= towstring(RegisteredRVAddon.CallbackFunction(RegisteredRVAddon.CallbackOwner, RVMOD_Manager.Events.CREDITS_REQUESTED, {}) or "None Specified")
			AddonData.RVLicense			= towstring(RegisteredRVAddon.CallbackFunction(RegisteredRVAddon.CallbackOwner, RVMOD_Manager.Events.LICENSE_REQUESTED, {}) or "Not Specified")
			AddonData.RVProjectURL		= towstring(RegisteredRVAddon.CallbackFunction(RegisteredRVAddon.CallbackOwner, RVMOD_Manager.Events.PROJECT_URL_REQUESTED, {}) or "")
			AddonData.RVRecentUpdates	= towstring(RegisteredRVAddon.CallbackFunction(RegisteredRVAddon.CallbackOwner, RVMOD_Manager.Events.RECENT_UPDATES_REQUESTED, {}) or "None Specified")
			AddonData.IsRVAddon			= RegisteredRVAddon.CallbackFunction(RegisteredRVAddon.CallbackOwner, RVMOD_Manager.Events.PARENT_WINDOW_UPDATED, {ParentWindow = AddonData.RVSettingsWindow}) or false
		else
			AddonData.RVName			= towstring(AddonData.name)
			AddonData.RVCredits			= towstring("None Specified")
			AddonData.RVLicense			= towstring("Not Specified")
			AddonData.RVProjectURL		= towstring("")
			AddonData.RVRecentUpdates	= towstring("None Specified")
			AddonData.IsRVAddon			= false
		end

		-- Seventh step: create settings container window
		LabelSetText(AddonData.RVSettingsWindow.."NoSettingsLabel", AddonData.RVName..L" does not have additional options")
		WindowSetShowing(AddonData.RVSettingsWindow.."NoSettingsLabel", not AddonData.IsRVAddon)
	end
end

--------------------------------------------------------------
-- function CalculateActiveAddon
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.CalculateActiveAddon()

	-- First step: get current addon name
	local Result = RVMOD_Manager.CurrentConfiguration.ActiveAddon

	-- Second step: calculate another addon name if the current does not exists
	if RVMOD_Manager.GetAddonData(Result) == nil then

		-- : check if we got any addons in the list
		if #RVMOD_Manager.AddonsOrder > 0 then

			-- : we have some addons in the list, let's select the first one
			AddonIndex = RVMOD_Manager.AddonsOrder[1]
		else

			-- : we don't have any addons in the list, so let's just select anything we got in the system
			AddonIndex = 1
		end

		-- : get addon name by it's index
		Result = RVMOD_Manager.AddonsList[AddonIndex].name
	end

	-- Final step: return result
	return Result
end

--------------------------------------------------------------
-- function GetAddonData
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.GetAddonData(AddonName)

	-- First step: list all available addons
	for AddonIndex, AddonData in ipairs(RVMOD_Manager.AddonsList) do

		-- Second step: check if names are equal
		if(string.lower(AddonData.name) == string.lower(AddonName)) then

			-- Final step: return result
			return AddonData
		end
	end
end

--------------------------------------------------------------
-- function ShowAddon
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.ShowAddon(AddonName)

	-- First step: get AddonToShow and AddonToHide
	local AddonToShow	= RVMOD_Manager.GetAddonData(AddonName)
	local AddonToHide	= RVMOD_Manager.GetAddonData(RVMOD_Manager.CurrentConfiguration.ActiveAddon)

	-- Second step: hide and show addon settings
	if AddonToHide ~= nil then

		-- : hide previous selected addon
		RVAPI_LQuery.API_WindowAnimateAlpha(AddonToHide.RVSettingsWindow, 0, true, RVMOD_Manager.CurrentConfiguration.FadeInOutDelay)

		-- : reset selected addon name
		RVMOD_Manager.CurrentConfiguration.ActiveAddon = ""
	end
	if AddonToShow ~= nil then

		-- : set settings window visibility
		RVAPI_LQuery.API_WindowAnimateAlpha(AddonToShow.RVSettingsWindow, 1, true, RVMOD_Manager.CurrentConfiguration.FadeInOutDelay)

		-- : update general information using the UiModWindow API
		UiModWindow.UpdateModDetailsData(WindowManager.."ContentRVGeneral", AddonToShow)

		-- : add more information
		LabelSetText(WindowManager.."ContentRVGeneralScrollChildCreditsText", AddonToShow.RVCredits)
		LabelSetText(WindowManager.."ContentRVGeneralScrollChildDateText", towstring(AddonToShow.date))
		LabelSetText(WindowManager.."ContentRVGeneralScrollChildLicenseText", AddonToShow.RVLicense)
		TextEditBoxSetText(WindowManager.."ContentRVGeneralScrollChildProjectURLText", AddonToShow.RVProjectURL)
		LabelSetText(WindowManager.."ContentRVGeneralScrollChildRecentUpdatesText", AddonToShow.RVRecentUpdates)

		-- : update scroll window since we changed its contents
		ScrollWindowUpdateScrollRect(WindowManager.."ContentRVGeneral")
		ScrollWindowSetOffset(WindowManager.."ContentRVGeneral", 0)

		-- : set new selected addon name
		RVMOD_Manager.CurrentConfiguration.ActiveAddon = AddonToShow.name
	end
end

--------------------------------------------------------------
-- function FilterAddonsList
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.FilterAddonsList()

	-- First step: define locals
	local WindowIndex		= 1
	local ScrollChildWindow = WindowManager.."ContentListBoxScrollChild"

	-- Second step: reset all internal locals
	while table.remove(RVMOD_Manager.AddonsOrder) do end

	-- Third step: list all modules
	for AddonIndex, AddonData in ipairs(RVMOD_Manager.AddonsList) do

		-- : check for filter
		if	(RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_ALL] and not AddonData.IsRVAddon and not (AddonData.moduleType == SystemData.UiModuleType.DEFAULT_INGAME)) or
			(RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_RV] and AddonData.IsRVAddon) or
			(RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_EA] and (AddonData.moduleType == SystemData.UiModuleType.DEFAULT_INGAME)) then

			-- : add index into the RVMOD_Manager.AddonsOrder
			table.insert(RVMOD_Manager.AddonsOrder,	AddonIndex)

			-- : 
			if not DoesWindowExist(ScrollChildWindow..WindowIndex) then

				-- : 
				CreateWindowFromTemplate(ScrollChildWindow..WindowIndex, "RVMOD_ManagerListBoxRowTemplate", ScrollChildWindow)

				-- : 
				if WindowIndex == 1 then
				    WindowAddAnchor(ScrollChildWindow..WindowIndex, "topleft", ScrollChildWindow, "topleft", 0, 0)
				    WindowAddAnchor(ScrollChildWindow..WindowIndex, "topright", ScrollChildWindow, "topright", 0, 0)
				else
				    WindowAddAnchor(ScrollChildWindow..WindowIndex, "bottomleft", ScrollChildWindow..(WindowIndex-1), "topleft", 0, 0)
				    WindowAddAnchor(ScrollChildWindow..WindowIndex, "bottomright", ScrollChildWindow..(WindowIndex-1), "topright", 0, 0)
				end
			end

			-- : 
			WindowSetId(ScrollChildWindow..WindowIndex, WindowIndex)

			-- : 
			WindowIndex = WindowIndex + 1
		end
	end

	-- Fourth step: remove unused child windows if needed
	WindowIndex = #RVMOD_Manager.AddonsOrder + 1
	while DoesWindowExist(ScrollChildWindow..WindowIndex) do

		-- : remove child window
		DestroyWindow(ScrollChildWindow..WindowIndex)

		-- : calculate new window index
		WindowIndex = WindowIndex + 1
	end

	-- Fifth step: (hack) update main window scale, it will redraw the scroll window list
	local ScaleFactor = WindowGetScale(WindowManager)
	WindowSetScale(WindowManager, ScaleFactor-0.0001)
	WindowSetScale(WindowManager, ScaleFactor)

	-- Final step: update scroll window since we changed its contents
	ScrollWindowUpdateScrollRect(WindowManager.."ContentListBox")
	ScrollWindowSetOffset(WindowManager.."ContentListBox", 0)
end

--------------------------------------------------------------
-- function SortAddonsList
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.SortAddonsList()

	-- First step: sort filtered addons
	table.sort(RVMOD_Manager.AddonsOrder, CompareAddons)

	-- Second step: update labels in the addon list
	RVMOD_Manager.UpdateListBox()
end

--------------------------------------------------------------
-- function UpdateListBox
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.UpdateListBox()

	-- First step: define locals
	local ScrollChildWindow		= WindowManager.."ContentListBoxScrollChild"
	local bkg_color_selected	= DataUtils.GetAlternatingRowColor(1)
	local bkg_color				= DataUtils.GetAlternatingRowColor(0)
	local AddonData				= nil
	local BackgroundColor		= nil
	local StatusColor			= nil
	local StringColor			= nil

	-- Third step: for every index do...
	for WindowIndex, AddonIndex in ipairs(RVMOD_Manager.AddonsOrder) do

		-- : 
		AddonData				= RVMOD_Manager.AddonsList[AddonIndex]
		BackgroundColor			= bkg_color
		StatusColor				= {r=0, g=0, b=0, a=1}
		StringColor				= {r=255, g=204, b=102, a=1}

		-- : calculate default selected addon if not set
		if RVMOD_Manager.CurrentConfiguration.ActiveAddon == "" and WindowIndex == 1 then

			RVMOD_Manager.CurrentConfiguration.ActiveAddon = AddonData.name
		end

		-- : setup status color
		if		AddonData.loadStatus == SystemData.UiModuleLoadStatus.NOT_LOADED then

			StatusColor.r		= DefaultColor.LIGHT_GRAY.r
			StatusColor.g		= DefaultColor.LIGHT_GRAY.g
			StatusColor.b		= DefaultColor.LIGHT_GRAY.b
			StatusColor.a		= 1

			StringColor.r		= 150
			StringColor.g		= 150
			StringColor.b		= 150
			StringColor.a		= 1

		elseif	AddonData.loadStatus == SystemData.UiModuleLoadStatus.REPLACED then

			StatusColor.r		= DefaultColor.TEAL.r
			StatusColor.g		= DefaultColor.TEAL.g
			StatusColor.b		= DefaultColor.TEAL.b
			StatusColor.a		= 1

			StringColor.r		= DefaultColor.TEAL.r
			StringColor.g		= DefaultColor.TEAL.g
			StringColor.b		= DefaultColor.TEAL.b
			StringColor.a		= 1

		elseif	AddonData.loadStatus == SystemData.UiModuleLoadStatus.LOADING_DEPENDENCIES then

			StatusColor.r		= DefaultColor.WHITE.r
			StatusColor.g		= DefaultColor.WHITE.g
			StatusColor.b		= DefaultColor.WHITE.b
			StatusColor.a		= 1

		elseif	AddonData.loadStatus == SystemData.UiModuleLoadStatus.FAILED_MISSING_DEPENDENCY or
				AddonData.loadStatus == SystemData.UiModuleLoadStatus.FAILED_DEPENDENCY_NOT_ENABLED or
				AddonData.loadStatus == SystemData.UiModuleLoadStatus.FAILED_DEPENDENCY_FAILED or
				AddonData.loadStatus == SystemData.UiModuleLoadStatus.FAILED_CIRCULAR_DEPENDENCY then

			StatusColor.r		= DefaultColor.RED.r
			StatusColor.g		= DefaultColor.RED.g
			StatusColor.b		= DefaultColor.RED.b
			StatusColor.a		= 1

			StringColor.r		= DefaultColor.RED.r
			StringColor.g		= DefaultColor.RED.g
			StringColor.b		= DefaultColor.RED.b
			StringColor.a		= 1

		elseif	AddonData.loadStatus == SystemData.UiModuleLoadStatus.SUCEEDED_NO_ERRORS then

			StatusColor.r		= DefaultColor.GREEN.r
			StatusColor.g		= DefaultColor.GREEN.g
			StatusColor.b		= DefaultColor.GREEN.b
			StatusColor.a		= 1

		elseif	AddonData.loadStatus == SystemData.UiModuleLoadStatus.SUCEEDED_WITH_ERRORS then

			StatusColor.r		= DefaultColor.YELLOW.r
			StatusColor.g		= DefaultColor.YELLOW.g
			StatusColor.b		= DefaultColor.YELLOW.b
			StatusColor.a		= 1

			StringColor.r		= DefaultColor.YELLOW.r
			StringColor.g		= DefaultColor.YELLOW.g
			StringColor.b		= DefaultColor.YELLOW.b
			StringColor.a		= 1

		end

		-- : setup selected font and background colors
		if AddonData.name == RVMOD_Manager.CurrentConfiguration.ActiveAddon then

			BackgroundColor		= bkg_color_selected
			StringColor.r		= 255
			StringColor.g		= 255
			StringColor.b		= 255
		end

		-- : mark addon if enabled/disabled switch required
		if AddonData.RVSwitchRequired then
			DynamicImageSetTexture(ScrollChildWindow..WindowIndex.."StatusIcon", "RVMOD_ManagerStatusIcon2Texture", 0, 0)
		else
			DynamicImageSetTexture(ScrollChildWindow..WindowIndex.."StatusIcon", "RVMOD_ManagerStatusIcon1Texture", 0, 0)
		end

		-- : mark addon with additional settings
		WindowSetShowing(ScrollChildWindow..WindowIndex.."Settings", AddonData.IsRVAddon)

		-- : set labels
		LabelSetText(ScrollChildWindow..WindowIndex.."Name", AddonData.RVName)

		-- : set colors
		WindowSetTintColor(ScrollChildWindow..WindowIndex.."StatusIcon", StatusColor.r, StatusColor.g, StatusColor.b)
		WindowSetAlpha(ScrollChildWindow..WindowIndex.."StatusIcon", StatusColor.a)
		WindowSetTintColor(ScrollChildWindow..WindowIndex.."SettingsIcon", StatusColor.r, StatusColor.g, StatusColor.b)
		WindowSetAlpha(ScrollChildWindow..WindowIndex.."SettingsIcon", StatusColor.a)

		WindowSetTintColor(ScrollChildWindow..WindowIndex.."Background", BackgroundColor.r, BackgroundColor.g+AddonIndex*60, BackgroundColor.b)	
		WindowSetAlpha(ScrollChildWindow..WindowIndex.."Background", BackgroundColor.a)

		LabelSetTextColor(ScrollChildWindow..WindowIndex.."Name", StringColor.r, StringColor.g, StringColor.b)
		WindowSetFontAlpha(ScrollChildWindow..WindowIndex.."Name", StringColor.a)
	end
end

--------------------------------------------------------------
-- function UpdateReloadUIButton
-- Description:
--------------------------------------------------------------
function RVMOD_Manager.UpdateReloadUIButton()

	-- First step: get locals
	local CanEnable	= false

	-- Second step: list all addons
	for AddonIndex, AddonData in ipairs(RVMOD_Manager.AddonsList) do

		-- : Third step: check for RVSwitchRequired flag
		if AddonData.RVSwitchRequired then
			CanEnable = true
			break
		end
	end

	-- Final step: set button status
	RVAPI_LQuery.API_WindowAnimateAlpha(WindowManager.."ContentButtonReloadUI", BooleanToNumber(CanEnable), true, RVMOD_Manager.CurrentConfiguration.FadeInOutDelay)
	ButtonSetDisabledFlag(WindowManager.."ContentButtonReloadUI", not CanEnable)
end

-------------------------------------------------------------
-- Window Events
--------------------------------------------------------------

function RVMOD_Manager.OnLButtonUpToggleButton()

	RVMOD_Manager.API_ToggleAddon(nil, nil)
end

function RVMOD_Manager.OnLButtonDownRow()

	local WindowIndex			= WindowGetId(SystemData.ActiveWindow.name)
	local AddonIndex			= RVMOD_Manager.AddonsOrder[WindowIndex]
	local AddonData				= RVMOD_Manager.AddonsList[AddonIndex]
	local AddonName				= AddonData.name

	RVMOD_Manager.ShowAddon(AddonName)
	RVMOD_Manager.UpdateListBox()
end

function RVMOD_Manager.OnLButtonDownStatusIcon()

	local ParentRow				= WindowGetParent(SystemData.ActiveWindow.name)
	local WindowIndex			= WindowGetId(ParentRow)
	local AddonIndex			= RVMOD_Manager.AddonsOrder[WindowIndex]
	local AddonData				= RVMOD_Manager.AddonsList[AddonIndex]

	AddonData.RVSwitchRequired	= not AddonData.RVSwitchRequired

	RVMOD_Manager.UpdateListBox()
	RVMOD_Manager.UpdateReloadUIButton()
end

function RVMOD_Manager.OnLButtonDownSettingsIcon()

end

function RVMOD_Manager.OnMouseOverStatusIcon()

	local ParentRow				= WindowGetParent(SystemData.ActiveWindow.name)
	local WindowIndex			= WindowGetId(ParentRow)
	local AddonIndex			= RVMOD_Manager.AddonsOrder[WindowIndex]
	local AddonData				= RVMOD_Manager.AddonsList[AddonIndex]

	Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, nil)
	Tooltips.SetTooltipText(1, 1, AddonData.RVName)
	Tooltips.SetTooltipText(2, 1, L"Status: "..UiModWindow.ModLoadStatusData[AddonData.loadStatus].name)
	Tooltips.SetTooltipText(3, 1, L"Click to mark for enabling/disabling")
	Tooltips.SetTooltipColor(2, 1, 57, 141, 255)
	Tooltips.SetTooltipColor(3, 1, 100, 160, 100)
	Tooltips.Finalize()

	local anchor = {Point="topright", RelativeTo=ParentRow, RelativePoint="topleft", XOffset=2, YOffset=0}
	Tooltips.AnchorTooltip(anchor)
	Tooltips.SetTooltipAlpha(1)
end

function RVMOD_Manager.OnMouseOverSettingsIcon()

	local ParentRow				= WindowGetParent(SystemData.ActiveWindow.name)
	local WindowIndex			= WindowGetId(ParentRow)
	local AddonIndex			= RVMOD_Manager.AddonsOrder[WindowIndex]
	local AddonData				= RVMOD_Manager.AddonsList[AddonIndex]

	Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, nil)
	Tooltips.SetTooltipText(1, 1, AddonData.RVName)
	Tooltips.SetTooltipText(2, 1, L"This addon is registered in the RV Mods Manager to show more options")
	Tooltips.SetTooltipColor(2, 1, 57, 141, 255)
	Tooltips.Finalize()

	local anchor = {Point="topright", RelativeTo=ParentRow, RelativePoint="topleft", XOffset=2, YOffset=0}
	Tooltips.AnchorTooltip(anchor)
	Tooltips.SetTooltipAlpha(1)
end

function RVMOD_Manager.OnClickTabSettings()

	RVMOD_Manager.CurrentConfiguration.ActiveTAB = TAB_SETTINGS
	RVMOD_Manager.UpdateTabs()
end

function RVMOD_Manager.OnClickTabGeneral()

	RVMOD_Manager.CurrentConfiguration.ActiveTAB = TAB_GENERAL
	RVMOD_Manager.UpdateTabs()
end

function RVMOD_Manager.OnLButtonUpFilterAll()

	RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_ALL] = not RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_ALL]
	RVMOD_Manager.UpdateFilterControls()

	RVMOD_Manager.FilterAddonsList()
	RVMOD_Manager.UpdateContentWindows()
	RVMOD_Manager.SortAddonsList()
end

function RVMOD_Manager.OnLButtonUpFilterRV()

	RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_RV] = not RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_RV]
	RVMOD_Manager.UpdateFilterControls()

	RVMOD_Manager.FilterAddonsList()
	RVMOD_Manager.UpdateContentWindows()
	RVMOD_Manager.SortAddonsList()
end

function RVMOD_Manager.OnLButtonUpFilterEA()

	RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_EA] = not RVMOD_Manager.CurrentConfiguration.FilterBy[FILTER_BY_EA]
	RVMOD_Manager.UpdateFilterControls()

	RVMOD_Manager.FilterAddonsList()
	RVMOD_Manager.UpdateContentWindows()
	RVMOD_Manager.SortAddonsList()
end

function RVMOD_Manager.OnLButtonUpSortBy()

	if RVMOD_Manager.CurrentConfiguration.SortOrder == SORT_ORDER_ASC then
		RVMOD_Manager.CurrentConfiguration.SortOrder = SORT_ORDER_DESC
	else
		RVMOD_Manager.CurrentConfiguration.SortOrder = SORT_ORDER_ASC
	end
	RVMOD_Manager.UpdateSortByControls()
	RVMOD_Manager.SortAddonsList()
end

function RVMOD_Manager.OnLButtonUpMagnifier()

	RVMOD_Manager.CurrentConfiguration.UseGlobalScale = not RVMOD_Manager.CurrentConfiguration.UseGlobalScale
	RVMOD_Manager.UpdateWindowScale(WindowManager)
end

function RVMOD_Manager.OnMouseOverFilterAll()

	Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, nil)
	Tooltips.SetTooltipText(1, 1, L"ALL")
	Tooltips.SetTooltipText(2, 1, L"Shows all user addons except addons with settings and EA addons")
	Tooltips.SetTooltipText(3, 1, L"Click to show/hide")
	Tooltips.SetTooltipColor(2, 1, 57, 141, 255)
	Tooltips.SetTooltipColor(3, 1, 100, 160, 100)
	Tooltips.Finalize()

	local anchor = {Point="topleft", RelativeTo=SystemData.ActiveWindow.name, RelativePoint="bottomleft", XOffset=0, YOffset=-8}
	Tooltips.AnchorTooltip(anchor)
	Tooltips.SetTooltipAlpha(1)
end

function RVMOD_Manager.OnMouseOverFilterRV()

	Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, nil)
	Tooltips.SetTooltipText(1, 1, L"RV")
	Tooltips.SetTooltipText(2, 1, L"Shows addons with settings")
	Tooltips.SetTooltipText(3, 1, L"Click to show/hide")
	Tooltips.SetTooltipColor(2, 1, 57, 141, 255)
	Tooltips.SetTooltipColor(3, 1, 100, 160, 100)
	Tooltips.Finalize()

	local anchor = {Point="topleft", RelativeTo=SystemData.ActiveWindow.name, RelativePoint="bottomleft", XOffset=0, YOffset=-8}
	Tooltips.AnchorTooltip(anchor)
	Tooltips.SetTooltipAlpha(1)
end

function RVMOD_Manager.OnMouseOverFilterEA()

	Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, nil)
	Tooltips.SetTooltipText(1, 1, L"EA")
	Tooltips.SetTooltipText(2, 1, L"Shows EA addons")
	Tooltips.SetTooltipText(3, 1, L"Click to show/hide")
	Tooltips.SetTooltipColor(2, 1, 57, 141, 255)
	Tooltips.SetTooltipColor(3, 1, 100, 160, 100)
	Tooltips.Finalize()

	local anchor = {Point="topleft", RelativeTo=SystemData.ActiveWindow.name, RelativePoint="bottomleft", XOffset=0, YOffset=-8}
	Tooltips.AnchorTooltip(anchor)
	Tooltips.SetTooltipAlpha(1)
end

function RVMOD_Manager.OnMouseOverSortBy()

	Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, nil)
	Tooltips.SetTooltipText(1, 1, L"Sort destination")
	Tooltips.SetTooltipText(2, 1, L"Click to change destination")
	Tooltips.SetTooltipColor(2, 1, 100, 160, 100)
	Tooltips.Finalize()

	local anchor = {Point="topleft", RelativeTo=SystemData.ActiveWindow.name, RelativePoint="bottomleft", XOffset=0, YOffset=-8}
	Tooltips.AnchorTooltip(anchor)
	Tooltips.SetTooltipAlpha(1)
end

function RVMOD_Manager.OnMouseOverMagnifier()

	Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, nil)
	Tooltips.SetTooltipText(1, 1, L"Magnifier")
	Tooltips.SetTooltipText(2, 1, L"Click to ZOOM in-out")
	Tooltips.SetTooltipColor(2, 1, 100, 160, 100)
	Tooltips.Finalize()

	local anchor = {Point="topleft", RelativeTo=SystemData.ActiveWindow.name, RelativePoint="bottomleft", XOffset=0, YOffset=-8}
	Tooltips.AnchorTooltip(anchor)
	Tooltips.SetTooltipAlpha(1)
end

function RVMOD_Manager.OnSelChangedSortBy( choiceIndex )

	RVMOD_Manager.CurrentConfiguration.SortBy = RVMOD_Manager.SortByChoices[choiceIndex].Value
	RVMOD_Manager.SortAddonsList()
end

function RVMOD_Manager.OnClickReloadUI()

	-- First step: check for disabled flag
	if ButtonGetDisabledFlag(WindowManager.."ContentButtonReloadUI") then
		return
	end

	-- Second step: set new enabled flag
	for AddonIndex, AddonData in ipairs(RVMOD_Manager.AddonsList) do

		-- : get "enabled" flag
		local IsEnabled = AddonData.isEnabled

		-- : switch on/off if necessary
		if AddonData.RVSwitchRequired then
			IsEnabled = not IsEnabled
		end

		-- : set module "enabled" flag
		ModuleSetEnabled(AddonData.name, IsEnabled)
	end	

	-- Final step: do /reloadui
	BroadcastEvent(SystemData.Events.RELOAD_INTERFACE)
end

function RVMOD_Manager.OnLButtonUpProcessed()

	-- : check if scale factor changed
	if ScaleFactorUpdated then

		-- : reset flag status
		ScaleFactorUpdated = false

		-- : animate window scale
		RVMOD_Manager.UpdateWindowScale(WindowManager)
	end
end

function RVMOD_Manager.OnSlideFadeInOutDelay(slidePos)

	RVMOD_Manager.CurrentConfiguration.FadeInOutDelay = slidePos
end

function RVMOD_Manager.OnSlideZoomInOutDelay(slidePos)

	RVMOD_Manager.CurrentConfiguration.ZoomInOutDelay = slidePos
end

function RVMOD_Manager.OnSlideScale(slidePos)

	-- First step: define locals
	local ScaleFactor = slidePos + 0.5

	-- Second step: check if scale factor changed
	if RVMOD_Manager.CurrentConfiguration.ScaleFactor ~= ScaleFactor then
		ScaleFactorUpdated = true
	end

	-- Final step: set new scale factor
	RVMOD_Manager.CurrentConfiguration.ScaleFactor = ScaleFactor
end

--------------------------------------------------------------------------------
--								RVMOD_Manager API							  --
--------------------------------------------------------------------------------

--------------------------------------------------------------
-- function API_RegisterAddon
-- Description: registers "CallbackFunction" for the "Name" addon
-- 				Name:				addon name. Should be the same from the .mod file under the "<UiMod />" tag
--				CallbackOwner:		table name for the CallbackFunction
--				CallbackFunction:	callBack function itself
--------------------------------------------------------------
function RVMOD_Manager.API_RegisterAddon(Name, CallbackOwner, CallbackFunction)

	-- First step: check for input
	if string.len(Name or "") <= 0 or CallbackOwner == nil or CallbackFunction == nil then

		d("API_RegisterAddon: "..Name.." addon can not be registered!")
		return false
	end

	-- Second step: save input data
	RegisteredRVAddons[Name] = {
		Name				= Name,
		CallbackOwner		= CallbackOwner,
		CallbackFunction	= CallbackFunction
	}

	-- Third step: update addons list
	RVMOD_Manager.UpdateRVVariables()
	RVMOD_Manager.FilterAddonsList()
	RVMOD_Manager.SortAddonsList()

	-- Fourth step: update active addon if needed
	if Name == RVMOD_Manager.CurrentConfiguration.ActiveAddon then
		RVMOD_Manager.ShowAddon(RVMOD_Manager.CurrentConfiguration.ActiveAddon)
	end

	-- Fifth step: update content windows
	RVMOD_Manager.UpdateContentWindows()

	-- Final step: return result
	return true
end

--------------------------------------------------------------
-- function API_ToggleAddon
-- Description: 
--------------------------------------------------------------
function RVMOD_Manager.API_ToggleAddon(Name, TabNumber)

	-- First step: define toggle logic
	if Name == nil or (string.lower(RVMOD_Manager.CurrentConfiguration.ActiveAddon) == string.lower(Name) and RVMOD_Manager.CurrentConfiguration.ActiveTAB == TabNumber) then

		-- : invert IsShowing flag
		RVMOD_Manager.CurrentConfiguration.IsShowing = not RVMOD_Manager.CurrentConfiguration.IsShowing
	else

		-- : set true
		RVMOD_Manager.CurrentConfiguration.IsShowing = true
	end

	-- Second step: update window visibility
	RVMOD_Manager.UpdateManagerWindowVisibility()

	-- Third step: update visible addon
	if RVMOD_Manager.CurrentConfiguration.IsShowing and Name~=nil then
		RVMOD_Manager.ShowAddon(Name)
		RVMOD_Manager.UpdateListBox()
	end

	-- Final step: update tabs
	if RVMOD_Manager.CurrentConfiguration.IsShowing and TabNumber~=nil then
		RVMOD_Manager.CurrentConfiguration.ActiveTAB = TabNumber
		RVMOD_Manager.UpdateTabs()
	end
end
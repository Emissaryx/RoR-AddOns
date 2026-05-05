local RVCredits					= "Taldren"
local RVLicense					= "MIT License"
local RVProjectURL				= "http://www.returnofreckoning.com/forum/viewtopic.php?f=11&t=4534"
local RVRecentUpdates			= 
"08.03.2016 - v1.15 Release\n"..
"\t- Effects prototype has been temporarily disabled, as it affected the general stability of the project. This might be rewritten later with a better and more stable implementaton\n"..
"\n"..
"09.07.2015 - v1.14 Release\n"..
"\t- Project official site location has been changed\n"..
"\n"..
"xx.xx.2010 - v1.13 Release\n"..
"\t- Fixed an issue related with the animation color for the dead unit. It should show dialog box correctly now\n"..
"\t- \n"..
"\n"..
"25.07.2010 - v1.12 Release\n"..
"\t- Code clearance\n"..
"\t- Adaptation to the new distance system has been made\n"..
"\t- Effects prototype (alpha version) has been implemented\n"..
"\t- 'No alpha animation' bug has been fixed\n"..
"\n"..
"24.02.2010 - v1.11 Release\n"..
"\t- Code clearance\n"..
"\t- Adapted to work with the RV Mods Manager v0.99"

RVF_EveOnline = RVAPI_Frame:Subclass()

--------------------------------------------------------------
-- function Initialize()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline.Initialize()

	-- First step: register this template in the RVAPI_Frames - templates and frames manager
	RVAPI_Frames.API_RegisterTemplate("RVF_EveOnline", "Eve Online")

	-- Second step: define event handlers
	RegisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "RVF_EveOnline.OnAllModulesInitialized")
end

--------------------------------------------------------------
-- function Shutdown()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline.Shutdown()

	-- First step: unregister all events
	UnregisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "RVF_EveOnline.OnAllModulesInitialized")

	-- Second step:
	RVAPI_Frames.API_UnRegisterTemplate("RVF_EveOnline")
end

--------------------------------------------------------------
-- function OnAllModulesInitialized()
-- Description: event ALL_MODULES_INITIALIZED
-- We can start working with the RVAPI just then we sure they are all initialized
-- and ready to provide their services
--------------------------------------------------------------
function RVF_EveOnline.OnAllModulesInitialized()

	-- Final step: register in the RV Mods Manager
	-- Please note the folowing:
	-- 1. always do this ON SystemData.Events.ALL_MODULES_INITIALIZED event
	-- 2. you don't need to add RVMOD_Manager to the dependency list
	-- 3. the registration code should be same as below, with your own function parameters
	-- 4. for more information please follow by project official site
	if RVMOD_Manager then
		RVMOD_Manager.API_RegisterAddon("RVF_EveOnline", RVF_EveOnline, RVF_EveOnline.OnRVManagerCallback)
	end
end

--------------------------------------------------------------
-- function OnRVManagerCallback
-- Description:
--------------------------------------------------------------
function RVF_EveOnline.OnRVManagerCallback(Self, Event, EventData)

	if	Event == RVMOD_Manager.Events.CREDITS_REQUESTED then

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
-- constructor Create()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:Create(frameName)

	-- First step: get an object from a parent method
	local frameObject = self:ParentCreate(frameName, "RVF_EveOnlineFrameTemplate", "Root")

	-- Second step: define "class" variables
	frameObject.eHealthPercent			= 100
	frameObject.eActionPercent			= 100
	frameObject.eName					= L""
	frameObject.eLevel					= 0
	frameObject.eTier					= 0
	frameObject.eRangeMax				= RVAPI_Range.Ranges.MAX_RANGE
	frameObject.eCareerLine				= 0
	frameObject.eCareerName				= L""
	frameObject.eTitle					= L""
	frameObject.eGroupIndex				= 0
	frameObject.eMemberIndex			= 0
	frameObject.eIsSelf					= false
	frameObject.eEffects				= {}
	frameObject.eCurrentColorBox		= ""

    local buffAnchor = 
    {
        Point           = "center",
        RelativePoint   = "center",
        RelativeTo      = frameName.."Effects", 
        XOffset         = 0,
        YOffset         = 0,
    }
	frameObject.eBuffTracker = CustomBuffTracker:Create(frameName.."Effects", "RVF_EveOnlineBuffIconTemplate", frameName.."Effects", buffAnchor, 0, 20, 5, SHOW_BUFF_FRAME_TIMER_LABELS)

	-- Third step: 
	AnimatedImageStartAnimation(frameName.."Animation", 0, true, false, 0)
	StatusBarSetMaximumValue(frameName.."ReticleHealthBar", 100)
	StatusBarSetMaximumValue(frameName.."ReticleActionBar", 100)
	frameObject:UpdateLines()

	-- Fourth step: register events
	WindowRegisterEventHandler(frameName, SystemData.Events.USER_SETTINGS_CHANGED, "RVF_EveOnline.OnUserSettingsChanged")
	WindowRegisterCoreEventHandler(frameName, "OnUpdate", "RVF_EveOnline.OnUpdate")
	WindowRegisterCoreEventHandler(frameName.."Animation", "OnShown", "RVF_EveOnline.OnShownAnimationWindow")

	-- Final step: return object
	return frameObject
end

--------------------------------------------------------------
-- destructor Destroy()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:Destroy()

	-- First step: get frame window
	local FrameWindow = self:GetFrameWindow()

	-- Second step: unregister events
	WindowUnregisterEventHandler(FrameWindow, SystemData.Events.USER_SETTINGS_CHANGED)
	WindowUnregisterCoreEventHandler(FrameWindow, "OnUpdate")
	WindowUnregisterCoreEventHandler(FrameWindow.."Animation", "OnShown")

	-- Third step: close buff tracker
	self.eBuffTracker:Shutdown()

	-- Final step: call parent destructor
	self:ParentDestroy()
end

--------------------------------------------------------------
-- function OnGetDefaultSettings()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:OnGetDefaultSettings()

	-- First step: collect all default settings
	local Settings = {
		showTargetName			= true,						-- show name label
		showTargetRange			= true,						-- show range label
		showTargetTitle			= true,						-- show target title
		showTargetLevel			= true,						-- show target level
		showTargetCareer		= true,						-- show target career
		showTargetHealthPercent	= true,						-- show target health percent
		showTargetRectangle		= true,						-- show reticle rectangle
		showTargetLines			= true,						-- show reticle lines
		showTargetCareerIcon	= true,						-- show career icon
		showTargetAnimation		= true,						-- show animation
		showTargetEffects		= false,					-- show effects, disabled by default while in alpha stage
		UseOutlineFont			= false,					-- use outline font

		swapNameFields			= false,					-- swap Name1 and Name2 fields

		UseGlobalScale			= true,
		ScaleFactor				= 1,						-- scale factor
		Layer					= Window.Layers.DEFAULT,	-- set background layer as default Window.Layers, WindowSetLayer(self.name, layer), WindowGetLayer(self.name)

		frameTintColor			= {R=1,		G=1,	B=1,	A=0.5},
		deadFrameTintColor		= {R=0.5,	G=0.5,	B=0.5,	A=1},
		linesTintColor			= {R=1,		G=1,	B=1,	A=0.5},
		deadLinesTintColor		= {R=0.5,	G=0.5,	B=0.5,	A=1},
		stringsTintColor		= {R=1,		G=1,	B=1,	A=1},
		deadStringsTintColor	= {R=1,		G=1,	B=1,	A=0.5},
		careerIconTintColor		= {R=1,		G=1,	B=1,	A=1},
		deadCareerIconTintColor	= {R=1,		G=1,	B=1,	A=0.75},
		animationTintColor		= {R=1,		G=1,	B=1,	A=0.75},
		deadAnimationTintColor	= {R=1,		G=1,	B=1,	A=0.5},
	}

	-- Final step: return result
	return Settings
end

--------------------------------------------------------------
-- function OnInitializeSettingsWindow()
-- Description: 
--------------------------------------------------------------
function RVF_EveOnline:OnInitializeSettingsWindow()

	local SettingsWindow = self:GetSettingsWindow()

	-- First step: create window from template
	CreateWindowFromTemplate(SettingsWindow, "RVF_EveOnlineSettingsTemplate", "Root")
	LabelSetText(SettingsWindow.."TitleBarText", L"Eve Online")
	ButtonSetText(SettingsWindow.."ButtonOK", L"OK")

	-- Second step: set tab buttons
	ButtonSetText(SettingsWindow.."TabGeneral", L"General")
	ButtonSetText(SettingsWindow.."TabStrings", L"Strings")
	ButtonSetText(SettingsWindow.."TabFrame", L"Frame")
	ButtonSetText(SettingsWindow.."TabCareerIcon", L"Career icon")
	ButtonSetText(SettingsWindow.."TabAnimation", L"Animation")

	-- Third step: set additional controls
	ComboBoxAddMenuItem(SettingsWindow.."TabWGeneralLayers", towstring("Background Layer (0)"))
	ComboBoxAddMenuItem(SettingsWindow.."TabWGeneralLayers", towstring("Default Layer (1)"))
	ComboBoxAddMenuItem(SettingsWindow.."TabWGeneralLayers", towstring("Secondary Layer (2)"))
	ComboBoxAddMenuItem(SettingsWindow.."TabWGeneralLayers", towstring("Popup Layer (3)"))
	ComboBoxAddMenuItem(SettingsWindow.."TabWGeneralLayers", towstring("Overlay Layer (4)"))

	LabelSetText(SettingsWindow.."TabWGeneralLabelEffectsEnabled", L"Enable effects (pre Alpha version)")
	LabelSetTextColor(SettingsWindow.."TabWGeneralLabelEffectsEnabled", 255, 255, 255)
	LabelSetText(SettingsWindow.."TabWGeneralLabelUseGlobalScale", L"Use Global UI Scale")
	LabelSetTextColor(SettingsWindow.."TabWGeneralLabelUseGlobalScale", 255, 255, 255)
	LabelSetText(SettingsWindow.."TabWGeneralSliderBarScaleLabel", L"Scale")

	-- Fourth step: set Frame tab window
	LabelSetText(SettingsWindow.."TabWFrameRectangleCaption", L"Rectangle")
	LabelSetText(SettingsWindow.."TabWFrameLabelRectangleEnabled", L"Enabled")
	LabelSetTextColor(SettingsWindow.."TabWFrameLabelRectangleEnabled", 255, 255, 255)

	LabelSetText(SettingsWindow.."TabWFrameLinesCaption", L"Lines")
	LabelSetText(SettingsWindow.."TabWFrameLabelLinesEnabled", L"Enabled")
	LabelSetTextColor(SettingsWindow.."TabWFrameLabelLinesEnabled", 255, 255, 255)

	-- Fifth step: set Strings tab window
	LabelSetText(SettingsWindow.."TabWStringsCaptionColor", L"Color")
	LabelSetTextColor(SettingsWindow.."TabWStringsCaptionColor", 255, 255, 255)

	LabelSetText(SettingsWindow.."TabWStringsLabelShowName", L"Show Name")
	LabelSetTextColor(SettingsWindow.."TabWStringsLabelShowName", 255, 255, 255)

	LabelSetText(SettingsWindow.."TabWStringsLabelShowLevel", L"Show Level")
	LabelSetTextColor(SettingsWindow.."TabWStringsLabelShowLevel", 255, 255, 255)

	LabelSetText(SettingsWindow.."TabWStringsLabelShowRange", L"Show Range")
	LabelSetTextColor(SettingsWindow.."TabWStringsLabelShowRange", 255, 255, 255)

	LabelSetText(SettingsWindow.."TabWStringsLabelShowTier", L"Show Title")
	LabelSetTextColor(SettingsWindow.."TabWStringsLabelShowTier", 255, 255, 255)

	LabelSetText(SettingsWindow.."TabWStringsLabelShowHealthPercent", L"Show Health Percentage")
	LabelSetTextColor(SettingsWindow.."TabWStringsLabelShowHealthPercent", 255, 255, 255)

	LabelSetText(SettingsWindow.."TabWStringsLabelShowOutlineFont", L"Use Outline Font")
	LabelSetTextColor(SettingsWindow.."TabWStringsLabelShowOutlineFont", 255, 255, 255)

	LabelSetText(SettingsWindow.."TabWStringsLabelSwapNameFields", L"Swap Names")
	LabelSetTextColor(SettingsWindow.."TabWStringsLabelSwapNameFields", 255, 255, 255)

	-- Sixth step: set CareerIcon tab window
	LabelSetText(SettingsWindow.."TabWCareerIconCaption", L"Career Icon")
	LabelSetText(SettingsWindow.."TabWCareerIconLabelEnabled", L"Enabled")
	LabelSetTextColor(SettingsWindow.."TabWCareerIconLabelEnabled", 255, 255, 255)

	-- Seventh step: set Animation tab window
	LabelSetText(SettingsWindow.."TabWAnimationCaption", L"Animation")
	LabelSetText(SettingsWindow.."TabWAnimationLabelEnabled", L"Enabled")
	LabelSetTextColor(SettingsWindow.."TabWAnimationLabelEnabled", 255, 255, 255)

	-- Final step: setup tabs visibility
	WindowSetShowing(SettingsWindow.."TabWGeneral", true)
	WindowSetShowing(SettingsWindow.."TabWStrings", false)
	WindowSetShowing(SettingsWindow.."TabWFrame", false)
	WindowSetShowing(SettingsWindow.."TabWCareerIcon", false)
	WindowSetShowing(SettingsWindow.."TabWAnimation", false)

	ButtonSetPressedFlag(SettingsWindow.."TabGeneral", true)
	ButtonSetPressedFlag(SettingsWindow.."TabStrings", false)
	ButtonSetPressedFlag(SettingsWindow.."TabFrame", false)
	ButtonSetPressedFlag(SettingsWindow.."TabCareerIcon", false)
	ButtonSetPressedFlag(SettingsWindow.."TabAnimation", false)
end

--------------------------------------------------------------
-- function OnShowSettingsWindow()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:OnShowSettingsWindow()

	local CurrentSettings	= self:GetSettings()
	local SettingsWindow	= self:GetSettingsWindow()

	-- First step: update General TAB
	ButtonSetPressedFlag(SettingsWindow.."TabWGeneralCheckBoxEffectsEnabled", CurrentSettings.showTargetEffects)
	ButtonSetPressedFlag(SettingsWindow.."TabWGeneralCheckBoxUseGlobalScale", CurrentSettings.UseGlobalScale)
	SliderBarSetCurrentPosition(SettingsWindow.."TabWGeneralSliderBarScale", CurrentSettings.ScaleFactor-0.5)
	LabelSetText(SettingsWindow.."TabWGeneralSliderBarScaleEdit",	towstring(string.sub(CurrentSettings.ScaleFactor, 1, 3)))
	ComboBoxSetSelectedMenuItem(SettingsWindow.."TabWGeneralLayers", CurrentSettings.Layer+1)

	-- : update Frame TAB
	ButtonSetPressedFlag(SettingsWindow.."TabWFrameCheckBoxRectangleEnabled", CurrentSettings.showTargetRectangle)
	ButtonSetPressedFlag(SettingsWindow.."TabWFrameCheckBoxLinesEnabled", CurrentSettings.showTargetLines)
	WindowSetTintColor(SettingsWindow.."TabWFrameRectangleLiveColorBorderForeground", CurrentSettings.frameTintColor.R*255, CurrentSettings.frameTintColor.G*255, CurrentSettings.frameTintColor.B*255) 
	WindowSetTintColor(SettingsWindow.."TabWFrameRectangleDeadColorBorderForeground", CurrentSettings.deadFrameTintColor.R*255, CurrentSettings.deadFrameTintColor.G*255, CurrentSettings.deadFrameTintColor.B*255) 
	WindowSetTintColor(SettingsWindow.."TabWFrameLinesLiveColorBorderForeground", CurrentSettings.linesTintColor.R*255, CurrentSettings.linesTintColor.G*255, CurrentSettings.linesTintColor.B*255) 
	WindowSetTintColor(SettingsWindow.."TabWFrameLinesDeadColorBorderForeground", CurrentSettings.deadLinesTintColor.R*255, CurrentSettings.deadLinesTintColor.G*255, CurrentSettings.deadLinesTintColor.B*255) 

	-- : update Strings TAB
	ButtonSetPressedFlag(SettingsWindow.."TabWStringsCheckBoxShowName", CurrentSettings.showTargetName)
	ButtonSetPressedFlag(SettingsWindow.."TabWStringsCheckBoxShowLevel", CurrentSettings.showTargetLevel)
	ButtonSetPressedFlag(SettingsWindow.."TabWStringsCheckBoxShowTier", CurrentSettings.showTargetTitle)
	ButtonSetPressedFlag(SettingsWindow.."TabWStringsCheckBoxShowRange", CurrentSettings.showTargetRange)
	ButtonSetPressedFlag(SettingsWindow.."TabWStringsCheckBoxShowHealthPercent", CurrentSettings.showTargetHealthPercent)
	ButtonSetPressedFlag(SettingsWindow.."TabWStringsCheckBoxShowOutlineFont", CurrentSettings.UseOutlineFont)
	ButtonSetPressedFlag(SettingsWindow.."TabWStringsCheckBoxSwapNameFields", CurrentSettings.swapNameFields)
	WindowSetTintColor(SettingsWindow.."TabWStringsLiveColorBorderForeground", CurrentSettings.stringsTintColor.R*255, CurrentSettings.stringsTintColor.G*255, CurrentSettings.stringsTintColor.B*255) 
	WindowSetTintColor(SettingsWindow.."TabWStringsDeadColorBorderForeground", CurrentSettings.deadStringsTintColor.R*255, CurrentSettings.deadStringsTintColor.G*255, CurrentSettings.deadStringsTintColor.B*255) 

	-- : update Career Icon TAB
	ButtonSetPressedFlag(SettingsWindow.."TabWCareerIconCheckBoxEnabled", CurrentSettings.showTargetCareerIcon)
	WindowSetTintColor(SettingsWindow.."TabWCareerIconLiveColorBorderForeground", CurrentSettings.careerIconTintColor.R*255, CurrentSettings.careerIconTintColor.G*255, CurrentSettings.careerIconTintColor.B*255) 
	WindowSetTintColor(SettingsWindow.."TabWCareerIconDeadColorBorderForeground", CurrentSettings.deadCareerIconTintColor.R*255, CurrentSettings.deadCareerIconTintColor.G*255, CurrentSettings.deadCareerIconTintColor.B*255) 

	-- : update Animation TAB
	ButtonSetPressedFlag(SettingsWindow.."TabWAnimationCheckBoxEnabled", CurrentSettings.showTargetAnimation)
	WindowSetTintColor(SettingsWindow.."TabWAnimationLiveColorBorderForeground", CurrentSettings.animationTintColor.R*255, CurrentSettings.animationTintColor.G*255, CurrentSettings.animationTintColor.B*255) 
	WindowSetTintColor(SettingsWindow.."TabWAnimationDeadColorBorderForeground", CurrentSettings.deadAnimationTintColor.R*255, CurrentSettings.deadAnimationTintColor.G*255, CurrentSettings.deadAnimationTintColor.B*255) 
end

--------------------------------------------------------------
-- function OnSetSetting()
-- Description: set settings event
--------------------------------------------------------------
function RVF_EveOnline:OnSetSetting(SettingName, Value)

	-- : get frame window
	local FrameWindow = self:GetFrameWindow()

	-- set frameTintColor, deadFrameTintColor
	if	SettingName == "frameTintColor" or
		SettingName == "deadFrameTintColor" then

		-- : update reticle
		self:UpdateRectangleColor()
	end

	-- set linesTintColor, deadLinesTintColor
	if	SettingName == "linesTintColor" or
		SettingName == "deadLinesTintColor" then

		-- : update lines
		self:UpdateLinesColor()
	end

	-- set stringsTintColor, deadStringsTintColor
	if	SettingName == "stringsTintColor" or
		SettingName == "deadStringsTintColor" then

		-- : update strings
		self:UpdateStringsColor()
	end

	-- set careerIconTintColor, deadCareerIconTintColor
	if	SettingName == "careerIconTintColor" or
		SettingName == "deadCareerIconTintColor" then

		-- : update career icon
		self:UpdateCareerIconColor()
	end

	-- set animationTintColor, deadAnimationTintColor
	if	SettingName == "animationTintColor" or
		SettingName == "deadAnimationTintColor" then

		-- : update animation
		self:UpdateAnimationColor()
	end

	-- set showTargetName
	if	SettingName == "showTargetName" then

		-- : update name
		self:UpdateName()
	end

	-- set showTargetLevel
	if	SettingName == "showTargetLevel" or
		SettingName == "showTargetTitle" then

		-- : update tier
		self:UpdateTier()
	end

	-- set showTargetRange
	if	SettingName == "showTargetRange" then
		WindowSetShowing(FrameWindow.."Range", Value)
	end

	-- set showTargetHealthPercent
	if	SettingName == "showTargetHealthPercent" then
		WindowSetShowing(FrameWindow.."Health", Value)
	end

	-- set showTargetRectangle
	if	SettingName == "showTargetRectangle" then
		WindowSetShowing(FrameWindow.."Reticle", Value)
	end

	-- set showTargetLines
	if	SettingName == "showTargetLines" then
		WindowSetShowing(FrameWindow.."HorizontalLine", Value)
		WindowSetShowing(FrameWindow.."VerticalLine", Value)
	end

	-- set showTargetCareerIcon
	if	SettingName == "showTargetCareerIcon" then
		WindowSetShowing(FrameWindow.."CareerIcon", Value)
	end

	-- set showTargetAnimation
	if	SettingName == "showTargetAnimation" then
		WindowSetShowing(FrameWindow.."Animation", Value)
	end

	-- set showTargetEffects
	if	SettingName == "showTargetEffects" then
		WindowSetShowing(FrameWindow.."Effects", Value)
	end

	-- set UseOutlineFont
	if	SettingName == "UseOutlineFont" then
		if Value then
			LabelSetFont(FrameWindow.."Name1", "font_clear_large", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
			LabelSetFont(FrameWindow.."Name2", "font_clear_large", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
			LabelSetFont(FrameWindow.."Range", "font_clear_large", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
			LabelSetFont(FrameWindow.."Health", "font_clear_large", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
		else
			LabelSetFont(FrameWindow.."Name1", "font_journal_text_large", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
			LabelSetFont(FrameWindow.."Name2", "font_journal_text_large", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
			LabelSetFont(FrameWindow.."Range", "font_journal_text_large", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
			LabelSetFont(FrameWindow.."Health", "font_journal_text_large", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
		end
	end

	-- set swapNameFields
	if	SettingName == "swapNameFields" then

		-- update Names
		self:UpdateName()
		self:UpdateTier()
	end

	-- set ScaleFactor
	if	SettingName == "ScaleFactor" or
		SettingName == "UseGlobalScale" then

		-- set Scale
		self:UpdateScale()
	end

	-- set Layer
	if	SettingName == "Layer" then

		-- set Layer
		WindowSetLayer(FrameWindow, Value)
	end
end

--------------------------------------------------------------
-- function GetSettingByWindow()
-- Description: 
--------------------------------------------------------------
function RVF_EveOnline:GetSettingByWindow(WindowName)

	local SettingsWindow = self:GetSettingsWindow()

	-- First step: calculate SettingName
	if WindowName == SettingsWindow.."TabWFrameRectangleLiveColor" then
		SettingName = "frameTintColor"
	elseif WindowName == SettingsWindow.."TabWFrameRectangleDeadColor" then
		SettingName = "deadFrameTintColor"
	elseif WindowName == SettingsWindow.."TabWFrameLinesLiveColor" then
		SettingName = "linesTintColor"
	elseif WindowName == SettingsWindow.."TabWFrameLinesDeadColor" then
		SettingName = "deadLinesTintColor"
	elseif WindowName == SettingsWindow.."TabWStringsLiveColor" then
		SettingName = "stringsTintColor"
	elseif WindowName == SettingsWindow.."TabWStringsDeadColor" then
		SettingName = "deadStringsTintColor"
	elseif WindowName == SettingsWindow.."TabWCareerIconLiveColor" then
		SettingName = "careerIconTintColor"
	elseif WindowName == SettingsWindow.."TabWCareerIconDeadColor" then
		SettingName = "deadCareerIconTintColor"
	elseif WindowName == SettingsWindow.."TabWAnimationLiveColor" then
		SettingName = "animationTintColor"
	elseif WindowName == SettingsWindow.."TabWAnimationDeadColor" then
		SettingName = "deadAnimationTintColor"
	end

	-- Final step: return result
	return SettingName
end

-------------------------------------------------------------
-- Window Events
--------------------------------------------------------------

function RVF_EveOnline.CloseSettings()

	local self = RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(SystemData.ActiveWindow.name))
	self:HideFrameSettings()
end

function RVF_EveOnline.OnClickTabGeneral()

	local self = RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(SystemData.ActiveWindow.name)))
	local SettingsWindow = self:GetSettingsWindow()

	WindowSetShowing(SettingsWindow.."TabWGeneral", true)
	WindowSetShowing(SettingsWindow.."TabWStrings", false)
	WindowSetShowing(SettingsWindow.."TabWFrame", false)
	WindowSetShowing(SettingsWindow.."TabWCareerIcon", false)
	WindowSetShowing(SettingsWindow.."TabWAnimation", false)

	ButtonSetPressedFlag(SettingsWindow.."TabGeneral", true)
	ButtonSetPressedFlag(SettingsWindow.."TabStrings", false)
	ButtonSetPressedFlag(SettingsWindow.."TabFrame", false)
	ButtonSetPressedFlag(SettingsWindow.."TabCareerIcon", false)
	ButtonSetPressedFlag(SettingsWindow.."TabAnimation", false)
end

function RVF_EveOnline.OnClickTabStrings()

	local self = RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(SystemData.ActiveWindow.name)))
	local SettingsWindow = self:GetSettingsWindow()

	WindowSetShowing(SettingsWindow.."TabWGeneral", false)
	WindowSetShowing(SettingsWindow.."TabWStrings", true)
	WindowSetShowing(SettingsWindow.."TabWFrame", false)
	WindowSetShowing(SettingsWindow.."TabWCareerIcon", false)
	WindowSetShowing(SettingsWindow.."TabWAnimation", false)

	ButtonSetPressedFlag(SettingsWindow.."TabGeneral", false)
	ButtonSetPressedFlag(SettingsWindow.."TabStrings", true)
	ButtonSetPressedFlag(SettingsWindow.."TabFrame", false)
	ButtonSetPressedFlag(SettingsWindow.."TabCareerIcon", false)
	ButtonSetPressedFlag(SettingsWindow.."TabAnimation", false)
end

function RVF_EveOnline.OnClickTabFrame()

	local self = RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(SystemData.ActiveWindow.name)))
	local SettingsWindow = self:GetSettingsWindow()

	WindowSetShowing(SettingsWindow.."TabWGeneral", false)
	WindowSetShowing(SettingsWindow.."TabWStrings", false)
	WindowSetShowing(SettingsWindow.."TabWFrame", true)
	WindowSetShowing(SettingsWindow.."TabWCareerIcon", false)
	WindowSetShowing(SettingsWindow.."TabWAnimation", false)

	ButtonSetPressedFlag(SettingsWindow.."TabGeneral", false)
	ButtonSetPressedFlag(SettingsWindow.."TabStrings", false)
	ButtonSetPressedFlag(SettingsWindow.."TabFrame", true)
	ButtonSetPressedFlag(SettingsWindow.."TabCareerIcon", false)
	ButtonSetPressedFlag(SettingsWindow.."TabAnimation", false)
end

function RVF_EveOnline.OnClickTabCareerIcon()

	local self = RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(SystemData.ActiveWindow.name)))
	local SettingsWindow = self:GetSettingsWindow()

	WindowSetShowing(SettingsWindow.."TabWGeneral", false)
	WindowSetShowing(SettingsWindow.."TabWStrings", false)
	WindowSetShowing(SettingsWindow.."TabWFrame", false)
	WindowSetShowing(SettingsWindow.."TabWCareerIcon", true)
	WindowSetShowing(SettingsWindow.."TabWAnimation", false)

	ButtonSetPressedFlag(SettingsWindow.."TabGeneral", false)
	ButtonSetPressedFlag(SettingsWindow.."TabStrings", false)
	ButtonSetPressedFlag(SettingsWindow.."TabFrame", false)
	ButtonSetPressedFlag(SettingsWindow.."TabCareerIcon", true)
	ButtonSetPressedFlag(SettingsWindow.."TabAnimation", false)
end

function RVF_EveOnline.OnClickTabAnimation()

	local self = RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(SystemData.ActiveWindow.name)))
	local SettingsWindow = self:GetSettingsWindow()

	WindowSetShowing(SettingsWindow.."TabWGeneral", false)
	WindowSetShowing(SettingsWindow.."TabWStrings", false)
	WindowSetShowing(SettingsWindow.."TabWFrame", false)
	WindowSetShowing(SettingsWindow.."TabWCareerIcon", false)
	WindowSetShowing(SettingsWindow.."TabWAnimation", true)

	ButtonSetPressedFlag(SettingsWindow.."TabGeneral", false)
	ButtonSetPressedFlag(SettingsWindow.."TabStrings", false)
	ButtonSetPressedFlag(SettingsWindow.."TabFrame", false)
	ButtonSetPressedFlag(SettingsWindow.."TabCareerIcon", false)
	ButtonSetPressedFlag(SettingsWindow.."TabAnimation", true)
end

function RVF_EveOnline.OnComboBoxLayerChange( choiceIndex )

	local ComboBoxWindow = SystemData.ActiveWindow.name
	local self = RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ComboBoxWindow)))

	self:SetSetting("Layer", choiceIndex-1)
end

function RVF_EveOnline.OnSlideScale( slidePos )

	local SliderWindow = SystemData.ActiveWindow.name
	local self = RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(SliderWindow)))
	local SettingsWindow = self:GetSettingsWindow()

	local ScaleFactor	= slidePos + 0.5
	self:SetSetting("ScaleFactor", ScaleFactor)
	LabelSetText(SettingsWindow.."TabWGeneralSliderBarScaleEdit", towstring(string.sub(ScaleFactor, 1, 3)))
end

function RVF_EveOnline.OnMouseOverColorBox()

	local ColorBoxWindow	= SystemData.ActiveWindow.name
	local self				= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ColorBoxWindow)))
	local SettingsWindow	= self:GetSettingsWindow()

	Tooltips.CreateTextOnlyTooltip (ColorBoxWindow, nil)

	if ColorBoxWindow == SettingsWindow.."TabWFrameRectangleLiveColor" then
		Tooltips.SetTooltipText(1, 1, L"color")
	elseif ColorBoxWindow == SettingsWindow.."TabWFrameRectangleDeadColor" then
		Tooltips.SetTooltipText(1, 1, L"dead unit color")
	elseif ColorBoxWindow == SettingsWindow.."TabWFrameLinesLiveColor" then
		Tooltips.SetTooltipText(1, 1, L"color")
	elseif ColorBoxWindow == SettingsWindow.."TabWFrameLinesDeadColor" then
		Tooltips.SetTooltipText(1, 1, L"dead unit color")
	elseif ColorBoxWindow == SettingsWindow.."TabWStringsLiveColor" then
		Tooltips.SetTooltipText(1, 1, L"color")
	elseif ColorBoxWindow == SettingsWindow.."TabWStringsDeadColor" then
		Tooltips.SetTooltipText(1, 1, L"dead unit color")
	elseif ColorBoxWindow == SettingsWindow.."TabWCareerIconLiveColor" then
		Tooltips.SetTooltipText(1, 1, L"color")
	elseif ColorBoxWindow == SettingsWindow.."TabWCareerIconDeadColor" then
		Tooltips.SetTooltipText(1, 1, L"dead unit color")
	elseif ColorBoxWindow == SettingsWindow.."TabWAnimationLiveColor" then
		Tooltips.SetTooltipText(1, 1, L"color")
	elseif ColorBoxWindow == SettingsWindow.."TabWAnimationDeadColor" then
		Tooltips.SetTooltipText(1, 1, L"dead unit color")
	end
	Tooltips.SetTooltipColorDef(1, 1, Tooltips.COLOR_BODY)
	Tooltips.Finalize()

	local anchor = {Point="topleft", RelativeTo=ColorBoxWindow, RelativePoint="bottomleft", XOffset=0, YOffset=-8}
	Tooltips.AnchorTooltip(anchor)
	Tooltips.SetTooltipAlpha(1)
end

function RVF_EveOnline.OnLButtonUpColorBox()

	-- First step: get the colorbox windo name and the right self: object
	local ColorBoxWindow	= SystemData.ActiveWindow.name
	local self				= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ColorBoxWindow)))
	local SettingsWindow	= self:GetSettingsWindow()

	-- Second step: check for the current ColorBox
	if self.eCurrentColorBox == ColorBoxWindow then

		-- Third step: close color dialog if opened
		RVAPI_ColorDialog.API_CloseDialog(true)
	else

		-- Fourth step: calculate input data
		local SettingName	= self:GetSettingByWindow(ColorBoxWindow)
		local Color			= self:GetSettings()[SettingName]
		local Layer			= WindowGetLayer(SettingsWindow) + 1
		if Layer > Window.Layers.OVERLAY then
			Layer			= Window.Layers.OVERLAY
		end

		-- Fifth step: open color dialog window
		RVAPI_ColorDialog.API_OpenDialog(self, RVF_EveOnline.OnColorDialogCallback, true, Color.R*255, Color.G*255, Color.B*255, Color.A, Layer)

		-- Sixth step: save new ColorBox window
		self.eCurrentColorBox = ColorBoxWindow
	end
end

function RVF_EveOnline:OnColorDialogCallback(Event, EventData)

	-- First step: check for the current ColorBox
	if self.eCurrentColorBox == "" then
		return
	end

	-- Second step: calculate setting name
	local SettingName = self:GetSettingByWindow(self.eCurrentColorBox)

	-- Third step: check for the setting name
	if SettingName == "" then
		return
	end

	-- Fourth step: get color
	local Color	= self:GetSettings()[SettingName]

	-- Fifth step: check for the right event
	if Event == RVAPI_ColorDialog.Events.COLOR_EVENT_UPDATED then

		-- : set new color values
		WindowSetTintColor(self.eCurrentColorBox.."BorderForeground", EventData.Red, EventData.Green, EventData.Blue) 
		Color.R	= EventData.Red / 255
		Color.G	= EventData.Green / 255
		Color.B	= EventData.Blue / 255
		Color.A	= EventData.Alpha
		self:SetSetting(SettingName, Color)

	elseif Event == RVAPI_ColorDialog.Events.COLOR_EVENT_CLOSED then

		-- : clear the current ColorBox window name
		self.eCurrentColorBox = ""
	end
end

function RVF_EveOnline.SetShowName()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local showTargetName		= self:GetSettings().showTargetName

	self:SetSetting("showTargetName", not showTargetName)
	ButtonSetPressedFlag(ActiveWindow, not showTargetName)
end

function RVF_EveOnline.SetShowLevel()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local showTargetLevel		= self:GetSettings().showTargetLevel

	self:SetSetting("showTargetLevel", not showTargetLevel)
	ButtonSetPressedFlag(ActiveWindow, not showTargetLevel)
end

function RVF_EveOnline.SetShowTier()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local showTargetTitle		= self:GetSettings().showTargetTitle

	self:SetSetting("showTargetTitle", not showTargetTitle)
	ButtonSetPressedFlag(ActiveWindow, not showTargetTitle)
end

function RVF_EveOnline.SetShowRange()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local showTargetRange		= self:GetSettings().showTargetRange

	self:SetSetting("showTargetRange", not showTargetRange)
	ButtonSetPressedFlag(ActiveWindow, not showTargetRange)
end

function RVF_EveOnline.SetShowHealthPercent()

	local ActiveWindow				= SystemData.ActiveWindow.name
	local self						= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local showTargetHealthPercent	= self:GetSettings().showTargetHealthPercent

	self:SetSetting("showTargetHealthPercent", not showTargetHealthPercent)
	ButtonSetPressedFlag(ActiveWindow, not showTargetHealthPercent)
end

function RVF_EveOnline.SetShowOutlineFont()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local UseOutlineFont		= self:GetSettings().UseOutlineFont

	self:SetSetting("UseOutlineFont", not UseOutlineFont)
	ButtonSetPressedFlag(ActiveWindow, not UseOutlineFont)
end

function RVF_EveOnline.SetSwapNameFields()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local swapNameFields		= self:GetSettings().swapNameFields

	self:SetSetting("swapNameFields", not swapNameFields)
	ButtonSetPressedFlag(ActiveWindow, not swapNameFields)
end

function RVF_EveOnline.SetEffectsEnabled()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local showTargetEffects		= self:GetSettings().showTargetEffects

	self:SetSetting("showTargetEffects", not showTargetEffects)
	ButtonSetPressedFlag(ActiveWindow, not showTargetEffects)
end

function RVF_EveOnline.SetUseGlobalScale()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local UseGlobalScale		= self:GetSettings().UseGlobalScale

	self:SetSetting("UseGlobalScale", not UseGlobalScale)
	ButtonSetPressedFlag(ActiveWindow, not UseGlobalScale)
end

function RVF_EveOnline.SetRectangleEnabled()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local showTargetRectangle	= self:GetSettings().showTargetRectangle

	self:SetSetting("showTargetRectangle", not showTargetRectangle)
	ButtonSetPressedFlag(ActiveWindow, not showTargetRectangle)
end

function RVF_EveOnline.SetLinesEnabled()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local showTargetLines		= self:GetSettings().showTargetLines

	self:SetSetting("showTargetLines", not showTargetLines)
	ButtonSetPressedFlag(ActiveWindow, not showTargetLines)
end

function RVF_EveOnline.SetCareerIconEnabled()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local showTargetCareerIcon	= self:GetSettings().showTargetCareerIcon

	self:SetSetting("showTargetCareerIcon", not showTargetCareerIcon)
	ButtonSetPressedFlag(ActiveWindow, not showTargetCareerIcon)
end

function RVF_EveOnline.SetAnimationEnabled()

	local ActiveWindow			= SystemData.ActiveWindow.name
	local self					= RVAPI_Frames.API_GetFrameObjectBySettingsWindow(WindowGetParent(WindowGetParent(ActiveWindow)))
	local showTargetAnimation	= self:GetSettings().showTargetAnimation

	self:SetSetting("showTargetAnimation", not showTargetAnimation)
	ButtonSetPressedFlag(ActiveWindow, not showTargetAnimation)
end

function RVF_EveOnline.OnLinesUpdated()

	local self = RVAPI_Frames.API_GetFrameObjectByFrameWindow(WindowGetParent(WindowGetParent(SystemData.ActiveWindow.name)))
	self:UpdateLines()
end

function RVF_EveOnline.OnUserSettingsChanged()

	local self = RVAPI_Frames.API_GetFrameObjectByFrameWindow(SystemData.ActiveWindow.name)
	self:UpdateLines()
	self:UpdateScale()
end

function RVF_EveOnline.OnUpdate(elapsedTime)

	local self = RVAPI_Frames.API_GetFrameObjectByFrameWindow(SystemData.ActiveWindow.name)
	self.eBuffTracker:Update(elapsedTime)
end

function RVF_EveOnline.OnShownAnimationWindow()

	-- NOTE: (MrAngel)	hack for the "no alpha animation" bug
	--					I have no idea what Mythic changed with this API function,
	--					but it would not work anymore fine without it
	local self = RVAPI_Frames.API_GetFrameObjectByFrameWindow(WindowGetParent(SystemData.ActiveWindow.name))
	self:UpdateAnimationColor()
end

--------------------------------------------------------------
-- function OnEntityUpdated()
-- Description: entity updated event
--------------------------------------------------------------
function RVF_EveOnline:OnEntityUpdated(EntityData)

	-- First step: calculate LiveDeadStatusChanged
	local LiveDeadStatusChanged =	(self.eHealthPercent > 0 and EntityData.HitPointPercent == 0) or 
									(self.eHealthPercent == 0 and EntityData.HitPointPercent > 0)

	-- Second step: save new values
	self.eHealthPercent	= EntityData.HitPointPercent
	self.eActionPercent	= EntityData.ActionPointPercent
	self.eName			= EntityData.Name
	self.eLevel			= EntityData.Level
	self.eTier			= EntityData.Tier
	self.eRangeMax		= EntityData.RangeMax
	self.eCareerLine	= EntityData.CareerLine
	self.eCareerName	= EntityData.CareerName
	self.eTitle			= EntityData.Title
	self.eGroupIndex	= EntityData.GroupIndex
	self.eMemberIndex	= EntityData.MemberIndex
	self.eIsSelf		= EntityData.IsSelf

	-- Second step: update frame elements
	self:UpdateName()
	self:UpdateTier()
	self:UpdateHealth()
	self:UpdateRange()
	self:UpdateHealthActionBars()
	self:UpdateCareerIcon()

	-- Third step: update effects if changed
	if self:CompareEffects(self.eEffects, EntityData.Effects) then
		self.eEffects	= EntityData.Effects
		self:UpdateEffects()
	end

	-- Final step: check live/dead status
	if LiveDeadStatusChanged then
		self:UpdateRectangleColor()
		self:UpdateLinesColor()
		self:UpdateStringsColor()
		self:UpdateCareerIconColor()
		self:UpdateAnimationColor()
	end
end

--------------------------------------------------------------
-- function CompareEffects()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:CompareEffects(Effects1, Effects2)

	-- First step: define locals
	local EffectsChanged1 = false
	local EffectsChanged2 = false

	-- Second step: check for Effects1
	for EffectIndex, EffectData in pairs(Effects1) do
		if Effects2[EffectIndex] == nil then
			EffectsChanged1 = true
			break
        end
	end

	-- Third step: check for Effects2
	for EffectIndex, EffectData in pairs(Effects2) do
		if Effects1[EffectIndex] == nil then
			EffectsChanged2 = true
			break
        end
	end

	-- Final step: return result
	return EffectsChanged1 or EffectsChanged2
end

--------------------------------------------------------------
-- function UpdateLines()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateLines()

	-- First step: get frame window
	local FrameWindow = self:GetFrameWindow()

	-- Second step: update horizontal line
	local Width, Height = WindowGetDimensions(FrameWindow.."HorizontalLine")
	WindowSetDimensions(FrameWindow.."HorizontalLineBar", Width, 1)

	-- Third step: update vertical line
	local Width, Height = WindowGetDimensions(FrameWindow.."VerticalLine")
	WindowSetDimensions(FrameWindow.."VerticalLineBar", 1, Height)
end

--------------------------------------------------------------
-- function UpdateScale()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateScale()

	-- First step: get frame window
	local FrameWindow = self:GetFrameWindow()

	-- Second step: get scale factor
	local ScaleFactor
	if self:GetSettings().UseGlobalScale then
		ScaleFactor = InterfaceCore.GetScale()
	else
		ScaleFactor = self:GetSettings().ScaleFactor or 1
	end

	-- Third step: apply scale factor
	WindowSetScale(FrameWindow.."Reticle", ScaleFactor*1)
	WindowSetScale(FrameWindow.."Animation", ScaleFactor*1)
	WindowSetScale(FrameWindow.."Effects", ScaleFactor*1)
	WindowSetScale(FrameWindow.."Name1", ScaleFactor*0.5)
	WindowSetScale(FrameWindow.."Health", ScaleFactor*1)
	WindowSetScale(FrameWindow.."Range", ScaleFactor*0.6)
	WindowSetScale(FrameWindow.."Name2", ScaleFactor*1)
	WindowSetScale(FrameWindow.."CareerIcon", ScaleFactor*0.8)
	WindowSetScale(FrameWindow.."HorizontalLine", 1)
	WindowSetScale(FrameWindow.."VerticalLine", 1)
end

--------------------------------------------------------------
-- function UpdateName()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateName()

	-- First step: get frame window
	local FrameWindow = self:GetFrameWindow()

	-- Second step: get original name
	local Name	= self.eName or ""
	if not self:GetSettings().showTargetName then
		Name = ""
	end

	-- Final step: send a name value to window
	if self:GetSettings().swapNameFields then
		LabelSetText(FrameWindow.."Name2", towstring(Name:upper()))
	else
		LabelSetText(FrameWindow.."Name1", towstring(Name:upper()))
	end
end

--------------------------------------------------------------
-- function UpdateTier()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateTier()

	-- First step: get locals
	local Tier			= self.eTier or 0
	local Title			= self.eTitle or L""
	local TitleLine		= self.eCareerName or L""
	local LevelLine		= self.eLevel or 0
	local FrameWindow	= self:GetFrameWindow()

	-- Second step: calculate a proper title
	if self:GetSettings().showTargetTitle then
		if  Title ~= L"" then
			TitleLine	= Title
		elseif Tier == 1 then
			TitleLine	= L"Champion"
		elseif  Tier == 2 then
			TitleLine	= L"Hero"
		elseif  Tier == 3 then
			TitleLine	= L"Lord"
		end
	else
		TitleLine		= L""
	end

	-- Third step: check for show level flag
	if self:GetSettings().showTargetLevel then

		-- Fourth step: check for TitleLine
		if TitleLine == L"" then
			LevelLine = LevelLine.." LVL"
		else
			LevelLine = " "..LevelLine
		end
	else
		LevelLine = ""
	end

	-- Final step: update tier and level
	if self:GetSettings().swapNameFields then
		LabelSetText(FrameWindow.."Name1", towstring(TitleLine:upper())..towstring(LevelLine))
	else
		LabelSetText(FrameWindow.."Name2", towstring(TitleLine:upper())..towstring(LevelLine))
	end
end

--------------------------------------------------------------
-- function UpdateHealth()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateHealth()

	-- First step: get locals
	local healthPercent	= self.eHealthPercent or 100
	local FrameWindow	= self:GetFrameWindow()

	-- Final step: update health
	LabelSetText(FrameWindow.."Health", towstring(healthPercent)..L"%")
end

--------------------------------------------------------------
-- function UpdateRange()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateRange()

	-- First step: get locals
	local RangeMax		= self.eRangeMax or RVAPI_Range.Ranges.MAX_RANGE
	local FrameWindow	= self:GetFrameWindow()

	-- Second step: check for range
	if RangeMax >= RVAPI_Range.Ranges.MAX_RANGE then

		-- Third step: set value as "FAR"
		LabelSetText(FrameWindow.."Range", L"FAR")
	else

		-- Fourth step: set actual value
		LabelSetText(FrameWindow.."Range", towstring(RangeMax)..L" ft")
	end
end

--------------------------------------------------------------
-- function UpdateHealthActionBars()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateHealthActionBars()

	-- First step: get frame window
	local FrameWindow = self:GetFrameWindow()

	-- Second step: update health bar
	local healthPercent		= self.eHealthPercent or 100
	local showHealthWindow	= healthPercent > 0
	WindowSetShowing(FrameWindow.."ReticleHealth", showHealthWindow)
	StatusBarSetCurrentValue(FrameWindow.."ReticleHealthBar", healthPercent)

	-- Third step: update action bar
	local actionPercent = self.eActionPercent or 100
	local showActionWindow	= actionPercent > 0 and (self.eGroupIndex > 0 and self.eMemberIndex > 0 or self.eIsSelf) and showHealthWindow
	WindowSetShowing(FrameWindow.."ReticleAction", showActionWindow)
	StatusBarSetCurrentValue(FrameWindow.."ReticleActionBar", actionPercent)
end

--------------------------------------------------------------
-- function UpdateCareerIcon()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateCareerIcon()

	-- First step: get frame window
	local FrameWindow = self:GetFrameWindow()

	-- Second step: check for career line 
	if self.eCareerLine ~= nil and self.eCareerLine ~=0 then

		-- Third step: get locals
		local ShowCareerIcon = self:GetSettings().showTargetCareerIcon
		local texture, x, y = GetIconData(Icons.GetCareerIconIDFromCareerLine(self.eCareerLine))

		-- Fourth step: set proper icon
		DynamicImageSetTexture(FrameWindow.."CareerIcon", texture, x, y)

		-- Fifth step: process showing status
		WindowSetShowing(FrameWindow.."CareerIcon", ShowCareerIcon)
	else

		-- Sixth step: hide icon
		WindowSetShowing(FrameWindow.."CareerIcon", false)
	end
end

--------------------------------------------------------------
-- function UpdateEffects()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateEffects()

	-- First step: update effects list in the buff tracker
	-- TODO: commented ou as it currently defective and does not work
--	self.eBuffTracker:UpdateBuffs(self.eEffects, true)
end

--------------------------------------------------------------
-- function UpdateRectangleColor()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateRectangleColor()

	-- First step: get frame window
	local FrameWindow = self:GetFrameWindow()

	-- Second step: get rectangle color by health
	local healthPercent = self.eHealthPercent or 100
	local TintColor
	if healthPercent > 0 then
		TintColor = self:GetSettings().frameTintColor
	else
		TintColor = self:GetSettings().deadFrameTintColor
	end

	-- Third step: check for TintColor
	if TintColor ~= nil then

		-- Fourth step: get RGBA components
		local R,G,B,A = math.floor(TintColor.R*255), math.floor(TintColor.G*255), math.floor(TintColor.B*255), TintColor.A

		-- Fifth step: set tint color for the rectangle and a bars
		WindowSetTintColor(FrameWindow.."Reticle", R, G, B)
		WindowSetAlpha(FrameWindow.."Reticle", A)
	
		WindowSetTintColor(FrameWindow.."ReticleHealth", 100, 100, 100)
		WindowSetTintColor(FrameWindow.."ReticleHealthBar", R, G, B)
	
		WindowSetTintColor(FrameWindow.."ReticleAction", 100, 100, 100)
		WindowSetTintColor(FrameWindow.."ReticleActionBar", R, G, B)
	end
end

--------------------------------------------------------------
-- function UpdateLinesColor()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateLinesColor()

	-- First step: get frame window
	local FrameWindow = self:GetFrameWindow()

	-- Second step: get lines color by health
	local healthPercent = self.eHealthPercent or 100
	local TintColor
	if healthPercent > 0 then
		TintColor = self:GetSettings().linesTintColor
	else
		TintColor = self:GetSettings().deadLinesTintColor
	end

	-- Third step: check for TintColor
	if TintColor ~= nil then

		-- Fourth step: get RGBA components
		local R,G,B,A = math.floor(TintColor.R*255), math.floor(TintColor.G*255), math.floor(TintColor.B*255), TintColor.A

		-- Fifth step: set tint color for the lines
		WindowSetTintColor(FrameWindow.."HorizontalLine", R, G, B)
		WindowSetTintColor(FrameWindow.."VerticalLine", R, G, B)
		WindowSetAlpha(FrameWindow.."HorizontalLine", A)
		WindowSetAlpha(FrameWindow.."VerticalLine", A)
	end
end

--------------------------------------------------------------
-- function UpdateStringsColor()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateStringsColor()

	-- First step: get frame window
	local FrameWindow = self:GetFrameWindow()

	-- Second step: get tint color by health
	local healthPercent = self.eHealthPercent or 100
	local TintColor
	if healthPercent > 0 then
		TintColor = self:GetSettings().stringsTintColor
	else
		TintColor = self:GetSettings().deadStringsTintColor
	end

	-- Third step: check for TintColor
	if TintColor == nil then
		return
	end

	-- Fourth step: get RGBA components
	local R,G,B,A = math.floor(TintColor.R*255), math.floor(TintColor.G*255), math.floor(TintColor.B*255), TintColor.A

	-- Fifth step: set tint color
	LabelSetTextColor(FrameWindow.."Name1", R, G, B)
	LabelSetTextColor(FrameWindow.."Name2", R, G, B)
	LabelSetTextColor(FrameWindow.."Health", R, G, B)
	LabelSetTextColor(FrameWindow.."Range", R, G, B)
	WindowSetFontAlpha(FrameWindow.."Name1", A)
	WindowSetFontAlpha(FrameWindow.."Name2", A)
	WindowSetFontAlpha(FrameWindow.."Health", A)
	WindowSetFontAlpha(FrameWindow.."Range", A)
end

--------------------------------------------------------------
-- function UpdateCareerIconColor()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateCareerIconColor()

	-- First step: get frame window
	local FrameWindow = self:GetFrameWindow()

	-- Second step: get tint color by health
	local healthPercent = self.eHealthPercent or 100
	local TintColor
	if healthPercent > 0 then
		TintColor = self:GetSettings().careerIconTintColor
	else
		TintColor = self:GetSettings().deadCareerIconTintColor
	end

	-- Third step: check for TintColor
	if TintColor == nil then
		return
	end

	-- Fourth step: get RGBA components
	local R,G,B,A = math.floor(TintColor.R*255), math.floor(TintColor.G*255), math.floor(TintColor.B*255), TintColor.A

	-- Fifth step: set tint color
	WindowSetTintColor(FrameWindow.."CareerIcon", R, G, B)
	WindowSetAlpha(FrameWindow.."CareerIcon", A)
end

--------------------------------------------------------------
-- function UpdateAnimationColor()
-- Description:
--------------------------------------------------------------
function RVF_EveOnline:UpdateAnimationColor()

	-- First step: get frame window
	local FrameWindow = self:GetFrameWindow()

	-- Second step: get tint color by health
	local healthPercent = self.eHealthPercent or 100
	local TintColor
	if healthPercent > 0 then
		TintColor = self:GetSettings().animationTintColor
	else
		TintColor = self:GetSettings().deadAnimationTintColor
	end

	-- Third step: check for TintColor
	if TintColor == nil then
		return
	end

	-- Fourth step: get RGBA components
	local R,G,B,A = math.floor(TintColor.R*255), math.floor(TintColor.G*255), math.floor(TintColor.B*255), TintColor.A

	-- Fifth step: set tint color
	WindowSetTintColor(FrameWindow.."Animation", R, G, B)

	-- Final step: restart animation
	WindowStopAlphaAnimation(FrameWindow.."Animation")
	WindowStartAlphaAnimation(FrameWindow.."Animation", Window.AnimationType.LOOP, A/10, A, 0.3, false, 0, 0)
end
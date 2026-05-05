RVAPI_ColorDialog = {}
local RVAPI_ColorDialog			= RVAPI_ColorDialog

local RVName					= "Color Dialog API"
local RVCredits					= "Philosound"
local RVLicense					= "MIT License"
local RVProjectURL				= "http://www.returnofreckoning.com/forum/viewtopic.php?f=11&t=4534"
local RVRecentUpdates			= 
"09.07.2015 - v1.03 Release\n"..
"\t- Project official site location has been changed\n"..
"\n"..
"11.03.2010 - v1.02 Release\n"..
"\t- RGB/RGBA color types support. API_OpenDialog has been modified. Thanks to Philosound for the good idea.\n"..
"\n"..
"24.02.2010 - v1.01 Release\n".. 
"\t- Code clearance\n"..
"\t- Adapted to work with the RV Mods Manager v0.99"

local WindowColorDialogSettings	= "RVAPI_ColorDialogSettings"
local WindowColorDialog			= "RVAPI_ColorDialogWindow"

local CurrentCallbackOwner		= nil
local CurrentCallbackFunction	= nil
local CurrentLayer				= Window.Layers.DEFAULT
local CurrentColorType			= 0
local CurrentColorRed			= 0
local CurrentColorGreen			= 0
local CurrentColorBlue			= 0
local CurrentColorAlpha			= 0
local NewColorRed				= 0
local NewColorGreen				= 0
local NewColorBlue				= 0
local NewColorAlpha				= 0
local NewColorHue				= 0
local NewColorSaturation		= 0
local NewColorBrightness		= 0

local ScreenMouseX				= 0
local ScreenMouseY				= 0

local IsMovingColorPointer		= false
local IsUpdatingEdits			= false

--------------------------------------------------------------
-- var ColorTypes
-- Description: color type. RGB or RGBA
--------------------------------------------------------------
RVAPI_ColorDialog.ColorTypes =
{
	COLOR_TYPE_RGB			= 1,
	COLOR_TYPE_RGBA			= 2,
}

--------------------------------------------------------------
-- var Events
-- Description: build in events
--------------------------------------------------------------
RVAPI_ColorDialog.Events =
{
	COLOR_EVENT_UPDATED		= 1,
	COLOR_EVENT_CLOSED		= 2,
}

--------------------------------------------------------------
-- var DefaultConfiguration
-- Description: default module configuration
--------------------------------------------------------------
RVAPI_ColorDialog.DefaultConfiguration =
{

}

--------------------------------------------------------------
-- var CurrentConfiguration
-- Description: current module configuration
--------------------------------------------------------------
RVAPI_ColorDialog.CurrentConfiguration =
{
	-- should stay empty, will load in the InitializeConfiguration() function
}

--------------------------------------------------------------
-- function Initialize()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.Initialize()

	-- First step: load configuration
	RVAPI_ColorDialog.InitializeConfiguration()

	-- Second step: define event handlers
	RegisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "RVAPI_ColorDialog.OnAllModulesInitialized")
	RegisterEventHandler(SystemData.Events.L_BUTTON_UP_PROCESSED, "RVAPI_ColorDialog.OnLButtonUpColor")
end

--------------------------------------------------------------
-- function Shutdown()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.Shutdown()

	-- First step: unregister all events
	UnregisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "RVAPI_ColorDialog.OnAllModulesInitialized")
	UnregisterEventHandler(SystemData.Events.L_BUTTON_UP_PROCESSED, "RVAPI_ColorDialog.OnLButtonUpColor")

	-- Second step: destroy color dialog window
	if DoesWindowExist(WindowColorDialog) then
		DestroyWindow(WindowColorDialog)
	end
end

--------------------------------------------------------------
-- function InitializeConfiguration()
-- Description: loads current configuration
--------------------------------------------------------------
function RVAPI_ColorDialog.InitializeConfiguration()

	-- First step: move default value to the CurrentConfiguration variable
	for k,v in pairs(RVAPI_ColorDialog.DefaultConfiguration) do
		if(RVAPI_ColorDialog.CurrentConfiguration[k]==nil) then
			RVAPI_ColorDialog.CurrentConfiguration[k]=v
		end
	end
end

--------------------------------------------------------------
-- function OnAllModulesInitialized()
-- Description: event ALL_MODULES_INITIALIZED
-- We can start working with the RVAPI just then we sure they are all initialized
-- and ready to provide their services
--------------------------------------------------------------
function RVAPI_ColorDialog.OnAllModulesInitialized()

	-- Final step: register in the RV Mods Manager
	-- Please note the folowing:
	-- 1. always do this ON SystemData.Events.ALL_MODULES_INITIALIZED event
	-- 2. you don't need to add RVMOD_Manager to the dependency list
	-- 3. the registration code should be same as below, with your own function parameters
	-- 4. for more information please follow by project official site
	if RVMOD_Manager then
		RVMOD_Manager.API_RegisterAddon("RVAPI_ColorDialog", RVAPI_ColorDialog, RVAPI_ColorDialog.OnRVManagerCallback)
	end
end

--------------------------------------------------------------
-- function OnRVManagerCallback
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.OnRVManagerCallback(Self, Event, EventData)

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

--[[
--------------------------------------------------------------
-- function InitializeWindowColorDialogSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.InitializeWindowColorDialogSettings(ParentWindow)

	-- First step: create a module settings window
	WGUIColorDialogSettings = ParentWindow("Window", WindowColorDialogSettings)
	WGUIColorDialogSettings:AnchorTo(ParentWindow, "topleft", "topleft")
	WGUIColorDialogSettings:AddAnchor(ParentWindow, "bottomright", "bottomright")

	-- Second step:
end

--------------------------------------------------------------
-- function ShowModuleSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.ShowModuleSettings(ModuleWindow)

	-- First step: check for window
	if not WGUIColorDialogSettings then
		RVAPI_ColorDialog.InitializeWindowColorDialogSettings(ModuleWindow)
	end

	-- Final step: show everything
	WGUIColorDialogSettings:Show()
end

--------------------------------------------------------------
-- function HideModuleSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.HideModuleSettings()

	-- Final step: hide window
	WGUIColorDialogSettings:Hide()
end

--------------------------------------------------------------
-- function GetModuleStatus()
-- Description: returns module status: RV_System.Status
--------------------------------------------------------------
function RVAPI_ColorDialog.GetModuleStatus()

	-- Final step: return status
	-- TODO: (MrAngel) place a status calculation code in here
	return RV_System.Status.MODULE_STATUS_ENABLED
end
]]
--------------------------------------------------------------
-- function InitializeWindowColorDialog()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.InitializeWindowColorDialog()

	-- First step: create main window
	CreateWindow(WindowColorDialog, false)

	-- Second step: set additional controls
	ButtonSetText(WindowColorDialog.."ButtonOK", L"OK")
	ButtonSetText(WindowColorDialog.."ButtonCancel", L"Cancel")

	LabelSetText(WindowColorDialog.."ColorNewLabel", L"new")
	LabelSetFont(WindowColorDialog.."ColorNewLabel", "font_clear_tiny", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextColor(WindowColorDialog.."ColorNewLabel", 255, 255, 255)

	LabelSetText(WindowColorDialog.."ColorCurrentLabel", L"current")
	LabelSetFont(WindowColorDialog.."ColorCurrentLabel", "font_clear_tiny", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextColor(WindowColorDialog.."ColorCurrentLabel", 255, 255, 255)

	LabelSetText(WindowColorDialog.."ColorCurrentHueLabel", L"H:")
	LabelSetFont(WindowColorDialog.."ColorCurrentHueLabel", "font_clear_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextColor(WindowColorDialog.."ColorCurrentHueLabel", 255, 255, 255)
	LabelSetText(WindowColorDialog.."ColorCurrentHueMetrics", L"degree")
	LabelSetFont(WindowColorDialog.."ColorCurrentHueMetrics", "font_clear_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextColor(WindowColorDialog.."ColorCurrentHueMetrics", 255, 255, 255)
	LabelSetText(WindowColorDialog.."ColorCurrentSaturationLabel", L"S:")
	LabelSetFont(WindowColorDialog.."ColorCurrentSaturationLabel", "font_clear_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextColor(WindowColorDialog.."ColorCurrentSaturationLabel", 255, 255, 255)
	LabelSetText(WindowColorDialog.."ColorCurrentSaturationMetrics", L"%")
	LabelSetFont(WindowColorDialog.."ColorCurrentSaturationMetrics", "font_clear_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextColor(WindowColorDialog.."ColorCurrentSaturationMetrics", 255, 255, 255)
	LabelSetText(WindowColorDialog.."ColorCurrentBrightnessLabel", L"B:")
	LabelSetFont(WindowColorDialog.."ColorCurrentBrightnessLabel", "font_clear_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextColor(WindowColorDialog.."ColorCurrentBrightnessLabel", 255, 255, 255)
	LabelSetText(WindowColorDialog.."ColorCurrentBrightnessMetrics", L"%")
	LabelSetFont(WindowColorDialog.."ColorCurrentBrightnessMetrics", "font_clear_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextColor(WindowColorDialog.."ColorCurrentBrightnessMetrics", 255, 255, 255)

	LabelSetText(WindowColorDialog.."ColorCurrentRedLabel", L"R:")
	LabelSetFont(WindowColorDialog.."ColorCurrentRedLabel", "font_clear_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextColor(WindowColorDialog.."ColorCurrentRedLabel", 255, 255, 255)
	LabelSetText(WindowColorDialog.."ColorCurrentGreenLabel", L"G:")
	LabelSetFont(WindowColorDialog.."ColorCurrentGreenLabel", "font_clear_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextColor(WindowColorDialog.."ColorCurrentGreenLabel", 255, 255, 255)
	LabelSetText(WindowColorDialog.."ColorCurrentBlueLabel", L"B:")
	LabelSetFont(WindowColorDialog.."ColorCurrentBlueLabel", "font_clear_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextColor(WindowColorDialog.."ColorCurrentBlueLabel", 255, 255, 255)

	LabelSetText(WindowColorDialog.."SliderBarAlphaLabel", L"Alpha")
end

--------------------------------------------------------------
-- function UpdateWindowSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.UpdateWindowSettings()

	-- First step: update settings window layer
	WindowSetLayer(WindowColorDialog, CurrentLayer)

	-- Second step: set new colors 
	NewColorRed			= CurrentColorRed
	NewColorGreen		= CurrentColorGreen
	NewColorBlue		= CurrentColorBlue
	NewColorAlpha		= CurrentColorAlpha

	-- Third step: convert to HSB
	NewColorHue,
	NewColorSaturation,
	NewColorBrightness	= RVAPI_ColorDialog.RGB2HSB(NewColorRed, NewColorGreen, NewColorBlue)

	-- Fourth step:
	WindowSetTintColor(WindowColorDialog.."ColorCurrentForeground", CurrentColorRed, CurrentColorGreen, CurrentColorBlue)
	RVAPI_ColorDialog.UpdateColorPreview()

	-- Fifth step: update color selector by HSB
	RVAPI_ColorDialog.UpdateColorSelector()

	-- Sixth step: update HSB edit fields
	RVAPI_ColorDialog.UpdateHSBEdits()

	-- Seventh step: update RGB edit fields
	RVAPI_ColorDialog.UpdateRGBEdits()

	-- Final step: update alpha slider bar
	RVAPI_ColorDialog.UpdateAlphaSliderBar()
end

--------------------------------------------------------------
-- function ShowWindowColorDialog()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.ShowWindowColorDialog()

	-- First step: check for window
	if not DoesWindowExist(WindowColorDialog) then
		RVAPI_ColorDialog.InitializeWindowColorDialog()
	end

	-- Second step: update fields with the current configuration 
	RVAPI_ColorDialog.UpdateWindowSettings()

	-- Final step: show everything
	WindowSetShowing(WindowColorDialog, true)
end

--------------------------------------------------------------
-- function HideWindowColorDialog()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.HideWindowColorDialog()

	-- Final step: hide window
	WindowSetShowing(WindowColorDialog, false)
end

--------------------------------------------------------------
-- function RGB2HSB()
-- Description: ported from the http://www.rags-int-inc.com/PhotoTechStuff/AcrCalibration/RGB2HSB.html
--------------------------------------------------------------
function RVAPI_ColorDialog.RGB2HSB(Red, Green, Blue)

	-- First step: define locals
	local min = math.min(Red, Green, Blue)
	local max = math.max(Red, Green, Blue)
	local delta = max - min
	local hue = 0
	local sat = 0
	local lumin = 0

	-- Second step: check for maximum RGB value
	if max ~= 0 then

		-- Third step: calculate saturation & luminence
		sat = delta / max 
		lumin = max / 255

		-- Fourth step: calculate hue
		if delta ~= 0 then
			if Red==max then
				hue = (Green - Blue) / delta
			elseif Green==max then
				hue = 2 + ((Blue - Red) / delta)
			else
				hue = 4 + ((Red - Green) / delta)
			end
		end
		hue = hue * 60
		if hue < 0 then
			hue = hue + 360
		end
	end

	-- Final step: return result
	return math.ceil(hue), math.ceil(sat * 100), math.ceil(lumin * 100)
end

--------------------------------------------------------------
-- function HSB2RGB()
-- Description: ported from the http://www.easyrgb.com/index.php?X=MATH
--------------------------------------------------------------
function RVAPI_ColorDialog.HSB2RGB(H, S, B)

	-- First step: define locals
	local Red, Green, Blue

	-- Second step: normalize to 1
	H = H/360
	S = S/100
	B = B/100

	-- Third step: check for saturaetion
	if S == 0 then

		Red = B * 255
		Green = B * 255
		Blue = B * 255

	else

		local var_h = H * 6

		if var_h == 6 then
			var_h = 0		-- H must be < 1
		end

		local var_i = math.floor(var_h)				 -- Or ... var_i = floor( var_h )
		local var_1 = B * (1 - S)
		local var_2 = B * (1 - S * (var_h - var_i))
		local var_3 = B * (1 - S * (1 - (var_h - var_i)))

		if var_i == 0 then
			var_r = B
			var_g = var_3
			var_b = var_1
		elseif var_i == 1 then
			var_r = var_2
			var_g = B
			var_b = var_1
		elseif var_i == 2 then
			var_r = var_1
			var_g = B
			var_b = var_3
		elseif var_i == 3 then
			var_r = var_1
			var_g = var_2
			var_b = B
		elseif var_i == 4 then
			var_r = var_3
			var_g = var_1
			var_b = B
		else
			var_r = B
			var_g = var_1
			var_b = var_2
		end

		-- : normalize to 255
		Red = var_r * 255
		Green = var_g * 255
		Blue = var_b * 255
	end

	-- Final step: return result
	return Red, Green, Blue
end

--------------------------------------------------------------
-- function UpdateColorSelector()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.UpdateColorPreview()

	-- First step: update color preview (new color field) 
	WindowSetTintColor(WindowColorDialog.."ColorNewForeground", NewColorRed, NewColorGreen, NewColorBlue)
end

--------------------------------------------------------------
-- function UpdateColorSelector()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.UpdateColorSelector()

	-- First step: get color window dimensions
	local GUIWindowWidth, GUIWindowHeight = WindowGetDimensions(WindowColorDialog.."Color")

	-- Second step: set color pointer position
	local ColorPointerX = (NewColorHue * (GUIWindowWidth-1)) / 360
	local ColorPointerY = (GUIWindowHeight-1) - (NewColorBrightness * (GUIWindowHeight-1)) / 100
	RVAPI_ColorDialog.SetColorPointerPostition(ColorPointerX, ColorPointerY)

	-- Third step: set saturation
	SliderBarSetCurrentPosition(WindowColorDialog.."SliderBarSaturation", NewColorSaturation / 100)
	WindowSetAlpha(WindowColorDialog.."ColorBlack", NewColorSaturation / 100)
end

--------------------------------------------------------------
-- function SetColorPointerPostition()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.SetColorPointerPostition(X, Y)

	-- First step: clear anchors
	WindowClearAnchors(WindowColorDialog.."ColorPointer")

	-- Second step: set new position
	WindowAddAnchor(WindowColorDialog.."ColorPointer", "topleft", WindowColorDialog.."Color", "center", X, Y)
end

--------------------------------------------------------------
-- function UpdateHSBEdits()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.UpdateHSBEdits()

	-- First step: set edit boxes values
	IsUpdatingEdits = true
	TextEditBoxSetText(WindowColorDialog.."ColorCurrentHue", towstring(math.floor(NewColorHue)))
	TextEditBoxSetText(WindowColorDialog.."ColorCurrentSaturation", towstring(math.floor(NewColorSaturation)))
	TextEditBoxSetText(WindowColorDialog.."ColorCurrentBrightness", towstring(math.floor(NewColorBrightness)))
	IsUpdatingEdits = false
end

--------------------------------------------------------------
-- function UpdateRGBEdits()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.UpdateRGBEdits()

	-- First step: set edit boxes values
	IsUpdatingEdits = true
	TextEditBoxSetText(WindowColorDialog.."ColorCurrentRed", towstring(math.floor(NewColorRed)))
	TextEditBoxSetText(WindowColorDialog.."ColorCurrentGreen", towstring(math.floor(NewColorGreen)))
	TextEditBoxSetText(WindowColorDialog.."ColorCurrentBlue", towstring(math.floor(NewColorBlue)))
	IsUpdatingEdits = false
end

--------------------------------------------------------------
-- function UpdateAlphaSliderBar()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.UpdateAlphaSliderBar()

	-- First step: update slider bar and information
	SliderBarSetCurrentPosition(WindowColorDialog.."SliderBarAlpha", NewColorAlpha)
	LabelSetText(WindowColorDialog.."SliderBarAlphaEdit",	towstring(string.sub(NewColorAlpha, 1, 6)))

	-- Second step: set controls visibility
	WindowSetShowing(WindowColorDialog.."SliderBarAlpha", CurrentColorType == RVAPI_ColorDialog.ColorTypes.COLOR_TYPE_RGBA)
	WindowSetShowing(WindowColorDialog.."SliderBarAlphaEdit", CurrentColorType == RVAPI_ColorDialog.ColorTypes.COLOR_TYPE_RGBA)
	WindowSetShowing(WindowColorDialog.."SliderBarAlphaLabel", CurrentColorType == RVAPI_ColorDialog.ColorTypes.COLOR_TYPE_RGBA)
end

--------------------------------------------------------------
-- function SendNewColor()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.SendNewColor()

	-- First step: send color information to the client application
	CurrentCallbackFunction(CurrentCallbackOwner, RVAPI_ColorDialog.Events.COLOR_EVENT_UPDATED, {Red = NewColorRed, Green = NewColorGreen, Blue = NewColorBlue, Alpha = NewColorAlpha})
end

--------------------------------------------------------------
-- function SendCurrentColor()
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.SendCurrentColor()

	-- First step: send color information to the client application
	CurrentCallbackFunction(CurrentCallbackOwner, RVAPI_ColorDialog.Events.COLOR_EVENT_UPDATED, {Red = CurrentColorRed, Green = CurrentColorGreen, Blue = CurrentColorBlue, Alpha = CurrentColorAlpha})
end

-------------------------------------------------------------
-- Window Events
--------------------------------------------------------------

function RVAPI_ColorDialog.OnUpdate( timePassed )

	-- First step: check for mouse position changed
	if (ScreenMouseX ~= SystemData.MousePosition.x or ScreenMouseY ~= SystemData.MousePosition.y) then

		-- Second step: save new position
		ScreenMouseX = SystemData.MousePosition.x
		ScreenMouseY = SystemData.MousePosition.y

		-- Final step: emulate mouse move event
		RVAPI_ColorDialog.OnMouseMove(ScreenMouseX, ScreenMouseY)
	end
end

function RVAPI_ColorDialog.OnMouseMove(MouseX, MouseY)

	-- First step: check for moving pointer flag
	if IsMovingColorPointer then

		-- Second step: get locals
		local ScreenWindowX, ScreenWindowY = WindowGetScreenPosition(WindowColorDialog.."Color")
		local GUIColorX = ScreenMouseX / InterfaceCore.GetScale() - ScreenWindowX / InterfaceCore.GetScale()
		local GUIColorY = ScreenMouseY / InterfaceCore.GetScale() - ScreenWindowY / InterfaceCore.GetScale()
		local GUIWindowWidth, GUIWindowHeight = WindowGetDimensions(WindowColorDialog.."Color")

		-- Third step: fix coordinates
		if GUIColorX < 0 then
			GUIColorX = 0
		end
		if GUIColorX > GUIWindowWidth - 1 then
			GUIColorX = GUIWindowWidth - 1
		end
		if GUIColorY < 0 then
			GUIColorY = 0
		end
		if GUIColorY > GUIWindowHeight - 1 then
			GUIColorY = GUIWindowHeight - 1
		end

		-- Fourth step: set pointer position
		RVAPI_ColorDialog.SetColorPointerPostition(GUIColorX, GUIColorY)

		-- Fifth step: set new HSB
		NewColorHue				= (GUIColorX * 360) / (GUIWindowWidth - 1)
		NewColorBrightness		= 100 - (GUIColorY * 100) / (GUIWindowHeight - 1)

		-- Sixth step: set new RGB
		NewColorRed,
		NewColorGreen,
		NewColorBlue			= RVAPI_ColorDialog.HSB2RGB(NewColorHue, NewColorSaturation, NewColorBrightness)

		-- Seventh step: update fields
		RVAPI_ColorDialog.UpdateHSBEdits()
		RVAPI_ColorDialog.UpdateRGBEdits()
		RVAPI_ColorDialog.UpdateColorPreview()

		-- Final step: send new color to the client application
		RVAPI_ColorDialog.SendNewColor()
	end
end

function RVAPI_ColorDialog.OnLButtonDownColor()

	-- First step: inform everyone we are starting to move pointer
	IsMovingColorPointer = true

	-- Second step: emulate OnMouseMove event
	RVAPI_ColorDialog.OnMouseMove(ScreenMouseX, ScreenMouseY)
end

function RVAPI_ColorDialog.OnLButtonUpColor()

	-- First step: inform everyone we are not moving pointer
	IsMovingColorPointer = false
end

function RVAPI_ColorDialog.OnTextChangedEdit()

	-- First step: check for IsUpdatingEdits
	if IsUpdatingEdits then 
		return
	end

	-- Second step: get edit window name
	local EditWindow = SystemData.ActiveWindow.name

	-- Third step: check for the value type. It should be numeric only
	local Value = tonumber(WStringToString(TextEditBoxGetText(EditWindow)))
	if Value == nil
	then
		return
	end

	-- Fourth step: check for right edit window name
	if EditWindow == WindowColorDialog.."ColorCurrentHue" then

		-- : check for right range
		if Value < 0 or Value > 360 then
			return
		end

		-- : set new HSB
		NewColorHue			= Value

		-- : set new RGB
		NewColorRed,
		NewColorGreen,
		NewColorBlue		= RVAPI_ColorDialog.HSB2RGB(NewColorHue, NewColorSaturation, NewColorBrightness)

	elseif EditWindow == WindowColorDialog.."ColorCurrentSaturation" then

		-- : check for right range
		if Value < 0 or Value > 100 then
			return
		end

		-- : set new HSB
		NewColorSaturation	= Value

		-- : set new RGB
		NewColorRed,
		NewColorGreen,
		NewColorBlue		= RVAPI_ColorDialog.HSB2RGB(NewColorHue, NewColorSaturation, NewColorBrightness)

	elseif EditWindow == WindowColorDialog.."ColorCurrentBrightness" then

		-- : check for right range
		if Value < 0 or Value > 100 then
			return
		end

		-- : set new HSB
		NewColorBrightness	= Value

		-- : set new RGB
		NewColorRed,
		NewColorGreen,
		NewColorBlue		= RVAPI_ColorDialog.HSB2RGB(NewColorHue, NewColorSaturation, NewColorBrightness)

	elseif EditWindow == WindowColorDialog.."ColorCurrentRed" then

		-- : check for right range
		if Value < 0 or Value > 255 then
			return
		end

		-- : set new RGB
		NewColorRed			= Value

		-- : set new HSB
		NewColorHue,
		NewColorSaturation,
		NewColorBrightness	= RVAPI_ColorDialog.RGB2HSB(NewColorRed, NewColorGreen, NewColorBlue)

	elseif EditWindow == WindowColorDialog.."ColorCurrentGreen" then

		-- : check for right range
		if Value < 0 or Value > 255 then
			return
		end

		-- : set new RGB
		NewColorGreen		= Value

		-- : set new HSB
		NewColorHue,
		NewColorSaturation,
		NewColorBrightness	= RVAPI_ColorDialog.RGB2HSB(NewColorRed, NewColorGreen, NewColorBlue)

	elseif EditWindow == WindowColorDialog.."ColorCurrentBlue" then

		-- : check for right range
		if Value < 0 or Value > 255 then
			return
		end

		-- : set new RGB
		NewColorBlue		= Value

		-- : set new HSB
		NewColorHue,
		NewColorSaturation,
		NewColorBrightness	= RVAPI_ColorDialog.RGB2HSB(NewColorRed, NewColorGreen, NewColorBlue)

	end

	-- Fifth step: update fields
	RVAPI_ColorDialog.UpdateColorSelector()
	RVAPI_ColorDialog.UpdateHSBEdits()
	RVAPI_ColorDialog.UpdateRGBEdits()
	RVAPI_ColorDialog.UpdateColorPreview()

	-- Final step: send new color to the client application
	RVAPI_ColorDialog.SendNewColor()
end

function RVAPI_ColorDialog.OnSlide( slidePos )

	local SliderWindow = SystemData.ActiveWindow.name

	if SliderWindow == WindowColorDialog.."SliderBarSaturation" then

		-- : set alpha for the ColorBlack
		WindowSetAlpha(WindowColorDialog.."ColorBlack", slidePos)

		-- : set new HSB
		NewColorSaturation		= slidePos * 100

		-- : set new RGB
		NewColorRed,
		NewColorGreen,
		NewColorBlue			= RVAPI_ColorDialog.HSB2RGB(NewColorHue, NewColorSaturation, NewColorBrightness)

		-- : update fields
		RVAPI_ColorDialog.UpdateHSBEdits()
		RVAPI_ColorDialog.UpdateRGBEdits()
		RVAPI_ColorDialog.UpdateColorPreview()

		-- : send new color to the client application
		RVAPI_ColorDialog.SendNewColor()

	elseif SliderWindow == WindowColorDialog.."SliderBarAlpha" then

		-- : set alpha information
		LabelSetText(WindowColorDialog.."SliderBarAlphaEdit", towstring(string.sub(slidePos, 1, 6)))

		-- : set new A
		NewColorAlpha			= slidePos

		-- : send new color to the client application
		RVAPI_ColorDialog.SendNewColor()

	end
end

function RVAPI_ColorDialog.OnLButtonUpButtonOK()

	-- First step: close dialog window and save color
	RVAPI_ColorDialog.API_CloseDialog(true)
end

function RVAPI_ColorDialog.OnLButtonUpButtonCancel()

	-- First step: close dialog window and don't save a color
	RVAPI_ColorDialog.API_CloseDialog(false)
end

--------------------------------------------------------------------------------
--							RVAPI_ColorDialog API							  --
--------------------------------------------------------------------------------

--------------------------------------------------------------
-- function API_GetLink
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.API_GetLink()

	-- Final step: return link information
	return CurrentCallbackOwner, CurrentCallbackFunction
end

--------------------------------------------------------------
-- function API_OpenDialog
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.API_OpenDialog(CallbackOwner, CallbackFunction, SaveColor, ColorR, ColorG, ColorB, ColorA, Layer, ColorType)

	-- First step: check for input data
	if CallbackOwner == nil or CallbackFunction == nil then
		return false
	end

	-- Second step: close dialog window and don't save a color settings
	RVAPI_ColorDialog.API_CloseDialog(SaveColor)

	-- Third step: set new link
	CurrentCallbackOwner	= CallbackOwner
	CurrentCallbackFunction	= CallbackFunction
	CurrentColorRed			= ColorR or 0
	CurrentColorGreen		= ColorG or 0
	CurrentColorBlue		= ColorB or 0
	CurrentColorAlpha		= ColorA or 1
	CurrentLayer			= Layer or Window.Layers.DEFAULT
	CurrentColorType		= ColorType or RVAPI_ColorDialog.ColorTypes.COLOR_TYPE_RGBA

	-- Fourth step: show settings window
	RVAPI_ColorDialog.ShowWindowColorDialog()

	-- Final step: return result
	return true
end

--------------------------------------------------------------
-- function API_CloseDialog
-- Description:
--------------------------------------------------------------
function RVAPI_ColorDialog.API_CloseDialog(SaveColor)

	-- First step: check for link
	if CurrentCallbackOwner == nil or CurrentCallbackFunction == nil then
		return false
	end

	-- Second step: get locals
	local LocalSaveColor = SaveColor or false

	-- Third step: check for the SaveColor flag
	if LocalSaveColor then

		-- Fourth step: send new color to the client application
		RVAPI_ColorDialog.SendNewColor()
	else

		-- Fifth step: send current color to the client application
		RVAPI_ColorDialog.SendCurrentColor()
	end

	-- Sixth step: hide dialog window
	RVAPI_ColorDialog.HideWindowColorDialog()

	-- Seventh step: send OnClose event to the client application
	CurrentCallbackFunction(CurrentCallbackOwner, RVAPI_ColorDialog.Events.COLOR_EVENT_CLOSED, {ColorSaved = LocalSaveColor})

	-- Eight step: clear link information
	CurrentCallbackOwner	= nil
	CurrentCallbackFunction	= nil

	-- Final step: return result
	return true
end
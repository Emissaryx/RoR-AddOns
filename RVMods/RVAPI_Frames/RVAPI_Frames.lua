RVAPI_Frames = {}
local RVAPI_Frames				= RVAPI_Frames

local RVName					= "Frames API"
local RVCredits					= "silverq"
local RVLicense					= "MIT License"
local RVProjectURL				= "http://www.returnofreckoning.com/forum/viewtopic.php?f=11&t=4534"
local RVRecentUpdates			= 
"09.07.2015 - v1.05 Release\n"..
"\t- Project official site location has been changed\n"..
"\n"..
"25.08.2010 - v1.04 Release\n"..
"\t- updated to work with the Range API v2.0"..
"\n"..
"25.07.2010 - v1.03 Release\n"..
"\t- Templates signature idea has been removed from the project\n"..
"\t- TemplatesList have more data now\n"..
"\n"..
"24.02.2010 - v1.02 Release\n".. 
"\t- Code clearance\n"..
"\t- Adapted to work with the RV Mods Manager v0.99"

local WindowFramesSettings		= "RVAPI_FramesSettingsWindow"
local TemplatesList				= {}
local FramesList				= {}

--------------------------------------------------------------
-- var DefaultConfiguration
-- Description: default module configuration
--------------------------------------------------------------
RVAPI_Frames.DefaultConfiguration =
{

}

--------------------------------------------------------------
-- var CurrentConfiguration
-- Description: current module configuration
--------------------------------------------------------------
RVAPI_Frames.CurrentConfiguration =
{
	-- should stay empty, will load in the InitializeConfiguration() function
}

--------------------------------------------------------------
-- function Initialize()
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.Initialize()

	-- First step: load configuration
	RVAPI_Frames.InitializeConfiguration()

	-- Second step: define event handlers
	RegisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "RVAPI_Frames.OnAllModulesInitialized")
end

--------------------------------------------------------------
-- function Shutdown()
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.Shutdown()

	-- First step: unregister all events
	UnregisterEventHandler(SystemData.Events.ALL_MODULES_INITIALIZED, "RVAPI_Frames.OnAllModulesInitialized")
end

--------------------------------------------------------------
-- function OnCheckRequirementsCallback
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.OnCheckTemplateRequirementsCallback(Module)

	-- First step: define module requirements here
	-- TODO: (MrAngel) will remove later if no used
	return true
end

--------------------------------------------------------------
-- function InitializeConfiguration()
-- Description: loads current configuration
--------------------------------------------------------------
function RVAPI_Frames.InitializeConfiguration()

	-- First step: move default value to the CurrentConfiguration variable
	for k,v in pairs(RVAPI_Frames.DefaultConfiguration) do
		if(RVAPI_Frames.CurrentConfiguration[k]==nil) then
			RVAPI_Frames.CurrentConfiguration[k]=v
		end
	end
end

--------------------------------------------------------------
-- function OnAllModulesInitialized()
-- Description: event ALL_MODULES_INITIALIZED
-- We can start working with the RVAPI just then we sure they are all initialized
-- and ready to provide their services
--------------------------------------------------------------
function RVAPI_Frames.OnAllModulesInitialized()

	-- Final step: register in the RV Mods Manager
	-- Please note the folowing:
	-- 1. always do this ON SystemData.Events.ALL_MODULES_INITIALIZED event
	-- 2. you don't need to add RVMOD_Manager to the dependency list
	-- 3. the registration code should be same as below, with your own function parameters
	-- 4. for more information please follow by project official site
	if RVMOD_Manager then
		RVMOD_Manager.API_RegisterAddon("RVAPI_Frames", RVAPI_Frames, RVAPI_Frames.OnRVManagerCallback)
	end
end

--------------------------------------------------------------
-- function OnRVManagerCallback
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.OnRVManagerCallback(Self, Event, EventData)

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
-- function InitializeWindowFramesSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.InitializeWindowFramesSettings(ParentWindow)

	-- First step: create a module settings window
	WGUIFramesSettings = ParentWindow("Window", WindowFramesSettings)
	WGUIFramesSettings:AnchorTo(ParentWindow, "topleft", "topleft")
	WGUIFramesSettings:AddAnchor(ParentWindow, "bottomright", "bottomright")

	-- Second step:
end

--------------------------------------------------------------
-- function ShowModuleSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.ShowModuleSettings(ModuleWindow)

	-- First step: check for window
	if not WGUIFramesSettings then
		RVAPI_Frames.InitializeWindowFramesSettings(ModuleWindow)
	end

	-- Final step: show everything
	WGUIFramesSettings:Show()
end

--------------------------------------------------------------
-- function HideModuleSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.HideModuleSettings()

	-- Final step: hide window
	WGUIFramesSettings:Hide()
end

--------------------------------------------------------------
-- function GetModuleStatus()
-- Description: returns module status: RV_System.Status
--------------------------------------------------------------
function RVAPI_Frames.GetModuleStatus()

	-- Final step: return status
	-- TODO: (MrAngel) place a status calculation code in here
	return RV_System.Status.MODULE_STATUS_ENABLED
end
]]

--------------------------------------------------------------------------------
--								RVAPI_Frames API							  --
--------------------------------------------------------------------------------

--------------------------------------------------------------
-- function API_IsTemplateExists
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_IsTemplateExists(templateTable)

	-- Final step: return result
	return TemplatesList[templateTable] ~= nil
end

--------------------------------------------------------------
-- function API_RegisterTemplate
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_RegisterTemplate(templateTable, templateName)

	-- First step: check for dublicates
	if RVAPI_Frames.API_IsTemplateExists(templateTable) then

		d("API_RegisterTemplate: "..templateTable.." is a duplicate!")
		return
	end

	-- Second step: check for the template requrements
	if not RVAPI_Frames.OnCheckTemplateRequirementsCallback(_G[templateTable]) then

		d("API_RegisterTemplate: "..templateTable.." can not be registered!")
		return
	end

	-- Final step: save table instance
	TemplatesList[templateTable] =
	{
		TableName		= templateTable,
		TemplateName	= templateName, 
		Object			= _G[templateTable],
	}
end

--------------------------------------------------------------
-- function API_UnRegisterTemplate
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_UnRegisterTemplate(templateTable)

	-- First step: check for templateTable exists
	if not RVAPI_Frames.API_IsTemplateExists(templateTable) then

		d("API_UnRegisterTemplate: "..templateTable.." is not registered!")
		return
	end

	-- Final step: remove template from the TemplatesList
	TemplatesList[templateTable] = nil
end

--------------------------------------------------------------
-- function API_GetTemplatesList
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_GetTemplatesList()

	-- Final step: return templates list
	return TemplatesList
end

--------------------------------------------------------------
-- function API_RegisterFrame
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_RegisterFrame(frameName, templateTable, visible)

	-- First step: check for template
	if not RVAPI_Frames.API_IsTemplateExists(templateTable) then

		d("API_RegisterFrame: "..templateTable.." template not found!")
		return false
	end

	-- Second step: check for dublicates
	if FramesList[frameName] ~= nil then

		d("API_RegisterFrame: "..frameName.." is a duplicate!")
		return false
	end

	-- Third step: register new frame
	FramesList[frameName] = _G[templateTable]:Create(frameName)

	-- Final step: hide frame if needed
	visible = visible or false
	if not visible then
		FramesList[frameName]:Hide()
	end

	return true
end

--------------------------------------------------------------
-- function API_UnRegisterFrame
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_UnRegisterFrame(frameName)

	-- First step: check for frameName exists
	if FramesList[frameName] == nil then

		d("API_UnRegisterFrame: "..frameName.." is not registered!")
		return
	end

	-- Final step: destroy frame
	FramesList[frameName]:Destroy()
	FramesList[frameName] = nil
end

--------------------------------------------------------------
-- function API_IsFrameExists
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_IsFrameExists(frameName)

	-- Final step: return result
	return FramesList[frameName] ~= nil
end

--------------------------------------------------------------
-- function API_UpdateFrameTarget
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_UpdateFrameTarget(frameName, entityId, hideOnZeroEntity)

	-- First step: check for frameName exists
	if FramesList[frameName] == nil then

		d("API_UpdateFrameTarget: "..frameName.." is not registered!")
		return
	end

	-- Final step: update frame target
	FramesList[frameName]:SetEntity(entityId, hideOnZeroEntity)
end

--------------------------------------------------------------
-- function API_GetFrameObjectByFrameWindow
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_GetFrameObjectByFrameWindow(frameName)

	-- First step: check for frameName exists
	if FramesList[frameName] == nil then

		d("API_GetFrameObjectByFrameWindow: "..frameName.." is not registered!")
		return
	end

	-- Final step: return result
	return FramesList[frameName]
end

--------------------------------------------------------------
-- function API_GetFrameObjectBySettingsWindow
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_GetFrameObjectBySettingsWindow(settingsName)

	-- First step: list every registered frame
	for frameName, frameObject in pairs(FramesList) do

		-- Second step: check for frame settings window name
		if frameObject.WindowFrameSettings == settingsName then

			-- Third step: return found object
			return frameObject
		end
	end

	-- Final step: return nothing
	return nil
end

--------------------------------------------------------------
-- function API_OpenFrameSettings
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_OpenFrameSettings(frameName)

	-- First step: check for frameName exists
	if FramesList[frameName] == nil then

		d("API_OpenFrameSettings: "..frameName.." is not registered!")
		return
	end

	-- Final step: show farme settings
	FramesList[frameName]:ShowFrameSettings()
end

--------------------------------------------------------------
-- function API_CloseFrameSettings
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_CloseFrameSettings(frameName)

	-- First step: check for frameName exists
	if FramesList[frameName] == nil then

		d("API_CloseFrameSettings: "..frameName.." is not registered!")
		return
	end

	-- Final step: hide frame settings
	FramesList[frameName]:HideFrameSettings()
end

--------------------------------------------------------------
-- function API_CloseFrameSettings
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_IsFrameShowingSettings(frameName)

	-- First step: check for frameName exists
	if FramesList[frameName] == nil then

		d("API_CloseFrameSettings: "..frameName.." is not registered!")
		return
	end

	-- Second step: return result
	local SettingsWindow = FramesList[frameName].WindowFrameSettings
	if DoesWindowExist(SettingsWindow) then
		return WindowGetShowing(SettingsWindow)
	else
		return false
	end
end

--------------------------------------------------------------
-- function API_GetFrameSettings
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_GetFrameSettings(frameName)

	-- First step: check for frameName exists
	if FramesList[frameName] == nil then

		d("API_GetFrameSettings: "..frameName.." is not registered!")
		return
	end

	-- Second step: return settings
	return FramesList[frameName]:GetSettings()
end

--------------------------------------------------------------
-- function API_SetFrameSettings
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_SetFrameSettings(frameName, Settings)

	-- First step: check for frameName exists
	if FramesList[frameName] == nil then

		d("API_SetFrameSettings: "..frameName.." is not registered!")
		return
	end

	-- Second step: set settings
	FramesList[frameName]:SetSettings(Settings)
end

--------------------------------------------------------------
-- function API_SetFrameSetting
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_SetFrameSetting(frameName, settingName, value)

	-- First step: check for frameName exists
	if FramesList[frameName] == nil then

		d("API_SetFrameSetting: "..frameName.." is not registered!")
		return
	end

	-- Second step: set settings
	FramesList[frameName]:SetSetting(settingName, value)
end

--------------------------------------------------------------
-- function API_LinkFrameSettings
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_LinkFrameSettings(parentFrameName, childFrameName)

	-- First step: check for parentFrameName exists
	if FramesList[parentFrameName] == nil then

		d("API_LinkFrameSettings: "..parentFrameName.." is not registered!")
		return
	end

	-- Second step: check for childFrameName exists
	if FramesList[childFrameName] == nil then

		d("API_LinkFrameSettings: "..childFrameName.." is not registered!")
		return
	end

	-- Third step: link frame settings
	FramesList[parentFrameName]:LinkSettings(childFrameName)
end

--------------------------------------------------------------
-- function API_UnLinkFrameSettings
-- Description:
--------------------------------------------------------------
function RVAPI_Frames.API_UnLinkFrameSettings(parentFrameName, childFrameName)

	-- First step: check for parentFrameName exists
	if FramesList[parentFrameName] == nil then

		d("API_UnLinkFrameSettings: "..parentFrameName.." is not registered!")
		return
	end

	-- Second step: check for childFrameName exists
	if FramesList[childFrameName] == nil then

		d("API_UnLinkFrameSettings: "..childFrameName.." is not registered!")
		return
	end

	-- Third step: unlink frame settings
	FramesList[parentFrameName]:UnLinkSettings(childFrameName)
end
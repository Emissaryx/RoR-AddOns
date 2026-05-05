RVAPI_Frame			= {}
RVAPI_Frame.__index	= RVAPI_Frame

--------------------------------------------------------------
-- function Subclass()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:Subclass()
	local derivedObject = setmetatable ({}, self)

	derivedObject.__index       = derivedObject

	for k, v in pairs (self)
	do
		if (type (v) == "function")
		then
			derivedObject["Parent"..k] = v
		end
	end

	return derivedObject
end

--------------------------------------------------------------
-- constructor Create()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:Create(frameName, templateName, parentName)

	-- First step: define parent window
	parentName = parentName or "Root"

	-- Second step: create anchor
	if not CreateWindowFromTemplate (frameName, templateName, parentName)
	then
		return nil
	end

	-- Third Fourth step: get table
	local frameObject = setmetatable ({}, self)

	-- Fourth step: init variables
	frameObject.WindowFrame			= frameName
	frameObject.WindowFrameSettings	= frameName.."Settings"
	frameObject.EntityId			= 0
	frameObject.ChildFrames			= {}
	frameObject.Settings			= {}
	frameObject.DefaultSettings		= frameObject:OnGetDefaultSettings()

	-- Fifth step: assign events
	WindowRegisterCoreEventHandler(frameName, "OnShown", "RVAPI_Frame.ShowFrameEvent")
	WindowRegisterCoreEventHandler(frameName, "OnHidden", "RVAPI_Frame.HideFrameEvent")
	RVAPI_Entities.API_RegisterEventHandler(RVAPI_Entities.Events.ENTITY_LOADING_BEGIN, frameObject, frameObject.LoadingBeginEvent)
	RVAPI_Entities.API_RegisterEventHandler(RVAPI_Entities.Events.ENTITY_UPDATED, frameObject, frameObject.EntityUpdatedEvent)

	-- Sixth step: set default configuration and call set settings event
	frameObject:SetSettings(frameObject.DefaultSettings)

	-- Final step: return object
	return frameObject
end

--------------------------------------------------------------
-- destructor Destroy()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:Destroy()

	-- First step: hide frame
	self:Hide()

	-- Second step: hide settings window
	self:HideFrameSettings()

	-- Third step: destroy settings window
	if DoesWindowExist(self.WindowFrameSettings) then
		DestroyWindow(self.WindowFrameSettings)
	end

	-- Fourth step: unregister events
	WindowUnregisterCoreEventHandler(self.WindowFrame, "OnShown")
	WindowUnregisterCoreEventHandler(self.WindowFrame, "OnHidden")
	RVAPI_Entities.API_UnregisterEventHandler(RVAPI_Entities.Events.ENTITY_LOADING_BEGIN, self, self.LoadingBeginEvent)
	RVAPI_Entities.API_UnregisterEventHandler(RVAPI_Entities.Events.ENTITY_UPDATED, self, self.EntityUpdatedEvent)

	-- Final step: destroy frame
	if DoesWindowExist(self.WindowFrame) then
		DestroyWindow(self.WindowFrame)
	end
end

--------------------------------------------------------------
-- function Show()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:Show()

	-- First step: check showing status
	if WindowGetShowing(self.WindowFrame) then
		return false
	end

	-- Second step: show window
	WindowSetShowing(self.WindowFrame, true)

	-- Final step: attach window if needed
	self:Attach()
end

--------------------------------------------------------------
-- function Hide()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:Hide()

	-- First step: detach window
	self:Detach()

	-- Second step: check showing status
	if not WindowGetShowing(self.WindowFrame) then
		return
	end

	-- Final step: hide window
	WindowSetShowing(self.WindowFrame, false)
end

--------------------------------------------------------------
-- function ShowFrameEvent()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame.ShowFrameEvent()

	-- First step: get frame object
	local self = RVAPI_Frames.API_GetFrameObjectByFrameWindow(SystemData.ActiveWindow.name)

	-- Final step: call event
	self:OnShowFrameWindow()
end

--------------------------------------------------------------
-- function HideFrameEvent()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame.HideFrameEvent()

	-- First step: get frame object
	local self = RVAPI_Frames.API_GetFrameObjectByFrameWindow(SystemData.ActiveWindow.name)

	-- Final step: call event
	self:OnHideFrameWindow()
end

--------------------------------------------------------------
-- function LoadingBeginEvent()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:LoadingBeginEvent(EventData)

	-- Final step: reset entityId to zero
	self:SetEntity(0, true)
end

--------------------------------------------------------------
-- function EntityUpdatedEvent()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:EntityUpdatedEvent(EventData)

	-- First step: check for correct entityId
	if EventData.EntityId ~= self.EntityId then
		return
	end

	-- Final step: call event
	self:OnEntityUpdated(EventData.EntityData)
end

--------------------------------------------------------------
-- function SetEntity()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:SetEntity(EntityId, hideOnZeroEntity)

	-- First step: check if entityId is changed
	if self.EntityId==EntityId then
		return
	end

	-- Second step: detach window and hide if needed
	if EntityId==0 and hideOnZeroEntity then
		self:Hide()
	else
		self:Detach()
	end

	-- Third step: set new entity Id
	self.EntityId = EntityId

	-- Fourth step: attach window to a new entity Id
	self:Attach()

	-- Final step: call event
	if self.EntityId > 0 then
		local EntityData = RVAPI_Entities.API_GetEntityData(self.EntityId)
		self:OnEntityUpdated(EntityData)
	end
end

--------------------------------------------------------------
-- function Attach()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:Attach()

	-- First step: check for current entityId
	if self.EntityId > 0 then

		-- Second step: attach window
		MoveWindowToWorldObject(self.WindowFrame, self.EntityId, 1.0)
		AttachWindowToWorldObject(self.WindowFrame, self.EntityId)

		-- Final step: call event
		self:OnAttach()
	end
end

--------------------------------------------------------------
-- function Detach()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:Detach()

	-- First step: check for current entityId
	if self.EntityId > 0 then

		-- Second step: detach window
		DetachWindowFromWorldObject(self.WindowFrame, self.EntityId)

		-- Final step: call event
		self:OnDetach()
	end
end

--------------------------------------------------------------
-- function GetSettingsWindow()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:GetSettingsWindow()

	-- First step: get settings window name
	return self.WindowFrameSettings
end

--------------------------------------------------------------
-- function GetFrameWindow()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:GetFrameWindow()

	-- First step: get frame window name
	return self.WindowFrame
end

--------------------------------------------------------------
-- function GetSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:GetSettings()

	-- First step: get current configuration for the frame
	return self.Settings
end

--------------------------------------------------------------
-- function SetSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:SetSettings(Settings)

	-- First step: check for input value
	if Settings ~= nil then

		-- Second step: set all settings
		for SettingName, Value in pairs(self.DefaultSettings) do

			-- Third step: check if Settings[SettingName] is set
			if Settings[SettingName] ~= nil then
				self:SetSetting(SettingName, Settings[SettingName])
			end
		end
	end
end

--------------------------------------------------------------
-- function SetSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:SetSetting(SettingName, Value)

	-- First step: set new configuration
	self.Settings[SettingName] = Value

	-- Second step: set childrens configuration
	for FrameIndex, FrameName in ipairs(self.ChildFrames) do
		RVAPI_Frames.API_SetFrameSetting(FrameName, SettingName, Value)
	end

	-- Final step: call OnSetSettings event
	self:OnSetSetting(SettingName, Value)
end

--------------------------------------------------------------
-- function LinkSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:LinkSettings(FrameName)

	-- First step: set new settings to the FrameName 
	RVAPI_Frames.API_SetFrameSettings(FrameName, self.Settings)

	-- Final step: save fraem name in the ChildFrames list
	table.insert(self.ChildFrames, FrameName)
end

--------------------------------------------------------------
-- function UnLinkSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:UnLinkSettings(FrameName)

	-- First step: get the FrameName index in the ChildFrames list
	for FrameIndex, FrameValue in ipairs(self.ChildFrames) do

		-- Second step: check for the frame name
		if FrameName == FrameValue then

			-- Final step: remove FrameName from the ChildFrames list
			table.remove(self.ChildFrames, FrameIndex)
		end
	end
end

--------------------------------------------------------------
-- function ShowFrameSettings()
-- Description: 
--------------------------------------------------------------
function RVAPI_Frame:ShowFrameSettings()

	-- First step: check if the WindowFrameSettings is initialized
	if not DoesWindowExist(self.WindowFrameSettings) then
		self:OnInitializeSettingsWindow()
	end

	-- Second step: show window
	if not WindowGetShowing(self.WindowFrameSettings) then
		WindowSetShowing(self.WindowFrameSettings, true)
	end

	-- Final step: send event
	self:OnShowSettingsWindow()
end

--------------------------------------------------------------
-- function HideFrameSettings()
-- Description: 
--------------------------------------------------------------
function RVAPI_Frame:HideFrameSettings()

	-- First step: check if the WindowFrameSettings is initialized
	if not DoesWindowExist(self.WindowFrameSettings) then
		return
	end

	-- Second step: hide window
	if WindowGetShowing(self.WindowFrameSettings) then
		WindowSetShowing(self.WindowFrameSettings, false)

		-- Final step: send event
		RVAPI_Frame:OnHideSettingsWindow()
	end
end

--------------------------------------------------------------
-- function OnGetDefaultSettings()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:OnGetDefaultSettings()

	local Settings = {
		-- your default settings here
	}

	return Settings
end

--------------------------------------------------------------
-- function OnShowFrameWindow()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:OnShowFrameWindow()

	-- your on show code here
end

--------------------------------------------------------------
-- function OnHideFrameWindow()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:OnHideFrameWindow()

	-- your on hide code here
end

--------------------------------------------------------------
-- function OnEntityUpdated()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:OnEntityUpdated(EntityData)

	-- your on entity updated code here
end

--------------------------------------------------------------
-- function OnAttach()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:OnAttach()

	-- your on attach code here
end

--------------------------------------------------------------
-- function OnDetach()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:OnDetach()

	-- your on detach code here
end

--------------------------------------------------------------
-- function OnSetSetting()
-- Description:
--------------------------------------------------------------
function RVAPI_Frame:OnSetSetting(SettingName, Value)

	-- your on set setting code here
end

--------------------------------------------------------------
-- function OnInitializeSettingsWindow()
-- Description: 
--------------------------------------------------------------
function RVAPI_Frame:OnInitializeSettingsWindow()

	-- your on initialize settings window code here
end

--------------------------------------------------------------
-- function OnShowSettingsWindow()
-- Description: 
--------------------------------------------------------------
function RVAPI_Frame:OnShowSettingsWindow()

	-- your on show setting window code here
end

--------------------------------------------------------------
-- function OnHideSettingsWindow()
-- Description: 
--------------------------------------------------------------
function RVAPI_Frame:OnHideSettingsWindow()

	-- your on hide setting window code here
end
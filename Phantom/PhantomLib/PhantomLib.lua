local MAJOR, MINOR = "PhantomLib", 18

local PhantomLib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not PhantomLib then return end

local strmatch = string.match
local WindowGetId = WindowGetId
local DoesWindowExist = DoesWindowExist
local ButtonGetPressedFlag = ButtonGetPressedFlag

PhantomLib._dirtyWindows = true
PhantomLib._dirtyBuffs = true
PhantomLib._dirtyRegister = true

local oWindowSetShowing = WindowSetShowing

local WindowSetShowing =
    function(window, show)
        -- Protect against non-existant windows
        if DoesWindowExist(window) then
            oWindowSetShowing(window, show)
        end
    end

local firstLoad = true

-- Initialize window display states
PhantomLib.windowStates = {
    OpenPartySearchButton = true,
    PetWindow = true,
    MainAssist = true,
	ActionBarLockToggler = true,
	SocialWindowButton = true,
	OverheadMapArea = true,
	OverheadMapWorld = true,
	OverheadMapCity = true,
	OverheadMapZoom = true,
	OverheadMapScenario = true,
	OverheadMapMail = true,
	OverheadMapPins = true,
	OverheadMapFrame = true,
    OverheadMapRally = true,
}

PhantomLib.buffStates = {
    PlayerWindow = true,
    GroupWindow = true,
    TargetWindow = true,
}

PhantomLib.registerStates = {
    OpenPartySearchButton = false,
    MainAssist = true,

}

PhantomLib.eventStates = {
    PlayerBuffs = true,
    GroupBuffs = true,
    TargetBuffs = true,
}

local hooked = {}

function PhantomLib.InstallEA_Window_OverheadMapHooks()
	if not EA_Window_OverheadMap then return end
	if not hooked.EA_Window_OverheadMap then hooked.EA_Window_OverheadMap = {} end
	
	if not hooked.EA_Window_OverheadMap.UpdateScenarioButtons and EA_Window_OverheadMap.UpdateScenarioButtons then
		hooked.EA_Window_OverheadMap.UpdateScenarioButtons = EA_Window_OverheadMap.UpdateScenarioButtons
		EA_Window_OverheadMap.UpdateScenarioButtons =
			function(...)
				hooked.EA_Window_OverheadMap.UpdateScenarioButtons(...)
				if not PhantomLib.windowStates.OverheadMapScenario then
					WindowSetShowing("EA_Window_OverheadMapScenarioSummaryButton", false)
					WindowSetShowing("EA_Window_OverheadMapMapScenarioQueue", false)
					WindowSetShowing("EA_Window_OverheadMapScenarioGroupButton", false)
				end
			end
	end
	
	if not hooked.EA_Window_OverheadMap.UpdateScenarioQueueButton and EA_Window_OverheadMap.UpdateScenarioQueueButton then
		hooked.EA_Window_OverheadMap.UpdateScenarioQueueButton = EA_Window_OverheadMap.UpdateScenarioQueueButton
		EA_Window_OverheadMap.UpdateScenarioQueueButton =
			function(...)
				hooked.EA_Window_OverheadMap.UpdateScenarioQueueButton(...)
				if not PhantomLib.windowStates.OverheadMapScenario then
					WindowSetShowing("EA_Window_OverheadMapMapScenarioQueueGlowAnim", false)
				end
			end
	end
	
	if not hooked.EA_Window_OverheadMap.UpdateCityRating and EA_Window_OverheadMap.UpdateCityRating then
		hooked.EA_Window_OverheadMap.UpdateCityRating = EA_Window_OverheadMap.UpdateCityRating
		EA_Window_OverheadMap.UpdateCityRating =
			function(...)
				hooked.EA_Window_OverheadMap.UpdateCityRating(...)
				if not PhantomLib.windowStates.OverheadMapCity then
					WindowSetShowing("EA_Window_OverheadMapCityRating", false)
				end
			end
	end
	
	if not hooked.EA_Window_OverheadMap.UpdateMailIcon and EA_Window_OverheadMap.UpdateMailIcon then
		hooked.EA_Window_OverheadMap.UpdateMailIcon = EA_Window_OverheadMap.UpdateMailIcon
		EA_Window_OverheadMap.UpdateMailIcon =
			function(...)
				hooked.EA_Window_OverheadMap.UpdateMailIcon(...)
				if not PhantomLib.windowStates.OverheadMapMail then
					WindowSetShowing("EA_Window_OverheadMapMailNotificationIcon", false)
				end
			end
	end
	
end

function PhantomLib.InstallEA_ChatWindowHooks()
	if not EA_ChatWindow then return end
	if not hooked.EA_ChatWindow then hooked.EA_ChatWindow = {} end
	
	if not hooked.EA_ChatWindow.UpdateSocialWindowButton and EA_ChatWindow.UpdateSocialWindowButton then
		hooked.EA_ChatWindow.UpdateSocialWindowButton = EA_ChatWindow.UpdateSocialWindowButton
		EA_ChatWindow.UpdateSocialWindowButton =
			function(...)
				hooked.EA_ChatWindow.UpdateSocialWindowButton(...)
				if not PhantomLib.windowStates.SocialWindowButton then
					WindowSetShowing("ChatWindowSocialWindowButton", false)
				end
			end
	end
end

function PhantomLib.InstallActionBarClusterManagerHooks()
	if not ActionBarClusterManager then return end
	if not hooked.ActionBarClusterManager then hooked.ActionBarClusterManager = {} end
	
	if not hooked.ActionBarClusterManager.SpawnActionBars and ActionBarClusterManager.SpawnActionBars then
		hooked.ActionBarClusterManager.SpawnActionBars = ActionBarClusterManager.SpawnActionBars
		ActionBarClusterManager.SpawnActionBars =
			function(...)
				hooked.ActionBarClusterManager.SpawnActionBars(...)
				if not PhantomLib.windowStates.ActionBarLockToggler then
                    if QUICK_LOCK_NAME and DoesWindowExist(QUICK_LOCK_NAME) then
                        WindowSetShowing(QUICK_LOCK_NAME, false)
                    end
				end
			end
	end

end

function PhantomLib.InstallPlayerAssistHooks()
    if not EA_Button_PlayerAssist then return end
    if not hooked.EA_Button_PlayerAssist then hooked.EA_Button_PlayerAssist = {} end
    
    if not hooked.EA_Button_PlayerAssist.UpdateButtonVisibility and EA_Button_PlayerAssist.UpdateButtonVisibility then
        hooked.EA_Button_PlayerAssist.UpdateButtonVisibility = EA_Button_PlayerAssist.UpdateButtonVisibility
        EA_Button_PlayerAssist.UpdateButtonVisibility =
            function(self, ...)
                hooked.EA_Button_PlayerAssist.UpdateButtonVisibility(self, ...)
                if not PhantomLib.windowStates.MainAssist then
                    if DoesWindowExist("EA_AssistWindowMainAssist") then
                        WindowSetShowing("EA_AssistWindowMainAssist", false)
                    elseif DoesWindowExist("MainAssist") then
                        WindowSetShowing("MainAssist", false)
                    end
                end
            end
    end
end

function PhantomLib.InstallPetWindowHooks()
    if not PetWindow then return end
    if not hooked.PetWindow then hooked.PetWindow = {} end
    
    if not hooked.PetWindow.UpdatePet and PetWindow.UpdatePet then
        hooked.PetWindow.UpdatePet = PetWindow.UpdatePet
        PetWindow.UpdatePet =
            function(self, ...)
                hooked.PetWindow.UpdatePet(self, ...)
                if self.m_UnitFrame and not PhantomLib.windowStates.PetWindow then
                    self.m_UnitFrame:Show(false)
                end

            end
    end

end

function PhantomLib.InstallOpenPartyWindowHooks()
    if not OpenPartyWindow then return end
    if not hooked.OpenPartyWindow then hooked.OpenPartyWindow = {} end
    
    if not hooked.OpenPartyWindow.ShowOpenPartyButton and OpenPartyWindow.ShowOpenPartyButton then
        hooked.OpenPartyWindow.ShowOpenPartyButton = OpenPartyWindow.ShowOpenPartyButton
        OpenPartyWindow.ShowOpenPartyButton =
            function(...)
                hooked.OpenPartyWindow.ShowOpenPartyButton(...)
                if not PhantomLib.windowStates.OpenPartySearchButton then
                    WindowSetShowing("OpenPartySearchButton", false)
                end
            end
    end
end

function PhantomLib.InstallBuffHooks()
    if not BuffFrame then return end
    if not hooked.BuffFrame then hooked.BuffFrame = {} end
    
    if not hooked.BuffFrame.Show and BuffFrame.Show then
        hooked.BuffFrame.Show = BuffFrame.Show
        BuffFrame.Show =
            function(self, ...)
                if not self then return end
                local name = self:GetName()
                local alpha1,num1,alpha2 = strmatch(name, "([a-zA-Z]+)([0-9]*)([a-zA-Z]*)Buffs")
                if alpha1 == "Player" then
					if PhantomLib.buffStates.PlayerWindow then
                        hooked.BuffFrame.Show(self, ...)
                    else
                        hooked.BuffFrame.Show(self, false)
                    end
                elseif alpha1 == "Group" and num1 ~= "" then
					if PhantomLib.buffStates.GroupWindow then
                        hooked.BuffFrame.Show(self, ...)
                    else
                        hooked.BuffFrame.Show(self, false)
                    end
                elseif alpha1 == "TargetWindow" or alpha1 == "FriendlyTargetWindow" then
					if PhantomLib.buffStates.TargetWindow then
                        hooked.BuffFrame.Show(self, ...)
                    else
                        hooked.BuffFrame.Show(self, false)
                    end
                else
                    hooked.BuffFrame.Show(self, ...)
                end
            end
    end
end

function PhantomLib.InstallHooks()
    PhantomLib.InstallBuffHooks()
    PhantomLib.InstallOpenPartyWindowHooks()
    PhantomLib.InstallPlayerAssistHooks()
	PhantomLib.InstallActionBarClusterManagerHooks()
	PhantomLib.InstallEA_ChatWindowHooks()
	PhantomLib.InstallEA_Window_OverheadMapHooks()
    PhantomLib.InstallPetWindowHooks()
end

function PhantomLib.EnforceWindowStates()

    -- Open Party button
    if OpenPartyWindow then
        if PhantomLib.windowStates.OpenPartySearchButton then
            if OpenPartyWindow.UpdateOpenPartyButton then
                OpenPartyWindow.UpdateOpenPartyButton()
            end
        else
            WindowSetShowing("OpenPartySearchButton", false)
        end
    end

    -- Main Assist
    if PhantomLib.windowStates.MainAssist then
        if EA_Button_PlayerAssist and EA_Button_PlayerAssist.UpdateButtonVisibility then
            EA_Button_PlayerAssist.UpdateButtonVisibility()
        end
    else
        if DoesWindowExist("EA_AssistWindowMainAssist") then
            WindowSetShowing("EA_AssistWindowMainAssist", false)
        elseif DoesWindowExist("MainAssist") then
            WindowSetShowing("MainAssist", false)
        end
    end

    -- Action bar lock icon
    if QUICK_LOCK_NAME and DoesWindowExist(QUICK_LOCK_NAME) then
        WindowSetShowing(QUICK_LOCK_NAME, PhantomLib.windowStates.ActionBarLockToggler)
    end

    -- Social window button
    if DoesWindowExist("ChatWindowSocialWindowButton") then
        WindowSetShowing("ChatWindowSocialWindowButton", PhantomLib.windowStates.SocialWindowButton)
    end

    -- Overhead map elements
    WindowSetShowing("EA_Window_OverheadMapAreaNameBackground", PhantomLib.windowStates.OverheadMapArea)
    WindowSetShowing("EA_Window_OverheadMapAreaNameText", PhantomLib.windowStates.OverheadMapArea)
    WindowSetShowing("EA_Window_OverheadMapCityRating", PhantomLib.windowStates.OverheadMapCity)

    WindowSetShowing("EA_Window_OverheadMapZoomSlider", PhantomLib.windowStates.OverheadMapZoom)
    WindowSetShowing("EA_Window_OverheadMapZoomSliderBackground", PhantomLib.windowStates.OverheadMapZoom)

    WindowSetShowing("EA_Window_OverheadMapMapWorldMapButton", PhantomLib.windowStates.OverheadMapWorld)
    WindowSetShowing("EA_Window_OverheadMapMapFrame", PhantomLib.windowStates.OverheadMapFrame)
    WindowSetShowing("EA_Window_OverheadMapFilterMenuButton", PhantomLib.windowStates.OverheadMapPins)

    -- Safely force overhead map refresh
    if EA_Window_OverheadMap then
        if EA_Window_OverheadMap.UpdateScenarioButtons then
            EA_Window_OverheadMap.UpdateScenarioButtons()
        end
        if EA_Window_OverheadMap.UpdateScenarioQueueButton then
            EA_Window_OverheadMap.UpdateScenarioQueueButton()
        end
        if EA_Window_OverheadMap.UpdateMailIcon then
            EA_Window_OverheadMap.UpdateMailIcon()
        end
    end

    -- Rally button
    if DoesWindowExist("EA_Window_OverheadMapMapRallyCall") then
        WindowSetShowing("EA_Window_OverheadMapMapRallyCall", PhantomLib.windowStates.OverheadMapRally)
    end

    -- Pet window refresh (safe broadcast)
    if SystemData and SystemData.Events then
        BroadcastEvent(SystemData.Events.PLAYER_PET_UPDATED)
    end

    -- =========================
    -- Buff refresh (guarded)
    -- =========================

    if GroupWindow and GroupWindow.OnEffectsUpdated and GroupWindow.Buffs then
        for i = GameData.BuffTargetType.GROUP_MEMBER_START, GameData.BuffTargetType.GROUP_MEMBER_END do
            if GroupWindow.Buffs[i+1] then
                GroupWindow.OnEffectsUpdated(i, GetBuffs(i), true)
            end
        end
    end

    if PlayerWindow and PlayerWindow.OnEffectsUpdated then
        PlayerWindow.OnEffectsUpdated(GetBuffs(GameData.BuffTargetType.SELF), true)
    end

    if TargetWindow and TargetWindow.OnEffectsUpdated then
        TargetWindow.OnEffectsUpdated(
            GameData.BuffTargetType.TARGET_HOSTILE,
            GetBuffs(GameData.BuffTargetType.TARGET_HOSTILE),
            true
        )

        TargetWindow.OnEffectsUpdated(
            GameData.BuffTargetType.TARGET_FRIENDLY,
            GetBuffs(GameData.BuffTargetType.TARGET_FRIENDLY),
            true
        )
    end

end

function PhantomLib.EnforceRegisterStates()
    
    -- Open party search button
    if OpenPartyWindow then
        if PhantomLib.windowStates.OpenPartySearchButton and not PhantomLib.registerStates.OpenPartySearchButton then
            LayoutEditor.RegisterWindow("OpenPartySearchButton", L"Open Party Button", L"Open Party Search Button",
                false, false, false, nil)
            PhantomLib.registerStates.OpenPartySearchButton = true
        elseif not PhantomLib.windowStates.OpenPartySearchButton and PhantomLib.registerStates.OpenPartySearchButton then
            LayoutEditor.UnregisterWindow("OpenPartySearchButton")
            PhantomLib.registerStates.OpenPartySearchButton = false
        end
    end
    
    -- Main assist button
    local assistWin = nil
    if DoesWindowExist("EA_AssistWindowMainAssist") then
        assistWin = "EA_AssistWindowMainAssist"
    elseif DoesWindowExist("MainAssist") then
        assistWin = "MainAssist"
    end
    if assistWin then
        if PhantomLib.windowStates.MainAssist and not PhantomLib.registerStates.MainAssist then
            LayoutEditor.RegisterWindow(assistWin,
                        GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_ASSIST_WINDOW_NAME ),
                        GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_ASSIST_WINDOW_DESC ),
                        false, false,
                        true, nil )
            PhantomLib.registerStates.MainAssist = true
        elseif not PhantomLib.windowStates.MainAssist and PhantomLib.registerStates.MainAssist then
            LayoutEditor.UnregisterWindow(assistWin)
            PhantomLib.registerStates.MainAssist = false
        end
    end
end

function PhantomLib.EnforceEventStates()
	if PhantomLib.buffStates.PlayerWindow and not PhantomLib.eventStates.PlayerBuffs then
        WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_EFFECTS_UPDATED, "PlayerWindow.OnEffectsUpdated")
        PhantomLib.eventStates.PlayerBuffs = true
	elseif not (PhantomLib.buffStates.PlayerWindow) and PhantomLib.eventStates.PlayerBuffs then
        WindowUnregisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_EFFECTS_UPDATED)
        PhantomLib.eventStates.PlayerBuffs = false
    end
	
	if PhantomLib.buffStates.GroupWindow and not PhantomLib.eventStates.GroupBuffs then
        RegisterEventHandler(SystemData.Events.GROUP_EFFECTS_UPDATED, "GroupWindow.OnEffectsUpdated")
        PhantomLib.eventStates.GroupBuffs = true
		
	elseif not (PhantomLib.buffStates.GroupWindow) and PhantomLib.eventStates.GroupBuffs then
        UnregisterEventHandler(SystemData.Events.GROUP_EFFECTS_UPDATED, "GroupWindow.OnEffectsUpdated")
        PhantomLib.eventStates.GroupBuffs = false
    end
    
	if (PhantomLib.buffStates.TargetWindow) and not PhantomLib.eventStates.TargetBuffs then
        WindowRegisterEventHandler("TargetWindow", SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "TargetWindow.OnEffectsUpdated")
        PhantomLib.eventStates.TargetBuffs = true

	elseif not (PhantomLib.buffStates.TargetWindow) and PhantomLib.eventStates.TargetBuffs then
        WindowUnregisterEventHandler("TargetWindow", SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED)
        PhantomLib.eventStates.TargetBuffs = false
    end
    
end

function PhantomLib.SetWindowShowing(window)
    if window and PhantomLib.windowStates[window] ~= nil then
        PhantomLib.windowStates[window] = true
        PhantomLib._dirtyWindows = true
        PhantomLib._dirtyRegister = true
        return true
    end
end

function PhantomLib.SetWindowHidden(window)
    if window and PhantomLib.windowStates[window] ~= nil then
        PhantomLib.windowStates[window] = false
        PhantomLib._dirtyWindows = true
        PhantomLib._dirtyRegister = true
        return true
    end
    return false
end

function PhantomLib.SetBuffsShowing(window)
    if window and PhantomLib.buffStates[window] ~= nil then
        PhantomLib.buffStates[window] = true
        PhantomLib._dirtyBuffs = true
        return true
    end
    return false
end

function PhantomLib.SetBuffsHidden(window)
    if window and PhantomLib.buffStates[window] ~= nil then
        PhantomLib.buffStates[window] = false
        PhantomLib._dirtyBuffs = true
        return true
    end
end

function PhantomLib.Enforce()
    if PhantomLib._dirtyBuffs then
        PhantomLib.EnforceEventStates()
    end

    if PhantomLib._dirtyWindows then
        PhantomLib.EnforceWindowStates()
    end

    if PhantomLib._dirtyRegister then
        PhantomLib.EnforceRegisterStates()
    end

    PhantomLib._dirtyBuffs = false
    PhantomLib._dirtyWindows = false
    PhantomLib._dirtyRegister = false
end

function PhantomLib.OnLoad()
	if firstLoad then
		firstLoad = false
		PhantomLib.InstallHooks()
	end
	
    PhantomLib.Enforce()
end

-- Finally, if it hasn't already been registered, set up PhantomLib to perform its duties once everything has loaded.
if not PhantomLib.loadHandlerRegistered then
    RegisterEventHandler(SystemData.Events.LOADING_END, "PhantomLib.OnLoad")
    RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "PhantomLib.OnLoad")
    PhantomLib.loadHandlerRegistered = true
end

_G["PhantomLib"] = PhantomLib
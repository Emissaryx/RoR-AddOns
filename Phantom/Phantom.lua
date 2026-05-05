Phantom = {}

local PhantomLib = LibStub("PhantomLib")
local pairs = pairs
local ButtonGetPressedFlag   = ButtonGetPressedFlag
local ButtonSetPressedFlag   = ButtonSetPressedFlag
local ButtonSetCheckButtonFlag = ButtonSetCheckButtonFlag
local WindowSetShowing       = WindowSetShowing
local DoesWindowExist        = DoesWindowExist
local LabelSetText           = LabelSetText
local LabelSetWordWrap       = LabelSetWordWrap
local RegisterEventHandler   = RegisterEventHandler
local CreateWindow           = CreateWindow

local init = {
        windows = {
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
        },
        buffs = {
            PlayerWindow = true,
            GroupWindow = true,
            TargetWindow = true,
        },
    }

if not Phantom.Settings then
    Phantom.Settings = init
else
    Phantom.Settings.windows = Phantom.Settings.windows or {}
    Phantom.Settings.buffs   = Phantom.Settings.buffs   or {}

    for k, v in pairs(init.windows) do
        if Phantom.Settings.windows[k] == nil then
            Phantom.Settings.windows[k] = v
        end
    end

    for k, v in pairs(init.buffs) do
        if Phantom.Settings.buffs[k] == nil then
            Phantom.Settings.buffs[k] = v
        end
    end
end

function Phantom.CloseSettingsWindow()
    WindowSetShowing("PhantomSettings", false)
end

function Phantom.ImplementSettings()
    
    for k,v in pairs(Phantom.Settings.windows) do
        if v then
            PhantomLib.SetWindowShowing(k)
        else
            PhantomLib.SetWindowHidden(k)
        end
    end
    
    for k,v in pairs(Phantom.Settings.buffs) do
        if v then
            PhantomLib.SetBuffsShowing(k)
        else
            PhantomLib.SetBuffsHidden(k)
        end
    end
    
    PhantomLib.Enforce()
    
end

function Phantom.SaveSettings()
    local dirty = false

    local function SetWin(key, buttonName)
        local newVal = ButtonGetPressedFlag(buttonName)
        if Phantom.Settings.windows[key] ~= newVal then
            Phantom.Settings.windows[key] = newVal
            dirty = true
        end
    end

    local function SetBuff(key, buttonName)
        local newVal = ButtonGetPressedFlag(buttonName)
        if Phantom.Settings.buffs[key] ~= newVal then
            Phantom.Settings.buffs[key] = newVal
            dirty = true
        end
    end

    SetWin("PetWindow", "PhantomSettingsHidePet")
    SetWin("MainAssist", "PhantomSettingsHideMainAssist")
    SetWin("ActionBarLockToggler", "PhantomSettingsHideBarLock")
    SetWin("SocialWindowButton", "PhantomSettingsHideSocial")

    SetWin("OverheadMapArea", "PhantomSettingsHideMapArea")
    SetWin("OverheadMapWorld", "PhantomSettingsHideMapWorld")
    SetWin("OverheadMapCity", "PhantomSettingsHideMapCity")
    SetWin("OverheadMapZoom", "PhantomSettingsHideMapZoom")
    SetWin("OverheadMapScenario", "PhantomSettingsHideMapScen")
    SetWin("OverheadMapMail", "PhantomSettingsHideMapMail")
    SetWin("OverheadMapPins", "PhantomSettingsHideMapPins")
    SetWin("OverheadMapFrame", "PhantomSettingsHideMapFrame")
    SetWin("OverheadMapRally", "PhantomSettingsHideMapRally")

    SetBuff("PlayerWindow", "PhantomSettingsHidePlayerBuffs")
    SetBuff("GroupWindow", "PhantomSettingsHideGroupBuffs")
    SetBuff("TargetWindow", "PhantomSettingsHideTargetBuffs")

    if dirty then
        Phantom.ImplementSettings()
    end
end

function Phantom.PopulateWindow()
    ButtonSetPressedFlag("PhantomSettingsHidePet", Phantom.Settings.windows.PetWindow)
    ButtonSetPressedFlag("PhantomSettingsHideMainAssist", Phantom.Settings.windows.MainAssist)
	ButtonSetPressedFlag("PhantomSettingsHideBarLock", Phantom.Settings.windows.ActionBarLockToggler)
	ButtonSetPressedFlag("PhantomSettingsHideSocial", Phantom.Settings.windows.SocialWindowButton)
	ButtonSetPressedFlag("PhantomSettingsHideMapArea", Phantom.Settings.windows.OverheadMapArea)
	ButtonSetPressedFlag("PhantomSettingsHideMapWorld", Phantom.Settings.windows.OverheadMapWorld)
	ButtonSetPressedFlag("PhantomSettingsHideMapCity", Phantom.Settings.windows.OverheadMapCity)
	ButtonSetPressedFlag("PhantomSettingsHideMapZoom", Phantom.Settings.windows.OverheadMapZoom)
	ButtonSetPressedFlag("PhantomSettingsHideMapScen", Phantom.Settings.windows.OverheadMapScenario)
	ButtonSetPressedFlag("PhantomSettingsHideMapMail", Phantom.Settings.windows.OverheadMapMail)
	ButtonSetPressedFlag("PhantomSettingsHideMapPins", Phantom.Settings.windows.OverheadMapPins)
	ButtonSetPressedFlag("PhantomSettingsHideMapFrame", Phantom.Settings.windows.OverheadMapFrame)
    ButtonSetPressedFlag("PhantomSettingsHideMapRally", Phantom.Settings.windows.OverheadMapRally)

    if DoesWindowExist("EA_Window_OverheadMapMapRallyCall") then
        WindowSetShowing("PhantomSettingsHideMapRally", true)
        WindowSetShowing("PhantomSettingsHideMapRallyLabel", true)
    else
        WindowSetShowing("PhantomSettingsHideMapRally", false)
        WindowSetShowing("PhantomSettingsHideMapRallyLabel", false)
    end
    
	ButtonSetPressedFlag("PhantomSettingsHidePlayerBuffs", Phantom.Settings.buffs.PlayerWindow)
    ButtonSetPressedFlag("PhantomSettingsHideGroupBuffs", Phantom.Settings.buffs.GroupWindow)
    ButtonSetPressedFlag("PhantomSettingsHideTargetBuffs", Phantom.Settings.buffs.TargetWindow)
    
end

function Phantom.Show()
    WindowSetShowing("PhantomSettings", true)
end

function Phantom.OnLoad()    
    Phantom.ImplementSettings()
    
    if (LibSlash and (not LibSlash.IsSlashCmdRegistered("phantom"))) then
        LibSlash.RegisterSlashCmd("phantom", Phantom.Show)
    end
end

function Phantom.Initialize()
    if Phantom._initialized then return end
    Phantom._initialized = true
    CreateWindow("PhantomSettings", false)
    
    LabelSetText("PhantomSettingsTitleBarText", L"Phantom")
    
    LabelSetText("PhantomSettingsHidePlayerLabel", L"Self (Player) Frame")
    ButtonSetCheckButtonFlag("PhantomSettingsHidePlayerBuffs", true)
    
    LabelSetText("PhantomSettingsHideGroupLabel", L"Group Members")
    ButtonSetCheckButtonFlag("PhantomSettingsHideGroupBuffs", true)
    
    LabelSetText("PhantomSettingsHideTargetLabel", L"Target Frames")
    ButtonSetCheckButtonFlag("PhantomSettingsHideTargetBuffs", true)
    
    LabelSetText("PhantomSettingsHidePetLabel", L"Pet Status")
    ButtonSetCheckButtonFlag("PhantomSettingsHidePet", true)
    
    LabelSetText("PhantomSettingsHideMainAssistLabel", L"Main Assist Button")
    ButtonSetCheckButtonFlag("PhantomSettingsHideMainAssist", true)
    
	LabelSetText("PhantomSettingsHideBarLockLabel", L"Action Bar Lock Icon")
    ButtonSetCheckButtonFlag("PhantomSettingsHideBarLock", true)
	
	LabelSetText("PhantomSettingsHideSocialLabel", L"Social Window 'Heads'")
    ButtonSetCheckButtonFlag("PhantomSettingsHideSocial", true)

	LabelSetText("PhantomSettingsHideMapAreaLabel", L"Minimap Area Text")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapArea", true)
	
	LabelSetText("PhantomSettingsHideMapWorldLabel", L"Minimap Globe Button")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapWorld", true)
	
	LabelSetText("PhantomSettingsHideMapCityLabel", L"Minimap City Status")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapCity", true)
	
	LabelSetText("PhantomSettingsHideMapZoomLabel", L"Minimap Zoom Bar")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapZoom", true)
	
	LabelSetText("PhantomSettingsHideMapScenLabel", L"Minimap Scenario Buttons")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapScen", true)
	
	LabelSetText("PhantomSettingsHideMapMailLabel", L"Minimap Mail Icon")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapMail", true)
	
	LabelSetText("PhantomSettingsHideMapPinsLabel", L"Minimap Filters Pin")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapPins", true)
	
	LabelSetText("PhantomSettingsHideMapFrameLabel", L"Minimap Frame")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapFrame", true)
    
    LabelSetText("PhantomSettingsHideMapRallyLabel", L"Minimap Rally Button")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapRally", true)
	
    LabelSetWordWrap("PhantomSettingsInstructionsLabel", true)
    LabelSetText("PhantomSettingsInstructionsLabel",
        L"First checkbox is for window, second checkbox is for buffs.")
    
    LabelSetWordWrap("PhantomSettingsInstructions2Label", true)
    LabelSetText("PhantomSettingsInstructions2Label",
        L"Check a box to show that item, uncheck to hide. Settings save when window is closed.")
        
    RegisterEventHandler(SystemData.Events.LOADING_END, "Phantom.OnLoad")
    RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "Phantom.OnLoad")
end
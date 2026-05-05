scnoload = scnoload or {}

local firstLoad = true

local old_LoadBegin
local old_SetDisplayMode
local old_ToggleShowing

local RegisterEventHandler = RegisterEventHandler
local WindowSetShowing = WindowSetShowing
local BroadcastEvent = BroadcastEvent
local WindowUtils = WindowUtils

local function print(msg)
    EA_ChatWindow.Print(towstring(msg))
end

function scnoload.Initialize()
    RegisterEventHandler(SystemData.Events.LOADING_END, "scnoload.OnLoad")
    RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "scnoload.OnLoad")
end

function scnoload.OnLoad()
    if not firstLoad then return end
    firstLoad = false

    scnoload.Settings = scnoload.Settings or { mode = "sc", oldway = false }

    scnoload.SetHooks()

    LibSlash.RegisterSlashCmd("scnoload", function(input) scnoload.SlashHandler(input) end)
    if not LibSlash.IsSlashCmdRegistered("snl") then
        LibSlash.RegisterSlashCmd("snl", function(input) scnoload.SlashHandler(input) end)
    end
end

function scnoload.SlashHandler(input)
    local opt, val = input:match("([a-z0-9]+)[ ]?(.*)")

    if not opt or opt == "help" then
        print("")
        print("scnoload slash commands:")
        print("/snl help - displays this help")
        print("/snl mode (all/sc)")
        print("/snl oldway")
        return
    end

    if opt == "mode" then
        if val == "all" or val == "sc" then
            scnoload.Settings.mode = val
            print("scnoload mode set to " .. val)
        else
            print("scnoload mode must be 'all' or 'sc'")
        end
        return
    end

    if opt == "oldway" then
        scnoload.Settings.oldway = not scnoload.Settings.oldway
        print("scnoload oldway set to " .. tostring(scnoload.Settings.oldway))
    end
end

function scnoload.SetHooks()
    if old_LoadBegin then return end

    old_LoadBegin = EA_Window_LoadingScreen.OnLoadBegin
    EA_Window_LoadingScreen.OnLoadBegin = scnoload.HookedLoadBegin

    old_SetDisplayMode = ScenarioSummaryWindow.SetDisplayMode
    ScenarioSummaryWindow.SetDisplayMode = scnoload.HookedSetDisplayMode

    old_ToggleShowing = ScenarioSummaryWindow.ToggleShowing
    ScenarioSummaryWindow.ToggleShowing = scnoload.HookedToggleShowing
end

function scnoload.HookedLoadBegin()
    if GameData.ScenarioData.id == 0 and scnoload.Settings.mode ~= "all" then
        return old_LoadBegin()
    end

    local loadingData = LoadingScreenGetCurrentData()

    if GameData.Player.zone ~= loadingData.zoneId then
        return old_LoadBegin()
    end

    if not scnoload.Settings.oldway then
        old_LoadBegin()
        WindowSetShowing("EA_Window_LoadingScreen", false)
        BroadcastEvent(SystemData.Events.ENTER_WORLD)
    else
        BroadcastEvent(SystemData.Events.ENTER_WORLD)
    end
end

function scnoload.HookedSetDisplayMode(mode)
    old_SetDisplayMode(mode)

    local shouldShow =
        GameData.ScenarioData.mode == GameData.ScenarioMode.POST_MODE and
        ScenarioSummaryWindow.currentMode == ScenarioSummaryWindow.MODE_POST_MODE

    if shouldShow then
        WindowSetShowing("ScenarioSummaryWindowClose", true)
    end
end

function scnoload.HookedToggleShowing()
    old_ToggleShowing()

    if GameData.Player.isInScenario or WindowGetShowing("ScenarioSummaryWindow") then
        local shouldShow =
            GameData.ScenarioData.mode == GameData.ScenarioMode.POST_MODE and
            ScenarioSummaryWindow.currentMode == ScenarioSummaryWindow.MODE_POST_MODE

        if shouldShow then
            WindowUtils.ToggleShowing("ScenarioSummaryWindow")
        end
    end
end

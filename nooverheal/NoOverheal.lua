-- v1.40
-- text / notext
-- lock state is saved

----------------------------------------------------------------------------------------------
-- Main addon table
----------------------------------------------------------------------------------------------
NoOverheal = NoOverheal or {
    TimeLeft = 0,
    Time = 0,
}

-- Update throttle interval in seconds (performance control)
local UPDATE_INTERVAL = 0.1

-- Localize globals for performance
local CancelSpell          = CancelSpell
local LabelSetText         = LabelSetText
local LabelSetTextColor    = LabelSetTextColor
local WindowSetMovable     = WindowSetMovable
local WindowGetMovable     = WindowGetMovable
local towstring            = towstring
local WStringToString      = WStringToString
local EA_ChatWindow_Print  = EA_ChatWindow.Print
local IsWarBandActive      = IsWarBandActive
local WindowSetShowing     = WindowSetShowing

local strlen = string.len
local strsub = string.sub

----------------------------------------------------------------------------------------------
-- Career table
----------------------------------------------------------------------------------------------
local HEALER_LINES = {
    [GameData.CareerLine.RUNE_PRIEST]    = true,
    [GameData.CareerLine.WARRIOR_PRIEST] = true,
    [GameData.CareerLine.ARCHMAGE]       = true,
    [GameData.CareerLine.SHAMAN]         = true,
    [GameData.CareerLine.ZEALOT]         = true,
    [GameData.CareerLine.DISCIPLE]       = true,
}

----------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------
function NoOverheal.IsHealerCareer()

    if not GameData
       or not GameData.Player
       or not GameData.Player.career
       or not GameData.Player.career.line
    then
        return false
    end

    return HEALER_LINES[GameData.Player.career.line] == true
end

function NoOverheal.OnInitialize()

    -- Always create the window
    CreateWindow("NoOverheal_Window", true)

    -- Saved vars
    local save = NoOverheal.save
    if not save then
        save = {
            MaxHealth = 99,
            active    = true,
            chattext  = true,
            locked    = false,
        }
        NoOverheal.save = save
    end

    -- Register window
    LayoutEditor.RegisterWindow(
        "NoOverheal_Window",
        L"NoOverheal",
        L"main",
        true, true, true, nil
    )

    -- Visual setup
    WindowSetFontAlpha("NoOverheal_Window", 0.5)
    WindowSetFontAlpha("NoOverheal_WindowText", 1.0)

    LabelSetText("NoOverheal_WindowText", NoOverheal.ADDONNAME)
    LabelSetTextColor("NoOverheal_WindowText", 255, 0, 20)

    LabelSetText("NoOverheal_WindowNameText", NoOverheal.NOTARGET)
    LabelSetTextColor("NoOverheal_WindowNameText", 140, 140, 140)

    -- Events always registered
    RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "NoOverheal.OnPlayerBeginCast")
    RegisterEventHandler(SystemData.Events.PLAYER_END_CAST,   "NoOverheal.OnPlayerEndCast")
    RegisterEventHandler(SystemData.Events.SPELL_CAST_CANCEL, "NoOverheal.OnCancelSpell")

    NoOverheal._active = true

    NoOverheal.SetWindowLockState()
    NoOverheal.SlashHandlerInit()

    EA_ChatWindow_Print(NoOverheal.GREETINGS)
end

function NoOverheal.OnShutdown()

    if not NoOverheal._active then return end

    UnregisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "NoOverheal.OnPlayerBeginCast")
    UnregisterEventHandler(SystemData.Events.PLAYER_END_CAST,   "NoOverheal.OnPlayerEndCast")
    UnregisterEventHandler(SystemData.Events.SPELL_CAST_CANCEL, "NoOverheal.OnCancelSpell")
end

function NoOverheal.CreateTooltip(window, text)
    if not window or not text then return end
    Tooltips.CreateTextOnlyTooltip(window, text)
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_TOP)
end

function NoOverheal.OnUpdate(elapsedTime)

    local t = NoOverheal

    -- Hard safety init
    if t.Time == nil then t.Time = 0 end
    if t.TimeLeft == nil then t.TimeLeft = 0 end

    -- Career gating here, not in OnInitialize
    if NoOverheal.IsHealerCareer() then
        WindowSetShowing("NoOverheal_Window", true)
    else
        WindowSetShowing("NoOverheal_Window", false)
        return
    end

    t.Time = t.Time + elapsedTime
    t.TimeLeft = t.TimeLeft - elapsedTime

    if t.TimeLeft > 0 then return end

    t.TimeLeft = UPDATE_INTERVAL
    t.UpdateHealthArray()
end

function NoOverheal.OnLButtonUp()
    -- Cancel only when locked
    if not WindowGetMovable("NoOverheal_Window") then
        CancelSpell()
    end
end

function NoOverheal.OnMButtonUp()
    NoOverheal.save.locked = not NoOverheal.save.locked
    NoOverheal.SetWindowLockState()
end

function NoOverheal.OnRButtonUp()

    local save = NoOverheal.save
    save.active = not save.active

    if save.active then
        EA_ChatWindow_Print(NoOverheal.ON)
    else
        EA_ChatWindow_Print(NoOverheal.OFF)
    end
end

function NoOverheal.OnMouseOver()

    LabelSetText("NoOverheal_WindowText", NoOverheal.ADDONNAME)
    LabelSetTextColor("NoOverheal_WindowText", 200, 10, 40)

    NoOverheal.CreateTooltip("NoOverheal_Window", NoOverheal.TOOLTIPTEXT)
end

function NoOverheal.OnMouseOverEnd()

    LabelSetText("NoOverheal_WindowText", NoOverheal.ADDONNAME)
    LabelSetTextColor("NoOverheal_WindowText", 255, 0, 20)
end

function NoOverheal.OnPlayerBeginCast(actionId, isChannel, desiredCastTime, averageLatency)

    NoOverheal.curHealName = nil
    NoOverheal.curHealNameTrimmed = nil

    local abilityData = Player.GetAbilityData(actionId)
    if not abilityData 
       or not abilityData.isHealing
       or abilityData.targetType ~= 2
       or desiredCastTime <= 0.5
    then
        return
    end

    local name = TargetInfo:UnitName("selffriendlytarget")
    if not name or name == L"" then
        name = GameData.Player.name
    end

    NoOverheal.curHealName = name
    NoOverheal.curHealNameTrimmed = NoOverheal.TrimName(name)

    LabelSetText("NoOverheal_WindowNameText", name)
    LabelSetTextColor("NoOverheal_WindowNameText", 0, 255, 0)
end


function NoOverheal.OnPlayerEndCast()

    NoOverheal.curHealName = nil
    NoOverheal.curHealNameTrimmed = nil

    LabelSetText("NoOverheal_WindowNameText", NoOverheal.NOTARGET)
    LabelSetTextColor("NoOverheal_WindowNameText", 140, 140, 140)
end


function NoOverheal.OnCancelSpell()

    NoOverheal.curHealName = nil
    NoOverheal.curHealNameTrimmed = nil

    LabelSetTextColor("NoOverheal_WindowNameText", 255, 255, 255)
end

function NoOverheal.UpdateHealthArray()

    -- Bail early if nothing to do
    if not NoOverheal.curHealName or not NoOverheal.save.active then
        return
    end

    local Check = NoOverheal.CheckOverheal

    -- Warband (24-man)
    if IsWarBandActive() then
        local raidgroups = GetBattlegroupMemberData()

        for groupIndex = 1, 4 do
            local group = raidgroups[groupIndex]
            if group and group.players then
                for memberIndex = 1, 6 do
                    local player = group.players[memberIndex]
                    if player then
                        Check(player.name, player.healthPercent)
                    end
                end
            end
        end

    else
        -- Self
        local max = GameData.Player.hitPoints.maximum
        if max and max > 0 then
            local hp = GameData.Player.hitPoints.current * 100 / max
            Check(GameData.Player.name, hp)
        end

        -- Group members
        for i = 1, 5 do
            if GroupWindow.IsMemberValid(i) then
                local hp = select(1, GetGroupMemberStatusData(i))
                Check(GroupWindow.groupData[i].name, hp)
            end
        end
    end

    -- Friendly target (always last)
    local name = TargetInfo:UnitName("selffriendlytarget")
    if name and name ~= L"" then
        local hp = TargetInfo:UnitHealth("selffriendlytarget")
        Check(name, hp)
    end
end

function NoOverheal.CheckOverheal(name, health)

    local cur = NoOverheal.curHealName
    if not cur or not NoOverheal.save.active or not name or not health then
        return
    end

    local targetName = NoOverheal.curHealNameTrimmed or NoOverheal.TrimName(cur)
    local checkName  = NoOverheal.TrimName(name)

    if targetName ~= checkName then
        return
    end

    local maxHealth = NoOverheal.save.MaxHealth
    if health >= maxHealth then
        if NoOverheal.save.chattext then
            EA_ChatWindow_Print(NoOverheal.PREVENT .. cur)
        end
        CancelSpell()
        return
    end

    LabelSetText(
        "NoOverheal_WindowNameText",
        L"" .. cur .. L" (" .. health .. L")"
    )
end


function NoOverheal.TrimName(name)

    if not name then return L"" end

    if type(name) == "string" then
        name = towstring(name)
    end

    local s = WStringToString(name)
    if not s or s == "" then return L"" end

    local len = strlen(s)
    if len < 2 then return name end

    if strsub(s, len - 1, len - 1) == "^" then
        return towstring(strsub(s, 1, len - 2))
    end

    return name
end


function NoOverheal.SetWindowLockState()

    local locked = NoOverheal.save.locked

    WindowSetMovable("NoOverheal_Window", not locked)

    if locked then
        EA_ChatWindow_Print(NoOverheal.ADDONNAME .. L": " .. NoOverheal.LOCKED)
    else
        EA_ChatWindow_Print(NoOverheal.ADDONNAME .. L": " .. NoOverheal.MOVEABLE)
    end
end







if not HealAll then HealAll = {} end

local healingInProgress = false

local function SafePrint(msg)
    if EA_ChatWindow and EA_ChatWindow.Print then
        EA_ChatWindow.Print(msg)
    end
end

function HealAll.Initialize()
    if HealAll._initialized then return end
    HealAll._initialized = true

    RegisterEventHandler(SystemData.Events.INTERACT_SHOW_HEALER, "HealAll.Heal")

    SafePrint(L"<LINK data=\"0\" text=\"[HealAll]\" color=\"50,255,10\"> Addon initialized.")
end

function HealAll.Heal()
    if healingInProgress then return end
    healingInProgress = true

    local w = EA_Window_InteractionHealer
    if not w then
        healingInProgress = false
        return
    end

    WindowSetShowing("EA_Window_InteractionHealer", false)

    local penalties = tonumber(w.penaltyCount) or 0
    if penalties == 0 then
        healingInProgress = false
        return
    end

    local cost = tonumber(w.costToRemoveSinglePenalty) or 0
    local totalCost = MoneyFrame.FormatMoneyString(penalties * cost)

    pcall(function()
        w.HealAllPenalties()
    end)

    if totalCost and totalCost ~= L"" then
        SafePrint(L"<LINK data=\"0\" text=\"[HealAll]\" color=\"50,255,10\"> Healer services cost you " .. totalCost .. L".")
    end

    healingInProgress = false
end

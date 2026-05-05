----------------------------------------------------------------------------------------------
-- Slash handler (self-safe)
----------------------------------------------------------------------------------------------

NoOverheal = NoOverheal or {}

----------------------------------------------------------------------------------------------
-- Slash initialization
----------------------------------------------------------------------------------------------
function NoOverheal.SlashHandlerInit()
    NoOverheal.original_OnKeyEnter = EA_ChatWindow.OnKeyEnter
    EA_ChatWindow.OnKeyEnter = NoOverheal.OnKeyEnter
end


----------------------------------------------------------------------------------------------
-- Intercept chat input
----------------------------------------------------------------------------------------------
function NoOverheal.OnKeyEnter(...)

    local text = EA_TextEntryGroupEntryBoxTextInput.Text
    if not text or text == L"" then
        return NoOverheal.original_OnKeyEnter(...)
    end

    local cmd, args = text:match(L"^/([%w]+)%s*(.*)")
    if cmd == L"noo" then
        NoOverheal.HandleSlash(args)
        EA_TextEntryGroupEntryBoxTextInput.Text = L""
        return
    end

    return NoOverheal.original_OnKeyEnter(...)
end


----------------------------------------------------------------------------------------------
-- Slash command handler
----------------------------------------------------------------------------------------------
function NoOverheal.HandleSlash(args)

    local save = NoOverheal.save

    if args == L"on" or args == L"an" then
        save.active = true
        EA_ChatWindow_Print(NoOverheal.ON)

    elseif args == L"off" or args == L"aus" then
        save.active = false
        EA_ChatWindow_Print(NoOverheal.OFF)

    elseif args == L"lock" then
        save.locked = true
        NoOverheal.SetWindowLockState()

    elseif args == L"unlock" then
        save.locked = false
        NoOverheal.SetWindowLockState()

    elseif args == L"text" then
        save.chattext = true
        EA_ChatWindow_Print(NoOverheal.ADDONNAME .. L": " .. NoOverheal.TEXT)

    elseif args == L"notext" then
        save.chattext = false
        EA_ChatWindow_Print(NoOverheal.ADDONNAME .. L": " .. NoOverheal.NOTEXT)

    else
        EA_ChatWindow_Print(NoOverheal.HELPHEADLINE)
        EA_ChatWindow_Print(NoOverheal.HELPON)
        EA_ChatWindow_Print(NoOverheal.HELPOFF)
        EA_ChatWindow_Print(NoOverheal.HELPLOCK)
        EA_ChatWindow_Print(NoOverheal.HELPUNLOCK)
        EA_ChatWindow_Print(NoOverheal.HELPTEXT)
        EA_ChatWindow_Print(NoOverheal.HELPNOTEXT)
        EA_ChatWindow_Print(
            L"(lock=" .. towstring(booltostring(save.locked)) .. L")"
        )
    end
end

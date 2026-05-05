ClickSoundSuppressor = ClickSoundSuppressor or {}

local RegisterEventHandler = RegisterEventHandler

function ClickSoundSuppressor.OnInit()
    RegisterEventHandler(SystemData.Events.ENTER_WORLD, "ClickSoundSuppressor.DisableClickSound")
    RegisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "ClickSoundSuppressor.DisableClickSound")
    RegisterEventHandler(SystemData.Events.LOADING_END, "ClickSoundSuppressor.DisableClickSound")
end

function ClickSoundSuppressor.DisableClickSound()
    if Sound.BUTTON_CLICK ~= 0 then
        Sound.BUTTON_CLICK = 0
    end
end

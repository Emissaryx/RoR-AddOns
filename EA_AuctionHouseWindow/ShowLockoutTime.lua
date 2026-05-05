ShowLockoutTime = {}

function ShowLockoutTime.Initialize()
    -- Register the slash command
    LibSlash.RegisterSlashCmd("showlockout", ShowLockoutTime.DisplayLockoutTime)
    -- You can add more initialization logic here if needed in the future
end

function ShowLockoutTime.DisplayLockoutTime()
    if GameData and GameData.Account and GameData.Account.CharacterCreation and GameData.Account.CharacterCreation.RemainingLockoutTime then
        local timeLeft = GameData.Account.CharacterCreation.RemainingLockoutTime
        local formattedTime = TimeUtils.FormatTimeCondensed(timeLeft)
        local message = "Lockout Time Remaining: " .. formattedTime

        TextLogAddEntry("Chat", SystemData.ChatLogFilters.SYSTEM, towstring(message))
    else
        TextLogAddEntry("Chat", SystemData.ChatLogFilters.SYSTEM, towstring("No lockout time available."))
    end
end
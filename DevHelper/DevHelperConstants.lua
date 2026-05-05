if not DevHelper then DevHelper = {} end  -- Initialize the DevHelper table if not already defined

-- Define colors for messages (in alphabetical order by color name)
DevHelper.Colors = {
    black = {0, 0, 0},                    -- Black
    blue = {60, 120, 200},                -- Blue
    bright_yellow = {255, 255, 0},        -- Bright Yellow
    brown = {165, 42, 42},                -- Brown
    chartreuse = {127, 255, 0},           -- Chartreuse
    cyan = {0, 255, 255},                 -- Cyan
    dark_green = {0, 100, 0},             -- Dark Green
    deep_sky_blue = {0, 191, 255},        -- Deep Sky Blue
    electric_blue = {125, 249, 255},      -- Electric Blue
    gold = {255, 215, 0},                 -- Gold
    grey = {150, 150, 150},               -- Grey
    green = {0, 150, 50},                 -- Green
    hot_pink = {255, 20, 147},            -- Hot Pink
    light_blue = {173, 216, 230},         -- Light Blue
    light_green = {144, 238, 144},        -- Light Green
    lime = {0, 255, 0},                   -- Bright Lime Green
    magenta = {255, 0, 255},              -- Magenta
    maroon = {128, 0, 0},                 -- Maroon
    navy = {0, 0, 128},                   -- Navy
    olive = {128, 128, 0},                -- Olive
    orange = {255, 165, 0},               -- Orange
    orange_red = {255, 69, 0},            -- Bright Orange-Red
    pink = {255, 105, 180},               -- Pink
    purple = {128, 0, 128},               -- Purple
    red = {240, 60, 60},                  -- Red
    silver = {192, 192, 192},             -- Silver
    teal = {0, 128, 128},                 -- Teal
    turquoise = {64, 224, 208},           -- Turquoise
    vivid_violet = {238, 130, 238},       -- Vivid Violet
    white = {255, 255, 255},              -- White
    yellow = {255, 170, 70}               -- Yellow
}

-- Default settings for DevHelper, reflecting the SavedVariables structure
DevHelper.DefaultSettings = {
    settingsVersion = 1,                  -- Settings version for upgrade compatibility
    messageStart = "<icon49>",            -- Icon to prepend to messages
    messageEnd = "<icon49>",              -- Icon to append to messages
    textColor = "white",                  -- Default color for text
    windowSize = 0.65,                    -- Scaling factor for the DevHelper window size
    showLfgIcons = false,                 -- LFG icons disabled by default
    messages = {                          -- Define available commands and messages for UI

        {
            message = "nil",               -- Placeholder message
            type = "other",                -- Message type
            messageColor = "olive",        -- Text color for message
            label = "Dev",                 -- Button label
            isNotEnabled = false,          -- Button is enabled by default
            labelColor = "olive",          -- Label color for button
            submenu = "None",              -- No submenu for this button
        },
        
        {
            message = "ability cooldownreset", -- Command to reset ability cooldown
            type = "other",                    -- Message type
            messageColor = "olive",            -- Text color for message
            label = "AB CD Reset",             -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "olive",              -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "gps",                   -- Command to show GPS
            type = "other",                    -- Message type
            messageColor = "olive",            -- Text color for message
            label = "GPS",                     -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "olive",              -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "info",                  -- Command to show info
            type = "other",                    -- Message type
            messageColor = "olive",            -- Text color for message
            label = "Info",                    -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "olive",              -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "nil",                   -- Placeholder message
            type = "other",                    -- Message type
            messageColor = "magenta",          -- Text color for message
            label = "GM",                      -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "magenta",            -- Label color for button
            submenu = "None",                  -- No submenu for this button
        },
        
        {
            message = "gm hide",               -- Command to hide GM status
            type = "other",                    -- Message type
            messageColor = "magenta",          -- Text color for message
            label = "GM Hide",                 -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "magenta",            -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "gm togglerank",         -- Command to toggle GM rank
            type = "other",                    -- Message type
            messageColor = "magenta",          -- Text color for message
            label = "GM Toggle",               -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "magenta",            -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "nil",                   -- Placeholder message
            type = "other",                    -- Message type
            messageColor = "light_green",      -- Text color for message
            label = "NPC/OBJ",                 -- Button label for NPC/Objects
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "light_green",        -- Label color for button
            submenu = "None",                  -- No submenu for this button
        },
        
        {
            message = "npc move",              -- Command to move NPC
            type = "other",                    -- Message type
            messageColor = "light_green",      -- Text color for message
            label = "NPC Move",                -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "light_green",        -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "npc rem 1",             -- Command to remove NPC
            type = "other",                    -- Message type
            messageColor = "light_green",      -- Text color for message
            label = "NPC Remove",              -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "light_green",        -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "go move",               -- Command to move GameObject (GO)
            type = "other",                    -- Message type
            messageColor = "light_green",      -- Text color for message
            label = "GO Move",                 -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "light_green",        -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "go remove 1",           -- Command to remove GameObject (GO)
            type = "other",                    -- Message type
            messageColor = "light_green",      -- Text color for message
            label = "GO Remove",               -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "light_green",        -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "nil",                   -- Placeholder message
            type = "other",                    -- Message type
            messageColor = "cyan",             -- Text color for message
            label = "PQ Cmds",                 -- Button label for PQ commands
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "cyan",               -- Label color for button
            submenu = "None",                  -- No submenu for this button
        },
        
        {
            message = "pq clear",              -- Command to clear PQ
            type = "other",                    -- Message type
            messageColor = "cyan",             -- Text color for message
            label = "PQ Clear",                -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "cyan",               -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "pq next",               -- Command to go to next PQ
            type = "other",                    -- Message type
            messageColor = "cyan",             -- Text color for message
            label = "PQ Next",                 -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "cyan",               -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "pq reload",             -- Command to reload PQ
            type = "other",                    -- Message type
            messageColor = "cyan",             -- Text color for message
            label = "PQ Reload",               -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "cyan",               -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "pq reset",              -- Command to reset PQ
            type = "other",                    -- Message type
            messageColor = "cyan",             -- Text color for message
            label = "PQ Reset",                -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "cyan",               -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "pq status",             -- Command to show PQ status
            type = "other",                    -- Message type
            messageColor = "cyan",             -- Text color for message
            label = "PQ Status",               -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "cyan",               -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "nil",                   -- Placeholder message
            type = "other",                    -- Message type
            messageColor = "gold",             -- Text color for message
            label = "Reload",                  -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "gold",               -- Label color for button
            submenu = "None",                  -- No submenu for this button
        },
        
        {
            message = "ability reload",        -- Command to reload ability
            type = "other",                    -- Message type
            messageColor = "gold",             -- Text color for message
            label = "Ability",                 -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "gold",               -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "chapter reload",        -- Command to reload chapter
            type = "other",                    -- Message type
            messageColor = "gold",             -- Text color for message
            label = "Chapter",                 -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "gold",               -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "go reload",             -- Command to reload GameObject (GO)
            type = "other",                    -- Message type
            messageColor = "gold",             -- Text color for message
            label = "GO",                      -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "gold",               -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "item reload",           -- Command to reload item
            type = "other",                    -- Message type
            messageColor = "gold",             -- Text color for message
            label = "Item",                    -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "gold",               -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "npc reload",            -- Command to reload NPC
            type = "other",                    -- Message type
            messageColor = "gold",             -- Text color for message
            label = "NPC",                     -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "gold",               -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "nil",                   -- Placeholder message
            type = "other",                    -- Message type
            messageColor = "orange_red",       -- Text color for message
            label = "Script",                  -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "orange_red",         -- Label color for button
            submenu = "None",                  -- No submenu for this button
        },
        
        {
            message = "script reload",         -- Command to reload script
            type = "other",                    -- Message type
            messageColor = "orange_red",       -- Text color for message
            label = "Reload",                  -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "orange_red",         -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "script regionReload",   -- Command to reload script region
            type = "other",                    -- Message type
            messageColor = "orange_red",       -- Text color for message
            label = "Region",                  -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "orange_red",         -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "nil",                   -- Placeholder message
            type = "other",                    -- Message type
            messageColor = "hot_pink",         -- Text color for message
            label = "Server",                  -- Button label for server commands
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "hot_pink",           -- Label color for button
            submenu = "None",                  -- No submenu for this button
        },
        
        {
            message = "server reboot now",     -- Command to reboot server
            type = "other",                    -- Message type
            messageColor = "chartreuse",       -- Text color for message
            label = "Reboot",                  -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "hot_pink",           -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "nil",                   -- Placeholder message
            type = "other",                    -- Message type
            messageColor = "green",            -- Text color for message
            label = "Speed",                   -- Button label for speed commands
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "green",              -- Label color for button
            submenu = "None",                  -- No submenu for this button
        },
        
        {
            message = "player speed 1",        -- Command to set player speed to 1
            type = "other",                    -- Message type
            messageColor = "green",            -- Text color for message
            label = "1",                       -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "green",              -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "player speed 40",       -- Command to set player speed to 40
            type = "other",                    -- Message type
            messageColor = "green",            -- Text color for message
            label = "40",                      -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "green",              -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "player speed 255",      -- Command to set player speed to 255
            type = "other",                    -- Message type
            messageColor = "green",            -- Text color for message
            label = "255",                     -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "green",              -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "player speed 510",      -- Command to set player speed to 510
            type = "other",                    -- Message type
            messageColor = "green",            -- Text color for message
            label = "510",                     -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "green",              -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "player speed 765",      -- Command to set player speed to 765
            type = "other",                    -- Message type
            messageColor = "green",            -- Text color for message
            label = "765",                     -- Button label
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "green",              -- Label color for button
            submenu = "Parent",                -- Appears under a parent submenu
        },
        
        {
            message = "nil",                   -- Placeholder message
            type = "other",                    -- Message type
            messageColor = "blue",             -- Text color for message
            label = "Teleport",                -- Button label for teleport commands
            isNotEnabled = false,              -- Button is enabled by default
            labelColor = "blue",               -- Label color for button
            submenu = "None",                  -- No submenu for this button
        },
        
        {
            message = "teleport map 162 124138 131932 12715", -- Command to teleport to Altdorf
            type = "other",                                    -- Message type
            messageColor = "blue",                             -- Text color for message
            label = "Altdorf",                                 -- Button label
            labelColor = "blue",                               -- Label color for button
            submenu = "Parent",                                -- Appears under a parent submenu
        },
        
        {
            message = "teleport map 294 1078881 967821 16384", -- Command to teleport to Emissary Test
            type = "other",                                    -- Message type
            messageColor = "blue",                             -- Text color for message
            label = "Emissary Test",                           -- Button label
            isNotEnabled = false,                              -- Button is enabled by default
            labelColor = "blue",                               -- Label color for button
            submenu = "Parent",                                -- Appears under a parent submenu
        },
        
        {
            message = "teleport map 161 440232 135835 17555", -- Command to teleport to Inevitable City
            type = "other",                                   -- Message type
            messageColor = "blue",                            -- Text color for message
            label = "Inevitable City",                        -- Button label
            isNotEnabled = false,                             -- Button is enabled by default
            labelColor = "blue",                              -- Label color for button
            submenu = "Parent",                               -- Appears under a parent submenu
        },
        
        {
            message = "teleport map 175 1531984 109464 5144", -- Command to teleport to Moon
            type = "other",                                   -- Message type
            messageColor = "blue",                            -- Text color for message
            label = "Moon",                                   -- Button label
            isNotEnabled = false,                             -- Button is enabled by default
            labelColor = "blue",                              -- Label color for button
            submenu = "Parent",                               -- Appears under a parent submenu
        },
        
        {
            message = "kill",                                 -- Command to kill target
            type = "Normal",                                  -- Message type
            messageColor = "yellow",                          -- Text color for message
            label = "Kill",                                   -- Button label
            labelColor = "yellow",                            -- Label color for button
            submenu = "None",                                 -- No submenu for this button
        },
        
        {
            message = "revive",                               -- Command to revive target
            type = "Normal",                                  -- Message type
            messageColor = "yellow",                          -- Text color for message
            label = "Revive",                                 -- Button label
            labelColor = "yellow",                            -- Label color for button
            submenu = "None",                                 -- No submenu for this button
        },
        
        {
            message = "fly 1",                                -- Command to enable flight
            type = "Normal",                                  -- Message type
            messageColor = "red",                             -- Text color for message
            label = "Fly",                                    -- Button label
            labelColor = "red",                               -- Label color for button
            submenu = "None",                                 -- No submenu for this button
        },
        
        {
            message = "invincible",                           -- Command to make target invincible
            type = "Normal",                                  -- Message type
            messageColor = "red",                             -- Text color for message
            label = "Invincible",                             -- Button label
            labelColor = "red",                               -- Label color for button
            submenu = "None",                                 -- No submenu for this button
        },
        
        {
            message = "shroud",                               -- Command to enable shroud (invisibility)
            type = "Normal",                                  -- Message type
            messageColor = "red",                             -- Text color for message
            label = "Shroud",                                 -- Button label
            labelColor = "red",                               -- Label color for button
            submenu = "None",                                 -- No submenu for this button
        },
    },
}
-- Define message types for commands
DevHelper.messageTypes = {
    "Normal",    -- Normal command type
    "other",     -- Other command type
}

-- Define template settings for UI layout
DevHelper.Templates = {
    [1] = {
        titleWidth = 254,          -- Width of the window title
        buttonWidth = 126,         -- Button width
        buttonHeight = 54,         -- Button height
        buttonsPerRow = 8,         -- Number of buttons per row
    },
    [2] = {
        titleWidth = 400,          -- Alternative template: larger window title
        buttonWidth = 220,         -- Larger buttons
        buttonHeight = 40,         -- Smaller button height
        buttonsPerRow = 14,        -- More buttons per row
    },    
}

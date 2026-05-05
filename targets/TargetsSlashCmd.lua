-- TargetsSlashCmd.lua (Allies-only, max 16)

TargetsSlashCmd = {}

-- Locals
local table_remove = table.remove
local table_concat = table.concat
local math_min     = math.min
local math_max     = math.max
local math_abs     = math.abs
local pairs        = pairs
local ipairs       = ipairs
local tostring     = tostring
local tonumber     = tonumber
local towstring    = towstring

function TargetsSlashCmd.register()
    TargetsSlashCmd.list = {
        help    = { f = TargetsSlashCmd.cmd_usage,          argc = 0, help = "- show command list" },
        toggle  = { f = TargetsSlashCmd.cmd_toggle,         argc = 0, help = "- toggle allies list" },
        max     = { f = TargetsSlashCmd.cmd_maxplayers,     argc = 1, help = "<count> - set max allies (1 to 16)" },
        sorted  = { f = TargetsSlashCmd.cmd_toggle_sort,    argc = 0, help = "- toggle player sorting" },
        addfav  = { f = TargetsSlashCmd.cmd_add_favorites,  argc = 1, help = "<name> - add player to favorites" },
        delfav  = { f = TargetsSlashCmd.cmd_del_favorites,  argc = 1, help = "<name> - remove player from favorites" },
        listfav = { f = TargetsSlashCmd.cmd_list_favorites, argc = 0, help = "- list all favorite players" },
        clearfav= { f = TargetsSlashCmd.cmd_clear_favorites,argc = 0, help = "- clear all favorites" },
        decay   = { f = TargetsSlashCmd.cmd_decay,          argc = 1, help = "<value> - set decay timeout (sec)" },
    }

    LibSlash.RegisterSlashCmd("targets", function(msg)
        TargetsSlashCmd.parse_cmd(msg)
    end)
end

function TargetsSlashCmd.print(text)
    EA_ChatWindow.Print(L"[Targets] " .. towstring(text))
end

function TargetsSlashCmd.parse_cmd(msg)
    local args = StringSplit(msg)
    local cmd_name = table_remove(args, 1)

    if not cmd_name then
        TargetsSlashCmd.cmd_usage()
        return
    end

    cmd_name = cmd_name:lower()
    local cmd = TargetsSlashCmd.list[cmd_name]

    if not cmd then
        TargetsSlashCmd.print("Unknown command: " .. cmd_name)
        return
    end

    if #args < cmd.argc then
        TargetsSlashCmd.print("Usage: /targets " .. cmd_name .. " " .. cmd.help)
        return
    end

    cmd.f(args)
end

function TargetsSlashCmd.cmd_usage()
    TargetsSlashCmd.print("[Commands]")
    for key, cmd in pairs(TargetsSlashCmd.list) do
        TargetsSlashCmd.print("/targets " .. key .. " " .. cmd.help)
    end
end

function TargetsSlashCmd.cmd_toggle()
    local plist = Targets.allies
    plist.visible = not plist.visible
    Targets.saved.allies.visible = plist.visible
    for _, frame in ipairs(plist.frames) do
        frame.visible = plist.visible
    end
    TargetsSlashCmd.print("Allies list " .. (plist.visible and "shown" or "hidden"))
end

function TargetsSlashCmd.cmd_toggle_sort()
    local plist = Targets.allies
    plist.list.sort_players = not plist.list.sort_players
    plist.list.dirty = true
    Targets.saved.allies.sort_players = plist.list.sort_players
    TargetsSlashCmd.print("Sorting = " .. tostring(plist.list.sort_players))
end

function TargetsSlashCmd.cmd_maxplayers(args)
    local count = math_min(
        math_max(tonumber(args[1]) or TargetList.MAX_PLAYERS, 1),
        TargetList.MAX_PLAYERS
    )
    local plist = Targets.allies
    plist.list.max_players = count
    plist.list.dirty = true
    Targets.saved.allies.max_players = count
    TargetsSlashCmd.print("Max allies = " .. count)
end

function TargetsSlashCmd.cmd_add_favorites(args)
    local name = args[1]
    Targets.saved.favorites[name] = true
    TargetsSlashCmd.print("Added " .. name .. " to favorites")
end

function TargetsSlashCmd.cmd_del_favorites(args)
    local name = args[1]
    if Targets.saved.favorites[name] then
        Targets.saved.favorites[name] = nil
        TargetsSlashCmd.print("Removed " .. name .. " from favorites")
    else
        TargetsSlashCmd.print("Player not found: " .. name)
    end
end

function TargetsSlashCmd.cmd_list_favorites()
    TargetsSlashCmd.print("[Favorites]")
    local out = {}
    for name in pairs(Targets.saved.favorites) do
        out[#out + 1] = name
    end
    TargetsSlashCmd.print(table_concat(out, " "))
end

function TargetsSlashCmd.cmd_clear_favorites()
    Targets.saved.favorites = {}
    TargetsSlashCmd.print("Favorites cleared")
end

function TargetsSlashCmd.cmd_decay(args)
    TargetList.DEFAULT_DECAY =
        math_abs(tonumber(args[1]) or TargetList.DEFAULT_DECAY)
    TargetsSlashCmd.print(
        "Decay timeout = " .. TargetList.DEFAULT_DECAY .. " sec"
    )
end
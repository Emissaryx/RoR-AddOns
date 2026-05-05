-- AB_util.lua
-- Utility functions

AB_util = {}

-- return "rdps", "mdps", "healer", "tank" or nil (error)
function AB_util.career_category(cid)
    return AB_const.CAREERLINE_MAP[cid]
end

function AB_util.is_healer_base_career(cid)
    return cid ~= nil and AB_const.CAREERLINE_MAP[cid] == AB_const.HEALER
end

function AB_util.shout(text)
    TextLogAddEntry ("Chat", SystemData.ChatLogFilters.SHOUT, towstring(text))
end

function AB_util.print(text)
    local formatted_prefix = AutoBand.GetFormattedPrefixWString(true, { open_gui_on_click = true })
    EA_ChatWindow.Print(formatted_prefix .. towstring(text))
end

function AB_util.debug(stuff)
    if (AutoBand.debugon) then
        d(stuff)
    end
end

-- Returns true if the zone id appears in the known RvR/City allowlist.
function AB_util.is_known_rvr_zone_id(zid)
    if not zid or type(zid) ~= "number" then return false end
    -- Prefer the set built during init if available
    if AutoBand and AutoBand.allowed_rvr_zones_set and AutoBand.allowed_rvr_zones_set[zid] then
        return true
    end
    -- Fallback: linear scan over constants (called rarely)
    if AB_const and AB_const.ZONEIDS then
        for _, v in ipairs(AB_const.ZONEIDS) do
            if v == zid then return true end
        end
    end
    return false
end

-- Sanitize a zone name to ASCII-safe plain text for chat insertion.
-- Keeps letters, numbers, spaces, hyphens and apostrophes; strips everything else.
local function sanitize_zone_text(str)
    if not str then return nil end
    if type(str) ~= "string" then
        local ok, s = pcall(tostring, str)
        if not ok then return nil end
        str = s
    end
    -- Remove any engine/link tags just in case
    str = str:gsub("<[^>]*>", "")
    -- Drop control chars
    str = str:gsub("%c", "")
    -- Allow only alnum, space, hyphen and apostrophe
    str = str:gsub("[^%w %-%']", "")
    -- Collapse whitespace and trim
    str = str:gsub("%s+", " ")
    str = str:gsub("^%s*(.-)%s*$", "%1")
    if str == "" then return nil end
    return str
end

-- Safely resolve a zone name for a given id, with allowlist + sanitization.
-- Returns a plain Lua string suitable for concatenation in chat commands.
function AB_util.get_zone_name_sanitized(zid)
    if not zid or zid == 0 then
        return "Offline"
    end

    -- 1) Prefer engine-provided name if it sanitizes cleanly
    local ok, wzn = pcall(GetZoneName, zid)
    if ok and wzn and wzn ~= L"" then
        -- Trim any engine suffix after caret (e.g., "^n,in") like we do for names
        if AutoBand and AutoBand.FixString then
            local okfix, fixed = pcall(AutoBand.FixString, wzn)
            if okfix and fixed then wzn = fixed end
        end
        local zstr = sanitize_zone_text(tostring(wzn))
        if zstr and zstr ~= "" then
            return zstr
        end
    end

    -- 2) Fallback to explicit overrides table, if provided
    if AB_const and AB_const.ZONE_NAME_OVERRIDES and AB_const.ZONE_NAME_OVERRIDES[zid] then
        return AB_const.ZONE_NAME_OVERRIDES[zid]
    end

    -- 3) Final fallback
    return "Unknown Zone (" .. tostring(zid) .. ")"
end

-- Resolve the text used in adverts. For paired T1/T2/T3 campaign zones,
-- include both linked zones so ads match the playable pair instead of one side.
function AB_util.get_advert_zone_name_sanitized(zid)
    local zone_name = AB_util.get_zone_name_sanitized(zid)
    if not zone_name or zone_name == "" or zone_name == "Offline" then
        return zone_name
    end

    local pairings = AB_const and AB_const.CAMPAIGN_ZONE_PAIRINGS
    if not pairings then
        return zone_name
    end

    local paired_zid = pairings[zid]
    if not paired_zid or paired_zid == zid then
        return zone_name
    end

    local ordered_ids = { zid, paired_zid }
    table.sort(ordered_ids, function(a, b)
        local na, nb = tonumber(a), tonumber(b)
        if na and nb then
            return na < nb
        end
        if na then return true end
        if nb then return false end
        return tostring(a) < tostring(b)
    end)

    local parts = {}
    local seen = {}
    local short_names = AB_const and AB_const.ZONE_PAIR_SHORT_NAMES
    for _, zone_id in ipairs(ordered_ids) do
        if not seen[zone_id] then
            local label = AB_util.get_zone_name_sanitized(zone_id)
            if label and label ~= "" and label ~= "Offline" then
                if short_names and short_names[zone_id] and short_names[zone_id] ~= "" then
                    label = short_names[zone_id]
                end
                table.insert(parts, label)
                seen[zone_id] = true
            end
        end
    end

    if #parts >= 2 then
        return table.concat(parts, " / ")
    end
    if #parts == 1 then
        return parts[1]
    end
    return zone_name
end

-- iterates over every player in data calling "f(group id, player object, player position)"
function AB_util.foreach_player(data, f)
    for i, group in pairs(data) do
        for j, player in pairs(group) do
            f(i, player, j)
        end
    end
end

-- returns a COPY of a scenario party in player[i][j] format
function AB_util.get_hot_scdata()
    local newwb = {}
    local scdata = GameData.GetScenarioPlayerGroups()    -- get scenario wb
    for _, player in ipairs(scdata) do
        if (newwb[player.sgroupindex] == nil) then
            newwb[player.sgroupindex] = {}        -- create group
        end
        newwb[player.sgroupindex][player.sgroupslotnum] = player
    end
    return newwb
end

-- returns a COPY of a warband party in player[i][j] format
function AB_util.get_hot_wbdata()
    local newwb = {}
    local wbdata = GetBattlegroupMemberData()        -- get warband
    for i in ipairs(wbdata) do
        newwb[i] = {}
    end
    for gid, group in ipairs(wbdata) do
        for _, player in ipairs(group.players) do
            table.insert(newwb[gid], player)
        end
    end
    return newwb
end

-- return wb size
function AB_util.size_wb(wb)
    local count = 0
    if (wb) then
        for _, grp in pairs(wb) do
            count = count + (#grp)
        end
    end
    return count
end

function AB_util.size_table(t)
    local count = 0
    if (t) then
        for _ in pairs(t) do
            count = count + 1
        end
    end
    return count
end

function AB_util.get_level_range_score(level)
    if level == 40 then return 8
    elseif level >= 36 and level <= 39 then return 7
    elseif level >= 32 and level <= 35 then return 6
    elseif level >= 28 and level <= 31 then return 5
    elseif level >= 24 and level <= 27 then return 4
    elseif level >= 20 and level <= 23 then return 3
    elseif level >= 16 and level <= 19 then return 2
    elseif level >= 1 and level <= 15 then return 1
    else return 0
    end
end

function AB_util.print_wb(wb)
        AB_util.foreach_player(wb,
                function (gid, player, pid)
                        -- Attempt to get player name, role, and level for a more informative debug message
                        local playerName = (player and player.name and tostring(player.name)) or "UnknownName"
                        local playerRole = (player and player.role and tostring(player.role)) or "UnknownRole"
                        local playerLevel = (player and player.level and tostring(player.level)) or "??"
                        local playerCareerId = (player and player.careerLine and tostring(player.careerLine)) or (player and player.career and tostring(player.career)) or "??" -- player.career used in bin objects
                        local playerCareerName = ""
                        if AutoBand and AutoBand.GetCareerName and (player.careerLine or player.career) then
                                playerCareerName = " (" .. AutoBand.GetCareerName(player.careerLine or player.career) .. ")"
                        end

                        AB_util.debug("gid " .. gid .. " pid " .. pid .. " - Name: " .. playerName .. ", Role: " .. playerRole .. ", Lvl: " .. playerLevel .. ", CareerID: " .. playerCareerId .. playerCareerName)
                end
        )
end

-- Build a compact one-line summary of roles per group: "G1 T/H/D 2/2/2 | G2 ... | G4 empty"
function AB_util.roles_summary_line(wb_obj, dps_before_healers)
    local ok = (wb_obj and wb_obj.group ~= nil)
    if not ok then
        if AutoBand and AutoBand.get_wb then wb_obj = AutoBand.get_wb() else return "" end
    end
    local maxg = (wb_obj and wb_obj.MAX_GROUPS) or (AB_const and AB_const.MAX_WB_GROUPS) or 4
    local parts = {}
    for gid = 1, maxg do
        local t, h, md, rd = 0, 0, 0, 0
        local g = (wb_obj.group and wb_obj.group[gid]) or {}
        for i = 1, #g do
            local p = g[i]
            local r = p and p.role
            if r == AB_const.TANK then t = t + 1
            elseif r == AB_const.HEALER then h = h + 1
            elseif r == AB_const.MDPS then md = md + 1
            elseif r == AB_const.RDPS then rd = rd + 1 end
        end
        local total = t + h + md + rd
        if total == 0 then
            parts[#parts+1] = string.format("G%d empty", gid)
        else
            local dps = md + rd
            if dps_before_healers then
                parts[#parts+1] = string.format("G%d %d-%d-%d", gid, t, dps, h)
            else
                parts[#parts+1] = string.format("G%d %d-%d-%d", gid, t, h, dps)
            end
        end
    end
    return table.concat(parts, " | ")
end

function AB_util.dump_recursive(data, indent, depth, max_depth)
    indent = indent or ""
    depth = depth or 0
    max_depth = max_depth or 7 -- Limit recursion depth to prevent excessive output/errors

    if depth > max_depth then
        AB_util.print(indent .. "[Max recursion depth reached]")
        return
    end

    -- Check if data is actually a table before iterating
    if type(data) ~= "table" then
        AB_util.print(indent .. "[Not a table: " .. type(data) .. "] " .. tostring(data))
        return
    end

    for k, v in pairs(data) do
        local key_str = tostring(k)
        local value_type = type(v)
        local output = indent .. key_str .. ": "

        if value_type == "table" then
            AB_util.print(output .. "(table) {")
            -- CORRECTED: Use the fully qualified name for the recursive call
            local success, err = pcall(AB_util.dump_recursive, v, indent .. "  ", depth + 1, max_depth)
            if not success then
                AB_util.print(indent .. "  [Error accessing table content: " .. tostring(err) .. "]")
            end
            AB_util.print(indent .. "}") -- Close the table brace
        elseif value_type == "function" then
            AB_util.print(output .. "(function)")
        elseif value_type == "userdata" then
            -- Try to get more info if possible, otherwise just print type
            -- Use pcall as tostring on some userdata might error
            local success_ud, info_ud = pcall(tostring, v)
            if success_ud and info_ud ~= nil and string.len(info_ud) < 100 then -- Avoid huge userdata strings
                AB_util.print(output .. "(userdata: " .. info_ud .. ")")
            else
                AB_util.print(output .. "(userdata)")
            end
        elseif value_type == "nil" then
            AB_util.print(output .. "nil")
        else -- boolean, number, string
            -- Use pcall for tostring just in case
            local success_val, val_str = pcall(tostring, v)
            if success_val then
                AB_util.print(output .. val_str)
            else
                AB_util.print(output .. "[Error converting value to string]")
            end
        end
    end
end


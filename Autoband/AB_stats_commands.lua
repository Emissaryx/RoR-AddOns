-- AB_stats_commands.lua
-- /ab stats command surface.

if type(AutoBand) ~= "table" then
    AutoBand = {}
end

local stats_module = AutoBand._realmstats_module or {}
local stats_const = stats_module.const or {}
local stats_fn = stats_module.fn or {}

local REALMSTATS_SHIFT_THRESHOLD_MIN_PERCENT = stats_const.REALMSTATS_SHIFT_THRESHOLD_MIN_PERCENT or 0
local REALMSTATS_SHIFT_THRESHOLD_MAX_PERCENT = stats_const.REALMSTATS_SHIFT_THRESHOLD_MAX_PERCENT or 100
local REALMRANK_CSV_FILE_NAME = stats_const.REALMRANK_CSV_FILE_NAME or "AutoBand_RealmRank.csv"

local parse_first_number = stats_fn.parse_first_number
local clamp_realmstats_shift_threshold_percent = stats_fn.clamp_realmstats_shift_threshold_percent
local realmstats_reset_startup_runtime = stats_fn.realmstats_reset_startup_runtime
local realmstats_copy_snapshot = stats_fn.realmstats_copy_snapshot
local realmstats_get_shift_threshold_percent = stats_fn.realmstats_get_shift_threshold_percent
local realmstats_format_threshold_percent = stats_fn.realmstats_format_threshold_percent
local realmstats_is_threshold_action = stats_fn.realmstats_is_threshold_action
local normalize_realmstats_breakdown_tier = stats_fn.normalize_realmstats_breakdown_tier
local realmstats_breakdown_usage = stats_fn.realmstats_breakdown_usage
local realmstats_show_career_breakdown = stats_fn.realmstats_show_career_breakdown
local realmstats_print_snapshot = stats_fn.realmstats_print_snapshot

if type(parse_first_number) ~= "function" then
    parse_first_number = function(raw)
        return tonumber(raw)
    end
end
if type(clamp_realmstats_shift_threshold_percent) ~= "function" then
    clamp_realmstats_shift_threshold_percent = function(value)
        local number = tonumber(value)
        if not number then
            return nil
        end
        if number < REALMSTATS_SHIFT_THRESHOLD_MIN_PERCENT then
            number = REALMSTATS_SHIFT_THRESHOLD_MIN_PERCENT
        elseif number > REALMSTATS_SHIFT_THRESHOLD_MAX_PERCENT then
            number = REALMSTATS_SHIFT_THRESHOLD_MAX_PERCENT
        end
        return number
    end
end
if type(realmstats_reset_startup_runtime) ~= "function" then
    realmstats_reset_startup_runtime = function(_announced) end
end
if type(realmstats_copy_snapshot) ~= "function" then
    realmstats_copy_snapshot = function(snapshot)
        return snapshot
    end
end
if type(realmstats_get_shift_threshold_percent) ~= "function" then
    realmstats_get_shift_threshold_percent = function()
        return 2
    end
end
if type(realmstats_format_threshold_percent) ~= "function" then
    realmstats_format_threshold_percent = function(value)
        return tostring(value or 2) .. "%"
    end
end
if type(realmstats_is_threshold_action) ~= "function" then
    realmstats_is_threshold_action = function(action)
        return action == "threshold" or action == "thres" or action == "thresh" or action == "diff"
    end
end
if type(normalize_realmstats_breakdown_tier) ~= "function" then
    normalize_realmstats_breakdown_tier = function(_raw)
        return nil, nil
    end
end
if type(realmstats_breakdown_usage) ~= "function" then
    realmstats_breakdown_usage = function()
        AB_util.print("Usage: /ab stats breakdown [tAll|t1|t2t3|t2+|t4|rr60|rr80] [detailed]")
    end
end
if type(realmstats_show_career_breakdown) ~= "function" then
    realmstats_show_career_breakdown = function(_tier_key, _tier_label, _show_careers)
        AB_util.print("[Error] Realm stats breakdown unavailable in this build.")
        return false
    end
end
if type(realmstats_print_snapshot) ~= "function" then
    realmstats_print_snapshot = function(_snapshot, _opts) end
end

local function realmstats_try_forced_refresh_for_missing_snapshot()
    if type(AutoBand.refresh_realmrank_cache) ~= "function" then
        return false
    end
    if type(AutoBand.has_realmrank_snapshot_rows) == "function" and
       AutoBand.has_realmrank_snapshot_rows() ~= true then
        return false
    end
    return AutoBand.refresh_realmrank_cache(true) == true
end

local function realmstats_show_current_snapshot(show_info)
    if type(AutoBand.is_realmrank_soft_disabled) == "function" and AutoBand.is_realmrank_soft_disabled() then
        return false
    end

    local loaded = false
    if type(AutoBand.ensure_realmrank_snapshot_loaded) == "function" then
        loaded = AutoBand.ensure_realmrank_snapshot_loaded(false)
    end
    local snapshot = AutoBand.realmstats_snapshot
    if type(snapshot) ~= "table" or type(snapshot.overall) ~= "table" then
        if realmstats_try_forced_refresh_for_missing_snapshot() then
            loaded = true
            snapshot = AutoBand.realmstats_snapshot
        end
    end
    local csv_stale = AutoBand.is_realmrank_data_stale and AutoBand.is_realmrank_data_stale() == true
    if csv_stale then
        AB_util.print("[Error] Realm stats unavailable: online CSV is stale (" .. REALMRANK_CSV_FILE_NAME .. ").")
        return false
    end
    if type(snapshot) ~= "table" or type(snapshot.overall) ~= "table" then
        local miss_reason = loaded and "stats columns missing from CSV rows" or "online CSV unavailable"
        AB_util.print("[Error] Realm stats unavailable: " .. miss_reason .. " (" .. REALMRANK_CSV_FILE_NAME .. ").")
        return false
    end
    realmstats_print_snapshot(snapshot, { include_snapshot_row = show_info == true })
    return true
end

function AutoBand.cmd_stats(args)
    if type(AutoBand.ensure_realmstats_startup_runtime) == "function" then
        AutoBand.ensure_realmstats_startup_runtime()
    end

    if type(AutoBand.is_realmrank_soft_disabled) == "function" and AutoBand.is_realmrank_soft_disabled() then
        return
    end

    local action = nil
    local action2 = nil
    local action3 = nil
    if type(args) == "table" and args[1] then
        action = tostring(args[1])
        local ok_lower, lowered = pcall(string.lower, action)
        if ok_lower and lowered then
            action = lowered
        end
    end
    if type(args) == "table" and args[2] then
        action2 = tostring(args[2])
    end
    if type(args) == "table" and args[3] then
        action3 = tostring(args[3])
    end

    if action == "breakdown" or action == "careers" or action == "roles" or action == "pie" or action == "comp" then
        local tier_raw = action2
        local show_careers = false
        local function is_detailed(s)
            return s == "detailed" or s == "detail" or s == "full"
        end
        if is_detailed(action2) then
            tier_raw = nil
            show_careers = true
        elseif is_detailed(action3) then
            show_careers = true
        end
        local tier_key, tier_label = normalize_realmstats_breakdown_tier(tier_raw)
        if tier_key == nil then
            realmstats_breakdown_usage()
            return
        end
        realmstats_show_career_breakdown(tier_key, tier_label, show_careers)
        return
    end

    local show_info = false
    local desired_state = nil
    local threshold_set = nil
    local threshold_changed = false
    local threshold_value = realmstats_get_shift_threshold_percent()

    if action == "enable" or action == "on" then
        desired_state = true
    elseif action == "disable" or action == "off" then
        desired_state = false
    elseif action == "toggle" then
        desired_state = not (AutoBand.saved and AutoBand.saved.realmstats_enabled == true)
    elseif action == "info" or action == "details" then
        desired_state = nil
        show_info = true
    elseif action == nil or action == "now" or action == "show" or action == "status" then
        desired_state = nil
    elseif realmstats_is_threshold_action(action) then
        if action2 ~= nil and action2 ~= "" then
            local parsed = clamp_realmstats_shift_threshold_percent(parse_first_number(action2))
            if parsed == nil then
                AB_util.print(
                    "Usage: /ab stats threshold <percent> (range " ..
                    tostring(REALMSTATS_SHIFT_THRESHOLD_MIN_PERCENT) .. "-" ..
                    tostring(REALMSTATS_SHIFT_THRESHOLD_MAX_PERCENT) .. ")"
                )
                return
            end
            threshold_set = parsed
        end
    else
        local parsed_inline = clamp_realmstats_shift_threshold_percent(parse_first_number(action))
        if parsed_inline ~= nil then
            threshold_set = parsed_inline
        else
            AB_util.print("Usage: /ab stats [now|info|enable|disable|toggle|threshold <percent>|<percent>|breakdown [tier]]")
            return
        end
    end

    if threshold_set ~= nil then
        threshold_value = threshold_set
        if AutoBand.saved then
            local current_saved = clamp_realmstats_shift_threshold_percent(AutoBand.saved.realmstats_shift_threshold_percent)
            if current_saved == nil or current_saved ~= threshold_set then
                threshold_changed = true
            end
            AutoBand.saved.realmstats_shift_threshold_percent = threshold_set
        end
    end

    if desired_state ~= nil then
        AutoBand.saved.realmstats_enabled = desired_state
        if desired_state ~= true then
            AutoBand.realmstats_last_report = nil
            realmstats_reset_startup_runtime(false)
        else
            realmstats_reset_startup_runtime(true)
        end
    end

    local format_threshold = function(value)
        return realmstats_format_threshold_percent(value)
    end

    if show_info then
        AB_util.print(
            "Realm stats monitor: " ..
            tostring(AutoBand.saved.realmstats_enabled == true) ..
            " (alerts on shifts > " .. format_threshold(threshold_value) .. ")."
        )
    end
    if threshold_set == nil and realmstats_is_threshold_action(action) then
        AB_util.print("Realm stats shift threshold: " .. format_threshold(threshold_value) .. ".")
    elseif threshold_changed then
        AB_util.print("Realm stats shift threshold set to " .. format_threshold(threshold_value) .. ".")
    end

    local shown = realmstats_show_current_snapshot(show_info)
    if shown and AutoBand.saved.realmstats_enabled == true then
        realmstats_reset_startup_runtime(true)
        if desired_state ~= nil then
            AutoBand.realmstats_last_report = realmstats_copy_snapshot(AutoBand.realmstats_snapshot)
            AB_util.print("Realm stats baseline refreshed.")
        elseif type(AutoBand.realmstats_last_report) ~= "table" then
            AutoBand.realmstats_last_report = realmstats_copy_snapshot(AutoBand.realmstats_snapshot)
        end
    end
end

AutoBand.realmstats_show_current_snapshot = realmstats_show_current_snapshot

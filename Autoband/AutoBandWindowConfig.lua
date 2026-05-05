-- AutoBand config tab UI bindings.
AutoBandWindowConfig = {}

AutoBandWindowConfig.name = "AutoBandWindowConfigTab"
AutoBandWindowConfig.combobox_name = AutoBandWindowConfig.name .. "ComboBox"
AutoBandWindowConfig.guild_priority_value_label_name = AutoBandWindowConfig.name .. "GuildPriorityValueLabel"
AutoBandWindowConfig.friend_priority_value_label_name = AutoBandWindowConfig.name .. "FriendPriorityValueLabel"

local function next_social_priority_mode(mode)
    mode = AutoBand.normalize_social_priority_mode(mode, AB_const.SOCIAL_PRIORITY_MODE_OFF)
    local modes = AB_const.SOCIAL_PRIORITY_MODES or {
        AB_const.SOCIAL_PRIORITY_MODE_OFF,
        AB_const.SOCIAL_PRIORITY_MODE_PREFER,
        AB_const.SOCIAL_PRIORITY_MODE_PROTECT,
        AB_const.SOCIAL_PRIORITY_MODE_PROMOTE
    }
    local index = 1
    for i = 1, #modes do
        if modes[i] == mode then
            index = i
            break
        end
    end
    index = index + 1
    if index > #modes then
        index = 1
    end
    return modes[index]
end

local function previous_social_priority_mode(mode)
    mode = AutoBand.normalize_social_priority_mode(mode, AB_const.SOCIAL_PRIORITY_MODE_OFF)
    local modes = AB_const.SOCIAL_PRIORITY_MODES or {
        AB_const.SOCIAL_PRIORITY_MODE_OFF,
        AB_const.SOCIAL_PRIORITY_MODE_PREFER,
        AB_const.SOCIAL_PRIORITY_MODE_PROTECT,
        AB_const.SOCIAL_PRIORITY_MODE_PROMOTE
    }
    local index = 1
    for i = 1, #modes do
        if modes[i] == mode then
            index = i
            break
        end
    end
    index = index - 1
    if index < 1 then
        index = #modes
    end
    return modes[index]
end

function AutoBandWindowConfig.refresh_social_controls()
    LabelSetText(AutoBandWindowConfig.name .. "SocialLabel", L"Social")
    LabelSetText(AutoBandWindowConfig.name .. "GuildPriorityLabel", L"Guild prio")
    LabelSetText(AutoBandWindowConfig.name .. "FriendPriorityLabel", L"Friend prio")
    LabelSetText(AutoBandWindowConfig.name .. "GuildGroupingLabel", L"Group guildies together")
    LabelSetText(
        AutoBandWindowConfig.guild_priority_value_label_name,
        towstring(AutoBand.get_social_priority_mode_label(AutoBand.get_saved_social_priority_mode("guild")))
    )
    LabelSetText(
        AutoBandWindowConfig.friend_priority_value_label_name,
        towstring(AutoBand.get_social_priority_mode_label(AutoBand.get_saved_social_priority_mode("friend")))
    )
    ButtonSetPressedFlag(
        AutoBandWindowConfig.name .. "GuildGroupingCheckBox",
        AutoBand.saved and AutoBand.saved.guild_grouping_enabled == true
    )
end

local function refresh_exclude_realm_healer_alt_spec_label()
    local label_name = AutoBandWindowConfig.name .. "ExcludeRealmHealerAltSpecLabel"
    local checkbox_name = AutoBandWindowConfig.name .. "ExcludeRealmHealerAltSpecCheckBox"
    local alt_check_enabled = AutoBand.saved and AutoBand.saved.alt_speccheck_enabled == true
    local exclude_enabled = AutoBand.saved and AutoBand.saved.exclude_realm_healer_alt_spec == true

    LabelSetText(label_name, towstring(AB_const.GetExcludeRealmHealerAltSpecLabel()))
    if alt_check_enabled then
        LabelSetTextColor(label_name, 225, 225, 225)
    else
        LabelSetTextColor(label_name, 150, 150, 150)
    end

    ButtonSetPressedFlag(checkbox_name, exclude_enabled)
    ButtonSetDisabledFlag(checkbox_name, not alt_check_enabled)
end

local function should_show_common_race_names_control()
    if not (AutoBand and AutoBand.raceDetermined == true and AB_const) then
        return false
    end
    if type(AB_const.RaceSupportsCommonNames) ~= "function" then
        return false
    end
    return AB_const.RaceSupportsCommonNames(AutoBand.race) == true
end

local function build_common_race_names_tooltip_text()
    local race = nil
    if AutoBand and AutoBand.raceDetermined == true then
        race = AutoBand.race
    end

    if race and type(AB_const.RaceSupportsCommonNames) == "function" and AB_const.RaceSupportsCommonNames(race) == true then
        local lore_title = AB_const.GetRaceLoreTitle(race)
        local common_title = AB_const.GetRaceCommonTitle(race)
        if lore_title and common_title and lore_title ~= "" and common_title ~= "" then
            return towstring("Uses '" .. tostring(common_title) .. "' instead of '" .. tostring(lore_title) .. "' in race-restriction text.")
        end
    end

    return L"Uses common race names in race-restriction text."
end

local function get_autokick_period_value()
    local period = nil

    if AutoBand and AutoBand.saved then
        period = tonumber(AutoBand.saved.autokick_period)
    end

    if period == nil then
        period = AB_const.KICK_PERIOD
    end

    period = math.floor(period)
    if period < 0 then
        period = 0
    elseif period > AB_const.MAX_KICKOFF_TIME then
        period = AB_const.MAX_KICKOFF_TIME
    end

    return period
end

function AutoBandWindowConfig.refresh_common_race_names_control()
    local label_name = AutoBandWindowConfig.name .. "CommonRaceNamesLabel"
    local checkbox_name = AutoBandWindowConfig.name .. "CommonRaceNamesCheckBox"
    local show_control = should_show_common_race_names_control()

    WindowSetShowing(label_name, show_control)
    WindowSetShowing(checkbox_name, show_control)

    if show_control then
        ButtonSetPressedFlag(checkbox_name, AutoBand.saved and AutoBand.saved.use_common_race_names == true)
    end
end


function AutoBandWindowConfig.Initialize()
  -- Settings: Templates
  LabelSetText(AutoBandWindowConfig.name .. "DefaultLabel", L"Default Template")
  ButtonSetText(AutoBandWindowConfig.name .. "ClearTemplateButton", L"Reset")

  AutoBandWindowConfig.refresh_default_template()

  LabelSetText(AutoBandWindowConfig.name .. "ComboBoxLabel", L"Distribution Algorithm:")
  AutoBandWindowConfig.init_combobox()
  AutoBandWindowConfig.refresh_combobox()

  -- Settings: Auto Kick for Composition
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "KickCheckBox", true)

  -- Settings: Auto Kick too far
  LabelSetText(AutoBandWindowConfig.name .. "AutoKickToofarLabel", L"AKick too far")
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "KickToofarCheckBox", true)
  LabelSetText(AutoBandWindowConfig.name .. "KickTimeLabel", L"Timeout") -- (min)")
  AutoBandWindowConfig.refresh_kickoff()

  -- Settings: Auto Kick Low Rank
  LabelSetText(AutoBandWindowConfig.name .. "AutoKickLowRankLabel", L"AKick below rank requirements")
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "KickLowRankCheckBox", true)

  -- Settings: Auto Kick Stealthers
  LabelSetText(AutoBandWindowConfig.name .. "AutoKickStealthersLabel", towstring(AB_const.GetAutoKickStealthersLabel("AKick")))
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "KickStealthersCheckBox", true)

  -- Settings: Auto Kick players in non-oRVR or Cities
  LabelSetText(AutoBandWindowConfig.name .. "AutoKickRvRZonesLabel", L"AKick players in SCs")
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "KickRvRZonesCheckBox", true)

  -- Settings: Treat BW/Sorc as MDPS
  LabelSetText(AutoBandWindowConfig.name .. "BWSorcAsMDPSLabel", towstring( AB_const.GetBWSorcAsMDPSLabel() ) )
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "BWSorcAsMDPSCheckBox", true)

  -- Settings: Initialize Restrict Race <<
  LabelSetText(AutoBandWindowConfig.name .. "RestrictRaceLabel", towstring( AB_const.GetRestrictRaceLabel() ) )
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "RestrictRaceCheckBox", true)
  LabelSetText(AutoBandWindowConfig.name .. "CommonRaceNamesLabel", L"Common\nnames")
  LabelSetTextColor(AutoBandWindowConfig.name .. "CommonRaceNamesLabel", 225, 225, 225)
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "CommonRaceNamesCheckBox", true)
  AutoBandWindowConfig.refresh_common_race_names_control()

  -- Settings: BackFill
  LabelSetText(AutoBandWindowConfig.name .. "BackFillLabel", L"BackFill when AKick")
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "BackFillCheckBox", true)

  -- Settings: Social
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "GuildGroupingCheckBox", true)
  WindowSetShowing(AutoBandWindowConfig.name .. "SocialLabel", false)
  AutoBandWindowConfig.refresh_social_controls()

  -- Settings: AKick ignored players
  LabelSetText(AutoBandWindowConfig.name .. "KickIgnoreLabel", L"AKick ignored")
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "KickIgnoreCheckBox", true)

  -- Settings: Rank requirements
  LabelSetText(AutoBandWindowConfig.name .. "RankReqLabel", L"Tank")
  LabelSetText(AutoBandWindowConfig.name .. "HealerRankReqLabel", L"Heal")
  LabelSetText(AutoBandWindowConfig.name .. "DpsRankReqLabel", L"DPS")

  -- Settings: Alt Check
  LabelSetText(AutoBandWindowConfig.name .. "AltCheckLabel", L"Alt-Spec check")
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "AltCheckCheckBox", true)
  refresh_exclude_realm_healer_alt_spec_label()
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "ExcludeRealmHealerAltSpecCheckBox", true)

  -- Settings: Minimap icon
  -- LabelSetText(AutoBandWindowConfig.name .. "MapIconLabel", L"Minimap icon")
  -- ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "MapIconCheckBox", true)
  --    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "MapIconCheckBox", AutoBand.saved.displayicon)

  -- Settings: DPS Weighting
  ButtonSetCheckButtonFlag(AutoBandWindowConfig.name .. "DpsWeightingCheckBox", true)
  LabelSetText(AutoBandWindowConfig.name .. "MaxMdpsLabel", L"  Max mDPS")
  LabelSetText(AutoBandWindowConfig.name .. "MaxRdpsLabel", L"  Max rDPS")
  ButtonSetPressedFlag(AutoBandWindowConfig.name .. "DpsWeightingCheckBox", AutoBand.saved.dps_weighting_enabled)

  AutoBandWindowConfig.refresh_min_rank()
  AutoBandWindowConfig.refresh_min_rank_healer()
  AutoBandWindowConfig.refresh_min_rank_dps()
  AutoBandWindowConfig.refresh_dps_weights()
  AutoBandWindowConfig.refresh_social_controls()

  LabelSetText(AutoBandWindowConfig.name .. "VersionLabel", L"v" .. towstring(AB_const.VERSION))
  AutoBandWindowConfig.refresh_autokick_label()

  -- Button bar
  ButtonSetText(AutoBandWindowConfig.name .. "ResetButton", L"Restore Defaults")
  WindowSetShowing(AutoBandWindowConfig.name .. "DisplaySeperator1", false)
  WindowSetShowing(AutoBandWindowConfig.name .. "DisplaySeperator2", true)
end

function AutoBandWindowConfig.refresh_default_template()
        local clear_default = true
        local default_template = AB_const.EMPTY_TEMPLATE

        if (AutoBand.saved.default_template ~= AB_const.EMPTY_TEMPLATE) then
                clear_default = false
                default_template = AutoBand.saved.default_template
                AB_util.debug("Default is not set to automatic: " .. default_template)
        end

        LabelSetText(AutoBandWindowConfig.name .. "DefaultTemplateLabel", towstring(default_template))
        ButtonSetDisabledFlag(AutoBandWindowConfig.name .. "ClearTemplateButton", clear_default)
end


function AutoBandWindowConfig.init_combobox()
        -- reloadui combobox
        AutoBandWindowConfig.combo_items = {}
        ComboBoxClearMenuItems(AutoBandWindowConfig.combobox_name)
        -- add from templates
        for mid, mode in pairs(AB_const.ALGO_MODE) do
                ComboBoxAddMenuItem(AutoBandWindowConfig.combobox_name, towstring("(" .. mid .. ") " .. mode))
                table.insert(AutoBandWindowConfig.combo_items, "(" .. mid .. ") " .. mode)
        end
end

function AutoBandWindowConfig.refresh_combobox()
        ComboBoxSetSelectedMenuItem(AutoBandWindowConfig.combobox_name, AutoBand.saved.org_algo_mode)
end

-- return selected text
function AutoBandWindowConfig.selected_combobox()
        return tostring(ComboBoxGetSelectedText(AutoBandWindowConfig.combobox_name))
end

-- load selected algorithm
function AutoBandWindowConfig.OnSelChangedComboBox()
        local name = AutoBandWindowConfig.selected_combobox()
        local index = nil
        for i, v in ipairs(AutoBandWindowConfig.combo_items) do
                if (v == name) then
                        index = i
                        break
                end
        end
        if (index) then
                AutoBand.saved.org_algo_mode = index
                ComboBoxSetSelectedMenuItem(AutoBandWindowConfig.combobox_name, AutoBand.saved.org_algo_mode)
                AB_util.debug(AutoBand.saved.org_algo_mode)
                if AutoBand and AutoBand.mark_template_settings_modified then
                    AutoBand.mark_template_settings_modified()
                end
        end
end

function AutoBandWindowConfig.Shutdown()
end

function AutoBandWindowConfig.Hide()
    WindowSetShowing(AutoBandWindowConfig.name, false)
end

function AutoBandWindowConfig.Show()
    AutoBandWindowConfig.refresh_default_template()
    AutoBandWindowConfig.refresh_combobox()
    AutoBandWindowConfig.refresh_min_rank()
    AutoBandWindowConfig.refresh_min_rank_healer()
    AutoBandWindowConfig.refresh_min_rank_dps()
    AutoBandWindowConfig.refresh_dps_weights()
    AutoBandWindowConfig.refresh_autokick_controls()
    AutoBandWindowConfig.refresh_social_controls()
    WindowSetShowing(AutoBandWindowConfig.name .. "SocialLabel", false)
    -- ButtonSetPressedFlag(AutoBandWindowConfig.name .. "MapIconCheckBox", AutoBand.saved.displayicon)
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "AltCheckCheckBox", AutoBand.saved.alt_speccheck_enabled)
    refresh_exclude_realm_healer_alt_spec_label()
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "DpsWeightingCheckBox", AutoBand.saved.dps_weighting_enabled)
    LabelSetText(AutoBandWindowConfig.name .. "BWSorcAsMDPSLabel", towstring ( AB_const.GetBWSorcAsMDPSLabel() ) )
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "BWSorcAsMDPSCheckBox", AutoBand.saved.bw_sorc_as_mdps)
    LabelSetText(AutoBandWindowConfig.name .. "RestrictRaceLabel", towstring ( AB_const.GetRestrictRaceLabel() ) )
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "RestrictRaceCheckBox", AutoBand.saved.restrict_same_race)
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "CommonRaceNamesCheckBox", AutoBand.saved.use_common_race_names)
    AutoBandWindowConfig.refresh_common_race_names_control()
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "BackFillCheckBox", AutoBand.saved.backfill_enabled)
    AutoBandWindow.toggle_mapicon(AutoBand.saved.displayicon)
    WindowSetShowing(AutoBandWindowConfig.name, true)
end

function AutoBandWindowConfig.OnClearTemplateButton()
        if (ButtonGetDisabledFlag(AutoBandWindowConfig.name .. "ClearTemplateButton")) then
                return
        end
        AutoBand.saved.default_template = AB_const.EMPTY_TEMPLATE
        AutoBandWindowConfig.refresh_default_template()
end

function AutoBandWindowConfig.OnPressTimeMinusButton()
        AutoBand.saved.autokick_period = get_autokick_period_value() - 1
        if (AutoBand.saved.autokick_period < 0) then
                AutoBand.saved.autokick_period = AB_const.MAX_KICKOFF_TIME
        end
        LabelSetText(AutoBandWindowConfig.name .. "AutoKickTimeoutLabel", L"" .. AutoBand.saved.autokick_period)
        if AutoBand and AutoBand.mark_template_settings_modified then
                AutoBand.mark_template_settings_modified()
        end
end

function AutoBandWindowConfig.OnPressTimePlusButton()
        AutoBand.saved.autokick_period = get_autokick_period_value() + 1
        if (AutoBand.saved.autokick_period > AB_const.MAX_KICKOFF_TIME) then
                AutoBand.saved.autokick_period = 0
        end
        LabelSetText(AutoBandWindowConfig.name .. "AutoKickTimeoutLabel", L"" .. AutoBand.saved.autokick_period)
        if AutoBand and AutoBand.mark_template_settings_modified then
                AutoBand.mark_template_settings_modified()
        end

end

local CAREER_RANK_REQUIREMENT_MAX = 40
local REALMRANK_REQUIREMENT_STEP = 5

local function normalize_rank_ui_value(raw)
  local n = tonumber(raw)
  if n == nil then
    return 1
  end
  n = math.floor(n)
  if n < 1 then
    n = 1
  elseif n > AB_const.MAXIMUM_RANK then
    n = AB_const.MAXIMUM_RANK
  end
  if n > CAREER_RANK_REQUIREMENT_MAX and (n % REALMRANK_REQUIREMENT_STEP) ~= 0 then
    n = n - (n % REALMRANK_REQUIREMENT_STEP)
    if n <= CAREER_RANK_REQUIREMENT_MAX then
      n = CAREER_RANK_REQUIREMENT_MAX + REALMRANK_REQUIREMENT_STEP
    end
  end
  return n
end

local function can_use_rr_requirements_from_ui()
  if not AutoBand or type(AutoBand.can_use_realmrank_requirement) ~= "function" then
    return false, "rank updates are currently unavailable"
  end
  local ok_rr, reason = AutoBand.can_use_realmrank_requirement(true)
  if ok_rr then
    return true, nil
  end
  return false, reason or "rank updates are currently unavailable"
end

local function step_rank_up_ui(current, rr_allowed)
  current = normalize_rank_ui_value(current)
  if current < CAREER_RANK_REQUIREMENT_MAX then
    return current + 1
  end
  if current == CAREER_RANK_REQUIREMENT_MAX then
    if rr_allowed then
      return CAREER_RANK_REQUIREMENT_MAX + REALMRANK_REQUIREMENT_STEP
    end
    return 1
  end
  if not rr_allowed then
    return current
  end
  local next_value = current + REALMRANK_REQUIREMENT_STEP
  if next_value > AB_const.MAXIMUM_RANK then
    return 1
  end
  return next_value
end

local function step_rank_down_ui(current, rr_allowed)
  current = normalize_rank_ui_value(current)
  if current > CAREER_RANK_REQUIREMENT_MAX then
    local next_value = current - REALMRANK_REQUIREMENT_STEP
    if next_value < CAREER_RANK_REQUIREMENT_MAX then
      next_value = CAREER_RANK_REQUIREMENT_MAX
    end
    return next_value
  end
  if current > 1 then
    return current - 1
  end
  if rr_allowed then
    return AB_const.MAXIMUM_RANK
  end
  return CAREER_RANK_REQUIREMENT_MAX
end

local function ensure_role_rank_fields()
  if not AutoBand or not AutoBand.saved then
    return
  end
  if AutoBand.saved.min_rank_tank ~= nil and AutoBand.saved.min_rank_healer ~= nil and AutoBand.saved.min_rank_dps ~= nil then
    return
  end
  if type(AutoBand.get_saved_rank_requirements) == "function" then
    local tank_rank, healer_rank, dps_rank = AutoBand.get_saved_rank_requirements(AutoBand.saved)
    AutoBand.saved.min_rank_tank = tank_rank
    AutoBand.saved.min_rank_healer = healer_rank
    AutoBand.saved.min_rank_dps = dps_rank
  end
end

local function sync_rank_fields_after_ui_edit()
  ensure_role_rank_fields()
  if AutoBand and type(AutoBand.sync_legacy_rank_requirement_fields) == "function" then
    AutoBand.sync_legacy_rank_requirement_fields(AutoBand.saved)
  else
    local legacy_rank = AutoBand.saved.min_rank_tank or AB_const.MINIMUM_RANK_TANK
    if (AutoBand.saved.min_rank_dps or AB_const.MINIMUM_RANK_DPS) > legacy_rank then
      legacy_rank = AutoBand.saved.min_rank_dps
    end
    AutoBand.saved.min_rank = legacy_rank
  end
end

local function refresh_role_rank_labels()
  ensure_role_rank_fields()
  LabelSetText(AutoBandWindowConfig.name .. "MinRankValueLabel", L"" .. AutoBand.saved.min_rank_tank)
  LabelSetText(AutoBandWindowConfig.name .. "MinHealerRankValueLabel", L"" .. AutoBand.saved.min_rank_healer)
  LabelSetText(AutoBandWindowConfig.name .. "MinDpsRankValueLabel", L"" .. AutoBand.saved.min_rank_dps)
end

local function set_role_rank_value(field, value)
  ensure_role_rank_fields()
  local changed = AutoBand.saved[field] ~= value
  if type(AutoBand.set_saved_rank_requirements) == "function" then
    local tank_rank = AutoBand.saved.min_rank_tank
    local healer_rank = AutoBand.saved.min_rank_healer
    local dps_rank = AutoBand.saved.min_rank_dps
    if field == "min_rank_tank" then
      tank_rank = value
    elseif field == "min_rank_healer" then
      healer_rank = value
    else
      dps_rank = value
    end
    AutoBand.set_saved_rank_requirements(tank_rank, healer_rank, dps_rank, AutoBand.saved)
  else
    AutoBand.saved[field] = value
    sync_rank_fields_after_ui_edit()
  end
  if changed and type(AutoBand.arm_rank_requirement_grace) == "function" then
    AutoBand.arm_rank_requirement_grace()
  end
  refresh_role_rank_labels()
  if AutoBand and AutoBand.mark_template_settings_modified then
    AutoBand.mark_template_settings_modified()
  end
end

local function adjust_role_rank_down(field)
  refresh_role_rank_labels()
  local ok_rr = can_use_rr_requirements_from_ui()
  set_role_rank_value(field, step_rank_down_ui(AutoBand.saved[field], ok_rr == true))
end

local function adjust_role_rank_up(field, role_label)
  refresh_role_rank_labels()
  local rr_allowed, rr_reason = can_use_rr_requirements_from_ui()
  local next_value = step_rank_up_ui(AutoBand.saved[field], rr_allowed == true)
  if next_value > CAREER_RANK_REQUIREMENT_MAX and rr_allowed ~= true then
    AB_util.print("[error] Cannot set " .. tostring(role_label) .. " RR requirement above 40: " .. tostring(rr_reason) .. ". Please restart the rank updater and run /ab csvrefresh.")
    return
  end
  set_role_rank_value(field, next_value)
end

function AutoBandWindowConfig.OnPressRankMinusButton()
  adjust_role_rank_down("min_rank_tank")
end

function AutoBandWindowConfig.OnPressRankPlusButton()
  adjust_role_rank_up("min_rank_tank", "tank")
end

function AutoBandWindowConfig.OnPressHealerRankMinusButton()
  adjust_role_rank_down("min_rank_healer")
end

function AutoBandWindowConfig.OnPressHealerRankPlusButton()
  adjust_role_rank_up("min_rank_healer", "healer")
end

function AutoBandWindowConfig.OnPressDpsRankMinusButton()
  adjust_role_rank_down("min_rank_dps")
end

function AutoBandWindowConfig.OnPressDpsRankPlusButton()
  adjust_role_rank_up("min_rank_dps", "dps")
end

function AutoBandWindowConfig.refresh_kickoff()
        local autokick_period = get_autokick_period_value()
        if AutoBand and AutoBand.saved then
                AutoBand.saved.autokick_period = autokick_period
        end
        LabelSetText(AutoBandWindowConfig.name .. "AutoKickTimeoutLabel", L"" .. autokick_period)
        ButtonSetPressedFlag(AutoBandWindowConfig.name .. "KickCheckBox", AutoBand.saved and AutoBand.saved.autokick_enabled == true)
end

function AutoBandWindowConfig.refresh_min_rank()
        refresh_role_rank_labels()
end

function AutoBandWindowConfig.refresh_min_rank_healer()
        refresh_role_rank_labels()
end

function AutoBandWindowConfig.refresh_min_rank_dps()
        refresh_role_rank_labels()
end

function AutoBandWindowConfig.refresh_dps_weights()
  LabelSetText(AutoBandWindowConfig.name .. "MaxMdpsValueLabel", L"" .. AutoBand.saved.max_mdps)
  LabelSetText(AutoBandWindowConfig.name .. "MaxRdpsValueLabel", L"" .. AutoBand.saved.max_rdps)
  ButtonSetPressedFlag(AutoBandWindowConfig.name .. "DpsWeightingCheckBox", AutoBand.saved.dps_weighting_enabled)
end

function AutoBandWindowConfig.OnKickCheckBox()
  local enabled = ButtonGetPressedFlag(AutoBandWindowConfig.name .. "KickCheckBox")
  AutoBand.set_autokick_enabled(enabled, { skip_gui_refresh = true })
  ButtonSetPressedFlag(AutoBandWindowConfig.name .. "KickCheckBox", AutoBand.saved.autokick_enabled)
  AutoBandWindowConfig.refresh_autokick_label() -- Ensure label also updates
end

function AutoBandWindowConfig.OnKickToofarCheckBox()
        local enabled = ButtonGetPressedFlag(AutoBandWindowConfig.name .. "KickToofarCheckBox")
        AutoBand.set_autokick_toofar_enabled(enabled, { skip_gui_refresh = true })
end

function AutoBandWindowConfig.OnKickLowRankCheckBox()
  local enabled = ButtonGetPressedFlag(AutoBandWindowConfig.name .. "KickLowRankCheckBox")
  AutoBand.set_autokick_low_rank_enabled(enabled, { skip_gui_refresh = true })
end

function AutoBandWindowConfig.OnKickStealthersCheckBox()
  local enabled = ButtonGetPressedFlag(AutoBandWindowConfig.name .. "KickStealthersCheckBox")
  AutoBand.set_autokick_we_wh_enabled(enabled, { skip_gui_refresh = true })
end

function AutoBandWindowConfig.OnKickRvRZonesCheckBox()
  local enabled = ButtonGetPressedFlag(AutoBandWindowConfig.name .. "KickRvRZonesCheckBox")
  AutoBand.set_autokick_rvrzone_enabled(enabled, { skip_gui_refresh = true })
end

function AutoBandWindowConfig.OnKickIgnoreCheckBox()
    local enabled = ButtonGetPressedFlag(AutoBandWindowConfig.name .. "KickIgnoreCheckBox")
    AutoBand.set_autokick_ignorelist_enabled(enabled, { skip_gui_refresh = true })
end

function AutoBandWindowConfig.OnBackFillCheckBox()
    local enabled = ButtonGetPressedFlag(AutoBandWindowConfig.name .. "BackFillCheckBox")
    AutoBand.set_backfill_enabled(enabled, { skip_gui_refresh = true })
end

function AutoBandWindowConfig.OnBWSorcAsMDPSCheckBox()
  AutoBand.cmd_toggle_bw_sorc_mdps({})
end

function AutoBandWindowConfig.OnRestrictRaceCheckBox()
  AutoBand.cmd_toggle_restrict_race({})
end

function AutoBandWindowConfig.OnCommonRaceNamesCheckBox()
  local enabled = ButtonGetPressedFlag(AutoBandWindowConfig.name .. "CommonRaceNamesCheckBox")
  AutoBand.set_use_common_race_names(enabled)
  LabelSetText(AutoBandWindowConfig.name .. "RestrictRaceLabel", towstring(AB_const.GetRestrictRaceLabel()))
  AutoBandWindowConfig.refresh_common_race_names_control()
end

function AutoBandWindowConfig.OnDpsWeightingCheckBox()
  AutoBand.cmd_toggle_dps_weighting({})
end

function AutoBandWindowConfig.OnPressMaxMdpsPlusButton()
  if AutoBand.saved.max_mdps < AutoBand.saved.max_dps then
    local new_mdps = AutoBand.saved.max_mdps + 1
    local new_rdps = AutoBand.saved.max_dps - new_mdps
    if new_rdps < 0 then -- Prevent rdps from becoming negative
      new_rdps = 0
      new_mdps = AutoBand.saved.max_dps -- MDPS takes all remaining
    end
    AutoBand.cmd_set_dps_weights({tostring(new_mdps), tostring(new_rdps)}, true) -- Pass true for called_from_gui
  else
    -- Optional: AB_util.print("[Info] Max mDPS cannot exceed total Max DPS.")
    AutoBandWindowConfig.refresh_dps_weights() -- Refresh to show current valid state
  end
end

function AutoBandWindowConfig.OnPressMaxMdpsMinusButton()
  local new_mdps = AutoBand.saved.max_mdps - 1
  if new_mdps >= 0 then
    local new_rdps = AutoBand.saved.max_dps - new_mdps
    AutoBand.cmd_set_dps_weights({tostring(new_mdps), tostring(new_rdps)}, true) -- Pass true
  else
    AutoBandWindowConfig.refresh_dps_weights()
  end
end

function AutoBandWindowConfig.OnPressMaxRdpsPlusButton()
  if AutoBand.saved.max_rdps < AutoBand.saved.max_dps then
    local new_rdps = AutoBand.saved.max_rdps + 1
    local new_mdps = AutoBand.saved.max_dps - new_rdps
    if new_mdps < 0 then -- Prevent mdps from becoming negative
      new_mdps = 0
      new_rdps = AutoBand.saved.max_dps -- RDPS takes all remaining
    end
    AutoBand.cmd_set_dps_weights({tostring(new_mdps), tostring(new_rdps)}, true) -- Pass true
  else
    AutoBandWindowConfig.refresh_dps_weights()
  end
end

function AutoBandWindowConfig.OnPressMaxRdpsMinusButton()
  local new_rdps = AutoBand.saved.max_rdps - 1
  if new_rdps >= 0 then
    local new_mdps = AutoBand.saved.max_dps - new_rdps
    AutoBand.cmd_set_dps_weights({tostring(new_mdps), tostring(new_rdps)}, true) -- Pass true
  else
    AutoBandWindowConfig.refresh_dps_weights()
  end
end

function AutoBandWindowConfig.OnResetConfig()
        AutoBand.saved.autokick_enabled = AB_const.AUTOKICK
        AutoBand.saved.autokick_period = AB_const.KICK_PERIOD
        AutoBand.saved.autokick_toofar_enabled = AB_const.AUTOKICKTOOFAR
        AutoBand.saved.autokick_low_rank_enabled = AB_const.KICKLOWRNK
        AutoBand.saved.max_tanks = AB_const.DEFAULT_MAX_TANKS
        AutoBand.saved.max_healers = AB_const.DEFAULT_MAX_HEALERS
        AutoBand.saved.max_dps = AB_const.DEFAULT_MAX_DPS
        AutoBand.saved.guild_priority_enabled = AB_const.GUILDPRIORITY
        AutoBand.saved.guild_priority_mode = AB_const.DEFAULT_GUILD_PRIORITY_MODE
        AutoBand.saved.friend_priority_enabled = false
        AutoBand.saved.friend_priority_mode = AB_const.DEFAULT_FRIEND_PRIORITY_MODE
        AutoBand.saved.guild_grouping_enabled = AB_const.GUILD_GROUPING_ENABLED
        AutoBand.saved.default_template = AB_const.EMPTY_TEMPLATE
        AutoBand.saved.org_algo_mode = AB_const.DEFAULT_ORG_ALGO
        AutoBand.saved.min_rank_tank = AB_const.MINIMUM_RANK_TANK
        AutoBand.saved.min_rank_healer = AB_const.MINIMUM_RANK_HEALER
        AutoBand.saved.min_rank_dps = AB_const.MINIMUM_RANK_DPS
        sync_rank_fields_after_ui_edit()
        AutoBand.saved.displayicon = AutoBand.saved.displayicon
        AutoBand.saved.alt_speccheck_enabled = AB_const.ALTCHECK
        AutoBand.saved.exclude_realm_healer_alt_spec = AB_const.EXCLUDE_REALM_HEALER_ALT_SPEC
        AutoBand.saved.dps_weighting_enabled = AB_const.DPS_WEIGHTING_ENABLED
        AutoBand.saved.max_mdps = AB_const.DEFAULT_MAX_MDPS
        AutoBand.saved.max_rdps = AB_const.DEFAULT_MAX_RDPS
        AutoBand.saved.autokick_we_wh_enabled = AB_const.AUTOKICK_WE_WH
        AutoBand.saved.autokick_rvrzone_enabled = AB_const.AUTOKICKRVRZONE
        AutoBand.saved.bw_sorc_as_mdps = AB_const.BW_SORC_AS_MDPS
        AutoBand.saved.restrict_same_race = AB_const.RESTRICT_RACE
        AutoBand.saved.backfill_enabled = AB_const.BACKFILL
        AutoBand.saved.autokick_ignorelist_enabled = AB_const.AUTOKICK_IGNORELIST
        AutoBandWindowConfig.refresh_autokick_label()
        AB_util.print("Reset ConfigTab-settings to Default.")
        if AutoBand and AutoBand.mark_template_settings_modified then
            AutoBand.mark_template_settings_modified()
        end
        AutoBandWindowConfig.Show()

        if AutoBandWindowTemplate and AutoBandWindowTemplate.refresh_role_limits then
            AutoBandWindowTemplate.refresh_role_limits()
        end
end

function AutoBandWindowConfig.OnAltCheckCheckBox()
        AutoBand.saved.alt_speccheck_enabled = ButtonGetPressedFlag(AutoBandWindowConfig.name .. "AltCheckCheckBox")
        if AutoBand and AutoBand.mark_alt_spec_snapshot_dirty then
            AutoBand.mark_alt_spec_snapshot_dirty()
        end
        AB_util.print("Use alt spec check: " .. tostring(AutoBand.saved.alt_speccheck_enabled))
        if AutoBand and AutoBand.mark_template_settings_modified then
            AutoBand.mark_template_settings_modified()
        end
        AutoBand.need_role_update = true
        refresh_exclude_realm_healer_alt_spec_label()
end

function AutoBandWindowConfig.OnExcludeRealmHealerAltSpecCheckBox()
    if not AutoBand.saved.alt_speccheck_enabled then
        refresh_exclude_realm_healer_alt_spec_label()
        return
    end
    AutoBand.saved.exclude_realm_healer_alt_spec = ButtonGetPressedFlag(AutoBandWindowConfig.name .. "ExcludeRealmHealerAltSpecCheckBox")
    if AutoBand and AutoBand.mark_alt_spec_snapshot_dirty then
        AutoBand.mark_alt_spec_snapshot_dirty()
    end
    AB_util.print(AB_const.GetExcludeRealmHealerAltSpecLabel() .. " from alt spec check: " .. tostring(AutoBand.saved.exclude_realm_healer_alt_spec))
    if AutoBand and AutoBand.mark_template_settings_modified then
        AutoBand.mark_template_settings_modified()
    end
    AutoBand.need_role_update = true
    refresh_exclude_realm_healer_alt_spec_label()
end

function AutoBandWindowConfig.OnGuildPriorityModeButton()
        AutoBand.set_guild_priority_mode(
            next_social_priority_mode(AutoBand.get_saved_social_priority_mode("guild"))
        )
end

function AutoBandWindowConfig.OnFriendPriorityModeButton()
        AutoBand.set_friend_priority_mode(
            next_social_priority_mode(AutoBand.get_saved_social_priority_mode("friend"))
        )
end

function AutoBandWindowConfig.OnPressGuildPriorityPlusButton()
        AutoBandWindowConfig.OnGuildPriorityModeButton()
end

function AutoBandWindowConfig.OnPressGuildPriorityMinusButton()
        AutoBand.set_guild_priority_mode(
            previous_social_priority_mode(AutoBand.get_saved_social_priority_mode("guild"))
        )
end

function AutoBandWindowConfig.OnPressFriendPriorityPlusButton()
        AutoBandWindowConfig.OnFriendPriorityModeButton()
end

function AutoBandWindowConfig.OnPressFriendPriorityMinusButton()
        AutoBand.set_friend_priority_mode(
            previous_social_priority_mode(AutoBand.get_saved_social_priority_mode("friend"))
        )
end

function AutoBandWindowConfig.OnGuildGroupingCheckBox()
        AutoBand.set_guild_grouping_enabled(
            ButtonGetPressedFlag(AutoBandWindowConfig.name .. "GuildGroupingCheckBox")
        )
end

function AutoBandWindowConfig.refresh_autokick_label()
    -- Construct the dynamic composition part first
    local composition_string = towstring(AutoBand.saved.max_tanks) .. L"-" .. towstring(AutoBand.saved.max_healers) .. L"-" .. towstring(AutoBand.saved.max_dps)
    -- Update Auto Kick Label
    local autokick_label_text = L"Auto enforce " .. composition_string .. L" WB"
    LabelSetText(AutoBandWindowConfig.name .. "AutoKickLabel", autokick_label_text)
    -- Update DPS Weighting Label (Added)
    local dpsweight_label_text = L"DPS Weight when " .. composition_string
    LabelSetText(AutoBandWindowConfig.name .. "DpsWeightingLabel", dpsweight_label_text)
    -- Also refresh the checkbox state
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "KickCheckBox", AutoBand.saved.autokick_enabled)
end

function AutoBandWindowConfig.refresh_autokick_controls()
    AutoBandWindowConfig.refresh_kickoff()
    AutoBandWindowConfig.refresh_autokick_label()
    LabelSetText(AutoBandWindowConfig.name .. "AutoKickStealthersLabel", towstring(AB_const.GetAutoKickStealthersLabel("AKick")))
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "KickToofarCheckBox", AutoBand.saved.autokick_toofar_enabled)
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "KickLowRankCheckBox", AutoBand.saved.autokick_low_rank_enabled)
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "KickStealthersCheckBox", AutoBand.saved.autokick_we_wh_enabled)
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "KickRvRZonesCheckBox", AutoBand.saved.autokick_rvrzone_enabled)
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "KickIgnoreCheckBox", AutoBand.saved.autokick_ignorelist_enabled)
    LabelSetText(AutoBandWindowConfig.name .. "RestrictRaceLabel", towstring(AB_const.GetRestrictRaceLabel()))
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "RestrictRaceCheckBox", AutoBand.saved.restrict_same_race)
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "CommonRaceNamesCheckBox", AutoBand.saved.use_common_race_names)
    AutoBandWindowConfig.refresh_common_race_names_control()
    ButtonSetPressedFlag(AutoBandWindowConfig.name .. "BackFillCheckBox", AutoBand.saved.backfill_enabled)
    WindowSetShowing(AutoBandWindowConfig.name .. "SocialLabel", false)
    AutoBandWindowConfig.refresh_social_controls()
end

-- Helper function to be called by label click handlers
function AutoBandWindowConfig.GenericLabelClickHandler(checkboxRelativeName, originalCheckboxHandlerFunction)
    local checkboxFullName = AutoBandWindowConfig.name .. checkboxRelativeName
    PlaySound(GameData.Sound.BUTTON_CLICK)
    -- 1. Toggle the checkbox's visual state
    ButtonSetPressedFlag(checkboxFullName, not ButtonGetPressedFlag(checkboxFullName))
    -- 2. Call the original handler function that the checkbox itself uses
    if originalCheckboxHandlerFunction then
        originalCheckboxHandlerFunction()
    end
end

-- Specific label click handlers
function AutoBandWindowConfig.OnClickAutoKickLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("KickCheckBox", AutoBandWindowConfig.OnKickCheckBox)
end

function AutoBandWindowConfig.OnClickDpsWeightingLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("DpsWeightingCheckBox", AutoBandWindowConfig.OnDpsWeightingCheckBox)
end

function AutoBandWindowConfig.OnClickKickToofarLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("KickToofarCheckBox", AutoBandWindowConfig.OnKickToofarCheckBox)
end

function AutoBandWindowConfig.OnClickKickLowRankLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("KickLowRankCheckBox", AutoBandWindowConfig.OnKickLowRankCheckBox)
end

function AutoBandWindowConfig.OnClickKickStealthersLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("KickStealthersCheckBox", AutoBandWindowConfig.OnKickStealthersCheckBox)
end

function AutoBandWindowConfig.OnClickKickRvRZonesLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("KickRvRZonesCheckBox", AutoBandWindowConfig.OnKickRvRZonesCheckBox)
end

function AutoBandWindowConfig.OnClickBWSorcAsMDPSLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("BWSorcAsMDPSCheckBox", AutoBandWindowConfig.OnBWSorcAsMDPSCheckBox)
end

function AutoBandWindowConfig.OnClickRestrictRaceLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("RestrictRaceCheckBox", AutoBandWindowConfig.OnRestrictRaceCheckBox)
end

function AutoBandWindowConfig.OnClickCommonRaceNamesLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("CommonRaceNamesCheckBox", AutoBandWindowConfig.OnCommonRaceNamesCheckBox)
end

function AutoBandWindowConfig.OnClickBackFillLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("BackFillCheckBox", AutoBandWindowConfig.OnBackFillCheckBox)
end

local function get_tooltip_window_name()
    local window_name = nil
    if SystemData and SystemData.ActiveWindow and SystemData.ActiveWindow.name then
        window_name = SystemData.ActiveWindow.name
    elseif SystemData and SystemData.MouseOverWindow and SystemData.MouseOverWindow.name then
        window_name = SystemData.MouseOverWindow.name
    end
    return window_name
end

local function get_tooltip_font_linespacing()
    if type(WindowUtils) == "table" and tonumber(WindowUtils.FONT_DEFAULT_TEXT_LINESPACING) ~= nil then
        return tonumber(WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
    end
    return 20
end

local function apply_small_tooltip_font()
    if type(LabelSetFont) ~= "function" then
        return
    end
    local linespacing = get_tooltip_font_linespacing()
    LabelSetFont("DefaultTooltipRow1Col1Text", "font_clear_small", linespacing)
    LabelSetFont("DefaultTooltipRow1Col2Text", "font_clear_small", linespacing)
    LabelSetFont("DefaultTooltipRow1Col3Text", "font_clear_small", linespacing)
end

local function restore_tooltip_font()
    if type(LabelSetFont) ~= "function" then
        return
    end
    local linespacing = get_tooltip_font_linespacing()
    LabelSetFont("DefaultTooltipRow1Col1Text", "font_default_text", linespacing)
    LabelSetFont("DefaultTooltipRow1Col2Text", "font_default_text", linespacing)
    LabelSetFont("DefaultTooltipRow1Col3Text", "font_default_text", linespacing)
end

local function build_too_far_tooltip_text()
    return L"Kick players who are too far away.\nProtect/Promote priority is excluded."
end

local SETTING_TOOLTIPS = {
    DefaultLabel = L"Used by /ab org when no template is named.",
    DefaultTemplateLabel = L"Used by /ab org when no template is named.",
    ComboBoxLabel = L"Spread evens roles out. Aggregate packs fuller groups.",
    ComboBox = L"Spread evens roles out. Aggregate packs fuller groups.",
    AutoKickLabel = L"Enforces the tank, healer, and DPS role caps.",
    KickCheckBox = L"Enforces the tank, healer, and DPS role caps.",
    DpsWeightingLabel = L"Splits DPS into separate mDPS and rDPS caps.",
    DpsWeightingCheckBox = L"Splits DPS into separate mDPS and rDPS caps.",
    MaxMdpsLabel = L"Adjusts the mDPS share of the DPS cap.",
    MaxMdpsValueLabel = L"Adjusts the mDPS share of the DPS cap.",
    ButtonPlusMaxMdps = L"Adjusts the mDPS share of the DPS cap.",
    ButtonMinusMaxMdps = L"Adjusts the mDPS share of the DPS cap.",
    MaxRdpsLabel = L"Adjusts the rDPS share of the DPS cap.",
    MaxRdpsValueLabel = L"Adjusts the rDPS share of the DPS cap.",
    ButtonPlusMaxRdps = L"Adjusts the rDPS share of the DPS cap.",
    ButtonMinusMaxRdps = L"Adjusts the rDPS share of the DPS cap.",
    AutoKickToofarLabel = build_too_far_tooltip_text,
    KickToofarCheckBox = build_too_far_tooltip_text,
    KickTimeLabel = L"Minutes before too-far kicks.",
    AutoKickTimeoutLabel = L"Minutes before too-far kicks.",
    ButtonPlusTime = L"Minutes before too-far kicks.",
    ButtonMinusTime = L"Minutes before too-far kicks.",
    AutoKickStealthersLabel = function()
        return AB_const.GetAutoKickStealthersLabel("Kick") .. "."
    end,
    KickStealthersCheckBox = function()
        return AB_const.GetAutoKickStealthersLabel("Kick") .. "."
    end,
    AutoKickRvRZonesLabel = L"Kicks members outside RvR or city zones.",
    KickRvRZonesCheckBox = L"Kicks members outside RvR or city zones.",
    BWSorcAsMDPSLabel = function()
        return "Treats " .. tostring(AB_const.GetBWSorcAsMDPSLabel()) .. " for role checks."
    end,
    BWSorcAsMDPSCheckBox = function()
        return "Treats " .. tostring(AB_const.GetBWSorcAsMDPSLabel()) .. " for role checks."
    end,
    RestrictRaceLabel = L"Only your race is allowed in the warband.",
    RestrictRaceCheckBox = L"Only your race is allowed in the warband.",
    AltCheckLabel = L"Adjusts some careers by spec when assigning roles.",
    AltCheckCheckBox = L"Adjusts some careers by spec when assigning roles.",
    SocialLabel = L"Controls guild/friend trim priority, promote displacement, and grouping guildies together during organize.",
    GuildPriorityLabel = L"Prioritize guildies.\nPrefer = kick others first.\nProtect = ignore rank reqs.\nPromote = replaces newest non-guildie.",
    GuildPriorityValueLabel = L"Prioritize guildies.\nPrefer = kick others first.\nProtect = ignore rank reqs.\nPromote = replaces newest non-guildie.",
    ButtonPlusGuildPriority = L"Prioritize guildies.\nPrefer = kick others first.\nProtect = ignore rank reqs.\nPromote = replaces newest non-guildie.",
    ButtonMinusGuildPriority = L"Prioritize guildies.\nPrefer = kick others first.\nProtect = ignore rank reqs.\nPromote = replaces newest non-guildie.",
    FriendPriorityLabel = L"Prioritize friends.\nPrefer = kick others first.\nProtect = ignore rank reqs.\nPromote = replaces newest non-friend.",
    FriendPriorityValueLabel = L"Prioritize friends.\nPrefer = kick others first.\nProtect = ignore rank reqs.\nPromote = replaces newest non-friend.",
    ButtonPlusFriendPriority = L"Prioritize friends.\nPrefer = kick others first.\nProtect = ignore rank reqs.\nPromote = replaces newest non-friend.",
    ButtonMinusFriendPriority = L"Prioritize friends.\nPrefer = kick others first.\nProtect = ignore rank reqs.\nPromote = replaces newest non-friend.",
    GuildGroupingLabel = L"Groups guildies together while organizing.",
    GuildGroupingCheckBox = L"Groups guildies together while organizing.",
    KickIgnoreLabel = L"Kicks players on your ignore list.",
    KickIgnoreCheckBox = L"Kicks players on your ignore list.",
}

local function get_setting_tooltip_text()
    local window_name = get_tooltip_window_name()
    if not window_name or window_name == "" then
        return nil
    end

    local prefix = AutoBandWindowConfig.name
    if string.sub(window_name, 1, #prefix) ~= prefix then
        return nil
    end

    local key = string.sub(window_name, #prefix + 1)
    local tooltip_value = SETTING_TOOLTIPS[key]
    if type(tooltip_value) == "function" then
        return tooltip_value()
    end
    return tooltip_value
end

local function show_text_tooltip(tooltip_text)
    if type(Tooltips) ~= "table" or type(Tooltips.CreateTextOnlyTooltip) ~= "function" then
        return
    end
    local window_name = get_tooltip_window_name()
    if not window_name or window_name == "" then
        return
    end
    local tooltip_value = tooltip_text
    if type(tooltip_value) == "string" then
        tooltip_value = towstring(tooltip_value)
    end
    if type(Tooltips.SetTooltipText) == "function" then
        Tooltips.CreateTextOnlyTooltip(window_name)
        apply_small_tooltip_font()
        Tooltips.SetTooltipText(1, 1, tooltip_value)
        if type(Tooltips.Finalize) == "function" then
            Tooltips.Finalize()
        end
    else
        Tooltips.CreateTextOnlyTooltip(window_name, tooltip_value)
    end
    if type(Tooltips.AnchorTooltip) == "function" then
        Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_TOP)
    end
end

local function hide_text_tooltip()
    if type(Tooltips) ~= "table" or type(Tooltips.DestroyTooltip) ~= "function" then
        return
    end
    local window_name = get_tooltip_window_name()
    if not window_name or window_name == "" then
        return
    end
    restore_tooltip_font()
    Tooltips.DestroyTooltip(window_name)
end

local function build_rankreq_tooltip_text(base_text)
    local text = base_text
    local rr_allowed, _ = can_use_rr_requirements_from_ui()
    if rr_allowed ~= true then
        text = text .. L"\nRR offline: 45+ locked."
    end
    return text
end

function AutoBandWindowConfig.OnKickLowRankMouseOver()
    show_text_tooltip(L"Turns rank checks on or off.")
end

function AutoBandWindowConfig.OnKickLowRankMouseOverEnd()
    hide_text_tooltip()
end

function AutoBandWindowConfig.OnRankReqMouseOver()
    show_text_tooltip(build_rankreq_tooltip_text(L"Tank minimum rank.\n1-40 checks CR.\n45-70 checks RR."))
end

function AutoBandWindowConfig.OnRankReqMouseOverEnd()
    hide_text_tooltip()
end

function AutoBandWindowConfig.OnHealerRankReqMouseOver()
    show_text_tooltip(build_rankreq_tooltip_text(L"Healer minimum rank.\n1-40 checks CR.\n45-70 checks RR."))
end

function AutoBandWindowConfig.OnHealerRankReqMouseOverEnd()
    hide_text_tooltip()
end

function AutoBandWindowConfig.OnDpsRankReqMouseOver()
    show_text_tooltip(build_rankreq_tooltip_text(L"DPS minimum rank.\nApplies to both melee and ranged DPS.\n1-40 checks CR.\n45-70 checks RR."))
end

function AutoBandWindowConfig.OnDpsRankReqMouseOverEnd()
    hide_text_tooltip()
end

function AutoBandWindowConfig.OnBackFillMouseOver()
    show_text_tooltip(L"Fills fast first, then trims newest extras as needed roles or ranks arrive.")
end

function AutoBandWindowConfig.OnBackFillMouseOverEnd()
    hide_text_tooltip()
end

function AutoBandWindowConfig.OnCommonRaceNamesMouseOver()
    show_text_tooltip(build_common_race_names_tooltip_text())
end

function AutoBandWindowConfig.OnCommonRaceNamesMouseOverEnd()
    hide_text_tooltip()
end

function AutoBandWindowConfig.OnExcludeRealmHealerAltSpecMouseOver()
    local tooltip_text = L"Excludes Runepriests from Alt-Spec check"
    if AutoBand and AutoBand.faction == AB_const.DESTRUCTION then
        tooltip_text = L"Excludes Zealots from Alt-Spec check"
    elseif AutoBand and AutoBand.faction ~= AB_const.ORDER then
        tooltip_text = L"Excludes Runepriests/Zealots from Alt-Spec check"
    end

    show_text_tooltip(tooltip_text)
end

function AutoBandWindowConfig.OnExcludeRealmHealerAltSpecMouseOverEnd()
    hide_text_tooltip()
end

function AutoBandWindowConfig.OnSettingMouseOver()
    local tooltip_text = get_setting_tooltip_text()
    if tooltip_text then
        show_text_tooltip(tooltip_text)
    end
end

function AutoBandWindowConfig.OnSettingMouseOverEnd()
    hide_text_tooltip()
end

function AutoBandWindowConfig.OnClickAltCheckLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("AltCheckCheckBox", AutoBandWindowConfig.OnAltCheckCheckBox)
end

function AutoBandWindowConfig.OnClickExcludeRealmHealerAltSpecLabel()
    if not AutoBand.saved.alt_speccheck_enabled then
        return
    end
    AutoBandWindowConfig.GenericLabelClickHandler("ExcludeRealmHealerAltSpecCheckBox", AutoBandWindowConfig.OnExcludeRealmHealerAltSpecCheckBox)
end

function AutoBandWindowConfig.OnClickGuildPriorityLabel()
    AutoBandWindowConfig.OnGuildPriorityModeButton()
end

function AutoBandWindowConfig.OnClickFriendPriorityLabel()
    AutoBandWindowConfig.OnFriendPriorityModeButton()
end

function AutoBandWindowConfig.OnClickGuildGroupingLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("GuildGroupingCheckBox", AutoBandWindowConfig.OnGuildGroupingCheckBox)
end

function AutoBandWindowConfig.OnClickKickIgnoreLabel()
    AutoBandWindowConfig.GenericLabelClickHandler("KickIgnoreCheckBox", AutoBandWindowConfig.OnKickIgnoreCheckBox)
end

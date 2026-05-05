-- AutoBand tools tab UI bindings.
AutoBandWindowTools = {}

AutoBandWindowTools.name = "AutoBandWindowToolsTab"

AutoBandWindowTools.tools_data = {
        [AB_const.KICK_OFFLINE] = { ["button"] = "KickOfflineCheckBox" , ["label"] = "KickOfflineLabel", ["func_kick"]= AutoBand.cmd_kick_toofar, ["func_print"] = AutoBand.cmd_list_offline},
        [AB_const.KICK_ZONE] = { ["button"] = "KickZoneCheckBox" , ["label"] = "KickZoneLabel", ["func_kick"]= AutoBand.cmd_kick_notinzone, ["func_print"] = AutoBand.cmd_list_zone},
        [AB_const.KICK_RANK] = { ["button"] = "KickRankCheckBox" , ["label"] = "KickRankLabel", ["func_kick"]= AutoBand.cmd_kick_rank, ["func_print"] = AutoBand.cmd_list_rank} }

local function set_checkbox_enabled_with_label_color(checkbox_name, label_name, enabled)
    if type(ButtonSetDisabledFlag) == "function" then
        ButtonSetDisabledFlag(checkbox_name, not enabled)
    end
    if type(LabelSetTextColor) == "function" then
        if enabled then
            LabelSetTextColor(label_name, 225, 225, 225)
        else
            LabelSetTextColor(label_name, 150, 150, 150)
        end
    end
end

local function get_realmstats_buttons_state()
    if type(AutoBand.cmd_stats) ~= "function" then
        return false, "cmd_missing"
    end

    if type(AutoBand.is_realmrank_soft_disabled) == "function" and AutoBand.is_realmrank_soft_disabled() then
        return false, "soft_disabled"
    end

    if type(AutoBand.get_realmrank_snapshot_state) == "function" then
        local snapshot_state = AutoBand.get_realmrank_snapshot_state(true, { cache_first = true })
        if type(snapshot_state) == "table" and snapshot_state.status == "ok" then
            return true, "ok"
        end
        if type(snapshot_state) == "table" and type(snapshot_state.status) == "string" then
            return false, snapshot_state.status
        end
        return false, "csv_unavailable"
    end

    local loaded = false
    if type(AutoBand.ensure_realmrank_snapshot_loaded) == "function" then
        loaded = AutoBand.ensure_realmrank_snapshot_loaded(false) == true
    end
    local has_rows = type(AutoBand.realmrank_lookup) == "table" and next(AutoBand.realmrank_lookup) ~= nil
    if not loaded and not has_rows then
        return false, "csv_unavailable"
    end
    if AutoBand.is_realmrank_data_stale and AutoBand.is_realmrank_data_stale() == true then
        return false, "csv_stale"
    end
    return true, "ok"
end

local function realmstats_disabled_tooltip_text_for_status(status)
    if status == "csv_stale" or status == "stale" then
        return "RR CSV stale. Use /ab csvrefresh."
    end
    if status == "csv_unavailable" or status == "csv_empty" or status == "unavailable" or status == "empty" then
        return "RR CSV unavailable. Use /ab csvrefresh."
    end
    if status == "soft_disabled" then
        return "RR data unavailable right now."
    end
    if status == "cmd_missing" then
        return "Realmstats unavailable in this build."
    end
    return "RR data unavailable. Use /ab csvrefresh."
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

local function maybe_show_realmstats_disabled_tooltip(button_name)
    local button_full_name = AutoBandWindowTools.name .. button_name
    if type(ButtonGetDisabledFlag) ~= "function" or ButtonGetDisabledFlag(button_full_name) ~= true then
        return
    end
    local text = AutoBandWindowTools.realmstats_disabled_tooltip_text
    if type(text) ~= "string" or text == "" then
        text = "RR CSV unavailable. Use /ab csvrefresh."
    end
    show_text_tooltip(text)
end

local function build_discord_req_tooltip_text()
    return "Adds 'Discord req.' to search ads."
end

local function build_no_mic_tooltip_text()
    return "Adds '(no mic needed)' after Discord req."
end

local function build_too_far_tooltip_text()
    return "Kick players who are too far away.\nProtect/Promote priority is excluded."
end

function AutoBandWindowTools.RefreshRealmstatsButtons()
    local available, status = get_realmstats_buttons_state()
    local disabled = not available
    ButtonSetDisabledFlag(AutoBandWindowTools.name .. "StatsButton", disabled)
    ButtonSetDisabledFlag(AutoBandWindowTools.name .. "StatsBreakdownButton", disabled)
    AutoBandWindowTools.realmstats_disabled_tooltip_text = realmstats_disabled_tooltip_text_for_status(status)
    if type(WindowSetShowing) == "function" then
        WindowSetShowing(AutoBandWindowTools.name .. "StatsButtonDisabledHover", disabled)
        WindowSetShowing(AutoBandWindowTools.name .. "StatsBreakdownButtonDisabledHover", disabled)
    end
    return available
end

function AutoBandWindowTools.RefreshSearchDiscordControls()
    local discord_checkbox_name = AutoBandWindowTools.name .. "DiscordReqCheckBox"
    local no_mic_checkbox_name = AutoBandWindowTools.name .. "NoMicCheckBox"
    local no_mic_label_name = AutoBandWindowTools.name .. "NoMicLabel"
    local discord_enabled = AutoBand.saved and AutoBand.saved.search_discord_req_enabled == true
    local no_mic_enabled = AutoBand.saved and AutoBand.saved.search_no_mic_enabled == true

    ButtonSetPressedFlag(discord_checkbox_name, discord_enabled)
    ButtonSetPressedFlag(no_mic_checkbox_name, no_mic_enabled)
    set_checkbox_enabled_with_label_color(no_mic_checkbox_name, no_mic_label_name, discord_enabled)
end


function AutoBandWindowTools.Initialize()
        LabelSetText(AutoBandWindowTools.name .. "KickLabel", L"Manage Players")

        for fid, func in pairs(AutoBandWindowTools.tools_data) do
                LabelSetText(AutoBandWindowTools.name .. func["label"], towstring(AB_const.LABEL_KICK[fid]))
                ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. func["button"], true)
                ButtonSetPressedFlag(AutoBandWindowTools.name .. func["button"], AutoBand.saved.kick_func_enabled[fid])
        end

        ButtonSetText(AutoBandWindowTools.name .. "PrintButton", L"Print")
        ButtonSetText(AutoBandWindowTools.name .. "KickButton", L"Kick")

        LabelSetText(AutoBandWindowTools.name .. "SearchRoleLabel", L"Manual Search for Players")
        LabelSetText(AutoBandWindowTools.name .. "SearchRoleChan1Label", L"Manual Search in /1 (region)")
        LabelSetText(AutoBandWindowTools.name .. "SearchRoleChanT4Label", L"Manual Search in /t4")
        LabelSetText(AutoBandWindowTools.name .. "SearchRoleChan5Label", L"Manual Search in /5 (lfg)")

        ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. "SearchRoleChan1CheckBox", true) -- Enable check button behavior
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "SearchRoleChan1CheckBox", true)  -- Check it
        -- ButtonSetDisabledFlag(AutoBandWindowTools.name .. "SearchRoleChan1CheckBox", true)  -- Disable it

        ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. "SearchRoleChanT4CheckBox", true) -- Enable check button behavior
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "SearchRoleChanT4CheckBox", false)  -- Default unchecked

        ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. "SearchRoleChan5CheckBox", true) -- Enable check button behavior
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "SearchRoleChan5CheckBox", false)  -- Default unchecked

        ButtonSetText(AutoBandWindowTools.name .. "SearchRoleButton", L"Manual Search")
        ButtonSetText(AutoBandWindowTools.name .. "FormWarbandButton", L"Form WB")

        LabelSetText(AutoBandWindowTools.name .. "AutoSearchLabel", L"Auto Search in /1 every 5 mins")
        ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. "AutoSearchCheckBox", true)
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "AutoSearchCheckBox", AutoBand.saved.autonote_enabled)

        LabelSetText(AutoBandWindowTools.name .. "AutoPartyNoteLabel", L"Auto Update /partynote for WB")
        ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. "AutoPartyNoteCheckBox", true)
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "AutoPartyNoteCheckBox", AutoBand.saved.autopartynote_enabled)

        ButtonSetText(AutoBandWindowTools.name .. "OrganizeButton", L"Organize WB")
        ButtonSetText(AutoBandWindowTools.name .. "OrganizeRangeButton", L"Organize WB (distance)")
        ButtonSetText(AutoBandWindowTools.name .. "StatsButton", L"Realmstats")
        ButtonSetText(AutoBandWindowTools.name .. "StatsBreakdownButton", L"Realmstats breakdown")

        LabelSetText(AutoBandWindowTools.name .. "NotifyBuffsLabel", L"Notify WB after Organize")
        ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. "NotifyBuffsCheckBox", true) -- Enable check button behavior

        LabelSetText(AutoBandWindowTools.name .. "PrintRoleLabel", L"Print Role Assignments")
        ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. "PrintRoleCheckBox", true) -- Enable check button behavior

        LabelSetText(AutoBandWindowTools.name .. "DiscordReqLabel", L"Append \"Discord req\"")
        ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. "DiscordReqCheckBox", true)
        LabelSetText(AutoBandWindowTools.name .. "NoMicLabel", L"No mic")
        ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. "NoMicCheckBox", true)
        AutoBandWindowTools.RefreshSearchDiscordControls()

        LabelSetText(AutoBandWindowTools.name .. "AutoFormSearchLabel", L"Autoform WB on search if needed")
        ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. "AutoFormSearchCheckBox", true)

        LabelSetText(AutoBandWindowTools.name .. "RightClickOrganizeLabel", L"RClick Icon to Organize")
        ButtonSetCheckButtonFlag(AutoBandWindowTools.name .. "RightClickOrganizeCheckBox", true) -- Enable check button behavior
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "RightClickOrganizeCheckBox", AutoBand.saved.right_click_organize)

        -- Button bar
        ButtonSetText(AutoBandWindowTools.name .. "ResetButton", L"Restore Defaults")
        AutoBandWindowTools.RefreshRealmstatsButtons()
end

function AutoBandWindowTools.Shutdown()
end


function AutoBandWindowTools.Hide()
        WindowSetShowing(AutoBandWindowTools.name, false)
end


function AutoBandWindowTools.Show()
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "AutoSearchCheckBox", AutoBand.saved.autonote_enabled)
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "AutoPartyNoteCheckBox", AutoBand.saved.autopartynote_enabled)
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "NotifyBuffsCheckBox", AutoBand.saved.notify_buffs_enabled)
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "RightClickOrganizeCheckBox", AutoBand.saved.right_click_organize)
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "PrintRoleCheckBox", AutoBand.saved.printrole_enabled)
        AutoBandWindowTools.RefreshSearchDiscordControls()
        ButtonSetPressedFlag(AutoBandWindowTools.name .. "AutoFormSearchCheckBox", AutoBand.saved.autoform_search_enabled)
        AutoBandWindowTools.RefreshRealmstatsButtons()
        WindowSetShowing(AutoBandWindowTools.name, true)
end


function AutoBandWindowTools.reset_kick_enabled()
        for fid, func in pairs(AutoBandWindowTools.tools_data) do
                ButtonSetPressedFlag(AutoBandWindowTools.name .. func["button"], AB_const.KICK_FUNC_DEFAULT[fid])
                AutoBand.saved.kick_func_enabled[fid] = AB_const.KICK_FUNC_DEFAULT[fid]
        end
end


function AutoBandWindowTools.OnKickOfflineCheckBox()
        AutoBand.saved.kick_func_enabled[AB_const.KICK_OFFLINE] = ButtonGetPressedFlag(AutoBandWindowTools.name .. "KickOfflineCheckBox")
end


function AutoBandWindowTools.OnKickZoneCheckBox()
        AutoBand.saved.kick_func_enabled[AB_const.KICK_ZONE] = ButtonGetPressedFlag(AutoBandWindowTools.name .. "KickZoneCheckBox")
end


function AutoBandWindowTools.OnKickRankCheckBox()
        AutoBand.saved.kick_func_enabled[AB_const.KICK_RANK] = ButtonGetPressedFlag(AutoBandWindowTools.name .. "KickRankCheckBox")
end


function AutoBandWindowTools.OnKickButton()
        for fid, kick_func in pairs(AutoBandWindowTools.tools_data) do
                -- to make sure that you read the values from check boxes
                AutoBand.saved.kick_func_enabled[fid] = ButtonGetPressedFlag(AutoBandWindowTools.name .. kick_func["button"])
                if (AutoBand.saved.kick_func_enabled[fid]) then
                        kick_func.func_kick()
                end
        end
end

function AutoBandWindowTools.OnPrintButton()
        AB_util.print("Warband Report ")
        for fid, kick_func in pairs(AutoBandWindowTools.tools_data) do
                -- to make sure that you read the values from check boxes
                AutoBand.saved.kick_func_enabled[fid] = ButtonGetPressedFlag(AutoBandWindowTools.name .. kick_func["button"])
                if (AutoBand.saved.kick_func_enabled[fid]) then
                        kick_func.func_print()
                end
        end
end

function AutoBandWindowTools.OnOrganizeButton()
  -- Call the existing command function directly
  AutoBand.cmd_organize({}) -- Pass empty args table
end

function AutoBandWindowTools.OnOrganizeRangeButton()
  AutoBand.cmd_organize({"distance"}) -- Pass "distance" as the first argument in a table
end

function AutoBandWindowTools.OnStatsButton()
  if not AutoBandWindowTools.RefreshRealmstatsButtons() then
    return
  end
  AutoBand.cmd_stats({})
end

local function get_online_monitor_group_count_for_stats_right_click()
  if type(AutoBand.get_online_monitor_count) == "function" then
    local count = tonumber(AutoBand.get_online_monitor_count())
    if count ~= nil and count > 0 then
      return math.floor(count)
    end
    return 0
  end

  if type(AutoBand.online_monitor_groups) ~= "table" then
    return 0
  end

  local count = 0
  for key, _ in pairs(AutoBand.online_monitor_groups) do
    if type(key) == "string" and key ~= "" then
      count = count + 1
    end
  end
  return count
end

function AutoBandWindowTools.OnStatsButtonRightClick()
  if not AutoBandWindowTools.RefreshRealmstatsButtons() then
    return
  end
  if type(AutoBand.cmd_online) ~= "function" then
    return
  end
  if get_online_monitor_group_count_for_stats_right_click() <= 0 then
    return
  end
  AutoBand.cmd_online({})
end

function AutoBandWindowTools.OnStatsBreakdownButton()
  if not AutoBandWindowTools.RefreshRealmstatsButtons() then
    return
  end
  AutoBand.cmd_stats({"breakdown"})
end

function AutoBandWindowTools.OnStatsBreakdownButtonRightClick()
  if not AutoBandWindowTools.RefreshRealmstatsButtons() then
    return
  end
  AutoBand.cmd_stats({"breakdown", "detailed"})
end

function AutoBandWindowTools.OnStatsButtonMouseOver()
  maybe_show_realmstats_disabled_tooltip("StatsButton")
end

function AutoBandWindowTools.OnStatsButtonMouseOverEnd()
  hide_text_tooltip()
end

function AutoBandWindowTools.OnStatsBreakdownButtonMouseOver()
  maybe_show_realmstats_disabled_tooltip("StatsBreakdownButton")
end

function AutoBandWindowTools.OnStatsBreakdownButtonMouseOverEnd()
  hide_text_tooltip()
end

function AutoBandWindowTools.OnDiscordReqMouseOver()
  show_text_tooltip(build_discord_req_tooltip_text())
end

function AutoBandWindowTools.OnDiscordReqMouseOverEnd()
  hide_text_tooltip()
end

function AutoBandWindowTools.OnNoMicMouseOver()
  show_text_tooltip(build_no_mic_tooltip_text())
end

function AutoBandWindowTools.OnNoMicMouseOverEnd()
  hide_text_tooltip()
end

function AutoBandWindowTools.OnKickOfflineMouseOver()
  show_text_tooltip(build_too_far_tooltip_text())
end

function AutoBandWindowTools.OnKickOfflineMouseOverEnd()
  hide_text_tooltip()
end

function AutoBandWindowTools.OnNotifyBuffsCheckBox()
  -- Call the existing command function which handles toggling and feedback
  AutoBand.cmd_toggle_buffnotify({})
end

function AutoBandWindowTools.OnRightClickOrganizeCheckBox()
  -- Call the existing command function which handles toggling and feedback
  AutoBand.cmd_toggle_rco({})
end

function AutoBandWindowTools.OnPrintRoleCheckBox()
  -- Call the existing command function which handles toggling and feedback
  AutoBand.cmd_flag_printrole({})
end

function AutoBandWindowTools.OnAutoFormSearchCheckBox()
    AutoBand.cmd_toggle_autoform_search({})
end

function AutoBandWindowTools.OnDiscordReqCheckBox()
    AutoBand.saved.search_discord_req_enabled = ButtonGetPressedFlag(AutoBandWindowTools.name .. "DiscordReqCheckBox")
    AB_util.print("Append \"Discord req\" to searches: " .. tostring(AutoBand.saved.search_discord_req_enabled))
    if AutoBand and AutoBand.mark_template_settings_modified then
        AutoBand.mark_template_settings_modified()
    end
    AutoBandWindowTools.RefreshSearchDiscordControls()
end

function AutoBandWindowTools.OnNoMicCheckBox()
    local checkbox_name = AutoBandWindowTools.name .. "NoMicCheckBox"
    if type(ButtonGetDisabledFlag) == "function" and ButtonGetDisabledFlag(checkbox_name) == true then
        return
    end
    AutoBand.saved.search_no_mic_enabled = ButtonGetPressedFlag(checkbox_name)
    AB_util.print("Append \"no mic needed\" to searches: " .. tostring(AutoBand.saved.search_no_mic_enabled))
    if AutoBand and AutoBand.mark_template_settings_modified then
        AutoBand.mark_template_settings_modified()
    end
end

function AutoBandWindowTools.OnSearchRoleButton()
  local args = {} -- Table to hold the channel arguments

        if ButtonGetPressedFlag(AutoBandWindowTools.name .. "SearchRoleChan1CheckBox") then
                table.insert(args, "1")
        end

  if ButtonGetPressedFlag(AutoBandWindowTools.name .. "SearchRoleChanT4CheckBox") then
    table.insert(args, "t4")
  end

  if ButtonGetPressedFlag(AutoBandWindowTools.name .. "SearchRoleChan5CheckBox") then
    table.insert(args, "5")
  end

  AutoBand.cmd_search_roles(args)
end

function AutoBandWindowTools.OnFormWarbandButton()
    AutoBand.cmd_form({})
end

function AutoBandWindowTools.OnAutoSearchCheckBox()
        -- Call the existing command function which toggles the setting and prints feedback
        AutoBand.cmd_flag_autonote({})
end

function AutoBandWindowTools.OnAutoPartyNoteCheckBox()
    AutoBand.cmd_toggle_partynote({})
end

function AutoBandWindowTools.OnResetTools()
    AB_util.debug(AutoBand.saved.kick_func_enabled)
    AB_util.debug(AB_const.KICK_FUNC_DEFAULT)
    AutoBandWindowTools.reset_kick_enabled()

    AutoBand.saved.autonote_enabled = AB_const.AUTONOTE
    AutoBand.saved.autopartynote_enabled = AB_const.AUTOPARTYNOTE
    AutoBand.saved.notify_buffs_enabled = true
    AutoBand.saved.right_click_organize = AB_const.RIGHTCLICKORGANIZE
    AutoBand.saved.printrole_enabled = AB_const.PRINTROLE
    AutoBand.saved.search_discord_req_enabled = AB_const.SEARCH_DISCORD_REQ
    AutoBand.saved.search_no_mic_enabled = AB_const.SEARCH_NO_MIC
    AutoBand.saved.autoform_search_enabled = AB_const.AUTOFORM_SEARCH

    AB_util.print("Reset ToolsTab-settings to Default.")
    if AutoBand and AutoBand.mark_template_settings_modified then
        AutoBand.mark_template_settings_modified()
    end

    AutoBandWindowTools.Show()
end

-- Helper for labels that should trigger the original checkbox logic
function AutoBandWindowTools.GenericLabelClickHandler(checkboxRelativeName, originalCheckboxHandlerFunction)
    PlaySound(GameData.Sound.BUTTON_CLICK)
    local checkboxFullName = AutoBandWindowTools.name .. checkboxRelativeName
    if type(ButtonGetDisabledFlag) == "function" and ButtonGetDisabledFlag(checkboxFullName) == true then
        return
    end
    ButtonSetPressedFlag(checkboxFullName, not ButtonGetPressedFlag(checkboxFullName))
    if originalCheckboxHandlerFunction then
        originalCheckboxHandlerFunction()
    end
end

-- Helper for labels that ONLY toggle the checkbox visual state (state read later by a separate button)
function AutoBandWindowTools.ToggleCheckboxVisualState(checkboxRelativeName)
    PlaySound(GameData.Sound.BUTTON_CLICK)
    local checkboxFullName = AutoBandWindowTools.name .. checkboxRelativeName
    if type(ButtonGetDisabledFlag) == "function" and ButtonGetDisabledFlag(checkboxFullName) == true then
        return
    end
    ButtonSetPressedFlag(checkboxFullName, not ButtonGetPressedFlag(checkboxFullName))
end

-- Specific label click handlers for AutoBandWindowTools

-- Cases where label click should only toggle checkbox visual state:
function AutoBandWindowTools.OnClickSearchRoleChan1Label()
    PlaySound(GameData.Sound.BUTTON_CLICK)
    AutoBandWindowTools.ToggleCheckboxVisualState("SearchRoleChan1CheckBox")
end
function AutoBandWindowTools.OnClickSearchRoleChanT4Label()
    PlaySound(GameData.Sound.BUTTON_CLICK)
    AutoBandWindowTools.ToggleCheckboxVisualState("SearchRoleChanT4CheckBox")
end
function AutoBandWindowTools.OnClickSearchRoleChan5Label()
    PlaySound(GameData.Sound.BUTTON_CLICK)
    AutoBandWindowTools.ToggleCheckboxVisualState("SearchRoleChan5CheckBox")
end

-- Cases where label click should mimic checkbox action (toggle + call handler):
function AutoBandWindowTools.OnClickKickOfflineLabel()
    AutoBandWindowTools.GenericLabelClickHandler("KickOfflineCheckBox", AutoBandWindowTools.OnKickOfflineCheckBox)
end
function AutoBandWindowTools.OnClickKickZoneLabel()
    AutoBandWindowTools.GenericLabelClickHandler("KickZoneCheckBox", AutoBandWindowTools.OnKickZoneCheckBox)
end
function AutoBandWindowTools.OnClickKickRankLabel()
    AutoBandWindowTools.GenericLabelClickHandler("KickRankCheckBox", AutoBandWindowTools.OnKickRankCheckBox)
end

function AutoBandWindowTools.OnClickAutoSearchLabel()
    AutoBandWindowTools.GenericLabelClickHandler("AutoSearchCheckBox", AutoBandWindowTools.OnAutoSearchCheckBox)
end

function AutoBandWindowTools.OnClickAutoPartyNoteLabel()
    AutoBandWindowTools.GenericLabelClickHandler("AutoPartyNoteCheckBox", AutoBandWindowTools.OnAutoPartyNoteCheckBox)
end

function AutoBandWindowTools.OnClickNotifyBuffsLabel()
    AutoBandWindowTools.GenericLabelClickHandler("NotifyBuffsCheckBox", AutoBandWindowTools.OnNotifyBuffsCheckBox)
end

function AutoBandWindowTools.OnClickRightClickOrganizeLabel()
    AutoBandWindowTools.GenericLabelClickHandler("RightClickOrganizeCheckBox", AutoBandWindowTools.OnRightClickOrganizeCheckBox)
end

function AutoBandWindowTools.OnClickPrintRoleLabel()
    AutoBandWindowTools.GenericLabelClickHandler("PrintRoleCheckBox", AutoBandWindowTools.OnPrintRoleCheckBox)
end

function AutoBandWindowTools.OnClickDiscordReqLabel()
    AutoBandWindowTools.GenericLabelClickHandler("DiscordReqCheckBox", AutoBandWindowTools.OnDiscordReqCheckBox)
end

function AutoBandWindowTools.OnClickNoMicLabel()
    AutoBandWindowTools.GenericLabelClickHandler("NoMicCheckBox", AutoBandWindowTools.OnNoMicCheckBox)
end

function AutoBandWindowTools.OnClickAutoFormSearchLabel()
    AutoBandWindowTools.GenericLabelClickHandler("AutoFormSearchCheckBox", AutoBandWindowTools.OnAutoFormSearchCheckBox)
end

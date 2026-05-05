-- AutoBand template tab UI bindings.
AutoBandWindowTemplate = {}

AutoBandWindowTemplate.name = "AutoBandWindowTemplateTab"
AutoBandWindowTemplate.combobox_name = AutoBandWindowTemplate.name .. "ComboBox"
AutoBandWindowTemplate.applybutton_name = AutoBandWindowTemplate.name .. "ApplyButton"
AutoBandWindowTemplate.orgbutton_name = AutoBandWindowTemplate.name .. "OrgButton"
AutoBandWindowTemplate.orgselectedbutton_name = AutoBandWindowTemplate.name .. "OrgSelectedButton"
AutoBandWindowTemplate.deletebutton_name = AutoBandWindowTemplate.name .. "DeleteButton"
AutoBandWindowTemplate.savebutton_name = AutoBandWindowTemplate.name .. "SaveButton"
AutoBandWindowTemplate.defaultcheckbox_name = AutoBandWindowTemplate.name .. "DefaultCheckBox"
AutoBandWindowTemplate.rightclicktemplatecheckbox_name = AutoBandWindowTemplate.name .. "RightClickTemplateMenuCheckBox"

AutoBandWindowTemplate.group_roles = {}
AutoBandWindowTemplate.group_checkbox = {}
AutoBandWindowTemplate.modified = false
AutoBandWindowTemplate.combo_items = {}
AutoBandWindowTemplate.role_limit_warning_text = nil
AutoBandWindowTemplate.role_limit_warning_flags = { tank = false, healer = false, dps = false }

local TEMPLATE_LABEL_NORMAL = { 225, 225, 225 }
local TEMPLATE_LABEL_WARNING = { 255, 96, 96 }

local function template_set_label_color(name, rgb)
    if type(LabelSetTextColor) ~= "function" then
        return
    end
    LabelSetTextColor(name, rgb[1], rgb[2], rgb[3])
end

local function template_get_tooltip_window_name()
    if SystemData and SystemData.ActiveWindow and SystemData.ActiveWindow.name then
        return SystemData.ActiveWindow.name
    end
    if SystemData and SystemData.MouseOverWindow and SystemData.MouseOverWindow.name then
        return SystemData.MouseOverWindow.name
    end
    return nil
end

local function template_get_tooltip_font_linespacing()
    if type(WindowUtils) == "table" and tonumber(WindowUtils.FONT_DEFAULT_TEXT_LINESPACING) ~= nil then
        return tonumber(WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
    end
    return 20
end

local function template_apply_small_tooltip_font()
    if type(LabelSetFont) ~= "function" then
        return
    end
    local linespacing = template_get_tooltip_font_linespacing()
    LabelSetFont("DefaultTooltipRow1Col1Text", "font_clear_small", linespacing)
    LabelSetFont("DefaultTooltipRow1Col2Text", "font_clear_small", linespacing)
    LabelSetFont("DefaultTooltipRow1Col3Text", "font_clear_small", linespacing)
end

local function template_restore_tooltip_font()
    if type(LabelSetFont) ~= "function" then
        return
    end
    local linespacing = template_get_tooltip_font_linespacing()
    LabelSetFont("DefaultTooltipRow1Col1Text", "font_default_text", linespacing)
    LabelSetFont("DefaultTooltipRow1Col2Text", "font_default_text", linespacing)
    LabelSetFont("DefaultTooltipRow1Col3Text", "font_default_text", linespacing)
end

local function template_show_text_tooltip(tooltip_text)
    if type(Tooltips) ~= "table" or type(Tooltips.CreateTextOnlyTooltip) ~= "function" then
        return
    end
    local window_name = template_get_tooltip_window_name()
    if not window_name or window_name == "" then
        return
    end
    local tooltip_value = tooltip_text
    if type(tooltip_value) == "string" then
        tooltip_value = towstring(tooltip_value)
    end
    if type(Tooltips.SetTooltipText) == "function" then
        Tooltips.CreateTextOnlyTooltip(window_name)
        template_apply_small_tooltip_font()
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

local function template_hide_text_tooltip()
    if type(Tooltips) ~= "table" or type(Tooltips.DestroyTooltip) ~= "function" then
        return
    end
    local window_name = template_get_tooltip_window_name()
    if not window_name or window_name == "" then
        return
    end
    template_restore_tooltip_font()
    Tooltips.DestroyTooltip(window_name)
end

local function template_count_current_layout_roles()
    local counts = { tank = 0, healer = 0, mdps = 0, rdps = 0, dps = 0 }
    for gid = 1, AB_const.MAX_WB_GROUPS do
        local checkbox_name = AutoBandWindowTemplate.group_checkbox and AutoBandWindowTemplate.group_checkbox[gid]
        local role_group = AutoBandWindowTemplate.group_roles and AutoBandWindowTemplate.group_roles[gid]
        if checkbox_name and role_group and ButtonGetPressedFlag(checkbox_name) then
            for pid = 1, AB_const.GROUP_SIZE do
                local labelname = role_group[pid]
                local role = labelname and tostring(LabelGetText(labelname)) or nil
                if role == AB_const.TANK then
                    counts.tank = counts.tank + 1
                elseif role == AB_const.HEALER then
                    counts.healer = counts.healer + 1
                elseif role == AB_const.MDPS then
                    counts.mdps = counts.mdps + 1
                    counts.dps = counts.dps + 1
                elseif role == AB_const.RDPS then
                    counts.rdps = counts.rdps + 1
                    counts.dps = counts.dps + 1
                end
            end
        end
    end
    return counts
end

local function template_build_role_limit_warning()
    local saved = AutoBand.saved or {}
    local counts = template_count_current_layout_roles()
    local warning_flags = { tank = false, healer = false, dps = false }
    local issue_lines = {}

    local max_tanks = tonumber(saved.max_tanks) or 0
    local max_healers = tonumber(saved.max_healers) or 0
    local max_dps = tonumber(saved.max_dps) or 0

    if counts.tank > max_tanks then
        warning_flags.tank = true
        issue_lines[#issue_lines + 1] = string.format("Tanks %d/%d", counts.tank, max_tanks)
    end
    if counts.healer > max_healers then
        warning_flags.healer = true
        issue_lines[#issue_lines + 1] = string.format("Healers %d/%d", counts.healer, max_healers)
    end
    if counts.dps > max_dps then
        warning_flags.dps = true
        issue_lines[#issue_lines + 1] = string.format("DPS %d/%d", counts.dps, max_dps)
    end

    if saved.dps_weighting_enabled == true then
        local max_mdps = tonumber(saved.max_mdps) or 0
        local max_rdps = tonumber(saved.max_rdps) or 0
        if counts.mdps > max_mdps then
            warning_flags.dps = true
            issue_lines[#issue_lines + 1] = string.format("mDPS %d/%d", counts.mdps, max_mdps)
        end
        if counts.rdps > max_rdps then
            warning_flags.dps = true
            issue_lines[#issue_lines + 1] = string.format("rDPS %d/%d", counts.rdps, max_rdps)
        end
    end

    if #issue_lines == 0 then
        return nil, warning_flags
    end

    local lines = {
        "Template layout exceeds current caps.",
        "Exceeded (layout/cap):"
    }
    for i = 1, #issue_lines do
        lines[#lines + 1] = issue_lines[i]
    end
    return table.concat(lines, "\n"), warning_flags
end

function AutoBandWindowTemplate.RefreshRightClickTemplateMenuState()
    local checkbox_name = AutoBandWindowTemplate.rightclicktemplatecheckbox_name
    local label_name = AutoBandWindowTemplate.name .. "RightClickTemplateMenuLabel"
    local enabled = AutoBand.saved and AutoBand.saved.right_click_organize == true

    ButtonSetPressedFlag(checkbox_name, AutoBand.saved.right_click_organize_include_templates == true)
    ButtonSetDisabledFlag(checkbox_name, not enabled)
    if enabled then
        LabelSetTextColor(label_name, 225, 225, 225)
    else
        LabelSetTextColor(label_name, 150, 150, 150)
    end
end


function AutoBandWindowTemplate.Initialize()
    LabelSetText(AutoBandWindowTemplate.name .. "ComboBoxLabel", L"Templates:")

    LabelSetText(AutoBandWindowTemplate.name .. "DefaultLabel", L"Default")
    ButtonSetCheckButtonFlag(AutoBandWindowTemplate.defaultcheckbox_name, true)

    ButtonSetDisabledFlag(AutoBandWindowTemplate.savebutton_name, true)
    ButtonSetText(AutoBandWindowTemplate.savebutton_name, L"Save")
    ButtonSetText(AutoBandWindowTemplate.deletebutton_name, L"Delete")
    ButtonSetText(AutoBandWindowTemplate.applybutton_name, L"Apply")
    ButtonSetText(AutoBandWindowTemplate.orgbutton_name, L"Organize WB")
    ButtonSetText(AutoBandWindowTemplate.orgselectedbutton_name, L"Organize WB (template)")
    LabelSetText(AutoBandWindowTemplate.name .. "RightClickTemplateMenuLabel", towstring("Include template organize options\nin icon RClick menu"))
    ButtonSetCheckButtonFlag(AutoBandWindowTemplate.rightclicktemplatecheckbox_name, true)
    AutoBandWindowTemplate.RefreshRightClickTemplateMenuState()

    LabelSetText(AutoBandWindowTemplate.name .. "RolesLabel", L"Warband Role Composition")
    LabelSetText(AutoBandWindowTemplate.name .. "TanksLabel", L" Tanks")
    LabelSetText(AutoBandWindowTemplate.name .. "HealersLabel", L"  Healers")
    LabelSetText(AutoBandWindowTemplate.name .. "DpsLabel", L"     DPS")
    AutoBandWindowTemplate.refresh_role_limits()

    -- add the empty template automatic
    AutoBand.saved.templates[AB_const.EMPTY_TEMPLATE] = nil

    -- mask down
    WindowSetShowing(AutoBandWindowTemplate.name .. "Mask", false)

    AutoBandWindowTemplate.create_role_labels()

    AutoBandWindowTemplate.refresh_gui()
    -- Restore the remembered template selection instead of always snapping back to <Automatic>.
    local initial_selection = AB_const.EMPTY_TEMPLATE
    if AutoBand and type(AutoBand.restore_saved_template_selection) == "function" then
        initial_selection = AutoBand.restore_saved_template_selection()
    elseif AutoBand and type(AutoBand.saved) == "table" then
        initial_selection = AutoBand.saved.active_template_selection or AB_const.EMPTY_TEMPLATE
    end
    AutoBandWindowTemplate.set_combobox_item(initial_selection)
end

function AutoBandWindowTemplate.Shutdown()
end

function AutoBandWindowTemplate.Hide()
    WindowSetShowing(AutoBandWindowTemplate.name, false)
end

function AutoBandWindowTemplate.Show()
    if AutoBand and AutoBand.template_settings_dirty == true then
        AutoBandWindowTemplate.modified = true
    end
    ButtonSetPressedFlag(AutoBandWindowTemplate.defaultcheckbox_name, AutoBandWindowTemplate.selected_combobox() == AutoBand.saved.default_template)
    AutoBandWindowTemplate.RefreshRightClickTemplateMenuState()
    ButtonSetDisabledFlag(AutoBandWindowTemplate.savebutton_name, not AutoBandWindowTemplate.modified)
    AutoBandWindowTemplate.refresh_role_limits()
    WindowSetShowing(AutoBandWindowTemplate.name, true)
end

function AutoBandWindowTemplate.mark_modified(opts)
    opts = opts or {}
    AutoBandWindowTemplate.modified = true
    if type(ButtonSetDisabledFlag) == "function" then
        ButtonSetDisabledFlag(AutoBandWindowTemplate.savebutton_name, false)
        if opts.enable_apply then
            ButtonSetDisabledFlag(AutoBandWindowTemplate.applybutton_name, false)
        end
    end
end

-- default template checkbox pressed
function AutoBandWindowTemplate.OnDefaultCheckBox()
    if (ButtonGetDisabledFlag(AutoBandWindowTemplate.defaultcheckbox_name)) then
        return
    end

    local checked = ButtonGetPressedFlag(AutoBandWindowTemplate.defaultcheckbox_name)
    if (checked) then
        AutoBand.saved.default_template = AutoBandWindowTemplate.selected_combobox()
    else
        AutoBand.saved.default_template = AB_const.EMPTY_TEMPLATE
    end
end

function AutoBandWindowTemplate.is_special_template(name)
    return (name == AB_const.CURRENT_WB) or (name == AB_const.EMPTY_TEMPLATE)
end

-- Load and remember a template selection: restore its saved settings, then show its layout.
function AutoBandWindowTemplate.load_template(name)
    AB_util.debug("Loading: " .. name)
    if AutoBand then
        if type(AutoBand.remember_active_template_selection) == "function" then
            name = AutoBand.remember_active_template_selection(name)
        else
            AutoBand.template_active_key = name
        end
    end

    -- check if it's the default
    ButtonSetPressedFlag(AutoBandWindowTemplate.defaultcheckbox_name, name == AutoBand.saved.default_template)

    local temp = nil
    local is_special = AutoBandWindowTemplate.is_special_template(name)
    ButtonSetDisabledFlag(AutoBandWindowTemplate.defaultcheckbox_name, is_special)
--    ButtonSetDisabledFlag(AutoBandWindowTemplate.deletebutton_name, is_special)
    ButtonSetDisabledFlag(AutoBandWindowTemplate.orgselectedbutton_name, is_special)

    ButtonSetDisabledFlag(AutoBandWindowTemplate.applybutton_name, false)
    if (is_special) then
        if (name == AB_const.CURRENT_WB) then
            temp = AB_template.from_wb(AutoBand.get_wb())
            ButtonSetDisabledFlag(AutoBandWindowTemplate.applybutton_name, true)    -- no point applying warband to current warband
        elseif (name == AB_const.EMPTY_TEMPLATE) then
            if type(AutoBand.restore_normal_template_settings) == "function" then
                AutoBand.restore_normal_template_settings({ silent = true, template_name = name })
            end
            temp = AB_const.EMPTY_WB_TEMPLATE
        end
        ButtonSetText(AutoBandWindowTemplate.deletebutton_name, L"Reset")
    else
        temp = AutoBand.saved.templates[name]
        if type(AutoBand.apply_template_settings) == "function" then
            AutoBand.apply_template_settings(temp, { silent = true, template_name = name })
        end
        if type(AutoBand.template_get_layout) == "function" then
            temp = AutoBand.template_get_layout(temp)
        end
        ButtonSetText(AutoBandWindowTemplate.deletebutton_name, L"Delete")
    end

    if (temp) then
        for gid = 1, AB_const.MAX_WB_GROUPS do
            for pid = 1, AB_const.GROUP_SIZE do
                local labelname = AutoBandWindowTemplate.group_roles[gid][pid]
                if (temp[gid][pid] == nil) then
                    AutoBandWindowTemplate.set_role_label(labelname, AB_const.LABEL_EMPTY)
                else
                    AutoBandWindowTemplate.set_role_label(labelname, temp[gid][pid].role)
                end
            end
        end
    end

    AutoBandWindowTemplate.modified = false
    if AutoBand then
        AutoBand.template_settings_dirty = false
    end
    ButtonSetDisabledFlag(AutoBandWindowTemplate.savebutton_name, true)
    AutoBandWindowTemplate.refresh_role_limits()
end

-- load selected template from combobox selected
function AutoBandWindowTemplate.OnSelChangedComboBox()
    AutoBandWindowTemplate.load_template(AutoBandWindowTemplate.selected_combobox())
end

-- Save the current editor layout together with the current settings preset.
function AutoBandWindowTemplate.OnSaveTemplate()
    if (ButtonGetDisabledFlag(AutoBandWindowTemplate.savebutton_name)) then
        return
    end

    -- mask up
    WindowSetShowing(AutoBandWindowTemplate.name .. "Mask", true)

    AutoBandWindowTemplateSave.ShowModal(
        -- this get called back if the user pressed OK and typed something
        function(name)
            -- save in AutoBand.saved.templates
            if type(AutoBand.build_template_snapshot) == "function" then
                AutoBand.saved.templates[name] = AutoBand.build_template_snapshot(AutoBandWindowTemplate.get_template_from_labels())
            else
                AutoBand.saved.templates[name] = AutoBandWindowTemplate.get_template_from_labels()
            end
            -- reset checkboxes
            for gid = 1, AB_const.MAX_WB_GROUPS do
                ButtonSetPressedFlag(AutoBandWindowTemplate.group_checkbox[gid], true)
            end
            AutoBandWindowTemplate.modified = false
            if AutoBand then
                AutoBand.template_settings_dirty = false
            end
            -- refresh
            AutoBandWindowTemplate.refresh_gui()
            AutoBandWindowTemplate.set_combobox_item(name)
        end
    )
end

-- delete template
function AutoBandWindowTemplate.OnDeleteTemplate()
    if (ButtonGetDisabledFlag(AutoBandWindowTemplate.deletebutton_name)) then
        return
    end

    local sel = AutoBandWindowTemplate.selected_combobox()
    if (AutoBandWindowTemplate.is_special_template(sel)) then
        -- we will refresh if it's <warband> or reset if it's <automatic>, in any case just reload them
        -- Only reset the role composition counts if they are not already default.
        if not (AutoBand.saved.max_tanks == AB_const.DEFAULT_MAX_TANKS and
                AutoBand.saved.max_healers == AB_const.DEFAULT_MAX_HEALERS and
                AutoBand.saved.max_dps == AB_const.DEFAULT_MAX_DPS)
        then
            AutoBand.cmd_resetroles({})
        end
        AutoBandWindowTemplate.load_template(sel)
        return
    end
    AB_util.debug("Deleting: " .. sel)
    if (AutoBand.saved.templates[sel] ~= nil) then
        local function delete_selected_template(template_name)
            if (AutoBand.saved.templates[template_name] ~= nil) then
                AutoBand.saved.templates[template_name] = nil
                if (AutoBand.saved.default_template == template_name) then
                    AutoBand.saved.default_template = AB_const.EMPTY_TEMPLATE
                end
                if AutoBand and type(AutoBand.remember_active_template_selection) == "function" then
                    AutoBand.remember_active_template_selection(AB_const.EMPTY_TEMPLATE)
                elseif AutoBand then
                    AutoBand.template_active_key = AB_const.EMPTY_TEMPLATE
                end
                AutoBandWindowTemplate.refresh_gui()
                AutoBandWindowTemplate.set_combobox_item(AB_const.EMPTY_TEMPLATE)
            end
        end

        if type(AutoBandWindowTemplateDeleteConfirm) == "table" and type(AutoBandWindowTemplateDeleteConfirm.ShowModal) == "function" then
            AutoBandWindowTemplateDeleteConfirm.ShowModal(sel, delete_selected_template)
        else
            delete_selected_template(sel)
        end
    end
end

-- Apply the current editor layout only and organize the live warband.
-- This does not reload saved preset settings from the selected template entry.
function AutoBandWindowTemplate.OnApplyTemplate()
    if (ButtonGetDisabledFlag(AutoBandWindowTemplate.applybutton_name)) then
        return
    end

        if (AutoBand.is_wb_leader() or AutoBand.debugon) then
        AB_org.auto_organize(AutoBandWindowTemplate.get_template_from_labels())
    end
end

-- organize using normal /ab org behavior (default template path)
function AutoBandWindowTemplate.OnOrganize()
    if (ButtonGetDisabledFlag(AutoBandWindowTemplate.orgbutton_name)) then
        return
    end
    AutoBand.cmd_organize({})
end

-- organize using currently selected combobox template (/ab org <template>)
function AutoBandWindowTemplate.OnOrganizeSelectedTemplate()
    if (ButtonGetDisabledFlag(AutoBandWindowTemplate.orgselectedbutton_name)) then
        return
    end

    local selected = AutoBandWindowTemplate.selected_combobox()
    if not selected or selected == "" then
        AB_util.print("[error] No template selected.")
        return
    end

    if AutoBandWindowTemplate.is_special_template(selected) then
        AB_util.print("[error] Select a saved template to organize by name.")
        return
    end

    if AutoBand.saved.templates[selected] == nil then
        AB_util.print("[error] Template '" .. tostring(selected) .. "' does not exist.")
        return
    end

    AutoBand.cmd_organize({selected})
end

function AutoBandWindowTemplate.OnRightClickTemplateMenuCheckBox()
    if ButtonGetDisabledFlag(AutoBandWindowTemplate.rightclicktemplatecheckbox_name) then
        return
    end
    AutoBand.saved.right_click_organize_include_templates = ButtonGetPressedFlag(AutoBandWindowTemplate.rightclicktemplatecheckbox_name)
    AB_util.print("Right-click icon menu includes template organize options: " .. tostring(AutoBand.saved.right_click_organize_include_templates))
end

function AutoBandWindowTemplate.OnClickRightClickTemplateMenuLabel()
    if ButtonGetDisabledFlag(AutoBandWindowTemplate.rightclicktemplatecheckbox_name) then
        return
    end
    PlaySound(GameData.Sound.BUTTON_CLICK)
    ButtonSetPressedFlag(
        AutoBandWindowTemplate.rightclicktemplatecheckbox_name,
        not ButtonGetPressedFlag(AutoBandWindowTemplate.rightclicktemplatecheckbox_name)
    )
    AutoBandWindowTemplate.OnRightClickTemplateMenuCheckBox()
end

function AutoBandWindowTemplate.OnRoleLimitsMouseOver()
    if AutoBandWindowTemplate.role_limit_warning_text and AutoBandWindowTemplate.role_limit_warning_text ~= "" then
        template_show_text_tooltip(AutoBandWindowTemplate.role_limit_warning_text)
    end
end

function AutoBandWindowTemplate.OnRoleLimitsMouseOverEnd()
    template_hide_text_tooltip()
end

function AutoBandWindowTemplate.OnApplyButtonMouseOver()
    if ButtonGetDisabledFlag(AutoBandWindowTemplate.applybutton_name) then
        return
    end
    template_show_text_tooltip("Organizes the live warband using the current layout shown here.")
end

function AutoBandWindowTemplate.OnApplyButtonMouseOverEnd()
    template_hide_text_tooltip()
end

-- create a template from labels
function AutoBandWindowTemplate.get_template_from_labels()
    local temp = {}
    for gid = 1, AB_const.MAX_WB_GROUPS do
        temp[gid] = {}
        -- if the group checkbox is checked
        if (ButtonGetPressedFlag(AutoBandWindowTemplate.group_checkbox[gid])) then
            for pid = 1, AB_const.GROUP_SIZE do
                local role = tostring(LabelGetText(AutoBandWindowTemplate.group_roles[gid][pid]))
                if (role ~= AB_const.LABEL_EMPTY) then
                    temp[gid][pid] = {["role"] = role}
                end
            end
        end
    end
    return temp
end


-- sets role label name and color
function AutoBandWindowTemplate.set_role_label(labelname, role)
    LabelSetText(labelname , towstring(role))
    local color = AB_const.LABEL_ROLE_COLORS[role]
    LabelSetTextColor(labelname, color[1], color[2], color[3])
end

-- return selected text
function AutoBandWindowTemplate.selected_combobox()
    return tostring(ComboBoxGetSelectedText(AutoBandWindowTemplate.combobox_name))
end

-- sets combobox to item called "name"
function AutoBandWindowTemplate.set_combobox_item(name)
    local index = nil
    for i, v in ipairs(AutoBandWindowTemplate.combo_items) do
        if (v == name) then
            index = i
            break
        end
    end
    if (index) then
        ComboBoxSetSelectedMenuItem(AutoBandWindowTemplate.combobox_name, index)
        AutoBandWindowTemplate.load_template(name)
    end
end

-- reload combobox items
function AutoBandWindowTemplate.refresh_gui()
    -- enable/disable Save
    ButtonSetDisabledFlag(AutoBandWindowTemplate.savebutton_name, not AutoBandWindowTemplate.modified)
    -- reloadui combobox
    AutoBandWindowTemplate.combo_items = {}
    ComboBoxClearMenuItems(AutoBandWindowTemplate.combobox_name)
    -- add current warband
    ComboBoxAddMenuItem(AutoBandWindowTemplate.combobox_name, towstring(AB_const.EMPTY_TEMPLATE))
    table.insert(AutoBandWindowTemplate.combo_items, AB_const.EMPTY_TEMPLATE)
    ComboBoxAddMenuItem(AutoBandWindowTemplate.combobox_name, towstring(AB_const.CURRENT_WB))
    table.insert(AutoBandWindowTemplate.combo_items, AB_const.CURRENT_WB)
    -- add from templates
    for tname in pairs(AutoBand.saved.templates) do
        ComboBoxAddMenuItem(AutoBandWindowTemplate.combobox_name, towstring(tname))
        table.insert(AutoBandWindowTemplate.combo_items, tname)
    end
end

-- create GUI element and return its name
function AutoBandWindowTemplate.create_element_tl_tl(element, name, parent, xoff, yoff, width, height)
    local label_name = AutoBandWindowTemplate.name .. "Elem" .. name
    CreateWindowFromTemplate(label_name, element, parent)
    width = width or 100
    height = height or 30
    WindowSetDimensions(label_name, width, height)
    WindowAddAnchor(label_name, "topleft", parent, "topleft", xoff, yoff)
    return label_name
end

-- fired whenever a role label is left clicked
function AutoBandWindowTemplate.role_label_left_clicked()
    AutoBandWindowTemplate.rotate_role_label(-1)
end

-- fired whenever a role label is right clicked
function AutoBandWindowTemplate.role_label_right_clicked()
    AutoBandWindowTemplate.rotate_role_label(1)
end

-- rotate label by "inc"
function AutoBandWindowTemplate.rotate_role_label(inc)
    local labelname = SystemData.ActiveWindow.name
    AB_util.debug(labelname)
    local role = tostring(LabelGetText(labelname))
    local c = AB_const.LABEL_ROLE_CATEGORIES[role] + inc
    if (c <= 0) then
        c = #AB_const.LABEL_ROLE_CATEGORIES_REV
    elseif (c > #AB_const.LABEL_ROLE_CATEGORIES_REV) then
        c = 1
    end
    AutoBandWindowTemplate.set_role_label(labelname, AB_const.LABEL_ROLE_CATEGORIES_REV[c])
    AutoBandWindowTemplate.mark_modified({ enable_apply = true })
    AutoBandWindowTemplate.refresh_role_limits()
end

function AutoBandWindowTemplate.group_checkbox_clicked()
    AutoBandWindowTemplate.mark_modified({ enable_apply = true })
    AutoBandWindowTemplate.refresh_role_limits()
end

-- create role labels
function AutoBandWindowTemplate.create_role_labels()
    local Y_OFF = 95
    for gid = 1, AB_const.MAX_WB_GROUPS do
        AutoBandWindowTemplate.group_roles[gid] = {}
        local xoff = ((gid - 1) * 110) + 30
        -- create label for each group
        local capname = AutoBandWindowTemplate.create_element_tl_tl("EA_Label_DefaultText", "Caption" .. gid, AutoBandWindowTemplate.name, xoff + 20, 10 + Y_OFF, 25)
        LabelSetText(capname, towstring("#" .. gid))
        -- create role labels
        for pid = 1, AB_const.GROUP_SIZE do
            local yoff = (pid * 30) + 10 + Y_OFF
            local labelname = AutoBandWindowTemplate.create_element_tl_tl("EA_Label_DefaultText", "Role" .. gid .. pid, AutoBandWindowTemplate.name, xoff, yoff, 65)
            AutoBandWindowTemplate.set_role_label(labelname, AB_const.LABEL_EMPTY)
            WindowRegisterCoreEventHandler(labelname, "OnLButtonUp", "AutoBandWindowTemplate.role_label_left_clicked")
            WindowRegisterCoreEventHandler(labelname, "OnRButtonUp", "AutoBandWindowTemplate.role_label_right_clicked")
            AutoBandWindowTemplate.group_roles[gid][pid] = labelname
        end
        -- create checkbox for each group
        local yoff = ((AB_const.GROUP_SIZE + 1) * 30) + 20 + Y_OFF
        local chkboxname = AutoBandWindowTemplate.create_element_tl_tl("EA_Button_DefaultCheckBox", "CheckBox" .. gid, AutoBandWindowTemplate.name, xoff + 20, yoff, 22, 22)
        ButtonSetCheckButtonFlag(chkboxname, true)
        ButtonSetPressedFlag(chkboxname, true)
        WindowRegisterCoreEventHandler(chkboxname, "OnLButtonUp", "AutoBandWindowTemplate.group_checkbox_clicked")
        AutoBandWindowTemplate.group_checkbox[gid] = chkboxname
    end
end

function AutoBandWindowTemplate.refresh_role_limits()
    LabelSetText(AutoBandWindowTemplate.name .. "TanksValueLabel", towstring(AutoBand.saved.max_tanks))
    LabelSetText(AutoBandWindowTemplate.name .. "HealersValueLabel", towstring(AutoBand.saved.max_healers))
    LabelSetText(AutoBandWindowTemplate.name .. "DpsValueLabel", towstring(AutoBand.saved.max_dps))

    local warning_text, warning_flags = template_build_role_limit_warning()
    AutoBandWindowTemplate.role_limit_warning_text = warning_text
    AutoBandWindowTemplate.role_limit_warning_flags = warning_flags or { tank = false, healer = false, dps = false }

    local any_warning = warning_text ~= nil and warning_text ~= ""
    template_set_label_color(
        AutoBandWindowTemplate.name .. "RolesLabel",
        any_warning and TEMPLATE_LABEL_WARNING or TEMPLATE_LABEL_NORMAL
    )
    template_set_label_color(
        AutoBandWindowTemplate.name .. "TanksLabel",
        AutoBandWindowTemplate.role_limit_warning_flags.tank and TEMPLATE_LABEL_WARNING or TEMPLATE_LABEL_NORMAL
    )
    template_set_label_color(
        AutoBandWindowTemplate.name .. "TanksValueLabel",
        AutoBandWindowTemplate.role_limit_warning_flags.tank and TEMPLATE_LABEL_WARNING or TEMPLATE_LABEL_NORMAL
    )
    template_set_label_color(
        AutoBandWindowTemplate.name .. "HealersLabel",
        AutoBandWindowTemplate.role_limit_warning_flags.healer and TEMPLATE_LABEL_WARNING or TEMPLATE_LABEL_NORMAL
    )
    template_set_label_color(
        AutoBandWindowTemplate.name .. "HealersValueLabel",
        AutoBandWindowTemplate.role_limit_warning_flags.healer and TEMPLATE_LABEL_WARNING or TEMPLATE_LABEL_NORMAL
    )
    template_set_label_color(
        AutoBandWindowTemplate.name .. "DpsLabel",
        AutoBandWindowTemplate.role_limit_warning_flags.dps and TEMPLATE_LABEL_WARNING or TEMPLATE_LABEL_NORMAL
    )
    template_set_label_color(
        AutoBandWindowTemplate.name .. "DpsValueLabel",
        AutoBandWindowTemplate.role_limit_warning_flags.dps and TEMPLATE_LABEL_WARNING or TEMPLATE_LABEL_NORMAL
    )
end

function AutoBandWindowTemplate.OnPressTanksPlusButton()
    local tanks = AutoBand.saved.max_tanks
    local healers = AutoBand.saved.max_healers
    local dps = AutoBand.saved.max_dps

    if tanks < 24 then
        tanks = tanks + 1
        if dps > 0 then
            dps = dps - 1
        elseif healers > 0 then
            healers = healers - 1
        end
        AutoBand.cmd_setroles({tostring(tanks), tostring(healers), tostring(dps)}, true)
        AutoBandWindowTemplate.refresh_role_limits()
    end
end

function AutoBandWindowTemplate.OnPressTanksMinusButton()
    local tanks = AutoBand.saved.max_tanks
    local healers = AutoBand.saved.max_healers
    local dps = AutoBand.saved.max_dps

    if tanks > 0 then
        tanks = tanks - 1
        dps = dps + 1
        AutoBand.cmd_setroles({tostring(tanks), tostring(healers), tostring(dps)}, true)
        AutoBandWindowTemplate.refresh_role_limits()
    end
end

function AutoBandWindowTemplate.OnPressHealersPlusButton()
    local tanks = AutoBand.saved.max_tanks
    local healers = AutoBand.saved.max_healers
    local dps = AutoBand.saved.max_dps

    if healers < 24 then
        healers = healers + 1
        if dps > 0 then
            dps = dps - 1
        elseif tanks > 0 then
            tanks = tanks - 1
        end
        AutoBand.cmd_setroles({tostring(tanks), tostring(healers), tostring(dps)}, true)
        AutoBandWindowTemplate.refresh_role_limits()
    end
end

function AutoBandWindowTemplate.OnPressHealersMinusButton()
    local tanks = AutoBand.saved.max_tanks
    local healers = AutoBand.saved.max_healers
    local dps = AutoBand.saved.max_dps

    if healers > 0 then
        healers = healers - 1
        dps = dps + 1
        AutoBand.cmd_setroles({tostring(tanks), tostring(healers), tostring(dps)}, true)
        AutoBandWindowTemplate.refresh_role_limits()
    end
end

function AutoBandWindowTemplate.OnPressDpsPlusButton()
    local tanks = AutoBand.saved.max_tanks
    local healers = AutoBand.saved.max_healers
    local dps = AutoBand.saved.max_dps

    if dps < 24 then
        dps = dps + 1
        if healers > 0 then
            healers = healers - 1
        elseif tanks > 0 then
            tanks = tanks - 1
        end
        AutoBand.cmd_setroles({tostring(tanks), tostring(healers), tostring(dps)}, true)
        AutoBandWindowTemplate.refresh_role_limits()
    end
end

function AutoBandWindowTemplate.OnPressDpsMinusButton()
    local tanks = AutoBand.saved.max_tanks
    local healers = AutoBand.saved.max_healers
    local dps = AutoBand.saved.max_dps

    if dps > 0 then
        dps = dps - 1
        healers = healers + 1
        AutoBand.cmd_setroles({tostring(tanks), tostring(healers), tostring(dps)}, true)
        AutoBandWindowTemplate.refresh_role_limits()
    end
end

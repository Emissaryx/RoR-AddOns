AutoBandWindowTemplateDeleteConfirm = {}
AutoBandWindowTemplateDeleteConfirm.name = "AutoBandWindowTemplateDeleteConfirm"
AutoBandWindowTemplateDeleteConfirm.callback = nil
AutoBandWindowTemplateDeleteConfirm.template_name = nil

function AutoBandWindowTemplateDeleteConfirm.Initialize()
    LabelSetText(AutoBandWindowTemplateDeleteConfirm.name .. "TitleBarText", L"Delete Template")
    LabelSetText(AutoBandWindowTemplateDeleteConfirm.name .. "MessageLabel", L"Delete this template?")
    ButtonSetText(AutoBandWindowTemplateDeleteConfirm.name .. "OKButton", L"Delete")
    ButtonSetText(AutoBandWindowTemplateDeleteConfirm.name .. "CancelButton", L"Cancel")
end

function AutoBandWindowTemplateDeleteConfirm.OnOK()
    local callback = AutoBandWindowTemplateDeleteConfirm.callback
    local template_name = AutoBandWindowTemplateDeleteConfirm.template_name
    AutoBandWindowTemplateDeleteConfirm.Hide()
    if callback then
        callback(template_name)
    end
end

function AutoBandWindowTemplateDeleteConfirm.OnCancel()
    AutoBandWindowTemplateDeleteConfirm.Hide()
end

function AutoBandWindowTemplateDeleteConfirm.Hide()
    AutoBandWindowTemplateDeleteConfirm.callback = nil
    AutoBandWindowTemplateDeleteConfirm.template_name = nil
    WindowSetShowing(AutoBandWindowTemplateDeleteConfirm.name, false)
    WindowSetShowing(AutoBandWindowTemplate.name .. "Mask", false)
end

function AutoBandWindowTemplateDeleteConfirm.ShowModal(template_name, callback)
    AutoBandWindowTemplateDeleteConfirm.callback = callback
    AutoBandWindowTemplateDeleteConfirm.template_name = template_name
    LabelSetText(
        AutoBandWindowTemplateDeleteConfirm.name .. "MessageLabel",
        towstring("Delete template:\n'" .. tostring(template_name or "") .. "'")
    )
    WindowSetShowing(AutoBandWindowTemplate.name .. "Mask", true)
    WindowSetShowing(AutoBandWindowTemplateDeleteConfirm.name, true)
end

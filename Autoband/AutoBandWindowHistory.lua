--
AutoBandWindowHistory = {}

AutoBandWindowHistory.name = "AutoBandWindowHistoryTab"


function AutoBandWindowHistory.Initialize()
--    LabelSetText(AutoBandWindowHistory.name .. "ComboBoxLabel", L"Events:")
end



function AutoBandWindowHistory.Hide()
    WindowSetShowing(AutoBandWindowHistory.name, false)
end

function AutoBandWindowHistory.Show()
    WindowSetShowing(AutoBandWindowHistory.name, true)
end

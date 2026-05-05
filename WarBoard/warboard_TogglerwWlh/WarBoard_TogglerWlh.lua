if not WarBoard_TogglerWlh then WarBoard_TogglerWlh = {} end
local WarBoard_TogglerWlh = WarBoard_TogglerWlh
local modName = "WarBoard_TogglerWlh"
local modLabel = "WB Lead Helper"

function WarBoard_TogglerWlh.Initialize()
	if LibWBToggler.CreateToggler(modName, modLabel, "WlhIcon", 0, 0) then
		WindowSetDimensions(modName, 170, 30)
		WindowSetDimensions(modName.."Label", 130, 30)
		LibWBToggler.RegisterEvent(modName, "OnLButtonUp", "WarBoard_TogglerWbLeadHelperWindow")
		LibWBToggler.RegisterEvent(modName, "OnRButtonUp", "WarBoard_TogglerWbLeadHelperConfig")
		LibWBToggler.RegisterEvent(modName, "OnMouseOver", "WarBoard_TogglerWlh.ShowStatus")
	end
end

function WarBoard_TogglerWbLeadHelperWindow()
	wbLeadHelper.toggleWbLeadHelperWindow()
end

function WarBoard_TogglerWbLeadHelperConfig()
	wbLeadHelper.SlashCmd("config")
end

function WarBoard_TogglerWlh.ShowStatus()
	Tooltips.CreateTextOnlyTooltip(modName, nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor(modName))
	Tooltips.SetTooltipText(1, 1, L"Warboard Leader Helper")
	Tooltips.SetTooltipText(2, 1, L"Left Click:")
	Tooltips.SetTooltipText(2, 3, L"Toggle WLH")
	Tooltips.SetTooltipText(3, 1, L"Right Click:")
	Tooltips.SetTooltipText(3, 3, L"Open config")
	Tooltips.Finalize()
end
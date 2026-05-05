
wbLeadHelperChooseIcon = {}

wbLeadHelperChooseIcon.name = "wbLeadHelperChooseIconDialog"

function wbLeadHelperChooseIcon.Initialize()

	CreateWindow (wbLeadHelperChooseIcon.name, false)

end

local tinsert = table.insert
local choose_icon_dlg =
{
	isInitialized = false
}

function wbLeadHelperChooseIcon.IsOpen ()
	return WindowGetShowing (wbLeadHelperChooseIcon.name)
end


function wbLeadHelperChooseIcon.Hide ()
	WindowSetShowing (wbLeadHelperChooseIcon.name, false)
end


function wbLeadHelperChooseIcon.Open (onOkCallback)

	if (not choose_icon_dlg.isInitialized) then

		-- initialize dialog UI
		LabelSetText (wbLeadHelperChooseIcon.name .. "TitleBarText", L"Icon Ids")

		wbLeadHelperChooseIcon.UpdateList ()

		choose_icon_dlg.isInitialized = true
	end

	-- proceed parameters
	choose_icon_dlg.onOkCallback = onOkCallback

	WindowSetShowing (wbLeadHelperChooseIcon.name, true)
end


function wbLeadHelperChooseIcon.UpdateList ()

	wbLeadHelperChooseIcon.DialogListData = {}
	wbLeadHelperChooseIcon.DialogListIndexes = {}

	local k = 1
	local id = 1
	local max_id = 50000

	while (id < max_id)
	do
		local data = {}

		while (id < max_id and #data < 8)
		do
			local texture, x, y = GetIconData (id)

			if (texture and texture ~= "icon-00001" and texture ~= "icon-00002")
			then
				tinsert (data, id)
			end

			id = id + 1
		end

		tinsert (wbLeadHelperChooseIcon.DialogListData, data)
		tinsert (wbLeadHelperChooseIcon.DialogListIndexes, k)
		k = k + 1
	end

	ListBoxSetDisplayOrder (wbLeadHelperChooseIcon.name .. "Icons", wbLeadHelperChooseIcon.DialogListIndexes)
end


function wbLeadHelperChooseIcon.OnIconsPopulate ()

	if (wbLeadHelperChooseIconDialogIcons.PopulatorIndices == nil) then return end

	local row_window_name
	local data

	for k, v in ipairs (wbLeadHelperChooseIconDialogIcons.PopulatorIndices)
	do
		row_window_name = wbLeadHelperChooseIcon.name .. "IconsRow"..k
		data = wbLeadHelperChooseIcon.DialogListData[v]

		for i = 1, 8
		do
			local id = data[i]

			if (id)
			then
				WindowSetShowing (row_window_name.."Icon"..i, true)

				local texture, x, y = GetIconData (id)
				DynamicImageSetTexture (row_window_name.."Icon"..i.."Icon", texture, x, y)
			else
				WindowSetShowing (row_window_name.."Icon"..i, false)
			end
		end
	end
end


function wbLeadHelperChooseIcon.OnListRowLButtonUp ()

	local data_index = ListBoxGetDataIndex (wbLeadHelperChooseIcon.name .. "Icons", WindowGetId (SystemData.ActiveWindow.name))
	local icon_index = tonumber (SystemData.ActiveWindow.name:match (wbLeadHelperChooseIcon.name .. "IconsRow%d+Icon(%d+)"))

	if (choose_icon_dlg.onOkCallback)
	then
		choose_icon_dlg.onOkCallback (wbLeadHelperChooseIcon.DialogListData[data_index][icon_index])
	end

	wbLeadHelperChooseIcon.Hide ()
end

function wbLeadHelperChooseIcon.OnMouseOverCreateTooltip()
	local dataIndex = ListBoxGetDataIndex (wbLeadHelperChooseIcon.name .. "Icons", WindowGetId (SystemData.ActiveWindow.name))
	local iconIndex = tonumber (SystemData.ActiveWindow.name:match (wbLeadHelperChooseIcon.name .. "IconsRow%d+Icon(%d+)"))

	local iconId = wbLeadHelperChooseIcon.DialogListData[dataIndex][iconIndex];

	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=0, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, towstring("Icon Id: " .. iconId))
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end
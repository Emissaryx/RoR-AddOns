
DevHelperChooseIcon = {}

DevHelperChooseIcon.name = "DevHelperChooseIconDialog"

function DevHelperChooseIcon.Initialize()

	CreateWindow (DevHelperChooseIcon.name, false)

end

local tinsert = table.insert
local choose_icon_dlg =
{
	isInitialized = false
}

function DevHelperChooseIcon.IsOpen ()
	return WindowGetShowing (DevHelperChooseIcon.name)
end


function DevHelperChooseIcon.Hide ()
	WindowSetShowing (DevHelperChooseIcon.name, false)
end


function DevHelperChooseIcon.Open (onOkCallback)

	if (not choose_icon_dlg.isInitialized) then

		-- initialize dialog UI
		LabelSetText (DevHelperChooseIcon.name .. "TitleBarText", L"Icon Ids")

		DevHelperChooseIcon.UpdateList ()

		choose_icon_dlg.isInitialized = true
	end

	-- proceed parameters
	choose_icon_dlg.onOkCallback = onOkCallback

	WindowSetShowing (DevHelperChooseIcon.name, true)
end


function DevHelperChooseIcon.UpdateList ()

	DevHelperChooseIcon.DialogListData = {}
	DevHelperChooseIcon.DialogListIndexes = {}

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

		tinsert (DevHelperChooseIcon.DialogListData, data)
		tinsert (DevHelperChooseIcon.DialogListIndexes, k)
		k = k + 1
	end

	ListBoxSetDisplayOrder (DevHelperChooseIcon.name .. "Icons", DevHelperChooseIcon.DialogListIndexes)
end


function DevHelperChooseIcon.OnIconsPopulate ()

	if (DevHelperChooseIconDialogIcons.PopulatorIndices == nil) then return end

	local row_window_name
	local data

	for k, v in ipairs (DevHelperChooseIconDialogIcons.PopulatorIndices)
	do
		row_window_name = DevHelperChooseIcon.name .. "IconsRow"..k
		data = DevHelperChooseIcon.DialogListData[v]

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


function DevHelperChooseIcon.OnListRowLButtonUp ()

	local data_index = ListBoxGetDataIndex (DevHelperChooseIcon.name .. "Icons", WindowGetId (SystemData.ActiveWindow.name))
	local icon_index = tonumber (SystemData.ActiveWindow.name:match (DevHelperChooseIcon.name .. "IconsRow%d+Icon(%d+)"))

	if (choose_icon_dlg.onOkCallback)
	then
		choose_icon_dlg.onOkCallback (DevHelperChooseIcon.DialogListData[data_index][icon_index])
	end

	DevHelperChooseIcon.Hide ()
end

function DevHelperChooseIcon.OnMouseOverCreateTooltip()
	local dataIndex = ListBoxGetDataIndex (DevHelperChooseIcon.name .. "Icons", WindowGetId (SystemData.ActiveWindow.name))
	local iconIndex = tonumber (SystemData.ActiveWindow.name:match (DevHelperChooseIcon.name .. "IconsRow%d+Icon(%d+)"))

	local iconId = DevHelperChooseIcon.DialogListData[dataIndex][iconIndex];

	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=0, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, towstring("Icon Id: " .. iconId))
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end
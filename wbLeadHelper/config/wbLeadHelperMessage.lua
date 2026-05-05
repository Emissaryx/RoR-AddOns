local tinsert = table.insert
local pairs = pairs

--WbLeadHelperMessage class
WbLeadHelperMessage = {}
WbLeadHelperMessage.__index = WbLeadHelperMessage

function WbLeadHelperMessage.New (data)
	local obj = {}
	setmetatable (obj, WbLeadHelperMessage)

	-- defaults
	obj.label = nil
	obj.labelColor = 1
	obj.message = nil
	obj.messageColor = 1
	obj.type = 1
	obj.submenu = 1
	obj.isNotEnabled = false
	
	if (data)
	then
		obj:Load (data)
	end

	return obj
end


function WbLeadHelperMessage:Load (data)

	self.label = data.label
	self.labelColor = data.labelColor
	self.message = data.message
	self.messageColor = data.messageColor
	self.type = data.type
	self.submenu = data.submenu or 1
	self.isNotEnabled = data.isNotEnabled

end


function WbLeadHelperMessage:Edit (onOkCallback)
	WbLeadHelperMessage.MessageDialogOpen (self, function (old, new)
		old:Load (new)
		if (onOkCallback) then
			onOkCallback (self)
		end
	end)
end

----------------------------------------------------------------- UI: Click casting dialog
local message_dlg = {
	isInitialized = false,
	colors = {},
	submenus = {}
}

function WbLeadHelperMessage.MessageDialogIsOpen ()
	return WindowGetShowing ("WbLeadHelperMessage")
end

function  WbLeadHelperMessage.MessageDialogHide ()
	WindowSetShowing ("WbLeadHelperMessage", false)
end

function WbLeadHelperMessage.MessageDialogOpen (data, onOkCallback)

	message_dlg.isLoading = true

	if (not message_dlg.isInitialized) then
		-- initialize dialog UI
		CreateWindow ("WbLeadHelperMessage", false)

		LabelSetText ("WbLeadHelperMessageTitleBarText", L"Button config")
		ButtonSetText ("WbLeadHelperMessageOkButton", L"OK")
		ButtonSetText ("WbLeadHelperMessageCancelButton", L"Cancel")

		LabelSetText ("WbLeadHelperMessageContentScrollChildLabelLabel", L"Label:")
		LabelSetText ("WbLeadHelperMessageContentScrollChildLabelColor", L"Label color:")
		local i = 1
		for k,v in pairs(wbLeadHelper.Colors) do
			ComboBoxAddMenuItem ("WbLeadHelperMessageContentScrollChildLabelColorCombobox", towstring(k))
			message_dlg.colors[i] = k
			i = i + 1
		end

		LabelSetText ("WbLeadHelperMessageContentScrollChildMessageLabel", L"Message:")
		LabelSetText ("WbLeadHelperMessageContentScrollChildMessageColor", L"Message color:")
		for k,v in pairs(wbLeadHelper.Colors) do
			ComboBoxAddMenuItem ("WbLeadHelperMessageContentScrollChildMessageColorCombobox", towstring(k))
		end

		LabelSetText ("WbLeadHelperMessageContentScrollChildTypeLabel", L"Type:")
		for i=1, #wbLeadHelper.messageTypes do
			ComboBoxAddMenuItem ("WbLeadHelperMessageContentScrollChildTypeCombobox", towstring(wbLeadHelper.messageTypes[i]))
		end

		LabelSetText ("WbLeadHelperMessageContentScrollChildSubmenuLabel", L"Submenu of:")
		ComboBoxAddMenuItem ("WbLeadHelperMessageContentScrollChildSubmenuCombobox", L"None")
		ComboBoxAddMenuItem ("WbLeadHelperMessageContentScrollChildSubmenuCombobox", L"Parent")
		tinsert(message_dlg.submenus, "None")
		tinsert(message_dlg.submenus, "Parent")
		for k,v in pairs(wbLeadHelper.messageTypes) do
			if v ~= "Normal" and v ~= "Zones"  and v ~= "Bos" then
				ComboBoxAddMenuItem ("WbLeadHelperMessageContentScrollChildSubmenuCombobox", towstring(v))
				tinsert(message_dlg.submenus, v)
			end
		end
		message_dlg.isInitialized = true
	end

	-- proceed parameters
	message_dlg.oldData = data
	message_dlg.onOkCallback = onOkCallback

	message_dlg.data = WbLeadHelperMessage.New (data)

	-- fill form with existing data if available
	TextEditBoxSetText ("WbLeadHelperMessageContentScrollChildLabelText",towstring( wbLeadHelper.isNil( message_dlg.data.label, L"")))
	if type(message_dlg.data.labelColor) ~= "number" then
		message_dlg.data.labelColor = wbLeadHelper.indexOf(message_dlg.colors, message_dlg.data.labelColor)
	end
	ComboBoxSetSelectedMenuItem ("WbLeadHelperMessageContentScrollChildLabelColorCombobox", message_dlg.data.labelColor)

	TextEditBoxSetText ("WbLeadHelperMessageContentScrollChildMessageText",towstring( wbLeadHelper.isNil( message_dlg.data.message, L"")))
	if type(message_dlg.data.messageColor) ~= "number" then
		message_dlg.data.messageColor = wbLeadHelper.indexOf(message_dlg.colors, message_dlg.data.messageColor)
	end
	ComboBoxSetSelectedMenuItem ("WbLeadHelperMessageContentScrollChildMessageColorCombobox", message_dlg.data.messageColor)

	if type(message_dlg.data.type) ~= "number" then
		message_dlg.data.type = wbLeadHelper.indexOf(wbLeadHelper.messageTypes, message_dlg.data.type)
	end
	ComboBoxSetSelectedMenuItem ("WbLeadHelperMessageContentScrollChildTypeCombobox", message_dlg.data.type)

	if type(message_dlg.data.submenu) ~= "number" then
		message_dlg.data.submenu = wbLeadHelper.indexOf(message_dlg.submenus, message_dlg.data.submenu)
	end
	ComboBoxSetSelectedMenuItem ("WbLeadHelperMessageContentScrollChildSubmenuCombobox", message_dlg.data.submenu)

	message_dlg.isLoading = false
	WindowSetShowing ("WbLeadHelperMessage", true)

	ScrollWindowSetOffset ("WbLeadHelperMessageContent", 0)
	ScrollWindowUpdateScrollRect ("WbLeadHelperMessageContent")
end

function WbLeadHelperMessage.OnOk ()

	if (message_dlg.isLoading or not WbLeadHelperMessage.MessageDialogIsOpen()) then return end

	message_dlg.data.label = wbLeadHelper.isEmpty (TextEditBoxGetText ("WbLeadHelperMessageContentScrollChildLabelText"), nil)
	message_dlg.data.label = tostring( message_dlg.data.label )
	message_dlg.data.labelColor = ComboBoxGetSelectedMenuItem ("WbLeadHelperMessageContentScrollChildLabelColorCombobox")
	message_dlg.data.labelColor = message_dlg.colors[message_dlg.data.labelColor]
	message_dlg.data.labelColor = tostring( message_dlg.data.labelColor )
	message_dlg.data.message = wbLeadHelper.isEmpty (TextEditBoxGetText ("WbLeadHelperMessageContentScrollChildMessageText"), nil)
	message_dlg.data.message = tostring( message_dlg.data.message )
	message_dlg.data.messageColor = ComboBoxGetSelectedMenuItem ("WbLeadHelperMessageContentScrollChildMessageColorCombobox")
	message_dlg.data.messageColor = message_dlg.colors[message_dlg.data.messageColor]
	message_dlg.data.messageColor = tostring( message_dlg.data.messageColor )	
	message_dlg.data.type = ComboBoxGetSelectedMenuItem ("WbLeadHelperMessageContentScrollChildTypeCombobox")
	message_dlg.data.type = wbLeadHelper.messageTypes[message_dlg.data.type]
	message_dlg.data.type = tostring( message_dlg.data.type )
	message_dlg.data.submenu = ComboBoxGetSelectedMenuItem ("WbLeadHelperMessageContentScrollChildSubmenuCombobox")
	message_dlg.data.submenu = message_dlg.submenus[message_dlg.data.submenu]
	message_dlg.data.submenu = tostring( message_dlg.data.submenu )

	if (not message_dlg.data.label) then
		DialogManager.MakeOneButtonDialog (L"You must enter a label.", L"Ok")
		return
	end

	if (message_dlg.onOkCallback) then
		message_dlg.onOkCallback (message_dlg.oldData, message_dlg.data)
	end

	WbLeadHelperMessage.MessageDialogHide()
end

function WbLeadHelperMessage.OnMouseOverLabelEditBox()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"The text of the button.\n\nYou can use the tag <nl> to force a new line.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function WbLeadHelperMessage.OnMouseOverMessageEditBox()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, 
    	L"The message seen in chat.\n\n" .. 

    	L"There are different \"tags\" available depending on what \"Type\" and \"Submenu type\" you choose below.\n\n" ..

    	L"Most tags should be self explanatory. Have a look at the default message for how they work.\n\n" .. 

    	L"Type LFM, Submenu None:\nTags <LFM>, <LFMZ>, <GL>\n" ..
    	L"Type LFM, Submenu Any:\n<healer>, <tank>, <dps> get a little icon in the final message.\n" ..
    	L"<autoRolesNUM> scans the group/warband for NUM missing roles. E.g.: <autoRoles8> for 8 of each role\n\n" ..
    	
    	L"/ANYTHING at the START of the message, to choose a specific chat channel. E.g.: \"/party test\" will post \"test\" in the party channel."
    )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function WbLeadHelperMessage.OnMouseOverTypeComboBox()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, 
    	L"The message type.\n\n" .. 

    	L"\"Normal\" Usually all messages without a submenu.\n" ..
    	L"Use the default messages as examples for the other types."
    )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function WbLeadHelperMessage.OnMouseOverSubmenuComboBox()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, 
    	L"Makes this message a submenu.\n(Only for type: LFM at the moment)\n\n" .. 

    	L"\"None\" Normal message, no submenu, the default. \n\n" ..

    	L"\"Parent\" The message is a submenu. Appears only in the menu of the first parent in the list.\n\n" ..

    	L"\"LFM\" The message is a submenu. Appears in all menus of the type LFM."
    )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

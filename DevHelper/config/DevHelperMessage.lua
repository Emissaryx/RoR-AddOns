local tinsert = table.insert
local tsort = table.sort
local ipairs = ipairs
local pairs = pairs

--DevHelperMessage class
DevHelperMessage = {}
DevHelperMessage.__index = DevHelperMessage

function DevHelperMessage.New (data)
	local obj = {}
	setmetatable (obj, DevHelperMessage)

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


function DevHelperMessage:Load (data)

	self.label = data.label
	self.labelColor = data.labelColor
	self.message = data.message
	self.messageColor = data.messageColor
	self.type = data.type
	self.submenu = data.submenu or 1
	self.isNotEnabled = data.isNotEnabled

end


function DevHelperMessage:Edit (onOkCallback)
	DevHelperMessage.MessageDialogOpen (self, self.id, function (old, new)
		old:Load (new)
		if (onOkCallback) then
			onOkCallback (self)
		end
	end)
end


function DevHelperMessage:Remove ()
end

----------------------------------------------------------------- UI: Click casting dialog
local message_dlg = {
	isInitialized = false,
	colors = {},
	submenus = {}
}

function DevHelperMessage.MessageDialogIsOpen ()
	return WindowGetShowing ("DevHelperMessage")
end

function  DevHelperMessage.MessageDialogHide ()
	WindowSetShowing ("DevHelperMessage", false)
end

function DevHelperMessage.MessageDialogOpen (data, ignoreId, onOkCallback)

	message_dlg.isLoading = true

	if (not message_dlg.isInitialized) then
		-- initialize dialog UI
		CreateWindow ("DevHelperMessage", false)

		LabelSetText ("DevHelperMessageTitleBarText", L"Button config")
		ButtonSetText ("DevHelperMessageOkButton", L"OK")
		ButtonSetText ("DevHelperMessageCancelButton", L"Cancel")

		LabelSetText ("DevHelperMessageContentScrollChildLabelLabel", L"Label:")
		LabelSetText ("DevHelperMessageContentScrollChildLabelColor", L"Label color:")
		local i = 1
		for k,v in pairs(DevHelper.Colors) do
			ComboBoxAddMenuItem ("DevHelperMessageContentScrollChildLabelColorCombobox", towstring(k))
			message_dlg.colors[i] = k
			i = i + 1
		end

		LabelSetText ("DevHelperMessageContentScrollChildMessageLabel", L"Message:")
		LabelSetText ("DevHelperMessageContentScrollChildMessageColor", L"Message color:")
		for k,v in pairs(DevHelper.Colors) do
			ComboBoxAddMenuItem ("DevHelperMessageContentScrollChildMessageColorCombobox", towstring(k))
		end

		LabelSetText ("DevHelperMessageContentScrollChildTypeLabel", L"Type:")
		for i=1, #DevHelper.messageTypes do
			ComboBoxAddMenuItem ("DevHelperMessageContentScrollChildTypeCombobox", towstring(DevHelper.messageTypes[i]))
		end

		LabelSetText ("DevHelperMessageContentScrollChildSubmenuLabel", L"Submenu of:")
		ComboBoxAddMenuItem ("DevHelperMessageContentScrollChildSubmenuCombobox", L"None")
		ComboBoxAddMenuItem ("DevHelperMessageContentScrollChildSubmenuCombobox", L"Parent")
		tinsert(message_dlg.submenus, "None")
		tinsert(message_dlg.submenus, "Parent")
		for k,v in pairs(DevHelper.messageTypes) do
			if v ~= "Normal" and v ~= "Zones"  and v ~= "Bos" and v ~= "NPCHEALTH" then
				ComboBoxAddMenuItem ("DevHelperMessageContentScrollChildSubmenuCombobox", towstring(v))
				tinsert(message_dlg.submenus, v)
			end
		end
		message_dlg.isInitialized = true
	end

	-- proceed parameters
	message_dlg.oldData = data
	message_dlg.onOkCallback = onOkCallback

	message_dlg.data = DevHelperMessage.New (data)

	-- fill form with existing data if available
	TextEditBoxSetText ("DevHelperMessageContentScrollChildLabelText",towstring( DevHelper.isNil( message_dlg.data.label, L"")))
	d(message_dlg.data.label)
	if type(message_dlg.data.labelColor) ~= "number" then
		message_dlg.data.labelColor = DevHelper.indexOf(message_dlg.colors, message_dlg.data.labelColor)
	end
	ComboBoxSetSelectedMenuItem ("DevHelperMessageContentScrollChildLabelColorCombobox", message_dlg.data.labelColor)

	TextEditBoxSetText ("DevHelperMessageContentScrollChildMessageText",towstring( DevHelper.isNil( message_dlg.data.message, L"")))
	if type(message_dlg.data.messageColor) ~= "number" then
		message_dlg.data.messageColor = DevHelper.indexOf(message_dlg.colors, message_dlg.data.messageColor)
	end
	ComboBoxSetSelectedMenuItem ("DevHelperMessageContentScrollChildMessageColorCombobox", message_dlg.data.messageColor)

	if type(message_dlg.data.type) ~= "number" then
		message_dlg.data.type = DevHelper.indexOf(DevHelper.messageTypes, message_dlg.data.type)
	end
	ComboBoxSetSelectedMenuItem ("DevHelperMessageContentScrollChildTypeCombobox", message_dlg.data.type)

	if type(message_dlg.data.submenu) ~= "number" then
		message_dlg.data.submenu = DevHelper.indexOf(message_dlg.submenus, message_dlg.data.submenu)
	end
	ComboBoxSetSelectedMenuItem ("DevHelperMessageContentScrollChildSubmenuCombobox", message_dlg.data.submenu)

	message_dlg.isLoading = false
	WindowSetShowing ("DevHelperMessage", true)

	ScrollWindowSetOffset ("DevHelperMessageContent", 0)
	ScrollWindowUpdateScrollRect ("DevHelperMessageContent")
end

function DevHelperMessage.OnOk ()

	if (message_dlg.isLoading or not DevHelperMessage.MessageDialogIsOpen()) then return end

	message_dlg.data.label = DevHelper.isEmpty (TextEditBoxGetText ("DevHelperMessageContentScrollChildLabelText"), nil)
	message_dlg.data.label = tostring( message_dlg.data.label )
	message_dlg.data.labelColor = ComboBoxGetSelectedMenuItem ("DevHelperMessageContentScrollChildLabelColorCombobox")
	message_dlg.data.labelColor = message_dlg.colors[message_dlg.data.labelColor]
	message_dlg.data.labelColor = tostring( message_dlg.data.labelColor )
	message_dlg.data.message = DevHelper.isEmpty (TextEditBoxGetText ("DevHelperMessageContentScrollChildMessageText"), nil)
	message_dlg.data.message = tostring( message_dlg.data.message )
	message_dlg.data.messageColor = ComboBoxGetSelectedMenuItem ("DevHelperMessageContentScrollChildMessageColorCombobox")
	message_dlg.data.messageColor = message_dlg.colors[message_dlg.data.messageColor]
	message_dlg.data.messageColor = tostring( message_dlg.data.messageColor )	
	message_dlg.data.type = ComboBoxGetSelectedMenuItem ("DevHelperMessageContentScrollChildTypeCombobox")
	message_dlg.data.type = DevHelper.messageTypes[message_dlg.data.type]
	message_dlg.data.type = tostring( message_dlg.data.type )
	message_dlg.data.submenu = ComboBoxGetSelectedMenuItem ("DevHelperMessageContentScrollChildSubmenuCombobox")
	message_dlg.data.submenu = message_dlg.submenus[message_dlg.data.submenu]
	message_dlg.data.submenu = tostring( message_dlg.data.submenu )

	if (not message_dlg.data.label) then
		DialogManager.MakeOneButtonDialog (L"You must enter a label.", L"Ok")
		return
	end

	if (message_dlg.onOkCallback) then
		message_dlg.onOkCallback (message_dlg.oldData, message_dlg.data)
	end

	DevHelperMessage.MessageDialogHide()
end

function DevHelperMessage.OnMouseOverLabelEditBox()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"The text of the button.\n\nYou can use the tag <nl> to force a new line.")
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperMessage.OnMouseOverMessageEditBox()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, 
    	L"The message seen in chat.\n\n" .. 

    	L"There are different \"tags\" available depending on what \"Type\" and \"Submenu type\" you choose below.\n\n" ..

    	L"Most tags should be self exclanatory. Have a look at the default message for how they work.\n\n" .. 

    	L"Type other, Submenu None:\nTags <other>, <otherZ>, <GL>\n" ..
    	L"Type other, Submenu Any:\n<healer>, <tank>, <dps> get a little icon in the final message.\n" ..
    	L"<autoRolesNUM> scans the group/warband for NUM missing roles. E.g.: <autoRoles8> for 8 of each role\n\n" ..
    	
    	L"/ANYTHING at the START of the message, to choose a specific chat channel. E.g.: \"/party test\" will post \"test\" in the party channel."
    )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperMessage.OnMouseOverTypeComboBox()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, 
    	L"The message type.\n\n" .. 

    	L"\"Normal\" Usually all messages without a submenu." ..

    	L"Take a lok at the default "
    )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end

function DevHelperMessage.OnMouseOverSubmenuComboBox()
	-- just a tooltip
	local anchor = { Point="right",  RelativeTo=SystemData.ActiveWindow.name, RelativePoint="left", XOffset=5, YOffset=0 }
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, 
    	L"Makes this message a submenu.\n(Only for type: LFG at the moment)\n\n" .. 

    	L"\"None\" Normal message, no submenu, the default. \n\n" ..

    	L"\"Parent\" The message is a submenu. Appears only in the menu of the first parent in the list.\n\n" ..

    	L"\"LFG\" The message is a submenu. Appears in all menus of the type LFG."
    )
    Tooltips.Finalize();
    Tooltips.AnchorTooltip( anchor )
end
if not DevHelper then DevHelper = {} end

local activeTemplate = DevHelper.Templates[1]
local towstring = towstring
local CreateHyperLink = CreateHyperLink
local DoesWindowExist = DoesWindowExist
local table_insert = table.insert
local table_sort = table.sort
local DevHelperWindowName = "DevHelperWindow"
local showingAlternateTitle = false
local inLoadingScreen = false
local timerActive = 0
local activeChatChannel = ""
local subMenuActive = false
local zoneMenuActive = false
local boMenuActive = false
local otherMenuActive = false
local countdownMenuActive = false
local clickedMainMenuMessageId = 0
local tmpMessageActive = ""
local tmpColorActive = ""
local hookOnKeyEnter
local chatHookActive = false

local BACK_LABEL = "- BACK -"

DevHelper._destroyQueue = DevHelper._destroyQueue or {}
DevHelper.activeSettings = {}

local function IsMenuString(item)
	return type(item) == "string"
end

local function Print(str)
	EA_ChatWindow.Print(towstring(str))
end

function DevHelper.OnInitialize()

	-- load persistent settings
	if not DevHelper.Settings then 
		DevHelper.Settings = DevHelper.DefaultSettings
	end
	DevHelper.setActiveSettings(DevHelper.Settings)

	--check if settinsg have to be reset
	if not DevHelper.Settings.settingsVersion or DevHelper.Settings.settingsVersion < DevHelper.DefaultSettings.settingsVersion then
		DevHelper.DefaultSettingsChangedDialog()
	end

	hookOnKeyEnter = EA_ChatWindow.OnKeyEnter
	EA_ChatWindow.OnKeyEnter = DevHelper.OnKeyEnter
	chatHookActive = false

	if (DoesWindowExist(DevHelperWindowName) == false) then
		DevHelper.createDevHelperWindow()
	end
	
	RegisterEventHandler( SystemData.Events.LOADING_BEGIN, "DevHelper.LOADING_START")
	RegisterEventHandler( SystemData.Events.LOADING_END, "DevHelper.LOADING_END")
	
	if LibSlash then
		-- register LibSlash command "/DevHelper" and tries "/devh"
		LibSlash.RegisterSlashCmd("DevHelper", function(args) DevHelper.SlashCmd(args) end)
		if (not LibSlash.IsSlashCmdRegistered("devh")) then
			LibSlash.RegisterSlashCmd("devh", function(args) DevHelper.SlashCmd(args) end)
		end
		Print("<LINK data=\"0\" text=\"[DevHelper]\" color=\"50,255,10\"> Addon initialized. Use /devh or /DevHelper to show options.")
	else
		Print("<LINK data=\"0\" text=\"[DevHelper]\" color=\"50,255,10\"> Addon initialized.")
	end
	
end

function DevHelper.OnShutdown()
    -- Restore the original OnKeyEnter function
    EA_ChatWindow.OnKeyEnter = hookOnKeyEnter
    
    -- Disable the chat hook
    chatHookActive = false

    -- Unregister events if needed
    UnregisterEventHandler(SystemData.Events.LOADING_BEGIN, "DevHelper.LOADING_START")
    UnregisterEventHandler(SystemData.Events.LOADING_END, "DevHelper.LOADING_END")

    -- Check if there are any windows to destroy safely on shutdown
    if DevHelper.deferredWindowDestruction and DoesWindowExist(DevHelper.deferredWindowDestruction) then
        DestroyWindow(DevHelper.deferredWindowDestruction)
        DevHelper.deferredWindowDestruction = nil
    end
	
	 for i = 1, 100 do
        local win = "DevHelper_Message_" .. i
        if DoesWindowExist(win) then
            DestroyWindow(win)
        end
    end

    -- Any other necessary cleanup processes can be added here
end

function DevHelper.LOADING_START()
	inLoadingScreen = true
end

function DevHelper.LOADING_END()
	inLoadingScreen = false
end


function DevHelper.SlashCmd(args)

	local command
	local parameter
	local separator = string.find(args," ")
	
	if separator then
		command = string.sub(args, 0, separator - 1)
		parameter = string.sub(args, separator + 1, -1)
	else
		command = args
	end
	

	if ( command == "show"or command == "s" or command == "toggle" or command == "t") then
		DevHelper.toggleDevHelperWindow()
	elseif ( command == "config" or command == "cfg" or command == "c") then
		DevHelperConfigWindow.Show()
	else 
		Print("<LINK data=\"0\" text=\"[DevHelper]\" color=\"50,255,10\"> /devh show - toggle the main window.")
		Print("<LINK data=\"0\" text=\"[DevHelper]\" color=\"50,255,10\"> /devh config - open the configuration window.")
	end
	
end

function DevHelper.createDevHelperWindow()

	if (DoesWindowExist(DevHelperWindowName) == false) then 
		CreateWindow(DevHelperWindowName, false)
	end
	showingAlternateTitle = false
		
	-- title label background
	WindowSetTintColor(DevHelperWindowName .. "TitleBackground", 0, 0, 0)
	WindowSetAlpha(DevHelperWindowName .. "TitleBackground", 0.55)

	WindowSetDimensions( DevHelperWindowName .. "Title", activeTemplate.titleWidth, 30)
	WindowSetDimensions( DevHelperWindowName .. "TitleLabel", activeTemplate.titleWidth, 30)

	ButtonSetText (DevHelperWindowName .."CloseButton", L"X")
	--ButtonSetText (DevHelperWindowName .."ChatButton", L"CM")

	WindowSetScale( DevHelperWindowName, DevHelper.activeSettings.windowSize )

	DevHelper.draw()
	
end

function DevHelper.hideDevHelperWindowName()
	DevHelper.toggleDevHelperWindow()
end

local TIME_DELAY2 = 1
local timeLeft2 = 1
local timerDelay = 5
function DevHelper.timerUpdate(elapsed)

	if (inLoadingScreen == true) then return end

	timeLeft2 = timeLeft2 - elapsed
    if (timeLeft2 > 0) then
        return
    end
	
	if (timerActive > 10) then
		if (timerDelay == 1 ) then
			--d(timerActive)
			--d(activeChatChannel)
			DevHelper.chat(timerActive, activeChatChannel, tmpColorActive)
			timerDelay = 5
		else
			timerDelay = timerDelay -1
		end
		--d("delay: " .. tostring(timerDelay))
	elseif (timerActive > 0) then
		--d(timerActive)
		--d(activeChatChannel)
		DevHelper.chat(timerActive, activeChatChannel, tmpColorActive)
		timerDelay = 5
	end
	if (timerActive > 0) then
		timerActive = timerActive -1
	end
	
	timeLeft2 = TIME_DELAY2
end

function DevHelper.draw(toggle)

	if ( zoneMenuActive == true) then return end
	if ( boMenuActive == true) then return end
	if ( otherMenuActive == true) then return end
	if ( countdownMenuActive == true) then return end
	
	DevHelper.drawWindows(DevHelper.activeSettings.messages, toggle)

end

function DevHelper.drawCountdownMenu(countdowns)
	DevHelper.drawWindows(countdowns)
end

function DevHelper.drawZoneMenu(zoneNames)
	DevHelper.drawWindows(zoneNames)
end

function DevHelper.drawBoMenu(bos)
	DevHelper.drawWindows(bos)
end

function DevHelper.drawotherMenu(other)
	DevHelper.drawWindows(other)
end

-- IMPORTANT MENU INVARIANTS:
-- 1) BACK is a STRING, not a table
-- 2) BACK must always be index 1 in submenu lists
-- 3) submenu filtering applies ONLY to table items
-- 4) item indices must align with DevHelper_Message_<index>
-- Violating these WILL break BACK and menu layout
function DevHelper.drawWindows(items, toggle)

	if (not items) then return end
	
	if subMenuActive and items[1] ~= BACK_LABEL then
		d("DevHelper ERROR: submenu missing BACK — draw aborted")
		return
	end

	local isVisible = WindowGetShowing(DevHelperWindowName)
	if (toggle) then
		WindowSetShowing(DevHelperWindowName, not isVisible)
	end

	DevHelper.hideWindows(100)

	-- draw windows for all messages
	local xOffset = 0
	local yOffset = (3 * DevHelper.activeSettings.windowSize)
	local bottomWindow = "DevHelperWindowTitle"
	local j = 1
	for i=1, #items do
		repeat

			if type(items[i]) == "table" and not items[i].submenu then 
				items[i].submenu = "None"
			end

			if items[i].isNotEnabled then
				do break end
			end

			-- if not subMenuActive and items[i].submenu ~= "None" then 
				-- do break end
			-- end 
			
			if type(items[i]) == "table" then
				if not subMenuActive and items[i].submenu ~= "None" then
					do break end
				end
			end


			local label = items[i].label or items[i]

			-- If submenu is active, inherit the parent color (tmpColorActive)
			local color
			if subMenuActive and tmpColorActive then
				color = tmpColorActive  -- Inherit parent menu color
			else
				color = DevHelper.Colors[items[i].labelColor] or DevHelper.Colors["white"]  -- Use item-specific color or default to white
			end

			-- replace linebreaks for text formatting
			label = label:gsub("<br>", "\n", 1) -- for backwards compatibility
			label = label:gsub("<nl>", "\n", 1)

			-- remove remaining tags so they are not shown in the label
			label = label:gsub("<", "")
			label = label:gsub(">", "")

			local messageWindow = "DevHelper_Message_" .. tostring(i)	
			if (DoesWindowExist(messageWindow) == false) then
				CreateWindowFromTemplate( messageWindow, "DevHelper_Message_Template", "Root")
			end
			
			WindowSetShowing(messageWindow, isVisible)
			WindowSetTintColor(messageWindow .. "Background", 0, 0, 0)
			WindowSetAlpha(messageWindow .. "Background", 0.5)

			LabelSetText(messageWindow .. "Label", towstring(label))
			LabelSetTextColor(messageWindow .. "Label", color[1], color[2], color[3])  -- Set the label color

			WindowSetDimensions(messageWindow .. "Label", activeTemplate.buttonWidth, activeTemplate.buttonHeight)
			WindowClearAnchors(messageWindow)
			WindowSetDimensions(messageWindow, activeTemplate.buttonWidth, activeTemplate.buttonHeight)

			WindowAddAnchor(messageWindow, "bottomleft", bottomWindow, "topleft", (xOffset / InterfaceCore.GetScale()) * DevHelper.activeSettings.windowSize, (2 / InterfaceCore.GetScale()) * DevHelper.activeSettings.windowSize)
			WindowSetScale(messageWindow, DevHelper.activeSettings.windowSize)
					
			if (toggle) then
				WindowSetShowing(messageWindow, not isVisible)
			else
				WindowSetShowing(messageWindow, isVisible)
			end

			bottomWindow = messageWindow

			if (j % activeTemplate.buttonsPerRow == 0) then
				xOffset = xOffset + (activeTemplate.buttonWidth + 2) * (j / activeTemplate.buttonsPerRow)
				bottomWindow = "DevHelperWindowTitle"
			else 
				xOffset = 0
			end

			j = j +1

		until true
	end

	if (showingAlternateTitle == false) then
		DevHelper.showNormalTitle()
	end
end

function DevHelper.extractColor(message)

	if ( not message ) then return end

	local color = DevHelper.Colors["white"]
	local aColor, cColor
	if(message:match("<%w+>")) then
		aColor = message:match("<(%w+)>")
		cColor = DevHelper.Colors[tostring(aColor)]
		if(cColor) then
			message = message:gsub("<%w+>", "", 1)
			message = DevHelper.trim(message)
			return message, cColor
		end
	end

	return message, color
end

-- function DevHelper.destroyWindows(number)

	-- if ( not number ) then return end

	-- for i=1, number do
		-- local messageWindow = "DevHelper_Message_" .. tostring(i)	
		-- if (DoesWindowExist(messageWindow) == true) then
			-- DestroyWindow(messageWindow)
		-- end
	-- end	
-- end

function DevHelper.hideWindows(number)
    if not number then return end

    for i = 1, number do
        local win = "DevHelper_Message_" .. tostring(i)
        if DoesWindowExist(win) then
            WindowSetShowing(win, false)
        end
    end
end

function DevHelper.destroyWindows(number)
	if not number then return end

	for i = 1, number do
		local win = "DevHelper_Message_" .. tostring(i)
		if DoesWindowExist(win) then
			DestroyWindow(win)
		end
	end
end

function DevHelper.toggleDevHelperWindow()
	DevHelper.draw(true)	
end

function DevHelper.onLMB()
	DevHelper.toChat("lmb")
end

function DevHelper.onRMB()
    -- Directly call the function to open the config window
    DevHelperConfigWindow.Show()
end

function DevHelper.toChat(mouseButton)

	local selectedWindow = towstring(SystemData.ActiveWindow.name)
	local mouseoverMessageId = selectedWindow:match(L"DevHelper_Message_(%d+)")
	mouseoverMessageId = tonumber(mouseoverMessageId)

	local item = DevHelper.activeSettings.messages[mouseoverMessageId]
	local message = ""
	if ( zoneMenuActive ) then
		local zoneNames = DevHelper.getAllZoneNames()
		message = zoneNames[mouseoverMessageId]
	elseif ( boMenuActive ) then
		local bos = DevHelper.getBObyZoneId(DevHelper.getCurrentZone())
		message = bos[mouseoverMessageId]
	elseif ( otherMenuActive ) then
		local other = DevHelper.getSubmenuMessages()
		message = other[mouseoverMessageId]
	elseif ( countdownMenuActive ) then
		local countdowns = DevHelper.getCountDowns()
		message = countdowns[mouseoverMessageId]
	else
		message = item.message
	end

	-- extract chat channel from message
	local chat = DevHelper.setChatChannel(mouseButton, message)
	message = message:gsub("^/%w+ ", "")	

	-- extract message color from message
	local color = DevHelper.Colors[item.messageColor] or DevHelper.Colors["white"]

	-- replace group leader tag
	if (message:match("<GL>")) then
		local groupLeader = "me"
		local checkLeader = DevHelper.getDever()
		if( checkLeader ~= nil and checkLeader ~= '') then 
			groupLeader = "@" .. checkLeader
		end
		message = message:gsub("<GL>", groupLeader)
	end


	--
	--
	-- When a sub menu is active or no more menus follow
	--
	--
	if(countdownMenuActive) then
		-- countdown menu is active
		DevHelper.hideWindows(100)

		if(message:match(BACK_LABEL)) then
		else
			local timerVal = tonumber(message)
			timerActive = timerVal -1 -- this value is monitored by the game update function.
			activeChatChannel = chat
			DevHelper.chat( timerVal .. " sec countdown started!", chat, tmpColorActive) --only the initial value is put in chat here
		end
		countdownMenuActive = false
		subMenuActive = false
		DevHelper.draw() -- draw here just to avoid a delay in the messages showing up again

	-- zoneMenu is active 
	elseif (zoneMenuActive) then

		DevHelper.hideWindows(100)

		if(message:match(BACK_LABEL)) then
		else
			local newMessage = message:upper()
			newMessage = tmpMessageActive:gsub("<Z>", newMessage)
			DevHelper.chat(newMessage, chat, tmpColorActive)
		end
		zoneMenuActive = false
		subMenuActive = false
		tmpMessageActive = ""
		tmpColorActive = ""

		DevHelper.draw() -- draw here just to avoid a delay in the messages showing up again

	-- boMenu is active 
	elseif (boMenuActive) then

		DevHelper.hideWindows(100)

		if(message:match(BACK_LABEL)) then
		else
			local newMessage = message:upper()
			newMessage = tmpMessageActive:gsub("<B>", newMessage)
			DevHelper.chat(newMessage, chat, tmpColorActive)
		end
		boMenuActive = false
		subMenuActive = false
		tmpMessageActive = ""
		tmpColorActive = ""

		DevHelper.draw() -- draw here just to avoid a delay in the messages showing up again

	elseif (otherMenuActive) then

		DevHelper.hideWindows(100)

		if(message:match(BACK_LABEL)) then
		        -- Handle back logic
		else
			local newMessage = message
			local match = message:match("<autoRoles(%d+)>")
			if (match) then
				match = tonumber(match)
				newMessage = DevHelper.AutoLookingForPlayers(match)
				if newMessage == "2" then
					Print("<LINK data=\"0\" text=\"[DevHelper]\" color=\"255,50,50\"> Warband full.")
				elseif not newMessage then 
					--this path should not be reached anymore, since a group with just you is used in case you are not in a warband.
					Print("<LINK data=\"0\" text=\"[DevHelper]\" color=\"255,50,50\"> Please join a warband before using the auto search feature.")
				end		
			end

			if (newMessage and newMessage ~= "2") then
				newMessage = tmpMessageActive:gsub("<other>", newMessage)
				local zone = GetZoneName(DevHelper.getCurrentZone())
				newMessage = newMessage:gsub("<otherZ>", tostring(zone))

				newMessage = DevHelper.addCareerIcons(newMessage)
	
				DevHelper.chat(newMessage, chat, tmpColorActive)
			end
		end
		otherMenuActive = false
		subMenuActive = false
		tmpMessageActive = ""
		tmpColorActive = ""

		DevHelper.draw() -- draw here just to avoid a delay in the messages showing up again


	--
	--
	-- When a first level menu is active (e.g. the initial messages are shown)
	--
	--
	elseif (item.type == "Countdown") then

		if(timerActive ~= 0) then
			timerActive = 0
			DevHelper.chat("Countdown aborted!", chat, color)
		else
			countdownMenuActive = true
			subMenuActive = true
			local countdowns = DevHelper.getCountDowns()
			DevHelper.drawCountdownMenu(countdowns)
			tmpColorActive = color
		end

	elseif (item.type == "Zones") then

		zoneMenuActive = true
		subMenuActive = true
		tmpMessageActive = message
		tmpColorActive = color

		local zoneNames = DevHelper.getAllZoneNames()

		DevHelper.drawZoneMenu(zoneNames)
	elseif (item.type == "other") then

		otherMenuActive = true
		subMenuActive = true
		tmpMessageActive = message
		tmpColorActive = color
		clickedMainMenuMessageId = mouseoverMessageId

		local otherNames = DevHelper.getSubmenuMessages("label")

		DevHelper.drawotherMenu(otherNames)

	elseif (item.type == "Bos") then

		local bos = DevHelper.getBObyZoneId(DevHelper.getCurrentZone())

		boMenuActive = true
		subMenuActive = true
		tmpMessageActive = message
		tmpColorActive = color

		DevHelper.drawBoMenu(bos)

	else
		DevHelper.chat(message, chat, color)	
	end
end

function DevHelper.chat(message, channel, color)

    local fullMessage = DevHelper.activeSettings.messageStart .. " " .. message .. " " .. DevHelper.activeSettings.messageEnd
    fullMessage = DevHelper.ColorText(fullMessage, color)

    -- If channel is provided, prepend it to the message
    if channel then
        fullMessage = channel .. fullMessage
    end

    -- Check if the config window is showing, for debugging or alternative output
    if WindowGetShowing(DevHelperConfigWindow.name) then
        Print("<LINK data=\"0\" text=\"[DevHelper]\" color=\"50,255,10\"> " .. fullMessage)
    else
        -- Convert the string to wide string format and send
        SendChatText(towstring(fullMessage), L"")
    end
end


function DevHelper.addCareerIcons(newMessage)
	local tankIcons = "<icon22702>"
	local healerIcons = "<icon22706>"
	local dpsIcons = "<icon22701>" 

	if(DevHelper.activeSettings.showLfgIcons) then
		tankIcons, healerIcons, dpsIcons = DevHelper.getOwnFactionCareerIconsByType()
	end

	newMessage = newMessage:gsub("<healer>", healerIcons.." healer")
	newMessage = newMessage:gsub("<tank>", tankIcons.." tank")
	newMessage = newMessage:gsub("<dps>", dpsIcons.." dps")

	return newMessage
end

function DevHelper.setChatChannel(mb, text)
    -- Check if the mouse button is left (lmb)
    if mb == "lmb" then
        -- Replace nil or invalid text with an empty string
        if not text or text == "nil" or text == "" then
            return -- Exit early if text is nil, "nil", or empty
        end

        -- Check if the text is "- BACK -" and avoid adding the "]" prefix
        if text == BACK_LABEL then
            -- Simply return without sending a command or adding a "]"
            return -- Prevents "- BACK -" from being processed
        end

        -- Prepare the command by prefixing it with "]" and appending the provided text for other messages
        local command = "]" .. text
        -- Convert the command string to wide string format, as required by the game API
        local wstringCommand = towstring(command)
        -- Attempt to send the command
        SendChatText(wstringCommand, L"")
    end
end

function DevHelper.onMouseOver()
	local hoverWindow = tostring(SystemData.MouseOverWindow.name)
	local color = DevHelper.Colors["grey"]
	WindowSetTintColor(hoverWindow, color[1], color[2], color[3])
end

function DevHelper.onMouseOut()
	DevHelper.showNormalTitle()

	local hoverWindow = tostring(SystemData.MouseOverWindow.name)
	local color = DevHelper.Colors["black"]	
	WindowSetTintColor(hoverWindow, color[1], color[2], color[3])		
end

function DevHelper.showNormalTitle()
	LabelSetText("DevHelperWindowTitleLabel", L"DevHelper")
end

function DevHelper.splitMessage(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function DevHelper.trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function DevHelper.getAllZoneNames()

	local zoneNames = {}
	table_insert(zoneNames, 1, BACK_LABEL)

	for i=1, #DevHelper.ZoneIds do
		local zoneName = tostring(GetZoneName(DevHelper.ZoneIds[i]))
		table_insert(zoneNames, zoneName)
	end

	return zoneNames
end

function DevHelper.getCountDowns()
	local countdowns = {} 
	table_insert(countdowns, 1, BACK_LABEL)

	for i=1, #DevHelper.CountdownSteps do
		table_insert(countdowns, tostring(DevHelper.CountdownSteps[i]))
	end

	return countdowns
end

function DevHelper.getCurrentZone()
	return GameData.Player.zone
end

function DevHelper.getBObyZoneId(id)

	local bos = {}
	table_insert(bos, 1, BACK_LABEL)

	for i=1, #DevHelper.BosByZoneId[id] do
		table_insert(bos, DevHelper.BosByZoneId[id][i])
	end

	for _, v in pairs(DevHelper.MiscBoNames) do
		table_insert(bos, v)
	end
	
	return bos
end

function DevHelper.getSubmenuMessages(messageType)

	if clickedMainMenuMessageId < 1 then return end
	if not messageType then messageType = "message" end

	local messages = {} 
	table_insert(messages, 1, BACK_LABEL)

	local clickedMessageType = DevHelper.activeSettings.messages[clickedMainMenuMessageId].type

	-- add messages with the submenu type "Parent"
	for i=clickedMainMenuMessageId+1, #DevHelper.activeSettings.messages do
		if DevHelper.activeSettings.messages[i].submenu == "Parent" then
			table_insert(messages, DevHelper.activeSettings.messages[i][messageType])
		end
		--break when no more submenus directly after the clickedMessage are found
		if DevHelper.activeSettings.messages[i].submenu == "None" or not DevHelper.activeSettings.messages[i].submenu then
			break
		end
	end
	
	-- add messages with the same type, no matter where they are located
	for i=1, #DevHelper.activeSettings.messages do
		if DevHelper.activeSettings.messages[i].submenu == clickedMessageType then
			table_insert(messages, DevHelper.activeSettings.messages[i][messageType])
		end
	end

	return messages
end

function DevHelper.toggleColoredChat()
	if not chatHookActive then
		Print("<LINK data=\"0\" text=\"[DevHelper]\" color=\"50,255,10\"> Permanent colored chat enabled.")
		chatHookActive = true
	else
		Print("<LINK data=\"0\" text=\"[DevHelper]\" color=\"50,255,10\"> Permanent colored chat disabled.")
		chatHookActive = false
	end
end

function DevHelper.OnKeyEnter(...)
	if not chatHookActive then
		return hookOnKeyEnter(...)
	end

	local message = DevHelper.trim(tostring(EA_TextEntryGroupEntryBoxTextInput.Text))
	message = DevHelper.activeSettings.messageStart .. " " .. message .. " " .. DevHelper.activeSettings.messageEnd	
	message = DevHelper.ColorText(message, DevHelper.Colors[DevHelper.activeSettings.textColor])

	EA_TextEntryGroupEntryBoxTextInput.Text = towstring(message)

	return hookOnKeyEnter(...)
end

function DevHelper.ColorText(text, color)

	if ( not text ) then return end
	if ( not color ) then color = DevHelper.Colors["white"] end

	-- Split sentences into single words so tehy can be colored and ignored seperately
	local words = DevHelper.mysplit(text)

	--d(words)

	local newText = ""
	local coloringStarted = false
	for i=1, #words do
		local word = words[i]
		if ( word == "" or word == nil or 
			 word:sub(1,1) == "/" or word:sub(1,1) == "." or 
			 word:sub(1,1) == "]" or word:sub(1,1) == "*" or 
			 word:sub(1,1) == "<") then

			-- end text coloring
			if(coloringStarted) then
				newText= newText .. "\">"
				coloringStarted = false
			end

			-- add the string without color
			newText = newText .. word .. " "
		elseif( word:sub(1,1) == "@") then
			-- end text coloring
			if(coloringStarted) then
				newText= newText .. "\">"
				coloringStarted = false
			end

			local pl = word:gsub("@", "")
			newText = newText .. tostring(CreateHyperLink(L"PLAYER:" .. towstring(pl), towstring(word), {}, {} )) .. " "
		else

			-- start text coloring
			if( not coloringStarted) then
				newText= newText .. "<LINK data=\"0\" color=\"" .. color[1] .. "," .. color[2] .. "," .. color[3] .. "\" text=\""
				coloringStarted = true
			end

			newText = newText .. word
			
			-- end of array close coloring if open
			if( i == table.getn(words) and coloringStarted) then
				newText = newText .. "\">"
			end

			newText = newText .. " "
		end	
	end	

	return newText
end

function DevHelper.mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function DevHelper.setActiveSettings(settings)
	DevHelper.activeSettings = settings
end 

function DevHelper.DefaultSettingsChangedDialog ()
	DialogManager.MakeTwoButtonDialog (
	L"DevHelper has to be reset to it's default settings to function properly. This will reset all custom messages you created!\n\nDo it now?",
	L"Yes",
	function ()
		DevHelper.Settings = DevHelper.DefaultSettings
		DevHelper.setActiveSettings(DevHelper.Settings)
		
		DevHelper.createDevHelperWindow()
		ModulesSaveSettings() -- Write SavedVariables.lua to disk
	end,
	L"No")
end

function DevHelper.isNil (value, nilReturnValue)
	if (value == nil) then return nilReturnValue end
	return value
end

function DevHelper.isEmpty (value, emptyReturnValue)
	if (not value or value:len() < 1) then return emptyReturnValue end
	return value
end

function DevHelper.indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end
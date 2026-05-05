if not wbLeadHelper then wbLeadHelper = {} end

-- TODO: maybe add a moral build + dump button
-- TODO: Shortcuts for buttons, maybe

local activeTemplate = wbLeadHelper.Templates[1];
local towstring = towstring
local CreateHyperLink = CreateHyperLink
local DoesWindowExist = DoesWindowExist
local table_insert = table.insert;
local wbLeadHelperWindowName = "wbLeadHelperWindow";
local showingAlternateTitle = false;
local inLoadingScreen = false;
local timerActive = 0;
local activeChatChannel = "";
local subMenuActive = false;
local zoneMenuActive = false;
local boMenuActive = false;
local lfmMenuActive = false;
local countdownMenuActive = false;
local clickedMainMenuMessageId = 0;
local tmpMessageActive = "";
local tmpColorActive = "";
local hookOnKeyEnter;
local chatHookActive = false;
local string_lower = string.lower;

wbLeadHelper.activeSettings = {};

local function Print(str)
	EA_ChatWindow.Print(towstring(str));
end

local function copySettingsTable(source)
	if type(source) ~= "table" then
		return source
	end

	local copy = {}
	for key, value in pairs(source) do
		copy[key] = copySettingsTable(value)
	end

	return copy
end

local function getSettingsMessagesCount(settings)
	if not settings or type(settings.messages) ~= "table" then
		return 0
	end

	return #settings.messages
end

local function settingsMessagesMatchDefaults(settings)
	if not settings or type(settings.messages) ~= "table" then
		return false
	end

	local savedMessages = settings.messages
	local defaultMessages = wbLeadHelper.DefaultSettings and wbLeadHelper.DefaultSettings.messages or {}

	if #savedMessages ~= #defaultMessages then
		return false
	end

	for i = 1, #defaultMessages do
		local saved = savedMessages[i]
		local default = defaultMessages[i]

		if type(saved) ~= "table" or type(default) ~= "table" then
			return false
		end

		local savedSubmenu = saved.submenu or "None"
		local defaultSubmenu = default.submenu or "None"
		local savedDisabled = saved.isNotEnabled and true or false
		local defaultDisabled = default.isNotEnabled and true or false

		if tostring(saved.label or "") ~= tostring(default.label or "")
			or tostring(saved.message or "") ~= tostring(default.message or "")
			or tostring(saved.type or "") ~= tostring(default.type or "")
			or tostring(savedSubmenu) ~= tostring(defaultSubmenu)
			or savedDisabled ~= defaultDisabled
		then
			return false
		end
	end

	return true
end

function wbLeadHelper.GetSettingsDebugSummary()
	local settings = wbLeadHelper.Settings
	local effectiveSettings = settings or wbLeadHelper.activeSettings
	local messageCount = getSettingsMessagesCount(effectiveSettings)
	local matchesDefaults = settingsMessagesMatchDefaults(effectiveSettings)
	local source = "saved/custom"

	if not settings then
		source = "missing"
	elseif settings == wbLeadHelper.DefaultSettings then
		source = "default-fallback"
	elseif messageCount == 0 then
		source = "saved/no-messages"
	elseif matchesDefaults then
		source = "saved/default-like"
	end

	local version = "nil"
	if effectiveSettings and effectiveSettings.settingsVersion ~= nil then
		version = tostring(effectiveSettings.settingsVersion)
	end

	local resetNeeded = "no"
	if settings
		and (not settings.settingsVersion
		or settings.settingsVersion < wbLeadHelper.DefaultSettings.settingsVersion
		)
	then
		resetNeeded = "yes"
	end

	return "source=" .. source
		.. ", messages=" .. tostring(messageCount)
		.. ", defaultLike=" .. (matchesDefaults and "yes" or "no")
		.. ", settingsVersion=" .. version
		.. ", resetNeeded=" .. resetNeeded
end

function wbLeadHelper.PrintSettingsDebugSummary(context)
	local suffix = ""
	if context and context ~= "" then
		suffix = " [" .. tostring(context) .. "]"
	end

	Print("<LINK data=\"0\" text=\"[wbLeadHelper]\" color=\"180,220,255\"> Settings debug" .. suffix .. ": " .. wbLeadHelper.GetSettingsDebugSummary())
end

function wbLeadHelper.OnInitialize()

	-- Load persistent settings if available; otherwise use a runtime copy of defaults.
	if not wbLeadHelper.Settings then
		wbLeadHelper.setActiveSettings(copySettingsTable(wbLeadHelper.DefaultSettings))
	else
		wbLeadHelper.setActiveSettings(wbLeadHelper.Settings)
	end
	wbLeadHelper.PrintSettingsDebugSummary("init")

	-- Check if saved settings need to be reset.
	if wbLeadHelper.Settings
		and (not wbLeadHelper.Settings.settingsVersion
		or wbLeadHelper.Settings.settingsVersion < wbLeadHelper.DefaultSettings.settingsVersion)
	then
		Print("<LINK data=\"0\" text=\"[wbLeadHelper]\" color=\"255,170,70\"> Settings debug: saved settings are missing or outdated, reset dialog will open.")
		wbLeadHelper.DefaultSettingsChangedDialog();
	end

	hookOnKeyEnter = EA_ChatWindow.OnKeyEnter;
	EA_ChatWindow.OnKeyEnter = wbLeadHelper.OnKeyEnter;
	chatHookActive = false

	if (DoesWindowExist(wbLeadHelperWindowName) == false) then
		wbLeadHelper.createWbLeadHelperWindow();
	end
	
	RegisterEventHandler( SystemData.Events.LOADING_BEGIN, "wbLeadHelper.LOADING_START");
	RegisterEventHandler( SystemData.Events.LOADING_END, "wbLeadHelper.LOADING_END");
	
	if LibSlash then
		-- register LibSlash command "/wbLeadHelper" and tries "/wlh"
		LibSlash.RegisterSlashCmd("wbLeadHelper", function(args) wbLeadHelper.SlashCmd(args) end);
		if (not LibSlash.IsSlashCmdRegistered("wlh")) then
			LibSlash.RegisterSlashCmd("wlh", function(args) wbLeadHelper.SlashCmd(args) end);
		end
		Print("<LINK data=\"0\" text=\"[wbLeadHelper]\" color=\"50,255,10\"> Addon initialized. Use /wlh or /wbLeadHelper to show options.");
	else
		Print("<LINK data=\"0\" text=\"[wbLeadHelper]\" color=\"50,255,10\"> Addon initialized.");
	end
	
end

function wbLeadHelper.OnShutdown()
	EA_ChatWindow.OnKeyEnter = hookOnKeyEnter;
	chatHookActive = false
end

function wbLeadHelper.LOADING_START()
	inLoadingScreen = true;
end

function wbLeadHelper.LOADING_END()
	inLoadingScreen = false;
end


function wbLeadHelper.SlashCmd(args)

	local command;
	local separator = string.find(args," ");
	
	if separator then
		command = string.sub(args, 0, separator - 1);
	else
		command = args;
	end
	

	if ( command == "show"or command == "s" or command == "toggle" or command == "t") then
		wbLeadHelper.toggleWbLeadHelperWindow();
	elseif ( command == "config" or command == "cfg" or command == "c") then
		wbLeadHelperConfigWindow.Show();
	else 
		Print("<LINK data=\"0\" text=\"[wbLeadHelper]\" color=\"50,255,10\"> /wlh show - toggle the main window.");
		Print("<LINK data=\"0\" text=\"[wbLeadHelper]\" color=\"50,255,10\"> /wlh config - open the configuration window.");
	end
	
end

function wbLeadHelper.createWbLeadHelperWindow()

	if (DoesWindowExist(wbLeadHelperWindowName) == false) then 
		CreateWindow(wbLeadHelperWindowName, false);
	end
	showingAlternateTitle = false;
		
	-- title label background
	WindowSetTintColor(wbLeadHelperWindowName .. "TitleBackground", 0, 0, 0);
	WindowSetAlpha(wbLeadHelperWindowName .. "TitleBackground", 0.55);

	WindowSetDimensions( wbLeadHelperWindowName .. "Title", activeTemplate.titleWidth, 30);
	WindowSetDimensions( wbLeadHelperWindowName .. "TitleLabel", activeTemplate.titleWidth, 30);

	ButtonSetText (wbLeadHelperWindowName .."CloseButton", L"X");
	ButtonSetText (wbLeadHelperWindowName .."ChatButton", L"CM");

	WindowSetScale( wbLeadHelperWindowName, wbLeadHelper.activeSettings.windowSize );

	wbLeadHelper.draw();
	
end

local TIME_DELAY2 = 1;
local timeLeft2 = 1;
local timerDelay = 5;
function wbLeadHelper.timerUpdate(elapsed)

	if (inLoadingScreen == true) then return end

	timeLeft2 = timeLeft2 - elapsed;
    if (timeLeft2 > 0) then
        return;
    end
	
	if (timerActive > 10) then
		if (timerDelay == 1 ) then
			--d(timerActive);
			--d(activeChatChannel);
			wbLeadHelper.chat(timerActive, activeChatChannel, tmpColorActive);
			timerDelay = 5;
		else
			timerDelay = timerDelay -1;
		end
		--d("delay: " .. tostring(timerDelay));
	elseif (timerActive > 0) then
		--d(timerActive);
		--d(activeChatChannel);
		wbLeadHelper.chat(timerActive, activeChatChannel, tmpColorActive);
		timerDelay = 5;
	end
	if (timerActive > 0) then
		timerActive = timerActive -1;
	end
	
	timeLeft2 = TIME_DELAY2;
end

function wbLeadHelper.draw(toggle)

	if ( zoneMenuActive == true) then return end
	if ( boMenuActive == true) then return end
	if ( lfmMenuActive == true) then return end
	if ( countdownMenuActive == true) then return end
	
	wbLeadHelper.drawWindows(wbLeadHelper.activeSettings.messages, toggle);

end

function wbLeadHelper.drawCountdownMenu(countdowns)
	wbLeadHelper.drawWindows(countdowns);
end

function wbLeadHelper.drawZoneMenu(zoneNames)
    wbLeadHelper._zoneMenuFlat = zoneNames

    local old = activeTemplate.buttonsPerRow
    activeTemplate.buttonsPerRow = 10
    wbLeadHelper.drawWindows(zoneNames)
    activeTemplate.buttonsPerRow = old
end

function wbLeadHelper.drawBoMenu(bos, miscBos)
	if not bos then return end

	local showMisc = wbLeadHelper.activeSettings
		and wbLeadHelper.activeSettings.showMiscBoColumn
		and miscBos and #miscBos > 0

	-- Left column = BOs only; remove misc names if they appear in bos
	local left = bos
	if showMisc then
		local mset = {}
		local function norm(s) return string.lower((tostring(s) or ""):gsub("<[^>]->","")):gsub("^%s+",""):gsub("%s+$","") end
		for i=1, #miscBos do mset[norm(miscBos[i])] = true end
		local filtered = {}
		for i=1, #bos do if not mset[norm(bos[i])] then table_insert(filtered, bos[i]) end end
		left = filtered
	end

	local flat = {}
	local rowsPerCol

	if showMisc then
		rowsPerCol = math.min(10, math.max(#left, #miscBos))
		if rowsPerCol < 1 then rowsPerCol = 1 end
		for i=1, #left do table_insert(flat, left[i]) end
		for i=#left+1, rowsPerCol do table_insert(flat, { __spacer = true, label = "" }) end
		for i=1, #miscBos do table_insert(flat, miscBos[i]) end
	else
		rowsPerCol = 10
		flat = left
	end

	wbLeadHelper._boMenuFlat = flat

	local old = activeTemplate.buttonsPerRow
	activeTemplate.buttonsPerRow = rowsPerCol
	wbLeadHelper.drawWindows(flat)
	activeTemplate.buttonsPerRow = old
end

function wbLeadHelper.drawLfmMenu(lfm)
	wbLeadHelper.drawWindows(lfm);
end

function wbLeadHelper.drawWindows(items, toggle)

	if ( not items ) then return end

	local isVisible = WindowGetShowing(wbLeadHelperWindowName);
	if (toggle) then
		WindowSetShowing(wbLeadHelperWindowName, not isVisible);
	end

	wbLeadHelper.destroyWindows(100);

	-- draw windows for all messages
	local xOffset = 0;
	local bottomWindow = "wbLeadHelperWindowTitle";
	local j = 1;
	for i=1, #items do
		repeat

			if type(items[i]) == "table" and not items[i].submenu then 
				items[i].submenu = "None";
			end

			if items[i].isNotEnabled then
				do break end
			end

			if not subMenuActive and items[i].submenu ~= "None" then 
				do break end
			end 

			local label = items[i].label or items[i];
			local color = wbLeadHelper.Colors[items[i].labelColor] or wbLeadHelper.Colors["white"];

			-- replace linebreaks for text formatting
			label = label:gsub("<br>", "\n", 1); --for backwards compatibility
			label = label:gsub("<nl>", "\n", 1);

			-- remove remaining tags so they are not shown in the label
			label = label:gsub("<", "");
			label = label:gsub(">", "");

			local messageWindow = "wbLeadHelper_Message_" .. tostring(i);	
			if (DoesWindowExist(messageWindow) == false) then
				CreateWindowFromTemplate( messageWindow, "wbLeadHelper_Message_Template", "Root");
			end
			
			WindowSetShowing( messageWindow, isVisible);
			WindowSetTintColor(messageWindow .. "Background", 0, 0, 0);
			-- Hide spacer rows (advance grid without drawing a button)
			if (type(items[i]) == "table" and items[i].__spacer) then
				WindowSetShowing(messageWindow, false);
			else

			WindowSetAlpha(messageWindow .. "Background", 0.5);
			end

			LabelSetText( messageWindow .. "Label", towstring(label));
			LabelSetTextColor(messageWindow .. "Label", color[1], color[2], color[3])

			WindowSetDimensions( messageWindow .. "Label", activeTemplate.buttonWidth, activeTemplate.buttonHeight);
			WindowClearAnchors( messageWindow );
			WindowSetDimensions( messageWindow, activeTemplate.buttonWidth, activeTemplate.buttonHeight);

			WindowAddAnchor( messageWindow , "bottomleft", bottomWindow, "topleft", (xOffset / InterfaceCore.GetScale()) * wbLeadHelper.activeSettings.windowSize, (2 / InterfaceCore.GetScale()) * wbLeadHelper.activeSettings.windowSize );
			WindowSetScale( messageWindow, wbLeadHelper.activeSettings.windowSize );
					
			if (type(items[i]) == "table" and items[i].__spacer) then
			WindowSetShowing(messageWindow, false);
		elseif (toggle) then
			WindowSetShowing( messageWindow, not isVisible);
		else
			WindowSetShowing( messageWindow, isVisible);
		end

			bottomWindow = messageWindow;

			if (j % activeTemplate.buttonsPerRow == 0) then
				xOffset = xOffset + (activeTemplate.buttonWidth + 2) * (j / activeTemplate.buttonsPerRow);
				bottomWindow = "wbLeadHelperWindowTitle";
			else 
				xOffset = 0;
			end

			j = j +1 ;

		until true
	end

	if (showingAlternateTitle == false) then
		wbLeadHelper.showNormalTitle();
	end
end

function wbLeadHelper.destroyWindows(number)

	if ( not number ) then return end

	for i=1, number do
		local messageWindow = "wbLeadHelper_Message_" .. tostring(i);	
		if (DoesWindowExist(messageWindow) == true) then
			DestroyWindow(messageWindow);
		end
	end	
end

function wbLeadHelper.toggleWbLeadHelperWindow()
	wbLeadHelper.draw(true);	
end

function wbLeadHelper.onLMB()
	wbLeadHelper.toChat("lmb");
end

function wbLeadHelper.onRMB()
	wbLeadHelper.toChat("rmb");
end

function wbLeadHelper.toChat(mouseButton)

	local selectedWindow = towstring(SystemData.ActiveWindow.name);
	local mouseoverMessageId = selectedWindow:match(L"wbLeadHelper_Message_(%d+)");
	mouseoverMessageId = tonumber(mouseoverMessageId);

	local item = wbLeadHelper.activeSettings.messages[mouseoverMessageId];
	local message = "";
	if ( zoneMenuActive ) then
		local zoneNames = wbLeadHelper._zoneMenuFlat or wbLeadHelper.getAllZoneNames()
		message = zoneNames[mouseoverMessageId]	elseif ( boMenuActive ) then
		-- use flattened list so misc/keeps work
		local idx = mouseoverMessageId
		local sel = wbLeadHelper._boMenuFlat and wbLeadHelper._boMenuFlat[idx]
		if type(sel) == "table" then
			message = sel.label or ""
		else
			message = sel or ""
		end
	elseif ( lfmMenuActive ) then
		local lfm = wbLeadHelper.getSubmenuMessages();
		message = lfm[mouseoverMessageId];
	elseif ( countdownMenuActive ) then
		local countdowns = wbLeadHelper.getCountDowns();
		message = countdowns[mouseoverMessageId];
	else
		message = item.message;
	end

	-- Resolve the chat channel; LFM submenu left-clicks always go to /5.
	local chat;
	if (lfmMenuActive and mouseButton == "lmb") then
		chat = "/5 ";
	else
		chat = wbLeadHelper.setChatChannel(mouseButton, message);
	end
	message = message:gsub("^/%w+ ", "")

	-- SAFE color lookup (prevents zone menu clicks from dying)
	local color = wbLeadHelper.Colors["white"]
	if item and item.messageColor then
	    color = wbLeadHelper.Colors[item.messageColor] or color
	end

	-- replace group leader tag
	if (message:match("<GL>")) then
		local groupLeader = "me";
		local checkLeader = wbLeadHelper.getWbLeader();
		if( checkLeader ~= nil and checkLeader ~= '') then 
			groupLeader = "@" .. checkLeader;
		end
		message = message:gsub("<GL>", groupLeader);
	end


	--
	--
	-- When a sub menu is active or no more menus follow
	--
	--
	if(countdownMenuActive) then
		-- countdown menu is active
		wbLeadHelper.destroyWindows(100);

		if(message:match("- BACK -")) then
		else
			local timerVal = tonumber(message);
			timerActive = timerVal -1; -- this value is monitored by the game update function.
			activeChatChannel = chat;
			wbLeadHelper.chat( timerVal .. " sec countdown started!", chat, tmpColorActive); --only the initial value is put in chat here
		end
		countdownMenuActive = false;
		subMenuActive = false;
		wbLeadHelper.draw(); -- draw here just to avoid a delay in the messages showing up again

	-- Zone menu is active.
	elseif (zoneMenuActive) then

		wbLeadHelper.destroyWindows(100);

		if(message:match("- BACK -")) then
		else
			local newMessage = message:upper();
			newMessage = tmpMessageActive:gsub("<Z>", newMessage);
			wbLeadHelper.chat(newMessage, chat, tmpColorActive);
		end
		zoneMenuActive = false;
		subMenuActive = false;
		tmpMessageActive = "";
		tmpColorActive = "";

		wbLeadHelper.draw(); -- draw here just to avoid a delay in the messages showing up again

	
	-- BO menu is active.
	elseif (boMenuActive) then

		wbLeadHelper.destroyWindows(100);

		if(message:match("- BACK -")) then
		else
			local idx = mouseoverMessageId
			local selected = wbLeadHelper._boMenuFlat and wbLeadHelper._boMenuFlat[idx] or message
			local newMessage = tostring(selected):upper();
			newMessage = tmpMessageActive:gsub("<B>", newMessage);
			wbLeadHelper.chat(newMessage, chat, tmpColorActive);
		end
		boMenuActive = false;
		subMenuActive = false;
		tmpMessageActive = "";
		tmpColorActive = "";

		wbLeadHelper.draw(); -- draw here just to avoid a delay in the messages showing up again

	elseif (lfmMenuActive) then

		wbLeadHelper.destroyWindows(100);

		if(message:match("- BACK -")) then
		else
			local newMessage = message;
			local match = message:match("<autoRoles(%d+)>");
			if (match) then
				match = tonumber(match);
				newMessage = wbLeadHelper.AutoLookingForPlayers(match);
				if newMessage == "2" then
					Print("<LINK data=\"0\" text=\"[wbLeadHelper]\" color=\"255,50,50\"> Warband full.");
				elseif not newMessage then 
					-- This path should not be reached anymore, since a party with just you is used outside warbands.
					Print("<LINK data=\"0\" text=\"[wbLeadHelper]\" color=\"255,50,50\"> Please join a warband before using the auto search feature.");
				end		
			end

			if (newMessage and newMessage ~= "2") then
				newMessage = tmpMessageActive:gsub("<LFM>", newMessage);
				local zone = GetZoneName(wbLeadHelper.getCurrentZone());
				newMessage = newMessage:gsub("<LFMZ>", tostring(zone));

				newMessage = wbLeadHelper.addCareerIcons(newMessage);
	
				wbLeadHelper.chat(newMessage, chat, tmpColorActive);
			end
		end
		lfmMenuActive = false;
		subMenuActive = false;
		tmpMessageActive = "";
		tmpColorActive = "";

		wbLeadHelper.draw(); -- draw here just to avoid a delay in the messages showing up again


	--
	--
	-- When a first level menu is active (e.g. the initial messages are shown)
	--
	--
	elseif (item.type == "Countdown") then

		if(timerActive ~= 0) then
			timerActive = 0;
			wbLeadHelper.chat("Countdown aborted!", chat, color);
		else
			countdownMenuActive = true;
			subMenuActive = true;
			local countdowns = wbLeadHelper.getCountDowns();
			wbLeadHelper.drawCountdownMenu(countdowns);
			tmpColorActive = color;
		end

	elseif (item.type == "Zones") then

		zoneMenuActive = true;
		subMenuActive = true;
		tmpMessageActive = message;
		tmpColorActive = color;

		local zoneNames = wbLeadHelper.getAllZoneNames();

		wbLeadHelper.drawZoneMenu(zoneNames);
	elseif (item.type == "LFM") then

		lfmMenuActive = true;
		subMenuActive = true;
		tmpMessageActive = message;
		tmpColorActive = color;
		clickedMainMenuMessageId = mouseoverMessageId;

		local lfmNames = wbLeadHelper.getSubmenuMessages("label");

		wbLeadHelper.drawLfmMenu(lfmNames);

	
elseif (item.type == "Bos") then

	local bos, miscBos = wbLeadHelper.getBObyZoneId(wbLeadHelper.getCurrentZone());

	boMenuActive = true;
	subMenuActive = true;
	tmpMessageActive = message;
	tmpColorActive = color;

	wbLeadHelper.drawBoMenu(bos, miscBos);

	else
		wbLeadHelper.chat(message, chat, color);	
	end
end

function wbLeadHelper.chat(message, channel, color)

	local message = wbLeadHelper.activeSettings.messageStart .. " " .. message .. " " .. wbLeadHelper.activeSettings.messageEnd;
	local message = wbLeadHelper.ColorText(message, color);
	message = channel .. message;

	--EA_ChatWindow.InsertText( towstring(message), towstring(channel) );
	if( WindowGetShowing(wbLeadHelperConfigWindow.name)) then
		Print("<LINK data=\"0\" text=\"[wbLeadHelper]\" color=\"50,255,10\"> " .. message);
	else
		SendChatText( towstring(message), L"" );
	end
end

function wbLeadHelper.addCareerIcons(newMessage)
	local tankIcons = "<icon22702>";
	local healerIcons = "<icon22706>";
	local dpsIcons = "<icon22701>"; 

	if(wbLeadHelper.activeSettings.showLfgIcons) then
		tankIcons, healerIcons, dpsIcons = wbLeadHelper.getOwnFactionCareerIconsByType();
	end

	newMessage = newMessage:gsub("<healer>", healerIcons.." healer");
	newMessage = newMessage:gsub("<tank>", tankIcons.." tank");
	newMessage = newMessage:gsub("<dps>", dpsIcons.." dps");

	return newMessage;
end

function wbLeadHelper.setChatChannel(mb, text)
    local pref = (type(text) == "string") and text:match("^/%w+%s")
    if pref then return pref end

    if mb == "lmb" then
        if IsWarBandActive and IsWarBandActive() then
            return "/wb "
        else
            return "/p "
        end
    end

    return "/1 "
end

function wbLeadHelper.onMouseOver()
	wbLeadHelper.onZoneMouseOver();
	wbLeadHelper.OnMouseOverCreateGroupStatsTooltip();

	local hoverWindow = tostring(SystemData.MouseOverWindow.name);
	local color = wbLeadHelper.Colors["grey"];
	WindowSetTintColor(hoverWindow, color[1], color[2], color[3]);
end

function wbLeadHelper.onMouseOut()
	wbLeadHelper.showNormalTitle();

	local hoverWindow = tostring(SystemData.MouseOverWindow.name);
	local color = wbLeadHelper.Colors["black"];	
	WindowSetTintColor(hoverWindow, color[1], color[2], color[3]);		
end

function wbLeadHelper.onZoneMouseOver()
    local label

    local hoverWindow = tostring(SystemData.MouseOverWindow.name or "")
    local mouseoverMessageId

    if hoverWindow ~= "" then
        local hoverWstr = towstring(hoverWindow)
        local match = hoverWstr:match(L"wbLeadHelper_Message_(%d+)Background")
        if match then
            mouseoverMessageId = tonumber(match)
        end
    end

    local isLFM = false
    if lfmMenuActive then
        isLFM = true
    elseif mouseoverMessageId
        and wbLeadHelper.activeSettings
        and wbLeadHelper.activeSettings.messages
        and wbLeadHelper.activeSettings.messages[mouseoverMessageId]
        and wbLeadHelper.activeSettings.messages[mouseoverMessageId].type == "LFM"
    then
        isLFM = true
    end

    if isLFM then
        label = L"LFG <icon00092> / <icon00093> Region"
    elseif IsWarBandActive and IsWarBandActive() then
        label = L"WB <icon00092> / <icon00093> Region"
    else
        label = L"Party <icon00092> / <icon00093> Region"
    end

    LabelSetText("wbLeadHelperWindowTitleLabel", label)
    showingAlternateTitle = true
end

function wbLeadHelper.showNormalTitle()
	LabelSetText("wbLeadHelperWindowTitleLabel", L"wbLeadHelper");
end

function wbLeadHelper.OnMouseOverCreateGroupStatsTooltip()

	if subMenuActive then return end

	local selectedWindow = towstring(SystemData.ActiveWindow.name);
	local mouseoverMessageId = selectedWindow:match(L"wbLeadHelper_Message_(%d+)Background");
	mouseoverMessageId = tonumber(mouseoverMessageId);

	local item = wbLeadHelper.activeSettings.messages[mouseoverMessageId];

	if item.type ~= "LFM" then return end

	-- search for AUTO message with the submenu type "Parent"
	local groupCount = 8;
	for i=mouseoverMessageId+1, #wbLeadHelper.activeSettings.messages do
		if wbLeadHelper.activeSettings.messages[i].submenu == "Parent" then
			local match = wbLeadHelper.activeSettings.messages[i].message:match("<autoRoles(%d+)>");
			if (match) then
				groupCount = tonumber(match);
				break;
			end
		end
		--break when no more submenus directly after the clickedMessage are found
		if wbLeadHelper.activeSettings.messages[i].submenu == "None" or not wbLeadHelper.activeSettings.messages[i].submenu then
			break
		end
	end

	local stats = wbLeadHelper.AutoLookingForPlayers(groupCount);

	if not stats or stats == "2" then return end

	stats = wbLeadHelper.addCareerIcons(stats);

	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
    Tooltips.SetTooltipText( 1, 1, towstring(" Missing roles\n " .. stats .. " \n"))
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
    Tooltips.Finalize();
end

function wbLeadHelper.trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function wbLeadHelper.getAllZoneNames()
    local zoneNames = {}
    table_insert(zoneNames, 1, "- BACK -")

    local src = wbLeadHelper.MoveTo or wbLeadHelper.ZoneIds
    for i = 1, #src do
        local zoneId = src[i]
        local zoneName = tostring(GetZoneName(zoneId))
        table_insert(zoneNames, zoneName)
    end

    return zoneNames
end

function wbLeadHelper.getCountDowns()
	local countdowns = {}; 
	table_insert(countdowns, 1, "- BACK -");

	for i=1, #wbLeadHelper.CountdownSteps do
		table_insert(countdowns, tostring(wbLeadHelper.CountdownSteps[i]));
	end

	return countdowns;
end

function wbLeadHelper.getCurrentZone()
	return GameData.Player.zone;
end


function wbLeadHelper.getBObyZoneId(id)

	local bos = {};
	table_insert(bos, 1, "- BACK -");

	for i=1, #wbLeadHelper.BosByZoneId[id] do
		table_insert(bos, wbLeadHelper.BosByZoneId[id][i]);
	end

	-- don't merge misc into main; return as separate list (whitelisted by zone)
	local misc = wbLeadHelper.GetMiscBoNamesForZone(id)

	return bos, misc;
end

function wbLeadHelper.getSubmenuMessages(messageType)

	if clickedMainMenuMessageId < 1 then return end
	if not messageType then messageType = "message" end

	local messages = {}; 
	table_insert(messages, 1, "- BACK -");

	local clickedMessageType = wbLeadHelper.activeSettings.messages[clickedMainMenuMessageId].type;

	-- add messages with the submenu type "Parent"
	for i=clickedMainMenuMessageId+1, #wbLeadHelper.activeSettings.messages do
		if wbLeadHelper.activeSettings.messages[i].submenu == "Parent" then
			table_insert(messages, wbLeadHelper.activeSettings.messages[i][messageType]);
		end
		--break when no more submenus directly after the clickedMessage are found
		if wbLeadHelper.activeSettings.messages[i].submenu == "None" or not wbLeadHelper.activeSettings.messages[i].submenu then
			break
		end
	end
	
	-- add messages with the same type, no matter where they are located
	for i=1, #wbLeadHelper.activeSettings.messages do
		if wbLeadHelper.activeSettings.messages[i].submenu == clickedMessageType then
			table_insert(messages, wbLeadHelper.activeSettings.messages[i][messageType]);
		end
	end

	return messages;
end

function wbLeadHelper.toggleColoredChat()
	if not chatHookActive then
		Print("<LINK data=\"0\" text=\"[wbLeadHelper]\" color=\"50,255,10\"> Permanent colored chat enabled.");
		chatHookActive = true;
	else
		Print("<LINK data=\"0\" text=\"[wbLeadHelper]\" color=\"50,255,10\"> Permanent colored chat disabled.");
		chatHookActive = false;
	end
end

function wbLeadHelper.OnKeyEnter(...)
	if not chatHookActive then
		return hookOnKeyEnter(...)
	end

	local message = wbLeadHelper.trim(tostring(EA_TextEntryGroupEntryBoxTextInput.Text));
	message = wbLeadHelper.activeSettings.messageStart .. " " .. message .. " " .. wbLeadHelper.activeSettings.messageEnd;	
	message = wbLeadHelper.ColorText(message, wbLeadHelper.Colors[wbLeadHelper.activeSettings.textColor]);

	EA_TextEntryGroupEntryBoxTextInput.Text = towstring(message);

	return hookOnKeyEnter(...);
end

function wbLeadHelper.ColorText(text, color)

	if ( not text ) then return end
	if ( not color ) then color = wbLeadHelper.Colors["white"] end

	-- Split text into words so links, commands, and player names can be handled separately.
	local words = wbLeadHelper.mysplit(text);

	--d(words)

	local newText = "";
	local coloringStarted = false;
	for i=1, #words do
		local word = words[i];
		if ( word == "" or word == nil or 
			 word:sub(1,1) == "/" or word:sub(1,1) == "." or 
			 word:sub(1,1) == "]" or word:sub(1,1) == "*" or 
			 word:sub(1,1) == "<") then

			-- end text coloring
			if(coloringStarted) then
				newText= newText .. "\">";
				coloringStarted = false;
			end

			-- add the string without color
			newText = newText .. word .. " ";
		elseif( word:sub(1,1) == "@") then
			-- end text coloring
			if(coloringStarted) then
				newText= newText .. "\">";
				coloringStarted = false;
			end

			local pl = word:gsub("@", "");
			newText = newText .. tostring(CreateHyperLink(L"PLAYER:" .. towstring(pl), towstring(word), {}, {} )) .. " ";
		else

			-- start text coloring
			if( not coloringStarted) then
				newText= newText .. "<LINK data=\"0\" color=\"" .. color[1] .. "," .. color[2] .. "," .. color[3] .. "\" text=\"";
				coloringStarted = true;
			end

			newText = newText .. word;
			
			-- end of array close coloring if open
			if( i == table.getn(words) and coloringStarted) then
				newText = newText .. "\">";
			end

			newText = newText .. " ";
		end	
	end	

	return newText;
end

function wbLeadHelper.mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function wbLeadHelper.AutoLookingForPlayers(roleCount)

	if not roleCount then roleCount = 8 end

	local groups = {};
	if wbLeadHelper.inWarBand() then
		groups = wbLeadHelper.gatherWarbandPlayers();
	else 
		groups = wbLeadHelper.gatherGroupPlayers();
	end

	--d(DUMP_TABLE(groups))

	if not groups then return end

	local tanks, healers, dpss = 0, 0, 0;
	for i=1, #groups do
		local grp = groups[i];
		--d(grp)
		for i=1, #grp do
			local player = grp[i];
			if (player.role == "tank") then
				tanks = tanks + 1
			end
			if (player.role == "healer") then
				healers = healers + 1
			end
			if (player.role == "mdps") then
				dpss = dpss + 1
			end
			if (player.role == "rdps") then
				dpss = dpss + 1
			end
		end
	end

	if (tanks == 0 and healers == 0 and dpss == 0) then return end
	if (tanks+healers+dpss == 24) then return "2" end

--[[	d("healers: " .. healers)
	d("tanks:   " .. tanks)
	d("dpss:    " .. dpss)
	d("total:   " .. tanks+healers+dpss)--]]

	if (tanks < roleCount or healers < roleCount or dpss < roleCount) then

		-- This may briefly target more than 24 roles while prioritizing healers, then tanks, then dps until the roster is full.

		local healersStr = "";
		if healers < roleCount then
			local neededHeals = roleCount - healers;
			if ( tanks+healers+dpss+neededHeals >= 24) then
				neededHeals = neededHeals - (tanks+healers+dpss+neededHeals - 24);
				healers = healers + neededHeals;
			end
			healersStr = neededHeals .. " <healer> ";
			if ( (tanks < roleCount or dpss < roleCount) and ( tanks+healers+dpss < 24) ) then 
				healersStr = healersStr .. "/ ";
			end
		end

		local tanksStr = "";
		if tanks < roleCount and ( tanks+healers+dpss < 24) then
			local neededTanks = roleCount - tanks;
			if ( tanks+healers+dpss+neededTanks >= 24) then
				neededTanks = neededTanks - (tanks+healers+dpss+neededTanks - 24);
				tanks = tanks + neededTanks;
			end
			tanksStr = neededTanks .. " <tank> ";
			if (dpss < roleCount and ( tanks+healers+dpss < 24) ) then 
				tanksStr = tanksStr .. "/ ";
			end
		end

		local dpssStr = "";
		if dpss < roleCount and ( tanks+healers+dpss < 24) then
			local neededDpss = roleCount - dpss;
			if ( tanks+healers+dpss+neededDpss >= 24) then
				neededDpss = neededDpss - (tanks+healers+dpss+neededDpss - 24);
				dpss = dpss + neededDpss;
			end
			dpssStr = neededDpss .. " <dps>";
		end

		return healersStr .. tanksStr .. dpssStr;
	end
end

-- Gather warband data and assign roles using the current alt-spec settings.
function wbLeadHelper.gatherWarbandPlayers()
	local group = {};
	local wbdata = GetBattlegroupMemberData();
	local altSpecDpsSet = wbLeadHelper.getAltSpecDpsSet();

	--wbdata = wbLeadHelper.FakeWbData;
	--wbdata = wbLeadHelper.FakeGroupData;
	--d(DUMP_TABLE(wbdata))

	for i in ipairs(wbdata) do
		group[i] = {};
	end

	for gid, grp in ipairs(wbdata) do
		for pid, player in ipairs(grp.players) do
			player.role = wbLeadHelper.getPlayerRole(player, altSpecDpsSet);
			table.insert(group[gid], player);
		end
	end

	return group;
end

-- Gather party data and assign roles using the current alt-spec settings.
function wbLeadHelper.gatherGroupPlayers()
	local group = {{}};
	--local gData = GroupWindow.groupData;
	local gData = PartyUtils.GetPartyData();
	local altSpecDpsSet = wbLeadHelper.getAltSpecDpsSet();

	--gData = wbLeadHelper.FakeGroupData2;
	--d(DUMP_TABLE(gData))

	-- Own player data
	local me = {
		["name"] = GameData.Player.name,
		["careerLine"] = GameData.Player.career.line,
		["role"] = wbLeadHelper.getPlayerRole({
			name = GameData.Player.name,
			careerLine = GameData.Player.career.line,
		}, altSpecDpsSet);
		["isGroupLeader"] = GameData.Player.isGroupLeader,
	}
	table.insert(group[1], me);

	for pid, player in ipairs(gData) do
		if player.online and me.name ~= player.name then
			player.role = wbLeadHelper.getPlayerRole(player, altSpecDpsSet);
			table.insert(group[1], player);
		end
	end

	return group;
end

function wbLeadHelper.getWbLeader()
	local groups;
	if wbLeadHelper.inWarBand() then
		groups = wbLeadHelper.gatherWarbandPlayers();
	else 
		groups = wbLeadHelper.gatherGroupPlayers();
	end

	local leader = "";
	for i=1, #groups do
		local grp = groups[i];
		for i=1, #grp do
			local player = grp[i];
			if (player.isGroupLeader) then
				leader = tostring(player.name);
			end
		end
	end

	return leader;
end

function wbLeadHelper.getPlayerRoleByCareer(id)
	local career = wbLeadHelper.CareerLineById[id];
	if career then
		return career.type;
	end
end

function wbLeadHelper.toNameString(name)
	if not name then return nil end

	if type(name) ~= "string" and WStringToString then
		name = WStringToString(name)
	end

	if type(name) ~= "string" then
		name = tostring(name)
	end

	return name
end

function wbLeadHelper.normalizeNameKey(name)
	local asString = wbLeadHelper.toNameString(name)
	if not asString then return nil end
	return string_lower(asString)
end

function wbLeadHelper.isRunePriestOrZealot(career)
	if not career or not GameData or not GameData.CareerLine then
		return false
	end

	return career == GameData.CareerLine.RUNE_PRIEST or career == GameData.CareerLine.ZEALOT
end

function wbLeadHelper.shouldIgnoreAltSpecForCareer(career)
	local settings = wbLeadHelper.activeSettings
	if not settings then
		return false
	end

	if settings.disableAltSpecCheck then
		return true
	end

	if settings.disableAltSpecCheckForRunePriestZealot and wbLeadHelper.isRunePriestOrZealot(career) then
		return true
	end

	return false
end

function wbLeadHelper.getScoreboardSource()
	local inScenario = GameData and GameData.Player and (GameData.Player.isInScenario or GameData.Player.isInSiege)

	if inScenario and ScenarioSummaryWindow and ScenarioSummaryWindow.playersData then
		return ScenarioSummaryWindow.playersData
	end

	if RoRGroupScoreboard and RoRGroupScoreboard.playersDataRaw then
		return RoRGroupScoreboard.playersDataRaw
	end

	return nil
end

function wbLeadHelper.getAltSpecDpsSet()
	if wbLeadHelper.activeSettings and wbLeadHelper.activeSettings.disableAltSpecCheck then
		return nil
	end

	local playersData = wbLeadHelper.getScoreboardSource()
	if not playersData then
		return nil
	end

	local set = {}
	for _, pdata in pairs(playersData) do
		local archetype = pdata and (pdata.archtype or pdata.archetype)
		archetype = tonumber(archetype)
		if archetype and archetype > 0 and pdata.name then
			local key = wbLeadHelper.normalizeNameKey(pdata.name)
			if key then
				set[key] = true
			end
		end
	end

	if next(set) == nil then
		return nil
	end

	return set
end

function wbLeadHelper.getPlayerRole(player, altSpecDpsSet)
	if not player then
		return nil
	end

	local career = player.careerLine or player.career
	local role = wbLeadHelper.getPlayerRoleByCareer(career)
	if role ~= "tank" and altSpecDpsSet and not wbLeadHelper.shouldIgnoreAltSpecForCareer(career) then
		local nameKey = wbLeadHelper.normalizeNameKey(player.name)
		if nameKey and altSpecDpsSet[nameKey] then
			return "rdps"
		end
	end

	return role
end

function wbLeadHelper.getOwnFactionCareerIconsByType()

	local TankIcons = "";
	local HealerIcons = "";
	local DpsIcons = "";

	for i=1, #wbLeadHelper.CareerLineById do
		local career = wbLeadHelper.CareerLineById[i];
		if(career.faction == GameData.Player.realm) then
			if (career.type == "tank") then
				TankIcons = TankIcons .. career.icon .. "";
			elseif (career.type == "healer") then
				HealerIcons = HealerIcons .. career.icon .. "";
			else
				DpsIcons = DpsIcons .. career.icon .. "";
			end
		end
	end

	return TankIcons, HealerIcons, DpsIcons;
end

function wbLeadHelper.EnsureSettingsTable()
	if wbLeadHelper.Settings then
		return wbLeadHelper.Settings
	end

	if wbLeadHelper.activeSettings and type(wbLeadHelper.activeSettings) == "table" then
		wbLeadHelper.Settings = copySettingsTable(wbLeadHelper.activeSettings)
	else
		wbLeadHelper.Settings = copySettingsTable(wbLeadHelper.DefaultSettings)
	end

	return wbLeadHelper.Settings
end

function wbLeadHelper.setActiveSettings(settings)
	if settings.disableAltSpecCheck == nil then
		settings.disableAltSpecCheck = wbLeadHelper.DefaultSettings.disableAltSpecCheck
	end

	if settings.disableAltSpecCheckForRunePriestZealot == nil then
		settings.disableAltSpecCheckForRunePriestZealot = wbLeadHelper.DefaultSettings.disableAltSpecCheckForRunePriestZealot
	end

	wbLeadHelper.activeSettings = settings;
end 

function wbLeadHelper.DefaultSettingsChangedDialog ()
	DialogManager.MakeTwoButtonDialog (
	L"wbLeadHelper has to be reset to it's default settings to function properly. This will reset all custom messages you created!\n\nDo it now?",
	L"Yes",
	function ()
		wbLeadHelper.Settings = wbLeadHelper.DefaultSettings;
		wbLeadHelper.setActiveSettings(wbLeadHelper.Settings)
		
		wbLeadHelper.createWbLeadHelperWindow()
		ModulesSaveSettings() -- Write SavedVariables.lua to disk
	end,
	L"No")
end

function wbLeadHelper.isNil (value, nilReturnValue)
	if (value == nil) then return nilReturnValue end
	return value
end

function wbLeadHelper.isEmpty (value, emptyReturnValue)
	if (not value or value:len() < 1) then return emptyReturnValue end
	return value
end

function wbLeadHelper.indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function wbLeadHelper.inWarBand()
    return IsWarBandActive()
end

function wbLeadHelper.inAParty()
    return GetNumGroupmates() > 0
end

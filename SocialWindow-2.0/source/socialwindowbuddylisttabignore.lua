-- Ignore List view
SocialWindowBuddyListTabIgnore = {}


local SelectedPlayerDataIndex    = 0
local SelectedFriendsName        = L""
local playerListOrder = {}
SocialWindowBuddyListTabIgnore.playerListData = {}
local ignoreDirty = true

local FRIENDTYPE = SocialWindowTabFriends.FRIENDTYPE
local FILTERTYPE = SocialWindowTabFriends.FILTERTYPE

SocialWindowBuddyListTabIgnore.filterLabels = {}

----------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------
SocialWindowBuddyListTabIgnore.Settings = {}
SocialWindowBuddyListTabIgnore.Settings.filters = {}

-- This function is used as the comparison function for 
-- table.sort() on the player display order
local function ComparePlayers(index1, index2)
    if (index2 == nil) then
        return false
    end

    local player1 = SocialWindowBuddyListTabIgnore.playerListData[index1]
    local player2 = SocialWindowBuddyListTabIgnore.playerListData[index2]
    
    if (player1 == nil or player1.name == nil or player1.name == L"") then
        return false
    end
    
    if (player2 == nil or player2.name == nil or player2.name == L"") then
        return true
    end

    local compareResult = 0
    local Player1Online = not (WStringsCompare(player1.onlineString, GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE)) == 0)
    local Player2Online = not (WStringsCompare(player2.onlineString, GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE)) == 0)
    if Player1Online and Player2Online then
        compareResult = WStringsCompare(player1.name, player2.name)
    elseif (Player1Online or Player2Online) then
        if Player1Online then
            compareResult = -1
        else
            compareResult = 1
        end
    else
        compareResult = 0
    end

    if (compareResult == 0) then
        compareResult = WStringsCompare(player1.name, player2.name)
    end

    return (compareResult < 0)
end

local function InitPlayerListData()
    SocialWindowBuddyListTabIgnore.playerListData = {}
    local IgnoreListData = GetIgnoreList()   
    if (IgnoreListData ~= nil) then
        for key, value in ipairs(IgnoreListData) do
            -- These should match the data that was retrived from war_interface::LuaGetFriendsList
            SocialWindowBuddyListTabIgnore.playerListData[key] = {}
            SocialWindowBuddyListTabIgnore.playerListData[key].name = value.name
            SocialWindowBuddyListTabIgnore.playerListData[key].career = value.careerName
            if (value.careerName == L"") then
                SocialWindowBuddyListTabIgnore.playerListData[key].rankString = L""
            else
                SocialWindowBuddyListTabIgnore.playerListData[key].rankString = L""..value.rank
                -- if the person is offline the Rank is invalid, so don't display anything in the list
            end
            if (value.zoneID ~= 0) then
                SocialWindowBuddyListTabIgnore.playerListData[key].onlineString = GetZoneName(value.zoneID)
            else
                SocialWindowBuddyListTabIgnore.playerListData[key].onlineString = GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE)
            end
            if (value.guildName == nil) then
                SocialWindowBuddyListTabIgnore.playerListData[key].guildName = L""
            else
                SocialWindowBuddyListTabIgnore.playerListData[key].guildName = value.guildName
            end
        end
    end
end

local function FilterPlayerList()	
    playerListOrder = {}
    for dataIndex, data in ipairs(SocialWindowBuddyListTabIgnore.playerListData) do
        table.insert(playerListOrder, dataIndex)
    end
end

-- sort buddy list always by 1) Online/Offline, 2) Name
local function SortPlayerList()	
    table.sort( playerListOrder, ComparePlayers )
end

local function UpdatePlayerList()
    InitPlayerListData()
    ignoreDirty = false
    FilterPlayerList()
    SortPlayerList() 
    ListBoxSetDisplayOrder( "SocialWindowBuddyListTabIgnoreList", playerListOrder )
end

---------------------------------------
-- Buddy List (Friends) Functions
---------------------------------------
function SocialWindowBuddyListTabIgnore.Initialize()
    ListBoxSetDisplayOrder("SocialWindowBuddyListTabIgnoreList", playerListOrder)
    WindowRegisterEventHandler("SocialWindowBuddyListTabIgnoreList", SystemData.Events.SOCIAL_IGNORE_UPDATED, "SocialWindowBuddyListTabIgnore.OnIgnoreUpdated")
    SocialWindowBuddyListTabIgnore.OnIgnoreUpdated()
end

function SocialWindowBuddyListTabIgnore.OnIgnoreUpdated()
    ignoreDirty = true
    if WindowGetShowing("SocialWindowBuddyList") then
        UpdatePlayerList()
    end
end

function SocialWindowBuddyListTabIgnore.OnShown()
    if ignoreDirty then
        UpdatePlayerList()
    end
end

-- Handles the Left Button click on a player row (on the Buddy List)
function SocialWindowBuddyListTabIgnore.OnLButtonUpPlayerRow()
    -- let's just show the context menu.
    -- there's no point on the buddy list of only selecting a player as there's no remove button
    SocialWindowBuddyListTabIgnore.OnRButtonUpPlayerRow()
end

function SocialWindowBuddyListTabIgnore.OnMouseOverPlayerRow()
    -- Create a tooltip detailing the information from the columns that were in the old Social Window friends tab
    -- determine which player we are mousing over
	local rowNum = WindowGetId(SystemData.ActiveWindow.name)	
	local dataIndex = SocialWindowBuddyListTabIgnoreList.PopulatorIndices[rowNum]
    local IgnoreData = SocialWindowBuddyListTabIgnore.playerListData[dataIndex]
    if IgnoreData then
        Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name)
        --name
        local iRow = 1
        Tooltips.SetTooltipText(iRow, 1, IgnoreData.name)
        -- location / online status
        iRow = iRow + 1
        if (WStringsCompare(IgnoreData.onlineString, GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE) ) == 0) then
            Tooltips.SetTooltipColorDef(1, 1, DefaultColor.MEDIUM_LIGHT_GRAY)                
            Tooltips.SetTooltipText(iRow, 1,  IgnoreData.onlineString)
        else
            Tooltips.SetTooltipColorDef(1, 1, DefaultColor.GREEN)                
            Tooltips.SetTooltipText(iRow, 1,  GetStringFormatFromTable("SocialStrings", StringTables.Social.TOOLTIP_BUDDY_LIST_LOCATION, {IgnoreData.onlineString} ))
            -- class
            iRow = iRow + 1
            Tooltips.SetTooltipText( iRow, 1, GetStringFormatFromTable( "SocialStrings", StringTables.Social.TOOLTIP_BUDDY_LIST_CAREER, {IgnoreData.career} ) )
            -- rank
            iRow = iRow + 1
            Tooltips.SetTooltipText( iRow, 1, GetStringFormatFromTable( "SocialStrings", StringTables.Social.TOOLTIP_BUDDY_LIST_RANK, {IgnoreData.rankString} ) )
            -- guild
            iRow = iRow + 1
            if (IgnoreData.guildName == nil) then
                Tooltips.SetTooltipText( iRow, 1, GetString( StringTables.Default.LABEL_GUILD_NAME ))
            else
                Tooltips.SetTooltipText( iRow, 1, GetString( StringTables.Default.LABEL_GUILD_NAME )..L" "..IgnoreData.guildName )
            end           
        end       
        Tooltips.Finalize()        
        Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_VARIABLE)
    end    
end

function SocialWindowBuddyListTabIgnore.OnRButtonUpPlayerRow()
    -- Convert the Row index to the data index
	local rowNum = WindowGetId(SystemData.ActiveWindow.name)	
	local dataIndex = SocialWindowBuddyListTabIgnoreList.PopulatorIndices[ rowNum ]	
    SocialWindowTabIgnore.UpdateSelectedPlayerData(dataIndex)
    if(SocialWindowTabIgnore.SelectedIgnoreName ~= L"") then
        EA_Window_ContextMenu.CreateContextMenu(SystemData.MouseOverWindow.name, nil, SocialWindowTabIgnore.SelectedIgnoreName)
		EA_Window_ContextMenu.AddMenuDivider()
	    EA_Window_ContextMenu.AddMenuItem(GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_IGNORE_BUTTON_REMOVEIGNORE), SocialWindowTabIgnore.RemoveIgnore, false, true)   
		EA_Window_ContextMenu.Finalize()
    end
end

function SocialWindowBuddyListTabIgnore.UpdateSelectedPlayerData(dataIndex)
    -- Set the label values
    if (dataIndex ~= nil and dataIndex ~= 0) then
        SelectedPlayerDataIndex = dataIndex
        SelectedFriendsName = SocialWindowBuddyListTabIgnore.playerListData[dataIndex].name
    else
        SelectedPlayerDataIndex = 0
        SelectedFriendsName = L""
    end
    SocialWindowBuddyListTabIgnore.UpdateSelectedRow()
end

function SocialWindowBuddyListTabIgnore.UpdateSelectedRow()
    if (nil == SocialWindowBuddyListTabIgnoreList.PopulatorIndices) then
        return
    end    
    -- Setup the Custom formating for each row
    for rowIndex, dataIndex in ipairs(SocialWindowBuddyListTabIgnoreList.PopulatorIndices) do    
        local selected = SelectedPlayerDataIndex == dataIndex
        local rowName = "SocialWindowBuddyListTabIgnoreListRow"..rowIndex
        ButtonSetPressedFlag(rowName, selected)
        ButtonSetStayDownFlag(rowName, selected)
    end    
end

function SocialWindowBuddyListTabIgnore.UpdatePlayerRowIgnoreList()
    if (SocialWindowBuddyListTabIgnoreList.PopulatorIndices == nil) then
        return
    end
    for rowIndex, dataIndex in ipairs (SocialWindowBuddyListTabIgnoreList.PopulatorIndices) do
        local rowName = "SocialWindowBuddyListTabIgnoreListRow"..rowIndex
        -- Change colors based on if the guild member is selected/unselected, or offline            
        local labelColor = DefaultColor.GREEN           -- Default Online Memebers are gree     
        if (WStringsCompare(SocialWindowBuddyListTabIgnore.playerListData[dataIndex].onlineString, GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE) ) == 0) then
            labelColor = DefaultColor.MEDIUM_LIGHT_GRAY		-- Offline Members are grey
        end       
        LabelSetTextColor( rowName.."Name", labelColor.r, labelColor.g, labelColor.b) 
    end
    SocialWindowTabFriends.SetListRowTints(SocialWindowBuddyListTabIgnoreList, "SocialWindowBuddyListTabIgnoreListRow")
end
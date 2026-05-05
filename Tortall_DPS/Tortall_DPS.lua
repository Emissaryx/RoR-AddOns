TortallDPSMeter = TortallDPSMeter or {}
TortallDPSMeterSettings = TortallDPSMeterSettings or {}
TortallDPSMeter.Settings = TortallDPSMeterSettings

local isMeterShowing = false
local isDetailShowing = false

local DAMAGE_TAB  = 1
local HEALING_TAB = 2
local currentTab = DAMAGE_TAB

local DETAIL_ABILITIES = "Abilities"
local DETAIL_TARGET    = "Target"
local DETAIL_WhatHM    = "WhatHM"
local DETAIL_WhoHM     = "WhoHM"
local currentDetail = nil

local COLUMN_NAME, COLUMN_TOTAL, COLUMN_MIN, COLUMN_MAX, COLUMN_AVG, COLUMN_CRITPCT = 1, 2, 3, 4, 5, 6
local COLUMN_MITIGATED, COLUMN_PCT_TOT = 7, 8
local COLUMN_BLOCKED, COLUMN_DISRUPTED, COLUMN_DODGED, COLUMN_PARRIED = 9, 10, 11, 12
local COLUMN_NORMAL, COLUMN_CRIT = 13, 14

local Columns = {}

local GroupSortOrder = COLUMN_NAME
local GroupStats = {}
local ListGroupStats = {}

local currentStats

-- Used to position TortallDPSMeterGroupWindow based on whether other views are visible
local group_anchor = { Point = "bottomleft", RelativePoint = "topleft", XOffset = 0, YOffset = 0 }

local labelColor = {}
labelColor[false] = { r = 255, g = 255, b = 255 }
labelColor[true]  = { r = 255, g = 150, b = 5 }

local registered_chat = false
local registered_tac = false
local registered_ls = false
local registered_slash = false

local dps_title = "Tortall's DPS Meter"

-- OPTIMIZATION: Batch UI updates instead of per-event
local uiUpdateTimer = 0
local UI_UPDATE_INTERVAL = 0.075  -- Update UI every 75ms (13 times per second)
local needsUIUpdate = false
local needsSort = false

-- OPTIMIZATION: Cache formatted strings to reduce allocations
local cachedStrings = {
    lastAmount = "",
    lastCount = "",
    lastAverage = "",
    lastMin = "",
    lastMax = "",
    lastDPS = "",
    lastCountPS = "",
    lastCombatTime = ""
}

-- OPTIMIZATION: Dirty flags to track what needs updating
local dirtyFlags = {
    summary = false,
    detail = false,
    sort = false
}

-- OPTIMIZATION: Pre-calculated derived values cache
local derivedCache = {}

local function loadModule( modName )
    local mods = ModulesGetData()
    local v
    
    for _, v in ipairs( mods ) do
        if ( v.name == modName ) and ( v.isEnabled ) then
            d("Initializing "..v.name)
            if ( not v.isLoaded ) then ModuleInitialize(v.name) end
            return true
        end
    end
    
    return false
end

local function divide( numa, numb )
    if ( numb ~= nil ) and ( numb ~= 0.0 ) then 
        return numa / numb 
    end
    return numa
end

local function combatTotal()
    if ( currentTab == DAMAGE_TAB ) then
        if ( currentDetail == DETAIL_ABILITIES ) or ( currentDetail == DETAIL_TARGET ) then
            return TortallDPSCore.Stats[currentStats].Damage.Dealt.Total.Amount
        else
            return TortallDPSCore.Stats[currentStats].Damage.Taken.Total.Amount
        end
    else
        if ( currentDetail == DETAIL_ABILITIES ) or ( currentDetail == DETAIL_TARGET ) then
            return TortallDPSCore.Stats[currentStats].Healing.Dealt.Total.Amount
        else
            return TortallDPSCore.Stats[currentStats].Healing.Taken.Total.Amount
        end
    end
end

-- OPTIMIZATION: Pre-calculate derived values and cache them
local function updateDerivedValues(data)
    if not derivedCache[data] then
        derivedCache[data] = {}
    end
    
    local cache = derivedCache[data]
    cache.Average = divide(data.Amount, data.Count)
    cache.CritPct = divide(data.Crit.Count, data.Count)
    cache.PctTotal = divide(data.Amount, combatTotal())
end

function TortallDPSMeter.ChatCallback( msg, author )
    local dps, min, max, avg = msg:match(L"^([0-9.]+)^-([0-9.]+)^-([0-9.]+)^-([0-9.]+)")

    if ( GroupStats[author] == nil ) then
        GroupStats[author] = { name = author }
        
        table.insert(ListGroupStats, GroupStats[author])

        local GroupStatsOrder = {}
        for rowIndex = 1, table.getn(ListGroupStats) do
            table.insert(GroupStatsOrder, rowIndex)
        end

        ListBoxSetDisplayOrder( "TortallDPSMeterGroupWindowList", GroupStatsOrder )
    end
    
    GroupStats[author].dps = dps
    GroupStats[author].Min = min
    GroupStats[author].Max = max
    GroupStats[author].Average = avg
    
    TortallDPSMeter.PopulateGroupStats()
end

function TortallDPSMeter.LibSyncCallback( author, msg )
    if ( towstring(author) ~= (GameData.Player.name):match(L"([^^]+)^?.*") ) then
        TortallDPSMeter.ChatCallback(msg, towstring(author))
    end
end

-- =========================================================
-- Detail window resize sync (WAR-safe, structural)
-- =========================================================
local function SyncDetailLayout()
    if not (DoesWindowExist("TortallDPSMeter")
        and DoesWindowExist("TortallDPSMeterDetailWindow")
        and DoesWindowExist("TortallDPSMeterDetailWindowList")) then return end

    local w = WindowGetDimensions("TortallDPSMeter")
    local _, h = WindowGetDimensions("TortallDPSMeterDetailWindow")

    WindowSetDimensions("TortallDPSMeterDetailWindow", w, h)
    WindowSetDimensions("TortallDPSMeterDetailWindowList", w - 12, 228)
end

function TortallDPSMeter.Initialize()
    ----------------------------------------------------------------
    -- Layout + basic setup
    ----------------------------------------------------------------
    LayoutEditor.RegisterWindow(
        "TortallDPSToggle",
        L"Toggle for TDPS",
        L"Toggle for TDPS",
        true, false, true, nil
    )

    LabelSetText("TortallDPSToggleLabel", L"DPS")

    -- Base registration uses the Global stats table
    currentStats = "Global"

    CreateWindowFromTemplate(
        "TortallDPSMeterDetailWindow",
        "TortallDPSMeterDetailWindow",
        "Root"
    )

    ----------------------------------------------------------------
    -- Settings defaults (DO NOT overwrite existing data)
    ----------------------------------------------------------------
    local settings = TortallDPSMeter.Settings

    if type(settings.nochat) ~= "boolean" then
        settings.nochat = false
    end

    if type(settings.opacity) ~= "number" then
        settings.opacity = 0.2
    end

    -- Initialize lists/columns AFTER settings exist
    TortallDPSMeter.InitializeLists()
    TortallDPSMeter.InitializeColumns()

    ----------------------------------------------------------------
    -- Event handlers
    ----------------------------------------------------------------
    RegisterEventHandler(
        SystemData.Events.GROUP_UPDATED,
        "TortallDPSMeter.OnGroupUpdated"
    )

    RegisterEventHandler(
        SystemData.Events.UPDATE_PROCESSED,
        "TortallDPSMeter.OnUpdate"
    )

    ----------------------------------------------------------------
    -- Window visibility
    ----------------------------------------------------------------
    WindowSetShowing("TortallDPSMeterDetailWindow", false)
    WindowSetShowing("TortallDPSMeterGroupWindow", false)

    ----------------------------------------------------------------
    -- Apply saved opacity (THIS is what was failing before)
    ----------------------------------------------------------------
    local alpha = settings.opacity

    for _, win in ipairs({
        "TortallDPSMeter",
        "TortallDPSMeterDetailWindow",
        "TortallDPSMeterGroupWindow"
    }) do
        if DoesWindowExist(win) then
            WindowSetAlpha(win, alpha)
        end
    end

    ----------------------------------------------------------------
    -- Labels
    ----------------------------------------------------------------
    LabelSetText("TortallDPSMeterDamageLabel",   L"Damage")
    LabelSetText("TortallDPSMeterHealingLabel",  L"Healing")
    LabelSetText("TortallDPSMeterTitleLabel",    towstring(dps_title.." - Overall"))

    LabelSetText("TortallDPSMeterTotalLabel",    L"Total")
    LabelSetText("TortallDPSMeterNormalLabel",   L"Normal")
    LabelSetText("TortallDPSMeterCritLabel",     L"Crit")
    LabelSetText("TortallDPSMeterPSLabel",       L"Per Second")
    LabelSetText("TortallDPSMeterAmountLabel",   L"Amount")
    LabelSetText("TortallDPSMeterCountLabel",    L"Count")
    LabelSetText("TortallDPSMeterAverageLabel",  L"Average")
    LabelSetText("TortallDPSMeterMinLabel",      L"Minimum")
    LabelSetText("TortallDPSMeterMaxLabel",      L"Maximum")

    LabelSetText("TortallDPSMeterResetLabel",    L"Reset")
    LabelSetText("TortallDPSMeterAbilitiesLabel",L"Abilities")
    LabelSetText("TortallDPSMeterTargetsLabel",  L"Targets")
    LabelSetText("TortallDPSMeterGroupLabel",    L"Group")

    LabelSetText("TortallDPSMeterGroupWindowName",    L"Player")
    LabelSetText("TortallDPSMeterGroupWindowDPS",     L"DPS")
    LabelSetText("TortallDPSMeterGroupWindowMin",     L"Min")
    LabelSetText("TortallDPSMeterGroupWindowMax",     L"Max")
    LabelSetText("TortallDPSMeterGroupWindowAverage", L"Avg")

    ----------------------------------------------------------------
    -- Detail system
    ----------------------------------------------------------------
    TortallDPSDetail.Initialize()

    ----------------------------------------------------------------
    -- Group window anchor
    ----------------------------------------------------------------
    WindowClearAnchors("TortallDPSMeterGroupWindow")
    WindowAddAnchor(
        "TortallDPSMeterGroupWindow",
        group_anchor.Point,
        "TortallDPSMeter",
        group_anchor.RelativePoint,
        group_anchor.XOffset,
        group_anchor.YOffset
    )

    isMeterShowing = WindowGetShowing("TortallDPSMeter")
    isGroupShowing = false

    ----------------------------------------------------------------
    -- Default tab
    ----------------------------------------------------------------
    TortallDPSMeter.DamageTab()

    ----------------------------------------------------------------
    -- Core registration
    ----------------------------------------------------------------
    TortallDPSCore.Register(
        "Tortall_DPS",
        TortallDPSMeter.DamageUpdate,
        TortallDPSMeter.NewEntry
    )

    TortallDPSCore.Register(
        "Tortall_DPS",
        TortallDPSMeter.DamageUpdate,
        TortallDPSMeter.NewEntry,
        nil,
        "TDPS_User1"
    )

    TortallDPSCore.Register(
        "TDPS_User2",
        TortallDPSMeter.DamageUpdate,
        TortallDPSMeter.NewEntry,
        nil,
        "TDPS_User2"
    )

    ----------------------------------------------------------------
    -- Addon integration
    ----------------------------------------------------------------
    TortallDPSMeter.RegisterWithAddons()

    TextLogAddEntry("Chat", 0, L"Tortall's DPS Meter Initialized.")
end

function TortallDPSMeter.SlashHandler( args )
    if ( args == "reset" )  then TortallDPSMeter.Reset()                 end
    if ( args == "toggle" ) then TortallDPSMeter.Toggle()                end
    if ( args == "nochat" ) then TortallDPSMeter.Settings.nochat = true  end
    if ( args == "chat" )   then TortallDPSMeter.Settings.nochat = false end
end

function TortallDPSMeter.OnOpacityChanged()
    local alpha = WindowGetAlpha("TortallDPSMeter")
    TortallDPSMeter.Settings.opacity = alpha
end

function TortallDPSMeter.InitializeLists()
    local k
    
    TortallDPSMeter.Lists = { Global = {}, TDPS_User1 = {}, TDPS_User2 = {} }
    
    for k in pairs(TortallDPSMeter.Lists) do
        TortallDPSMeter.Lists[k][TortallDPSCore.DAMAGE_DEALT] = {}
        TortallDPSMeter.Lists[k][TortallDPSCore.DAMAGE_DEALT][TortallDPSCore.ABILITY] = { list = {}, sortOrder = COLUMN_NAME, sortDir = SORT_ASC }
        TortallDPSMeter.Lists[k][TortallDPSCore.DAMAGE_DEALT][TortallDPSCore.TARGET]  = { list = {}, sortOrder = COLUMN_NAME, sortDir = SORT_ASC }
        TortallDPSMeter.Lists[k][TortallDPSCore.DAMAGE_TAKEN] = {}
        TortallDPSMeter.Lists[k][TortallDPSCore.DAMAGE_TAKEN][TortallDPSCore.ABILITY] = { list = {}, sortOrder = COLUMN_NAME, sortDir = SORT_ASC }
        TortallDPSMeter.Lists[k][TortallDPSCore.DAMAGE_TAKEN][TortallDPSCore.TARGET]  = { list = {}, sortOrder = COLUMN_NAME, sortDir = SORT_ASC }
        TortallDPSMeter.Lists[k][TortallDPSCore.HEAL_DEALT]  = {}
        TortallDPSMeter.Lists[k][TortallDPSCore.HEAL_DEALT][TortallDPSCore.ABILITY]   = { list = {}, sortOrder = COLUMN_NAME, sortDir = SORT_ASC }
        TortallDPSMeter.Lists[k][TortallDPSCore.HEAL_DEALT][TortallDPSCore.TARGET]    = { list = {}, sortOrder = COLUMN_NAME, sortDir = SORT_ASC }
        TortallDPSMeter.Lists[k][TortallDPSCore.HEAL_TAKEN] = {}
        TortallDPSMeter.Lists[k][TortallDPSCore.HEAL_TAKEN][TortallDPSCore.ABILITY]   = { list = {}, sortOrder = COLUMN_NAME, sortDir = SORT_ASC }
        TortallDPSMeter.Lists[k][TortallDPSCore.HEAL_TAKEN][TortallDPSCore.TARGET]    = { list = {}, sortOrder = COLUMN_NAME, sortDir = SORT_ASC }
    end

    TortallDPSMeter.InitializeTabs()
end

function TortallDPSMeter.InitializeTabs()
    TortallDPSMeter.Tabs = {}
    TortallDPSMeter.Tabs[DAMAGE_TAB] = { Abilities = TortallDPSMeter.Lists[currentStats][TortallDPSCore.DAMAGE_DEALT][TortallDPSCore.ABILITY],
                                         Target    = TortallDPSMeter.Lists[currentStats][TortallDPSCore.DAMAGE_DEALT][TortallDPSCore.TARGET],
                                         WhatHM    = TortallDPSMeter.Lists[currentStats][TortallDPSCore.DAMAGE_TAKEN][TortallDPSCore.ABILITY],
                                         WhoHM     = TortallDPSMeter.Lists[currentStats][TortallDPSCore.DAMAGE_TAKEN][TortallDPSCore.TARGET] }

    TortallDPSMeter.Tabs[HEALING_TAB] = { Abilities = TortallDPSMeter.Lists[currentStats][TortallDPSCore.HEAL_DEALT][TortallDPSCore.ABILITY],
                                          Target    = TortallDPSMeter.Lists[currentStats][TortallDPSCore.HEAL_DEALT][TortallDPSCore.TARGET],
                                          WhatHM    = TortallDPSMeter.Lists[currentStats][TortallDPSCore.HEAL_TAKEN][TortallDPSCore.ABILITY],
                                          WhoHM     = TortallDPSMeter.Lists[currentStats][TortallDPSCore.HEAL_TAKEN][TortallDPSCore.TARGET] }
end

function TortallDPSMeter.InitializeColumns()
    local saved = TortallDPSMeter.Settings.SavedColumns

    if type(saved) == "table"
       and saved[DAMAGE_TAB]
       and saved[HEALING_TAB]
    then
        Columns = saved
        return
    end

    -- fallback defaults
    Columns[DAMAGE_TAB] = {
        Abilities = { 1,2,3,4,5,6 },
        Target    = { 1,2,3,4,5,6 },
        WhatHM    = { 1,2,3,4,5,6 },
        WhoHM     = { 1,2,3,4,5,6 },
    }

    Columns[HEALING_TAB] = {
        Abilities = { 1,2,3,4,5,6 },
        Target    = { 1,2,3,4,5,6 },
        WhatHM    = { 1,2,3,4,5,6 },
        WhoHM     = { 1,2,3,4,5,6 },
    }

    TortallDPSMeter.Settings.SavedColumns = Columns
end

function TortallDPSMeter.Reset()
    TortallDPSCore.Reset(currentStats)

    local i, j
    for i = TortallDPSCore.DAMAGE_DEALT, TortallDPSCore.HEAL_TAKEN do
        for j = TortallDPSCore.ABILITY, TortallDPSCore.TARGET do
            TortallDPSMeter.Lists[currentStats][i][j].list = {}
        end
    end
    
    -- Clear derived cache
    derivedCache = {}
    
    -- Clear cached strings
    for k in pairs(cachedStrings) do
        cachedStrings[k] = ""
    end
    
    TortallDPSDetail.SetList(TortallDPSMeter.Tabs[currentTab][currentDetail])
    
    TextLogAddEntry("Chat", 0, L"Tortall's DPS Meter reset for "..towstring(currentStats))
end

function TortallDPSMeter.NewEntry( damageType, entry, entryType, notify )
    table.insert(TortallDPSMeter.Lists[notify][damageType][entryType].list, entry)
    
    -- OPTIMIZATION: Set dirty flags instead of immediate sort
    needsSort = true
    dirtyFlags.detail = true
    dirtyFlags.sort = true
end

local message     = L""
local lastMessage = L""

local WAIT = 1.0
local TIME = 0.0
local messageSendTimer = 0.0

-- OPTIMIZATION: Batched UI update handler
function TortallDPSMeter.OnUpdate( elapsed )
    -- Handle group message sending (only when not in combat)
    if ( not GameData.Player.inCombat ) then
        if ( message ~= lastMessage ) then
            messageSendTimer = messageSendTimer + elapsed
            if ( messageSendTimer >= WAIT ) then
                messageSendTimer = 0.0
                if ( registered_tac ) then TortallAddonChat.SendGroup( "Tortall_DPS", message ) end
                if ( registered_ls ) then LibSync.Out("Tortall_DPS", message) end
                lastMessage = message
            end
        end
    end
    
    -- OPTIMIZATION: Batched UI updates
    if needsUIUpdate then
        uiUpdateTimer = uiUpdateTimer + elapsed
        if uiUpdateTimer >= UI_UPDATE_INTERVAL then
            uiUpdateTimer = 0
            
            -- Perform actual UI updates
            if dirtyFlags.summary then
                TortallDPSMeter.RefreshSummary()
                dirtyFlags.summary = false
            end
            
            if dirtyFlags.sort and needsSort then
                TortallDPSDetail.Sort()
                needsSort = false
                dirtyFlags.sort = false
            end
            
            if dirtyFlags.detail then
                TortallDPSDetail.Populate()
                dirtyFlags.detail = false
            end
            
            needsUIUpdate = false
        end
    end
end

-- OPTIMIZATION: Separate summary refresh from full update
function TortallDPSMeter.RefreshSummary()
    local ltable, amount, min, max, count
    
    if not TortallDPSCore.Stats[currentStats] then return end
    
    local stats = TortallDPSCore.Stats[currentStats]
    local combatTime = stats.CombatTime
    
    if ( currentTab == HEALING_TAB ) then 
        ltable = stats.Healing 
    else 
        ltable = stats.Damage 
    end

    amount = ltable.Dealt.Total.Amount
    min    = ltable.Dealt.Total.Min or 0
    max    = ltable.Dealt.Total.Max
    count  = ltable.Dealt.Total.Count

    -- OPTIMIZATION: Only update labels if values actually changed
    local newAmount = towstring(amount)
    if cachedStrings.lastAmount ~= newAmount then
        LabelSetText( "TortallDPSMeterAmount", newAmount )
        cachedStrings.lastAmount = newAmount
    end
    
    local newCount = towstring(count)
    if cachedStrings.lastCount ~= newCount then
        LabelSetText( "TortallDPSMeterCount", newCount )
        cachedStrings.lastCount = newCount
    end
    
    local newAverage = towstring(string.format("%.2f", divide(amount, count)))
    if cachedStrings.lastAverage ~= newAverage then
        LabelSetText( "TortallDPSMeterAverage", newAverage )
        cachedStrings.lastAverage = newAverage
    end
    
    local newMin = towstring(min)
    if cachedStrings.lastMin ~= newMin then
        LabelSetText( "TortallDPSMeterMin", newMin )
        cachedStrings.lastMin = newMin
    end
    
    local newMax = towstring(max)
    if cachedStrings.lastMax ~= newMax then
        LabelSetText( "TortallDPSMeterMax", newMax )
        cachedStrings.lastMax = newMax
    end

    -- Update DPS calculations
    local newDPS = towstring(string.format("%.2f", divide(amount, combatTime)))
    if cachedStrings.lastDPS ~= newDPS then
        LabelSetText( "TortallDPSMeterDamagePS", newDPS )
        cachedStrings.lastDPS = newDPS
    end
    
    local newCountPS = towstring(string.format("%.2f", divide(count, combatTime)))
    if cachedStrings.lastCountPS ~= newCountPS then
        LabelSetText( "TortallDPSMeterCountPS", newCountPS )
        cachedStrings.lastCountPS = newCountPS
    end

    -- Prepare message for group sharing
    if ( TortallDPSMeter.Settings.nochat == false ) and ( registered_chat ) then
        local dmgMin = stats.Damage.Dealt.Total.Min or 0
        message = towstring(string.format("%.2f", divide(stats.Damage.Dealt.Total.Amount, combatTime))) .. L"^" ..
                  towstring(dmgMin) .. L"^" ..
                  towstring(stats.Damage.Dealt.Total.Max) .. L"^" ..
                  towstring(string.format("%.2f", divide(stats.Damage.Dealt.Total.Amount, stats.Damage.Dealt.Total.Count)))
    end

    -- Update normal/crit stats
    local v
    for _, v in pairs({ "Normal", "Crit" }) do
        amount = ltable.Dealt[v].Amount
        min    = ltable.Dealt[v].Min or 0
        max    = ltable.Dealt[v].Max
        count  = ltable.Dealt[v].Count

        LabelSetText( "TortallDPSMeter"..v.."Damage", towstring(amount) )
        LabelSetText( "TortallDPSMeter"..v.."Count", towstring(count) )
        LabelSetText( "TortallDPSMeter"..v.."Average", towstring(string.format("%.2f", divide(amount, count))) )
        LabelSetText( "TortallDPSMeter"..v.."Min", towstring(min) )
        LabelSetText( "TortallDPSMeter"..v.."Max", towstring(max) )
    end
    
    local newCombatTime = towstring(combatTime)
    if cachedStrings.lastCombatTime ~= newCombatTime then
        LabelSetText( "TortallDPSMeterCombatTime", newCombatTime )
        cachedStrings.lastCombatTime = newCombatTime
    end
end

-- OPTIMIZATION: DamageUpdate now just sets flags instead of updating UI directly
function TortallDPSMeter.DamageUpdate( damage, healing, combatTime, channel )
    -- Ignore notifications for any stats list we aren't showing at the moment.
    if ( channel ~= nil ) and ( currentStats ~= channel ) then return end

    -- Set dirty flags to trigger batched UI update
    dirtyFlags.summary = true
    dirtyFlags.detail = true
    needsUIUpdate = true
end

function TortallDPSMeter.OnGroupUpdated()
    for k in pairs(GroupStats) do
        local found = false
        for index = 1, GroupWindow.MAX_GROUP_MEMBERS do
            if (GroupWindow.IsMemberValid(index) == true) then
                found = (GroupWindow.groupData[index].name):match(L"([^^]+)^?.*") == k
                
                if found then break end
            end
        end
        if not found then GroupStats[k] = nil end
    end

    ListGroupStats = {}
    for k in pairs(GroupStats) do
        table.insert(ListGroupStats, GroupStats[k])
    end

    local GroupStatsOrder = {}
    for rowIndex = 1, table.getn(ListGroupStats) do
        table.insert(GroupStatsOrder, rowIndex)
    end

    ListBoxSetDisplayOrder( "TortallDPSMeterGroupWindowList", GroupStatsOrder )
end

function TortallDPSMeter.PopulateGroupStats()
    if ( TortallDPSMeterGroupWindowList.PopulatorIndices == nil ) then return end

    for row, data in ipairs(TortallDPSMeterGroupWindowList.PopulatorIndices) do
        local rowFrame   = "TortallDPSMeterGroupWindowListRow"..row
        local playerData = ListGroupStats[data]
        
        LabelSetText(rowFrame.."Name", playerData.name)
        LabelSetText(rowFrame.."DPS", playerData.dps)
        LabelSetText(rowFrame.."Min", playerData.Min)
        LabelSetText(rowFrame.."Max", playerData.Max)
        LabelSetText(rowFrame.."Average", playerData.Average)
    end
end

local function SetGroupAnchor()
    local Point, RelativeTo, RelativePoint, XOffset, YOffset
    Point         = group_anchor.Point
    RelativePoint = group_anchor.RelativePoint
    XOffset       = group_anchor.XOffset
    YOffset       = group_anchor.YOffset

    RelativeTo = "TortallDPSMeter"
    
    if ( isDetailShowing ) then RelativeTo = "TortallDPSMeterDetailWindow" end

    WindowClearAnchors("TortallDPSMeterGroupWindow")
    WindowAddAnchor("TortallDPSMeterGroupWindow", Point, RelativeTo, RelativePoint, XOffset, YOffset)
end

local detailLabels = { [DETAIL_ABILITIES] = "TortallDPSMeterAbilitiesLabel",
                       [DETAIL_TARGET]    = "TortallDPSMeterTargetsLabel",
                       [DETAIL_WhatHM]    = "TortallDPSMeterWhatHMLabel",
                       [DETAIL_WhoHM]     = "TortallDPSMeterWhoHMLabel" }
                       
local detailButtons = { TortallDPSMeterAbilities = DETAIL_ABILITIES, TortallDPSMeterTargets = DETAIL_TARGET,
                        TortallDPSMeterWhatHM = DETAIL_WhatHM, TortallDPSMeterWhoHM = DETAIL_WhoHM }

function TortallDPSMeter.ToggleDetail()
    local l, newDetail
    
    for _, l in pairs(detailLabels) do
        LabelSetTextColor(l, labelColor[false].r, labelColor[false].g, labelColor[false].b)
    end

    newDetail = detailButtons[SystemData.ActiveWindow.name]
    
    isDetailShowing = ( newDetail ~= currentDetail )
    WindowSetShowing("TortallDPSMeterDetailWindow", isDetailShowing)

    if ( isDetailShowing == false ) then
        currentDetail = nil
    else
        local alpha = WindowGetAlpha("TortallDPSMeterDetailWindow")
        
        WindowSetAlpha( "TortallDPSMeterDetailWindow", 1.0 )
        WindowSetAlpha( "TortallDPSMeterDetailWindow", alpha )
            
        LabelSetTextColor(detailLabels[newDetail], labelColor[true].r, labelColor[true].g, labelColor[true].b)

        currentDetail = newDetail

        TortallDPSDetail.SetColumns(Columns[currentTab][currentDetail])
		
		SyncDetailLayout() -- added here Emissary
		
        TortallDPSDetail.SetList(TortallDPSMeter.Tabs[currentTab][currentDetail])
    end
    
    SetGroupAnchor()
end

function TortallDPSMeter.ToggleGroup()
    isGroupShowing = not isGroupShowing

    WindowSetShowing("TortallDPSMeterGroupWindow", isGroupShowing)
    local labelColor = labelColor[isGroupShowing]
    LabelSetTextColor("TortallDPSMeterGroupLabel", labelColor.r, labelColor.g, labelColor.b)
    
    if ( isGroupShowing ) then
        local alpha = WindowGetAlpha("TortallDPSMeterGroupWindow")
        
        WindowSetAlpha( "TortallDPSMeterGroupWindow", 1.0 )
        WindowSetAlpha( "TortallDPSMeterGroupWindow", alpha )
    end
end

function TortallDPSMeter.Toggle()
    isMeterShowing = not isMeterShowing

    WindowSetShowing("TortallDPSMeter", isMeterShowing)

    -- When hiding the Meter, hide the other windows.
    -- When showing the Meter, show the other windows if they had been showing.
    if ( isDetailShowing ) then
        WindowSetShowing("TortallDPSMeterDetailWindow", isMeterShowing)
    end
    if ( isGroupShowing ) then
        WindowSetShowing("TortallDPSMeterGroupWindow", isMeterShowing)
    end

    if ( isMeterShowing == true ) then
        local alpha = WindowGetAlpha("TortallDPSMeter")
        
        for _, w in pairs({ "TortallDPSMeter", "TortallDPSMeterDetailWindow", "TortallDPSMeterGroupWindow" }) do
            WindowSetAlpha( w, 1.0 )
            WindowSetAlpha( w, alpha )
        end
    end
end

local function switchTab( tab, f_label, t_label, color, WhatHM, WhoHM )
    LabelSetTextColor(f_label, labelColor[false].r, labelColor[false].g, labelColor[false].b)
    LabelSetTextColor(t_label, labelColor[true].r, labelColor[true].g, labelColor[true].b)
    
    WindowSetTintColor("TortallDPSMeterSummaryBG", color.r, color.g, color.b)

    LabelSetText( "TortallDPSMeterWhatHMLabel", WhatHM )
    LabelSetText( "TortallDPSMeterWhoHMLabel", WhoHM )
    
    currentTab = tab

    if ( currentDetail ~= nil ) then
        TortallDPSDetail.SetColumns(Columns[currentTab][currentDetail])
        TortallDPSDetail.SetList(TortallDPSMeter.Tabs[currentTab][currentDetail])
    end

    -- Force immediate refresh when switching tabs
    dirtyFlags.summary = true
    dirtyFlags.detail = true
    needsUIUpdate = true
    TortallDPSMeter.RefreshSummary()
end

function TortallDPSMeter.DamageTab()
    switchTab(DAMAGE_TAB, "TortallDPSMeterHealingLabel", "TortallDPSMeterDamageLabel",
              { r = 250, g = 0, b = 0 },
              L"What Hit Me?", L"Who Hit Me?")
end

function TortallDPSMeter.HealingTab()
    switchTab(HEALING_TAB, "TortallDPSMeterDamageLabel", "TortallDPSMeterHealingLabel",
              { r = 0, g = 0, b = 250 },
              L"What Healed Me?", L"Who Healed Me?")
end

function TortallDPSMeter.RegisterWithAddons()
    if ( TortallDPSMeter.Settings.nochat == true ) then
        registered_chat = true
    end
    
    if ( registered_chat == false ) then
        if ( LibSync == nil ) then loadModule("LibSync") end
        if ( LibSync ~= nil ) then
            LibSync.Register("Tortall_DPS", LIBSYNC_LEVEL_GROUP, TortallDPSMeter.LibSyncCallback)
            registered_ls = true
            registered_chat = true
        end
        if ( TortallAddonChat == nil ) then loadModule("Tortall_Addon_Chat") end
        if ( TortallAddonChat ~= nil ) then
            TortallAddonChat.Register( { name = "Tortall_DPS", callback = TortallDPSMeter.ChatCallback } )
            registered_tac = true
            registered_chat = true
        end
    end

    if ( registered_slash == false ) then
        if ( LibSlash == nil ) then loadModule("LibSlash") end
        if ( LibSlash ~= nil ) then
            LibSlash.RegisterSlashCmd("tdps", TortallDPSMeter.SlashHandler)
            registered_slash = true
        end
    end
end

function TortallDPSMeter.OnRButtonUp()
    if ( SystemData.ActiveWindow.name == "TortallDPSMeterTitleLabel") then
       -- EA_Window_ContextMenu.CreateOpacityOnlyContextMenu( "TortallDPSMeter" )
	   EA_Window_ContextMenu.CreateOpacityOnlyContextMenu( "TortallDPSMeter", "TortallDPSMeter.OnOpacityChanged")
	   
        return
    end
    
    EA_Window_ContextMenu.CreateContextMenu( "TortallDPSMeter", EA_Window_ContextMenu.CONTEXT_MENU_1, L"Channels" )
    EA_Window_ContextMenu.AddMenuItem( L"Overall", TortallDPSMeter.OnMenuGlobal, false, true )
    EA_Window_ContextMenu.AddMenuItem( L"User 1", TortallDPSMeter.OnMenuUser1, false, true )
    EA_Window_ContextMenu.AddMenuItem( L"User 2", TortallDPSMeter.OnMenuUser2, false, true )
    
    EA_Window_ContextMenu.Finalize()
end

local function SwitchStats()
    TortallDPSMeter.InitializeTabs()

    TortallDPSDetail.SetList(TortallDPSMeter.Tabs[currentTab][currentDetail])

    -- Force immediate refresh
    dirtyFlags.summary = true
    dirtyFlags.detail = true
    needsUIUpdate = true
    TortallDPSMeter.RefreshSummary()
end

function TortallDPSMeter.OnMenuGlobal()
    currentStats = "Global"
    LabelSetText( "TortallDPSMeterTitleLabel", towstring(dps_title.." - Overall") )
    
    SwitchStats()
end

function TortallDPSMeter.OnMenuUser1()
    currentStats = "TDPS_User1"
    LabelSetText( "TortallDPSMeterTitleLabel", towstring(dps_title.." - User 1") )

    SwitchStats()
end

function TortallDPSMeter.OnMenuUser2()
    currentStats = "TDPS_User2"
    LabelSetText( "TortallDPSMeterTitleLabel", towstring(dps_title.." - User 2") )

    SwitchStats()
end

---------------------------------------------------------------------------

local SORT_ASC  = 1
local SORT_DESC = 2

local SortData = { sortOrder = COLUMN_NAME, list = nil, sortDir = SORT_ASC }

local ColumnHeadings = { L"Name", L"Total", L"Min", L"Max", L"Avg", L"Crit%", L"Mit", L"%Total",
                         L"Block", L"Disrupt", L"Dodge", L"Parry", L"Normal", L"Critical" }
local ColumnLabels = { "TortallDPSMeterDetailWindowBtn1Label",
                       "TortallDPSMeterDetailWindowBtn2Label",
                       "TortallDPSMeterDetailWindowBtn3Label",
                       "TortallDPSMeterDetailWindowBtn4Label",
                       "TortallDPSMeterDetailWindowBtn5Label",
                       "TortallDPSMeterDetailWindowBtn6Label" }
local ColumnLabelMap = { TortallDPSMeterDetailWindowBtn1 = 1,
                         TortallDPSMeterDetailWindowBtn2 = 2,
                         TortallDPSMeterDetailWindowBtn3 = 3,
                         TortallDPSMeterDetailWindowBtn4 = 4,
                         TortallDPSMeterDetailWindowBtn5 = 5,
                         TortallDPSMeterDetailWindowBtn6 = 6 }

TortallDPSDetail = {}

TortallDPSDetail.ColumnNames = { "COLUMN_NAME", "COLUMN_TOTAL", "COLUMN_MIN", "COLUMN_MAX", "COLUMN_AVG", "COLUMN_CRITPCT",
                                 "COLUMN_MITIGATED", "COLUMN_PCT_TOT",
                                 "COLUMN_BLOCKED", "COLUMN_DISRUPTED", "COLUMN_DODGED", "COLUMN_PARRIED",
                                 "COLUMN_NORMAL", "COLUMN_CRIT" }

TortallDPSDetail.ColumnIndexes = { COLUMN_NAME = 1, COLUMN_TOTAL = 2, COLUMN_MIN = 3, COLUMN_MAX = 4, COLUMN_AVG = 5, COLUMN_CRITPCT = 6,
                                   COLUMN_MITIGATED = 7, COLUMN_PCT_TOT = 8,
                                   COLUMN_BLOCKED = 9, COLUMN_DISRUPTED = 10, COLUMN_DODGED = 11, COLUMN_PARRIED = 12,
                                   COLUMN_NORMAL = 13, COLUMN_CRIT = 14 }

TortallDPSDetail.List    = nil
TortallDPSDetail.Columns = nil

-- OPTIMIZATION: Lookup table for field access instead of long if-chain
local fieldAccessors = {
    [COLUMN_TOTAL] = function(data) return data.Amount end,
    [COLUMN_MIN] = function(data) return data.Min end,
    [COLUMN_MAX] = function(data) return data.Max end,
    [COLUMN_AVG] = function(data) return divide(data.Amount, data.Count) end,
    [COLUMN_CRITPCT] = function(data) return divide(data.Crit.Count, data.Count) end,
    [COLUMN_MITIGATED] = function(data) return data.Mitigated end,
    [COLUMN_PCT_TOT] = function(data) return divide(data.Amount, combatTotal()) end,
    [COLUMN_BLOCKED] = function(data) return data.Block end,
    [COLUMN_DISRUPTED] = function(data) return data.Disrupt end,
    [COLUMN_DODGED] = function(data) return data.Dodge end,
    [COLUMN_PARRIED] = function(data) return data.Parry end,
    [COLUMN_NORMAL] = function(data) return data.Normal.Amount end,
    [COLUMN_CRIT] = function(data) return data.Crit.Amount end
}

local function CompareDetails( index1, index2 )
    if ( index2 == nil ) then return false end

    if ( SortData.sortDir == SORT_DESC ) then
        local tmp = index1
        index1 = index2
        index2 = tmp
    end
    
    local entity1 = SortData.list[index1]
    local entity2 = SortData.list[index2]
    
    local sortOrder = SortData.sortOrder
    
    if ( entity1 == nil ) or ( entity1.Name == nil ) or ( entity1.Name == L"" ) then return false end
    if ( entity2 == nil ) or ( entity2.Name == nil ) or ( entity2.Name == L"" ) then return true  end
    
    if ( sortOrder == COLUMN_NAME ) then
        return ( WStringsCompare(entity1.Name:lower(), entity2.Name:lower()) < 0 )
    end
   
    -- OPTIMIZATION: Use lookup table instead of long if-chain
    local accessor = fieldAccessors[sortOrder]
    if not accessor then return false end
    
    local v1 = accessor(entity1)
    local v2 = accessor(entity2)

    if ( v1 == v2 ) then
        return ( ( SortData.sortDir == SORT_ASC  ) and ( WStringsCompare(entity1.Name, entity2.Name) < 0 ) ) or
               ( ( SortData.sortDir == SORT_DESC ) and ( WStringsCompare(entity1.Name, entity2.Name) > 0 ) )
    else
        return ( v1 < v2 )
    end
end

local function sortList(lTable)
    if ( currentDetail == nil ) or
       ( ( TortallDPSMeter.Tabs[currentTab][currentDetail] ~= nil) and
         ( TortallDPSMeter.Tabs[currentTab][currentDetail] == lTable ) ) then
        local StatsOrder = {}

        for rowIndex = 1, table.getn(lTable.list) do
            table.insert(StatsOrder, rowIndex)
        end

        SortData.sortOrder = lTable.sortOrder
        SortData.list      = lTable.list
        SortData.sortDir   = lTable.sortDir

        table.sort(StatsOrder, CompareDetails)

        ListBoxSetDisplayOrder( "TortallDPSMeterDetailWindowList", StatsOrder )
    end
end

function TortallDPSDetail.Initialize()
    for i = 1, 6 do
        LabelSetText(ColumnLabels[i], ColumnHeadings[i])
    end
    
    for k, v in pairs(ColumnLabelMap) do
        WindowSetId(k, v)
    end
end

function TortallDPSDetail.SetColumns( columns )
    TortallDPSDetail.Columns = columns
    
    TortallDPSDetail.UpdateHeadings( columns )
end

function TortallDPSDetail.UpdateHeadings( columns )
    for i = 2, 6 do
        LabelSetText(ColumnLabels[i], ColumnHeadings[columns[i]])
    end
end

function TortallDPSDetail.SetList( list )
    TortallDPSDetail.List = list
    
    if ( list ~= nil ) then
        sortList(list)
        TortallDPSDetail.Populate()
    end
end

function TortallDPSDetail.Sort()
    if ( TortallDPSDetail.List ~= nil ) then sortList(TortallDPSDetail.List) end
end

-- OPTIMIZATION: Use lookup table for field display instead of long if-chain
local function Field( data, index )
    local columnType = TortallDPSDetail.Columns[index]
    
    if ( columnType == COLUMN_NAME ) then
        return data.Name
    end
    if ( columnType == COLUMN_TOTAL ) then
        return towstring(data.Amount)
    end
    if ( columnType == COLUMN_MIN ) then
        local min = data.Min or 0
        return towstring(min)
    end
    if ( columnType == COLUMN_MAX ) then
        return towstring(data.Max)
    end
    if ( columnType == COLUMN_AVG ) then
        return towstring(string.format("%.2f", divide(data.Amount, data.Count)))
    end
    if ( columnType == COLUMN_CRITPCT ) then
        return towstring(string.format("%3d", divide(data.Crit.Count, data.Count) * 100))..L"%"
    end
    if ( columnType == COLUMN_MITIGATED ) then
        return towstring(data.Mitigated)
    end
    if ( columnType == COLUMN_PCT_TOT ) then
        return towstring(string.format("%3d", divide(data.Amount, combatTotal()) * 100))..L"%"
    end
    if ( columnType == COLUMN_BLOCKED ) then
        return towstring(data.Block)
    end
    if ( columnType == COLUMN_DISRUPTED ) then
        return towstring(data.Disrupt)
    end
    if ( columnType == COLUMN_DODGED ) then
        return towstring(data.Dodge)
    end
    if ( columnType == COLUMN_PARRIED ) then
        return towstring(data.Parry)
    end
    if ( columnType == COLUMN_NORMAL ) then
        return towstring(data.Normal.Amount)
    end
    if ( columnType == COLUMN_CRIT ) then
        return towstring(data.Crit.Amount)
    end
    
    return L""
end

function TortallDPSDetail.Populate()
    if ( TortallDPSMeterDetailWindowList.PopulatorIndices == nil ) then return end
    if ( currentDetail == nil ) then return end
    
    for row, data in ipairs(TortallDPSMeterDetailWindowList.PopulatorIndices) do
        local rowFrame   = "TortallDPSMeterDetailWindowListRow"..row
        local listData = TortallDPSDetail.List.list[data]

        if ( listData == nil ) then break end

        for i = 1, 6 do
            LabelSetText(rowFrame..i, Field(listData, i))
        end
    end
end

function TortallDPSDetail.GenericSort()
    local newSortOrder = TortallDPSDetail.Columns[ColumnLabelMap[SystemData.ActiveWindow.name]]
    local list = TortallDPSDetail.List
    
    if ( list.sortOrder == newSortOrder ) then
        list.sortDir = ( list.sortDir == SORT_ASC ) and SORT_DESC or SORT_ASC
    else
        list.sortDir = SORT_ASC
    end

    list.sortOrder = newSortOrder

    sortList(list)
end

function TortallDPSDetail.ShowColumnMenu()
    local menuitems = { L"Name", L"Total", L"Minimum", L"Maximum", L"Average", L"Crit Percentage", L"Mitigated", L"Percent of Total", L"Block", L"Disrupt", L"Dodge", L"Parry", L"Normal", L"Critical" }
    
    local wName = SystemData.ActiveWindow.name

    EA_Window_ContextMenu.CreateContextMenu( wName, EA_Window_ContextMenu.CONTEXT_MENU_1, L"Columns" )
    
    -- Name isn't changeable, nor can any other column be changed to name.
    for i = 2, table.getn(menuitems) do
        EA_Window_ContextMenu.AddMenuItem( menuitems[i], function () TortallDPSDetail.ColumnChange(WindowGetId(wName), i) end, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1 )
    end
    
    EA_Window_ContextMenu.Finalize()
end

function TortallDPSDetail.ColumnChange( column, index )
    TortallDPSDetail.Columns[column] = index
    
    LabelSetText(ColumnLabels[column], ColumnHeadings[index])
    
    TortallDPSDetail.SetList(TortallDPSDetail.List)
end
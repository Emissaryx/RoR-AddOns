GetStats = {}
GetStats.Compare = {}
Getstats_CompareStats = {}
GetStats.GotSomethingToCompare = false
GetStats.LastCompareCount = 0
local version = "1.2"

-- track widest seen so Embissary never shrinks below previous
local PrevWidth = 0

-- treat only stat lines as data
local function isStatLine(t)
    if not t or wstring.len(t) == 0 then return false end
    if wstring.find(t, L"SOR_") then return false end
    if wstring.find(t, L"SCPlayers") then return false end
    if wstring.find(t, L"^Speed:%s*%d+") then return true end
    if wstring.find(t, L"^%a[%a%s]+%s%d+%s%(") then return true end
    if wstring.find(t, L"^%a[%a%s]+%s%d+$") then return true end
    return false
end

local function set_row_sizes(row, lab, text, idx, parentWinName, curLines, curMaxW)
    -- un-clamp widths so measurement is not limited by current sizes
    WindowSetDimensions(parentWinName, 2068, 28 + (math.max(1, curLines) * 22))
    WindowSetDimensions(row, 2048, 28)
    WindowSetDimensions(lab, 2048, 20)
    LabelSetWordWrap(lab, false)
    LabelSetText(lab, text)

    -- measure single-line width, then lock sizes exactly
    local w = LabelGetTextDimensions(lab) or 0
    WindowSetDimensions(lab, w, 20)
    WindowSetDimensions(row, w + 20, 28)
    WindowSetOffsetFromParent(row, 0, 6 + (idx * 22))

    if w > curMaxW then curMaxW = w end
    WindowSetDimensions(parentWinName, curMaxW + 20, 28 + (curLines * 22))
    return curMaxW, w
end

function GetStats.OnInitialize()
    CreateWindow("GetStatsWindow", false)
    CreateWindow("GetStatsCompareWindow", false)
    GetStats.Populating = false
    GetStats.LineNumber = 0
    GetStats.LineLength = 0
    GetStats.TempLineLength = 0

    RegisterEventHandler(TextLogGetUpdateEventId("Chat"), "GetStats.OnChatLogUpdated")
    TextLogAddEntry("Chat", 0, L"<icon00057> GetStats " .. towstring(version) .. L" Loaded.")
end

function GetStats.OnChatLogUpdated(updateType, filterType)
    if updateType ~= SystemData.TextLogUpdate.ADDED then return end

    local _, _, text = TextLogGetEntry("Chat", TextLogGetNumEntries("Chat") - 1)
    if not text then return end

    -- build Embissary as lines arrive
    if GetStats.Populating and isStatLine(text) then
        GetStats.LineNumber = GetStats.LineNumber + 1
        local i   = GetStats.LineNumber
        local row = "GetStatsLine" .. i
        local lab = row .. "Text"

        if not DoesWindowExist(row) then
            CreateWindowFromTemplate(row, "GetStatsLabelTemplate", "GetStatsWindow")
        end
        WindowSetParent(row, "GetStatsWindow")

        GetStats.LineLength = select(1, set_row_sizes(row, lab, text, i, "GetStatsWindow", GetStats.LineNumber, GetStats.LineLength))
        GetStats.Compare[i] = text
        PrevWidth = math.max(PrevWidth, GetStats.LineLength)
    end

    -- start of a new dump
    if text:find(L"Stats for") then
        -- move last dump into compare
        Getstats_CompareStats = GetStats.Compare
        if next(Getstats_CompareStats) ~= nil then
            WindowSetShowing("GetStatsCompareWindow", true)
            GetStats_CompareLineLength = 0

            for i = 1, #Getstats_CompareStats do
                local base = "GetStatsCompareLine" .. i
                local lab  = base .. "Text"
                if not DoesWindowExist(base) then
                    CreateWindowFromTemplate(base, "GetStatsLabelTemplate", "GetStatsCompareWindow")
                    WindowSetParent(base, "GetStatsCompareWindow")
                end
                GetStats_CompareLineLength = select(1,
                    set_row_sizes(base, lab, towstring(Getstats_CompareStats[i]), i,
                                  "GetStatsCompareWindow", i, GetStats_CompareLineLength))
            end

            -- remove any leftover rows from earlier compare
            for j = (#Getstats_CompareStats + 1), GetStats.LastCompareCount do
                local n = "GetStatsCompareLine" .. j
                if DoesWindowExist(n) then DestroyWindow(n) end
            end
            GetStats.LastCompareCount = #Getstats_CompareStats

            WindowSetDimensions("GetStatsCompareWindow",
                GetStats_CompareLineLength + 20,
                28 + (#Getstats_CompareStats * 22))
            LabelSetText("GetStatsCompareWindowTitle", L"Prev stats")

            PrevWidth = math.max(PrevWidth, GetStats_CompareLineLength)
        else
            WindowSetShowing("GetStatsCompareWindow", false)
        end

        -- reset main for new capture
        GetStats.Compare = {}
        LabelSetText("GetStatsWindowTitle", wstring.sub(text, 11, -3))
        for i = 1, GetStats.LineNumber do
            local row = "GetStatsLine" .. i
            if DoesWindowExist(row) then DestroyWindow(row) end
        end
        GetStats.LineNumber = 0
        GetStats.LineLength = 0
        GetStats.TempLineLength = 0
        WindowSetShowing("GetStatsWindow", true)
        GetStats.Populating = true
    end

    -- end marker of current dump
    if text:find(L"Current") then
        GetStats.Populating = false
        local w = math.max(GetStats.LineLength, PrevWidth)
        WindowSetDimensions("GetStatsWindow", w + 20, 28 + (GetStats.LineNumber * 22))
    end
end

function GetStats.CloseWindow()
    WindowSetShowing("GetStatsWindow", false)
    WindowSetShowing("GetStatsCompareWindow", false)
    Getstats_CompareStats = {}
    GetStats_TempCompareLineLength = 0
    GetStats_CompareLineLength = 0
end

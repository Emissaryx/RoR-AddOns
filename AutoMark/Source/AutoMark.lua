AutoMark = {}

local ENABLED = true
local MARKERS = {}
local TEST_WINDOW = "AutoMark_Tester"

------------------------------------------------------------
-- Marker creation / destruction
------------------------------------------------------------
local function CreateMarker(objectId, careerId)
    local windowName = "AutoMark_M" .. objectId
    CreateWindowFromTemplate(windowName, "T_AutoMark_Marker", "Root")
    WindowSetShowing(windowName, true)

    local iconId = Icons.GetCareerIconIDFromCareerLine(careerId)
    local tex, x, y = GetIconData(iconId)
    DynamicImageSetTexture(windowName .. "_Icon", tex, x, y)

    return { objectId = objectId, windowName = windowName }
end

local function DestroyMarker(marker)
    DestroyWindow(marker.windowName)
end

------------------------------------------------------------
-- World object existence probe
------------------------------------------------------------
local function WorldObjectExists(objectId)
    WindowSetShowing(TEST_WINDOW, true)

    local cx = SystemData.screenResolution.x / 2
    local cy = SystemData.screenResolution.y / 2

    WindowClearAnchors(TEST_WINDOW)
    WindowAddAnchor(TEST_WINDOW, "topleft", "Root", "topleft", cx, cy)
    local r1x, r1y = WindowGetScreenPosition(TEST_WINDOW)

    MoveWindowToWorldObject(TEST_WINDOW, objectId, 1.0)

    if not WindowGetShowing(TEST_WINDOW) then
        WindowSetShowing(TEST_WINDOW, true)
        return true
    end

    local ox, oy = WindowGetScreenPosition(TEST_WINDOW)
    if ox ~= r1x or oy ~= r1y then return true end

    WindowClearAnchors(TEST_WINDOW)
    WindowAddAnchor(TEST_WINDOW, "topleft", "Root", "topleft", cx + 10, cy + 10)
    local r2x, r2y = WindowGetScreenPosition(TEST_WINDOW)

    MoveWindowToWorldObject(TEST_WINDOW, objectId, 1.0)
    ox, oy = WindowGetScreenPosition(TEST_WINDOW)

    return (ox ~= r2x or oy ~= r2y)
end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------
function AutoMark.OnInitialize()
    if ENABLED then RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "AutoMark.OnPlayerTargetUpdated") end
    LibSlash.RegisterSlashCmd("automark", AutoMark.OnSlashCommand)
    if not DoesWindowExist(TEST_WINDOW) then CreateWindow(TEST_WINDOW, true) end
end

------------------------------------------------------------
-- Target tracking
------------------------------------------------------------
function AutoMark.OnPlayerTargetUpdated(targetType, objectId, objectType)
    if targetType == "selffriendlytarget" or objectType ~= SystemData.TargetObjectType.ENEMY_PLAYER then return end

    for i = 1, #MARKERS do
        if MARKERS[i].objectId == objectId then return end
    end

    TargetInfo:UpdateFromClient()
    MARKERS[#MARKERS + 1] = CreateMarker(objectId, TargetInfo:UnitCareer(targetType))
end

------------------------------------------------------------
-- Slash commands
------------------------------------------------------------
function AutoMark.OnSlashCommand(text)

    if text == "clear" then
        for i = 1, #MARKERS do DestroyMarker(MARKERS[i]) end
        MARKERS = {}

    elseif text == "off" then
        if ENABLED then
            ENABLED = false
            UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "AutoMark.OnPlayerTargetUpdated")
        end
        TextLogAddEntry("Chat", 0, L"AutoMark stopped tracking new enemies.")

    elseif text == "on" then
        if not ENABLED then
            ENABLED = true
            RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "AutoMark.OnPlayerTargetUpdated")
        end
        TextLogAddEntry("Chat", 0, L"AutoMark is now tracking new enemy players.")

    else
        TextLogAddEntry("Chat", 0, L"Valid options: \"clear\", \"on\", \"off\".")
    end
end

------------------------------------------------------------
-- Update loop
------------------------------------------------------------
function AutoMark.OnUpdate(deltaTime)
    for i = #MARKERS, 1, -1 do
        local m = MARKERS[i]
        if not WorldObjectExists(m.objectId) then
            DestroyMarker(m)
            MARKERS[i] = MARKERS[#MARKERS]
            table.remove(MARKERS)
        else
            MoveWindowToWorldObject(m.windowName, m.objectId, 1.0)
            WindowSetAlpha(m.windowName, 1.0)
        end
    end
end

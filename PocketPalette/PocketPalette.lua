if (not PP)
then
    PP = {}
end

-- Keep this in sync with PocketPalette.mod:
-- UiMod@version and VersionSettings@savedVariablesVersion.
PP.version = "2.1.2"

PP.settings =
{
    persistent = false,
    ordering =
    {
        L"Default",
        L"Name",
        L"Count"
    },
    type =
    {
        L"Diffuse (\"flat\") only",     -- Type 1
        L"Specular (\"shiny\") only",   -- Type 2
        L"Diffuse and Specular"
    },
    filter = "",
    windows =
    {
        ["main"] =
        {
            name = "PPMain",
            width = 0,
            height = 0,
            x = 0,
            y = 0,
            minimized = false,
            anchor = {}
        }
    },
    items =
    {
        { slot = 15, iconNum = 11, dyes = {} },
        { slot =  9, iconNum =  9, dyes = {} },
        { slot = 10, iconNum = 10, dyes = {} },
        { slot = 13, iconNum = 13, dyes = {} },
        { slot =  6, iconNum =  6, dyes = {} },
        { slot =  7, iconNum =  7, dyes = {} },
        { slot = 14, iconNum = 14, dyes = {} },
        { slot =  8, iconNum =  8, dyes = {} }
    },
    itemsPersist =
    {
        { slot = 15, iconNum = 11, dyes = {} },
        { slot =  9, iconNum =  9, dyes = {} },
        { slot = 10, iconNum = 10, dyes = {} },
        { slot = 13, iconNum = 13, dyes = {} },
        { slot =  6, iconNum =  6, dyes = {} },
        { slot =  7, iconNum =  7, dyes = {} },
        { slot = 14, iconNum = 14, dyes = {} },
        { slot =  8, iconNum =  8, dyes = {} }
    },
    items_defaults =
    {
        ["primary"]   = { r = 0, g = 0, b = 0, a = 0.1 },
        ["secondary"] = { r = 0, g = 0, b = 0, a = 0.1 }
    }
}

PP.selectedDyeIndex = 1

PP.introText = L"Pocket Palette allows you to preview and experiment with all available dyes before applying them in game."

PP.introGuide = L"1. Select a dye from the Dye Picker. You can locate dyes by name using the filter, or change the list ordering.\n" ..
                L"2. Apply the selected dye to an equipment slot using the left or right mouse button. The \"All\" slot applies the same dye to every slot.\n" ..
                L"3. The character model will update to reflect the selected dyes in real time.\n\n" ..
                L"Tip: Type /pp reset in chat to clear all applied dyes."

PP.itemWindowGuide = L"Select an equipment slot to apply the chosen dye.\n\n" ..
                     L"Left Click: Apply primary color\n" ..
                     L"Right Click: Apply secondary color\n\n" ..
                     L"Click the same color again to remove it."


PP.toolTips =
{
    items =
    {
        [15] = L"Apply dye to all Items.\n\nThis has lower priorty than setting a color for a specific item slot.",
        [ 9] = L"Helm",
        [10] = L"Shoulders",
        [13] = L"Back",
        [ 6] = L"Body",
        [ 7] = L"Gloves",
        [14] = L"Belt",
        [ 8] = L"Boots"
    }
}

PP.dyeSourceLabel =
{
    client_csv = "Live client CSV",
    addon_csv = "Shipped PocketPalette.csv",
    placeholder = "Placeholder (no hue data)"
}

local table_insert = table.insert
local table_sort = table.sort
local string_find = string.find
local string_gsub = string.gsub
local string_lower = string.lower

local tostring      = tostring
local tonumber      = tonumber
local pairs         = pairs
local ipairs        = ipairs
local type          = type
local string        = string
local table         = table
local setmetatable  = setmetatable
local getmetatable  = getmetatable

local function GetDyeSourceLabel(source_key)
    return PP.dyeSourceLabel[source_key] or "Unknown"
end

local function DetermineDyeType(dye)
    local spec_i = tonumber(dye.SpecularIntensity) or 0
    local spec_r = tonumber(dye.SpecularRed) or 0
    local spec_g = tonumber(dye.SpecularGreen) or 0
    local spec_b = tonumber(dye.SpecularBlue) or 0

    -- Some client CSV parses lose SpecularIntensity but keep Specular RGB.
    if spec_i > 0 or spec_r > 1 or spec_g > 1 or spec_b > 1 then
        return 2
    end

    return 1
end

local debug_mode = false
if (debug_mode)
then

    d ("HighlightWindow( window ) : available")

    function HighlightWindow (window_name)

        if (WindowGetShowing (HelpTips.FOCUS_WINDOW_NAME) == true)
        then
            WindowStopAlphaAnimation (HelpTips.FOCUS_WINDOW_NAME)
            WindowSetShowing (HelpTips.FOCUS_WINDOW_NAME, false)
        end

        HelpTips.SetFocusOnWindow (window_name)

    end

end

local function DeepCopy(t, seen)
    if type(t) ~= "table" then return t end
    if seen and seen[t] then return seen[t] end
    local s = seen or {}
    local out = {}
    s[t] = out
    for k,v in pairs(t) do
        out[DeepCopy(k,s)] = DeepCopy(v,s)
    end
    return setmetatable(out, getmetatable(t))
end

function PP.Initialize()

    if LibSlash and LibSlash.RegisterSlashCmd then
        LibSlash.RegisterSlashCmd("pp", function (args)
            local cmd = string_lower(tostring(args or ""))

            if cmd == "reset" then
                PP.ResetAll()
            else
                WindowSetShowing("PPMain", true)
            end
        end)
    else
        d("PocketPalette: LibSlash not found, /pp disabled")
    end

    TextLogAddEntry(
        "Chat",
        SystemData.ChatLogFilters.SAY,
        L"Pocket Palette: Type /PP to show window"
    )
	
	TextLogAddEntry(
		"Chat",
		SystemData.ChatLogFilters.SAY,
		L"Pocket Palette: /pp reset clears all applied dyes"
	)

    RegisterEventHandler(SystemData.Events.ITEM_SET_DATA_ARRIVED, "PP.UpdateItemSlots")
    RegisterEventHandler(SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "PP.UpdateItemSlots")
    RegisterEventHandler(SystemData.Events.PLAYER_EQUIPMENT_SLOT_UPDATED, "PP.UpdateItemSlots")

    PP.CreateWindow()
    PP.ApplyPersistentItems()
    PP.GetDyeData()
    PP.UpdateDyeList()

    RegisterEventHandler(SystemData.Events.LOADING_END, "PP.PreviewDyes")
end

function PP.OnShown ()

    if (debug_mode)
    then
        d ("PP.OnShown")
    end

    PP.PreviewDyes ()
    PP.UpdateDyeCounts ()
    PP.UpdateItemSlots ()

end

function PP.OnClose ()

    if (debug_mode)
    then
        d ("PP.OnClose")
    end

    PP.ResetPreviewDyes ()

    WindowSetShowing (PP.settings.windows.main.name, false)

end

function PP.CreateWindow ()

    if (debug_mode)
    then
        d ("PP.CreateWindow")
    end

    local window_name_main = "PPMain"
    CreateWindow (window_name_main, false)
    LabelSetText (window_name_main.."TitleBarText", L"Pocket Palette")
    ButtonSetText (window_name_main.."CharacterWindowBtn", L"Paperdoll")
    ButtonSetText (window_name_main.."TogglePickerBtn", L"Hide")
    LabelSetText (window_name_main.."IntroText", PP.introText)
    LabelSetText (window_name_main.."IntroGuide", PP.introGuide)
    LabelSetText (window_name_main.."SaveSettingsLabel", L"Persistent settings")
    ButtonSetPressedFlag (window_name_main.."SaveSettingsButton", PP.settings.persistent)

    local window_name_dye = "DyeWindow"
    LabelSetText (window_name_dye.."TitleBarText", L"Dye Picker")
    LabelSetText (window_name_dye.."SelectedDye", L"Selected Dye")
    LabelSetText (window_name_dye.."Filter", L"Name filter:")
    LabelSetText (window_name_dye.."DyeOrder", L"Ordering:")
    LabelSetText (window_name_dye.."DyeType", L"Type:")

    for key, value in pairs (PP.settings.ordering)
    do
        ComboBoxAddMenuItem (window_name_dye.."DyeOrderCombo", value)
    end

    ComboBoxSetSelectedMenuItem (window_name_dye.."DyeOrderCombo", 1)

    for key, value in pairs (PP.settings.type)
    do
        ComboBoxAddMenuItem (window_name_dye.."DyeTypeCombo", value)
    end

    ComboBoxSetSelectedMenuItem (window_name_dye.."DyeTypeCombo", 3)

    local window_name_item = "ItemWindow"
    LabelSetText (window_name_item.."TitleBarText", L"Item Slots")
    LabelSetText (window_name_item.."Guide", PP.itemWindowGuide)

    PP.settings.windows["main"].width, PP.settings.windows["main"].height = WindowGetDimensions (PP.settings.windows["main"].name)

    local i, j, k, l, m = WindowGetAnchor (PP.settings.windows["main"].name, 1)
    PP.settings.windows["main"].anchor.x = l
    PP.settings.windows["main"].anchor.y = m

end

function PP.PersistentSettings()
    if not PP.settings.persistent then
        -- user explicitly disabled persistence → wipe state
        PP.settings.items = DeepCopy({
            { slot = 15, iconNum = 11, dyes = {} },
            { slot =  9, iconNum =  9, dyes = {} },
            { slot = 10, iconNum = 10, dyes = {} },
            { slot = 13, iconNum = 13, dyes = {} },
            { slot =  6, iconNum =  6, dyes = {} },
            { slot =  7, iconNum =  7, dyes = {} },
            { slot = 14, iconNum = 14, dyes = {} },
            { slot =  8, iconNum =  8, dyes = {} }
        })
    end
end

function PP.PersistentToggle ()
    local window_name = "PPMainSaveSettingsButton"

    PP.settings.persistent = not PP.settings.persistent
    ButtonSetPressedFlag(window_name, PP.settings.persistent)

    PP.PersistentSettings()
end

function PP.GetDyeData()

    local function skip_dye_name(dye_name)
        if type(dye_name) ~= "string" then
            return true
        end

        local name = string_lower(dye_name)

        return dye_name == ''
            or dye_name == '0'
            or name == 'player dyes'
            or string_find(name, "color", 1, true) == 1
    end

    local function trim_string(value)
        if value == nil then
            return ""
        end

        if type(value) ~= "string" then
            value = tostring(value)
        end

        value = string_gsub(value, "^%s+", "")
        value = string_gsub(value, "%s+$", "")

        return value
    end

    local function value_has_data(value)
        if value == nil then
            return false
        end

        if type(value) == "string" then
            return value ~= ""
        end

        return trim_string(tostring(value)) ~= ""
    end

    local function clamp_byte(value, fallback)
        if value ~= nil and type(value) ~= "number" and type(value) ~= "string" then
            value = tostring(value)
        end

        local n = tonumber(value)
        if n == nil then
            return fallback
        end

        if n < 0 then
            return 0
        end

        if n > 255 then
            return 255
        end

        return n
    end

    local function normalize_key(key_name)
        if key_name == nil then
            return ""
        end

        if type(key_name) ~= "string" then
            key_name = tostring(key_name)
        end

        return string_lower(string_gsub(key_name, "[^%w]", ""))
    end

    local function build_lookup(row)
        local lookup = {}

        for key, value in pairs(row) do
            if value_has_data(value) then
                local normalized = normalize_key(trim_string(key))
                if normalized ~= "" and lookup[normalized] == nil then
                    lookup[normalized] = value
                end
            end
        end

        return lookup
    end

    local function get_row_value(row, lookup, named_candidates, index_candidates)
        for _, key_name in ipairs(named_candidates) do
            local value = lookup[key_name]
            if value_has_data(value) then
                return value
            end

            value = row[key_name]
            if value_has_data(value) then
                return value
            end

            if type(towstring) == "function" then
                local wkey = towstring(key_name)
                value = row[wkey]
                if value_has_data(value) then
                    return value
                end
            end
        end

        for _, index in ipairs(index_candidates) do
            local value = row[index]
            if value_has_data(value) then
                return value
            end
        end

        return nil
    end

    local function is_usable_dye_name(dye_name, dye_id)
        if dye_name == ""
            or dye_name == tostring(dye_id)
        then
            return false
        end

        local lower_name = string_lower(dye_name)

        return lower_name ~= "nil"
            and lower_name ~= "unknown"
            and string_find(lower_name, "missing", 1, true) == nil
            and string_find(lower_name, "not found", 1, true) == nil
            and string_find(lower_name, "unknown string", 1, true) == nil
            and string_find(dye_name, "[%a]") ~= nil
            and not skip_dye_name(dye_name)
    end

    local function extract_dye_row(dye_id, row)
        if type(row) ~= "table" then
            return nil
        end

        local lookup = build_lookup(row)
        local dye_name = trim_string(tostring(get_row_value(row, lookup, { "name", "dyename" }, { 2 }) or ""))

        if skip_dye_name(dye_name) then
            if type(GetDyeNameString) == "function" then
                local ok, fallback_name = pcall(GetDyeNameString, dye_id)
                if ok then
                    fallback_name = trim_string(tostring(fallback_name or ""))
                    if is_usable_dye_name(fallback_name, dye_id) then
                        dye_name = fallback_name
                    end
                end
            end
        end

        if not is_usable_dye_name(dye_name, dye_id) then
            return nil
        end

        return {
            ID = dye_id,
            Name = dye_name,
            DiffuseRed = clamp_byte(get_row_value(row, lookup, { "diffusered", "diffuse", "red", "diffuse1" }, { 3 }), nil),
            DiffuseGreen = clamp_byte(get_row_value(row, lookup, { "diffusegreen", "green", "diffuse2" }, { 4 }), nil),
            DiffuseBlue = clamp_byte(get_row_value(row, lookup, { "diffuseblue", "blue", "diffuse3" }, { 5 }), nil),
            DiffuseIntensity = clamp_byte(get_row_value(row, lookup, { "diffuseintensity", "diffusealpha", "alpha", "diffuse4" }, { 6 }), nil),
            SpecularRed = clamp_byte(get_row_value(row, lookup, { "specularred", "specular", "specular1" }, { 7 }), nil),
            SpecularGreen = clamp_byte(get_row_value(row, lookup, { "speculargreen", "specular2" }, { 8 }), nil),
            SpecularBlue = clamp_byte(get_row_value(row, lookup, { "specularblue", "specular3" }, { 9 }), nil),
            SpecularIntensity = clamp_byte(get_row_value(row, lookup, { "specularintensity", "specularalpha", "specular4" }, { 10 }), nil)
        }
    end

    local source_priority =
    {
        addon_csv = 1,
        client_csv = 2
    }

    local function upsert_dye(dye_row, source_key)
        if not dye_row or not dye_row.ID then
            return
        end

        local dye = PP.DyeData[dye_row.ID]
        if not dye then
            dye =
            {
                ID = dye_row.ID,
                Count = 0
            }
            PP.DyeData[dye_row.ID] = dye
        end

        if source_key and source_priority[source_key] then
            local current_priority = source_priority[dye.Source] or 0
            if current_priority <= source_priority[source_key] then
                dye.Source = source_key
            end
        end

        local incoming_has_diffuse =
            dye_row.DiffuseRed ~= nil
            or dye_row.DiffuseGreen ~= nil
            or dye_row.DiffuseBlue ~= nil
            or dye_row.DiffuseIntensity ~= nil

        if incoming_has_diffuse and source_key and source_priority[source_key] then
            local current_hue_priority = source_priority[dye.HueSource] or 0
            if current_hue_priority <= source_priority[source_key] then
                dye.HueSource = source_key
            end
        end

        if dye_row.Name and not skip_dye_name(dye_row.Name) then
            dye.Name = dye_row.Name
        end

        if dye_row.DiffuseRed ~= nil then
            dye.DiffuseRed = dye_row.DiffuseRed
        end
        if dye_row.DiffuseGreen ~= nil then
            dye.DiffuseGreen = dye_row.DiffuseGreen
        end
        if dye_row.DiffuseBlue ~= nil then
            dye.DiffuseBlue = dye_row.DiffuseBlue
        end
        if dye_row.DiffuseIntensity ~= nil then
            dye.DiffuseIntensity = dye_row.DiffuseIntensity
        end
        if dye_row.SpecularRed ~= nil then
            dye.SpecularRed = dye_row.SpecularRed
        end
        if dye_row.SpecularGreen ~= nil then
            dye.SpecularGreen = dye_row.SpecularGreen
        end
        if dye_row.SpecularBlue ~= nil then
            dye.SpecularBlue = dye_row.SpecularBlue
        end
        if dye_row.SpecularIntensity ~= nil then
            dye.SpecularIntensity = dye_row.SpecularIntensity
        end

        local has_any_diffuse =
            dye.DiffuseRed ~= nil
            or dye.DiffuseGreen ~= nil
            or dye.DiffuseBlue ~= nil
            or dye.DiffuseIntensity ~= nil

        if not has_any_diffuse then
            -- No hue data from client/shipped sources: use a visible placeholder hue.
            dye.DiffuseRed = 127
            dye.DiffuseGreen = 127
            dye.DiffuseBlue = 127
            dye.DiffuseIntensity = 255
            dye.MissingHue = true
            dye.HueSource = "placeholder"
        else
            if dye.DiffuseRed == nil then
                dye.DiffuseRed = 127
            end
            if dye.DiffuseGreen == nil then
                dye.DiffuseGreen = dye.DiffuseRed
            end
            if dye.DiffuseBlue == nil then
                dye.DiffuseBlue = dye.DiffuseRed
            end
            if dye.DiffuseIntensity == nil then
                dye.DiffuseIntensity = 255
            end
            dye.MissingHue = false
            if dye.HueSource == nil then
                dye.HueSource = dye.Source
            end
        end
        if dye.SpecularRed == nil then
            dye.SpecularRed = 0
        end
        if dye.SpecularGreen == nil then
            dye.SpecularGreen = 0
        end
        if dye.SpecularBlue == nil then
            dye.SpecularBlue = 0
        end
        if dye.SpecularIntensity == nil then
            dye.SpecularIntensity = 0
        end

        dye.Type = DetermineDyeType(dye)
    end

    local function import_csv_rows(rows, source_key)
        if type(rows) ~= "table" then
            return 0
        end

        local imported = 0
        for dye_key, dye_value in pairs(rows) do
            if type(dye_value) == "table" then
                local dye_id = tonumber(dye_key)
                if dye_id == nil then
                    dye_id = tonumber(dye_value.ID or dye_value.Id or dye_value.id)
                end

                if dye_id and dye_id > 0 then
                    local dye_row = extract_dye_row(dye_id, dye_value)
                    if dye_row then
                        upsert_dye(dye_row, source_key)
                        imported = imported + 1
                    end
                end
            end
        end

        return imported
    end

    local function read_csv(path, target_key)
        PP[target_key] = nil
        local ok = pcall(BuildTableFromCSV, path, "PP." .. target_key)
        if not ok then
            PP[target_key] = nil
            return nil, false
        end

        local rows = PP[target_key]
        PP[target_key] = nil

        return rows, true
    end

    PP.DyeData = {}

    local addon_rows, addon_ok = read_csv(
        tostring(SystemData.Directories.AddOnsInterface) .. "/PocketPalette/PocketPalette.csv",
        "_DyeDataAddonCSV"
    )
    if addon_ok then
        import_csv_rows(addon_rows, "addon_csv")
    end

    local client_rows, client_ok = read_csv(
        "data\\gamedata\\tintpalette_equipment.csv",
        "_DyeDataClientCSV"
    )
    if client_ok then
        import_csv_rows(client_rows, "client_csv")
    end

    PP.UpdateDyeCounts()
end

function PP.UpdateDyeCounts()

    local inventory_dyes = {}

    local items = GetInventoryItemData()
    if items then
        for _, value in ipairs(items) do
            if value.id ~= 0 and value.type == GameData.ItemTypes.DYE then
                local entry = inventory_dyes[value.uniqueID]
                if entry then
                    entry.count = entry.count + value.stackCount
                else
                    inventory_dyes[value.uniqueID] =
                    {
                        name  = tostring(value.name),
                        id    = value.uniqueID,
                        count = value.stackCount
                    }
                end
            end
        end
    end

    items = GetBankData()
    if items then
        for _, value in ipairs(items) do
            if value.id ~= 0 and value.type == GameData.ItemTypes.DYE then
                local entry = inventory_dyes[value.uniqueID]
                if entry then
                    entry.count = entry.count + value.stackCount
                else
                    inventory_dyes[value.uniqueID] =
                    {
                        name  = tostring(value.name),
                        id    = value.uniqueID,
                        count = value.stackCount
                    }
                end
            end
        end
    end

    if debug_mode then
        inventory_dyes["TEST"] =
        {
            name  = "Chaos Black Dye",
            id    = 99,
            count = 999
        }
    end

    for dye_key, dye_value in pairs(PP.DyeData) do
        if dye_value and dye_value.Name then
            local dye_name = string_gsub(dye_value.Name, ' %(.*%)', '') .. " Dye"

            for _, inventory_value in pairs(inventory_dyes) do
                if inventory_value.name and dye_name == inventory_value.name then
                    PP.DyeData[dye_key].Count = inventory_value.count
                end
            end
        end
    end
end

function PP.ShowPaperDoll ()

    if (WindowGetShowing ("CharacterWindow") == true)
    then
        WindowSetShowing ("CharacterWindow", false)
    else
        WindowSetShowing ("CharacterWindow", true)
    end
end

function PP.ToggleWindow ()

    local b = PP.settings.windows["main"].name

    local l, m = WindowGetScreenPosition (b)
    local w, h = WindowGetDimensions(b)

    local x = {}
    local y = WindowGetAnchorCount (b)

    for z = 1, y
    do
        table.insert (x, { WindowGetAnchor (b, z) })
    end

    local A = 200

    if (PP.settings.windows["main"].minimized == true)
    then
        WindowSetShowing ("DyeWindow", true)
        WindowSetShowing ("ItemWindow", true)
        WindowClearAnchors (b)

        local B = x[1][5] - (A / 2 - PP.settings.windows["main"].height / 2)
        WindowAddAnchor (b, x[1][1], x[1][3], x[1][2], x[1][4], B)
        WindowSetDimensions (b, PP.settings.windows["main"].width, PP.settings.windows["main"].height)
        WindowForceProcessAnchors (b)
        ButtonSetText (b.."TogglePickerBtn", L"Hide")

        PP.settings.windows["main"].minimized = false
    else
        WindowSetShowing ("DyeWindow", false)
        WindowSetShowing ("ItemWindow", false)
        WindowClearAnchors (b)

        local B = x[1][5] - (PP.settings.windows["main"].height / 2 - A / 2)
        WindowAddAnchor (b, x[1][1], x[1][3], x[1][2], x[1][4], B)
        WindowSetDimensions (b, PP.settings.windows["main"].width, A)
        WindowForceProcessAnchors (b)
        ButtonSetText (b.."TogglePickerBtn", L"Show")
        PP.settings.windows["main"].minimized = true
    end
end

function PP.DyeWindowPopulateDisplay ()

    if (not DyeWindowList.PopulatorIndices)
    then

        if (debug_mode)
        then
            d("DyeWindowList: List was empty")
        end

        return

    end

    for index, value in ipairs (DyeWindowList.PopulatorIndices)
    do
        local E = "DyeWindow"
        local F = E.."ListRow"..index
        local dye = PP.DyeData[value]

        WindowSetTintColor (F.."Color", dye.DiffuseRed, dye.DiffuseGreen, dye.DiffuseBlue)
        WindowSetAlpha (F.."Color", dye.DiffuseIntensity)
        LabelSetText (F.."Name", towstring (dye.Name))
        LabelSetText (F.."Count", towstring (dye.Count))

        PP.UpdateListRow (value, F)
    end

end

function PP.UpdateListRow (D, F)

    F = F or nil

    if (D == PP.selectedDyeIndex)
    then
        WindowSetTintColor (F.."Background", 200, 200, 200)
        WindowSetAlpha (F.."Background", 0.4)
        WindowSetTintColor ("DyeWindowSelectedDyeColor", PP.DyeData[PP.selectedDyeIndex].DiffuseRed, PP.DyeData[PP.selectedDyeIndex].DiffuseGreen, PP.DyeData[PP.selectedDyeIndex].DiffuseBlue)
        WindowSetAlpha ("DyeWindowSelectedDyeColor", PP.DyeData[PP.selectedDyeIndex].DiffuseIntensity / 2)
        LabelSetText ("DyeWindowSelectedDyeName", towstring (PP.DyeData[PP.selectedDyeIndex].Name))
        LabelSetText("DyeWindowSelectedDyeCount", towstring(PP.DyeData[PP.selectedDyeIndex].Count))
    else
        WindowSetAlpha(F.."Background", 0)
    end

end

function PP.DyeRowMouseOver()

    local row = WindowGetId(SystemData.ActiveWindow.name)
    local dye_id = ListBoxGetDataIndex("DyeWindowList", row)
    local dye = PP.DyeData and PP.DyeData[dye_id]

    if not dye then
        return
    end

    local hue_source = dye.HueSource or (dye.MissingHue and "placeholder") or dye.Source
    local source_label = GetDyeSourceLabel(dye.Source)
    local hue_label = GetDyeSourceLabel(hue_source)

    local tooltip =
        "#" .. tostring(dye.ID or dye_id)
        .. " | Src: " .. source_label

    if hue_label ~= source_label then
        tooltip = tooltip .. "\nHue: " .. hue_label
    end

    if type(WindowGetScale) == "function" and type(WindowSetScale) == "function" then
        if PP._prevTooltipScale == nil then
            PP._prevTooltipScale = WindowGetScale("DefaultTooltip")
        end
        WindowSetScale("DefaultTooltip", 0.82)
    end

    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, towstring(tooltip))
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_TOP)
    Tooltips.Finalize()
end

function PP.DyeRowMouseOverEnd()
    if type(WindowSetScale) == "function" and PP._prevTooltipScale then
        WindowSetScale("DefaultTooltip", PP._prevTooltipScale)
    end
    PP._prevTooltipScale = nil
    Tooltips.ClearTooltip()
end

function PP.UpdateDyeList()

    -- Sort helper
    local function BuildSortedIndex(source, key, out, descending)
        local tmp = {}

        for id, row in pairs(source) do
            table_insert(tmp, { id, row[key] })
        end

        if descending then
            table_sort(tmp, function(a, b) return a[2] > b[2] end)
        else
            table_sort(tmp, function(a, b) return a[2] < b[2] end)
        end

        for _, v in ipairs(tmp) do
            table_insert(out, v[1])
        end
    end

    -- Deep copy (preserves original table + metatable)
    local function DeepCopyTable(src, seen)
        if type(src) ~= "table" then
            return src
        end

        if seen and seen[src] then
            return seen[src]
        end

        local s = seen or {}
        local copy = setmetatable({}, getmetatable(src))
        s[src] = copy

        for k, v in pairs(src) do
            copy[DeepCopyTable(k, s)] = DeepCopyTable(v, s)
        end

        return copy
    end

    -- Clone base dye table
    PP.DyeDataVisible = DeepCopyTable(PP.DyeData)

    -- Name filter
    if PP.settings.filter ~= "" then
        for id, dye in pairs(PP.DyeDataVisible) do
            local name = dye and dye.Name
            if type(name) ~= "string"
                or not string_find(string_lower(name), PP.settings.filter)
            then
                PP.DyeDataVisible[id] = nil
            end
        end
    end

    -- Type filter (Diffuse / Specular)
    local selected_type = ComboBoxGetSelectedMenuItem("DyeWindowDyeTypeCombo")

    if selected_type ~= 3 then
        for id, dye in pairs(PP.DyeDataVisible) do
            if not dye or dye.Type ~= selected_type then
                PP.DyeDataVisible[id] = nil
            end
        end
    end

    -- Build display order
    local order = {}
    local sorters =
    {
        [1] = function()
            BuildSortedIndex(PP.DyeDataVisible, "ID", order)
        end,

        [2] = function()
            BuildSortedIndex(PP.DyeDataVisible, "Name", order)
        end,

        [3] = function()
            BuildSortedIndex(PP.DyeDataVisible, "Count", order, true)
        end,

        [4] = function()
            for id in pairs(PP.DyeDataVisible) do
                table_insert(order, 1, id)
            end
        end
    }

    local sorter = sorters[ComboBoxGetSelectedMenuItem("DyeWindowDyeOrderCombo")]
    if sorter then
        sorter()
    else
        sorters[1]()
    end

    ListBoxSetDisplayOrder("DyeWindowList", order)
end

function PP.UpdateDyeFilter ()

    PP.settings.filter = string_lower (tostring (TextEditBoxGetText ("DyeWindowFilterEditBox")))

    PP.UpdateDyeList ()

end

function PP.SelectDye ()

    local window_id = WindowGetId (SystemData.MouseOverWindow.name)

    PP.selectedDyeIndex = ListBoxGetDataIndex ("DyeWindowList", window_id)

    local E = "DyeWindow"

    for index, value in ipairs (DyeWindowList.PopulatorIndices)
    do
        local window_name_list_row = E.."ListRow"..index
        PP.UpdateListRow (value, window_name_list_row)
    end

end

function PP.UpdateItemSlots ()

    local equipment = GetEquipmentData ()
    local h = "ItemWindow"

    for item_index, item in ipairs (PP.settings.items)
    do
        local iconId = 0

		if item.slot ~= 15 and equipment[item.slot].iconNum ~= 0 then
			iconId = equipment[item.slot].iconNum
		else
			iconId = CharacterWindow.EquipmentSlotInfo[item.iconNum].iconNum
		end

local texture_name, texture_x, texture_y = GetIconData(iconId)
        DynamicImageSetTexture (h.."EquipmentSlot"..item.slot.."IconBase", texture_name, texture_x, texture_y)
        WindowSetTintColor (h.."EquipmentSlot"..item.slot.."IconPri", PP.settings.items_defaults.primary.r, PP.settings.items_defaults.primary.g, PP.settings.items_defaults.primary.b)
        WindowSetAlpha (h.."EquipmentSlot"..item.slot.."IconPri", PP.settings.items_defaults.primary.a)
        WindowSetTintColor (h.."EquipmentSlot"..item.slot.."IconSec", PP.settings.items_defaults.secondary.r, PP.settings.items_defaults.secondary.g, PP.settings.items_defaults.secondary.b)
        WindowSetAlpha (h.."EquipmentSlot"..item.slot.."IconSec", PP.settings.items_defaults.secondary.a)
    end

    PP.UpdateItemDyes ()

end

function PP.UpdateItemDyes ()

    local b = "ItemWindow"

    for item_index, item in ipairs (PP.settings.items)
    do
        local a1 = b.."EquipmentSlot"..item.slot

        if (item.dyes.primary == nil)
        then
            WindowSetTintColor (a1 .."IconPri", PP.settings.items_defaults.primary.r, PP.settings.items_defaults.primary.g, PP.settings.items_defaults.primary.b)
            WindowSetAlpha (a1 .."IconPri", PP.settings.items_defaults.primary.a)
        else
            WindowSetTintColor (a1 .."IconPri", PP.DyeData[item.dyes.primary].DiffuseRed, PP.DyeData[item.dyes.primary].DiffuseGreen, PP.DyeData[item.dyes.primary].DiffuseBlue)
            WindowSetAlpha (a1 .."IconPri", PP.DyeData[item.dyes.primary].DiffuseIntensity)
        end

        if (item.dyes.secondary == nil)
        then
            WindowSetTintColor (a1 .."IconSec", PP.settings.items_defaults.secondary.r, PP.settings.items_defaults.secondary.g, PP.settings.items_defaults.secondary.b)
            WindowSetAlpha (a1 .."IconSec", PP.settings.items_defaults.secondary.a)
        else
            WindowSetTintColor (a1 .."IconSec", PP.DyeData[item.dyes.secondary].DiffuseRed, PP.DyeData[item.dyes.secondary].DiffuseGreen, PP.DyeData[item.dyes.secondary].DiffuseBlue)
            WindowSetAlpha (a1 .."IconSec", PP.DyeData[item.dyes.secondary].DiffuseIntensity)
        end
    end

end

function PP.ItemSlotMouseOver ()

    local a2 = WindowGetId (SystemData.ActiveWindow.name)
    local a3 = PP.toolTips.items[a2]
    local a4 = Tooltips.COLOR_HEADING

    if a2 == 15 or CharacterWindow.equipmentData[a2].id == 0
    then
        a4 = Tooltips.COLOR_ITEM_DEFAULT_GRAY
    else
        a3 = a3 ..L" : "..CharacterWindow.equipmentData[a2].name

        if PP.ItemIsDyable (CharacterWindow.equipmentData[a2])
        then
        else
            a3 = a3 ..L"\n\n"..GetString (StringTables.Default.TEXT_CANNOT_DYE_ITEM)
            a4 = Tooltips.COLOR_FAILS_REQUIREMENTS
        end
    end

    for z, Z in ipairs (PP.settings.items)
    do
        if Z.slot == a2 then

            local a5 = L""

            if Z.dyes.primary ~= nil and Z.dyes.secondary ~= nil
            then
                local a6 = GetDyeNameString (Z.dyes.primary)
                local a7 = GetDyeNameString (Z.dyes.secondary)
                a5 = GetStringFormat (StringTables.Default.TEXT_TWO_DYE_COLOR, { a6, a7 })

            elseif Z.dyes.primary~=nil
            then
                local a8 = GetDyeNameString (Z.dyes.primary)
                a5 = GetStringFormat (StringTables.Default.TEXT_ONE_DYE_COLOR, { a8 })

            elseif Z.dyes.secondary ~= nil
            then
                local a9 = GetDyeNameString (Z.dyes.secondary)
                a5 = GetStringFormat (StringTables.Default.TEXT_ONE_DYE_COLOR, { a9 })

            end

            a3 = a3 ..L"\n\n"..a5

        end
    end

    Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, a3)
    Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP)
    Tooltips.SetTooltipColorDef (1, 1, a4)
    Tooltips.Finalize ()

end

function PP.ItemSlotLMouse ()
    PP.SetItemDye (true)
end

function PP.ItemSlotRMouse ()
    PP.SetItemDye (false)
end

function PP.ResetAll() -- added by Emissary
    -- Clear runtime items
    PP.settings.items = DeepCopy({
        { slot = 15, iconNum = 11, dyes = {} },
        { slot =  9, iconNum =  9, dyes = {} },
        { slot = 10, iconNum = 10, dyes = {} },
        { slot = 13, iconNum = 13, dyes = {} },
        { slot =  6, iconNum =  6, dyes = {} },
        { slot =  7, iconNum =  7, dyes = {} },
        { slot = 14, iconNum = 14, dyes = {} },
        { slot =  8, iconNum =  8, dyes = {} }
    })

    -- Clear persistent storage
    PP.settings.itemsPersist = DeepCopy(PP.settings.items)

    -- Revert previews safely
    RevertAllDyePreview()

    -- Refresh UI
    PP.UpdateItemSlots()
    PP.UpdateItemDyes()
    PP.PreviewDyes()

    d("PocketPalette: dyes reset")
end

function PP.ApplyPersistentItems() -- added by Emissary
    if PP.settings.persistent
       and PP.settings.itemsPersist
       and type(PP.settings.itemsPersist) == "table"
    then
        PP.settings.items = DeepCopy(PP.settings.itemsPersist)
    end
end

function PP.MaybeSavePersistentItems() -- added by Emissary
    if PP.settings.persistent then
        PP.settings.itemsPersist = DeepCopy(PP.settings.items)
    end
end

function PP.SetItemDye (aa)
    local a2 = WindowGetId (SystemData.ActiveWindow.name)
    local ab = aa and 'primary' or 'secondary'

    for z, Z in ipairs (PP.settings.items) do
        if a2 == Z.slot then
            if PP.settings.items[z].dyes[ab] == nil
               or PP.settings.items[z].dyes[ab] ~= PP.selectedDyeIndex
            then
                PP.settings.items[z].dyes[ab] = PP.selectedDyeIndex
            else
                PP.settings.items[z].dyes[ab] = nil
            end
        end
    end

    PP.MaybeSavePersistentItems()   -- Added by Emissary

    PP.UpdateItemDyes()
    PP.ItemSlotMouseOver()
    PP.PreviewDyes()
end

function PP.ResetPreviewDyes ()

    if PP.settings.persistent == false
    then
        RevertAllDyePreview ()
    end
end

function PP.PreviewDyes()

    if not CharacterWindow or not CharacterWindow.equipmentData then
        return
    end

    PP.ResetPreviewDyes()

    local ac = 0
    local ad = 0

    -- collect "All slots" dyes (slot 15)
    for _, Z in ipairs(PP.settings.items) do
        if Z.slot == 15 then
            ac = Z.dyes.primary or ac
            ad = Z.dyes.secondary or ad
        end
    end

    -- apply previews
    for _, Z in ipairs(PP.settings.items) do
        if Z.slot ~= 15 then
            local ae = ac ~= 0 and ac or CharacterWindow.equipmentData[Z.slot].dyeTintA
            local af = ad ~= 0 and ad or CharacterWindow.equipmentData[Z.slot].dyeTintB

            if Z.dyes.primary then
                ae = Z.dyes.primary
            end

            if Z.dyes.secondary then
                af = Z.dyes.secondary
            end

            DyeMerchantPreview(GameData.ItemLocs.EQUIPPED, Z.slot, ae, af)
        end
    end
end

function PP.ItemIsDyable(ag)
    if not ag or not ag.id or not ag.flags then
        return false
    end

    local mask = GetDyeTintMasks(ag.id)

    return ag.flags[GameData.Item.EITEMFLAG_DYE_ABLE] == true
        and mask ~= GameData.TintMasks.NONE
        and not ag.broken
end

function PP.ItemIsBleachable (ag)
    return PP.ItemIsDyable(ag)
        and (ag.dyeTintA ~= 0 or ag.dyeTintB ~= 0)
end

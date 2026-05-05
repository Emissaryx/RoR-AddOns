--[[
  IraConfig ((Lib) Ira Config) version 1.05
  by Irinia of Volkmar

  This file handles spinner controls.
--]]

IraConfig = IraConfig or {}
local ic = IraConfig

ic.vSpinners = ic.vSpinners or {}

local function NormalizeSpinnerConfig(maxValue, minValue, inc)
    if not maxValue or maxValue <= 0 then
        maxValue = 999999
    end

    if not inc or inc < 1 then
        inc = 1
    end

    if not minValue or minValue < 0 then
        minValue = 0
    end

    if minValue > maxValue then
        minValue, maxValue = maxValue, minValue
    end

    return maxValue, minValue, inc
end

local function GetSpinnerConfig(editName)
    if not editName then
        return nil
    end
    return ic.vSpinners[editName]
end

local function GetSpinnerEditFromButton()
    local buttonName = SystemData.MouseOverWindow.name
    if not buttonName or buttonName == "" then
        return nil
    end

    local spinnerFrame = WindowGetParent(buttonName)
    if not spinnerFrame then
        return nil
    end

    local _, _, editName = WindowGetAnchor(spinnerFrame, 1)
    return editName
end

local function GetSpinnerValue(editName, config)
    if not editName or not config then
        return nil
    end

    local text = TextEditBoxGetText(editName)
    local value = tonumber(text)

    if not value then
        return config.min or 0
    end

    return value
end

local function SetSpinnerValue(editName, value)
    if not editName or value == nil then
        return
    end
    TextEditBoxSetText(editName, towstring(value))
end

function ic.SetupSpinner(editName, maxValue, minValue, inc)
    if not editName or editName == "" then
        return
    end

    local parent = WindowGetParent(editName)
    if not parent then
        return
    end

    local spinnerName = editName .. "Spinner"

    CreateWindowFromTemplate(spinnerName, "IraConfigSpinner", parent)
    WindowAddAnchor(spinnerName, "right", editName, "left", 1, 0)

    maxValue, minValue, inc = NormalizeSpinnerConfig(maxValue, minValue, inc)

    ic.vSpinners[editName] = {
        max = maxValue,
        min = minValue,
        inc = inc,
    }

    -- If you want automatic validation while typing or on wheel, you can
    -- re enable these and provide the handlers:
    -- WindowRegisterCoreEventHandler(editName, "OnTextChanged", "IraConfig.SpinnerChange")
    -- WindowRegisterCoreEventHandler(editName, "OnMouseWheel", "IraConfig.SpinnerWheel")
end

function ic.SpinnerMinus()
    local editName = GetSpinnerEditFromButton()
    if not editName then
        return
    end

    local config = GetSpinnerConfig(editName)
    if not config then
        return
    end

    local value = GetSpinnerValue(editName, config)
    local maxValue = config.max
    local minValue = config.min
    local inc = config.inc

    if value <= minValue then
        value = maxValue
    elseif value == maxValue and inc > 1 then
        -- Keeps the same step behavior for ranges like 0 255
        if math.mod(maxValue, inc) ~= 0 then
            value = maxValue - math.mod(maxValue, inc)
        else
            value = value - inc
        end
    elseif (value - inc) < minValue then
        value = minValue
    else
        value = value - inc
    end

    SetSpinnerValue(editName, value)
end

function ic.SpinnerPlus()
    local editName = GetSpinnerEditFromButton()
    if not editName then
        return
    end

    local config = GetSpinnerConfig(editName)
    if not config then
        return
    end

    local value = GetSpinnerValue(editName, config)
    local maxValue = config.max
    local minValue = config.min
    local inc = config.inc

    if value >= maxValue then
        value = minValue
    elseif (value + inc) > maxValue then
        value = maxValue
    else
        value = value + inc
    end

    SetSpinnerValue(editName, value)
end

function ic.SpinnerChange()
    local editName = SystemData.ActiveWindow.name
    if not editName then
        return
    end

    local config = GetSpinnerConfig(editName)
    if not config then
        return
    end

    local value = GetSpinnerValue(editName, config)

    local changed = false

    if value < config.min then
        value = config.min
        changed = true
    end

    if value > config.max then
        value = config.max
        changed = true
    end

    if changed then
        SetSpinnerValue(editName, value)
    end
end

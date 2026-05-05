--[[
  Crafting Info Tooltip v1.27

  Crafting Info Tooltip (CraftValueTip) is an addon for Warhammer: Age of
  Reckoning which displays the hidden stats on crafting items as part of the
  tooltip.

  This file contains everything related to the config UI.
]]--

function CraftValueTip.InitConfig()
  local windowName = "CraftValueTipConfig"

  -- Create the config window if it does not already exist
  if not DoesWindowExist(windowName) then
    CreateWindow(windowName, false)
  end

  -- Register with IraConfig and remember our tab id
  CraftValueTip.nConfigTab = IraConfig.RegisterAddon(
    L"CraftTip",
    CraftValueTip.GetPhrase("config", "tabtip"),
    windowName,
    CraftValueTip.ConfigCallback
  )

  -- Force initial population of the window
  CraftValueTip.ConfigCallback(IraConfig.CALLBACK_OPEN, CraftValueTip.nConfigTab)
end

function CraftValueTip.DoConfig()
  if CraftValueTip.nConfigTab then
    IraConfig.Open(CraftValueTip.nConfigTab)
  end
end

function CraftValueTip.ConfigCallback(message, tabId)
  local windowName = "CraftValueTipConfig"

  if message == IraConfig.CALLBACK_OPEN then
    -- Static labels
    LabelSetText(
      windowName .. "Version",
      CraftValueTip.GetPhrase("config", "version", CraftValueTip.version)
    )
    LabelSetText(
      windowName .. "LanguageLabel",
      CraftValueTip.GetPhrase("config", "language")
    )
    LabelSetText(
      windowName .. "ShowLabel",
      CraftValueTip.GetPhrase("config", "showinfo")
    )
    LabelSetText(
      windowName .. "ShowDevLabel",
      CraftValueTip.GetPhrase("config", "showdev")
    )

    -- Language combo box setup
    ComboBoxClearMenuItems(windowName .. "Language")

    -- Entry 1: "use game default"
    ComboBoxAddMenuItem(
      windowName .. "Language",
      CraftValueTip.GetPhrase("config", "langdefault")
    )

    -- Build language forward and reverse maps
    CraftValueTip.vLangMapFwd = { [0] = 1 }  -- settings.language -> combo index
    CraftValueTip.vLangMapRev = { [1] = 0 }  -- combo index -> settings.language

    local comboIndex = 2
    for langId, localeData in pairs(CraftValueTip.T) do
      CraftValueTip.vLangMapFwd[langId]   = comboIndex
      CraftValueTip.vLangMapRev[comboIndex] = langId

      ComboBoxAddMenuItem(windowName .. "Language", localeData.config.langthis)

      comboIndex = comboIndex + 1
    end

  elseif message == IraConfig.CALLBACK_RESET then
    -- Refresh the controls from current settings
    ButtonSetPressedFlag(windowName .. "ShowButton",    CraftValueTip.settings.enable)
    ButtonSetPressedFlag(windowName .. "ShowDevButton", CraftValueTip.settings.debug)

    local selectedIndex

    if CraftValueTip.vLangMapFwd
       and CraftValueTip.vLangMapFwd[CraftValueTip.settings.language]
    then
      selectedIndex = CraftValueTip.vLangMapFwd[CraftValueTip.settings.language]
    else
      selectedIndex = 1  -- default
    end

    ComboBoxSetSelectedMenuItem(windowName .. "Language", selectedIndex)

  elseif message == IraConfig.CALLBACK_SAVE then
    -- Save checkboxes
    CraftValueTip.settings.enable = ButtonGetPressedFlag(windowName .. "ShowButton")
    CraftValueTip.settings.debug  = ButtonGetPressedFlag(windowName .. "ShowDevButton")

    -- Save language
    local selectedIndex = tonumber(
      ComboBoxGetSelectedMenuItem(windowName .. "Language")
    )

    local newLanguage = CraftValueTip.settings.language

    if CraftValueTip.vLangMapRev and CraftValueTip.vLangMapRev[selectedIndex] then
      newLanguage = CraftValueTip.vLangMapRev[selectedIndex]
    else
      newLanguage = 0  -- "use game default"
    end

    -- If language changed, apply and refresh labels
    if newLanguage ~= CraftValueTip.settings.language then
      CraftValueTip.settings.language = newLanguage
      CraftValueTip.SetLanguage(CraftValueTip.settings.language)

      -- Rebuild labels and combo contents
      CraftValueTip.ConfigCallback(IraConfig.CALLBACK_OPEN,  tabId)
      CraftValueTip.ConfigCallback(IraConfig.CALLBACK_RESET, tabId)
    end
  end
end

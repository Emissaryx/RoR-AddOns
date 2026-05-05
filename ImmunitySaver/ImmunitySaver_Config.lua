LibConfig = LibStub("LibConfig")

ImmunitySaver_Config = {}

local GUI

local function AddInfoLabel(text)
	local label = GUI("label", text)
	label.label:Font("font_default_text_small")
	label.label:Align("left")
end

function ImmunitySaver_Config.Slash(input)
	if not GUI then
		local settings = ImmunitySaver.Settings or ImmunitySaver.DefaultSettings
		local version  = (settings and settings.Version) or "1.00"

		GUI = LibConfig("ImmunitySaver v" .. tostring(version), settings, true, ImmunitySaver_Config.SettingsChanged)

		GUI:AddTab("Info")
		AddInfoLabel("ImmunitySaver can set a check for abilities that will be ineffective if the target is immune or when the target")
		AddInfoLabel("The check will be indicated with these symbols:")
		AddInfoLabel("<icon05007> - Immovable")
		AddInfoLabel("<icon05006> - Unstoppable")
		AddInfoLabel("When the ability's check is triggered the ability will be disabled (greyed out) on the hotbar.")
		AddInfoLabel("To toggle the check on an ability SHIFT-LEFT CLICK the ability on your hotbar.")
		AddInfoLabel("By default targeted abilities that Knock-down, Punt, Stagger, Silence or Disarm are configured accordingly.")

		GUI:AddTab("Settings")
		GUI("checkbox", "Enabled", "Enabled")
		GUI("checkbox", "Show Symbols", "Symbols")
		GUI("checkbox", "Show Combat Error messages", "ErrorMessages")
		GUI("checkbox", "Reset Ability Defaults", "ResetAbilities")
	end

	GUI:Show()
end

function ImmunitySaver_Config.SettingsChanged()
	if GUI then
		GUI:Hide()
	end
	ImmunitySaver.UpdateSettings()
end

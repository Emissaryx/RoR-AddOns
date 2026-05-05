LibConfig = LibStub("LibConfig")

GCDsaver_Config = {}

local GUI

function GCDsaver_Config.Slash(input)
	if (not GUI) then
		-- parameters: title text, settings table, callback-function
		-- note that you need to have a settings table!
		GUI = LibConfig("GCDsaver v" .. tostring(GCDsaver.Settings.Version), GCDsaver.Settings, true, GCDsaver_Config.SettingsChanged)
		
		GUI:AddTab("Info")
		local infoText
		infoText = GUI("label", "GCDsaver can block the use of abilities that are ineffective if the target is immune, or have exceeded a stack limit on the target, or the attacker's career resources are not yet maxed.")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label", "The check will be indicated with these symbols:")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label", "1x - One stack")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label", "2x - Two stacks")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label", "3x - Three stacks")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label", "<icon05007> - Immovable")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label", "<icon05006> - Unstoppable")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")
		
		infoText = GUI("label", "RE - Career resources")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label", "When the ability's check is triggered the ability will be disabled (greyed out) on the hotbar.")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label", "To toggle the check on an ability SHIFT-LEFT CLICK the ability on your hotbar.")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")
		
		infoText = GUI("label", "To disable/enable the check on a specific slot, CTRL-LEFT CLICK the ability on your hotbar.")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label", "By default targeted abilities that Knock-down, Punt, Stagger, Silence or Disarm are configured accordingly.")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		GUI:AddTab("Settings")
		GUI("checkbox", "Enabled", "Enabled")
		GUI("checkbox", "Show Symbols", "Symbols")
		GUI("checkbox", "Show Combat Error messages", "ErrorMessages")
		-- Add checkboxes for new buff blocking settings
        GUI("checkbox", "Block Self and Friendly Buffs", "BlockFriendlyBuffs")
        GUI("checkbox", "Block Hostile Buffs", "BlockHostileBuffs")
		-- Add a textbox for Resource Trigger
		GUI("textbox", "Resource Trigger", "MaxResources")
		-- Add a checkbox for Debug Messages
        GUI("checkbox", "Show Debug Messages", "DebugMessages")
	end
	GUI:Show()
end

function GCDsaver_Config.SettingsChanged()
	GUI:Hide()
	GCDsaver.UpdateSettings()
end
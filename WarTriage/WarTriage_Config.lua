local LibConfig = LibStub and LibStub("LibConfig")
if not LibConfig then return end

WarTriage_Config = {}

local GUI

function WarTriage_Config.Slash(input)
	if not GUI or not GUI.Show then
		-- parameters: title text, settings table, callback-function
		-- note that you need to have a settings table!
		local settings = (WarTriage and (WarTriage.Settings or WarTriage.DefaultSettings)) or {}
		GUI = LibConfig("WarTriage v" .. tostring(settings.version), settings, true, WarTriage_Config.SettingsChanged)


		GUI:AddTab("Info")
		local infoText
		infoText = GUI("label", "WarTriage is an addon for the lazy or incompetent healer that needs automatic assistance to help decide which player to heal.")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label",  "The addon creates a macro which you put on your hotbar. When the macro is clicked the party/scenario/warband-member most in need of heals will be targeted.")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label",  "<icon20087> The macro icon will glow when there is a new player in need of heals. The glow will be more intense the more hurt the player is.")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label",  "Only players within healing range will be selected and a limited line-of sight check will be performed.")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		infoText = GUI("label",  "On the Settings tab you can enable/disable features or the addon entirely. On the Priorities tab you can adjust the behaviour of the selection algorithm.")
		infoText.label:Font("font_default_text_small")
		infoText.label:Align("left")

		GUI:AddTab("Settings")
		GUI("checkbox", "Enabled", "enabled")
		GUI("checkbox", "Check Line-of-Sight", "losCheck")
		GUI("checkbox", "Check Range", "rangeCheck")
		--GUI("checkbox", "Favor own Party", "favorOwnParty")
		GUI("checkbox", "Own Party Only", "ownPartyOnly")
		GUI("checkbox", "Ignore Dead", "ignoreDead")
		--GUI("checkbox", "Screen Alerts", "screenAlerts")
		GUI("checkbox", "Glow Effects", "glowEffects")

		GUI:AddTab("Priorities")
		local textbox
		textbox = GUI("textbox", "Always prioritize self if health % below:", "selfTargetPct")
		textbox.label:Font("font_default_text_small")
		textbox.label:Align("left")
		textbox.edit:AnchorTo(textbox.label, "right", "right")
		textbox.edit:Resize(50)

		textbox = GUI("textbox", "Then alive healers with health % below:", "healerTargetPct")
		textbox.label:Font("font_default_text_small")
		textbox.label:Align("left")
		textbox.edit:AnchorTo(textbox.label, "right", "right")
		textbox.edit:Resize(50)

		textbox = GUI("textbox", "Then alive dps with health % below:", "dpsTargetPct")
		textbox.label:Font("font_default_text_small")
		textbox.label:Align("left")
		textbox.edit:AnchorTo(textbox.label, "right", "right")
		textbox.edit:Resize(50)

		textbox = GUI("textbox", "Then alive tanks with health % below:", "tankTargetPct")
		textbox.label:Font("font_default_text_small")
		textbox.label:Align("left")
		textbox.edit:AnchorTo(textbox.label, "right", "right")
		textbox.edit:Resize(50)

		textbox = GUI("textbox", "Otherwise dead players or with health % below:", "playerTargetPct")
		textbox.label:Font("font_default_text_small")
		textbox.label:Align("left")
		textbox.edit:AnchorTo(textbox.label, "right", "right")
		textbox.edit:Resize(50)
	end
	GUI:Show()
end

function WarTriage_Config.SettingsChanged()
    if GUI and GUI.Hide then
        GUI:Hide()
    end
    if WarTriage and WarTriage.PrintSettings then
        WarTriage.PrintSettings()
    end
end

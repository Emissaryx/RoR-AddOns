TurretRange = TurretRange or {};
if (not TurretRange.Localization) then
	TurretRange.Localization = {};
	TurretRange.Localization.Language = {};
end

local localizationWarning = false;

function TurretRange.Localization.GetMapping()

	local lang = TurretRange.Localization.Language[SystemData.Settings.Language.active];
	
	if (not lang) then
		if (not localizationWarning) then
			d("Your current language is not supported. English will be used instead.");
			localizationWarning = true;
		end
		lang = TurretRange.Localization.Language[SystemData.Settings.Language.ENGLISH];
	end
	
	return lang;
	
end
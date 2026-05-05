JunkDumpLocalization = {}


function JunkDumpLocalization.getMainStrings(lang)
	if lang == 1 then
		return mainStrings.en
--[[	if lang == 2 then
		return mainStrings.fr
	if lang == 3 then
		return mainStrings.gr
	if lang == 4 then
		return mainStrings.it
	if lang == 5 then
		return mainStrings.sp
	if lang == 6 then
		return mainStrings.ko
	if lang == 7 then
		return mainStrings.s_ch
	if lang == 8 then
		return mainStrings.t_ch
	if lang == 9 then
		return mainStrings.jp
	if lang == 10 then
		return mainStrings.ru --]]
	else
		return mainStrings.en
	end
end

function JunkDumpLocalization.getUIStrings(lang)
	if lang == 1 then
		return uiStrings.en
--[[	if lang == 2 then
		return uiStrings.fr
	if lang == 3 then
		return uiStrings.gr
	if lang == 4 then
		return uiStrings.it
	if lang == 5 then
		return uiStrings.sp
	if lang == 6 then
		return uiStrings.ko
	if lang == 7 then
		return uiStrings.s_ch
	if lang == 8 then
		return uiStrings.t_ch
	if lang == 9 then
		return uiStrings.jp
	if lang == 10 then
		return uiStrings.ru --]]
	else
		return uiStrings.en
	end
end

mainStrings = {
				en = { L"WARNING: /jd has been taken by something else. Use /junkdump instead.", --1
					   L"JunkDump ", L" loaded. /junkdump or /jd for info.", --2 & 3
					   L"Removed ", L" from the Exceptions List", --4 & 5
					   L"Added ", L" to the Exceptions List", -- 6 & 7

					   L"from the Additions List", -- 8
					   L"to the Additions List", --9

					   L"Current Exceptions:", --10
					   L"Curent Additions:", --11

					   L"Invalid options. Do /junkdump or /jd for list of valid ones.", --12

					   L"Invalid Server", --13
					   L"Invalid Name", --14

					   L"Settings from ", L" of ", L" has been copied to this character.", --15 & 16 & 17
					   L"Settings for ", L" of ", L" have been deleted.", --18 & 19 & 20

					   L"Your settings have been reset.", --21

					   L"~~Nothing~~", --22

					   L"Items sold: ", --23
					   L"You have earned ", --24

					   L"Left Click - Sell Junk", --25
					   L"Right Click - Options Window",  --26
					   
					   L"Junk Dump Commands: /junkdump command [values]", --27
					   L"exceptions [list|del] [Item#] -- Will list all items in list, or delete specified one.", --28
					   L"additions [list|del] [Item#] -- Will list all items in list, or delete specified one.", --29
					   L"profiles [list|reset|copy|del] [character name] [server name] -- Only copy and del take name and server. Reset resets your current character settings.", --30
					   L"options -- Will open a gui options manager." } --31
}

uiStrings = {
				en = { L"JunkDump Settings",
					   L"Professions",

					   L"Bag-Mode",
					   L"On",
					   L"Off",

					   L"Show Gold Report",
					   L"On",
					   L"Off",

					   L"Show Item Report",
					   L"On",
					   L"Off",

					   L"Sell Talisman Making Items",
					   L"On",
					   L"Off",
					   L"Max Talisman Skill",

					   L"Sell Apothecary Items",
					   L"On",
					   L"Off",
					   L"Max Apothecary Skill",

					   L"Sell Cultivation Items",
					   L"On",
					   L"Off",
					   L"Max Cultivation Skill",

					   L"Sell Salvaging Items",
					   L"On",
					   L"Off",
					   L"Max Salvaging Skill",

					   L"Ignore Rarity for Professions",
					   L"On",
					   L"Off",

					   L"Bag-Mode Bag",

					   L"Rarity",
					   L"Grey",
					   L"White",
					   L"Green",
					   L"Blue",
					   L"Purple",
					   L"Orange",

					   L"Test Settings",
					   L"Clear Test",
					   L"About",
					   L"Professions" }
}
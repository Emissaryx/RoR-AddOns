<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="LibWBToggler" version="0.4" date="9/14/2009" >
		<Author name="Computerpunk" email="teromario@yahoo.com" />
		<Description text="Library for creating WarBoard_Module Toggler" />
		<VersionSettings gameVersion="1.3.3" windowsVersion="1.0" savedVariablesVersion="1.5" />
		<Dependencies>
			<Dependency name="WarBoard" />
		</Dependencies>
		<Files>
			<File name="libs\LibStub.lua" />
			<File name="libs\LibGUI.lua" />
			<File name="libs\LibConfig.lua" />
			<File name="LibWBToggler.lua" />
			<File name="WBTogglerTemplate.xml" />
			<File name="LibWBTogglerManager.lua" />
		</Files>
		<OnInitialize>
			<CallFunction name="LibWBTogglerManager.Initialize" />
		</OnInitialize>
		<SavedVariables>
			<SavedVariable name="LibWBToggler.modsSettings" />
		</SavedVariables>
		<WARInfo>
	<Categories>
		<Category name="DEVELOPMENT" />
	</Categories>
	<Careers>
		<Career name="BLACKGUARD" />
		<Career name="WITCH_ELF" />
		<Career name="DISCIPLE" />
		<Career name="SORCERER" />
		<Career name="IRON_BREAKER" />
		<Career name="SLAYER" />
		<Career name="RUNE_PRIEST" />
		<Career name="ENGINEER" />
		<Career name="BLACK_ORC" />
		<Career name="CHOPPA" />
		<Career name="SHAMAN" />
		<Career name="SQUIG_HERDER" />
		<Career name="WITCH_HUNTER" />
		<Career name="KNIGHT" />
		<Career name="BRIGHT_WIZARD" />
		<Career name="WARRIOR_PRIEST" />
		<Career name="CHOSEN" />
		<Career name= "MARAUDER" />
		<Career name="ZEALOT" />
		<Career name="MAGUS" />
		<Career name="SWORDMASTER" />
		<Career name="SHADOW_WARRIOR" />
		<Career name="WHITE_LION" />
		<Career name="ARCHMAGE" />
	</Careers>
		</WARInfo>
	</UiMod>
</ModuleFile>
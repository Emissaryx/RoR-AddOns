<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="WarBoard" version="5.3.5" date="08/11/2025" >
		<Author name="Computerpunk" email="" />
		<Description text="A board of war." />
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.1" savedVariablesVersion="1.2" />
		<Dependencies>
			<Dependency name="LibSlash" optional="true" />
		</Dependencies>
		<Files>
			<File name="WarBoard.lua" />
			<File name="WarBoard.xml" />
			<File name="WarBoardOptions.xml" />
			<File name="WarBoardOptions.lua" />
		</Files>
		<OnInitialize>
			<CallFunction name="WarBoard.Initialize" />
		</OnInitialize>

		<SavedVariables>
			<SavedVariable name="WarBoardSettings" />
		</SavedVariables>
		<WARInfo>
	<Categories>
		<Category name="OTHER" />
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
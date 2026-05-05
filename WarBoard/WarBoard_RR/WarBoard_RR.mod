<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="WarBoard_RR" version="0.6" date="08/11/2025" >
		<Author name="Snotrocket" email="" />
		<Description text="A Renown module for WarBoard." />
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" />
		<Dependencies>
			<Dependency name="WarBoard" />
		</Dependencies>
		<Files>
			<File name="WarBoard_RR.lua" />
			<File name="WarBoard_RR.xml" />
		</Files>
		<OnInitialize>
			<CallFunction name="WarBoard_RR.Initialize" />
		</OnInitialize>

		<!-- Added: persist toggle across reloads/logins -->
		<SavedVariables>
			<Variable name="WarBoard_RR_Saved" />
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
				<Career name="MARAUDER" />
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
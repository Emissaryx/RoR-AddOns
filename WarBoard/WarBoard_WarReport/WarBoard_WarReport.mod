<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="WarBoard_WarReport" version="1.0.1" date="04/08/2025" >
		<Author name="Psychoxell (Adeptha)" email="" />
		<Description text="War Report Timer for WarBoard" />
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0"/>
		<Dependencies>
			<Dependency name="WarBoard" forceEnable="true" />
		</Dependencies>
		<Files>
			<File name="WarBoard_WarReport.lua" />
			<File name="WarBoard_WarReport.xml" />
		</Files>
		<SavedVariables/>
		<OnInitialize>
			<CallFunction name="WarBoard_WarReport.Initialize" />
		</OnInitialize>
		<OnUpdate>
			<CallFunction name="WarBoard_WarReport.OnUpdate" />
		</OnUpdate>
		<OnShutdown>
			<CallFunction name="WarBoard_WarReport.OnShutdown" />
		</OnShutdown>
		<WARInfo>
			<Categories>
				<Category name="SYSTEM" />
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
<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="Vectors" version="1.00.4" date="03/09/2011" >

		<VersionSettings gameVersion="1.4.1" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="Crestor" email="crestor@web.de" />
		<Description text="Vectors helps UI creators make their work aviable on more resolutions." />

		<Dependencies>
			<Dependency name="EASystem_LayoutEditor" />
			<Dependency name="EA_SettingsWindow" />
		</Dependencies>

		<SavedVariables>
			<SavedVariable name="Vectors.data" />
		</SavedVariables>

		<Files>
			<File name="textures\textures.xml" />
			<File name="Vis.xml" />
			<File name="Settings.xml" />
			<File name="Core.lua" />
			<File name="Dangerous_Windows.lua" />
			<File name="Vis.lua" />
			<File name="Settings.lua" />
			<File name="Fader.lua" />
		</Files>

		<OnInitialize>
				<CallFunction name="Vectors.Initialize" />
				<CallFunction name="Vectors.Settings.Create" />
		</OnInitialize>

		<OnShutdown>
			<CallFunction name="Vectors.Shutdown" />
		</OnShutdown>

		<WARInfo>
			<Categories>
				<Category name="SYSTEM" />
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

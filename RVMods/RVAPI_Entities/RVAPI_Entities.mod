<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

	<UiMod name="RVAPI_Entities" version="0.74" date="07/09/2015" >
		<VersionSettings gameVersion="1.4.0" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="MrAngel" email="" />
		<Description text="Ingame entities API. Every object in the game have its own ID, which is called also EntityID. You can use that addon to retrieve an entities information like name, career, health, level etc." />
		<Dependencies>
			<Dependency name="EASystem_Utils" optional="false" forceEnable="true" />
			<Dependency name="RVAPI_Range" optional="false" forceEnable="true" />
		</Dependencies>

		<SavedVariables>
			<SavedVariable name="RVAPI_Entities.CurrentConfiguration" />
		</SavedVariables>

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
				<Career name="MARAUDER" />
				<Career name="ZEALOT" />
				<Career name="MAGUS" />
				<Career name="SWORDMASTER" />
				<Career name="SHADOW_WARRIOR" />
				<Career name="WHITE_LION" />
				<Career name="ARCHMAGE" />
			</Careers>
		</WARInfo>

		<Files>
			<File name="RVAPI_Entities.lua" />
			<File name="RVAPI_Entities.xml" />
		</Files>

		<OnInitialize>
			<CallFunction name="RVAPI_Entities.Initialize" />
		</OnInitialize>

		<OnUpdate>
			<CallFunction name="RVAPI_Entities.OnUpdate" />
		</OnUpdate>

		<OnShutdown>
			<CallFunction name="RVAPI_Entities.Shutdown" />
		</OnShutdown>
	</UiMod>

</ModuleFile>
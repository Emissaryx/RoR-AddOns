<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

	<UiMod name="RVMOD_Targets" version="1.13" date="07/09/2015" >
		<VersionSettings gameVersion="1.4.0" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="MrAngel" email="" />
		<Description text="Target frames." />
		<Dependencies>
			<Dependency name="EASystem_Utils" optional="false" forceEnable="true" />
			<Dependency name="RVAPI_Entities" optional="false" forceEnable="true" />
			<Dependency name="RVAPI_Frames" optional="false" forceEnable="true" />
		</Dependencies>

		<SavedVariables>
			<SavedVariable name="RVMOD_Targets.CurrentConfiguration" />
		</SavedVariables>

		<WARInfo>
			<Categories>
				<Category name="COMBAT" />
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
			<File name="RVMOD_Targets.lua" />
			<File name="RVMOD_Targets.xml" />
		</Files>

		<OnInitialize>
			<CallFunction name="RVMOD_Targets.Initialize" />
		</OnInitialize>

		<OnUpdate />

		<OnShutdown>
			<CallFunction name="RVMOD_Targets.Shutdown" />
		</OnShutdown>
	</UiMod>

</ModuleFile>
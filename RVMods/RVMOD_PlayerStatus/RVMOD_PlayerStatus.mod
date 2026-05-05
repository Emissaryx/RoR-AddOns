<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

	<UiMod name="RVMOD_PlayerStatus" version="v1.12" date="07/09/2015" >
		<VersionSettings gameVersion="1.4.0" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="MrAngel" email="" />
		<Description text="Showing you health and action bar status. It is highly recommended, but not required to install RV_Mods manager to get access to the addon settings." />
		<Dependencies>
			<Dependency name="RVAPI_ColorDialog" optional="false" forceEnable="true" />
		</Dependencies>

		<Files>
			<File name="RVMOD_PlayerStatus.xml" />
			<File name="RVMOD_PlayerStatus.lua" />
		</Files>

		<SavedVariables>
			<SavedVariable name="RVMOD_PlayerStatus.CurrentConfiguration" />
		</SavedVariables>

		<WARInfo>
			<Categories>
				<Category name="RVR" />
				<Category name="GROUPING" />
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

		<OnInitialize>
			<CallFunction name="RVMOD_PlayerStatus.Initialize" />
		</OnInitialize>

		<OnUpdate />

		<OnShutdown>
			<CallFunction name="RVMOD_PlayerStatus.Shutdown" />
		</OnShutdown>
	</UiMod>

</ModuleFile>
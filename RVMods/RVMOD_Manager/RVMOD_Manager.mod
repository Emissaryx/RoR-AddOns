<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

	<UiMod name="RVMOD_Manager" version="1.11" date="07/09/2015">
		<VersionSettings gameVersion="1.4.0" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="MrAngel" email="" />
		<Description text="Manages addons and provides a GUI to their options." />
		<Dependencies>
			<Dependency name="EATemplate_DefaultWindowSkin" />
			<Dependency name="EA_UiModWindow" />
			<Dependency name="RVAPI_LQuery" optional="false" forceEnable="true" />
		</Dependencies>

		<Files>
			<File name="RVMOD_ManagerTemplates.xml" />
			<File name="RVMOD_ManagerWindow.xml" />
			<File name="RVMOD_ManagerSettingsWindow.xml" />
			<File name="RVMOD_ManagerToggleButtonWindow.xml" />
			<File name="RVMOD_Manager.lua" />
		</Files>

		<SavedVariables>
			<SavedVariable name="RVMOD_Manager.CurrentConfiguration" />
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

		<OnInitialize>
			<CreateWindow name="RVMOD_ManagerToggleButtonWindow" />
			<CreateWindow name="RVMOD_ManagerWindow" />
			<CallFunction name="RVMOD_Manager.Initialize" />
		</OnInitialize>

		<OnUpdate />

		<OnShutdown>
			<CallFunction name="RVMOD_Manager.Shutdown" />
			<DestroyWindow name="RVMOD_ManagerWindow" />
			<DestroyWindow name="RVMOD_ManagerToggleButtonWindow" />
		</OnShutdown>
	</UiMod>
</ModuleFile>
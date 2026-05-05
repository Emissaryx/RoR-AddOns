<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

	<UiMod name="Ace" version="1.2.5" date="2010/12">
		<Author name="ace" email="ace@gmail.com" />
		<Description text="Provides a template for creating addon objects." />
		<VersionSettings gameVersion="1.4.0" windowsVersion="1.0" savedVariablesVersion="1.0" />

		<Dependencies>
			<Dependency name="EA_UiDebugTools" />
			<Dependency name="EA_PlayerMenu" />
			<Dependency name="EASystem_Strings" />
			<Dependency name="EASystem_Utils" />
			<Dependency name="EASystem_TargetInfo" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
        </Dependencies>
		
		<Files>
		
			<File name="LibStub.lua" />
			<File name="AceAddon-3.0.lua" />
			<File name="AceDB-3.0.lua" />
			<File name="AceDBOptions-3.0.lua" />
			<File name="AceLocale-3.0.lua" />
			<File name="AceTimer-3.0.lua" />
			<File name="CallbackHandler-1.0.lua" />
			<File name="LibGUI.lua" />
			
			<File name="LibSharedAssets.lua" />

			<File name="SharedAssets/textures.xml" />
			<File name="SharedAssets/textures.lua" />

		</Files>

		
		<WARInfo>
		    <Categories>
		        <Category name="BUFFS_DEBUFFS" />
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
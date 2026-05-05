<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="JunkDump" version="1.2.2" date="11/15/2018" >

		<Author name="Daegalus" email="yulian@kuncheff.com" />
		<Description text="Instantly sells all your grey items. Configurable to add other items, add exception items, and/or higher rarities." />
		<VersionSettings gameVersion="1.3.1" windowsVersion="1.0" savedVariablesVersion="1.0" />
        <Dependencies>
            <Dependency name="LibSlash" />
			<Dependency name="EATemplate_DefaultWindowSkin" />
			<Dependency name="EASystem_DialogManager" />
			<Dependency name="EASystem_WindowUtils" />
			<Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_Cursor" />
			<Dependency name="EA_ChatWindow" />
			<Dependency name="EA_CharacterWindow" />
			<Dependency name="EA_ContextMenu" />
        </Dependencies>
        
		<Files>
			<File name="JunkDump.lua" />
			<File name="JunkDump.xml" />
			<File name="JunkDumpOptions.lua" />
			<File name="JunkDumpOptions.xml" />
			<File name="JunkDumpLocalization.lua" />
		</Files>
		
		<SavedVariables>
		  <SavedVariable name="JunkDumpSettings" />
		</SavedVariables>
		
		<OnInitialize>
		  <CallFunction name="JunkDump.Initialize" />
		  <CallFunction name="JunkDumpOptions.Initialize" />
		</OnInitialize>
		<OnUpdate/>
		<OnShutdown>
			<CallFunction name="JunkDump.OnShutdown" />
		</OnShutdown>
		<WARInfo>
			<Categories>
				<Category name="ITEMS_INVENTORY" />
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

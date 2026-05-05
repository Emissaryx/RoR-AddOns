<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="BiggerLootBag" version="1.0.0" date="26/11/2024" >
		<Author name="Psychoxell (Adeptha)" email="" />
		<Description text="This module contains the EA Default Loot Windows." />
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0"/>
		<WARInfo>
			<Replaces name="EA_LootWindow" />
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
		<Dependencies>           
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_Cursor" />
            <Dependency name="EA_OpenPartyWindow" />
        </Dependencies>
		<Files>        
            <File name="Source/LootWindow.xml" />
            <File name="Source/ChooseOneLootWindow.xml" />
            <File name="Source/LootRollWindow.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="EA_Window_Loot" show="false" />
            <CreateWindow name="EA_Window_LootRoll" show="false" />
            <CreateWindow name="EA_Window_ChooseOneLoot" show="false" />
		</OnInitialize>   
		<SavedVariables/>
		<OnUpdate/>
		<OnShutdown/>		
	</UiMod>
</ModuleFile>
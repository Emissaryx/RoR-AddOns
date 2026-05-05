<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="AggroMeter" version="1.4" date="03/9/2025">
		<Author name="Sullemunk" />
		<Description text="Displays the current list of Aggro holders on Champions/Heroes/Lords. Made for RoR by Sullemunk(Client) and Hargrim(Server)" />
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<WARInfo>
			<Categories>
		        <Category name="RVR" />
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
		<Dependencies>
            <Dependency name="EATemplate_Icons" />				
            <Dependency name="EASystem_WindowUtils" />			
			<Dependency name="EA_ChatWindow" />
			<Dependency name="EATemplate_UnitFrames" />				
			<Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />            
            <Dependency name="EASystem_LayoutEditor" />
            <Dependency name="EA_Cursor" />
            <Dependency name="EASystem_AdvancedWindowManager" />	
            <Dependency name="ror_PacketHandling" />				
			
		</Dependencies>
		<Files>
			<File name="AggroMeter.lua" />
			<File name="AggroMeter.xml" />		
		</Files>
		<SavedVariables>
			<SavedVariable name="AggroMeter.Settings" global="false"/>
			</SavedVariables>
		<OnInitialize>
			<CallFunction name="AggroMeter.Initialize" />				
		</OnInitialize>
        <OnShutdown>
			<CallFunction name="AggroMeter.Shutdown" />
		</OnShutdown> 		
		<OnUpdate>
			<CallFunction name="AggroMeter.OnUpdate" />	
		</OnUpdate>
	</UiMod>
</ModuleFile>
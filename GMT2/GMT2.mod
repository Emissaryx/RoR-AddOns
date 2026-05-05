<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="GMT2" version="0.7" date="14/06/2020" >
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="Sullemunk"/>
		<Description text="Git Management Tool" />
        <Dependencies>
		    <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_TargetInfo" />
            <Dependency name="EA_ContextMenu" />
			 <Dependency name="EA_ChatWindow" />
			 <Dependency name="EA_ChatSystem" />
			<Dependency name="EA_WorldMapWindow" /> 
			<Dependency name="EA_TargetWindow" /> 	
			<Dependency name="EA_PlayerMenu" />
			<Dependency name="Pure" optional="true" forceEnable="false" />
			
		</Dependencies>
		<Files>
		<File name="Modules/GM_Ticket.xml" />
		<File name="GMT2.lua" />
		<File name="Modules/GMT2.xml" />				
		<File name="Modules/Map.lua" />
		<File name="Modules/GetLog.lua" />	
		<File name="Modules/GetChar.lua" />
		<File name="Modules/ListBuffs.lua" />
		<File name="Modules/GetStats.lua" />			
		<File name="Modules/GM_Ticket.lua" />
		<File name="Modules/Info.lua" />		
		<File name="Modules/findip.lua" />	
		<File name="Modules/GetInventory.lua" />	
		<File name="Modules/findOffip.lua" />	
		
		<File name="Modules/Map.xml" />				
		<File name="Modules/GetLog.xml" />	
		<File name="Modules/GetChar.xml" />
		<File name="Modules/ListBuffs.xml" />
		<File name="Modules/GetStats.xml" />			
		<File name="Modules/Info.xml" />
		<File name="Modules/findip.xml" />
		<File name="Modules/GetInventory.xml" />	
		<File name="Modules/findOffip.xml" />
		
		</Files>
		<OnInitialize>
		<CallFunction name="GMT2.OnInitialize" /> 
		</OnInitialize>
		<OnUpdate>
    	</OnUpdate>
        <OnShutdown>
        </OnShutdown>
		
		
	</UiMod>
</ModuleFile>
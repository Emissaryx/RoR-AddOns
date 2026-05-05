<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="GuardLine" version="1.7" date="13/1/2024">
	<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" /> 
     <Author name="Sullemunk" />
        <Description text="Tether you to a Guard (formely teather) \n Use /GuardLine for options" />
		<Dependencies>
			<Dependency name="EATemplate_Icons"/>
			<Dependency name="LibGuard"/>			
			<Dependency name="LibSlash"/>			
		</Dependencies>
        <Files>
            <File name="GuardLine.lua" />
            <File name="GuardLine.xml" />
        </Files>
		
		<SavedVariables>
        	<SavedVariable name="GuardLine.Settings" />
        </SavedVariables> 
		
        <OnInitialize>
            <CallFunction name="GuardLine.init" />
        </OnInitialize>
        <OnUpdate>
	            <CallFunction name="GuardLine.update" />		
    	  </OnUpdate>
        <OnShutdown />
		<Replaces name="teather" />
    </UiMod>
</ModuleFile>
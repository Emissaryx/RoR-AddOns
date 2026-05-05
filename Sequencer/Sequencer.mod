<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="Sequencer" version="1.0.5" date="13/07/2021" >
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="RoR_Team" email="" />
		<Description text="Sequence Builder" />
		
        <Dependencies>
            <Dependency name="EA_ChatWindow" />
			<Dependency name="EA_ActionBars" />
			
        </Dependencies>
        
        <SavedVariables>
        </SavedVariables>
        
		<Files>
			<File name="Sequencer.lua" />
			<File name="Sequencer.xml" />
		</Files>
		
		<OnInitialize>
            <CallFunction name="Sequencer.OnInitialize" />
		</OnInitialize>

		
	</UiMod>
</ModuleFile>

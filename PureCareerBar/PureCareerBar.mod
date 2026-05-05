<? version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >
	<UiMod name="Pure Careerbar" version="1.0.1" date="2009/08">
		<Author name="smurfy" email="" />
		<Description text="Pure Templates - Additional Template for Pure with a Careervar" />
		<VersionSettings gameVersion="1.3.1" windowsVersion="1.0" savedVariablesVersion="1.0" />
		
		<Dependencies>
			<Dependency name="Pure" />
        </Dependencies>
        
        <Files>
        	<File name="Libraries/LibStub.lua" />
			<File name="Libraries/LibGUI.lua" />
			<File name="Libraries/CallbackHandler-1.0.lua" />
			<File name="Libraries/AceLocale-3.0.lua" />
			<File name="Libraries/AceDB-3.0.lua" />
			<File name="Libraries/AceDBOptions-3.0.lua" />
			<File name="Libraries/LibSharedAssets.lua" />
			
        	<File name="Localization/enUS.lua" />
        
        	<File name="PureCareerBar_Default.xml" />
			<File name="PureCareerBar_Free.xml" />
			
			<File name="PureConfig_CareerBar.lua" />
			
        	<File name="PurePlayer_UnitFrame_CareerBar.lua" />
			<File name="PureCareerBar.lua" />
		</Files>
		
		<OnInitialize>
			<CallFunction name="PureCareerBar.OnInitialize" />
		</OnInitialize>
		
		<OnUpdate>
            <CallFunction name="PureConfig_Careerbar_OnUpdate" />
        </OnUpdate>        
	</UiMod>
</ModuleFile>
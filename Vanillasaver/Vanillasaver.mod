<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="Vanillasaver" version="1.07" date="18/09/2024" >
		<Author name="Talladego, SWF" email="" />
		<Description text="Vanillasaver" />
		<VersionSettings gameVersion="1.9.9" windowsVersion="1.0" savedVariablesVersion="1.0" />

		<Dependencies>
			<Dependency name="EA_ActionBars" />
			<Dependency name="LibSlash" />
		</Dependencies>
			
		<Files>
			<File name="libs\LibStub.lua" />
			<File name="libs\LibGUI.lua" />
			<File name="libs\LibConfig.lua" />		
			<File name="Vanillasaver.lua" />			
			<File name="Vanillasaver_Config.lua" />						
		</Files>

		<SavedVariables>
			<SavedVariable name="Vanillasaver.Settings" />
		</SavedVariables>

		<OnInitialize>
			<CallFunction name="Vanillasaver.Initialize" />
		</OnInitialize>

		<OnUpdate>
			<CallFunction name="Vanillasaver.OnUpdate" />
		</OnUpdate>

		<OnShutdown>
			<CallFunction name="Vanillasaver.OnShutdown" />
		</OnShutdown>
	</UiMod>
</ModuleFile>

<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="LibSkillicon" version="1.0" date="17/11/2024">
		<Author name="SilverWF" email="silverwf@gmail.com"/>
		<Description text="Skill Icons Library<br>Developed by SilverWF"/>
		<VersionSettings gameVersion="1.9.9" windowsVersion="1.0" savedVariablesVersion="1.0"/>
		<Dependencies>
			<Dependency name="EA_ChatWindow"/>
		</Dependencies>
		<Files>
			<File name="Source/LibSkillicon.lua"/>
		</Files>
		<OnInitialize>
			<CallFunction name="LibSkillicon.Init"/>
		</OnInitialize>
		<OnUpdate>
		</OnUpdate>
		<OnShutdown>
		</OnShutdown>
		<SavedVariables>
		</SavedVariables>
	</UiMod>
</ModuleFile>

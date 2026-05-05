<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="wbLeadHelper" version="1.0.8" date="04/17/2026">
		<Author name="provide" />
		<Description text="Helps warband leaders to communicate with their warband members. Run /wlh command for instructions." />
		<VersionSettings gameVersion="1.4.8" windowsVersion="0.1" savedVariablesVersion="1.0" />
		<Dependencies>
			<Dependency name="LibSlash" optional="false" forceEnable="true" />
		</Dependencies>
		<Files>
			<File name="wbLeadHelperConstants.lua" />

			<File name="config/wbLeadHelperCommon.xml" />
			<File name="config/wbLeadHelperChooseIcon.lua" />
			<File name="config/wbLeadHelperChooseIcon.xml" />			
			<File name="config/wbLeadHelperMessagesTab.lua" />
			<File name="config/wbLeadHelperMessagesTab.xml" />
			<File name="config/wbLeadHelperConfigTab.lua" />
			<File name="config/wbLeadHelperConfigTab.xml" />
			<File name="config/wbLeadHelperConfigWindow.lua" />
			<File name="config/wbLeadHelperConfigWindow.xml" />
			<File name="config/wbLeadHelperMessage.lua" />
			<File name="config/wbLeadHelperMessage.xml" />

			<File name="wbLeadHelper.lua" />
			<File name="wbLeadHelper.xml" />
		</Files>
		<SavedVariables>
			<SavedVariable name="wbLeadHelper.Settings" />
		</SavedVariables>
		<OnInitialize>
			<CallFunction name="wbLeadHelper.OnInitialize" />
			<CreateWindow name="wbLeadHelperConfigWindow" show="false"/>
		</OnInitialize>
		<OnUpdate>
			<CallFunction name="wbLeadHelper.timerUpdate" />
		</OnUpdate>
		<OnShutdown>
			<CallFunction name="wbLeadHelper.OnShutdown" />
		</OnShutdown>
		<WARInfo>
			<Categories>
				<Category name="RVR" />
			</Categories>
		</WARInfo>
	</UiMod>
</ModuleFile>

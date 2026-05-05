<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="DevHelper" version="0.1.0" date="03/09/2024">
		<Author name="Emissary" />
		<Description text="Helps developers with simple tasks. Run /devh command for instructions." />
		<VersionSettings gameVersion="1.4.8" windowsVersion="0.1" />
		<Dependencies>
			<Dependency name="LibSlash" optional="false" forceEnable="true" />
		</Dependencies>
		<Files>
			<File name="DevHelperConstants.lua" />

			<File name="config/DevHelperCommon.xml" />
			<File name="config/DevHelperChooseIcon.lua" />
			<File name="config/DevHelperChooseIcon.xml" />			
			<File name="config/DevHelperMessagesTab.lua" />
			<File name="config/DevHelperMessagesTab.xml" />
			<File name="config/DevHelperConfigTab.lua" />
			<File name="config/DevHelperConfigTab.xml" />
			<File name="config/DevHelperConfigWindow.lua" />
			<File name="config/DevHelperConfigWindow.xml" />
			<File name="config/DevHelperMessage.lua" />
			<File name="config/DevHelperMessage.xml" />

			<File name="DevHelper.lua" />
			<File name="DevHelper.xml" />
		</Files>
		<SavedVariables>
			<SavedVariable name="DevHelper.Settings" global="true"/>
		</SavedVariables>
		<OnInitialize>
			<CallFunction name="DevHelper.OnInitialize" />
			<CreateWindow name="DevHelperConfigWindow" show="false"/>
		</OnInitialize>
		<OnUpdate>
			<CallFunction name="DevHelper.timerUpdate" />
		</OnUpdate>
		<OnShutdown>
			<CallFunction name="DevHelper.OnShutdown" />
		</OnShutdown>
		<WARInfo>
			<Categories>
				<Category name="RVR" />
			</Categories>
		</WARInfo>
	</UiMod>
</ModuleFile>

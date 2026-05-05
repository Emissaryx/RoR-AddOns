<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="TurretRange" version="1.1.0" date="03/07/2017" >
		<Author name="Healix,Sullemunk" email="" />
		<Description text="Displays the distance to your turret/daemon. Updated By Sullemunk for RoR" />
		<VersionSettings gameVersion="1.3.6" windowsVersion="1.0" savedVariablesVersion="1.0" />
		
		<Dependencies>
		</Dependencies>
		
		<Files>
			<File name="Localization.lua" />
			<File name="Localization/enUS.lua" />
			<File name="Core.lua" />
			<File name="Display.lua" />
			<File name="Display.xml" />
			<File name="Setup/Setup.lua" />
			<File name="Setup/SetupMenu.xml" />
			<File name="Setup/SetupDistances.lua" />
			<File name="Setup/SetupDistances.xml" />
			<File name="Setup/SetupDistance.lua" />
			<File name="Setup/SetupDistance.xml" />
			<File name="Setup/SetupDisplay.lua" />
			<File name="Setup/SetupDisplay.xml" />
			<File name="Setup/SetupGeneral.lua" />
			<File name="Setup/SetupGeneral.xml" />
		</Files>
		
		<SavedVariables>
			<SavedVariable name="TurretRange.Settings" />
		</SavedVariables>
		
		<OnInitialize>
			<CreateWindow name="TurretRangeSetupMenuWindow" show="false" />
			<CreateWindow name="TurretRangeSetupDistancesWindow" show="false" />
			<CreateWindow name="TurretRangeSetupDistanceWindow" show="false" />
			<CreateWindow name="TurretRangeSetupDisplayWindow" show="false" />
			<CreateWindow name="TurretRangeSetupGeneralWindow" show="false" />
			<CreateWindow name="TurretRangeDisplay" show="false" />
			<CallFunction name="TurretRange.Initialize" />
		</OnInitialize>
		<OnUpdate>
			<CallFunction name="TurretRange.OnUpdate" />
		</OnUpdate>
		<OnShutdown>
		</OnShutdown>
	</UiMod>
</ModuleFile>

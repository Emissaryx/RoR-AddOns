<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<UiMod name="Targets" version="1.00" date="05/01/2026">
	<Author name="Differential,Eowoyn and Emissary" email="emissary@returnofreckoning.com"/>
	<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0"/>
	<Description text="Player target helper"/>

	<Dependencies>
		<Dependency name="LibSlash"/>
		<Dependency name="EASystem_Strings"/>
		<Dependency name="EASystem_Utils"/>
		<Dependency name="EASystem_TargetInfo"/>
		<Dependency name="EASystem_LayoutEditor"/>
	</Dependencies>

	<Files>
		<File name="TargetList.lua"/>
		<File name="TargetsSlashCmd.lua"/>
		<File name="TargetsUnitFrame.lua"/>
		<File name="TargetsWindow.xml"/>
		<File name="Targets.lua"/>
	</Files>

	<OnInitialize>
		<CreateWindow name="TargetsAnchor"/>
		<CallFunction name="Targets.init"/>
	</OnInitialize>

	<SavedVariables>
		<SavedVariable name="Targets.saved"/>
	</SavedVariables>

	<OnUpdate>
		<CallFunction name="Targets.update"/>
	</OnUpdate>

	<OnShutdown/>


	<WARInfo>
			<Categories>
				<Category name="RVR" />
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
				<Career name= "MARAUDER" />
				<Career name="ZEALOT" />
				<Career name="MAGUS" />
				<Career name="SWORDMASTER" />
				<Career name="SHADOW_WARRIOR" />
				<Career name="WHITE_LION" />
				<Career name="ARCHMAGE" />
			</Careers>
	</WARInfo>
</UiMod>
</ModuleFile>
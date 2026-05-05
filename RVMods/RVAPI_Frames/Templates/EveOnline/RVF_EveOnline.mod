<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

	<UiMod name="RVF_EveOnline" version="1.14" date="07/09/2015" >
		<VersionSettings gameVersion="1.4.0" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="MrAngel" email="" />
		<Description text="Eve Online style template. Recommended for single targets." />
		<Dependencies>
			<Dependency name="EATemplate_UnitFrames" optional="false" forceEnable="true" />
			<Dependency name="RVAPI_ColorDialog" optional="false" forceEnable="true" />
			<Dependency name="RVAPI_Range" optional="false" forceEnable="true" />
			<Dependency name="RVAPI_Frames" optional="false" forceEnable="true" />
		</Dependencies>

		<SavedVariables />

		<WARInfo>
			<Categories>
				<Category name="SYSTEM" />
				<Category name="DEVELOPMENT" />
				<Category name="OTHER" />
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
				<Career name="MARAUDER" />
				<Career name="ZEALOT" />
				<Career name="MAGUS" />
				<Career name="SWORDMASTER" />
				<Career name="SHADOW_WARRIOR" />
				<Career name="WHITE_LION" />
				<Career name="ARCHMAGE" />
			</Careers>
		</WARInfo>

		<Files>
			<File name="CustomBuffFrame.lua" />
			<File name="RVF_EveOnline.lua" />
			<File name="RVF_EveOnline.xml" />
		</Files>

		<OnInitialize>
			<CallFunction name="RVF_EveOnline.Initialize" />
		</OnInitialize>

		<OnUpdate />

		<OnShutdown>
			<CallFunction name="RVF_EveOnline.Shutdown" />
		</OnShutdown>
	</UiMod>

</ModuleFile>
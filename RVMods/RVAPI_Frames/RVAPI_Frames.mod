<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

	<UiMod name="RVAPI_Frames" version="1.05" date="07/09/2015" >
		<VersionSettings gameVersion="1.4.0" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="MrAngel" email="" />
		<Description text="On screen frames API. This addon allow you easily create your own frames and attach them to any object (EntityID) in the game." />
		<Dependencies>
			<Dependency name="RVAPI_Entities" optional="false" forceEnable="true" />
		</Dependencies>

		<SavedVariables>
			<SavedVariable name="RVAPI_Frames.CurrentConfiguration" />
		</SavedVariables>

		<WARInfo>
			<Categories>
				<Category name="SYSTEM" />
				<Category name="DEVELOPMENT" />
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
			<File name="RVAPI_Frame.lua" />
			<File name="RVAPI_Frame.xml" />
			<File name="RVAPI_Frames.lua" />
			<File name="RVAPI_Frames.xml" />
		</Files>

		<OnInitialize>
			<CallFunction name="RVAPI_Frames.Initialize" />
		</OnInitialize>

		<OnUpdate />

		<OnShutdown>
			<CallFunction name="RVAPI_Frames.Shutdown" />
		</OnShutdown>
	</UiMod>

</ModuleFile>
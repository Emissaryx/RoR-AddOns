<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

	<UiMod name="RVAPI_LQuery" version="0.02" date="07/09/2015" >
		<VersionSettings gameVersion="1.4.0" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Author name="MrAngel" email="" />
		<Description text="LQuery API. Provides a set of animation functions." />

		<Dependencies />

		<SavedVariables>
			<SavedVariable name="RVAPI_LQuery.CurrentConfiguration" />
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
			<File name="RVAPI_LQuery.lua" />
			<File name="RVAPI_LQuery.xml" />
		</Files>

		<OnInitialize>
			<CallFunction name="RVAPI_LQuery.Initialize" />
		</OnInitialize>

		<OnUpdate>
			<CallFunction name="RVAPI_LQuery.OnUpdate" />
		</OnUpdate>

		<OnShutdown>
			<CallFunction name="RVAPI_LQuery.Shutdown" />
		</OnShutdown>
	</UiMod>

</ModuleFile>
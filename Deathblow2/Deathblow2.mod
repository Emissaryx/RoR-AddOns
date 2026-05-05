<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="Deathblow2" version="2.1" date="1/3/2026">
		<Author name="Sullemunk" email="" />
		<Description text="Notifies you and announces killing blows, and keeps track of Kill/death scores.  Made for RoR by Sullemunk" />
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<WARInfo>
			<Categories>
		        <Category name="RVR" />
		        <Category name="COMBAT" />
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
		<Dependencies>
    		<Dependency name="LibSlash" optional="false" forceEnable="true" />
		</Dependencies>
		<Files>
				<File name="Deathblow2.lua" />
				<File name="Deathblow2.xml" />


				</Files>
		<SavedVariables>
			<SavedVariable name="Deathblow.SavedSettings" global="true"/>
			<SavedVariable name="BlowDeath.SavedSettings" global="true"/>
			<SavedVariable name="DBSETTINGS" global="true"/>
			</SavedVariables>
		<OnInitialize>
				<CallFunction name="Deathblow.Initialize" />
				<CreateWindow name="DeathblowMenuButton" show="true" />	
	</OnInitialize>
		<OnUpdate />
		<OnShutdown />

	</UiMod>
</ModuleFile>
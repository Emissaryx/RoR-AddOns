<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="AssignBearerFix" version="1.0.0" date="04/07/2025" >
		<Author name="Psychoxell (Adeptha)" email="" />
		<Description text="Fix for assign bearer. If there is no spot left this addon will unassign bearer form offline players." />
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0"/>
		<Dependencies/>
		<Files>
			<File name="AssignBearerFix.lua" />
		</Files>
		<SavedVariables/>
		<OnInitialize>
			<CallFunction name="AssignBearerFix.Initialize" />
		</OnInitialize>
		<OnUpdate>
			<CallFunction name="AssignBearerFix.OnUpdate" />
		</OnUpdate>
		<OnShutdown>
			<CallFunction name="AssignBearerFix.OnShutdown" />
		</OnShutdown>
		<WARInfo>
			<Categories>
				<Category name="SYSTEM" />
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
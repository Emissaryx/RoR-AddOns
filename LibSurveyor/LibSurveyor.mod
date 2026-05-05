<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="LibSurveyor" version="1.2.4" date="12/02/2025" >
		<Author name="Ninjas" email="" />
		<Description text="Mapping library and data store. Never get lost again!" />


		<VersionSettings gameVersion="1.4.8"/>
		
		<Files>
			<File name="LibStub.lua"/>
			<File name="LibSurveyor.lua"/>
			
			<File name="Classes\Display.lua"/>
			<File name="Classes\Pin.lua"/>
			<File name="Classes\PinType.lua"/>
			<File name="Classes\Point.lua"/>
			
			<File name="Database.lua"/>
			<File name="PlayerLocation.lua"/>
			
			<File name="Data\ZoneOffsets.lua"/>
			
			<File name="Windows.xml"/>
		</Files>
		
		<SavedVariables>
			<SavedVariable name="LibSurveyorDB"/>
		</SavedVariables>
		
		<OnInitialize>
			<CallFunction name="LibSurveyor_1.ValidateDB"/>
			<CallFunction name="LibSurveyor_1.OnInitialize"/>
		</OnInitialize>

	   <WARInfo>
	     <Categories>
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
<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="PlanB" version="2.5.0" date="01/10/2026" >
        
		<Author name="FuriousGuy / Dorgudurk / Randomage / Emissary" email="emissary@returnofreckoning.com" />
		<Description text="A hotbar mod for Swordmasters and Black Orcs that automatically switches hotbar pages when the Plan or Balance state changes."/>
        <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Dependencies>
			<Dependency name="EA_ChatWindow"/>
			<Dependency name="EA_CareerResourcesWindow"/>
			<Dependency name="EA_ActionBars"/>
			<Dependency name="LibSlash"/>
		</Dependencies>
        
		<Files>
			<File name="PlanB.lua"/>
		</Files>
        
		<OnInitialize>
			<CallFunction name="PlanB.Initialize"/>
		</OnInitialize>

		<OnUpdate/>
		
		<OnShutdown/>

		<SavedVariables>
			<SavedVariable name="PlanB.data"/>
		</SavedVariables>
	</UiMod>
</ModuleFile>

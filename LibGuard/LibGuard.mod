<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="LibGuard" version="1.7" date="13/01/2024" >
        
		<Author name="Sullemunk" email="" />
		<Description text="Standard Guard Library"/>
        <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Dependencies>
			<Dependency name="EA_ChatWindow"/>
			<Dependency name="EA_ActionBars"/>			
			<Dependency name="LibSlash"/>
			<Dependency name="ror_PacketHandling"/>		
		</Dependencies>
        
		<Files>
			<File name="Source/LibGuard.lua"/>		
		</Files>
        
		<OnInitialize>
			<CallFunction name="LibGuard.Init"/>
		</OnInitialize>

		<OnUpdate>
				</OnUpdate>	
		<OnShutdown>
			<CallFunction name="LibGuard.OnShutdown"/>
		 </OnShutdown>
		<SavedVariables>
			<SavedVariable name="LibGuard.UsePet"/>	
		</SavedVariables>
	</UiMod>
</ModuleFile>

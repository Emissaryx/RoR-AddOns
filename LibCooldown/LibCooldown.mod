<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="LibCooldown" version="0.31" date="02/02/2009" >

		<Author name="Vidhar" email="-" />
		<Description text="Library for Ability and Item Cooldowns." />
		
    <Dependencies>
        <Dependency name="EASystem_LayoutEditor" />
        <Dependency name="EA_ChatWindow" />
        <Dependency name="EA_UiModWindow" />
    </Dependencies>
        
		<Files>
			<File name="LibCooldown.lua" />
		</Files>
		
		<OnInitialize>
			<CallFunction name="LibCooldown.Initialize" />
		</OnInitialize>
		<OnUpdate>
            <CallFunction name="LibCooldown.OnUpdate" />
        </OnUpdate>
		<OnShutdown/>
		
	</UiMod>
</ModuleFile>

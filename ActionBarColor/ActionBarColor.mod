<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="ActionBarColor" version="1.3" date="17/08/2025" >

		<Author name="Aiiane" email="aiiane@aiiane.net" />
		<Description text="Makes buttons turn red when the target is out of range or line of sight." />
		
        <Dependencies>
            <Dependency name="EA_ActionBars" />
            <Dependency name="EA_MoraleWindow" />
        </Dependencies>
        
		<Files>
			<File name="ActionBarColor.lua" />
		</Files>
		
		<OnInitialize>
            <CallFunction name="ActionBarColor.Initialize" />
		</OnInitialize>
		
	</UiMod>
</ModuleFile>

<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile>
    <UiMod name="Pocket Palette" version="2.1.2" date="04/04/2026" >
        
        <Author name="Eibon (creator), Zomega (maintainer), Emissary (maintainer)" email="emissary@returnofreckoning.com" />

        <Description text="Pocket Palette inspired by DyePreview. Show the Pocket Palette window using the chat command /PP" />
        
        <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="2.1.2" />

        <Dependencies>
            <Dependency name="EA_AbilitiesWindow" />
            <Dependency name="EA_CareerResourcesWindow" />
            <Dependency name="EA_MoraleWindow" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EATemplate_Icons" />
            <Dependency name="EA_CharacterWindow" />
            <Dependency name="LibSlash" />
        </Dependencies>

        <Files>
            <File name="PocketPalette.lua" />
			      <File name="PocketPalette.xml" />
            <File name="PocketPalette.csv" />
        </Files>
        
        <OnInitialize>
            <CallFunction name="PP.Initialize" />
        </OnInitialize>

        <OnShutdown />
        <OnUpdate />

        <SavedVariables>
			<SavedVariable name="PP.settings.persistent" global="false" />
            <SavedVariable name="PP.settings.itemsPersist" global="false" />
		</SavedVariables>

    </UiMod>
</ModuleFile>

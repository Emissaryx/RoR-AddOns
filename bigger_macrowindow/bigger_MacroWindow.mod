<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="bigger_MacroWindow" version="1.30" date="01/31/2026" >
        <Replaces name="EA_MacroWindow" />
        <Author name="EAMythic | changes by Emissary" email="emissary@returnofreckoning.com" />
        <VersionSettings gameVersion="1.4.8" windowsVersion="1.0.0" savedVariablesVersion="1.30" />
        <Description text="This module contains the (bigger) Macros window." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
        </Dependencies>
        <Files>
            <File name="Source/MacroWindow.xml" />
			<File name="Source/MacroIcons.xml"/>
            <!-- <File name="Source/MacroWindow.lua" /> -->
        </Files>
        <OnInitialize>
            <CreateWindow name="MacroIconSelectionWindow" show="false" />
            <CreateWindow name="EA_Window_Macro" show="false" />
        </OnInitialize>
    </UiMod>

</ModuleFile>

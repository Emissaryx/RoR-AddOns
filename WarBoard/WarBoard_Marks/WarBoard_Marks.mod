<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="WarBoard_Marks" version="0.5.1" date="03/19/2026">

        <Author name="Lizardry and Ninjas" email="xxx@xxx.com" />
        <Description text="A session Marks tracker mod for WarBoard." />
        <VersionSettings gameVersion="1.4.8" />

        <Dependencies>
            <Dependency name="WarBoard" />
        </Dependencies>

        <Files>
            <File name="WarBoard_Marks.lua" />
            <File name="WarBoard_Marks.xml" />
        </Files>

        <SavedVariables>
            <SavedVariable name="WarBoard_Marks_Settings" />
        </SavedVariables>

        <OnInitialize>
            <CallFunction name="WarBoard_Marks.Initialize" />
        </OnInitialize>

        <OnUpdate />
        <OnShutdown />
    </UiMod>
</ModuleFile>
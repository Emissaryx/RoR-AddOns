<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <UiMod name="HealAll" version="1.1" date="01/19/2026">
        <Author name="Gobbo (updated by Emissary)" email="emissary@returnofreckoning.com" />
        <Description text="Automatically removes all penalties when interacting with a healer." />

        <Dependencies>
            <Dependency name="EA_InteractionWindow" />
        </Dependencies>

        <Files>
            <File name="HealAll.lua"/>
        </Files>

        <OnInitialize>
            <CallFunction name="HealAll.Initialize" />
        </OnInitialize>

        <OnShutdown />

    </UiMod>
</ModuleFile>

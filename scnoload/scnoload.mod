<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <UiMod name="scnoload" version="1.5" date="2026-01-10">
        <Author name="phorbs and Emissary" />
        <Description text="Suppresses the loading screen while you respawn in scenarios." />

        <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />

        <Dependencies>
            <Dependency name="LibSlash" />
            <Dependency name="EA_LoadingScreen" />
            <Dependency name="EA_ScenarioSummaryWindow" />
        </Dependencies>

        <WARInfo>
            <Categories>
                <Category name="RVR" />
                <Category name="OTHER" />
            </Categories>
        </WARInfo>

        <Files>
            <File name="scnoload.lua" />
        </Files>

        <OnInitialize>
            <CallFunction name="scnoload.Initialize" />
        </OnInitialize>

        <SavedVariables>
            <SavedVariable name="scnoload.Settings" />
        </SavedVariables>

    </UiMod>

</ModuleFile>

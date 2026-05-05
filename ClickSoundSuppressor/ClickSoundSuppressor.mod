<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <UiMod name="ClickSoundSuppressor" version="1.10" date="2026-01-10">

    <Author name="TVBrowntown and renamed by Emissary" email="emissary@returnofreckoning.com" />
    <Description text="Disables UI button click sounds." />

    <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />

    <Dependencies>
    </Dependencies>

    <Files>
      <File name="ClickSoundSuppressor.lua" />
    </Files>

    <SavedVariables>
    </SavedVariables>

    <OnInitialize>
      <CallFunction name="ClickSoundSuppressor.OnInit" />
    </OnInitialize>

    <OnUpdate>
    </OnUpdate>

    <OnShutdown>
    </OnShutdown>

  </UiMod>
</ModuleFile>

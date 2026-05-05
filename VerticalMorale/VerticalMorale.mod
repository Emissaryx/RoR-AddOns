<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <UiMod name="VerticalMorale" version="1.0.5" date="2010-06-02">

    <Author name="Reivan" email="" />
    <Description text="Changes the layout of EA_MoraleWindow to vertical." />

    <VersionSettings gameVersion="1.3.5" windowsVersion="1.0" savedVariablesVersion="1.0" />

    <Dependencies>
      <Dependency name="EA_MoraleWindow" />
      <Dependency name="LibSlash" />
    </Dependencies>

    <SavedVariables>
      <SavedVariable name="VerticalMorale.side" />
    </SavedVariables>

    <Files>
      <File name="VerticalMorale.xml" />
      <File name="VerticalMorale.lua" />
    </Files>

    <OnInitialize>
      <CallFunction name="VerticalMorale.Initialize" />
    </OnInitialize>

    <OnShutdown>
      <CallFunction name="VerticalMorale.Shutdown" />
    </OnShutdown>

  </UiMod>
</ModuleFile>

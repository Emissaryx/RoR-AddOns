<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <UiMod name="PetAssist" version="6.3" date="14/11/2024" >
    <Author name="SilverWF / Emissary" email="silverwf@gmail.com" />
    <Description text="Forces Pet to Attack your target at every offensive spell cast and heel at every defensive spell cast.<br>Please read Readme.txt file" />
    <VersionSettings gameVersion="1.4.8" />

    <Dependencies>
      <Dependency name="LibSlash" />
    </Dependencies>

    <Files>
      <File name="PetAssist.lua" />
    </Files>

    <OnInitialize>
      <CallFunction name="PetAssist.Initialize" />
    </OnInitialize>
    <OnUpdate>
      <CallFunction name="PetAssist.OnUpdate" />
    </OnUpdate>

    <WARInfo>
      <Careers>
        <Career name="ENGINEER" />
        <Career name="SQUIG_HERDER" />
        <Career name="MAGUS" />
        <Career name="WHITE_LION" />
      </Careers>
    </WARInfo>
  </UiMod>
</ModuleFile>

<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <UiMod name="StopRes" version="1.0.0" date="09/06/21" >
    <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
    <Author name="xyeppp" email="" />
    <Description text="Stops your ressurects when target has been ressurected." />
    <Dependencies>
      <Dependency name="EA_CastTimerWindow" />
    </Dependencies>
    <Files>
      <File name="StopCore.lua" />
    </Files>
      <OnInitialize>
      <CallFunction name="StopRes.Initialize" />
    </OnInitialize>	
	<OnUpdate>
	<CallFunction name="StopRes.OnTesting" />
	</OnUpdate>
	<OnShutdown>
	<CallFunction name="StopRes.Shutdown" />
	</OnShutdown>
	<SavedVariables>
	<SavedVariable name="StopRes.Settings" />
	</SavedVariables>
    <WARInfo>
    </WARInfo>
  </UiMod>
</ModuleFile>

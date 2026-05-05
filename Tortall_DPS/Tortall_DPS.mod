<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >    
  <UiMod name="Tortall_DPS" version="6.5.0" date="2025-02-01" >    
    <VersionSettings gameVersion="1.9.9" windowsVersion="1.0" savedVariablesVersion="1.0" />          
    <Author name="Tortall" email="" />        
    <Description text="Tortall's DPS Meter - Optimized Version" />        
    <Dependencies>                     
      <Dependency name="EATemplate_DefaultWindowSkin" />            
      <Dependency name="EASystem_Utils" />            
      <Dependency name="EASystem_WindowUtils" />            
      <Dependency name="EASystem_Tooltips" />            
      <Dependency name="EASystem_LayoutEditor" />            
      <Dependency name="TortallDPSCore" />        
    </Dependencies>        
    <Files>            
      <File name="Tortall_DPS.xml" />            
      <File name="Tortall_DPS_Detail.xml" />            
      <File name="Tortall_DPS_Toggle.xml" />        
    </Files>        
    <OnInitialize>            
      <CreateWindow name="TortallDPSToggle" show="true" />            
      <CreateWindow name="TortallDPSMeterGroupWindow" show="false" />            
      <CreateWindow name="TortallDPSMeter" show="false" />        
    </OnInitialize>                      
    <!-- REMOVED: OnUpdate section - now handled internally via RegisterEventHandler -->
    <SavedVariables>            
      <SavedVariable name="TortallDPSMeter.Settings" />        
    </SavedVariables>    
  </UiMod>
</ModuleFile>

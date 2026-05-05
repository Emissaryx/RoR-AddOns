<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >    
  <UiMod name="TortallDPSCore" version="2.3.3" date="05/30/2009" >        
    <Author name="Tortall" email="" />            
    <VersionSettings gameVersion="1.9.9" windowsVersion="1.0" savedVariablesVersion="1.0" />          
    <Description text="Tortall's DPS Parser." />        
    <Dependencies>                     
      <Dependency name="EA_ChatWindow" />        
    </Dependencies>        
    <Files>            
      <File name="TortallDPSCore.lua" />            
      <File name="TortallDPSCore-ru.lua" />        
    </Files>        
    <OnInitialize>            
      <CallFunction name="TortallDPSCore.Initialize" />        
    </OnInitialize>                      
    <OnShutdown>            
      <CallFunction name="TortallDPSCore.Shutdown" />        
    </OnShutdown>        
    <SavedVariables>            
      <SavedVariable name="TortallDPSCore.SavedState" />        
    </SavedVariables>    
  </UiMod>     
</ModuleFile>
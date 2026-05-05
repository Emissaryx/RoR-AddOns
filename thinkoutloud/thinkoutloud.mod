<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">   
  <UiMod name="ThinkOutLoud" version="1.3.4" date="2025-12-07" >
    <Author name="thanners" email="thanners@ninjasaurus.net" />
    <Description text="Offers various options for announcing when you use abilities. Few templates added by SilverWF. Fixes and Improvements by Idrinth and Ninjas." />      
    <VersionSettings gameVersion="1.4.8" />      
    <Dependencies>         
      <Dependency name="EA_ChatWindow" />
      <Dependency name="LibSlash" />
      <Dependency name="AutoChannel" />
    </Dependencies>             
    <Files>         
      <File name="thinkoutloud.lua" />         
      <File name="tolset.lua" />         
      <File name="tolskill.lua" />         
      <File name="config.lua" />         
      <File name="tolsettingsui.xml" />         
      <File name="tolsettingsui.lua" />      
    </Files>      
    <SavedVariables>         
      <SavedVariable name="ThinkOutLoud.PersistentSettings" />      
    </SavedVariables>             
    <OnInitialize>         
      <CallFunction name="ThinkOutLoud.Initialize" />      
    </OnInitialize>      
    <OnUpdate>         
      <CallFunction name="ThinkOutLoud.Update" />      
    </OnUpdate>      
    <OnShutdown>         
      <CallFunction name="ThinkOutLoud.Shutdown" />      
    </OnShutdown>          
  </UiMod>
</ModuleFile>
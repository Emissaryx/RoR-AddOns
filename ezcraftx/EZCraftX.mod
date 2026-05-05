<? version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >	
  <UiMod name="EZCraftX" version="1.1.8" date="2009/07/25">		
    <Author name="Iphitos" email="iphitos@war-rdu.de" />		
    <Description text="EZCraft Xtended - now in color" />		
    <VersionSettings gameVersion="1.9.9" windowsVersion="1.1" savedVariablesVersion="1.1" />    
    <Dependencies>      
      <Dependency name="EATemplate_DefaultWindowSkin" />    	
      <Dependency name="EA_ChatWindow" />			
      <Dependency name="EA_BackpackWindow" />			
      <Dependency name="EA_CraftingSystem" />      
      <Dependency name="LibSlash" />    
    </Dependencies>		
    <Files>			
      <File name="Libraries/LibStub.lua" />			
      <File name="Libraries/LibGUI.lua" />			
      <File name="Libraries/AceLocale-3.0.lua" />			
      <File name="Localization/enUS.lua" />			
      <File name="Localization/deDE.lua" />			
      <File name="Localization/itIT.lua" />			
      <File name="Localization/ruRU.lua" />			
      <File name="Source/EZCraftX.lua" />			
      <File name="Source/EZCraftX.xml" />			
      <File name="Source/EZCraftX_Templates.xml" />		
    </Files>		     
    <SavedVariables>      
      <SavedVariable name="EZCraftX.options" />    
    </SavedVariables>		
    <OnInitialize>			
      <CreateWindow name="EZCraftXWindow" show="false" />			
      <CallFunction name="EZCraftX.OnInitialize" />		
    </OnInitialize>	
  </UiMod>
</ModuleFile>
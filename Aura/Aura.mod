<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >
	<UiMod name="Aura" version="2.8.2" date="2021/05" >
		<Author name="Wikki" email="wikkifizzle@gmail.com" />
		<Description text="Aura - A customizable event notification system." />
		<VersionSettings gameVersion="1.4.0" windowsVersion="1.0" savedVariablesVersion="1.0" />
		<Dependencies>
			<Dependency name="EA_AbilitiesWindow" />
			<Dependency name="EA_CareerResourcesWindow" />
			<Dependency name="EA_MoraleWindow" />
			<Dependency name="EA_GuildWindow" />
			<Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
			<Dependency name="EATemplate_Icons" />
			<Dependency name="LibSlash" />
		</Dependencies>
		<Files>
			<File name="Source/TargetInfoFix.lua" />
			
			<File name="Libraries/LibStub.lua" />
			<File name="Libraries/AceLocale-3.0.lua" />
			<File name="Libraries/LibPickle.lua" />
			
			<File name="Localization/deDE.lua" />
			<File name="Localization/enUS.lua" />
			<File name="Localization/esES.lua" />
			<File name="Localization/frFR.lua" />
			<File name="Localization/itIT.lua" />
			<File name="Localization/jaJP.lua" />
			<File name="Localization/koKR.lua" />
			<File name="Localization/ruRU.lua" />
			<File name="Localization/zhCN.lua" />
			<File name="Localization/zhTW.lua" />
			
			<File name="Source/Templates.xml" />
			<File name="Source/AuraConstants.lua" />
			<File name="Source/AuraEffectTracker.lua" />
			<File name="Source/AuraProfile.lua" />
			<File name="Source/AuraShares.xml" />
			<File name="Source/AuraShares.lua" />
			<File name="Source/AuraHelpers.lua" />
			<File name="Assets/AuraTextures.xml" />
			<File name="Assets/AuraTextures.lua" />
			<File name="Assets/AuraCustomTextures.xml" />
			<File name="Assets/AuraCustomTextures.lua" />
			<File name="Source/AuraColorPicker.xml" />
			<File name="Source/AuraTooltip.xml" />
			<File name="Source/AuraTooltip.lua" />
			<File name="Source/AuraTexture.xml" />
			<File name="Source/AuraTexture.lua" />
			<File name="Source/AuraAddon.lua" />
			<File name="Source/Aura.lua" />
			<File name="Source/AuraSettings.xml" />
			<File name="Source/AuraConfig.xml" />
			<File name="Source/AuraEngine.lua" />
		</Files>
		<OnInitialize>
			<CallFunction name="AuraAddon.OnInitialize" />
			<CreateWindow name="AuraTexture" show="false" />
			<CreateWindow name="AuraColorPicker" show="false" />
			<CreateWindow name="AuraConfig" show="false" />
			<CreateWindow name="AuraShares" show="false" />
			<CreateWindow name="AuraSettings" show="false" />
			<CallFunction name="AuraTooltip.OnInitialize"/>
		</OnInitialize>
		<OnUpdate>
			<CallFunction name="AuraEngine.Event_UPDATE_PROCESSED"/>
		</OnUpdate>
		<OnShutdown>
			<CallFunction name="AuraSettings.OnShutdown" />        
            <CallFunction name="AuraAddon.OnShutdown" />        
        </OnShutdown> 
        
        <WARInfo>
		    <Categories>
		        <Category name="ACTION_BARS" />
		        <Category name="BUFFS_DEBUFFS" />
		        <Category name="RVR" />
		        <Category name="COMBAT" />
		        <Category name="AUCTION" />
		    </Categories>
		    <Careers>
		        <Career name="BLACKGUARD" />
		        <Career name="WITCH_ELF" />
		        <Career name="DISCIPLE" />
		        <Career name="SORCERER" />
		        <Career name="IRON_BREAKER" />
		        <Career name="SLAYER" />
		        <Career name="RUNE_PRIEST" />
		        <Career name="ENGINEER" />
		        <Career name="BLACK_ORC" />
		        <Career name="CHOPPA" />
		        <Career name="SHAMAN" />
		        <Career name="SQUIG_HERDER" />
		        <Career name="WITCH_HUNTER" />
		        <Career name="KNIGHT" />
		        <Career name="BRIGHT_WIZARD" />
		        <Career name="WARRIOR_PRIEST" />
		        <Career name="CHOSEN" />
		        <Career name= "MARAUDER" />
		        <Career name="ZEALOT" />
		        <Career name="MAGUS" />
		        <Career name="SWORDMASTER" />
		        <Career name="SHADOW_WARRIOR" />
		        <Career name="WHITE_LION" />
		        <Career name="ARCHMAGE" />
		    </Careers>
		</WARInfo>

	</UiMod>
</ModuleFile>

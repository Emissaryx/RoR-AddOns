<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="LibAchievements" version="0.3" date="19/08/2009" >
		<Author name="Tempest" email="icona@gmx.net" />
		<Description text="Simple library to register custom achievement entries in the tome of knowledge." />
    <VersionSettings gameVersion="1.3.1" windowsVersion="1.0" savedVariablesVersion="1.0" />
    <Dependencies>
        <Dependency name="EA_TomeOfKnowledge" />
    </Dependencies>     
		<Files>
			<File name="LibAchievements.lua" />
		</Files>
		<OnInitialize>
			<CallFunction name="LibAchievements.Initialize" />
		</OnInitialize>
		<OnUpdate/>
		<OnShutdown/>
		<WARInfo>
			<Categories>
				<Category name="DEVELOPMENT" />
				<Category name="OTHER" />
			</Categories>
		</WARInfo>
	</UiMod>
</ModuleFile>

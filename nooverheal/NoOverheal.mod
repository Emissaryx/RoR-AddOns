<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<UiMod name="NoOverheal" version="1.40" date="01/19/2026" >
		<Author name="Archivar and Emissary" email="emissary@returnofreckoning.com" />
		<Description text="no overheal" />
		<Dependencies>
			<Dependency name="EA_ChatWindow" />
		</Dependencies>
		<SavedVariables>
			<SavedVariable name="NoOverheal.save" />
		</SavedVariables>
		<Files>
			<File name="no_localization.en.lua" />
			<File name="no_localization.de.lua" />
			<File name="no_SlashHandler.lua" />
			<File name="NoOverheal.lua" />
			<File name="NoOverheal.xml" />
		</Files>
		<OnInitialize>
			<CallFunction name="NoOverheal.OnInitialize" />
		</OnInitialize>
		<OnShutdown>
			<CallFunction name="NoOverheal.OnShutdown" />
		</OnShutdown>
		<OnUpdate>
			<CallFunction name="NoOverheal.OnUpdate" />
		</OnUpdate>

	</UiMod>
</ModuleFile>


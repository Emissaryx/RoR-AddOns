<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="Rangechecker" version="1.02" date="5/07/2017">
        <Author name="SIDR" email="B_KOCMOC@mail.ru" />
        <Description text="Creates a frame that shows distance to enemy target. Some dirty fixes by anon" />
		<Dependencies>
			<Dependency name="LibSlash" />
		</Dependencies>
		<SavedVariables>
            <SavedVariable name="RangecheckerSettings" />
        </SavedVariables>
        <Files>
            <File name="Rangechecker.lua" />
            <File name="Rangechecker.xml" />
        </Files>
        <OnInitialize>
            <CallFunction name="Rangechecker.Initialize" />
        </OnInitialize>
        <OnUpdate />
		<OnShutdown />
    </UiMod>
</ModuleFile>

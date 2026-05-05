<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="HideHiddenFrames" version="1.0" date="1/1/2018">
        <VersionSettings gameVersion="1.4.6" windowsVersion="1.0" savedVariablesVersion="1.0"/>

        <Author name="a" />
        <Description text="Hide hidden frames in layout editor completely. No more gray junk. Make it visible again using 'Windows' button in the middle of the screen."/>

        <Dependencies>
            <Dependency name="EASystem_LayoutEditor"/>
        </Dependencies>

        <Files>
            <File name="HideHiddenFrames.lua" />
        </Files>

        <OnInitialize>            
            <CallFunction name="HideHiddenFrames.Initialize" />
        </OnInitialize>

        <WARInfo>
            <Categories>
                <Category name="INTERFACE" />
            </Categories>
        </WARInfo>

    </UiMod>
</ModuleFile>

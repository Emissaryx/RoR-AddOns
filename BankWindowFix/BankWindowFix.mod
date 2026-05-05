<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="BankWindowFix" version="1.0.1" date="03-Aug-17" >
        <Author name="anon" email="" />
        <Description text="RButton will now put items from bank to bag (originally only worked in other direction); items will attempt to stack when moving from bag to bank and vice versa; items will be put into currently open bank tab and not in the first free slot." />
        <Dependencies>
            <Dependency name="EA_BankWindow" />
             <Dependency name="EA_BackpackWindow" />
        </Dependencies>
        <Files>
            <File name="Source/BankWindowFix.xml" />
            <File name="Source/BankWindowFix.lua" />
        </Files>
        <OnInitialize>
            <CallFunction name="BankWindowFix.Initialize" />
        </OnInitialize>
    </UiMod>

</ModuleFile>

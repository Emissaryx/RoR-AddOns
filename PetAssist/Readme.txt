-- by SilverWF --

* Lightweight and simple addon to handle your pet - that was my main goal while creating this.
* This addon would force your pet to attack your CURRENT target.

-- Commands --
* /pa on - turn on addon
* /pa off - turn it off

* I RECOMMEND you to create an ingame macro with following text:
	/script PetAssist.ChangeState()
	and put it on the hotbar. Pressing on it would toggle the addon ON or OFF and also would force your pet to attack your target or run to you.


-- Features --
* For better work, put your pet to the passive stance - this addon would do that at the every time you log in.
* If you use any offensive skill - your pet would be forced to attack your current hostile target and use his skills
* If you use detaunts (WL and SH), Flee, Run away (SH) or using skill, which name starts with "Summon" (afaik, mounts only) - then pet would be called back to you
* If you use any another skill - your pet will continue do his previous action


-- What is new --
* ver 6.2 - nov 2024
	returned back offensive/defensive/neutral reaction logic
	now pet would not be forced to use his skills if you didn't have hostile tartget
...
* ver 1 - long long time ago at live servers...
	Initial release
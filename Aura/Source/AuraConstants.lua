--[[
	This application is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The applications is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with the applications.  If not, see <http://www.gnu.org/licenses/>.
--]]

if not AuraConstants then AuraConstants = {} end

--[[
	NOTE:  THE ORDER OF THESE ENTRIES MATTER.  ADD NEW ONES TO THE END
--]]
-- Activation Types
AuraConstants.TRIGGER_TYPE_EFFECTS 			= 1		
AuraConstants.TRIGGER_TYPE_HITPOINTS		= 2		
AuraConstants.TRIGGER_TYPE_ACTIONPOINTS		= 3	
AuraConstants.TRIGGER_TYPE_MORALE			= 4
AuraConstants.TRIGGER_TYPE_ABILITY			= 5
AuraConstants.TRIGGER_TYPE_CAREER			= 6
AuraConstants.TRIGGER_TYPE_PET				= 7

-- This table must reflect the Aura.TRIGGER_TYPES_ listing
AuraConstants.Trigger											= {}
AuraConstants.Trigger[AuraConstants.TRIGGER_TYPE_EFFECTS]		= { Name=L"Effect" }
AuraConstants.Trigger[AuraConstants.TRIGGER_TYPE_HITPOINTS]		= { Name=L"Hit Points" }
AuraConstants.Trigger[AuraConstants.TRIGGER_TYPE_ACTIONPOINTS]	= { Name=L"Action Points" }
AuraConstants.Trigger[AuraConstants.TRIGGER_TYPE_MORALE]		= { Name=L"Morale" }
AuraConstants.Trigger[AuraConstants.TRIGGER_TYPE_ABILITY]		= { Name=L"Ability" }
AuraConstants.Trigger[AuraConstants.TRIGGER_TYPE_CAREER]		= { Name=L"Career" }
AuraConstants.Trigger[AuraConstants.TRIGGER_TYPE_PET]			= { Name=L"Pet" }

--[[
	NOTE:  THE ORDER OF THESE ENTRIES MATTER.  ADD NEW ONES TO THE END
--]]
-- Effect Types
AuraConstants.Effects		= {}
AuraConstants.Effects[1]	= { key="", 				Name=L"-Any-" }
AuraConstants.Effects[2]	= { key="isHealing", 		Name=GetString( StringTables.Default.LABEL_FILTER_HEALING ) }
AuraConstants.Effects[3]	= { key="isDebuff", 		Name=GetString( StringTables.Default.LABEL_ABILITY_TYPE_DEBUFF ) }
AuraConstants.Effects[4]	= { key="isBuff", 			Name=GetString( StringTables.Default.LABEL_ABILITY_TYPE_BUFF ) }
AuraConstants.Effects[5]	= { key="isDefensive", 		Name=GetString( StringTables.Default.LABEL_FILTER_DEFENSE ) }
AuraConstants.Effects[6]	= { key="isOffensive", 		Name=GetString( StringTables.Default.LABEL_FILTER_OFFENSE ) }
AuraConstants.Effects[7]	= { key="isDamaging", 		Name=GetString( StringTables.Default.LABEL_FILTER_DAMAGE ) }
AuraConstants.Effects[8]	= { key="isStatsBuff", 		Name=GetString( StringTables.Default.LABEL_FILTER_STATS_BUFF ) }
AuraConstants.Effects[9]	= { key="isHex", 			Name=GetString( StringTables.Default.LABEL_ABILITY_TYPE_HEX ) }
AuraConstants.Effects[10]	= { key="isCurse", 			Name=GetString( StringTables.Default.LABEL_ABILITY_TYPE_CURSE ) }
AuraConstants.Effects[11]	= { key="isCripple", 		Name=GetString( StringTables.Default.LABEL_ABILITY_TYPE_CRIPPLE ) }
AuraConstants.Effects[12]	= { key="isAilment", 		Name=GetString( StringTables.Default.LABEL_ABILITY_TYPE_AILMENT ) }
AuraConstants.Effects[13]	= { key="isBolster", 		Name=GetString( StringTables.Default.LABEL_ABILITY_TYPE_BOLSTER ) }
AuraConstants.Effects[14]	= { key="isAugmentation", 	Name=GetString( StringTables.Default.LABEL_ABILITY_TYPE_AUGMENTATION ) }
AuraConstants.Effects[15]	= { key="isBlessing", 		Name=GetString( StringTables.Default.LABEL_ABILITY_TYPE_BLESSING ) }
AuraConstants.Effects[16]	= { key="isEnchantment", 	Name=GetString( StringTables.Default.LABEL_ABILITY_TYPE_ENCHANTMENT ) }

--[[
	NOTE:  THE ORDER OF THESE ENTRIES MATTER.  ADD NEW ONES TO THE END
--]]
AuraConstants.HIT_POINT_TYPE_SELF 		= 1
AuraConstants.HIT_POINT_TYPE_ENEMY 		= 2
AuraConstants.HIT_POINT_TYPE_FRIENDLY 	= 3

AuraConstants.HitPointTypes 		= {}
AuraConstants.HitPointTypes[AuraConstants.HIT_POINT_TYPE_SELF]		= { Name=L"Self", 				target="" }
AuraConstants.HitPointTypes[AuraConstants.HIT_POINT_TYPE_ENEMY]		= { Name=L"Enemy Target", 		target="selfhostiletarget" }
AuraConstants.HitPointTypes[AuraConstants.HIT_POINT_TYPE_FRIENDLY]	= { Name=L"Friendly Target", 	target="selffriendlytarget" }

--[[
	NOTE:  THE ORDER OF THESE ENTRIES MATTER.  ADD NEW ONES TO THE END
--]]
-- Texture Types
AuraConstants.TEXTURE_TYPE_ICON					= 1
AuraConstants.TEXTURE_TYPE_AURA					= 2
AuraConstants.TEXTURE_TYPE_CUSTOM				= 3

-- Texture Min/Max Info
AuraConstants.TEXTURE_MIN_SCALE					= .01
AuraConstants.TEXTURE_MAX_SCALE					= 2.50
AuraConstants.TEXTURE_ROUND						= 3
AuraConstants.TIMER_MIN_SCALE					= .2
AuraConstants.TIMER_MAX_SCALE					= 5.0
AuraConstants.TIMER_ROUND						= 3

--[[
	NOTE:  THE ORDER OF THESE ENTRIES MATTER.  ADD NEW ONES TO THE END
--]]
-- Operator Types
AuraConstants.OPERATOR_EQUAL					= 1
AuraConstants.OPERATOR_LESSTHAN					= 2
AuraConstants.OPERATOR_GREATERTHAN				= 3
AuraConstants.OPERATOR_NOT						= 4

--[[
	NOTE:  THE ORDER OF THESE ENTRIES MATTER.  ADD NEW ONES TO THE END
--]]
-- Activation Animation Types
AuraConstants.ActivationAnimations 				= {}
AuraConstants.ActivationAnimations[1]			= { Name=L"-None-"  }
AuraConstants.ActivationAnimations[2]			= { Name=L"Fade In - Slow", type=Window.AnimationType.SINGLE, startAlpha=0.0, endAlpha=1.0, duration=1.5, setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.ActivationAnimations[3]			= { Name=L"Fade In", type=Window.AnimationType.SINGLE, startAlpha=0.0, endAlpha=1.0, duration=1, setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.ActivationAnimations[4]			= { Name=L"Fade In - Fast", type=Window.AnimationType.SINGLE, startAlpha=0.0, endAlpha=1.0, duration=.5, setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.ActivationAnimations[5]			= { Name=L"Pulse - Slow", type=Window.AnimationType.LOOP, startAlpha=0.3, endAlpha=1.0, duration=1.5, setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.ActivationAnimations[6]			= { Name=L"Pulse", type=Window.AnimationType.LOOP, startAlpha=0.3, endAlpha=1.0, duration=1, setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.ActivationAnimations[7]			= { Name=L"Pulse - Fast", type=Window.AnimationType.LOOP, startAlpha=0.3, endAlpha=1.0, duration=0.5, setStartBeforeDelay=true, delay=0, loopCount=0 }

--[[
	NOTE:  THE ORDER OF THESE ENTRIES MATTER.  ADD NEW ONES TO THE END
--]]
-- Deactivation Animation Types
AuraConstants.DeactivationAnimations 			= {}
AuraConstants.DeactivationAnimations[1]			= { Name=L"-None-" }
AuraConstants.DeactivationAnimations[2]			= { Name=L"Fade Out - Slow", type=Window.AnimationType.SINGLE_NO_RESET, startAlpha=1.0, endAlpha=0.0, duration=1.5, setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.DeactivationAnimations[3]			= { Name=L"Fade Out", type=Window.AnimationType.SINGLE_NO_RESET, startAlpha=1.0, endAlpha=0.0, duration=1, setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.DeactivationAnimations[4]			= { Name=L"Fade Out - Fast", type=Window.AnimationType.SINGLE_NO_RESET, startAlpha=1.0, endAlpha=0.0, duration=.5, setStartBeforeDelay=true, delay=0, loopCount=0 }

--[[
	NOTE:  THE ORDER OF THESE ENTRIES MATTER.  ADD NEW ONES TO THE END
--]]
-- Screen Flash Animation Types
--
-- End Alphas are not used for these, the texture-alpha is
--
AuraConstants.ActivationScreenFlash				= {}
AuraConstants.ActivationScreenFlash[1]			= { Name=L"-None-"  }
AuraConstants.ActivationScreenFlash[2]			= { Name=L"Fade In - Slow", 	type=Window.AnimationType.SINGLE, 		startAlpha=0.0, 	endAlpha=1.0, 	duration=1.5, 	setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.ActivationScreenFlash[3]			= { Name=L"Fade In", 			type=Window.AnimationType.SINGLE, 		startAlpha=0.0, 	endAlpha=1.0, 	duration=1.0, 	setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.ActivationScreenFlash[4]			= { Name=L"Fade In - Fast", 	type=Window.AnimationType.SINGLE, 		startAlpha=0.0, 	endAlpha=1.0, 	duration=0.5, 	setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.ActivationScreenFlash[5]			= { Name=L"Pulse - Slow", 		type=Window.AnimationType.LOOP, 		startAlpha=0.3, 	endAlpha=1.0, 	duration=1.5, 	setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.ActivationScreenFlash[6]			= { Name=L"Pulse", 				type=Window.AnimationType.LOOP, 		startAlpha=0.3, 	endAlpha=1.0, 	duration=1.0, 	setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.ActivationScreenFlash[7]			= { Name=L"Pulse - Fast", 		type=Window.AnimationType.LOOP, 		startAlpha=0.3, 	endAlpha=1.0, 	duration=0.5, 	setStartBeforeDelay=true, delay=0, loopCount=0 }
AuraConstants.ActivationScreenFlash[8]			= { Name=L"Fade In/Out - Slow", type=Window.AnimationType.POP_AND_EASE, startAlpha=0.0, 	endAlpha=1.0, 	duration=3.0, 	setStartBeforeDelay=true, delay=0, loopCount=1 }
AuraConstants.ActivationScreenFlash[9]			= { Name=L"Fade In/Out", 		type=Window.AnimationType.POP_AND_EASE, startAlpha=0.0, 	endAlpha=1.0, 	duration=2.0, 	setStartBeforeDelay=true, delay=0, loopCount=1 }
AuraConstants.ActivationScreenFlash[10]			= { Name=L"Fade In/Out - Fast", type=Window.AnimationType.POP_AND_EASE, startAlpha=0.0, 	endAlpha=1.0, 	duration=1.0, 	setStartBeforeDelay=true, delay=0, loopCount=1 }


--[[
	NOTE:  THE ORDER OF THESE ENTRIES MATTER.  ADD NEW ONES TO THE END
--]]
-- Sound Mappings from GameData.Sound (aka Sound.)
AuraConstants.Sounds 		= {}
AuraConstants.Sounds[1] 	= { Name=L"-None-", 					SoundID=0 }
AuraConstants.Sounds[2] 	= { Name=L"Money Loot", 				SoundID=Sound.MONEY_LOOT }
AuraConstants.Sounds[3] 	= { Name=L"Window Open", 				SoundID=Sound.WINDOW_OPEN }
AuraConstants.Sounds[4] 	= { Name=L"Window Close",		 		SoundID=Sound.WINDOW_CLOSE }
AuraConstants.Sounds[5] 	= { Name=L"Public Tome Unlocked",		SoundID=Sound.PUBLIC_TOME_UNLOCKED }
AuraConstants.Sounds[6]		= { Name=L"RvR Flag On",				SoundID=Sound.RVR_FLAG_ON }
AuraConstants.Sounds[7]		= { Name=L"RvR Flag Off",				SoundID=Sound.RVR_FLAG_OFF }
AuraConstants.Sounds[8]		= { Name=L"Apo Container Added",		SoundID=Sound.APOTHECARY_CONTAINER_ADDED }
AuraConstants.Sounds[9]		= { Name=L"Apo Determinent Added",		SoundID=Sound.APOTHECARY_DETERMINENT_ADDED }
AuraConstants.Sounds[10]	= { Name=L"Apo Resource Added",			SoundID=Sound.APOTHECARY_RESOURCE_ADDED }
AuraConstants.Sounds[11]	= { Name=L"Apo Add Failed",				SoundID=Sound.APOTHECARY_ADD_FAILED }
AuraConstants.Sounds[12]	= { Name=L"Apo Item Removed",			SoundID=Sound.APOTHECARY_ITEM_REMOVED }
AuraConstants.Sounds[13]	= { Name=L"Apo Brew Started",			SoundID=Sound.APOTHECARY_BREW_STARTED }
AuraConstants.Sounds[14]	= { Name=L"Apo Failed",					SoundID=Sound.APOTHECARY_FAILED }
AuraConstants.Sounds[15]	= { Name=L"Cultivating Seed Added",		SoundID=Sound.CULTIVATING_SEED_ADDED }
AuraConstants.Sounds[16]	= { Name=L"Cultivating Soil Added",		SoundID=Sound.CULTIVATING_SOIL_ADDED }
AuraConstants.Sounds[17]	= { Name=L"Cultivating Water Added",	SoundID=Sound.CULTIVATING_WATER_ADDED }
AuraConstants.Sounds[18]	= { Name=L"Cultivating Nutrient Added",	SoundID=Sound.CULTIVATING_NUTRIENT_ADDED }
AuraConstants.Sounds[19]	= { Name=L"Cultivating Harvest Crop",	SoundID=Sound.CULTIVATING_HARVEST_CROP }

--[[
	NOTE:  THE ORDER OF THESE ENTRIES MATTER.  ADD NEW ONES TO THE END
--]]
AuraConstants.AlertText 		= {}
AuraConstants.AlertText[1] 		= { Name=L"-None-" }
AuraConstants.AlertText[2] 		= { Name=L"Default", 				type=SystemData.AlertText.Types.DEFAULT }
AuraConstants.AlertText[3] 		= { Name=L"Combat", 				type=SystemData.AlertText.Types.COMBAT }
AuraConstants.AlertText[4] 		= { Name=L"Quest Name", 			type=SystemData.AlertText.Types.QUEST_NAME }
AuraConstants.AlertText[5] 		= { Name=L"Quest Condition", 		type=SystemData.AlertText.Types.QUEST_CONDITION }
AuraConstants.AlertText[6] 		= { Name=L"Quest End", 				type=SystemData.AlertText.Types.QUEST_END }
AuraConstants.AlertText[7] 		= { Name=L"Objective", 				type=SystemData.AlertText.Types.OBJECTIVE }
AuraConstants.AlertText[8] 		= { Name=L"RvR", 					type=SystemData.AlertText.Types.RVR }
AuraConstants.AlertText[9] 		= { Name=L"Scenario", 				type=SystemData.AlertText.Types.SCENARIO }
AuraConstants.AlertText[10] 	= { Name=L"Movement RvR", 			type=SystemData.AlertText.Types.MOVEMENT_RVR }
AuraConstants.AlertText[11] 	= { Name=L"Enter Area", 			type=SystemData.AlertText.Types.ENTERAREA }
AuraConstants.AlertText[12] 	= { Name=L"Errors", 				type=SystemData.AlertText.Types.STATUS_ERRORS }
AuraConstants.AlertText[13] 	= { Name=L"Achievements Gold", 		type=SystemData.AlertText.Types.STATUS_ACHIEVEMENTS_GOLD }
AuraConstants.AlertText[14] 	= { Name=L"Achievements Purple", 	type=SystemData.AlertText.Types.STATUS_ACHIEVEMENTS_PURPLE }
AuraConstants.AlertText[15] 	= { Name=L"Achievements Rank", 		type=SystemData.AlertText.Types.STATUS_ACHIEVEMENTS_RANK }
AuraConstants.AlertText[16] 	= { Name=L"Achievements Renown", 	type=SystemData.AlertText.Types.STATUS_ACHIEVEMENTS_RENOUN }
AuraConstants.AlertText[17] 	= { Name=L"Guild Rank", 			type=SystemData.AlertText.Types.GUILD_RANK }
AuraConstants.AlertText[18] 	= { Name=L"PQ Name",				type=SystemData.AlertText.Types.PQ_NAME }
AuraConstants.AlertText[19] 	= { Name=L"PQ Description", 		type=SystemData.AlertText.Types.PQ_DESCRIPTION }
AuraConstants.AlertText[20] 	= { Name=L"Enter Zone", 			type=SystemData.AlertText.Types.ENTERZONE }
AuraConstants.AlertText[21] 	= { Name=L"Order", 					type=SystemData.AlertText.Types.ORDER }
AuraConstants.AlertText[22] 	= { Name=L"Destruction", 			type=SystemData.AlertText.Types.DESTRUCTION }
AuraConstants.AlertText[23] 	= { Name=L"Neutral", 				type=SystemData.AlertText.Types.NEUTRAL }
AuraConstants.AlertText[24] 	= { Name=L"Ability", 				type=SystemData.AlertText.Types.ABILITY }
AuraConstants.AlertText[25] 	= { Name=L"City Rating", 			type=SystemData.AlertText.Types.CITY_RATING }
AuraConstants.AlertText[26] 	= { Name=L"BO Name", 				type=SystemData.AlertText.Types.BO_NAME }
AuraConstants.AlertText[27] 	= { Name=L"BO Description", 		type=SystemData.AlertText.Types.BO_DESCRIPTION }
Enemy.Settings = 
{
	combatLogIgnoreAbilityMinValue = 20000,
	combatLogTargetDefenseShow = 
	{
		false,
		false,
		false,
		false,
		false,
		false,
	},
	prevVersion = 279,
	combatLogTargetDefenseHideTimeout = 10,
	guardMarkEnabled = true,
	groupIconsOtherGroupsAlpha = 1,
	debug = false,
	combatLogTargetDefenseTotalEnabled = false,
	unitFramesDirection1 = 4,
	groupIconsPetScale = 1,
	unitFramesMyGroupOnly = false,
	soundOnNewTarget = false,
	guardDistanceIndicatorAlphaNormal = 0.75,
	talismanAlerterColorWarning = 
	{
		255,
		255,
		100,
	},
	talismanAlerterAnimation = false,
	combatLogIDSRowPadding = L"3",
	killSpamKilledByYouSound = 219,
	combatLogTargetDefenseSize = 
	{
		60,
		20,
	},
	guardDistanceIndicatorWarningDistance = 30,
	combatLogTargetDefenseTotalBackgroundAlpha = 0.5,
	groupIconsPetLayer = 0,
	combatLogIDSDisplayTime = 20,
	combatLogTargetDefenseTotalCalculate = 
	{
		false,
		false,
		false,
		false,
		false,
		false,
	},
	groupIconsEnabled = true,
	groupIconsBGColor = 
	{
		200,
		255,
		0,
	},
	groupIconsOffset = 
	{
		0,
		50,
	},
	combatLogTargetDefenseBackgroundAlpha = 0.5,
	combatLogIDSType = "dps",
	groupIconsPetIconColor = 
	{
		255,
		100,
		200,
	},
	combatLogIDSRowBackgroundAlpha = 0.7,
	clickCastings = 
	{
	},
	unitFramesDetachMyGroup = true,
	unitFramesHideWhenSolo = true,
	groupIconsBGAlpha = 0.5,
	effectsIndicators = 
	{
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			effectFilters = 
			{
				[1] = 
				{
					descriptionMatch = 2,
					type = "guard",
					typeMatch = 1,
					hasDurationLimit = false,
					castedByMe = 2,
					filterName = L"MyGuard",
					nameMatch = 1,
					durationType = 3,
				},
			},
			color = 
			{
				b = 0,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = true,
			offsetX = 1,
			icon = "guard",
			canDispell = 1,
			isCircleIcon = false,
			id = "18",
			alpha = 1,
			archetypeMatch = 1,
			scale = 2,
			name = L"My guard",
			isEnabled = true,
			playerType = 3,
			offsetY = 1,
			anchorTo = 5,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				true,
				false,
				false,
			},
			effectFilters = 
			{
				[1] = 
				{
					descriptionMatch = 2,
					type = "guard",
					typeMatch = 1,
					hasDurationLimit = false,
					castedByMe = 3,
					filterName = L"NotMyGuard",
					nameMatch = 1,
					durationType = 3,
				},
			},
			color = 
			{
				b = 255,
				g = 181,
				r = 127,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 3,
			icon = "guard",
			canDispell = 1,
			isCircleIcon = false,
			id = "19",
			alpha = 1,
			archetypeMatch = 2,
			name = L"Other guard",
			scale = 1.3,
			isEnabled = true,
			anchorTo = 5,
			playerType = 3,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 133,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = -10,
			customIcon = 20305,
			icon = "effect",
			canDispell = 2,
			isCircleIcon = false,
			id = "20",
			alpha = 1,
			archetypeMatch = 1,
			scale = 2,
			name = L"Any dispellable",
			isEnabled = true,
			playerType = 1,
			offsetY = 18,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					castedByMe = 1,
					durationType = 2,
					hasDurationLimit = false,
					filterName = L"Any",
					nameMatch = 1,
					descriptionMatch = 2,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			effectFilters = 
			{
				[1] = 
				{
					descriptionMatch = 2,
					type = "isHealing",
					typeMatch = 1,
					hasDurationLimit = false,
					castedByMe = 2,
					filterName = L"MyHealing",
					nameMatch = 1,
					durationType = 2,
				},
			},
			color = 
			{
				b = 0,
				g = 191,
				r = 255,
			},
			anchorFrom = 9,
			exceptMe = false,
			offsetX = -14,
			icon = "dot",
			canDispell = 1,
			isCircleIcon = false,
			id = "21",
			alpha = 1,
			archetypeMatch = 1,
			scale = 1,
			name = L"HoT",
			isEnabled = false,
			playerType = 1,
			offsetY = 0,
			anchorTo = 9,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			effectFilters = 
			{
				
				{
					descriptionMatch = 2,
					type = "isBuff",
					typeMatch = 1,
					hasDurationLimit = false,
					castedByMe = 2,
					filterName = L"MyBuff",
					nameMatch = 1,
					durationType = 2,
				},
				
				{
					descriptionMatch = 2,
					type = "isHealing",
					typeMatch = 1,
					hasDurationLimit = false,
					castedByMe = 2,
					filterName = L"MyHealing",
					nameMatch = 1,
					durationType = 2,
				},
			},
			scale = 1,
			anchorFrom = 8,
			exceptMe = false,
			offsetX = -30,
			icon = "dot",
			canDispell = 1,
			isCircleIcon = false,
			id = "22",
			alpha = 1,
			logic = L"MyBuff and not MyHealing",
			archetypeMatch = 1,
			anchorTo = 7,
			name = L"Buff",
			playerType = 1,
			isEnabled = false,
			offsetY = 10,
			color = 
			{
				b = 255,
				g = 200,
				r = 50,
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			effectFilters = 
			{
				
				{
					durationType = 2,
					type = "isBlessing",
					filterName = L"MyBlessing",
					descriptionMatch = 2,
					castedByMe = 2,
					durationMax = 59,
					hasDurationLimit = true,
					nameMatch = 1,
					typeMatch = 1,
				},
				
				{
					descriptionMatch = 2,
					type = "isHealing",
					typeMatch = 1,
					hasDurationLimit = false,
					castedByMe = 2,
					filterName = L"MyHealing",
					nameMatch = 1,
					durationType = 2,
				},
			},
			scale = 1,
			anchorFrom = 8,
			exceptMe = false,
			offsetX = -29,
			icon = "dot",
			canDispell = 1,
			isCircleIcon = false,
			id = "23",
			alpha = 1,
			logic = L"MyBlessing and not MyHealing",
			archetypeMatch = 1,
			anchorTo = 8,
			name = L"Blessing",
			playerType = 1,
			isEnabled = false,
			offsetY = 20,
			color = 
			{
				b = 255,
				g = 200,
				r = 50,
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				true,
			},
			effectFilters = 
			{
				[1] = 
				{
					descriptionMatch = 2,
					type = "healDebuffOut50",
					typeMatch = 1,
					hasDurationLimit = false,
					castedByMe = 3,
					filterName = L"OutHealDebuff",
					nameMatch = 1,
					durationType = 1,
				},
			},
			color = 
			{
				b = 64,
				g = 255,
				r = 191,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 8,
			icon = "heal",
			canDispell = 1,
			isCircleIcon = false,
			id = "24",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.5,
			name = L"Outgoing 50% heal debuff",
			isEnabled = true,
			playerType = 1,
			offsetY = 18,
			anchorTo = 5,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			effectFilters = 
			{
				[1] = 
				{
					descriptionMatch = 2,
					type = "healDebuffIn50",
					typeMatch = 1,
					hasDurationLimit = false,
					castedByMe = 3,
					filterName = L"InHealDebuff",
					nameMatch = 1,
					durationType = 1,
				},
			},
			color = 
			{
				b = 64,
				g = 64,
				r = 255,
			},
			anchorFrom = 8,
			exceptMe = false,
			offsetX = -40,
			icon = "heal",
			canDispell = 1,
			isCircleIcon = false,
			id = "25",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.6,
			name = L"Incomming 50% heal debuff",
			isEnabled = false,
			playerType = 1,
			offsetY = -5,
			anchorTo = 8,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			effectFilters = 
			{
				[1] = 
				{
					descriptionMatch = 2,
					type = "stagger",
					typeMatch = 1,
					hasDurationLimit = false,
					castedByMe = 1,
					filterName = L"Stagger",
					nameMatch = 1,
					durationType = 2,
				},
			},
			color = 
			{
				b = 128,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = -20,
			icon = "stagger",
			canDispell = 1,
			isCircleIcon = false,
			id = "26",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.6,
			name = L"Stagger",
			isEnabled = true,
			playerType = 1,
			offsetY = -10,
			anchorTo = 5,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				true,
			},
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"DoK_WP_Regen",
					abilityIds = L"9561, 8237",
					castedByMe = 1,
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[9561] = true,
						[8237] = true,
					},
					hasDurationLimit = false,
					durationType = 1,
				},
			},
			color = 
			{
				b = 128,
				g = 64,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = -20,
			icon = "disabled",
			canDispell = 1,
			isCircleIcon = false,
			id = "27",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.5,
			name = L"DoK/WP regen",
			isEnabled = true,
			playerType = 1,
			offsetY = 5,
			anchorTo = 5,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 50,
			customIcon = 23175,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "28",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Immaculate Defense",
			isEnabled = true,
			playerType = 1,
			offsetY = -29,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"ID",
					abilityIds = L"613",
					castedByMe = 1,
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[613] = true,
					},
					hasDurationLimit = false,
					durationType = 2,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				true,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 30,
			customIcon = 23153,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "29",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Focused Mind",
			isEnabled = true,
			playerType = 1,
			offsetY = -29,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"FM",
					abilityIds = L"653, 674, 695, 3882",
					castedByMe = 1,
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[3882] = true,
						[695] = true,
						[674] = true,
						[653] = true,
					},
					hasDurationLimit = false,
					durationType = 2,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 50,
			customIcon = 10965,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "30",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"1001 Dark Blessings",
			isEnabled = true,
			playerType = 1,
			offsetY = -29,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"TODB",
					abilityIds = L"9616",
					castedByMe = 1,
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[9616] = true,
					},
					hasDurationLimit = false,
					durationType = 2,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 50,
			customIcon = 8042,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "31",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Gift of Life",
			isEnabled = true,
			playerType = 1,
			offsetY = -29,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"GOF",
					abilityIds = L"8308",
					castedByMe = 1,
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[8308] = true,
					},
					hasDurationLimit = false,
					durationType = 2,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = -29,
			customIcon = 10908,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "32",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Improved Word of Pain",
			isEnabled = true,
			playerType = 1,
			offsetY = -29,
			effectFilters = 
			{
				[1] = 
				{
					durationType = 2,
					filterName = L"WordOfPain",
					descriptionMatch = 2,
					castedByMe = 1,
					abilityIds = L"9475, 20535",
					durationMax = 5,
					hasDurationLimit = true,
					abilityIdsHash = 
					{
						[8560] = true,
						[9475] = true,
						[1608] = true,
						[3746] = true,
						[3748] = true,
						[20535] = true,
						[20458] = true,
						[8617] = true,
						[3570] = true,
						[20476] = true,
						[1588] = true,
						[8556] = true,
						[8619] = true,
						[1591] = true,
						[8567] = true,
						[3650] = true,
						[8620] = true,
						[3747] = true,
						[3670] = true,
						[3038] = true,
						[8551] = true,
						[3773] = true,
						[1600] = true,
						[8618] = true,
						[3671] = true,
					},
					nameMatch = 1,
					typeMatch = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = -29,
			customIcon = 8015,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "33",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Improved Boiling Blood",
			isEnabled = true,
			playerType = 1,
			offsetY = -29,
			effectFilters = 
			{
				[1] = 
				{
					durationType = 2,
					filterName = L"BoilingBlood",
					descriptionMatch = 2,
					castedByMe = 1,
					abilityIds = L"8165",
					durationMax = 5,
					hasDurationLimit = true,
					abilityIdsHash = 
					{
						[9475] = true,
						[8165] = true,
						[20535] = true,
					},
					nameMatch = 1,
					typeMatch = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			scale = 0.3,
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 7960,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "34",
			effectFilters = 
			{
				[1] = 
				{
					durationType = 1,
					filterName = L"healing_hand",
					descriptionMatch = 2,
					castedByMe = 2,
					abilityIds = L"3365",
					durationMax = 5,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[3365] = true,
						[8165] = true,
					},
					nameMatch = 1,
					typeMatch = 1,
				},
			},
			alpha = 1,
			width = 60,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			height = 60,
			name = L"wp_healing_hand",
			playerType = 1,
			isEnabled = true,
			offsetY = 21,
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			scale = 0.3,
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 8035,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "35",
			effectFilters = 
			{
				[1] = 
				{
					durationType = 1,
					filterName = L"pious_rest",
					descriptionMatch = 2,
					castedByMe = 2,
					abilityIds = L"8232,8265",
					durationMax = 5,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[8232] = true,
						[8265] = true,
					},
					nameMatch = 2,
					typeMatch = 1,
				},
			},
			alpha = 1,
			width = 60,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			height = 60,
			name = L"wp_pious_rest",
			playerType = 3,
			isEnabled = true,
			offsetY = 4,
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			scale = 0.3,
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 13342,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "36",
			effectFilters = 
			{
				[1] = 
				{
					durationType = 1,
					filterName = L"lambent_aura",
					descriptionMatch = 2,
					castedByMe = 2,
					abilityIds = L"3914, 9238, 20494",
					durationMax = 5,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[20494] = true,
						[9238] = true,
						[3914] = true,
					},
					nameMatch = 1,
					typeMatch = 1,
				},
			},
			alpha = 1,
			width = 60,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			height = 60,
			name = L"am_lambent_aura",
			playerType = 1,
			isEnabled = true,
			offsetY = 21,
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 13413,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "37",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"am_magical_infusion",
			isEnabled = true,
			playerType = 1,
			offsetY = 4,
			effectFilters = 
			{
				[1] = 
				{
					durationType = 1,
					filterName = L"magical_infusion",
					descriptionMatch = 2,
					castedByMe = 1,
					abilityIds = L"9272",
					durationMax = 5,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[9272] = true,
					},
					nameMatch = 1,
					typeMatch = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 4561,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "38",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"rp_rune_of_regeneration",
			isEnabled = true,
			playerType = 1,
			offsetY = 21,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"rune_of_regeneration",
					abilityIds = L"1590,20474",
					castedByMe = 2,
					descriptionMatch = 2,
					nameMatch = 2,
					abilityIdsHash = 
					{
						[1590] = true,
						[20474] = true,
					},
					hasDurationLimit = false,
					durationType = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			scale = 0.3,
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 22704,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "39",
			effectFilters = 
			{
				[1] = 
				{
					durationType = 1,
					filterName = L"blessing_of_grungni",
					descriptionMatch = 2,
					castedByMe = 2,
					abilityIds = L"3410",
					durationMax = 5,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[3410] = true,
					},
					nameMatch = 2,
					typeMatch = 1,
				},
			},
			alpha = 1,
			width = 60,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			height = 60,
			name = L"rp_blessing_of_grungni",
			playerType = 1,
			isEnabled = true,
			offsetY = 4,
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 10956,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "40",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"dok_khaines_vigor",
			isEnabled = true,
			playerType = 3,
			offsetY = 4,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"khaines_vigor",
					abilityIds = L"9573",
					castedByMe = 2,
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[9573] = true,
					},
					hasDurationLimit = false,
					durationType = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			scale = 0.3,
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 10937,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "41",
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"soul_infusion",
					abilityIds = L"3366",
					castedByMe = 2,
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[3366] = true,
					},
					hasDurationLimit = false,
					durationType = 1,
				},
			},
			alpha = 1,
			width = 60,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			height = 60,
			name = L"dok_soul_infusion",
			playerType = 1,
			isEnabled = true,
			offsetY = 21,
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			scale = 0.3,
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 5142,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "42",
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"tzench_cordial",
					abilityIds = L"8558",
					castedByMe = 2,
					descriptionMatch = 2,
					nameMatch = 2,
					abilityIdsHash = 
					{
						[8558] = true,
					},
					hasDurationLimit = false,
					durationType = 1,
				},
			},
			alpha = 1,
			width = 60,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			height = 60,
			name = L"zealot_tzenchs_coordial",
			playerType = 1,
			isEnabled = true,
			offsetY = 21,
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 22704,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "43",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"zealot_blessing_of_chaos",
			isEnabled = true,
			playerType = 1,
			offsetY = 4,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"boc",
					abilityIds = L"3426, 3777",
					castedByMe = 2,
					descriptionMatch = 2,
					nameMatch = 2,
					abilityIdsHash = 
					{
						[3426] = true,
						[3777] = true,
					},
					hasDurationLimit = false,
					durationType = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				true,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 4,
			exceptMe = false,
			offsetX = -50,
			customIcon = 2629,
			icon = "other",
			canDispell = 2,
			isCircleIcon = false,
			id = "44",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Indigestion",
			isEnabled = true,
			playerType = 1,
			offsetY = 0,
			effectFilters = 
			{
				
				{
					durationType = 1,
					type = "isHex",
					filterName = L"Indigestion",
					descriptionMatch = 2,
					castedByMe = 1,
					name = L"indigestion",
					hasDurationLimit = false,
					nameMatch = 1,
					typeMatch = 1,
				},
				
				{
					typeMatch = 1,
					castedByMe = 1,
					name = L"shatter limbs",
					durationType = 1,
					nameMatch = 1,
					filterName = L"Shatter",
					hasDurationLimit = false,
					descriptionMatch = 2,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 221,
				g = 255,
				r = 0,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 0,
			customIcon = 8042,
			icon = "dot",
			canDispell = 1,
			isCircleIcon = false,
			id = "45",
			alpha = 1,
			archetypeMatch = 1,
			scale = 1,
			name = L"My marks/runes",
			isEnabled = true,
			playerType = 3,
			offsetY = 23,
			effectFilters = 
			{
				[1] = 
				{
					durationType = 1,
					filterName = L"AnyMarkOrRune",
					descriptionMatch = 2,
					castedByMe = 2,
					abilityIds = L"3746, 8551, 8617, 3748, 8560, 8619, 20458, 3747, 8556, 8618, 3038, 3773, 8567, 8620, 1591, 3670, 20476, 1588, 1600, 3570, 1608, 3650, 3671, 8269, 9248, 1910, 20415",
					durationMax = 5,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[8560] = true,
						[1608] = true,
						[3670] = true,
						[3746] = true,
						[3748] = true,
						[1588] = true,
						[20458] = true,
						[8617] = true,
						[3570] = true,
						[1910] = true,
						[8269] = true,
						[8556] = true,
						[3671] = true,
						[20415] = true,
						[1600] = true,
						[8619] = true,
						[20476] = true,
						[3650] = true,
						[3747] = true,
						[8620] = true,
						[9248] = true,
						[3038] = true,
						[8551] = true,
						[3773] = true,
						[8567] = true,
						[1591] = true,
						[8618] = true,
					},
					nameMatch = 1,
					typeMatch = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			effectFilters = 
			{
				
				{
					descriptionMatch = 2,
					type = "healDebuffIn50",
					typeMatch = 1,
					hasDurationLimit = false,
					castedByMe = 3,
					filterName = L"InHealDebuff",
					nameMatch = 1,
					durationType = 1,
				},
				
				{
					typeMatch = 1,
					filterName = L"wp_healdebuff",
					abilityIds = L"8270,1746,3292,20593",
					castedByMe = 3,
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[8270] = true,
						[1746] = true,
						[3292] = true,
						[20593] = true,
					},
					hasDurationLimit = false,
					durationType = 1,
				},
			},
			scale = 0.5,
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 16,
			icon = "heal",
			canDispell = 1,
			isCircleIcon = false,
			id = "46",
			alpha = 1,
			logic = L"InHealDebuff or wp_healdebuff",
			archetypeMatch = 1,
			anchorTo = 5,
			name = L"Incoming 50% heal debuff",
			playerType = 1,
			isEnabled = true,
			offsetY = 18,
			color = 
			{
				b = 64,
				g = 64,
				r = 255,
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 2576,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "47",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"sham_quit_bleedin",
			isEnabled = true,
			playerType = 1,
			offsetY = 21,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"quitbleedin",
					abilityIds = L"3908",
					castedByMe = 2,
					descriptionMatch = 2,
					nameMatch = 2,
					abilityIdsHash = 
					{
						[3908] = true,
					},
					hasDurationLimit = false,
					durationType = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 32,
			customIcon = 2501,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "48",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"sham_do_sumfin_useful",
			isEnabled = true,
			playerType = 1,
			offsetY = 4,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"do_sumfin_useful",
					abilityIds = L"3274",
					castedByMe = 2,
					descriptionMatch = 2,
					nameMatch = 2,
					abilityIdsHash = 
					{
						[3274] = true,
					},
					hasDurationLimit = false,
					durationType = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = -8,
			customIcon = 5007,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "49",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Immovable",
			isEnabled = true,
			playerType = 1,
			offsetY = -29,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"immovable",
					abilityIds = L"408,2876,3249",
					castedByMe = 1,
					name = L"immovable",
					descriptionMatch = 2,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[3249] = true,
						[2876] = true,
						[408] = true,
					},
					nameMatch = 1,
					durationType = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 10,
			customIcon = 5006,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "50",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Unstoppable",
			isEnabled = true,
			playerType = 1,
			offsetY = -29,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"unstoppable",
					abilityIds = L"402,403,404,405,406,407,412,413,414,2877",
					castedByMe = 1,
					name = L"unstoppable",
					descriptionMatch = 2,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[412] = true,
						[413] = true,
						[414] = true,
						[402] = true,
						[403] = true,
						[404] = true,
						[405] = true,
						[406] = true,
						[407] = true,
						[2877] = true,
					},
					nameMatch = 1,
					durationType = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = -45,
			customIcon = 23174,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "51",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Champ",
			isEnabled = true,
			playerType = 1,
			offsetY = 2,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"champ",
					abilityIds = L"608,3245,3331",
					castedByMe = 1,
					name = L"champion's challenge",
					descriptionMatch = 2,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[3245] = true,
						[608] = true,
						[3331] = true,
					},
					nameMatch = 1,
					durationType = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = -35,
			customIcon = 23172,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "52",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Demo",
			isEnabled = true,
			playerType = 1,
			offsetY = 2,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"Demo",
					abilityIds = L"606",
					castedByMe = 1,
					name = L"demolishing strike",
					descriptionMatch = 2,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[606] = true,
					},
					nameMatch = 1,
					durationType = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = -35,
			customIcon = 5118,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "53",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Talon",
			isEnabled = true,
			playerType = 1,
			offsetY = 2,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"talon",
					abilityIds = L"8605",
					castedByMe = 1,
					name = L"tzeentch's talon",
					descriptionMatch = 2,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[8605] = true,
					},
					nameMatch = 1,
					durationType = 1,
				},
			},
			playerTypeMatch = 1,
		},
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			anchorTo = 5,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			anchorFrom = 5,
			exceptMe = false,
			offsetX = 18,
			customIcon = 10997,
			icon = "other",
			canDispell = 1,
			isCircleIcon = true,
			id = "54",
			alpha = 1,
			archetypeMatch = 1,
			scale = 0.3,
			name = L"Shadow/Purgatory",
			isEnabled = true,
			playerType = 1,
			offsetY = -8,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"shadow",
					abilityIds = L"9701,9700",
					castedByMe = 1,
					name = L"shadow of death",
					descriptionMatch = 2,
					hasDurationLimit = false,
					abilityIdsHash = 
					{
						[9701] = true,
						[9700] = true,
					},
					nameMatch = 1,
					durationType = 1,
				},
			},
			playerTypeMatch = 1,
		},
	},
	groupIconsPetHPBGColor = 
	{
		100,
		0,
		0,
	},
	unitFramesDirection2 = 4,
	guardMarkTemplate = 
	{
		scale = 0.8,
		unique = false,
		firstLetters = 4,
		showCareerIcon = false,
		canClearOnClick = false,
		permanentTargets = 
		{
		},
		id = 378,
		targetOnClick = true,
		alpha = 1,
		text = L"G",
		color = 
		{
			65,
			150,
			255,
		},
		font = "font_default_text_giant",
		name = L"",
		layer = 3,
		display = 1,
		offsetY = 75,
		neverExpire = true,
		permanent = false,
	},
	groupIconsOtherGroupsHPBGColor = 
	{
		50,
		100,
		100,
	},
	unitFramesSorting = 
	{
		1,
		2,
		3,
	},
	objectWindowsInactiveTimeout = 1200,
	unitFramesGroupsCount1 = 1,
	killSpamEnabled = false,
	groupIconsParts = 
	{
	},
	groupIconsOtherGroupsOffset = 
	{
		0,
		50,
	},
	CombatLogStats = 
	{
		[1] = 
		{
			eps = 
			{
				[4] = 
				{
					valueAoeMaxData = 
					{
						
						{
							overheal = 1038,
							type = 4,
							ability = L"Divine Mend",
							currentTarget = true,
							time = 64926538887,
							value = 0,
							str = L"Your Divine Mend heals you for 0 points. (1038 overhealed)",
							crit = false,
							object = L"you",
						},
						
						{
							overheal = 439,
							type = 4,
							ability = L"Divine Aid",
							currentTarget = true,
							time = 64926538888,
							value = 0,
							str = L"Your Divine Aid heals you for 0 points. (439 overhealed)",
							crit = false,
							object = L"you",
						},
						
						{
							overheal = 112,
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538889,
							value = 0,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							crit = false,
							object = L"you",
						},
						
						{
							overheal = 172,
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538890,
							value = 0,
							str = L"Your Lingering Divine Aid critically heals you for 0 points. (172 overhealed)",
							crit = true,
							object = L"you",
						},
						
						{
							overheal = 658,
							type = 4,
							ability = L"Divine Aid",
							currentTarget = true,
							time = 64926538891,
							value = 0,
							str = L"Your Divine Aid critically heals you for 0 points. (658 overhealed)",
							crit = true,
							object = L"you",
						},
						
						{
							overheal = 112,
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538892,
							value = 0,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							crit = false,
							object = L"you",
						},
						
						{
							overheal = 1038,
							type = 4,
							ability = L"Divine Mend",
							currentTarget = true,
							time = 64926538893,
							value = 0,
							str = L"Your Divine Mend heals you for 0 points. (1038 overhealed)",
							crit = false,
							object = L"you",
						},
						
						{
							overheal = 112,
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538893,
							value = 0,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							crit = false,
							object = L"you",
						},
					},
					total = 2651,
					objectTime = 64926538896,
					data = 
					{
						
						{
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538889,
							value = 0,
							object = L"you",
							crit = false,
							overheal = 112,
						},
						
						{
							str = L"Your Lingering Divine Aid critically heals you for 0 points. (172 overhealed)",
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538890,
							value = 0,
							object = L"you",
							crit = true,
							overheal = 172,
						},
						
						{
							str = L"Your Divine Aid critically heals you for 0 points. (658 overhealed)",
							type = 4,
							ability = L"Divine Aid",
							currentTarget = true,
							time = 64926538891,
							value = 0,
							object = L"you",
							crit = true,
							overheal = 658,
						},
						
						{
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538892,
							value = 0,
							object = L"you",
							crit = false,
							overheal = 112,
						},
						
						{
							str = L"Your Divine Mend heals you for 0 points. (1038 overhealed)",
							type = 4,
							ability = L"Divine Mend",
							currentTarget = true,
							time = 64926538893,
							value = 0,
							object = L"you",
							crit = false,
							overheal = 1038,
						},
						
						{
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538893,
							value = 0,
							object = L"you",
							crit = false,
							overheal = 112,
						},
						
						{
							str = L"Your Lingering Divine Aid critically heals you for 0 points. (165 overhealed)",
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538894,
							value = 0,
							object = L"you",
							crit = true,
							overheal = 165,
						},
						
						{
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538895,
							value = 0,
							object = L"you",
							crit = false,
							overheal = 112,
						},
						
						{
							str = L"Your Lingering Divine Aid critically heals you for 0 points. (170 overhealed)",
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538896,
							value = 0,
							object = L"you",
							crit = true,
							overheal = 170,
						},
					},
					totalAoe = 2651,
					valueMaxData = 
					{
						
						{
							overheal = 1038,
							type = 4,
							ability = L"Divine Mend",
							currentTarget = true,
							time = 64926538887,
							value = 0,
							str = L"Your Divine Mend heals you for 0 points. (1038 overhealed)",
							crit = false,
							object = L"you",
						},
						
						{
							overheal = 439,
							type = 4,
							ability = L"Divine Aid",
							currentTarget = true,
							time = 64926538888,
							value = 0,
							str = L"Your Divine Aid heals you for 0 points. (439 overhealed)",
							crit = false,
							object = L"you",
						},
						
						{
							overheal = 112,
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538889,
							value = 0,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							crit = false,
							object = L"you",
						},
						
						{
							overheal = 172,
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538890,
							value = 0,
							str = L"Your Lingering Divine Aid critically heals you for 0 points. (172 overhealed)",
							crit = true,
							object = L"you",
						},
						
						{
							overheal = 658,
							type = 4,
							ability = L"Divine Aid",
							currentTarget = true,
							time = 64926538891,
							value = 0,
							str = L"Your Divine Aid critically heals you for 0 points. (658 overhealed)",
							crit = true,
							object = L"you",
						},
						
						{
							overheal = 112,
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538892,
							value = 0,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							crit = false,
							object = L"you",
						},
						
						{
							overheal = 1038,
							type = 4,
							ability = L"Divine Mend",
							currentTarget = true,
							time = 64926538893,
							value = 0,
							str = L"Your Divine Mend heals you for 0 points. (1038 overhealed)",
							crit = false,
							object = L"you",
						},
						
						{
							overheal = 112,
							type = 4,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538893,
							value = 0,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							crit = false,
							object = L"you",
						},
					},
					valueAoe = 379,
					valueMax = 614,
					value = 379,
					object = L"you",
					valueAoeMax = 614,
				},
				[3] = 
				{
					total = 2651,
					objectTime = 64926538896,
					data = 
					{
						
						{
							overheal = 112,
							type = 3,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538889,
							value = 0,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							crit = false,
							object = L"Ybilla",
						},
						
						{
							overheal = 172,
							type = 3,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538890,
							value = 0,
							str = L"Your Lingering Divine Aid critically heals you for 0 points. (172 overhealed)",
							crit = true,
							object = L"Ybilla",
						},
						
						{
							overheal = 658,
							type = 3,
							ability = L"Divine Aid",
							currentTarget = true,
							time = 64926538891,
							value = 0,
							str = L"Your Divine Aid critically heals you for 0 points. (658 overhealed)",
							crit = true,
							object = L"Ybilla",
						},
						
						{
							overheal = 112,
							type = 3,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538892,
							value = 0,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							crit = false,
							object = L"Ybilla",
						},
						
						{
							overheal = 1038,
							type = 3,
							ability = L"Divine Mend",
							currentTarget = true,
							time = 64926538893,
							value = 0,
							str = L"Your Divine Mend heals you for 0 points. (1038 overhealed)",
							crit = false,
							object = L"Ybilla",
						},
						
						{
							overheal = 112,
							type = 3,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538893,
							value = 0,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							crit = false,
							object = L"Ybilla",
						},
						
						{
							overheal = 165,
							type = 3,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538894,
							value = 0,
							str = L"Your Lingering Divine Aid critically heals you for 0 points. (165 overhealed)",
							crit = true,
							object = L"Ybilla",
						},
						
						{
							overheal = 112,
							type = 3,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538895,
							value = 0,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
							crit = false,
							object = L"Ybilla",
						},
						
						{
							overheal = 170,
							type = 3,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							time = 64926538896,
							value = 0,
							str = L"Your Lingering Divine Aid critically heals you for 0 points. (170 overhealed)",
							crit = true,
							object = L"Ybilla",
						},
					},
					totalAoe = 0,
					valueMaxData = 
					{
						
						{
							overheal = 1038,
							type = 3,
							ability = L"Divine Mend",
							currentTarget = true,
							object = L"Ybilla",
							value = 0,
							time = 64926538887,
							crit = false,
							str = L"Your Divine Mend heals you for 0 points. (1038 overhealed)",
						},
						
						{
							overheal = 439,
							type = 3,
							ability = L"Divine Aid",
							currentTarget = true,
							object = L"Ybilla",
							value = 0,
							time = 64926538888,
							crit = false,
							str = L"Your Divine Aid heals you for 0 points. (439 overhealed)",
						},
						
						{
							overheal = 112,
							type = 3,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							object = L"Ybilla",
							value = 0,
							time = 64926538889,
							crit = false,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
						},
						
						{
							overheal = 172,
							type = 3,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							object = L"Ybilla",
							value = 0,
							time = 64926538890,
							crit = true,
							str = L"Your Lingering Divine Aid critically heals you for 0 points. (172 overhealed)",
						},
						
						{
							overheal = 658,
							type = 3,
							ability = L"Divine Aid",
							currentTarget = true,
							object = L"Ybilla",
							value = 0,
							time = 64926538891,
							crit = true,
							str = L"Your Divine Aid critically heals you for 0 points. (658 overhealed)",
						},
						
						{
							overheal = 112,
							type = 3,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							object = L"Ybilla",
							value = 0,
							time = 64926538892,
							crit = false,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
						},
						
						{
							overheal = 1038,
							type = 3,
							ability = L"Divine Mend",
							currentTarget = true,
							object = L"Ybilla",
							value = 0,
							time = 64926538893,
							crit = false,
							str = L"Your Divine Mend heals you for 0 points. (1038 overhealed)",
						},
						
						{
							overheal = 112,
							type = 3,
							ability = L"Lingering Divine Aid",
							currentTarget = true,
							object = L"Ybilla",
							value = 0,
							time = 64926538893,
							crit = false,
							str = L"Your Lingering Divine Aid heals you for 0 points. (112 overhealed)",
						},
					},
					object = L"Ybilla",
					valueMax = 614,
					value = 379,
					valueAoe = 0,
				},
			},
			name = L"Default",
			data = 
			{
				[4] = 
				{
					[L"Divine Mend"] = 
					{
						normal = 
						{
							overheal = 2076,
							total = 0,
							abs = 0,
							min = 1038,
							count = 2,
							max = 1038,
							mit = 0,
							maxObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
							minObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
						},
						dodge = 0,
						disrupt = 0,
						block = 0,
						crit = 
						{
							overheal = 0,
							total = 0,
							count = 0,
							abs = 0,
							mit = 0,
						},
						parry = 0,
					},
					[L"Lingering Divine Aid"] = 
					{
						normal = 
						{
							overheal = 448,
							total = 0,
							abs = 0,
							min = 112,
							count = 4,
							max = 112,
							mit = 0,
							maxObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
							minObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
						},
						dodge = 0,
						disrupt = 0,
						block = 0,
						crit = 
						{
							overheal = 507,
							total = 0,
							abs = 0,
							min = 165,
							count = 3,
							max = 172,
							mit = 0,
							maxObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
							minObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
						},
						parry = 0,
					},
					[L"Divine Aid"] = 
					{
						normal = 
						{
							overheal = 439,
							total = 0,
							abs = 0,
							min = 439,
							count = 1,
							max = 439,
							mit = 0,
							maxObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
							minObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
						},
						dodge = 0,
						disrupt = 0,
						block = 0,
						crit = 
						{
							overheal = 658,
							total = 0,
							abs = 0,
							min = 658,
							count = 1,
							max = 658,
							mit = 0,
							maxObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
							minObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
						},
						parry = 0,
					},
				},
				[3] = 
				{
					[L"Ybilla - Lingering Divine Aid"] = 
					{
						normal = 
						{
							overheal = 448,
							total = 0,
							abs = 0,
							min = 112,
							count = 4,
							max = 112,
							mit = 0,
							maxObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
							minObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
						},
						dodge = 0,
						disrupt = 0,
						block = 0,
						crit = 
						{
							overheal = 507,
							total = 0,
							abs = 0,
							min = 165,
							count = 3,
							max = 172,
							mit = 0,
							maxObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
							minObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
						},
						parry = 0,
					},
					[L"Ybilla - Divine Aid"] = 
					{
						normal = 
						{
							overheal = 439,
							total = 0,
							abs = 0,
							min = 439,
							count = 1,
							max = 439,
							mit = 0,
							maxObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
							minObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
						},
						dodge = 0,
						disrupt = 0,
						block = 0,
						crit = 
						{
							overheal = 658,
							total = 0,
							abs = 0,
							min = 658,
							count = 1,
							max = 658,
							mit = 0,
							maxObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
							minObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
						},
						parry = 0,
					},
					[L"Ybilla - Divine Mend"] = 
					{
						normal = 
						{
							overheal = 2076,
							total = 0,
							abs = 0,
							min = 1038,
							count = 2,
							max = 1038,
							mit = 0,
							maxObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
							minObject = 
							{
								isNpc = false,
								type = "selffriendlytarget",
								name = L"Ybilla",
								isFriendly = true,
								id = 116,
								level = 40,
								hp = 100,
								career = 12,
							},
						},
						dodge = 0,
						disrupt = 0,
						block = 0,
						crit = 
						{
							overheal = 0,
							total = 0,
							count = 0,
							abs = 0,
							mit = 0,
						},
						parry = 0,
					},
				},
			},
			dt = 
			{
				minutes = 19,
				year = 2019,
				month = 12,
				day = 24,
				hours = 13,
				seconds = 29,
				totalSeconds = 64926537569,
			},
		},
	},
	groupIconsOtherGroupsBGColor = 
	{
		200,
		255,
		255,
	},
	unitFramesGroupsPadding2 = 1,
	talismanAlerterEnabled = false,
	autoAssist = false,
	groupIconsPetHPColor = 
	{
		255,
		225,
		255,
	},
	combatLogIDSTimeframe = 7.5,
	unitFramesHideMyGroup = false,
	groupIconsHPBGColor = 
	{
		0,
		100,
		0,
	},
	stopwatchEnabled = false,
	timerEnabled = true,
	killSpamListBottomUp = false,
	groupIconsScale = 1,
	playerKills = 2033,
	combatLogIDSMaxRows = L"5",
	groupIconsPetAlpha = 1,
	combatLogTargetDefenseTimeframe = 7.5,
	combatLogTargetDefenseEnabled = false,
	markNewTarget = true,
	unitFramesTooltipMode = "alt",
	unitFramesGroupsDirection1 = 2,
	combatLogEPSTimeframe = 7.5,
	combatLogEPSMaxValueMinTime = 4.5,
	combatLogTargetDefenseTotalBackground = 
	{
		0,
		0,
		0,
	},
	objectWindowsTimeout = 20,
	combatLogIgnoreWhenPolymorphed = true,
	combatLogIDSRowBackground = 
	{
		225,
		50,
		50,
	},
	unitFramesPadding2 = 1,
	combatLogEPSEnabled = 
	{
		false,
		false,
		false,
		false,
	},
	unitFramesLayer = 1,
	groupIconsOtherGroupsScale = 0.6,
	targetShowDelay = 8,
	assistTargetOnNotifyClick = true,
	scenarioInfoReplaceStandardWindow = false,
	unitFramesTestMode = false,
	markTemplates = 
	{
		
		{
			scale = 0.5,
			unique = false,
			firstLetters = L"4",
			showCareerIcon = true,
			canClearOnClick = true,
			permanentTargets = 
			{
			},
			id = 1,
			targetOnClick = true,
			alpha = 1,
			text = L"",
			color = 
			{
				1,
				100,
				255,
			},
			font = "font_clear_large_bold",
			name = L"T",
			layer = 0,
			display = 2,
			offsetY = 50,
			neverExpire = false,
			permanent = false,
		},
		
		{
			scale = 0.5,
			unique = false,
			firstLetters = L"4",
			showCareerIcon = true,
			canClearOnClick = true,
			permanentTargets = 
			{
			},
			id = 2,
			targetOnClick = true,
			alpha = 1,
			text = L"",
			color = 
			{
				255,
				50,
				1,
			},
			font = "font_clear_large_bold",
			name = L"D",
			layer = 0,
			display = 2,
			offsetY = 50,
			neverExpire = false,
			permanent = false,
		},
		
		{
			scale = 0.5,
			unique = false,
			firstLetters = L"4",
			showCareerIcon = true,
			canClearOnClick = true,
			permanentTargets = 
			{
			},
			id = 3,
			targetOnClick = true,
			alpha = 1,
			text = L"",
			color = 
			{
				1,
				255,
				100,
			},
			font = "font_clear_large_bold",
			name = L"H",
			layer = 3,
			display = 2,
			offsetY = 50,
			neverExpire = false,
			permanent = false,
		},
		
		{
			scale = 1,
			unique = false,
			firstLetters = L"4",
			showCareerIcon = true,
			canClearOnClick = true,
			permanentTargets = 
			{
			},
			id = 4,
			targetOnClick = true,
			alpha = 1,
			text = L"",
			color = 
			{
				255,
				255,
				100,
			},
			font = "font_clear_large_bold",
			name = L"L",
			layer = 0,
			display = 2,
			offsetY = 50,
			neverExpire = false,
			permanent = false,
		},
		
		{
			scale = 0.5,
			unique = false,
			firstLetters = L"4",
			showCareerIcon = true,
			canClearOnClick = true,
			permanentTargets = 
			{
			},
			id = 5,
			targetOnClick = true,
			alpha = 1,
			text = L"",
			color = 
			{
				255,
				43,
				255,
			},
			font = "font_clear_large_bold",
			name = L"P",
			layer = 3,
			display = 2,
			offsetY = 50,
			neverExpire = false,
			permanent = false,
		},
	},
	groupIconsAlpha = 1,
	unitFramesEnabled = true,
	unitFramesSize = 
	{
		120,
		60,
	},
	guardDistanceIndicatorScaleWarning = 1.5,
	unitFramesSortingEnabled = true,
	timerInactiveColor = 
	{
		255,
		255,
		255,
	},
	stateMachineThrottle = 0.3,
	newTargetMarkTemplate = 
	{
		scale = 1,
		unique = false,
		firstLetters = 4,
		showCareerIcon = true,
		canClearOnClick = true,
		permanentTargets = 
		{
		},
		id = 377,
		targetOnClick = true,
		alpha = 1,
		text = L"KILL",
		color = 
		{
			r = 255,
			g = 0,
			b = 0,
		},
		font = "font_clear_large_bold",
		name = L"",
		layer = 3,
		display = 1,
		offsetY = 50,
		neverExpire = false,
		permanent = false,
	},
	groupIconsPetBGAlpha = 0.5,
	groupIconsOtherGroupsHPColor = 
	{
		200,
		255,
		255,
	},
	unitFramesScale = 1,
	unitFramesMyGroupFirst = true,
	combatLogTargetDefenseBackground = 
	{
		0,
		0,
		0,
	},
	guardDistanceIndicator = 2,
	timerActiveColor = 
	{
		255,
		1,
		25,
	},
	scenarioInfoData = 
	{
		maxTimer = 0,
		startingScenario = 2111,
		destructionPoints = 0,
		id = 0,
		queuedWithGroup = false,
		activeQueue = 0,
		pointMax = 0,
		mode = 3,
		timeLeft = 0,
		orderPoints = 0,
	},
	combatLogEnabled = false,
	talismanAlerterDisplayMode = 2,
	groupIconsLayer = 0,
	groupIconsTargetOnClick = true,
	chatThrottleDelay = 10,
	combatLogIDSEnabled = false,
	combatLogLogParseErrors = false,
	scenarioInfoSelection = 
	{
		
		{
			sortColumn = "value1",
			columns = 
			{
				"db",
				"deaths",
			},
			sortDirection = false,
			id2 = "1",
			id = "All",
		},
		
		{
			sortColumn = "value1",
			columns = 
			{
				"db",
				"deaths",
			},
			sortDirection = false,
			id2 = "2",
			id = "All",
		},
	},
	version = 279,
	guardDistanceIndicatorColorNormal = 
	{
		127,
		181,
		255,
	},
	guardDistanceIndicatorScaleNormal = 1,
	guardDistanceIndicatorAnimation = true,
	playerDeaths = 1085,
	guardEnabled = false,
	killSpamReparseChunkSize = 20,
	groupIconsShowOnMarkedPlayers = false,
	groupIconsHPColor = 
	{
		200,
		255,
		0,
	},
	groupIconsOtherGroupsLayer = 0,
	chatDelay = 2,
	combatLogStatisticsEnabled = false,
	combatLogIDSRowSize = 
	{
		250,
		30,
	},
	scenarioAlerterEnabled = false,
	unitFramesParts = 
	{
		
		{
			type = "selectionFrame",
			id = "6",
			data = 
			{
				offlineHide = true,
				anchorTo = "center",
				color = 
				{
					255,
					255,
					100,
				},
				layer = 0,
				anchorFrom = "center",
				pos = 
				{
					1,
					1,
				},
				vertical = false,
				size = 
				{
					124,
					64,
				},
				deadHide = false,
				scale = 1,
				distHide = false,
				alpha = 1,
				texture = "rect",
			},
			exceptMe = false,
			name = L"Selection",
			playerType = 1,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			type = "panel",
			id = "7",
			data = 
			{
				offlineColor = 
				{
					150,
					150,
					150,
				},
				offlineHide = false,
				anchorTo = "center",
				scale = 1,
				layer = 0,
				alpha = 0.75,
				pos = 
				{
					1,
					1,
				},
				size = 
				{
					120,
					60,
				},
				deadHide = false,
				deadColor = 
				{
					200,
					50,
					50,
				},
				color = 
				{
					0,
					0,
					0,
				},
				vertical = false,
				distHide = false,
				anchorFrom = "center",
				texture = "default2",
			},
			exceptMe = false,
			name = L"Background",
			playerType = 1,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			type = "hpacbar",
			id = "8",
			data = 
			{
				anchorTo = "center",
				color = 
				{
					255,
					255,
					180,
				},
				anchorFrom = "center",
				vertical = false,
				distHide = false,
				texture = "minimalist",
				healColor = 
				{
					1,
					255,
					100,
				},
				offlineHide = true,
				distAlpha = 0.5,
				textureFullResize = false,
				wrap = false,
				alpha = 1,
				deadHide = true,
				dpsColor = 
				{
					255,
					50,
					1,
				},
				scale = 1,
				layer = 1,
				tankColor = 
				{
					1,
					100,
					255,
				},
				size = 
				{
					120,
					60,
				},
				pos = 
				{
					0,
					0,
				},
			},
			exceptMe = false,
			name = L"HP",
			playerType = 1,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			type = "apbar",
			id = "9",
			data = 
			{
				offlineHide = true,
				pos = 
				{
					35,
					0,
				},
				anchorTo = "bottomleft",
				textureFullResize = true,
				layer = 2,
				anchorFrom = "bottomleft",
				distAlpha = 0.5,
				color = 
				{
					255,
					220,
					100,
				},
				deadHide = true,
				alpha = 1,
				vertical = false,
				scale = 1,
				distHide = false,
				size = 
				{
					128,
					3,
				},
				texture = "plain",
			},
			exceptMe = false,
			name = L"AP",
			playerType = 3,
			isEnabled = false,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			type = "nameText",
			id = "10",
			data = 
			{
				anchorTo = "bottomleft",
				scale = 1,
				anchorFrom = "bottomleft",
				vertical = false,
				distHide = false,
				size = 
				{
					129,
					30,
				},
				distColor = 
				{
					190,
					225,
					255,
				},
				distAlpha = 0.5,
				align = "bottomleft",
				layer = 4,
				alpha = 1,
				maxLength = 4,
				deadHide = false,
				font = "font_clear_small_bold",
				color = 
				{
					255,
					255,
					255,
				},
				wrap = false,
				offlineHide = false,
				texture = "aluminium",
				pos = 
				{
					5,
					-2,
				},
			},
			exceptMe = false,
			name = L"Name",
			playerType = 1,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			type = "careerIcon",
			id = "11",
			data = 
			{
				offlineHide = false,
				anchorTo = "topleft",
				scale = 0.7,
				layer = 4,
				anchorFrom = "topleft",
				pos = 
				{
					1,
					3,
				},
				deadHide = false,
				size = 
				{
					28,
					28,
				},
				vertical = false,
				color = 
				{
					255,
					255,
					255,
				},
				distHide = false,
				alpha = 0.8,
				texture = "aluminium",
			},
			exceptMe = false,
			name = L"Icon",
			playerType = 1,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			type = "levelText",
			id = "12",
			data = 
			{
				anchorTo = "bottomleft",
				scale = 0.8,
				layer = 2,
				anchorFrom = "bottomleft",
				pos = 
				{
					12,
					5,
				},
				vertical = false,
				size = 
				{
					30,
					20,
				},
				align = "center",
				font = "font_clear_small_bold",
				color = 
				{
					255,
					255,
					255,
				},
				alpha = 1,
				texture = "aluminium",
			},
			exceptMe = false,
			name = L"Level",
			playerType = 1,
			isEnabled = false,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			type = "groupLeaderIcon",
			id = "13",
			data = 
			{
				offlineHide = false,
				anchorTo = "topleft",
				color = 
				{
					150,
					190,
					255,
				},
				layer = 4,
				alpha = 1,
				pos = 
				{
					-5,
					-1,
				},
				vertical = false,
				size = 
				{
					16,
					16,
				},
				deadHide = false,
				scale = 1,
				distHide = false,
				anchorFrom = "topleft",
				texture = "star",
			},
			exceptMe = false,
			name = L"Leader",
			playerType = 1,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			type = "moraleText",
			id = "14",
			data = 
			{
				anchorTo = "right",
				color = 
				{
					255,
					255,
					1,
				},
				anchorFrom = "right",
				vertical = false,
				prefix = L"",
				suffix = L"",
				distHide = false,
				texture = "3dots",
				offlineHide = true,
				align = "center",
				layer = 4,
				alpha = 1,
				deadHide = true,
				scale = 1,
				font = "font_clear_medium_bold",
				textureFullResize = false,
				size = 
				{
					30,
					30,
				},
				pos = 
				{
					7,
					18,
				},
			},
			exceptMe = false,
			name = L"Morale",
			playerType = 1,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			type = "distanceText",
			id = "15",
			data = 
			{
				anchorTo = "center",
				color = 
				{
					255,
					255,
					255,
				},
				farValue = 151,
				anchorFrom = "center",
				farText = L"FAR",
				prefix = L"",
				suffix = L"",
				distHide = false,
				size = 
				{
					30,
					30,
				},
				offlineHide = true,
				align = "right",
				layer = 2,
				alpha = 1,
				deadHide = true,
				scale = 0.9,
				font = "font_clear_small_bold",
				texture = "aluminium",
				vertical = false,
				pos = 
				{
					44,
					-5,
				},
			},
			exceptMe = true,
			name = L"Distance",
			playerType = 1,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			type = "distanceBar",
			id = "16",
			data = 
			{
				anchorTo = "topright",
				color = 
				{
					190,
					255,
					50,
				},
				level1 = 65,
				anchorFrom = "topright",
				level2 = 100,
				distHide = false,
				texture = "4dots",
				offlineHide = true,
				textureFullResize = false,
				layer = 2,
				alpha = 1,
				color1 = 
				{
					255,
					150,
					50,
				},
				color2 = 
				{
					255,
					50,
					50,
				},
				deadHide = true,
				color3 = 
				{
					255,
					50,
					50,
				},
				scale = 1,
				level3 = 150,
				vertical = false,
				size = 
				{
					40,
					10,
				},
				pos = 
				{
					-3,
					4,
				},
			},
			exceptMe = false,
			name = L"Distance bar",
			playerType = 1,
			isEnabled = false,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
		
		{
			type = "hppText",
			id = "17",
			data = 
			{
				anchorTo = "right",
				color = 
				{
					255,
					255,
					255,
				},
				anchorFrom = "right",
				vertical = false,
				prefix = L"",
				suffix = L"%",
				distHide = false,
				size = 
				{
					50,
					30,
				},
				offlineHide = true,
				textureFullResize = false,
				layer = 2,
				alpha = 1,
				deadHide = true,
				scale = 0.7,
				texture = "3dots",
				align = "rightcenter",
				font = "font_clear_small_bold",
				pos = 
				{
					-3,
					1,
				},
			},
			exceptMe = false,
			name = L"HP %",
			playerType = 1,
			isEnabled = false,
			archetypes = 
			{
				false,
				false,
				false,
			},
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
	},
	unitFramesPadding1 = 0,
	guardDistanceIndicatorAlphaWarning = 1,
	guardDistanceIndicatorColorWarning = 
	{
		255,
		50,
		50,
	},
	groupIconsOtherGroupsBGAlpha = 0.5,
	playerKDRDisplayMode = 5,
	soundOnNewTargetId = 500,
	groupIconsHideOnSelf = true,
	groupIconsShowOtherGroups = true,
	intercomPrivate = true,
	unitFramesCount1 = 6,
	combatLogIDSRowScale = 1,
	unitFramesIsVertical = false,
	combatLogEPSShow = 
	{
		false,
		false,
		false,
		false,
	},
	scenarioInfoPlayers = 
	{
		
		{
			deaths = 0,
			renown = 0,
			healing = 1152312,
			soloKills = 57670,
			damage = 68292,
			kills = 318,
			name = L"Blaxican",
			exp = 0,
			db = 1,
			level = 40,
			career = 12,
			realm = 1,
		},
		
		{
			deaths = 0,
			renown = 1500,
			healing = 18846,
			soloKills = 387543,
			damage = 82874,
			kills = 316,
			name = L"Hammerhead",
			exp = 0,
			db = 4,
			level = 40,
			career = 1,
			realm = 1,
		},
		
		{
			deaths = 15,
			renown = 0,
			healing = 0,
			soloKills = 219834,
			damage = 186024,
			kills = 11,
			name = L"Darth",
			exp = 0,
			db = 1,
			level = 40,
			career = 21,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 1363,
			healing = 650126,
			soloKills = 15441,
			damage = 8539,
			kills = 318,
			name = L"Florenx",
			exp = 0,
			db = 0,
			level = 40,
			career = 12,
			realm = 1,
		},
		
		{
			deaths = 8,
			renown = 1391,
			healing = 1500,
			soloKills = 354885,
			damage = 26890,
			kills = 10,
			name = L"Genelart",
			exp = 0,
			db = 0,
			level = 40,
			career = 13,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 1553,
			healing = 690240,
			soloKills = 42442,
			damage = 31258,
			kills = 318,
			name = L"Pokma",
			exp = 0,
			db = 2,
			level = 40,
			career = 12,
			realm = 1,
		},
		
		{
			deaths = 13,
			renown = 1487,
			healing = 254708,
			soloKills = 8688,
			damage = 17213,
			kills = 10,
			name = L"Aptekarz",
			exp = 0,
			db = 0,
			level = 40,
			career = 7,
			realm = 2,
		},
		
		{
			deaths = 11,
			renown = 1500,
			healing = 7500,
			soloKills = 6145,
			damage = 1020879,
			kills = 11,
			name = L"Atel",
			exp = 0,
			db = 3,
			level = 40,
			career = 24,
			realm = 2,
		},
		
		{
			deaths = 1,
			renown = 1653,
			healing = 3128,
			soloKills = 313145,
			damage = 184892,
			kills = 318,
			name = L"Aethilmar",
			exp = 0,
			db = 5,
			level = 40,
			career = 17,
			realm = 1,
		},
		
		{
			deaths = 16,
			renown = 1425,
			healing = 30060,
			soloKills = 1309534,
			damage = 111404,
			kills = 11,
			name = L"Baaldr",
			exp = 0,
			db = 0,
			level = 40,
			career = 5,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 836664,
			soloKills = 66363,
			damage = 31797,
			kills = 318,
			name = L"Agnar",
			exp = 0,
			db = 1,
			level = 40,
			career = 12,
			realm = 1,
		},
		
		{
			deaths = 12,
			renown = 0,
			healing = 36459,
			soloKills = 0,
			damage = 694966,
			kills = 11,
			name = L"Akasha",
			exp = 0,
			db = 0,
			level = 40,
			career = 16,
			realm = 2,
		},
		
		{
			deaths = 13,
			renown = 1444,
			healing = 28922,
			soloKills = 5570,
			damage = 462392,
			kills = 11,
			name = L"Oyareydelurto",
			exp = 0,
			db = 0,
			level = 40,
			career = 8,
			realm = 2,
		},
		
		{
			deaths = 1,
			renown = 1627,
			healing = 40002,
			soloKills = 1799,
			damage = 935611,
			kills = 316,
			name = L"Ephov",
			exp = 5,
			db = 41,
			level = 40,
			career = 2,
			realm = 1,
		},
		
		{
			deaths = 1,
			renown = 1459,
			healing = 20069,
			soloKills = 710572,
			damage = 105202,
			kills = 318,
			name = L"Sciberr",
			exp = 0,
			db = 0,
			level = 40,
			career = 1,
			realm = 1,
		},
		
		{
			deaths = 15,
			renown = 1408,
			healing = 326262,
			soloKills = 79396,
			damage = 1547,
			kills = 11,
			name = L"Khardruum",
			exp = 0,
			db = 0,
			level = 40,
			career = 15,
			realm = 2,
		},
		
		{
			deaths = 8,
			renown = 0,
			healing = 526012,
			soloKills = 23213,
			damage = 10243,
			kills = 11,
			name = L"Tontin",
			exp = 0,
			db = 0,
			level = 40,
			career = 7,
			realm = 2,
		},
		
		{
			deaths = 2,
			renown = 1617,
			healing = 37554,
			soloKills = 14487,
			damage = 3427,
			kills = 0,
			name = L"Sanguinarius",
			exp = 0,
			db = 0,
			level = 40,
			career = 23,
			realm = 2,
		},
		
		{
			deaths = 16,
			renown = 0,
			healing = 637668,
			soloKills = 65814,
			damage = 21377,
			kills = 11,
			name = L"Kkpp",
			exp = 0,
			db = 0,
			level = 40,
			career = 23,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 665471,
			soloKills = 6186,
			damage = 23120,
			kills = 318,
			name = L"Ybli",
			exp = 0,
			db = 0,
			level = 40,
			career = 3,
			realm = 1,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 0,
			soloKills = 0,
			damage = 820211,
			kills = 318,
			name = L"Varahir",
			exp = 0,
			db = 26,
			level = 40,
			career = 18,
			realm = 1,
		},
		
		{
			deaths = 20,
			renown = 0,
			healing = 13356,
			soloKills = 399488,
			damage = 66141,
			kills = 10,
			name = L"Draeguard",
			exp = 0,
			db = 1,
			level = 40,
			career = 21,
			realm = 2,
		},
		
		{
			deaths = 9,
			renown = 1542,
			healing = 1122707,
			soloKills = 34059,
			damage = 8330,
			kills = 10,
			name = L"Flashdancex",
			exp = 0,
			db = 0,
			level = 40,
			career = 15,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 1500,
			soloKills = 0,
			damage = 596991,
			kills = 318,
			name = L"Falinirya",
			exp = 5,
			db = 16,
			level = 40,
			career = 18,
			realm = 1,
		},
		
		{
			deaths = 3,
			renown = 0,
			healing = 568431,
			soloKills = 19678,
			damage = 34591,
			kills = 10,
			name = L"Shammimi",
			exp = 0,
			db = 0,
			level = 40,
			career = 7,
			realm = 2,
		},
		
		{
			deaths = 1,
			renown = 0,
			healing = 16556,
			soloKills = 396697,
			damage = 69866,
			kills = 318,
			name = L"Maceinface",
			exp = 0,
			db = 2,
			level = 40,
			career = 1,
			realm = 1,
		},
		
		{
			deaths = 2,
			renown = 0,
			healing = 776569,
			soloKills = 152795,
			damage = 42865,
			kills = 317,
			name = L"Ianthia",
			exp = 0,
			db = 0,
			level = 40,
			career = 3,
			realm = 1,
		},
		
		{
			deaths = 1,
			renown = 1405,
			healing = 4548,
			soloKills = 356651,
			damage = 80904,
			kills = 318,
			name = L"Lillamy",
			exp = 0,
			db = 2,
			level = 40,
			career = 1,
			realm = 1,
		},
		
		{
			deaths = 13,
			renown = 0,
			healing = 29820,
			soloKills = 5773,
			damage = 1449301,
			kills = 11,
			name = L"Szilvia",
			exp = 0,
			db = 3,
			level = 40,
			career = 16,
			realm = 2,
		},
		
		{
			deaths = 15,
			renown = 1399,
			healing = 54343,
			soloKills = 0,
			damage = 677304,
			kills = 11,
			name = L"Nurglegor",
			exp = 0,
			db = 0,
			level = 40,
			career = 14,
			realm = 2,
		},
		
		{
			deaths = 17,
			renown = 0,
			healing = 7908,
			soloKills = 364500,
			damage = 193925,
			kills = 11,
			name = L"Mogulblack",
			exp = 0,
			db = 0,
			level = 40,
			career = 21,
			realm = 2,
		},
		
		{
			deaths = 16,
			renown = 0,
			healing = 1683,
			soloKills = 4469,
			damage = 689662,
			kills = 10,
			name = L"Soh",
			exp = 0,
			db = 0,
			level = 40,
			career = 6,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 1546,
			healing = 816133,
			soloKills = 395,
			damage = 9053,
			kills = 316,
			name = L"Tripspirit",
			exp = 0,
			db = 0,
			level = 40,
			career = 3,
			realm = 1,
		},
		
		{
			deaths = 15,
			renown = 1277,
			healing = 26485,
			soloKills = 316856,
			damage = 127933,
			kills = 11,
			name = L"Aiorobos",
			exp = 0,
			db = 0,
			level = 40,
			career = 13,
			realm = 2,
		},
		
		{
			deaths = 1,
			renown = 1657,
			healing = 15179,
			soloKills = 2525,
			damage = 1455753,
			kills = 318,
			name = L"Akame",
			exp = 5,
			db = 51,
			level = 40,
			career = 19,
			realm = 1,
		},
		
		{
			deaths = 1,
			renown = 0,
			healing = 50390,
			soloKills = 6397,
			damage = 1013164,
			kills = 318,
			name = L"Herms",
			exp = 0,
			db = 47,
			level = 40,
			career = 2,
			realm = 1,
		},
		
		{
			deaths = 17,
			renown = 0,
			healing = 1834,
			soloKills = 607221,
			damage = 115471,
			kills = 11,
			name = L"Murrdur",
			exp = 0,
			db = 0,
			level = 40,
			career = 21,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 23030,
			soloKills = 418025,
			damage = 44616,
			kills = 318,
			name = L"Portz",
			exp = 0,
			db = 0,
			level = 40,
			career = 10,
			realm = 1,
		},
		
		{
			deaths = 15,
			renown = 1336,
			healing = 459998,
			soloKills = 98689,
			damage = 37567,
			kills = 10,
			name = L"Ciliegia",
			exp = 0,
			db = 0,
			level = 40,
			career = 23,
			realm = 2,
		},
		
		{
			deaths = 1,
			renown = 0,
			healing = 33547,
			soloKills = 389406,
			damage = 61042,
			kills = 318,
			name = L"Waats",
			exp = 0,
			db = 2,
			level = 40,
			career = 10,
			realm = 1,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 16239,
			soloKills = 5463,
			damage = 808642,
			kills = 318,
			name = L"Savagery",
			exp = 5,
			db = 36,
			level = 40,
			career = 19,
			realm = 1,
		},
		
		{
			deaths = 18,
			renown = 1518,
			healing = 21082,
			soloKills = 39329,
			damage = 756856,
			kills = 10,
			name = L"Yyfu",
			exp = 0,
			db = 3,
			level = 40,
			career = 6,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 1450,
			healing = 39091,
			soloKills = 0,
			damage = 956951,
			kills = 316,
			name = L"Grimnews",
			exp = 0,
			db = 35,
			level = 40,
			career = 2,
			realm = 1,
		},
		
		{
			deaths = 12,
			renown = 1402,
			healing = 97194,
			soloKills = 701669,
			damage = 60806,
			kills = 10,
			name = L"Syzygy",
			exp = 0,
			db = 0,
			level = 40,
			career = 5,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 32449,
			soloKills = 0,
			damage = 1437472,
			kills = 318,
			name = L"Babymoon",
			exp = 0,
			db = 47,
			level = 40,
			career = 11,
			realm = 1,
		},
		
		{
			deaths = 1,
			renown = 1323,
			healing = 39087,
			soloKills = 525882,
			damage = 50441,
			kills = 315,
			name = L"Ulx",
			exp = 5,
			db = 0,
			level = 40,
			career = 10,
			realm = 1,
		},
		
		{
			deaths = 14,
			renown = 0,
			healing = 0,
			soloKills = 0,
			damage = 227793,
			kills = 10,
			name = L"Tarones",
			exp = 0,
			db = 0,
			level = 40,
			career = 8,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 365949,
			soloKills = 86079,
			damage = 1801,
			kills = 317,
			name = L"Namajunas",
			exp = 0,
			db = 0,
			level = 40,
			career = 3,
			realm = 1,
		},
	},
	groupIconsPetBGColor = 
	{
		255,
		225,
		255,
	},
	unitFramesGroupsPadding1 = 20,
	scenarioInfoEnabled = false,
	combatLogTargetDefenseScale = 1,
	guardDistanceIndicatorClickThrough = false,
	groupIconsPetOffset = 
	{
		0,
		20,
	},
	combatLogIgnoreNpc = false,
	unitFramesGroupsDirection2 = 2,
	guardDistanceIndicatorMovable = true,
}




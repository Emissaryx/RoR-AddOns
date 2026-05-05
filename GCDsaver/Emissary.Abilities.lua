-- Emissary.Abilities.lua
Emissary = Emissary or {}
Emissary.Abilities = Emissary.Abilities or {}


-- 🔁 Flattens grouped ability tables into a set-style lookup table
local function FlattenAbilityTable(groupedTable)
    local flat = {}
    for _, group in ipairs(groupedTable) do
        if type(group) == "number" then
            flat[group] = true
        elseif type(group) == "table" then
            for _, id in ipairs(group) do
                flat[id] = true
            end
        end
    end
    return flat
end

Emissary.Execution = {
    [8087] = true, -- Trial by Pain -- Witch Hunter
    [8082] = true, -- Absolution -- Witch Hunter
    [9399] = true, -- Ruthless Assault -- Witch Elf
    [9404] = true, -- Heart Render Toxin -- Witch Elf
    [9410] = true -- Puncture -- Witch Elf
    -- ... add more ability IDs here
}

Emissary.Silence = {
    {1607, 3305, 20477, 20478}, -- Runepriest, Spellbinding Rune "Silence for 4 seconds"
    {8174, 20579}, -- Bright Wizard, Choking Smoke "AoE silence for 3 seconds"
    {8256, 20516, 20517}, -- Warrior Priest, Vow of Silence "Silence for 4 seconds"
    {8100, 20331}, -- Witch Hunter, Silence the Heretic "Silence for 3 seconds"
    {9253, 20495, 20496, 23139}, -- Archmage, Law of Gold "Silence for 5 seconds"
    {9095, 20396, 20397}, -- Shadow Warrior, Throat Shot "Silence for 4 seconds"
    {3958, 9177}, -- White Lion, Throat Bite "Silence for 4 seconds (pet)"
    {1683, 20148}, -- Black Orc, Shut Yer Face "Silence for 4 seconds"
    {1917, 3218, 20416, 20417}, -- Shaman, You Got Nuthin! "Silence for 5 seconds"
    {1839, 20345, 20346}, -- Squig Herder, Choking Arrer "Silence for 4 seconds"
    {9565, 20437, 20438}, -- Disciple of Khaine, Consume Thought "Silence for 4 seconds"
    {9489, 20539}, -- Sorcerer, Stricken Voices "AoE silence for 3 seconds"
    {3616, 9409, 20272}, -- Witch Elf, Throat Slitter "Silence for 3 seconds"
    {8565, 20456, 20457} -- Zealot, Tzeentch's Lash "Silence for 5 seconds"
}

Emissary.Root = {
    {608}, -- Tank, Champion's Challenge "Root for 10 seconds. Cannot be purged. M1 Tank"
    {9018, 20228}, -- Swordmaster, Aethyric Grasp "AoE root for 5 seconds"
    {10347}, -- Engineer, Restraining Shot "Root. Full Warlord Engineer"
    {1519, 20378}, -- Engineer, Barbed Wire "AoE root for 5 seconds"
    {9334, 20166}, -- Black Guard, Chains of Hatred "AoE root for 5 seconds"
    {8168, 20578}, -- Bright Wizard, Fire Cage "AoE Root for 5 seconds"
    {9477, 20538}, -- Sorcerer, Grip of Fear "AoE Root for 5 seconds"
    {1370}, -- Ironbreaker, Grip of Stone "AoE Root for 5 seconds"
    {8336, 20186}, -- Chosen, Petrify "AoE Root for 5 seconds"
    {8024, 20248}, -- Knight, Shackle "AoE Root for 5 seconds"
    {8480, 20559}, -- Magus, Tzeentch's Grasp "AoE Root for 5 seconds"
    {10361}, -- Magus, Tzeentch's Holding "Root for 10 seconds. Full Warlord Magus"
    {1681}, -- Black Orc, Where You Going? "AoE Root for 5 seconds"
    {9224}, -- White Lion, Ensnare "Root for 5 seconds. Purgeable. M1 White Lion"
    {8449}, -- Marauder, Flames of Fate "Root for 5 seconds. Purgeable. M1 Marauder"
    {1418} -- Ironbreaker, Rock Clutch "Root for 5 seconds. Purgeable. M1 Ironbreaker"
}

Emissary.KD = {
    {1755, 20598}, -- Choppa, Sit Down! "Unblockable KD for 3 seconds"
    {1536}, -- Engineer, Crack Shot "Disarm for 3 seconds"
    {1525}, -- Engineer, Self-destruct "AoE KD for 3 seconds"
    {1384, 13156, 20208}, -- Ironbreaker, Cave-In "KD for 3 seconds"
    {1369, 20209}, -- Ironbreaker, Shield of Reprisal "KD for 3 seconds"
    {1443, 20618}, -- Slayer, Incapacitate "Unblockable KD for 3 seconds"
    {8186}, -- Bright Wizard, Stop, Drop And Roll "KD for 3 seconds"
    {8018, 20250}, -- Knight, Smashing Counter "KD for 3 seconds"
    {8110}, -- Witch Hunter, Dragon Gun "KD for 3 seconds"
    {8115, 20332}, -- Witch Hunter, Pistol Whip "KD for 3 seconds"
    {8086, 20325, 20326}, -- Witch Hunter, Confess! "Disarm for 4 seconds"
    {3082, 9096}, -- Shadow Warrior, Eye Shot "KD for 3 seconds"
    {9108, 20404}, -- Shadow Warrior, Exploit Weakness "KD for 3 seconds"
    {3713, 9098, 20403}, -- Shadow Warrior, Opportunistic Strike "Disarm for 4 seconds"
    {3541, 9028}, -- Swordmaster, Crashing Wave "KD for 3 seconds"
    {3959}, -- White Lion, Brutal Pounce "Pet KD"
    {1688, 20147}, -- Black Orc, Down Ya Go "KD for 3 seconds"
    {1835}, -- Squig Herder, Not So Fast! "KD for 2 seconds"
    {3482, 9321, 20170, 20171}, -- Black Guard, Spiteful Slam "KD for 5 seconds"
    {2888}, -- Black Guard, Malignant Strike! "KD for 3 seconds"
    {9482, 20540}, -- Sorcerer, Frostbite "Disarm for 3 seconds"
    {9427}, -- Witch Elf, Heart Seeker "KD for 3 seconds"
    {3581, 3582, 3583, 3584, 3585, 9422}, -- Witch Elf, On Your Knees! "KD for 3 seconds"
    {3628, 9400, 12024, 20266, 20267}, -- Witch Elf, Sever Limb "Disarm for 4 seconds"
    {8346, 20188}, -- Chosen, Downfall "KD for 3 seconds"
    {8495}, -- Magus, Perils of the Warp "Disarm for 3 seconds"
    {8481}, -- Magus, Instability "AoE KD for 3 seconds"
    {8423, 20288}, -- Marauder, Concussive Jolt "AoE KD for 2 seconds"
    {8405, 20286} -- Marauder, Death Grip "Disarm for 4 seconds"
}

Emissary.Armor_Debuff = {
    {1371}, -- Ironbreaker, Stone Breaker "Armor debuff"
    {3061, 20328}, -- Witch Hunter, Burn Armor "AoE armor debuff"
    {9104, 20394}, -- Shadow Warrior, Acid Arrow "Armor debuff"
    {1666, 3058, 3373}, -- Black Orc, Wot Armor ? "Armor debuff"
    {9192}, -- White Lion, Force Opportunity "Armor debuff"
    {1823, 20343}, -- Squig Herder, What Blocka? "Armor debuff"
    {3481, 9329, 20162}, -- Black Guard, Horrific Wound "Armor debuff"
    {8418}, -- Marauder, Cutting Claw "Armor debuff"
    {8600}, -- Zealot, Sweeping Disgorgement "AoE armor debuff"
    {1638, 3471}, -- Runepriest, Concussive Runes "AoE armor debuff"
    {10145, 10146, 10147, 10148, 10149, 10150, 10151, 10152, 10153, 10154, 10155, 10596, 10570, 10571, 10572, 10573, 10574, 10575, 10576, 10577, 10578, 10578} -- Set/Equipment, Dissolve "Armor debuff from set/equipment"
}

Emissary.Stagger = {
    {1613, 3028, 20480}, -- Runepriest, Rune of Binding "Stagger for 6 seconds"
    {31, 3034}, -- Engineer, Detonation "AoE stagger for 3 seconds"
    {3030, 8038, 20249}, -- Knight, Heaven's Fury "AoE stagger for 3 seconds"
    {3033, 8094}, -- Witch Hunter, Declare Anathema "Stagger for 6 seconds (+ Retro Jump)"
    {3032, 9396}, -- Witch Elf, Agile Escape "Stagger for 6 seconds (+ Retro Jump)"
    {3031, 8349, 20189}, -- Chosen, Quake "AoE stagger for 3 seconds"
    {379, 383, 3067, 3149, 3167}, -- Magus, Detonation "AoE stagger for 3 seconds"
    {3027, 8571, 20461}, -- Zealot, Aethyric Shock "Stagger for 6 seconds"
    {24840} -- "Stagger for 6 seconds" (missing career and ability name)
}

-- Challenge abilities reformatted for GCDsaver.Settings.Abilities
Emissary.Challenge = {
    -- Challenge Abilityid and Class
    [1368] = true,	-- Ironbreaker
    [1679] = true,	-- Blackorc
    [8021] = true,	-- Knight
    [8333] = true,	-- Chosen
    [9013] = true,	-- Swordmaster
    [9332] = true	-- Blackguard
    }	

-- Snare abilities reformatted for GCDsaver.Settings.Abilities
Emissary.Snares = {
    -- Ironbreaker
    [1387] = true,	-- Earthshatter "AoE slow of 40%"
    [20207] = true,	-- Earthshatter "AoE slow of 40%"
    [1358] = true,	-- Binding Grudge "Slow of 40%"

    -- Engineer
    [1509] = true,	-- Spanner Swipe "Slow of 40%"
    [20380] = true,	-- Spanner Swipe "Slow of 40%"
	
	-- Slayer
    [1463] = true,	-- No Escape "AoE slow of 10% to 40%"
    [3319] = true,	-- No Escape "AoE slow of 10% to 40%"
    [20617] = true,	-- No Escape "AoE slow of 10% to 40%"
    [1432] = true,	-- Slow Down "Slow of 40%"
    [3311] = true,	-- Slow Down "Slow of 40%"

    -- Bright Wizard
    [3438] = true,	-- Withering Heat "Slow of 40%"
    [8185] = true,	-- Withering Heat "Slow of 40%"

    -- Knight
    [8012] = true,	-- Crippling Blow "Slow of 40%"
    [20243] = true,	-- Crippling Blow "Slow of 40%"

    -- Warrior Priest
    [8255] = true,	-- Weight of Guilt "Slow of 40%"
    [20511] = true,	-- Judgement "Slow of 20%"

    -- Witch Hunter
    [8080] = true,	-- Snap Shot "Slow of 40%"
    [20327] = true,	-- Snap Shot "Slow of 40%"

    -- Archmage
    [9251] = true,	-- Mistress of the Marsh "AoE slow of 40%"
    [9255] = true,	-- Wind Blast "Punt + Slow of 40%"

    -- Shadow Warrior
    [2711] = true,	-- Ambush "AoE slow of 60% (M2)"
    [9092] = true,	-- Whirling Pin "AoE slow of 40% (+ Retro jump)"
    [20398] = true,	-- Whirling Pin "AoE slow of 40% (+ Retro jump)"
    [3012] = true,	-- Takedown "Slow of 40%"
    [3565] = true,	-- Takedown "Slow of 40%"
    [9087] = true,	-- Takedown "Slow of 40%"
    [20393] = true,	-- Takedown "Slow of 40%"

    -- Swordmaster
    [9004] = true,	-- Quick Incision "Slow of 40%"
    [9057] = true,	-- Wings of Heaven "AoE slow of 60% (M1)"

    -- White Lion
    [3280] = true,	-- Cleave Limb "Slow of 40%"
    [9170] = true,	-- Cleave Limb "Slow of 40%"
    [20306] = true,	-- Cleave Limb "Slow of 40%"

    -- Black Orc
    [1670] = true,	-- Trip 'Em Up "Slow of 40%"
    [20144] = true,	-- Trip 'Em Up "Slow of 40%"
    [1718] = true,	-- Big Brawlin' "Slow of 20%"
    [3465] = true,	-- Big Brawlin' "Slow of 20%"

    -- Shaman
    [1914] = true,	-- Eeeek! "Punt + slow of 40%"
    [20420] = true,	-- Eeeek! "Punt + slow of 40%"
    [1927] = true,	-- Sticky Feetz "AoE slow of 40%"
    [3275] = true,	-- Sticky Feetz "AoE slow of 40%"

    -- Squig Herder
    [1825] = true,	-- Stop Runnin! "Slow of 40%"
    [20344] = true,	-- Stop Runnin! "Slow of 40%"
    [2] = true,	    -- Big Claw "Slow of 40%"
    [20362] = true,	-- Big Claw "Slow of 40%"
    [1878] = true,	-- Squig Goo "AoE slow of 60% (M2)"
    [1831] = true,	-- Sticky Squigz "AoE slow of 40% (+ Retro jump)"
    [20351] = true,	-- Sticky Squigz "AoE slow of 40% (+ Retro jump)"

    -- Black Guard
    [9318] = true,	-- Crippling Anger "Slow of 40%"
    [9348] = true,	-- Wave of Scorn "AoE slow of 40%"

    -- Disciple of Khaine
    [3696] = true,	-- Covenant of Celerity "Slow of 20%"
    [9568] = true,	-- Fist of Khaine "Slow of 20%"
    [23064] = true,	-- Fist of Khaine "Slow of 20%"
    [9549] = true,	-- Flay "Slow of 40%"
    [23151] = true,	-- Flay "Slow of 40%"

    -- Sorcerer
    [9479] = true,	-- Arctic Blast "Slow of 40%"
    [20537] = true,	-- Arctic Blast "Slow of 40%"
	
	-- Witch Elf
    [9394] = true,	-- Throwing Dagger "Slow of 40%"
    [20268] = true,	-- Throwing Dagger "Slow of 40%"

    -- Chosen
    [8324] = true,	-- Dizzying Blow "Slow of 40%"

    -- Magus
    [8527] = true,	-- Grasping Darkess "Slow of 60% (M1)"
    [3946] = true,	-- Chaotic Rift "AoE pull + slow of 40%"
    [8499] = true,	-- Chaotic Rift "AoE pull + slow of 40%"
    [8484] = true,	-- Daemonic Maw "Slow of 40%"
    [8498] = true,	-- Tzeentch's Firestorm "AoE slow of 20%"

    -- Engineer
    [1542] = true,	-- Electromagnet "AoE pull + slow of 40%"
    [1541] = true,	-- Phosphorous Shells "AoE slow of 20%"
    [3221] = true,	-- Phosphorous Shells "AoE slow of 20%"
    [20374] = true,	-- Phosphorous Shells "AoE slow of 20%"

    -- Marauder
    [8396] = true,	-- Debilitate "Slow of 40%"

    -- Zealot
    [2871] = true,	-- Storm of Ravens "Slow of 40%"
    [8576] = true,	-- Storm of Ravens "Slow of 40%"

    -- Runepriest
    [1614] = true,	-- Rune of Burning "Slow of 40%"
    [2740] = true,	-- Rune of Burning "Slow of 40%"
    [1628] = true,	-- Sundered Motion "Slow of 40%"
    [3981] = true,	-- Sundered Motion "Slow of 40%"
    [1635] = true,	-- Immolating Grasp "Slow of 40%"
    [3500] = true,	-- Immolating Grasp "Slow of 40%"

    -- Ironbreaker
    [1407] = true,	-- Powered Etchings "AoE punt + slow of 40%"

    -- Choppa
    [1744] = true,	-- Don't go nowhere "Slow of 40%"
    [3289] = true,	-- Don't go nowhere "Slow of 40%"
    [1774] = true,	-- Choppa, Wot's Da Rush ? "AoE slow between 10% and 40%"
    [3302] = true,	-- Choppa, Wot's Da Rush ? "AoE slow between 10% and 40%"
    [20599] = true	-- Choppa, Wot's Da Rush ? "AoE slow between 10% and 40%"
    }	


Emissary.Detaunt = {
        {1595}, -- Rune Priest, Rune of Preservation "Reduces the target's damage on the Rune Priest"
        {1592}, -- Rune Priest, Grimnir's Shield "Reduces all damage on the Rune Priest"
        {1516, 20373}, -- Engineer, Addling Shot "Reduces the target's damage on the Engineer"
        {1441}, -- Slayer, Distracting Roar "Reduces the target's damage on the Slayer"
        {8162}, -- Bright Wizard, Smoke Screen "Reduces the target's damage on the Bright Wizard"
        {8245}, -- Warrior Priest, Repent "Reduces the target's damage on the Warrior Priest"
        {8088}, -- Witch Hunter, Get Thee Behind Me! "Reduces the target's damage on the Witch Hunter"
        {9256}, -- Archmage, Dissipating Hatred "Reduces the target's damage on the Archmage"
        {3559, 9265}, -- Archmage, Walk Between Worlds "Reduces the target's damage on the Archmage"
        {9089}, -- Shadow Warrior, Distracting Shot "Reduces the target's damage on the Shadow Warrior"
        {9169}, -- White Lion, Submission "Reduces the target's damage on the White Lion"
        {1918}, -- Shaman, Look Over There! "Reduces the target's damage on the Shaman"
        {1915, 3863}, -- Shaman, Stop Hittin' me! "Reduces the target's damage on the Shaman"
        {760}, -- Shaman, Whazat Behind You?! "Reduces the target's damage on the Shaman"
        {1827, 20354}, -- Squig Herder, Don't Eat Me "Reduces the target's damage on the Squig Herder"
        {1753}, -- Choppa, Outta My Face! "Reduces the target's damage on the Choppa"
        {3046, 9555}, -- Disciple of Khaine, Terrifying Vision "Reduces the target's damage on the Disciple of Khaine"
        {9474}, -- Sorcerer, Dread Aspect "Reduces the target's damage on the Sorcerer"
        {9392}, -- Witch Elf, Enchanting Beauty "Reduces the target's damage on the Witch Elf"
        {8477}, -- Magus, Horrifying Visions "Reduces the target's damage on the Magus"
        {8402}, -- Marauder, Wave of Horror "Reduces the target's damage on the Marauder"
        {8621}, -- Zealot, Chaotic Blur "Reduces the target's damage on the Zealot"
        {8622, 20460} -- Zealot, Embrace the Warp "Reduces all damage on the Zealot"
    }
	
Emissary.Outgoinghealdebuff = {
        {1410, 3166}, -- Iron Breaker, Punishing Knock "Debuff outgoing heal by 50%"
        {9191}, -- White Lion, Thin the Herd "Debuff outgoing heal by 50%"
        {1773}, -- Choppa, No More Helpin' "Debuff outgoing heal by 50%"
        {9373}, -- Black Guard, Soul Killer "Debuff outgoing heal by 50%"
        {3002, 3784}, -- Witch Hunter, Blessed Bullets of Confession "Debuff outgoing heal by 50%"
        {3811, 20263} -- Witch Elf, Kiss of Death "Debuff outgoing heal by 50%"
    }

Emissary.Incominghealdebuff = {
        {1434, 12692}, -- Slayer, Deep Wound "Debuff incoming heal by 50%"
        {3569, 8184, 20577}, -- Bright Wizard, Playing With Fire "Debuff incoming heal by 50%"
        {8270}, -- Warrior Priest, Absence of Faith "Debuff incoming heal by 50%"
        {8112, 20324}, -- Witch Hunter, Punish the False "Debuff incoming heal by 50%"
        {3915, 9247}, -- Archmage, Scatter the Winds "Debuff incoming heal by 50%"
        {9109}, -- Shadow Warrior, Shadow Sting "Debuff incoming heal by 50%"
        {1905, 3352}, -- Shaman, Gork's Barbs "Debuff incoming heal by 50%"
        {1853}, -- Squig Herder, Rotten Arrer "Debuff incoming heal by 50%"
        {3428, 9602}, -- Disciple of Khaine, Curse of Khaine "Debuff incoming heal by 50% on critical hit"
        {9424}, -- Witch Elf, Black Lotus Blade "Debuff incoming heal by 50%"
        {8401, 8440}, -- Marauder, Tainted Claw "Debuff incoming heal by 25% (50% with tactic)"
        {3075, 8596}, -- Zealot, Changer's Touch "Debuff incoming heal by 50% on critical hit"
        {1633, 3393}, -- Runepriest, Rune of Nullification "Debuff incoming heal by 50% on critical hit"
        {1746, 3292, 20593} -- Choppa, Can't Stop Da Chop "Debuff incoming heal by 50%"
    }
	
Emissary.Guard = {
        {1363}, -- Guard, Iron Breaker "Divides the damage in half between the guard and the guarded ally"
        {1674}, -- Save Da Runts, Black Orc "Divides the damage in half between the guard and the guarded ally"
        {8013}, -- Guard, Knight "Divides the damage in half between the guard and the guarded ally"
        {8325}, -- Guard, Chosen "Divides the damage in half between the guard and the guarded ally"
        {9008}, -- Guard, Sword Master "Divides the damage in half between the guard and the guarded ally"
        {9325}  -- Guard, Black Guard "Divides the damage in half between the guard and the guarded ally"
    }
	
	-- 🔄 Convert grouped lists to flat lookup tables
Emissary.Silence              = FlattenAbilityTable(Emissary.Silence)
Emissary.Root                 = FlattenAbilityTable(Emissary.Root)
Emissary.KD                   = FlattenAbilityTable(Emissary.KD)
Emissary.Stagger              = FlattenAbilityTable(Emissary.Stagger)
Emissary.Detaunt              = FlattenAbilityTable(Emissary.Detaunt)
Emissary.Armor_Debuff         = FlattenAbilityTable(Emissary.Armor_Debuff)
Emissary.Incominghealdebuff   = FlattenAbilityTable(Emissary.Incominghealdebuff)
Emissary.Outgoinghealdebuff   = FlattenAbilityTable(Emissary.Outgoinghealdebuff)
Emissary.Guard                = FlattenAbilityTable(Emissary.Guard)

Emissary.SnaresByIcon = {}

for abilityId in pairs(Emissary.Snares) do
    local data = GetAbilityData(abilityId)
    if data and data.iconNum then
        Emissary.SnaresByIcon[data.iconNum] = true
    end
end

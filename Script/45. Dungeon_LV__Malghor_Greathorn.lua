local muskID = 59465      -- Writhing Musk cloud creature ID
local muskID2 = 59469     -- Writhing Musk that is Spawned and moves to random target         
local bossID = 6821       -- Malghor Greathorn (boss)
local bossInCombat = false -- Tracks whether the boss is in combat
local bosshatesme = 10000 -- Hatred added from Musk
local bosshateReset = 9000 -- Hatred added when boss resets aggro
local prange = 4800 -- Range for boss interactions
local muskrangecheck = 80 -- Range for Musk detection
local musktimercheck = 250 -- Timer check for Musk
local hatredResetTimer = 20000 -- Boss aggro reset every 20s
local hatredEventID = nil -- Stores the boss hatred reset event ID
local spawnedMusks = {} -- Table to track spawned Musk clouds

-- Writhing Musk (59465) Spawn Locations in Zone 260
local muskSpawnLocations = {
    {x = 1399913, y = 1582979, z = 7798, o = 2446},
    {x = 1399908, y = 1582626, z = 7840, o = 2764},
    {x = 1399838, y = 1583283, z = 7848, o = 2924},
    {x = 1399616, y = 1583005, z = 7872, o = 2696},
    {x = 1399488, y = 1583153, z = 7900, o = 2798},
    {x = 1399430, y = 1581791, z = 7903, o = 3169},
    {x = 1399133, y = 1582167, z = 7898, o = 3128},
    {x = 1400411, y = 1581590, z = 8083, o = 3605},
    {x = 1400522, y = 1582480, z = 7933, o = 3379},
    {x = 1400448, y = 1583460, z = 7816, o = 910},
    {x = 1400110, y = 1583241, z = 7838, o = 2463},
    {x = 1401448, y = 1583787, z = 7896, o = 2636},
    {x = 1402051, y = 1583313, z = 7944, o = 3393},
    {x = 1401879, y = 1583573, z = 7938, o = 3236},
    {x = 1402566, y = 1583190, z = 8032, o = 2243},
    {x = 1402269, y = 1582759, z = 8018, o = 200},
    {x = 1401556, y = 1583945, z = 7936, o = 265},
    {x = 1401643, y = 1583030, z = 7898, o = 604},
    {x = 1401545, y = 1583382, z = 7874, o = 139},
    {x = 1402873, y = 1582425, z = 8188, o = 422},
    {x = 1402066, y = 1582670, z = 7996, o = 398},
    {x = 1400994, y = 1582726, z = 7923, o = 68},
    {x = 1399344, y = 1582380, z = 7854, o = 3424},
    {x = 1401339, y = 1581613, z = 8177, o = 2343},
    {x = 1400731, y = 1582068, z = 8031, o = 2514},
    {x = 1401481, y = 1581231, z = 8265, o = 216},
    {x = 1400061, y = 1581825, z = 7971, o = 4039},
    {x = 1401361, y = 1580959, z = 8300, o = 1695},
    {x = 1400757, y = 1581512, z = 8129, o = 1115},
    {x = 1402526, y = 1582939, z = 8028, o = 1194},
    {x = 1401307, y = 1582084, z = 8067, o = 2321},
    {x = 1401870, y = 1581003, z = 8344, o = 22},
    {x = 1402785, y = 1582315, z = 8190, o = 1115},
    {x = 1400652, y = 1582721, z = 7893, o = 2184},
    {x = 1402407, y = 1582240, z = 8088, o = 1558},
    {x = 1401677, y = 1581474, z = 8229, o = 11},
    {x = 1400195, y = 1581894, z = 7981, o = 3868},
    {x = 1400353, y = 1583139, z = 7824, o = 3686},
    {x = 1401214, y = 1582679, z = 7947, o = 2343},
    {x = 1402537, y = 1582086, z = 8188, o = 1308},
    {x = 1399827, y = 1582372, z = 7854, o = 3424},
    {x = 1400523, y = 1581889, z = 8023, o = 3868},
    {x = 1399938, y = 1581937, z = 7920, o = 4039},
    {x = 1399606, y = 1582523, z = 7850, o = 3424},
    {x = 1400430, y = 1582200, z = 8008, o = 3868},
}

-- Function to generate circle points around the boss
local function GetCirclePoints(centerX, centerY, centerZ, radius, numPoints)
    local points = {}
    local angleStep = 2 * math.pi / numPoints
    for i = 0, numPoints - 1 do
        local angle = i * angleStep
        local x = centerX + radius * math.cos(angle)
        local y = centerY + radius * math.sin(angle)
        table.insert(points, {x = x, y = y, z = centerZ})
    end
    return points
end

-- Function to spawn moving Musk at health thresholds in a circle
local function SpawnMuskAtHealthThreshold(creature)
    if not bossInCombat then return end

    -- Get players in range
    local players = creature:GetPlayersInRange(prange, 0, 1)
    if #players == 0 then return end  -- No players available

    -- Spawn musks in a circle around the boss
    local muskPositions = GetCirclePoints(creature:GetX(), creature:GetY(), creature:GetZ(), 400, 6) -- 6 Musk spawns around boss at 400 radius

    for _, pos in ipairs(muskPositions) do
        local musk = creature:SpawnCreature(muskID2, pos.x, pos.y, pos.z, 0, 5, 540000) -- 9 min despawn timer, instant despawn on death
        if musk then
            -- Select a random player to move towards
            local targetPlayer = players[math.random(#players)]

            -- Ensure Musk waits a short moment before moving (avoids AI issues)
            musk:RegisterEvent(function()
                musk:MoveFollow(targetPlayer, nil)
                --creature:Say("DEBUG: Spawned Moving Musk at " .. creature:GetHealthPct() .. "% targeting " .. targetPlayer:GetName())
            end, 2000, 1) -- 2s delay before moving
        end
    end
end

--[[ 
    ### Checks if a Musk Cloud Exists at a Specific Location ###
    
    Iterates over all existing Musk clouds within a specified range and determines 
    if one already exists at the given coordinates.

    @param creature (Creature) - The entity performing the check (typically the boss).
    @param x (float) - X coordinate of the location to check.
    @param y (float) - Y coordinate of the location to check.
    @param z (float) - Z coordinate of the location to check.

    @return (boolean) - Returns `true` if a Musk cloud is present, `false` otherwise.
]]
local function IsMuskAtLocation(creature, x, y, z)
    local musks = creature:GetCreaturesInRange(prange, muskID, 0, 1) -- Check for existing Musks
    for _, musk in ipairs(musks) do
        if musk:GetX() == x and musk:GetY() == y and musk:GetZ() == z then
            return true -- A Musk cloud is already at this location
        end
    end
    return false -- No Musk cloud found at this location
end


--[[ 
    ### Respawn Missing Musk Clouds ###
    
    Ensures that all predefined Musk cloud locations are occupied. If a Musk is missing
    from any of the spawn points, a new one is created.

    @param creature (Creature) - The boss responsible for managing Musk spawns.
]]
local function RespawnMissingMusks(creature)
    local count = 0  -- Tracks how many Musks were respawned

    for _, loc in ipairs(muskSpawnLocations) do
        -- Check if a Musk is already present at this location
        if not IsMuskAtLocation(creature, loc.x, loc.y, loc.z) then
            local musk = creature:SpawnCreature(muskID, loc.x, loc.y, loc.z, loc.o, 2, 600000) -- 10-minute duration
            if musk then
                table.insert(spawnedMusks, musk) -- Track newly spawned Musks
                count = count + 1
            end
        end
    end

    -- Debugging Output
   -- creature:Say("DEBUG: Respawned " .. count .. " missing Musk clouds.")
end


--- 
-- Checks Nearby Players, Applies Hatred, and Casts an Ability 
-- This function runs periodically for each Musk cloud in the encounter.
-- If a player steps into the Musk, it triggers Malghor's aggression.
--
-- @param eventId (integer) - Unique event ID assigned to this periodic check.
-- @param taskDelay (integer) - Delay (ms) before the event executes.
-- @param repeatsLeft (integer) - Remaining iterations for the event (-1 for infinite).
-- @param _worldObject (WorldObject) - The Musk cloud entity performing the check.
---
local function CheckNearbyPlayers(eventId, taskDelay, repeatsLeft, _worldObject)
    local creature = _worldObject:ToCreature()
    if not creature then return end  -- Ensure the Musk cloud still exists

    -- **Find the nearest player within detection range**
    local nearestPlayer = creature:GetNearestPlayer(muskrangecheck)

    if nearestPlayer then
        -- **Locate Malghor Greathorn within range**
        local boss = creature:GetNearestCreature(prange, bossID)

        -- **If the boss is in combat, apply hatred, cast ability, and destroy Musk**
        if boss and bossInCombat then
            -- **Apply Hatred to the Player**
            boss:AddHatred(nearestPlayer, bosshatesme)

            -- **Notify all players in range about the event**
            local muskMessage = "Malghor smells Musk on " .. nearestPlayer:GetName() .. "!"

            for player in creature.PlayersInRange do
                player:SendLocalizeString(muskMessage, SystemData.ChatLogFilters.C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
                player:SendLocalizeString(muskMessage, SystemData.ChatLogFilters.CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
            end

            -- **Cast Ability 4413 on the Player**
            boss:AddAbility(4413, nearestPlayer)

            -- **Apply Visual Effect to the Player**
            nearestPlayer:PlayEffect(3936) 

            -- **Stop checking further and destroy Musk cloud**
            creature:RemoveEventById(eventId)
            creature:Destroy()
        end
    end
end

--[[ 
    ### Musk Activation on Spawn ###
    
    When a Musk cloud spawns, it starts continuously checking for nearby players.
    If a player steps into its detection radius, the Musk will apply hatred and trigger boss mechanics.
    
    @param creature (Creature) - The Musk cloud instance that has spawned.
]]
local function OnMuskSpawn(creature)
    -- Start checking for nearby players at fixed intervals
    creature:RegisterEvent(CheckNearbyPlayers, musktimercheck, 0)
end


--[[  
    ### Resets the Boss's Hatred and Chooses a New Target ###

    This function clears Malghor Greathorn's hatred list and selects a new random target 
    from players in range. The selected player will receive increased threat, and all players 
    will be notified of Malghor's shift in aggression.

    @param eventId (integer) - The event ID associated with this function call.
    @param delay (integer) - The delay before execution (in milliseconds).
    @param repeats (integer) - The number of times this event repeats (-1 for infinite).
    @param creature (Creature) - The boss (Malghor Greathorn) executing the hatred reset.
]]
local function ResetBossHatred(eventId, delay, repeats, creature)
    -- **Ensure valid boss reference and that it is in combat**
    if not creature or not bossInCombat then return end

    -- **Clear all existing hatred**
    creature:ClearHatredList()

    -- **Retrieve all players within range**
    local playersInRange = creature:GetPlayersInRange(prange, 0, 1)
    local numPlayers = playersInRange and #playersInRange or 0

    -- **Choose a new target if players are available**
    if numPlayers > 0 then
        local randomIndex = math.random(1, numPlayers)
        local chosenPlayer = playersInRange[randomIndex]

        -- **Apply hatred towards the chosen player**
        creature:AddHatred(chosenPlayer, bosshateReset)

        -- **Notify all players in the area about the hatred shift**
        for player in creature.PlayersInRange do
            local hatredMessage = "Malghor changes his target to " .. chosenPlayer:GetName() .. "!"

            player:SendLocalizeString(hatredMessage, SystemData.ChatLogFilters.C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)
            player:SendLocalizeString(hatredMessage, SystemData.ChatLogFilters.CSR_TELL_RECEIVE, Localized_text.CHAT_TAG_DEFAULT)
        end
    end
end

--[[ 
    ### Boss Health-Based Mechanics ###
    
    This function triggers at predefined health thresholds to spawn moving Musk clouds.
    
    **Health Stages & Effects:**
    - **80%** - First wave of Musk clouds
    - **60%** - Second wave
    - **40%** - Third wave
    - **20%** - Final wave
    
    @param creature (Creature) - The boss receiving damage.
    @param attacker (Unit) - The player or entity dealing the damage.
    @param damage (integer) - The amount of damage taken.
]]
local function OnMalgorReceiveDamage(creature, attacker, damage)
    local currentStage = creature:GetState("STAGE")

    -- Check each health threshold and trigger Musk spawn mechanics
    if currentStage == 0 and creature:HealthBelowPct(81) then
        creature:SetState("STAGE", 1)
        SpawnMuskAtHealthThreshold(creature) -- First wave at 80%

    elseif currentStage == 1 and creature:HealthBelowPct(61) then
        creature:SetState("STAGE", 2)
        SpawnMuskAtHealthThreshold(creature) -- Second wave at 60%

    elseif currentStage == 2 and creature:HealthBelowPct(41) then
        creature:SetState("STAGE", 3)
        SpawnMuskAtHealthThreshold(creature) -- Third wave at 40%

    elseif currentStage == 3 and creature:HealthBelowPct(21) then
        creature:SetState("STAGE", 4)
        SpawnMuskAtHealthThreshold(creature) -- Final wave at 20%
    end
end

--[[ 
    Handles the full cleanup of the encounter. 
    - Resets boss state and hatred tracking.
    - Removes active events and resets hatred.
    - Destroys all remaining Musk clouds (static & moving).
    - Removes Ability 4413 from all players in range.

    @param creature (Creature) - The boss entity triggering the cleanup.
]]
local function CleanupEncounter(creature)
    if not creature then return end -- Prevent errors if creature is nil

    -- Reset boss combat state
    bossInCombat = false
    creature:SetState("STAGE", 0)

    -- Remove hatred reset event if it is still active
    if hatredEventID then
        creature:RemoveEventById(hatredEventID)
        hatredEventID = nil
    end

    -- Clear hatred list to reset boss threat
    creature:ClearHatredList()

    -- **Destroy ALL remaining Musks (static & moving)**
    local musks = creature:GetCreaturesInRange(prange, muskID, 0, 1)
    local movingMusks = creature:GetCreaturesInRange(prange, muskID2, 0, 1)

    for _, musk in ipairs(musks) do
        if musk then musk:Destroy() end
    end

    for _, musk in ipairs(movingMusks) do
        if musk then musk:Destroy() end
    end

    -- **Remove Ability 4413 from all players in range**
    local playersInRange = creature:GetPlayersInRange(prange, 0, 1)
    for _, player in ipairs(playersInRange) do
        if player then
            player:RemoveAbility(4413)
           -- creature:Say("DEBUG: Removed Ability 4413 from " .. player:GetName() .. ".")
        end
    end
end

--[[ 
    Handles the boss entering combat. 
    - Resets stage tracking and marks boss as in combat.
    - Ensures all Musks are present by respawning any missing ones.
    - Starts the periodic hatred reset event.

    @param creature (Creature) - The boss entering combat.
    @param attacker (Player) - The player who engaged the boss.
]]
local function OnBossEnterCombat(creature, attacker)
    if not creature then return end

    -- Reset boss state tracking
    creature:SetState("STAGE", 0)
    bossInCombat = true

    -- Debug message to confirm combat start
   -- creature:Say("DEBUG: Boss entered combat. Starting hatred reset event.")

    -- Ensure all Musks are spawned
    RespawnMissingMusks(creature)

    -- Start the periodic hatred reset event (every 20 seconds)
    hatredEventID = creature:RegisterEvent(ResetBossHatred, hatredResetTimer, 0)
end

--[[ 
    Handles the boss leaving combat (resetting or wiping). 
    - Cleans up the encounter.
    - Ensures all Musks are restored to their designated spawn locations.

    @param creature (Creature) - The boss leaving combat.
]]
local function OnBossLeaveCombat(creature)
    if not creature then return end

    -- Clean up encounter state
    CleanupEncounter(creature)

    -- Restore missing Musks
    RespawnMissingMusks(creature)
end

--[[ 
    Handles the boss's death. 
    - Cleans up the encounter completely.

    @param creature (Creature) - The boss that died.
    @param killer (Player or NPC) - The entity responsible for the boss's death.
]]
local function OnBossDie(creature, killer)
    if not creature then return end

    -- Fully reset encounter
    CleanupEncounter(creature)
end

--[[ 
    Handles the boss spawning into the world. 
    - Ensures all static Musks are properly present at their spawn points.

    @param creature (Creature) - The boss that spawned.
]]
local function OnBossSpawn(creature)
    if not creature then return end

    -- Ensure all static Musk clouds exist at their designated locations
    RespawnMissingMusks(creature)
end

--[[ 
    ### Event Registration ###
    
    This section registers all key events related to:
    - **Musk Clouds:** Handles spawn detection and event interactions.
    - **Boss Behavior:** Tracks health stages, combat transitions, and encounter cleanup.
    
    **Event List:**
    - `OnSpawn` → Initializes Musk Clouds when they appear.
    - `OnReceiveDamage` → Triggers phase-based mechanics.
    - `OnEnterCombat` / `OnLeaveCombat` → Manages boss fight state.
    - `OnDie` → Ensures full cleanup of the encounter.
]]

-- Register Musk Cloud events
RegisterCreatureEvent(muskID, CreatureEvent.OnSpawn, OnMuskSpawn)      -- Static Musk Clouds
RegisterCreatureEvent(muskID2, CreatureEvent.OnSpawn, OnMuskSpawn)    -- Moving Musk Clouds

-- Register Boss events
RegisterCreatureEvent(bossID, CreatureEvent.OnReceiveDamage, OnMalgorReceiveDamage)  -- Handles health-based mechanics
RegisterCreatureEvent(bossID, CreatureEvent.OnSpawn, OnBossSpawn)                    -- Ensures static Musk Clouds exist
RegisterCreatureEvent(bossID, CreatureEvent.OnEnterCombat, OnBossEnterCombat)        -- Initializes combat state and timers
RegisterCreatureEvent(bossID, CreatureEvent.OnLeaveCombat, OnBossLeaveCombat)        -- Cleans up encounter on reset/wipe
RegisterCreatureEvent(bossID, CreatureEvent.OnDie, OnBossDie)                        -- Full encounter reset on boss death
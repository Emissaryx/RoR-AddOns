-- GCDsaverAPI.lua
GCDsaverAPI = {}

-- 🔄 Localized globals for performance
local type        = type
local pairs       = pairs
local ipairs      = ipairs
local tostring    = tostring
local tonumber    = tonumber
local string_find = string.find
local string_fmt  = string.format
local math_floor  = math.floor

-- 🔧 Game API functions
local GetBuffs         = GetBuffs
local GetAbilityData   = GetAbilityData
local GetHotbarData    = GetHotbarData
local GetCareerResource = GetCareerResource
local GetComputerTime  = GetComputerTime
local GetTodaysDate    = GetTodaysDate
local GetNumGroupmates = GetNumGroupmates
local IsAbilityEnabled = IsAbilityEnabled
local IsWarBandActive  = IsWarBandActive
local BroadcastEvent   = BroadcastEvent
local TextLogAddEntry  = TextLogAddEntry

local MAX_BUFF_CACHE_ENTRIES = 300

-------------------------------------------------------
GCDsaverAPI.PARAMS          = {
        ability     = "abilityId",
        item        = "itemId",
        target      = "target",
        stack       = "stackCount",
        self        = "onlySelf",
        mechanic    = "mechanic",
        cd          = "virtualCooldown",
        need        = "need",
		check       = "check",
        effect      = "effect",
        condition   = "condition",
        hp          = "hp",
        hpPercent   = "hpPercent",
        ap          = "ap",
        career      = "career",
        archetype   = "archetype",
        duration    = "duration",
        text        = "text",
        tier		= "tier"
    }
	
GCDsaverAPI.BuffBehavior = {
    [GameData.CareerLine.ENGINEER] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.SHADOW_WARRIOR] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.SQUIG_HERDER] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.IRON_BREAKER] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.BLACKGUARD] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.SWORDMASTER] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.BLACK_ORC] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.KNIGHT] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.CHOSEN] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.WITCH_HUNTER] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.WITCH_ELF] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.WHITE_LION] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.MARAUDER] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.SLAYER] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.CHOPPA] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.ARCHMAGE] = { checkHostile = false, checkFriendly = true, checkSelf = true },
    [GameData.CareerLine.SHAMAN] = { checkHostile = false, checkFriendly = true, checkSelf = true },
    [GameData.CareerLine.RUNE_PRIEST] = { checkHostile = false, checkFriendly = true, checkSelf = true },
    [GameData.CareerLine.ZEALOT] = { checkHostile = false, checkFriendly = true, checkSelf = true },
    [GameData.CareerLine.BRIGHT_WIZARD] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.SORCERER] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.MAGUS] = { checkHostile = true, checkFriendly = false, checkSelf = false },
    [GameData.CareerLine.WARRIOR_PRIEST] = { checkHostile = true, checkFriendly = true, checkSelf = true },
    [GameData.CareerLine.DISCIPLE] = { checkHostile = false, checkFriendly = true, checkSelf = true }
}
    
GCDsaverAPI.careerDB = {
    -- Ranged physical DPS
    en  = GameData.CareerLine.ENGINEER,
    sw  = GameData.CareerLine.SHADOW_WARRIOR,
    sh  = GameData.CareerLine.SQUIG_HERDER,
    
    -- Tank
    ib  = GameData.CareerLine.IRON_BREAKER,
    bg  = GameData.CareerLine.BLACKGUARD,
    sm  = GameData.CareerLine.SWORDMASTER,
    bo  = GameData.CareerLine.BLACK_ORC,
    kbs = GameData.CareerLine.KNIGHT,
    chs = GameData.CareerLine.CHOSEN,
    
    -- Melee DPS
    wh  = GameData.CareerLine.WITCH_HUNTER,
    we  = GameData.CareerLine.WITCH_ELF,
    wl  = GameData.CareerLine.WHITE_LION,
    ma  = GameData.CareerLine.MARAUDER,
    sl  = GameData.CareerLine.SLAYER,
    chp = GameData.CareerLine.CHOPPA,
    
    -- Ranged support
    am  = GameData.CareerLine.ARCHMAGE,
    sha = GameData.CareerLine.SHAMAN,
    rp  = GameData.CareerLine.RUNE_PRIEST,
    zlt = GameData.CareerLine.ZEALOT,
    
    -- Ranged magical DPS
    bw  = GameData.CareerLine.BRIGHT_WIZARD,
    sor = GameData.CareerLine.SORCERER,
    mag = GameData.CareerLine.MAGUS,
    
    -- Melee support
    wp  = GameData.CareerLine.WARRIOR_PRIEST,
    dok = GameData.CareerLine.DISCIPLE,
    
    -- Other
    npc = 0,
    obj = -1
}

GCDsaverAPI.TARGET = {
    PLAYER  = "p",
    FRIEND  = "f",
    ENEMY   = "e"
}

GCDsaverAPI.ABILITYTYPE = {
    STANDARD    = GameData.AbilityType.STANDARD,
    MORALE      = GameData.AbilityType.MORALE,
    TACTIC      = GameData.AbilityType.TACTIC,    
    GRANTED     = GameData.AbilityType.GRANTED,
    PET         = GameData.AbilityType.PET,
    PASSIVE     = GameData.AbilityType.PASSIVE,
    GUILD       = GameData.AbilityType.GUILD
}

GCDsaverAPI.CONDITIONS = {
    heal    = "isHealing",
    dbuf    = "isDebuff",
    buf     = "isBuff",
    def     = "isDefensive",
    off     = "isOffensive",
    dam     = "isDamaging",
    sbuf    = "isStatsBuff",
    hex     = "isHex",
    cur     = "isCurse",
    crip    = "isCripple",
    ail     = "isAilment",
    bols    = "isBolster",
    aug     = "isAugmentation",
    bless   = "isBlessing",
    ench    = "isEnchantment",
    unst    = "isUnstoppable",
    imm     = "isImmovable",
    sna     = "isSnared",
    roo     = "isRooted",
    det     = "isDetaunted",
    mou     = "isMounted"
}

-- 🔗 Map of actionId → iconNum
local abilityToBuffIcon = {
    [8271] = 7947,
    -- Add more mappings here if needed
}

function GCDsaverAPI.checkBuffByAbility(actionId, targetType)
    local buffIcon = abilityToBuffIcon[actionId]
    if not buffIcon then return false end
    return GCDsaverAPI.hasBuff(targetType, { iconNum = buffIcon }, nil, true)
end

function GCDsaverAPI.GetTargetId(target)
    target = GCDsaver.getActualTarget(target)
    if target == GCDsaverAPI.TARGET.ENEMY then
        return TargetInfo:UnitEntityId(TargetInfo.HOSTILE_TARGET)
    elseif target == GCDsaverAPI.TARGET.FRIEND then
        return TargetInfo:UnitEntityId(TargetInfo.FRIENDLY_TARGET)
    elseif target == GCDsaverAPI.TARGET.SELF then
        return TargetInfo:UnitEntityId(TargetInfo.SELF)
    else
        return 0
    end
end


function GCDsaverAPI.IsPetAbility(actionId)
    if not actionId then return false end
    local actionData = GCDsaverMemory.getActionDataCache(actionId)
    if not actionData then return false end -- race condition...
    if actionData.actionType == "ability" then
	if actionData.petAbility == true then
		return true
	else
		return false
	end
    else
        return false
    end
end

function GCDsaverAPI.GetTimeFromSeconds(t)
    if not t then return 0, 0, 0 end

    t = math_floor(t + 0.5)

    local d = math_floor(t / 86400.0)
    t = t - (d * 86400)
    local h = math_floor(t / 3600.0)
    t = t - (h * 3600)
    local m = math_floor(t / 60.0)
    t = t - (m * 60)
    local s = math_floor(t + 0.5)

    return d, h, m, s
end


function GCDsaverAPI.GetCurrentDateTime()
    local t = GetComputerTime()
    local d = GetTodaysDate()
    local _d, h, m, s = GCDsaverAPI.GetTimeFromSeconds(t)

    return {
        year = d.todaysYear,
        month = d.todaysMonth,
        day = d.todaysDay,
        hours = h,
        minutes = m,
        seconds = s,
        totalSeconds = t  -- Assuming t is the Unix time in seconds
    }
end

function GCDsaverAPI.IsItem(actionId)
    if not actionId then return false end
    return GCDsaverAPI.isActionType(actionId, "item")
end

function GCDsaverAPI.isActionType(actionId, actionType)
    local actionData = GCDsaverMemory.getActionDataCache(actionId)
    if not actionData then return false end -- race condition...
    if actionData.actionType == actionType then
        return true
    else
        return false
    end
end

function GCDsaverAPI.IsAbility(actionId)
    if not actionId then return false end
    return GCDsaverAPI.isActionType(actionId, "ability")
end

function GCDsaverAPI.GetDefaultTarget(actionId)
    
    -- items are only allowed to target the player at the moment...
    if GCDsaverAPI.IsItem(actionId) then
        return GCDsaverAPI.TARGET.PLAYER
    end

    if GCDsaverMemory.GetDefaultTarget(actionId) then
        return GCDsaverMemory.GetDefaultTarget(actionId)
    end
    
    if GCDsaverAPI.DefaultTarget[actionId] then
        for _, target in pairs(GCDsaverAPI.TARGET) do
            if GCDsaverAPI.DefaultTarget[actionId] == target then
                return target
            end
        end
    end
    
    local enemyBuffed = GCDsaverAPI.hasEffect(actionId, GCDsaverAPI.TARGET.ENEMY, 's').stackCount
    
    if GCDsaverAPI.isDebuff(actionId) or enemyBuffed > 0 then
        return GCDsaverAPI.TARGET.ENEMY
    else
        return GCDsaverAPI.TARGET.FRIEND
    end
end

function GCDsaverAPI.isBuff(actionId)
    local actionData = GCDsaverMemory.getActionDataCache(actionId)
    if not actionData then return false end
    return actionData.isBuff or actionData.isHealing or actionData.isBlessing
end

-- function GCDsaverAPI.getActualTarget(target)
    -- if not target then
        -- return nil
    -- end
     
    -- local unitId
    -- if target == GCDsaverAPI.TARGET.ENEMY and GCDsaverAPI.hasEnemy() then
        -- return GCDsaverAPI.TARGET.ENEMY
    -- elseif target == GCDsaverAPI.TARGET.FRIEND and GCDsaverAPI.hasFriend() then
        -- return GCDsaverAPI.TARGET.FRIEND
    -- elseif target == GCDsaverAPI.TARGET.FRIEND or target == GCDsaverAPI.TARGET.PLAYER then
        -- return GCDsaverAPI.TARGET.PLAYER
    -- else
        -- return nil
    -- end
-- end

function GCDsaverAPI.getActualTarget(target)
    if not target then return nil end

    local resolved = nil
    if target == GCDsaverAPI.TARGET.ENEMY and GCDsaverAPI.hasEnemy() then
        resolved = GCDsaverAPI.TARGET.ENEMY
    elseif target == GCDsaverAPI.TARGET.FRIEND and GCDsaverAPI.hasFriend() then
        resolved = GCDsaverAPI.TARGET.FRIEND
    elseif target == GCDsaverAPI.TARGET.PLAYER then
        resolved = GCDsaverAPI.TARGET.PLAYER
    end

    if GCDsaver.Settings.DebugMessages then
        d("[getActualTarget] Requested: " .. tostring(target) .. " | Resolved: " .. tostring(resolved))
    end

    return resolved
end

function GCDsaverAPI.isDebuff(actionId)
    local actionData = GCDsaverMemory.getActionDataCache(actionId)
    if not actionData then return false end
    return actionData.isHex or actionData.isCurse or actionData.isCripple
        or actionData.isAilment or actionData.isDebuff
end

function GCDsaverAPI.hasEffect(ability, target, selfOnly)

    -- get the id if we have a name
    if type(ability) ~= "number" then
        ability = GetActionIdFromName(tostring(ability))
    end
    
    local voidStack = { stackCount = 0 }
    target = GCDsaver.getActualTarget(target)
    if not target then
        return voidStack, voidStack
    end
    
    -- perform test
    if GCDsaverEngine.GetEffects(target) and GCDsaverEngine.GetEffects(target)[ability] then
        if not selfOnly then
            return GCDsaverEngine.GetEffects(target)[ability].self, GCDsaverEngine.GetEffects(target)[ability].other
        elseif selfOnly == 's' then
            return GCDsaverEngine.GetEffects(target)[ability].self
        else
            return GCDsaverEngine.GetEffects(target)[ability].other
        end
    end
    
    return voidStack, voidStack
end

function GCDsaverAPI.hasCondition(condition, target)
    target = GCDsaver.getActualTarget(target)
    if not target then
        return nil
    end
    
    if GCDsaverEngine.GetConditions(target) and GCDsaverEngine.GetConditions(target)[condition] then
        return true
    end
    return false
end

function GCDsaverAPI.hasFriend()
    if TargetInfo.m_Units.selffriendlytarget ~=nil and TargetInfo.m_Units.selffriendlytarget.entityid ~=0 then
        if TargetInfo.m_Units.selffriendlytarget.entityid ~= GameData.Player.worldObjNum then
            return true
        end
    end
    return false
end

function GCDsaverAPI.isFriend()
    if TargetInfo.m_Units.selffriendlytarget ~=nil and TargetInfo.m_Units.selffriendlytarget.entityid ~=0 then
        if TargetInfo.m_Units.selffriendlytarget.entityid == GameData.Player.worldObjNum then
            return true
        end
    end
    return false
end

function GCDsaverAPI.hasEnemy()
    return TargetInfo.m_Units.selfhostiletarget ~=nil
           and TargetInfo.m_Units.selfhostiletarget.entityid ~=0
end

function GCDsaverAPI.hasPet()
    return GameData.Player.Pet.name ~= L""
end

function GCDsaverAPI.inCombat()
    return GameData.Player.inCombat
end

 function GCDsaverAPI.petHasTarget()
	return GameData.Player.Pet.Target.name  ~= L""
end

function GCDsaverAPI.hasMechanic(neededMechanic)

    -- make sure we get a number
    neededMechanic = tonumber(neededMechanic)
    
    -- Get career currentMechanic 
    local currentMechanic = tonumber(GetCareerResource( GameData.BuffTargetType.SELF ))
        
    -- archmage and shaman
    if GameData.Player.career.line == 20 or GameData.Player.career.line == 7 then
        if neededMechanic > 0 then
            -- AM: tranquility test
            neededMechanic = neededMechanic +5
            if currentMechanic >= neededMechanic then
                return true
            end
        else
            -- AM: force test
            neededMechanic = neededMechanic*-1
            if currentMechanic <= 5 and currentMechanic >= neededMechanic then
                return true
            end
        end
    -- zealot and runepriest
    elseif GameData.Player.career.line == 15 or GameData.Player.career.line == 3 then
    	return GCDsaverEngine.getRunepriestZealotMechanic() == neededMechanic
    else    
        -- other careers
        if currentMechanic >= neededMechanic then
            return true
        end
    end
    return false
end

function GCDsaverAPI.hasHitPoints(value)
    return GameData.Player.hitPoints.current >= value
end

function GCDsaverAPI.hasHitPointsPercent(percent, target)
    target = GCDsaverAPI.getActualTarget(target)
    
    if target == GCDsaverAPI.TARGET.FRIEND then
        return TargetInfo:UnitHealth(TargetInfo.FRIENDLY_TARGET) >= percent
    elseif target == GCDsaverAPI.TARGET.ENEMY then
        return TargetInfo:UnitHealth(TargetInfo.HOSTILE_TARGET) >= percent
    else
        return (GameData.Player.hitPoints.current/GameData.Player.hitPoints.maximum * 100) >= percent
    end
end

function GCDsaverAPI.hasName(text, target)
    local target = GCDsaverAPI.getActualTarget(target)
    local targetName = ""
    
    if target == GCDsaverAPI.TARGET.FRIEND then
        targetName = TargetInfo:UnitName(TargetInfo.FRIENDLY_TARGET) 
    elseif target == GCDsaverAPI.TARGET.ENEMY then
        targetName = TargetInfo:UnitName(TargetInfo.HOSTILE_TARGET) 
    else
        targetName = GameData.Player.name
    end
    
    local index = string_find(WStringToString(targetName), text) 
    if not index then
        return false
    end
    return true
end

function GCDsaverAPI.inSiege()
    return GameData.Player.isInSiege
end

function GCDsaverAPI.inScenario()
    return GameData.Player.isInScenario
end

function GCDsaverAPI.inWarBand()
    return IsWarBandActive()
end

function GCDsaverAPI.isRVR()
    return GameData.Player.rvrZoneFlagged
end

function GCDsaverAPI.inMyParty()
    if not GCDsaverAPI.hasFriend() then return true end
    local targetName = TargetInfo:UnitName(TargetInfo.FRIENDLY_TARGET) 
    if GroupWindow.IsPlayerInGroup( targetName ) then
        return true
    end
    return false
end

function GCDsaverAPI.inAParty()
    return GetNumGroupmates() > 0
end

function GCDsaverAPI.isMoving() 
    return GCDsaverEngine.PlayerMoving()
end

function GCDsaverAPI.getCareer(target)
    target = GCDsaverAPI.getActualTarget(target)
    if not target then
        return nil
    end
     
    local unitId
    if target == GCDsaverAPI.TARGET.ENEMY then
        unitId = TargetInfo.HOSTILE_TARGET
    elseif target == GCDsaverAPI.TARGET.FRIEND then
        unitId = TargetInfo.FRIENDLY_TARGET
    elseif target == GCDsaverAPI.TARGET.PLAYER then
        return GameData.Player.career.line
    else
        return nil
    end
    
    if TargetInfo:UnitIsNPC(unitId) then
        return GCDsaverAPI.careerDB.npc
    end
    
    local careerId = TargetInfo:UnitCareer(unitId)
    if careerId == 0 then
        return GCDsaverAPI.careerDB.obj
    else
        return TargetInfo:UnitCareer(unitId)
    end
end

function GCDsaverAPI.GetCurrentSlot(actionId)
    -- Loop through 36 of the 60 hotbar slots
    for slot = 1, 60 do  -- Using 36 as the total number of hotbar slots when there actually is 60
        -- Use GetHotbarData function to get details about the slot
        local actionType, slotActionId, isSlotEnabled, isTargetValid, isSlotBlocked = GetHotbarData(slot)
        
        -- Check if the current slot's action matches the actionId we're looking for
        if slotActionId == actionId then
            return slot -- Return the current slot number if a match is found
        end
    end
    return nil -- Return nil if no slot contains the action
end

function GCDsaverAPI.isEnabled(id)

    if not id then
        return false
    end
    
    if GCDsaverAPI.IsAbility(id) then
        if not GCDsaverAPI.hasAbility(id) then return false end
        return IsAbilityEnabled(id)
    elseif GCDsaverAPI.IsItem(id) then
        if not GCDsaverAPI.hasItem(id) then return false end
        GCDsaverEngine.OnCooldown(id)
        local actionData = GCDsaverMemory.getActionDataCache(id)
        if not actionData then return false end
        local cd = actionData.cooldown
        if not cd or cd == 0 then
            return true
        end
    end
    return false
end

function GCDsaverAPI.hasItem(theId)
    if GCDsaverMemory.getActionDataCache(theId).hasAction then return true end
    return false
end

function GCDsaverAPI.hasAbility(theId)
    if GCDsaverMemory.getActionDataCache(theId).hasAction then return true end
    return false
end

----------------------------------------------------------------------------------------------------------------------------------

function GCDsaverAPI.hasActionPoints(value) 
    return GameData.Player.actionPoints.current >= value
end

function GCDsaverAPI.hasSelfTarget()
	local target = TargetInfo.m_Units[TargetInfo.SELF]
	if target and target.entityid ~= 0 then
		return true
	end
	return false
end

function GCDsaverAPI.hasFriendlyTarget()
	local target = TargetInfo.m_Units[TargetInfo.FRIENDLY_TARGET]
	if target and target.entityid ~= 0 then
		return true
	end
	return false
end

function GCDsaverAPI.hasHostileTarget()
	local target = TargetInfo.m_Units[TargetInfo.HOSTILE_TARGET]
	if target and target.entityid ~= 0 then
		return true
	end
	return false
end

-- Local variable within GCDsaverAPI to keep track of buff checks
-- 🔒 Cache for ability data
local abilityDataCache = {}

-- 📥 Safe cached accessor for ability data
function GCDsaverAPI.GetCachedAbilityData(actionId)
    if not actionId then return nil end

    if not abilityDataCache[actionId] then
        local data = GetAbilityData(actionId) -- ✅ Correct function
        if data then
            abilityDataCache[actionId] = data
        end
    end

    return abilityDataCache[actionId]
end


-- 🔄 Optional: Clear ability data cache (for debugging or reloads)
function GCDsaverAPI.ClearAbilityDataCache()
    abilityDataCache = {}
    if GCDsaver.Settings.DebugMessages then
        d("🧹 Cleared AbilityData cache!")
    end
end

local hasBuffCheckCount = 0

-- Cache for storing buff checks
local buffCache = {}

-- Function to increment and get the current count
function GCDsaverAPI.incrementHasBuffCheckCount()
    hasBuffCheckCount = hasBuffCheckCount + 1
    return hasBuffCheckCount
end

-- 💣 Cache purge if size is too big
local function purgeBuffCacheIfTooBig()
    local count = 0
    for _ in pairs(buffCache) do
        count = count + 1
        if count > MAX_BUFF_CACHE_ENTRIES then
            buffCache = {}
            if GCDsaver.Settings.DebugMessages then
                d("💥 Buff cache purged! Exceeded " .. MAX_BUFF_CACHE_ENTRIES .. " entries.")
            end
            return
        end
    end
end

-- ♻️ Cache clearer
function GCDsaverAPI.clearBuffCache(targetType)
    targetType = targetType and tostring(targetType):upper() or "ALL"

    for key in pairs(buffCache) do
        if type(key) == "string" and (targetType == "ALL" or key:find(targetType)) then
            buffCache[key] = nil
        end
    end

    purgeBuffCacheIfTooBig()

    if GCDsaver.Settings.DebugMessages then
        d("♻️ Buff cache cleared for targetType: " .. targetType)
    end
end

-- 🧠 Buff check logic
function GCDsaverAPI.hasBuff(target, abilityData, stackCount, disableCache)
    -- 🔄 Convert numeric ID into full data
    if type(abilityData) == "number" then
        if GCDsaver.Settings.DebugMessages then
            d("[hasBuff] WARNING: abilityData was number (" .. tostring(abilityData) .. "), converting using GCDsaverAPI.GetCachedAbilityData()")
        end
        abilityData = GCDsaverAPI.GetCachedAbilityData(abilityData)
        if not abilityData then
            if GCDsaver.Settings.DebugMessages then
                d("[hasBuff] ERROR: GetAbilityData returned nil for ID: " .. tostring(abilityData))
            end
            return false
        end
    end

    local count = GCDsaverAPI.incrementHasBuffCheckCount()
    if GCDsaver.Settings.DebugMessages then
        d(string.format("Debug: hasBuff checked %d times", count))
    end

    if not target then
        if GCDsaver.Settings.DebugMessages then
            d("Debug: Target is nil in hasBuff")
        end
        return false
    end

    -- 🎯 Get readable type
    local targetType
    if target == GameData.BuffTargetType.SELF then
        targetType = "SELF"
    elseif target == GameData.BuffTargetType.TARGET_FRIENDLY then
        targetType = "FRIENDLY"
    elseif target == GameData.BuffTargetType.TARGET_HOSTILE then
        targetType = "HOSTILE"
    else
        targetType = "UNKNOWN"
    end

    -- 🧠 Key it up
    local cacheKey = string.format("%s_%d_%s", targetType, abilityData.iconNum, tostring(stackCount or "nil"))

    -- 📦 Use cache if we got it
    if not disableCache and buffCache[cacheKey] ~= nil then
        if GCDsaver.Settings.DebugMessages then
            d("Debug: Returning cached result for " .. cacheKey)
        end
        return buffCache[cacheKey]
    end

    -- 🔍 Search local GCDsaver target cache
    local targetCache = GCDsaver[targetType .. "TargetEffects"] or {}
    if targetCache[abilityData.iconNum] then
        local buff = targetCache[abilityData.iconNum]
        if buff.stackCount == stackCount or stackCount == nil then
            if not disableCache then
                buffCache[cacheKey] = true
                purgeBuffCacheIfTooBig()
            end
            if GCDsaver.Settings.DebugMessages then
                d("Debug: Internal cache hit for " .. cacheKey)
            end
            return true
        end
    end

    -- 🧾 Pull live from GetBuffs
    local buffData = GetBuffs(target)
    if not buffData then
        if GCDsaver.Settings.DebugMessages then
            d("Debug: No buff data found for target in hasBuff")
        end
        if not disableCache then
            buffCache[cacheKey] = false
            purgeBuffCacheIfTooBig()
        end
        return false
    end

    -- 🧪 Final fallback, loop buffs
    for _, buff in pairs(buffData) do
        if buff.iconNum == abilityData.iconNum and buff.castByPlayer and (buff.stackCount == stackCount or stackCount == nil) then
            if GCDsaver.Settings.DebugMessages then
                d("Debug: Live buff matched with stack count on target (" .. targetType .. ")")
            end
            if not disableCache then
                buffCache[cacheKey] = true
                purgeBuffCacheIfTooBig()
            end
            return true
        end
    end

    -- ❌ Nothing matched
    if not disableCache then
        buffCache[cacheKey] = false
        purgeBuffCacheIfTooBig()
    end
    return false
end

-- Move these variables outside of the function for proper caching
local cachedTargetType = nil
local cachedTargetId = nil

function GCDsaverAPI.getTargetType(targetType)
	if targetType == 0 then
		return GameData.BuffTargetType.SELF
	elseif targetType == 1 and GCDsaverAPI.hasHostileTarget() then
		return GameData.BuffTargetType.TARGET_HOSTILE
	elseif targetType == 1 then
		return nil -- Ugly workaround to correct for incorrect buffs when no hostile target
	elseif targetType == 2 and GCDsaverAPI.hasFriendlyTarget() then
		return GameData.BuffTargetType.TARGET_FRIENDLY
	elseif targetType == 2 then
		return GameData.BuffTargetType.SELF
	else
		return GameData.BuffTargetType.SELF
	end
end

function GCDsaverAPI.hasSnareBuffOnHostileTarget()
    if not GCDsaverAPI.hasHostileTarget() then
        return false
    end

    local buffData = GetBuffs(GameData.BuffTargetType.TARGET_HOSTILE)
    if not buffData then
        return false
    end

    for _, buff in pairs(buffData) do
        if Emissary.Snares[buff.abilityId] then
            return true  -- The target is snared
        end
    end

    return false  -- No snare buffs found on the target
end



function GCDsaverAPI.alertText(text)
	if SettingsWindowTabInterface.SavedMessageSettings.combat then
		SystemData.AlertText.VecType = {SystemData.AlertText.Types.COMBAT}
		SystemData.AlertText.VecText = {towstring(text)}
		BroadcastEvent(SystemData.Events.SHOW_ALERT_TEXT)
	end
end

function GCDsaverAPI.chatInfo(actionId, slot)
	local state = GCDsaver.Settings.Abilities[actionId]
	local name = tostring(GCDsaverAPI.GetCachedAbilityData(actionId).name)
	local icon = "<icon".. tostring(GCDsaverAPI.GetCachedAbilityData(actionId).iconNum) .. ">"
	if GCDsaver.Settings.DisableSlotChecks[slot] then
		TextLogAddEntry("Chat", 0, towstring("GCDsaver: Disabling slot " .. slot .. " check for " .. icon .. " " .. name))
	elseif not state then
		TextLogAddEntry("Chat", 0, towstring("GCDsaver: Clearing check for " .. icon .. " " .. name))
	elseif state >= 1 and state <= 3 then
		TextLogAddEntry("Chat", 0, towstring("GCDsaver: Setting (" .. state ..  "x) Stack check for " .. icon .. " " .. name))
	elseif state == IMMOVABLE then
		TextLogAddEntry("Chat", 0, towstring("GCDsaver: Setting <icon05007> Immovable check for " .. icon .. " " .. name))
	elseif state == UNSTOPPABLE then
		TextLogAddEntry("Chat", 0, towstring("GCDsaver: Setting <icon05006> Unstoppable check for " .. icon .. " " .. name))
	elseif state == CAREER_RESOURCE then
		TextLogAddEntry("Chat", 0, towstring("GCDsaver: Setting (RE" .. GCDsaver.Settings.MaxResources .. ") career resource check for " .. icon .. " " .. name))
	end
end

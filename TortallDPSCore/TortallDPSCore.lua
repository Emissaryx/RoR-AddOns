LogDisplaySetEntryLimit("DebugWindowText", 5000)

TortallDPSCore = {}

TortallDPSCore.Addons = {}

TortallDPSCore.DAMAGE_DEALT = 1
TortallDPSCore.DAMAGE_TAKEN = 2
TortallDPSCore.HEAL_DEALT   = 3
TortallDPSCore.HEAL_TAKEN   = 4

TortallDPSCore.ABILITY = 1
TortallDPSCore.TARGET  = 2

local YOUR_HITS         = SystemData.ChatLogFilters.YOUR_HITS
local YOUR_HEALS        = SystemData.ChatLogFilters.YOUR_HEALS
local PET_DMG           = SystemData.ChatLogFilters.PET_DMG
local PET_HITS          = SystemData.ChatLogFilters.PET_HITS
local YOUR_DMG_FROM_PC  = SystemData.ChatLogFilters.YOUR_DMG_FROM_PC
local YOUR_DMG_FROM_NPC = SystemData.ChatLogFilters.YOUR_DMG_FROM_NPC

local SaveKey = L""
local ParseTextTable = {}
local ParseTable = nil
local CleanPlayerName = nil

-- Performance optimization: batch update callbacks instead of per-event
local updateTimer = 0
local UPDATE_INTERVAL = 0.05 -- Update every 50ms (20 times per second)
local needsUpdate = false

-- Performance optimization: object pooling for data structures
local dataPool = {}
local MAX_POOL_SIZE = 50

-- Memory management: limits on tracked entries
local MAX_ABILITIES_PER_TABLE = 150
local MAX_TARGETS_PER_TABLE = 100

-- English
ParseTextTable[1] = { dealt = { damage = {}, heals = {}, crit = {}, block = {}, disrupt = {}, dodge = {}, parry = {}, pet = {} },
                      taken = { damage = {}, heals = {}, crit = {}, block = {}, disrupt = {}, dodge = {}, parry = {} } }

ParseTextTable[1].dealt.damage.parse = L"Your (.-) hits (.-)for (%d+) damage%."
ParseTextTable[1].dealt.pet.parse = L"Your (.-) hits (.-) for (%d+) damage%."
ParseTextTable[1].dealt.heals.parse = L"Your (.-) heals (.-) for (%d+) points%."
ParseTextTable[1].dealt.dodge.parse = L"(.+) dodged your (.-)%."
ParseTextTable[1].dealt.disrupt.parse = L"(.+) disrupted your (.-)%."
ParseTextTable[1].dealt.block.parse = L"(.+) blocked your (.-)%."
ParseTextTable[1].dealt.parry.parse = L"(.+) parried your (.-)%."

ParseTextTable[1].dealt.damage.fields = { ability = 1, object = 2, amount = 3 }
ParseTextTable[1].dealt.pet.fields = { ability = 1, object = 2, amount = 3 }
ParseTextTable[1].dealt.heals.fields = { ability = 1, object = 2, amount = 3 }
ParseTextTable[1].dealt.block.fields = { ability = 2, object = 1 }
ParseTextTable[1].dealt.disrupt.fields = { ability = 2, object = 1 }
ParseTextTable[1].dealt.dodge.fields = { ability = 2, object = 1 }
ParseTextTable[1].dealt.parry.fields = { ability = 2, object = 1 }

ParseTextTable[1].taken.damage.parse = L"^(.-)'s (.-) hits you for (%d+) damage%."
ParseTextTable[1].taken.heals.parse = L"^(.-)'s (.-) heals you for (%d+) points%."

ParseTextTable[1].taken.damage.fields = { ability = 2, object = 1, amount = 3 }
ParseTextTable[1].taken.heals.fields = { ability = 2, object = 1, amount = 3 }

ParseTextTable[1].mitigated = L"%((%d+) mitigated%)"
ParseTextTable[1].absorbed =  L"%((%d+) absorbed%)"
ParseTextTable[1].dealt.crit = L"Your .- critically"
ParseTextTable[1].taken.crit = L".-'s .- critically"


-- French
ParseTextTable[2] = { dealt = { damage = {}, heals = {}, crit = {}, block = {}, disrupt = {}, dodge = {}, parry = {}, pet = {} },
                      taken = { damage = {}, heals = {}, crit = {}, block = {}, disrupt = {}, dodge = {}, parry = {} } }

ParseTextTable[2].dealt.damage.parse = L"Votre (.-) inflige un coup.- � (.-) et provoque (%d+) points de d�g�ts%."
ParseTextTable[2].dealt.pet.parse = L"Votre (.-) inflige un coup.- � (.-) et provoque (%d+) points de d�g�ts%."
ParseTextTable[2].dealt.heals.parse = L"Votre (.-) [vous ]*administre un soin.*[�t] (.-)[ ,qui]* r�cup[��]rez? (%d+) points de vie.+"
ParseTextTable[2].dealt.dodge.parse = L"(.+) a esquiv� votre (.-)%."
ParseTextTable[2].dealt.disrupt.parse = L"(.+) a dissip� votre (.-)%."
ParseTextTable[2].dealt.block.parse = L"(.+) a bloqu� votre (.-)%."
ParseTextTable[2].dealt.parry.parse = L"(.+) a par� votre (.-)%."

ParseTextTable[2].dealt.damage.fields = { ability = 1, object = 2, amount = 3 }
ParseTextTable[2].dealt.pet.fields = { ability = 1, object = 2, amount = 3 }
ParseTextTable[2].dealt.heals.fields = { ability = 1, object = 2, amount = 3 }
ParseTextTable[2].dealt.block.fields = { ability = 2, object = 1 }
ParseTextTable[2].dealt.disrupt.fields = { ability = 2, object = 1 }
ParseTextTable[2].dealt.dodge.fields = { ability = 2, object = 1 }
ParseTextTable[2].dealt.parry.fields = { ability = 2, object = 1 }

ParseTextTable[2].taken.damage.parse = L"[Ll][ae%p][s%s]?(.+) d[e%p]%s*([A-Z].-) vous inflige un coup et provoque (%d+) points de d�g�ts.+"
ParseTextTable[2].taken.heals.parse = L"[Ll][ea%p]%s*(.+) d[%pe]%s*(.-) vous administre un soin.+ vous r�cup�rez (%d+) points de vie.+"

ParseTextTable[2].taken.damage.fields = { ability = 1, object = 2, amount = 3 }
ParseTextTable[2].taken.heals.fields = { ability = 1, object = 2, amount = 3 }

ParseTextTable[2].mitigated = L"%((%d+) att�nu�%)"
ParseTextTable[2].absorbed =  L"%((%d+) absorb�%)"
ParseTextTable[2].dealt.crit = L"critique"
ParseTextTable[2].taken.crit = L"critique"


-- German
ParseTextTable[3] = { dealt = { damage = {}, heals = {}, crit = {}, block = {}, disrupt = {}, dodge = {}, parry = {}, pet = {} },
                      taken = { damage = {}, heals = {}, crit = {}, block = {}, disrupt = {}, dodge = {}, parry = {} } }

ParseTextTable[3].dealt.damage.parse = L"Ihr trefft (.-) %s*und Eu[er]+ (.-) verursacht (%d+) Schadenspunkte%."
ParseTextTable[3].dealt.pet.parse = L"Euer Begleiter trifft (.-) und (.-) verursacht (%d+) Schadenspunkte%."
ParseTextTable[3].dealt.heals.parse = L"Ihr heilt (.-) %s*und Eu[er]+ (.-) stellt (%d+) Lebenspunkte wieder her%."
ParseTextTable[3].dealt.dodge.parse = L"(.+) dodged your (.-)%."
ParseTextTable[3].dealt.disrupt.parse = L"(.+) disrupted your (.-)%."
ParseTextTable[3].dealt.block.parse = L"(.+) hat Euren (.-) geblockt%."
ParseTextTable[3].dealt.parry.parse = L"(.+) parried your (.-)%."

ParseTextTable[3].dealt.damage.fields = { ability = 2, object = 1, amount = 3 }
ParseTextTable[3].dealt.pet.fields = { ability = 2, object = 1, amount = 3 }
ParseTextTable[3].dealt.heals.fields = { ability = 2, object = 1, amount = 3 }
ParseTextTable[3].dealt.block.fields = { ability = 2, object = 1 }
ParseTextTable[3].dealt.disrupt.fields = { ability = 2, object = 1 }
ParseTextTable[3].dealt.dodge.fields = { ability = 2, object = 1 }
ParseTextTable[3].dealt.parry.fields = { ability = 2, object = 1 }

ParseTextTable[3].taken.damage.parse = L"(.-) trifft Euch und %w+ (.-) %[*verursacht%]* (%d+) Schadenspunkte%."
ParseTextTable[3].taken.heals.parse = L"(.-) heilt Euch.*und %w+ (.-) %[*stellt%]* (%d+) Lebenspunkte wieder her%."

ParseTextTable[3].taken.damage.fields = { ability = 2, object = 1, amount = 3 }
ParseTextTable[3].taken.heals.fields = { ability = 2, object = 1, amount = 3 }

ParseTextTable[3].absorbed =  L"%((%d+) Punkte wurden absorbiert%)"
ParseTextTable[3].mitigated = L"%(Um (%d+) Punkte abgeschw�cht%)"
ParseTextTable[3].dealt.crit = L"Ihr .- kritisch und"
ParseTextTable[3].taken.crit = L"kritisch"


local function newstats()
    local stats = { paused = false, CombatTime = 0, save = true }

    stats.Damage = { Dealt = { Stats = {}, Object = {} }, Taken = { Stats = {}, Object = {} } }

    stats.Damage.Dealt.Total  = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0,
                                  Block = 0, Parry = 0, Disrupt = 0, Dodge = 0 }
    stats.Damage.Dealt.Normal = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0 }
    stats.Damage.Dealt.Crit   = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0 }

    stats.Damage.Taken.Total  = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0,
                                  Block = 0, Parry = 0, Disrupt = 0, Dodge = 0 }
    stats.Damage.Taken.Normal = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0 }
    stats.Damage.Taken.Crit   = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0 }


    stats.Healing = { Dealt = { Stats = {}, Object = {} }, Taken = { Stats = {}, Object = {} } }

    stats.Healing.Dealt.Total  = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0,
                                   Block = 0, Parry = 0, Disrupt = 0, Dodge = 0 }
    stats.Healing.Dealt.Normal = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0 }
    stats.Healing.Dealt.Crit   = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0 }

    stats.Healing.Taken.Total  = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0,
                                   Block = 0, Parry = 0, Disrupt = 0, Dodge = 0 }
    stats.Healing.Taken.Normal = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0 }
    stats.Healing.Taken.Crit   = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0 }

    return stats
end

local function english_fixup( object, ability )
    ability = ability:gsub(L" critically", "")
    ability = ability:gsub(L"^%[", "")
    ability = ability:gsub(L"%]$", "")

    if ( ability == L"attack" ) then ability = L"Auto Attack"      end
    if ( object == L"you" )     then object = CleanPlayerName end

    return object, ability
end

local function french_fixup( object, ability )
    ability = ability:gsub(L"^%[", "")
    ability = ability:gsub(L"%]$", "")

    if ( ability == L"attaque" ) then ability = L"Attaque auto"     end
    if ( object == L"vous" )     then object = CleanPlayerName end

    return object, ability
end

local function german_fixup( object, ability )
    ability = ability:gsub(L"^%[", "")
    ability = ability:gsub(L"%]$", "")
    ability = ability:gsub(L"sein ", L"Begleiter%-")
    ability = ability:gsub(L"seine ", L"Begleiter%-")

    object = object:gsub(L" kritisch", "")
    object = object:gsub(L"^das ", "")
    object = object:gsub(L"^den ", "")
    object = object:gsub(L"^die ", "")
    object = object:gsub(L"^Ein ", "")
    object = object:gsub(L"^Eine ", "")

    if ( object == L"Euch" ) then object = CleanPlayerName end

    return object, ability
end

function TortallDPSCore.Initialize()
    SaveKey = tostring(SystemData.Server.Name .. GameData.Player.name)
    
    -- OPTIMIZATION: Cache cleaned player name to avoid repeated pattern matching
    CleanPlayerName = GameData.Player.name:match(L"([^^]+)^?.*") or GameData.Player.name
    
    if ( TortallDPSCore.SavedState == nil ) then
        TortallDPSCore.SavedState = { savestate = true, [SaveKey] = {} }
    end
    if ( TortallDPSCore.SavedState[SaveKey] == nil ) then TortallDPSCore.SavedState[SaveKey] = {} end

    ParseTextTable[1].fixup = english_fixup
    ParseTextTable[2].fixup = french_fixup
    ParseTextTable[3].fixup = german_fixup

    ParseTextTable[10] = TortallDPSCoreRu.InitLocale()

    ParseTable = ParseTextTable[SystemData.Settings.Language.active]

    TortallDPSCore.Stats = {}

    TortallDPSCore.Register("Global")

    RegisterEventHandler( SystemData.Events.UPDATE_PROCESSED, "TortallDPSCore.OnUpdate")
    RegisterEventHandler( TextLogGetUpdateEventId( "Combat" ), "TortallDPSCore.OnCombatLog" )
end

function TortallDPSCore.Shutdown()
end

function TortallDPSCore.Reset(channel)
    channel = channel or "Global"
	channel = tostring(channel)

    TortallDPSCore.Stats[channel] = newstats()

    local addon
    for _, addon in pairs(TortallDPSCore.Addons) do
        if ( addon.Channels[channel] ~= nil ) then
            addon.Channels[channel] = TortallDPSCore.Stats[channel]
            if ( addon.update ~= nil ) and ( TortallDPSCore.Stats[channel].paused == false ) then
                local success, errmsg =
                    pcall(addon.update, addon.Channels[channel].Damage, addon.Channels[channel].Healing, addon.Channels[channel].CombatTime, channel)
                if ( success == false ) then
                    d(L"Error calling update callback")
                    d(towstring(errmsg))
                    -- FIX: Actually disable the callback on error to prevent spam
                    addon.update = nil
                end
            end
        end
    end

    DEBUG(L"TortallDPSCore reset for "..towstring(channel))
end

function TortallDPSCore.Pause( channel, pause )
    if ( TortallDPSCore.Stats[channel] ~= nil ) then
        TortallDPSCore.Stats[channel].paused = pause
    end
end

local function registerEventType(hashmap, newobject, constant1, constant2, channel)
    local v
    for _, v in pairs(hashmap) do
        local success, errmsg = pcall(newobject, constant1, v, constant2, channel)
        if ( success == false ) then
            d("Error calling "..tostring(callback).." callback");
            d(errmsg)
        end
    end
end

function TortallDPSCore.Register( addon, update, newobject, latestobject, channel )
    if ( TortallDPSCore.Addons[addon] == nil ) then
        TortallDPSCore.Addons[addon] = {}
        TortallDPSCore.Addons[addon].Channels = {}
    end

    TortallDPSCore.Addons[addon].update = update
    TortallDPSCore.Addons[addon].newobject = newobject
    TortallDPSCore.Addons[addon].latestobject = latestobject

    if ( channel == nil ) then channel = "Global" end
    channel = tostring(channel)

    if ( TortallDPSCore.Stats[channel] == nil ) then
        if ( TortallDPSCore.SavedState.savestate == true ) and
           ( TortallDPSCore.SavedState[SaveKey][channel] ~= nil ) and ( TortallDPSCore.SavedState[SaveKey][channel].save == true ) then
            TortallDPSCore.Stats[channel] = TortallDPSCore.SavedState[SaveKey][channel]
        else
            TortallDPSCore.Stats[channel] = newstats()
            if ( TortallDPSCore.SavedState.savestate == true ) then
                TortallDPSCore.SavedState[SaveKey][channel] = TortallDPSCore.Stats[channel]
            end
        end
    end

    TortallDPSCore.Addons[addon].Channels[channel] = TortallDPSCore.Stats[channel]

    -- Notify the addon for any saved data
    if ( newobject ~= nil ) and ( TortallDPSCore.SavedState.savestate == true ) then
        registerEventType(
            TortallDPSCore.SavedState[SaveKey][channel].Damage.Dealt.Object,
            newobject,
            TortallDPSCore.DAMAGE_DEALT,
            TortallDPSCore.TARGET,
            channel
        )
        registerEventType(
            TortallDPSCore.SavedState[SaveKey][channel].Damage.Dealt.Stats,
            newobject,
            TortallDPSCore.DAMAGE_DEALT,
            TortallDPSCore.ABILITY,
            channel
        )
        registerEventType(
            TortallDPSCore.SavedState[SaveKey][channel].Damage.Taken.Object,
            newobject,
            TortallDPSCore.DAMAGE_TAKEN,
            TortallDPSCore.TARGET,
            channel
        )
        registerEventType(
            TortallDPSCore.SavedState[SaveKey][channel].Damage.Taken.Stats,
            newobject,
            TortallDPSCore.DAMAGE_TAKEN,
            TortallDPSCore.ABILITY,
            channel
        )
        registerEventType(
            TortallDPSCore.SavedState[SaveKey][channel].Healing.Dealt.Object,
            newobject,
            TortallDPSCore.HEAL_DEALT,
            TortallDPSCore.TARGET,
            channel
        )
        registerEventType(
            TortallDPSCore.SavedState[SaveKey][channel].Healing.Dealt.Stats,
            newobject,
            TortallDPSCore.HEAL_DEALT,
            TortallDPSCore.ABILITY,
            channel
        )
        registerEventType(
            TortallDPSCore.SavedState[SaveKey][channel].Healing.Taken.Object,
            newobject,
            TortallDPSCore.HEAL_TAKEN,
            TortallDPSCore.TARGET,
            channel
        )
        registerEventType(
            TortallDPSCore.SavedState[SaveKey][channel].Healing.Taken.Stats,
            newobject,
            TortallDPSCore.HEAL_TAKEN,
            TortallDPSCore.ABILITY,
            channel
        )
    end

    d("Registration from "..addon.." for channel "..tostring(channel)..".")
end

-- OPTIMIZATION: Batch update callbacks instead of calling on every event
local function CallUpdateCallbacks()
    local addon, channel
    for _, addon in pairs(TortallDPSCore.Addons) do
        for channel in pairs(addon.Channels) do
            if ( addon.update ~= nil ) and ( TortallDPSCore.Stats[channel].paused == false ) then
                local success, errmsg =
                    pcall(addon.update, addon.Channels[channel].Damage, addon.Channels[channel].Healing, addon.Channels[channel].CombatTime, channel)
                if ( success == false ) then
                    d(L"Error calling update callback")
                    d(towstring(errmsg))
                    -- FIX: Actually disable the callback on error
                    addon.update = nil
                end
            end
        end
    end
end

function TortallDPSCore.OnUpdate( elapsed )
    if ( GameData.Player.inCombat ) then
        local v
        for _, v in pairs(TortallDPSCore.Stats) do
            if ( v.paused == false ) then v.CombatTime = v.CombatTime + elapsed end
        end
        
        -- OPTIMIZATION: Batch updates instead of per-event
        if needsUpdate then
            updateTimer = updateTimer + elapsed
            if updateTimer >= UPDATE_INTERVAL then
                updateTimer = 0
                CallUpdateCallbacks()
                needsUpdate = false
            end
        end
    end
end

function TortallDPSCore.OnCombatLog( updateType, filterType )
    if ( updateType ~= SystemData.TextLogUpdate.ADDED ) then return end

    local num = TextLogGetNumEntries("Combat") - 1
    local _, _, msg = TextLogGetEntry("Combat", num)
    
    TortallDPSCore.ParseEntry(msg, filterType)
    
    -- OPTIMIZATION: Flag that we need an update instead of calling immediately
    needsUpdate = true
end

local function newSubtable( name )
    local t = { Name = name }
    t.Amount = 0
    t.Mitigated = 0
    t.Absorbed = 0
    t.Count = 0
    t.Max = 0
    t.Min = nil
    t.Pet = false
    t.Block = 0
    t.Disrupt = 0
    t.Dodge = 0
    t.Parry = 0
    t.Normal = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0 }
    t.Crit   = { Amount = 0, Count = 0, Max = 0, Min = nil, Mitigated = 0, Absorbed = 0 }

    return t
end

-- OPTIMIZATION: Object pooling for data structures
local function getDataObject()
    local data = table.remove(dataPool)
    if not data then
        data = {
            Count = 0, Amount = 0, Mitigated = 0, Absorbed = 0,
            Ability = "", Object = "", Pet = false,
            Block = 0, Disrupt = 0, Dodge = 0, Parry = 0,
            Critical = false
        }
    end
    return data
end

local function returnDataObject(data)
    if #dataPool < MAX_POOL_SIZE then
        -- Reset the object
        data.Count = 0
        data.Amount = 0
        data.Mitigated = 0
        data.Absorbed = 0
        data.Ability = ""
        data.Object = ""
        data.Pet = false
        data.Block = 0
        data.Disrupt = 0
        data.Dodge = 0
        data.Parry = 0
        data.Critical = false
        table.insert(dataPool, data)
    end
end

local function notify( callback, dmgType, entry, objectType, channel, data )
    local addon
    for _, addon in pairs(TortallDPSCore.Addons) do
        if ( addon.Channels[channel] ~= nil ) and ( addon[callback] ~= nil ) then
            local success, errmsg = pcall(addon[callback], dmgType, entry, objectType, channel, data)
            if ( success == false ) then
                d(L"Error calling "..towstring(callback)..L" callback")
                d(towstring(errmsg))
                -- FIX: Actually disable the callback on error
                addon[callback] = nil
            end
        end
    end
end

-- OPTIMIZATION: Count table entries more efficiently
local function countTableEntries(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- OPTIMIZATION: Remove lowest damage/heal entries when tables get too large
local function pruneTableIfNeeded(statsTable, maxSize)
    local count = countTableEntries(statsTable)
    if count <= maxSize then return end
    
    -- Find and remove lowest value entry
    local lowestKey, lowestAmount = nil, math.huge
    for key, entry in pairs(statsTable) do
        if entry.Amount < lowestAmount then
            lowestAmount = entry.Amount
            lowestKey = key
        end
    end
    
    if lowestKey then
        statsTable[lowestKey] = nil
    end
end

function TortallDPSCore.ParseEntry( text, filter )
    -- OPTIMIZATION: Early filter routing to reduce string matching attempts
    local isDealingDamage = (filter == YOUR_HITS or filter == PET_HITS or filter == PET_DMG)
    local isTakingDamage = (filter == YOUR_DMG_FROM_PC or filter == YOUR_DMG_FROM_NPC)
    local isHealing = (filter == YOUR_HEALS)
    
    if not (isDealingDamage or isTakingDamage or isHealing) then
        return -- Unknown filter type, skip
    end
    
    local matched = false
    local p_damage, d_damage, d_heal, d_block, d_disrupt, d_dodge, d_parry
    local t_damage, t_heal
    local ability, object, amount, mitigated, absorbed
    local critical
    local dmgType
    
    -- OPTIMIZATION: Only try relevant patterns based on filter
    if isDealingDamage then
        if filter == PET_HITS then
            p_damage, _, ability, object, amount = text:find(ParseTable.dealt.pet.parse)
            if p_damage then
                matched = true
                ability = ability or ""
                object = object or ""
                amount = amount or "0"
            end
        end
        
        if not matched then
            d_damage, _, ability, object, amount = text:find(ParseTable.dealt.damage.parse)
            if d_damage then
                matched = true
                ability = ability or ""
                object = object or ""
                amount = amount or "0"
            end
        end
        
        if not matched then
            d_block, _, object, ability = text:find(ParseTable.dealt.block.parse)
            if d_block then matched = true end
        end
        
        if not matched then
            d_disrupt, _, object, ability = text:find(ParseTable.dealt.disrupt.parse)
            if d_disrupt then matched = true end
        end
        
        if not matched then
            d_dodge, _, object, ability = text:find(ParseTable.dealt.dodge.parse)
            if d_dodge then matched = true end
        end
        
        if not matched then
            d_parry, _, object, ability = text:find(ParseTable.dealt.parry.parse)
            if d_parry then matched = true end
        end
        
    elseif isHealing then
        d_heal, _, ability, object, amount = text:find(ParseTable.dealt.heals.parse)
        if d_heal then
            matched = true
            ability = ability or ""
            object = object or ""
            amount = amount or "0"
        end
        
    elseif isTakingDamage then
        t_damage, _, object, ability, amount = text:find(ParseTable.taken.damage.parse)
        if t_damage then
            matched = true
            object = object or ""
            ability = ability or ""
            amount = amount or "0"
        end
        
        if not matched then
            t_heal, _, object, ability, amount = text:find(ParseTable.taken.heals.parse)
            if t_heal then
                matched = true
                object = object or ""
                ability = ability or ""
                amount = amount or "0"
            end
        end
    end

    if not matched then return end
    
    -- FIX: Validate that we have the required fields
    if not object or not ability then
        return
    end

    -- Parse mitigated/absorbed/critical
    mitigated = text:match(ParseTable.mitigated) or "0"
    absorbed = text:match(ParseTable.absorbed) or "0"
    
    if isDealingDamage then
        critical = text:match(ParseTable.dealt.crit)
    else
        critical = text:match(ParseTable.taken.crit)
    end

    -- Determine damage type
    if p_damage or d_damage or d_block or d_disrupt or d_dodge or d_parry then
        dmgType = TortallDPSCore.DAMAGE_DEALT
    elseif d_heal then
        dmgType = TortallDPSCore.HEAL_DEALT
    elseif t_damage then
        dmgType = TortallDPSCore.DAMAGE_TAKEN
    elseif t_heal then
        dmgType = TortallDPSCore.HEAL_TAKEN
    end

    -- OPTIMIZATION: Skip self-damage using cached player name
    if d_damage and object == CleanPlayerName then
        return
    end

    object, ability = ParseTable.fixup(object, ability)

    amount = tonumber(amount) or 0
    mitigated = tonumber(mitigated) or 0
    absorbed = tonumber(absorbed) or 0

    -- OPTIMIZATION: Use object pooling instead of creating new table every time
    local data = getDataObject()
    data.Count = 1
    data.Amount = amount
    data.Mitigated = mitigated
    data.Absorbed = absorbed
    data.Ability = ability
    data.Object = object
    data.Pet = (filter == PET_HITS)
    data.Block = (d_block and 1 or 0)
    data.Disrupt = (d_disrupt and 1 or 0)
    data.Dodge = (d_dodge and 1 or 0)
    data.Parry = (d_parry and 1 or 0)
    data.Critical = (critical ~= nil)

    local channel, stats
    for channel, stats in pairs(TortallDPSCore.Stats) do
        if stats.paused == false then
            local subTable
            
            if p_damage or d_damage or d_block or d_disrupt or d_dodge or d_parry then
                subTable = stats.Damage.Dealt
            elseif d_heal then
                subTable = stats.Healing.Dealt
            elseif t_damage then
                subTable = stats.Damage.Taken
            elseif t_heal then
                subTable = stats.Healing.Taken
            end

            subTable.Total.Amount    = subTable.Total.Amount + data.Amount
            subTable.Total.Mitigated = subTable.Total.Mitigated + data.Mitigated
            subTable.Total.Absorbed  = subTable.Total.Absorbed + data.Absorbed
            subTable.Total.Count     = subTable.Total.Count + data.Count
            subTable.Total.Block     = subTable.Total.Block + data.Block
            subTable.Total.Disrupt   = subTable.Total.Disrupt + data.Disrupt
            subTable.Total.Dodge     = subTable.Total.Dodge + data.Dodge
            subTable.Total.Parry     = subTable.Total.Parry + data.Parry
            if ( subTable.Total.Min == nil ) or ( subTable.Total.Min > data.Amount ) then subTable.Total.Min = data.Amount end
            if ( subTable.Total.Max < data.Amount ) then subTable.Total.Max = data.Amount end

            if ( subTable.Stats[ability] == nil ) then
                -- OPTIMIZATION: Prune table if it's getting too large
                pruneTableIfNeeded(subTable.Stats, MAX_ABILITIES_PER_TABLE)
                
                subTable.Stats[ability] = newSubtable(ability)
                notify("newobject", dmgType, subTable.Stats[ability], TortallDPSCore.ABILITY, channel, data)
            end

            if ( subTable.Object[object] == nil ) then
                -- OPTIMIZATION: Prune table if it's getting too large
                pruneTableIfNeeded(subTable.Object, MAX_TARGETS_PER_TABLE)
                
                subTable.Object[object] = newSubtable(object)
                notify("newobject", dmgType, subTable.Object[object], TortallDPSCore.TARGET, channel, data)
            end

            TortallDPSCore.UpdateEntry(subTable.Stats[ability], data)
            TortallDPSCore.UpdateEntry(subTable.Object[object], data)

            notify("latestobject", dmgType, subTable.Stats[ability], TortallDPSCore.ABILITY, channel, data)
            notify("latestobject", dmgType, subTable.Object[object], TortallDPSCore.TARGET, channel, data)

            if ( data.Critical == false ) then
                subTable = subTable.Normal
            else
                subTable = subTable.Crit
            end

            subTable.Amount    = subTable.Amount + data.Amount
            subTable.Mitigated = subTable.Mitigated + data.Mitigated
            subTable.Absorbed  = subTable.Absorbed + data.Absorbed
            subTable.Count     = subTable.Count + data.Count
            if ( subTable.Min == nil ) or ( subTable.Min > data.Amount ) then subTable.Min = data.Amount end
            if ( subTable.Max < data.Amount ) then subTable.Max = data.Amount end
        end
    end
    
    -- OPTIMIZATION: Return data object to pool
    returnDataObject(data)
end

function TortallDPSCore.UpdateEntry(entry, data)
    entry.Amount    = entry.Amount + data.Amount
    entry.Mitigated = entry.Mitigated + data.Mitigated
    entry.Absorbed  = entry.Absorbed + data.Absorbed
    entry.Count     = entry.Count + data.Count
    entry.Block     = entry.Block + data.Block
    entry.Disrupt   = entry.Disrupt + data.Disrupt
    entry.Dodge     = entry.Dodge + data.Dodge
    entry.Parry     = entry.Parry + data.Parry
    if ( entry.Min == nil ) or ( entry.Min > data.Amount ) then entry.Min = data.Amount end
    if ( entry.Max < data.Amount ) then entry.Max = data.Amount end

    local subTable
    if ( data.Critical == false ) then
        subTable = entry.Normal
    else
        subTable = entry.Crit
    end

    subTable.Amount    = subTable.Amount + data.Amount
    subTable.Mitigated = subTable.Mitigated + data.Mitigated
    subTable.Absorbed  = subTable.Absorbed + data.Absorbed
    subTable.Count     = subTable.Count + data.Count
    if ( subTable.Min == nil ) or ( subTable.Min > data.Amount ) then subTable.Min = data.Amount end
    if ( subTable.Max < data.Amount ) then subTable.Max = data.Amount end
end

function TortallDPSCore.Save( save, channel )
    if ( channel ~= nil ) then
        TortallDPSCore.SavedState[SaveKey][channel].save = save
    else
        TortallDPSCore.SavedState.savestate = save
    end
end
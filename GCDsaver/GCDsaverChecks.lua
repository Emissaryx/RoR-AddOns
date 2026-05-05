-- ==========================
-- ===== Public members =====
-- ==========================

GCDsaverChecks = {
    BasicChecks = {
        TargetValidity = {},
        IsEnabled = {},
        Cooldown = {},
        DefaultVirtualCooldown = {}
    },
    CustomChecks = {},
    ShortNames = {

    },    
    Loaded = false
}


-- ===========================
-- ===== Private members =====
-- ===========================

local Checks = {}


-- ===========================
-- ===== Private methods =====
-- ===========================
-- Basic checks
function Checks.TargetValidity(id)
    if not (GCDsaverAPI.IsAbility(id) or GCDsaverAPI.IsItem(id)) or (GCDsaverMemory.GetDisableDCheck("target", id) or GCDsaverAPI.IsPetAbility(id)) then return true end
    if GCDsaverAPI.IsItem(id) then return true end -- we dont check target on items... (may need to rethink this in future)
    local tv1,tv2 = IsTargetValid(id)
    if tv1 then
        return true
    end
    return false
    --return (tv1 and tv2)
end

function Checks.IsEnabled(id)
    if(GCDsaverAPI.IsPetAbility(id) and GCDsaverAPI.hasPet() and GCDsaverAPI.petHasTarget()) then return true end
    if GCDsaverMemory.GetDisableDCheck("enabled", id) then return true end
    return GCDsaverAPI.isEnabled(id)
end

function Checks.Cooldown(id)
    if GCDsaverMemory.GetDisableDCheck("cooldown", id) then return true end
    return not GCDsaverEngine.OnCooldown(id)
end

function Checks.DefaultVirtualCooldown(id)
    local target = GCDsaverAPI.GetDefaultTarget(id)
    local cooldown = GCDsaverMemory.GetCareerwideVCD(id)
    if not cooldown then return true end
    return not GCDsaverEngine.OnVirtualCDown(id, cooldown, target)
end

-- ============================
-- ===== Internal methods =====
-- ============================

function GCDsaverChecks.Initialize()
    GCDsaverChecks.Loaded = true
    return GCDsaverChecks.Loaded
end


-- ==========================
-- ===== Public methods =====
-- ==========================

function GCDsaverChecks.GetCheck(checkName)
    return Checks[checkName]
end

function GCDsaverChecks.RegisterCheck(checkName, check, params, shortName)
    if not checkName or type(checkName) ~= "string" then
        return
    end
    if not params or type(params) ~= "table" then
        return
    end
    if not check or type(check) ~= "function" then
        return
    end
    
    GCDsaverChecks.CustomChecks[checkName] = params
    Checks[checkName] = check
    if shortName and type(shortName) == "string" and shortName ~= ""
            and not GCDsaverChecks.ShortNames[shortName] then
        GCDsaverChecks.ShortNames[shortName] = checkName
    end
end
local checkFullName = "HitPoints"
local shortName = "hp"
local parameters = { GCDsaverAPI.PARAMS.hp, GCDsaverAPI.PARAMS.need  }
                 
local checkFunction =
function(abilityId, params)
    local hp = params[GCDsaverAPI.PARAMS.hp]
    local needHp = params[GCDsaverAPI.PARAMS.need]
    
    local hasHp = GCDsaverAPI.hasHitPoints(hp)
    if needHp == "-" then
        return not hasHp
    end
    
    return hasHp
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















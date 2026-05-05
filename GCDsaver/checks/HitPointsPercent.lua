local checkFullName = "HitPointsPercent"
local shortName = "hpp"
local parameters = { GCDsaverAPI.PARAMS.hpPercent, GCDsaverAPI.PARAMS.need, GCDsaverAPI.PARAMS.target   }
                 
local checkFunction =
function(abilityId, params)
    local hpPercent = params[GCDsaverAPI.PARAMS.hpPercent]
    local needHp = params[GCDsaverAPI.PARAMS.need]
    local target = params[GCDsaverAPI.PARAMS.target]
    
    if not target then
        target = GCDsaverAPI.GetDefaultTarget(abilityId)
    end
    
    local hasHp = GCDsaverAPI.hasHitPointsPercent(hpPercent, target)
    if needHp == "-" then
        return not hasHp
    end
    
    return hasHp
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















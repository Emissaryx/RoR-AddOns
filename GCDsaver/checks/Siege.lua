local checkFullName = "Siege"
local shortName = "si"
local parameters = { GCDsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local needSiege = params[GCDsaverAPI.PARAMS.need]
    
    local hasSI = GCDsaverAPI.inSiege()
    if needSiege == "-" then
        return not hasSI
    end
    
    return hasSI
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















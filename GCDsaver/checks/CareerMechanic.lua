local checkFullName = "CareerMechanic"
local shortName = "cm"
local parameters = { GCDsaverAPI.PARAMS.mechanic, GCDsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local requiredMechanic = params[GCDsaverAPI.PARAMS.mechanic]
    local needMechanic = params[GCDsaverAPI.PARAMS.need]
    
    local hasMechanic = GCDsaverAPI.hasMechanic(requiredMechanic)
    if needMechanic == "-" then
        return not hasMechanic
    end
    
    return hasMechanic
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















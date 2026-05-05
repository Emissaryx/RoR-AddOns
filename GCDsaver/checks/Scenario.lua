local checkFullName = "Scenario"
local shortName = "sc"
local parameters = { GCDsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local needScenario = params[GCDsaverAPI.PARAMS.need]
    
    local hasSC = GCDsaverAPI.inScenario()
    if needScenario == "-" then
        return not hasSC
    end
    
    return hasSC
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















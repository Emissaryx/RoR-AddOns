local checkFullName = "InAParty"
local shortName = "iap"
local parameters = { GCDsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local needInAParty = params[GCDsaverAPI.PARAMS.need]
    
    local hasIAP = GCDsaverAPI.inAParty()
    if needInAParty == "-" then
        return not hasIAP
    end
    
    return hasIAP
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















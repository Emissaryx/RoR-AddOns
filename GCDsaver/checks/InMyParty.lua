local checkFullName = "InMyParty"
local shortName = "imp"
local parameters = { GCDsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local needInMyParty = params[GCDsaverAPI.PARAMS.need]
    
    local hasIMP = GCDsaverAPI.inMyParty()
    if needInMyParty == "-" then
        return not hasIMP
    end
    
    return hasIMP
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















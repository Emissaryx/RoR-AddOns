local checkFullName = "Pet"
local shortName = "p"
local parameters = { GCDsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local needPet = params[GCDsaverAPI.PARAMS.need]
    
    local hasPet = GCDsaverAPI.hasPet()
    if needPet == "-" then
        return not hasPet
    end
    
    return hasPet
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















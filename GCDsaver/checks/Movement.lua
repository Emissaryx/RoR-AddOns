local checkFullName = "Movement"
local shortName = "mov"
local parameters = { GCDsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local needMoving = params[GCDsaverAPI.PARAMS.need]
    
    local isMoving = GCDsaverAPI.isMoving()
    if needMoving == "-" then
        return not isMoving
    end
    
    return isMoving
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















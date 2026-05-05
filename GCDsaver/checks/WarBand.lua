local checkFullName = "WarBand"
local shortName = "wb"
local parameters = { GCDsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local needWB = params[GCDsaverAPI.PARAMS.need]
    
    local hasWB = GCDsaverAPI.inWarBand()
    if needWB == "-" then
        return not hasWB
    end
    
    return hasWB
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















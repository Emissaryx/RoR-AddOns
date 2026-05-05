local checkFullName = "ActionPoints"
local shortName = "ap"
local parameters = { GCSsaverAPI.PARAMS.ap, GCSsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local ap = params[GCSsaverAPI.PARAMS.ap]
    local needAp = params[GCSsaverAPI.PARAMS.need]
    
    local hasAp = GCDsaverAPI.hasActionPoints(ap)
    if needAp == "-" then
        return not hasAp
    end
    
    return hasAp
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















local checkFullName = "Career"
local shortName = "c"
local parameters = { GCDsaverAPI.PARAMS.career, GCDsaverAPI.PARAMS.need, GCDsaverAPI.PARAMS.target }
                 
local checkFunction =
function(abilityId, params)
    local career = params[GCDsaverAPI.PARAMS.career]
    local needCareer = params[GCDsaverAPI.PARAMS.need]
    local target = params[GCDsaverAPI.PARAMS.target]
    
    if not target then
        target = GCDsaverAPI.GetDefaultTarget(abilityId)
    end
    
    local isCareer = GCDsaverAPI.isCareer(career, target)
    if needCareer == "-" then
        return not isCareer
    end
    
    return isCareer
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















local checkFullName = "AbilityTargetValid"
local shortName = "atv"
local parameters = { GCSsaverAPI.PARAMS.ability, GCSsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local abilityId = params[GCSsaverAPI.PARAMS.ability]
    local needTargetValid = params[GCSsaverAPI.PARAMS.need]
    
    local isValid = IsTargetValid(abilityId)
    if needTargetValid == "-" then
        return not isValid
    end
    
    return isValid
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















local checkFullName = "AbilityEnabled"
local shortName = "ae"
local parameters = { GCSsaverAPI.PARAMS.ability, GCSsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local abilityId = params[GCSsaverAPI.PARAMS.ability]
    local needEnabled = params[GCSsaverAPI.PARAMS.need]
    
    local isEnabled = IsAbilityEnabled(abilityId)
    if needEnabled == "-" then
        return not isEnabled
    end
    
    return isEnabled
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















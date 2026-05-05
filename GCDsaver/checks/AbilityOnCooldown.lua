local checkFullName = "AbilityOnCooldown"
local shortName = "acd"
local parameters = { GCSsaverAPI.PARAMS.ability, GCSsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local abilityId = params[GCSsaverAPI.PARAMS.ability]
    local needOnCooldown = params[GCSsaverAPI.PARAMS.need]
    
    local isOnCooldown = NerfedEngine.OnCooldown(abilityId)
    if needOnCooldown == "-" then
        return not isOnCooldown
    end
    
    return isOnCooldown
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















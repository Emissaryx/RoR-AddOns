local checkFullName = "AbilityChanneled"
local shortName = "ac"
local parameters = { GCSsaverAPI.PARAMS.ability, GCSsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local abilityId = params[GCSsaverAPI.PARAMS.ability]
    local needEnabled = params[GCSsaverAPI.PARAMS.need]
    
    local isEnabled = ActionBars:GetActionCastTimer (abilityId) == 0
    isEnabled = not isEnabled
    if needEnabled == "-" then
        return not isEnabled
    end
    
    return isEnabled
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















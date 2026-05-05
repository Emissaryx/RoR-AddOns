local checkFullName = "Effect"
local shortName = "e"
local parameters = { GCDsaverAPI.PARAMS.effect, GCDsaverAPI.PARAMS.stack, GCDsaverAPI.PARAMS.self, GCDsaverAPI.PARAMS.need, GCDsaverAPI.PARAMS.target, GCDsaverAPI.PARAMS.duration }
                 
local checkFunction =
function(abilityId, params)
    local effect = params[GCDsaverAPI.PARAMS.effect]
    local needEffect = params[GCDsaverAPI.PARAMS.need]
    
    local hasEffect = not GCDsaverChecks.GetCheck("Stack")(effect, params)
    if needEffect == "-" then
        return not hasEffect
    end
    
    return hasEffect
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















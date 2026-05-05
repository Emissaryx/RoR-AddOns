local checkFullName = "Combat"
local shortName = "com"
local parameters = { GCDsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local needCombat = params[GCDsaverAPI.PARAMS.need]
    
    local inCombat = GCDsaverAPI.inCombat()
    if needCombat == "-" then
        return not inCombat
    end
    
    return inCombat
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















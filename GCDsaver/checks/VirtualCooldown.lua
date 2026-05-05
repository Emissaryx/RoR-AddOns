local checkFullName = "VirtualCooldown"
local shortName = "cd"
local parameters = { GCDsaverAPI.PARAMS.cd}
                 
local checkFunction =
function(abilityId, params)
    local cooldown = params[GCDsaverAPI.PARAMS.cd]
    
    local target = GCDsaverAPI.GetDefaultTarget(abilityId)
    
    return not GCDsaverEngine.OnVirtualCDown(abilityId, cooldown, target)
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















local checkFullName = "Condition"
local shortName = "con"
local parameters = { GCDsaverAPI.PARAMS.condition, GCDsaverAPI.PARAMS.need, GCDsaverAPI.PARAMS.target }
                 
local checkFunction =
function(abilityId, params)
    local condition = params[GCDsaverAPI.PARAMS.condition]
    local needCondition = params[GCDsaverAPI.PARAMS.need]
    local target = params[GCDsaverAPI.PARAMS.target]
    
    if not target then
        target = GCDsaverAPI.GetDefaultTarget(abilityId)
    end
    
    local hasCondition = GCDsaverAPI.hasCondition(GCDsaverAPI.CONDITIONS[condition], target)
    if needCondition == "-" then
        return not hasCondition
    end
    
    return hasCondition
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















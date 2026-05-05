local checkFullName = "Stack"
local shortName = "st"
local parameters = { GCDsaverAPI.PARAMS.stack, GCDsaverAPI.PARAMS.self, GCDsaverAPI.PARAMS.target, GCDsaverAPI.PARAMS.duration}
                 
local checkFunction =
function(abilityId, params)
    local stackCount = params[GCDsaverAPI.PARAMS.stack]
    local onlySelf = params[GCDsaverAPI.PARAMS.self]
    local target = params[GCDsaverAPI.PARAMS.target]
    local duration = params[GCDsaverAPI.PARAMS.duration]
    
    if not onlySelf or not onlySelf == 's' then
        onlySelf = 'o'
    end
    
    if not target then
        target = GCDsaverAPI.GetDefaultTarget(abilityId)
    end
    
    local stackInfo = GCDsaverAPI.hasEffect(abilityId, target, onlySelf)
    if duration and stackInfo.duration and stackInfo.duration <= duration then
        return true
    end
    return stackInfo.stackCount < stackCount
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)






























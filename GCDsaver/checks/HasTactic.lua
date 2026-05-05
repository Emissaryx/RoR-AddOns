local checkFullName = "HasTactic" 
local shortName = "tac" 
local parameters = { GCDsaverAPI.PARAMS.ability, GCDsaverAPI.PARAMS.need } 
local checkFunction = 
function(abilityId, params) 
    local abilityId = params[GCDsaverAPI.PARAMS.ability] 
    local needEnabled = params[GCDsaverAPI.PARAMS.need] 
    local hasTactic = false 
        for _, tactic in pairs(GetActiveTactics()) do 
                if tactic == abilityId then hasTactic = true end 
        end 
        if needEnabled == "-" then 
                return not hasTactic 
        end 
    return hasTactic 
end 
GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName) 
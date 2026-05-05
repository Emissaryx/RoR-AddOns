local checkFullName = "EnemyTarget"
local shortName = "et"
local parameters = { GCDsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local needFriend = params[GCDsaverAPI.PARAMS.need]
    
    local hasFriend = GCDsaverAPI.hasFriend()
    if needFriend == "-" then
        return not hasFriend
    end
    
    return hasFriend
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















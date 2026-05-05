local checkFullName = "FriendlyTarget"
local shortName = "ft"
local parameters = { GCDsaverAPI.PARAMS.need, GCDsaverAPI.PARAMS.self }
                 
local checkFunction =
function(abilityId, params)
    local needFriend = params[GCDsaverAPI.PARAMS.need]
    local selfFriend = params[GCDsaverAPI.PARAMS.self]
    
    if not selfFriend or not selfFriend == 's' then    
        local hasFriend = GCDsaverAPI.hasFriend()
        if needFriend == "-" then
            return not hasFriend
        end
        return hasFriend
    else
        local isFriend = GCDsaverAPI.isFriend()
        if needFriend == "-" then
            return not isFriend
        end
        return isFriend
    end
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















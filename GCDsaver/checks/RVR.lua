local checkFullName = "RealmVersusRealm"
local shortName = "RVR"
local parameters = { GCDsaverAPI.PARAMS.need}
                 
local checkFunction =
function(abilityId, params)
    local needRVR = params[GCDsaverAPI.PARAMS.need]
    
    local hasRVR = GCDsaverAPI.isRVR()
    if needRVR == "-" then
        return not hasRVR
    end
    
    return hasRVR
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















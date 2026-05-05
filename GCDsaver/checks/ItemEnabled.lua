local checkFullName = "ItemEnabled"
local shortName = "ie"
local parameters = { GCDsaverAPI.PARAMS.item, GCDsaverAPI.PARAMS.need }
                 
local checkFunction =
function(abilityId, params)
    local itemId = params[GCDsaverAPI.PARAMS.item]
    local needEnabled = params[GCDsaverAPI.PARAMS.need]
    
    local isEnabled = GCDsaverChecks.GetCheck("IsEnabled")(itemId)
    if needEnabled == "-" then
        return not isEnabled
    end
    
    return isEnabled
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















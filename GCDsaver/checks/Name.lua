local checkFullName = "Name"
local shortName = "nam"
local parameters = { GCDsaverAPI.PARAMS.text, GCDsaverAPI.PARAMS.need, GCDsaverAPI.PARAMS.target }
                 
local checkFunction =
function(abilityId, params)
    local pattern = params[GCDsaverAPI.PARAMS.text]
    local needEnabled = params[GCDsaverAPI.PARAMS.need]
    local target = params[GCDsaverAPI.PARAMS.target]

    local isMatch = GCDsaverAPI.hasName(pattern, target)

    if needEnabled == "-" then
        return not isMatch
    end
    
    return isMatch
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















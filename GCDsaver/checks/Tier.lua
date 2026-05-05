local checkFullName = "Tier"
local shortName = "t"
local parameters = { GCDsaverAPI.PARAMS.tier, GCDsaverAPI.PARAMS.check }
                 
local checkFunction =

function(abilityId, params)

    local required = params[GCDsaverAPI.PARAMS.tier]
    local check = params[GCDsaverAPI.PARAMS.check]
    
    local actual = GCDsaverAPI.getEnemyTier()

    if check == ">=" then
        if need >= actual then
			return true
		end
    elseif check == "==" then
    	if need == actual then
			return true
		end
    elseif	check == "<=" then
	   	if need <= actual then
			return true
		end
    end
    
    return false

end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)

-- check passes if your current target is your bunny hop target
local checkFullName = "BunnyHop"
local shortName = "bhop"
local parameters = {GCDsaverAPI.PARAMS.need}
                 
local checkFunction =
function(abilityId, params)

    local needEnabled = params[GCDsaverAPI.PARAMS.need]
    
    local targetName = TargetInfo:UnitName(TargetInfo.HOSTILE_TARGET) 

		local isMatch = function(targetName)
		
		if(targetName == GCDsaverMacro.BunnyHopCheck()) then
			return true
		end
		
		return false;
    end

    if needEnabled == "-" then
        return not isMatch
    end
    
    return isMatch
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















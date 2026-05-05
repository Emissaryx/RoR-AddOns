local checkFullName = "Archetype"
local shortName = "a"
local parameters = { GCSsaverAPI.PARAMS.archetype, GCSsaverAPI.PARAMS.need, GCSsaverAPI.PARAMS.target }
                 
local checkFunction =
function(abilityId, params)
    local archetype = params[GCSsaverAPI.PARAMS.archetype]
    local needArchetype = params[GCSsaverAPI.PARAMS.need]
    local target = params[GCSsaverAPI.PARAMS.target]
    
    if not target then
        target = GCSsaverAPI.GetDefaultTarget(abilityId)
    end
    
    local isArchetype = GCSsaverAPI.isArchetype(archetype, target)
    if needArchetype == "-" then
        return not isArchetype
    end
    
    return isArchetype
end

GCDsaverChecks.RegisterCheck(checkFullName, checkFunction, parameters, shortName)





















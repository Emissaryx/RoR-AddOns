--[[
    TargetInfo:UpdateFromClient fix, coded by Aiiane
    - Solves the problem of bad target data if multiple addons are calling TargetInfo:UpdateFromClient()
    - 16 Oct. 2008
--]]
local version = 1
if TargetInfoFix and TargetInfoFix.version >= version then return end
if TargetInfoFix then
    TargetInfoFix.oldversion = TargetInfoFix.version
    TargetInfoFix.version = version
else
    TargetInfoFix = {}
    TargetInfoFix.version = version
end

if not TargetInfoFix.ptuEventRegistered then
    RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "TargetInfoFix.SET_TARGETINFO_FIX_UPDATE_FLAG_DONOTTOUCH")
    TargetInfoFix.ptuEventRegistered = true
end

if not TargetInfoFix.upEventRegistered then
    RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TargetInfoFix.APPLY_TARGETINFO_FIX_DONOTTOUCH")
    TargetInfoFix.upEventRegistered = true
end

function TargetInfoFix.APPLY_TARGETINFO_FIX_DONOTTOUCH()
    if SystemData.LoadingData.isLoading then return end
    if TargetInfoFix.fixApplied then return end
    
    TargetInfoFix.fixApplied = true
    
    -- Yes, this isn't nice hooking, it's replacement. I know.
    TargetInfo.UpdateFromClient =
        function(self, ...)
            local targets = GetUpdatedTargets ()
            
            if (targets ~= nil) then
                for unitId, targetData in pairs (targets) do
                    self:SetUnitInfo (unitId, targetData)
                end
            else
                -- Only consider a null result valid if we haven't had another UpdateFromClient call since our last seen PLAYER_TARGET_UPDATED
                if (self.TargetInfoFixUpdateFlag == nil) or (self.TargetInfoFixUpdateFlag == true) then
                    self:ClearUnits ()
                end
            end
            
            self.TargetInfoFixUpdateFlag = false
        end
    
    d("TargetInfo fix applied.")
end

function TargetInfoFix.SET_TARGETINFO_FIX_UPDATE_FLAG_DONOTTOUCH()
    TargetInfo.TargetInfoFixUpdateFlag = true
    
    if TargetInfoFix.upEventRegistered and TargetInfoFix.fixApplied then
        UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TargetInfoFix.APPLY_TARGETINFO_FIX_DONOTTOUCH")
        
        TargetInfoFix.SET_TARGETINFO_FIX_UPDATE_FLAG_DONOTTOUCH =
            function()
                TargetInfo.TargetInfoFixUpdateFlag = true
            end
    end
end
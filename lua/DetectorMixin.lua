// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//    
// lua\DetectorMixin.lua    
//    
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

DetectorMixin = CreateMixin(DetectorMixin)
DetectorMixin.type = "Detector"

// Should be smaller than DetectableMixin:kResetDetectionInterval
local kUpdateDetectionInterval = 0.5

DetectorMixin.expectedCallbacks =
{
    // Returns integer for team number
    GetTeamNumber = "",
    
    // Returns 0 if not active currently
    GetDetectionRange = "Return range of the detector.",
    
    GetOrigin = "Detection origin",
}

local function PerformDetection(self)

    // Get list of Detectables in range.
    local range = self:GetDetectionRange()
    
    if range > 0 then
    
        local teamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
        local origin = self:GetOrigin()
        local detectables = GetEntitiesWithMixinForTeamWithinRange("Detectable", teamNumber, origin, range)
        
        // Mark them as detected.
        for index, detectable in ipairs(detectables) do
            detectable:SetDetected(true)
        end
        
    end
    
    return true
    
end

function DetectorMixin:__initmixin()

    self.timeSinceLastDetected = 0
    
    self:AddTimedCallback(PerformDetection, kUpdateDetectionInterval)
    
end
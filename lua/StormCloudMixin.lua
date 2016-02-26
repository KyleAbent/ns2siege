// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\StormCloudMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

StormCloudMixin = CreateMixin( StormCloudMixin )
StormCloudMixin.type = "Storm"

kStormCloudSpeed = 1.8

StormCloudMixin.networkVars =
{
    stormCloudSpeed = "private boolean",
}

function StormCloudMixin:__initmixin()

    self.timeUntilStormCloud = 0
    self.stormCloudSpeed = false
    
end

function StormCloudMixin:ModifyMaxSpeed(maxSpeedTable)

    if self.stormCloudSpeed then
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed + kStormCloudSpeed
    end
    
end

if Server then

    function StormCloudMixin:SetSpeedBoostDuration(duration)
        
        self.timeUntilStormCloud = Shared.GetTime() + duration
        self.stormCloudSpeed = true
        
    end
    
    local function SharedUpdate(self)
        self.stormCloudSpeed = self.timeUntilStormCloud >= Shared.GetTime()
    end

    function StormCloudMixin:OnProcessMove(input)    
        SharedUpdate(self)
    end
    
    function StormCloudMixin:OnUpdate(deltaTime)   
        PROFILE("StormCloudMixin:OnUpdate")
        SharedUpdate(self)
    end
    
end


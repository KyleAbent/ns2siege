// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CelerityMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

CelerityMixin = CreateMixin( CelerityMixin )
CelerityMixin.type = "Celerity"

CelerityMixin.networkVars =
{
    celeritySpeedScalar = "private float",
}

function CelerityMixin:__initmixin()
    self.celeritySpeedScalar = 0
end

function CelerityMixin:ModifyMaxSpeed(maxSpeedTable)
    maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed + self.celeritySpeedScalar * kCelerityAddSpeed
end

if Server then
    function CelerityMixin:OnProcessMove(input)
    
        if GetHasCelerityUpgrade(self) then
            self.celeritySpeedScalar = Clamp(GetSpurLevel(self:GetTeamNumber()) / 3, 0, 1)
        else
            self.celeritySpeedScalar = 0
        end    
    end
end


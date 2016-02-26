// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\WebableMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

WebableMixin = CreateMixin( WebableMixin )
WebableMixin.type = "Webable"

WebableMixin.optionalCallbacks =
{
    OnWebbed = "Called when entity is being webbed.",
    OnWebbedEnd = "Called when entity leaves webbed state."
}

WebableMixin.networkVars =
{
    webbed = "boolean",
    timeWebEnds = "private time"
}

function WebableMixin:__initmixin()

    if Server then
        self.webbed = false
        self.timeWebEnds = 0
    end
    
end

function WebableMixin:ModifyMaxSpeed(maxSpeedTable)

    if self.webbed then
    
        local slowDown = 0.15
    
        if self.GetWebSlowdownScalar then
            slowDown = self:GetWebSlowdownScalar() or 1
        end
    
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * slowDown
    end

end

function WebableMixin:GetIsWebbed()
    return self.webbed
end    

function WebableMixin:SetWebbed(duration)

    self:TriggerEffects("webbed")

    self.timeWebEnds = Shared.GetTime() + duration
    if not self.webbed and self.OnWebbed then
        self:OnWebbed()
    end

    self.webbed = true
    
    if self:isa("Player") then
    
        local slowdown = 0.15
        
        if self.GetWebSlowdownScalar then
            slowdown = self:GetWebSlowdownScalar() or 1
        end
    
        local velocity = self:GetVelocity()
        velocity.x = velocity.x * slowdown
        velocity.z = velocity.z * slowdown
        velocity.y = math.min(1, velocity.y * slowdown)
        self:SetVelocity(velocity)
        
    end
    
end

local function SharedUpdate(self)

    local wasWebbed = self.webbed
    self.webbed = self.timeWebEnds > Shared.GetTime()
    
    if wasWebbed and not self.webbed and self.OnWebbedEnd then
        self:OnWebbedEnd()
    end
    
end

if Server then

    function WebableMixin:OnUpdate(deltaTime)
        PROFILE("WebableMixin:OnUpdate")
        SharedUpdate(self)
    end
    
end

function WebableMixin:OnProcessMove(input)

    SharedUpdate(self)
    
    for _, web in ipairs(GetEntitiesForTeamWithinRange("Web", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kMaxWebLength * 2)) do
        web:UpdateWebOnProcessMove(self)
    end
    
end

function WebableMixin:OnUpdateAnimationInput(modelMixin)
    modelMixin:SetAnimationInput("webbed", self.webbed)
end

function WebableMixin:OnUpdateRender()

    // TODO: custom material?

end

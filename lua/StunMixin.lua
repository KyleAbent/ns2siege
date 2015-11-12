// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\StunMixin.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

StunMixin = CreateMixin(StunMixin)
StunMixin.type = "Stun"

StunMixin.optionalCallbacks =
{
    OnStun = "Called when a knockback is triggered",
    GetIsStunAllowed = "Return true/false to limit stuns only to certain situations."
}

StunMixin.networkVars =
{
timeLastStun = "time"

}

function StunMixin:__initmixin()

    // time stamp when stun ends
    self.timeLastStun = 0
end
function StunMixin:GetLastStunTime()
return self.timeLastStun
end
function StunMixin:SetStun()

    local allowed = true
    
    if self.GetIsStunAllowed then
        allowed = self:GetIsStunAllowed()
    end
    
    if allowed then
    
        self.timeLastStun = Shared.GetTime()
        
        if self.OnStun then
        self:OnStun()
        end
        
    end
    
end

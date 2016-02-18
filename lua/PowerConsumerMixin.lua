// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\PowerConsumerMixin.lua
//
//    Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/PowerUtility.lua")

PowerConsumerMixin = CreateMixin(PowerConsumerMixin)
PowerConsumerMixin.type = "PowerConsumer"

PowerConsumerMixin.ClientPowerNodeCheckIntervall = 10

// This is needed so alien structures can be cloaked, but not marine structures
PowerConsumerMixin.expectedCallbacks =
{
    GetRequiresPower = "Return true/false if this object requires power"
}

PowerConsumerMixin.optionalCallbacks =
{
}

PowerConsumerMixin.networkVars =
{
    powered = "boolean",
    powerSurge = "boolean",
    mainbattle = "boolean",
}

function PowerConsumerMixin:__initmixin()
    self.powered = true
    self.mainbattle = false
end
function PowerConsumerMixin:GetIsPowered() 
    return true
end
function PowerConsumerMixin:SetPowerOn() 
    Print("Derp")
        self.powered = true
end
function PowerConsumerMixin:SetPowerOff() 
    Print("Derp")
        self.powered = true
end
if Server then
    function PowerConsumerMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)
    
       
        if not self.mainbattle or ( self:GetIsSiege() and not string.find(self:GetLocationName(), "Siege") and not string.find(self:GetLocationName(), "siege") ) then 
         damageTable.damage = damageTable.damage * kMainRoomDamageMult
        end
        
    end
    
       function PowerConsumerMixin:GetIsSiege()
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   return true
               end
            end
            return false
      end
      
end

    
// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\SupplyUserMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

SupplyUserMixin = CreateMixin( SupplyUserMixin )
SupplyUserMixin.type = "Supply"

SupplyUserMixin.networkVars =
{
    iscreditstructure = "boolean",
}
function SupplyUserMixin:__initmixin()
    
    assert(Server)    
    
    local team = self:GetTeam()
    if team and team.AddSupplyUsed then
    
        team:AddSupplyUsed(LookupTechData(self:GetTechId(), kTechDataSupply, 0))
        self.supplyAdded = true   
 
    end
   self.iscreditstructure = false
end

local function RemoveSupply(self)

    if self.supplyAdded then
        
        local team = self:GetTeam()
        if team and team.RemoveSupplyUsed then
            
            team:RemoveSupplyUsed(LookupTechData(self:GetTechId(), kTechDataSupply, 0))
            self.supplyAdded = false
            
        end
        
    end
    
end
function SupplyUserMixin:GetIsaCreditStructure()
return self.iscreditstructure
end
function SupplyUserMixin:SetIsCreditStructure()
self.iscreditstructure = true
end
function SupplyUserMixin:OnKill()
    if self:GetIsaCreditStructure() then return end
    RemoveSupply(self)
end

function SupplyUserMixin:OnDestroy()
    if self:GetIsaCreditStructure() then return end
    RemoveSupply(self)
    
end

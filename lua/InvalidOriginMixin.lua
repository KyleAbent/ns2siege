// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//    
// lua\InvalidOriginMixin.lua
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)  
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

/**
 * If an entity is outside the playable area, OnInvalidOrigin will be called
 * by the engine. This mixin destroys the entity.
 */
InvalidOriginMixin = CreateMixin(InvalidOriginMixin)
InvalidOriginMixin.type = "InvalidOrigin"

InvalidOriginMixin.networkVars =
{
}

function InvalidOriginMixin:OnInvalidOrigin()

 if HasMixin(self, "Moveable") or self:isa("FuncTrain") or self:isa("LogicBreakable") then return end //just till actual issue is fixed
 
    Print("Warning: A " .. self:GetClassName() .. " went out of bounds, destroying...")
    
    if self:isa("Spectator") then
        self:SetOrigin(Vector(0,0,0))
    elseif HasMixin(self, "Live") then
        self:Kill()
    else
        DestroyEntity(self)
    end
    
end
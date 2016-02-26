// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Weapons\Candy.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/TeamMixin.lua")

class 'Candy' (Projectile)

Candy.kMapName = "Candy"
Candy.kRadius = 0.05
local kLifetime = 5

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function Candy:OnCreate()

    Projectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    
end

function Candy:OnInitialized()

    Projectile.OnInitialized(self)
    
    if Server then
        self:AddTimedCallback(Candy.TimeUp, kLifetime)
    end
    
end

if Server then

    function Candy:ProcessHit(targetHit, surface, normal)
    
        if (not self:GetOwner() or targetHit ~= self:GetOwner()) then
            //DestroyEntity(self)
        end
        
    end
    
    function Candy:TimeUp(currentRate)
    
        DestroyEntity(self)
        return false
        
    end
    
end

Shared.LinkClassToMap("Candy", Candy.kMapName, networkVars)
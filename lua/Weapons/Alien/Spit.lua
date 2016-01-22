// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Spit.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/SharedDecal.lua")

PrecacheAsset("materials/infestation/spit_decal.surface_shader")

class 'Spit' (PredictedProjectile)

Spit.kMapName = "spit"
Spit.kDamage = kSpitDamage
Spit.kClearOnImpact = true
Spit.kClearOnEnemyImpact = true
Spit.kModelName          = PrecacheAsset("models/alien/cyst/cyst.model")
local networkVars =
{
}

local kSpitLifeTime = 8

//Spit.kProjectileCinematic = PrecacheAsset("cinematics/alien/gorge/dripping_slime.cinematic")
Spit.kRadius = 0.15

AddMixinNetworkVars(TeamMixin, networkVars)

function Spit:OnCreate()

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, DamageMixin)
    InitMixin(self, TeamMixin)
    
    if Server then
        self:AddTimedCallback(Spit.TimeUp, kSpitLifeTime)
    end

end
function Spit:GetProjectileModel()
    return Spit.kModelName
end 
function Spit:GetDeathIconIndex()
    return kDeathMessageIcon.Spit
end

function Spit:GetWeaponTechId()
    return kTechId.Spit
end

if Server then

local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end
          
    function Spit:ProcessHit(targetHit, surface, normal, hitPoint)

        if self:GetOwner() ~= targetHit then
            self:DoDamage(kSpitDamage, targetHit, hitPoint, normal, "none", false, false)
            if entity ~= nil and HasMixin(entity, "Webable") then entity:SetWebbed(4) end
        elseif self:GetOwner() == targetHit then
            //a little hacky
            local player = self:GetOwner()
            if player then
                local eyePos = player:GetEyePos()        
                local viewCoords = player:GetViewCoords()
                local trace = Shared.TraceRay(eyePos, eyePos + viewCoords.zAxis * 1.5, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
                if trace.fraction ~= 1 then
                    local entity = trace.entity
                    if entity ~= nil and HasMixin(entity, "Webable") then entity:SetWebbed(4) end
                    self:DoDamage(kSpitDamage, entity, hitPoint, normal, "none", false, false)
                end
            end
        end
        
        GetEffectManager():TriggerEffects("spit_hit", { effecthostcoords = self:GetCoords() })
        
        local cysts = GetEntitiesWithinRange("Cyst", self:GetOrigin(), kCystRedeployRange)
        if #cysts == 0 then
          --enforce ground
           //for i = 1, #20 do
        local origin = GetGroundAtPointWithCapsule(self:GetOrigin(), Vector(.25,.25,.25),  PhysicsMask.CystBuild, EntityFilterOne(self))
        //   if origin then break end
           //end
           if origin then
             if GetPathingRequirementsMet(origin, Vector(.25,.25,.25)) then
             local cyst = CreateEntity(Cyst.kMapName, origin, 2)
             end
           end
           
        end   
        DestroyEntity(self)
        
    end
  
    function Spit:TimeUp()

        DestroyEntity(self)
        return false
        
    end
    
end

Shared.LinkClassToMap("Spit", Spit.kMapName, networkVars)
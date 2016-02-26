// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\ClusterGrenade.lua 
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Projectile.lua")

class 'ClusterGrenade' (PredictedProjectile)

ClusterGrenade.kMapName = "clustergrenadeprojectile"
ClusterGrenade.kModelName = PrecacheAsset("models/marine/grenades/gr_cluster_world.model")

local networkVars = { }

local kLifeTime = 1.2

ClusterGrenade.kRadius = 0.085
ClusterGrenade.kDetonateRadius = 0.17
ClusterGrenade.kClearOnImpact = false
ClusterGrenade.kClearOnEnemyImpact = true

local kGrenadeCameraShakeDistance = 15
local kGrenadeMinShakeIntensity = 0.01
local kGrenadeMaxShakeIntensity = 0.12

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

local kClusterGrenadeFragmentPoints =
{
    Vector(0.1, 0.12, 0.1),
    Vector(-0.1, 0.12, -0.1),
    Vector(0.1, 0.12, -0.1),
    Vector(-0.1, 0.12, 0.1),
    
    Vector(-0.0, 0.12, 0.1),
    Vector(-0.1, 0.12, 0.0),
    Vector(0.1, 0.12, 0.0),
    Vector(0.0, 0.12, -0.1),
}

local function CreateFragments(self)

    local origin = self:GetOrigin()
    local player = self:GetOwner()
        
    for i = 1, #kClusterGrenadeFragmentPoints do
    
        local creationPoint = origin + kClusterGrenadeFragmentPoints[i]
        local fragment = CreateEntity(ClusterFragment.kMapName, creationPoint, self:GetTeamNumber())
        
        local startVelocity = GetNormalizedVector(creationPoint - origin) * (3 + math.random() * 6) + Vector(0, 4 * math.random(), 0)
        fragment:Setup(player, startVelocity, true, nil, self)
    
    end

end

function ClusterGrenade:OnCreate()

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    
    if Server then
    
        self:AddTimedCallback(ClusterGrenade.TimedDetonateCallback, kLifeTime)
        
    end
    
end

function ClusterGrenade:ProcessHit(targetHit, surface)

    if targetHit and GetAreEnemies(self, targetHit) then
    
        if Server then
            self:Detonate(targetHit)
        else
            return true
        end    
    
    end

    if Server then
    
        if self:GetVelocity():GetLength() > 2 then
            self:TriggerEffects("grenade_bounce")
        end
        
    end
    
    return false
    
end

function ClusterGrenade:ProcessNearMiss( targetHit, endPoint )
    if targetHit and GetAreEnemies(self, targetHit) then
        if Server then
            self:Detonate( targetHit )
        end
        return true
    end
end

if Server then
    
    function ClusterGrenade:TimedDetonateCallback()
        self:Detonate()
    end
        
    function ClusterGrenade:Detonate(targetHit)

        CreateFragments(self)

        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kClusterGrenadeDamageRadius)
        table.removevalue(hitEntities, self)

        if targetHit then
            table.removevalue(hitEntities, targetHit)
            self:DoDamage(kClusterGrenadeDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
        end

        RadiusDamage(hitEntities, self:GetOrigin(), kClusterGrenadeDamageRadius, kClusterGrenadeDamage, self)
        
        local surface = GetSurfaceFromEntity(targetHit)
        
        if GetIsVortexed(self) then
            surface = "ethereal"
        end

        local params = { surface = surface }
        if not targetHit then
            params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
        end
        
        self:TriggerEffects("cluster_grenade_explode", params)
        CreateExplosionDecals(self)
        TriggerCameraShake(self, kGrenadeMinShakeIntensity, kGrenadeMaxShakeIntensity, kGrenadeCameraShakeDistance)
        
        DestroyEntity(self)

end

end

function ClusterGrenade:GetDeathIconIndex()
    return kDeathMessageIcon.ClusterGrenade
end

Shared.LinkClassToMap("ClusterGrenade", ClusterGrenade.kMapName, networkVars)


class 'ClusterFragment' (Projectile)

ClusterFragment.kMapName = "clusterfragment"
--ClusterFragment.kModelName = PrecacheAsset("models/effects/frag_metal.model")

function ClusterFragment:OnCreate()

    Projectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    
    if Server then
        self:AddTimedCallback(ClusterFragment.TimedDetonateCallback, math.random() * 1 + 0.5)
    elseif Client then
        self:AddTimedCallback(ClusterFragment.CreateResidue, 0.06)
    end
    
end

function ClusterFragment:GetProjectileModel()
    return ClusterFragment.kModelName
end

function ClusterFragment:GetDeathIconIndex()
    return kDeathMessageIcon.ClusterGrenade
end

if Server then

    function ClusterFragment:TimedDetonateCallback()
        self:Detonate()
    end

    function ClusterFragment:Detonate(targetHit)

        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kClusterFragmentDamageRadius)
        table.removevalue(hitEntities, self)

        if targetHit then
            table.removevalue(hitEntities, targetHit)
            self:DoDamage(kClusterFragmentDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
        end

        RadiusDamage(hitEntities, self:GetOrigin(), kClusterFragmentDamageRadius, kClusterFragmentDamage, self)
        
        local surface = GetSurfaceFromEntity(targetHit)

        local params = { surface = surface }
        if not targetHit then
            params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
        end
        
        self:TriggerEffects("cluster_fragment_explode", params)
        CreateExplosionDecals(self)
        DestroyEntity(self)

    end

end

function ClusterFragment:CreateResidue()

    self:TriggerEffects("clusterfragment_residue")
    return true

end

Shared.LinkClassToMap("ClusterFragment", ClusterFragment.kMapName, networkVars)
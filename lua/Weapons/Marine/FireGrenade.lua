// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\Grenade.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")

class 'FireGrenade' (PredictedProjectile)

FireGrenade.kMapName = "firegrenade"
FireGrenade.kModelName = PrecacheAsset("models/marine/grenades/gr_nerve_world.model")
FireGrenade.kUseServerPosition = true




FireGrenade.kRadius = 0.085
FireGrenade.kClearOnImpact = false
FireGrenade.kClearOnEnemyImpact = false 


local networkVars = 
{
    releaseGas = "boolean"
}

local kLifeTime = 10
local kGasReleaseDelay = 2

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

local function TimeUp(self)
    DestroyEntity(self)
end

function FireGrenade:OnCreate()

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)

    if Server then    
        self:AddTimedCallback(TimeUp, kLifeTime)
        self:AddTimedCallback(FireGrenade.ReleaseGas, kGasReleaseDelay)
        self:AddTimedCallback(FireGrenade.UpdateFireFlameCloud, 1)    
    end
   self.releaseGas = false
    self.clientGasReleased = false
end

function FireGrenade:GetDeathIconIndex()
    return kDeathMessageIcon.GasGrenade
end


    function FireGrenade:ProcessHit(targetHit, surface, normal, endPoint )

       if self:GetVelocity():GetLength() > 2 then
           self:TriggerEffects("grenade_bounce")
        end
        
    end
if Client then

    function FireGrenade:OnUpdateRender()
    
        PredictedProjectile.OnUpdateRender(self)
    
        if self.releaseGas and not self.clientGasReleased then

            self:TriggerEffects("release_firegas", { effethostcoords = Coords.GetTranslation(self:GetOrigin())} )        
            self.clientGasReleased = true
        
        end
    
    end
elseif Server then
        
    function FireGrenade:ReleaseGas()  
        self.releaseGas = true    
    end
    
    function FireGrenade:UpdateFireFlameCloud()
    
        if self.releaseGas then
        
            local direction = Vector(math.random() - 0.5, 0.5, math.random() - 0.5)
            direction:Normalize()
            
            local trace = Shared.TraceRay(self:GetOrigin() + Vector(0, 0.2, 0), self:GetOrigin() + direction * 7, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAll())
            local fireflamecloud = CreateEntity(FireFlameCloud.kMapName, self:GetOrigin(), self:GetTeamNumber())
            fireflamecloud:SetEndPos(trace.endPoint)
            
            local owner = self:GetOwner()
            if owner then
                fireflamecloud:SetOwner(owner)
            end
        
        end
        
        return true
    
    end
end

Shared.LinkClassToMap("FireGrenade", FireGrenade.kMapName, networkVars)


class 'FireFlameCloud' (Entity)

FireFlameCloud.kMapName = "fireflamecloud"
FireFlameCloud.kEffectName = PrecacheAsset("cinematics/marine/fireflamecloud.cinematic")

local gFireFlameCloudDamageTakers = {}

local kCloudUpdateRate = 1
local kSpreadDelay = 0.6
local kFireFlameCloudRadius = 7
local kFireFlameCloudLifetime = 6

local kCloudMoveSpeed = 2

local networkVars =
{
}

AddMixinNetworkVars(TeamMixin, networkVars)

function FireFlameCloud:OnCreate()

    Entity.OnCreate(self)

    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)

    if Server then
    
        self.creationTime = Shared.GetTime()
    
        self:AddTimedCallback(TimeUp, kFireFlameCloudLifetime)
        self:AddTimedCallback(FireFlameCloud.DoSetOnFire, kCloudUpdateRate)
        
        InitMixin(self, OwnerMixin)
        
    end
    
    self:SetUpdates(true)
    self:SetRelevancyDistance(kMaxRelevancyDistance)

end

function FireFlameCloud:SetEndPos(endPos)
    self.endPos = Vector(endPos)
end

if Client then

    function FireFlameCloud:OnInitialized()

        local cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        cinematic:SetCinematic(FireFlameCloud.kEffectName)
        cinematic:SetParent(self)
        cinematic:SetCoords(Coords.GetIdentity())
        
    end
    
end

local function GetRecentlyDamaged(entityId, time)

    for index, pair in ipairs(gFireFlameCloudDamageTakers) do
        if pair[1] == entityId and pair[2] > time then
            return true
        end
    end
    
    return false

end

local function SetRecentlyDamaged(entityId)

    for index, pair in ipairs(gFireFlameCloudDamageTakers) do
        if pair[1] == entityId then
            table.remove(gFireFlameCloudDamageTakers, index)
        end
    end
    
    table.insert(gFireFlameCloudDamageTakers, {entityId, Shared.GetTime()})
    
end

local function GetIsInCloud(self, entity, radius)

    local targetPos = entity.GetEyePos and entity:GetEyePos() or entity:GetOrigin()    
    return (self:GetOrigin() - targetPos):GetLength() <= radius

end

function FireFlameCloud:DoSetOnFire()

    local radius = math.min(1, (Shared.GetTime() - self.creationTime) / kSpreadDelay) * kFireFlameCloudRadius

    for _, entity in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), 2*kFireFlameCloudRadius)) do

        if not GetRecentlyDamaged(entity:GetId(), (Shared.GetTime() - kCloudUpdateRate)) and GetIsInCloud(self, entity, radius) then
            
            self:DoDamage(kFireFlameCloudDamagePerSecond * kCloudUpdateRate, entity, entity:GetOrigin(), GetNormalizedVector(self:GetOrigin() - entity:GetOrigin()), "none")
         //   entity:SetOnFire(4)
            SetRecentlyDamaged(entity:GetId())
            
        end
    
    end

    return true

end

function FireFlameCloud:GetDeathIconIndex()
    return kDeathMessageIcon.GasGrenade
end

if Server then

    function FireFlameCloud:OnUpdate(deltaTime)
    
        if self.endPos then
            local newPos = SlerpVector(self:GetOrigin(), self.endPos, deltaTime * kCloudMoveSpeed)
            self:SetOrigin(newPos)
        end
        
    end

end

function FireFlameCloud:GetDamageType()
    return kDamageType.Flame
end

Shared.LinkClassToMap("FireFlameCloud", FireFlameCloud.kMapName, networkVars)


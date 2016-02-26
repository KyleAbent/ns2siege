// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\GasGrenade.lua 
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/OwnerMixin.lua")

class 'GasGrenade' (PredictedProjectile)

GasGrenade.kMapName = "gasgrenadeprojectile"
GasGrenade.kModelName = PrecacheAsset("models/marine/grenades/gr_nerve_world.model")
GasGrenade.kUseServerPosition = true

GasGrenade.kRadius = 0.085
GasGrenade.kClearOnImpact = false
GasGrenade.kClearOnEnemyImpact = false

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

function GasGrenade:OnCreate()

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    
    if Server then  
  
        self:AddTimedCallback(TimeUp, kLifeTime)
        self:AddTimedCallback(GasGrenade.ReleaseGas, kGasReleaseDelay)
        self:AddTimedCallback(GasGrenade.UpdateNerveGas, 1)
        
    end
    
    self.releaseGas = false
    self.clientGasReleased = false
    
end

function GasGrenade:ProcessHit(targetHit, surface)

    if self:GetVelocity():GetLength() > 2 then
        self:TriggerEffects("grenade_bounce")
    end
    
end

if Client then

    function GasGrenade:OnUpdateRender()
    
        PredictedProjectile.OnUpdateRender(self)
    
        if self.releaseGas and not self.clientGasReleased then

            self:TriggerEffects("release_nervegas", { effethostcoords = Coords.GetTranslation(self:GetOrigin())} )        
            self.clientGasReleased = true
        
        end
    
    end

elseif Server then
    
    function GasGrenade:ReleaseGas()  
        self.releaseGas = true    
    end
    
    function GasGrenade:UpdateNerveGas()
    
        if self.releaseGas then
        
            local direction = Vector(math.random() - 0.5, 0.5, math.random() - 0.5)
            direction:Normalize()
            
            local trace = Shared.TraceRay(self:GetOrigin() + Vector(0, 0.2, 0), self:GetOrigin() + direction * 7, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAll())
            local nervegascloud = CreateEntity(NerveGasCloud.kMapName, self:GetOrigin(), self:GetTeamNumber())
            nervegascloud:SetEndPos(trace.endPoint)
            
            local owner = self:GetOwner()
            if owner then
                nervegascloud:SetOwner(owner)
            end
        
        end
        
        return true
    
    end

end

Shared.LinkClassToMap("GasGrenade", GasGrenade.kMapName, networkVars)

class 'NerveGasCloud' (Entity)

NerveGasCloud.kMapName = "nervegascloud"
NerveGasCloud.kEffectName = PrecacheAsset("cinematics/marine/nervegascloud.cinematic")

local gNerveGasDamageTakers = {}

local kCloudUpdateRate = 0.3
local kSpreadDelay = 0.6
local kNerveGasCloudRadius = 7
local kNerveGasCloudLifetime = 6

local kCloudMoveSpeed = 2

local networkVars =
{
}

AddMixinNetworkVars(TeamMixin, networkVars)

function NerveGasCloud:OnCreate()

    Entity.OnCreate(self)

    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)

    if Server then
    
        self.creationTime = Shared.GetTime()
    
        self:AddTimedCallback(TimeUp, kNerveGasCloudLifetime)
        self:AddTimedCallback(NerveGasCloud.DoNerveGasDamage, kCloudUpdateRate)
        
        InitMixin(self, OwnerMixin)
        
    end
    
    self:SetUpdates(true)
    self:SetRelevancyDistance(kMaxRelevancyDistance)

end

function NerveGasCloud:SetEndPos(endPos)
    self.endPos = Vector(endPos)
end

if Client then

    function NerveGasCloud:OnInitialized()

        local cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        cinematic:SetCinematic(NerveGasCloud.kEffectName)
        cinematic:SetParent(self)
        cinematic:SetCoords(Coords.GetIdentity())
        
    end
    
end

local function GetRecentlyDamaged(entityId, time)

    for index, pair in ipairs(gNerveGasDamageTakers) do
        if pair[1] == entityId and pair[2] > time then
            return true
        end
    end
    
    return false

end

local function SetRecentlyDamaged(entityId)

    for index, pair in ipairs(gNerveGasDamageTakers) do
        if pair[1] == entityId then
            table.remove(gNerveGasDamageTakers, index)
        end
    end
    
    table.insert(gNerveGasDamageTakers, {entityId, Shared.GetTime()})
    
end

local function GetIsInCloud(self, entity, radius)

    local targetPos = entity.GetEyePos and entity:GetEyePos() or entity:GetOrigin()    
    return (self:GetOrigin() - targetPos):GetLength() <= radius

end

function NerveGasCloud:DoNerveGasDamage()

    local radius = math.min(1, (Shared.GetTime() - self.creationTime) / kSpreadDelay) * kNerveGasCloudRadius

    for _, entity in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), 2*kNerveGasCloudRadius)) do

        if not GetRecentlyDamaged(entity:GetId(), (Shared.GetTime() - kCloudUpdateRate)) and GetIsInCloud(self, entity, radius) then
            
            self:DoDamage(kNerveGasDamagePerSecond * kCloudUpdateRate, entity, entity:GetOrigin(), GetNormalizedVector(self:GetOrigin() - entity:GetOrigin()), "none")
            SetRecentlyDamaged(entity:GetId())
            
        end
    
    end

    return true

end

function NerveGasCloud:GetDeathIconIndex()
    return kDeathMessageIcon.GasGrenade
end

if Server then

    function NerveGasCloud:OnUpdate(deltaTime)
    
        if self.endPos then
            local newPos = SlerpVector(self:GetOrigin(), self.endPos, deltaTime * kCloudMoveSpeed)
            self:SetOrigin(newPos)
        end
        
    end

end

function NerveGasCloud:GetDamageType()
    return kNerveGasDamageType
end

Shared.LinkClassToMap("NerveGasCloud", NerveGasCloud.kMapName, networkVars)


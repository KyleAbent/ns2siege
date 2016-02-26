// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Weapons\SnowBall.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/TeamMixin.lua")

class 'SnowBall' (Projectile)

SnowBall.kMapName = "SnowBall"
local kModelName = PrecacheAsset("seasonal/holiday2012/models/snowball_01.model")
local kSnowHit = PrecacheAsset("seasonal/holiday2012/cinematics/snowball_hit.cinematic")
local kHitSound = PrecacheAsset("sound/NS2.fev/common/snowball")
local kSnowSplatMaterial = PrecacheAsset("seasonal/holiday2012/materials/effects/snow_splat.material")
    
PrecacheAsset("seasonal/holiday2012/materials/effects/snow_splat.surface_shader")

local kLifetime = 60
local snow = nil

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function SnowBall:OnCreate()

    Projectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    
end

function SnowBall:OnInitialized()

    Projectile.OnInitialized(self)
    
    if Server then
        self:AddTimedCallback(SnowBall.TimeUp, kLifetime)
    end
    
end

function SnowBall:GetProjectileModel()
    return kModelName
end

if Server then

    function SnowBall:ProcessHit(targetHit, surface, normal)
    
        if (not self:GetOwner() or targetHit ~= self:GetOwner()) then
        
            self:TriggerEffects("snowball_hit")
            
            DestroyEntity(self)

            local coords = Coords.GetIdentity()
            coords.origin = self:GetOrigin()
            coords.yAxis = normal
            coords.zAxis = GetNormalizedVector(self.desiredVelocity)
            coords.xAxis = coords.zAxis:CrossProduct(coords.yAxis)
            coords.zAxis = coords.yAxis:CrossProduct(coords.xAxis)
            local angles = Angles()
            Shared.PlayWorldSound(nil, kHitSound, nil, coords.origin, 1)
            angles:BuildFromCoords(coords)
            local message = { origin = coords.origin, yaw = angles.yaw, pitch = angles.pitch, roll = angles.roll }
            local nearbyPlayers = GetEntitiesWithinRange("Player", self:GetOrigin(), 20)
            for p = 1, #nearbyPlayers do
                Server.SendNetworkMessage(nearbyPlayers[p], "SnowBallHit", message, false)
            end
            
        end
        
    end
    
    function SnowBall:TimeUp(currentRate)
    
        DestroyEntity(self)
        return false
        
    end
    
end

local kSnowBallHitMessage =
{
    origin = "vector",
    yaw = "angle",
    pitch = "angle",
    roll = "angle"
}
Shared.RegisterNetworkMessage("SnowBallHit", kSnowBallHitMessage)

if Client then

    local function OnMessageSnowBallHit(message)

        local coords = Angles(message.pitch, message.yaw, message.roll):GetCoords(message.origin)
        local snow_hit = Client.CreateCinematic(RenderScene.Zone_Default)//RenderScene.Zone_ViewModel)
        snow_hit:SetCinematic(kSnowHit)
        snow_hit:SetCoords(coords)
        snow_hit:SetIsVisible(true)
        
    end
    Client.HookNetworkMessage("SnowBallHit", OnMessageSnowBallHit)
    
end

Shared.LinkClassToMap("SnowBall", SnowBall.kMapName, networkVars)
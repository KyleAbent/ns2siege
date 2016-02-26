// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Weapons\SnowBallThrower.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/Weapons/SnowBall.lua")

class 'SnowBallThrower' (Weapon)

SnowBallThrower.kMapName = "snowballthrower"

local kPlayerVelocityFraction = 1
local kBombVelocity = 15

function SnowBallThrower:OnCreate()
    Weapon.OnCreate(self)
end

function SnowBallThrower:GetHUDSlot()
    return 1
end

function FireSnowballProjectile(player)

    if Server then
    
        local viewAngles = player:GetViewAngles()
        local viewCoords = viewAngles:GetCoords()
        local startPoint = player:GetEyePos() + viewCoords.zAxis * 1
        
        local startPointTrace = Shared.TraceRay(player:GetEyePos(), startPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
        startPoint = startPointTrace.endPoint
        
        local startVelocity = viewCoords.zAxis * kBombVelocity
        
        local snowBall = CreateEntity(SnowBall.kMapName, startPoint, player:GetTeamNumber())
        snowBall:Setup(player, startVelocity, true, nil, player)
        
    end
    
end

Shared.LinkClassToMap("SnowBallThrower", SnowBallThrower.kMapName, networkVars)
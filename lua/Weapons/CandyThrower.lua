// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Weapons\CandyThrower.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/Weapons/Candy.lua")
Script.Load("lua/Weapons/Projectile.lua")

class 'CandyThrower' (Weapon)

CandyThrower.kMapName = "candy_thrower"

local kModelName1 = PrecacheAsset("seasonal/halloween2014/models/candy/candy_01.model")
local kModelName2 = PrecacheAsset("seasonal/halloween2014/models/candy/candy_02.model")
local kModelName3 = PrecacheAsset("seasonal/halloween2014/models/candy/candy_03.model")

local kBombVelocity = 15
local kShootLimit = 0.5
local currentModel = 0

function CandyThrower:OnCreate()
    Weapon.OnCreate(self)
end

function CandyThrower:GetHUDSlot()
    return 2
end

local function PickModel()
    
    currentModel = currentModel + 1
    
    if currentModel == 1 then
        return kModelName1
    elseif currentModel == 2 then
        return kModelName2
    elseif currentModel == 3 then
        return kModelName3
    elseif currentModel == 4 then
        currentModel = 1
        return kModelName1
    end

end

function FireCandyProjectile(player)

    if Server then
    
        local viewAngles = player:GetViewAngles()
        
        local viewCoords = viewAngles:GetCoords()
        local startPoint = player:GetEyePos() + viewCoords.zAxis * 1
        
        local startPointTrace = Shared.TraceRay(player:GetEyePos(), startPoint, CollisionRep.Damage, PhysicsMask.PredictedProjectileGroup, EntityFilterOne(player))
        startPoint = startPointTrace.endPoint
        
        local startVelocity = viewCoords.zAxis * kBombVelocity
        
        local candy = CreateEntity(Candy.kMapName, startPoint, player:GetTeamNumber())
        candy:Setup(player, startVelocity, true, nil, player, PickModel())
        //local candy = player:CreatePredictedProjectile(Candy.kMapName, startPoint, startVelocity, 0.25, 0.25, true)
        
    end
    
end

function CandyThrower:GetIsDroppable()
    return false
end

Shared.LinkClassToMap("CandyThrower", CandyThrower.kMapName, networkVars)
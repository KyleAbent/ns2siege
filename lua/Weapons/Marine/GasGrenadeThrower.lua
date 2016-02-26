// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\GasGrenadeThrower.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Throws gas grenades.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/Weapons/Marine/GasGrenade.lua")

local networkVars =
{
}

class 'GasGrenadeThrower' (GrenadeThrower)

GasGrenadeThrower.kMapName = "gasgrenade"

local kModelName = PrecacheAsset("models/marine/grenades/gr_nerve.model")
local kViewModels = GenerateMarineGrenadeViewModelPaths("gr_nerve")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/grenade_view.animation_graph")

function GasGrenadeThrower:GetThirdPersonModelName()
    return kModelName
end

function GasGrenadeThrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function GasGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function GasGrenadeThrower:GetGrenadeClassName()
    return "GasGrenade"
end

Shared.LinkClassToMap("GasGrenadeThrower", GasGrenadeThrower.kMapName, networkVars)
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\ClusterGrenadeThrower.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Throws cluster grenades.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/Weapons/Marine/ClusterGrenade.lua")

local networkVars =
{
}

class 'ClusterGrenadeThrower' (GrenadeThrower)

ClusterGrenadeThrower.kMapName = "clustergrenade"

local kModelName = PrecacheAsset("models/marine/grenades/gr_cluster.model")
local kViewModels = GenerateMarineGrenadeViewModelPaths("gr_cluster")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/grenade_view.animation_graph")

function ClusterGrenadeThrower:GetThirdPersonModelName()
    return kModelName
end

function ClusterGrenadeThrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function ClusterGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function ClusterGrenadeThrower:GetGrenadeClassName()
    return "ClusterGrenade"
end

Shared.LinkClassToMap("ClusterGrenadeThrower", ClusterGrenadeThrower.kMapName, networkVars)
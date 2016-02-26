// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\PulseGrenadeThrower.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Throws pulse grenades.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/Weapons/Marine/PulseGrenade.lua")

local networkVars =
{
}

class 'PulseGrenadeThrower' (GrenadeThrower)

PulseGrenadeThrower.kMapName = "pulsegrenade"

local kModelName = PrecacheAsset("models/marine/grenades/gr_pulse.model")
local kViewModels = GenerateMarineGrenadeViewModelPaths("gr_pulse")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/grenade_view.animation_graph")

function PulseGrenadeThrower:GetThirdPersonModelName()
    return kModelName
end

function PulseGrenadeThrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function PulseGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function PulseGrenadeThrower:GetGrenadeClassName()
    return "PulseGrenade"
end

Shared.LinkClassToMap("PulseGrenadeThrower", PulseGrenadeThrower.kMapName, networkVars)
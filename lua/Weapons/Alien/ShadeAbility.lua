//
// lua\Weapons\Alien\ShadeAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'ShadeStructureAbility' (StructureAbility)

function ShadeStructureAbility:GetEnergyCost(player)
    return 0
end

function ShadeStructureAbility:GetPrimaryAttackDelay()
    return 0
end

function ShadeStructureAbility:GetGhostModelName(ability)
    return Shade.kModelName
end

function ShadeStructureAbility:GetDropStructureId()
    return kTechId.Shade
end

function ShadeStructureAbility:GetRequiredTechId()
    return kTechId.ShadeHive
end
local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end
function ShadeStructureAbility:GetIsPositionValid(displayOrigin, player, normal, lastClickedPosition, entity)
    return GetPathingRequirementsMet(displayOrigin,  GetExtents(kTechId.Shade) )
end

function ShadeStructureAbility:GetSuffixName()
    return "shade"
end
function ShadeStructureAbility:GetDropRange()
    return 1.5
end
function ShadeStructureAbility:GetDropClassName()
    return "Shade"
end

function ShadeStructureAbility:GetDropMapName()
    return Shade.kMapName
end
//
// lua\Weapons\Alien\CragAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'CragStructureAbility' (StructureAbility)

function CragStructureAbility:GetEnergyCost(player)
    return 0
end

function CragStructureAbility:GetGhostModelName(ability)
    return Crag.kModelName
end

function CragStructureAbility:GetDropStructureId()
    return kTechId.Crag
end
local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end
function CragStructureAbility:GetIsPositionValid(position, player)
    return GetPathingRequirementsMet(position,  GetExtents(kTechId.Crag) )
end
function CragStructureAbility:GetSuffixName()
    return "crag"
end
function CragStructureAbility:GetDropClassName()
    return "Crag"
end
function CragStructureAbility:GetDropRange()
    return 3
end

function CragStructureAbility:GetDropMapName()
    return Crag.kMapName
end

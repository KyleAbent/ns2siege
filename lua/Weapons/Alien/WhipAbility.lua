//
// lua\Weapons\Alien\WhipAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'WhipStructureAbility' (StructureAbility)

function WhipStructureAbility:GetEnergyCost(player)
    return kDropStructureEnergyCost
end
function WhipStructureAbility:GetGhostModelName(ability)
    return Whip.kModelName
end

function WhipStructureAbility:GetDropStructureId()
    return kTechId.Whip
end

function WhipStructureAbility:GetRequiredTechId()
    return kTechId.None
end
local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end
function WhipStructureAbility:GetIsPositionValid(displayOrigin, player, normal, lastClickedPosition, entity)
    return GetPathingRequirementsMet(displayOrigin,  GetExtents(kTechId.Whip) )
end

function WhipStructureAbility:GetSuffixName()
    return "whip"
end

function WhipStructureAbility:GetDropClassName()
    return "Whip"
end
function WhipStructureAbility:GetDropRange()
    return 1.5
end
function WhipStructureAbility:GetDropMapName()
    return Whip.kMapName
end
//
// lua\Weapons\Alien\ShiftAbility.lua

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'ShiftStructureAbility' (StructureAbility)

function ShiftStructureAbility:GetEnergyCost(player)
    return 0
end

function ShiftStructureAbility:GetPrimaryAttackDelay()
    return 0
end
local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end
function ShiftStructureAbility:GetIconOffsetY(secondary)
    return kAbilityOffset.Hydra
end

function ShiftStructureAbility:GetGhostModelName(ability)
    return Shift.kModelName
end

function ShiftStructureAbility:GetDropStructureId()
    return kTechId.Shift
end
function ShiftStructureAbility:GetRequiredTechId()
    return kTechId.ShiftHive
end

function ShiftStructureAbility:GetIsPositionValid(displayOrigin, player, normal, lastClickedPosition, entity)
    return GetPathingRequirementsMet(displayOrigin,  GetExtents(kTechId.Shift) )
end

function ShiftStructureAbility:GetSuffixName()
    return "shift"
end

function ShiftStructureAbility:GetDropClassName()
    return "Shift"
end
function ShiftStructureAbility:GetDropRange()
    return 1.5
end
function ShiftStructureAbility:GetDropMapName()
    return Shift.kMapName
end
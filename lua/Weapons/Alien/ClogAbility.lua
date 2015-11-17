// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\ClogAbility.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'ClogAbility' (StructureAbility)

local kMinDistance = 0.5
local kClogOffset = 0.3

function ClogAbility:OverrideInfestationCheck(trace)

    if trace.entity and trace.entity:isa("Clog") then
        return true
    end

    return false    

end

function ClogAbility:AllowBackfacing()
    return true
end
function ClogAbility:GetRequiredTechId()
    return kTechId.None
end
function ClogAbility:GetIsPositionValid(position, player)

    local valid = true
    local entities = GetEntitiesWithinRange("ScriptActor", position, 7)    
    for _, entity in ipairs(entities) do
    
        if not entity:isa("Infestation") and entity ~= player then
        
            local checkDistance = ConditionalValue(entity:isa("PhaseGate") or entity:isa("TunnelEntrance") or entity:isa("InfantryPortal"), 3, kMinDistance)
            valid = ((entity:GetCoords().yAxis * checkDistance * 0.75 + entity:GetOrigin()) - position):GetLength() > checkDistance

            if not valid then
                break
            end
        
        end
    
    end
    
    return valid

end

function ClogAbility:ModifyCoords(coords)
    coords.origin = coords.origin + coords.yAxis * kClogOffset
end

function ClogAbility:GetEnergyCost(player)
    return kDropStructureEnergyCost
end

function ClogAbility:GetDropRange()
    return 3
end

function ClogAbility:GetPrimaryAttackDelay()
    return 1.0
end

function ClogAbility:GetGhostModelName(ability)

    local player = ability:GetParent()
    if player and player:isa("Gorge") then
    
        local variant = player:GetVariant()
        if variant == kGorgeVariant.shadow then
            return Clog.kModelNameShadow
        end
        
    end
    
    return Clog.kModelName
    
end

function ClogAbility:GetDropStructureId()
    return kTechId.Clog
end

function ClogAbility:GetSuffixName()
    return "clog"
end

function ClogAbility:GetDropClassName()
    return "Clog"
end

function ClogAbility:GetDropMapName()
    return Clog.kMapName
end    
function ClogAbility:IsAllowed(player)
    return true
end

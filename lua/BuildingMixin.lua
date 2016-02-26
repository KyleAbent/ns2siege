// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\BuildingMixin.lua    
//    
//    Created by:   Andrew Spiering (andrew@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

BuildingMixin = { }
BuildingMixin.type = "Building"

function BuildingMixin:__initmixin()    
end

local function EvalBuildIsLegal(self, techId, origin, angle, builderEntity, isCommanderPicked)

    PROFILE("EvalBuildIsLegal")

    local legalBuildPosition = false
    local position = nil
    local attachEntity = nil
    local errorString = nil
    
    if not isCommanderPicked then
    
        // When Drifters and MACs build, or untargeted build/buy actions, trace from order point down to see
        // if they're trying to build on top of anything and if that's OK.
        local trace = Shared.TraceRay(Vector(origin.x, origin.y + .1, origin.z), Vector(origin.x, origin.y - .2, origin.z), CollisionRep.Select, PhysicsMask.CommanderBuild, EntityFilterOne(builderEntity))
        legalBuildPosition, position, attachEntity, errorString = GetIsBuildLegal(techId, trace.endPoint, angle, kStructureSnapRadius, self:GetOwner(), builderEntity)
        
    else
    
        local commander = self:GetOwner()
        if commander == nil then
            commander = self
        end
        legalBuildPosition, position, attachEntity, errorString = GetIsBuildLegal(techId, origin, angle, kStructureSnapRadius, commander, builderEntity)
        
    end
    
    return legalBuildPosition, position, attachEntity, errorString
    
end

// Returns true or false, as well as the entity id of the new structure (or -1 if false)
// If not isCommanderPicked, builderEntity will be the entity doing the building.
function BuildingMixin:AttemptToBuild(techId, origin, normal, orientation, isCommanderPicked, buildTech, builderEntity, trace, owner)

    local legalBuildPosition = false
    local position = nil
    local attachEntity = nil
    local coordsMethod = LookupTechData(techId, kTechDataOverrideCoordsMethod, nil)

    legalBuildPosition, position, attachEntity, errorString = EvalBuildIsLegal(self, techId, origin, orientation, builderEntity, isCommanderPicked)
    
    if legalBuildPosition then
    
        local commander = self:GetOwner()
        if commander == nil then
            commander = self
        end
        
        if owner ~= nil then
            commander = owner
        end
        
        local newEnt = nil
        if builderEntity and builderEntity.OverrideBuildEntity then
            newEnt = builderEntity:OverrideBuildEntity(techId, position, commander)
        end
        
        if not newEnt then
            newEnt = CreateEntityForCommander(techId, position, commander)
        end
        
        if newEnt ~= nil then
            if newEnt.UpdateWeaponSkins then
                -- Apply weapon variant
                newEnt:UpdateWeaponSkins( commander:GetClient() )
            end
            
            // Use attach entity orientation 
            if attachEntity then
                orientation = attachEntity:GetAngles().yaw
            end
            
            if coordsMethod then
            
                local coords = coordsMethod(newEnt:GetCoords(), normal)
                newEnt:SetCoords(coords)
            
            // If orientation yaw specified, set it
            elseif orientation then
            
                local angles = Angles(0, orientation, 0)
                local coords = Coords.GetLookIn(newEnt:GetOrigin(), angles:GetCoords().zAxis)
                newEnt:SetCoords(coords)
            
            else
            
                // align it with the surface (normal)
                local coords = Coords.GetLookIn(newEnt:GetOrigin(), Vector.zAxis, normal)
                newEnt:SetCoords(coords)
                
            end

            self:TriggerEffects("commander_create_local", { ismarine = GetIsMarineUnit(newEnt), isalien = GetIsAlienUnit(newEnt) })
            
            return true, newEnt:GetId()
            
        end
        
    elseif errorString then

        //DebugPrint("AttemptToBuild failed, errorString: %s. Stack: %s", errorString, Script.CallStack())
    
        local commander = self:isa("Commander") and self or self:GetOwner()
    
        if commander then
        
            if Server then
                local message = BuildCommanderErrorMessage(errorString, position)
                Server.SendNetworkMessage(commander, "CommanderError", message, true)  
            end
        
        end
    
    end
    
    return false, -1
    
end

// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\ObstacleMixin.lua    
//
// Created by: Dushan Leska (dushan@unknownworlds.com) 
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/PathingUtility.lua")

ObstacleMixin = CreateMixin(ObstacleMixin)
ObstacleMixin.type = "Obstacle"

gAllObstacles = { }

ObstacleMixin.expectedMixins =
{
    Extents = "Required for obstacle radius."
}

ObstacleMixin.optionalCallbacks =
{
    GetResetsPathing = "Pathing entities will recalculate their path when this obstacle is added / removed."
}

local PathingUtility_GetIsPathingMeshInitialized = GetIsPathingMeshInitialized

// technically it would be most correct to reset all entities in the world
// but practically, entities which implemented GetResetsPathing are of temporary nature and used for blocking,
// and unless units travel <range> faster than those temporary entities lifetime, there is no reason to change this
local function InformEntitiesInRange(self, range)

    for _, pathEnt in ipairs(GetEntitiesWithMixinWithinRange("Pathing", self:GetOrigin(), range)) do
        pathEnt:OnObstacleChanged()
    end

end

function RemoveAllObstacles()
    for obstacle, v in pairs(gAllObstacles) do
        obstacle:RemoveFromMesh()
    end
end

function ObstacleMixin:__initmixin()
    self.obstacleId = -1
end

// most classes call SetModel(modelName) in OnCreate or at least in OnInitialized, so the correct extents
// will already be set once ObstacleMixin:OnInitialized is being called
function ObstacleMixin:OnInitialized()
    self:AddToMesh()
end

function ObstacleMixin:OnPathingMeshInitialized()
    self:AddToMesh()
end

function ObstacleMixin:OnDestroy()
    self:RemoveFromMesh()
end

// obstacle mixin requires extents mixin, so this will be called after extents have been updated correctly
function ObstacleMixin:OnModelChanged()

    self:RemoveFromMesh()
    self:AddToMesh()
    
end

function ObstacleMixin:AddToMesh()

    if PathingUtility_GetIsPathingMeshInitialized() then
   
        if self.obstacleId ~= -1 then
            Pathing.RemoveObstacle(self.obstacleId)
            gAllObstacles[self] = nil
        end

        local position, radius, height = self:_GetPathingInfo()   
        self.obstacleId = Pathing.AddObstacle(position, radius, height) 
      
        if self.obstacleId ~= -1 then
        
            gAllObstacles[self] = true
            if self.GetResetsPathing and self:GetResetsPathing() then
                InformEntitiesInRange(self, 25)
            end
            
        end
    
    end
    
end

function ObstacleMixin:RemoveFromMesh()

    if self.obstacleId ~= -1 then    
    
        Pathing.RemoveObstacle(self.obstacleId)
        self.obstacleId = -1
        gAllObstacles[self] = nil
        
        if self.GetResetsPathing and self:GetResetsPathing() then
            InformEntitiesInRange(self, 25)
        end
        
    end
end

function ObstacleMixin:GetObstacleId()
    return self.obstacleId
end

function ObstacleMixin:_GetPathingInfo()

    local position = self:GetOrigin() + Vector(0, -100, 0)  
    local radius = LookupTechData(self:GetTechId(), kTechDataObstacleRadius, 1.0)
    local height = 1000.0
    
    return position, radius, height
  
end

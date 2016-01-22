// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ResourcePoint_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function ResourcePoint:Reset()
    
    self:OnInitialized()
    
    self:ClearAttached()
    
end
function ResourcePoint:AutoDrop()
    if self:GetAttached() == nil then
      
          local powerpoint = GetPowerPointForLocation(self:GetLocationName())
          if powerpoint ~= nil then 
           if powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled()then 
              self:SpawnResourceTowerForTeamModified(1, kTechId.Extractor)
           elseif powerpoint:GetIsDisabled() then                                                  --avg
              local infestation = GetEntitiesWithMixinWithinRange("Infestation", self:GetOrigin(), 7) 
              if #infestation >= 1 then
               self:SpawnResourceTowerForTeamModified(2, kTechId.Harvester)
               end
              end//
           end//
           
             //if respoint:GetGameEffectMask(kGameEffect.OnInfestation) and marine == false then
             // respoint:SpawnResourceTowerForTeamModified(2, kTechId.Harvester)
            //end   
     
       end//
end
function ResourcePoint:OnAttached(entity)
    self.occupiedTeam = entity:GetTeamNumber()
    entity:SetCoords(self:GetCoords())
end

function ResourcePoint:OnDetached()
    self.showObjective = false
    self.occupiedTeam = 0
end

// Create a new resource tower on this nozzle, returning false if already occupied or not enough room
function ResourcePoint:SpawnResourceTowerForTeam(team, techId)

    if self:GetAttached() == nil then
    
        // Force create because entity may not be cleaned up from round reset
        local tower = CreateEntityForTeam(techId, self:GetOrigin(), team:GetTeamNumber(), nil)
        
        if tower then
        
            tower:SetConstructionComplete()           
            
            self:SetAttached(tower)
            
            return tower
            
        end
       
    else
        Print("ResourcePoint:SpawnResourceTowerForTeam(%s): Entity %s already attached.", EnumToString(kTechId, techId), self:GetAttached():GetClassName()) 
    end
    
    return nil
    
end
// Create a new resource tower on this nozzle, returning false if already occupied or not enough room
function ResourcePoint:SpawnResourceTowerForTeamModified(teamnumber, techId)

    if self:GetAttached() == nil then
    
        // Force create because entity may not be cleaned up from round reset
        local tower = CreateEntityForTeam(techId, self:GetOrigin(), teamnumber, nil)
        
        if tower then
        
          //  tower:SetConstructionComplete()           
            
            self:SetAttached(tower)
            
            return tower
            
        end
       
    else
        Print("ResourcePoint:SpawnResourceTowerForTeam(%s): Entity %s already attached.", EnumToString(kTechId, techId), self:GetAttached():GetClassName()) 
    end
    
    return nil
    
end

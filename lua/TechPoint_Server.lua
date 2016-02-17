// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechPoint_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function TechPoint:GetCanTakeDamageOverride()
    return false
end

function TechPoint:GetCanDieOverride()
    return false
end

function TechPoint:OnAttached(entity)
    self.occupiedTeam = entity:GetTeamNumber()
end

function TechPoint:OnDetached()
    self.showObjective = false
    self.occupiedTeam = 0
end

function TechPoint:Reset()
    
    self:OnInitialized()
    
    self:ClearAttached()
    
end

function TechPoint:SetAttached(structure)

    if structure and structure:isa("CommandStation") then
        self.smashed = false
        self.smashScouted = false
    end
    ScriptActor.SetAttached(self, structure)
    
end 

// Spawn command station or hive on tech point
function TechPoint:SpawnCommandStructure(teamNumber)
    if teamNumber == 1 then self:SetIsVisible(false) end
    local alienTeam = (GetGamerules():GetTeam(teamNumber):GetTeamType() == kAlienTeamType)
    local techId = ConditionalValue(alienTeam, kTechId.Hive, kTechId.CommandStation)
    if teamNumber == 1 then self:DeleteExtraTechPoints() end
    return CreateEntityForTeam(techId, Vector(self:GetOrigin()), teamNumber)
    
end
function TechPoint:SpawnOtherHives() --Okay matey you've got it 3 hives comin up
   for index, techpoint in ipairs( GetEntitiesWithinRange( "TechPoint", self:GetOrigin(), 18) ) do
     if techpoint:GetAttached() == nil then techpoint:SpawnCommandStructure(2) end
      end
end
function TechPoint:DeleteExtraTechPoints()
  if Shared.GetMapName() == "ns2_sorrow_siege" or Shared.GetMapName() == "ns2_lobstersiege" or Shared.GetMapName() == "ns2_sorrow_siege" or Shared.GetMapName() == "ns_digsiege_2007" then return end
for index, techpoint in ipairs( GetEntitiesWithinRange( "TechPoint", self:GetOrigin(), 12) ) do
     if techpoint ~= self then DestroyEntity(techpoint) end
end

end
function TechPoint:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    
    if self.smashed and not self.smashScouted then
        local attached = self:GetAttached()
        if attached and attached:GetIsSighted() then
            self.smashScouted = true
        end
    end    
    
end    

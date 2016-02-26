// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/SensorBlip.lua
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/MinimapMappableMixin.lua")

class 'SensorBlip' (Entity)

SensorBlip.kMapName = "sensorblip"

local networkVars =
{
    entId       = "entityid"
}

function SensorBlip:OnCreate()

    Entity.OnCreate(self)
    
    self.entId    = Entity.invalidId
    
    self:UpdateRelevancy()
    
    if Client then
        InitMixin(self, MinimapMappableMixin)
    end
    
end

function SensorBlip:UpdateRelevancy()

    self:SetRelevancyDistance(Math.infinity)
    self:SetExcludeRelevancyMask(kRelevantToTeam1)
    
end

function SensorBlip:Update(entity)

    if entity.GetEngagementPoint then
        self:SetOrigin(entity:GetEngagementPoint())
    else
        self:SetOrigin(entity:GetModelOrigin())
    end
    
    self.entId = entity:GetId()
    
end


if Client then
  
    function SensorBlip:GetMapBlipType()
        return kMinimapBlipType.SensorBlip
    end
    
    function SensorBlip:GetMapBlipColor(minimap, item)
        return item.blipColor
    end
    
    function SensorBlip:GetMapBlipTeam(minimap)
        return kMinimapBlipTeam.Enemy
    end
    
    function SensorBlip:UpdateMinimapActivity(minimap, item)      
        local origin = self:GetOrigin()
        local isMoving = item.prevOrigin ~= origin
        item.prevOrigin = origin
        return (isMoving and kMinimapActivity.Medium) or kMinimapActivity.Static
    end

end -- Client


Shared.LinkClassToMap("SensorBlip", SensorBlip.kMapName, networkVars)
// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TeleportTrigger.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// Teleport entity to destination.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'TeleportTrigger' (Trigger)

TeleportTrigger.kMapName = "teleport_trigger"

local networkVars =
{
}

local function GetTeleportDestinationCoords(self)

    local destinationEntities = {}

    for _, entity in ientitylist(Shared.GetEntitiesWithClassname("TeleportDestination")) do
    
        if entity.teleportDestinationId == self.teleportDestinationId then     
            table.insert(destinationEntities, entity)  
        end
    
    end
    
    if #destinationEntities > 0 then
        return destinationEntities[math.random(1, #destinationEntities)]:GetCoords()
    end

end

function TeleportTrigger:OnCreate()

    Trigger.OnCreate(self)
    
    self:SetPropagate(Entity.Propagate_Never)

end

function TeleportTrigger:OnInitialized()

    Trigger.OnInitialized(self)    
    self:SetTriggerCollisionEnabled(true)
    
end

function TeleportTrigger:GetIsMapEntity()
    return true
end 

local kTeleportClassNames =
{
    "ReadyRoomPlayer",
    "Embryo",
    "Skulk",
    "Gorge",
    "Lerk",
    "Fade",
    "Onos",
    "Marine",
    "JetpackMarine",
    "Exo"
}

function TeleportTrigger:OnTriggerEntered(enterEnt, triggerEnt)

    local className = enterEnt:GetClassName()

    if table.contains(kTeleportClassNames, className) then

        local destinationCoords = GetTeleportDestinationCoords(self)

        if destinationCoords then
        
            local oldCoords = enterEnt:GetCoords()
        
            enterEnt:SetCoords(destinationCoords)
            
            if enterEnt:isa("Player") then
            
                local newAngles = Angles(0, 0, 0)            
                newAngles.yaw = GetYawFromVector(destinationCoords.zAxis)
                enterEnt:SetOffsetAngles(newAngles)
            
            end
            
            GetEffectManager():TriggerEffects("teleport_trigger", { effecthostcoords = oldCoords }, self)
            GetEffectManager():TriggerEffects("teleport_trigger", { effecthostcoords = destinationCoords }, self)
            
            enterEnt.timeOfLastPhase = Shared.GetTime()
        
        end
    
    end
    
end

Shared.LinkClassToMap("TeleportTrigger", TeleportTrigger.kMapName, networkVars)
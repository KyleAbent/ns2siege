// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TeleportDestination.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'TeleportDestination' (Entity)

TeleportDestination.kMapName = "teleport_destination"

local networkVars =
{
}

function TeleportDestination:OnCreate()

    Entity.OnCreate(self)
    
    self:SetPropagate(Entity.Propagate_Never)

end

function TeleportDestination:GetIsMapEntity()
    return true
end    

Shared.LinkClassToMap("TeleportDestination", TeleportDestination.kMapName, networkVars)
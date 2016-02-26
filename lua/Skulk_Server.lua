// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Skulk_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function Skulk:InitWeapons()

    Alien.InitWeapons(self)
    
    self:GiveItem(BiteLeap.kMapName)
    self:GiveItem(Parasite.kMapName)
    
    self:SetActiveWeapon(BiteLeap.kMapName)    
    
end

function Skulk:InitWeaponsForReadyRoom()
    
    Alien.InitWeaponsForReadyRoom(self)
    
    self:GiveItem(ReadyRoomLeap.kMapName)
    self:SetActiveWeapon(ReadyRoomLeap.kMapName)
    
end

function Skulk:GetTierTwoTechId()
    return kTechId.Leap
end

function Skulk:GetTierThreeTechId()
    return kTechId.Xenocide
end
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Onos_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com) and
//                  Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function Onos:InitWeapons()

    Alien.InitWeapons(self)

    self:GiveItem(Gore.kMapName)
    self:SetActiveWeapon(Gore.kMapName)
    
end

function Onos:GetTierOneTechId()
    return kTechId.Charge
end

function Onos:GetTierTwoTechId()
    return kTechId.BoneShield
end

function Onos:GetTierThreeTechId()
    return kTechId.Stomp
end

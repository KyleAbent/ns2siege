// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Lerk_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function Lerk:InitWeapons()

    Alien.InitWeapons(self)

    self:GiveItem(LerkBite.kMapName)    
    self:SetActiveWeapon(LerkBite.kMapName)
    
end
function Lerk:GetTierOneTechId()
    return kTechId.Umbra
end
function Lerk:GetTierTwoTechId()
    return kTechId.Spores
end
function Lerk:GetTierThreeTechId()
    return kTechId.PrimalScream
end
function Lerk:GetPlayIdleSound()
    
    local time = Shared.GetTime()
    
    -- Don't turn off idle sound until after first "grunt" is complete
    if self.playIdleSound and time < self.playIdleStartTime + self.kIdleSoundMinPlayLength then
        return true
    end
    
    -- Don't start again until after some silence
    if not self.playIdleSound and time < self.playIdleStartTime + self.kIdleSoundMinSilenceLength then
        return false
    end
    
    local shouldPlay
    if self:GetIsOnGround() then
        shouldPlay = Player.GetPlayIdleSound( self )
    else
        shouldPlay = self:GetIsAlive() and self:GetVelocityLength() > self.kIdleSoundMinSpeed
    end
    
    if not self.playIdleSound and shouldPlay then
        self.playIdleStartTime = time
    end
    
    return shouldPlay
end


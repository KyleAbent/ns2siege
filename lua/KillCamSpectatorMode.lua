// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\FollowingSpectatorMode.lua
//
// Created by: Marc Delorme (marc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/SpectatorMode.lua")

class 'KillCamSpectatorMode' (SpectatorMode)

KillCamSpectatorMode.name = "KillCam"

-- seconds to move back in time. The replay starts 2 seconds after the death, so 4 seconds worth of replay
KillCamSpectatorMode.kInterpOffset = 6
-- ... and let us enjoy the scene of the death for one extra second
KillCamSpectatorMode.kDuration = 1 + KillCamSpectatorMode.kInterpOffset 

function KillCamSpectatorMode:Initialize(spectator)
    
    if Server then

        local angles = Angles(spectator:GetViewAngles())
        
        // Start with a null velocity
        spectator:SetVelocity(Vector(0, 0, 0))
        
        spectator:SetBaseViewAngles(Angles(0, 0, 0))
        spectator:SetViewAngles(angles)
        

    end
    
    if Client then
        Client.SetLocalInterpDelta(KillCamSpectatorMode.kInterpOffset)
    end
    
end

function KillCamSpectatorMode:Uninitialize(spectator)
    
    if Client then
        Client.SetLocalInterpDelta(0)
    end

end

function KillCamSpectatorMode:OnProcessMove(spectator, input)
    local timeSinceKill = Shared.GetTime() - spectator:GetKillCamBaseTime()
    local victim = spectator:GetKillCamVictim()
    local killer = spectator:GetKillCamKiller()  
    
    if not killer or not victim or timeSinceKill > KillCamSpectatorMode.kDuration then
        
        spectator:SetSpectatorMode(kSpectatorMode.FirstPerson)
    
    else

        if victim then
            spectator.killCamVictimOrigin = GetTargetOrigin(victim)
        end
            
        if killer then
            local killerOrigin = killer:GetEyePos() 
            local vec = GetNormalizedVector(spectator.killCamVictimOrigin - killerOrigin - killer:GetViewOffset())
            spectator:SetOrigin(killerOrigin)
            SetViewAnglesFromVector(spectator, vec)
        end
        
    end
    
end

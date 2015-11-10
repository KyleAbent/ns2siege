// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ReadyRoomTeam.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// This class is used for the team that is for players that are in the ready room.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Team.lua")
Script.Load("lua/TeamDeathMessageMixin.lua")

class 'ReadyRoomTeam' (Team)

function ReadyRoomTeam:Initialize(teamName, teamNumber)

    InitMixin(self, TeamDeathMessageMixin)
    
    Team.Initialize(self, teamName, teamNumber)
    
end

function ReadyRoomTeam:GetRespawnMapName(player)

    local mapName = player.kMapName    
    
    if mapName == nil then
        mapName = ReadyRoomPlayer.kMapName
    end
    
    // Use previous life form if dead or in commander chair
    if (mapName == MarineCommander.kMapName) 
       or (mapName == AlienCommander.kMapName) 
       or (mapName == Spectator.kMapName) 
       or (mapName == AlienSpectator.kMapName) 
       or (mapName ==  MarineSpectator.kMapName) then 
    
        mapName = player:GetPreviousMapName()
        
    end
    
    if mapName == Embryo.kMapName then
        mapName = ReadyRoomEmbryo.kMapName
    elseif mapName == Exo.kMapName then
        mapName = ReadyRoomExo.kMapName
    end
            
    return mapName
    
end

/**
 * Transform player to appropriate team respawn class and respawn them at an appropriate spot for the team.
 */
 //Siege - Replace everyone with RR player - im tired of all the RR errors and this is a simple fix 
function ReadyRoomTeam:ReplaceRespawnPlayer(player, origin, angles)
       local mapName = ReadyRoomPlayer.kMapName
    local newPlayer = player:Replace(mapName, self:GetTeamNumber(), false, origin)
    self:RespawnPlayer(newPlayer, origin, angles)
    newPlayer:ClearGameEffects()
    newPlayer:SetCameraDistance(3)
    return (newPlayer ~= nil), newPlayer
end

function ReadyRoomTeam:GetSupportsOrders()
    return false
end

function ReadyRoomTeam:TriggerAlert(techId, entity)
    return false
end
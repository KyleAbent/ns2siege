// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AlienSpectator.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Alien spectators can choose their upgrades and lifeform while dead.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TeamSpectator.lua")

if Client then
    Script.Load("lua/TeamMessageMixin.lua")
end

class 'AlienSpectator' (TeamSpectator)

AlienSpectator.kMapName = "alienspectator"

local networkVars =
{
    eggId = "private entityid",
    queuePosition = "private integer (-1 to 100)",
    autoSpawnTime = "private float"
}

local function UpdateQueuePosition(self)

    if self:GetIsDestroyed() then
        return false
    end
    
    self.queuePosition = self:GetTeam():GetPlayerPositionInRespawnQueue(self)
    return true
    
end

local function UpdateWaveTime(self)

    if self:GetIsDestroyed() then
        return false
    end
    
    if self.queuePosition <= self:GetTeam():GetEggCount() then
        local entryTime = self:GetRespawnQueueEntryTime() or 0
        self.timeWaveSpawnEnd = entryTime + kAlienSpawnTime
    else
        self.timeWaveSpawnEnd = 0
    end
    
    Server.SendNetworkMessage(Server.GetOwner(self), "SetTimeWaveSpawnEnds", { time = self.timeWaveSpawnEnd }, true)
    
    if not self.sentRespawnMessage then
    
        Server.SendNetworkMessage(Server.GetOwner(self), "SetIsRespawning", { isRespawning = true }, true)
        self.sentRespawnMessage = true
        
    end
    
    return true
    
end

function AlienSpectator:OnCreate()

    TeamSpectator.OnCreate(self)

    if Client then
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIAlienTeamMessage" })
    end
    
    self.timeWaveSpawnEnd = 0    
    self.movedToEgg = false
    
    self.eggId = Entity.invalidId
    self.queuePosition = 0
    self.autoSpawnTime = 0

    self:SetTeamNumber(2)
    
end

function AlienSpectator:OnInitialized()

    TeamSpectator.OnInitialized(self)

    if Server then
    
        self.evolveTechIds = { kTechId.Skulk }
        self:AddTimedCallback(UpdateQueuePosition, 0.1)
        self:AddTimedCallback(UpdateWaveTime, 0.1)
        UpdateQueuePosition(self)
        
    end
    
end

if Server then

    function AlienSpectator:GetDesiredSpawnPoint()
        return self.desiredSpawnPoint
    end    

    function AlienSpectator:Replace(mapName, newTeamNumber, preserveWeapons, atOrigin, extraValues)
    
        Server.SendNetworkMessage(Server.GetOwner(self), "SetIsRespawning", { isRespawning = false }, true)    
        return TeamSpectator.Replace(self, mapName, newTeamNumber, preserveWeapons, atOrigin, extraValues)
    
    end

    function AlienSpectator:GetWaveSpawnEndTime()
        return self.timeWaveSpawnEnd
    end
    
end
function AlienSpectator:GetIsValidToSpawn()
    return true
end

// Returns egg we're currently spawning in or nil if none
function AlienSpectator:GetHostEgg()

    if self.eggId ~= Entity.invalidId then
        return Shared.GetEntity(self.eggId)
    end
    
    return nil
    
end

function AlienSpectator:SetEggId(id)

    self.eggId = id
    
    if self.eggId == Entity.invalidId then
        self.autoSpawnTime = 0
    else
        self.autoSpawnTime = Shared.GetTime() + 1
    end
    
end

function AlienSpectator:GetEggId()
    return self.eggId
end

function AlienSpectator:GetQueuePosition()
    return self.queuePosition
end

function AlienSpectator:GetAutoSpawnTime()
    return self.autoSpawnTime - Shared.GetTime()
end

function AlienSpectator:OnProcessMove(input)

    TeamSpectator.OnProcessMove(self, input)
    
    if Server then
    
        if self.autoSpawnTime > 0 and Shared.GetTime() >= self.autoSpawnTime then
            self:SpawnPlayerOnAttack()
        end
        
        if not self.waitingToSpawnMessageSent then
        
            SendPlayersMessage({ self }, kTeamMessageTypes.SpawningWait)
            self.waitingToSpawnMessageSent = true
            
        end
        
    end
    
end

function AlienSpectator:SpawnPlayerOnAttack()

    local egg = self:GetHostEgg()
    
    if egg ~= nil then
        return egg:SpawnPlayer()
    elseif Shared.GetCheatsEnabled() then
        return self:GetTeam():ReplaceRespawnPlayer(self)
    end
    
    self:TriggerInvalidSound()
    
    return false, nil
    
end

// Same as Skulk so his view height is right when spawning in
function AlienSpectator:GetMaxViewOffsetHeight()
    return Skulk.kViewOffsetHeight
end

/**
 * Prevent the camera from penetrating into the world when waiting to spawn at an Egg.
 */
function AlienSpectator:GetPreventCameraPenetration()

    local followTarget = Shared.GetEntity(self:GetFollowTargetId())
    return followTarget and followTarget:isa("Egg")
    
end

if Server then
    
    function AlienSpectator:CopyPlayerDataFrom(player)

        Player.CopyPlayerDataFrom(self, player)
        
        // copy for ready room, give the tech if they deserve it
        Alien.CopyPlayerDataForReadyRoomFrom( self, player )
        
    end
    
end
    
Shared.LinkClassToMap("AlienSpectator", AlienSpectator.kMapName, networkVars)
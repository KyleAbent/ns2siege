// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========    
//    
// lua\SpawnBlocker.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/TeamMixin.lua")

class 'SpawnBlocker' (Entity)

SpawnBlocker.kMapName = "spawnblocker"

local kDefaultBlockDuration = 5

local kBlockerCinematics =
{
    [kMarineTeamType] = PrecacheAsset("cinematics/marine/blocker.cinematic"),
    [kAlienTeamType] = PrecacheAsset("cinematics/alien/blocker.cinematic")
}

local networkVars =
{
}

AddMixinNetworkVars(TeamMixin, networkVars)

function SpawnBlocker:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    
    self:SetUpdates(true)
    self.endTime = kDefaultBlockDuration + Shared.GetTime()
    
end

function SpawnBlocker:OnDestroy()

    if self.blockerCinematic then
        Client.DestroyCinematic(self.blockerCinematic)
        self.blockerCinematic = nil
    end

end

function SpawnBlocker:SetDuration(duration)
    self.endTime = duration + Shared.GetTime()
end

if Server then

    function SpawnBlocker:OnUpdate(deltaTime)
    
        if self.endTime and self.endTime <= Shared.GetTime() then
            DestroyEntity(self)
        end
    
    end

end

function SpawnBlocker:OnUpdateRender()

    local player = Client.GetLocalPlayer()
    local showBlocker = player ~= nil and player:isa("Commander") and player.currentTechId ~= kTechId.None and LookupTechData(player.currentTechId, kTechDataSpawnBlock, false)

    if showBlocker and not self.blockerCinematic then
    
        self.blockerCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.blockerCinematic:SetCinematic(kBlockerCinematics[player:GetTeamType()])
        self.blockerCinematic:SetCoords(Coords.GetTranslation(self:GetOrigin()))
        self.blockerCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    
    elseif not showBlocker and self.blockerCinematic then
    
        Client.DestroyCinematic(self.blockerCinematic)
        self.blockerCinematic = nil
        
    end

end

Shared.LinkClassToMap("SpawnBlocker", SpawnBlocker.kMapName, networkVars)
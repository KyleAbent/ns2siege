// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\InfantryPortal.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) 
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/PowerConsumerMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ParasiteMixin.lua")

class 'InfantryPortal' (ScriptActor)

local kSpinEffect = PrecacheAsset("cinematics/marine/infantryportal/spin.cinematic")
local kAnimationGraph = PrecacheAsset("models/marine/infantry_portal/infantry_portal.animation_graph")
local kHoloMarineModel = PrecacheAsset("models/marine/male/male_spawn.model")

local kHoloMarineMaterialname = PrecacheAsset("cinematics/vfx_materials/marine_ip_spawn.material")

if Client then
    PrecacheAsset("cinematics/vfx_materials/marine_ip_spawn.surface_shader")
end

InfantryPortal.kMapName = "infantryportal"

InfantryPortal.kModelName = PrecacheAsset("models/marine/infantry_portal/infantry_portal.model")

InfantryPortal.kAnimSpinStart = "spin_start"
InfantryPortal.kAnimSpinContinuous = "spin"

InfantryPortal.kUnderAttackSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/base_under_attack")
InfantryPortal.kIdleLightEffect = PrecacheAsset("cinematics/marine/infantryportal/idle_light.cinematic")

InfantryPortal.kTransponderUseTime = .5
local kUpdateRate = 0.25
InfantryPortal.kTransponderPointValue = 15
InfantryPortal.kLoginAttachPoint = "keypad"

local kPushRange = 3
local kPushImpulseStrength = 40

local kInfantryPortalGainXP = .1
local kInfantryPortalMaxLevel = 10
InfantryPortal.GainXp = .025

local networkVars =
{
    queuedPlayerId = "entityid",
    level = "float (0 to " .. kInfantryPortalMaxLevel  .. " by .1)",
    creditstructre = "boolean",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(PowerConsumerMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

local function CreateSpinEffect(self)

    if not self.spinCinematic then
    
        self.spinCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.spinCinematic:SetCinematic(kSpinEffect)
        self.spinCinematic:SetCoords(self:GetCoords())
        self.spinCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    
    end
    
    if not self.fakeMarineModel and not self.fakeMarineMaterial then
    
        self.fakeMarineModel = Client.CreateRenderModel(RenderScene.Zone_Default)
        self.fakeMarineModel:SetModel(Shared.GetModelIndex(kHoloMarineModel))
        
        local coords = self:GetCoords()
        coords.origin = coords.origin + Vector(0, 0.4, 0)
        
        self.fakeMarineModel:SetCoords(coords)
        self.fakeMarineModel:InstanceMaterials()
        self.fakeMarineModel:SetMaterialParameter("hiddenAmount", 1.0)
        
        self.fakeMarineMaterial = AddMaterial(self.fakeMarineModel, kHoloMarineMaterialname)
    
    end
    
    if self.clientQueuedPlayerId ~= self.queuedPlayerId then
        self.timeSpinStarted = Shared.GetTime()
        self.clientQueuedPlayerId = self.queuedPlayerId
    end
    
    local spawnProgress = Clamp((Shared.GetTime() - self.timeSpinStarted) / self:GetSpawnTime(), 0, 1)
    
    self.fakeMarineModel:SetIsVisible(true)
    self.fakeMarineMaterial:SetParameter("spawnProgress", spawnProgress+0.2)    // Add a little so it always fills up

end

local function DestroySpinEffect(self)

    if self.spinCinematic then
    
        Client.DestroyCinematic(self.spinCinematic)    
        self.spinCinematic = nil
    
    end
    
    if self.fakeMarineModel then    
        self.fakeMarineModel:SetIsVisible(false)
    end

end

function InfantryPortal:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    if Server then
        self.timeLastPush = 0
    end
    
    self.queuedPlayerId = Entity.invalidId
    
    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    self.level = 0
    self.creditstructre = false
end

local function StopSpinning(self)

    self:TriggerEffects("infantry_portal_stop_spin")
    self.timeSpinUpStarted = nil
    
end

local function PushPlayers(self)

    for _, player in ipairs(GetEntitiesWithinRange("Player", self:GetOrigin(), 0.5)) do

        if player:GetIsAlive() and HasMixin(player, "Controller") then

            player:DisableGroundMove(0.1)
            player:SetVelocity(Vector(GetSign(math.random() - 0.5) * 2, 3, GetSign(math.random() - 0.5) * 2))

        end
        
    end

end

local function InfantryPortalUpdate(self)

    self:FillQueueIfFree()
    
    if GetIsUnitActive(self) and self:GetTeam():GetHasAbilityToRespawn() then
        
        local remainingSpawnTime = self:GetSpawnTime()
        if self.queuedPlayerId ~= Entity.invalidId then
        
            local queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
            if queuedPlayer then
            
                remainingSpawnTime = math.max(0, self.queuedPlayerStartTime + self:GetSpawnTime() - Shared.GetTime())
            
                if remainingSpawnTime < 0.3 and self.timeLastPush + 0.5 < Shared.GetTime() then
                
                    PushPlayers(self)
                    self.timeLastPush = Shared.GetTime()
                    
                end
                
            else
            
                self.queuedPlayerId = nil
                self.queuedPlayerStartTime = nil
                
            end

        end
    
        if remainingSpawnTime == 0 then
            self:FinishSpawn()
        end
        
        // Stop spinning if player left server, switched teams, etc.
        if self.timeSpinUpStarted and self.queuedPlayerId == Entity.invalidId then
            StopSpinning(self)
        end
        
    end
    
    return true
    
end

function InfantryPortal:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(InfantryPortal.kModelName, kAnimationGraph)
    
    if Server then
    
        self:AddTimedCallback(InfantryPortalUpdate, kUpdateRate)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        
    elseif Client then
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
    end
    
    InitMixin(self, IdleMixin)
    
end
/*
function InfantryPortal:GetLevelPercentage()
return self.level / kInfantryPortalMaxLevel * kSentryScaleSize
end

function InfantryPortal:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end
*/
function InfantryPortal:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, kInfantryPortalMaxLevel - self.level)
        self.level = self.level + xpReward
   
    return xpReward
    
end
function InfantryPortal:GetMaxLevel()
return kInfantryPortalMaxLevel
end
function InfantryPortal:GetLevel()
        return Round(self.level, 2)
end
  function InfantryPortal:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Level %s Infantry Portal"), self:GetLevel())
return unitName
end  
function InfantryPortal:GetAddXPAmount()
return InfantryPortal.GainXp
end
function InfantryPortal:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    // Put the player back in queue if there was one hoping to spawn at this now destroyed IP.
    if Server then
        self:RequeuePlayer()
    elseif Client then
    
        DestroySpinEffect(self)
        
        if self.fakeMarineModel then
        
            Client.DestroyRenderModel(self.fakeMarineModel)
            self.fakeMarineModel = nil
            self.fakeMarineMaterial = nil
            
        end
        
    end
    
end

function InfantryPortal:GetNanoShieldOffset()
    return Vector(0, -0.1, 0)
end

function InfantryPortal:GetRequiresPower()
    return true
end

local function QueueWaitingPlayer(self)

    if self:GetIsAlive() and self.queuedPlayerId == Entity.invalidId then

        // Remove player from team spawn queue and add here
        local team = self:GetTeam()
        local playerToSpawn = team:GetOldestQueuedPlayer()

        if playerToSpawn ~= nil then
            
            playerToSpawn:SetIsRespawning(true)
            team:RemovePlayerFromRespawnQueue(playerToSpawn)
            
            self.queuedPlayerId = playerToSpawn:GetId()
            self.queuedPlayerStartTime = Shared.GetTime()

            self:StartSpinning()            
            
            SendPlayersMessage({ playerToSpawn }, kTeamMessageTypes.Spawning)
            
            if Server then
                
                if playerToSpawn.SetSpectatorMode then
                    playerToSpawn:SetSpectatorMode(kSpectatorMode.Following)
                end
                
                playerToSpawn:SetFollowTarget(self)

            end
            
        end
        
    end

end

function InfantryPortal:GetReceivesStructuralDamage()
    return true
end
function InfantryPortal:GetSpawnTime()
local fair = kMarineRespawnTime
 // Print("fair is %s", fair)
//if Server then
// fair = GetFairRespawnLength()
//   Print("fair is %s", fair)
//end
    local length = ( fair - (self.level/100) * fair)
      // Print("respawn length is %s", length)
    return math.round(length, 2)
end
function InfantryPortal:OnReplace(newStructure)
    newStructure.queuedPlayerId = self.queuedPlayerId
end
function InfantryPortal:CheckSpaceAboveForSpawn()

    local startPoint = self:GetOrigin() 
    local endPoint = startPoint + Vector(0.35, 0.95, 0.35)
    
    return GetWallBetween(startPoint, endPoint, self)
    
end
              function InfantryPortal:FindFreeSpace()    
        for index = 1, 100 do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), .5, 24, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == self:GetLocationName()
        
           if spawnPoint ~= nil and sameLocation then//and GetIsPointOnInfestation(spawnPoint) then
           return spawnPoint
           end
       end
           Print("No valid spot found for phase cannon!")
           return self:GetOrigin()
    end
// Spawn player on top of IP. Returns true if it was able to, false if way was blocked.
local function SpawnPlayer(self)

    if self.queuedPlayerId ~= Entity.invalidId then
    
        local queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
        local team = queuedPlayer:GetTeam()
        
        // Spawn player on top of IP
        local spawnOrigin = self:GetAttachPointOrigin("spawn_point")
        spawnOrigin = ConditionalValue(self:CheckSpaceAboveForSpawn(), self:FindFreeSpace(), spawnOrigin)
        local success, player = team:ReplaceRespawnPlayer(queuedPlayer, spawnOrigin, queuedPlayer:GetAngles())
        if success then

            player:SetCameraDistance(0)
            
            if HasMixin( player, "Controller" ) and HasMixin( player, "AFKMixin" ) then
                
                if player:GetAFKTime() > self:GetSpawnTime() - 1 then
                    
                    player:DisableGroundMove(0.1)
                    player:SetVelocity( Vector( GetSign( math.random() - 0.5) * 2.25, 3, GetSign( math.random() - 0.5 ) * 2.25 ) )
                    
                end
                
            end
            
            self.queuedPlayerId = Entity.invalidId
            self.queuedPlayerStartTime = nil
            
            player:ProcessRallyOrder(self)

            self:TriggerEffects("infantry_portal_spawn")            
            
            return true
            
        else
            Print("Warning: Infantry Portal failed to spawn the player")
        end
        
    end
    
    return false

end
if Server then
   function InfantryPortal:GetIsFront()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetFrontDoorsOpen() then 
                   return true
               end
            end
        end
            return false
end
function InfantryPortal:GetCanBeUsedConstructed(byPlayer)
  return not self:GetIsFront() and not byPlayer:GetHasLayStructure() and byPlayer:GetHasWelderPrimary()
end
function InfantryPortal:OnUseDuringSetup(player, elapsedTime, useSuccessTable)

    // Play flavor sounds when using MAC.
    if Server then
    
        local time = Shared.GetTime()
        
       // if self.timeOfLastUse == nil or (time > (self.timeOfLastUse + 4)) then
        
           local laystructure = player:GiveItem(LayStructures.kMapName)
           laystructure:SetTechId(kTechId.InfantryPortal)
           laystructure:SetMapName(InfantryPortal.kMapName)
           laystructure.originalposition = self:GetOrigin()
           DestroyEntity(self)
           // self.timeOfLastUse = time
            
      //  end
       //self:PlayerUse(player) 
    end
    
end
end
function InfantryPortal:GetIsWallWalkingAllowed()
    return false
end 

// Takes the queued player from this IP and placed them back in the
// respawn queue to be spawned elsewhere.
function InfantryPortal:RequeuePlayer()

    if self.queuedPlayerId ~= Entity.invalidId then
    
        local player = Shared.GetEntity(self.queuedPlayerId)
        local team = self:GetTeam()
        if team then
            team:PutPlayerInRespawnQueue(Shared.GetEntity(self.queuedPlayerId))
        end
        player:SetIsRespawning(false)
        player:SetSpectatorMode(kSpectatorMode.Following)
        
    end
    
    // Don't spawn player.
    self.queuedPlayerId = Entity.invalidId
    self.queuedPlayerStartTime = nil

end

if Server then

    function InfantryPortal:OnEntityChange(entityId, newEntityId)
    
        if self.queuedPlayerId == entityId then
        
            // Player left or was replaced, either way 
            // they're not in the queue anymore
            self.queuedPlayerId = Entity.invalidId
            self.queuedPlayerStartTime = nil
            
        end
        
    end
    
    function InfantryPortal:OnKill(attacker, doer, point, direction)
    
        ScriptActor.OnKill(self, attacker, doer, point, direction)
        
        StopSpinning(self)
        
        // Put the player back in queue if there was one hoping to spawn at this now dead IP.
        self:RequeuePlayer()
        
    end
    
end

if Server then

    function InfantryPortal:FillQueueIfFree()
    
        if GetIsUnitActive(self) and self:GetTeam():GetHasAbilityToRespawn() then
        
            if self.queuedPlayerId == Entity.invalidId then
                QueueWaitingPlayer(self)
            end
            
        end
        
    end
    
    function InfantryPortal:FinishSpawn()
    
        SpawnPlayer(self)
        StopSpinning(self)
        self.timeSpinUpStarted = nil
        self:AddXP(kInfantryPortalGainXP)  
    end
    
end

function InfantryPortal:StartSpinning()

    if self.timeSpinUpStarted == nil then
    
        self:TriggerEffects("infantry_portal_start_spin")
        self.timeSpinUpStarted = Shared.GetTime()
        
    end
    
end

function InfantryPortal:OnPowerOn()

    if self.queuedPlayerId ~= Entity.invalidId then
    
        local queuedPlayer = Shared.GetEntity(self.queuedPlayerId)        
        if queuedPlayer then
        
            queuedPlayer:SetRespawnQueueEntryTime(Shared.GetTime())            
            self:StartSpinning()
            
        end
        
    end
    
end

function InfantryPortal:OnPowerOff()

    // Put the player back in queue if there was one hoping to spawn at this IP.
    StopSpinning(self)
    self:RequeuePlayer()
    
end

function InfantryPortal:GetDamagedAlertId()
    return kTechId.MarineAlertInfantryPortalUnderAttack
end

function InfantryPortal:OnUpdateAnimationInput(modelMixin)

    PROFILE("InfantryPortal:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("spawning", self.queuedPlayerId ~= Entity.invalidId)
    modelMixin:SetAnimationInput("powered", true)
    
end

function InfantryPortal:OnOverrideOrder(order)

    // Convert default to set rally point.
    if order:GetType() == kTechId.Default then
        order:SetType(kTechId.SetRally)
    end
    
end
function InfantryPortal:GetIPS()
    
return ips 
end
function GetInfantryPortalGhostGuides(commander)

    local commandStations = GetEntitiesForTeam("CommandStation", commander:GetTeamNumber())
    local attachRange = LookupTechData(kTechId.InfantryPortal, kStructureAttachRange, 1)
    local result = { }
    
    for _, commandStation in ipairs(commandStations) do
        if commandStation:GetIsBuilt() then
            result[commandStation] = attachRange
        end
    end
    
    return result

end
local kTraceOffset = 0.1
function GetCommandStationIsBuilt(techId, origin, normal, commander)

    // check if there is a built command station in our team
    if not commander then
        return false
    end
    local ips = 0
        for index, ip in ientitylist(Shared.GetEntitiesWithClassname("InfantryPortal")) do
        
            if not ip.creditstructre then
                ips = ips + 1
            end
        end  
        
    if ips >= 6 then return false end
    
    local spaceFree = GetHasRoomForCapsule(Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents), origin + Vector(0, 0.1 + Player.kYExtents, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls)
    
    if spaceFree then
    
        local cs = GetEntitiesForTeamWithinRange("CommandStation", commander:GetTeamNumber(), origin, 15)
        if cs and #cs > 0 then
            return cs[1]:GetIsBuilt()
        end
    
    end
    
    return false

end
if Server then
    function InfantryPortal:OnUpdate(deltaTime)
         local max = kInfantryPortalHealth * (self.level/100) + kInfantryPortalHealth
        if self:GetMaxHealth() ~= max then
         self:AdjustMaxHealth( max ) 
        self:AdjustMaxArmor(kInfantryPortalArmor * (self.level/100) + kInfantryPortalArmor)
        end
     end
end
if Client then

    function InfantryPortal:PreventSpinEffect(duration)
        self.preventSpinDuration = duration
        DestroySpinEffect(self)
    end

    function InfantryPortal:OnUpdate(deltaTime)

        PROFILE("InfantryPortal:OnUpdate")
               
        ScriptActor.OnUpdate(self, deltaTime)
        
        
        if self.preventSpinDuration then            
            self.preventSpinDuration = math.max(0, self.preventSpinDuration - deltaTime)         
        end

        local shouldSpin = GetIsUnitActive(self) and self.queuedPlayerId ~= Entity.invalidId and (self.preventSpinDuration == nil or self.preventSpinDuration == 0)
        
        if shouldSpin then
            CreateSpinEffect(self)
        else
            DestroySpinEffect(self)
        end
        
    end

end

function InfantryPortal:GetTechButtons()
local techButtons = nil
  techButtons =  {kTechId.SetRally, kTechId.SpawnMarine, kTechId.None, kTechId.None, 
        kTechId.None, kTechId.None, kTechId.None, kTechId.None,}
        if self.level ~= kInfantryPortalMaxLevel then
    techButtons[5] = kTechId.LevelIP
    end
      return techButtons
end
 function InfantryPortal:PerformActivation(techId, position, normal, commander)
     local success = false
    if techId == kTechId.LevelIP then
    success = self:AddXP(5)    
    end
      return success, true
end
function InfantryPortal:GetHealthbarOffset()
    return 0.5
end 

Shared.LinkClassToMap("InfantryPortal", InfantryPortal.kMapName, networkVars, true)
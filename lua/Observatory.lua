// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Observatory.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/Marine/Scan.lua")

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
Script.Load("lua/DetectorMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/PowerConsumerMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ParasiteMixin.lua")

class 'Observatory' (ScriptActor)

Observatory.kMapName = "observatory"

Observatory.kModelName = PrecacheAsset("models/marine/observatory/observatory.model")
Observatory.kCommanderScanSound = PrecacheAsset("sound/NS2.fev/marine/commander/scan_com")

local kDistressBeaconSoundMarine = PrecacheAsset("sound/NS2.fev/marine/common/distress_beacon_marine")

local kObservatoryTechButtons = { kTechId.Scan, kTechId.None, kTechId.Detector, kTechId.None,
                                   kTechId.None, kTechId.None, kTechId.None, kTechId.None }

Observatory.kDistressBeaconTime = kDistressBeaconTime
Observatory.kDistressBeaconRange = kDistressBeaconRange
Observatory.kDetectionRange = 22 // From NS1 

///Siege Random Automatic Passive Time Researches

local kAnimationGraph = PrecacheAsset("models/marine/observatory/observatory.animation_graph")

local networkVars = { 
                     lastscantime = "time",  
                     ignorelimit = "boolean", 
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
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(PowerConsumerMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

function Observatory:OnCreate()

    ScriptActor.OnCreate(self)
    
    if Server then
    
        self.distressBeaconSound = Server.CreateEntity(SoundEffect.kMapName)
        self.distressBeaconSound:SetAsset(kDistressBeaconSoundMarine)
        self.distressBeaconSound:SetRelevancyDistance(Math.infinity)
        
        self:AddTimedCallback(Observatory.RevealCysts, 4)

    end
    
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
    InitMixin(self, DetectorMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)

    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)  
    
    self.lastscantime = 0
    self.ignorelimit = false
end

function Observatory:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(Observatory.kModelName, kAnimationGraph)
    
    if Server then
    
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
    self:Generate()
end
function Observatory:Generate()
if Observatory.kRandomnlyGeneratedTimeToUnlock ~= 0 then return end
Observatory.kRandomnlyGeneratedTimeToUnlock = math.random(kSecondMarkToUnlockPhaseTechMin, kSecondMarkToUnlockPhaseTechMax)
Print("Phasetech: %s",Observatory.kRandomnlyGeneratedTimeToUnlock)
end

function Observatory:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if Server then
    
        DestroyEntity(self.distressBeaconSound)
        self.distressBeaconSound = nil

        
    end
    
end

function Observatory:GetTechButtons(techId)

    if techId == kTechId.RootMenu then
        return kObservatoryTechButtons
    end
    
    return nil
    
end

function Observatory:GetDetectionRange()

    if GetIsUnitActive(self) then
        return Observatory.kDetectionRange
    end
    
    return 0
    
end

function Observatory:GetRequiresPower()
    return true
end

function Observatory:GetReceivesStructuralDamage()
    return true
end

function Observatory:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function Observatory:GetDistressOrigin()

    // Respawn at nearest built command station
    local origin = nil
    
    local nearest = GetNearest(self:GetOrigin(), "CommandStation", self:GetTeamNumber(), function(ent) return ent:GetIsBuilt() and ent:GetIsAlive() end)
    if nearest then
        origin = nearest:GetModelOrigin()
    end
    
    return origin
    
end

local function TriggerMarineBeaconEffects(self)

    for index, player in ipairs(GetEntitiesForTeam("Player", self:GetTeamNumber())) do
    
        if player:GetIsAlive() and (player:isa("Marine") or player:isa("Exo")) then
            player:TriggerEffects("player_beacon")
        end
    
    end

end
function Observatory:TriggerAdvancedBeacon()

    local success = false
    
    if not self:GetIsBeaconing() then

        self.distressBeaconSound:Start()

        local origin = self:GetDistressOrigin()
        
        if origin then
        
            self.distressBeaconSound:SetOrigin(origin)

            // Beam all faraway players back in a few seconds!
           // self.distressBeaconTime = Shared.GetTime() + Observatory.kDistressBeaconTime
              self.advancedBeaconTime = Shared.GetTime() + Observatory.kDistressBeaconTime
            if Server then
            
                TriggerMarineBeaconEffects(self)
                
                local location = GetLocationForPoint(self:GetDistressOrigin())
                local locationName = location and location:GetName() or ""
                local locationId = Shared.GetStringIndex(locationName)
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Beacon, locationId)
                
            end
            
            success = true
        
        end
    
    end
    
    return success, not success
    
end
function Observatory:TriggerDistressBeacon()

    local success = false
    
    if not self:GetIsBeaconing() then

        self.distressBeaconSound:Start()

        local origin = self:GetDistressOrigin()
        
        if origin then
        
            self.distressBeaconSound:SetOrigin(origin)

            // Beam all faraway players back in a few seconds!
            self.distressBeaconTime = Shared.GetTime() + Observatory.kDistressBeaconTime
            
            if Server then
            
                TriggerMarineBeaconEffects(self)
                
                local location = GetLocationForPoint(self:GetDistressOrigin())
                local locationName = location and location:GetName() or ""
                local locationId = Shared.GetStringIndex(locationName)
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Beacon, locationId)
                
            end
            
            success = true
        
        end
    
    end
    
    return success, not success
    
end

function Observatory:CancelDistressBeacon()

    self.distressBeaconTime = nil
    self.distressBeaconSound:Stop()

end
function Observatory:CancelAdvancedBeacon()

    self.advancedBeaconTime = nil
    self.distressBeaconSound:Stop()

end
function Observatory:OnVortex()

    if self:GetIsBeaconing() then
        self:CancelDistressBeacon()
    elseif self:GetIsAdvancedBeaconing() then
       self:CancelAdvancedBeacon()
      
    end
    
end

local function GetIsPlayerNearby(self, player, toOrigin)
    return (player:GetOrigin() - toOrigin):GetLength() < Observatory.kDistressBeaconRange
end

local function GetPlayersToBeacon(self, toOrigin)

    local players = { }
    
    for index, player in ipairs(self:GetTeam():GetPlayers()) do
    
        // Don't affect Commanders or Heavies
        if player:isa("Marine") or player:isa("Exo") and ( player.GetCanBeacon and olayer:GetCanBeacon() )then
        
            // Don't respawn players that are already nearby.
            if not GetIsPlayerNearby(self, player, toOrigin) then
            
                if player:isa("Exo") then
                    table.insert(players, 1, player)
                else
                    table.insert(players, player)
                end
                
            end
            
        end
        
    end

    return players
    
end

// Spawn players at nearest Command Station to Observatory - not initial marine start like in NS1. Allows relocations and more versatile tactics.
local function RespawnPlayer(self, player, distressOrigin)

    // Always marine capsule (player could be dead/spectator)
    local extents = HasMixin(player, "Extents") and player:GetExtents() or LookupTechData(kTechId.Marine, kTechDataMaxExtents)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)
    local range = Observatory.kDistressBeaconRange
    local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, distressOrigin, 2, range, EntityFilterAll())
    
    if spawnPoint then
    
        if HasMixin(player, "SmoothedRelevancy") then
            player:StartSmoothedRelevancy(spawnPoint)
        end
        
        player:SetOrigin(spawnPoint)
        if player.TriggerBeaconEffects then
            player:TriggerBeaconEffects()
        end

    end
    
    return spawnPoint ~= nil, spawnPoint
    
end

function Observatory:PerformDistressBeacon()

    self.distressBeaconSound:Stop()
    
    local anyPlayerWasBeaconed = false
    local successfullPositions = {}
    local successfullExoPositions = {}
    local failedPlayers = {}
    
    local distressOrigin = self:GetDistressOrigin()
    if distressOrigin then
    
        for index, player in ipairs(GetPlayersToBeacon(self, distressOrigin)) do
        
            local success, respawnPoint = RespawnPlayer(self, player, distressOrigin)
            if success then
            
                anyPlayerWasBeaconed = true
                if player:isa("Exo") then
                    table.insert(successfullExoPositions, respawnPoint)
                end
                
                table.insert(successfullPositions, respawnPoint)
                
            else
                table.insert(failedPlayers, player)
            end
            
        end
        
        // Also respawn players that are spawning in at infantry portals near command station (use a little extra range to account for vertical difference)
        for index, ip in ipairs(GetEntitiesForTeamWithinRange("InfantryPortal", self:GetTeamNumber(), distressOrigin, kInfantryPortalAttachRange + 1)) do
        
            ip:FinishSpawn()
            local spawnPoint = ip:GetAttachPointOrigin("spawn_point")
            table.insert(successfullPositions, spawnPoint)
            
        end
        
    end
    
    local usePositionIndex = 1
    local numPosition = #successfullPositions

    for i = 1, #failedPlayers do
    
        local player = failedPlayers[i]  

        if player:isa("Exo") then        
            player:SetOrigin(successfullExoPositions[math.random(1, #successfullExoPositions)])        
        else
              
            player:SetOrigin(successfullPositions[usePositionIndex])
            if player.TriggerBeaconEffects then
                player:TriggerBeaconEffects()
            end
            
            usePositionIndex = Math.Wrap(usePositionIndex + 1, 1, numPosition)
            
        end    
              
    end

    if anyPlayerWasBeaconed then
        self:TriggerEffects("distress_beacon_complete")
    end
    
end
function Observatory:OnUpdateAnimationInput(modelMixin)

    modelMixin:SetAnimationInput("powered", true)
    
end
if Server then
   function Observatory:GetIsFront()
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
function Observatory:GetCanBeUsedConstructed(byPlayer)
  return not self:GetIsFront() and not byPlayer:GetWeaponInHUDSlot(5) and byPlayer:GetHasWelderPrimary()
end
function Observatory:OnUseDuringSetup(player, elapsedTime, useSuccessTable)

    // Play flavor sounds when using MAC.
    if Server then

        local time = Shared.GetTime()
        
       // if self.timeOfLastUse == nil or (time > (self.timeOfLastUse + 4)) then
        
           local laystructure = player:GiveItem(LayStructures.kMapName)
           laystructure:SetTechId(kTechId.Observatory)
           laystructure:SetMapName(Observatory.kMapName)
           DestroyEntity(self)
           // self.timeOfLastUse = time
            
      //  end
       //self:PlayerUse(player) 
    end
    
end
end
function Observatory:PerformAdvancedBeacon()

    self.distressBeaconSound:Stop()
    
    local anyPlayerWasBeaconed = false
    local successfullPositions = {}
    local successfullExoPositions = {}
    local failedPlayers = {}
    
    local distressOrigin = self:GetDistressOrigin()
    if distressOrigin then
    
        for index, player in ipairs(GetPlayersToBeacon(self, distressOrigin)) do
        
            local success, respawnPoint = RespawnPlayer(self, player, distressOrigin)
            if success then
            
                anyPlayerWasBeaconed = true
                if player:isa("Exo") then
                    table.insert(successfullExoPositions, respawnPoint)
                end
                    
                table.insert(successfullPositions, respawnPoint)
                
            else
                table.insert(failedPlayers, player)
            end
            
        end
        
        // Respawn DeadPlayers
     //   if Server then
       //     local gameRules = GetGamerules()
         //   if gameRules then
           //    if gameRules:GetGameStarted() and not gameRules:GetIsSuddenDeath() then 
                        for _, entity in ientitylist(Shared.GetEntitiesWithClassname("MarineSpectator")) do
                          if entity:GetTeamNumber() == 1 and not entity:GetIsAlive() then
                          entity:SetCameraDistance(0)
                          entity:GetTeam():ReplaceRespawnPlayer(entity)
                          end
                        end
             //  end
           // end
         // end
            
        
    end
    
    local usePositionIndex = 1
    local numPosition = #successfullPositions

    for i = 1, #failedPlayers do
    
        local player = failedPlayers[i]  
    
        if player:isa("Exo") then        
            player:SetOrigin(successfullExoPositions[math.random(1, #successfullExoPositions)])  
            player:SetCameraDistance(0)      
        else
              
            player:SetOrigin(successfullPositions[usePositionIndex])
            player:SetCameraDistance(0) 
            player.timeLastBeacon  = Shared.GetTime()
            if player.TriggerBeaconEffects then
                player:TriggerBeaconEffects()
                player:SetCameraDistance(0)  
            end
            
            usePositionIndex = Math.Wrap(usePositionIndex + 1, 1, numPosition)
            
        end    
    
    end

    if anyPlayerWasBeaconed then
        self:TriggerEffects("distress_beacon_complete")
    end
    
end
function Observatory:SetPowerOff()    
    
    // Cancel distress beacon on power down
    if self:GetIsBeaconing() then    
        self:CancelDistressBeacon()  
        self:CancelAdvancedBeacon()   
    end

end

function Observatory:RevealCysts()

    for _, cyst in ipairs(GetEntitiesForTeamWithinRange("Cyst", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Observatory.kDetectionRange)) do
        if self:GetIsBuilt() and self:GetIsPowered() then
            cyst:SetIsSighted(true)
        end
    end

    return self:GetIsAlive()

end

function GetCheckObsyLimit(techId, origin, normal, commander)
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    
    if locationName then
    
        validRoom = true
        
        for index, obs in ientitylist(Shared.GetEntitiesWithClassname("Observatory")) do
        
            if obs:GetLocationName() == locationName and not obs.ignorelimit then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    
    return validRoom and numInRoom < 3
    
end
function Observatory:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    if GetHasTech(self, kTechId.PhaseTech) or not  GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return end
    local commander = GetCommanderForTeam(1)
    if not commander then return end
    

    local techid = nil
    
    if not GetHasTech(self, kTechId.PhaseTech) then
    techid = kTechId.PhaseTech
    else
       return  
    end
    
   local techNode = commander:GetTechTree():GetTechNode( techid ) 
   commander.isBotRequestedAction = true
   commander:ProcessTechTreeActionForEntity(techNode, self:GetOrigin(), Vector(0,1,0), true, 0, self, nil)
end
function Observatory:ScanAtOrigin()
         CreateEntity( Scan.kMapName, self:GetOrigin(), 1)
         self.lastscantime = Shared.GetTime()
end
  function Observatory:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    
  //  if self:GetIsSiege() then //and not self:GetCanAutomaticTriggerInkAgain() then
     local NowToInk = self:GetCoolDown() - (Shared.GetTime() - self.lastscantime)
     local ScanLength =  math.ceil( Shared.GetTime() + NowToInk - Shared.GetTime() )
     local time = ScanLength
     unitName = string.format(Locale.ResolveString("Observatory (%s)"), Clamp(time, 0, self:GetCoolDown()))
  //  end
 
return unitName
end 
function Observatory:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
function Observatory:GetCoolDown()
return kSiegeObsAutoScanCooldown
end
function Observatory:GetIsInSiege()
if string.find(self:GetLocationName(), "siege") or string.find(self:GetLocationName(), "Siege") then return true end
return false
end
function Observatory:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if GetIsUnitActive(self) then
    
        if techId == kTechId.DistressBeacon then
            return self:TriggerDistressBeacon()
        end
        if techId == kTechId.AdvancedBeacon then
                  if not self:GetIsPowered() then
                   self:SetPowerSurgeDuration(5)
                   end
           return self:TriggerAdvancedBeacon()
         end
        
    end
    
    return ScriptActor.PerformActivation(self, techId, position, normal, commander)
    
end

function Observatory:GetIsBeaconing()
    return self.distressBeaconTime ~= nil
end
function Observatory:GetIsAdvancedBeaconing()
    return self.advancedBeaconTime ~= nil
end

if Server then

    function Observatory:OnKill(killer, doer, point, direction)

        if self:GetIsBeaconing() then
            self:CancelDistressBeacon()
        elseif self:GetIsAdvancedBeaconing() then
           self:CancelAdvancedBeacon()
        end
        
        ScriptActor.OnKill(self, killer, doer, point, direction)
        
    end
    
end

function Observatory:OverrideVisionRadius()
    return Observatory.kDetectionRange
end

if Server then

    function OnConsoleDistress()
    
        if Shared.GetCheatsEnabled() or Shared.GetDevMode() then
            local beacons = Shared.GetEntitiesWithClassname("Observatory")
            for i, beacon in ientitylist(beacons) do
                beacon:TriggerDistressBeacon()
            end
        end
        
    end
    
    Event.Hook("Console_distress", OnConsoleDistress)
    
end

if Server then

    function Observatory:OnConstructionComplete()

        if self.phaseTechResearched then

            local techTree = GetTechTree(self:GetTeamNumber())
            if techTree then
                local researchNode = techTree:GetTechNode(kTechId.PhaseTech)
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.PhaseTech, self)
            end    
            
        end

    end
    
end    

function Observatory:GetHealthbarOffset()
    return 0.9
end 


Shared.LinkClassToMap("Observatory", Observatory.kMapName, networkVars)
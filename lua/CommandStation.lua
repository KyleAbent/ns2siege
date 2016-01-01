// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CommandStation.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/Marine/NanoShield.lua")

Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/RecycleMixin.lua")

Script.Load("lua/CommandStructure.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/IdleMixin.lua")

class 'CommandStation' (CommandStructure)

CommandStation.kMapName = "commandstation"

CommandStation.kModelName = PrecacheAsset("models/marine/command_station/command_station.model")
local kAnimationGraph = PrecacheAsset("models/marine/command_station/command_station.animation_graph")

CommandStation.kUnderAttackSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/command_station_under_attack")

PrecacheAsset("models/marine/command_station/command_station_display.surface_shader")

local kLoginAttachPoint = "login"
CommandStation.kCommandStationKillConstant = 1.05


//Siege
CommandStation.UnlockCatPatTime = 0
CommandStation.UnlockNanoTime = 0
local kDistressBeaconSoundMarine = PrecacheAsset("sound/NS2.fev/marine/common/distress_beacon_marine")

if Server then
    Script.Load("lua/CommandStation_Server.lua")
end

local networkVars = 
{
}

AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)

function CommandStation:OnCreate()

    CommandStructure.OnCreate(self)
    
    InitMixin(self, CorrodeMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, ParasiteMixin)


end

function CommandStation:OnInitialized()

    CommandStructure.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, HiveVisionMixin)
    
    self:SetModel(CommandStation.kModelName, kAnimationGraph)
    
    if Server then
    
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
         self.distressBeaconSound = Server.CreateEntity(SoundEffect.kMapName)
         self.distressBeaconSound:SetAsset(kDistressBeaconSoundMarine)
         self.distressBeaconSound:SetRelevancyDistance(Math.infinity)
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        
    end
    
    InitMixin(self, IdleMixin)
    self:Generate()
end
function CommandStation:Generate()
if CommandStation.UnlockCatPatTime ~= 0 then return end
CommandStation.UnlockCatPatTime = math.random(kSecondMarkToUnlockCatPackTechMin, kSecondMarkToUnlockCatPackTechMax)
CommandStation.UnlockNanoTime = math.random(kSecondMarkToUnlockNanoTechMin, kSecondMarkToUnlockNanoTechMax)
Print("CatPack: %s, Nano: %s", CommandStation.UnlockCatPatTime, CommandStation.UnlockNanoTime )
end

function CommandStation:GetIsWallWalkingAllowed()
    return false
end
function CommandStation:GetCanBeWeldedOverride()
return not self:GetIsSuddenDeath()
end
function CommandStation:GetAddConstructHealth()

return not self:GetIsSuddenDeath()
end
function CommandStation:GetCanBeNanoShieldedOverride()
return not self:GetIsVortexed()
end
function CommandStation:GetIsSuddenDeath()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetIsSuddenDeath() then 
                   return true
               end
            end
        end
            return false
end
local kHelpArrowsCinematicName = PrecacheAsset("cinematics/marine/commander_arrow.cinematic")
PrecacheAsset("models/misc/commander_arrow.model")
          
if Client then

    function CommandStation:GetHelpArrowsCinematicName()
        return kHelpArrowsCinematicName
    end
    
end

function CommandStation:GetRequiresPower()
    return false
end

function CommandStation:GetNanoShieldOffset()
    return Vector(0, -0.3, 0)
end

function CommandStation:GetUsablePoints()

    local loginPoint = self:GetAttachPointOrigin(kLoginAttachPoint)
    return { loginPoint }
    
end

function CommandStation:GetTechButtons()
    return { kTechId.None, kTechId.Recycle } //kTechId.BluePrintTech }
end
function CommandStation:ModifyDamageTaken(damageTable, attacker, doer, damageType)

      if self:GetHealthScalar() <= 0.10 then 
      damageTable.damage = damageTable.damage * .5
      end
 
    
end
function CommandStation:GetCCAmount()
local amount = 0
        for index, CC in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
        
               amount  = amount + 1
            
        end
        
    
    return amount
    
end
if Server then
function GetCCQualifications(techId, origin, normal, commander)
 if CommandStation:GetCCAmount() >= 3 then return false end
 
             local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetIsSuddenDeath() then 
                   return false
               end
            end
            return true
end
end
function CommandStation:GetCanBeUsed(player, useSuccessTable)

    // Cannot be used if the team already has a Commander (but can still be used to build).
    if player:isa("Exo") or (self:GetIsBuilt() and GetTeamHasCommander(self:GetTeamNumber())) then
        useSuccessTable.useSuccess = false
    end
    
end

function CommandStation:GetCanRecycleOverride()
    return not self:GetIsOccupied() and self:GetCanBeWeldedOverride()
end

function CommandStation:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = CommandStructure.GetTechAllowed(self, techId, techNode, player)

    if techId == kTechId.Recycle then
        allowed = allowed and not self:GetIsOccupied()
    end
    
    return allowed, canAfford
    
end
function CommandStation:OnConstructionComplete()
self:AddTimedCallback(CommandStation.UpdateManually, kBeaconDelay)
end
function CommandStation:UpdateManually()
   if Server then 
      if not self:GetIsVortexed() and self:GetIsBuilt() then self:UpdateBeacons() end
    self:UpdatePassive() 
    end
    
    return true
end
function CommandStation:UpdateBeacons()
  local time = self:GetTeam():GetBeacons()
  
    if time then
          local healthscalar = self:GetHealthScalar()
          if healthscalar <= .75 then
             self:UseBeacon()
          end
    end
    
end
function CommandStation:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
local function GetIsPlayerNearby(self, player, toOrigin)
    return (player:GetOrigin() - toOrigin):GetLength() < 17 or self:GetLocationName() == player:GetLocationName()
end
function CommandStation:UseBeacon()
   if self:GetIsVortexed() then return end
                
                
                local eligable = {}
                
               for _, entity in ientitylist(Shared.GetEntitiesWithClassname("MarineSpectator")) do
                          if entity:GetTeamNumber() == 1 and not entity:GetIsAlive() then
                         // entity:SetCameraDistance(0)
                         // entity:GetTeam():ReplaceRespawnPlayer(entity)
                         table.insert(eligable,entity)
                          end
               end
                        
             if not self:GetIsSuddenDeath() then  
                 for _, entity in ientitylist(Shared.GetEntitiesWithClassname("Marine")) do
                       if entity:GetIsAlive() and not GetIsPlayerNearby(self, entity, self:GetOrigin()) 
                      and not entity:GetIsInSiege() and entity:GetCanBeacon() then
                       table.insert(eligable,entity) 
                      end
                 end
             end
                
            if #eligable == 0 then return end
            
             self.distressBeaconSound:Start()
             self:AddTimedCallback(function()  self.distressBeaconSound:Stop() end,1 ) 
              self.distressBeaconSound:SetOrigin(self:GetOrigin())
               local location = GetLocationForPoint(self:GetOrigin())
                local locationName = location and location:GetName() or ""
                local locationId = Shared.GetStringIndex(locationName)
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Beacon, locationId)
                self:GetTeam():DeductBeacon()
                
                
            local onteam = self:GetNumPlayers()
            
             local gameRules = GetGamerules()
           local roundlength =  Shared.GetTime() - gameRules:GetGameStartTime()
         local scalar = onteam * Clamp(kFrontDoorTime/kSiegeDoorTime, 0.1, 1)
            local beaconed = 0
           for i = 1, Clamp(#eligable, 1, scalar ) do
                local player = eligable[i]
                
                if player:GetIsAlive() then
                player:TriggerBeacon(self:FindFreeSpace())
                player.timeLastBeacon = Shared.GetTime()
                beaconed = beaconed + 1
                else
                player:SetCameraDistance(0)
                player:GetTeam():ReplaceRespawnPlayer(player, self:FindFreeSpace(), player:GetAngles(), nil, true) 
                player.timeLastBeacon = Shared.GetTime()
                beaconed = beaconed + 1
                end
           end  
    Print("CommandStation HP: %s, Players on team: %s, Eligable for beacon: %s, ", self:GetHealthScalar(), onteam, scalar, beaconed)
   
end
function CommandStation:GetNumPlayers()
local marines = 0

               for _, entity in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                          if entity:GetTeamNumber() == 1 and not entity:isa("Commander") then
                            marines = marines +1
                          end
               end
               return marines
end
    function CommandStation:FindFreeSpace()
    
        for index = 1, 100 do
           local extents = Vector(1,1,1)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), .5, 24, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == self:GetLocationName()
        
           if spawnPoint ~= nil and sameLocation  then
           return spawnPoint
           end
       end
           Print("No valid spot found for CC beacon!")
           return self:GetOrigin()
    end
 /*
   function CommandStation:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Command Station (%s)"), self:GetTeam():GetBeacons())
return unitName
end 
*/
function CommandStation:ExperimentalBeacon(anotheramt)
end
function CommandStation:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    if  GetHasTech(self, kTechId.NanoShieldTech) or not  GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return true end
    local commander = GetCommanderForTeam(1)
    if not commander then return true end
    

    local techid = nil
    
    if not GetHasTech(self, kTechId.CatPackTech) then
    techid = kTechId.CatPackTech
    elseif GetHasTech(self, kTechId.MinesTech) and not GetHasTech(self, kTechId.NanoShieldTech) then
    techid = kTechId.NanoShieldTech
    else
       return  true
    end
    
   local techNode = commander:GetTechTree():GetTechNode( techid ) 
   commander.isBotRequestedAction = true
   commander:ProcessTechTreeActionForEntity(techNode, self:GetOrigin(), Vector(0,1,0), true, 0, self, nil)
end
if Server then
function CommandStation:UpdateResearch(deltaTime)
 if not self.timeLastUpdateCheck or self.timeLastUpdateCheck + 15 < Shared.GetTime() then 
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
    if researchNode then
        local gameRules = GetGamerules()
        local projectedminutemarktounlock = 60
        local currentroundlength = ( Shared.GetTime() - gameRules:GetGameStartTime() )
        if researchNode:GetTechId() == kTechId.CatPackTech then
           projectedminutemarktounlock = CommandStation.UnlockCatPatTime
        elseif researchNode:GetTechId() == kTechId.NanoShieldTech then
          projectedminutemarktounlock = CommandStation.UnlockNanoTime
         end
        
     /// kRecycleTime

        //1 minute = mines
        //so if building armory at 30 seconds
        //then progress will be 30 seconds
        //
       
       //mines 60
       //grenades 120
       //shotgun 180
       //onifle 240
       //AA 300
       
        local progress = Clamp(currentroundlength / projectedminutemarktounlock, 0, 1)
        //Print("%s", progress)
        if progress ~= self.researchProgress then
        
            self.researchProgress = progress

            researchNode:SetResearchProgress(self.researchProgress)
            
            local techTree = self:GetTeam():GetTechTree()
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
            
            // Update research progress
            if self.researchProgress == 1 then

                // Mark this tech node as researched
                researchNode:SetResearched(true)
                
                techTree:QueueOnResearchComplete(self.researchingId, self)
                
            end
        
        end
        
    end 
self.timeLastUpdateCheck = Shared.GetTime()
end
end
end//server
function CommandStation:GetIsPlayerInside(player)

    // Check to see if we're in range of the visible center of the login platform
    local vecDiff = (player:GetModelOrigin() - self:GetKillOrigin())
    return vecDiff:GetLength() < CommandStation.kCommandStationKillConstant
    
end

local kCommandStationState = enum( { "Normal", "Locked", "Welcome", "Unbuilt" } )
function CommandStation:OnUpdateRender()

    PROFILE("CommandStation:OnUpdateRender")

    CommandStructure.OnUpdateRender(self)
    
    local model = self:GetRenderModel()
    if model then
    
        local state = kCommandStationState.Normal
        
        if self:GetIsGhostStructure() then
            state = kCommandStationState.Unbuilt
        elseif self:GetIsOccupied() then
            state = kCommandStationState.Welcome
        elseif GetTeamHasCommander(self:GetTeamNumber()) then
            state = kCommandStationState.Locked
        end
        
        model:SetMaterialParameter("state", state)
        
    end
    
end
function CommandStation:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if Server then
    
        DestroyEntity(self.distressBeaconSound)
        self.distressBeaconSound = nil

        
    end
    
end
function CommandStation:GetHealthbarOffset()
    return 2
end

// return a good spot from which a player could have entered the hive
// used for initial entry point for the commander
function CommandStation:GetDefaultEntryOrigin()
    return self:GetOrigin() + Vector(0,0.9,0)
end

Shared.LinkClassToMap("CommandStation", CommandStation.kMapName, networkVars)
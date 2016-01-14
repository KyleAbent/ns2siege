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
function CommandStation:GetIsSiege()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   return true
               end
            end
        end
            return false
end
function CommandStation:ModifyDamageTaken(damageTable, attacker, doer, damageType)

      if self:GetIsSiege() then 
      damageTable.damage = damageTable.damage * .7
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
if Server then
function CommandStation:OnConstructionComplete()
self:AddTimedCallback(CommandStation.UpdateBeacons, kBeaconDelay)
end
function CommandStation:UpdateBeacons()
  local time = self:GetTeam():GetBeacons()
                    //So the auto beacon triggers infinite as long as health says so.  
    if time then
          local armorscalar = self:GetArmorScalar()
          if armorscalar <= .15 then
             self:UseBeacon()
          end
    end
    
    return true
    
end
function CommandStation:GetLocationName() //Minimap location name which powerpoints use to determine where things take place
                                          //I figure it would be handy for both marines and aliens to recieve notifications 
                                          //Perhaps even waypoints for less confusion of learning all these new map designsw.
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
local function GetIsPlayerNearby(self, player, toOrigin)
    return (player:GetOrigin() - toOrigin):GetLength() < 17 or self:GetLocationName() == player:GetLocationName()
end
function CommandStation:FindEligable()
                local eligable = {}
               for _, entity in ientitylist(Shared.GetEntitiesWithClassname("MarineSpectator")) do
                          if entity:GetTeamNumber() == 1 and not entity:GetIsAlive() then
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
             return eligable
end
function CommandStation:RespawnAndTeleportEligable(eligable)
local gameRules = GetGamerules()
 local roundlength = Shared.GetTime() - gameRules:GetGameStartTime()
              for i = 1, Clamp(#eligable, 1, 12 ) do
                local player = eligable[i]
                if player:GetIsAlive() and player:GetCanBeacon() then
                player:TriggerBeacon(self:FindFreeSpace())
                else
                player:GetTeam():ReplaceRespawnPlayer(player, self:FindFreeSpace(), player:GetAngles(), nil, true) 
                player:SetCameraDistance(0)
                player.timeLastBeacon = Shared.GetTime()
                end
           end  
end
function CommandStation:UseBeacon()
   if self:GetIsVortexed() then return end
                local eligable = self:FindEligable()
                if #eligable == 0 then return end
               self.distressBeaconSound:Start()
               self.distressBeaconSound:SetOrigin(self:GetOrigin())
                self:AlertTeams()
                self:GetTeam():DeductBeacon()
                self:RespawnAndTeleportEligable(eligable)
                                    --This version the sound will stop after beacon is complete
                                    --This way I know that the beacon actually works or not. Before
                                    --Before I couldnt tell. I just want it to work correctly before
                                    --People judge it. I know there's alot of complaints :l. But I love 
                                    --How this plays out too much.
      self.distressBeaconSound:Stop()
      self:AddTimedCallback(CommandStation.AlertMarinesWeld, 4 ) 
   
end
function CommandStation:AlertTeams()
                local location = GetLocationForPoint(self:GetOrigin())
                local locationName = location and location:GetName() or ""
                local locationId = Shared.GetStringIndex(locationName)
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.AutoBeacon, locationId)
                SendTeamMessage(self:GetEnemyTeam(), kTeamMessageTypes.AutoBeacon, locationId)
                //This sends on screen notifications saying the room location the beacon took place.
end
function CommandStation:AlertMarinesWeld()
          //So after the auto beacon triggers, marines recieve a notification to weld the CC
          //they may not know it but this is the cause of auto beacon
          //Aliens can trap marines in a room like flies, taking over their hardware for their own conveniance,
          //If a marine tries to leave the room they have 30 seconds until they are eligable again for an auto beacon,
          //unless they so happen to die the counter resets (Perhaps later the counter may last through death but not yet)
          for _, player in ipairs(GetEntitiesWithinRange("Marine", self:GetOrigin(), 999)) do
        if player:GetIsAlive() and not player:isa("Commander") then
           player:GiveOrder(kTechId.Weld, self:GetId(), self:GetOrigin(), nil, true, true)
        end
              CreatePheromone(kTechId.ThreatMarker, self:GetOrigin(), 2)  //Make alien threat
        //Also give away your position to the enemies you poor S.O.B's !
end
function CommandStation:GetNumPlayers()
local marines = 1
               for _, entity in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                          if entity:GetTeamNumber() == 1 and not entity:isa("Commander") then
                            marines = marines + 1
                          end
               end
               return marines
end
end//server
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
end
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
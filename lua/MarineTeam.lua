// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MarineTeam.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// This class is used for teams that are actually playing the game, e.g. Marines or Aliens.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Marine.lua")
Script.Load("lua/PlayingTeam.lua")

class 'MarineTeam' (PlayingTeam)

MarineTeam.gSandboxMode =  true


// How often to send the "No IPs" message to the Marine team in seconds.
local kSendNoIPsMessageRate = 20

local kCannotSpawnSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/need_ip")

--Cache for spawned ip positions
local takenInfantryPortalPoints = {}

function MarineTeam:ResetTeam()
	takenInfantryPortalPoints = {}
	
    local commandStructure = PlayingTeam.ResetTeam(self)
    
    self.updateMarineArmor = false
    
    if self.brain ~= nil then
        self.brain:Reset()
    end
    
    return commandStructure
    
end

function MarineTeam:OnResetComplete()

    //adjust first power node    
    local initialTechPoint = self:GetInitialTechPoint()
    for index, powerPoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
    
        if powerPoint:GetLocationName() == initialTechPoint:GetLocationName() then
            powerPoint:SetConstructionComplete()
        end
        
    end
    self.beacons = 16
    self.lastbeacontime = Shared.GetTime()
end

function MarineTeam:GetTeamType()
    return kMarineTeamType
end

function MarineTeam:GetIsMarineTeam()
    return true 
end

function MarineTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)
    
    self.respawnEntity = Marine.kMapName
    
    self.updateMarineArmor = false
    
    self.lastTimeNoIPsMessageSent = Shared.GetTime()
    
    
end
function MarineTeam:DeductBeacon()
self.lastbeacontime = Shared.GetTime()
end
function MarineTeam:GetBeacons()
local time = self.lastbeacontime == nil or Shared.GetTime() > self.lastbeacontime + kBeaconDelay
return time
end
function MarineTeam:GetHasAbilityToRespawn()
/*
          if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetIsSuddenDeath() then 
               return false
               end
            end
          end
   */       
    // Any active IPs on team? There could be a case where everyone has died and no active
    // IPs but builder bots are mid-construction so a marine team could theoretically keep
    // playing but ignoring that case for now
    local spawningStructures = GetEntitiesForTeam("CommandStation", self:GetTeamNumber())
    
    for index, current in ipairs(spawningStructures) do
    
        if current:GetIsBuilt() then
            return true
        end
        
    end        
    
    return false
    
end

function MarineTeam:OnRespawnQueueChanged()

    local spawningStructures = GetEntitiesForTeam("InfantryPortal", self:GetTeamNumber())
    
    for index, current in ipairs(spawningStructures) do
    
        if current:GetIsBuilt() and current:GetIsPowered() then
            current:FillQueueIfFree()
        end
        
    end        
    
end


function MarineTeam:GetTotalInRespawnQueue()
    
    local queueSize = #self.respawnQueue
    local numPlayers = 0
    
    for i = 1, #self.respawnQueue do
        local player = Shared.GetEntity(self.respawnQueue[i])
        if player then
            numPlayers = numPlayers + 1
        end
    
    end
    
    local allIPs = GetEntitiesForTeam( "InfantryPortal", self:GetTeamNumber() )
    if #allIPs > 0 then
        
        for _, ip in ipairs( allIPs ) do
        
            if GetIsUnitActive( ip ) then
                
                if ip.queuedPlayerId ~= nil and ip.queuedPlayerId ~= Entity.invalidId then
                    numPlayers = numPlayers + 1
                end
                
            end
        
        end
        
    end
    
    return numPlayers
    
end


local function CheckForNoIPs(self)

    PROFILE("MarineTeam:CheckForNoIPs")

    if Shared.GetTime() - self.lastTimeNoIPsMessageSent >= kSendNoIPsMessageRate then
    
        self.lastTimeNoIPsMessageSent = Shared.GetTime()
        if Shared.GetEntitiesWithClassname("InfantryPortal"):GetSize() == 0 then
        
            self:ForEachPlayer(function(player) StartSoundEffectForPlayer(kCannotSpawnSound, player) end)
            SendTeamMessage(self, kTeamMessageTypes.CannotSpawn)
            
        end
        
    end
    
end

local function SpawnBaseEntities(self, techPoint)
//messy and mir-air. But whatever. Requires GetGroundPosition
    local techPointOrigin = techPoint:GetOrigin()
        local IPspawnPoint1 = GetRandomBuildPosition( kTechId.InfantryPortal, techPointOrigin, 12 )
        local IPspawnPoint2 = GetRandomBuildPosition( kTechId.InfantryPortal, techPointOrigin, 12 )
        local ArmoryPoint = GetRandomBuildPosition( kTechId.Armory, techPointOrigin, 12 )
        local ArmsLabPoint = GetRandomBuildPosition( kTechId.ArmsLab, techPointOrigin, 12 )
        local MacPoint1 = GetRandomBuildPosition( kTechId.MAC, techPointOrigin, 12 )
        local MacPoint2 = GetRandomBuildPosition( kTechId.MAC, techPointOrigin, 12 )
        local MacPoint3 = GetRandomBuildPosition( kTechId.MAC, techPointOrigin, 12 )
        local PrototypeLabPoint = GetRandomBuildPosition( kTechId.PrototypeLab, techPointOrigin, 12 )
        local PhaseGatePoint = GetRandomBuildPosition( kTechId.PhaseGate, techPointOrigin, 12 )
  
    CreateEntity(InfantryPortal.kMapName, IPspawnPoint1, self:GetTeamNumber())
    CreateEntity(InfantryPortal.kMapName, IPspawnPoint2, self:GetTeamNumber())
    CreateEntity(Armory.kMapName, ArmoryPoint, self:GetTeamNumber())
    CreateEntity(ArmsLab.kMapName, ArmsLabPoint, self:GetTeamNumber())
    CreateEntity(MAC.kMapName, MacPoint1, self:GetTeamNumber())
    CreateEntity(MAC.kMapName, MacPoint2, self:GetTeamNumber())
    CreateEntity(MAC.kMapName, MacPoint3, self:GetTeamNumber())
    CreateEntity(PrototypeLab.kMapName, PrototypeLabPoint, self:GetTeamNumber())
    CreateEntity(PhaseGate.kMapName, PhaseGatePoint, self:GetTeamNumber())
        
    
end
   local function FindFreeSpace(origin)
    
        for index = 1, 100 do
           local extents = Vector(1,1,1)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, origin, 1, 24, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == GetLocationForPoint(origin)
        
           if spawnPoint ~= nil and sameLocation  then
           return spawnPoint
           end
       end
           Print("No valid spot found for marine initial structure spawn!")
           return origin
    end
local function SpawnMac(self, techPoint)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
		
        spawnPoint = GetRandomBuildPosition( kTechId.MAC, techPointOrigin, kInfantryPortalAttachRange + 5 )
        spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
		
    
    if spawnPoint then
    
        local pt = CreateEntity(MAC.kMapName, spawnPoint, self:GetTeamNumber())
        
        
    end
    
end
local function SpawnArc(self, techPoint)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
		
        spawnPoint = GetRandomBuildPosition( kTechId.ARC, techPointOrigin, kInfantryPortalAttachRange - 5)
        spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
		
    
    if spawnPoint then
    
        local arc = CreateEntity(ARC.kMapName, spawnPoint, self:GetTeamNumber())
        arc:GiveOrder(kTechId.ARCDeploy, arc:GetId(), arc:GetOrigin(), nil, false, false)
        
        
    end
    
end
local function SpawnObservatory(self, techPoint)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
		
        spawnPoint = GetRandomBuildPosition( kTechId.Observatory, techPointOrigin, kInfantryPortalAttachRange )
        spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
		
    
    if spawnPoint then
    
        local pt = CreateEntity(Observatory.kMapName, spawnPoint, self:GetTeamNumber())
        SetRandomOrientation(pt)
        pt:SetConstructionComplete()
        
    end
    
end
local function SpawnPrototypeLab(self, techPoint)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
		
        spawnPoint = GetRandomBuildPosition( kTechId.PrototypeLab, techPointOrigin, kInfantryPortalAttachRange + 5)
        spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
		
    
    if spawnPoint then
    
        local pt = CreateEntity(PrototypeLab.kMapName, spawnPoint, self:GetTeamNumber())
        
        SetRandomOrientation(pt)
        pt:SetConstructionComplete()
        
    end
    
end
local function SpawnArmory(self, techPoint)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
		
        spawnPoint = GetRandomBuildPosition( kTechId.Armory, techPointOrigin, kInfantryPortalAttachRange + 5)
        spawnPoint = spawnPoint and spawnPoint - Vector( 0, 0.6, 0 )
		
    
    if spawnPoint then
    
        local aa = CreateEntity(Armory.kMapName, spawnPoint, self:GetTeamNumber())
        
        SetRandomOrientation(aa)
        aa:SetConstructionComplete()
        
    end
    
end

function MarineTeam:Update(timePassed)

    PROFILE("MarineTeam:Update")

    PlayingTeam.Update(self, timePassed)
    

    if GetGamerules():GetGameStarted() then
        CheckForNoIPs(self)
    end
   
    
end

function MarineTeam:GetHasPoweredPhaseGate()
    return self.hasPoweredPG == true    
end

function MarineTeam:InitTechTree()
   
   PlayingTeam.InitTechTree(self)
    
    // Marine tier 1
    self.techTree:AddBuildNode(kTechId.CommandStation,            kTechId.None,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.Extractor,                 kTechId.None,                kTechId.None)
    
    self.techTree:AddUpgradeNode(kTechId.ExtractorArmor)
    
    // Count recycle like an upgrade so we can have multiples
    self.techTree:AddUpgradeNode(kTechId.Recycle, kTechId.None, kTechId.None)
    
    self.techTree:AddPassive(kTechId.Welding)
    self.techTree:AddPassive(kTechId.SpawnMarine)
    self.techTree:AddPassive(kTechId.CollectResources, kTechId.Extractor)
    self.techTree:AddPassive(kTechId.Detector)
    
    self.techTree:AddSpecial(kTechId.TwoCommandStations)
    self.techTree:AddSpecial(kTechId.ThreeCommandStations)
    
    // When adding marine upgrades that morph structures, make sure to add to GetRecycleCost() also
    self.techTree:AddBuildNode(kTechId.InfantryPortal,            kTechId.CommandStation,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.Sentry,                    kTechId.None,     kTechId.None, true)
     //   self.techTree:AddBuildNode(kTechId.ARC,    kTechId.ARCRoboticsFactory,     kTechId.None, true)  
        
    self.techTree:AddActivation(kTechId.MACEMP,                 kTechId.None,         kTechId.None) 
    
    self.techTree:AddBuildNode(kTechId.Armory,                    kTechId.CommandStation,      kTechId.None)  
    self.techTree:AddBuildNode(kTechId.ArmsLab,                   kTechId.CommandStation,                kTechId.None)  
    self.techTree:AddManufactureNode(kTechId.MAC,                 kTechId.RoboticsFactory,                kTechId.None,  true) 
    self.techTree:AddManufactureNode(kTechId.ARC,    kTechId.ARCRoboticsFactory,     kTechId.None, true)  
    self.techTree:AddBuyNode(kTechId.Axe,                         kTechId.None,              kTechId.None)
    self.techTree:AddBuyNode(kTechId.Pistol,                      kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Rifle,                       kTechId.None,                kTechId.None)

    self.techTree:AddBuildNode(kTechId.SentryBattery,             kTechId.None,      kTechId.None)      
    
    self.techTree:AddOrder(kTechId.Defend)
    self.techTree:AddOrder(kTechId.FollowAndWeld)
    
    // Commander abilities
    self.techTree:AddResearchNode(kTechId.NanoShieldTech)
    self.techTree:AddResearchNode(kTechId.CatPackTech)
    self.techTree:AddResearchNode(kTechId.BluePrintTech)
    
    self.techTree:AddTargetedActivation(kTechId.NanoShield,       kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.Scan,             kTechId.Observatory)
    self.techTree:AddTargetedActivation(kTechId.PowerSurge,       kTechId.RoboticsFactory)
    self.techTree:AddTargetedActivation(kTechId.MedPack,          kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.AmmoPack,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.CatPack,          kTechId.None) 
    
    self.techTree:AddAction(kTechId.SelectObservatory)

    // Armory upgrades

    self.techTree:AddUpgradeNode(kTechId.ArmoryArmor,              kTechId.None)
    
    // arms lab upgrades
    
    self.techTree:AddResearchNode(kTechId.Armor1,                 kTechId.ArmsLab)
    self.techTree:AddResearchNode(kTechId.Armor2,                 kTechId.Armor1, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Armor3,                 kTechId.Armor2, kTechId.None)    
    self.techTree:AddResearchNode(kTechId.NanoArmor,              kTechId.None)

    
    
    
    self.techTree:AddResearchNode(kTechId.Weapons1,               kTechId.ArmsLab)
    self.techTree:AddResearchNode(kTechId.Weapons2,               kTechId.Weapons1, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons3,               kTechId.Weapons2, kTechId.None)
    self.techTree:AddResearchNode(kTechId.RifleClip,              kTechId.Weapons3, kTechId.None)
    
    // Marine tier 2
    
    self.techTree:AddBuildNode(kTechId.AdvancedArmory,               kTechId.Armory,        kTechId.None)
    self.techTree:AddResearchNode(kTechId.PhaseTech,                    kTechId.Observatory,        kTechId.None)
    self.techTree:AddBuildNode(kTechId.PhaseGate,                    kTechId.None,        kTechId.None, true)


    self.techTree:AddBuildNode(kTechId.Observatory,               kTechId.None,       kTechId.None)      
    self.techTree:AddActivation(kTechId.DistressBeacon,           kTechId.Observatory) 
    self.techTree:AddActivation(kTechId.LevelSentry,           kTechId.None)  
    self.techTree:AddActivation(kTechId.LevelIP,           kTechId.None)   
    self.techTree:AddActivation(kTechId.PGchannelOne,           kTechId.None)  
    self.techTree:AddActivation(kTechId.PGchannelTwo,           kTechId.None)  
    self.techTree:AddActivation(kTechId.PGchannelThree,           kTechId.None)  
    self.techTree:AddResearchNode(kTechId.AdvancedBeaconTech,                    kTechId.None,        kTechId.None)
    self.techTree:AddActivation(kTechId.AdvancedBeacon,           kTechId.None)  
    
    // Door actions
    self.techTree:AddBuildNode(kTechId.Door, kTechId.None, kTechId.None)
    self.techTree:AddActivation(kTechId.DoorOpen)
    self.techTree:AddActivation(kTechId.DoorClose)
    self.techTree:AddActivation(kTechId.DoorLock)
    self.techTree:AddActivation(kTechId.DoorUnlock)
    
    self.techTree:AddActivation(kTechId.MoveThroughLockedDoorOff)
    self.techTree:AddActivation(kTechId.MoveThroughLockedDoorOn)
    
    // Weapon-specific
    
    self.techTree:AddUpgradeNode(kTechId.ArmoryHealth,           kTechId.None,              kTechId.None)
   

    self.techTree:AddTargetedBuyNode(kTechId.HeavyMachineGun,            kTechId.None,         kTechId.None)
        
    self.techTree:AddResearchNode(kTechId.ShotgunTech,           kTechId.Armory,              kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.Shotgun,            kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropShotgun,     kTechId.None,         kTechId.None)
    
        self.techTree:AddResearchNode(kTechId.HeavyRifleTech,           kTechId.None,              kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.HeavyRifle,            kTechId.None,         kTechId.None)
        self.techTree:AddTargetedBuyNode(kTechId.HeavyArmor,            kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropHeavyRifle,     kTechId.None,         kTechId.None)
    
        self.techTree:AddTargetedBuyNode(kTechId.ExoNanoArmor,            kTechId.Armor1,         kTechId.None)
            self.techTree:AddTargetedBuyNode(kTechId.JumpPack,            kTechId.None,         kTechId.None)
                self.techTree:AddTargetedBuyNode(kTechId.FireBullets,            kTechId.None,         kTechId.None)
           self.techTree:AddTargetedBuyNode(kTechId.Resupply,            kTechId.None,         kTechId.None)
                
    self.techTree:AddResearchNode(kTechId.AdvancedWeaponry,      kTechId.None,      kTechId.None)    
    
    self.techTree:AddTargetedBuyNode(kTechId.GrenadeLauncher,  kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropGrenadeLauncher,  kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.AdvancedArmoryUpgrade,  kTechId.None)
        
    self.techTree:AddResearchNode(kTechId.GrenadeTech,           kTechId.Armory,                   kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.ClusterGrenade,     kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.GasGrenade,         kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.PulseGrenade,       kTechId.None)
    
    self.techTree:AddTargetedBuyNode(kTechId.Flamethrower,     kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropFlamethrower,    kTechId.None)
    self.techTree:AddResearchNode(kTechId.MinesTech,            kTechId.Armory,           kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.LayMines,          kTechId.None,        kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.LayStructures,          kTechId.None,        kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropMines,      kTechId.None,        kTechId.None)
    
    self.techTree:AddTargetedBuyNode(kTechId.Welder,          kTechId.Armory,        kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropWelder,   kTechId.Armory,        kTechId.None)
    
    // ARCs
    self.techTree:AddBuildNode(kTechId.RoboticsFactory,                    kTechId.InfantryPortal,                 kTechId.None)  
    self.techTree:AddUpgradeNode(kTechId.UpgradeRoboticsFactory,           kTechId.Armory,              kTechId.RoboticsFactory) 
    self.techTree:AddBuildNode(kTechId.ARCRoboticsFactory,                 kTechId.None,              kTechId.RoboticsFactory)
    
    
        self.techTree:AddActivation(kTechId.MacSpawnOn,                kTechId.RoboticsFactory,          kTechId.None)
    self.techTree:AddActivation(kTechId.MacSpawnOff,                kTechId.RoboticsFactory,          kTechId.None)
        
    self.techTree:AddActivation(kTechId.ArcSpawnOn,                kTechId.ARCRoboticsFactory,          kTechId.None)
    self.techTree:AddActivation(kTechId.ArcSpawnOff,                kTechId.ARCRoboticsFactory,          kTechId.None)
    
        self.techTree:AddActivation(kTechId.Lock,                kTechId.None,          kTechId.None)
    self.techTree:AddActivation(kTechId.Unlock,                kTechId.None,          kTechId.None)
    
    
    
    self.techTree:AddResearchNode(kTechId.MacWeldMacs,            kTechId.ARCRoboticsFactory,                   kTechId.None)
   
    
    
    self.techTree:AddTechInheritance(kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory)
   
      
    self.techTree:AddActivation(kTechId.ARCDeploy)
    self.techTree:AddActivation(kTechId.ARCUndeploy)
    
    // Robotics factory menus
    self.techTree:AddMenu(kTechId.RoboticsFactoryARCUpgradesMenu)
    self.techTree:AddMenu(kTechId.RoboticsFactoryMACUpgradesMenu)
    
    self.techTree:AddMenu(kTechId.WeaponsMenu)
    
    // Marine tier 3
    self.techTree:AddBuildNode(kTechId.PrototypeLab,          kTechId.None,              kTechId.None)        

    // Jetpack
    self.techTree:AddResearchNode(kTechId.JetpackTech,           kTechId.PrototypeLab, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Jetpack,                    kTechId.None, kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropJetpack,    kTechId.None, kTechId.None)
    
    // Exosuit
    self.techTree:AddResearchNode(kTechId.ExosuitTech,           kTechId.PrototypeLab, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Exosuit,                    kTechId.None, kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropExosuit,     kTechId.None, kTechId.None)
    self.techTree:AddResearchNode(kTechId.DualMinigunTech,       kTechId.None, kTechId.TwoCommandStations)
    self.techTree:AddResearchNode(kTechId.DualMinigunExosuit,    kTechId.DualMinigunTech, kTechId.TwoCommandStations)
    self.techTree:AddResearchNode(kTechId.ClawRailgunExosuit,    kTechId.None, kTechId.None)
    self.techTree:AddResearchNode(kTechId.DualRailgunTech,       kTechId.None, kTechId.TwoCommandStations)
    self.techTree:AddResearchNode(kTechId.DualRailgunExosuit,    kTechId.DualMinigunTech, kTechId.TwoCommandStations)
    
    self.techTree:AddBuyNode(kTechId.UpgradeToDualMinigun, kTechId.DualMinigunTech, kTechId.TwoCommandStations)
    self.techTree:AddBuyNode(kTechId.UpgradeToDualRailgun, kTechId.DualMinigunTech, kTechId.TwoCommandStations)

    self.techTree:AddActivation(kTechId.SocketPowerNode,    kTechId.None,   kTechId.None)
    
    self.techTree:SetComplete()

end

function MarineTeam:SpawnInitialStructures(techPoint)

    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)
    
    SpawnBaseEntities(self, techPoint)
    return tower, commandStation
    
end

function MarineTeam:GetSpectatorMapName()
    return MarineSpectator.kMapName
end

function MarineTeam:OnBought(techId)

    local listeners = self.eventListeners['OnBought']

    if listeners then

        for _, listener in ipairs(listeners) do
            listener(techId)
        end

    end

end

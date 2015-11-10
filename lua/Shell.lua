// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Shell.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
//    Alien structure that hosts Shell upgrades. 1 shell: level 1 upgrade, 2 shells: level 2 etc.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

class 'Shell' (ScriptActor)

Shell.kMapName = "shell"

Shell.kModelName = PrecacheAsset("models/alien/shell/shell.model")

Shell.kAnimationGraph = PrecacheAsset("models/alien/shell/shell.animation_graph")

local kLifeSpan = 30 //contamination


local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(TeleportMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
local function TimeUp(self)

    self:Kill()
    return false

end
function Shell:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, CloakableMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, ObstacleMixin)    
    InitMixin(self, FireMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, TeleportMixin)
    InitMixin(self, UmbraMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, CombatMixin)
    
    if Server then
        InitMixin(self, InfestationTrackerMixin)
    elseif Client then
        InitMixin(self, CommanderGlowMixin)    
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.None)
    self:SetPhysicsGroup(PhysicsGroup.DroppedWeaponGroup)

end

function Shell:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Shell.kModelName, Shell.kAnimationGraph)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, SleeperMixin)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
      
  //    self:AddTimedCallback(Shell.OnDrain, 1)
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
   // self.startsBuilt = true
end

function Shell:GetIsSmallTarget()
    return true
end

function Shell:GetBioMassLevel()
    return kShellBiomass
end


function Shell:GetHealthbarOffset()
    return 0.45
end

function Shell:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function Shell:GetCanSleep()
    return true
end

function Shell:GetIsWallWalkingAllowed()
    return false
end 

function Shell:GetReceivesStructuralDamage()
    return true
end
if Server then
    function Shell:OnKill(attacker, doer, point, direction)

        ScriptActor.OnKill(self, attacker, doer, point, direction)
        self:TriggerEffects("death")
        DestroyEntity(self)
    end
    
    function Shell:OnDestroy()
        ScriptActor.OnDestroy(self)
    end
function Shell:OnConstructionComplete()
        self:AddTimedCallback(TimeUp, kLifeSpan + 0.5)  
        self:GenerateRandomNumberofEggsNearbyDerpHead()
        self:AddTimedCallback(function()  self:GenerateRandomNumberofEggsNearbyDerpHead() end, 5)
        self:AddTimedCallback(function()  self:GenerateRandomNumberofEggsNearbyDerpHead() end, 10)
        self:AddTimedCallback(function()  self:GenerateRandomNumberofEggsNearbyDerpHead() end, 15)
        self:AddTimedCallback(function()  self:GenerateRandomNumberofEggsNearbyDerpHead() end, 20)
        self:AddTimedCallback(function()  self:GenerateRandomNumberofEggsNearbyDerpHead() end, 25)
        self:AddTimedCallback(function()  self:GenerateRandomNumberofEggsNearbyDerpHead() end, 30)
  end
  function Shell:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
function Shell:GenerateRandomNumberofEggsNearbyDerpHead()
    self.shellSpawnPoints = { }
    local minNeighbourDistance = .5
    local maxEggSpawns = math.random(3,6)
    local maxAttempts = maxEggSpawns * 10
    for index = 1, maxAttempts do
    
        // Note: We use kTechId.Skulk here instead of kTechId.Egg because they do not share the same extents.
        // The Skulk is a bit bigger so there are cases where it would find a location big enough for an Egg
        // but too small for a Skulk and the Skulk would be stuck when spawned.
        local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
        local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), .5, 7, EntityFilterAll())
        
        if spawnPoint ~= nil then
            spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
        end
        
        local location = spawnPoint and GetLocationForPoint(spawnPoint)
        local locationName = location and location:GetName() or ""
        
        local sameLocation = spawnPoint ~= nil and locationName == self:GetLocationName()
        
        if spawnPoint ~= nil and sameLocation then
        
            local tooCloseToNeighbor = false
            for _, point in ipairs(self.shellSpawnPoints) do
            
                if (point - spawnPoint):GetLengthSquared() < (minNeighbourDistance * minNeighbourDistance) then
                
                    tooCloseToNeighbor = true
                    break
                    
                end
                
            end
            
            if not tooCloseToNeighbor then
              table.insert(self.shellSpawnPoints, spawnPoint)
                if #self.shellSpawnPoints >= maxEggSpawns then
                    break
                end

                
            end
            
        end
      self:ActuallySpawnEggs()   
    end
end
function Shell:ActuallySpawnEggs()
    if self.shellSpawnPoints == nil or #self.shellSpawnPoints == 0 then
    
        //Print("Can't spawn egg. No spawn points!")
        return nil
        
    end

       local eggCount = 0

    for i = 1, #self.shellSpawnPoints do

        local position = eggCount == 0 and table.random(self.shellSpawnPoints) or self.shellSpawnPoints[i]  

        // Need to check if this spawn is valid for an Egg and for a Skulk because
        // the Skulk spawns from the Egg.
        local validForEgg = GetIsPlacementForTechId(position, true, kTechId.Egg)
        local validForSkulk = GetIsPlacementForTechId(position, true, kTechId.Skulk)

        // Prevent an Egg from spawning on top of a Resource Point.
        local notNearResourcePoint = #GetEntitiesWithinRange("ResourcePoint", position, 2) == 0
        
        if validForEgg and validForSkulk and notNearResourcePoint then
        
            local egg = CreateEntity(Egg.kMapName, position, 2)
            egg:AddTimedCallback(function()  DestroyEntity(egg) end, 120)
            egg:SetHive(self)
            

            if egg ~= nil then
            
                // Randomize starting angles
                local angles = self:GetAngles()
                angles.yaw = math.random() * math.pi * 2
                egg:SetAngles(angles)
                
                // To make sure physics model is updated without waiting a tick
                egg:UpdatePhysicsModel()
                
                self.timeOfLastEgg = Shared.GetTime()
                
                return egg
                
            end
            
        end

    
    end
    
    return nil
    
end
end //ofserver


function Shell:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function Shell:OverrideHintString(hintString)

    if self:GetIsUpgrading() then
        return "COMM_SEL_UPGRADING"
    end
    
    return hintString
    
end


Shared.LinkClassToMap("Shell", Shell.kMapName, networkVars)
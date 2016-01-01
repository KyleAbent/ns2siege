// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Veil.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
//    Alien structure that hosts Veil upgrades. 1 Veil: level 1 upgrade, 2 Veils: level 2 etc.
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
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

Script.Load("lua/RepositioningMixin.lua")

class 'Veil' (ScriptActor)

Veil.kMapName = "veil"

Veil.kModelName = PrecacheAsset("models/alien/veil/veil.model")

Veil.kAnimationGraph = PrecacheAsset("models/alien/veil/veil.animation_graph")

local kLifeSpan = 20 //contamination

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
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
local function TimeUp(self)

    self:Kill()
    return false

end

function Veil:OnCreate()

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
    InitMixin(self, MaturityMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, BiomassMixin)
    
    if Server then
        InitMixin(self, InfestationTrackerMixin)
    elseif Client then
        InitMixin(self, CommanderGlowMixin)    
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    
end

function Veil:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Veil.kModelName, Veil.kAnimationGraph)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, SleeperMixin)
        InitMixin(self, RepositioningMixin)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end

end

function Veil:GetBioMassLevel()
    return kVeilBiomass
end

function Veil:GetReceivesStructuralDamage()
    return true
end

function Veil:GetMaturityRate()
    return kVeilMaturationTime
end

function Veil:GetMatureMaxHealth()
    return kMatureVeilHealth
end 

function Veil:GetMatureMaxArmor()
    return kMatureVeilArmor
end 

function Veil:GetIsWallWalkingAllowed()
    return false
end

function Veil:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function Veil:GetCanSleep()
    return true
end

function Veil:GetIsSmallTarget()
    return true
end

if Server then
function Veil:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
    function Veil:OnConstructionComplete()
     //local isinsiege = string.find(self:GetLocationName(), "Siege") or string.find(self:GetLocationName(), "siege")
     // if not isinsiege then
     //   self:AddTimedCallback(TimeUp, kLifeSpan + 0.5)  
     //   self:TeleportFractionHere()
         self:AddTimedCallback(function()  self:TeleportFractionHere() end, 4)
        self:AddTimedCallback(function()  self:TeleportFractionHere() end, 8)
        self:AddTimedCallback(function()  self:TeleportFractionHere() end, 12)
        self:AddTimedCallback(function()  self:TeleportFractionHere() end, 16)
     // else
          //self:AddTimedCallback(function()  self:TeleportFractionHere() end, 8)
         // self:AddTimedCallback(function()  self:TeleportFractionHere() end, 16)
      //end
    end
    function Veil:TeleportFractionHere()
      local eligable = {}
        
            for _, structure in ipairs(GetEntitiesWithMixinForTeam("Supply", 2)) do
                 if not structure.iscreditstructure and not ( structure.IsInRangeOfHive and structure:IsInRangeOfHive() )
                  and not structure:isa("Drifter") and not structure:isa("DrifterEgg") and not 
                     ( structure.GetIsMoving and structure:GetIsMoving() ) then
                       if structure:GetLocationName() == self:GetLocationName() and self:GetDistance(structure) >= 12 or
                        structure:GetLocationName() ~= self:GetLocationName() and self:GetDistance(structure) <= 25 then 
                          if structure:GetEligableForBeacon() then
                         structure:ClearOrders()
                         structure:GiveOrder(kTechId.Move, self:GetId(), self:GetOrigin(), nil, true, true) 
                         structure.lastbeacontime = Shared.GetTime()
                         end//
                       end//
                       if self:GetDistance(structure) >= 26 and structure:GetIsBuilt() and structure:GetEligableForBeacon()  then
                         table.insert(eligable,structure)
                       end //
                  end //
            end //
                             ///so it takes 4 to get 100%
           if #eligable == 0 then return end
           for i = 1, Clamp(#eligable * 0.25, 1, 4) do
                local entity = eligable[i]
                
                    if HasMixin(entity, "Obstacle") then
                    entity:RemoveFromMesh()
                    end
                    entity:ClearOrders()
                    entity:TriggerBeacon(self:FindFreeSpace())
                entity:AddTimedCallback(function()  entity:InfestationNeedsUpdate() end, 4.5)
                entity:AddTimedCallback(function()  entity:Check() end, 4.5)
                 if HasMixin(entity, "Obstacle") then
                entity:AddTimedCallback(function()  if entity.obstacleId == -1 then entity:AddToMesh() end  end, 8)
                end
            
            end  //
            
            return false
    end //
    function Veil:FindFreeSpace()
    
        for index = 1, 20 do
           local extents = Vector(1,1,1)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), .5, 17, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == self:GetLocationName()
        
           if spawnPoint ~= nil and sameLocation and GetIsPointOnInfestation(spawnPoint) then
           return spawnPoint
           end
       end
           Print("No valid spot found for structure beacon echo!")
           return self:GetOrigin()
    end
    function Veil:OnKill(attacker, doer, point, direction)

        ScriptActor.OnKill(self, attacker, doer, point, direction)
        self:TriggerEffects("death")
        DestroyEntity(self)
    
    end

    function Veil:OnDestroy()
        
      //  local team = self:GetTeam()
      //  if team then
      //      team:OnUpgradeChamberDestroyed(self)
      //  end
        
        ScriptActor.OnDestroy(self)
    
    end   

end

function Veil:GetHealthbarOffset()
    return 1
end

function Veil:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function Veil:OverrideHintString(hintString)

    if self:GetIsUpgrading() then
        return "COMM_SEL_UPGRADING"
    end
    
    return hintString
    
end

Shared.LinkClassToMap("Veil", Veil.kMapName, networkVars)
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Crag.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Alien structure that gives the commander defense and protection abilities.
//
// Passive ability - heals nearby players and structures
// Triggered ability - emit defensive umbra (8 seconds)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/UpgradableMixin.lua")
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
Script.Load("lua/CommanderGlowMixin.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/TargetCacheMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommAbilities/Alien/CragUmbra.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/IdleMixin.lua")

class 'Crag' (ScriptActor)

Crag.kMapName = "crag"

Crag.kModelName = PrecacheAsset("models/alien/crag/crag.model")

Crag.kAnimationGraph = PrecacheAsset("models/alien/crag/crag.animation_graph")

// Same as NS1
Crag.kHealRadius = 14
Crag.kHealAmount = 10
Crag.kHealWaveAmount = 50
Crag.kMaxTargets = 3
Crag.kThinkInterval = .25
Crag.kHealInterval = 2
Crag.kHealEffectInterval = 1

Crag.kHealWaveDuration = 8

Crag.kHealPercentage = 0.06
Crag.kMinHeal = 10
Crag.kMaxHeal = 60
Crag.kHealWaveMultiplier = 1.3

local networkVars =
{
    // For client animations
    healingActive = "boolean",
    healWaveActive = "boolean",
    moving = "boolean",
    lasthealwavetrigger = "time",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(UpgradableMixin, networkVars)
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
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)

function Crag:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, UpgradableMixin)
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
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, TeleportMixin)    
    InitMixin(self, UmbraMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    
    self.healingActive = false
    self.healWaveActive = false
    
    self:SetUpdates(true)
    InitMixin(self, FireMixin)
    
    if Server then
        InitMixin(self, InfestationTrackerMixin)
    elseif Client then    
        InitMixin(self, CommanderGlowMixin)    
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    self.lasthealwavetrigger = 0
end

function Crag:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Crag.kModelName, Crag.kAnimationGraph)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, SleeperMixin)
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SupplyUserMixin)
        
        // TODO: USE TRIGGERS, see shade

        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    InitMixin(self, IdleMixin)
    
end

function Crag:PreventTurning()
    return true
end

function Crag:GetCanReposition()
    return true
end

function Crag:OverrideRepositioningSpeed()
    return kAlienStructureMoveSpeed * 2.5
end  
function Crag:GetIsFlameAble()
    return true
end
function Crag:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end
function Crag:GetCanSleep()
    return not self.healingActive
end

local function GetHealTargets(self)

    local targets = {}
    
    // priority on players
    for _, player in ipairs(GetEntitiesForTeamWithinRange("Player", self:GetTeamNumber(), self:GetOrigin(), Crag.kHealRadius)) do
    
        if player:GetIsAlive() and not player:isa("Commander") then
            table.insert(targets, player)
        end
        
    end

    for _, healable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), Crag.kHealRadius)) do
        
        if healable:GetIsAlive() and not healable:isa("Player") and not healable:isa("Commander") then
            table.insertunique(targets, healable)
        end
        
    end

    return targets

end
function Crag:PerformHealing()

    PROFILE("Crag:PerformHealing")

    local targets = GetHealTargets(self)
    local entsHealed = 0
    
    for _, target in ipairs(targets) do
    
        local healAmount = self:TryHeal(target)
        entsHealed = entsHealed + ((healAmount > 0 and 1) or 0)
        
        if entsHealed >= Crag.kMaxTargets then
            break
        end
    
    end

    if entsHealed > 0 then   
        self.timeOfLastHeal = Shared.GetTime()        
    end
    
end
function Crag:GetCragsInRange()
      local crag = GetEntitiesWithinRange("Crag", self:GetOrigin(), Crag.kHealRadius)
           return Clamp(#crag, 0, self:GetCragStackLevel())
end
function Crag:GetCragStackLevel()
           local teamInfo = GetTeamInfoEntity(2)
           local bioMass = (teamInfo and teamInfo.GetBioMassLevel) and teamInfo:GetBioMassLevel() or 0
           return math.round(bioMass / 4, 1, 3)
end
function Crag:GetArcsInRange()
      local arc= GetEntitiesWithinRange("ARC", self:GetOrigin(), Crag.kHealRadius)
           return Clamp(#arc, 0, 4)
end

  function Crag:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    local NowToHeal = kHealWaveCooldown - (Shared.GetTime() - self.lasthealwavetrigger)
     local InkLength =  math.ceil( Shared.GetTime() + NowToHeal - Shared.GetTime() )
     local time = InkLength
    unitName = string.format(Locale.ResolveString("Crag (%s Stacking) (%s)"), self:GetCragsInRange(),  Clamp(time, 0, kHealWaveCooldown) )
return unitName
end
function Crag:TryHeal(target)

    local unclampedHeal = target:GetMaxHealth() * Crag.kHealPercentage
    local heal = Clamp(unclampedHeal, Crag.kMinHeal, Crag.kMaxHeal) 
       
    if self.healWaveActive then
        heal = heal * Crag.kHealWaveMultiplier
    end
    
    heal = heal * self:GetCragsInRange()/3 + heal
    
    if self:GetIsSiege() and target:isa("Hive") or target:isa("Crag") then
       heal = heal * 1.3
    end
    
    if target:GetHealthScalar() ~= 1 and (not target.timeLastCragHeal or target.timeLastCragHeal + Crag.kHealInterval <= Shared.GetTime()) then
       local amountHealed = target:AddHealth(heal)
       target.timeLastCragHeal = Shared.GetTime()
       
       return amountHealed
    else
        return 0
    end
   
end
function Crag:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)
    if self:GetIsSiege() and attacker:isa("ARC") and attacker:GetIsInSiege() then 
    
          if self:GetIsBuilt() then
          damageTable.damage = 100
          else
          damageTable.damage = 50 //* self.buildFraction
          end
          
    end
end
function Crag:GetIsSiege()
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
function Crag:GetIsSuddenDeath()
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
function Crag:IsInRangeOfHive()
      local hives = GetEntitiesWithinRange("Hive", self:GetOrigin(), Shade.kCloakRadius)
   if #hives >=1 then return true end
   return false
end
function Crag:UpdateHealing()

    local time = Shared.GetTime()
    
    if not self:GetIsOnFire() and ( self.timeOfLastHeal == nil or (time > self.timeOfLastHeal + Crag.kHealInterval) ) then     
        self:PerformHealing()        
    end
    
end

function Crag:GetMaxSpeed()
    return kAlienStructureMoveSpeed
end
// Look for nearby friendlies to heal
function Crag:OnUpdate(deltaTime)

    PROFILE("Crag:OnUpdate")

    ScriptActor.OnUpdate(self, deltaTime)
    
    UpdateAlienStructureMove(self, deltaTime)
    
    
    if Server then
    


        if not self.timeLastCragUpdate then
            self.timeLastCragUpdate = Shared.GetTime()
        end
        
        if self.timeLastCragUpdate + Crag.kThinkInterval < Shared.GetTime() then
        
            if GetIsUnitActive(self) then            
                self:UpdateHealing()                
            end

            self.healingActive = self:GetIsHealingActive()
            self.healWaveActive = self:GetIsHealWaveActive()
            
            self.timeLastCragUpdate = Shared.GetTime()
            
        end
    
    elseif Client then
    
        if self.healWaveActive or self.healingActive then
        
            if not self.lastHealEffect or self.lastHealEffect + Crag.kHealEffectInterval < Shared.GetTime() then
            
                local localPlayer = Client.GetLocalPlayer()
                local showHeal = not HasMixin(self, "Cloakable") or not self:GetIsCloaked() or not GetAreEnemies(self, localPlayer)
        
                if showHeal then
                
                    if self.healWaveActive then
                        self:TriggerEffects("crag_heal_wave")
                    elseif self.healingActive then
                        self:TriggerEffects("crag_heal")
                    end
                    
                end
                
                self.lastHealEffect = Shared.GetTime()
            
            end
            
        end
    
    end
    
end

function Crag:GetTechButtons(techId)

    local techButtons = { kTechId.HealWave, kTechId.Move, kTechId.CragHeal, kTechId.None,
                          kTechId.CragUmbra, kTechId.None, kTechId.None, kTechId.Digest}
    
     if self:GetIsSiege() and self:IsInRangeOfHive() then
    techButtons[1] = kTechId.None
    end
    
    if self.moving then
        techButtons[2] = kTechId.Stop
    end
    
    return techButtons
    
end
function Crag:OnResearchComplete(researchId)

    if researchId == kTechId.Digest then
        self:TriggerEffects("digest", {effecthostcoords = self:GetCoords()} )
        self:Kill()
    end
        
end
function Crag:PerformAction(techNode)

    if techNode:GetTechId() == kTechId.Stop then
        self:ClearOrders()
    end

end

function Crag:OnTeleportEnd()
    self:ResetPathing()
end

function Crag:GetIsHealWaveActive()
    return self:GetIsAlive() and self:GetIsBuilt() and (self.timeOfLastHealWave ~= nil) and (Shared.GetTime() < (self.timeOfLastHealWave + Crag.kHealWaveDuration))
end

function Crag:GetIsHealingActive()
    return self:GetIsAlive() and self:GetIsBuilt() and (self.timeOfLastHeal ~= nil) and (Shared.GetTime() < (self.timeOfLastHeal + Crag.kHealInterval))
end

function Crag:TriggerHealWave(commander)

    self.timeOfLastHealWave = Shared.GetTime()
    return true
    
end

function Crag:GetReceivesStructuralDamage()
    return true
end

function Crag:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    allowed = allowed and not self:GetIsOnFire() and not ( ( self:GetIsSiege() and not self:GetIsSuddenDeath() ) and self:IsInRangeOfHive() )
    
    return allowed, canAfford

end

function Crag:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if techId == kTechId.HealWave then
        success = self:TriggerHealWave(commander)
        self.lasthealwavetrigger = Shared.GetTime()
   elseif  techId == kTechId.CragUmbra then
    success = self:TriggerUmbra()
    end
    
    return success, true
    
end
function Crag:TriggerUmbra()

    CreateEntity(CragUmbra.kMapName,  self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
    self:TriggerEffects("crag_trigger_umbra")
    return true
end
function Crag:OnUpdateAnimationInput(modelMixin)

    PROFILE("Crag:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("heal", self.healingActive or self.healWaveActive)
    modelMixin:SetAnimationInput("moving", self.moving)
    
end
/*
function Crag:GetCanBeUsedConstructed(byPlayer)
return byPlayer:isa("Gorge")
end
function Crag:OnUse(player, elapsedTime, useSuccessTable)

        player:SetHUDSlotActive(2)
        local dropStructureAbility = player:GetWeapon(DropStructureAbility.kMapName)
        if dropStructureAbility then
            dropStructureAbility:SetActiveStructure(7)
        end

              
        if Server then DestroyEntity(self) end
    
end
*/

Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)
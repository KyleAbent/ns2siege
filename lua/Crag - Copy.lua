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
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommAbilities/Alien/CragUmbra.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/BiomassMixin.lua")
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
Crag.MaxLevel = 30
Crag.ScaleSize = 1.3
Crag.GainXP = .7

local networkVars =
{
    // For client animations
    healingActive = "boolean",
    healWaveActive = "boolean",
    
    moving = "boolean",
    level = "float (0 to " .. Crag.MaxLevel .. " by .1)",
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
AddMixinNetworkVars(MaturityMixin, networkVars)
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
    InitMixin(self, MaturityMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, BiomassMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    
    self.healingActive = false
    self.healWaveActive = false
    
    self:SetUpdates(true)
    self.level = 0
    InitMixin(self, FireMixin)
    
    if Server then
        InitMixin(self, InfestationTrackerMixin)
    elseif Client then    
        InitMixin(self, CommanderGlowMixin)    
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)

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

function Crag:GetBioMassLevel()
    return kCragBiomass
end

function Crag:GetCanReposition()
    return true
end

function Crag:OverrideRepositioningSpeed()
    return kAlienStructureMoveSpeed * 2.5
end

function Crag:GetMaturityRate()
    return kCragMaturationTime
end

function Crag:GetMatureMaxHealth()
    return kMatureCragHealth
end

function Crag:GetMatureMaxArmor()
    return kMatureCragArmor
end    

function Crag:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end
function Crag:PreOnKill(attacker, doer, point, direction)
if self.level ~= 1 then self.level = 1 end
end
function Crag:GetCanSleep()
    return not self.healingActive
end

local function GetHealTargets(self)

    local targets = {}
    
    // priority on players
    for _, player in ipairs(GetEntitiesForTeamWithinRange("Player", self:GetTeamNumber(), self:GetOrigin(), Crag.kHealRadius)) do
    
        if player:GetIsAlive() then
            table.insert(targets, player)
        end
        
    end

    for _, healable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), Crag.kHealRadius)) do
        
        if healable:GetIsAlive() then
            table.insertunique(targets, healable)
        end
        
    end

    return targets

end
function Crag:GetLevelPercentage()
return self.level / Crag.MaxLevel * Crag.ScaleSize
end
function Crag:GetMaxLevel()
return Crag.MaxLevel
end
function Crag:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
    if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end
function Crag:PerformHealing()

    PROFILE("Crag:PerformHealing")

    local targets = GetHealTargets(self)
    local entsHealed = 0
    
    for _, target in ipairs(targets) do
    
        local healAmount = self:TryHeal(target)
        entsHealed = entsHealed + ((healAmount > 0 and 1) or 0)
        local targets = math.round(Crag.kMaxTargets + (self.level/100) * Crag.kMaxTargets)
        if entsHealed >= targets then
            break
        end
    
    end

    if entsHealed > 0 then   
        self.timeOfLastHeal = Shared.GetTime()
        self:AddXP(Crag.GainXP)        
    end
    
end
function Crag:GetAddXPAmount()
return Crag.GainXP
end
function Crag:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, Crag.MaxLevel - self.level)
        self.level = self.level + xpReward
   
    return xpReward
    
end
function Crag:TryHeal(target)

    local unclampedHeal = (target:GetMaxHealth() * Crag.kHealPercentage) * (self.level/100) + target:GetMaxHealth() * Crag.kHealPercentage
    local heal = Clamp(unclampedHeal, Crag.kMinHeal, Crag.kMaxHeal) 
    
    if self.healWaveActive then
        heal = heal * Crag.kHealWaveMultiplier
    end
    
    if target:GetHealthScalar() ~= 1 and (not target.timeLastCragHeal or target.timeLastCragHeal + (Crag.kHealInterval - (self.level/100) * Crag.kHealInterval) <= Shared.GetTime()) then
    
        local amountHealed = target:AddHealth(heal)
        target.timeLastCragHeal = Shared.GetTime()
        return amountHealed
        
    else
        return 0
    end
    
end

function Crag:UpdateHealing()

    local time = Shared.GetTime()
    
    if not self:GetIsOnFire() and ( self.timeOfLastHeal == nil or (time > self.timeOfLastHeal + (Crag.kHealInterval - (self.level/100) * 2) ) ) then    
        self:PerformHealing()        
    end
    
end

function Crag:GetMaxSpeed()
    return kAlienStructureMoveSpeed
end
function Crag:GetLevel()
        return Round(self.level, 2)
end
function Crag:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Level %s Crag"), self:GetLevel())
return unitName
end
// Look for nearby friendlies to heal
function Crag:OnUpdate(deltaTime)

    PROFILE("Crag:OnUpdate")

    ScriptActor.OnUpdate(self, deltaTime)
    
    UpdateAlienStructureMove(self, deltaTime)
    
    if self.CheckModelCoords == nil or (Shared.GetTime() > self.CheckModelCoords + 30) then
    self:UpdateModelCoords()
    self:UpdatePhysicsModel()
    if (self._modelCoords and self.boneCoords and self.physicsModel) then
    self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
    end      
    self.CheckModelCoords = Shared.GetTime()
    end
    
    if Server then
    
       if self:GetIsMature() then
       self:AdjustMaxHealth(kMatureCragHealth * (self.level/100) + kMatureCragHealth) 
       self:AdjustMaxArmor(kMatureCragArmor * (self.level/100) + kMatureCragArmor)
       end
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
                          kTechId.CragUmbra, kTechId.None, kTechId.None, kTechId.None }
    
    if self.moving then
        techButtons[2] = kTechId.Stop
    end
    
    return techButtons
    
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
    allowed = allowed and not self:GetIsOnFire()
    
    return allowed, canAfford

end

function Crag:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if techId == kTechId.HealWave then
        success = self:TriggerHealWave(commander)
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

function Crag:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end


Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)
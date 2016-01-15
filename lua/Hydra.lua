// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Hydra.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Structure droppable by Gorge that attacks enemy targets with clusters of shards. Can be built
// on walls.
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
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/TargetCacheMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/ClogFallMixin.lua")
Script.Load("lua/DigestMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/TriggerMixin.lua")
Script.Load("lua/TargettingMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/IdleMixin.lua")

class 'Hydra' (ScriptActor)

Hydra.kMapName = "hydra"

Hydra.kModelName = PrecacheAsset("models/alien/hydra/hydra.model")
Hydra.kModelNameShadow = PrecacheAsset("models/alien/hydra/hydra_shadow.model")
Hydra.kAnimationGraph = PrecacheAsset("models/alien/hydra/hydra.animation_graph")

Hydra.kSpikeSpeed = 250
Hydra.kSpread = Math.Radians(8)
Hydra.kTargetVelocityFactor = 0.10 // Increase this to overshoot fast moving targets (jetpackers).
Hydra.kRange = 17.78              // From NS1 (also "alert" range)
Hydra.kDamage = kHydraDamage
Hydra.kAlertCheckInterval = 2

Hydra.MaxLevel = 99
Hydra.ScaleSize = 2
Hydra.GainXP = 1

Hydra.kFov = 360

kHydraDigestDuration = 1

if Server then
    Script.Load("lua/Hydra_Server.lua")
end

local networkVars =
{
    alerting = "boolean",
    attacking = "boolean",
    hydraParentId = "entityid",
    level = "float (0 to " .. Hydra.MaxLevel .. " by .1)",
}

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
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(TeleportMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)

function Hydra:OnCreate()

    ScriptActor.OnCreate(self)

    if Server then

        InitMixin(self, ClogFallMixin)

    end
    
    InitMixin(self, DigestMixin)
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
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, TeleportMixin)
    InitMixin(self, UmbraMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DissolveMixin)
    InitMixin(self, CatalystMixin)
    
    self.alerting = false
    self.attacking = false
    self.hydraParentId = Entity.invalidI
    
    if Server then
        InitMixin(self, InfestationTrackerMixin)
    end
    self.level = 1
end

function Hydra:OnInitialized()

    if Server then
    
        ScriptActor.OnInitialized(self)
        
        self:SetModel(Hydra.kModelName, Hydra.kAnimationGraph)
       
        self:SetUpdates(true)
        
        // TargetSelectors require the TargetCacheMixin for cleanup.
        InitMixin(self, TargetCacheMixin)
        
        self.targetSelector = TargetSelector():Init(
                self,
                Hydra.kRange * (self.level/100) + Hydra.kRange, 
                true,
                { kAlienStaticTargets, kAlienMobileTargets }, { self.FilterTarget(self) } )   
        
        
        InitMixin(self, SleeperMixin)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        self:TriggerEffects("spawn", {effecthostcoords = self:GetCoords()} )
        
        InitMixin(self, StaticTargetMixin)
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
    InitMixin(self, IdleMixin)
    
end
function Hydra:FilterTarget()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end
function Hydra:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("FuncDoor") and target.health == 0 then
    return false
    end
    
    return true
    
end
function Hydra:GetBarrelPoint()
    return self:GetEyePos()
end

function Hydra:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if Client then
    
        Client.DestroyRenderDecal(self.decal)
        self.decal = nil
        
    end
    
end

function Hydra:SetVariant(gorgeVariant)

    if gorgeVariant == kGorgeVariant.shadow then
        self:SetModel(Hydra.kModelNameShadow, Hydra.kAnimationGraph)
    else
        self:SetModel(Hydra.kModelName, Hydra.kAnimationGraph)
    end
    
end
function Hydra:GetLevelPercentage()
return self.level / Hydra.MaxLevel * Hydra.ScaleSize
end
function Hydra:GetMaxLevel()
return Hydra.MaxLevel
end
function Hydra:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end
function Hydra:GetAddXPAmount()
return self:GetIsSetup() and Hydra.GainXP * 4 or Hydra.GainXP
end
function Hydra:GetIsSetup()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and not gameRules:GetFrontDoorsOpen() then 
                   return true
               end
            end
        end
            return false
end
function Hydra:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, Hydra.MaxLevel - self.level)
        self.level = self.level + xpReward
   
      
   // self:AdjustMaxHealth(kHydraHealth * (self.level/100) + kHydraHealth) 
   // self:AdjustMaxArmor(kHydraArmor * (self.level/100) + kHydraArmor)
    
    return xpReward
    
end
function Hydra:GetLevel()
        return Round(self.level, 2)
end
  function Hydra:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Level %s Hydra"), self:GetLevel())
return unitName
end 
function Hydra:GetIsFlameAble()
    return true
end

function Hydra:GetCanDie(byDeathTrigger)
    return not byDeathTrigger
end

function Hydra:GetCanAutoBuild()
    return self:GetGameEffectMask(kGameEffect.OnInfestation)
end

function Hydra:GetShowHitIndicator()
    return true
end

function Hydra:GetDeathIconIndex()
    return kDeathMessageIcon.HydraSpike
end

function Hydra:OnClogFallDone(isAttached, normal)

    if not isAttached then
    
        local coords = self:GetCoords()
        coords.yAxis = normal
        coords.xAxis = coords.yAxis:CrossProduct( coords.zAxis )
        coords.zAxis = coords.xAxis:CrossProduct( coords.yAxis )
        self:SetCoords(coords)
        
    end

end

function Hydra:GetTracerEffectName()
    return kSpikeTracerEffectName
end

function Hydra:GetTracerResidueEffectName()
    return kSpikeTracerResidueEffectName
end

function Hydra:GetReceivesStructuralDamage()
    return true
end

function Hydra:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function Hydra:GetCanSleep()
    return not self.alerting and not self.attacking
end

function Hydra:GetMinimumAwakeTime()
    return 10
end

function Hydra:GetFov()
    return Hydra.kFov
end

/**
 * Note: The Hydra must be built to digest it because otherwise the
 * "use" button will be displayed and a new Gorge will attempt to
 * build it by "using" which will cause it to be destroyed.
 */
function Hydra:GetCanDigest(player)

    return player:GetIsAlive() and player:GetId() == self.hydraParentId and
            self:GetIsAlive() and self:GetIsBuilt()
    
end

function Hydra:GetDigestDuration()
    return kHydraDigestDuration
end
 
function Hydra:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = useSuccessTable.useSuccess and self:GetCanDigest(player)    
end

function Hydra:GetCanBeUsedConstructed()
    return true
end    

function Hydra:GetEyePos()
    return self:GetOrigin() + self:GetViewOffset()
end

/**
 * Put the eye up roughly 100 cm.
 */
function Hydra:GetViewOffset()
    return self:GetCoords().yAxis * 1
end

function Hydra:GetCanGiveDamageOverride()
    return true
end

function Hydra:OnUpdateAnimationInput(modelMixin)

    PROFILE("Hydra:OnUpdateAnimationInput")

    modelMixin:SetAnimationInput("attacking", self.attacking)
    modelMixin:SetAnimationInput("alerting", self.alerting)
    
end

function Hydra:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, 0.4, 0)
end

function Hydra:OnUpdateRender()

    local showDecal = self:GetIsVisible() and not self:GetIsCloaked()

    if not self.decal and showDecal then
        self.decal = CreateSimpleInfestationDecal(0.9, self:GetCoords())
    elseif self.decal and not showDecal then
        Client.DestroyRenderDecal(self.decal)
        self.decal = nil
    end

end

Shared.LinkClassToMap("Hydra", Hydra.kMapName, networkVars)
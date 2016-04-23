--Kyle Abent
--modified by
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/DoorMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/UpgradableMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/MobileTargetMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/WebableMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")

class 'ARC' (ScriptActor)

ARC.kMapName = "arc"

ARC.kModelName = PrecacheAsset("models/marine/arc/arc.model")
local kAnimationGraph = PrecacheAsset("models/marine/arc/arc.animation_graph")


ARC.kHealth                 = kARCHealth
ARC.kStartDistance          = 4
ARC.kAttackDamage           = kARCDamage
ARC.kFireRange              = kARCRange         // From NS1
ARC.kMinFireRange           = kARCMinRange
ARC.kSplashRadius           = 7
ARC.kUpgradedSplashRadius   = 13
ARC.kMoveSpeed              = 2.0
ARC.kCombatMoveSpeed        = 0.8
ARC.kFov                    = 360
ARC.kCapsuleHeight = .05
ARC.kCapsuleRadius = .5
ARC.MaxLevel = 90
ARC.GainXP = 2.64
ARC.ScaleSize = 1.3
ARC.MaxDmgBonus = 2

ARC.kMode = enum( {'Stationary', 'Moving', 'Targeting', 'Destroyed'} )

if Server then
    Script.Load("lua/ARC_Server.lua")
end

local networkVars =
{
    mode = "enum ARC.kMode",
    level = "float (0 to " .. ARC.MaxLevel .. " by .1)",
    --dmgbonus = "float (1 to " .. ARC.MaxDmgBonus .. " by .10)",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(UpgradableMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(WebableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)

function ARC:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, DoorMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, UpgradableMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, SelectableMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, WebableMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, GhostStructureMixin)
    
    if Server then
    
        InitMixin(self, SleeperMixin)
        
        
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
    end
   
    
    self:SetLagCompensated(true)
    self.level = 0
    --self.dmgbonus = 1

end

function ARC:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(ARC.kModelName, kAnimationGraph)
    
    if Server then
    
        local angles = self:GetAngles()
        self.desiredPitch = angles.pitch
        self.desiredRoll = angles.roll
    
        InitMixin(self, MobileTargetMixin)
   
        self:SetPhysicsType(PhysicsType.Kinematic)
        
        // Cannons start out mobile
        self:SetMode(ARC.kMode.Stationary)
        
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
 
     /*
         if (self:GetIsSiegeEnabled() and self:GetIsInSiege()) then
           if self:GetArcsInSiege() > 1 then
           self:SetSiegeArcDmgBonus(-0.10)
           end
        end
        */

    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
    
    end
    
    self:SetUpdates(true)
    
    InitMixin(self, IdleMixin)

    
end

function ARC:GetHealthbarOffset()
    return 0.7
end 

function ARC:GetPlayIdleSound()
    return false
end

function ARC:GetReceivesStructuralDamage()
    return true
end

function ARC:GetCanSleep()
    return self.mode == ARC.kMode.Stationary
end

function ARC:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end

/**
 * Put the eye up 1 m.
 */
function ARC:GetViewOffset()
    return self:GetCoords().yAxis * 1.0
end

function ARC:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)
local damage = 1
    if doer:isa("DotMarker") or doer:isa("Gore") then
       damage = damage - (self:GetDamageResistance()/100) * damage
    end
  damageTable.damage = damageTable.damage * damage 
end
function ARC:GetDamageResistance()
return self.level
end
function ARC:GetEyePos()
    return self:GetOrigin() + self:GetViewOffset()
end
function ARC:GetLevelPercentage()
return self.level / ARC.MaxLevel * ARC.ScaleSize
end
function ARC:GetMaxLevel()
return ARC.MaxLevel
end
/*
function ARC:OnAdjustModelCoords(modelCoords)
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
function ARC:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, ARC.MaxLevel - self.level)
        self.level = self.level + xpReward
        
        self:AdjustMaxArmor(kARCArmor * (self.level/100) + kARCArmor)
        
   
    return xpReward
    
end
/*
function ARC:GetCanDieOverride() 
return false
end
*/
function ARC:GetArcsInRange()
      local arc = GetEntitiesWithinRange("ARC", self:GetOrigin(), ARC.kFireRange)
           return Clamp(#arc, 0, 100)
end
function ARC:GetArcsInSiege()
 local count = 0
      local arc = GetEntitiesWithinRange("ARC", self:GetOrigin(), 999999)
      if #arc == 0 then return end
       for i = 1, #arc do
         local entity = arc[i]
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        if string.find(locationName, "siege") or string.find(locationName, "Siege") then
           count = count + 1
         end
       end
           return count
end
function ARC:GetLevel()
        return Round(self.level, 2)
end
  function ARC:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
      //  if self.health == 0 then
            --unitName = string.format(Locale.ResolveString("ALIEN HIJACKED ARC"))
      //  else
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        if string.find(locationName, "siege") or string.find(locationName, "Siege") then
        unitName = string.format(Locale.ResolveString("Siege ARC (%s) (%s)"), self:GetLevel(), self:GetArcsInSiege() ) --, self.dmgbonus )
        else
        unitName = string.format(Locale.ResolveString("ARC (%s) (%s)"), self:GetLevel(), self:GetArcsInRange(), math.round(self:GetDamageResistance(),1))
        end
   //end
return unitName
end 
function ARC:GetInAttackMode()
    return true
end

function ARC:GetCanGiveDamageOverride()
    return not self:GetIsVortexed()
end

function ARC:GetFov()
    return ARC.kFov
end

function ARC:GetEffectParams(tableParams)
    tableParams[kEffectFilterDeployed] = self:GetInAttackMode()
end

function ARC:FilterTarget()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end

//
// Do a complete check if the target can be fired on. 
//
function ARC:GetCanFireAtTarget(target)    

    if target == nil then        
        return false
    end
    
    if not self:GetIsBuilt() then 
     return false
     end
    
    if not HasMixin(target, "Live") or not target:GetIsAlive() then
        return false
    end
    
    if not GetAreEnemies(self, target) then        
        return false
    end
    
    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
    
    // don't target eggs (they take only splash damage)
    if target:isa("Egg") or target:isa("Cyst") then
        return false
    end
        local gameRules = GetGamerules()
       if (gameRules:GetGameStarted() and not gameRules:GetFrontDoorsOpen()) or  self:GetIsVortexed() then return false end
    return self:GetCanFireAtTargetActual(target) 
    
end

function ARC:GetCanFireAtTargetActual(target, targetPoint)    

    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
    local gameRules = GetGamerules()
    if ( gameRules:GetGameStarted() and not gameRules:GetFrontDoorsOpen() ) or  self:GetIsVortexed() then return false end
    
    // don't target eggs (they take only splash damage)
    if target:isa("Egg") or target:isa("Cyst") then
        return false
    end
    if not target:GetIsSighted() and not GetIsTargetDetected(target) then
        return false
    end
  if  not (self:GetIsSiegeEnabled() and self:GetIsInSiege() ) then
  
    local distToTarget = (target:GetOrigin() - self:GetOrigin()):GetLengthXZ()
    if (distToTarget > ARC.kFireRange) or (distToTarget < ARC.kMinFireRange) then
        return false
    end
    
   end 
    return true
    
end
function ARC:GetGainXPAmount()
local amount =  ARC.GainXP
  if self:GetIsSiegeEnabled() and self:GetIsInSiege() then
     amount = amount * 2 
  end

  return amount

end
function ARC:OnUpdate(deltaTime)

    PROFILE("ARC:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)
    
    if Server then
    
         /*
      
            if self.Levelslowly == nil or (Shared.GetTime() > self.Levelslowly + 4) then
            self:AddXP(self:GetGainXPAmount())
            self.Levelslowly = Shared.GetTime()
            end
        */

    end
  
    
end

function ARC:OnModeChangedClient(oldMode, newMode)

    if oldMode == ARC.kMode.Targeting and newMode ~= ARC.kMode.Targeting then
        self:TriggerEffects("arc_stop_effects")
    end

end

function ARC:OnKill(attacker, doer, point, direction)

    self:TriggerEffects("arc_stop_effects")
    
    if Server then
    
        self:ClearOrders()
        
        self:SetMode(ARC.kMode.Destroyed)
        /*
        if (self:GetIsSiegeEnabled() and self:GetIsInSiege()) then
          self:SetSiegeArcDmgBonus(0.10)
        end
        */
    end 
  
end
/*
function ARC:AddDmgBonus(amount)
    local dmgReward = 0
        dmgReward = math.min(amount, ARC.MaxDmgBonus - self.dmgbonus)
        self.dmgbonus = self.dmgbonus + dmgReward     
    return dmgReward
end
*/
function ARC:OnUpdateAnimationInput(modelMixin)

    PROFILE("ARC:OnUpdateAnimationInput")
    
    local activity = "none"
    if self.mode == ARC.kMode.Targeting then
        activity = "primary"
    end
    modelMixin:SetAnimationInput("activity", activity)
    
    modelMixin:SetAnimationInput("deployed", true)
end

function ARC:GetShowHitIndicator()
    return true
end




Shared.LinkClassToMap("ARC", ARC.kMapName, networkVars, true)
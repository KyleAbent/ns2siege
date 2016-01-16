// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Shade.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Alien structure that provides cloaking abilities and confuse and deceive capabilities.
//
// Disorient (Passive) - Enemy structures and players flicker in and out when in range of Shade, 
// making it hard for Commander and team-mates to be able to support each other. Extreme reverb 
// sounds for enemies (and slight reverb sounds for friendlies) enhance the effect.
//
// Cloak (Triggered) - Instantly cloaks self and all enemy structures and aliens in range
// for a short time. Mutes or changes sounds too? Cleverly used, this would ideally allow a 
// team to get a stealth hive built. Allow players to stay cloaked for awhile, until they attack
// (even if they move out of range - great for getting by sentries).
//
// Hallucination - Allow Commander to create fake Fade, Onos, Hive (and possibly 
// ammo/medpacks). They can be pathed around and used to create tactical distractions or divert 
// forces elsewhere.
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
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/CommAbilities/Alien/ShadeInk.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/TriggerMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/IdleMixin.lua")

class 'Shade' (ScriptActor)

Shade.kMapName = "shade"

Shade.kModelName = PrecacheAsset("models/alien/shade/shade.model")
Shade.kAnimationGraph = PrecacheAsset("models/alien/shade/shade.animation_graph")

local kCloakTriggered = PrecacheAsset("sound/NS2.fev/alien/structures/shade/cloak_triggered")
local kCloakTriggered2D = PrecacheAsset("sound/NS2.fev/alien/structures/shade/cloak_triggered_2D")

Shade.kCloakRadius = 17

Shade.kCloakUpdateRate = 0.2

Shade.MaxLevel = 99
Shade.ScaleSize = 2
Shade.GainXP = 1

local networkVars = { 
    moving = "boolean",
    lastinktrigger = "time",
    level = "float (0 to " .. Shade.MaxLevel .. " by .1)",
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
        
function Shade:OnCreate()

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
    InitMixin(self, FireMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, TeleportMixin)
    InitMixin(self, UmbraMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    
    if Server then
    
        //InitMixin(self, TriggerMixin, {kPhysicsGroup = PhysicsGroup.TriggerGroup, kFilterMask = PhysicsMask.AllButTriggers} )    
        InitMixin(self, InfestationTrackerMixin)
    elseif Client then
        InitMixin(self, CommanderGlowMixin)            
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    self.lastinktrigger = 0
    self.level = 1

end

function Shade:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Shade.kModelName, Shade.kAnimationGraph)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SupplyUserMixin)

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


function Shade:OverrideRepositioningSpeed()
    return kAlienStructureMoveSpeed * 2.5
end

function Shade:PreventTurning()
    return true
end


function Shade:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function Shade:GetCanDie(byDeathTrigger)
    return not byDeathTrigger
end

function Shade:GetTechButtons(techId)

    local techButtons = { kTechId.ShadeInk, kTechId.Move, kTechId.ShadeCloak, kTechId.None, 
                          kTechId.None, kTechId.None, kTechId.None, kTechId.Digest }
                      
    if self:GetIsSiege() and self:IsInRangeOfHive() then
    techButtons[1] = kTechId.None
    end
    
    if self.moving then
        techButtons[2] = kTechId.Stop
    end                      

    return techButtons
    
end
function Shade:PerformAction(techNode)

    if techNode:GetTechId() == kTechId.Stop then
        self:ClearOrders()
    end

end
function Shade:GetAddXPAmount()
return self:GetIsSetup() and Shade.GainXP * 4 or Shade.GainXP
end
function Shade:GetIsSetup()
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
function Shade:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, Shade.MaxLevel - self.level)
        self.level = self.level + xpReward
   
      
   // self:AdjustMaxHealth(kHydraHealth * (self.level/100) + kHydraHealth) 
   // self:AdjustMaxArmor(kHydraArmor * (self.level/100) + kHydraArmor)
    
    return xpReward
    
end
function Shade:GetLevel()
        return Round(self.level, 2)
end

function Shade:OnResearchComplete(researchId)

    // Transform into mature shade
    if researchId == kTechId.EvolveHallucinations then
        success = self:GiveUpgrade(kTechId.ShadePhantomMenu)
    elseif researchId == kTechId.Digest then
        self:TriggerEffects("digest", {effecthostcoords = self:GetCoords()} )
        self:Kill()
    end
    
end

function Shade:TriggerInk()

  if Server then
    // Create ShadeInk entity in world at this position with a small offset
    CreateEntity(ShadeInk.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
  end
  
    self:TriggerEffects("shade_ink")
    self.lastinktrigger = Shared.GetTime()
    return true

end
function Shade:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if techId == kTechId.ShadeInk then
        success = self:TriggerInk()
    end
    
    return success, true
    
end

function Shade:GetReceivesStructuralDamage()
    return true
end

function Shade:OnUpdateAnimationInput(modelMixin)

    PROFILE("Shade:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("cloak", true)
    modelMixin:SetAnimationInput("moving", self.moving)
    
end

function Shade:GetMaxSpeed()
    return kAlienStructureMoveSpeed
end

function Shade:OnTeleportEnd()
    self:ResetPathing()
end

function Shade:GetCanReposition()
    return true
end

if Server then

    function Shade:OnConstructionComplete()    
             local commander = self:GetTeam():GetCommander()
       if commander ~= nil then
       commander:AddScore(1) 
       end
        self:AddTimedCallback(Shade.UpdateCloaking, Shade.kCloakUpdateRate)    
     //   self:AddTimedCallback(Shade.UpdatePassive, self:GetCoolDown())
    end
    /*
    function Shade:UpdatePassive(deltaTime)
        if not self:GetIsOnFire() and self:GetIsSiege() and GetHasTech(self, kTechId.ShadeHive) and self:IsInRangeOfHive() then self:PerformActivation(kTechId.ShadeInk, nil, normal, commander) self:TellOtherShadesToAbide() end
                return self:GetIsAlive()
    end
    */
    function Shade:UpdateCloaking()
    
        if not self:GetIsOnFire() then
            for _, cloakable in ipairs( GetEntitiesWithMixinForTeamWithinRange("Cloakable", self:GetTeamNumber(), self:GetOrigin(), Shade.kCloakRadius) ) do
                cloakable:TriggerCloak()
            end
        end
        
        return self:GetIsAlive()
    
    end

end
/*
function Shade:TellOtherShadesToAbide()

            for _, Shade in ipairs( GetEntitiesWithMixinForTeamWithinRange("Shade", self:GetTeamNumber(), self:GetOrigin(), Shade.kCloakRadius) ) do
                Shade.lastinktrigger = Shared.GetTime()
            end
            
       
end
*/
function Shade:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end
function Shade:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    allowed = allowed and not self:GetIsOnFire()  and not ( ( self:GetIsSiege() and not self:GetIsSuddenDeath() ) and self:IsInRangeOfHive() )
    
    return allowed, canAfford
    
end
function Shade:OnUpdate(deltaTime)
    ScriptActor.OnUpdate(self, deltaTime)        
    UpdateAlienStructureMove(self, deltaTime)
        if Server then
    
            if self.Levelslowly == nil or (Shared.GetTime() > self.Levelslowly + 4) then
            self:AddXP(Shade.GainXP * 4)
            self.Levelslowly = Shared.GetTime()
            end
    
    end
    
end
function Shade:OnScan()
               
     if self:GetIsBuilt() and not self:GetIsOnFire() and self:GetCanTrigger() then
                 local number = math.random(self.level, 100)
                 if number >= 99 then self:TriggerInk() end
     end     
                 
    self:TriggerUncloak()
    
end
function Shade:GetCanTrigger()
  for _, Shade in ipairs(GetEntitiesForTeamWithinRange("Shade", self:GetTeamNumber(), self:GetOrigin(), Shade.kCloakRadius)) do
               if not (Shade.lastinktrigger + kShadeInkCooldown) > Shared.GetTime() then 
                return false
                end
          end
         return true 

end
function Shade:IsInRangeOfHive()
      local hives = GetEntitiesWithinRange("Hive", self:GetOrigin(), Shade.kCloakRadius)
   if #hives >=1 then return true end
   return false
end
function Shade:GetIsSiege()
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
function Shade:GetIsSuddenDeath()
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

  function Shade:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    --Kyle Abent :) Original writings! Wooo! who woulda thunk it? eh?. well you know it plays out fun, so who knows. May be onto somethin here.. ;)
  //  if self:GetIsSiege() then //and not self:GetCanAutomaticTriggerInkAgain() then
     local NowToInk = self:GetCoolDown() - (Shared.GetTime() - self.lastinktrigger)
     local InkLength =  math.ceil( Shared.GetTime() + NowToInk - Shared.GetTime() )
     local time = InkLength
     unitName = string.format(Locale.ResolveString("Level %s Shade (%s)"), self:GetLevel(), Clamp(time, 0, self:GetCoolDown()))
  //  end
 
return unitName
end 
function Shade:GetCoolDown()
    return kShadeInkCooldown
end
function Shade:GetHasShadeHive()
      local shadehive = GetEntitiesWithinRange("ShadeHive", self:GetOrigin(), 999999)
           if #shadehive >=1 then return true end
           return false
end

Shared.LinkClassToMap("Shade", Shade.kMapName, networkVars)
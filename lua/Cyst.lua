// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Cyst.lua
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
// A cyst controls and spreads infestation
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/SpawnBlockMixin.lua")
Script.Load("lua/IdleMixin.lua")

Script.Load("lua/CommAbilities/Alien/EnzymeCloud.lua")
Script.Load("lua/CommAbilities/Alien/Rupture.lua")

class 'Cyst' (ScriptActor)

Cyst.kMaxEncodedPathLength = 30
Cyst.kMapName = "cyst"
Cyst.kModelName = PrecacheAsset("models/alien/cyst/cyst.model")

Cyst.kAnimationGraph = PrecacheAsset("models/alien/cyst/cyst.animation_graph")

Cyst.kEnergyCost = 25
Cyst.kPointValue = 5
// how fast the impulse moves
Cyst.kImpulseSpeed = 8

Cyst.kThinkInterval = 1 
Cyst.kImpulseColor = Color(1,1,0)
Cyst.kImpulseLightIntensity = 8
local kImpulseLightRadius = 1.5

Cyst.kExtents = Vector(0.2, 0.1, 0.2)

Cyst.kBurstDuration = 3

// range at which we can be a parent
Cyst.kCystMaxParentRange = kCystMaxParentRange

// size of infestation patch
Cyst.kInfestationRadius = kInfestationRadius
Cyst.kInfestationGrowthDuration = Cyst.kInfestationRadius / kCystInfestDuration

local networkVars =
{

    // Since cysts don't move, we don't need the fields to be lag compensated
    // or delta encoded
    m_origin = "position (by 0.05 [], by 0.05 [], by 0.05 [])",
    m_angles = "angles (by 0.1 [], by 10 [], by 0.1 [])",
    
    // Cysts are never attached to anything, so remove the fields inherited from Entity
    m_attachPoint = "integer (-1 to 0)",
    m_parentId = "integer (-1 to 0)",
    
    // Track our parentId
    parentId = "entityid",
    hasChild = "boolean",
    

}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(PointGiverMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)

if Server then
    Script.Load("lua/Cyst_Server.lua")
end

function Cyst:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, UmbraMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, CloakableMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, DetectableMixin)
    
    if Server then
    
        InitMixin(self, SpawnBlockMixin)
        self:UpdateIncludeRelevancyMask()
        
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
    end

    self:SetPhysicsCollisionRep(CollisionRep.Move)
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
    self:SetLagCompensated(false)
    self.parentId = Entity.invalidId
end


function Cyst:GetShowSensorBlip()
    return false
end


function Cyst:OnInitialized()

    InitMixin(self, InfestationMixin)
    
    ScriptActor.OnInitialized(self)
    


    if Server then
        InitMixin(self, SleeperMixin)
        InitMixin(self, StaticTargetMixin)
        
        self:SetModel(Cyst.kModelName, Cyst.kAnimationGraph)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then    
    
        InitMixin(self, UnitStatusMixin)
        self:AddTimedCallback(Cyst.OnTimedUpdate, 0)
        // note that even though a Client side cyst does not do OnUpdate, its mixins (cloakable mixin) requires it for
        // now. If we can change that, then cysts _may_ be able to skip OnUpdate
         
    end   
    
    
    InitMixin(self, IdleMixin)
    
end

function Cyst:GetPlayIdleSound()
    return self:GetIsBuilt() and self:GetCurrentInfestationRadiusCached() < 1
end



function Cyst:GetInfestationGrowthRate()
    return Cyst.kInfestationGrowthDuration
end

function Cyst:GetHealthbarOffset()
    return 0.5
end 

/**
 * Infestation never sights nearby enemy players.
 */
function Cyst:OverrideCheckVision()
    return false
end

function Cyst:GetIsFlameAble()
    return true
end
function Cyst:GetCanSleep()
    return true
end    

function Cyst:GetTechButtons(techId)
  
    return  { kTechId.Infestation,  kTechId.None, kTechId.None, kTechId.None,
              kTechId.None, kTechId.None, kTechId.None, kTechId.None }

end

function Cyst:GetInfestationRadius()
    return kInfestationRadius
end

function Cyst:GetInfestationMaxRadius()
    return kInfestationRadius
end


function Cyst:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end




function Cyst:OnOverrideSpawnInfestation(infestation)

    infestation.maxRadius = kInfestationRadius
    // New infestation starts partially built, but this allows it to start totally built at start of game 
    local radiusPercent = math.max(infestation:GetRadius(), .2)
    infestation:SetRadiusPercent(radiusPercent)
    
end

function Cyst:GetReceivesStructuralDamage()
    return true
end

local function ServerUpdate(self, deltaTime)

    if not self:GetIsAlive() then
        return
    end
    
    if self.bursted then    
        self.bursted = self.timeBursted + Cyst.kBurstDuration > Shared.GetTime()    
    end
    
end


if Server then
  
    function Cyst:OnUpdate(deltaTime)

        PROFILE("Cyst:OnUpdate")
        
        ScriptActor.OnUpdate(self, deltaTime)
        
        if self:GetIsAlive() then
            
            ServerUpdate(self, deltaTime)
               
        else
        
            local destructionAllowedTable = { allowed = true }
            if self.GetDestructionAllowed then
                self:GetDestructionAllowed(destructionAllowedTable)
            end
            
            if destructionAllowedTable.allowed then
                DestroyEntity(self)
            end
        
        end
        
    end
    
elseif Client then
    
    // avoid using OnUpdate for cysts, instead use a variable timed callback
    function Cyst:OnTimedUpdate(deltaTime)
      
      PROFILE("Cyst:OnTimedUpdate")
      return kUpdateIntervalLow
      
    end

end

function Cyst:GetIsHealableOverride()
  return self:GetIsAlive() 
end



function Cyst:SetIncludeRelevancyMask(includeMask)

    includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)    
    ScriptActor.SetIncludeRelevancyMask(self, includeMask)    

end


Shared.LinkClassToMap("Cyst", Cyst.kMapName, networkVars)
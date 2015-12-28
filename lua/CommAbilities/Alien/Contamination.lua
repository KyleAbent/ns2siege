// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Contamination.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Creates temporary infestation.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/SelectableMixin.lua")
//Script.Load("lua/MapBlipMixin.lua")

class 'Contamination' (ScriptActor)

Contamination.kMapName = "contamination"

Contamination.kModelName = PrecacheAsset("models/alien/contamination/contamination.model")
local kAnimationGraph = PrecacheAsset("models/alien/contamination/contamination.animation_graph")

local kContaminationSpreadEffect = PrecacheAsset("cinematics/alien/contamination_spread.cinematic")

local kLifeSpan = 20
local kPhysicsRadius = 0.67

local networkVars =
{
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)

local function TimeUp(self)

    self:Kill()
    return false

end

function Contamination:OnCreate()

    ScriptActor.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, IdleMixin)
    InitMixin(self, SelectableMixin)

    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)

          if Server and not Shared.GetCheatsEnabled() then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and not gameRules:GetFrontDoorsOpen() then 
               DestroyEntity(self)
               end
            end
          end
   
end

function Contamination:OnInitialized()

    ScriptActor.OnInitialized(self)

    InitMixin(self, InfestationMixin)
    
    self:SetModel(Contamination.kModelName, kAnimationGraph)

    local coords = Angles(0, math.random() * 2 * math.pi, 0):GetCoords()
    coords.origin = self:GetOrigin()
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        self:AddTimedCallback(TimeUp, kLifeSpan)
        self:SetCoords(coords)
    //   if GetHasTech(self, kTechId.ContaminationHP) then self:SetHealth(1300) end  
    
           // if not HasMixin(self, "MapBlip") then
           // InitMixin(self, MapBlipMixin)
        //end
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        
        self.contaminationEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        self.contaminationEffect:SetCinematic(kContaminationSpreadEffect)
        self.contaminationEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.contaminationEffect:SetCoords(self:GetCoords())

        self.infestationDecal = CreateSimpleInfestationDecal(1, coords)
    
    end

end
function Contamination:GetTechButtons(techId)
    return { kTechId.Shell, kTechId.NutrientMist, kTechId.EtheralGate, kTechId.Crag, 
             kTechId.Whip, kTechId.Drifter, kTechId.Shade, kTechId.Shift }
end
function Contamination:GetIsFlameAble()
    return true
end

function Contamination:GetReceivesStructuralDamage()
    return true
end    

function Contamination:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if Client then
    
        if self.contaminationEffect then
        
            Client.DestroyCinematic(self.contaminationEffect)
            self.contaminationEffect = nil
        
        end
        
        if self.infestationDecal then
        
            Client.DestroyRenderDecal(self.infestationDecal)
            self.infestationDecal = nil
        
        end
    
    end

end

function Contamination:GetInfestationRadius()
    return kInfestationRadius
end

function Contamination:GetInfestationMaxRadius()
    return kInfestationRadius
end

function Contamination:GetInfestationGrowthRate()
    return 0.5
end

function Contamination:GetPlayIdleSound()
    return self:GetCurrentInfestationRadiusCached() < 1
end

function Contamination:OnKill(attacker, doer, point, direction)

    self:TriggerEffects("death")
    self:SetModel(nil)

  //if GetHasTech(self, kTechId.ContaminationRupture) then CreateEntity(Rupture.kMapName, self:GetOrigin(), self:GetTeamNumber()) end
    
end 

function Contamination:GetSendDeathMessageOverride()
    return false
end

function Contamination:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function Contamination:GetCanBeHealedOverride()
    return false
end

function Contamination:OverrideCheckVision()
    return false
end

local kTargetPointOffset = Vector(0, 0.18, 0)
function Contamination:GetEngagementPointOverride()
    return self:GetOrigin() + kTargetPointOffset
end

function Contamination:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    
    if not self:GetIsAlive() then
    
        if Server then
    
            local destructionAllowedTable = { allowed = true }
            if self.GetDestructionAllowed then
                self:GetDestructionAllowed(destructionAllowedTable)
            end
            
            if destructionAllowedTable.allowed then
                DestroyEntity(self)
            end
        
        end
        
        if Client then
        
            if self.contaminationEffect then
                
                Client.DestroyCinematic(self.contaminationEffect)
                self.contaminationEffect = nil
                
            end
            
            if self.infestationDecal then
            
                Client.DestroyRenderDecal(self.infestationDecal)
                self.infestationDecal = nil
            
            end
            
        end 
    
    end

end

Shared.LinkClassToMap("Contamination", Contamination.kMapName, networkVars)
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\DrifterEgg.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/UmbraMixin.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")

class 'DrifterEgg' (ScriptActor)
DrifterEgg.kMapName = "drifteregg"

DrifterEgg.kModelName = PrecacheAsset("models/alien/cocoon/cocoon.model")
local kAnimationGraph = PrecacheAsset("models/alien/cocoon/cocoon.animation_graph")

local networkVars =
{
    creationTime = "time"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)

AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)

function DrifterEgg:OnCreate()

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
    InitMixin(self, LOSMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, UmbraMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
end

function DrifterEgg:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    
    if Server then
        
        InitMixin(self, SupplyUserMixin)
        InitMixin(self, StaticTargetMixin)
        self:AddTimedCallback(DrifterEgg.Hatch, kDrifterHatchTime)        
        self:AddTimedCallback(DrifterEgg.UpdateTech, 0.2)
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        
    end
    
    self:SetModel(DrifterEgg.kModelName, kAnimationGraph)

end

function DrifterEgg:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false
end

function DrifterEgg:OverrideGetStatusInfo()

    return { Locale.ResolveString("COMM_SEL_HATCHING"), 
             self:GetHatchProgress(),
             kTechId.Drifter
   }

end

function DrifterEgg:GetIsMoveable()
    return true
end

function DrifterEgg:GetHatchProgress()
    return Clamp((Shared.GetTime() - self.creationTime) / kDrifterHatchTime, 0, 1)
end

if Server then

    function DrifterEgg:UpdateTech()
    
        if not self:GetIsDestroyed() then
    
            local progress = self:GetHatchProgress()

            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.Drifter)    
            researchNode:SetResearchProgress(progress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", progress)) 
            
            if GetGamerules():GetAutobuild() then
                self:Hatch()
            end
        
            return true
        
        end
    
    end

    function DrifterEgg:OnOverrideOrder(order)

        // Convert default to set rally point.
        if order:GetType() == kTechId.Default then
            order:SetType(kTechId.SetRally)
        end
        
    end

    function DrifterEgg:Hatch()
            
        local drifter = CreateEntity(Drifter.kMapName, self:GetOrigin() + Vector(0, Drifter.kHoverHeight, 0), self:GetTeamNumber())
        drifter:ProcessRallyOrder(self)
        drifter:SetHealth(self:GetHealth())
        drifter:SetArmor(self:GetArmor())
        
        // inherit selection
        drifter.selectionMask = self.selectionMask
        drifter.hotGroupNumber = self.hotGroupNumber
        
        self:TriggerEffects("death")
        
        local techTree = self:GetTeam():GetTechTree()    
        local researchNode = techTree:GetTechNode(kTechId.Drifter)    
        researchNode:SetResearchProgress(1)
        techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 1)) 
        
        DestroyEntity(self)

    end
    
    function DrifterEgg:OnKill()
    
        self:TriggerEffects("death")
        DestroyEntity(self)
    
    end
    
end   

function DrifterEgg:OnUpdatePoseParameters()

    self:SetPoseParam("grow", self:GetHatchProgress())
    
end    

Shared.LinkClassToMap("DrifterEgg", DrifterEgg.kMapName, networkVars)
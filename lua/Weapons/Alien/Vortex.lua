// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Vortex.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)  
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Blink.lua")
Script.Load("lua/Weapons/Alien/EtherealGate.lua")
Script.Load("lua/EntityChangeMixin.lua")

class 'Vortex' (Blink)

Vortex.kMapName = "vortex"

local kCreateVortex = PrecacheAsset("cinematics/alien/fade/use_vortex.cinematic")

local networkVars =
{
    etherealGateId = "entityid"
}

local kRange = 35

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")
PrecacheAsset("cinematics/vfx_materials/vortex.surface_shader")

function Vortex:OnCreate()

    Blink.OnCreate(self)
 
    self.primaryAttacking = false
    
    if Server then
    
        self.etherealGateId = Entity.invalidId
        self.vortexTargetId = Entity.invalidId
        InitMixin(self, EntityChangeMixin)
        
    end

end

function Vortex:OnEntityChange(oldId, newId)

    if oldId == self.etherealGateId then
    
        self.etherealGateId = Entity.invalidId
        
        local player = self:GetParent()
        if player then
            player.hasEtherealGate = false
        end
        
    end
    
end

function Vortex:GetEtherealGate()
    
    if self.etherealGateId then
        return Shared.GetEntity(self.etherealGateId)
    end
    
end

function Vortex:DestroyOldGate()

    if self.etherealGateId ~= Entity.invalidId then
    
        local oldGate = Shared.GetEntity(self.etherealGateId)
        if oldGate then
            DestroyEntity(oldGate)
        end
        
        self.etherealGateId = Entity.invalidId
    
    end

end

function Vortex:GetAnimationGraphName()
    return kAnimationGraph
end

function Vortex:GetEnergyCost(player)
    return kVortexEnergyCost
end

function Vortex:GetPrimaryEnergyCost(player)
    return kVortexEnergyCost
end

function Vortex:GetHUDSlot()
    return 2
end

function Vortex:GetDeathIconIndex()
    return kDeathMessageIcon.Swipe
end

function Vortex:GetSecondaryTechId()
    return kTechId.Blink
end

function Vortex:GetBlinkAllowed()
    return true
end

function Vortex:OnPrimaryAttack(player)

    if not self:GetIsBlinking() and player:GetEnergy() >= self:GetEnergyCost() then
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end

function Vortex:OnPrimaryAttackEnd()
    
    Blink.OnPrimaryAttackEnd(self)
    
    self.primaryAttacking = false
    
end

function Vortex:OnHolster(player)

    Blink.OnHolster(self, player)
    
    self.primaryAttacking = false
    
end

local function PerformVortex(self, player)

    self:DestroyOldGate()  
    
    local gate = CreateEntity(EtherealGate.kMapName, player:GetOrigin(), player:GetTeamNumber())
    self.etherealGateId = gate:GetId()
    player.hasEtherealGate = true
    gate.fadeCrouched = player:GetCrouching()
    
end

function Vortex:OnTag(tagName)

    PROFILE("Vortex:OnTag")

    if tagName == "hit" then
    
        local player = self:GetParent()
        if player then
        
            player:DeductAbilityEnergy(self:GetPrimaryEnergyCost())

            if Server then
                PerformVortex(self, player)
            end            
            
            if Client and Client.GetLocalPlayer() == player and player:GetIsFirstPerson() then
                
                local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                cinematic:SetCinematic(kCreateVortex)
                
            end
            
        end
        
    end
    
end

function Vortex:OnUpdateAnimationInput(modelMixin)

    PROFILE("Vortex:OnUpdateAnimationInput")

    Blink.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("ability", "vortex")
    
    local activityString = (self.primaryAttacking and "primary") or "none"
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("Vortex", Vortex.kMapName, networkVars)
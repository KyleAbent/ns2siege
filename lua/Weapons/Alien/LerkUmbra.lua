// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\LerkUmbra.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
// 
// Umbra is main attack, spores is secondary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/SpikesMixin.lua")
Script.Load("lua/Weapons/Alien/CragLerkUmbra.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

class 'LerkUmbra' (Ability)

LerkUmbra.kMapName = "lerkumbra"

local kRange = 17

local kAnimationGraph = PrecacheAsset("models/alien/lerk/lerk_view.animation_graph")
local attackEffectMaterial = nil
local kUmbraSound = PrecacheAsset("sound/NS2.fev/alien/structures/crag/umbra")

local networkVars =
{
}

AddMixinNetworkVars(SpikesMixin, networkVars)

local function CreateUmbraCloud(self, player)

    local trace = Shared.TraceRay(player:GetEyePos(), player:GetEyePos() + player:GetViewCoords().zAxis * kRange, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
    local destination = trace.endPoint + trace.normal * 2
    
    local umbraCloud = CreateEntity(CragLerkUmbra.kMapName, player:GetEyePos() + player:GetViewCoords().zAxis, player:GetTeamNumber())
    umbraCloud:SetTravelDestination(destination)
    
    
    if (GetHasSilenceUpgrade(player) and GetVeilLevel(player:GetTeamNumber()) == 0) or not GetHasSilenceUpgrade(player) then
        StartSoundEffectAtOrigin(kUmbraSound, player:GetEyePos())
    end

end

function LerkUmbra:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, SpikesMixin)
    
    self.primaryAttacking = false
    
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end

end

function LerkUmbra:GetAnimationGraphName()
    return kAnimationGraph
end

function LerkUmbra:GetEnergyCost(player)
    return kUmbraEnergyCost
end

function LerkUmbra:GetHUDSlot()
    return 2
end

function LerkUmbra:GetRange()
    return kRange
end

function LerkUmbra:GetDeathIconIndex()
    return kDeathMessageIcon.Spikes
end

function LerkUmbra:GetSecondaryTechId()
    return kTechId.Spikes
end

function LerkUmbra:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() then
        self.primaryAttacking = true
        self:PerformPrimaryAttack(player)
    else
        self.primaryAttacking = false
    end
    
end

function LerkUmbra:OnPrimaryAttackEnd(player)
    self.primaryAttacking = false
end

function LerkUmbra:OnHolster(player)

    Ability.OnHolster(self, player)
    
    self.primaryAttacking = false
    
end

function LerkUmbra:OnTag(tagName)

    PROFILE("LerkUmbra:OnTag")

    if tagName == "hit" then
    
        local player = self:GetParent()
        
        if player then  
        
            self:TriggerEffects("umbra_attack")
            
            if Server then
                if player:GetEnergy() >= self:GetEnergyCost() then
                    CreateUmbraCloud(self, player)
                    player:DeductAbilityEnergy(self:GetEnergyCost())
                end
            end
            
        end
        
    end
    
end


function LerkUmbra:OnUpdateAnimationInput(modelMixin)

    PROFILE("Spikes:OnUpdateAnimationInput")
    
    if not self:GetIsSecondaryBlocking() then
    
        modelMixin:SetAnimationInput("ability", "umbra")

        local activityString = "none"
        if self.primaryAttacking then
            activityString = "primary"
        end

        modelMixin:SetAnimationInput("activity", activityString)
    
    end
    
end

Shared.LinkClassToMap("LerkUmbra", LerkUmbra.kMapName, networkVars)
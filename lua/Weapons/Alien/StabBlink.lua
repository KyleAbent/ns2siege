// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\StabBlink.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Blink.lua")

class 'StabBlink' (Blink)
StabBlink.kMapName = "stab"

local networkVars =
{
    stabbing = "compensated boolean"
}

local kRange = 1.9

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")

function StabBlink:OnCreate()

    Blink.OnCreate(self)

    self.primaryAttacking = false

end

function StabBlink:GetAnimationGraphName()
    return kAnimationGraph
end

function StabBlink:GetEnergyCost(player)
    return kStabEnergyCost
end

function StabBlink:GetHUDSlot()
    return 3
end

function StabBlink:GetPrimaryAttackRequiresPress()
    return false
end

function StabBlink:GetMeleeBase()

    --[[ Disabled increased bite cone
    local parent = self:GetParent()
    if parent and parent.GetIsEnzymed and parent:GetIsEnzymed() then
        return 1, 1.2
    end
    --]]
    return .7, 1
end

function StabBlink:GetDeathIconIndex()
    return kDeathMessageIcon.Stab
end

function StabBlink:GetSecondaryTechId()
    return kTechId.Blink
end

function StabBlink:GetBlinkAllowed()
    return not self.stabbing
end

function StabBlink:OnPrimaryAttack(player)

    if not self:GetIsBlinking() and player:GetEnergy() >= self:GetEnergyCost() then
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end

function StabBlink:OnPrimaryAttackEnd()
    
    Blink.OnPrimaryAttackEnd(self)
    
    self.primaryAttacking = false
    
end

function StabBlink:OnHolster(player)

    Blink.OnHolster(self, player)
    
    self.primaryAttacking = false
    self.stabbing = false
    
end

function StabBlink:OnDraw(player,previousWeaponMapName)

    Blink.OnDraw(self, player, previousWeaponMapName)
    
    self.primaryAttacking = false
    self.stabbing = false
    
end

function StabBlink:GetIsStabbing()
    return self.stabbing
end

function StabBlink:OnTag(tagName)

    PROFILE("SwipeBlink:OnTag")
    
    if tagName == "stab_start" then
    
        self:TriggerEffects("stab_attack")
        self.stabbing = true
    
        local player = self:GetParent()
        if player then
            player:DeductAbilityEnergy(self:GetEnergyCost())
        end
    
    elseif tagName == "hit" and self.stabbing then
    
        self:TriggerEffects("stab_hit")
        self.stabbing = false
    
        local player = self:GetParent()
        if player then

            AttackMeleeCapsule(self, player, kStabDamage, kRange, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
          
        end
        
    end

end

function StabBlink:OnUpdateAnimationInput(modelMixin)

    PROFILE("StabBlink:OnUpdateAnimationInput")

    Blink.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("ability", "stab")
    
    local activityString = (self.primaryAttacking and "primary") or "none"
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("StabBlink", StabBlink.kMapName, networkVars)
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Gore.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com) and
//                  Urwalek Andreas (andi@unknownworlds.com)
//
// Basic goring attack. Can also be used to smash down locked or welded doors.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/StompMixin.lua")

class 'Gore' (Ability)

Gore.kMapName = "gore"

local kAnimationGraph = PrecacheAsset("models/alien/onos/onos_view.animation_graph")

Gore.kAttackType = enum({ "Gore", "Smash", "None" })
// when hitting marine his aim is interrupted
Gore.kAimInterruptDuration = 0.7

local networkVars =
{
    attackType = "enum Gore.kAttackType",
    attackButtonPressed = "boolean"
}

AddMixinNetworkVars(StompMixin, networkVars)

local kAttackRange = 1.7
local kFloorAttackRage = 0.9

local kGoreSmashKnockbackForce = 590 // mass of a marine: 90
local kGoreSmashMinimumUpwardsVelocity = 9

local function PrioritizeEnemyPlayers(weapon, player, newTarget, oldTarget)
    return not oldTarget or (GetAreEnemies(player, newTarget) and newTarget:isa("Player") and not oldTarget:isa("Player") )
end

local function GetGoreAttackRange(viewCoords)
    return (kAttackRange + math.max(0, -viewCoords.zAxis.y) * kFloorAttackRage)
end

// checks in front of the onos in a radius for potential targets and returns the attack mode (randomized if no targets found)
local function GetAttackType(self, player)

    PROFILE("GetAttackType")
    
    local attackType = Gore.kAttackType.Gore
    local scale = 1
    if player.modelsize > 1 then scale = player.modelsize end 
    local range = GetGoreAttackRange(player:GetViewCoords()) * scale
    local didHit, target, direction = CheckMeleeCapsule(self, player, 0, range, nil, nil, nil, PrioritizeEnemyPlayers)

    if didHit then
    
        if target and HasMixin(target, "Live") then
        
            if ( target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage() ) and GetAreEnemies(player, target) then
                attackType = Gore.kAttackType.Smash         
            end
            
        end
    
    end

    if Server then
        self.lastAttackType = attackType
    end
    
    return attackType

end

function Gore:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, StompMixin)
    
    self.attackType = Gore.kAttackType.None
    if Server then
        self.lastAttackType = Gore.kAttackType.None
    end
    self.primaryAttacking = false  
end

function Gore:GetDeathIconIndex()
    return kDeathMessageIcon.Gore
end

function Gore:GetAnimationGraphName()
    return kAnimationGraph
end

function Gore:GetEnergyCost(player)
   //   local parent = self:GetParent()
    return kGoreEnergyCost //* parent.modelsize
end

function Gore:GetHUDSlot()
    return 1
end

function Gore:GetAttackType()
    return self.attackType
end

function Gore:OnHolster(player)

    Ability.OnHolster(self, player)
    
    self:OnAttackEnd()
    
end

function Gore:GetMeleeBase()

    --[[ Disabled increased bite cone
    local parent = self:GetParent()
    if parent and parent.GetIsEnzymed and parent:GetIsEnzymed() then
        return 1.4, 1.7
    end
    --]]
    return 1, 1.4
end

function Gore:Attack(player, charged)

    local didHit = false
    local impactPoint = nil
    local target = nil
    local attackType = self.attackType
    
    if Server then
        attackType = self.lastAttackType
    end
    
    local range = GetGoreAttackRange(player:GetViewCoords())
    didHit, target, impactPoint = AttackMeleeCapsule(self, player, kGoreDamage, range)
     if not charged then
    player:DeductAbilityEnergy(self:GetEnergyCost(player))
    elseif charged and target and target:isa("FuncDoor") then //attack it twice make sure it goes down
         didHit, target, impactPoint = AttackMeleeCapsule(self, player, kGoreDamage, range)
     end
    
    return didHit, impactPoint, target
    
end

function Gore:OnTag(tagName)

    PROFILE("Gore:OnTag")

    if tagName == "hit" then
    
        local player = self:GetParent()
        
        local didHit, impactPoint, target = self:Attack(player, false)
        
        // play sound effects
        self:TriggerEffects("gore_attack")
        
        // play particle effects for smash
        if didHit and self:GetAttackType() == Gore.kAttackType.Smash and ( not target or (target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage()) ) then
        
            local effectCoords = player:GetViewCoords()
            effectCoords.origin = impactPoint
            self:TriggerEffects("smash_attack_hit", {effecthostcoords = effectCoords} )
            
        end
        
        if self.attackButtonPressed then
            self.attackType = GetAttackType(self, player)
        else
            self:OnAttackEnd()
        end
        
        if player:GetEnergy() >= self:GetEnergyCost(player) or not self.attackButtonPressed then
            self:OnAttackEnd()
        end
        
    elseif tagName == "end" and not self.attackButtonPressed then
        self:OnAttackEnd()
    end    

end

function Gore:OnPrimaryAttack(player)

    local nextAttackType = self.attackType
    if nextAttackType == Gore.kAttackType.None then
        nextAttackType = GetAttackType(self, player)
    end

    if player:GetEnergy() >= self:GetEnergyCost(player) then
        self.attackType = nextAttackType
        self.attackButtonPressed = true
        self.primaryAttacking = true
    else
        self:OnAttackEnd()
    end 

end

function Gore:OnPrimaryAttackEnd(player)
    
    Ability.OnPrimaryAttackEnd(self, player)
    self:OnAttackEnd()
    
end

function Gore:OnAttackEnd()
    self.primaryAttacking = false
    self.attackType = Gore.kAttackType.None
    self.attackButtonPressed = false
end

function Gore:OnUpdateAnimationInput(modelMixin)

    local activityString = "none"
    local abilityString = "gore"
    
    if self.attackButtonPressed then
    
        if self.attackType == Gore.kAttackType.Gore then
            activityString = "primary"
        elseif self.attackType == Gore.kAttackType.Smash then
            activityString = "smash"
        end
        
    end
    
    modelMixin:SetAnimationInput("ability", abilityString)
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("Gore", Gore.kMapName, networkVars)
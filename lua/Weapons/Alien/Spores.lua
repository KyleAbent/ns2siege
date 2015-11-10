// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Spores.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
// 
// Spores main attack, spikes secondary
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
//Script.Load("lua/Weapons/Alien/SpikesMixin.lua")
Script.Load("lua/Weapons/Alien/SporeCloud.lua")
Script.Load("lua/Weapons/Alien/SporeMeleeCloud.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

kSporesHUDSlot = 3

local function CreateMeleeSporeCloud(self, origin, player)

    local spores = CreateEntity(SporeMeleeCloud.kMapName, origin, player:GetTeamNumber())
    
    spores:SetOwner(player)
    
    local coords = player:GetCoords()
    
    local velocity = player:GetVelocity()
    if velocity:Normalize() > 0.0 then
        // adjusts the effect to the players move direction (strafe + sporing)
        zAxis = velocity
    end
    coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
    coords.yAxis = coords.xAxis:CrossProduct(coords.zAxis)
    
    spores:SetCoords(coords)

    return spores
    
end

local function GetHasSporeCloudsInRangeWithLifeTime(position, range, minLifeTime)
    
    for index, sporeMeleeCloud in ipairs(GetEntitiesWithinRange("SporeMeleeCloud", position, range)) do
    
        if sporeMeleeCloud:GetMeleeCloudRemainingLifeTime() >= minLifeTime then
            return true
        end
    
    end
       for index, sporeRangedCloud in ipairs(GetEntitiesWithinRange("SporeCloud", position, range)) do
    
        if sporeRangedCloud:GetRemainingLifeTime() >= minLifeTime then
            return true
        end
    
    end 
end

class 'Spores' (Ability)

Spores.kMapName = "Spores"

local kAnimationGraph = PrecacheAsset("models/alien/lerk/lerk_view.animation_graph")


local kCheckSporeRange = kSporesDustCloudRadius * 0.7
local kCheckSporeLifeTime = kSporesDustCloudLifetime * 0.7
local kSporesBlockingTime = 0.3
local kLoopingDustSound = PrecacheAsset("sound/NS2.fev/alien/lerk/spore_spray")
local RangedSound = PrecacheAsset("sound/NS2.fev/alien/structures/crag/umbra")
            


local networkVars =
{
    lastPrimaryAttackStartTime = "time",
    lastPrimaryAttackEndTime = "time",
   lastSecondaryAttackStartTime = "time",
    lastSecondaryAttackEndTime = "time"
}

//AddMixinNetworkVars(SpikesMixin, networkVars)

function Spores:OnCreate()

    Ability.OnCreate(self)
    
    //InitMixin(self, SpikesMixin)
    
    self.primaryAttacking = false
    self.secondaryAttacking = false
   
    if Server then
        
        self.loopingSporesSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingSporesSound:SetAsset(kLoopingDustSound)
        self.loopingSporesSound:SetParent(self)
        
    elseif Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end

end

local function CreateSporeCloud(self, origin, player)

    local trace = Shared.TraceRay(player:GetEyePos(), player:GetEyePos() + player:GetViewCoords().zAxis * kSporesMaxCloudRange, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwo(self, player))
    local destination = trace.endPoint + trace.normal * 2
    
    local sporeCloud = CreateEntity(SporeCloud.kMapName, player:GetEyePos() + player:GetViewCoords().zAxis, player:GetTeamNumber())
    sporeCloud:SetOwner(player)
    sporeCloud:SetTravelDestination(destination)

end

function Spores:GetAttackDelay()
    return kSporesDustFireDelay
end

function Spores:OnDestroy()

    Ability.OnDestroy(self)
    
        if Server then
        self.loopingSporesSound = nil  
    end
    
    
end

function Spores:GetAnimationGraphName()
    return kAnimationGraph
end
function Spores:GetEnergyCost(player)
    return kSporesDustEnergyCost
end

function Spores:GetHUDSlot()
    return 3
end

function Spores:GetDeathIconIndex()
    return kDeathMessageIcon.Spores
end
/*
function Spores:GetSecondaryTechId()
    return kTechId.SporesMelee
end
*/

function Spores:OnPrimaryAttack(player)

	if player:GetEnergy() >= self:GetEnergyCost() and (Shared.GetTime() - self.lastPrimaryAttackStartTime) > self:GetAttackDelay() then
    
        self.primaryAttacking = true
        self:PerformPrimaryAttack(player)
        StartSoundEffectAtOrigin(RangedSound, player:GetOrigin())
    else
        self.primaryAttacking = false
    end
	
end


function Spores:OnPrimaryAttackEnd()
    
    self.primaryAttacking = false
    self.lastPrimaryAttackEndTime = Shared.GetTime()
    
    
end
function Spores:OnSecondaryAttack(player)

    if player:GetEnergy() >= kMeleeSporesDustEnergyCost and not GetHasSporeCloudsInRangeWithLifeTime(player:GetOrigin(), kCheckSporeRange, kCheckSporeLifeTime) then
    
        self.secondaryAttacking = true
        self:PerformSecondaryAttack(player)
        
    else
        self.secondaryAttacking = false
    end
    
end
function Spores:GetHasSecondary(player)
    return true
end
function Spores:OnSecondaryAttackEnd()
    
    self.secondaryAttacking = false
    self.lastSecondaryAttackEndTime = Shared.GetTime()
    
    if Server then
        self.loopingSporesSound:Stop()
    end
    
end


function Spores:PerformSecondaryAttack(player)

    // Create long-lasting spore cloud near player that can be used to prevent marines from passing through an area.
    if (Shared.GetTime() - self.lastSecondaryAttackStartTime) > kMeleeSporesDustFireDelay then
    
        self.lastSecondaryAttackStartTime = Shared.GetTime()
        
        if Client then
            self:TriggerEffects("spores_attack")
        end
        
        if Server then
        
            local origin = player:GetModelOrigin()
            local sporecloud = CreateMeleeSporeCloud(self, origin, player)
            local silenced = GetHasSilenceUpgrade(player) and GetVeilLevel(player:GetTeamNumber()) > 0
            if not self.loopingSporesSound:GetIsPlaying() and not silenced then
                self.loopingSporesSound:Start()
            end
            
            player:DeductAbilityEnergy(kMeleeSporesDustEnergyCost)
            
        end
        
    end
    
end
function Ability:GetSecondaryTechId()
    return kTechId.Spores
end
function Spores:PerformPrimaryAttack(player)

	self.lastPrimaryAttackStartTime = Shared.GetTime()

	self:TriggerEffects("spores_fire")
	
	if Server then
	
		local origin = player:GetModelOrigin()
		local sporecloud = CreateSporeCloud(self, origin, player)
		
		player:DeductAbilityEnergy(self:GetEnergyCost())
		
	end
        
end

function Spores:OnHolster(player)

    Ability.OnHolster(self, player)
    
    self.primaryAttacking = false
    
end



function Spores:OnUpdateAnimationInput(modelMixin)

  // PROFILE("Spikes:OnUpdateAnimationInput")
    

//    if not self:GetIsSecondaryBlocking() then
    
        modelMixin:SetAnimationInput("ability", "spores")
        
        local activityString = "none"
        if self.primaryAttacking then
            activityString = "primary"
        end
        
        modelMixin:SetAnimationInput("activity", activityString)
    
    //end
    
end

Shared.LinkClassToMap("Spores", Spores.kMapName, networkVars)
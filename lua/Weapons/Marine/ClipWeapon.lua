// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\ClipWeapon.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Basic bullet-based weapon. Handles primary firing only, as child classes have quite different
// secondary attacks.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/Weapons/BulletsMixin.lua")
Script.Load("lua/Hitreg.lua") 

PrecacheAsset("cinematics/materials/umbra/ricochet.cinematic")

class 'ClipWeapon' (Weapon)

local kBulletSize = 0.018

local idleTime = 0
local animFrequency = 10 //Amount of time between idle animations

ClipWeapon.kMapName = "clipweapon"

local networkVars =
{
    deployed = "boolean",
    
    ammo = "integer (0 to 511)",
    clip = "integer (0 to 200)",
    
    reloading = "compensated boolean",
    reloaded = "compensated boolean",
    
    timeAttackEnded = "time",
    
    lastTimeSprinted = "time",
    
}

// Weapon spread - from NS1/Half-life
ClipWeapon.kCone0Degrees  = Math.Radians(0)
ClipWeapon.kCone1Degrees  = Math.Radians(1)
ClipWeapon.kCone2Degrees  = Math.Radians(2)
ClipWeapon.kCone3Degrees  = Math.Radians(3)
ClipWeapon.kCone4Degrees  = Math.Radians(4)
ClipWeapon.kCone5Degrees  = Math.Radians(5)
ClipWeapon.kCone6Degrees  = Math.Radians(6)
ClipWeapon.kCone7Degrees  = Math.Radians(7)
ClipWeapon.kCone8Degrees  = Math.Radians(8)
ClipWeapon.kCone9Degrees  = Math.Radians(9)
ClipWeapon.kCone10Degrees = Math.Radians(10)
ClipWeapon.kCone15Degrees = Math.Radians(15)
ClipWeapon.kCone20Degrees = Math.Radians(20)

function ClipWeapon:OnCreate()

    Weapon.OnCreate(self)
    
    self.primaryAttacking = false
    self.secondaryAttacking = false
    self.timeAttackFired = 0
    self.timeAttackEnded = 0
    self.deployed = false
    self.lastTimeSprinted = 0
    self.shooting = false
    self.attackLastRequested = 0
    
    InitMixin(self, BulletsMixin)
    
    self.ammo = self:GetMaxClips() * self:GetClipSize()
    self.clip = self:GetClipSize()
    self.reloading = false
    
end

local function CancelReload(self)

    if self:GetIsReloading() then
    
        self.reloading = false
        if Client then
            self:TriggerEffects("reload_cancel")
        end
        if Server then
            self:TriggerEffects("reload_cancel")
        end
    end
    
end
function ClipWeapon:OnDestroy()

    Weapon.OnDestroy(self)
    
    CancelReload(self)
    
end

local function FillClip(self)

    // Stick the bullets in the clip back into our pool so that we don't lose
    // bullets. Not realistic, but more enjoyable
    self.ammo = self.ammo + self.clip
    
    // Transfer bullets from our ammo pool to the weapon's clip
    self.clip = math.min(self.ammo, self:GetClipSize())
    self.ammo = math.min(self.ammo - self.clip, self:GetMaxAmmo())
    
end

function ClipWeapon:OnInitialized()

    // Set model to be rendered in 3rd-person
    local worldModel = LookupTechData(self:GetTechId(), kTechDataModel)
    if worldModel ~= nil then
        self:SetModel(worldModel)
    end
    
    Weapon.OnInitialized(self)
    
end

function ClipWeapon:GetIsDeployed()
    return self.deployed
end

function ClipWeapon:GetBulletsPerShot()
    return 1
end

function ClipWeapon:GetMaxClips()
    return 4
end

function ClipWeapon:GetClipSize()
    return 10
end

// Used to affect spread and change the crosshair
function ClipWeapon:GetInaccuracyScalar(player)
    return ConditionalValue(player and player.GetIsInterrupted and player:GetIsInterrupted(), 8, 1)
end

// Return one of the ClipWeapon.kCone constants above
function ClipWeapon:GetSpread()
    return ClipWeapon.kCone0Degrees
end

function ClipWeapon:GetRange()
    return 100
end

function ClipWeapon:GetAmmo()
    return self.ammo
end

function ClipWeapon:GetClip()
    return self.clip
end

function ClipWeapon:GetAmmoFraction()

    local maxAmmo = self:GetMaxAmmo() + self:GetClipSize()
    if maxAmmo > 0 then
        return Clamp((self.clip + self.ammo) / maxAmmo, 0, 1)
    end
    
    return 1

end

function ClipWeapon:SetClip(clip)
    self.clip = clip
end

function ClipWeapon:GetAuxClip()
    return 0
end

function ClipWeapon:GetMaxAmmo()
    return self:GetMaxClips() * self:GetClipSize()
end

// Return world position of gun barrel, used for weapon effects.
function ClipWeapon:GetBarrelPoint()

    // TODO: Get this from the model and artwork.
    local player = self:GetParent()
    if player then
        return player:GetOrigin() + Vector(0, 2 * player:GetExtents().y * 0.8, 0) + player:GetCoords().zAxis * 0.5
    end
    
    return self:GetOrigin()
    
end

// Add energy back over time, called from Player:OnProcessMove
function ClipWeapon:ProcessMoveOnWeapon(player, input)

    if player:GetIsSprinting() then
        self.lastTimeSprinted = Shared.GetTime()
    end
    
end

function ClipWeapon:OnProcessMove(input)

    Weapon.OnProcessMove(self, input)

end

function ClipWeapon:GetBulletDamage(target, endPoint)

    assert(false, "Need to override GetBulletDamage()")
    
    return 0
    
end

function ClipWeapon:GetIsReloading()
    return self.reloading
end

function ClipWeapon:GetPrimaryCanInterruptReload()
    return false
end

function ClipWeapon:GetSecondaryCanInterruptReload()
    return false
end

function ClipWeapon:GiveAmmo(numClips, includeClip)

    // Fill reserves, then clip. NS1 just filled reserves but I like the implications of filling the clip too.
    // But don't do it until reserves full.
    local success = false
    local bulletsToGive = numClips * self:GetClipSize()
    
    local bulletsToAmmo = math.min(bulletsToGive, self:GetMaxAmmo() - self:GetAmmo())        
    if bulletsToAmmo > 0 then

        self.ammo = self.ammo + bulletsToAmmo

        bulletsToGive = bulletsToGive - bulletsToAmmo        
        
        success = true
        
    end
    
    if bulletsToGive > 0 and (self:GetClip() < self:GetClipSize() and includeClip) then
        
        self.clip = self.clip + math.min(bulletsToGive, self:GetClipSize() - self:GetClip())
        success = true        
        
    end

    return success
    
end

function ClipWeapon:GiveReserveAmmo(bullets)
    local bulletsToAmmo = math.min(bullets, self:GetMaxAmmo() - self:GetAmmo())  
    self.ammo = self.ammo + bulletsToAmmo
end

function ClipWeapon:GetNeedsAmmo(includeClip)
    return (includeClip and (self:GetClip() < self:GetClipSize())) or (self:GetAmmo() < self:GetMaxAmmo())
end

function ClipWeapon:GetPrimaryAttackRequiresPress()
    return false
end

function ClipWeapon:GetIsPrimaryAttackAllowed(player)

    if not player then
        return false
    end    

    local sprintedRecently = (Shared.GetTime() - self.lastTimeSprinted) < kMaxTimeToSprintAfterAttack
    local attackAllowed = (not self:GetPrimaryAttackRequiresPress() or not player:GetPrimaryAttackLastFrame())
    attackAllowed = attackAllowed and (not self:GetIsReloading() or self:GetPrimaryCanInterruptReload())
    
    // Note: the minimum fire delay is the time from when the weapon fired until it can start to attack again.
    // For weapons that fire immediately upon press, this is the same as ROF. For weapons with a delay from start
    // of attack until actual attack ... it is not.
    if attackAllowed and self.GetPrimaryMinFireDelay then
        attackAllowed = (Shared.GetTime() - self.timeAttackFired) >= self:GetPrimaryMinFireDelay()
        
        if not attackAllowed and self.OnMaxFireRateExceeded then
            self:OnMaxFireRateExceeded()
        end
        
    end
    
    return self:GetIsDeployed() and not sprintedRecently and attackAllowed

end

function ClipWeapon:OnPrimaryAttack(player)

    if self:GetIsPrimaryAttackAllowed(player) then
    
        if self.clip > 0 then

            CancelReload(self)
            
            self.primaryAttacking = true
            self.attackLastRequested = Shared.GetTime()
            
        elseif self.ammo > 0 then
        
            self:OnPrimaryAttackEnd(player)
            // Automatically reload if we're out of ammo.
            player:Reload()
            
        else
            self:OnPrimaryAttackEnd(player)            
        end
        
    else
        self:OnPrimaryAttackEnd(player)
    end
    
end

function ClipWeapon:OnPrimaryAttackEnd(player)

    if self.primaryAttacking then
    
        Weapon.OnPrimaryAttackEnd(self, player)
        
        self.primaryAttacking = false
        self.timeAttackEnded = Shared.GetTime()
        
        idleTime = Shared.GetTime()
    end
    
    self.shooting = false
    
end

function ClipWeapon:CreatePrimaryAttackEffect(player)
end

function ClipWeapon:GetHasSecondary(player)
    return true
end

function ClipWeapon:OnSecondaryAttack(player)

    local sprintedRecently = (Shared.GetTime() - self.lastTimeSprinted) < kMaxTimeToSprintAfterAttack
    local attackAllowed = not sprintedRecently and (not self:GetIsReloading() or self:GetSecondaryCanInterruptReload()) and (not self:GetSecondaryAttackRequiresPress() or not player:GetSecondaryAttackLastFrame())
    
    if not player:GetIsSprinting() and self:GetIsDeployed() and attackAllowed and not self.primaryAttacking then
    
        self.secondaryAttacking = true
        self.attackLastRequested = Shared.GetTime()
        CancelReload(self)
        
        Weapon.OnSecondaryAttack(self, player)
                
    else
        self:OnSecondaryAttackEnd(player)
    end
    
end

function ClipWeapon:OnSecondaryAttackEnd(player)

    Weapon.OnSecondaryAttackEnd(self, player)
    
    self.secondaryAttacking = false
    self.timeAttackEnded = Shared.GetTime()

end

function ClipWeapon:GetPrimaryAttacking()
    return self.primaryAttacking
end

function ClipWeapon:GetSecondaryAttacking()
    return self.secondaryAttacking
end

function ClipWeapon:GetBulletSize()
    return kBulletSize
end

function ClipWeapon:CalculateSpreadDirection(shootCoords, player)
    return CalculateSpread(shootCoords, self:GetSpread() * self:GetInaccuracyScalar(player), NetworkRandom)
end

/**
 * Fires the specified number of bullets in a cone from the player's current view.
 */
local function FireBullets(self, player)

    PROFILE("FireBullets")

    local viewAngles = player:GetViewAngles()
    local shootCoords = viewAngles:GetCoords()
    
    // Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local range = self:GetRange()
    
//    if GetIsVortexed(player) then
//        range = 5
//    end
    
    local numberBullets = self:GetBulletsPerShot()
    local startPoint = player:GetEyePos()
    local bulletSize = self:GetBulletSize()
    
    for bullet = 1, numberBullets do
    
        local spreadDirection = self:CalculateSpreadDirection(shootCoords, player)
        
        local endPoint = startPoint + spreadDirection * range
        local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, bulletSize, filter)        
        local damage = self:GetBulletDamage()

        HandleHitregAnalysis(player, startPoint, endPoint, trace)   

        local direction = (trace.endPoint - startPoint):GetUnit()
        local hitOffset = direction * kHitEffectOffset
        local impactPoint = trace.endPoint - hitOffset
        local effectFrequency = self:GetTracerEffectFrequency()
        local showTracer = math.random() < effectFrequency

        local numTargets = #targets
        
        if numTargets == 0 then
            self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
        end
        
        if Client and showTracer then
            TriggerFirstPersonTracer(self, impactPoint)
        end
        
        for i = 1, numTargets do

            local target = targets[i]
            local hitPoint = hitPoints[i]

            self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, damage, "", showTracer and i == numTargets)
            
            local client = Server and player:GetClient() or Client
            if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, bullet, startPoint, trace, damage)
            end
        
        end
        
    end
    
end

function ClipWeapon:FirePrimary(player)
    self.fireTime = Shared.GetTime()
    FireBullets(self, player)
end

// Play tracer sound/effect every %d bullets
function ClipWeapon:GetTracerEffectFrequency()
    return 0.5
end

function ClipWeapon:GetIsDroppable()
    return true
end

function ClipWeapon:GetSprintAllowed()
    return not self.reloading and (Shared.GetTime() > (self.timeAttackEnded + kMaxTimeToSprintAfterAttack))
end

function ClipWeapon:GetIdleAnimations(index)
    return "idle"
end

function ClipWeapon:CanReload()

    return self.ammo > 0 and
           self.clip < self:GetClipSize() and
           not self.reloading and 
           self.deployed
    
end

function ClipWeapon:OnReload(player)

    if self:CanReload() then
    
        self:TriggerEffects("reload")
        self.reloading = true
        
    end
    
end

function ClipWeapon:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)
    
    // Attach weapon to parent's hand
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    
    idleTime = Shared.GetTime()

end

function ClipWeapon:OnHolster(player)

    Weapon.OnHolster(self, player)
    
    CancelReload(self)
    
    self.deployed = false
    self.reloading = false
    self.shooting = false
    self.timeAttackFired = 0
    self.timeAttackEnded = 0
    
end

function ClipWeapon:GetEffectParams(tableParams)
    tableParams[kEffectFilterEmpty] = self.clip == 0
end

function ClipWeapon:GetMaxAllowedDelaySinceAttackRequest()
    // the rifle has a 40ms delay from pressing trigger to the shoot tag showing up, so we need 
    // about this much slack
    return 0.1
end

function ClipWeapon:GetIsAllowedToShoot(player)
    local timeSinceAttackKeyReleased = Shared.GetTime() - self.attackLastRequested
    // Log("%s: player %s, clip %s, tsakr %s, allowed %s", self, player, self.clip, timeSinceAttackKeyReleased, self:GetMaxAllowedDelaySinceAttackRequest())
    return player and self.clip > 0 and timeSinceAttackKeyReleased < self:GetMaxAllowedDelaySinceAttackRequest()
end

function ClipWeapon:OnTag(tagName)

    PROFILE("ClipWeapon:OnTag")


    if tagName == "shoot" then
    
        local player = self:GetParent()
        
        // We can get a shoot tag even when the clip is empty if the frame rate is low
        // and the animation loops before we have time to change the state.
        // we can also get tag from other weapons whose animation is running, so make sure that we are actually
        // attacking before we act on the shoot.
        if self:GetIsAllowedToShoot(player) then
        
            self:FirePrimary(player)
            
            // Don't decrement ammo in Darwin mode
            if not player or not ( player:GetDarwinMode() or player.RTDinfiniteammomode ) then
                self.clip = self.clip - 1
            end
            
            self:CreatePrimaryAttackEffect(player)
            
            self.timeAttackFired = Shared.GetTime()
            
            self.shooting = true
            
            //DebugFireRate(self)
            
        end
		
		-- If we fired the last bullet, reload immediatly
		if self.clip == 0 and self.ammo > 0 then
			player:Reload()
		end
           
    elseif tagName == "reload" then
        FillClip(self)
        self.reloaded = true
        self.shooting = false
    elseif tagName == "deploy_end" then
        self.deployed = true
    elseif tagName == "reload_end" and self.reloaded then
        self.reloading = false
        self.reloaded = false
    elseif tagName == "shoot_empty" then
        self:TriggerEffects("clipweapon_empty")
    end
    
end

function ClipWeapon:OnUpdateAnimationInput(modelMixin)

    PROFILE("ClipWeapon:OnUpdateAnimationInput")
    
  //  local stunned = false
    local interrupted = false
    local player = self:GetParent()
    if player then
    
    ///    if HasMixin(player, "Stun") and player:GetIsStunned() then
    //        stunned = true
   //     end
        
        if player.GetIsInterrupted and player:GetIsInterrupted() then
            interrupted = true
        end
        
        if player:GetIsIdle() then
            local totalTime = math.round(Shared.GetTime() - idleTime)
            if totalTime >= animFrequency*3 then
                idleTime = Shared.GetTime()
            elseif totalTime >= animFrequency*2 then
                modelMixin:SetAnimationInput("idleName", self:GetIdleAnimations(3))
            elseif totalTime >= animFrequency then
                modelMixin:SetAnimationInput("idleName", self:GetIdleAnimations(2))
            elseif totalTime < animFrequency then
                modelMixin:SetAnimationInput("idleName", self:GetIdleAnimations(1))
            end
            
        else
            idleTime = Shared.GetTime()
            modelMixin:SetAnimationInput("idleName", "idle")
        end
    
    end                   
    
    local activity = "none"
  //  if not stunned then
    
        if self:GetIsReloading() then
            activity = "reload"     
        elseif self.primaryAttacking then
            activity = "primary"
        elseif self.secondaryAttacking then
            activity = "secondary"
        end
        
  //  end
    
    modelMixin:SetAnimationInput("activity", activity)
    modelMixin:SetAnimationInput("flinch_gore", interrupted and not self:GetIsReloading())
    modelMixin:SetAnimationInput("empty", (self.ammo + self.clip) == 0)

end

// override if weapon should drop reserve ammo as separate entity
function ClipWeapon:GetAmmoPackMapName()
    return nil
end    

if Server then

    function ClipWeapon:Dropped(prevOwner)
    
        Weapon.Dropped(self, prevOwner)
        
        CancelReload(self)
        
        local ammopackMapName = self:GetAmmoPackMapName()
        
        if ammopackMapName and self.ammo ~= 0 then
        
            local ammoPack = CreateEntity(ammopackMapName, self:GetOrigin(), self:GetTeamNumber())
            ammoPack:SetAmmoPackSize(self.ammo)
            self.ammo = 0
            
            ammoPack.weapon = self:GetId()
        end
        
    end
    
elseif Client then

    function ClipWeapon:GetTriggerPrimaryEffects()
        return not self:GetIsReloading()
    end
    
    function ClipWeapon:GetTriggerSecondaryEffects()
        return not self:GetIsReloading()
    end

end

Shared.LinkClassToMap("ClipWeapon", ClipWeapon.kMapName, networkVars)
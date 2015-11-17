// Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Onos.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Gore attack should send players flying (doesn't have to be ragdoll). Stomp will stun
// marines in range and blow up mines.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/Weapons/Alien/Gore.lua")
Script.Load("lua/Weapons/Alien/BoneShield.lua")
Script.Load("lua/Alien.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/CelerityMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/BabblerClingMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/OnosVariantMixin.lua")

class 'Onos' (Alien)

Onos.kMapName = "onos"
Onos.kModelName = PrecacheAsset("models/alien/onos/onos.model")
Onos.kViewModelName = PrecacheAsset("models/alien/onos/onos_view.model")

local kOnosAnimationGraph = PrecacheAsset("models/alien/onos/onos.animation_graph")

local kChargeStart = PrecacheAsset("sound/NS2.fev/alien/onos/wound_serious")

local kRumbleSound = PrecacheAsset("sound/NS2.fev/alien/onos/rumble")

Onos.kJumpForce = 20
Onos.kJumpVerticalVelocity = 8

Onos.kJumpRepeatTime = .25
Onos.kViewOffsetHeight = 2.5
Onos.XExtents = .7
Onos.YExtents = 1.2
Onos.ZExtents = .4
Onos.kMass = 453 // Half a ton
Onos.kJumpHeight = 1.15

// triggered when the momentum value has changed by this amount (negative because we trigger the effect when the onos stops, not accelerates)
Onos.kMomentumEffectTriggerDiff = 3

Onos.kGroundFrictionForce = 3

// used for animations and sound effects
Onos.kMaxSpeed = 7.5
Onos.kChargeSpeed = 11.5

Onos.kHealth = kOnosHealth
Onos.kArmor = kOnosArmor
Onos.kChargeEnergyCost = kChargeEnergyCost

Onos.kChargeUpDuration = 0.5
Onos.kChargeDelay = 1.0

// mouse sensitivity scalar during charging
Onos.kChargingSensScalar = 0

Onos.kStoopingCheckInterval = 0.3
Onos.kStoopingAnimationSpeed = 2
Onos.kYHeadExtents = 0.7
Onos.kYHeadExtentsLowered = 0.0

local kAutoCrouchCheckInterval = 0.4

if Server then
    Script.Load("lua/Onos_Server.lua")
elseif Client then
    Script.Load("lua/Onos_Client.lua")
end

local networkVars =
{
    directionMomentum = "private float",
    stooping = "boolean",
    stoopIntensity = "compensated interpolated float",
    charging = "private boolean",
    rumbleSoundId = "entityid",
    timeOfLastPhase = "private time",
    modelsize = "float (0 to 10 by .1)",
    gravity = "float (-5 to 5 by 1)",

}

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(CelerityMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(BabblerClingMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(OnosVariantMixin, networkVars)

function Onos:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kOnosFov })
    
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, OnosVariantMixin)
    
    if Client then
    
        InitMixin(self, RailgunTargetMixin)
        self.boneShieldCrouchAmount = 0

        
    end
    
    self.directionMomentum = 0
    
    self.altAttack = false
    self.stooping = false
    self.charging = false
    self.stoopIntensity = 0
    self.timeLastCharge = 0
    self.timeLastChargeEnd = 0
    self.chargeSpeed = 0
    
    if Client then
        self:SetUpdates(true)
    elseif Server then
    
        self.rumbleSound = Server.CreateEntity(SoundEffect.kMapName)
        self.rumbleSound:SetAsset(kRumbleSound)
        self.rumbleSound:SetParent(self)
        self.rumbleSound:Start()
        self.rumbleSoundId = self.rumbleSound:GetId()
        
    end
    self.modelsize = 1
    self.gravity = 1
end

function Onos:OnInitialized()

    Alien.OnInitialized(self)
    
    self:SetModel(Onos.kModelName, kOnosAnimationGraph)
    
    self:AddTimedCallback(Onos.UpdateStooping, Onos.kStoopingCheckInterval)
    
    if Client then
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
    end
    
    InitMixin(self, IdleMixin)

end

function Onos:GetControllerPhysicsGroup()

    if self.isHallucination then
        return PhysicsGroup.SmallStructuresGroup
    end

    return PhysicsGroup.BigPlayerControllersGroup
    
end

function Onos:GetAcceleration()
    return 6.5
end

function Onos:GetAirControl()
    return 4
end
function Onos:ModifyGravityForce(gravityTable)

    if self:GetIsOnGround() then
        gravityTable.gravity = 0
   elseif self.gravity ~= 1 and not self:GetIsOnGround() then
        gravityTable.gravity = self.gravity
    end

end
function Onos:GetGroundFriction()
    return 6
end

function Onos:GetCarapaceSpeedReduction()
    return kOnosCarapaceSpeedReduction
end

function Onos:GetCrouchShrinkAmount()
    return 0.4
end

function Onos:GetExtentsCrouchShrinkAmount()
    return 0.4
end

function Onos:GetIsCharging()
    return self.charging
end

function Onos:GetCanJump()

    local weapon = self:GetActiveWeapon()
    local stomping = weapon and HasMixin(weapon, "Stomp") and weapon:GetIsStomping()

    return Alien.GetCanJump(self) and not stomping
    
end

function Onos:GetPlayFootsteps()
    return self:GetVelocityLength() > .75 and self:GetIsOnGround() and self:GetIsAlive()
end

function Onos:GetCanCrouch()
    return Alien.GetCanCrouch(self) and not self.charging
end

function Onos:GetChargeFraction()
    return ConditionalValue(self.charging, math.min(1, (Shared.GetTime() - self.timeLastCharge) / Onos.kChargeUpDuration ), 0)
end

local function TriggerMomentumChangeEffects(entity, surface, direction, normal, extraEffectParams)

    if Client and math.abs(direction:GetLengthSquared() - 1) < 0.001 then
    
        local tableParams = { }
        
        tableParams[kEffectFilterDoerName] = entity:GetClassName()
        tableParams[kEffectSurface] = ConditionalValue(type(surface) == "string" and surface ~= "", surface, "metal")
        
        local coords = Coords.GetIdentity()
        coords.origin = entity:GetOrigin()
        coords.zAxis = direction
        coords.yAxis = normal
        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        
        tableParams[kEffectHostCoords] = coords
        
        // Add in extraEffectParams if specified
        if extraEffectParams then
        
            for key, element in pairs(extraEffectParams) do
                tableParams[key] = element
            end
            
        end
        
        GetEffectManager():TriggerEffects("momentum_change", tableParams)
        
    end
    
end

function Onos:EndCharge()

    local surface, normal = GetSurfaceAndNormalUnderEntity(self)

    // align zAxis to player movement
    local moveDirection = self:GetVelocity()
    moveDirection:Normalize()
    
    TriggerMomentumChangeEffects(self, surface, moveDirection, normal)
    
    self.charging = false
    self.chargeSpeed = 0
    self.timeLastChargeEnd = Shared.GetTime()

end

function Onos:PreUpdateMove(input, runningPrediction)

    // determines how manuverable the onos is. When not charging, manuverability is 1.
    // when charging it goes towards zero as the speed increased. At zero, you can't strafe or change
    // direction.
    // The math.sqrt makes you drop manuverability quickly at the start and then drop it less and less
    // the 0.8 cuts manuverability to zero before the max speed is reached
    // Fiddle until it feels right.
    // 0.8 allows about a 90 degree turn in atrium, ie you can start charging
    // at the entrance, and take the first two stairs before you hit the lockdown.
    local manuverability = ConditionalValue(self.charging, math.max(0, 0.8 - math.sqrt(self:GetChargeFraction())), 1)
    
    if self.charging then
    
        // fiddle here to determine strafing
        input.move.x = input.move.x * math.max(0.3, manuverability)
        input.move.z = 1
        
        self:DeductAbilityEnergy(Onos.kChargeEnergyCost * input.time)
        
        // stop charging if out of energy, jumping or we have charged for a second and our speed drops below 4.5
        // - changed from 0.5 to 1s, as otherwise touchin small obstactles orat started stopped you from charging
        if self:GetEnergy() == 0 or
           self:GetIsJumping() or
          (self.timeLastCharge + 1 < Shared.GetTime() and self:GetVelocity():GetLengthXZ() < 4.5) then
        
            self:EndCharge()
            
        end
        
    end
    
    if self.autoCrouching then
        self.crouching = self.autoCrouching
    end
    /*
    if Client and self == Client.GetLocalPlayer() and not GetHasTech(self, kTechId.UpgradedCharge) then
    
        // Lower mouse sensitivity when charging, only affects the local player.
        Client.SetMouseSensitivityScalarX(manuverability)
        
    end
    */
end
function Onos:OnAdjustModelCoords(modelCoords)
    modelCoords.origin = modelCoords.origin - modelCoords.zAxis * 0.55
    local coords = modelCoords
	local scale = self.modelsize
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    return coords
end
function Onos:GetAngleSmoothRate()
    return 5
end

function Onos:GetVelocitySmoothRate()
    return 8
end

function Onos:PostUpdateMove(input, runningPrediction)

    if self.charging then
    
        local xzSpeed = self:GetVelocity():GetLengthXZ()
        if xzSpeed > self.chargeSpeed then
            self.chargeSpeed = xzSpeed
        end    
    
    end

end

function Onos:GetAirFriction()
    return 0.28
end
function Onos:GetMaxShieldAmount()
    return self:GetBaseHealth() * 0.40
end
function Onos:TriggerCharge(move)

    if not self.charging and self:GetHasMovementSpecial() and self.timeLastChargeEnd + Onos.kChargeDelay < Shared.GetTime() and self:GetIsOnGround() and not self:GetCrouching() and not self:GetIsBoneShieldActive() then

        self.charging = true
        self.timeLastCharge = Shared.GetTime()
        
        if Server and (GetHasSilenceUpgrade(self) and ConditionalValue(self.RTDSilence == true, 3, GetVeilLevel(self:GetTeamNumber())) == 0) or not GetHasSilenceUpgrade(self) then
            self:TriggerEffects("onos_charge")
        end
        
        self:TriggerUncloak()
    
    end
    
end
function Onos:HandleButtons(input)

    Alien.HandleButtons(self, input)
    
    if self:GetIsBoneShieldActive() then    
        input.move:Scale(0)    
    end

    if self.movementModiferState then    
        self:TriggerCharge(input.move)        
    else
    
        if self.charging then
            self:EndCharge()
        end
    
    end

end

// Required by ControllerMixin.
function Onos:GetMovePhysicsMask()
    return PhysicsMask.OnosMovement
end

function Onos:GetBaseArmor()
    return Onos.kArmor
end

function Onos:GetBaseHealth()
    return Onos.kHealth
end

function Onos:GetHealthPerBioMass()
    return kOnosHealtPerBioMass
end

function Onos:GetArmorFullyUpgradedAmount()
    return kOnosArmorFullyUpgradedAmount
end

function Onos:GetViewModelName()
    return self:GetVariantViewModel(self:GetVariant())
end

function Onos:GetMaxViewOffsetHeight()
    return Onos.kViewOffsetHeight
end 

/*
function Onos:GetMaxViewOffsetHeight()
    local size = self.modelsize
    if size > 2 then
    size = 2 
    end
    
    return Onos.kViewOffsetHeight * size
end
*/
function Onos:GetMaxSpeed(possible)
/*
    local size = self.modelsize
    if size > 1 then
    size = 1 
    end
    */
    if possible then
        return Onos.kMaxSpeed //* size
    end

    return ( Onos.kMaxSpeed + self:GetChargeFraction() * (Onos.kChargeSpeed - Onos.kMaxSpeed) ) //* size

end

// Half a ton
function Onos:GetMass()
    return Onos.kMass
end

function Onos:GetJumpHeight()
    return Onos.kJumpHeight
end

function Onos:GetMaxBackwardSpeedScalar()
    return 1
end

local kStoopPos = Vector(0, 2.6, 0)
function Onos:UpdateStooping(deltaTime)

    local topPos = self:GetOrigin() + kStoopPos
    topPos.y = topPos.y + Onos.kYHeadExtents
    
    local xzDirection = self:GetViewCoords().zAxis
    xzDirection.y = 0
    xzDirection:Normalize()
    
    local trace = Shared.TraceRay(topPos, topPos + xzDirection * 4, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    
    if not self.stooping and not self.crouching then

        if trace.fraction ~= 1 then
        
            local stoopPos = self:GetEyePos()
            stoopPos.y = stoopPos.y + Onos.kYHeadExtentsLowered
            
            local traceStoop = Shared.TraceRay(stoopPos, stoopPos + xzDirection * 4, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
            if traceStoop.fraction == 1 then
                self.stooping = true                
            end
            
        end    

    elseif self.stoopIntensity == 1 and trace.fraction == 1 then
        self.stooping = false
    end

    
    return true

end

function Onos:UpdateAutoCrouch(move)
 
    local moveDirection = self:GetCoords():TransformVector(move)
    
    local extents = GetExtents(kTechId.Onos)
    local startPos1 = self:GetOrigin() + Vector(0, extents.y * self:GetCrouchShrinkAmount(), 0)
    
    local frontLeft = -self:GetCoords().xAxis * extents.x - self:GetCoords().zAxis * extents.z
    local backRight = self:GetCoords().xAxis * extents.x - self:GetCoords().zAxis * extents.z
    
    local startPos2 = self:GetOrigin() + frontLeft + Vector(0, extents.y * (1 - self:GetCrouchShrinkAmount()), 0)
    local startPos3 = self:GetOrigin() + backRight + Vector(0, extents.y * (1 - self:GetCrouchShrinkAmount()), 0)

    local trace1 = Shared.TraceRay(startPos1, startPos1 + moveDirection * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    local trace2 = Shared.TraceRay(startPos2, startPos2 + moveDirection * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    local trace3 = Shared.TraceRay(startPos3, startPos3 + moveDirection * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    
    if trace1.fraction == 1 and trace2.fraction == 1 and trace3.fraction == 1 then
        self.crouching = true
        self.autoCrouching = true
    end

end

function Onos:OnUpdateAnimationInput(modelMixin)

    Alien.OnUpdateAnimationInput(self, modelMixin)
    
    if self:GetIsBoneShieldActive() then
        modelMixin:SetAnimationInput("move", "shield")
    end
    
end

function Onos:GetHasMovementSpecial()
    return self:GetHasOneHive()
end

function Onos:GetMovementSpecialEnergyCost()
    return 0
end

function Onos:GetMovementSpecialTechId()
    return kTechId.Charge
end

local function SharedUpdate(self, dt)

    if Client then
    
        local rumbleSound = Shared.GetEntity(self.rumbleSoundId)
        if rumbleSound then
            rumbleSound:SetParameter("speed", self:GetSpeedScalar(), 1)
        end
        
    end
    
end

function Onos:OnProcessMove(input)
    
    Alien.OnProcessMove(self, input)    

    if self.stooping then
        self.stoopIntensity = math.min(1, self.stoopIntensity + Onos.kStoopingAnimationSpeed * input.time)
    else
        self.stoopIntensity = math.max(0, self.stoopIntensity - Onos.kStoopingAnimationSpeed * input.time)
    end
    
    SharedUpdate(self, input.time)
    
end

function Onos:OnUpdate(dt)

    Alien.OnUpdate(self, dt)
    
    SharedUpdate(self, dt)
    
end

local function UpdateBoneShieldCrouch(self, deltaTime)

    local direction = self:GetIsBoneShieldActive() and 1 or -1

    self.boneShieldCrouchAmount = Clamp(self.boneShieldCrouchAmount + direction * deltaTime * 3, 0, 1)

end

function Onos:OnProcessIntermediate(input)

    Alien.OnProcessIntermediate(self, input)

    UpdateBoneShieldCrouch(self, input.time)
    
end

function Onos:GetIsEnergizeAllowed()
    return not self:GetIsBoneShieldActive()
end

function Onos:GetRecuperationRate()
    
    if self:GetIsBoneShieldActive() then
        return 0
    end

    return Alien.GetRecuperationRate(self)    
    
end

function Onos:OnProcessSpectate(deltaTime)

    Alien.OnProcessSpectate(self, deltaTime)

    UpdateBoneShieldCrouch(self, deltaTime)
    
end

function Onos:OnUpdatePoseParameters(viewModel)

    PROFILE("Onos:OnUpdatePoseParameters")
    
    Alien.OnUpdatePoseParameters(self, viewModel)
    
    self:SetPoseParam("stoop", self.stoopIntensity)
    
end

local kOnosHeadMoveAmount = 0
// Give dynamic camera motion to the player
function Onos:PlayerCameraCoordsAdjustment(cameraCoords)

    local camOffsetHeight = 0

    if self:GetIsFirstPerson() then
    
        if not self:GetIsJumping() then

            local movementScalar = Clamp((self:GetVelocity():GetLength() / self:GetMaxSpeed(true)), 0.0, 0.8)
            local bobbing = ( math.cos((Shared.GetTime() - self:GetTimeGroundTouched()) * 7) - 1 )
            cameraCoords.origin.y = cameraCoords.origin.y + kOnosHeadMoveAmount * movementScalar * bobbing
            
        end
        
        cameraCoords.origin.y = cameraCoords.origin.y - self.boneShieldCrouchAmount
        
    end

    return cameraCoords

end

local kOnosEngageOffset = Vector(0, 1.3, 0)
function Onos:GetEngagementPointOverride()
    return self:GetOrigin() + kOnosEngageOffset
end

local kBlockDoers =
{
    "Minigun",
    "Pistol",
    "Rifle",
    "HeavyMachineGun",
    "HeavyRifle",
    "Shotgun",
    "Axe",
    "Welder",
    "Sentry",
    "Claw"
}

local function GetHitsBoneShield(self, doer, hitPoint)

    if table.contains(kBlockDoers, doer:GetClassName()) then
    
        local viewDirection = GetNormalizedVectorXZ(self:GetViewCoords().zAxis)
        local zPosition = viewDirection:DotProduct(GetNormalizedVector(hitPoint - self:GetOrigin()))

        return zPosition > -0.1
    
    end
    
    return false

end

function Onos:GetSurfaceOverride(damage)

    if self:GetIsBoneShieldActive() and damage == 0 then
        return "none"
    end

end

function Onos:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

local damage = 1

    if doer:isa("Rifle") and GetHasTech(attacker, kTechId.HeavyRifleTech) then
    damage = damage * math.random(kOnifleDamageBonusMin, kOnifleDamageBonusMax)
  //  elseif doer:isa("MiniGun") then
  //  damage = damage * 1.07
    end
    
    if hitPoint ~= nil and self:GetIsBoneShieldActive() and GetHitsBoneShield(self, doer, hitPoint) then
    
       damage =  damage * kBoneShieldDamageReduction
        self:TriggerEffects("boneshield_blocked", {effecthostcoords = Coords.GetTranslation(hitPoint)} )
        
    end
  damageTable.damage = damageTable.damage * damage 
end

function Onos:ModifyAttackSpeed(attackSpeedTable)

    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and activeWeapon:isa("Gore") and activeWeapon:GetAttackType() == Gore.kAttackType.Smash then
        attackSpeedTable.attackSpeed = 1.35
    end

end

function Onos:GetIsBoneShieldActive()

    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and activeWeapon:isa("BoneShield") and activeWeapon.primaryAttacking then
        return true
    end    
    return false
    
end

Shared.LinkClassToMap("Onos", Onos.kMapName, networkVars)
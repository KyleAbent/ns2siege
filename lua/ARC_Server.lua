// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ARC_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// AI controllable "tank" that the Commander can move around, deploy and use for long-distance
// siege attacks.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kMoveParam = "move_speed"
local kMuzzleNode = "fxnode_arcmuzzle"
/*
function ARC:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)
local damage = 1
     if doer:isa("DotMarker") or doer:isa("Gore") then
       damage = damage - (self.level/100) * damage
    end
  damageTable.damage = damageTable.damage * damage 
end
*/
function ARC:OnEntityChange(oldId)

    if self.targetedEntity == oldId then
        self.targetedEntity = Entity.invalidId
    end    

end

function ARC:UpdateMoveOrder(deltaTime)

    local currentOrder = self:GetCurrentOrder()
    ASSERT(currentOrder)
    
    self:SetMode(ARC.kMode.Moving)  
    local scale = 1
    local moveSpeed = ( self:GetIsInCombat() or self:GetGameEffectMask(kGameEffect.OnInfestation) ) and ARC.kCombatMoveSpeed or ARC.kMoveSpeed 
    
      
    local maxSpeedTable = { maxSpeed = moveSpeed }
    self:ModifyMaxSpeed(maxSpeedTable)
    
    self:MoveToTarget(PhysicsMask.AIMovement, currentOrder:GetLocation(), maxSpeedTable.maxSpeed, deltaTime)
    
    self:AdjustPitchAndRoll()
    
    if self:IsTargetReached(currentOrder:GetLocation(), kAIMoveOrderCompleteDistance) then
    
        self:CompletedCurrentOrder()
        self:SetPoseParam(kMoveParam, 0)
        
        // If no more orders, we're done
        if self:GetCurrentOrder() == nil then
            self:SetMode(ARC.kMode.Stationary)
        end
        
    else
        self:SetPoseParam(kMoveParam, .5)
    end
    
end

// to determine the roll and the pitch of the body, we measure the roll
// at the back tracks only, then take the average of the back roll and
// a single trace at the rear of the forward track
// then we add a single trace at the front track (if we get individual
// front track pitching, we can split that into two)
ARC.kFrontFrontOffset = {1, 0 }
ARC.kFrontRearOffset = {0.3, 0 }
ARC.kLeftRearOffset = {-0.8, -0.55 }
ARC.kRightRearOffset = {-0.8, 0.55 }

ARC.kTrackTurnSpeed = math.pi
ARC.kTrackMaxSpeedAngle = math.rad(5)
ARC.kTrackNoSpeedAngle = math.rad(20)

function ARC:SmoothTurnOverride(time, direction, movespeed)

    local dirYaw = GetYawFromVector(direction)
    local myYaw = self:GetAngles().yaw
    local trackYaw = self:GetDeltaYaw(myYaw,dirYaw)

    // don't snap the tracks to our direction, need to smooth it
    local desiredTrackYaw = math.rad(Clamp(math.deg(trackYaw), -35, 35))
    local currentTrackYaw = math.rad(self.forwardTrackYawDegrees)
    local turnAmount,remainingYaw = self:CalcTurnAmount(desiredTrackYaw, currentTrackYaw, ARC.kTrackTurnSpeed, time)
    local newTrackYaw = currentTrackYaw + turnAmount

    self.forwardTrackYawDegrees = Clamp(math.deg(newTrackYaw), -35, 35)
    // if our tracks isn't positioned right, we slow down.
    return movespeed * self:CalcYawSpeedFraction(remainingYaw, ARC.kTrackMaxSpeedAngle, ARC.kTrackNoSpeedAngle)

end

function ARC:TrackTrace(origin, coords, offsets, debug)

    PROFILE("ARC:TrackTrace")

    local zOffset,xOffset = unpack(offsets)
    local pos = origin + coords.zAxis * zOffset + coords.xAxis * xOffset + Vector.yAxis
    // TODO: change to EntityFilterOne(self)
    local trace = Shared.TraceRay(pos,pos - Vector.yAxis * 2, CollisionRep.Move, PhysicsMask.Movement,  EntityFilterAll())

    return trace.endPoint
    
end

local kAngleSmoothSpeed = 0.8
local kTrackPitchSmoothSpeed = 30 // radians
function ARC:UpdateSmoothAngles(deltaTime)

    local angles = self:GetAngles()
    
    angles.pitch = Slerp(angles.pitch, self.desiredPitch, kAngleSmoothSpeed * deltaTime)
    angles.roll = Slerp(angles.roll, self.desiredRoll, kAngleSmoothSpeed * deltaTime)
    
    self:SetAngles(angles)
    
    self.forwardTrackPitchDegrees = Slerp(self.forwardTrackPitchDegrees, self.desiredForwardTrackPitchDegrees, kTrackPitchSmoothSpeed * deltaTime)

end
/*
function ARC:GetIsSiegeEnabled()
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   return true
               end
            end
            return false
end
*/
function ARC:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
function ARC:GetIsInSiege()
if string.find(self:GetLocationName(), "siege") or string.find(self:GetLocationName(), "Siege") then return true end
return false
end
function ARC:AdjustPitchAndRoll()

    // adjust our pitch. If we are moving, we trace below our front and rear wheels and set the pitch from there
    if self:GetCoords() ~= self.lastPitchCoords then
    
        self.lastPitchCoords = Coords(self:GetCoords())
        local origin = self:GetOrigin()
        local coords = self:GetCoords()
        local angles = self:GetAngles()
        
        // first, do the roll
        // the roll is based on the rear wheels only, as the model seems heavier in the back
        
        local leftRear = self:TrackTrace(origin, coords, ARC.kLeftRearOffset)
        local rightRear = self:TrackTrace(origin, coords, ARC.kRightRearOffset )
        local rearAvg = (leftRear + rightRear) / 2
        
        local rollVec = leftRear - rightRear
        rollVec:Normalize()
        local roll = GetPitchFromVector(rollVec)

        // the whole-body pitch is based on the rear and the rear of the front tracks
        
        local frontAxel =  self:TrackTrace(origin, coords, ARC.kFrontRearOffset)
        local bodyPitchVec = frontAxel - rearAvg
        bodyPitchVec:Normalize()
        local bodyPitch = GetPitchFromVector(bodyPitchVec)

        // those are set in OnUpdate and smoothed
        self.desiredPitch = bodyPitch
        self.desiredRoll = roll

        coords = self:GetCoords()
        
        // Once we have pitched the front forward, the front axel is in a new position
        frontAxel =  self:TrackTrace(origin, coords, ARC.kFrontRearOffset )
     
        local frontOfTrack = self:TrackTrace(origin, coords, ARC.kFrontFrontOffset )
        local trackPitchVec = frontAxel - frontOfTrack
        trackPitchVec:Normalize()
        local trackPitch = GetPitchFromVector(trackPitchVec) + angles.pitch
        self.desiredForwardTrackPitchDegrees = math.ceil(Clamp(math.deg(trackPitch), -35, 35) * 100) * 0.01
        
    end
    
end

function ARC:SetTargetDirection(targetPosition)
    self.targetDirection = GetNormalizedVector(targetPosition - self:GetOrigin())
end

function ARC:ClearTargetDirection()
    self.targetDirection = nil
end

function ARC:ValidateTargetPosition(position)

    // ink clouds will screw up with arcs
    local inkClouds = GetEntitiesForTeamWithinRange("ShadeInk", GetEnemyTeamNumber(self:GetTeamNumber()), position, ShadeInk.kShadeInkDisorientRadius)
    if #inkClouds > 0 then
        return false
    end

    return true

end

function ARC:UpdateOrders(deltaTime)

    // If deployed, check for targets.
    local currentOrder = self:GetCurrentOrder()
    
    if self:GetInAttackMode() then
    
        if self.targetPosition then
        
            local targetEntity = Shared.GetEntity(self.targetedEntity)
            if targetEntity then
                self.targetPosition = targetEntity:GetOrigin()
            end
            
            if self:ValidateTargetPosition(self.targetPosition) then
                self:SetTargetDirection(self.targetPosition)
            else
                self.targetPosition = nil
                self.targetedEntity = Entity.invalidId
            end
            
        else
        
            // Check for new target every so often, but not every frame.
            local time = Shared.GetTime()
            if self.timeOfLastAcquire == nil or (time > self.timeOfLastAcquire + 0.2) then
            
                self:AcquireTarget()
                self.timeOfLastAcquire = time
                
            end
            
        end
        
    elseif currentOrder then
    
        self.targetPosition = nil
        self.targetedEntity = Entity.invalidId
        
        // Move ARC if it has an order and it can be moved.
        local canMove = self.deployMode == ARC.kDeployMode.Undeployed
        if currentOrder:GetType() == kTechId.Move and canMove then
            self:UpdateMoveOrder(deltaTime)
        elseif currentOrder:GetType() == kTechId.ARCDeploy then
            self:Deploy()
        end
        
    else
        self.targetPosition = nil
        self.targetedEntity = Entity.invalidId
    end
    
end

function ARC:AcquireTarget()
    
    local finalTarget = nil
    
    finalTarget = self.targetSelector:AcquireTarget()
    
    if finalTarget ~= nil and self:ValidateTargetPosition(finalTarget:GetOrigin()) then
    
        self:SetMode(ARC.kMode.Targeting)
        self.targetPosition = finalTarget:GetOrigin()
        self.targetedEntity = finalTarget:GetId()
        
    else
    
        self:SetMode(ARC.kMode.Stationary)
        self.targetPosition = nil    
        self.targetedEntity = Entity.invalidId
        
    end
    
end

local function PerformAttack(self)

    if self.targetPosition then
    
        self:TriggerEffects("arc_firing")    
        // Play big hit sound at origin
        
        // don't pass triggering entity so the sound / cinematic will always be relevant for everyone
        GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self.targetPosition)})
        
        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self.targetPosition, ARC.kSplashRadius)
       // local damage = ARC.kAttackDamage * (self.level/100) + ARC.kAttackDamage
        // Do damage to every target in range
        RadiusDamage(hitEntities, self.targetPosition, ARC.kSplashRadius, ARC.kAttackDamage, self, true)

        // Play hit effect on each
        for index, target in ipairs(hitEntities) do
        
            if HasMixin(target, "Effects") then
                target:TriggerEffects("arc_hit_secondary")
            end 
           
        end
      // if not self:GetIsaCreditStructure() then self:AddXP(ARC.GainXP) end

      //  if self:GetIsInSiege() then self:AddXP(ARC.GainXP) end
      //self:AddXP(ARC.GainXP)
    end
    
    // reset target position and acquire new target
    self.targetPosition = nil
    self.targetedEntity = Entity.invalidId
    
end

function ARC:SetMode(mode)

    if self.mode ~= mode then
    
        local triggerEffectName = "arc_" .. string.lower(EnumToString(ARC.kMode, mode))        
        self:TriggerEffects(triggerEffectName)
        
        self.mode = mode
        
        // Now process actions per mode
        if self:GetInAttackMode() then
            self:AcquireTarget()
        end
        
    end
    
end

function ARC:GetCanReposition()
    return true
end

function ARC:OverrideRepositioningSpeed()
    return ARC.kMoveSpeed * 0.7
end

function ARC:OnTag(tagName)

    PROFILE("ARC:OnTag")
    
    if tagName == "fire_start" then
        PerformAttack(self)
    elseif tagName == "target_start" then
        self:TriggerEffects("arc_charge")
    elseif tagName == "attack_end" then
        self:SetMode(ARC.kMode.Targeting)
    elseif tagName == "deploy_start" then
        self:TriggerEffects("arc_deploying")
    elseif tagName == "undeploy_start" then
        self:TriggerEffects("arc_stop_charge")
    elseif tagName == "deploy_end" then
    
        // Clear orders when deployed so new ARC attack order will be used
        self.deployMode = ARC.kDeployMode.Deployed
        self:ClearOrders()
        // notify the target selector that we have moved.
        self.targetSelector:AttackerMoved()
        
        //self:AdjustMaxHealth(kARCDeployedHealth * self.level/100 + kARCDeployedHealth)
        
      //  local currentArmor = self:GetArmor()
      //  if currentArmor ~= 0 then
      //      self.undeployedArmor = currentArmor
      //  end
        
       // self:SetMaxArmor(kARCDeployedArmor * self.level/100 + kARCDeployedArmor)
       // self:SetArmor(self.deployedArmor)
        

        
    elseif tagName == "undeploy_end" then
    
        self.deployMode = ARC.kDeployMode.Undeployed
        
        self:AdjustMaxHealth(kARCHealth * self.level/100 + kARCHealth)
      //  self.deployedArmor = self:GetArmor()
      //  self:SetMaxArmor(kARCArmor * self.level/100 + kARCArmor)
      //  self:SetArmor(self.undeployedArmor)
        

        
    end
    
end

function ARC:AdjustPathingPitch(newLocation, pitch)

    local angles = self:GetAngles()
    angles.pitch = pitch
    self:SetAngles(angles)
    
end
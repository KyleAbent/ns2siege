Script.Load("lua/AlienStructure.lua")

// Have idle animations
Script.Load("lua/IdleMixin.lua")
// can be ordered to move along paths and uses reposition when too close to other AI units
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
// ragdolls on death
Script.Load("lua/RagdollMixin.lua")
// counts against the supply limit
Script.Load("lua/SupplyUserMixin.lua")
// is responsible for an alien upgrade tech
Script.Load("lua/UpgradableMixin.lua")

// can open doors
Script.Load("lua/DoorMixin.lua")
// have targetSelectors that needs cleanup
Script.Load("lua/TargetCacheMixin.lua")
// Can do damage
Script.Load("lua/DamageMixin.lua")
// Handle movement
Script.Load("lua/AlienStructureMoveMixin.lua")
//Script.Load("lua/ResearchMixin.lua")
local kWhipMaxLevel = 99
local kWhipScaleSize = 1.8
local kWhipXPGain = 1
local kWhipHealXPGain = 1

class 'Whip' (AlienStructure)

Whip.kMapName = "whip"

Whip.kModelName = PrecacheAsset("models/alien/whip/whip.model")
Whip.kAnimationGraph = PrecacheAsset("models/alien/whip/whip.animation_graph")

Whip.kUnrootSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/unroot")
Whip.kRootedSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/root")
Whip.kWalkingSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/walk")

local kStructureContaminationSound = PrecacheAsset("sound/NS2.fev/alien/gorge/babbler_ball_hit")

Whip.kFov = 360
Whip.kMoveSpeed = 3.5
Whip.kMaxMoveSpeedParam = 10
Whip.kWhipBallParam = "ball"



// slap data - ROF controlled by animation graph, about-ish 1 second per attack
Whip.kRange = 7
Whip.kDamage = kWhipSlapDamage

// bombard data - ROF controlled by animation graph, about 4 seconds per attack
Whip.kBombardRange = 20
Whip.kBombSpeed = 20

local networkVars =
{
    attackYaw = "interpolated integer (0 to 360)",
    
    slapping = "boolean", // true if we have started a slap attack
    bombarding = "boolean", // true if we have started a bombard attack
    rooted = "boolean",
    move_speed = "float", // used for animation speed
    
    // used for rooting/unrooting
    unblockTime = "time",
    level = "float (0 to " .. kWhipMaxLevel .. " by .1)",
}

AddMixinNetworkVars(UpgradableMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(DoorMixin, networkVars)
AddMixinNetworkVars(DamageMixin, networkVars)
AddMixinNetworkVars(AlienStructureMoveMixin, networkVars)
//AddMixinNetworkVars(ResearchMixin, networkVars)


PrecacheAsset("models/alien/whip/ball.surface_shader")

function Whip:OnCreate()

    AlienStructure.OnCreate(self)
    //ScriptActor.OnCreate(self)
    InitMixin(self, UpgradableMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DamageMixin)
    InitMixin(self, AlienStructureMoveMixin, { kAlienStructureMoveSound = Whip.kWalkingSound })
   // InitMixin(self, ResearchMixin)
    self.whipParentId = Entity.invalid
    self.attackYaw = 0
    
    self.slapping = false
    self.bombarding = false
    self.rooted = true 
    self.moving = false
    self.move_speed = 0
    //self.haslegs = false
    self.unblockTime = 0

   // to prevent collision with whip bombs
    self:SetPhysicsGroup(PhysicsGroup.WhipGroup)
    
    if Server then
        self.targetId = Entity.invalidId
        self.nextAttackTime = 0
    
    end
   self.level = 0
end

function Whip:OnInitialized()

    AlienStructure.OnInitialized(self, Whip.kModelName, Whip.kAnimationGraph)
    
    if Server then
    
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SupplyUserMixin)
        InitMixin(self, TargetCacheMixin)
  
        local targetTypes = { kAlienStaticTargets, kAlienMobileTargets }
        self.slapTargetSelector = TargetSelector():Init(self, Whip.kRange, true, targetTypes, { self.FilterTarget(self) })
     //   self.bombardTargetSelector = TargetSelector():Init(self, Whip.kBombardRange * (self.level/100) + Whip.kBombardRange, true, targetTypes)
        self.bombardTargetSelector = TargetSelector():Init(self, Whip.kBombardRange, true, targetTypes, { self.FilterTarget(self) })
        
    end
    
    InitMixin(self, DoorMixin)
    InitMixin(self, IdleMixin)
    
    self:SetUpdates(true)
    
end

function Whip:GetInfestationRadius()
    return kWhipInfestationRadius
end
function Whip:GetInfestationMaxRadius()
    return kWhipInfestationRadius
end
function Whip:GetStructureMoveable()
   return self:GetIsUnblocked()
end

function Whip:GetMaxSpeed()
    return Whip.kMoveSpeed * (self.level/100) + Whip.kMoveSpeed
end

// ---  RepositionMixin
function Whip:GetCanReposition()
    return self:GetIsBuilt()
end
function Whip:FilterTarget()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end
function Whip:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("FuncDoor") and target.health == 0 then
    return false
    end
    
    return true
    
end
function Whip:OverrideRepositioningSpeed()
    return kAlienStructureMoveSpeed * 2.5 
end

// --

// --- SleeperMixin
function Whip:GetCanSleep()
    if not self.slapping and not self.bombarding and not self.moving then return true end
end

function Whip:GetMinimumAwakeTime()
    return 10
end
// ---

// CQ: Is this needed? Used for LOS, but with 360 degree FOV...
function Whip:GetFov()
    return Whip.kFov
end
function Whip:GetAddXPAmount()
return self:GetIsSetup() and kWhipHealXPGain * 4 or kWhipHealXPGain
end
function Whip:GetIsSetup()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and not gameRules:GetFrontDoorsOpen() then 
                   return true
               end
            end
        end
            return false
end
function Whip:GetIsSiege()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   return true
               end
            end
        end
            return false
end
function Whip:OnTakeDamage(damage, attacker, doer, point)
if not self:GetIsSiege() and self:GetIsBuilt() and attacker and attacker:GetTeamNumber() == 1 then
self:AddXP(kWhipXPGain/100)
end
end

// --- DamageMixin
function Whip:GetShowHitIndicator()
    return false
end

// CQ: This should be something that everyone that can damage anything must implement, DamageMixin?
function Whip:GetDeathIconIndex()
    return kDeathMessageIcon.Whip
end

// --- UnitStatusMixin
function Whip:OverrideHintString(hintString)

        return "WHIP_BOMBARD_HINT"
    
end

// --- LOSMixin
function Whip:OverrideVisionRadius()
    // a whip sees as far as a player
    return kPlayerLOSDistance
end


// --- ModelMixin
function Whip:OnUpdatePoseParameters()

    local yaw = self.attackYaw
    if yaw >= 135 and yaw <= 225 then
        // we will be using the bombard_back animation which rotates through
        // 135 to 225 degrees using 225 to 315. Yea, screwed up.
        yaw = 90 + yaw
    end
    
    self:SetPoseParam("attack_yaw", yaw)
    self:SetPoseParam("move_speed", self.move_speed)
    
        self:SetPoseParam(Whip.kWhipBallParam, 1.0)
      //  self:SetPoseParam(Whip.kWhipBallParam, 0)
    
end

function Whip:OnUpdateAnimationInput(modelMixin)

    PROFILE("Whip:OnUpdateAnimationInput")  
    
    local activity = "none"

    if self.slapping then
        activity = "primary"
    elseif self.bombarding then
        activity = "secondary"
    end
    
    // use the back attack animation (both slap and bombard) for this range of yaw 
    local useBack = self.attackYaw > 135 and self.attackYaw < 225

    modelMixin:SetAnimationInput("use_back", useBack)    
    modelMixin:SetAnimationInput("activity", activity)
    modelMixin:SetAnimationInput("rooted", self.rooted)
    modelMixin:SetAnimationInput("move", self.moving and "run" or "idle")
    
end
// --- end ModelMixin

// --- LiveMixin
function Whip:GetCanGiveDamageOverride()
    // whips can hurt you
    return true
end

// CQ: EyePos seems to be somewhat hackish; used in several places but not owned anywhere... predates Mixins
function Whip:GetEyePos()
    return self:GetOrigin() + self:GetCoords().yAxis * 1.8
end
function Whip:OnOverrideOrder(order)
    if order:GetType() == kTechId.Default then
            order:SetType(kTechId.Move)

    end
end

function Whip:GetTechButtons(techId)
//    local commander = GetCommander(self:GetTeamNumber())
    local techButtons = nil

    techButtons = { kTechId.None, kTechId.None, None, kTechId.WhipBombard,  
                    kTechId.Slap, kTechId.None, kTechId.None, kTechId.Digest }
    if not self.moving then
     techButtons[1] = kTechId.Move  
    elseif self.moving then
     techButtons[1] = kTechId.Stop
     end
    return techButtons
    
end

function Whip:OnResearchComplete(researchId)

    if researchId == kTechId.Digest then
        self:TriggerEffects("digest", {effecthostcoords = self:GetCoords()} )
        self:Kill()
    end
        
end

function Whip:GetTechAllowed(techId, techNode, player)
    
    local allowed, canAfford = AlienStructure.GetTechAllowed(self, techId, techNode, player)
    
    if techId == kTechId.Stop then
        allowed = self:GetCurrentOrder() ~= nil
    end
    
    if techId == kTechId.Attack then
        allowed = self:GetIsBuilt() and self.rooted == true
    end

    return allowed and self:GetIsUnblocked(), canAfford
end
function Whip:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if techId == kTechId.StructureContamination then
    success = self:TriggerContamination()
    end
    return success, true
    
 end
function Whip:TriggerContamination()
    CreateEntity(Contamination.kMapName,  self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
    Shared.PlayPrivateSound(self, kStructureContaminationSound, nil, 1.0, self:GetOrigin())   
    return true
end
function Whip:GetVisualRadius()

    local slapRange = LookupTechData(self:GetTechId(), kVisualRange, nil)
 //   if self:GetHasUpgrade(kTechId.WhipBombard) then
      //  return { slapRange, Whip.kBombardRange * (self.level/100) + Whip.kBombardRange }
      return { slapRange, Whip.kBombardRange }
 //   end
    
  //  return slapRange
    
end
function Whip:GetLevel()
        return Round(self.level, 2)
end
function Whip:GetLevelPercentage()
return self.level / kWhipMaxLevel * kWhipScaleSize
end
function Whip:GetMaxLevel()
return kWhipMaxLevel
end
function Whip:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, kWhipMaxLevel - self.level)
        self.level = self.level + xpReward
   
      self:AdjustMaxHealth(kWhipHealth * (self.level/100) + kWhipHealth) 
      self:AdjustMaxArmor(kWhipArmor * (self.level/100) + kWhipArmor)
          
    return xpReward
    
end
/*
function Whip:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
    if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end
*/
function Whip:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Level %s Whip"), self:GetLevel())
return unitName
end

// --- end CommanderInterface

// --- Whip specific
function Whip:GetIsRooted()
     return self.rooted
end

function Whip:GetIsUnblocked()
    return self.unblockTime == 0 or (Shared.GetTime() > self.unblockTime)
end
function Whip:CheckSpaceAboveForJump()

    local startPoint = self:GetOrigin() 
    local endPoint = startPoint + Vector(1.2, 1.2, 1.2)
    
    return GetWallBetween(startPoint, endPoint, self)
    
end

function Whip:OnUpdate(deltaTime)

    PROFILE("Whip:OnUpdate")
    AlienStructure.OnUpdate(self, deltaTime)
       
    
    if Server then 
   
   /*
           if not self.timeLastMoveUpdateCheck or self.timeLastMoveUpdateCheck + 15 < Shared.GetTime() then 
            if self:CheckSpaceAboveForJump() then 
            self:MoveToUnstuck()
            end
            self.timeLastMoveUpdateCheck = Shared.GetTime()
        end
       */ 
        self:UpdateRootState()           
        self:UpdateOrders(deltaTime)
        
        // CQ: move_speed is used to animate the whip speed.
        // As GetMaxSpeed is constant, this just toggles between 0 and fixed value depending on moving
        // Doing it right should probably involve saving the previous origin and calculate the speed
        // depending on how fast we move
        self.move_speed = self.moving and ( self:GetMaxSpeed() / Whip.kMaxMoveSpeedParam ) or 0

    end  
    /*
        if self.CheckModelCoords == nil or (Shared.GetTime() > self.CheckModelCoords + 90) then
    self:UpdateModelCoords()
    self:UpdatePhysicsModel()
    if (self._modelCoords and self.boneCoords and self.physicsModel) then
    self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
    end      
    self.CheckModelCoords = Shared.GetTime()
    end
    */
end


// syncronize the whip_attack_start effect from the animation graph
if Client then

    function Whip:OnTag(tagName)

        PROFILE("ARC:OnTag")
        
        if tagName == "attack_start" then
            self:TriggerEffects("whip_attack_start")        
        end
        
    end

end
//whip_server.lua start

if Server then
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Whip_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================


// reset attack if we don't get an end-tag from the animation inside this time
local kAttackTimeout = 10
local kWhipAttackScanInterval = 0.33
local kSlapAfterBombardTimeout = 2
local kBombardAfterBombardTimeout = 5.3
local kAttackYawTurnRate = 120 // degrees/sec

Script.Load("lua/Ballistics.lua")

function Whip:PreOnKill(attacker, doer, point, direction)
if self.level ~= 1 then self.level = 1 end
end
function Whip:UpdateOrders(deltaTime)

    if GetIsUnitActive(self) then
        
        self:UpdateAttack(deltaTime)
        
    end
    
end
function Whip:OnTeleport()
    
end
function Whip:OnEntityChange(oldId, newId)

    if oldId ~= nil and newId == nil then
    
        if oldId == self.targetId then
            self.targetId = Entity.invalidId
        end
 
   end
    
end
function Whip:OnTeleportEnd()
        local contamination = GetEntitiesWithinRange("Contamination", self:GetOrigin(), kInfestationRadius) 
        if contamination then self:Root() end
end
function Whip:PerformAction(techNode, position)

    local success = false
    
    if techNode:GetTechId() == kTechId.Cancel or techNode:GetTechId() == kTechId.Stop then
    
        self:ClearOrders()
        success = true

    end
    
    return success
    
end


//
// --- Attack block
//
function Whip:UpdateAttack(deltaTime)
    local now = Shared.GetTime()
    
    local target = Shared.GetEntity(self.targetId)
    if target then
        // leaving tracking target for later... the other stuff works
        // self:TrackTarget(target, deltaTime)
    end

    if not self.nextAttackScanTime or now > self.nextAttackScanTime then
        self:UpdateAttacks()
    end
    
    if self.attackStartTime and now > self.attackStartTime + kAttackTimeout then
        Log("%s: started attack more than %s seconds ago, anim graph bug? Reset...", self, kAttackTimeout)
        self:EndAttack()
    end
   
end

function Whip:UpdateAttacks()

    if self:GetCanStartSlapAttack() then
        local newTarget = self:TryAttack(self.slapTargetSelector)
        self.nextAttackScanTime = Shared.GetTime() + kWhipAttackScanInterval
        if newTarget then
            self:FaceTarget(newTarget)
            self.targetId = newTarget:GetId()
            self.slapping = true
            self.bombarding = false
        end
    end
    
    if self:GetCanStartBombardAttack() then
        local newTarget = self:TryAttack(self.bombardTargetSelector)
        self.nextAttackScanTime = Shared.GetTime() + kWhipAttackScanInterval
        if newTarget then
            self:FaceTarget(newTarget)
            self.targetId = newTarget:GetId()
            self.bombarding = true
            self.slapping = false;
        end
    end

end

function Whip:UpdateRootState()

    local infested = self:GetGameEffectMask(kGameEffect.OnInfestation)
    local moveOrdered = self:GetCurrentOrder() and self:GetCurrentOrder():GetType() == kTechId.Move //or self:GetCurrentOrder():GetType() == kTechId.Follow
    // unroot if we have a move order or infestation recedes
    if self.rooted and (moveOrdered or not infested) then
        self:Unroot()
    end
    
    // root if on infestation and not moving/teleporting
    if not self.rooted and infested and not (moveOrdered or self:GetIsTeleporting()) then
        self:Root()
    end
    
end
function Whip:Root()

    StartSoundEffectOnEntity(Whip.kRootedSound, self)
    
    self:AttackerMoved() // reset target sel

    self.rooted = true
    self:SetBlockTime(0.5)
    
    self:EndAttack()
    
    return true
    
end
function Whip:SetBlockTime(interval)

    assert(type(interval) == "number")
    assert(interval > 0)
    
    self.unblockTime = Shared.GetTime() + interval
    
end
function Whip:Unroot()

    StartSoundEffectOnEntity(Whip.kUnrootSound, self)
    
    self.rooted = false
    self:SetBlockTime(0.5)
    self:EndAttack()
    self.attackStartTime = nil
    
    return true
    
end

function Whip:GetCanStartSlapAttack()

    if self.slapping or self.bombarding or not self.rooted or self:GetIsOnFire() then
        return false
    end
        
    // if we are in the aftermath of a long attack (ie, bombarding) and enough time has passed, we can try slapping    
    if self.waitingForEndAttack and self.attackStartTime and Shared.GetTime() > self.attackStartTime + kSlapAfterBombardTimeout then
        return true            
    end
    
    return not self.waitingForEndAttack

end

function Whip:GetCanStartBombardAttack()

    if self.slapping or self.bombarding or not self.rooted or self:GetIsOnFire() then
        return false
    end
    
    if self.waitingForEndAttack or self.bombarding or self.slapping then
        return false
    end
    
    // because bombard attacks can be terminated early, we have a second check to avoid premature bombardment
    if self.bombardAttackStartTime and Shared.GetTime() < self.bombardAttackStartTime + kBombardAfterBombardTimeout then
        return false
    end
    
    return true

end


function Whip:TryAttack(selector)

    // prioritize hitting the already targeted entity, if possible
    local target = Shared.GetEntity(self.targetId) 
    if target and selector:ValidateTarget(target) then
        return target
    end
    return selector:AcquireTarget()

end


local function AvoidSector(yaw, low, high)
    local mid = low + (high - low) / 2
    local result = 0
    if yaw > low and yaw < mid then
        result = low - yaw
    end
    if yaw >= mid and yaw < high then
        result = high - yaw
    end
    return result
end

//
// figure out the best combo of attack yaw and view yaw to use aginst the given target.
// returns viewYaw,attackYaw
//
function Whip:CalcTargetYaws(target)

    local point = target:GetEngagementPoint()

    // Note: The whip animation is screwed up
    // attack animation: valid for 270-90 degrees.
    // attack_back : valid for 135-225 using poseParams 225-315
    // bombard : valid for 270-90 degrees
    // bombard_back : covers the 135-225 degree area using poseParams 225-315
    // No valid attack animation covers the 90-135 and 225-270 angles - they are "dead"
    // To avoid the dead angles, we lerp the view angle at half the attack yaw rate
    
    // the attack_yaw we calculate here is the actual angle to be attacked. The pose_params
    // attack_yaw will be transformed to cover it correctly. OnUpdateAnimationInput handles
    // switching animations by use_back 

    // Update our attackYaw to aim at our current target
    local attackDir = GetNormalizedVector(point - self:GetModelOrigin())
    
    // the animation rotates the wrong way, mathemathically speaking
    local attackYawRadians = -math.atan2(attackDir.x, attackDir.z)
    
    // Factor in the orientation of the whip.
    attackYawRadians = attackYawRadians + self:GetAngles().yaw
    
    /*
    local angles2 = self:GetAngles()
    local p1 = self:GetModelOrigin()
    local c = angles2:GetCoords()
    DebugLine(p1, p1 + c.zAxis * 2, 5, 0, 1, 0, 1)
    angles2.yaw = self:GetAngles().yaw - attackYawRadians
    c = angles2:GetCoords()
    DebugLine(p1, p1 + c.zAxis * 2, 5, 1, 0, 0, 1)
    */
    
    local attackYawDegrees = DegreesTo360(math.deg(attackYawRadians), true)
    //Log("%s: attackYawDegrees %s, view angle deg %s", self, attackYawDegrees, DegreesTo360(math.deg(self:GetAngles().yaw)))
    
    // now figure out any adjustments needed in viewYaw to keep out of the bad animation zones
    local viewYawAdjust = AvoidSector(attackYawDegrees, 90,135)
    if viewYawAdjust == 0 then 
        viewYawAdjust = AvoidSector(attackYawDegrees, 225, 270)
    end
    
    attackYawDegrees = attackYawDegrees - viewYawAdjust
    viewYawAdjust = math.rad(viewYawAdjust)
    
    
    return  viewYawAdjust, attackYawDegrees

end

// Note: Non-functional; intended to adjust the angle of the model to keep
// facing the target, but not important enough to spend time on for 267
function Whip:TrackTarget(target, deltaTime)

    local point = target:GetEngagementPoint()

    // we can't adjust attack yaw after the attack has started, as that will change what animation is run and thus screw
    // the generation of hit tags. Instead, we rotate the whole whip so the attack will be towards the target
    
    local dir2Target = GetNormalizedVector(point - self:GetModelOrigin())
    
    local yaw2Target = -math.atan2(dir2Target.x, dir2Target.z)
    
    local attackYaw = math.rad(self.attackYaw)
    local desiredYaw = yaw2Target - attackYaw
    
    local angles = self:GetAngles()
    angles.yaw = desiredYaw
    // think about slerping later
    Log("%s: Tracking to %s", self, desiredYaw)
    // self:SetAngles(angles)
        
end
function Whip:FaceTarget(target)

    local viewYawAdjust, attackYaw = self:CalcTargetYaws(target)
    local angles = self:GetAngles()

    angles.yaw = angles.yaw + viewYawAdjust
    self:SetAngles(angles)
    
    self.attackYaw = attackYaw
   
end


function Whip:AttackerMoved()

    self.slapTargetSelector:AttackerMoved()
    self.bombardTargetSelector:AttackerMoved()

end

//
// Slap attack
//
function Whip:SlapTarget(target)
    self:FaceTarget(target)
    // where we hit
    local targetPoint = target:GetEngagementPoint()
    local attackOrigin = self:GetEyePos()
    local hitDirection = targetPoint - attackOrigin
    hitDirection:Normalize()
    // fudge a bit - put the point of attack 0.5m short of the target
    local hitPosition = targetPoint - hitDirection * 0.5
    
    self:DoDamage(kWhipSlapDamage, target, hitPosition, hitDirection, nil, true)
    self:TriggerEffects("whip_attack")
    self:StealFlamethrower(target)
    

end

//
// Bombard attack
//
function Whip:BombardTarget(target)
    self:FaceTarget(target)
    // This seems to fail completly; we get really weird values from the Whip_Ball point, 
    local bombStart,success = self:GetAttachPointOrigin("Whip_Ball")
    if not success then
        Log("%s: no Whip_Ball point?", self)
        bombStart = self:GetOrigin() + Vector(0,1,0);
    end
   
    local targetPos = target:GetEngagementPoint()
    
    local direction = Ballistics.GetAimDirection(bombStart, targetPos, Whip.kBombSpeed)
    if direction then
        self:FlingBomb(bombStart, targetPos, direction, Whip.kBombSpeed)
    end

end

function Whip:FlingBomb(bombStart, targetPos, direction, speed)

    local bomb = CreateEntity(WhipBomb.kMapName, bombStart, self:GetTeamNumber())
    
    // For callback purposes so we can adjust our aim
    bomb.intendedTargetPosition = targetPos
    bomb.shooter = self
    bomb.shooterEntId = self:GetId()
    
    SetAnglesFromVector(bomb, direction)

    local startVelocity = direction * speed
    bomb:Setup( self:GetOwner(), startVelocity, true, nil, self)
    
    // we set the lifetime so that if the bomb does not hit something, it still explodes in the general area. Good for hunting jetpackers.
    bomb:SetLifetime(self:CalcLifetime(bombStart, targetPos, startVelocity))
    
end

function Whip:CalcLifetime(bombStart, targetPos, startVelocity)

    local xzRange = (targetPos - bombStart):GetLengthXZ()
    local xzVelocity = Vector(startVelocity)
    xzVelocity.y = 0
    xzVelocity:Normalize()
    xzVelocity = xzVelocity:DotProduct(startVelocity)
    
    // Lifetime is enough to reach target + small random amount.
    local lifetime = xzRange / xzVelocity + math.random() * 0.2 
    
    return lifetime
    
end


// --- End BombardAttack

// --- Attack animation handling

function Whip:OnAttackStart() 

    // attack animation has started, so the attack has started
    if HasMixin(self, "Cloakable") then
        self:TriggerUncloak() 
    end

    if self.bombarding then
        self:TriggerEffects("whip_bombard")
    end
    self.attackStartTime = Shared.GetTime()
    
end
//self:GiveUpgrade(kTechId.WhipBombard)

function Whip:CreateFTAtAttachPointandFlickIt()

    local bombStart = self:GetAttachPointOrigin("Whip_Ball")
    //if not success then
    //    Log("%s: no Whip_Ball point?", self)
    //    bombStart = self:GetOrigin() + Vector(0,1,0);
   // end
    
local flamethrower = CreateEntity(Flamethrower.kMapName, bombStart + Vector(0,1,0), 1)


end

  function Whip:StealFlamethrower(target)      
                if target:isa("Marine") or target:isa("JetpackMarine") then 
                     local client = target:GetClient()
                     if not client then return end
                     local controlling = client:GetControllingPlayer()
                  if controlling:GetWeaponInHUDSlot(1) ~= nil and controlling:GetWeaponInHUDSlot(1):isa("Flamethrower") then
                     local roll = math.random(1,100)
                  if roll <=30 then
                    DestroyEntity(controlling:GetWeaponInHUDSlot(1))
                    if controlling:GetWeaponInHUDSlot(2) ~= nil then
                     controlling:SwitchWeapon(2)
                     else
                      controlling:SwitchWeapon(3)
                      end //
                       self:CreateFTAtAttachPointandFlickIt()
                       
                  end//
                end//
              end//
  end
                   

function Whip:OnAttackHit(target)

    if target and self.slapping then
        if not self:GetIsOnFire() and self.slapTargetSelector:ValidateTarget(target) then
            self:SlapTarget(target) 
           self:AddXP(kWhipXPGain)  
        end                        
    end
    
    if target and self.bombarding then
        if not self:GetIsOnFire() and self.bombardTargetSelector:ValidateTarget(target) then
            self:BombardTarget(target)
            self:AddXP(kWhipXPGain)   
        end        
    end
    // Stop trigger new attacks
    self.slapping = false
    self.bombarding = false    
    // mark that we are waiting for the end of an attack
    self.waitingForEndAttack = true
    
end

function Whip:EndAttack()

    // unblock the next attack
    self.attackStartTime = nil
    self.targetId = Entity.invalidId
    self.waitingForEndAttack = false;

    self:UpdateAttacks()

end


function Whip:OnTag(tagName)

    PROFILE("Whip:OnTag")
   
    local target = Shared.GetEntity(self.targetId)
    
    /*
    if tagName ~= "start" and tagName ~= "end" then
        Log("%s : %s for target %s, slapping %s, bombarding %s", self, tagName, target, self.slapping, self.bombarding)
    end
    */
    if tagName == "hit" then
        self:OnAttackHit(target)
    end

    if tagName == "slap_start" then
        self:OnAttackStart(target)                
    end

    if tagName == "slap_end" then
        self:EndAttack()
    end

    if tagName == "bombard_start" then
        self.bombardAttackStartTime = Shared.GetTime()
        self:OnAttackStart(target)                 
    end            

    if tagName == "bombard_end" then
      // we are only allowed to end our own attack - if a slap-attack has started, we must not terminate it early
      if self.bombardAttackStartTime == self.attackStartTime and not self.slapping then
          self:EndAttack()
      end
    end            

 end

 function Whip:OnOwnerChanged(oldOwner, newOwner)
    self.whipParentId = Entity.invalidId
    if newOwner ~= nil then
        self.whipParentId = newOwner:GetId()
    end
    
 end
 
 
 function Whip:GetCanBeUsedConstructed(byPlayere)
return true //byPlayere:isa("Gorge")
end
function Whip:OnUse(player, elapsedTime, useSuccessTable)

      player:SetHUDSlotActive(2)
      
              local weapon = player:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
        weapon:SetActiveStructure(6)
        end
end

function Whip:OnConstructionComplete()
       local commander = self:GetTeam():GetCommander()
       if commander ~= nil then
       commander:AddScore(1) 
       end
end

// --- End attack animation
end //end of whip_server.lua

Shared.LinkClassToMap("Whip", Whip.kMapName, networkVars, true)
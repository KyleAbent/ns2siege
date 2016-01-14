// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Gorge.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/Alien.lua")
Script.Load("lua/Weapons/Alien/SpitSpray.lua")
Script.Load("lua/Weapons/Alien/InfestationAbility.lua")
Script.Load("lua/Weapons/Alien/DropStructureAbility.lua")
Script.Load("lua/Weapons/Alien/BabblerAbility.lua")
Script.Load("lua/Weapons/Alien/BileBomb.lua")
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
Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/GorgeVariantMixin.lua")
Script.Load("lua/WallMovementMixin.lua")

class 'Gorge' (Alien)

if Server then    
    Script.Load("lua/Gorge_Server.lua")
end

local networkVars =
{
    wallWalking = "compensated boolean",
    timeLastWallWalkCheck = "private compensated time",
    bellyYaw = "private float",
    timeSlideEnd = "private time",
    startedSliding = "private boolean",
    sliding = "boolean",
    hasBellySlide = "private boolean",    
    timeOfLastPhase = "private time",
    modelsize = "float (0 to 10 by .1)",
           gravity = "float (-5 to 5 by 1)",
        gorgeusingLerkID = "entityid",
    isriding = "boolean",
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
AddMixinNetworkVars(GorgeVariantMixin, networkVars)

Gorge.kMapName = "gorge"
Gorge.kLerkAttachPoint = "fxnode_bilebomb"
Gorge.kModelName = PrecacheAsset("models/alien/gorge/gorge.model")
local kViewModelName = PrecacheAsset("models/alien/gorge/gorge_view.model")
local kGorgeAnimationGraph = PrecacheAsset("models/alien/gorge/gorge.animation_graph")

Gorge.kSlideLoopSound = PrecacheAsset("sound/NS2.fev/alien/gorge/slide_loop")
Gorge.kBuildSoundInterval = .5
Gorge.kBuildSoundName = PrecacheAsset("sound/NS2.fev/alien/gorge/build")

Gorge.kXZExtents = 0.5
Gorge.kYExtents = 0.475

local kMass = 80
local kJumpHeight = 1.2
local kStartSlideSpeed = 9.2
local kViewOffsetHeight = 0.6
local kMaxGroundSpeed = 6
local kMaxSlidingSpeed = 14
local kSlidingMoveInputScalar = 0.1
local kBuildingModeMovementScalar = 0.001

local kNormalWallWalkFeelerSize = 0.25
local kNormalWallWalkRange = 0.3
local kJumpWallRange = 0.4
local kJumpWallFeelerSize = 0.1
local kWallJumpInterval = 0.4
local kWallJumpForce = 5.2 // scales down the faster you are
local kMinWallJumpForce = 0.1
local kVerticalWallJumpForce = 4.3


Gorge.kAirZMoveWeight = 2.5
Gorge.kAirStrafeWeight = 2.5
Gorge.kAirBrakeWeight = 0.1

local kGorgeBellyYaw = "belly_yaw"
local kGorgeLeanSpeed = 2

function Gorge:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kGorgeFov })
    InitMixin(self, GorgeVariantMixin)
    InitMixin(self, WallMovementMixin)
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, TunnelUserMixin)
    
    InitMixin(self, PredictedProjectileShooterMixin)
    
    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
    
    self.bellyYaw = 0
    self.timeSlideEnd = 0
    self.startedSliding = false
    self.sliding = false
    self.verticalVelocity = 0
    self.modelsize = 1
    self.gravity = 0
    
    self.wallWalking = false
    self.wallWalkingNormalGoal = Vector.yAxis
    self.timeLastWallJump = 0
    self.gorgeusingLerkID = Entity.invalidI
    self.isriding = false
end

function Gorge:OnInitialized()

    Alien.OnInitialized(self)
    self.currentWallWalkingAngles = Angles(0.0, 0.0, 0.0)
    self:SetModel(Gorge.kModelName, kGorgeAnimationGraph)

    if Server then
    
        self.slideLoopSound = Server.CreateEntity(SoundEffect.kMapName)
        self.slideLoopSound:SetAsset(Gorge.kSlideLoopSound)
        self.slideLoopSound:SetParent(self)
        
    elseif Client then
    
        self:AddHelpWidget("GUIGorgeHealHelp", 2)
        self:AddHelpWidget("GUIGorgeBellySlideHelp", 2)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
    end
    
    InitMixin(self, IdleMixin)
    self.timeLastWallJump = 0
end

function Gorge:GetAirControl()
    return 5
end

function Gorge:GetCarapaceSpeedReduction()
    return kGorgeCarapaceSpeedReduction
end

if Client then

    function Gorge:GetHealthbarOffset()
        return 0.7
    end  

    function Gorge:OverrideInput(input)

        // Always let the DropStructureAbility override input, since it handles client-side-only build menu

        local buildAbility = self:GetWeapon(DropStructureAbility.kMapName)

        if buildAbility then
            input = buildAbility:OverrideInput(input)
        end
        
        return Player.OverrideInput(self, input)
        
    end
    
end

function Gorge:GetBaseArmor()
    return kGorgeArmor
end
function Gorge:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self.modelsize
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    return coords
end
function Gorge:GetBaseHealth()
    return kGorgeHealth
end

function Gorge:GetHealthPerBioMass()
    return kGorgeHealthPerBioMass
end

function Gorge:GetArmorFullyUpgradedAmount()
    return kGorgeArmorFullyUpgradedAmount
end

function Gorge:GetMaxViewOffsetHeight()
   // local size = self.modelsize
   // if size > 2 then
   // size = 2 
   // end
    return kViewOffsetHeight //* size
end
function Gorge:GetExtentsOverride()
//if self.modelsize < 1 then
  //  return Vector(Gorge.kXZExtents * self.modelsize, Gorge.kYExtents * self.modelsize, Gorge.kXZExtents * self.modelsize)
  //else
      return Vector(Gorge.kXZExtents, Gorge.kYExtents, Gorge.kXZExtents)
 // end
end
function Gorge:GetCrouchShrinkAmount()
    return 0
end

function Gorge:GetExtentsCrouchShrinkAmount()
    return 0
end
function Gorge:GetMovePhysicsMask()
    return PhysicsMask.AlienNonOnos
end
function Gorge:GetViewModelName()
    return self:GetVariantViewModel(self:GetVariant())
end

function Gorge:GetJumpHeight()
    return kJumpHeight
end

function Gorge:GetIsBellySliding()
    return self.sliding
end

function Gorge:GetCanJump()
    local canWallJump = self:GetCanWallJump()
    return self:GetIsOnGround() or canWallJump
end
function Gorge:GetIsWallWalking()
    return self.wallWalking
end
function Gorge:GetIsWallWalkingPossible() 
    return not self:GetRecentlyJumped() and not self:GetCrouching()
end
local function PredictGoal(self, velocity)

    PROFILE("Gorge:PredictGoal")

    local goal = self.wallWalkingNormalGoal
    if velocity:GetLength() > 1 and not self:GetIsGround() then

        local movementDir = GetNormalizedVector(velocity)
        local trace = Shared.TraceCapsule(self:GetOrigin(), movementDir * 2.5, Skulk.kXExtents, 0, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))

        if trace.fraction < 1 and not trace.entity then
            goal = trace.normal    
        end

    end

    return goal

end
local function GetIsSlidingDesired(self, input)

    if bit.band(input.commands, Move.MovementModifier) == 0 then
        return false
    end
    
    if self.crouching then
        return false
    end
    
    if not self:GetHasMovementSpecial() then
        return false
    end
    
    if self:GetVelocity():GetLengthXZ() < 3 or self:GetIsJumping() then
    
        if self:GetIsBellySliding() then    
            return false
        end 
           
    else
        
        local zAxis = self:GetViewCoords().zAxis
        zAxis.y = 0
        zAxis:Normalize()
        
        if GetNormalizedVectorXZ(self:GetVelocity()):DotProduct( zAxis ) < 0.2 then
            return false
        end
    
    end
    
    return true

end

// Handle transitions between starting-sliding, sliding, and ending-sliding
local function UpdateGorgeSliding(self, input)

    PROFILE("Gorge:UpdateGorgeSliding")
    
    local slidingDesired = GetIsSlidingDesired(self, input)
    if slidingDesired and not self.sliding and self:GetIsOnGround() and not self:GetIsOnLadder() and self:GetEnergy() >= kBellySlideCost and not self:GetIsWallWalking() then
    
        self.sliding = true
        self.startedSliding = true
        
        if Server then
            if (GetHasSilenceUpgrade(self) and ConditionalValue(self.RTDSilence == true, 3, GetVeilLevel(self:GetTeamNumber())) == 0) or not GetHasSilenceUpgrade(self) then
                self.slideLoopSound:Start()
            end
        end
        
        self:DeductAbilityEnergy(kBellySlideCost)
        self:PrimaryAttackEnd()
        self:SecondaryAttackEnd()
        
    end
    
    if not slidingDesired and self.sliding then
    
        self.sliding = false
        
        if Server then
            self.slideLoopSound:Stop()
        end
        
        self.timeSlideEnd = Shared.GetTime()
    
    end

    // Have Gorge lean into turns depending on input. He leans more at higher rates of speed.
    if self:GetIsBellySliding() then

        local desiredBellyYaw = 2 * (-input.move.x / kSlidingMoveInputScalar) * (self:GetVelocity():GetLength() / self:GetMaxSpeed())
        self.bellyYaw = Slerp(self.bellyYaw, desiredBellyYaw, input.time * kGorgeLeanSpeed)
        
    end
    
end
function Gorge:GetRecentlyWallJumped()
    return self.timeLastWallJump + kWallJumpInterval > Shared.GetTime()
end

function Gorge:GetCanWallJump()

    local wallWalkNormal = self:GetAverageWallWalkingNormal(kJumpWallRange, kJumpWallFeelerSize)
    if wallWalkNormal and self:GetHasThreeHives() then
        return wallWalkNormal.y < 0.5
    end
    
    return false

end
function Gorge:GetAirFriction()
    return 0.8
end
function Gorge:GetMaxShieldAmount()
    return self:GetBaseHealth() * 0.63
end
function Gorge:GetCanRepairOverride(target)
    return true
end

function Gorge:HandleButtons(input)

    PROFILE("Gorge:HandleButtons")
    
    Alien.HandleButtons(self, input)
    
    UpdateGorgeSliding(self, input)
    
end

function Gorge:OnUpdatePoseParameters(viewModel)

    PROFILE("Gorge:OnUpdatePoseParameters")
    
    Alien.OnUpdatePoseParameters(self, viewModel)
    
    self:SetPoseParam(kGorgeBellyYaw, self.bellyYaw * 45)
    
end

function Gorge:SetCrouchState(newCrouchState)
    self.crouching = newCrouchState
end

function Gorge:GetMaxSpeed(possible)
 /*
    local size = self.modelsize
    if size > 1 then
    size = 1 
    end
   */ 
    if possible then return kMaxGroundSpeed end //* size end
    
    local maxspeed = kMaxGroundSpeed
    if self:GetIsWallWalking() then
        maxspeed = maxspeed - 1
    end
    
    if self.movementModiferState then
        maxspeed = maxspeed * 0.5
    end
    
    return maxspeed //* size
    
end


function Gorge:ModifyGravityForce(gravityTable)

    if self:GetIsWallWalking() and not self:GetCrouching() or self.isriding or self:GetIsOnGround() then
        gravityTable.gravity = 0
    end
        if self.gravity ~= 0 then
        gravityTable.gravity = self.gravity
    end
    
end
function Gorge:GetIsSiege()
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

function Gorge:GetCanBeUsed(player, useSuccessTable)
if  not player:isa("Lerk") then useSuccessTable.useSuccess = false return end
 if ( self.isriding and self.gorgeusingLerkID == player:GetId() ) or not self.isriding then useSuccessTable.useSuccess = true end
end
function Gorge:OnUse(player, elapsedTime, useSuccessTable)
  
       
      if player.isoccupied == false then
     player.isoccupied = true 
    self.gorgeusingLerkID = player:GetId()
    player.lerkcarryingGorgeId = self:GetId()
     self.isriding = true
    else
     player.isoccupied = false
     self.gorgeusingLerkID = Entity.invalidI
     player.lerkcarryingGorgeId = Entity.invalidI
     self.isriding = false
     self:SetOrigin(player:GetOrigin())
     end
       
       
end

function Gorge:ModifyJump(input, velocity, jumpVelocity)

    if self:GetCanWallJump() then
    
        local direction = input.move.z == -1 and -1 or 1
    
        // we add the bonus in the direction the move is going
        local viewCoords = self:GetViewAngles():GetCoords()
        self.bonusVec = viewCoords.zAxis * direction
        self.bonusVec.y = 0
        self.bonusVec:Normalize()
        
        jumpVelocity.y = 3 + math.min(1, 1 + viewCoords.zAxis.y) * 2

        local celerityMod = (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * 0.4
        local currentSpeed = velocity:GetLengthXZ()
        local fraction = 1 - Clamp( currentSpeed / (11 + celerityMod), 0, 1)        
        
        local force = math.max(kMinWallJumpForce, (kWallJumpForce + celerityMod) * fraction)
          
        self.bonusVec:Scale(force)      

        if not self:GetRecentlyWallJumped() then
        
            self.bonusVec.y = viewCoords.zAxis.y * kVerticalWallJumpForce
            jumpVelocity:Add(self.bonusVec)

        end
        
        self.timeLastWallJump = Shared.GetTime()
        
    end
    
end
function Gorge:GetPerformsVerticalMove()
    return self:GetIsWallWalking()
end
function Gorge:OverrideUpdateOnGround(onGround)
    return onGround or self:GetIsWallWalking()
end
function Gorge:GetMaxBackwardSpeedScalar()
    return 0.5
end

function Gorge:GetAcceleration()
    return self:GetIsBellySliding() and 0 or 8
end

function Gorge:GetGroundFriction()
    
    if self:GetIsBellySliding() then
        return self:GetGameEffectMask(kGameEffect.OnInfestation) and 0.068 or 0.2
    end

    return 7
    
end

function Gorge:GetMass()
    return kMass
end

function Gorge:OnUpdateAnimationInput(modelMixin)

    PROFILE("Gorge:OnUpdateAnimationInput")
    
    Alien.OnUpdateAnimationInput(self, modelMixin)
    
    if self:GetIsBellySliding() then
        modelMixin:SetAnimationInput("move", "belly")
    end

end

function Gorge:GetMovementSpecialTechId()
    return kTechId.BellySlide
end

function Gorge:GetHasMovementSpecial()
    return true // self.hasBellySlide or self:GetTeamNumber() == kTeamReadyRoom
end

function Gorge:ModifyVelocity(input, velocity, deltaTime)
    
    // Give a little push forward to make sliding useful
    if self.startedSliding then
    
        if self:GetIsOnGround() then
        /*
        local size = self.modelsize
    if size > 1 then
    size = 1 
    end
    */
            local pushDirection = GetNormalizedVectorXZ(self:GetViewCoords().zAxis)
            
            local currentSpeed = math.max(0, pushDirection:DotProduct(velocity))
            
            local maxSpeedTable = { maxSpeed = kStartSlideSpeed } //* size }
            self:ModifyMaxSpeed(maxSpeedTable, input)
            
            local addSpeed = math.max(0, maxSpeedTable.maxSpeed - currentSpeed)
            local impulse = pushDirection * addSpeed

            velocity:Add(impulse)
        
        end
        
        self.startedSliding = false

    end
    
    if self:GetIsBellySliding() then
    
        local currentSpeed = velocity:GetLengthXZ()
        local prevY = velocity.y
        velocity.y = 0  
        
        local addVelocity = self:GetViewCoords():TransformVector(input.move)
        addVelocity.y = 0
        addVelocity:Normalize()
        addVelocity:Scale(deltaTime * 10)
        
        velocity:Add(addVelocity) 
        velocity:Normalize()
        velocity:Scale(currentSpeed)
        velocity.y = prevY
    
    end
    
end

function Gorge:GetPitchSmoothRate()
    return 1
end

function Gorge:GetPitchRollRate()
    return 3
end

local kMaxSlideRoll = math.rad(20)

function Gorge:GetDesiredAngles()

    local desiredAngles = Alien.GetDesiredAngles(self)
    
    if self:GetIsBellySliding() then
        desiredAngles.pitch = - self.verticalVelocity / 10 
        desiredAngles.roll = GetNormalizedVectorXZ(self:GetVelocity()):DotProduct(self:GetViewCoords().xAxis) * kMaxSlideRoll
    end
   if self:GetIsWallWalking() then return self.currentWallWalkingAngles end
       return desiredAngles
end
function Gorge:GetHeadAngles()

    if self:GetIsWallWalking() then
        // When wallwalking, the angle of the body and the angle of the head is very different
        return self:GetViewAngles()
    else
        return self:GetViewAngles()
    end

end
function Gorge:GetIsUsingBodyYaw()
    return not self:GetIsWallWalking()
end

function Gorge:GetAngleSmoothingMode()

    if self:GetIsWallWalking() then
        return "quatlerp"
    else
        return "euler"
    end

end
function Gorge:OnJump()

    self.wallWalking = false

    local material = self:GetMaterialBelowPlayer()    
    local velocityLength = self:GetVelocity():GetLengthXZ()
    
    if velocityLength > 11 then
        self:TriggerEffects("jump_best", {surface = material})          
    elseif velocityLength > 8.5 then
        self:TriggerEffects("jump_good", {surface = material})       
    end

    self:TriggerEffects("jump", {surface = material})
    
end
function Gorge:OnWorldCollision(normal, impactForce, newVelocity)

    PROFILE("Gorge:OnWorldCollision")

    self.wallWalking = self:GetIsWallWalkingPossible() and normal.y < 0.5
    
end
function Gorge:HasEnoughEnergyToWallFuck()
if self:GetEnergy() < kWallWalkEnergyCost then return false end
return true
end
function Gorge:PreUpdateMove(input, runningPrediction)
    PROFILE("Gorge:PreUpdateMove")
    self.prevY = self:GetOrigin().y
        if self:GetCrouching() then
        self.wallWalking = false
    end

    if self.wallWalking then

        // Most of the time, it returns a fraction of 0, which means
        // trace started outside the world (and no normal is returned)           
        local goal = self:GetAverageWallWalkingNormal(kNormalWallWalkRange, kNormalWallWalkFeelerSize)
        if goal ~= nil and self:GetHasThreeHives() then //and not self:GetEnergy() < kWallWalkEnergyCost then 
        
            self.wallWalkingNormalGoal = goal
            self.wallWalking = true
            self:SetEnergy(self:GetEnergy() - kWallWalkEnergyCost)

        else
            self.wallWalking = false
        end
    
    end
    
    if not self:GetIsWallWalking() then
        // When not wall walking, the goal is always directly up (running on ground).
        self.wallWalkingNormalGoal = Vector.yAxis
    end
    
    	if self.isriding then 
	 	local drifter = Shared.GetEntity( self.drifterId ) 
	 	 if drifter then
	   //    if not drifter:GetIsAlive() then self.isriding = false self.drifterId = Entity.invalidI return end 
	    	local offset = drifter:GetOrigin() + Vector(0,.5,0)
	 	   self:SetOrigin(offset)
           if not self:GetOrigin() == offset then self:SetOrigin(offset) SetMoveForHitregAnalysis(input)  end
         else
             local lerk = Shared.GetEntity(self.gorgeusingLerkID)
             if lerk then
         	       if not lerk then self.isriding = false self.gorgeusingLerkID = Entity.invalidI return end 
         	       local origin = lerk:GetOrigin() + Vector(0,.5,0)
	 	           self.fullPrecisionOrigin = origin
	 	          self:SetOrigin(origin)
                  if not self:GetOrigin() == origin then self:SetOrigin(origin)  end
                  SetMoveForHitregAnalysis(input)
             end
         end
   end
   
   

  //  if self.leaping and Shared.GetTime() > self.timeOfLeap + kLeapTime then
  //      self.leaping = false
  //  end
    
    self.currentWallWalkingAngles = self:GetAnglesFromWallNormal(self.wallWalkingNormalGoal or Vector.yAxis) or self.currentWallWalkingAngles


end
function Gorge:GetMoveSpeedIs2D()
    return not self:GetIsWallWalking()
end
function Gorge:GetCanStep()
    return not self:GetIsWallWalking()
end

function Gorge:PostUpdateMove(input, runningPrediction)

    if self:GetIsBellySliding() and self:GetIsOnGround() then
    
        local velocity = self:GetVelocity()
    
        local yTravel = self:GetOrigin().y - self.prevY
        local xzSpeed = velocity:GetLengthXZ()
        
        xzSpeed = xzSpeed + yTravel * -4
        
        if xzSpeed < kMaxSlidingSpeed or yTravel > 0 then
        
            local directionXZ = GetNormalizedVectorXZ(velocity)
            directionXZ:Scale(xzSpeed)

            velocity.x = directionXZ.x
            velocity.z = directionXZ.z
            
            self:SetVelocity(velocity)
            
        end

        self.verticalVelocity = yTravel / input.time
    
    end

end

if Client then

    function Gorge:GetShowGhostModel()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetShowGhostModel()
        end
        
        return false
        
    end
    
    function Gorge:GetGhostModelOverride()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") and weapon.GetGhostModelName then
            return weapon:GetGhostModelName(self)
        end
        
    end
    
    function Gorge:GetGhostModelTechId()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetGhostModelTechId()
        end
        
    end
    
    function Gorge:GetGhostModelCoords()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetGhostModelCoords()
        end
        
    end
    
    function Gorge:GetLastClickedPosition()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon.lastClickedPosition
        end
        
    end

    function Gorge:GetIsPlacementValid()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetIsPlacementValid()
        end
    
    end

    function Gorge:GetIgnoreGhostHighlight()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") and weapon.GetIgnoreGhostHighlight then
            return weapon:GetIgnoreGhostHighlight()
        end
        
    end  

end

function Gorge:GetCanSeeDamagedIcon(ofEntity)
    return not ofEntity:isa("Cyst")
end

function Gorge:GetCanAttack()
    return Alien.GetCanAttack(self) and not self:GetIsBellySliding()
end

function Gorge:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, 0.28, 0)
end

if Server then

    function Gorge:OnProcessMove(input)
    
        Alien.OnProcessMove(self, input)
        
        self.hasBellySlide = GetIsTechAvailable(self:GetTeamNumber(), kTechId.BellySlide) == true or GetGamerules():GetAllTech()
    
    end

end


Shared.LinkClassToMap("Gorge", Gorge.kMapName, networkVars, true)
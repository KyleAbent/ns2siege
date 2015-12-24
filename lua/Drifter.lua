// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Drifter.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// AI controllable glowing insect that the alien commander can control.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/DoorMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/UpgradableMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/MobileTargetMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/SoftTargetMixin.lua")
Script.Load("lua/StormCloudMixin.lua")
Script.Load("lua/UmbraMixin.lua")

Script.Load("lua/CommAbilities/Alien/EnzymeCloud.lua")
Script.Load("lua/CommAbilities/Alien/HallucinationCloud.lua")
Script.Load("lua/CommAbilities/Alien/MucousMembrane.lua")
Script.Load("lua/CommAbilities/Alien/StormCloud.lua")
Script.Load("lua/ResearchMixin.lua")
class 'Drifter' (ScriptActor)

Drifter.kMapName = "drifter"

Drifter.kModelName = PrecacheAsset("models/alien/drifter/drifter.model")
Drifter.kAnimationGraph = PrecacheAsset("models/alien/drifter/drifter.animation_graph")

Drifter.kEggModelName = PrecacheAsset("models/alien/drifter/drifter.model") // PrecacheAsset("models/alien/cocoon/cocoon.model") 
Drifter.kEggAnimationGraph = PrecacheAsset("models/alien/drifter/drifter.animation_graph") // PrecacheAsset("models/alien/cocoon/cocoon.animation_graph")

Drifter.kOrdered2DSoundName = PrecacheAsset("sound/NS2.fev/alien/drifter/ordered_2d")
Drifter.kOrdered3DSoundName = PrecacheAsset("sound/NS2.fev/alien/drifter/ordered")

local kDrifterConstructSound = PrecacheAsset("sound/NS2.fev/alien/drifter/drift")
local kDrifterMorphing = PrecacheAsset("sound/NS2.fev/alien/commander/drop_structure")

Drifter.kMoveSpeed = 11
Drifter.kHealth = kDrifterHealth
Drifter.kArmor = kDrifterArmor
            
Drifter.kCapsuleHeight = .05
Drifter.kCapsuleRadius = .5
Drifter.kStartDistance = 5
Drifter.kHoverHeight = 1.2

Drifter.kEnzymeRange = 22
Drifter.kMaxLevel = 50
Drifter.kMaxScale = 1.7
Drifter.AddXpCommander = 0.25
Drifter.AddXpConstruct = 0.0140625

local kDrifterSelfOrderRange = 12

Drifter.kFov = 360

Drifter.kTurnSpeed = 1.8 * math.pi
Drifter.kStormCloudTurnSpeed = 2.5 * math.pi

// Control detection of drifters from enemy team units.
local kDetectInterval = 0.5
local kDetectRange = 1.5

local kTrailCinematicNames =
{
    PrecacheAsset("cinematics/alien/drifter/trail1.cinematic"),
    PrecacheAsset("cinematics/alien/drifter/trail2.cinematic"),
    PrecacheAsset("cinematics/alien/drifter/trail3.cinematic"),
}

local kTrailFadeOutCinematicNames =
{
    PrecacheAsset("cinematics/alien/drifter/trail_fadeout.cinematic"),
}

local networkVars =
{
    // 0-1 scalar used to set move_speed model parameter according to how fast we recently moved
    moveSpeed = "float",
    moveSpeedParam = "compensated float",
    camouflaged = "boolean",
    hasCamouflage = "boolean",
    hasCelerity = "boolean",
    hasRegeneration = "boolean",
    canUseAbilities = "boolean",
    constructing = "boolean",
    level = "float (0 to " .. Drifter.kMaxLevel .. " by .1)",
    issoccupied = "boolean",
    playerId = "entityid",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(UpgradableMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(StormCloudMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)

function Drifter:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, DoorMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, UpgradableMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, FireMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, CloakableMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, SoftTargetMixin)
    InitMixin(self, StormCloudMixin)
    InitMixin(self, UmbraMixin)
    InitMixin(self, ResearchMixin)
    
    self:SetUpdates(true)
    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
    if Server then
        self:UpdateIncludeRelevancyMask()
    elseif Client then
        InitMixin(self, UnitStatusMixin)
    end
    self.level = 0
    self.isoccupied = false
    self.playerId = Entity.invalidI
    
    self.moveSpeed = 0
    self.moveSpeedParam = 0
    self.moveYaw = 0
    
end

function Drifter:OnInitialized()

    self.moveSpeed = 0
    self.moveSpeedParam = 0
    self.moveYaw = 0

    ScriptActor.OnInitialized(self)
    
    if Server then
    
        self:SetUpdates(true)
        self:UpdateIncludeRelevancyMask()
        
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SleeperMixin)
        InitMixin(self, MobileTargetMixin)
        InitMixin(self, SupplyUserMixin)
        
        self.canUseAbilities = true
        self.timeAbilityUsed = 0
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        self:SetModel(Drifter.kEggModelName, Drifter.kEggAnimationGraph)
        
    elseif Client then
    
        InitMixin(self, CommanderGlowMixin) 
    
        self.trailCinematic = Client.CreateTrailCinematic(RenderScene.Zone_Default)
        self.trailCinematic:SetCinematicNames(kTrailCinematicNames)
        self.trailCinematic:SetFadeOutCinematicNames(kTrailFadeOutCinematicNames)
        self.trailCinematic:AttachTo(self, TRAIL_ALIGN_MOVE,  Vector(0, 0.3, -0.9))
        self.trailCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.trailCinematic:SetOptions( {
                numSegments = 8,
                collidesWithWorld = false,
                visibilityChangeDuration = 1.2,
                fadeOutCinematics = true,
                stretchTrail = false,
                trailLength = 3.5,
                minHardening = 0.1,
                maxHardening = 0.3,
                hardeningModifier = 0,
                trailWeight = 0.0
            } )
    
    end
    
end
function Drifter:GetLevelPercentage()
return self.level / Drifter.kMaxLevel * Drifter.kMaxScale
end
function Drifter:GetMaxLevel()
return Drifter.kMaxLevel
end
/*
function Drifter:OnAdjustModelCoords(modelCoords)
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
function Drifter:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, Drifter.kMaxLevel - self.level)
        self.level = self.level + xpReward
   
                   self:AdjustMaxHealth(kDrifterHealth * (self.level/100) + kDrifterHealth) 
        self:AdjustMaxArmor(kDrifterArmor * (self.level/100) + kDrifterArmor )
        
    return xpReward
    
end
function Drifter:GetLevel()
        return Round(self.level, 2)
end
  function Drifter:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Level %s Drifter"), self:GetLevel())
return unitName
end 
function Drifter:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if Client then
    
        if self.trailCinematic then
            Client.DestroyTrailCinematic(self.trailCinematic)
        end 

        if self.playingConstructSound then
        
            Shared.StopSound(self, kDrifterConstructSound)  
            self.playingConstructSound = false 
            
        end
        
    end
    
end

function Drifter:GetTurnSpeedOverride()
    return self.stormCloudSpeed and Drifter.kStormCloudTurnSpeed or Drifter.kTurnSpeed
end

function Drifter:SetIncludeRelevancyMask(includeMask)

    includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)    
    ScriptActor.SetIncludeRelevancyMask(self, includeMask)    

end

function Drifter:GetCanSleep()
    return self:GetCurrentOrder() == nil
end

function Drifter:GetExtentsOverride()
    return Vector(Drifter.kCapsuleRadius, Drifter.kCapsuleHeight / 2, Drifter.kCapsuleRadius)
end

function Drifter:GetIsFlying()
    return true
end

function Drifter:GetHoverHeight()    
    return Drifter.kHoverHeight
end

function Drifter:GetDeathIconIndex()
    return kDeathMessageIcon.None
end

local function PlayOrderedSounds(self)

    StartSoundEffectOnEntity(Drifter.kOrdered3DSoundName, self)
    
    local commanders = GetEntitiesForTeam("Commander", self:GetTeamNumber())
    local currentComm = commanders and commanders[1] or nil
    
    if currentComm then
        Server.PlayPrivateSound(currentComm, Drifter.kOrdered2DSoundName, currentComm, 1.0, Vector(0, 0, 0))
    end
    
end

local function IsBeingGrown(self, target)

    if target.hasDrifterEnzyme then
        return true
    end

    for _, drifter in ipairs(GetEntitiesForTeam("Drifter", target:GetTeamNumber())) do
    
        if self ~= drifter then
        
            local order = drifter:GetCurrentOrder()
            if order and order:GetType() == kTechId.Grow then
            
                local growTarget = Shared.GetEntity(order:GetParam())
                if growTarget == target then
                    return true
                end
            
            end
        
        end
    
    end

    return false

end

local function FindTask(self)

    // find ungrown structures 
    for _, structure in ipairs(GetEntitiesWithMixinForTeamWithinRange("Construct", self:GetTeamNumber(), self:GetOrigin(), kDrifterSelfOrderRange)) do
    
        if not structure:GetIsBuilt() and not IsBeingGrown(self, structure) and (not structure.GetCanAutoBuild or structure:GetCanAutoBuild()) then      
  
            self:GiveOrder(kTechId.Grow, structure:GetId(), structure:GetOrigin(), nil, false, false)
            return  
      
        end
    
    end

        for _, ball in ipairs(GetEntitiesForTeamWithinRange("BabblerPheromone", self:GetTeamNumber(), self:GetOrigin(), 20)) do
            
            if ball:GetOwner().drifterId == self:GetId() and (ball:GetOrigin() - self:GetOrigin()):GetLength() > 4 then
                self:GiveOrder(kTechId.Move, ball:GetId(), ball:GetOrigin(), nil, false, false)
            end    
    
        end
end

function Drifter:OnOverrideOrder(order)

    local orderTarget = nil
    
    if order:GetParam() ~= nil then
        orderTarget = Shared.GetEntity(order:GetParam())
    end
    
    local orderType = order:GetType()
    
    if orderType == kTechId.Default or orderType == kTechId.Grow or orderType == kTechId.Move then

        if orderTarget and HasMixin(orderTarget, "Construct") and not orderTarget:GetIsBuilt() and GetAreFriends(self, orderTarget) and not IsBeingGrown(self, orderTarget) and (not orderTarget.GetCanAutoBuild or orderTarget:GetCanAutoBuild()) then    
            order:SetType(kTechId.Grow)
        elseif orderTarget and orderTarget:isa("Alien") and orderTarget:GetIsAlive() then
            order:SetType(kTechId.Follow)
        else
            order:SetType(kTechId.Move)
        end
    
    end
    
    if GetAreEnemies(self, orderTarget) then
        order.orderParam = -1
    end
    
    PlayOrderedSounds(self)
    
end

function Drifter:ResetOrders(resetOrigin, clearOrders)

    if resetOrigin then
    
        if self.oldLocation ~= nil then
            self:SetOrigin(self.oldLocation)
        else
            self:SetOrigin(self:GetOrigin() + Vector(0, self:GetHoverHeight(), 0))
        end
        
    end
    
    self:SetIgnoreOrders(false)
    
    if clearOrders then
        self:ClearOrders()
    end
    
    self.oldLocation = nil
    
end

// for marquee selection
function Drifter:GetIsMoveable()
    return true
end

function Drifter:ProcessMoveOrder(moveSpeed, deltaTime)

    local currentOrder = self:GetCurrentOrder()
    
    if currentOrder ~= nil then
    
        local hoverAdjustedLocation = currentOrder:GetLocation()
        
        if self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, moveSpeed, deltaTime) or (self:GetOrigin() - hoverAdjustedLocation):GetLengthXZ() < 0.5 then 

            if currentOrder:GetType() == kTechId.Move then
            
                self:CompletedCurrentOrder()
            
            // doesnt work with queued orders yet,    
            elseif currentOrder:GetType() == kTechId.Patrol then
            
                local prevTarget = currentOrder:GetLocation()
                local prevOrigin = currentOrder:GetOrigin()
                
                currentOrder:SetLocation(prevOrigin)
                currentOrder:SetOrigin(prevTarget)

            end    
                
        end
        
    end
    
end

function Drifter:ProcessFollowOrder(moveSpeed, deltaTime)

    local currentOrder = self:GetCurrentOrder()
    
    if currentOrder ~= nil then
    
        local destination = currentOrder:GetLocation()
        if (self:GetOrigin() - destination):GetLengthXZ() > 7.5 then
            self:MoveToTarget(PhysicsMask.AIMovement, destination, moveSpeed, deltaTime)
        end
        
    end
    
end

function Drifter:GetEngagementPointOverride()
    return self:GetOrigin()
end

local function GetCommander(teamNum)
    local commanders = GetEntitiesForTeam("Commander", teamNum)
    return commanders[1]
end
function Drifter:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
                return locationName
end
function Drifter:ProcessGrowOrder(moveSpeed, deltaTime)

    local currentOrder = self:GetCurrentOrder()
    
    if currentOrder ~= nil then
    
        local target = Shared.GetEntity(currentOrder:GetParam())
        
        if not target or target:GetIsBuilt() or not target:GetIsAlive() then        
            self:CompletedCurrentOrder()
        else
        
            local targetPos = target:GetOrigin()  
            local toTarget = targetPos - self:GetOrigin()
                // Continuously turn towards the target. But don't mess with path finding movement if it was done.

            if (toTarget):GetLength() > 3 then
                self:MoveToTarget(PhysicsMask.AIMovement, targetPos, moveSpeed, deltaTime)
            else
            
                if toTarget then
                    self:SmoothTurn(deltaTime, GetNormalizedVector(toTarget), 0)
                end
            
                target:RefreshDrifterConstruct(1 * (self.level/100) + 1)
                self:AddXP(Drifter.AddXpConstruct)
                self.constructing = true
            end

        end
    
    end

end

function Drifter:ProcessEnzymeOrder(moveSpeed, deltaTime)

    local currentOrder = self:GetCurrentOrder()
    
    if currentOrder ~= nil then
    
        local targetPos = currentOrder:GetLocation() + Vector(0, 0.4, 0)
        
        // check if we can reach the destinaiton
        if self:GetIsInCloudRange(targetPos) then

            local commander = GetCommander(self:GetTeamNumber())
            local techId = currentOrder:GetType()
            local cooldown = LookupTechData(techId, kTechDataCooldown, 0)
            
            if commander and cooldown ~= 0 then
            
                commander:SetTechCooldown(techId, cooldown, Shared.GetTime())
                local msg = BuildAbilityResultMessage(techId, true, Shared.GetTime())
                Server.SendNetworkMessage(commander, "AbilityResult", msg, false)   
                
            end 
            
            self:SpawnCloudAt(targetPos)
            self:CompletedCurrentOrder()
            self:TriggerUncloak()
            self.canUseAbilities = false 
            self.timeAbilityUsed = Shared.GetTime()     
            self:AddXP(Drifter.AddXpCommander)
        else
        
            // move to target otherwise
            if self:MoveToTarget(PhysicsMask.AIMovement, targetPos, moveSpeed, deltaTime) then
                self:ClearOrders()
            end
            
        end
        
    end
    
end


function Drifter:GetIsSmallTarget()
    return true
end

local function UpdateTasks(self, deltaTime)

    if not self:GetIsAlive() then
        return
    end
    
    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
    
        local maxSpeedTable = { maxSpeed = Drifter.kMoveSpeed * (self.level/100) + Drifter.kMoveSpeed }
        self:ModifyMaxSpeed(maxSpeedTable)
        local drifterMoveSpeed = maxSpeedTable.maxSpeed

        local currentOrigin = Vector(self:GetOrigin())
        
        if currentOrder:GetType() == kTechId.Move or currentOrder:GetType() == kTechId.Patrol then
            self:ProcessMoveOrder(drifterMoveSpeed, deltaTime)
        elseif currentOrder:GetType() == kTechId.Follow then
            self:ProcessFollowOrder(drifterMoveSpeed, deltaTime)     
        elseif currentOrder:GetType() == kTechId.EnzymeCloud or currentOrder:GetType() == kTechId.Hallucinate or currentOrder:GetType() == kTechId.MucousMembrane or currentOrder:GetType() == kTechId.Storm then
            self:ProcessEnzymeOrder(drifterMoveSpeed, deltaTime)
        elseif currentOrder:GetType() == kTechId.Grow then
            self:ProcessGrowOrder(drifterMoveSpeed, deltaTime)
        end
        
        // Check difference in location to set moveSpeed
        local distanceMoved = (self:GetOrigin() - currentOrigin):GetLength()
        
        self.moveSpeed = (distanceMoved / drifterMoveSpeed) / deltaTime
        
    else
    
        if not self.timeLastTaskCheck or self.timeLastTaskCheck + 2 < Shared.GetTime() then
        
            FindTask(self)
            self.timeLastTaskCheck = Shared.GetTime()
        
        end
    
    end
    
end

local function UpdateMoveYaw(self, deltaTime)

    local currentYaw = self:GetAngles().yaw
    
    if not self.lastYaw then
        self.lastYaw = currentYaw
    end
    
    if not self.moveYaw then
        self.moveYaw = 90
    end
    
    if self.lastYaw < currentYaw then
        self.moveYaw = math.max(0, self.moveYaw - 400 * deltaTime)
    elseif self.lastYaw > currentYaw then
        self.moveYaw = math.min(180, self.moveYaw + 400 * deltaTime)
    else
    
        if self.moveYaw < 90 then
            self.moveYaw = math.min(90, self.moveYaw + 200 * deltaTime)
        elseif self.moveYaw > 90 then
            self.moveYaw = math.max(90, self.moveYaw - 200 * deltaTime)   
        end
        
        self.lastYaw = currentYaw
        
    end

end

function Drifter:GetFov()
    return Drifter.kFov
end

function Drifter:GetIsCamouflaged()
    return false // self.camouflaged // and self.hasCamouflage
end

function Drifter:OnCapsuleTraceHit(entity)

    PROFILE("Drifter:OnCapsuleTraceHit")

    if GetAreEnemies(self, entity) then
        self.timeLastCombatAction = Shared.GetTime()
    end 
    
end

function Drifter:OnUpdatePoseParameters()

    PROFILE("Drifter:OnUpdatePoseParameters")
    
    self:SetPoseParam("move_speed", self.moveSpeedParam)
    self:SetPoseParam("move_yaw", 90)
    
end 

local function ScanForNearbyEnemy(self)

    // Check for nearby enemy units. Uncloak if we find any.
    self.lastDetectedTime = self.lastDetectedTime or 0
    if self.lastDetectedTime + kDetectInterval < Shared.GetTime() then
    
        if #GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kDetectRange) > 0 then
        
            self:TriggerUncloak()
            
        end
        self.lastDetectedTime = Shared.GetTime()
        
    end
    
end

function Drifter:PerformAction(techNode)

    if techNode:GetTechId() == kTechId.FollowAlien then
    
        local aliens = GetEntitiesForTeamWithinRange("Alien", self:GetTeamNumber(), self:GetOrigin(), 30)
        Shared.SortEntitiesByDistance(self:GetOrigin(), aliens)

        for i = 1, #aliens do
        
            local alien = aliens[i]
            if alien:GetIsAlive() and not alien:isa("Embryo") then
                self:GiveOrder(kTechId.Follow, alien:GetId(), alien:GetOrigin(), nil, true, true)
                break
            end
        
        end
        
    elseif techNode:GetTechId() == kTechId.HoldPosition then
        self:GiveOrder(kTechId.HoldPosition, self:GetId(), self:GetOrigin(), nil, true, true)
        return true
    end

end

function Drifter:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    
    // Blend smoothly towards target value
    self.moveSpeedParam = Clamp(Slerp(self.moveSpeedParam, self.moveSpeed, deltaTime), 0, 1)
    //UpdateMoveYaw(self, deltaTime)
    
    if Server then
    
    /*
                if self.CheckModelCoords == nil or (Shared.GetTime() > self.CheckModelCoords + 30) then
            self:UpdateModelCoords()
            self:UpdatePhysicsModel()
            if (self._modelCoords and self.boneCoords and self.physicsModel) then
            self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
            end      
            self.CheckModelCoords = Shared.GetTime()
            end
         */
        self.constructing = false
        UpdateTasks(self, deltaTime)
        
        ScanForNearbyEnemy(self)
        
        self.camouflaged = (not self:GetHasOrder() or self:GetCurrentOrder():GetType() == kTechId.HoldPosition ) and not self:GetIsInCombat()
/*
        self.hasCamouflage = GetHasTech(self, kTechId.ShadeHive) == true
        self.hasCelerity = GetHasTech(self, kTechId.ShiftHive) == true
        self.hasRegeneration = GetHasTech(self, kTechId.CragHive) == true
*/        
        if self.hasRegeneration then
        
            if self:GetIsHealable() and ( not self.timeLastAlienAutoHeal or self.timeLastAlienAutoHeal + kAlienRegenerationTime <= Shared.GetTime() ) then
            
                self:AddHealth(0.06 * self:GetMaxHealth())  
                self.timeLastAlienAutoHeal = Shared.GetTime()
                
            end    
        
        end
        
        self.canUseAbilities = self.timeAbilityUsed + kDrifterAbilityCooldown < Shared.GetTime()
        
    elseif Client then
    
        self.trailCinematic:SetIsVisible(self:GetIsMoving() and self:GetIsVisible())
        
        if self.constructing and not self.playingConstructSound then
        
            Shared.PlaySound(self, kDrifterConstructSound)
            self.playingConstructSound = true
            
        elseif not self.constructing and self.playingConstructSound then
        
            Shared.StopSound(self, kDrifterConstructSound)
            self.playingConstructSound = false
            
        end
        
    end
    
end

function Drifter:GetCanCloakOverride()
    return not self:GetHasOrder() or self:GetCurrentOrder():GetType() == kTechId.HoldPosition
end

if Client then

    function Drifter:GetIsMoving()
    
        if self.lastTimeChecked ~= Shared.GetTime() then
        
            if not self.lastPositionClient then
                self.lastPositionClient = self:GetOrigin()
            end
            
            self.movingThisFrame = (self:GetOrigin() - self.lastPositionClient):GetLength() ~= 0
            
            self.lastTimeChecked = Shared.GetTime()
            self.lastPositionClient = self:GetOrigin()
            
        end
        
        return self.movingThisFrame
        
    end
    
end

function Drifter:GetTechButtons(techId)

    local techButtons = { kTechId.EnzymeCloud, kTechId.Hallucinate, kTechId.MucousMembrane, kTechId.SelectHallucinations,
                          kTechId.Grow, kTechId.Move, kTechId.Patrol, kTechId.Digest }
/*
    if self.hasCelerity then
        techButtons[6] = kTechId.DrifterCelerity
    end
    
    if self.hasRegeneration then
        techButtons[7] = kTechId.DrifterRegeneration
    end
    
    if self.hasCamouflage then
        techButtons[8] = kTechId.DrifterCamouflage
    end
*/    
    return techButtons
    
end
function Drifter:OnResearchComplete(researchId)

    if researchId == kTechId.Digest then
        self:TriggerEffects("digest", {effecthostcoords = self:GetCoords()} )
        self:Kill()
    end
   
end
function Drifter:SpawnCloudAt(position)

    local team = self:GetTeam()
    local techId = self:GetCurrentOrder():GetType()
    local cost = GetCostForTech(techId)
    
    if cost <= team:GetTeamResources() then

        self:TriggerEffects("drifter_shoot_enzyme", {effecthostcoords = Coords.GetLookIn(self:GetOrigin(), GetNormalizedVectorXZ( position - self:GetOrigin())) } )
        
        local mapName = LookupTechData(techId, kTechDataMapName)
        if mapName then
        
            local cloudEntity = CreateEntity(mapName, position, self:GetTeamNumber())
            team:AddTeamResources(-cost)
            
        end
    
    end

end

function Drifter:GetDamagedAlertId()
    return kTechId.AlienAlertLifeformUnderAttack
end

function Drifter:GetIsInCloudRange(targetPos)

    PROFILE("Drifter:GetIsInEnzymeRange")
    
    local origin = self:GetOrigin()
    
    if (targetPos - origin):GetLength() < Drifter.kEnzymeRange then
    
        local trace = Shared.TraceRay(origin, targetPos, CollisionRep.LOS, PhysicsMask.Bullets, EntityFilterAll())            
        return trace.fraction == 1
    
    end
    
    return false

end

function Drifter:OverrideVisionRadius()
    return kPlayerLOSDistance
end

function Drifter:PerformActivation(techId, position, normal, commander)

    local success = false
    local keepProcessing = true
    
    if techId == kTechId.EnzymeCloud or techId == kTechId.Hallucinate or techId == kTechId.MucousMembrane or techId == kTechId.Storm then
    
        local team = self:GetTeam()
        local cost = GetCostForTech(techId)
        if cost <= team:GetTeamResources() then
        
            self:GiveOrder(techId, nil, position + Vector(0, 0.2, 0), nil, not commander.shiftDown, false)

            // Only 1 Drifter will process this activation.
            keepProcessing = false
            
        end
        
        // return false, team res will be drained once we reached the destination and created the enzyme entity
        success = false

    else
        return ScriptActor.PerformActivation(self, techId, position, normal, commander)
    end
    
    return success, keepProcessing
    
end

function Drifter:OnOverrideDoorInteraction(inEntity)
    return true, 4
end
function Drifter:GetCanDoorInteract(inEntity)
return false
end
function Drifter:UpdateIncludeRelevancyMask()
    SetAlwaysRelevantToCommander(self, true)
end

function Drifter:OnUpdateAnimationInput(modelMixin)

    PROFILE("Drifter:OnUpdateAnimationInput")
    
    local move = "idle"
    local currentOrder = self:GetCurrentOrder()
    if currentOrder then
        move = "run"
    end
    modelMixin:SetAnimationInput("move",  move)

    local activity = "none"
    if self.constructing then
        activity = "parasite"
    end

    modelMixin:SetAnimationInput("activity", activity)
    
end

function Drifter:OnTag(tagName)

    if self.constructing and tagName == "attack_end" then
        self:TriggerEffects("drifter_construct")
    end

end

if Server then

    function Drifter:GetCanReposition()
        return true
    end
    
    function Drifter:OverrideRepositioningSpeed()
        return 3
    end
    
    function Drifter:OverrideRepositioningDistance()
        return 0.8
    end    
    
    function Drifter:OverrideGetRepositioningTime()
        return 0.5
    end
    
end

function Drifter:GetShowHitIndicator()
    return false
end

function Drifter:PreOnKill()
    if self.occupied then 
       local gorge = Shared.GetEntity( self.playerId  ) 
       if gorge then
       gorge.isriding = false 
       gorge.drifterId = Entity.invalidI
        self.occupied = false
       end
    end
end

function Drifter:GetCanBeUsed(player, useSuccessTable)
   if not player:isa("Gorge") or ( self.isoccupied and not player.drifterId == self:GetId() ) and not Shared.GetCheatsEnabled() then
    useSuccessTable.useSuccess = false 
   else   
       useSuccessTable.useSuccess = true
    end
end
function Drifter:OnUse(player, elapsedTime, useSuccessTable)
   if not player.isriding then
    player.isriding = true 
    player.drifterId = self:GetId()
    self.isoccupied = true
    self.playerId = player:GetId()
    else
    player.isriding = false
     player.drifterId = Entity.invalidI
     self.isoccupied = false
     self.playerId = Entity.invalidI
     end
end
Shared.LinkClassToMap("Drifter", Drifter.kMapName, networkVars, true)
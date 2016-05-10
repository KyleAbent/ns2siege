--Kyle Abent
--Mac.lua Obviously by NS2 and UWE, 
--this is just renamed to "Antibody" for creative reasons. 
--IE - Easier to write creatively thinking as an "Antibody" than a "MAC" (for me anyways).

Script.Load("lua/CommAbilities/Marine/EMPBlast.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/DoorMixin.lua")
Script.Load("lua/BuildingMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/UpgradableMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
//Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/MobileTargetMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/AttackOrderMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/SoftTargetMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/WebableMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/RolloutMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")

class 'AntiBody' (ScriptActor)

AntiBody.kMapName = "mac"

AntiBody.kModelName = PrecacheAsset("models/marine/mac/mac.model")
AntiBody.kAnimationGraph = PrecacheAsset("models/marine/mac/mac.animation_graph")

AntiBody.kConfirmSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/confirm")
AntiBody.kConfirm2DSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/confirm_2d")
AntiBody.kStartConstructionSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/constructing")
AntiBody.kStartConstruction2DSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/constructing_2d")
AntiBody.kStartWeldSound = PrecacheAsset("sound/NS2.fev/marine/structures/mac/weld_start")
AntiBody.kHelpingSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/help_build")
AntiBody.kPassbyAntiBodySoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/passby_mac")
AntiBody.kPassbyDrifterSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/passby_driffter")

AntiBody.kUsedSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/use")

local kJetsCinematic = PrecacheAsset("cinematics/marine/mac/jet.cinematic")
local kJetsSound = PrecacheAsset("sound/NS2.fev/marine/structures/mac/thrusters")

local kRightJetNode = "fxnode_jet1"
local kLeftJetNode = "fxnode_jet2"
AntiBody.kLightNode = "fxnode_light"
AntiBody.kWelderNode = "fxnode_welder"

// Balance
AntiBody.kConstructRate = 0.4
AntiBody.kWeldRate = 0.5
AntiBody.kOrderScanRadius = 10
AntiBody.kRepairHealthPerSecond = 21 //15
AntiBody.kHealth = kAntiBodyHealth
AntiBody.kArmor = kAntiBodyArmor
AntiBody.kMoveSpeed = 6
AntiBody.kHoverHeight = .5
AntiBody.kStartDistance = 3
AntiBody.kWeldDistance = 2
AntiBody.kBuildDistance = 2     // Distance at which bot can start building a structure. 
AntiBody.kSpeedUpgradePercent = (1 + kMACSpeedAmount)
// how often we check to see if we are in a marines face when welding
// Note: Need to be fairly long to allow it to weld marines with backs towards walls - the AI will
// stop moving after a < 1 sec long interval, and the welding will be done in the time before it tries
// to move behind their backs again
AntiBody.kWeldPositionCheckInterval = 1 

// how fast the AntiBody rolls out of the ARC factory. Standard speed is just too fast.
AntiBody.kRolloutSpeed = 2

AntiBody.kCapsuleHeight = .2
AntiBody.kCapsuleRadius = .5

// Greetings
AntiBody.kGreetingUpdateInterval = 1
AntiBody.kGreetingInterval = 10
AntiBody.kGreetingDistance = 5
AntiBody.kUseTime = 2.0
AntiBody.MaxLevel = 99
AntiBody.GainXp = 0.15
AntiBody.WeldXp = 0.15
AntiBody.ScaleSize = 1.8
AntiBody.kGainXp = .5
AntiBody.kTurnSpeed = 3 * math.pi // a mac is nimble
local networkVars =
{
    welding = "boolean",
    constructing = "boolean",
    moving = "boolean",
    level = "float (0 to " .. AntiBody.MaxLevel .. " by .1)",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(UpgradableMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
//AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(AttackOrderMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(WebableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(SupplyUserMixin, networkVars)

local function GetIsWeldedByOtherAntiBody(self, target)

    if target then
    
        for _, mac in ipairs(GetEntitiesForTeam("AntiBody", self:GetTeamNumber())) do
        
            if self ~= mac then
            
                if mac.secondaryTargetId ~= nil and Shared.GetEntity(mac.secondaryTargetId) == target then
                    return true
                end
                
                local currentOrder = mac:GetCurrentOrder()
                local orderTarget = nil
                if currentOrder and currentOrder:GetParam() ~= nil then
                    orderTarget = Shared.GetEntity(currentOrder:GetParam())
                end
                
                if currentOrder and orderTarget == target and (currentOrder:GetType() == kTechId.FollowAndWeld or currentOrder:GetType() == kTechId.Weld or currentOrder:GetType() == kTechId.AutoWeld) then
                    return true
                end
                
            end
            
        end
        
    end
    
    return false
    
end

function AntiBody:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, DoorMixin)
    InitMixin(self, BuildingMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, UpgradableMixin)
    InitMixin(self, GameEffectsMixin)
    //InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, PathingMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, AttackOrderMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, SoftTargetMixin)
    InitMixin(self, WebableMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, RolloutMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, SupplyUserMixin)

        
    if Server then
        InitMixin(self, RepositioningMixin)
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self:SetUpdates(true)
    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
   self.level = .1
end

function AntiBody:OnInitialized()
    
    ScriptActor.OnInitialized(self)

    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)

    if Server then
    
        self:UpdateIncludeRelevancyMask()
        
        InitMixin(self, SleeperMixin)
        InitMixin(self, MobileTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        self.jetsSound = Server.CreateEntity(SoundEffect.kMapName)
        self.jetsSound:SetAsset(kJetsSound)
        self.jetsSound:SetParent(self)

    elseif Client then
    
        InitMixin(self, UnitStatusMixin)     
        InitMixin(self, HiveVisionMixin) 

        // Setup movement effects
        self.jetsCinematics = {}
        for index,attachPoint in ipairs({ kLeftJetNode, kRightJetNode }) do
            self.jetsCinematics[index] = Client.CreateCinematic(RenderScene.Zone_Default)
            self.jetsCinematics[index]:SetCinematic(kJetsCinematic)
            self.jetsCinematics[index]:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.jetsCinematics[index]:SetParent(self)
            self.jetsCinematics[index]:SetCoords(Coords.GetIdentity())
            self.jetsCinematics[index]:SetAttachPoint(self:GetAttachPointIndex(attachPoint))
            self.jetsCinematics[index]:SetIsActive(false)
        end

    end
    
    self.timeOfLastGreeting = 0
    self.timeOfLastGreetingCheck = 0
    self.timeOfLastChatterSound = 0
    self.timeOfLastWeld = 0
    self.timeOfLastConstruct = 0
    self.moving = false
    
    self:SetModel(AntiBody.kModelName, AntiBody.kAnimationGraph)
    
    InitMixin(self, IdleMixin)
    
end

function AntiBody:OnEntityChange(oldId)

    if oldId == self.secondaryTargetId then
    
        self.secondaryOrderType = nil
        self.secondaryTargetId = nil
        
    end
    
end

local function GetAutomaticOrder(self)

    local target = nil
    local orderType = nil

    if self.timeOfLastFindSomethingTime == nil or Shared.GetTime() > self.timeOfLastFindSomethingTime + 1 then

        local currentOrder = self:GetCurrentOrder()
        local primaryTarget = nil
        if currentOrder and currentOrder:GetType() == kTechId.FollowAndWeld then
            primaryTarget = Shared.GetEntity(currentOrder:GetParam())
        end

        if primaryTarget and ( HasMixin(primaryTarget, "Weldable") and primaryTarget:GetWeldPercentage() < .8 ) then
            
            target = primaryTarget
            orderType = kTechId.AutoWeld
                    
        else

            // If there's a friendly entity nearby that needs constructing, constuct it.
            local range = AntiBody.kOrderScanRadius
              range = ConditionalValue(not self:GetIsFront(), 9999, range)
            local constructable =  GetNearestMixin(self:GetOrigin(), "Construct", self:GetTeamNumber(), function(ent) return not ent:GetIsBuilt() and self:GetDistance(ent) <= range and ent:GetCanConstruct(self) and self:CheckTarget(ent:GetOrigin()) and not (not self:GetIsFront() and ent:isa("PowerPoint") ) end)
               if constructable then
                
                    target = constructable
                    orderType = kTechId.Construct
                    
                end
            if not target then
            
                // Look for entities to heal with weld.
                local weldables = GetEntitiesWithMixinForTeamWithinRange("Weldable", self:GetTeamNumber(), self:GetOrigin(), AntiBody.kOrderScanRadius)
                for w = 1, #weldables do
                
                    local weldable = weldables[w]
                    // There are cases where the weldable's weld percentage is very close to
                    // 100% but not exactly 100%. This second check prevents the AntiBody from being so pedantic.
                    if weldable:GetCanBeWelded(self) and weldable:GetWeldPercentage() < 1 and not GetIsWeldedByOtherAntiBody(self, weldable) then
                    
                        target = weldable
                        orderType = kTechId.AutoWeld
                        break

                    end
                    
                end
            
            end
        
        end

        self.timeOfLastFindSomethingTime = Shared.GetTime()

    end
    
    return target, orderType

end

function AntiBody:GetTurnSpeedOverride()
    return AntiBody.kTurnSpeed
end

function AntiBody:GetCanSleep()
    return self:GetCurrentOrder() == nil
end

function AntiBody:GetMinimumAwakeTime()
    return 5
end

function AntiBody:GetExtentsOverride()
    return Vector(AntiBody.kCapsuleRadius, AntiBody.kCapsuleHeight / 2, AntiBody.kCapsuleRadius)
end

function AntiBody:GetFov()
    return 360
end

function AntiBody:GetIsFlying()
    return true
end

function AntiBody:GetReceivesStructuralDamage()
    return true
end
function AntiBody:GetIsFront()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetFrontDoorsOpen() then 
                   return true
               end
            end
        end
            return false
end
function AntiBody:GetCanBeUsed(player, useSuccessTable)
  useSuccessTable.useSuccess = true //not self:GetIsFront() 
end
function AntiBody:OnUse(player, elapsedTime, useSuccessTable)

    // Play flavor sounds when using AntiBody.
    if Server then
    
        local time = Shared.GetTime()
        
        if self.timeOfLastUse == nil or (time > (self.timeOfLastUse + AntiBody.kUseTime)) then
        
            Server.PlayPrivateSound(player, AntiBody.kUsedSoundName, self, 1.0, Vector(0, 0, 0))
            self.timeOfLastUse = time
            
        end
       self:PlayerUse(player) 
    end
    
end


function AntiBody:PlayerUse(player)
   if Server then
       if not GetGamerules():GetFrontDoorsOpen() then 
          self:NotifyUse(player)
          return
       end
   end    
   self:GiveOrder(kTechId.FollowAndWeld, player:GetId(), player:GetOrigin(), nil, true, true) 
end
function AntiBody:NotifyUse(player)

end
// avoid the AntiBody hovering inside (as that shows the AntiBody through the factory top)
function AntiBody:GetHoverHeight()
    if self.rolloutSourceFactory then
        // keep it low until it leaves the factory, then go back to normal hover height
        local h = AntiBody.kHoverHeight * (1.1 - self.cursor:GetRemainingDistance()) / 1.1
        return math.max(0, h)
    end
    return AntiBody.kHoverHeight
end

function AntiBody:OnOverrideOrder(order)

    local orderTarget = nil
    if (order:GetParam() ~= nil) then
        orderTarget = Shared.GetEntity(order:GetParam())
    end
    
    local isSelfOrder = orderTarget == self
    
    // Default orders to unbuilt friendly structures should be construct orders
    if order:GetType() == kTechId.Default and GetOrderTargetIsConstructTarget(order, self:GetTeamNumber()) and not isSelfOrder then
    
        order:SetType(kTechId.Construct)

    elseif order:GetType() == kTechId.Default and GetOrderTargetIsWeldTarget(order, self:GetTeamNumber()) and not isSelfOrder and not GetIsWeldedByOtherAntiBody(self, orderTarget) then
    
        order:SetType(kTechId.FollowAndWeld)

    elseif (order:GetType() == kTechId.Default or order:GetType() == kTechId.Move) then
        
        // Convert default order (right-click) to move order
        order:SetType(kTechId.Move)
        
     elseif (order:GetType() == kTechId.Default) and orderTarget ~= nil and HasMixin(orderTarget, "Live") and GetAreEnemies(self, orderTarget) and orderTarget:GetIsAlive() and (not HasMixin(orderTarget, "LOS") or orderTarget:GetIsSighted()) then
    
        order:SetType(kTechId.Attack)
        
    end
    /*
    if GetAreEnemies(self, orderTarget) then
        order.orderParam = -1
    end
    */
end

function AntiBody:GetLevelPercentage()
return self.level / AntiBody.MaxLevel * AntiBody.ScaleSize
end

function AntiBody:GetMaxLevel()
return AntiBody.MaxLevel
end
/*
function AntiBody:OnAdjustModelCoords(modelCoords)
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
function AntiBody:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, AntiBody.MaxLevel - self.level)
        self.level = self.level + xpReward
        
           self:AdjustMaxHealth(kAntiBodyHealth * (self.level/AntiBody.MaxLevel) + kAntiBodyHealth) 
        self:AdjustMaxArmor(kAntiBodyArmor * (self.level/AntiBody.MaxLevel) + kAntiBodyArmor )
        
    return xpReward
    
end
function AntiBody:GetLevel()
        return Round(self.level, 2)
end
  function AntiBody:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Level %s AntiBody"), self:GetLevel())
return unitName
end 
function AntiBody:GetIsOrderHelpingOtherAntiBody(order)

    if order:GetType() == kTechId.Construct then
    
        // Look for friendly nearby AntiBodys
        local macs = GetEntitiesForTeamWithinRange("AntiBody", self:GetTeamNumber(), self:GetOrigin(), 3)
        for index, mac in ipairs(macs) do
        
            if mac ~= self then
            
                local otherMacOrder = mac:GetCurrentOrder()
                if otherMacOrder ~= nil and otherMacOrder:GetType() == order:GetType() and otherMacOrder:GetParam() == order:GetParam() then
                    return true
                end
                
            end
            
        end
        
    end
    
    return false
    
end

function AntiBody:OnOrderChanged()

    local order = self:GetCurrentOrder()    
    
    if order then
            
        local owner = self:GetOwner()
        
        if not owner then
            local commanders = GetEntitiesForTeam("Commander", self:GetTeamNumber())
            if commanders and commanders[1] then
                owner = commanders[1]
            end    
        end
        
        local currentComm = commanders and commanders[1] or nil

        // Look for nearby AntiBody doing the same thing
        if self:GetIsOrderHelpingOtherAntiBody(order) then
            self:PlayChatSound(AntiBody.kHelpingSoundName) 
            self.lastOrderLocation = order:GetLocation()
        elseif order:GetType() == kTechId.Construct then
        
            self:PlayChatSound(AntiBody.kStartConstructionSoundName)
            
            if currentComm then
                Server.PlayPrivateSound(currentComm, AntiBody.kStartConstruction2DSoundName, currentComm, 1.0, Vector(0, 0, 0))
            end
            self.lastOrderLocation = order:GetLocation()
            
        elseif order:GetType() == kTechId.Weld or order:GetType() == kTechId.AutoWeld then 
            
            if order:GetLocation() ~= self.lastOrderLocation or self.lastOrderLocation == nil then

                self:PlayChatSound(AntiBody.kStartWeldSound) 

                if currentComm then
                    Server.PlayPrivateSound(currentComm, AntiBody.kStartWeldSound, currentComm, 1.0, Vector(0, 0, 0))
                end
                
                self.lastOrderLocation = order:GetLocation()
                
            end
            
        else
        
            self:PlayChatSound(AntiBody.kConfirmSoundName)
            
            if currentComm then
                Server.PlayPrivateSound(currentComm, AntiBody.kConfirm2DSoundName, currentComm, 1.0, Vector(0, 0, 0))
            end
            
            self.lastOrderLocation = order:GetLocation()
            
        end

    end

end

function AntiBody:GetMoveSpeed()

    local maxSpeedTable = { maxSpeed = AntiBody.kMoveSpeed * (self.level/100) + AntiBody.kMoveSpeed }
    if self.rolloutSourceFactory then
        maxSpeedTable.maxSpeed = AntiBody.kRolloutSpeed
    end
    self:ModifyMaxSpeed(maxSpeedTable)

    return maxSpeedTable.maxSpeed
    
end

local function GetBackPosition(self, target)

    if not target:isa("Player") then
        return None
    end
    
    local coords = target:GetViewAngles():GetCoords()
    local targetViewAxis = coords.zAxis
    targetViewAxis.y = 0 // keep it 2D
    targetViewAxis:Normalize()
    local fromTarget = self:GetOrigin() - target:GetOrigin()
    local targetDist = fromTarget:GetLengthXZ()
    fromTarget.y = 0
    fromTarget:Normalize()

    local weldPos = None    
    local dot = targetViewAxis:DotProduct(fromTarget)    
    // if we are in front or not sufficiently away from the target, we calculate a new weldPos
    if dot > 0 or targetDist < AntiBody.kWeldDistance - 0.5 then
        // we are in front, find out back positon
        local obstacleSize = 0
        if HasMixin(target, "Extents") then
            obstacleSize = target:GetExtents():GetLengthXZ()
        end
        // we do not want to go straight through the player, instead we move behind and to the
        // left or right
        local targetPos = target:GetOrigin()
        local toMidPos = targetViewAxis * (obstacleSize + AntiBody.kWeldDistance - 0.1)
        local midWeldPos = targetPos - targetViewAxis * (obstacleSize + AntiBody.kWeldDistance - 0.1)
        local leftV = Vector(-targetViewAxis.z, targetViewAxis.y, targetViewAxis.x)
        local rightV = Vector(targetViewAxis.z, targetViewAxis.y, -targetViewAxis.x)
        local leftWeldPos = midWeldPos + leftV * 2
        local rightWeldPos = midWeldPos + rightV * 2
        /*
        DebugBox(leftWeldPos+Vector(0,1,0),leftWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 0, 0, 1)
        DebugBox(rightWeldPos+Vector(0,1,0),rightWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 1, 0, 1)
        DebugBox(midWeldPos+Vector(0,1,0),midWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 1, 1, 1)       
        */
        // take the shortest route
        local origin = self:GetOrigin()
        if (origin - leftWeldPos):GetLengthSquared() < (origin - rightWeldPos):GetLengthSquared() then
            weldPos = leftWeldPos
        else
            weldPos = rightWeldPos
        end
    end
    
    return weldPos
        
end
local function CheckBehindBackPosition(self, orderTarget)
    local toTarget = (orderTarget:GetOrigin() - self:GetOrigin())
    local distanceToTarget = toTarget:GetLength()
                    
    if not self.timeOfLastBackPositionCheck or Shared.GetTime() > self.timeOfLastBackPositionCheck + AntiBody.kWeldPositionCheckInterval then
 
        self.timeOfLastBackPositionCheck = Shared.GetTime()
        self.backPosition = GetBackPosition(self, orderTarget)

    end

    return self.backPosition    
end

function AntiBody:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
function AntiBody:OverrideHintString( hintString, forEntity )
    
    if not GetAreEnemies(self, forEntity) then
        if self.level ~= AntiBody.MaxLevel then
            return string.format(Locale.ResolveString( "Weld me to level me up!" ) )
        end
    end

    return hintString
    
end
function AntiBody:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, autoWeld)

    local time = Shared.GetTime()
    local canBeWeldedNow = false
    local orderStatus = kOrderStatus.InProgress

    if self.timeOfLastWeld == 0 or time > self.timeOfLastWeld + AntiBody.kWeldRate then
    
    
        // It is possible for the target to not be weldable at this point.
        // This can happen if a damaged Marine becomes Commander for example.
        // The Commander is not Weldable but the Order correctly updated to the
        // new entity Id of the Commander. In this case, the order will simply be completed.
        if orderTarget and HasMixin(orderTarget, "Weldable") then
        
            local toTarget = (orderLocation - self:GetOrigin())
            local distanceToTarget = toTarget:GetLength()
            canBeWeldedNow = orderTarget:GetCanBeWelded(self)
            
            local obstacleSize = 0
            if HasMixin(orderTarget, "Extents") then
                obstacleSize = orderTarget:GetExtents():GetLengthXZ()
            end
            
            if autoWeld and distanceToTarget > 15 then
                orderStatus = kOrderStatus.Cancelled
            elseif not canBeWeldedNow then
                orderStatus = kOrderStatus.Completed
            else
                local forceMove = false
                local targetPosition = orderTarget:GetOrigin()
                
                local closeEnoughToWeld = distanceToTarget - obstacleSize < AntiBody.kWeldDistance
                
                if closeEnoughToWeld then
                    local backPosition = CheckBehindBackPosition(self, orderTarget)
                    if backPosition then
                        forceMove = true
                        targetPosition = backPosition
                    end          
                end
                
                // If we're close enough to weld, weld (unless we must move to behind the player)
                if not forceMove and closeEnoughToWeld and not GetIsVortexed(self) then
                
                    orderTarget:OnWeld(self, AntiBody.kWeldRate * (self.level/100) + AntiBody.kWeldRate)
                    self:AddXP(AntiBody.GainXp)
                    self.timeOfLastWeld = time
                    self.moving = false
                    
                else
                
                    // otherwise move towards it
                    local hoverAdjustedLocation = GetHoverAt(self, targetPosition)
                    local doneMoving = self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime)
                    self.moving = not doneMoving
                    if doneMoving then
  
                        self.weldPosition = None
                    end
                end
                
            end    
            
        else
            orderStatus = kOrderStatus.Cancelled
        end
        
    end
    
    // Continuously turn towards the target. But don't mess with path finding movement if it was done.
    if not self.moving and orderLocation then
    
        local toOrder = (orderLocation - self:GetOrigin())
        self:SmoothTurn(deltaTime, GetNormalizedVector(toOrder), 0)
        
    end
    
    return orderStatus
    
end
function AntiBody:GetIsSetup()
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
function AntiBody:GetAddXPAmount()
return self:GetIsSetup() and AntiBody.WeldXp * 4 or AntiBody.WeldXp
end
function AntiBody:ProcessMove(deltaTime, target, targetPosition, closeEnough)

    local hoverAdjustedLocation = GetHoverAt(self, targetPosition)
    local orderStatus = kOrderStatus.None
    local distance = (targetPosition - self:GetOrigin()):GetLength()
    local doneMoving = target ~= nil and distance < closeEnough

    if not doneMoving and self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime) then

        orderStatus = kOrderStatus.Completed
        self.moving = false

    else
        orderStatus = kOrderStatus.InProgress
        self.moving = true
    end
    
    return orderStatus
    
end

function AntiBody:PlayChatSound(soundName)

    if self.timeOfLastChatterSound == 0 or (Shared.GetTime() > self.timeOfLastChatterSound + 2) then
        self:PlaySound(soundName)
        self.timeOfLastChatterSound = Shared.GetTime()
    end
    
end
function AntiBody:GetFrontDoorsOpen()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetFrontDoorsOpen() then 
                   return true
               end
            end
        end
            return false
end
// Look for other AntiBodys and Drifters to greet as we fly by 
function AntiBody:UpdateGreetings()

    local time = Shared.GetTime()
    if self.timeOfLastGreetingCheck == 0 or (time > (self.timeOfLastGreetingCheck + AntiBody.kGreetingUpdateInterval)) then
    
        if self.timeOfLastGreeting == 0 or (time > (self.timeOfLastGreeting + AntiBody.kGreetingInterval)) then
        
            local ents = GetEntitiesMatchAnyTypes({"AntiBody", "Drifter"})
            for index, ent in ipairs(ents) do
            
                if (ent ~= self) and (self:GetOrigin() - ent:GetOrigin()):GetLength() < AntiBody.kGreetingDistance then
                
                    if GetCanSeeEntity(self, ent) then
                        if ent:isa("AntiBody") then
                            self:PlayChatSound(AntiBody.kPassbyAntiBodySoundName)
                        elseif ent:isa("Drifter") then
                            self:PlayChatSound(AntiBody.kPassbyDrifterSoundName)
                        end
                        
                        self.timeOfLastGreeting = time
                        break
                        
                    end
                    
                end                    
                    
            end                
                            
        end
        
        self.timeOfLastGreetingCheck = time
        
    end

end
/*
function AntiBody:GetCanBeWeldedOverride()
    return self.lastTakenDamageTime + 1 < Shared.GetTime()
end
*/
function AntiBody:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, self:GetHoverHeight(), 0)
end

local function GetCanConstructTarget(self, target)
    return target ~= nil and HasMixin(target, "Construct") and GetAreFriends(self, target)
end

function AntiBody:ProcessConstruct(deltaTime, orderTarget, orderLocation)

    local time = Shared.GetTime()
    
    local toTarget = (orderLocation - self:GetOrigin())
    local distToTarget = toTarget:GetLengthXZ()
    local orderStatus = kOrderStatus.InProgress
    local canConstructTarget = GetCanConstructTarget(self, orderTarget)   
    
    if self.timeOfLastConstruct == 0 or (time > (self.timeOfLastConstruct + AntiBody.kConstructRate)) then

        if canConstructTarget then
        
            local engagementDist = GetEngagementDistance(orderTarget:GetId()) 
            if distToTarget < engagementDist then
        
                if orderTarget:GetIsBuilt() then   
                    orderStatus = kOrderStatus.Completed
                else
            
                    // Otherwise, add build time to structure
                        orderTarget:Construct(( AntiBody.kConstructRate * kAntiBodyConstructEfficacy) + (self.level/100) + ( AntiBody.kConstructRate * kAntiBodyConstructEfficacy) , self)
                        self.timeOfLastConstruct = time
                        self:AddXP(self:GetAddXPAmount())
                
                end
                
            else
            
                local hoverAdjustedLocation = GetHoverAt(self, orderLocation)
                local doneMoving = self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime)
                self.moving = not doneMoving

            end    
        
        
        else
            orderStatus = kOrderStatus.Cancelled
        end

        
    end
    
    // Continuously turn towards the target. But don't mess with path finding movement if it was done.
    if not self.moving and toTarget then
        self:SmoothTurn(deltaTime, GetNormalizedVector(toTarget), 0)
    end
    
    return orderStatus
    
end

local function FindSomethingToDo(self)

    local target, orderType = GetAutomaticOrder(self)
    if target and orderType then
        return self:GiveOrder(orderType, target:GetId(), target:GetOrigin(), nil, false, false) ~= kTechId.None    
    end
    
    return false
    
end

function AntiBody:OnOrderGiven(order)

    -- Clear out secondary order when an order is explicitly given to this AntiBody.
    self.secondaryOrderType = nil
    self.secondaryTargetId = nil
    
end

// for marquee selection
function AntiBody:GetIsMoveable()
    return true
end

function AntiBody:ProcessFollowAndWeldOrder(deltaTime, orderTarget, targetPosition)

    local currentOrder = self:GetCurrentOrder()
    local orderStatus = kOrderStatus.InProgress
    
    if orderTarget and orderTarget:GetIsAlive() then
        
        local target, orderType = GetAutomaticOrder(self)
        
        if target and orderType then
        
            self.secondaryOrderType = orderType
            self.secondaryTargetId = target:GetId()
            
        end
        
        target = target ~= nil and target or ( self.secondaryTargetId ~= nil and Shared.GetEntity(self.secondaryTargetId) )
        orderType = orderType ~= nil and orderType or self.secondaryOrderType
        
        local forceMove = false
        if not orderType then
            // if we don't have a secondary order, we make sure we move to the back of the player
            local backPosition = CheckBehindBackPosition(self, orderTarget)
            if backPosition then
                forceMove = true
                targetPosition = backPosition
            end
        end

        local distance = (self:GetOrigin() - targetPosition):GetLengthXZ()
        
        // stop moving to primary if we find something to do and we are not too far from our primary
        if orderType and self.moveToPrimary and distance < 10 then
            self.moveToPrimary = false
        end
        
        local triggerMoveDistance = (self.welding or self.constructing or orderType) and 15 or 6
        
        if distance > triggerMoveDistance or self.moveToPrimary or forceMove then
            
            local closeEnough = forceMove and 0.1 or 2.5
            if self:ProcessMove(deltaTime, target, targetPosition, closeEnough) == kOrderStatus.InProgress then
                self.moveToPrimary = true
                self.secondaryTargetId = nil
                self.secondaryOrderType = nil
            else
                self.moveToPrimary = false
            end
            
        else
            self.moving = false
        end
        
        // when we attempt to follow the primary target, dont interrupt with auto orders
        if not self.moveToPrimary then
        
            if target and orderType then
            
                local secondaryOrderStatus = nil
            
                if orderType == kTechId.AutoWeld then            
                    secondaryOrderStatus = self:ProcessWeldOrder(deltaTime, target, target:GetOrigin(), true)        
                elseif orderType == kTechId.Construct then
                    secondaryOrderStatus = self:ProcessConstruct(deltaTime, target, target:GetOrigin())
                end
                
                if secondaryOrderStatus == kOrderStatus.Completed or secondaryOrderStatus == kOrderStatus.Cancelled then
                
                    self.secondaryTargetId = nil
                    self.secondaryOrderType = nil
                    
                end
            
            end
        
        end
        
    else
        self.moveToPrimary = false
        orderStatus = kOrderStatus.Cancelled
    end
    
    return orderStatus

end

local function UpdateOrders(self, deltaTime)

    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
    
        local orderStatus = kOrderStatus.None        
        local orderTarget = Shared.GetEntity(currentOrder:GetParam())
        local orderLocation = currentOrder:GetLocation()
    
      if currentOrder:GetType() == kTechId.Attack then
            self:ProcessAttackOrder(1, AntiBody.kMoveSpeed, deltaTime)
        elseif currentOrder:GetType() == kTechId.FollowAndWeld then
            orderStatus = self:ProcessFollowAndWeldOrder(deltaTime, orderTarget, orderLocation)    
        elseif currentOrder:GetType() == kTechId.Move then
            local closeEnough = 2.5
            orderStatus = self:ProcessMove(deltaTime, orderTarget, orderLocation, closeEnough)
            self:UpdateGreetings()

        elseif currentOrder:GetType() == kTechId.Weld or currentOrder:GetType() == kTechId.AutoWeld then
            orderStatus = self:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, currentOrder:GetType() == kTechId.AutoWeld)
        elseif currentOrder:GetType() == kTechId.Build or currentOrder:GetType() == kTechId.Construct then
            orderStatus = self:ProcessConstruct(deltaTime, orderTarget, orderLocation)
        end
        
        if orderStatus == kOrderStatus.Cancelled then
            self:ClearCurrentOrder()
        elseif orderStatus == kOrderStatus.Completed then
            self:CompletedCurrentOrder()
        end
        
    end
    
end

function AntiBody:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
        

        
    if Server and self:GetIsAlive() then 
     /*
            self:AdjustMaxHealth(kAntiBodyHealth * (self.level/100) + kAntiBodyHealth) 
        self:AdjustMaxArmor(kAntiBodyArmor * (self.level/100) + kAntiBodyArmor )
        
     */
     

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
       
        
        // assume we're not moving initially
        self.moving = false
    
        if not self:GetHasOrder() then
            FindSomethingToDo(self)
        else
            UpdateOrders(self, deltaTime)
        end
        
        self.constructing = Shared.GetTime() - self.timeOfLastConstruct < 0.5
        self.welding = Shared.GetTime() - self.timeOfLastWeld < 0.5

        if self.moving and not self.jetsSound:GetIsPlaying() then
            self.jetsSound:Start()
        elseif not self.moving and self.jetsSound:GetIsPlaying() then
            self.jetsSound:Stop()
        end
        
    // client side build / weld effects
    elseif Client and self:GetIsAlive() then
    
        if self.constructing then
        
            if not self.timeLastConstructEffect or self.timeLastConstructEffect + AntiBody.kConstructRate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_construct")
                self.timeLastConstructEffect = Shared.GetTime()
                
            end
            
        end
        
        if self.welding then
        
            if not self.timeLastWeldEffect or self.timeLastWeldEffect + AntiBody.kWeldRate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_weld")
                self.timeLastWeldEffect = Shared.GetTime()
                
            end
            
        end
        
        if self:GetHasOrder() ~= self.clientHasOrder then
        
            self.clientHasOrder = self:GetHasOrder()
            
            if self.clientHasOrder then
                self:TriggerEffects("mac_set_order")
            end
            
        end

        if self.jetsCinematics then

            for id,cinematic in ipairs(self.jetsCinematics) do
                self.jetsCinematics[id]:SetIsActive(self.moving and self:GetIsVisible())
            end

        end

    end
    
end

function AntiBody:TriggerEMP()
    self:AddXP(AntiBody.kGainXp)
    CreateEntity(EMPBlast.kMapName,  self:GetOrigin(), self:GetTeamNumber())
    return true
    
end
function AntiBody:GetTechButtons(techId)

    local techButtons ={ kTechId.Move, kTechId.Stop, kTechId.Attack, kTechId.Welding,
             kTechId.kTechId.AntiBodyEMP, kTechId.None, kTechId.None, kTechId.Recycle }
    return techButtons
end
 function AntiBody:PerformActivation(techId, position, normal, commander)
     local success = false
    if  techId == kTechId.AntiBodyEMP then
    
        success = self:TriggerEMP()
    
    end
        return success, true
end
/*
function AntiBody:OnKill(attacker, doer, point, direction)
self:TriggerEMP()
end
*/
function AntiBody:OnOverrideDoorInteraction(inEntity)
    // AntiBodys will not open the door if they are currently
    // welding it shut
    if self:GetHasOrder() then
        local order = self:GetCurrentOrder()
        local targetId = order:GetParam()
        local target = Shared.GetEntity(targetId)
        if (target ~= nil) then
            if (target == inEntity) then
               return false, 0
            end
        end
    end
    return self.moving and not inEntity:GetIsInCombat(), 4
end
function AntiBody:OnDamageDone(doer, target)
if doer == self then
self:AddXP(AntiBody.kGainXp)
end
end
/*
function AntiBody:GetCanDoorInteract(inEntity)
return self.maclockedoors, 1
end
*/
function AntiBody:GetIdleSoundInterval()
    return 25
end

function AntiBody:UpdateIncludeRelevancyMask()
    SetAlwaysRelevantToCommander(self, true)
end

if Server then
    
    function AntiBody:GetCanReposition()
        return true
    end
    
    function AntiBody:OverrideRepositioningSpeed()
        return AntiBody.kMoveSpeed *.4
    end    
    
    function AntiBody:OverrideRepositioningDistance()
        return 0.4
    end    

    function AntiBody:OverrideGetRepositioningTime()
        return .5
    end

end

local function GetOrderMovesAntiBody(orderType)

    return orderType == kTechId.Move or
           orderType == kTechId.Attack or
           orderType == kTechId.Build or
           orderType == kTechId.Construct or
           orderType == kTechId.Weld

end

function AntiBody:OnUpdateAnimationInput(modelMixin)

    PROFILE("AntiBody:OnUpdateAnimationInput")
    
    local move = "idle"
    local currentOrder = self:GetCurrentOrder()
    if currentOrder then
    
        if GetOrderMovesAntiBody(currentOrder:GetType()) then
            move = "run"
        end
    
    end
    modelMixin:SetAnimationInput("move",  move)
    
    local currentTime = Shared.GetTime()
    local activity = "none"
    if currentTime - self:GetTimeOfLastAttackOrder() < 0.5 then
    activity = "primary"
    elseif self.constructing or self.welding then
        activity = "build"
    end
    modelMixin:SetAnimationInput("activity", activity)

end
function AntiBody:GetTimeLastDamageTaken()
    return self.lastTakenDamageTime
end
function AntiBody:GetTimeOfLastAttackOrder()
    return self.timeOfLastAttackOrder
end
function AntiBody:GetShowHitIndicator()
    return false
end

function AntiBody:GetPlayIdleSound()
    return not self:GetHasOrder() and GetIsUnitActive(self)
end

function AntiBody:GetHealthbarOffset()
    return 1.4
end 
function AntiBody:GetMeleeAttackDamage()
    return 5 * (self.level/100) + 5
end

function AntiBody:GetMeleeAttackInterval()
    return 0.6
end
function AntiBody:GetMeleeAttackOrigin()
    return self:GetAttachPointOrigin("fxnode_welder")
end
function AntiBody:OnDestroy()

    Entity.OnDestroy(self)

    if Client then

        for id,cinematic in ipairs(self.jetsCinematics) do

            Client.DestroyCinematic(cinematic)
            self.jetsCinematics[id] = nil

        end

    end
    
end

Shared.LinkClassToMap("AntiBody", AntiBody.kMapName, networkVars, true)

if Server then

    local function OnCommandFollowAndWeld(client)

        if client ~= nil and Shared.GetCheatsEnabled() then
        
            local player = client:GetControllingPlayer()
            for _, mac in ipairs(GetEntitiesForTeamWithinRange("AntiBody", player:GetTeamNumber(), player:GetOrigin(), 10)) do
                mac:GiveOrder(kTechId.FollowAndWeld, player:GetId(), player:GetOrigin(), nil, false, false)
            end
            
        end

    end

    Event.Hook("Console_followandweld", OnCommandFollowAndWeld)

end
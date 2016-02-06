Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/StunMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
//Script.Load("lua/LaserMixin.lua")
Script.Load("lua/TargetCacheMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/TriggerMixin.lua")
Script.Load("lua/TargettingMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")

local kSpinUpSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_spin_up")
local kSpinDownSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_spin_down")
local kSentryWeldGainXp =  0.75
local kSentryScaleSize = 1.8

class 'Sentry' (ScriptActor)

Sentry.kMapName = "sentry"

Sentry.kModelName = PrecacheAsset("models/marine/sentry/sentry.model")
local kAnimationGraph = PrecacheAsset("models/marine/sentry/sentry.animation_graph")

local kAttackSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_fire_loop")

local kSentryScanSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_scan")
Sentry.kUnderAttackSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/sentry_taking_damage")
Sentry.kFiringAlertSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/sentry_firing")

Sentry.kConfusedSound = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_confused")

Sentry.kFireShellEffect = PrecacheAsset("cinematics/marine/sentry/fire_shell.cinematic")

// Balance
Sentry.kPingInterval = 4
Sentry.kFov = 360
Sentry.kMaxPitch = 180
Sentry.kMaxYaw = Sentry.kFov / 2

Sentry.kBaseROF = kSentryAttackBaseROF
Sentry.kRandROF = kSentryAttackRandROF
Sentry.kSpread = Math.Radians(3)
Sentry.kBulletsPerSalvo = kSentryAttackBulletsPerSalvo
Sentry.kBarrelScanRate = 120      // Degrees per second to scan back and forth with no target
Sentry.kBarrelMoveRate = 160    // Degrees per second to move sentry orientation towards target or back to flat when targeted
Sentry.kRange = 20
Sentry.kReorientSpeed = .04

Sentry.kTargetAcquireTime = 0.4
Sentry.kConfuseDuration = 4
Sentry.kAttackEffectIntervall = 0.2
Sentry.kConfusedAttackEffectInterval = kConfusedSentryBaseROF

// Animations
Sentry.kYawPoseParam = "sentry_yaw" // Sentry yaw pose parameter for aiming
Sentry.kPitchPoseParam = "sentry_pitch"
Sentry.kMuzzleNode = "fxnode_sentrymuzzle"
Sentry.kEyeNode = "fxnode_eye"
Sentry.kLaserNode = "fxnode_eye"
Sentry.Damage = 5
Sentry.kSentryGainXp =  0.08
Sentry.kSentryLoseXp = 0.06
Sentry.kSentryMaxLevel = 99

// prevents attacking during deploy animation for kDeployTime seconds
local kDeployTime = 3.5

local networkVars =
{    
    // So we can update angles and pose parameters smoothly on client
    targetDirection = "vector",  
    
    confused = "boolean",
    
    deployed = "boolean",
    
    attacking = "boolean",
    
    attachedToBattery = "boolean",
    level = "float (0 to " .. Sentry.kSentryMaxLevel .. " by .1)",
    ignorelimit = "boolean",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
//AddMixinNetworkVars(LaserMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

function Sentry:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, StunMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, ParasiteMixin)    
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self.desiredYawDegrees = 0
    self.desiredPitchDegrees = 0
    self.barrelYawDegrees = 0
    self.barrelPitchDegrees = 0

    self.confused = false
    self.attachedToBattery = false
    
    if Server then

        self.attackSound = Server.CreateEntity(SoundEffect.kMapName)
        self.attackSound:SetParent(self)
        self.attackSound:SetAsset(kAttackSoundName)
        
    elseif Client then
    
        self.timeLastAttackEffect = Shared.GetTime()
        
        // Play a "ping" sound effect every Sentry.kPingInterval while scanning.
        local function PlayScanPing(sentry)
        
            if GetIsUnitActive(self) and not self.attacking and self.attachedToBattery then
                local player = Client.GetLocalPlayer()
                Shared.PlayPrivateSound(player, kSentryScanSoundName, nil, 1, sentry:GetModelOrigin())
            end
            return true
            
        end
        
        self:AddTimedCallback(PlayScanPing, Sentry.kPingInterval)
        
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    self.level = 0
    self.ignorelimit = false
    
end

function Sentry:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, WeldableMixin)
    
    //InitMixin(self, LaserMixin)
    
    self:SetModel(Sentry.kModelName, kAnimationGraph)
    
    self:SetUpdates(true)
    
    if Server then 
    
        InitMixin(self, SleeperMixin)
        
        self.timeLastTargetChange = Shared.GetTime()
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        // TargetSelectors require the TargetCacheMixin for cleanup.
        InitMixin(self, TargetCacheMixin)
        InitMixin(self, SupplyUserMixin)
        
        // configure how targets are selected and validated
        self.targetSelector = TargetSelector():Init(
            self,
            Sentry.kRange, 
            true,
            { kMarineStaticTargets, kMarineMobileTargets },
            { PitchTargetFilter(self,  -Sentry.kMaxPitch, Sentry.kMaxPitch), CloakTargetFilter() },
            { function(target) return not target:isa("Cyst") end } )

        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)   
        InitMixin(self, HiveVisionMixin)
 
    end
    
end

function Sentry:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    // The attackSound was already destroyed at this point, clear the reference.
    if Server then
        self.attackSound = nil
    end
    
end
/*
function Sentry:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)
local damage = 1
    if doer:isa("SwipeBlink") then
       damage = damage * (self.level/100) + damage
    elseif doer:isa("DotMarker") or doer:isa("Gore") then
       damage = damage - (self.level/100) * damage
    end
  damageTable.damage = damageTable.damage * damage 
end
*/
function Sentry:GetCanSleep()
    return self.attacking == false
end

function Sentry:GetMinimumAwakeTime()
    return 10
end 

function Sentry:GetFov()
    return Sentry.kFov
end

local kSentryEyeHeight = Vector(0, 0.8, 0)
function Sentry:GetEyePos()
    return self:GetOrigin() + kSentryEyeHeight
end

function Sentry:GetDeathIconIndex()
    return kDeathMessageIcon.Sentry
end

function Sentry:GetReceivesStructuralDamage()
    return true
end

function Sentry:GetBarrelPoint()
    return self:GetAttachPointOrigin(Sentry.kMuzzleNode)    
end

function Sentry:GetLaserAttachCoords()

    local coords = self:GetAttachPointCoords(Sentry.kLaserNode)    
    local xAxis = coords.xAxis
    coords.xAxis = -coords.zAxis
    coords.zAxis = xAxis

    return coords   
end
function Sentry:GetIsStunAllowed()
    return self:GetLastStunTime() + 4 < Shared.GetTime() and not self:GetIsVortexed() and (GetAreFrontDoorsOpen() or Shared.GetCheatsEnabled())
end
function Sentry:OverrideLaserLength()
    return Sentry.kRange
end

function Sentry:GetPlayInstantRagdoll()
    return true
end

function Sentry:GetIsLaserActive()
    return GetIsUnitActive(self) and self.deployed and self.attachedToBattery
end

function Sentry:OnUpdatePoseParameters()

    PROFILE("Sentry:OnUpdatePoseParameters")

    local pitchConfused = 0
    local yawConfused = 0
    
    // alter the yaw and pitch slightly, barrel will swirl around
    if self.confused then
    
        pitchConfused = math.sin(Shared.GetTime() * 6) * 2
        yawConfused = math.cos(Shared.GetTime() * 6) * 2
        
    end
    
    self:SetPoseParam(Sentry.kPitchPoseParam, self.barrelPitchDegrees + pitchConfused)
    self:SetPoseParam(Sentry.kYawPoseParam, self.barrelYawDegrees + yawConfused)
    
end

function Sentry:OnUpdateAnimationInput(modelMixin)

    PROFILE("Sentry:OnUpdateAnimationInput")    
    modelMixin:SetAnimationInput("attack", self.attacking)
    modelMixin:SetAnimationInput("powered", true)
    
end

// used to prevent showing the hit indicator for the commander
function Sentry:GetShowHitIndicator()
    return false
end
function Sentry:GetMaxLevel()
return Sentry.kSentryMaxLevel
end
function Sentry:OverrideHintString( hintString, forEntity )
    
    if not GetAreEnemies(self, forEntity) then
        if self.level ~= Sentry.kSentryMaxLevel then
            return string.format(Locale.ResolveString( "Weld me to level me up!" ) )
        end
    end

    return hintString
    
end
function Sentry:OnWeldOverride(entity, elapsedTime)

    local welded = false
    if self:GetIsBuilt() then self:AddXP(kSentryWeldGainXp) end
    // faster repair rate for sentries, promote use of welders
    if entity:isa("Welder") or entity:isa("ExoWelder") then

        local amount = kWelderSentryRepairRate * elapsedTime     
        self:AddHealth(amount)
        
    elseif entity:isa("MAC") then
    
        self:AddHealth(MAC.kRepairHealthPerSecond * elapsedTime) 
        
    end
end

function Sentry:GetHealthbarOffset()
    return 0.4
end 
function Sentry:GetAddXPAmount()
return self:GetIsSetup() and  kSentryWeldGainXp * 4 or kSentryWeldGainXp
end
function Sentry:GetLevelPercentage()
return self.level / Sentry.kSentryMaxLevel * kSentryScaleSize
end
function Sentry:GetIsSetup()
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
/*
function Sentry:OnAdjustModelCoords(modelCoords)
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
function Sentry:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, Sentry.kSentryMaxLevel - self.level)
        self.level = self.level + xpReward
   
           
        self:AdjustMaxHealth(kSentryHealth * (self.level/100) + kSentryHealth) 
        self:AdjustMaxArmor(kSentryArmor * (self.level/100) + kSentryArmor)
        
      
    return xpReward
    
end
function Sentry:LoseXP(amount)

        self.level = Clamp(self.level - amount, 0, 50)
        
                   /*
        self:AdjustMaxHealth(kSentryHealth * (self.level/100) + kSentryHealth) 
        self:AdjustMaxArmor(kSentryArmor * (self.level/100) + kSentryArmor)
        */
       
        self:AdjustMaxHealth(kSentryHealth * (self.level/Sentry.kSentryMaxLevel) + kSentryHealth) 
      //  self:AdjustMaxArmor(kSentryArmor * (self.level/kSentryMaxLevel) + kSentryArmor)
      
    
end
function Sentry:GetLevel()
        return Round(self.level, 2)
end
/*
function Sentry:OnKill(attacker, doer, point, direction)
self:TriggerEMP()
end
*/
function Sentry:TriggerEMP()
    CreateEntity(EMPBlast.kMapName,  self:GetOrigin(), self:GetTeamNumber())
    return true
    
end
function Sentry:OnDamageDone(doer, target)
if doer == self then
self:AddXP(Sentry.kSentryGainXp)
end
end
  function Sentry:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = string.format(Locale.ResolveString("Level %s Sentry"), self:GetLevel())
return unitName
end  
if Server then

    local function OnDeploy(self)
    
        self.attacking = false
        self.deployed = true
        return false
        
    end
    
    function Sentry:OnConstructionComplete()
        self:AddTimedCallback(OnDeploy, kDeployTime)      
    end
    
    function Sentry:OnStun()
        self:Confuse(2)
        
               //  if Server then
              // local bonewall = CreateEntity(BoneWall.kMapName, self:GetOrigin(), 2)    
              //  bonewall.modelsize = 0.15
              //  bonewall:AdjustMaxHealth(60)
              //  StartSoundEffectForPlayer(AlienCommander.kBoneWallSpawnSound, self)
              //   end
    end
    
    function Sentry:GetDamagedAlertId()
        return kTechId.MarineAlertSentryUnderAttack
    end
    
    function Sentry:FireBullets()

    local startPoint = self:GetBarrelPoint()
    local directionToTarget = self.target:GetEngagementPoint() - self:GetEyePos()
    local targetDistanceSquared = directionToTarget:GetLengthSquared()
    local theTimeToReachEnemy = targetDistanceSquared / (10 * 10)
    local engagementPoint = self.target:GetEngagementPoint()
    if self.target.GetVelocity then
    
        local targetVelocity = self.target:GetVelocity()
        engagementPoint = self.target:GetEngagementPoint() - ((targetVelocity:GetLength() * 0.5 - (self.level/100) * 1 * theTimeToReachEnemy) * GetNormalizedVector(targetVelocity))
        
    end
    
    local fireDirection = GetNormalizedVector(engagementPoint - startPoint)
    local fireCoords = Coords.GetLookIn(startPoint, fireDirection)    
    local spreadDirection = CalculateSpread(fireCoords, Math.Radians(15), math.random)
    
    local endPoint = startPoint + spreadDirection * (Sentry.kRange * (self.level/100) + Sentry.kRange)
    
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))
    
    if trace.fraction < 1 then
    
        local surface = nil
        
        // Disable friendly fire.
        local validtarget = GetAreEnemies(trace.entity, self)
        trace.entity = (not trace.entity or validtarget) and trace.entity or nil
        
        if not trace.entity then
            surface = trace.surface
        end
        
        local direction = (trace.endPoint - startPoint):GetUnit()
        local damage = 5 
        //if not self:GetIsaCreditStructure() and trace.entity and trace.entity:isa("Onos") then damage = 7 end 
        self:DoDamage(damage * (self.level/100) + damage, trace.entity, trace.endPoint, fireDirection, surface, false, true)
        
    end
    
        
    end
    
    // checking at range 1.8 for overlapping the radius a bit. no LOS check here since i think it would become too expensive with multiple sentries
    function Sentry:GetFindsSporesAt(position)
        return #GetEntitiesWithinRange("SporeCloud", position, 1.8) > 0
    end
    
    function Sentry:Confuse(duration)

        if not self.confused then
        
            self.confused = true
            self.timeConfused = Shared.GetTime() + duration
            
            StartSoundEffectOnEntity(Sentry.kConfusedSound, self)
            
        end
        
    end
    
    // check for spores in our way every 0.3 seconds
    local function UpdateConfusedState(self, target)

        if not self.confused and target then
            
            if not self.timeCheckedForSpores then
                self.timeCheckedForSpores = Shared.GetTime() - 0.3
            end
            
            if self.timeCheckedForSpores + 0.3 < Shared.GetTime() then
            
                self.timeCheckedForSpores = Shared.GetTime()
            
                local eyePos = self:GetEyePos()
                local toTarget = target:GetOrigin() - eyePos
                local distanceToTarget = toTarget:GetLength()
                toTarget:Normalize()
                
                local stepLength = 3
                local numChecks = math.ceil(Sentry.kRange/stepLength)
                
                // check every few meters for a spore in the way, min distance 3 meters, max 12 meters (but also check sentry eyepos)
                for i = 0, numChecks do
                
                    // stop when target has reached, any spores would be behind
                    if distanceToTarget < (i * stepLength) then
                        break
                    end
                
                    local checkAtPoint = eyePos + toTarget * i * stepLength
                    if self:GetFindsSporesAt(checkAtPoint) then
                        self:Confuse(Sentry.kConfuseDuration)
                        break
                    end
                
                end
            
            end
            
        elseif self.confused then
        
            if self.timeConfused < Shared.GetTime() then
                self.confused = false
            end
        
        end

    end
    
    local function UpdateBatteryState(self)
    
        local time = Shared.GetTime()
        
        if self.lastBatteryCheckTime == nil or (time > self.lastBatteryCheckTime + 0.5) then
        
            // Update if we're powered or not
            self.attachedToBattery = false
            
            local ents = GetEntitiesForTeamWithinRange("PowerPoint", self:GetTeamNumber(), self:GetOrigin(), 9999)
            for index, ent in ipairs(ents) do
            
                if GetIsUnitActive(ent) and ent:GetLocationName() == self:GetLocationName() then
                
                    self.attachedToBattery = true
                    break
                    
                end
                
            end
            
            local batteries = GetEntitiesForTeamWithinRange("SentryBattery", self:GetTeamNumber(), self:GetOrigin(), 9999)
            for index, battery in ipairs(batteries) do
            
                if GetIsUnitActive(battery) and battery:GetLocationName() == self:GetLocationName() then
                
                    self.attachedToBattery = true
                    break
                    
                end
                
            end  
            self.lastBatteryCheckTime = time
            
        end
        
    end
    
    function Sentry:OnUpdate(deltaTime)
    
        PROFILE("Sentry:OnUpdate")
        
        ScriptActor.OnUpdate(self, deltaTime)  
        
        UpdateBatteryState(self)
        

        
       
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
        
        if self.timeNextAttack == nil or (Shared.GetTime() > self.timeNextAttack) then
        
            local initialAttack = self.target == nil
            
            local prevTarget = nil
            if self.target then
                prevTarget = self.target
            end
            
            self.target = nil
            
            if GetIsUnitActive(self) and self.attachedToBattery and self.deployed then
                self.target = self.targetSelector:AcquireTarget()
            end
            
            if self.target then
            
                local previousTargetDirection = self.targetDirection
                self.targetDirection = GetNormalizedVector(self.target:GetEngagementPoint() - self:GetAttachPointOrigin(Sentry.kMuzzleNode))
                
                // Reset damage ramp up if we moved barrel at all                
                if previousTargetDirection then
                    local dotProduct = previousTargetDirection:DotProduct(self.targetDirection)
                    if dotProduct < .99 then
                    
                        self.timeLastTargetChange = Shared.GetTime()
                        
                    end    
                end

                // Or if target changed, reset it even if we're still firing in the exact same direction
                if self.target ~= prevTarget then
                    self.timeLastTargetChange = Shared.GetTime()
                end            
                
                // don't shoot immediately
                if not initialAttack then
                
                    self.attacking = true
                    self:FireBullets()
                    
                end    
                
            else
            
                self.attacking = false
                self.timeLastTargetChange = Shared.GetTime()

            end
            
            UpdateConfusedState(self, self.target)
            // slower fire rate when confused
            local confusedTime = ConditionalValue(self.confused, kConfusedSentryBaseROF, 0)
            
            // Random rate of fire so it can't be gamed

            if initialAttack and self.target then
                self.timeNextAttack = Shared.GetTime() + Sentry.kTargetAcquireTime
            else
                self.timeNextAttack = confusedTime + Shared.GetTime() + Sentry.kBaseROF + math.random() * Sentry.kRandROF
            end    
            
            if not GetIsUnitActive() or self.confused or not self.attacking or not self.attachedToBattery then
            
                if self.attackSound:GetIsPlaying() then
                    self.attackSound:Stop()
                end
                
            elseif self.attacking then
            
                if not self.attackSound:GetIsPlaying() then
                    self.attackSound:Start()
                end

            end 
        
        end
    
    end
    function Sentry:GetIsFront()
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
function Sentry:GetCanBeUsedConstructed(byPlayer)
  return not self:GetIsFront() and not  byPlayer:GetWeaponInHUDSlot(5)
end
function Sentry:OnUseDuringSetup(player, elapsedTime, useSuccessTable)

    // Play flavor sounds when using MAC.
    if Server then
    
        local time = Shared.GetTime()
        
       // if self.timeOfLastUse == nil or (time > (self.timeOfLastUse + 4)) then
        
           local laystructure = player:GiveItem(LayStructures.kMapName)
           laystructure:SetTechId(kTechId.Sentry)
           laystructure:SetMapName(Sentry.kMapName)
           laystructure.originalposition = self:GetOrigin()
           DestroyEntity(self)
           // self.timeOfLastUse = time
            
      //  end
       //self:PlayerUse(player) 
    end
    
end
elseif Client then

    local function UpdateAttackEffects(self, deltaTime)
    
        local intervall = ConditionalValue(self.confused, Sentry.kConfusedAttackEffectInterval, Sentry.kAttackEffectIntervall)
        if self.attacking and (self.timeLastAttackEffect + intervall < Shared.GetTime()) then
        
            if self.confused then
                self:TriggerEffects("sentry_single_attack")
            end
            
            // plays muzzle flash and smoke
            self:TriggerEffects("sentry_attack")

            self.timeLastAttackEffect = Shared.GetTime()
            
        end
        
    end

    function Sentry:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
        
        if GetIsUnitActive(self) and self.deployed and self.attachedToBattery then
      
            // Swing barrel yaw towards target        
            if self.attacking then
            
                if self.targetDirection then
                
                    local invSentryCoords = self:GetAngles():GetCoords():GetInverse()
                    self.relativeTargetDirection = GetNormalizedVector( invSentryCoords:TransformVector( self.targetDirection ) )
                    self.desiredYawDegrees = Clamp(math.asin(-self.relativeTargetDirection.x) * 180 / math.pi, -Sentry.kMaxYaw, Sentry.kMaxYaw)            
                    self.desiredPitchDegrees = Clamp(math.asin(self.relativeTargetDirection.y) * 180 / math.pi, -Sentry.kMaxPitch, Sentry.kMaxPitch)       
                    
                end
                
                UpdateAttackEffects(self, deltaTime)
                
            // Else when we have no target, swing it back and forth looking for targets
            else
            
                local sin = math.sin(math.rad((Shared.GetTime() + self:GetId() * .3) * Sentry.kBarrelScanRate))
                self.desiredYawDegrees = sin * self:GetFov() / 2
                
                // Swing barrel pitch back to flat
                self.desiredPitchDegrees = 0
            
            end
            
            // swing towards desired direction
            self.barrelPitchDegrees = Slerp(self.barrelPitchDegrees, self.desiredPitchDegrees, Sentry.kBarrelMoveRate * deltaTime)    
            self.barrelYawDegrees = Slerp(self.barrelYawDegrees , self.desiredYawDegrees, Sentry.kBarrelMoveRate * deltaTime)
        
        end
    
    end

end
function Sentry:GetTechButtons(techId)

    local techButtons = nil

    techButtons = { kTechId.None, kTechId.None, kTechId.None, kTechId.None, 
                    kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    
    if self.level ~= Sentry.kSentryMaxLevel then
    techButtons[1] = kTechId.LevelSentry
    end
    
    return techButtons
    
end
 function Sentry:PerformActivation(techId, position, normal, commander)
     local success = false
    if techId == kTechId.LevelSentry then
    success = self:AddXP(5)    
    end
      return success, true
end
function GetCheckSentryLimit(techId, origin, normal, commander)
/*
    -- Prevent the case where a Sentry in one room is being placed next to a
    -- SentryBattery in another room.
    local battery = GetSentryBatteryInRoom(origin)
    if battery then
    
        if (battery:GetOrigin() - origin):GetLength() > SentryBattery.kRange then
            return false
        end
        
    else
        return false
    end
   */ 
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    
    if locationName then
    
        validRoom = true
        
        for index, sentry in ientitylist(Shared.GetEntitiesWithClassname("Sentry")) do
        
            if sentry:GetLocationName() == locationName and not sentry.ignorelimit then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    
    return validRoom and numInRoom < kSentriesPerBattery
    
end

function GetBatteryInRange(commander)

    local batteries = {}
    for _, battery in ipairs(GetEntitiesForTeam("PowerPoint", commander:GetTeamNumber())) do
        batteries[battery] = 999999
    end
    
    return batteries
    
end

Shared.LinkClassToMap("Sentry", Sentry.kMapName, networkVars)

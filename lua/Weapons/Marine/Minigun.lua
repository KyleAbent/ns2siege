// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Weapons\Marine\Minigun.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/BulletsMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")

class 'Minigun' (Entity)

Minigun.kMapName = "minigun"

local kSpinUpSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_up_2"),
                            [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_up") }

local kSpinDownSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_down_2"),
                              [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_down") }

local kSpinSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_2"),
                          [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin") }

local kSpinTailSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/tail_2"),
                              [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/tail") }

local kHeatUISoundName = PrecacheAsset("sound/NS2.fev/marine/heavy/heat_UI")
local kOverheatedSoundName = PrecacheAsset("sound/NS2.fev/marine/heavy/overheated")

PrecacheAsset("shaders/ExoMinigunView.surface_shader")

local kOverheatEffect = PrecacheAsset("cinematics/marine/minigun/overheat.cinematic")

// Trigger on the client based on the "shooting" variable below.
local kShellsCinematics = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("cinematics/marine/minigun/mm_left_shell.cinematic"),
                            [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("cinematics/marine/minigun/mm_shell.cinematic") }
local kShellsAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "Exosuit_LElbow",
                              [ExoWeaponHolder.kSlotNames.Right] = "Exosuit_RElbow" }

local kMinigunRange = 400
local kMinigunSpread = Math.Radians(5)


local kBulletSize = 0.03

local kHeatUpRate = 0.15
local kDualGunHeatUpRate = 0.1125
local kCoolDownRate = 0.3

local networkVars =
{
    minigunAttacking = "private boolean",
    shooting = "boolean",
    heatAmount = "float (0 to 1 by 0.01)",
    overheated = "private boolean",
    spinSoundId = "entityid",
    heatUISoundId = "private entityid",
    rambo = "boolean",
}

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)

function Minigun:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, BulletsMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    InitMixin(self, PointGiverMixin)
    
    self.minigunAttacking = false
    self.shooting = false
    self.heatAmount = 0
    self.overheated = false
    self.rambo = false
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end
    
end

function Minigun:OnInitialized()

    if Client then
    
        local attachPointName = kShellsAttachPoints[self:GetExoWeaponSlot()]
        local cinematicName = kShellsCinematics[self:GetExoWeaponSlot()]
        if attachPointName and cinematicName then
        
            self.shellsCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
            self.shellsCinematic:SetCinematic(cinematicName)
            self.shellsCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.shellsCinematic:SetParent(self:GetParent())
            self.shellsCinematic:SetCoords(Coords.GetIdentity())
            self.shellsCinematic:SetAttachPoint(self:GetParent():GetAttachPointIndex(attachPointName))
            self.shellsCinematic:SetIsActive(false)
            
        end
        
    end
    
end

function Minigun:OnDestroy()

    Entity.OnDestroy(self)
    
    if self.shellsCinematic then
    
        Client.DestroyCinematic(self.shellsCinematic)
        self.shellsCinematic = nil
        
    end
    
    if self.heatDisplayUI then
    
        Client.DestroyGUIView(self.heatDisplayUI)
        self.heatDisplayUI = nil
        
    end
    
end

function Minigun:GetIsThrusterAllowed()
    return not self.shooting
end

function Minigun:OnWeaponSlotAssigned(slot)

    assert(Server)
    
    self.spinSound = Server.CreateEntity(SoundEffect.kMapName)
    self.spinSound:SetAsset(kSpinSoundNames[slot])
    self.spinSound:SetParent(self)
    self.spinSoundId = self.spinSound:GetId()
    
    self.heatUISound = Server.CreateEntity(SoundEffect.kMapName)
    self.heatUISound:SetAsset(kHeatUISoundName)
    self.heatUISound:SetParent(self)
    self.heatUISound:Start()
    self.heatUISoundId = self.heatUISound:GetId()
    
end

function Minigun:ConstrainMoveVelocity(moveVelocity)

    if self.minigunAttacking then
    
        moveVelocity.x = moveVelocity.x / 3
        moveVelocity.z = moveVelocity.z / 3
        
    end
    
end

function Minigun:OnPrimaryAttack(player)

    if not self.overheated then
    
        if not self.minigunAttacking then
        
            if Server then
                StartSoundEffectOnEntity(kSpinUpSoundNames[self:GetExoWeaponSlot()], self)
            end
            
        end
        
        self.minigunAttacking = true
        
    end
    
end

function Minigun:OnPrimaryAttackEnd(player)

    if self.minigunAttacking then
    
        if Server then
        
            if self.shooting then
                StartSoundEffectOnEntity(kSpinTailSoundNames[self:GetExoWeaponSlot()], self)
            end
            
            StartSoundEffectOnEntity(kSpinDownSoundNames[self:GetExoWeaponSlot()], self)
            
            if self.spinSound:GetIsPlaying() then
                self.spinSound:Stop()
            end    
            
        end
        
        self.shooting = false
        
    end
    
    self.minigunAttacking = false
    
end

function Minigun:GetBarrelPoint()

    local player = self:GetParent()
    if player then
    
        if player:GetIsLocalPlayer() then
        
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.65 + viewCoords.yAxis * -0.19
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.65 + viewCoords.yAxis * -0.19
            end    
        
        else
    
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.35 + viewCoords.yAxis * -0.15
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.35 + viewCoords.yAxis * -0.15
            end
            
        end    
        
    end
    
    return self:GetOrigin()
    
end

function Minigun:GetTracerEffectName()
    return kMinigunTracerEffectName
end

function Minigun:GetTracerEffectFrequency()
    return 1
end

function Minigun:GetIsAffectedByWeaponUpgrades()
    return true
end 

function Minigun:GetDeathIconIndex()
    return kDeathMessageIcon.Minigun
end

function Minigun:GetWeight()
    return kMinigunWeight
end

// TODO: we should use clip weapons provided functionality here (or create a more general solution which distincts between melee, hitscan and projectile only)!
local function Shoot(self, leftSide)

    local player = self:GetParent()
    
    // We can get a shoot tag even when the clip is empty if the frame rate is low
    // and the animation loops before we have time to change the state.
    if self.minigunAttacking and player then
    
        if Server and not self.spinSound:GetIsPlaying() then
            self.spinSound:Start()
        end    
    
        local viewAngles = player:GetViewAngles()
        local shootCoords = viewAngles:GetCoords()
        
        // Filter ourself out of the trace so that we don't hit ourselves.
        local filter = EntityFilterTwo(player, self)
        local startPoint = player:GetEyePos()
        
        local spreadDirection = CalculateSpread(shootCoords, kMinigunSpread, NetworkRandom)
        
        local range = kMinigunRange
 //       if GetIsVortexed(player) then
  //          range = 5
  //      end
        
        local endPoint = startPoint + spreadDirection * range
        
        local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, kBulletSize, filter) 
        
        local direction = (trace.endPoint - startPoint):GetUnit()
        local hitOffset = direction * kHitEffectOffset
        local impactPoint = trace.endPoint - hitOffset
        local surfaceName = trace.surface
        local effectFrequency = self:GetTracerEffectFrequency()
        local showTracer =  math.random() < effectFrequency
        
        local numTargets = #targets
        
        if numTargets == 0 then
            self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
        end
        
        if Client and showTracer then
            TriggerFirstPersonTracer(self, trace.endPoint)
        end
        
        for i = 1, numTargets do

            local target = targets[i]
            local hitPoint = hitPoints[i]
            local dist = Clamp(self:GetDistance(target), 1, kMinigunDamage)
            local damagey = Clamp( (kMinigunDamage - dist) + 4, 12, kMinigunDamage)
            /*
            dist = math.round(dist, 1)
            if dist >= 12 then 
            damagey = 18
            elseif dist == 11 then
            damagey = 19
            elseif dist == 10 then
            damagey = 20
            elseif dist == 9 then
            damagey = 20
            elseif dist == 8 then
            damagey = 20
            elseif dist == 7 then
            damagey = 20
            elseif dist == 6 then
            damagey = 20
            elseif dist == 5 then
            damagey = 21
            elseif dist <= 4 then
            damagey = 22
            end
            */
            //Print("%s distance, %s damage", math.round(dist, 1), math.round(damagey,1))
            self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, damagey, "", showTracer and i == numTargets)
            
            local client = Server and player:GetClient() or Client
            if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, bullet, startPoint, trace, damage)
            end
        
        end
        
        self.shooting = true
        
    end
    
end

local function UpdateOverheated(self, player)

    if not self.overheated and self.heatAmount == 1 then
    
        self.overheated = true
        self:OnPrimaryAttackEnd(player)
        
        if self:GetIsLeftSlot() then
            player:TriggerEffects("minigun_overheated_left")
        elseif self:GetIsRightSlot() then    
            player:TriggerEffects("minigun_overheated_right")
        end    
        
        StartSoundEffectForPlayer(kOverheatedSoundName, player)
        
    end
    
    if self.overheated and self.heatAmount == 0 then
        self.overheated = false
    end
    
end

function Minigun:AddHeat(amount)
    self.heatAmount = self.heatAmount + amount
end

function Minigun:ProcessMoveOnWeapon(player, input)
    if self.rambo then Shoot(self, true) Shoot(self, false) return end
    local dt = input.time
    local addAmount = self.shooting and (dt * kHeatUpRate) or -(dt * kCoolDownRate)
    self.heatAmount = math.min(1, math.max(0, self.heatAmount + addAmount))
    
    UpdateOverheated(self, player)
    
    if self.shooting then
    
        local exoWeaponHolder = player:GetActiveWeapon()
        if exoWeaponHolder then
        
            local otherSlotWeapon = self:GetExoWeaponSlot() == ExoWeaponHolder.kSlotNames.Left and exoWeaponHolder:GetRightSlotWeapon() or exoWeaponHolder:GetLeftSlotWeapon()
            if otherSlotWeapon and otherSlotWeapon:isa("Minigun") then
                otherSlotWeapon:AddHeat(dt * kDualGunHeatUpRate)
            end
        
        end
    
    end
    
    if Client and not Shared.GetIsRunningPrediction() then
    
        local spinSound = Shared.GetEntity(self.spinSoundId)
        spinSound:SetParameter("heat", self.heatAmount, 1)
        
        if player:GetIsLocalPlayer() then
        
            local heatUISound = Shared.GetEntity(self.heatUISoundId)
            heatUISound:SetParameter("heat", self.heatAmount, 1)
            
        end
        
    end
    
end

function Minigun:OnUpdateRender()

    PROFILE("Minigun:OnUpdateRender")

    local parent = self:GetParent()
    if parent and parent:GetIsLocalPlayer() then
    
        local viewModel = parent:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
        
            viewModel:InstanceMaterials()
            viewModel:GetRenderModel():SetMaterialParameter("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
            
        end
        
        local heatDisplayUI = self.heatDisplayUI
        if not heatDisplayUI then
        
            heatDisplayUI = Client.CreateGUIView(242, 720)
            heatDisplayUI:Load("lua/GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "MinigunDisplay.lua")
            heatDisplayUI:SetTargetTexture("*exo_minigun_" .. self:GetExoWeaponSlotName())
            self.heatDisplayUI = heatDisplayUI
            
        end
        
        heatDisplayUI:SetGlobal("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
        
    else
    
        if self.heatDisplayUI then
        
            Client.DestroyGUIView(self.heatDisplayUI)
            self.heatDisplayUI = nil
            
        end
        
    end
    
    if self.shellsCinematic then
        self.shellsCinematic:SetIsActive(self.shooting)
    end
    
end

if Server then

    function Minigun:OnParentKilled(attacker, doer, point, direction)
    
        self.spinSound:Stop()
        self.heatUISound:Stop()
        self.shooting = false
        
    end
    
end

function Minigun:OnTag(tagName)

    PROFILE("Minigun:OnTag")
    
    if self:GetIsLeftSlot() and tagName == "l_shoot" then
        Shoot(self, true)
    elseif not self:GetIsLeftSlot() and tagName == "r_shoot" then
        Shoot(self, false)
    end
    
end

function Minigun:OnUpdateAnimationInput(modelMixin)

    local activity = "none"
    if self.overheated then
        activity = "overheat"
    elseif self.minigunAttacking then
        activity = "primary"
    end
    modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), activity)
    
end

if Client then

    local kMinigunMuzzleEffectRate = 0.15
    local kAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "fxnode_l_minigun_muzzle", [ExoWeaponHolder.kSlotNames.Right] = "fxnode_r_minigun_muzzle" }
    local kMuzzleEffectName = PrecacheAsset("cinematics/marine/minigun/muzzle_flash.cinematic")
    
    function Minigun:GetIsActive()
        return true
    end
    
    function Minigun:GetPrimaryEffectRate()
        return kMinigunMuzzleEffectRate
    end
    
    function Minigun:GetPrimaryAttacking()
        return self.shooting
    end
    
    function Minigun:GetSecondaryAttacking()
        return false
    end
    
    function Minigun:OnClientPrimaryAttacking()
    
        local parent = self:GetParent()
        
        if parent then
            CreateMuzzleCinematic(self, kMuzzleEffectName, kMuzzleEffectName, kAttachPoints[self:GetExoWeaponSlot()] , parent)
        end
    
    end
    
end

Shared.LinkClassToMap("Minigun", Minigun.kMapName, networkVars)
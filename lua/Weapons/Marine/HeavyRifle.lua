// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\HeavyRifle.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

class 'HeavyRifle' (ClipWeapon)

HeavyRifle.kMapName = "heavyrifle"

HeavyRifle.kModelName = PrecacheAsset("models/marine/rifle/rifle.model")
local kViewModelName = PrecacheAsset("models/marine/rifle/rifle_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/rifle/rifle_view.animation_graph")

local kHeavyRifleBulletSize = 0.22

local kRange = 250
// 4 degrees in NS1
local kSpread = Math.Radians(5)
local kMinSpread = Math.Radians(0.2)

local kButtRange = 1.1

local kNumberOfVariants = 3

local kSingleShotSounds = { "sound/NS2.fev/marine/rifle/fire_single", "sound/NS2.fev/marine/rifle/fire_single_2", "sound/NS2.fev/marine/rifle/fire_single_3" }
for k, v in ipairs(kSingleShotSounds) do PrecacheAsset(v) end

local kLoopingSounds = { "sound/NS2.fev/marine/rifle/fire_14_sec_loop", "sound/NS2.fev/marine/rifle/fire_loop_2", "sound/NS2.fev/marine/rifle/fire_loop_3",
                         "sound/NS2.fev/marine/rifle/fire_loop_1_upgrade_1", "sound/NS2.fev/marine/rifle/fire_loop_2_upgrade_1", "sound/NS2.fev/marine/rifle/fire_loop_3_upgrade_1",
                         "sound/NS2.fev/marine/rifle/fire_loop_1_upgrade_3", "sound/NS2.fev/marine/rifle/fire_loop_2_upgrade_3", "sound/NS2.fev/marine/rifle/fire_loop_3_upgrade_3" }

for k, v in ipairs(kLoopingSounds) do PrecacheAsset(v) end

local kEndSounds = { "sound/NS2.fev/marine/rifle/end", "sound/NS2.fev/marine/rifle/end_upgrade_1", "sound/NS2.fev/marine/rifle/end_upgrade_3"  }
for k, v in ipairs(kEndSounds) do PrecacheAsset(v) end

local kLoopingShellCinematic = PrecacheAsset("cinematics/marine/rifle/shell_looping.cinematic")
local kLoopingShellCinematicFirstPerson = PrecacheAsset("cinematics/marine/rifle/shell_looping_1p.cinematic")
local kShellEjectAttachPoint = "fxnode_riflecasing"

local kMuzzleCinematics = {
    PrecacheAsset("cinematics/marine/rifle/muzzle_flash.cinematic"),
    PrecacheAsset("cinematics/marine/rifle/muzzle_flash2.cinematic"),
    PrecacheAsset("cinematics/marine/rifle/muzzle_flash3.cinematic"),
}

local networkVars =
{
    soundType = "integer (1 to 9)"
}

AddMixinNetworkVars(LiveMixin, networkVars)

local kMuzzleEffect = PrecacheAsset("cinematics/marine/rifle/muzzle_flash.cinematic")
local kMuzzleAttachPoint = "fxnode_riflemuzzle"

local function DestroyMuzzleEffect(self)

    if self.muzzleCinematic then
        Client.DestroyCinematic(self.muzzleCinematic)            
    end
    
    self.muzzleCinematic = nil
    self.activeCinematicName = nil

end

local function DestroyShellEffect(self)

    if self.shellsCinematic then
        Client.DestroyCinematic(self.shellsCinematic)            
    end
    
    self.shellsCinematic = nil

end

local function CreateMuzzleEffect(self)

    local player = self:GetParent()

    if player then

        local cinematicName = kMuzzleCinematics[math.ceil(self.soundType / 3)]
        self.activeCinematicName = cinematicName
        self.muzzleCinematic = CreateMuzzleCinematic(self, cinematicName, cinematicName, kMuzzleAttachPoint, nil, Cinematic.Repeat_Endless)
        self.firstPersonLoaded = player:GetIsLocalPlayer() and player:GetIsFirstPerson()
    
    end

end

local function CreateShellCinematic(self)

    local parent = self:GetParent()

    if parent and Client.GetLocalPlayer() == parent then
        self.loadedFirstPersonShellEffect = true
    else
        self.loadedFirstPersonShellEffect = false
    end

    if self.loadedFirstPersonShellEffect then
        self.shellsCinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)        
        self.shellsCinematic:SetCinematic(kLoopingShellCinematicFirstPerson)
    else
        self.shellsCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.shellsCinematic:SetCinematic(kLoopingShellCinematic)
    end    
    
    self.shellsCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    
    if self.loadedFirstPersonShellEffect then    
        self.shellsCinematic:SetParent(parent:GetViewModelEntity())
    else
        self.shellsCinematic:SetParent(self)
    end
    
    self.shellsCinematic:SetCoords(Coords.GetIdentity())
    
    if self.loadedFirstPersonShellEffect then  
        self.shellsCinematic:SetAttachPoint(parent:GetViewModelEntity():GetAttachPointIndex(kShellEjectAttachPoint))
    else    
        self.shellsCinematic:SetAttachPoint(self:GetAttachPointIndex(kShellEjectAttachPoint))
    end    

    self.shellsCinematic:SetIsActive(false)

end

function HeavyRifle:OnCreate()

    ClipWeapon.OnCreate(self)
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LiveMixin)
    
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    elseif Server then
        self.soundVariant = Shared.GetRandomInt(1, kNumberOfVariants)
        self.soundType = self.soundVariant
    end
    
end

function HeavyRifle:OnDestroy()

    ClipWeapon.OnDestroy(self)
    
    DestroyMuzzleEffect(self)
    DestroyShellEffect(self)
    
end

local function UpdateSoundType(self, player)

    local upgradeLevel = 0
    
    if player.GetWeaponUpgradeLevel then
        upgradeLevel = math.max(0, player:GetWeaponUpgradeLevel() - 1)
    end

    self.soundType = self.soundVariant + upgradeLevel * kNumberOfVariants

end

function HeavyRifle:OnPrimaryAttack(player)

    if not self:GetIsReloading() then
    
        if Server then
            UpdateSoundType(self, player)
        end
        
        ClipWeapon.OnPrimaryAttack(self, player)
        
    end    

end

function HeavyRifle:OnHolster(player)

    DestroyMuzzleEffect(self)  
    DestroyShellEffect(self)  
    ClipWeapon.OnHolster(self, player)
    
end

function HeavyRifle:OnHolsterClient()
    DestroyMuzzleEffect(self)
    DestroyShellEffect(self)
    ClipWeapon.OnHolsterClient(self)
end


function HeavyRifle:GetAnimationGraphName()
    return kAnimationGraph
end

function HeavyRifle:GetViewModelName()
    return kViewModelName
end

function HeavyRifle:GetDeathIconIndex()
    return kDeathMessageIcon.Rifle    
end

function HeavyRifle:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function HeavyRifle:GetClipSize()
    return kHeavyRifleClipSize
end

function HeavyRifle:GetSpread()
    return kSpread
end

local function HeavyRifleRandom()
    return math.max(0.2 + NetworkRandom())
end

function HeavyRifle:CalculateSpreadDirection(shootCoords, player)
    return CalculateSpread(shootCoords, self:GetSpread() * self:GetInaccuracyScalar(player), HeavyRifleRandom)
end

function HeavyRifle:GetBulletDamage(target, endPoint)
    return kHeavyRifleDamage
end

function HeavyRifle:GetBulletSize()
    return kHeavyRifleBulletSize
end

function HeavyRifle:GetRange()
    return kRange
end

function HeavyRifle:GetWeight()
    return kHeavyRifleWeight
end

function HeavyRifle:GetSecondaryCanInterruptReload()
    return false
end

function HeavyRifle:SetGunLoopParam(viewModel, paramName, rateOfChange)

    local current = viewModel:GetPoseParam(paramName)
    // 0.5 instead of 1 as full arm_loop is intense.
    local new = Clamp(current + rateOfChange, 0, 0.5)
    viewModel:SetPoseParam(paramName, new)
    
end

function HeavyRifle:UpdateViewModelPoseParameters(viewModel)

    viewModel:SetPoseParam("hide_gl", 1)
    viewModel:SetPoseParam("gl_empty", 1)
    
    local attacking = self:GetPrimaryAttacking()
    local sign = (attacking and 1) or 0
    
    self:SetGunLoopParam(viewModel, "arm_loop", sign)
    
end

function HeavyRifle:OnUpdateAnimationInput(modelMixin)

    PROFILE("HeavyRifle:OnUpdateAnimationInput")
    
    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("gl", false)
    
end

function HeavyRifle:GetAmmoPackMapName()
    return RifleAmmo.kMapName
end

if Client then

    function HeavyRifle:OnClientPrimaryAttackStart()
    
        Shared.PlaySound(self, kLoopingSounds[self.soundType])
        
        local player = self:GetParent()
        
        if not self.muzzleCinematic then            
            CreateMuzzleEffect(self)                
        elseif player then
        
            local cinematicName = kMuzzleCinematics[math.ceil(self.soundType / 3)]
            local useFirstPerson = player:GetIsLocalPlayer() and player:GetIsFirstPerson()
            
            if cinematicName ~= self.activeCinematicName or self.firstPersonLoaded ~= useFirstPerson then
            
                DestroyMuzzleEffect(self)
                CreateMuzzleEffect(self)
                
            end
            
        end
            
        // CreateMuzzleCinematic() can return nil in case there is no parent or the parent is invisible (for alien commander for example)
        if self.muzzleCinematic then
            self.muzzleCinematic:SetIsVisible(true)
        end
        
        if player then
        
            local useFirstPerson = player == Client.GetLocalPlayer()
            
            if useFirstPerson ~= self.loadedFirstPersonShellEffect then
                DestroyShellEffect(self)
            end
        
            if not self.shellsCinematic then
                CreateShellCinematic(self)
            end
        
            self.shellsCinematic:SetIsActive(true)

        end
        
    end
    
    // needed for first person muzzle effect since it is attached to the view model entity: view model entity gets cleaned up when the player changes (for example becoming a commander and logging out again) 
    // this results in viewmodel getting destroyed / recreated -> cinematic object gets destroyed which would result in an invalid handle.
    function HeavyRifle:OnParentChanged(oldParent, newParent)
        
        ClipWeapon.OnParentChanged(self, oldParent, newParent)
        DestroyMuzzleEffect(self)
        DestroyShellEffect(self)
        
    end
    
    function HeavyRifle:OnClientPrimaryAttackEnd()
    
        // Just assume the looping sound is playing.
        Shared.StopSound(self, kLoopingSounds[self.soundType])
        Shared.PlaySound(self, kEndSounds[math.ceil(self.soundType / 3)])
        
        if self.muzzleCinematic then
            self.muzzleCinematic:SetIsVisible(false)
        end
        
        if self.shellsCinematic then
            self.shellsCinematic:SetIsActive(false)
        end
        
    end
    
    function HeavyRifle:GetPrimaryEffectRate()
        return 0.08
    end
    
    function HeavyRifle:GetBarrelPoint()
    
        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
            
            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.15 + viewCoords.yAxis * -0.22
            
        end
        
        return self:GetOrigin()
        
    end
    
    function HeavyRifle:GetUIDisplaySettings()
        return { xSize = 256, ySize = 417, script = "lua/GUIHeavyRifleDisplay.lua", textureNameOverride = "rifle" }
    end
    
end

function HeavyRifle:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
    
end

function HeavyRifle:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function HeavyRifle:OnKill()
        DestroyEntity(self)
    end
    
    function Rifle:GetSendDeathMessageOverride()
        return false
    end 
    
end

Shared.LinkClassToMap("HeavyRifle", HeavyRifle.kMapName, networkVars)
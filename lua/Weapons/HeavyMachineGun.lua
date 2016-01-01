// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\HeavyRifle.lua
//
// lua\Weapons\HeavyMachineGun.lua
//

Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

class 'HeavyMachineGun' (ClipWeapon)

HeavyMachineGun.kMapName = "heavymachinegun"

HeavyMachineGun.kModelName = PrecacheAsset("models/marine/rifle/lmg.model")

local kDefaultVariantData = kMarineVariantData[ kDefaultMarineVariant ]

//DINGUS
function GenerateMarineRifleViewModelPaths()

    local viewModels = { }
    
    local function MakePath( variant )
        return "models/marine/rifle/lmg_view"..variant..".model"
    end
    
    for variant, data in pairs(kMarineVariantData) do
        viewModels[variant] = PrecacheAssetSafe( MakePath( data.viewModelFilePart), MakePath( kDefaultVariantData.viewModelFilePart) )
    end
    
    return viewModels
    
end

local kViewModels = GenerateMarineRifleViewModelPaths()

local kAnimationGraph = PrecacheAsset("models/marine/rifle/rifle_view.animation_graph")

local kRange = 100

local kSingleShotSound = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_2")
local kEndSound = PrecacheAsset("sound/NS2.fev/marine/rifle/end")

local kLoopingShellCinematic = PrecacheAsset("cinematics/marine/rifle/shell_looping.cinematic")
local kLoopingShellCinematicFirstPerson = PrecacheAsset("cinematics/marine/rifle/shell_looping_1p.cinematic")
local kShellEjectAttachPoint = "fxnode_riflecasing"

local kMuzzleEffect = PrecacheAsset("cinematics/marine/rifle/muzzle_flash.cinematic")
local kMuzzleAttachPoint = "fxnode_riflemuzzle"

local networkVars = 
{ 
	shooting = "boolean"
}

AddMixinNetworkVars(LiveMixin, networkVars)

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

        local cinematicName = kMuzzleEffect
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

function HeavyMachineGun:OnCreate()

    ClipWeapon.OnCreate(self)
	
	InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end
    
end

function HeavyMachineGun:OnDestroy()

    ClipWeapon.OnDestroy(self)
    
    DestroyMuzzleEffect(self)
    DestroyShellEffect(self)
    
end

function HeavyMachineGun:OnPrimaryAttack(player)

    if not self:GetIsReloading() then
    
        ClipWeapon.OnPrimaryAttack(self, player)
        
    end    

end

function HeavyMachineGun:GetNumStartClips()
    return 3
end

function HeavyMachineGun:GetMaxAmmo()
    return 3 * self:GetClipSize()
end

function HeavyMachineGun:OnHolster(player)

    DestroyMuzzleEffect(self)
    DestroyShellEffect(self)
    ClipWeapon.OnHolster(self, player)
    
end

function HeavyMachineGun:OnHolsterClient()

    DestroyMuzzleEffect(self)
    DestroyShellEffect(self)
    ClipWeapon.OnHolsterClient(self)
    
end

function HeavyMachineGun:GetAnimationGraphName()
    return kAnimationGraph
end

function HeavyMachineGun:GetViewModelName(sex, variant)
    return kViewModels[variant]
end

function HeavyMachineGun:GetDeathIconIndex()
    return kDeathMessageIcon.Crush
end

function HeavyMachineGun:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function HeavyMachineGun:GetClipSize()
  if GetHasTech(self:GetParent(), kTechId.RifleClip) then return kHeavyMachineGunClipSize + 25
  else
    return kHeavyMachineGunClipSize
    end
end

function HeavyMachineGun:GetSpread()
    return kHeavyMachineGunSpread
end

function HeavyMachineGun:GetBulletDamage(target, endPoint)
    return kHeavyMachineGunDamage
end

function HeavyMachineGun:GetRange()
    return kRange
end

function HeavyMachineGun:GetWeight()
 return kHeavyMachineGunWeight
end

function HeavyMachineGun:GetDamageType()
    local parent = self:GetParent()
    if parent and parent.hasfirebullets then
      return  kDamageType.PunctureFlame
   else
      return kHeavyMachineGunDamageType
    end
end

function HeavyMachineGun:GetCatalystSpeedBase()
local base = 1
	if self.deployed then
		base = 0.45
    end
    
   // if self.primaryAttacking then
   //     base = 2 //0.25 //0.5
   // end
    
	if self.reloading then 
        base = 0.38
	end
	
	return base
end

function HeavyMachineGun:OnSecondaryAttack(player)
end

function HeavyMachineGun:OverrideWeaponName()
    return "rifle"
end

function HeavyMachineGun:SetGunLoopParam(viewModel, paramName, rateOfChange)

    local current = viewModel:GetPoseParam(paramName)
    // 0.5 instead of 1 as full arm_loop is intense.
    local new = Clamp(current + rateOfChange, 0, 0.5)
    viewModel:SetPoseParam(paramName, new)
    
end

function HeavyMachineGun:UpdateViewModelPoseParameters(viewModel)

    viewModel:SetPoseParam("hide_gl", 1)
    viewModel:SetPoseParam("gl_empty", 1)
    
    local attacking = self:GetPrimaryAttacking()
    local sign = (attacking and 1) or 0
    
    self:SetGunLoopParam(viewModel, "arm_loop", sign)
    
end

function HeavyMachineGun:CanReload()
    return ClipWeapon.CanReload(self) and self.deployed
end

function HeavyMachineGun:OnReload(player)

    if self:CanReload() then
    
        self:TriggerEffects("reload")
        self.reloading = true
        self.reloadstart = Shared.GetTime()
    end
    
end

function HeavyMachineGun:OnTag(tagName)
	ClipWeapon.OnTag(self, tagName)
	
	if tagName == "reload_end" then
		if self.reloadstart then
			//Shared.Message(string.format("Reload took %s seconds!", Shared.GetTime() - self.reloadstart))
			self.reloadstart = nil
		end
	end
		
end

function HeavyMachineGun:OnUpdateAnimationInput(modelMixin)

    PROFILE("HeavyMachineGun:OnUpdateAnimationInput")
    
    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("gl", false)
    
end

function HeavyMachineGun:GetAmmoPackMapName()
    return HeavyMachineGunAmmo.kMapName
end

if Client then

    function HeavyMachineGun:OnClientPrimaryAttackStart()
      //  Shared.StopSound(self, kSingleShotSound)
        Shared.PlaySound(self, kSingleShotSound)        
		//Shared.PlaySound(self, kLoopingSound)
        
        local player = self:GetParent()
       //  self:SetCameraShake(1, 1, 1)
        if not self.muzzleCinematic then            
            CreateMuzzleEffect(self)                
        elseif player then
        
            local cinematicName = kMuzzleEffect
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
    
    function HeavyMachineGun:OnClientPrimaryAttacking()
      //  Shared.StopSound(self, kSingleShotSound)
        Shared.PlaySound(self, kSingleShotSound)
    end

	// needed for first person muzzle effect since it is attached to the view model entity: view model entity gets cleaned up when the player changes (for example becoming a commander and logging out again) 
    // this results in viewmodel getting destroyed / recreated -> cinematic object gets destroyed which would result in an invalid handle.
    function HeavyMachineGun:OnParentChanged(oldParent, newParent)
        
        ClipWeapon.OnParentChanged(self, oldParent, newParent)
        DestroyMuzzleEffect(self)
        DestroyShellEffect(self)
        
    end
    
    function HeavyMachineGun:OnClientPrimaryAttackEnd()
    
        // Just assume the looping sound is playing.
        Shared.StopSound(self, kSingleShotSound)
		//Shared.StopSound(self, kLoopingSound)
        Shared.PlaySound(self, kEndSound)
        
		if self.muzzleCinematic then
            self.muzzleCinematic:SetIsVisible(false)
        end
        
        if self.shellsCinematic then
            self.shellsCinematic:SetIsActive(false)
        end
        
    end
    
    function HeavyMachineGun:GetPrimaryEffectRate()
        return 0.07
    end

	function HeavyMachineGun:GetTriggerPrimaryEffects()
        return not self:GetIsReloading() and self.shooting
    end
    
    function HeavyMachineGun:GetBarrelPoint()
    
        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
            
            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.15 + viewCoords.yAxis * -0.22
            
        end
        
        return self:GetOrigin()
        
    end
    
    function HeavyMachineGun:GetUIDisplaySettings()
        return { xSize = 256, ySize = 417, script = "lua/Marines/GUIHeavyMachineGunDisplay.lua", textureNameOverride = "rifle"  }
    end
end

function HeavyMachineGun:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
    
end

function HeavyMachineGun:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function HeavyMachineGun:OnKill()
        DestroyEntity(self)
    end
    
    function HeavyMachineGun:GetSendDeathMessageOverride()
        return false
    end 
    
end

Shared.LinkClassToMap("HeavyMachineGun", HeavyMachineGun.kMapName, networkVars)

// -------------

class 'HeavyMachineGunAmmo' (WeaponAmmoPack)
HeavyMachineGunAmmo.kMapName = "heavymachinegunammo"
HeavyMachineGunAmmo.kModelName = PrecacheAsset("models/marine/ammopacks/hmg.model")

function HeavyMachineGunAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)    
    self:SetModel(HeavyMachineGunAmmo.kModelName)

end

function HeavyMachineGunAmmo:GetWeaponClassName()
    return "HeavyMachineGun"
end

Shared.LinkClassToMap("HeavyMachineGunAmmo", HeavyMachineGunAmmo.kMapName)
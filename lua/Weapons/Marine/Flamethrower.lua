Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/Weapons/Marine/Flame.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/Weapons/Marine/FireGrenade.lua")

class 'Flamethrower' (ClipWeapon)

if Client then
    Script.Load("lua/Weapons/Marine/Flamethrower_Client.lua")
end

Flamethrower.kMapName = "flamethrower"

Flamethrower.kModelName = PrecacheAsset("models/marine/flamethrower/flamethrower.model")
local kViewModels = GenerateMarineViewModelPaths("flamethrower")
local kAnimationGraph = PrecacheAsset("models/marine/flamethrower/flamethrower_view.animation_graph")

local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/flamethrower/attack_loop")

local kRange = kFlamethrowerRange
local kUpgradedRange = kFlamethrowerUpgradedRange

local kConeWidth = 0.17

local networkVars =
{ 
    createParticleEffects = "boolean",
    animationDoneTime = "float",
    loopingSoundEntId = "entityid",
    range = "integer (0 to 11)"
}

AddMixinNetworkVars(LiveMixin, networkVars)

function Flamethrower:OnCreate()

    ClipWeapon.OnCreate(self)
    
    self.loopingSoundEntId = Entity.invalidId
    
    if Server then
    
        self.createParticleEffects = false
        self.animationDoneTime = 0
        
        self.loopingFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingFireSound:SetAsset(kFireLoopingSound)
        self.loopingFireSound:SetParent(self)
        self.loopingSoundEntId = self.loopingFireSound:GetId()
        
    elseif Client then
    
        self:SetUpdates(true)
        self.lastAttackEffectTime = 0.0
        
    end
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, PointGiverMixin)

end

function Flamethrower:OnDestroy()

    ClipWeapon.OnDestroy(self)
    
    // The loopingFireSound was already destroyed at this point, clear the reference.
    if Server then
        self.loopingFireSound = nil
    elseif Client then
    
        if self.trailCinematic then
            Client.DestroyTrailCinematic(self.trailCinematic)
            self.trailCinematic = nil
        end
        
        if self.pilotCinematic then
            Client.DestroyCinematic(self.pilotCinematic)
            self.pilotCinematic = nil
        end
        
    end
    
end

function Flamethrower:GetAnimationGraphName()
    return kAnimationGraph
end

function Flamethrower:GetWeight()
    return kFlamethrowerWeight
end

function Flamethrower:OnHolster(player)

    ClipWeapon.OnHolster(self, player)
    
    self.createParticleEffects = false
    
end

function Flamethrower:OnDraw(player, previousWeaponMapName)

    ClipWeapon.OnDraw(self, player, previousWeaponMapName)
    
    self.createParticleEffects = false
    self.animationDoneTime = Shared.GetTime()
    
end

function Flamethrower:GetClipSize()
    return kFlamethrowerClipSize
end

function Flamethrower:CreatePrimaryAttackEffect(player)

    // Remember this so we can update gun_loop pose param
    self.timeOfLastPrimaryAttack = Shared.GetTime()

end

function Flamethrower:GetRange()
    return self.range
end

function Flamethrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function Flamethrower:FirePrimary(player, bullets, range, penetration)
    ShootFireGrenade(self, player)
end
local function ShootFireGrenade(self, player)

    PROFILE("ShootGrenade")
    
    self:TriggerEffects("grenadelauncher_attack")

    if Server or (Client and Client.GetIsControllingPlayer()) then

        local viewCoords = player:GetViewCoords()
        local eyePos = player:GetEyePos()

        local startPointTrace = Shared.TraceCapsule(eyePos, eyePos + viewCoords.zAxis, 0.2, 0, CollisionRep.Move, PhysicsMask.PredictedProjectileGroup, EntityFilterTwo(self, player))
        local startPoint = startPointTrace.endPoint

        local direction = viewCoords.zAxis
        
        if startPointTrace.fraction ~= 1 then
            direction = GetNormalizedVector(direction:GetProjection(startPointTrace.normal))
        end
               local grenade = player:CreatePredictedProjectile("FireGrenade", startPoint, direction * kGrenadeSpeed, 0.7, 0.45)

    end

end
function Flamethrower:GetDeathIconIndex()
    return kDeathMessageIcon.Flamethrower
end

function Flamethrower:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function Flamethrower:GetIsAffectedByWeaponUpgrades()
    return false
end

function Flamethrower:OnPrimaryAttack(player)

    if not self:GetIsReloading() then
    
        ClipWeapon.OnPrimaryAttack(self, player)
        
        if self:GetIsDeployed() and self:GetClip() > 0 and self:GetPrimaryAttacking() then
        
            if not self.createParticleEffects then
                self:TriggerEffects("flamethrower_attack_start")
            end
        
            self.createParticleEffects = true
            
            if Server and not self.loopingFireSound:GetIsPlaying() then
                self.loopingFireSound:Start()
            end
            
        end
        
        if self.createParticleEffects and self:GetClip() == 0 then
        
            self.createParticleEffects = false
            
            if Server then
                self.loopingFireSound:Stop()
            end
            
        end
    
        // Fire the cool flame effect periodically
        // Don't crank the period too low - too many effects slows down the game a lot.
        if Client and self.createParticleEffects and self.lastAttackEffectTime + 0.5 < Shared.GetTime() then
            
            self:TriggerEffects("flamethrower_attack")
            self.lastAttackEffectTime = Shared.GetTime()

        end
        
    end
    
end

function Flamethrower:OnPrimaryAttackEnd(player)

    ClipWeapon.OnPrimaryAttackEnd(self, player)

    self.createParticleEffects = false
        
    if Server then    
        self.loopingFireSound:Stop()        
    end
    
end

function Flamethrower:OnReload(player)

    if self:CanReload() then
    
        if Server then
        
            self.createParticleEffects = false
            self.loopingFireSound:Stop()
        
        end
        
        self:TriggerEffects("reload")
        self.reloading = true
        
    end
    
end

function Flamethrower:GetUpgradeTechId()
    return kTechId.FlamethrowerRangeTech
end

function Flamethrower:GetHasSecondary(player)
    return false
end

function Flamethrower:GetSwingSensitivity()
    return 0.8
end

function Flamethrower:Dropped(prevOwner)

    ClipWeapon.Dropped(self, prevOwner)
    
    if Server then
    
        self.createParticleEffects = false
        self.loopingFireSound:Stop()
        
    end
    
end

function Flamethrower:GetAmmoPackMapName()
    return FlamethrowerAmmo.kMapName
end

function Flamethrower:GetNotifiyTarget()
    return false
end

function Flamethrower:GetIdleAnimations(index)
    local animations = {"idle", "idle_fingers", "idle_clean"}
    return animations[index]
end

function Flamethrower:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function Flamethrower:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function Flamethrower:OnKill()
        DestroyEntity(self)
    end
    
    function Flamethrower:GetSendDeathMessageOverride()
        return false
    end 
    
    function Flamethrower:OnProcessMove(input)
        
        ClipWeapon.OnProcessMove(self, input)
        
        local hasRangeTech = false
        local parent = self:GetParent()
        if parent then
            hasRangeTech = GetHasTech(parent, kTechId.FlamethrowerRangeTech)
        end
        
        self.range = hasRangeTech and kUpgradedRange or kRange

    end
    
end

if Client then

    function Flamethrower:GetUIDisplaySettings()
        return { xSize = 128, ySize = 256, script = "lua/GUIFlamethrowerDisplay.lua" }
    end

end

Shared.LinkClassToMap("Flamethrower", Flamethrower.kMapName, networkVars)

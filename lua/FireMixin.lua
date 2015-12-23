// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\FireMixin.lua    
//    
//    Created by:   Andrew Spiering (andrew@unknownworlds.com) and
//                  Andreas Urwalek (andi@unknownworlds.com)   
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

FireMixin = CreateMixin( FireMixin )
FireMixin.type = "Fire"

PrecacheAsset("cinematics/vfx_materials/burning.surface_shader")
PrecacheAsset("cinematics/vfx_materials/burning_view.surface_shader")

local kBurningViewMaterial = PrecacheAsset("cinematics/vfx_materials/burning_view.material")
local kBurningMaterial = PrecacheAsset("cinematics/vfx_materials/burning.material")
local kBurnBigCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_big.cinematic")
local kBurnHugeCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_huge.cinematic")
local kBurnMedCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_med.cinematic")
local kBurnSmallCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_small.cinematic")
local kBurn1PCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_1p.cinematic")

local kBurnUpdateRate = 1

local kFireCinematicTable = { }
kFireCinematicTable["Hive"] = kBurnHugeCinematic
kFireCinematicTable["CommandStation"] = kBurnHugeCinematic
kFireCinematicTable["Clog"] = kBurnSmallCinematic
kFireCinematicTable["Onos"] = kBurnBigCinematic
kFireCinematicTable["MAC"] = kBurnSmallCinematic
kFireCinematicTable["Drifter"] = kBurnSmallCinematic
kFireCinematicTable["Sentry"] = kBurnSmallCinematic
kFireCinematicTable["Egg"] = kBurnSmallCinematic
kFireCinematicTable["Embryo"] = kBurnSmallCinematic

local function GetOnFireCinematic(ent, firstPerson)

    if firstPerson then
        return kBurn1PCinematic
    end
    
    return kFireCinematicTable[ent:GetClassName()] or kBurnMedCinematic
    
end

local kFireLoopingSound = { }
kFireLoopingSound["Entity"] = PrecacheAsset("sound/NS2.fev/common/fire_small")
kFireLoopingSound["Onos"] = PrecacheAsset("sound/NS2.fev/common/fire_large")
kFireLoopingSound["Hive"] = PrecacheAsset("sound/NS2.fev/common/fire_large")

local function GetOnFireSound(entClassName)
    return kFireLoopingSound[entClassName] or kFireLoopingSound["Entity"]
end
FireMixin.networkVars =
{
    isOnFire = "boolean"
}

function FireMixin:__initmixin()

    if Server then
    
        self.fireAttackerId = Entity.invalidId
        self.fireDoerId = Entity.invalidId
        
        self.timeBurnInit = 0        
        self.isOnFire = false
        
        self.onFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.onFireSound:SetAsset(GetOnFireSound(self:GetClassName()))
        self.onFireSound:SetParent(self)
        
    end
    
end

function FireMixin:OnDestroy()

    if self:GetIsOnFire() then
        self:SetGameEffectMask(kGameEffect.OnFire, false)
    end
    
    if Server then
    
        -- The onFireSound was already destroyed at this point, clear the reference.
        self.onFireSound = nil
        
    end
    
end

function FireMixin:SetOnFire(attacker, doer, duration)

    if Server and not self:GetIsDestroyed() then
    
        if not self:GetCanBeSetOnFire() then
            return
        end
        
        self:SetGameEffectMask(kGameEffect.OnFire, true)
        
        if attacker then
            self.fireAttackerId = attacker:GetId()
        end
        
        if doer then
            self.fireDoerId = doer:GetId()
        end
        if self:isa("Player") then
           self.enzymed = false
           self.primaled = false
        end                             
        local durationy = duration or 0
        local hackedmod = Shared.GetTime() + (durationy - kFlamethrowerBurnDuration)
        self.timeBurnInit = duration and hackedmod or Shared.GetTime()
        self.isOnFire = true
        
    end
    
end

function FireMixin:GetIsOnFire()

    if Client then
        return self.isOnFire
    end
    
    return self:GetGameEffectMask(kGameEffect.OnFire)
    
end

function FireMixin:GetCanBeSetOnFire()

    if self.OnOverrideCanSetFire then
        return self:OnOverrideCanSetFire()
    else
        return true
    end
    
end


function UpdateFireMaterial(self)

    if self._renderModel then
    
        if self.isOnFire and not self.fireMaterial then
        
            self.fireMaterial = Client.CreateRenderMaterial()
            self.fireMaterial:SetMaterial(kBurningMaterial)
            self._renderModel:AddMaterial(self.fireMaterial)
            
        elseif not self.isOnFire and self.fireMaterial then
        
            self._renderModel:RemoveMaterial(self.fireMaterial)
            Client.DestroyRenderMaterial(self.fireMaterial)
            self.fireMaterial = nil
            
        end
        
    end

    if self:isa("Player") and self:GetIsLocalPlayer() then
    
        local viewModelEntity = self:GetViewModelEntity()
        if viewModelEntity then
        
            local viewModel = self:GetViewModelEntity():GetRenderModel()
            if viewModel and (self.isOnFire and not self.viewFireMaterial) then
            
                self.viewFireMaterial = Client.CreateRenderMaterial()
                self.viewFireMaterial:SetMaterial(kBurningViewMaterial)
                viewModel:AddMaterial(self.viewFireMaterial)
                
            elseif viewModel and (not self.isOnFire and self.viewFireMaterial) then
            
                viewModel:RemoveMaterial(self.viewFireMaterial)
                Client.DestroyRenderMaterial(self.viewFireMaterial)
                self.viewFireMaterial = nil
                
            end
            
        end
        
    end
    
end

local function SharedUpdate(self, deltaTime)
    PROFILE("FireMixin:OnUpdate")
    if Client then
        UpdateFireMaterial(self)
        self:_UpdateClientFireEffects()
    end

    if not self:GetIsOnFire() then
        return
    end
    
    if Server then
    
        if self:GetIsAlive() and (not self.timeLastFireDamageUpdate or self.timeLastFireDamageUpdate + kBurnUpdateRate <= Shared.GetTime()) then
    
            local damageOverTime = kBurnUpdateRate * kBurnDamagePerSecond
            if self.GetIsFlameAble and self:GetIsFlameAble() then
                damageOverTime = damageOverTime * kFlameableMultiplier
            end
            
            local attacker = nil
            if self.fireAttackerId ~= Entity.invalidId then
                attacker = Shared.GetEntity(self.fireAttackerId)
            end

            local doer = nil
            if self.fireDoerId ~= Entity.invalidId then
                doer = Shared.GetEntity(self.fireDoerId)
            end
            
            local killedFromDamage, damageDone = self:DeductHealth(damageOverTime, attacker, doer)

            if attacker then
            
                SendDamageMessage( attacker, self, damageDone, self:GetOrigin(), damageDone )                
            
            end
            
            self.timeLastFireDamageUpdate = Shared.GetTime()
            
        end
        
        // See if we put ourselves out
        if Shared.GetTime() - self.timeBurnInit > kFlamethrowerBurnDuration then
            self:SetGameEffectMask(kGameEffect.OnFire, false)
        end
        
    end
    
end

function FireMixin:OnUpdate(deltaTime)   
    SharedUpdate(self, deltaTime)
end

function FireMixin:OnProcessMove(input)   
    SharedUpdate(self, input.time)
end

if Client then
    
    function FireMixin:_UpdateClientFireEffects()

        // Play on-fire cinematic every so often if we're on fire
        if self:GetGameEffectMask(kGameEffect.OnFire) and self:GetIsAlive() and self:GetIsVisible() then
        
            // If we haven't played effect for a bit
            local time = Shared.GetTime()
            
            if not self.timeOfLastFireEffect or (time > (self.timeOfLastFireEffect + .5)) then
            
                local firstPerson = (Client.GetLocalPlayer() == self)
                local cinematicName = GetOnFireCinematic(self, firstPerson)
                
                if firstPerson then
                    local viewModel = self:GetViewModelEntity()
                    if viewModel then
                        Shared.CreateAttachedEffect(self, cinematicName, viewModel, Coords.GetTranslation(Vector(0, 0, 0)), "", true, false)
                    end
                else
                    Shared.CreateEffect(self, cinematicName, self, self:GetAngles():GetCoords())
                end
                
                self.timeOfLastFireEffect = time
                
            end
            
        end
        
    end

end

function FireMixin:OnEntityChange(entityId, newEntityId)

    if entityId == self.fireAttackerId then
        self.fireAttackerId = newEntityId or Entity.invalidId
    end
    
    if entityId == self.fireDoerId then
        self.fireDoerId = newEntityId or Entity.invalidId
    end
    
end

function FireMixin:OnGameEffectMaskChanged(effect, state)

    if effect == kGameEffect.OnFire and state then
    
        if Server and not self.onFireSound:GetIsPlaying() then
            self.onFireSound:Start()
        end
        
    elseif effect == kGameEffect.OnFire and not state then
    
        self.fireAttackerId = Entity.invalidId
        self.fireDoerId = Entity.invalidId
        
        if Server then
            self.onFireSound:Stop()
        end
        
        self.timeBurnInit  = 0 
        
        self.isOnFire = false
        
    end
    
end

function FireMixin:OnUpdateAnimationInput(modelMixin)
    PROFILE("FireMixin:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("onfire", self:GetIsOnFire())
end
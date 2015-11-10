Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/Weapons/DotMarker.lua")

PrecacheAsset("cinematics/vfx_materials/decals/alien_blood.surface_shader")

class 'HallucinatedExplosion' (PredictedProjectile)

HallucinatedExplosion.kMapName            = "hallucinatedexplosion"
HallucinatedExplosion.kModelName          = PrecacheAsset("models/alien/gorge/bilebomb.model")

HallucinatedExplosion.kRadius             = 0.2
HallucinatedExplosion.kClearOnImpact      = true
HallucinatedExplosion.kClearOnEnemyImpact = true

// The max amount of time a Bomb can last for
HallucinatedExplosion.kLifetime = 6

local kExplosionDotInterval = 0.4

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function HallucinatedExplosion:OnCreate()
    
    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    
    if Server then
        self:AddTimedCallback(HallucinatedExplosion.TimeUp, HallucinatedExplosion.kLifetime)
    end

end

function HallucinatedExplosion:GetDeathIconIndex()
    return 
end

if Server then

    local function SineFalloff(distanceFraction)
        local piFraction = Clamp(distanceFraction, 0, 1) * math.pi / 2
        return math.cos(piFraction + math.pi) + 1 
    end

    function HallucinatedExplosion:ProcessHit(targetHit, surface, normal)        
        
        local dotMarker = CreateEntity(DotMarker.kMapName, self:GetOrigin() + normal * 0.2, self:GetTeamNumber())
        dotMarker:SetDamageType(kBileBombDamageType)
        dotMarker:SetLifeTime(kBileBombDuration)
        dotMarker:SetDamage(kBileBombDamage)
        dotMarker:SetRadius(kBileBombSplashRadius)
        dotMarker:SetDamageIntervall(kBileBombDotInterval)
        dotMarker:SetDotMarkerType(DotMarker.kType.Static)
        dotMarker:SetTargetEffectName("bilebomb_onstructure")
        dotMarker:SetDeathIconIndex(kDeathMessageIcon.BileBomb)
        dotMarker:SetOwner(self:GetOwner())
        dotMarker:SetFallOffFunc(SineFalloff)
        
        dotMarker:TriggerEffects("bilebomb_hit")

        DestroyEntity(self)
        
        CreateExplosionDecals(self, "bilebomb_decal")

    end
    
    function HallucinatedExplosion:TimeUp(currentRate)

        DestroyEntity(self)
        return false
    
    end

end

function HallucinatedExplosion:GetNotifiyTarget()
    return false
end


Shared.LinkClassToMap("HallucinatedExplosion", HallucinatedExplosion.kMapName, networkVars)
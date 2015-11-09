Script.Load("lua/CommAbilities/CommanderAbility.lua")
//Script.Load("lua/Weapons/Alien/HallucinatedExplosion.lua")

class 'HallucinationExplosion' (CommanderAbility)


HallucinationExplosion.kMapName = "hallucinationexplosion"


PrecacheAsset("cinematics/vfx_materials/decals/alien_blood.surface_shader")


HallucinationExplosion.kEffect = PrecacheAsset("cinematics/alien/drifter/flare.cinematic")
local kExplosionSound = PrecacheAsset("sound/NS2.fev/alien/skulk/jump_best_for_enemy") 

HallucinationExplosion.kType = CommanderAbility.kType.Instant

// duration of cinematic, increase cinematic duration and kCragUmbraDuration to 12 to match the old value from Crag.lua
HallucinationExplosion.kExplosionDuration = 1
HallucinationExplosion.kRadius = 12
if Server then
    function HallucinationExplosion:OnCreate()
        CommanderAbility.OnCreate(self)
    end
    
end
local kUpdateTime = 0.15

local networkVars = {}

function HallucinationExplosion:GetStartCinematic()
    return HallucinationExplosion.kEffect
end
function HallucinationExplosion:GetRepeatCinematic()
    return HallucinationExplosion.kEffect
end
function HallucinationExplosion:GetType()
    return HallucinationExplosion.kType
end
    
function HallucinationExplosion:GetLifeSpan()
    return HallucinationExplosion.kExplosionDuration
end

function HallucinationExplosion:OnInitialized()

    CommanderAbility.OnInitialized(self)
    if Server then
    Shared.PlayWorldSound(nil, kExplosionSound, nil, self:GetOrigin()) 
    end 
    /*
    if Client then
        DebugCapsule(self:GetOrigin(), self:GetOrigin(), CragUmbra.kRadius, 0, CragUmbra.kCragUmbraDuration)
    end
    */
    
end

function HallucinationExplosion:GetUpdateTime()
    return kUpdateTime
end

if Server then

    function HallucinationExplosion:Perform()

                local hallucination = CreateEntity(Hallucination.kMapName, self:GetOrigin(), 2)
                hallucination:SetEmulation(kTechId.HallucinateOnos)
                hallucination:AdjustMaxHealth(kOnosHealth)
                hallucination:AdjustMaxArmor(kOnosArmor)
         //  if GetHasTech(self, kTechId.ControlledHallucinationTierTwo) then 
                hallucination.controlledhallucination = true
            //    hallucination:AdjustMaxHealth(kOnosHealth / 2)
            //    hallucination:AdjustMaxArmor(kOnosArmor / 2)
           //   end
          //if GetHasTech(self, kTechId.ControlledHallucinationTierThree) then
            //  hallucination.tierthree = true
          //end
    end

end

Shared.LinkClassToMap("HallucinationExplosion", HallucinationExplosion.kMapName, networkVars)
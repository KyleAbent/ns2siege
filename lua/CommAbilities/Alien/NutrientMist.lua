// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\NutrientMist.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'NutrientMist' (CommanderAbility)

NutrientMist.kMapName = "nutrientmist"

NutrientMist.kNutrientMistEffect = PrecacheAsset("cinematics/alien/nutrientmist.cinematic")
NutrientMist.kNutrientMistEffect2 = PrecacheAsset("cinematics/alien/nutrientmist2.cinematic")

NutrientMist.kMistSound = PrecacheAsset("sound/NS2.fev/alien/commander/catalyze_3D")

NutrientMist.kType = CommanderAbility.kType.Repeat
NutrientMist.kSearchRange = 10

local netWorkVars =
{
}

if Server then

    function NutrientMist:OnInitialized()
    
        CommanderAbility.OnInitialized(self)
        
        // never show for marine commander
        local mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom, kRelevantToTeam2Commander)
        self:SetExcludeRelevancyMask(mask)
        
        StartSoundEffectAtOrigin(NutrientMist.kMistSound, self:GetOrigin())

    end

end

function NutrientMist:Perform()

    self.success = false

    local entities = GetEntitiesWithMixinForTeamWithinRange("Catalyst", self:GetTeamNumber(), self:GetOrigin(), NutrientMist.kSearchRange)
    
    for index, entity in ipairs(entities) do    
        entity:TriggerCatalyst(2)    
    end

end

function NutrientMist:GetStartCinematic()
   local random = math.random(1,2)
   if random == 1 then
    return NutrientMist.kNutrientMistEffect
    else
        return NutrientMist.kNutrientMistEffect2
    end
end

function NutrientMist:GetType()
    return NutrientMist.kType
end

function NutrientMist:GetUpdateTime()
    return 1.5
end

function NutrientMist:GetLifeSpan()
    return kNutrientMistDuration
end

Shared.LinkClassToMap("NutrientMist", NutrientMist.kMapName, netWorkVars)
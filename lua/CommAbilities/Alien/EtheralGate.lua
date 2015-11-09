// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\NutrientMist.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'EtherealGate' (CommanderAbility)

EtherealGate.kMapName = "etherealgate"

EtherealGate.kVortexLoopingCinematic = PrecacheAsset("cinematics/alien/fade/vortex.cinematic")

EtherealGate.kVortexLoopingSound = PrecacheAsset("sound/NS2.fev/alien/fade/vortex_loop")

EtherealGate.kType = CommanderAbility.kType.Repeat
EtherealGate.kSearchRange = 4
kEtherealGateLifeTime = 20
local netWorkVars =
{
}

if Server then

    function EtherealGate:OnInitialized()
    
        CommanderAbility.OnInitialized(self)
        
        // never show for marine commander
        local mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom, kRelevantToTeam2Commander)
        self:SetExcludeRelevancyMask(mask)
        
        StartSoundEffectAtOrigin(EtherealGate.kVortexLoopingSound, self:GetOrigin())

    end

end

function EtherealGate:Perform()

    self.success = false

    local entities = GetEntitiesWithMixinForTeamWithinRange("VortexAble", 1, self:GetOrigin(), EtherealGate.kSearchRange)
    
    for index, entity in ipairs(entities) do    
       if enetity:GetCanBeVortexed() then
        entity:SetVortexDuration(kEtherealGateLifeTime)   
       end 
    end

end

function EtherealGate:GetStartCinematic()
    return EtherealGate.kVortexLoopingCinematic
end

function EtherealGate:GetType()
    return EtherealGate.kType
end

function EtherealGate:GetUpdateTime()
    return 1.5
end

function NutrientMist:GetLifeSpan()
    return kEtherealGateLifeTime
end

Shared.LinkClassToMap("NutrientMist", NutrientMist.kMapName, netWorkVars)
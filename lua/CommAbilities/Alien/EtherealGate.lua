Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'EtherealGate' (CommanderAbility)

EtherealGate.kMapName = "etherealgate"

EtherealGate.kVortexLoopingCinematic = PrecacheAsset("cinematics/alien/fade/vortex.cinematic")

EtherealGate.kVortexLoopingSound = PrecacheAsset("sound/NS2.fev/alien/fade/vortex_loop")
EtherealGate.kVortexEndCinematic = PrecacheAsset("cinematics/alien/fade/vortex_destroy.cinematic")

EtherealGate.kType = CommanderAbility.kType.Repeat
EtherealGate.kSearchRange = 5
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
       if entity:GetCanBeVortexed() and not entity:GetIsVortexed() then
        entity:SetVortexDuration(6)   
       end 
    end

end

function EtherealGate:GetStartCinematic()
    return EtherealGate.kVortexLoopingCinematic
end
function EtherealGate:GetEndCinematic()
    return EtherealGate.kVortexEndCinematic
end
function EtherealGate:GetType()
    return EtherealGate.kType
end

function EtherealGate:GetUpdateTime()
    return 1.5
end

function EtherealGate:GetLifeSpan()
    return 12 ///  6 is too short - It Basically dissapears a few seconds after finding a target!
end

Shared.LinkClassToMap("EtherealGate", EtherealGate.kMapName, netWorkVars)
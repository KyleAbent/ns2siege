--[[
    lua/EvolutionChamber.lua
    
    Handles the life-form researches for the Hive.
]]
class 'EvolutionChamber' (ScriptActor)

EvolutionChamber.kMapName = "evolutionchamber"

local networkVars = { }

AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)

function EvolutionChamber:OnCreate()
    ScriptActor.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, ResearchMixin)

end

function EvolutionChamber:SetIncludeRelevancyMask(includeMask)

    includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)
    ScriptActor.SetIncludeRelevancyMask(self, includeMask)

end

function EvolutionChamber:GetTechButtons(techId)

    local techButtons = { kTechId.None, kTechId.None, kTechId.None, kTechId.None,
                                kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    
	
    if self:GetIsResearching() then
        techButtons[7] = kTechId.Cancel
    else
        techButtons[7] = kTechId.None
    end
    
    return techButtons
    
end

Shared.LinkClassToMap("EvolutionChamber", EvolutionChamber.kMapName, networkVars)

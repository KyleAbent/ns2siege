
Script.Load("lua/bots/PlayerBrain.lua")
Script.Load("lua/bots/GorgeBrain_Data.lua")

//----------------------------------------
//  
//----------------------------------------
class 'GorgeBrain' (PlayerBrain)

function GorgeBrain:Initialize()

    PlayerBrain.Initialize(self)
    self.senses = CreateSkulkBrainSenses()

end

function GorgeBrain:GetExpectedPlayerClass()
    return "Gorge"
end

function GorgeBrain:GetExpectedTeamNumber()
    return kAlienTeamType
end

function GorgeBrain:GetActions()
    return kSkulkBrainActions
end

function GorgeBrain:GetSenses()
    return self.senses
end
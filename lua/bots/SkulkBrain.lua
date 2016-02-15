
Script.Load("lua/bots/PlayerBrain.lua")
Script.Load("lua/bots/SkulkBrain_Data.lua")

//----------------------------------------
//  
//----------------------------------------
class 'SkulkBrain' (PlayerBrain)

function SkulkBrain:Initialize()

    PlayerBrain.Initialize(self)
    self.senses = CreateSkulkBrainSenses()

end

function SkulkBrain:GetExpectedPlayerClass()
    return "Skulk"
end

function SkulkBrain:GetExpectedTeamNumber()
    return kAlienTeamType
end

function SkulkBrain:GetActions()
    return kSkulkBrainActions
end

function SkulkBrain:GetSenses()
    return self.senses
end

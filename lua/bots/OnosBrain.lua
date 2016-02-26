
Script.Load("lua/bots/PlayerBrain.lua")
Script.Load("lua/bots/OnosBrain_Data.lua")

//----------------------------------------
//  
//----------------------------------------
class 'OnosBrain' (PlayerBrain)

function OnosBrain:Initialize()

    PlayerBrain.Initialize(self)
    self.senses = CreateSkulkBrainSenses()

end

function OnosBrain:GetExpectedPlayerClass()
    return "Onos"
end

function OnosBrain:GetExpectedTeamNumber()
    return kAlienTeamType
end

function OnosBrain:GetActions()
    return kOnosBrainActions
end

function OnosBrain:GetSenses()
    return self.senses
end

//----------------------------------------
//  
//----------------------------------------

Script.Load("lua/bots/CommanderBrain.lua")
Script.Load("lua/bots/AlienCommanderBrain_Data.lua")
Script.Load("lua/bots/BotDebug.lua")

gBotDebug:AddBoolean("kham")

gAlienCommanderBrains = {}

//----------------------------------------
//  
//----------------------------------------
class 'AlienCommanderBrain' (CommanderBrain)

function AlienCommanderBrain:Initialize()

    CommanderBrain.Initialize(self)
    self.senses = CreateAlienComSenses()
    table.insert( gAlienCommanderBrains, self )

end

function AlienCommanderBrain:GetExpectedPlayerClass()
    return "AlienCommander"
end

function AlienCommanderBrain:GetExpectedTeamNumber()
    return kAlienTeamType
end

function AlienCommanderBrain:GetActions()
    return kAlienComBrainActions
end

function AlienCommanderBrain:GetSenses()
    return self.senses
end

function AlienCommanderBrain:Update(bot, move)

    CommanderBrain.Update(self, bot, move)

    //----------------------------------------
    //  Do per-frame debugging here
    //----------------------------------------

    if gBotDebug:Get("kham") then

        local sdb = self:GetSenses()
        local rp = sdb:Get("resPointToInfest")
        local ofs = Vector(0,1,0)

        if rp ~= nil and sdb:Get("lastInfestorPos") ~= nil then
            DebugLine( rp:GetOrigin()+ofs, sdb:Get("lastInfestorPos")+ofs, 0.0,
                0,0,1,1,  true )
            if sdb:Get("bestCystPos") ~= nil then
                DebugLine( sdb:Get("bestCystPos")+ofs, sdb:Get("lastInfestorPos")+ofs, 0.0,
                   0,1,1,1,  true )
            end
        end

    end


end

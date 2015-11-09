// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//    
// lua\VotingForceEvenTeams.lua
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kExecuteVoteDelay = 2

RegisterVoteType("VotingForceEvenTeams", { })

if Client then

    local function SetupForceEvenTeamsVote(voteMenu)
    
        local function StartForceEvenTeamsVote(data)
            AttemptToStartVote("VotingForceEvenTeams", { })
        end
        
        voteMenu:AddMainMenuOption("Vote Score Based Teams", nil, StartForceEvenTeamsVote)
        
        -- This function translates the networked data into a question to display to the player for voting.
        local function GetVoteForceEvenTeamsQuery(data)
            return "Force Score Based Teams?"
        end
        AddVoteStartListener("VotingForceEvenTeams", GetVoteForceEvenTeamsQuery)
        
    end
    AddVoteSetupCallback(SetupForceEvenTeamsVote)
    
end

if Server then

    local function OnForceEvenTeamsVoteSuccessful(data)
      //  ForceEvenTeams()
           Shared.ConsoleCommand("sh_enablerandom true" ) 
    end
    
    SetVoteSuccessfulCallback("VotingForceEvenTeams", kExecuteVoteDelay, OnForceEvenTeamsVoteSuccessful)
    
end
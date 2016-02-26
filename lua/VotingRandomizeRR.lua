// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//    
// lua\VotingRandomizeRR.lua
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kExecuteVoteDelay = 2

RegisterVoteType("VoteRandomizeRR", { })

if Client then

    local function SetupRandomizeRRVote(voteMenu)
    
        local function StartRandomizeRRVote(data)
            AttemptToStartVote("VoteRandomizeRR", { })
        end
        
        voteMenu:AddMainMenuOption(Locale.ResolveString("VOTE_RANDOMIZE_RR"), nil, StartRandomizeRRVote)
        
        -- This function translates the networked data into a question to display to the player for voting.
        local function GetVoteRandomizeRRQuery(data)
            return Locale.ResolveString("VOTE_RANDOMIZE_RR_QUERY")
        end
        AddVoteStartListener("VoteRandomizeRR", GetVoteRandomizeRRQuery)
        
    end
    AddVoteSetupCallback(SetupRandomizeRRVote)
    
end

if Server then

    local function OnRandomizeRRVoteSuccessful(data)
    
        local rrPlayers = GetGamerules():GetTeam(kTeamReadyRoom):GetPlayers()
        for p = #rrPlayers, 1, -1 do
            JoinRandomTeam(rrPlayers[p])
        end
        
    end
    SetVoteSuccessfulCallback("VoteRandomizeRR", kExecuteVoteDelay, OnRandomizeRRVoteSuccessful)
    
end
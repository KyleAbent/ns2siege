// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//    
// lua\VotingKickPlayer.lua
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kExecuteVoteDelay = 3

RegisterVoteType("VoteKickPlayer", { kick_client = "integer" })

if Client then

    local function SetupKickPlayerVote(voteMenu)
    
        local function GetPlayerList()
        
            local playerList = Scoreboard_GetPlayerList()
            local menuItems = { }
            for p = 1, #playerList do
            
                local name = Scoreboard_GetPlayerData(Client.GetLocalClientIndex(), "Name")
                -- Don't add the local player to the list of players to vote kick.
                if playerList[p].name ~= name then
                    table.insert(menuItems, { text = playerList[p].name, extraData = { kick_client = playerList[p].client_index } })
                end
                
            end
            return menuItems
            
        end
        
        local function StartKickPlayerVote(data)
            AttemptToStartVote("VoteKickPlayer", { kick_client = data.kick_client })
        end
        
        voteMenu:AddMainMenuOption(Locale.ResolveString("VOTE_KICK_PLAYER"), GetPlayerList, StartKickPlayerVote)
        
        -- This function translates the networked data into a question to display to the player for voting.
        local function GetVoteKickPlayerQuery(data)
            return StringReformat(Locale.ResolveString("VOTE_KICK_PLAYER_QUERY"), { name = Scoreboard_GetPlayerName(data.kick_client) })
        end
        AddVoteStartListener("VoteKickPlayer", GetVoteKickPlayerQuery)
        
    end
    AddVoteSetupCallback(SetupKickPlayerVote)
    
end

if Server then

    local function OnKickPlayerVoteSuccessful(data)
    
        local client = Server.GetClientById(data.kick_client)
        -- client may be nil in some cases such as when this client disconnects before the vote is complete.
        if client then
            local votingsettings = Server.GetConfigSetting("voting")
            local bantime = votingsettings and tonumber(votingsettings.votekickbantime)
            if bantime and bantime > 0 then
                Shared.ConsoleCommand(string.format("sv_ban %s %s banned by VoteKick", client:GetUserId(), bantime))
            else
                Server.DisconnectClient(client)
            end
        end
        
    end
    SetVoteSuccessfulCallback("VoteKickPlayer", kExecuteVoteDelay, OnKickPlayerVoteSuccessful)
    
end
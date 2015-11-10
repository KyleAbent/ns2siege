local kExecuteVoteDelay = 3

RegisterVoteType("VoteGagPlayer", { gag_client = "integer" })

if Client then

    local function SetupGagPlayerVote(voteMenu)
    
        local function GetPlayerList()
        
            local playerList = Scoreboard_GetPlayerList()
            local menuItems = { }
            for p = 1, #playerList do
            
                local name = Scoreboard_GetPlayerData(Client.GetLocalClientIndex(), "Name")
                -- Don't add the local player to the list of players to vote gag.
                if playerList[p].name ~= name then
                    table.insert(menuItems, { text = playerList[p].name, extraData = { gag_client = playerList[p].client_index } })
                end
                
            end
            return menuItems
            
        end
        
        local function StartGagPlayerVote(data)
            AttemptToStartVote("VoteGagPlayer", { gag_client = data.gag_client })
        end
        
        voteMenu:AddMainMenuOption(Locale.ResolveString("Vote Gag Player"), GetPlayerList, StartGagPlayerVote)
        
        -- This function translates the networked data into a question to display to the player for voting.
        local function GetVoteGagPlayerQuery(data)
            return StringReformat(Locale.ResolveString("Gag/mute %{name}s for 5 minutes?"), { name = Scoreboard_GetPlayerName(data.gag_client) })
        end
        AddVoteStartListener("VoteGagPlayer", GetVoteGagPlayerQuery)
        
    end
    AddVoteSetupCallback(SetupGagPlayerVote)
    
end

if Server then

    local function OnGagPlayerVoteSuccessful(data)
    
        local client = Server.GetClientById(data.gag_client)
        if client then
     Shared.ConsoleCommand(string.format("sh_gag %s 300", client:GetUserId()))
      end
    end
    SetVoteSuccessfulCallback("VoteGagPlayer", kExecuteVoteDelay, OnGagPlayerVoteSuccessful)
    
end
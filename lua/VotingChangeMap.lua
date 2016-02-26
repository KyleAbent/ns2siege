// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//    
// lua\VotingChangeMap.lua
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

-- How many seconds to wait after the vote is complete before executing.
local kExecuteVoteDelay = 10

local kMaxMapNameLength = 32
Shared.RegisterNetworkMessage("AddVoteMap", { name = "string (" .. kMaxMapNameLength .. ")", index = "integer (0 to 255)" })

RegisterVoteType("VoteChangeMap", { map_index = "integer" })

if Client then

    local serverMapList = { }
    local serverMapIndices = { }
    local function OnAddVoteMap(message)
    
        table.insert(serverMapList, { text = message.name, extraData = { map_index = message.index } })
        serverMapIndices[message.index] = message.name
        
    end
    Client.HookNetworkMessage("AddVoteMap", OnAddVoteMap)
    
    local function SetupChangeMapVote(voteMenu)
    
        local function StartChangeMapVote(data)
            AttemptToStartVote("VoteChangeMap", { map_index = data.map_index })
        end
        voteMenu:AddMainMenuOption(Locale.ResolveString("VOTE_CHANGE_MAP"), function() return serverMapList end, StartChangeMapVote)
        
        -- This function translates the networked data into a question to display to the player for voting.
        local function GetVoteChangeMapQuery(data)
            return StringReformat(Locale.ResolveString("VOTE_CHANGE_MAP_QUERY"), { name = serverMapIndices[data.map_index] })
        end
        AddVoteStartListener("VoteChangeMap", GetVoteChangeMapQuery)
        
    end
    AddVoteSetupCallback(SetupChangeMapVote)
    
end

if Server then

    -- Send new Clients the map list.
    local function OnClientConnect(client)
    
        for i = 1, Server.GetNumMaps() do
        
            local mapName = Server.GetMapName(i)
            if MapCycle_GetMapIsInCycle(mapName) then
                Server.SendNetworkMessage(client, "AddVoteMap", { name = mapName, index = i }, true)
            end
            
        end
        
    end
    Event.Hook("ClientConnect", OnClientConnect)
    
    local function OnChangeMapVoteSuccessful(data)
        MapCycle_ChangeMap(Server.GetMapName(data.map_index))
    end
    SetVoteSuccessfulCallback("VoteChangeMap", kExecuteVoteDelay, OnChangeMapVoteSuccessful)
    
end
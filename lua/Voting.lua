// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//    
// lua\Voting.lua
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kVoteExpireTime = 20
local kDefaultVoteExecuteTime = 30
local kNextVoteAllowedAfterTime = 50
-- How many seconds must pass before a client can start another vote of a certain type after a failed vote.
local kStartVoteAfterFailureLimit = 3 * 60

Shared.RegisterNetworkMessage("SendVote", { voteId = "integer", choice = "boolean" })
kVoteState = enum( { 'InProgress', 'Passed', 'Failed' } )
Shared.RegisterNetworkMessage("VoteResults", { voteId = "integer", yesVotes = "integer (0 to 255)", noVotes = "integer (0 to 255)", requiredVotes = "integer (0 to 255)", state = "enum kVoteState" })
Shared.RegisterNetworkMessage("VoteComplete", { voteId = "integer" })
kVoteCannotStartReason = enum( { 'VoteAllowedToStart', 'VoteInProgress', 'Waiting', 'Spam', 'DisabledByAdmin', 'GameInProgress', 'TooLate' } )
Shared.RegisterNetworkMessage("VoteCannotStart", { reason = "enum kVoteCannotStartReason" })

local kVoteCannotStartReasonStrings = { }
kVoteCannotStartReasonStrings[kVoteCannotStartReason.VoteInProgress] = "VOTE_IN_PROGRESS"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.Waiting] = "VOTE_WAITING"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.Spam] = "VOTE_SPAM"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.GameInProgress] = "VOTE_GAME_IN_PROGRESS"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.DisabledByAdmin] = "VOTE_DISABLED_BY_ADMIN"
kVoteCannotStartReasonStrings[kVoteCannotStartReason.TooLate] = "VOTE_TOO_LATE"

if Server then

    function VotingResetGameAllowed()
        local gameRules = GetGamerules()
        return not gameRules:GetGameStarted() or Shared.GetTime() - gameRules:GetGameStartTime() < kMaxTimeBeforeReset
    end
    
    local activeVoteName = nil
    local activeVoteData = nil
    local activeVoteResults = nil
    local activeVoteStartedAtTime = nil
    local activeVoteId = 0
    local lastVoteStartAtTime = nil
    local lastTimeVoteResultsSent = 0
    local voteSuccessfulCallbacks = { }
    
    local startVoteHistory = { }
    
    local function GetStartVoteAllowed(voteName, client)

        -- Check that there is no current vote.
        if activeVoteName then    
            return kVoteCannotStartReason.VoteInProgress
        end
        
        -- Check that enough time has passed since the last vote.
        if lastVoteStartAtTime and Shared.GetTime() - lastVoteStartAtTime < kNextVoteAllowedAfterTime then
            return kVoteCannotStartReason.Waiting
        end
        
        -- Check that this client hasn't started a failed vote of this type recently.
        for v = #startVoteHistory, 1, -1 do
        
            local vote = startVoteHistory[v]
            if voteName == vote.type and client:GetUserId() == vote.client_id then
            
                if not vote.succeeded and Shared.GetTime() - vote.start_time < kStartVoteAfterFailureLimit then
                    return kVoteCannotStartReason.Spam
                end
                
            end
            
        end
        
        local votingSettings = Server.GetConfigSetting("voting")
        if votingSettings and votingSettings[string.lower(voteName)] == false then
            return kVoteCannotStartReason.DisabledByAdmin
        end
        
        if voteName == "VoteResetGame" then
            if not VotingResetGameAllowed() then
                return kVoteCannotStartReason.TooLate
            end
        end
        
        if voteName == "VotingForceEvenTeams" then
            if GetGamerules():GetGameStarted() == true then
                return kVoteCannotStartReason.GameInProgress
            end
        end
        
        return kVoteCannotStartReason.VoteAllowedToStart
        
    end
    
    local function StartVote(voteName, client, data)
        
        local voteCanStart = GetStartVoteAllowed(voteName, client)
        if voteCanStart == kVoteCannotStartReason.VoteAllowedToStart then
        
            activeVoteId = activeVoteId + 1
            activeVoteName = voteName
            activeVoteResults = { }
            activeVoteStartedAtTime = Shared.GetTime()
            lastVoteStartAtTime = activeVoteStartedAtTime
            data.voteId = activeVoteId
            local now = Shared.GetTime()
            data.expireTime = now + kVoteExpireTime
            data.client_index = client:GetId()
            Server.SendNetworkMessage(voteName, data)
            
            activeVoteData = data
            
            table.insert(startVoteHistory, { type = voteName, client_id = client:GetUserId(), start_time = now, succeeded = false })
            
            Print("Started Vote: " .. voteName)
            
        else
            Server.SendNetworkMessage(client, "VoteCannotStart", { reason = voteCanStart }, true)
        end
        
    end
    
    function HookStartVote(voteName)
    
        local function OnStartVoteReceived(client, message)
            StartVote(voteName, client, message)
        end
        Server.HookNetworkMessage(voteName, OnStartVoteReceived)
        
    end
    
    function RegisterVoteType(voteName, voteData)
    
        assert(voteData.voteId == nil, "voteId field detected while registering a vote type")
        voteData.voteId = "integer"
        assert(voteData.expireTime == nil, "expireTime field detected while registering a vote type")
        voteData.expireTime = "time"
        assert(voteData.client_index == nil, "client_index field detected while registering a vote type")
        voteData.client_index = "integer"
        Shared.RegisterNetworkMessage(voteName, voteData)
        HookStartVote(voteName)
        
    end
    
    function SetVoteSuccessfulCallback(voteName, delayTime, callback)
    
        local voteSuccessfulCallback = { }
        voteSuccessfulCallback.delayTime = delayTime
        voteSuccessfulCallback.callback = callback
        voteSuccessfulCallbacks[voteName] = voteSuccessfulCallback
        
    end
    
    local function CountVotes(voteResults)
    
        local yes = 0
        local no = 0
        for _, choice in pairs(voteResults) do
        
            yes = (choice and yes + 1) or yes
            no = (not choice and no + 1) or no
            
        end
        
        return yes, no
        
    end
    
    local lastVoteSent = 0
    
    local function OnSendVote(client, message)
    
        if activeVoteName then
        
            local votingDone = Shared.GetTime() - activeVoteStartedAtTime >= kVoteExpireTime
            if not votingDone and message.voteId == activeVoteId then
                activeVoteResults[client:GetUserId()] = message.choice
                lastVoteSent = Shared.GetTime()
            end
            
        end
        
    end
    Server.HookNetworkMessage("SendVote", OnSendVote)
    
    local function GetNumVotingPlayers()
        return Server.GetNumPlayers() - #gServerBots
    end
        
    local function GetVotePassed(yesVotes, noVotes)
        return yesVotes > (GetNumVotingPlayers() / 2)
    end
    
    local function OnUpdateVoting(dt)
    
        if activeVoteName then
        
            local yes, no = CountVotes(activeVoteResults)
            local required = math.floor(GetNumVotingPlayers() / 2) + 1
            local voteSuccessful = GetVotePassed(yes, no)
            local voteFailed = no >= math.floor(GetNumVotingPlayers() / 2) + 1
        
            if Shared.GetTime() - lastTimeVoteResultsSent > 1 then
            
                local voteState = kVoteState.InProgress
                
                local votingDone = Shared.GetTime() - activeVoteStartedAtTime >= kVoteExpireTime or voteSuccessful or voteFailed
                if votingDone then
                    voteState = voteSuccessful and kVoteState.Passed or kVoteState.Failed
                end
                
                Server.SendNetworkMessage("VoteResults", { voteId = activeVoteId, yesVotes = yes, noVotes = no, state = voteState, requiredVotes = required }, true)
                lastTimeVoteResultsSent = Shared.GetTime()
                
            end
            
            local voteSuccessfulCallback = voteSuccessfulCallbacks[activeVoteName]
            local delay = (voteSuccessfulCallback and (kVoteExpireTime + voteSuccessfulCallback.delayTime)) or kDefaultVoteExecuteTime
            
            if voteSuccessful then
                delay = lastVoteSent - activeVoteStartedAtTime + voteSuccessfulCallback.delayTime
            end
            if Shared.GetTime() - activeVoteStartedAtTime >= delay then
            
                Server.SendNetworkMessage("VoteComplete", { voteId = activeVoteId }, true)
                
                local yes, no = CountVotes(activeVoteResults)
                local voteSuccessful = GetVotePassed(yes, no)
                startVoteHistory[#startVoteHistory].succeeded = voteSuccessful
                Print("Vote Complete: " .. activeVoteName .. ". Successful? " .. (voteSuccessful and "Yes" or "No"))
                
                if voteSuccessfulCallback and voteSuccessful then
                    voteSuccessfulCallback.callback(activeVoteData)
                end
                
                activeVoteName = nil
                activeVoteData = nil
                activeVoteResults = nil
                activeVoteStartedAtTime = nil
                
            end
            
        end
        
    end
    Event.Hook("UpdateServer", OnUpdateVoting)
    
end

if Client then

    local currentVoteQuery = nil
    local currentVoteId = 0
    local currentVoteExpireTime = 0
    local yesVotes = 0
    local noVotes = 0
    local requiredVotes = 0
    local lastVoteResults = nil
    
    function RegisterVoteType(voteName, voteData)
    
        assert(voteData.voteId == nil, "voteId field detected while registering a vote type")
        voteData.voteId = "integer"
        assert(voteData.expireTime == nil, "expireTime field detected while registering a vote type")
        voteData.expireTime = "time"
        assert(voteData.client_index == nil, "client_index field detected while registering a vote type")
        voteData.client_index = "integer"
        Shared.RegisterNetworkMessage(voteName, voteData)
        
    end
    
    local voteSetupCallbacks = { }
    function AddVoteSetupCallback(callback)
        table.insert(voteSetupCallbacks, callback)
    end
    
    function AttemptToStartVote(voteName, data)
        Client.SendNetworkMessage(voteName, data, true)
    end
    
    function SendVoteChoice(votedYes)
    
        if currentVoteId > 0 then
        
            -- Predict the vote locally for the UI.
            if votedYes then
                yesVotes = yesVotes + 1
            else
                noVotes = noVotes + 1
            end
            
            Client.SendNetworkMessage("SendVote", { voteId = currentVoteId, choice = votedYes }, true)
            
        end
        
    end
    
    function GetCurrentVoteId()
        return currentVoteId
    end
    
    function GetCurrentVoteQuery()
        return currentVoteQuery
    end
    
    function GetCurrentVoteTimeLeft()
        return math.max(0, currentVoteExpireTime - Shared.GetTime())
    end
    
    function GetLastVoteResults()
        return lastVoteResults
    end
    
    function AddVoteStartListener(voteName, queryTextGenerator)
    
        local function OnVoteStarted(data)
        
            currentVoteId = data.voteId
            currentVoteExpireTime = data.expireTime
            yesVotes = 0
            noVotes = 0
            requiredVotes = 0
            currentVoteQuery = queryTextGenerator(data)
            lastVoteResults = nil
            local message = StringReformat(Locale.ResolveString("VOTE_PLAYER_STARTED_VOTE"), { name = Scoreboard_GetPlayerName(data.client_index) })
            ChatUI_AddSystemMessage(message)
            
        end
        Client.HookNetworkMessage(voteName, OnVoteStarted)
        
    end
    
    local function OnVoteResults(message)
    
        if currentVoteId == message.voteId then
        
            -- Use the higher value as we predict the vote for the local player.
            yesVotes = math.max(yesVotes, message.yesVotes)
            noVotes = math.max(noVotes, message.noVotes)
            requiredVotes = math.max(requiredVotes, message.requiredVotes)
            
            if message.state == kVoteState.Passed then
                lastVoteResults = true
            elseif message.state == kVoteState.Failed then
                lastVoteResults = false
            end
            
        end
        
    end
    Client.HookNetworkMessage("VoteResults", OnVoteResults)
    
    function GetVoteResults()
        return yesVotes, noVotes, requiredVotes
    end
    
    local function OnVoteComplete(message)
    
        if message.voteId == currentVoteId then
        
            currentVoteQuery = nil
            currentVoteId = 0
            currentVoteExpireTime = 0
            yesVotes = 0
            noVotes = 0
            requiredVotes = 0
            lastVoteResults = nil
            
        end
        
    end
    Client.HookNetworkMessage("VoteComplete", OnVoteComplete)
    
    local function OnVoteCannotStart(message)
    
        local reasonStr = kVoteCannotStartReasonStrings[message.reason]
        ChatUI_AddSystemMessage(Locale.ResolveString(reasonStr))
        
    end
    Client.HookNetworkMessage("VoteCannotStart", OnVoteCannotStart)
    
    -- Must be called after GUIStartVoteMenu is created.
    function OnGUIStartVoteMenuCreated(name, script)
    
        if name ~= "GUIStartVoteMenu" then
            return
        end
        
        -- Setup all the vote types.
        for s = 1, #voteSetupCallbacks do
            voteSetupCallbacks[s](script)
        end
        
    end
    ClientUI.AddScriptCreationEventListener(OnGUIStartVoteMenuCreated)
    
end
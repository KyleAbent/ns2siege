// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//
// lua\TournamentMode.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// Process chat commands when tournament mode is enabled.
//
// ========= For more information, visit us at http://www.unknownworlds.com =======================

local gTournamentModeEnabled = false
local gReadyTeams = {}

function EnableTournamentMode(client)

    if not gTournamentModeEnabled then
        GetGamerules():OnTournamentModeEnabled()
        ServerAdminPrint(client, "Tournament mode enabled.")
        Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Admin", -1, kTeamReadyRoom, kNeutralTeamType, "Tournament mode enabled."), true)
    end

    gTournamentModeEnabled = true
    
end

function DisableTournamentMode(client)

    if gTournamentModeEnabled then
        GetGamerules():OnTournamentModeDisabled()
        ServerAdminPrint(client, "Tournament mode disabled.")
        Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Admin", -1, kTeamReadyRoom, kNeutralTeamType, "Tournament mode disabled."), true)
    end

    gTournamentModeEnabled = false
    
end

function GetTournamentModeEnabled()
    return gTournamentModeEnabled
end

function TournamentModeOnGameEnd()
    gReadyTeams = {}
end

function TournamentModeOnReset()
    gReadyTeams = {}
end

local function CheckReadyness()

    if gReadyTeams[kTeam1Index] and gReadyTeams[kTeam2Index] then
        GetGamerules():SetTeamsReady(true)
        Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Admin", -1, kTeamReadyRoom, kNeutralTeamType, "Both teams ready."), true)
    else
        GetGamerules():SetTeamsReady(false)
    end

end

local function SetTeamReady(player)

    local teamNumber = player:GetTeamNumber()
    gReadyTeams[teamNumber] = true
    CheckReadyness()
    
end

local function SetTeamNotReady(player)

    local teamNumber = player:GetTeamNumber()
    gReadyTeams[teamNumber] = false
    CheckReadyness()
    
end

local function SetTeamPauseDesired(player)
    //GetGamerules():SetPaused()    
end

local function SetTeamPauseNotDesired()
     //GetGamerules():DisablePause()
end

local kSayCommands =
{
    ["ready"] = SetTeamReady,
    ["rdy"] = SetTeamReady,
    ["unready"] = SetTeamNotReady,
    ["unrdy"] = SetTeamNotReady,
    ["pause"] = SetTeamPauseDesired,
    ["unpause"] = SetTeamPauseNotDesired
}

function ProcessSayCommand(player, command)

    if gTournamentModeEnabled then

        for validCommand, func in pairs(kSayCommands) do
        
            if validCommand == string.lower(command) then
                func(player)
            end
        
        end
    
    end

end
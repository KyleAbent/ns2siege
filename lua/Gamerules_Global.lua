// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Gamerules_Global.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Global gamerules accessors. When gamerules are initialized by map they should call SetGamerules(). 
globalGamerules = globalGamerules or nil

function GetHasGameRules()
    return globalGamerules ~= nil
end

function SetGamerules(gamerules)

    if gamerules ~= globalGamerules then
        globalGamerules = gamerules
    end
    
end

function GetGamerules()

    if Server then
        return globalGamerules
    end
    
    return nil
    
end

local function OnClientConnect(client)
    GetGamerules():OnClientConnect(client)
end

local function OnClientDisconnect(client)    
    GetGamerules():OnClientDisconnect(client)    
end

// Game methods
Event.Hook("ClientConnect", OnClientConnect)
Event.Hook("ClientDisconnect", OnClientDisconnect)
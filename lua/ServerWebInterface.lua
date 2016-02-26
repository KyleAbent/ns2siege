// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\ServerWebAPI.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/RingBuffer.lua")

local kMaxPerfDatas = 30

// How often to log performance data in seconds.
local kLogPerfDataRate = 60

// The last kMaxPerfDatas performance samples (one is taken every kLogPerfDataRate seconds).
local perfDataBuffer = CreateRingBuffer(kMaxPerfDatas)

// The last time performance data was sampled.
local lastPerfDataTime = 0

// Stores cached workshop mod results for 60 seconds.
local getmodsCache = { }

Shared.SetWebRoot("web")

/**
 * Returns a list of all of the mods installed on the server (not necessarily active)
 */
local function GetModList()

    local returnList = { }
    
    for i = 1, Server.GetNumMods() do
        local id   = Server.GetModId(i)
        local name = Server.GetModTitle(i)
        returnList[i] = { id = id, name = name }
    end
    
    return returnList
    
end

local function GetMapList()

    local returnList = { }
    
    for i = 1, Server.GetNumMaps() do
        local name  = Server.GetMapName(i)
        local modId = Server.GetMapModId(i)
        returnList[i] = { name = name, modId = modId }
    end
    
    return returnList
    
end

local function GetTeamResourceCount()

    local marineRes = 0
    local alienRes = 0
    
    local teamInfo = GetEntitiesForTeam("TeamInfo", 1)
    if table.count(teamInfo) > 0 then
        marineRes = teamInfo[1]:GetTeamResources()
    end
    
    teamInfo = GetEntitiesForTeam("TeamInfo", 2)
    if table.count(teamInfo) > 0 then
        alienRes = teamInfo[1]:GetTeamResources()
    end
    
    return marineRes, alienRes
    
end

-- Returns a Lua table containing the state of the server.
local function GetServerState()

    local playerRecords = Shared.GetEntitiesWithClassname("Player")
    
    local playerList = { }
    for _, player in ientitylist(playerRecords) do
    
        local client = Server.GetOwner(player)
        // The ServerClient may be nil if this player was just removed from the server
        // right before this function was called.
        if client then
        
            local playerData =
            {
                name = player:GetName(),
                steamid = client:GetUserId(),
                isbot = tostring(client:GetIsVirtual()),
                team = player:GetTeamNumber(),
                iscomm = player:GetIsCommander(),
                score = HasMixin(player, "Scoring") and player:GetScore() or 0,
                kills = HasMixin(player, "Scoring") and player:GetKills() or 0,
                assists = HasMixin(player, "Scoring") and player:GetAssistKills() or 0,
                deaths = HasMixin(player, "Scoring") and player:GetDeaths() or 0,
                resources = player:GetResources(),
                ping = client:GetPing(),
                ipaddress = IPAddressToString(Server.GetClientAddress(client))
            }
            table.insert(playerList, playerData)
            
        end
        
    end
    
    local marineRes, alienRes = GetTeamResourceCount()
    
    return
    {
        webdomain = "[[webdomain]]",
        webport = "[[webport]]",
        cheats  = tostring(Shared.GetCheatsEnabled()),
        devmode = tostring(Shared.GetDevMode()),
        map = tostring(Shared.GetMapName()),
        players_online = playerRecords:GetSize(),
        marines = GetGamerules():GetTeam1():GetNumPlayers(),
        aliens = GetGamerules():GetTeam2():GetNumPlayers(),
        uptime = math.floor(Shared.GetTime()),
        player_list = playerList,
        marine_res = marineRes,
        alien_res = alienRes,
        server_name = Server.GetName(),
        frame_rate = Server.GetFrameRate()
    }
    
end

local function DecToHex(id)
    return string.format("%x", tonumber(id))
end

local function OnWebRequest(actions)

    if actions.request == "getbanlist" then
        return "application/json", json.encode(GetBannedPlayersList())
    elseif actions.request == "getreservedslots" then
        return "application/json", json.encode(GetReservedSlotData())
    elseif actions.request == "getperfdata" then
        return "application/json", json.encode(perfDataBuffer:ToTable())
    elseif actions.request == "getchatlist" then
        return "application/json", Server.recentChatMessages and json.encode(Server.recentChatMessages:ToTable()) or "{ }"
    elseif actions.request == "getinstalledmodslist" then
        return "application/json", json.encode(GetModList())
    elseif actions.request == "getmaplist" then
        return "application/json", json.encode(GetMapList())
    elseif actions.request == "getmapcycle" then
        return "application/json", json.encode(MapCycle_GetMapCycle())
    elseif actions.request == "setmapcycle" then
    
        MapCycle_SetMapCycle(json.decode(actions.data))
        return ""
        
    elseif actions.request == "setreservedslotamount" then
    
        SetReservedSlotAmount(actions.amount)
        return ""
        
    elseif actions.request == "installmod" then
    
        Server.InstallMod(DecToHex(actions.modid))
        return ""
        
    elseif actions.request == "getmods" then
    
        local url = "http://www.unknownworlds.com/spark/browse_workshop.php?appid=4920"
        local searchtext = actions.searchtext
        if type(searchtext) == "string" then
            url = url .. "&searchtext=" .. url_encode(searchtext)
        end
        local page = tostring(actions.p)
        if type(page) == "string" then
            url = url .. "&p=" .. page
        end
        
        local timeRequested = Shared.GetTime()
        
        if getmodsCache[url] then
            local startedLoading = getmodsCache[url].startedLoading
            if startedLoading then
                // Request times out after 30 seconds
                if timeRequested - startedLoading < 30 then
                    return "application/json", '{"loading": true}'
                end
            else
                // Cache workshop mods for 60 seconds
                if timeRequested - getmodsCache[url].cached_at < 60 then
                    return "application/json", getmodsCache[url].result
                else
                    getmodsCache[url] = nil
                end
            end
        end
 
        getmodsCache[url] = { startedLoading = timeRequested }
        
        Shared.SendHTTPRequest(url, "GET", function(result)
            getmodsCache[url] = { cached_at = Shared.GetTime(), result = result }
        end)
 
        return "application/json", '{"loading": true}'
        
    end
    
    if actions.command then
        Shared.ConsoleCommand(actions.rcon)
    end
    
    return "application/json", json.encode(GetServerState())
    
end
Event.Hook("WebRequest", OnWebRequest)

/**
 * This function should be called once per tick.
 */
local function UpdateServerWebInterface()

    if Shared.GetSystemTime() - lastPerfDataTime >= kLogPerfDataRate then
    
        local playerRecords = Shared.GetEntitiesWithClassname("Player")
        local entCount = Shared.GetEntitiesWithClassname("Entity"):GetSize()
        local newData = { players = playerRecords:GetSize(), tickrate = Server.GetFrameRate(), time = Shared.GetSystemTime(), ent_count = entCount }
        perfDataBuffer:Insert(newData)
        
        lastPerfDataTime = Shared.GetSystemTime()
        
    end
    
end

Event.Hook("UpdateServer", UpdateServerWebInterface)
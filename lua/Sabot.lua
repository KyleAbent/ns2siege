// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\SabotUtility.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/dkjson.lua")
Script.Load("lua/Globals.lua")

local kSabotURL = "http://hive.naturalselection2.com/api/"

local gServerSettings = { password = "", mapName = "" }
local gGathers = {}

kGatherStatus = enum({'Waiting', 'SearchingServer', 'PeparingServer', 'Connecting'})

// for current gather
local gGatherId = -1
local gChatMessages = {}
local gPlayerNames = {}
local gServerAddress = nil
local gServerPassword = nil
local gGatherStatus = 1
local gConnectionError = false
local gGatherPassword = nil

local kStatusMessages = {}
kStatusMessages[kGatherStatus.Waiting] = "Waiting for players..."
kStatusMessages[kGatherStatus.SearchingServer] = "Searching for server..."
kStatusMessages[kGatherStatus.PeparingServer] = "Preparing server..."
kStatusMessages[kGatherStatus.Connecting] = "Connecting to server..."

Sabot = {}

local function SetCurrentGatherId(gatherId)

    Client.SetOptionInteger("sabot/activeGatherId", gatherId)
    gGatherId = gatherId

end

local function GetPlayerName()
    return Client.GetOptionString(kNicknameOptionsKey, Client.GetUserName()) or kDefaultPlayerName
end

local function StoreGatherId(data)

    local obj, pos, err = json.decode(data, 1, nil)
    //DebugPrint("response StoreGatherId data %s", ToString(obj))
    
    if obj then
        SetCurrentGatherId(obj.gatherId or -1)
    end
    
    // need to refresh here otherwise the gather info is incomplete ingame
    if gGatherId ~= -1 then
    
        Sabot.RefreshGatherList()
        
        if gConnectionError then
            Sabot.QuitGather()    
        end
        
    end
    
end

local function JoinGatherOnSuccess(gatherInfo)

    return function (data)
    
        gGatherStatus = 1
    
        local obj, pos, err = json.decode(data, 1, nil)
        obj.data.gatherPassword = gatherInfo.gatherPassword
        //DebugPrint("response JoinGatherOnSuccess data %s", ToString(obj))

        if obj and obj.status == true then

            gGathers[obj.data.gatherId] = gatherInfo
            gGathers[obj.data.gatherId].gatherId = obj.data.gatherId
            
            Sabot.JoinGather(obj.data.gatherId, obj.data.gatherPassword)

        end
    
    end

end

local function GatherJoined(gatherId)

    return function (data)
    
        local obj, pos, err = json.decode(data, 1, nil)
        //DebugPrint("response GatherJoined data %s", ToString(obj))
    
        if obj and obj.message == "wrongPassword" then
            MainMenu_SetAlertMessage("Invalid Password.")
        elseif obj and obj.message == "noSlotsLeft" then
            MainMenu_SetAlertMessage("Gather is full.")
        elseif obj and obj.message == "alreadyInGather" then
            MainMenu_SetAlertMessage("You are already in a gather.")
        end
        
        if obj and obj.status == true then
        
            SetCurrentGatherId(gatherId)
            
            gChatMessages = {}
            gPlayerNames = {}
            
        end
    
    end

end

local function StoreGatherList(data)

    local obj, pos, err = json.decode(data, 1, nil)
    
    //DebugPrint("response StoreGatherList data %s", ToString(obj))
    
    gGathers = {}

    if obj then

        for index, gatherInfo in pairs(obj) do
            gGathers[gatherInfo.gatherId] = gatherInfo
        end
    
    end
    
    if gGatherId ~= -1 then
        if not gGathers[gGatherId] then
            SetCurrentGatherId(-1)
        end
    end    

end

local function StoreGather(data)

    //DebugPrint("response StoreGather")

    local obj, pos, err = json.decode(data, 1, nil)
    if obj then
        gGathers[obj.gatherId] = obj   
    end

end

local function RoomUpdated(gatherId)

    return function (data)
    
        gRoomIsUpdating = false
    
        local obj, pos, err = json.decode(data, 1, nil)
        //DebugPrint("response RoomUpdated data %s", ToString(obj))
    
        if not obj or not obj.status then   
            SetCurrentGatherId(-1)
            //DebugPrint("removed from gather room")
        else
            
            if obj.gatherData then
            
                if obj.gatherData.serverIp and string.len(obj.gatherData.serverIp) > 0 and obj.gatherData.serverPort and obj.gatherData.serverPort > 0 then
                    gServerAddress = string.format("%s:%d", obj.gatherData.serverIp, obj.gatherData.serverPort)
                else
                    gServerAddress = ""
                end
                
                gServerPassword = obj.gatherData.serverPassword
                
                gGatherStatus = obj.gatherData.status
                if not gGatherStatus then
                    gGatherStatus = 1
                else
                    gGatherStatus = Clamp(gGatherStatus, kGatherStatus.Waiting, kGatherStatus.Connecting)
                end
                
                local gather = gGathers[obj.gatherData.gatherId]
                if gather then
                
                    gather.country = obj.gatherData.country
                    gather.playerNumber = obj.gatherData.players
                    gather.playerSlots = obj.gatherData.slots
                
                end

            end
        
        end
 
    end

end

local function ServerUpdated(data)      
 
    local obj, pos, err = json.decode(data, 1, nil)
    //DebugPrint("response ServerUpdated data %s", ToString(obj))

    if obj and obj.status == true then   

        gServerSettings.password = obj.password
        gServerSettings.mapName = obj.map

    end

end

function Sabot.SetGatherId(gatherId)

    if gatherId and type(gatherId) == "string" then
        gatherId = tonumber(gatherId)
    end

    SetCurrentGatherId(gatherId or -1)
    //DebugPrint("Sabot.SetGatherId(%s)", ToString(gatherId or -1))
    
end

function Sabot.RequestGatherId()

    Shared.SendHTTPRequest(kSabotURL .. string.format( "get/gather/current/%d", Client.GetSteamId()), "GET",  {}, StoreGatherId)
    //DebugPrint(string.format( "get/gather/current/%d", Client.GetSteamId()))

end

function Sabot.GetNumGathers()

    local count = 0

    for index, gather in pairs(gGathers) do
        count = count + 1
    end
    
    return count
    
end

function Sabot.GetGatherStatus()
    return gGatherStatus
end

function Sabot.GetGathers()
    return gGathers
end

function Sabot.RefreshGatherList()
    Shared.SendHTTPRequest(kSabotURL .. "get/gathers", "GET", {}, StoreGatherList)
    //DebugPrint("HTTPRequest get/gathers")
end

function Sabot.CreateGather(gatherInfo)

    SetCurrentGatherId(-1)

    gatherInfo.ownerId = Client.GetSteamId()
    gatherInfo.playerNumber = 1
    gatherInfo.requiresPassword = (gatherInfo.gatherPassword and string.len(gatherInfo.gatherPassword) > 0) and true or false
    
    Shared.SendHTTPRequest(kSabotURL .. "post/gather/add", "POST",  { data = json.encode(gatherInfo) }, JoinGatherOnSuccess(gatherInfo))
    //DebugPrint("HTTPRequest post/gather/add")
    //DebugPrint("send data %s", ToString(gatherInfo))
    
end

function Sabot.SendChatMessage(message)

    local params = { steamId = Client.GetSteamId(), gatherId = gGatherId, playerName = GetPlayerName(), text = message }
    Shared.SendHTTPRequest(kSabotURL .. "post/gather/chat", "POST", { data = json.encode(params) })
    //DebugPrint("HTTPRequest post/gather/chat")
    
end

function Sabot.SendLobbyMessage(message)

    local params = { steamId = 0, gatherId = gGatherId, playerName = "Gather Lobby", text = message }
    Shared.SendHTTPRequest(kSabotURL .. "post/gather/chat", "POST", { data = json.encode(params) })
    //DebugPrint("HTTPRequest post/gather/sendstatusmessage")

end

function Sabot.QuitGather(preventQuery)

    SetCurrentGatherId(-1)   
    
    if preventQuery then
        local params = { steamId = Client.GetSteamId() }
        Shared.SendHTTPRequest(kSabotURL .. "post/gather/quit", "POST", { data = json.encode(params) })
    end
    //DebugPrint("HTTPRequest post/gather/quit")

end

function Sabot.JoinGather(gatherId, password)

    SetCurrentGatherId(-1)

    local params = { steamId = Client.GetSteamId(), gatherPassword = password, gatherId = gatherId, playerName = GetPlayerName() }
    Shared.SendHTTPRequest(kSabotURL .. "post/gather/join", "POST", { data = json.encode(params) }, GatherJoined(gatherId))
    //DebugPrint("HTTPRequest post/gather/join gatherId %s", ToString(gatherId))
    
end

function Sabot.GetGatherInfo(gatherId)
    return gGathers[gatherId]
end

function Sabot.GetCurrentGatherId()
    return gGatherId
end

function Sabot.GetIsInGather()
    return gGatherId ~= -1
end

function Sabot.GetGatherStatusMessage()

    if gGatherId > 0 then    
        return kStatusMessages[gGatherStatus]
    end

    return ""
    
end

function Sabot.GetPlayerNames()
    return gPlayerNames
end

function Sabot.GetChatMessates()
    return gChatMessages
end

function Sabot.GetLastChatMessage()
    return gChatMessages[#gChatMessages]
end

function Sabot.GetServerAddress()
    return gServerAddress
end

function Sabot.GetServerPassword()
    return gServerPassword or ""
end

function Sabot.UpdateRoom()

    local params = { steamId = Client.GetSteamId(), gatherId = gGatherId, playerName = GetPlayerName(), gatherPassword = Sabot.GetGatherPassword() }
    Shared.SendHTTPRequest("http://gathers.naturalselection2.com/api/keep-alive", "POST", { data = json.encode(params) }, RoomUpdated(gGatherId))
    gRoomIsUpdating = true
    //DebugPrint("HTTPRequest post/gather/update")

end

function Sabot.SetGatherPassword(password)
    gGatherPassword = password
end

function Sabot.GetGatherPassword()
    return gGatherPassword
end

function Sabot.GetIsRoomUpdating()
    return gRoomIsUpdating == true
end

function Sabot.UpdateGather()
    Shared.SendHTTPRequest(kSabotURL .. "get/gathers/"..gGatherId, "GET", {}, StoreGather)
    //DebugPrint("HTTPRequest get/gathers/"..gGatherId)
end

function Sabot.GetGatherId()
    return gGatherId
end

function Sabot.GetServerSettings()
    return gServerSettings
end

function Sabot.RequestServerConfig()

    local params = { ip = Server.GetIpAddress(), port = Server.GetPort() }
    Shared.SendHTTPRequest(kSabotURL .. "post/gather/serverUpdate", "POST", { data = json.encode(params) }, ServerUpdated)
    //DebugPrint("HTTPRequest post/gather/serverUpdate")
    
end

if Client then

    local function OnLoadComplete(message)
    
        gGatherId = Client.GetOptionInteger("sabot/activeGatherId", -1)
    
        if message then
        
            gConnectionError = true      
            if gGatherId > 0 then
                Sabot.QuitGather()
            end
  
        end
        
        //Sabot.RequestGatherId()
    
    end

    // query hive initially and ask if we are in a gather room
    Event.Hook("LoadComplete", OnLoadComplete)

end

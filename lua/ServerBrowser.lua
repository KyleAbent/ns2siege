--=============================================================================
--
-- lua/ServerBrowser.lua
--
-- Created by Henry Kropf and Charlie Cleveland
-- Copyright 2012, Unknown Worlds Entertainment
--
--=============================================================================

Script.Load("lua/Utility.lua")
Script.Load("lua/menu/GUIMainMenu.lua")

local kFavoritesFileName = "FavoriteServers.json"
local kHistoryFileName = "HistoryServers.json"
local kRankedFileName = "RankedServers.json"

local kFavoriteAddedSound = "sound/NS2.fev/common/checkbox_on"
Client.PrecacheLocalSound(kFavoriteAddedSound)

local kFavoriteRemovedSound = "sound/NS2.fev/common/checkbox_off"
Client.PrecacheLocalSound(kFavoriteRemovedSound)

function FormatServerName(serverName, rookieOnly)

    -- Change name to display "rookie friendly" at the end of the line.
    if rookieOnly then
    
        local maxLen = 34
        local separator = ConditionalValue(string.len(serverName) > maxLen, "... ", " ")
        serverName = serverName:sub(0, maxLen) .. separator .. Locale.ResolveString("ROOKIE_ONLY")
        
    else
    
        local maxLen = 50
        local separator = ConditionalValue(string.len(serverName) > maxLen, "... ", " ")
        serverName = serverName:sub(0, maxLen) .. separator
        
    end
    
    return serverName
    
end

function FormatGameMode(gameMode , maxPlayers)
    gameMode = gameMode:sub(0, 12)
    if gameMode == "ns2" and maxPlayers > 24 then gameMode = "ns2Large" end
    return gameMode
end

local function GetServerTagValue(serverIndex, tagName, asString)

    if serverIndex >= 0 then

        local serverTags = { }
        Client.GetServerTags(serverIndex, serverTags)
        for t = 1, #serverTags do

            local tag = serverTags[t]
            local _, endIndex = string.find(tag, tagName)
            if endIndex then

                local value = string.sub(tag, endIndex + 1)
                return asString and value or tonumber(value)

            end

        end

    end

end

function GetNumServerReservedSlots(serverIndex)
    return GetServerTagValue(serverIndex, "R_S") or 0
end

function GetServerPlayerSkill(serverIndex)
    return GetServerTagValue(serverIndex, "P_S") or 0
end

function GetServerTickRate(serverIndex)
    return Client.GetServerTickRate(serverIndex)
end

function GetDynDNS(serverIndex)
    return GetServerTagValue(serverIndex, "DYNDNS_", true)
end

--use the dyndns as adrress if there is any
function GetServerAddress(serverIndex)
    local dns = GetDynDNS(serverIndex)
    local address = Client.GetServerAddress(serverIndex)
    if not dns then return address end

    local _, port = string.match(address, "(.+):(%d+)")
    return string.format("%s:%s", dns, port)
end

local function CalculateSeverRanking(serverEntry)
    local exp = math.exp
    local sqrt = math.sqrt
    local players = serverEntry.numPlayers

    local playerskill = Client.GetSkill()
    local playerscore = Client.GetScore()
    local playerlevel = Client.GetLevel()

    local viability = 1/(1 + exp( -0.5 * (players - 12)))
    local dViability = (201.714 * exp(0.5 * players))/(403.429 + exp(0.5 * players))^2
    local player = 0.66 * viability + 0.33 * dViability * math.max(0, (serverEntry.maxPlayers - players - 1))
    local ping = 1 / (1 + exp( 1/40 * (serverEntry.ping - 100)))
    local skill = (players < 2 or playerskill == -1) and 1 or exp(- 0.1 * math.abs(serverEntry.playerSkill - playerskill) * sqrt(players - 1) / (100 * sqrt(12)))
    local perf = 1/(1 + exp( - serverEntry.currentScore/5))
    local joinable = players < (serverEntry.maxPlayers - serverEntry.numRS) and 1 or 0.05
    local fav = serverEntry.favorite and 2 or 1
    local ranked = serverEntry.ranked and 10 or 1

    local rookieonly = (not serverEntry.rookieOnly or playerlevel == - 1 or playerlevel >= kRookieLevel) and 1 or 1 + (1/exp(0.001*(playerskill - 4500)))


    return player * ping * perf * skill * joinable * fav * rookieonly * ranked
end

function BuildServerEntry(serverIndex)

    local mods = Client.GetServerKeyValue(serverIndex, "mods")
    
    local serverEntry = { }
    serverEntry.name = Client.GetServerName(serverIndex)
    serverEntry.maxPlayers = Client.GetServerMaxPlayers(serverIndex)
    serverEntry.mode = FormatGameMode(Client.GetServerGameMode(serverIndex), serverEntry.maxPlayers)
    serverEntry.map = GetTrimmedMapName(Client.GetServerMapName(serverIndex))
    serverEntry.numPlayers = Client.GetServerNumPlayers(serverIndex)
    serverEntry.numRS = GetNumServerReservedSlots(serverIndex)
    serverEntry.ping = Client.GetServerPing(serverIndex)
    serverEntry.address = GetServerAddress(serverIndex)
    serverEntry.requiresPassword = Client.GetServerRequiresPassword(serverIndex)
    serverEntry.playerSkill = GetServerPlayerSkill(serverIndex)
    serverEntry.rookieOnly = Client.GetServerHasTag(serverIndex, "rookie_only")
    serverEntry.ignorePlayNow = Client.GetServerHasTag(serverIndex, "ignore_playnow")
    serverEntry.gatherServer = Client.GetServerHasTag(serverIndex, "gather_server")
    serverEntry.friendsOnServer = false
    serverEntry.lanServer = false
    serverEntry.tickrate = GetServerTickRate(serverIndex)
    serverEntry.currentScore = Client.GetServerCurrentPerformanceScore(serverIndex)
    serverEntry.performanceScore = Client.GetServerPerformanceScore(serverIndex)
    serverEntry.performanceQuality = Client.GetServerPerformanceQuality(serverIndex)
    serverEntry.serverId = serverIndex
    serverEntry.modded = Client.GetServerIsModded(serverIndex)
    serverEntry.ranked = GetServerIsRanked(serverEntry.address)
    serverEntry.favorite = GetServerIsFavorite(serverEntry.address)
    serverEntry.history = GetServerIsHistory(serverEntry.address)
    serverEntry.customNetworkSettings = Client.GetServerHasTag(serverIndex, "custom_network_settings")
    
    serverEntry.name = FormatServerName(serverEntry.name, serverEntry.rookieOnly)

    serverEntry.rating = CalculateSeverRanking(serverEntry)
    
    return serverEntry
    
end

local function SetLastServerInfo(address, password, mapname)

    Client.SetOptionString(kLastServerConnected, address)
    Client.SetOptionString(kLastServerPassword, password)
    Client.SetOptionString(kLastServerMapName, GetTrimmedMapName(mapname))
    
end

local function GetLastServerInfo()

    local address = Client.GetOptionString(kLastServerConnected, "")
    local password = Client.GetOptionString(kLastServerPassword, "")
    local mapname = Client.GetOptionString(kLastServerMapName, "")
    
    return address, password, mapname
    
end

do
    local function SkipTut()
        Shared.Message("Welcome back!")
        Client.SetAchievement("First_0_1")
    end
    Event.Hook("Console_iamsquad5", SkipTut)
end


--Join the server specified by UID and password.
--If password is empty string there is no password.
function MainMenu_SBJoinServer(address, password, mapname, rookieOnly)

    if GetGUIMainMenu() then
        local isRookie = GetGUIMainMenu().playerLevel and GetGUIMainMenu().playerLevel < 1
        local doneTutorial = Client.GetAchievement("First_0_1")

        if not rookieOnly and isRookie and not doneTutorial then
            GetGUIMainMenu():CreateTutorialNagWindow()
            return
        end

    end

    Client.Disconnect()
    LeaveMenu()

    if address == nil or address == "" then
    
        Shared.Message("No valid server to connect to.")
        return
        
    end
    
    if password == nil then
        password = ""
    end
    Client.Connect(address, password)
    
    SetLastServerInfo(address, password, mapname)
    
end

function OnRetryCommand()

    local address, password, mapname = GetLastServerInfo()
    
    if address == nil or address == "" then
    
        Shared.Message("No valid server to connect to.")
        return
        
    end
    
    Client.Disconnect()
    LeaveMenu()
    Shared.Message("Reconnecting to " .. address)
    MainMenu_SBJoinServer(address, password, mapname, true)
    
end
Event.Hook("Console_retry", OnRetryCommand)
Event.Hook("Console_reconnect", OnRetryCommand)

local gFavoriteServers = LoadConfigFile(kFavoritesFileName) or { }
local gHistoryServers = LoadConfigFile(kHistoryFileName) or {}
local gRankedServers = LoadConfigFile(kRankedFileName) or {}

local function UpgradeFavoriteServersFormat(favorites)

    local newFavorites = favorites
    -- The old format stored a list of addresses as strings.
    if type(favorites[1]) == "string" then
    
        -- The new format stores a list of server entries as tables.
        newFavorites = { }
        for f = 1, #favorites do
            table.insert(newFavorites, { address = favorites[f] })
        end
        
        SaveConfigFile(kFavoritesFileName, newFavorites)
        
    end
    
    return newFavorites
    
end
gFavoriteServers = UpgradeFavoriteServersFormat(gFavoriteServers)

-- Remove any entries lacking a server address. These are bogus entries.
for f = #gFavoriteServers, 1, -1 do

    if not gFavoriteServers[f].address then
        table.remove(gFavoriteServers, f)
    end
    
end

for f = #gHistoryServers, 1, -1 do

    if not gHistoryServers[f].address then
        table.remove(gHistoryServers, f)
    end
    
end

function SetServerIsFavorite(serverData, isFavorite)

    local foundIndex = nil
    for f = 1, #gFavoriteServers do
    
        if gFavoriteServers[f].address == serverData.address then
        
            foundIndex = f
            break
            
        end
        
    end
    
    if isFavorite and not foundIndex then
    
        local savedServerData = { }
        for k, v in pairs(serverData) do savedServerData[k] = v end
        table.insert(gFavoriteServers, savedServerData)
        StartSoundEffect(kFavoriteAddedSound)
        
    elseif foundIndex then
    
        table.remove(gFavoriteServers, foundIndex)
        StartSoundEffect(kFavoriteRemovedSound)
        
    end
    
    SaveConfigFile(kFavoritesFileName, gFavoriteServers)
    
end

local kMaxServerHistory = 10

-- first in, first out
function AddServerToHistory(serverData)

    local foundIndex = nil
    for f = 1, #gHistoryServers do
    
        if gHistoryServers[f].address == serverData.address then
        
            foundIndex = f
            break
            
        end
        
    end
    
    if foundIndex == nil then

        if #gHistoryServers > kMaxServerHistory then
            table.remove(gHistoryServers, 1)    
        end
        
        local savedServerData = { }
        for k, v in pairs(serverData) do savedServerData[k] = v end        
        table.insert(gHistoryServers, savedServerData)
        
        SaveConfigFile(kHistoryFileName, gHistoryServers)
    
    end

end

function GetServerIsFavorite(address)

    for f = 1, #gFavoriteServers do
    
        if gFavoriteServers[f].address == address then
            return true
        end
        
    end
    
    return false
    
end

function GetServerIsHistory(address)

    for f = 1, #gHistoryServers do

        if gHistoryServers[f].address == address then
            return true
        end
        
    end
    
    return false

end

function UpdateRankedServers(rankedList)
    gRankedServers = rankedList

    SaveConfigFile(kRankedFileName, gRankedServers)
end

function GetServerIsRanked(address)
    return gRankedServers[address]
end

function UpdateFavoriteServerData(serverData)

    for f = 1, #gFavoriteServers do
    
        if gFavoriteServers[f].address == serverData.address then
        
            for k, v in pairs(serverData) do gFavoriteServers[f][k] = v end
            break
            
        end
        
    end
    
end

function UpdateHistoryServerData(serverData)

    for f = 1, #gFavoriteServers do
    
        if gHistoryServers[f].address == serverData.address then
        
            for k, v in pairs(serverData) do gHistoryServers[f][k] = v end
            break
            
        end
        
    end
    
end

function GetFavoriteServers()
    return gFavoriteServers
end

function GetHistoryServers()
    return gHistoryServers
end

function GetStoredServers()

    local servers = {}
    
    local function UpdateHistoryFlag(address, list)
    
        for i = 1, #list do
            if list[i].address == address then
                list[i].history = true
                return true
            end
        end
        
        return false
    
    end
    
    for f = 1, #gFavoriteServers do
    
        table.insert(servers, gFavoriteServers[f])  
        servers[f].favorite = true
        
    end
    
    for f = 1, #gHistoryServers do
 
        if not UpdateHistoryFlag(gHistoryServers[f].address, servers) then
        
            table.insert(servers, gHistoryServers[f])
            servers[#servers].favorite = false
            servers[#servers].history = true
            
        end
        
    end
    
    return servers

end

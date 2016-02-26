--=============================================================================
--
-- lua/Scoreboard.lua
-- 
-- Created by Henry Kropf and Charlie Cleveland
-- Copyright 2011, Unknown Worlds Entertainment
--
--=============================================================================

--[[
 * Main purpose it to maintain a cache for player info, allowing information for a player
 * to be retrived by a players clientIndex or playerName.
 *
 * Originally intended to be used by the scoreboard, therefore its name. 
 * Should probably be renamed PlayerRecords or PlayerDatabase
 *
 * Keeps track of when it was last updated and avoids updating more often than kMaxPlayerDataAge
]]
Script.Load("lua/Insight.lua")

-- primary lookup table with clientIndex (clientId) as key
local playerData = { }
-- index with player name as key
local playerDataByName = { }
-- sorted list by score
local sortedPlayerData = { }

local lastPlayerDataUpdateTime = 0
local kMaxPlayerDataAge = 0.5


local kStatusTranslationStringMap = {
    [kPlayerStatus.Dead]="STATUS_DEAD",
    [kPlayerStatus.Evolving]="STATUS_EVOLVING",
    [kPlayerStatus.Embryo]="STATUS_EMBRYO",
    [kPlayerStatus.Commander]="STATUS_COMMANDER",
    [kPlayerStatus.Exo]="STATUS_EXO",
    [kPlayerStatus.GrenadeLauncher]="STATUS_GRENADE_LAUNCHER",
    [kPlayerStatus.Rifle]= "STATUS_RIFLE",
    [kPlayerStatus.Shotgun]="STATUS_SHOTGUN",
    [kPlayerStatus.Flamethrower]="STATUS_FLAMETHROWER",
    [kPlayerStatus.Void]="STATUS_VOID",
    [kPlayerStatus.Spectator]="STATUS_SPECTATOR",
    [kPlayerStatus.Skulk]="STATUS_SKULK",
    [kPlayerStatus.Gorge]="STATUS_GORGE",
    [kPlayerStatus.Lerk]="STATUS_LERK",
    [kPlayerStatus.Fade]="STATUS_FADE",
    [kPlayerStatus.Onos]="STATUS_ONOS",
    [kPlayerStatus.SkulkEgg]="SKULK_EGG",
    [kPlayerStatus.GorgeEgg]="GORGE_EGG",
    [kPlayerStatus.LerkEgg]="LERK_EGG",
    [kPlayerStatus.FadeEgg]="FADE_EGG",
    [kPlayerStatus.OnosEgg]="ONOS_EGG",
}

-- reloads the player data. Should be no need to call this, as player data is reloaded on demand
function Scoreboard_ReloadPlayerData()
  
    PROFILE("Scoreboard:ReloadPlayerData")
    lastPlayerDataUpdateTime = Shared.GetTime()
  
    for _, pie in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
    
        local statusTxt = "-"
        if pie.status ~= kPlayerStatus.Hidden then
            local statusTranslationString = kStatusTranslationStringMap[pie.status]
            statusTxt = statusTranslationString and Locale.ResolveString(statusTranslationString) or "Unknown status:" .. pie.status
        end
        
        local playerRecord = playerData[pie.clientId]
        if playerRecord == nil then
            playerRecord = {}
            
            playerData[pie.clientId] = playerRecord
            
            playerRecord.ClientIndex = pie.clientId
            playerRecord.IsSteamFriend = Client.GetIsSteamFriend(pie.steamId)
            playerRecord.Ping = 0
        end
        
        playerRecord.LastUpdateTime = lastPlayerDataUpdateTime

        playerRecord.EntityId = pie.playerId
        playerRecord.Name = pie.playerName
        playerRecord.EntityTeamNumber = pie.teamNumber
        playerRecord.Score = pie.score
        playerRecord.Kills = pie.kills
        playerRecord.Deaths = pie.deaths
        playerRecord.Resources = math.floor(pie.resources)
        playerRecord.IsCommander = pie.isCommander
        playerRecord.IsRookie = pie.isRookie
        playerRecord.Status = statusTxt
        playerRecord.IsSpectator = pie.isSpectator
        playerRecord.Assists = pie.assists
        playerRecord.SteamId = pie.steamId
        playerRecord.Skill = pie.playerSkill
        playerRecord.Tech = pie.currentTech
        
    end
    
    sortedPlayerData = { }
    playerDataByName = { }
    
    -- clean out old player records
    for clientIndex, playerRecord in pairs(playerData) do
        if lastPlayerDataUpdateTime - playerRecord.LastUpdateTime > kMaxPlayerDataAge then
            playerData[clientIndex] = nil
        else
            table.insert(sortedPlayerData, playerRecord)
            playerDataByName[playerRecord.Name] = playerRecord
        end         
    end
    
    Scoreboard_Sort()
    
end

-- call this to ensure that the data is reasonably up-to-date
local function CheckForReload()
    if Shared.GetTime() - lastPlayerDataUpdateTime > kMaxPlayerDataAge then
        Scoreboard_ReloadPlayerData()
        return true
    end
    return false
end

-- Returns the playerRecord for the given players clientIndex, reloading player data if required
function Scoreboard_GetPlayerRecord(clientIndex)
    
    if not CheckForReload() and playerData[clientIndex] == nil then
        Scoreboard_ReloadPlayerData()
    end
    
    return playerData[clientIndex]
    
end

-- Returns the playerRecord for the given players name, reloading player data if required
function Scoreboard_GetPlayerRecordByName(playerName)
    
   if not CheckForReload() and playerDataByName[playerName] == nil then
        Scoreboard_ReloadPlayerData()
    end
    
    return playerDataByName[playerName]
    
end

function Insight_SetPlayerHealth(clientIndex, health, maxHealth, armor, maxArmor)
    
    local playerRecord = Scoreboard_GetPlayerRecord(clientIndex)
    if playerRecord then
        playerRecord.Health = health
        playerRecord.MaxHealth = maxHealth
        playerRecord.Armor = armor
        playerRecord.MaxArmor = maxArmor
    end
    
end

function Scoreboard_Clear()

    playerData = { }
    Insight_Clear()
    
end

-- Score > Kills > Deaths > Resources
function Scoreboard_Sort()

    local function sortByScore(player1, player2)
    
        if player1.EntityTeamNumber == player2.EntityTeamNumber then
        
            if player1.Score == player2.Score then
            
                if player1.Kills == player2.Kills then
                
                    if player1.Deaths == player2.Deaths then    
                    
                        if player1.Resources == player2.Resources then    
                        
                            -- Somewhat arbitrary but keeps more coherence and adds players to bottom in case of ties
                            return player1.ClientIndex > player2.ClientIndex
                            
                        else
                            return player1.Resources > player2.Resources
                        end
                        
                    else
                        return player1.Deaths < player2.Deaths
                    end
                    
                else
                    return player1.Kills > player2.Kills
                end
                
            else
                return player1.Score > player2.Score    
            end
            
        else
            -- Spectators should be at the top of the RR "team"
            -- Spectators are team 3 and RR players are team 0
            return player1.EntityTeamNumber > player2.EntityTeamNumber
        end
    end
        
    table.sort(sortedPlayerData, sortByScore)

end

function Scoreboard_SetPing(clientIndex, ping)
    -- setting ping does not cause a reload for missing player data
    if playerData[clientIndex] then
        playerData[clientIndex].Ping = ping
    end
    
end

-- Set local data for player so scoreboard updates instantly (used only in test)
function Scoreboard_SetLocalPlayerData(playerName, index, data)
  
    playerData[index] = data
        
end


function Scoreboard_GetPlayerName(clientIndex)

    local record = Scoreboard_GetPlayerRecord(clientIndex)
    return record and record.Name
    
end

function Scoreboard_GetPlayerList()
  
    CheckForReload()
    
    local playerList = { }
    for p = 1, #sortedPlayerData do
    
        local playerRecord = sortedPlayerData[p]
        table.insert(playerList, { name = playerRecord.Name, client_index = playerRecord.ClientIndex })
        
    end
    
    return playerList
    
end

function Scoreboard_GetPlayerData(clientIndex, dataType)
    -- often used to avoid a null-check
    local playerRecord = Scoreboard_GetPlayerRecord(clientIndex)
    return playerRecord and playerRecord[dataType]
            
end

--[[
 * Get table of scoreboard player records for all players with team numbers in specified table.
]]
function GetScoreData(teamNumberTable)

    local scoreData = { }
    local commanders = { }
    
    local localTeamNumber = Client.GetLocalClientTeamNumber()   

    for index, playerRecord in ipairs(sortedPlayerData) do
        if table.find(teamNumberTable, playerRecord.EntityTeamNumber) then
        
            local isVisibleTeam = localTeamNumber == kSpectatorIndex or playerRecord.EntityTeamNumber == localTeamNumber
            local isCommander = playerRecord.IsCommander and isVisibleTeam
        
            if not isCommander then
                table.insert(scoreData, playerRecord)
            else
                table.insert(commanders, playerRecord)
            end    
                
        end
    end
    
    for _, commander in ipairs(commanders) do
        table.insert(scoreData, 1, commander)
    end
    
    return scoreData
    
end

--[[
 * Get score data for the blue team
]]
function ScoreboardUI_GetBlueScores()
    return GetScoreData({ kTeam1Index })
end

--[[
 * Get score data for the red team
]]
function ScoreboardUI_GetRedScores()
    return GetScoreData({ kTeam2Index })
end

--[[
 * Get score data for everyone not playing.
]]
function ScoreboardUI_GetSpectatorScores()
    return GetScoreData({ kTeamReadyRoom, kSpectatorIndex })
end

function ScoreboardUI_GetAllScores()
    return GetScoreData({ kTeam1Index, kTeam2Index, kTeamReadyRoom, kSpectatorIndex })
end

function ScoreboardUI_GetTeamResources(teamNumber)

    local teamInfo = GetEntitiesForTeam("TeamInfo", teamNumber)
    if table.count(teamInfo) > 0 then
        return teamInfo[1]:GetTeamResources()
    end
    
    return 0

end

--[[
 * Get the name of the blue team
]]
function ScoreboardUI_GetBlueTeamName()
    return kTeam1Name
end

--[[
 * Get the name of the red team
]]
function ScoreboardUI_GetRedTeamName()
    return kTeam2Name
end

--[[
 * Get the name of the spectator team
]]
function ScoreboardUI_GetSpectatorTeamName()
    return kSpectatorTeamName
end

--[[
 * Return true if playerName is a local player.
]]
function ScoreboardUI_IsPlayerLocal(playerName)
    
    local player = Client.GetLocalPlayer()
    
    -- Get entry with this name and check entity id
    if player then
      
        local playerRecord = Scoreboard_GetPlayerRecord(player:GetClientIndex())     
        return playerRecord and playerName == playerRecord.Name
        
    end
    
    return false
    
end

function ScoreboardUI_IsPlayerCommander(playerName)

    local playerRecord = Scoreboard_GetPlayerRecordByName(playerName)
    return playerRecord and playerRecord.IsCommander            

end

function ScoreboardUI_IsPlayerRookie(playerName)
    
    local playerRecord = Scoreboard_GetPlayerRecordByName(playerName)
    return playerRecord and playerRecord.IsRookie            
    
end



function ScoreboardUI_GetTeamHasCommander(teamNumber)

    CheckForReload()
    
    for i = 1, #sortedPlayerData do
    
        local playerRecord = sortedPlayerData[i]
        if playerRecord.EntityTeamNumber == teamNumber and playerRecord.IsCommander then
            return true
        end
        
    end
    
    return false
    
end

function ScoreboardUI_GetCommanderName(teamNumber)

    CheckForReload()
    
    for i = 1, table.maxn(sortedPlayerData) do
    
        local playerRecord = sortedPlayerData[i]
        
        if (playerRecord.EntityTeamNumber == teamNumber) and playerRecord.IsCommander then
            return playerRecord.Name
        end
        
    end
    
    return nil
    
end

function ScoreboardUI_GetOrderedCommanderNames(teamNumber)
  
    CheckForReload()
    local commanders = {}
    
    -- Create table of commander entity ids and names
    for i = 1, table.maxn(sortedPlayerData) do
    
        local playerRecord = sortedPlayerData[i]
        
        if (playerRecord.EntityTeamNumber == teamNumber) and playerRecord.IsCommander then
            table.insert( commanders, {playerRecord.EntityId, playerRecord.Name} )
        end
        
    end
    
    local function sortCommandersByEntity(pair1, pair2)
        return pair1[1] < pair2[1]
    end
    
    -- Sort it by entity id
    table.sort(commanders, sortCommandersByEntity)
    
    --http Return names in order
    local commanderNames = {}
    for index, pair in ipairs(commanders) do
        table.insert(commanderNames, pair[2])
    end
    
    return commanderNames
    
end

function ScoreboardUI_GetNumberOfAliensByType(alienType)
  
    CheckForReload()
    local numberOfAliens = 0
    
    for index, playerRecord in ipairs(sortedPlayerData) do
        if alienType == playerRecord.Status then
            numberOfAliens = numberOfAliens + 1
        end
    end
    
    return numberOfAliens

end


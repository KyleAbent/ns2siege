// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ServerPerformanceData.lua
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
// Handles server-performance data.
//
// There are two users for this data
// - server admins wanting to figure out what is going on with the server 
// - players wanting to know if they should play on this server
//
// The data is accumulated and sent once per second to every client as part of the network packet
// (non-reliably; so if that packet is lost, the client will have to wait another second for the data)
// This can be used to alert the player that the current server is experiencing problems.
//
// Server admins can use something similar to the simple code below to monitor server state.
//
// The server query packet returns the last 30-second perf data, and the worst 30-second performance data
// for any current and historical games (as servers reboot every few days, an odd worst-case perf data will go away
// after a while). The browser analyzes these, then determines the score.
//
// Note that the server browser needs to indicate how certain it is about the score; a freshly rebooted
// server have no performance data available to send back. A green "???" mark for servers with no
// data, and one "?" less for every full-blown perf data available might be useful.
// 
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local thirtySecFull = ServerPerformanceData()
local thirtySecAcc = ServerPerformanceData()
local lastTimestamp = 0
local headerPrinted = false
local monitoringActive = false
local detailMonitoringActive = false
local spamMonitoringActive = false

// require a quality score of 50 to stop displaying unknown in text
// actual score is still indicated by color
kServerPerformanceDataUnknownQualityCutoff = 50

/*
 * Copy of the docs for the ServerPerformanceData object
 docs { Accumulate the result of the other in self. Used to get the performance for a longer duration }
method void ServerPerformanceData:Accumulate(ServerPerformanceData& other)

docs { Clears the contents }
method void ServerPerformanceData:Clear()

docs { Copy data from the other. }
method void ServerPerformanceData:Copy(ServerPerformanceData& other)

docs { Return a (dense) string representation of the performance data. }
method const char * ServerPerformanceData:ToString()

docs { Returns the performance score as a SIGNED number -99 - 100, the higher the better. }
method int ServerPerformanceData:GetScore()

docs { Returns the quality, 0-100, with 100 representing the server running at full load. }
method int ServerPerformanceData:GetQuality()

docs { Shared.GetTime() for when this data was completed. }
method double ServerPerformanceData:GetTimestamp()

docs { Server setting: moverate }
method int ServerPerformanceData:GetMoverate()

docs { Server setting: interp, in ms }
method int ServerPerformanceData:GetInterpMs()

docs { Server setting: tickrate }
method int ServerPerformanceData:GetTickrate()

docs { Server setting: sendrate }
method int ServerPerformanceData:GetSendrate()

docs { Server setting: max number of players }
method int ServerPerformanceData:GetMaxPlayers()

docs { Duration in ms for this data }
method int ServerPerformanceData:GetDurationMs() 

docs { Number of players. }
method int ServerPerformanceData:GetNumPlayers()

docs { Average world update interval (actual tickrate) } 
method int ServerPerformanceData:GetUpdateIntervalMs()

docs { Total number of entities updated, (ie number of entities * number of updates ) } 
method int ServerPerformanceData:GetNumEntitiesUpdated()

docs { Total time in ms spent updating non-player entities. }
method int ServerPerformanceData:GetTimeSpentOnUpdate()

docs { Total number of player moves processed }
method int ServerPerformanceData:GetMovesProcessed()

docs { Total time in ms spent handling player moves }
method int ServerPerformanceData:GetTimeSpentOnMoves()

docs { Total time in ms spent idling }
method int ServerPerformanceData:GetTimeSpentIdling()

docs { Total time in ms in overdraft. Note: may be high on idle Windows servers 
due to default Windows timeslice of 15ms. Becomes accurate once enough players starts playing. }
method int ServerPerformanceData:GetTimeOverdraft()

docs { Total number of times a player gets a slightly late network update (interval > 0.75 * interp) }
method int ServerPerformanceData:GetNumInterpWarns()

docs { Total number of times a player gets a very late network update (interval >= interp). This is fatal to the client performance and is heavily penalized when it comes to determining server capability. }
method int ServerPerformanceData:GetNumInterpFails()

docs { Average number of entities. }
method int ServerPerformanceData:GetEntityCount()
*/


local kServerPerformanceNameTable = 
{
    "SERVER_PERF_BAD",
    "SERVER_PERF_LOADED",
    "SERVER_PERF_OK",
    "SERVER_PERF_GOOD"
}

local kGood = 15
local kOk = -1
local kLoaded = -20
local kBad = -100

local kServerPerformanceLevelTable = { kBad, kLoaded, kOk, kGood }

ServerPerformanceData.kNumPerfLevels = #kServerPerformanceLevelTable


/**
 * The score color is used to determine logging - anything but "green" causes a log for
 * the lowest level of logging
 */
local function GetScoreColor(score)
    local result = "green"
    if score < kLoaded then 
        result = "red"
    elseif score < kOk then
        result = "orange"
    elseif score < kGood then
        result = "yellow"
    end
    return result
end

/**
 * Return a description of the ServerPerformanceData
 */
function ServerPerformanceData.DetailText(self)
    local dMs = self:GetDurationMs()
    if (dMs <= 0) then
        return "(no data)"
    end
    local players = self:GetNumPlayers()
    if players <= 0 then
        return "(no players)"
    end
    local dSec = dMs / 1000;
    local score = self:GetScore()
    local quality = self:GetQuality()
    local idlePer = 100 * self:GetTimeSpentIdling() / dMs
    local moveCnt = self:GetMovesProcessed() / dSec
    local movePer = 100 * self:GetTimeSpentOnMoves() / dMs
    local moveCost = self:GetTimeSpentOnMoves() / self:GetMovesProcessed()
    local movesPerPlayers = moveCnt / players
    local entityCnt = self:GetEntityCount()
    local entityPer = 100 * self:GetTimeSpentOnUpdate() / dMs;
    local entityCost = self:GetTimeSpentOnUpdate() / self:GetNumEntitiesUpdated()
    local tickrate = 1000 / self:GetUpdateIntervalMs()
    local overload = self:GetIncompleteCount() / (dSec * tickrate)
    local iwarns = self:GetNumInterpWarns() / dSec
    local ifails = self:GetNumInterpFails() / dSec
    return string.format("Score %d, Q %d, idle %.1f%%, mv %.1f%%(cnt %d(%d/%.1f), avg %.2fms), ent %.1f%%(cnt %d, avg %.2fms), tick %.1f (over %.1fms), iWarn %d, iFail %d",
            score, 
            quality,
            idlePer,
            movePer,
            moveCnt,
            players,
            movesPerPlayers,
            moveCost,
            entityPer,
            entityCnt,
            entityCost,
            tickrate,
            overload,
            iwarns,
            ifails)
        
end

/**
 * Return the header text (static part of the server data)
 */
function ServerPerformanceData.HeaderText(self)
    local moverate = self:GetMoverate()
    local interp = self:GetInterpMs()
    local tickrate = self:GetTickrate()
    local sendrate = self:GetSendrate()
    local maxplayers = self:GetMaxPlayers()
    return string.format("tickrate %d, moverate %d, maxplayers %d, sendrate %d, interp %d",
            tickrate,
            moverate,
            maxplayers,
            sendrate,
            interp)      
end

local function LogPerformance()
    // get the latest perf data, make sure it is uptodate
    local perfData = Shared.GetServerPerformanceData()
    
    if perfData:GetDurationMs() > 0 and lastTimestamp ~= perfData:GetTimestamp() then
        if spamMonitoringActive then
            if not headerPrinted then
                Log("PerfHeader: %s", ServerPerformanceData.HeaderText(perfData) )
                headerPrinted = true
            end
            Log("Perf %s", ServerPerformanceData.DetailText(perfData) )
        end
        thirtySecAcc:Accumulate(perfData)
        if thirtySecAcc:GetDurationMs() > (30 * 1000) then
            thirtySecFull:Copy(thirtySecAcc)
            thirtySecAcc:Clear()
            local color = GetScoreColor(thirtySecFull:GetScore())
            if detailMonitoringActive or (color ~= "green" and monitoringActive) then
                if not headerPrinted then
                    Log("PerfHeader: %s", ServerPerformanceData.HeaderText(perfData) )
                    headerPrinted = true
                end
                Log("Perf %5s: %s", color, ServerPerformanceData.DetailText(thirtySecFull))
            end
        end
        lastTimestamp = perfData:GetTimestamp()
    end
end

local function LogPerformanceServer()
    LogPerformance()
end

local function LogPerformanceClient()
    Client.SetDebugText("PerfData.OnUpdateClient entry")
    LogPerformance()
    Client.SetDebugText("PerfData.OnUpdateClient exit")
end

function ServerPerformanceData.GetColor(performanceScore)
    // 50 = fully green, 0 = yellow, -50 fully red
    local k = Clamp((performanceScore  + 50) / 100, 0, 1)
    return Color(1 - k, k, k - 0.8, 1)
end

dbgServerPerfData = false

function ServerPerformanceData.GetPerfIndexForTranslatedName(transPerfName)

    for i,name in ipairs(ServerPerformanceData.GetPerformanceLevelNames()) do
        if transPerfName == name then
            return i
        end
    end
    return 0
    
end

function ServerPerformanceData.GetPerformanceLevelNames()
    local result = {}
    for i,name in ipairs(kServerPerformanceNameTable) do
        result[i] = Locale.ResolveString(name)
    end
    return result
end

function ServerPerformanceData.GetScoreForPerformanceIndex(index)
    return kServerPerformanceLevelTable[index]
end


// return Unknown if quality is below cutoff (before that, the color
// of the text will still indicate score)
function ServerPerformanceData.GetPerformanceText(quality, score)
    local result = Locale.ResolveString("SERVER_PERF_UNKNOWN")
    if quality >= kServerPerformanceDataUnknownQualityCutoff then
        result = Locale.ResolveString(
            ( score < kLoaded and "SERVER_PERF_BAD" or
            ( score < kOk and "SERVER_PERF_LOADED" or
            ( score < kGood and "SERVER_PERF_OK" or "SERVER_PERF_GOOD"))))
    end
    
    if dbgServerPerfData then
        Log("PerfText: Quality %s, Score %s, result %s", quality, score, result)
    end
    
    return result
end

// repeating "perfmon" will rotate through the various detail levels
local function OnConsolePerfmon()
    if monitoringActive and not detailMonitoringActive then
        detailMonitoringActive = true
    elseif monitoringActive and detailMonitoringActive and not spamMonitoringActive then
        spamMonitoringActive = true
    else
        monitoringActive = not monitoringActive
        detailMonitoringActive = detailMonitoringActive and monitoringActive
        spamMonitoringActive = spamMonitoringActive and detailMonitoringActive and monitoringActive
    end
    
    Log("monitoringActive %s%s%s", monitoringActive,
        detailMonitoringActive and " (detailed)" or "",
        spamMonitoringActive and "[spam]" or "")
      
    if not monitoringActive then
        // make the header text trigger again
        headerPrinted = false
    end
end

local function OnConsolePerfDbg()
    dbgServerPerfData = not dbgServerPerfData
    Log("perfdbg %s", dbgServerPerfData)
end

if not __SPD_HOOKED then
  if Server then
      Event.Hook("UpdateServer", LogPerformanceServer)
  elseif Client then
      Event.Hook("UpdateClient", LogPerformanceClient, "ServerPerformanceData")
  end

  Event.Hook("Console_perfmon", OnConsolePerfmon)
  Event.Hook("Console_perfdbg", OnConsolePerfDbg)
  __SPD_HOOKED = true
end
//=============================================================================
//
// lua/Commander_IdleWorkerPanel.lua
// 
// Created by Henry Kropf and Charlie Cleveland
// Copyright 2011, Unknown Worlds Entertainment
//
//=============================================================================

/**
 * Return the number of idle workers
 */
function CommanderUI_GetIdleWorkerCount()
    
    local player = Client.GetLocalPlayer()
    
    // $AS FIXME: I do not know how this is possible as the local player should
    // never be nil :/ 
    if (player == nil) then
      return 0
    end
    
    if player.GetNumIdleWorkers ~= nil then
        return player:GetNumIdleWorkers()
    end
    
    return 0
    
end

/**
 * Indicates that user clicked on the idle worker
 */
function CommanderUI_ClickedIdleWorker()
    
    Shared.ConsoleCommand("gotoidleworker")
    
end

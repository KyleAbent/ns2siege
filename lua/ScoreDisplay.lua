//=============================================================================
//
// lua/ScoreDisplay.lua
// 
// Created by Henry Kropf
// Copyright 2011, Unknown Worlds Entertainment
//
//=============================================================================

local pendingScore = 0
local pendingRes = 0
local pendingWasKill = false

/**
 * Gets current score variable, returns it and sets var to 0. Also 
 * returns res given to player (0 to not display).
 */
function ScoreDisplayUI_GetNewScore()

    local tempScore = pendingScore
    local tempRes = pendingRes
    local tmpWasKill = pendingWasKill
    
    pendingScore = 0
    pendingRes = 0
    pendingWasKill = false
    
    return tempScore, tempRes, tmpWasKill
    
end


/**
 * Called to set latest score
 */
function ScoreDisplayUI_SetNewScore(score, res, wasKill)

    if wasKill or Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full then

        pendingScore = score
        pendingRes = res
        pendingWasKill = wasKill
    
    end
    
end

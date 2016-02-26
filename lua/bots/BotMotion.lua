// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// Created by Steven An (steve@unknownworlds.com)
//
// This class takes high-level motion-intents as input (ie. "I want to move here" or "I want to go in this direction")
// and translates them into controller-inputs, ie. mouse direction and button presses.
//
// ==============================================================================================

//----------------------------------------
//  Expensive pathing call
//----------------------------------------
local function GetOptimalMoveDirection( from, to )

    local pathPoints = PointArray()
    local reachable = Pathing.GetPathPoints(from, to, pathPoints)

    if reachable and #pathPoints > 0 then
        return (pathPoints[1] - from):GetUnit()
    else
        // sensible fallback
        // DebugPrint("Could not find path from %s to %s", ToString(from), ToString(to))
        return (to-from):GetUnit()
    end    

end

//----------------------------------------
//  Provides an interface for higher level logic to specify desired motion.
//  The actual bot classes use this to compute move.move, move.yaw/pitch. Also, jump.
//----------------------------------------

class "BotMotion"

function BotMotion:Initialize(player)

    self.currMoveDir = Vector(0,0,0)
    self.currViewDir = Vector(1,0,0)
    self.lastMovedPos = player:GetOrigin()

end

function BotMotion:ComputeLongTermTarget(player)

    local kTargetOffset = 1

    if self.desiredMoveDirection ~= nil then

        local toPoint = player:GetOrigin() + self.desiredMoveDirection * kTargetOffset
        return toPoint

    elseif self.desiredMoveTarget ~= nil then

        return self.desiredMoveTarget

    else
    
        return nil

    end    
end

//----------------------------------------
//  
//----------------------------------------
function BotMotion:OnGenerateMove(player)
    
    local currentPos = player:GetOrigin()
    local eyePos = player:GetEyePos()    
    local doJump = false

    local delta = currentPos - self.lastMovedPos

    //----------------------------------------
    //  Update ground motion
    //----------------------------------------

    local moveTargetPos = self:ComputeLongTermTarget(player)

    if moveTargetPos ~= nil and not player:isa("Embryo") then

        local distToTarget = currentPos:GetDistance(moveTargetPos)
    
        if distToTarget <= 0.01 then
            
            // Basically arrived, stay here
            self.currMoveDir = Vector(0,0,0)

        else
            
            // Path to the target position
            // But for perf and for hysteresis control, only change direction about every 10th of a second
            local updateMoveDir = math.random() < 0.1

            if updateMoveDir then

                // If we have not actually moved much since last frame, then maybe pathing is failing us
                // So for now, move in a random direction for a bit and jump
                if delta:GetLength() < 1e-2 then

                    //Print("stuck! spazzing out")
                    self.currMoveDir = GetRandomDirXZ()
                    doJump = true

                elseif distToTarget <= 2.0 then

                    // Optimization: If we are close enough to target, just shoot straight for it.
                    // We assume that things like lava pits will be reasonably large so this shortcut will
                    // not cause bots to fall in
                    // NOTE NOTE STEVETEMP TODO: We should add a visiblity check here. Otherwise, units will try to go through walls
                    self.currMoveDir = (moveTargetPos - currentPos):GetUnit()

                else

                    // We are pretty far - do the expensive pathing call
                    self.currMoveDir = GetOptimalMoveDirection( currentPos, moveTargetPos )

                end

            end

            self.lastMovedPos = currentPos
        end

        
    else

        // Did not want to move anywhere - stay still
        self.currMoveDir = Vector(0,0,0)

    end

    //----------------------------------------
    //  View direction
    //----------------------------------------

    if self.desiredViewTarget ~= nil then

        // Look at target
        self.currViewDir = (self.desiredViewTarget - eyePos):GetUnit()

    elseif self.currMoveDir:GetLength() > 1e-4 then

        // Look in move dir
        self.currViewDir = self.currMoveDir
        self.currViewDir.y = 0.0  // pathing points are slightly above ground, which leads to funny looking-up
        self.currViewDir = self.currViewDir:GetUnit()

    else
        // leave it alone
    end

    return self.currViewDir, self.currMoveDir, doJump

end

//----------------------------------------
//  Higher-level logic interface
//----------------------------------------
function BotMotion:SetDesiredMoveTarget(toPoint)

    // Mutually exclusive
    self:SetDesiredMoveDirection(nil)

    if not VectorsApproxEqual( toPoint, self.desiredMoveTarget, 1e-4 ) then
        self.desiredMoveTarget = toPoint
    end
    
end

//----------------------------------------
//  Higher-level logic interface
//----------------------------------------
// Note: while a move direction is set, it overrides a target set by SetDesiredMoveTarget
function BotMotion:SetDesiredMoveDirection(direction)

    if not VectorsApproxEqual( direction, self.desiredMoveDirection, 1e-4 ) then
        self.desiredMoveDirection = direction
    end
    
end

//----------------------------------------
//  Higher-level logic interface
//  Set to nil to clear view target
//----------------------------------------
function BotMotion:SetDesiredViewTarget(target)

    self.desiredViewTarget = target

end


// ======= Copyright (c) 2015, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// Created by Mats olsson (mats.olsson@matsotech.se)
//
// The aim control builds up a track of the target positions and will try to aim towards
// the target.
// It will simulate with a reaction time that uses the history of the target positions to
// extrapolate to where it will be after the reaction time has passed. This means that the
// aim is designed to allow the target to dodge bullets by changing direction quickly, ie
// the aim will be slow to react.
//
// ==============================================================================================


class "BotAim"

BotAim.reactionTime = 0.3

function BotAim:Initialize(owner)
    self.owner = owner
    self.target = nil
    self.lastTrackTime = Shared.GetTime()
    self.targetTrack = {}
end

function BotAim:Clear()
    self.target = nil
    self.lastTrackTime = Shared.GetTime()
    self.targetTrack = {}
end

function BotAim:UpdateAim(target, targetAimPoint)
    return BotAim_UpdateAim(self, target, targetAimPoint)
end

function BotAim_UpdateAim(self, target, targetAimPoint)
    local now = Shared.GetTime()
    if self.target ~= target or now - self.lastTrackTime > 0.3 then
        self.targetTrack = {}
        self.target = target
        -- Log("%s: Reset aim", self.owner)
    end
    self.lastTrackTime = now
    table.insert(self.targetTrack, { targetAimPoint, now, target} )
    local aimPoint = BotAim_GetAimPoint(self, now, targetAimPoint)
    // insert stuff like mouse movement, eye/hand coord etc - if required
    // ...
    self.owner:GetMotion():SetDesiredViewTarget( aimPoint )
    return aimPoint ~= nil
end

gBotDebug:AddBoolean("aim", false)

function BotAim_GetAimPoint(self, now, aimPoint)
    if gBotDebug:Get("aim") and gBotDebug:Get("spam") then
        Log("%s: getting aim point", self.owner)
    end

    while #self.targetTrack > 1 do
        -- search for a pair of tracks where the oldest is old enough for us to shoot from
        local p1, t1, target1 = unpack(self.targetTrack[1])
        local p2, t2, target2 = unpack(self.targetTrack[2])
               
        if target1 ~= target2 or now - t1 > BotAim.reactionTime + 0.1 or now - t2 > BotAim.reactionTime then
            -- t1 can't be used to shot on t2 due to different target
            -- OR t1 is uselessly old 
            -- OR we can use 2 because t2 is > reaction time
            table.remove(self.targetTrack, 1)
        else
            -- .. ending up here with [ (reactionTime + 0.1) > t1 > reactionTime > t2 ]
            local dt = now - t1
            if dt > BotAim.reactionTime then
                local mt = t2 - t1
                if mt > 0 then
                    local movementVector = (p2 - p1) / mt
                    local speed = movementVector:GetLength()
                    local result = p1 + movementVector * dt
                    local delta = result - aimPoint
                    if gBotDebug:Get("aim") then
                        Log("%s: Aiming at %s, off by %s, speed %s (%s tracks)", self.owner, target1, delta:GetLength(), speed, #self.targetTrack)
                    end
                    return result
                end
            end
            if gBotDebug:Get("aim") and gBotDebug:Get("spam") then
                Log("%s: waiting for reaction time", self.owner)
            end
            return null
        end
    end
    if gBotDebug:Get("aim") and gBotDebug:Get("spam") then
        Log("%s: no target", self.owner)
    end
    return nil
end

if Server then
Event.Hook("Console_bot_reactiontime", function(client, arg)
        if arg then
            BotAim.reactionTime = tonumber(arg)
        end
        Print("bot aim reaction time = %f", BotAim.reactionTime )
    end)
end

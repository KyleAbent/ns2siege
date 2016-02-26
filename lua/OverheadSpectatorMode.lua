// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\OverheadSpectatorMode.lua
//
// Created by: Marc Delorme (marc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/SpectatorMode.lua")

if Client then
    Script.Load("lua/GUIManager.lua")
end

class 'OverheadSpectatorMode' (SpectatorMode)

OverheadSpectatorMode.name = "Overhead"

// these are calibrated on Kodiak, maximum zoom-out, maximum height diff
local kSpectatorRelevancyOriginOffset = Vector(25,0,0) // adjust forward 
local kSpectatorRelevancyRangeOffset = 35 // and increase range

function OverheadSpectatorMode:Initialize(spectator)

    spectator:SetOverheadMoveEnabled(true)
    
    spectator:SetDesiredCamera( 0.3, { follow = true })
    
    // Set Overhead view angle.
    local overheadAngle = Angles((70 / 180) * math.pi, (90 / 180) * math.pi, 0)
    spectator:SetBaseViewAngles(Angles(0, 0, 0))
    spectator:SetViewAngles(overheadAngle)
    if Server then
        
        self:ConfigOverheadRelevancy(spectator)

    elseif Client and spectator == Client.GetLocalPlayer() then
    
        GetGUIManager():CreateGUIScriptSingle("GUIInsight_Overhead")
        MouseTracker_SetIsVisible(true, nil, true)
        
        SetCommanderPropState(true)
        SetSkyboxDrawState(false)
        Client.SetSoundGeometryEnabled(false)
        
        SetLocalPlayerIsOverhead(true)
        
        Client.SetPitch(overheadAngle.pitch)
        Client.SetYaw(overheadAngle.yaw)
        
    end
    
end

function OverheadSpectatorMode:Uninitialize(spectator)

    spectator:SetOverheadMoveEnabled(false)
    
    spectator:SetDesiredCamera( 0.3, { follow = true })
    local position = spectator:GetOrigin()
    
    -- Pick a height to set the spectator at
    -- Either a raytrace to the ground (better value)
    -- Or use the heightmap if the ray goes off the map
    local trace = GetCommanderPickTarget(spectator, spectator:GetOrigin(), true, false, false)
    local traceHeight = trace.endPoint.y
    local mapHeight = GetHeightmap():GetElevation(position.x, position.z) - 8
    
    -- Assume the trace is off the map if it's far from the heightmap
    -- Is there a better way to test this?
    local traceOffMap = math.abs(traceHeight-mapHeight) > 15
    local bestHeight = ConditionalValue(traceOffMap, mapHeight, traceHeight)
    position.y = bestHeight
    
    local viewAngles = spectator:GetViewAngles()
    viewAngles.pitch = 0
    spectator:SetOrigin(position)
    spectator:SetViewAngles(viewAngles)
    
    if Server then
    
        spectator:ConfigureRelevancy(Vector.origin, 0)    

    elseif Client then
    
        GetGUIManager():DestroyGUIScriptSingle("GUIInsight_Overhead")
        MouseTracker_SetIsVisible(false)
        
        SetCommanderPropState(false)
        SetSkyboxDrawState(true)
        Client.SetSoundGeometryEnabled(true)
        
        SetLocalPlayerIsOverhead(false)
        
        Client.SetPitch(viewAngles.pitch)
       
    end
    
end

function OverheadSpectatorMode:ConfigOverheadRelevancy(spectator)
            
    spectator:ConfigureRelevancy(kSpectatorRelevancyOriginOffset, kSpectatorRelevancyRangeOffset) 
   
end

if Server then

// for calibrating
function OnSpecRelevancy(client, range, xoffset)
    local player = client:GetPlayer()
    if player:isa("Spectator") then
        local specMode = player:GetSpectatorMode()
        if specMode:isa("OverheadSpectatorMode") then
            range = range or kSpectatorRelevancyRangeOffset
            xoffset = xoffset or kSpectatorRelevancyOriginOffset.x
            kSpectatorRelevancyRangeOffset = tonumber(range)
            kSpectatorRelevancyOriginOffset = Vector(tonumber(xoffset), 0, 0)
            specMode:ConfigOverheadRelevancy(player)
            Log("%s spectator mode relevancy range/origin.x offset : %s / %s", player, kSpectatorRelevancyRangeOffset, kSpectatorRelevancyOriginOffset.x)
        else
            Log("Wrong mode")
        end
    else
        Log("%s is not a spectator", player)
    end
end

Event.Hook("Console_spec_rel", OnSpecRelevancy)
end
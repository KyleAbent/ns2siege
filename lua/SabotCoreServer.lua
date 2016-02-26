// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\SabotCoreServer.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================   

Script.Load("lua/Utility.lua")
Script.Load("lua/Sabot.lua")
 
local gLastUpdate = 0
local gIsGatherReady = false
local gPassword = nil

local kPollTimeOut = 60
local kPollFrequency = 0.1

function Server.GetIsGatherReady()
    return gIsGatherReady
end    

local function UpdateGatherServer()

    if gLastUpdate + 5 < Shared.GetTime() then  
    
        gIsGatherReady = false
    
        local tags = { }
        Server.GetTags(tags)
        for t = 1, #tags do
        
            if string.find(tags[t], "gather_server") then
            
                gIsGatherReady = true
                break
                
            end
            
        end
        
        if gIsGatherReady then
      
            Sabot.RequestServerConfig()
            
            local settings = Sabot.GetServerSettings()  
            
            if gPassword ~= settings.password and settings.password ~= "" then
                Server.SetPassword(settings.password or "")
                Print("sabot changed password to %s, old one was %s", ToString(settings.password), ToString(gPassword))
            end
            
            if Shared.GetMapName() ~= settings.mapName and settings.mapName ~= "" and settings.mapName ~= nil then
                local success = MapCycle_ChangeMap(settings.mapName)
                Print("sabot %s map to %s, old one was %s", success and "changing" or "failed to change", ToString(settings.mapName), ToString(Shared.GetMapName()))
            end

        end
        
        gLastUpdate = Shared.GetTime() 
        
    end

end

Event.Hook("UpdateServer", UpdateGatherServer)
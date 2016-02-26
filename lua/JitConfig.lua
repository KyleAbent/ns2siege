// ======= Copyright (c) 2014, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\JitConfig.lua
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ConfigFileUtility.lua")

// How often to check/save jit params
local kUpdateRate = 5

// The last time key value pairs were updated.
local lastUpdateTime = 0


// on the server, we save in ServerConfig.json
// on the client, we save in options.xml (system/jit)

local JitConfig = {} 

if Server then
    JitConfig.Save = function(maxtrace, maxmcode)
        Server.SetConfigSetting("jit_maxtrace", maxtrace)
        Server.SetConfigSetting("jit_maxmcode", maxmcode)
        Server.SaveConfigSettings()
    end

    JitConfig.Get = function()
    // defaults for server set in ServerConfig.lua
	local maxtrace, maxmcode = Server.GetConfigSetting("jit_maxtrace"), Server.GetConfigSetting("jit_maxmcode")

	return maxtrace, maxmcode
    end

elseif Client then

    // Found through testing
    JitConfig.defaultMaxtrace = 9000
    JitConfig.defaultMaxmcode = 16000

    JitConfig.Save = function(maxtrace, maxmcode)
        Client.SetOptionInteger("system/jit/maxtrace", maxtrace)
        Client.SetOptionInteger("system/jit/maxmcode", maxmcode)    
    end

    JitConfig.Get = function()
        return Client.GetOptionInteger("system/jit/maxtrace", JitConfig.defaultMaxtrace), Client.GetOptionInteger("system/jit/maxmcode", JitConfig.defaultMaxmcode)
    end

end

local function UpdateConfig()
    if Client then Client.SetDebugText("JitConfig.OnUpdateClient entry") end
    if Shared.GetSystemTime() - lastUpdateTime >= kUpdateRate then

        // Persist any changed jit values
        local maxtrace = Shared.GetJitParam("maxtrace")
        local maxmcode = Shared.GetJitParam("maxmcode")
        local oldMaxtrace,oldMaxmcode = JitConfig.Get("jit_maxtrace") 
        if maxtrace ~= oldMaxtrace or maxmcode ~= oldMaxmcode then
            JitConfig.Save(maxtrace, maxmcode)
            Log("INFO: Adjusting LuaJIT settings: maxtrace %s(%s), maxmcode %s(%s)", maxtrace, oldMaxtrace, maxmcode, oldMaxmcode)
        end
                  
    end
    if Client then Client.SetDebugText("JitConfig.OnUpdateClient exit") end
end

local function UpdateJitParams()
  
    local maxtrace, maxmcode = JitConfig.Get()
    Shared.SetJitParam("maxtrace", maxtrace)
    Shared.SetJitParam("maxmcode", maxmcode)
    Log("INFO: LuaJIT setup: maxtrace=%s, maxmcode=%s", Shared.GetJitParam("maxtrace"), Shared.GetJitParam("maxmcode"))
    
end


if Server then

    // the server can update the JIT right away
    UpdateJitParams()
    Event.Hook("UpdateServer", UpdateConfig)

elseif Client then

    // ... the client needs to wait until the options.xml file is available 
    // (for some reason, the GetOptionInteger is defined in ClientLoaded and not Client)
    Event.Hook("LoadComplete", UpdateJitParams)
    Event.Hook("UpdateClient", UpdateConfig, "JitConfig")

end

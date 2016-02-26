
local jit = require("jit")

local jitParams = {

    maxtrace = true,
    maxrecord = true,
    maxirconst = true,
    maxside = true,
    maxsnap = true,
    
    hotloop = true,
    hotexit = true,
    tryside = true,
    
    instunroll = true,
    loopunroll = true,
    callunroll = true,
    recunroll = true,
    tailunroll = true,

    sizemcode = true,
    maxmcode = true,  
}

local function ProcessCommand(cmd, arg)
    
    if(not jit) then
        Print("jit: Error cant use jit console commands because LuaJIT is not loaded")
        return
    end
    
    cmd = cmd or "status"
    
    if(cmd == "flush") then
        
        jit.flush()
        Print("jit: machine code flushed")
        
    elseif(cmd == "on") then
        
        jit.on()
        Print("jit: JIT is now enabled")
        
    elseif(cmd == "fo") then
        
        jit.flush()
        jit.off()
        Print("jit: machine code flushed and jit turned off")
        
    elseif(cmd == "off") then
        
        jit.off()
        Print("jit: JIT is now disabled")
        
    elseif(cmd == "status") then
        
        Print("JIT Status: "..((jit.status() and "On") or "Off"))
        
    elseif(jitParams[cmd]) then
        
        if(not arg or arg == "") then
            Print("jit: Error a value needs to be specifed to set a jit paramamter "..cmd)
            return
        end
        
        jit.opt.start(cmd.."="..arg)
        Print("jit: jit parameter %s set to %s", cmd, arg)
        
    else

        Print("jit: Unknown command "..cmd)
    end
end




if(Client) then
    
    Event.Hook("Console_cjit", function(cmd, arg) 
        ProcessCommand(cmd, arg)
    end)
    
else
    
    Event.Hook("Console_sjit", function(client, cmd, arg, arg2) 
    
        if(client == nil or Shared.GetCheatsEnabled()) then
           ProcessCommand(cmd, arg) 
        end
    end)
end

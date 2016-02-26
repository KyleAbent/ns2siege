/**
 * Syncrhonizes the render settings on the camera with the stored render options
 */
function Render_SyncRenderOptions()

    local ambientOcclusion  = Client.GetOptionString("graphics/display/ambient-occlusion", "off")
    local atmospherics      = Client.GetOptionBoolean("graphics/display/atmospherics", true)
    local bloom             = Client.GetOptionBoolean("graphics/display/bloom_new", false)
    local shadows           = Client.GetOptionBoolean("graphics/display/shadows", true)
    local antiAliasing      = Client.GetOptionBoolean("graphics/display/anti-aliasing", true)
    local fog               = Client.GetOptionBoolean("graphics/display/fog", false)
    local particleQuality   = Client.GetOptionString("graphics/display/particles", "low")
    local reflections       = Client.GetOptionBoolean("graphics/reflections", false)
    local gammaAdjustment   = Clamp(Client.GetOptionFloat("graphics/display/gamma", Client.DefaultRenderGammaAdjustment), Client.MinRenderGamma , Client.MaxRenderGamma)

    Client.SetRenderSetting("mode", "lit")
    Client.SetRenderSetting("ambient_occlusion", ambientOcclusion)
    Client.SetRenderSetting("atmospherics", ToString(atmospherics))
    Client.SetRenderSetting("bloom"  , ToString(bloom))
    Client.SetRenderSetting("shadows", ToString(shadows))
    Client.SetRenderSetting("anti_aliasing", ToString(antiAliasing))
    Client.SetRenderSetting("fog", ToString(fog))
    Client.SetRenderSetting("particles", particleQuality)
    Client.SetRenderSetting("reflections", ToString(reflections))
    Client.SetRenderGammaAdjustment(gammaAdjustment)

end

local function RenderConsoleHandler(name, key)
    return function (enabled)
        if enabled == nil then
            enabled = "true"
        end
        Client.SetRenderSetting(name, ToString(enabled))
        Client.SetOptionBoolean(key, enabled == "true")
    end
end

local function RenderConsoleIntegerHandler(name, key)
    return function (int)
        if int == nil then
            int = 50
        end
        Client.SetRenderSetting(key, tonumber(int))
        Client.SetOptionInteger(key, tonumber(int))
        Render_SyncRenderOptions()
    end
end

local function RenderConsoleGammaHandler()

end

local function OnConsoleRenderMode(mode)
    if Shared.GetCheatsEnabled() or Shared.GetTestsEnabled() then
        if mode == nil then
            mode = "lit"
        end
        Client.SetRenderSetting("mode", mode)
    end
end

Client.ClearTextureLoadRules()
Client.AddTextureLoadRule("*_spec.dds", 1)  // Load all specular maps at 1/2 resolution
Client.AddTextureLoadRule("ui/*.*", -100)   // Don't reduce resolution on UI textures

Event.Hook("Console_r_mode",            OnConsoleRenderMode )
Event.Hook("Console_r_shadows",         RenderConsoleHandler("shadows", "graphics/display/shadows") )
Event.Hook("Console_r_ao",              RenderConsoleHandler("ambient_occlusion", "graphics/display/ambient-occlusion") )
Event.Hook("Console_r_atmospherics",    RenderConsoleHandler("atmospherics", "graphics/display/atmospherics") )
Event.Hook("Console_r_aa",              RenderConsoleHandler("anti_aliasing", "graphics/display/anti-aliasing") )
Event.Hook("Console_r_bloom",           RenderConsoleHandler("bloom", "graphics/display/bloom_new") )
Event.Hook("Console_r_fog",             RenderConsoleHandler("fog", "graphics/display/fog") )
Event.Hook("Console_r_glass",           RenderConsoleHandler("glass", "graphics/display/glass") )

Event.Hook("Console_r_gamma",              
    function (arg)
        if arg == nil then
            arg = Client.DefaultGammaAdjustment
        end

        local num = Clamp(tonumber(arg), Client.MinRenderGamma, Client.MaxRenderGamma)

        Shared.Message(string.format("Gamma changed to %.1f", num))

        Client.SetOptionFloat("graphics/display/gamma", num)
        Client.SetRenderGammaAdjustment(num)
        Render_SyncRenderOptions()
    end )

Event.Hook("Console_r_pq",
    function(arg)
        if arg == "high" then
            Client.SetRenderSetting("particles", "high")
            Client.SetOptionString("graphics/display/particles", "high")
        else
            Client.SetRenderSetting("particles", "low")
            Client.SetOptionString("graphics/display/particles", "low")
        end
    end )


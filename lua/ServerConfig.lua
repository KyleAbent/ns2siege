-- ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
--
-- lua\ServerConfig.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http:\\www.unknownworlds.com =====================

Script.Load("lua/ConfigFileUtility.lua")

-- How often to update key/value pairs on the server.
local kKeyValueUpdateRate = 5

-- The last time key value pairs were updated.
local lastKeyValueUpdateTime = 0

local configFileName = "ServerConfig.json"

local defaultConfig = {
                        settings =
                            {
                                rookie_friendly = true,
                                force_even_teams_on_join = true,
                                auto_team_balance = {
                                    enabled = true,
                                    enabled_on_unbalance_amount = 2,
                                    enabled_after_seconds = 10
                                },
                                end_round_on_team_unbalance = 0.4,
                                end_round_on_team_unbalance_check_after_time = 300,
                                end_round_on_team_unbalance_after_warning_time = 30,
                                auto_kick_afk_time = 300,
                                auto_kick_afk_capacity = 0.5,
                                voting = { 
                                    votekickplayer = true, 
                                    votechangemap = true, 
                                    voteresetgame = true, 
                                    votegagplayer = true,
                                    voterandomizerr = true, 
                                    votingforceeventeams = true  
                                },
                                alltalk = false,
                                pregamealltalk = false,
                                hiveranking = true,
                                use_own_consistency_config = false,
                                jit_maxmcode=35000,
                                jit_maxtrace=20000,
                                mod_backup_servers = {},
                                mod_backup_before_steam = false,
                            },
                        tags = { "rookie" }
                      }

local config = LoadConfigFile(configFileName, defaultConfig, true)
Server.SetModBackupServers(config.settings.mod_backup_servers, config.settings.mod_backup_before_steam)

local reservedSlotsConfigFileName = "ReservedSlotsConfig.json"
local reservedSlotsDefaultConfig = { 
    amount = 0, 
    ids = { }
}
local reservedSlotsConfig = LoadConfigFile(reservedSlotsConfigFileName, reservedSlotsDefaultConfig)

-- Add the tags to the server if they exist in the file.
if config.tags then

    for t = 1, #config.tags do
    
        if not type(config.tags[t]) == "string" then
            Shared.Message("Warning: Tags in " .. configFileName .. " must be strings")
        else
            Server.AddTag(config.tags[t])
        end
        
    end
    
end



function Server.GetConfigSetting(name)

    if config.settings then
        return config.settings[name]
    end
    return nil
    
end

function Server.GetHasTag(tag)

    for i = 1, #config.tags do
        if config.tags[i] == tag then
            return true
        end
    end

    return false

end

function Server.GetIsRookieFriendly()
    return Server.GetHasTag("rookie")
end

--[[
 * This can be used to override a setting. This will
 * not be saved to the config setting.
]]
function Server.SetConfigSetting(name, setting)
    config.settings[name] = setting
end

function Server.SaveConfigSettings()
    SaveConfigFile(configFileName, config)
end

function Server.GetReservedSlotsConfig()
    return reservedSlotsConfig
end

function Server.SaveReservedSlotsConfig()
    SaveConfigFile(reservedSlotsConfigFileName, reservedSlotsConfig)
end

--[[
 * This function should be called once per tick. It will update continuous data
]]
local function UpdateServerConfig()

    if Shared.GetSystemTime() - lastKeyValueUpdateTime >= kKeyValueUpdateRate then

        -- This isn't used by the server browser, but it is used by stats monitoring systems    
        Server.SetKeyValue("tickrate", ToString(math.floor(Server.GetFrameRate())))
        Server.SetKeyValue("ent_count", ToString(Shared.GetEntitiesWithClassname("Entity"):GetSize()))
        lastKeyValueUpdateTime = Shared.GetSystemTime()
             
    end
    
end


Event.Hook("UpdateServer", UpdateServerConfig)


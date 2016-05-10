kTeamMessageTypes = enum({ 'GameStarted', 'PowerLost', 'PowerRestored',  'CannotSpawn',
                           'SpawningWait', 'Spawning', 'ResearchComplete', 'ResearchLost',
                           'HiveConstructed', 'HiveUnderAttack', 'HiveLowHealth', 'HiveKilled',
                           'CommandStationUnderAttack', 'IPUnderAttack',
                            'SideDoor', 'FrontDoor', 'SiegeDoor', 'TeamsBalanced', 'TeamsUnbalanced', 
                           'SuddenDeath', 'ZedTimeBegin', 'ZedTimeEnd', 'Weapons1Researching', 'Weapons2Researching', 
                           'Weapons3Researching', 'Armor1Researching',   'Armor2Researching', 'Armor3Researching', 'MainRoom', 
                           'SiegeTime', 'KingCystLocation', 'PhaseCannonLocation', 'Beacon', })

local kTeamMessages = { }

kTeamMessages[kTeamMessageTypes.GameStarted] = { text = { [kMarineTeamType] = "Defend Until Siege Opens", [kAlienTeamType] = "Take Out Marines Before Siege Opens" } }

// This function will generate the string to display based on a location Id.
local locationStringGen = function(locationId, messageString) return string.format(Locale.ResolveString(messageString), Shared.GetString(locationId)) end

// Thos function will generate the string to display based on a research Id.
local researchStringGen = function(researchId, messageString) return string.format(Locale.ResolveString(messageString), GetDisplayNameForTechId(researchId)) end

kTeamMessages[kTeamMessageTypes.KingCystLocation] = { text = { [kAlienTeamType] = function(data) return locationStringGen(data, "King Cyst Grown in %s") end } }

kTeamMessages[kTeamMessageTypes.PhaseCannonLocation] = { text = { [kAlienTeamType] = function(data) return locationStringGen(data, "Phase Cannons activated in %s") end } }

kTeamMessages[kTeamMessageTypes.Beacon] = { text = { [kMarineTeamType] = function(data) return locationStringGen(data, "BEACON_TO") end } }
                                              
kTeamMessages[kTeamMessageTypes.MainRoom] = { text = { [kMarineTeamType] = function(data) return locationStringGen(data, "%s is Main Room") end,
                                                       [kAlienTeamType] = function(data) return locationStringGen(data, "%s is Main Room") end } }
                                                       
kTeamMessages[kTeamMessageTypes.SiegeTime] = { text = { [kMarineTeamType] = function(data) return locationStringGen(data, "Siege timer adjusted") end,
                                                       [kAlienTeamType] = function(data) return locationStringGen(data, "Siege timer adjusted") end } }

kTeamMessages[kTeamMessageTypes.PowerLost] = { text = { [kMarineTeamType] = function(data) return locationStringGen(data, "POWER_LOST") end } }

kTeamMessages[kTeamMessageTypes.PowerRestored] = { text = { [kMarineTeamType] = function(data) return locationStringGen(data, "POWER_RESTORED") end } }

kTeamMessages[kTeamMessageTypes.CannotSpawn] = { text = { [kMarineTeamType] = "NO_IPS" } }

kTeamMessages[kTeamMessageTypes.SpawningWait] = { text = { [kAlienTeamType] = "WAITING_TO_SPAWN" } }

kTeamMessages[kTeamMessageTypes.Spawning] = { text = { [kMarineTeamType] = "SPAWNING", [kAlienTeamType] = "SPAWNING" } }

kTeamMessages[kTeamMessageTypes.ResearchComplete] = { text = { [kAlienTeamType] = function(data) return researchStringGen(data, "EVOLUTION_AVAILABLE") end } }

kTeamMessages[kTeamMessageTypes.ResearchLost] = { text = { [kAlienTeamType] = function(data) return researchStringGen(data, "EVOLUTION_LOST") end } }

kTeamMessages[kTeamMessageTypes.HiveConstructed] = { text = { [kAlienTeamType] = function(data) return locationStringGen(data, "HIVE_CONSTRUCTED") end } }

kTeamMessages[kTeamMessageTypes.HiveLowHealth] = { text = { [kMarineTeamType] = function(data) return locationStringGen(data, "HIVE_LOW_HEALTH") end,
                                                            [kAlienTeamType] = function(data) return locationStringGen(data, "HIVE_LOW_HEALTH") end } }

kTeamMessages[kTeamMessageTypes.HiveKilled] = { text = { [kMarineTeamType] = function(data) return locationStringGen(data, "HIVE_KILLED") end,
                                                         [kAlienTeamType] = function(data) return locationStringGen(data, "HIVE_KILLED") end } }

kTeamMessages[kTeamMessageTypes.CommandStationUnderAttack] = { text = { [kMarineTeamType] = function(data) return locationStringGen(data, "COMM_STATION_UNDER_ATTACK") end } }

kTeamMessages[kTeamMessageTypes.IPUnderAttack] = { text = { [kMarineTeamType] = function(data) return locationStringGen(data, "IP_UNDER_ATTACK") end } }

kTeamMessages[kTeamMessageTypes.HiveUnderAttack] = { text = { [kAlienTeamType] = function(data) return locationStringGen(data, "HIVE_UNDER_ATTACK") end } }

kTeamMessages[kTeamMessageTypes.FrontDoor] = { text = { [kMarineTeamType] = "FrontDoor Now Open ", [kAlienTeamType] = "FrontDoor Now Open" } }

kTeamMessages[kTeamMessageTypes.SiegeDoor] = { text = { [kMarineTeamType] = "SiegeDoor Now Open ", [kAlienTeamType] = "SiegeDoor Now Open" } }

kTeamMessages[kTeamMessageTypes.SuddenDeath] = { text = { [kMarineTeamType] = "SuddenDeath Now Enabled ", [kAlienTeamType] = "SuddenDeath Now Enabled" } }

kTeamMessages[kTeamMessageTypes.ZedTimeBegin] = { text = { [kMarineTeamType] = "Slow Motion Activated", [kAlienTeamType] = "Slow Motion Activated" } }

kTeamMessages[kTeamMessageTypes.ZedTimeEnd] = { text = { [kMarineTeamType] = "Slow Motion Deactivated", [kAlienTeamType] = "Slow Motion Deactivated" } }

kTeamMessages[kTeamMessageTypes.TeamsUnbalanced] = { text = { [kMarineTeamType] = "TEAMS_UNBALANCED", [kAlienTeamType] = "TEAMS_UNBALANCED" } }

kTeamMessages[kTeamMessageTypes.TeamsBalanced] = { text = { [kMarineTeamType] = "TEAMS_BALANCED", [kAlienTeamType] = "TEAMS_BALANCED" } }

kTeamMessages[kTeamMessageTypes.Weapons1Researching] = { text = { [kMarineTeamType] = "Weapons 1 Researching", [kAlienTeamType] = "nil" } }
kTeamMessages[kTeamMessageTypes.Weapons2Researching] = { text = { [kMarineTeamType] = "Weapons 2 Researching", [kAlienTeamType] = "nil" } }
kTeamMessages[kTeamMessageTypes.Weapons3Researching] = { text = { [kMarineTeamType] = "Weapons 3 Researching", [kAlienTeamType] = "nil" } }

kTeamMessages[kTeamMessageTypes.Armor1Researching] = { text = { [kMarineTeamType] = "Armor 1 Researching", [kAlienTeamType] = "nil" } }
kTeamMessages[kTeamMessageTypes.Armor2Researching] = { text = { [kMarineTeamType] = "Armor 2 Researching", [kAlienTeamType] = "nil" } }
kTeamMessages[kTeamMessageTypes.Armor3Researching] = { text = { [kMarineTeamType] = "Armor 3 Researching", [kAlienTeamType] = "nil" } }

// Silly name but it fits the convention.
local kTeamMessageMessage =
{
    type = "enum kTeamMessageTypes",
    data = "integer"
}

Shared.RegisterNetworkMessage("TeamMessage", kTeamMessageMessage)

if Server then

    /**
     * Sends every team the passed in message for display.
     */
    function SendGlobalMessage(messageType, optionalData)
    
        if GetGamerules():GetGameStarted() then
        
            local teams = GetGamerules():GetTeams()
            for t = 1, #teams do
                SendTeamMessage(teams[t], messageType, optionalData)
            end
            
        end
        
    end
    
    /**
     * Sends every player on the passed in team the passed in message for display.
     */
    function SendTeamMessage(team, messageType, optionalData)
    
        local function SendToPlayer(player)
            Server.SendNetworkMessage(player, "TeamMessage", { type = messageType, data = optionalData or 0 }, true)
        end
        
        team:ForEachPlayer(SendToPlayer)
        
    end
    
    /**
     * Sends the passed in message to the players passed in.
     */
    function SendPlayersMessage(playerList, messageType, optionalData)
    
        if GetGamerules():GetGameStarted() then
        
            for p = 1, #playerList do
                Server.SendNetworkMessage(playerList[p], "TeamMessage", { type = messageType, data = optionalData or 0 }, true)
            end
            
        end
        
    end
    
    local function TestTeamMessage(client)
    
        local player = client:GetControllingPlayer()
        if player then
            SendPlayersMessage({ player }, kTeamMessageTypes.NoCommander)
        end
        
    end
    
    Event.Hook("Console_ttm", TestTeamMessage)
    
end

if Client then

    local function SetTeamMessage(messageType, messageData)
    
        local player = Client.GetLocalPlayer()
        if player and HasMixin(player, "TeamMessage") then
        
            if Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full then
        
                local displayText = kTeamMessages[messageType].text[player:GetTeamType()]
                
                if displayText then
                
                    if type(displayText) == "function" then
                        displayText = displayText(messageData)
                    else
                        displayText = Locale.ResolveString(displayText)
                    end
                    
                    assert(type(displayText) == "string")
                    player:SetTeamMessage(string.UTF8Upper(displayText))
                    
                end
            
            end
            
        end
        
    end
    
    function OnCommandTeamMessage(message)
        SetTeamMessage(message.type, message.data)
    end
    
    Client.HookNetworkMessage("TeamMessage", OnCommandTeamMessage)
    
end
Script.Load("lua/Badges_Shared.lua")

local ClientId2Badges = {}

local ClientIdDevs = {}

function Badges_HasDevBadge(userId)
    return ClientIdDevs[userId]
end

function Badges_SetBadges( clientid, badges )

    local client = Server.GetClientById(clientid)
    if not client then return end

    -- Build reverse table.
    local ownedBadges = { }
    if badges then

        for i,name in ipairs(badges) do
            ownedBadges[name] = i
        end

    end

    local msg = { clientId = clientid }

    -- Go through each badge to see if the client has it
    for _,info in ipairs(gBadgesData) do

        local hasBadge
        if info.productId then
            hasBadge = GetHasDLC(info.productId, client) and 10 or -1
        else
            hasBadge = ownedBadges[info.name] or -1
        end
        msg[Badge2NetworkVarName(info.name)] = hasBadge

        if (info.name == "dev" or info.name == "community_dev") and hasBadge > 0 then
            ClientIdDevs[client:GetUserId()] = true
        end

    end

    -- Send badge info update to all players (including the one who just connected)
    Server.SendNetworkMessage("ClientBadges", msg, true)

    -- Store it ourselves as well for future clients
    ClientId2Badges[ clientid ] = msg
end

local function OnClientConnect(client)
    if not client or client:GetIsVirtual() then return end

    -- Send this client the badge info for all existing clients
    for _, msg in pairs(ClientId2Badges) do
        Server.SendNetworkMessage( client, "ClientBadges", msg, true )
    end
    
end

local function OnClientDisconnect(client)
    if not client or client:GetIsVirtual() then return end

    ClientId2Badges[ client:GetId() ] = nil
end

Event.Hook("ClientConnect", OnClientConnect)
Event.Hook("ClientDisconnect", OnClientDisconnect)

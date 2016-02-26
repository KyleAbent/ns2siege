Script.Load("lua/Badges_Shared.lua")

local ClientId2Badges = {}

Client.HookNetworkMessage("ClientBadges",
    function(msg) 
        //Print("received ClientBadges msg for client id = "..msg.clientId.." msg = "..ToString(msg) )
        ClientId2Badges[ msg.clientId ] = msg
    end)

local textures = {}
local badgeNames = {}
function Badges_GetBadgeTextures( clientId, usecase )
    
    local badges = ClientId2Badges[clientId]
    
    if badges and textures[clientId] then
        return textures[clientId], badgeNames[clientId]
    elseif badges then
        textures[clientId] = {}
        badgeNames[clientId] = {}
        local tempTextures = {}
        local tempBadgeNames = {}
        local textureKey = (usecase == "scoreboard" and "scoreboardTexture" or "unitStatusTexture")
        
        for _, info in ipairs(gBadgesData) do
            local badgePosition = badges[ Badge2NetworkVarName(info.name) ]
            if badgePosition > 0 then
                tempTextures[badgePosition] = info[textureKey]
                tempBadgeNames[badgePosition] = info.name
            end
        end
        
        for pos, texture in pairs(tempTextures) do
            table.insert(textures[clientId], texture)
            table.insert(badgeNames[clientId], tempBadgeNames[pos])
        end
        
        return textures[clientId], badgeNames[clientId]
        
    else
        return {}, {}
    end

end
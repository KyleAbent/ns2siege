// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/MapBlip.lua
//
// MapBlips are displayed on player minimaps based on relevancy.
//
// Created by Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/MinimapMappableMixin.lua")

class 'MapBlip' (Entity)

MapBlip.kMapName = "MapBlip"

local networkVars =
{
    // replace m_origin with a less precise version lacking y
    m_origin = "interpolated position (by 0.2 [2 3 5], by 1000 [0 0 0], by 0.2 [2 3 5])",
    // replace m_angles with a less precise version lacking roll and pitch (range is 0-2pi, -> 0.1 = 6 bits)
    m_angles = "interpolated angles (by 10 [0], by 0.1 [3], by 10 [0])",
    mapBlipType = "enum kMinimapBlipType",
    mapBlipTeam = "integer (" .. ToString(kTeamInvalid) .. " to " .. ToString(kSpectatorIndex) .. ")",
    isInCombat = "boolean",
    isParasited = "boolean",
    ownerEntityId = "entityid",
    isHallucination = "boolean",
    active = "boolean"
}

function MapBlip:OnCreate()

    Entity.OnCreate(self)
    
    // Prevent the engine from calling OnSynchronize or OnUpdate for improved performance
    // since we create a lot of map blips.
    self:SetUpdates(false)
    
    self:SetOrigin(Vector(0,0,0))
    self:SetAngles(Angles(0,0,0))
    self.mapBlipType = kMinimapBlipType.TechPoint
    self.mapBlipTeam = kTeamReadyRoom
    self.ownerEntityId = Entity.invalidId
    self.isInCombat = false
    self.isParasited = false
    
    self:UpdateRelevancy()
    
    if Client then
        InitMixin(self, MinimapMappableMixin)
    end
    
end



function MapBlip:UpdateRelevancy()

    self:SetRelevancyDistance(Math.infinity)
    
    local mask = 0

    if self.mapBlipTeam == kTeam1Index or self.mapBlipTeam == kTeamInvalid or self:GetIsSighted() then
        mask = bit.bor(mask, kRelevantToTeam1)
    end
    if self.mapBlipTeam == kTeam2Index or self.mapBlipTeam == kTeamInvalid or self:GetIsSighted() then
        mask = bit.bor(mask, kRelevantToTeam2)
    end
    
    self:SetExcludeRelevancyMask( mask )

end

function MapBlip:SetOwner(ownerId, blipType, blipTeam)

    self.ownerEntityId = ownerId
    self.mapBlipType = blipType
    self.mapBlipTeam = blipTeam
    
    self:Update()

end


function MapBlip:GetOwnerEntityId()

    return self.ownerEntityId

end

-- used by bot brains
function MapBlip:GetType()
    
    return self.mapBlipType

end

-- required by minimapmappable
function MapBlip:GetMapBlipType()

    return self.mapBlipType

end

function MapBlip:GetTeamNumber()

    return self.mapBlipTeam

end

function MapBlip:GetRotation()

    return self:GetAngles().yaw

end

function MapBlip:GetIsActive()
    return self.active
end

function MapBlip:GetIsSighted()

    local owner = Shared.GetEntity(self.ownerEntityId)
    
    if owner then
    
        if owner.GetTeamNumber and owner:GetTeamNumber() == kTeamReadyRoom and owner:GetAttached() then
            owner = owner:GetAttached()
        end
        
        return HasMixin(owner, "LOS") and owner:GetIsSighted() or false
        
    end
    
    return false
    
end

function MapBlip:GetIsInCombat()
    return self.isInCombat
end

function MapBlip:GetIsParasited()
    return self.isParasited
end

// Called (server side) when a mapblips owner has changed its map-blip dependent state
function MapBlip:Update()

    PROFILE("MapBlip:Update")

    if self.ownerEntityId and Shared.GetEntity(self.ownerEntityId) then
    
        local owner = Shared.GetEntity(self.ownerEntityId)
        
        local fowardNormal = owner:GetCoords().zAxis
        -- Don't rotate power nodes
        local yaw = ConditionalValue(owner:isa("PowerPoint"), 0, math.atan2(fowardNormal.x, fowardNormal.z))
        
        self:SetAngles(Angles(0, yaw, 0))
        
        local origin = nil        
        if owner.GetPositionForMinimap then
            origin = owner:GetPositionForMinimap()
        else
            origin = owner:GetOrigin()
        end
        
        if origin then
        
            // always use zero y-origin (for now, if you want to use it for long-range hivesight, add it back
            self:SetOrigin(Vector(origin.x, 0, origin.z))      
            
            self:UpdateRelevancy()
            
            local owner = Shared.GetEntity(self.ownerEntityId)
            
            if HasMixin(owner, "MapBlip") then
            
                local success, blipType, blipTeam, isInCombat, isParasited = owner:GetMapBlipInfo()

                self.mapBlipType = blipType
                self.mapBlipTeam = blipTeam
                self.isInCombat = isInCombat    
                self.isParasited = isParasited
                
            end 
            
            if owner:isa("Player") then
                self.clientIndex = owner:GetClientIndex()
            end 

            self.isHallucination = owner.isHallucination == true or owner:isa("Hallucination")
            
            self.active = GetIsUnitActive(owner)

        end
        
    end
    
end

function MapBlip:GetIsValid()

    local entity = Shared.GetEntity(self:GetOwnerEntityId())
    if entity == nil then
        return false
    end
    
    if entity.GetIsBlipValid then
        return entity:GetIsBlipValid()
    end
    
    return true
    
end

if Client then
    
    local kFastMoverTypes = {}
    kFastMoverTypes[kMinimapBlipType.Drifter] = true
    kFastMoverTypes[kMinimapBlipType.MAC]     = true
        
    
    function MapBlip:GetMapBlipColor(minimap, item)
        return self.currentMapBlipColor or Color()
    end
    
    function MapBlip:GetMapBlipTeam(minimap)
      
        local playerTeam = minimap.playerTeam
        local blipTeam = kMinimapBlipTeam.Neutral

        local blipTeamNumber = self:GetTeamNumber()
        local isSteamFriend = false
        
        if self.clientIndex and self.clientIndex > 0 and blipTeamNumber ~= GetEnemyTeamNumber(playerTeam) then

            local steamId = GetSteamIdForClientIndex(self.clientIndex)
            if steamId then
                isSteamFriend = Client.GetIsSteamFriend(steamId)
            end

        end
        
        if not self:GetIsActive() then

            if blipTeamNumber == kMarineTeamType then
                blipTeam = kMinimapBlipTeam.InactiveMarine
            elseif blipTeamNumber== kAlienTeamType then
                blipTeam = kMinimapBlipTeam.InactiveAlien
            end

        elseif isSteamFriend then
        
            if blipTeamNumber == kMarineTeamType then
                blipTeam = kMinimapBlipTeam.FriendMarine
            elseif blipTeamNumber== kAlienTeamType then
                blipTeam = kMinimapBlipTeam.FriendAlien
            end
        
        else

            if blipTeamNumber == kMarineTeamType then
                blipTeam = kMinimapBlipTeam.Marine
            elseif blipTeamNumber== kAlienTeamType then
                blipTeam = kMinimapBlipTeam.Alien
            end
            
        end  

        return blipTeam
    end
     
    function MapBlip:InitActivityDefaults()
        -- default; these usually don't move, and if they move they move slowly. They may be attacked though, and then they
        -- need to animate at a higher rate
        self.combatActivity = kMinimapActivity.Medium
        self.movingActivity = kMinimapActivity.Low
        self.defaultActivity = kMinimapActivity.Static
        
        local isFastMover = kFastMoverTypes[self.mapBlipType]
        
        if isFastMover then
            self.defaultActivity = kMinimapActivity.Low
            self.movingActivity = kMinimapActivity.Medium
        end
        
    end

    function MapBlip:UpdateMinimapActivity(minimap, item)
        if self.combatActivity == nil then
            self:InitActivityDefaults()
        end
        // type can change (see infestation)
        local blipType = self:GetMapBlipType()            
        // the blipTeam can change if power changes
        local blipTeam = self:GetMapBlipTeam(minimap)
        if blipType ~= item.blipType or blipTeam ~= item.blipTeam then
            item.resetMinimapItem = true
        end
        local origin = self:GetOrigin()
        local isMoving = item.prevOrigin ~= origin
        item.prevOrigin = origin
        local result = (self.isInCombat and self.combatActivity) or  
              (isMoving and self.movingActivity) or 
              self.defaultActivity
        if self.mapBlipType == kMinimapBlipType.Scan then
            // the scan blip are animating.
            // TODO: make a ScanMapBlip subclass and handle things there instead... right now, the animation is handled
            // by the GUIMinimap changing the blipsize for all scans at the same time... which looks slightly silly, but
            // multiple scans are not used all that much.
            item.resetMinimapItem = true
            return kMinimapActivity.High
        end
        return result
    end

    
    local blipRotation = Vector(0,0,0)
    function MapBlip:UpdateMinimapItemHook(minimap, item)

        PROFILE("MapBlip:UpdateMinimapItemHook")

        local rotation = self:GetRotation()
        if rotation ~= item.prevRotation then
            item.prevRotation = rotation
            blipRotation.z = rotation
            item:SetRotation(blipRotation)
        end
        local blipTeam = self:GetMapBlipTeam(minimap)
        local blipColor = item.blipColor
        
        if self.OnSameMinimapBlipTeam(minimap.playerTeam, blipTeam) or minimap.spectating then

            self:UpdateHook(minimap, item)
            
            if self.isHallucination then
                blipColor = kHallucinationColor
            elseif self.isInCombat then
                if self.MinimapBlipTeamIsActive(blipTeam) then
                    blipColor = self.PulseRed(1.0)
                else
                    blipColor = self.PulseDarkRed(blipColor)
                end
            end  
        end
        self.currentMapBlipColor = blipColor

    end
    
    function MapBlip:UpdateHook(minimap, item)
        -- empty; allow players to decorate with their names
    end

end -- Client


Shared.LinkClassToMap("MapBlip", MapBlip.kMapName, networkVars)

class 'PlayerMapBlip' (MapBlip)

PlayerMapBlip.kMapName = "PlayerMapBlip"

local playerNetworkVars =
{
    clientIndex = "entityid",
}

if Client then
      function PlayerMapBlip:InitActivityDefaults()
        self.isInCombatActivity = kMinimapActivity.Medium
        self.movingActivity = kMinimapActivity.Medium
        self.defaultActivity = kMinimapActivity.Medium
      end
 
    -- the local player has a special marker; do not show his mapblip 
    function PlayerMapBlip:UpdateMinimapActivity(minimap, item)
        if self.clientIndex == minimap.clientIndex then
            return nil
        end
        return MapBlip.UpdateMinimapActivity(self, minimap, item)
    end
    
    -- players can show their names on the minimap
    function PlayerMapBlip:UpdateHook(minimap, item)
        minimap:DrawMinimapName(item, self:GetMapBlipTeam(minimap), self.clientIndex, self.isParasited)
    end

end


Shared.LinkClassToMap("PlayerMapBlip", PlayerMapBlip.kMapName, playerNetworkVars)
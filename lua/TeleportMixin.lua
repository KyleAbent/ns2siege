// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\TeleportMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Teleports the entity with a delay to a destination entity. If the destination entity has an
//    active order it will spawn at the order location, unless it does not require to be attached.
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

TeleportMixin = CreateMixin(TeleportMixin)
TeleportMixin.type = "TeleportAble"

TeleportMixin.kDefaultDelay = 3
TeleportMixin.kMaxRange = 4.5
TeleportMixin.kMinRange = 1
TeleportMixin.kAttachRange = 15
TeleportMixin.kDefaultSinkin = 1.4

TeleportMixin.optionalCallbacks = {

    OnTeleport = "Called when teleport is triggered.",
    OnTeleportEnd = "Called when teleport is done.",
    GetCanTeleportOverride = "Return true/false to allow/prevent teleporting."
    
}

TeleportMixin.networkVars = {
 
    isTeleporting = "boolean",
    teleportDelay = "float",
    lastbeacontime = "time",
    
}

function TeleportMixin:__initmixin()

    self.maxCatalystStacks = TeleportMixin.kDefaultStacks

    if Client then
    
        self.clientIsTeleporting = false
        
    elseif Server then
    
        self.isTeleporting = false
        self.destinationEntityId = Entity.invalidId
        self.timeUntilPort = 0
        self.teleportDelay = 0
        self.lastbeacontime = Shared.GetTime()
        
    end
    
end

function TeleportMixin:GetTeleportSinkIn()

    if self.OverrideGetTeleportSinkin then
        return self:OverrideGetTeleportSinkin()
    end
    
    if HasMixin(self, "Extents") then
        return self:GetExtents().y * 2.5
    end    
    
    return TeleportMixin.kDefaultSinkin
    
end   
function TeleportMixin:GetEligableForBeacon(who)
local boolean = self:GetIsBuilt() and self:GetDistance(who) >= 2  and not self:GetHasOrder() 
return Shared.GetTime() > self.lastbeacontime  + kSBCooldown and boolean
end
function TeleportMixin:GetIsTeleporting()
    return self.isTeleporting
end

function TeleportMixin:GetCanTeleport()

    local canTeleport = true
    if self.GetCanTeleportOverride then
        canTeleport = self:GetCanTeleportOverride()
    end
    
    return canTeleport and not self.isTeleporting and not self:InRangeofBeacon()
    
end
function TeleportMixin:InRangeofBeacon()
      for _, veil in ipairs(GetEntitiesForTeamWithinRange("Veil", 2, self:GetOrigin(),  TeleportMixin.kMaxRange)) do
            if veil:GetIsBuilt() then
                return true
            end
        end
        return false
end
/**
 * Forbid the update of model coordinates while we teleport(?)
 */
function TeleportMixin:GetForbidModelCoordsUpdate()
    return self.isTeleporting
end

function TeleportMixin:UpdateTeleportClientEffects(deltaTime)

    if self.clientIsTeleporting ~= self.isTeleporting then
    
        self:TriggerEffects("teleport_start", { effecthostcoords = self:GetCoords(), classname = self:GetClassName() })
        self.clientIsTeleporting = self.isTeleporting
        self.clientTimeUntilPort = self.teleportDelay
        
    end
    
    local renderModel = self:GetRenderModel()
    
    if renderModel then
    
        self.clientTimeUntilPort = math.max(0, self.clientTimeUntilPort - deltaTime)

        local sinkCoords = self:GetCoords()
        local teleportFraction = 1 - (self.clientTimeUntilPort / self.teleportDelay)

        sinkCoords.origin = sinkCoords.origin - teleportFraction * self:GetTeleportSinkIn() * sinkCoords.yAxis
        renderModel:SetCoords(sinkCoords)

    end

end

local function GetAttachDestination(self, attachTo, destinationOrigin)

    local attachEntities = GetEntitiesWithinRange(attachTo, destinationOrigin, TeleportMixin.kAttachRange)
    
    for i=1,#attachEntities do
        local ent = attachEntities[i]
        if not ent:GetAttached() and GetInfestationRequirementsMet(self:GetTechId(), ent:GetOrigin()) then
            
            // free up old attached entity and attach to new
            local attached = self:GetAttached()
            
            attached:ClearAttached()
            self:ClearAttached()
            
            self:SetAttached(ent)
            
            local attachCoords = ent:GetCoords()
            attachCoords.origin.y = attachCoords.origin.y + LookupTechData(self:GetTechId(), kTechDataSpawnHeightOffset, 0)
            
            return attachCoords
            
        end
    end

end

local function GetRandomSpawn(entityid,destinationOrigin)
    local destinationEntity = Shared.GetEntity(entityid)
    local extents = Vector(1,1,1)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
     local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, destinationEntity:GetModelOrigin(), TeleportMixin.kMinRange, TeleportMixin.kMaxRange, EntityFilterAll())
        
        if spawnPoint ~= nil then
            spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
        end
    
            return spawnPoint
        

end

local function AddObstacle(self)

    if self.obstacleId == -1 then
        self:AddToMesh()
    end    
       
    return false
 
end

local function PerformTeleport(self)

    local destinationEntity = Shared.GetEntity(self.destinationEntityId)
    
    if destinationEntity then

        local destinationCoords = nil        
        local attachTo = LookupTechData(self:GetTechId(), kStructureAttachClass, nil)
        
        // find a free attach entity
        if attachTo then
            destinationCoords = GetAttachDestination(self, attachTo, self.destinationPos)
        else
            destinationCoords = Coords.GetTranslation(self.destinationPos)
        end
        
        if destinationCoords then

            if HasMixin(self, "Obstacle") then
                self:RemoveFromMesh()
            end
        
            self:SetCoords(destinationCoords)

            if HasMixin(self, "Obstacle") then
                // this needs to be delayed, otherwise the obstacle is created too early and stacked up structures would not be able to push each other away
                self:AddTimedCallback(AddObstacle, 3)
            end
            
            local location = GetLocationForPoint(self:GetOrigin())
            local locationName = location and location:GetName() or ""
            
            self:SetLocationName(locationName, true)
            
            self:TriggerEffects("teleport_end", { classname = self:GetClassName() })
            
            if self.OnTeleportEnd then
                self:OnTeleportEnd(destinationEntity)
            end
            
            if HasMixin(self, "StaticTarget") then
                self:StaticTargetMoved()
            end

        else
            // teleport has failed, give back resources to shift

            if destinationEntity then
                destinationEntity:GetTeam():AddTeamResources(self.teleportCost)
            end
        
        end
    
    end
    
    self.destinationEntityId = Entity.invalidId
    self.isTeleporting = false
    self.timeUntilPort = 0
    self.teleportDelay = 0

end 

local function SharedUpdate(self, deltaTime)

    if Server then
    
        if self.isTeleporting then 
  
            self.timeUntilPort = math.max(0, self.timeUntilPort - deltaTime)
            if self.timeUntilPort == 0 then
                PerformTeleport(self)
            end
            
        end
    
    elseif Client then
    
        if self.isTeleporting then        
            self:UpdateTeleportClientEffects(deltaTime)
         
        elseif self.clientIsTeleporting then        
            self.clientIsTeleporting = false            
        end 
        
    end


end

function TeleportMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end

function TeleportMixin:OnUpdate(deltaTime)
    PROFILE("TeleportMixin:OnUpdate")
    SharedUpdate(self, deltaTime)
end
function TeleportMixin:TriggerBeacon(location)
 local locationto = location

 self:AddTimedCallback(function()  self:TriggerEffects("blink_in") self:SetOrigin(locationto) self:TriggerEffects("blink_out")  end, math.random(0.1,4))
 self.lastbeacontime = Shared.GetTime()

end
function TeleportMixin:TriggerEggBeacon(location)
 local locationto = location

 self:AddTimedCallback(function() self:SetOrigin(locationto)  end, math.random(0.1,4))
 self.lastbeacontime = Shared.GetTime()

end
function TeleportMixin:TriggerTeleport(delay, destinationEntityId, destinationPos, cost)

    if Server then
    
        self.teleportDelay = ConditionalValue(delay, delay, TeleportMixin.kDefaultDelay)
        self.timeUntilPort = ConditionalValue(delay, delay, TeleportMixin.kDefaultDelay)
        self.destinationEntityId = destinationEntityId
        self.destinationPos = destinationPos
        self.isTeleporting = true
        self.teleportCost = cost
        
        //Print("%s:TriggerTeleport ", self:GetClassName())
        
        if self.OnTeleport then
            self:OnTeleport()
        end    
        
    end
    
end

function TeleportMixin:OnUpdateAnimationInput(modelMixin)

    modelMixin:SetAnimationInput("isTeleporting", self.isTeleporting)

end


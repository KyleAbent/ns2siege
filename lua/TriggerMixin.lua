// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//    
// lua\TriggerMixin.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

/**
 * TriggerMixin has callbacks for when another entity enters or exits a volume.
 */
TriggerMixin = { }
TriggerMixin.type = "Trigger"

TriggerMixin.optionalCallbacks =
{
    OnTriggerEntered = "First parameter is the entity that entered the trigger, second is self",
    OnTriggerExited = "First parameter is the entity that exited the trigger, second is self",
    GetTrackEntity = "Filter entities which enter the trigger but are not interesting to us. Return false to ignore the entity.",
    OnTriggerListChanged = "Called whenever the trigger list has changed (entity entered/exited the trigger)"
}

TriggerMixin.optionalConstants =
{
    kPhysicsGroup = "Pass physics groups.",
    kFilterMask = "Pass filter mask."
}

function TriggerMixin:__initmixin()
    self.insideTriggerEntities = { }
end

local function DestroyTrigger(self)

    if self.triggerBody then
    
        Shared.DestroyCollisionObject(self.triggerBody)
        self.triggerBody = nil
        
    end
    
end

function TriggerMixin:SetSphere(setRadius)

    DestroyTrigger(self)
    
    local coords = self:GetCoords()
    
    self.triggerBody = Shared.CreatePhysicsSphereBody(false, setRadius, 0, coords)
    self.triggerBody:SetTriggerEnabled(true)
    self.triggerBody:SetCollisionEnabled(true)
    
    if self:GetMixinConstants().kPhysicsGroup then
        //Print("set trigger physics group to %s", EnumToString(PhysicsGroup, self:GetMixinConstants().kPhysicsGroup))
        self.triggerBody:SetGroup(self:GetMixinConstants().kPhysicsGroup)
    end
    
    if self:GetMixinConstants().kFilterMask then
        //Print("set trigger filter mask to %s", EnumToString(PhysicsMask, self:GetMixinConstants().kFilterMask))
        self.triggerBody:SetGroupFilterMask(self:GetMixinConstants().kFilterMask)
    end
    
    self.triggerBody:SetEntity(self)
    
end

function TriggerMixin:SetBox(setExtents)

    DestroyTrigger(self)
    
    --[[
    Why multiply the extents by 0.2395?
    
    The editor uses a model and scales that for the triggers. The game takes the scale and assumes the
    model is a certain size, the problem before was that this assumed value caused big overlapping
    between entities, causing some issues in a few maps. We're going to use a more accurate value now.
    
    If we scale the location entity to a 1x1x1 meter box the scaling comes back as 2.089896 2.089893
    2.089889. Therefore, the extents size is (approx) 0.4785 for each side (they are not exactly equal in
    all sides). To make the extents accurate, we'd have to multiply by 0.23925, but we're going to make
    it overlap it slightly to cover potential issues.
    
    This "magic value" is also used in Location.lua for the Commander VFX for powered areas.
    
    Previously the game was using 0.25 for the volume size, and 0.23 for the visual representation.
    --]]
    
    local extents = setExtents * 0.2395
    local coords = self:GetAngles():GetCoords()
    coords.origin = Vector(self:GetOrigin())
    // The physics origin is at it's center
    coords.origin.y = coords.origin.y + extents.y
    
    self.triggerBody = Shared.CreatePhysicsBoxBody(false, extents, 0, coords)
    self.triggerBody:SetTriggerEnabled(true)
    self.triggerBody:SetCollisionEnabled(false)
    
    if self:GetMixinConstants().kPhysicsGroup then
        //Print("set trigger physics group to %s", EnumToString(PhysicsGroup, self:GetMixinConstants().kPhysicsGroup))
        self.triggerBody:SetGroup(self:GetMixinConstants().kPhysicsGroup)
    end
    
    if self:GetMixinConstants().kFilterMask then
        //Print("set trigger filter mask to %s", EnumToString(PhysicsMask, self:GetMixinConstants().kFilterMask))
        self.triggerBody:SetGroupFilterMask(self:GetMixinConstants().kFilterMask)
    end
    
    self.triggerBody:SetEntity(self)
    
end

function TriggerMixin:OnDestroy()

    DestroyTrigger(self)
    
    self.insideTriggerEntities = { }
    
end

function TriggerMixin:SetTriggerCollisionEnabled(setEnabled)
    self.triggerBody:SetCollisionEnabled(setEnabled)
end

function TriggerMixin:GetIsPointInside(point)

    assert(self.triggerBody)
    
    return self.triggerBody:GetContainsPoint(point, CollisionRep.Default)
    
end

function TriggerMixin:GetNumberOfEntitiesInTrigger()
    return #self.insideTriggerEntities
end

function TriggerMixin:GetEntitiesInTrigger()

    local entities = { }
    
    for e = 1, #self.insideTriggerEntities do
        table.insert(entities, Shared.GetEntity(self.insideTriggerEntities[e]))
    end
    
    return entities
    
end

function TriggerMixin:GetEntityIdsInTrigger()

    local copyTable = table.array(#self.insideTriggerEntities)
    
    for index = 1, #self.insideTriggerEntities do
    
        local currentId = self.insideTriggerEntities[index]
        table.insert(copyTable, currentId)
        
    end
    
    return copyTable
    
end

function TriggerMixin:ForEachEntityInTrigger(callFunc)

    for e = 1, #self.insideTriggerEntities do
        callFunc(Shared.GetEntity(self.insideTriggerEntities[e]))
    end
    
end

function TriggerMixin:OnEntityChange(oldId, newId)

    table.removevalue(self.insideTriggerEntities, oldId)
    
end

function TriggerMixin:OnTriggerEntered(enterEntity)

    if self.GetTrackEntity then
    
        // Filter entity?
        if not self:GetTrackEntity(enterEntity) then
            return
        end
        
    end
    
    if table.insertunique(self.insideTriggerEntities, enterEntity:GetId()) then
    
        if self.OnTriggerListChanged then
            self:OnTriggerListChanged(enterEntity, true)
        end
    
    end
    
end

function TriggerMixin:OnTriggerExited(exitEntity)

    local exitEntId = exitEntity:GetId()
    if table.contains(self.insideTriggerEntities, exitEntId) then
    
        table.removevalue(self.insideTriggerEntities, exitEntId)
        
        if self.OnTriggerListChanged then
            self:OnTriggerListChanged(exitEntity, false)
        end
        
    end
    
end
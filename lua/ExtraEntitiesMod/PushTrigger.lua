//________________________________
//
//  NS2: Combat
//    Copyright 2014 Faultline Games Ltd.
//  and Unknown Worlds Ltd.
//
//________________________________

// PushTrigger.lua
// Entity for mappers to create teleporters

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'PushTrigger' (Trigger)

PushTrigger.kMapName = "push_trigger"

local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

local function PushEntity(self, entity)
    
    if self.enabled and entity:isa("Alien") or entity:isa("Marine") then
        local force = self.pushForce
        if self.pushDirection then      
            
            // get him in the air a bit
            if entity.GetIsOnGround and entity:GetIsOnGround() then
                local extents = GetExtents(entity:GetTechId())            
                if GetHasRoomForCapsule(extents, entity:GetOrigin() + Vector(0, extents.y + 0.2, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterTwo(self, entity)) then                
                    entity:SetOrigin(entity:GetOrigin() + Vector(0,0.2,0)) 
                end
                
                entity.timeOfLastJump = Shared.GetTime()
                entity.onGroundNeedsUpdate = true
                entity.jumping = true  
               
            end 
            
            entity.pushTime = Shared.GetTime()
            
            velocity = self.pushDirection * force 
            entity:SetVelocity(velocity)

        end 
    end
    
end

local function PushAllInTrigger(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        PushEntity(self, entity)
    end
    
end

function PushTrigger:OnCreate()
 
    Trigger.OnCreate(self)  
    
end

function PushTrigger:OnInitialized()

    Trigger.OnInitialized(self) 
    if Server then
        InitMixin(self, LogicMixin)   
        self.pushDirection = self:AnglesToVector()
        self:SetUpdates(true)  
    end
    self:SetTriggerCollisionEnabled(true) 
    
end

function PushTrigger:OnTriggerEntered(enterEnt, triggerEnt)

    if self.enabled then
         PushEntity(self, enterEnt)
    end
    
end


//Addtimedcallback had not worked, so lets search it this way
function PushTrigger:OnUpdate(deltaTime)

    if self.enabled then
        PushAllInTrigger(self)
    end
    
end


function PushTrigger:OnLogicTrigger()
	self:OnTriggerAction()
end

function PushTrigger:AnglesToVector()
    // y -1.57 in game is up in the air
    local angles =  self:GetAngles()
    local origin = self:GetOrigin()
    local directionVector = Vector(0,0,0)
    if angles then
        // get the direction Vector the pushTrigger should push you                
        
        // pitch to vector
        directionVector.z = math.cos(angles.pitch)
        directionVector.y = -math.sin(angles.pitch)
        
        // yaw to vector
        if angles.yaw ~= 0 then
            directionVector.x = directionVector.z * math.sin(angles.yaw)                   
            directionVector.z = directionVector.z * math.cos(angles.yaw)                                
        end  
    end
    return directionVector
end


Shared.LinkClassToMap("PushTrigger", PushTrigger.kMapName, networkVars)
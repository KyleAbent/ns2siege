// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\RolloutMixin.lua
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
//    Handles rolling out things from the robo-factory. 
//
//    RoboFactory creates them inside the factory, then calls Rollout to start the rollout.
//    Once the rollout is complete, the factory has its CompleteRollout method called, which 
//    opens up the factory for more work.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

RolloutMixin = CreateMixin(RolloutMixin)
RolloutMixin.type = "Rollout"

RolloutMixin.expectedMixins =
{
    Orders = "Must be able to take orders",
    Pathing = "Must be able to define a path",
    BaseModel = "Must have a model so we can take its size"
}

function RolloutMixin:__initmixin()
end

// just in case someone manages to kill the unit as it is rolling out...
// tested this using speed 0.3, damage 100, on a MAC. Worked.
function RolloutMixin:OnKill(attacker, doer, point, direction)

    if self.rolloutSourceFactory then
        self.rolloutSourceFactory:CompleteRollout(self)
        self.rolloutSourceFactory = nil
    end

end

// When the first order completes, we complete the rollout
function RolloutMixin:OnOrderComplete(order)

    if self.rolloutSourceFactory then

        self.rolloutSourceFactory:CompleteRollout(self)
        self.rolloutSourceFactory = nil
        
          // Print("Moving Complete") 

   //Print("Checking")
    local repositionables = GetEntitiesWithMixinForTeamWithinRange("Repositioning", self:GetTeamNumber(), self:GetModelOrigin(), 1.3)  


    local inrange = 0
    
    for _, repo in ipairs(repositionables) do  
      if repo ~= self then inrange = inrange + 1 break end
    end
    

    if inrange >= 1 then 

        local extents = Vector(1.3, 1, 1.3)
        local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), 1.5, 4, EntityFilterAll())
        
        if spawnPoint ~= nil then
            spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
        end
 
        if spawnPoint then
       // Print("Order Given to unstuck")
        self:AddTimedCallback(function () self:GiveOrder(kTechId.Move, nil, spawnPoint) end, 1)
        end
    
    end
    

    end
        
end

RolloutMixin.kMaxRolloutTime = 8

local function OnRolloutTimeout(self)
    if not self:GetIsDestroyed() and self.rolloutSourceFactory then
        Log("%s: failed to rollout from %s in time, ", self, self.rolloutSourceFactory)
        // still not rolled out. Teleport to target pos,
        self:SetIgnoreOrders(false)
        self:ClearOrders()
        self:SetOrigin(self.rolloutTargetPoint)
        self.rolloutSourceFactory:CompleteRollout(self)
        self.rolloutSourceFactory = nil
    end
    self.rolloutTargetPoint = nil
    return false
end

function RolloutMixin:Rollout(factory, factoryRolloutLength)
    // remeber the factory that created us. 
    self.rolloutSourceFactory = factory

    // we need to move our rear end clear of the factory rollout length.
    // so grab the min.z part of the model extents    
    local rearEndSize = math.abs(self:GetModelExtents().z)
    local rolloutLength = factoryRolloutLength + rearEndSize
    
    local direction = Vector(factory:GetAngles():GetCoords().zAxis)    
    local rolloutPoint = factory:GetOrigin() + direction * rolloutLength
    self.rolloutTargetPoint = rolloutPoint
    
    // give a move order to the position
    self:SetIgnoreOrders(false)
    self:GiveOrder(kTechId.Move, nil, rolloutPoint, nil, true, true)
    self:SetIgnoreOrders(true)
    // create an absolute path there to bypass the Pathing system for the rollout
    self:CreateAbsolutePath( {self:GetOrigin(), rolloutPoint })
    
    // for safety; add a timeout command to trigger the OnOrderComplete after 10 seconds, just in case they get stuck...
    self:AddTimedCallback(OnRolloutTimeout, RolloutMixin.kMaxRolloutTime)

end


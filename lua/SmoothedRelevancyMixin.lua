// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\SmoothedRelevancyMixin.lua
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

//
// Handles adjusting relevancy when you abruptly transfers to a new area on the map. 
// This means that suddenly, upto hundreds of new entities will enter your relevancy
// are, which in turn means that 100 of new entitites has to be created (fairly costly
// mostly due to the cost of mixin in all those mixins) as well as starting  to run
// OnUpdate - most entities that use OnUpdate have a timing-guard so that they only
// occasionally needs to consume CPU, but the first time they are created they always
// run their first OnUpdate at full cost.
//
// In addition, the network cost of transferring all those entities will cause the
// player to be network choked for multiple updates.
//
// This mixin allows a player to adjust his relevancy range so new entities are phased
// in over a longer time, thus smoothing out the CPU and network cost. 
//
// The user is assumed to call the StartSmoothingRelevancy(targetPosition) just before
// his origin is changed, as the mixin will take the current origin into consideration
// before deciding just how much to shrink the relevancy.
//
SmoothedRelevancyMixin = CreateMixin( SmoothedRelevancyMixin )
SmoothedRelevancyMixin.type = "SmoothedRelevancy"

// turn it off by setting to zero. global to make it easy to hotload-console it 
SmoothedRelevancyMixin.kTimeToMax = 0.7
SmoothedRelevancyMixin.kMaxShrink = kMaxRelevancyDistance - 5

if Server then

    local function UpdateRelevancy(self)
    
        if self.smoothedRelevancyStart then
        
            local dt = Shared.GetTime() - self.smoothedRelevancyStart
            if SmoothedRelevancyMixin.kTimeToMax > 0 then
                local fraction = 1 - math.min(1, dt / SmoothedRelevancyMixin.kTimeToMax)
                local relevancyDecrease = SmoothedRelevancyMixin.kMaxShrink * fraction
                self:ConfigureRelevancy(Vector.origin, -relevancyDecrease)
            end
            if dt >= SmoothedRelevancyMixin.kTimeToMax then
                self.smoothedRelevancyStart = nil
            end
        end
        
        // stop the callback if we are no longer in need of smoothing
        return nil ~= self.smoothedRelevancyStart 
        
    end


    function SmoothedRelevancyMixin:StartSmoothedRelevancy(destinationOrigin)

        if not self.smootherRelevancyStart then
            // should be slightly shorter than the server tick rate in order to be
            // sure to be called at least once every network update
            self:AddTimedCallback(UpdateRelevancy, 0.025)
        end

        self.smoothedRelevancyStart = Shared.GetTime()

        if destinationOrigin then
            // if we are jumping to a close target pos, don't shrink target relevancy
            // as much - that way, we don't loose/reload as many entities
            // we use a simple formula - at 1.5 max relevancy distance, we loose all.
            // at 0.5 max relevancy distance, we don't shrink any, and linear in between
            local dist = (self:GetOrigin() - destinationOrigin):GetLength()
            local alreadyDoneFrac = Clamp(1 - (dist - 0.5 * kMaxRelevancyDistance) / kMaxRelevancyDistance, 0, 1)
            // we increase our starting relevancy by pretending we started earlier
            self.smoothedRelevancyStart = self.smoothedRelevancyStart - alreadyDoneFrac * SmoothedRelevancyMixin.kTimeToMax
        end
        
        UpdateRelevancy(self)
    
    end
   
else
    function SmoothedRelevancyMixin:StartSmoothedRelevancy(destinationOrigin)
    end 
end

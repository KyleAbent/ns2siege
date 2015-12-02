
//NS2siege - because this shit doesnt work and it needs to... derp.
RepositioningMixin = CreateMixin( RepositioningMixin )
RepositioningMixin.type = "Repositioning"



local kGroupOrderCompleteRange = 6

RepositioningMixin.expectedCallbacks =
{
}

RepositioningMixin.optionalCallbacks =
{
}

function RepositioningMixin:__initmixin()
    
    
end


function RepositioningMixin:OnOrderComplete(currentOrder)

    if currentOrder:GetType() == kTechId.Move then 
    

  // Print("Moving Complete") 

   Print("Checking")
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
        Print("Order Given to unstuck")
        self:AddTimedCallback(function () self:GiveOrder(kTechId.Move, nil, spawnPoint) end, 1)
        end
    
    end




    end
end
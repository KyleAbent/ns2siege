// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CragLerkUmbra.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Protects friendly units from bullets.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'CragLerkUmbra' (CommanderAbility)

CragLerkUmbra.kMapName = "craglerkumbra"

CragLerkUmbra.kCragLerkUmbraEffect = PrecacheAsset("cinematics/alien/crag/umbra.cinematic")

CragLerkUmbra.kType = CommanderAbility.kType.Repeat

// duration of cinematic, increase cinematic duration and kCragLerkUmbraDuration to 12 to match the old value from Crag.lua
CragLerkUmbra.kCragLerkUmbraDuration = kUmbraDuration
CragLerkUmbra.kRadius = 12
CragLerkUmbra.kMaxRange = 17
local kUpdateTime = 0.15
CragLerkUmbra.kTravelSpeed = 60 // meters per second

local networkVars =
{
    destination = "vector"
}

function CragLerkUmbra:GetRepeatCinematic()
    return CragLerkUmbra.kCragLerkUmbraEffect
end

function CragLerkUmbra:GetType()
    return CragLerkUmbra.kType
end
    
function CragLerkUmbra:GetLifeSpan()
    return CragLerkUmbra.kCragLerkUmbraDuration
end

function CragLerkUmbra:OnInitialized()

    CommanderAbility.OnInitialized(self)
    
    /*
    if Client then
        DebugCapsule(self:GetOrigin(), self:GetOrigin(), CragLerkUmbra.kRadius, 0, CragLerkUmbra.kCragLerkUmbraDuration)
    end
    */
    
end

function CragLerkUmbra:SetTravelDestination(position)
    self.destination = position
end

// called client side
function CragLerkUmbra:GetRepeatingEffectCoords()

    if not self.travelCoords then
    
        local travelDirection = self.destination - self:GetOrigin()
        if travelDirection:GetLength() > 0 then
            
            self.travelCoords = Coords.GetIdentity()
            self.travelCoords.origin = self:GetOrigin()
            
            self.travelCoords.zAxis = GetNormalizedVector(travelDirection)
            self.travelCoords.xAxis = self.travelCoords.yAxis:CrossProduct(self.travelCoords.zAxis)
            self.travelCoords.yAxis = self.travelCoords.zAxis:CrossProduct(self.travelCoords.xAxis)
            
            return self.travelCoords
            
        end
    
    else
    
        self.travelCoords.origin = self:GetOrigin()
        return self.travelCoords
    
    end

end

function CragLerkUmbra:GetUpdateTime()
    return kUpdateTime
end

if Server then

    function CragLerkUmbra:Perform()
    
        for _, target in ipairs(GetEntitiesWithMixinForTeamWithinRange("Umbra", self:GetTeamNumber(), self:GetOrigin(), CragLerkUmbra.kRadius)) do
            target:SetHasUmbra(true,kUmbraRetainTime)
        end
        
    end
    
    function CragLerkUmbra:OnUpdate(deltaTime)
    
        CommanderAbility.OnUpdate(self, deltaTime)
        
        if self.destination and not self.doneTraveling then
        
            local travelVector = self.destination - self:GetOrigin()
            if travelVector:GetLength() > 0.3 then
                local distanceFraction = (self.destination - self:GetOrigin()):GetLength() / CragLerkUmbra.kMaxRange
                self:SetOrigin( self:GetOrigin() + GetNormalizedVector(travelVector) * deltaTime * CragLerkUmbra.kTravelSpeed * distanceFraction )
            else
            
                self.doneTraveling = true
                for _, umbraCloud in ipairs(GetEntitiesForTeamWithinRange("CragLerkUmbra", self:GetTeamNumber(), self:GetOrigin(), 5)) do
                    
                    if umbraCloud ~= self then
                        DestroyEntity(umbraCloud)
                    end
                    
                end
            
            end
        
        end
    
    end

end

Shared.LinkClassToMap("CragLerkUmbra", CragLerkUmbra.kMapName, networkVars)
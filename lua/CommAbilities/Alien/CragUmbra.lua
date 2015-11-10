// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CragUmbra.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Protects friendly units from bullets.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
//Siegemod ~ just had to update the file to the current build, and remove the destination/traveling area which always shot if off screen, to spawn where the crag is at currently
Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'CragUmbra' (CommanderAbility)

CragUmbra.kMapName = "cragumbra"

CragUmbra.kCragUmbraEffect = PrecacheAsset("cinematics/alien/crag/umbra.cinematic")
local kUmbraSound = PrecacheAsset("sound/NS2.fev/alien/structures/crag/umbra") 

CragUmbra.kType = CommanderAbility.kType.Repeat

// duration of cinematic, increase cinematic duration and kCragUmbraDuration to 12 to match the old value from Crag.lua
CragUmbra.kCragUmbraDuration = kUmbraDuration
CragUmbra.kRadius = kUmbraRadius
if Server then
    function CragUmbra:OnCreate()
        CommanderAbility.OnCreate(self)
    end
    
end
local kUpdateTime = 0.15

local networkVars = {}

function CragUmbra:GetStartCinematic()
    return CragUmbra.kCragUmbraEffect
end
function CragUmbra:GetRepeatCinematic()
    return CragUmbra.kCragUmbraEffect
end
function CragUmbra:GetType()
    return CragUmbra.kType
end
    
function CragUmbra:GetLifeSpan()
    return CragUmbra.kCragUmbraDuration
end

function CragUmbra:OnInitialized()

    CommanderAbility.OnInitialized(self)
    if Server then
    Shared.PlayWorldSound(nil, kUmbraSound, nil, self:GetOrigin()) 
    end 
    /*
    if Client then
        DebugCapsule(self:GetOrigin(), self:GetOrigin(), CragUmbra.kRadius, 0, CragUmbra.kCragUmbraDuration)
    end
    */
    
end

function CragUmbra:GetUpdateTime()
    return kUpdateTime
end

if Server then

    function CragUmbra:Perform()
    
        for _, target in ipairs(GetEntitiesWithMixinForTeamWithinRange("Umbra", self:GetTeamNumber(), self:GetOrigin(), CragUmbra.kRadius)) do
            target:SetHasUmbra(true,kUmbraDuration)
        end
        
    end

end

Shared.LinkClassToMap("CragUmbra", CragUmbra.kMapName, networkVars)
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Rupture.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Obscures marines vision.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'Rupture' (CommanderAbility)

Rupture.kMapName = "rupture"

Rupture.kRuptureEffect = PrecacheAsset("cinematics/alien/cyst/rupture.cinematic")
//Rupture.kBubbleEffect = PrecacheAsset("cinematics/alien/cyst/rupture_bubble.cinematic")
Rupture.kRuptureViewEffect = PrecacheAsset("cinematics/alien/cyst/rupture_view.cinematic")
Rupture.kBurstSound = PrecacheAsset("sound/NS2.fev/alien/structures/death_axe")

Rupture.kType = CommanderAbility.kType.OverTime

Rupture.kRadius = 12
Rupture.kDuration = 0.1
Rupture.kMarineViewDuration = 6
local networkVars = { }

/*
function Rupture:GetStartCinematic()
     return Rupture.kBubbleEffect
end
*/

function Rupture:GetType()
    return Rupture.kType
end

function Rupture:GetLifeSpan()
    return Rupture.kDuration
end

if Client then

    local function GetViewClear(point1, point2)
    
        local trace = Shared.TraceRay(point1, point2, CollisionRep.LOS, PhysicsMask.All, EntityFilterAll())
        return trace.fraction == 1
    
    end

    function Rupture:OnDestroy()

        // trigger first person obscurring effect, depending on players view
        local localPlayer = Client.GetLocalPlayer()
        if localPlayer and GetAreEnemies(self, localPlayer) and not localPlayer:isa("Commander") and not localPlayer:isa("Spectator") then

            local eyePos = localPlayer:GetEyePos()
            local origin = self:GetOrigin()
            
            if (eyePos - origin):GetLength() <= Rupture.kRadius and GetViewClear(eyePos, origin + Vector(0, 0.2, 0)) then
            
                local effect = Client.CreateCinematic(RenderScene.Zone_ViewModel)    
                effect:SetCinematic(Rupture.kRuptureViewEffect) 
            
                // translate world to view
                local viewInverse = localPlayer:GetViewCoords():GetInverse()                
                local viewPoint = viewInverse:TransformPoint(origin)
                // vertical always centered
                viewPoint.y = 0     
                // align zAxis towards rupture point
                effect:SetCoords(Coords.GetLookIn(Vector(0,0,0), viewPoint))
                
            end    
        
        end

        // trigger world effect
        local effect = Client.CreateCinematic(RenderScene.Zone_Default)    
        effect:SetCinematic(Rupture.kRuptureEffect)   
        effect:SetCoords(self:GetCoords())
        
        Shared.PlayWorldSound(nil, Rupture.kBurstSound, nil, self:GetOrigin(), 1)

    end

end

function Rupture:Perform()    
end

Shared.LinkClassToMap("Rupture", Rupture.kMapName, networkVars)
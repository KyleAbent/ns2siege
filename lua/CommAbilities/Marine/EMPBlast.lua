// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CommAbilities\Marine\EMPBlast.lua
//
//      Created by: Andreas Urwalek (andi@unknownworlds.com)
//
//      Takes kEMPBlastEnergyDamage energy away from all aliens in detonation radius.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'EMPBlast' (CommanderAbility)

EMPBlast.kMapName = "empblast"

local kSplashEffect = PrecacheAsset("cinematics/marine/mac/empblast.cinematic")
local kRadius = 6
local kType = CommanderAbility.kType.Instant
local kEMPBlastMinEnergy = 10

local networkVars =
{
}

function EMPBlast:GetStartCinematic()
    return kSplashEffect
end   

function EMPBlast:GetType()
    return kType
end

if Server then

    function EMPBlast:Perform()
        
        for _, alien in ipairs(GetEntitiesForTeamWithinRange("Alien", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kRadius)) do
        
            local energy = alien:GetEnergy()
            if energy > 10 then
            
                local newEnergy = math.max(10, alien:GetEnergy() - 30)
                alien:SetEnergy(newEnergy)
                alien:TriggerEffects("emp_blasted")
                
            end
            
        end

    end

end

Shared.LinkClassToMap("EMPBlast", EMPBlast.kMapName, networkVars)
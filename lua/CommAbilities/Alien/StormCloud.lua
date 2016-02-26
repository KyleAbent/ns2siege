// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CommAbilities\Alien\StormCloud.lua
//
//      Created by: Andreas Urwalek (andi@unknownworlds.com)
//
//      Increases movement speed inside the cloud.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'StormCloud' (CommanderAbility)

StormCloud.kMapName = "stormcloud"

StormCloud.kSplashEffect = PrecacheAsset("cinematics/alien/drifter/stormcloud.cinematic")
StormCloud.kType = CommanderAbility.kType.Repeat
StormCloud.kLifeSpan = 3
StormCloud.kThinkTime = 0.2

local kUnitSpeedBoostDuration = 1

StormCloud.kRadius = 8

local networkVars = { }

function StormCloud:OnInitialized()
    
    if Server then
        // sound feedback
        self:TriggerEffects("enzyme_cloud")
        DestroyEntitiesWithinRange("StormCloud", self:GetOrigin(), 25, EntityFilterOne(self)) 
    end
    
    CommanderAbility.OnInitialized(self)

end

function StormCloud:GetRepeatCinematic()
    return StormCloud.kSplashEffect
end

function StormCloud:GetType()
    return StormCloud.kType
end

function StormCloud:GetUpdateTime()
    return StormCloud.kThinkTime
end

function StormCloud:GetLifeSpan()
    return StormCloud.kLifeSpan   
end

if Server then

    function StormCloud:Perform()
        
        for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Storm", self:GetTeamNumber(), self:GetOrigin(), StormCloud.kRadius)) do
            unit:SetSpeedBoostDuration(kUnitSpeedBoostDuration)
        end

    end

end

Shared.LinkClassToMap("StormCloud", StormCloud.kMapName, networkVars)
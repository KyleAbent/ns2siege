// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\SporeCloud.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
//    This class is used for the lerks spore dust cloud attack (trailing spores).
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TeamMixin.lua")
Script.Load("lua/OwnerMixin.lua")
Script.Load("lua/DamageMixin.lua")

class 'SporeCloud' (Entity)

SporeCloud.kMapName = "sporecloud"

local kLoopingEffect = PrecacheAsset("cinematics/alien/lerk/sporesranged.cinematic")
local kSporesSound = PrecacheAsset("sound/NS2.fev/alien/structures/crag/umbra")
local kDamageInterval = 0.5

local gHurtBySpores = { }

local networkVars = { }

AddMixinNetworkVars(TeamMixin, networkVars)

function SporeCloud:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    
    if Server then
    
        InitMixin(self, OwnerMixin)
        
        self.nextDamageTime = 0
 
    end
    
    self:SetUpdates(true)
    
    self.createTime = Shared.GetTime()
    // note: let the cloud linger a little bit after it stops doing damage to let the animation play out
    self.endOfDamageTime = self.createTime + kSporesDustCloudLifetime 
    self.destroyTime = self.endOfDamageTime + 2

end

if Client then

    function SporeCloud:OnDestroy()

        Entity.OnDestroy(self)
        
        if self.sporeEffect then
        
            Client.DestroyCinematic(self.sporeEffect)
            self.sporeEffect = nil
            
            /*
            local fadeOutCinemtic = Client.CreateCinematic(RenderScene.Zone_Default)
            fadeOutCinemtic:SetCinematic(SporeCloud.kFadeOutEffect)
            fadeOutCinemtic:SetCoords(self:GetCoords())
            */
            
        end

    end

end

local function GetEntityRecentlyHurt(entityId, time)

    for index, pair in ipairs(gHurtBySpores) do
        if pair[1] == entityId and pair[2] > time then
            return true
        end
    end
    
    return false
    
end

local function SetEntityRecentlyHurt(entityId)

    for index, pair in ipairs(gHurtBySpores) do
        if pair[1] == entityId then
            table.remove(gHurtBySpores, index)
        end
    end
    
    table.insert(gHurtBySpores, {entityId, Shared.GetTime()})
    
end
function SporeCloud:GetThinkTime()
    return kDamageInterval
end
function SporeCloud:GetRepeatCinematic()
    return SporeCloud.kSporeCloudEffect
end
function SporeCloud:GetDamageType()
    return kDamageType.Gas
end

function SporeCloud:GetDeathIconIndex()
    return kDeathMessageIcon.SporeCloud
end

// Have damage radius grow to maximum non-instantly
function SporeCloud:GetDamageRadius()
    
    local scalar = Clamp((Shared.GetTime() - self.createTime) * 3, 0, 1)
    return scalar * kSporesDustCloudRadius
    
end

// They stick around for a while - don't show the numbers. Too much.
function SporeCloud:GetShowHitIndicator()
    return false
end

function SporeCloud:SporeDamage(time)

    local enemies = GetEntitiesForTeam("Player", GetEnemyTeamNumber(self:GetTeamNumber()))
    local damageRadius = self:GetDamageRadius()
    
    // When checking if spore cloud can reach something, only walls and door entities will block the damage.
    local filterNonDoors = EntityFilterAllButIsa("FuncMoveable")
    for index, entity in ipairs(enemies) do
    
        local attackPoint = entity:GetEyePos()        
        if (attackPoint - self:GetOrigin()):GetLength() < damageRadius then

            if not entity:isa("Commander") and not GetEntityRecentlyHurt(entity:GetId(), (time - kDamageInterval)) then

                // Make sure spores can "see" target
                local trace = Shared.TraceRay(self:GetOrigin(), attackPoint, CollisionRep.Damage, PhysicsMask.Bullets, filterNonDoors)
                if trace.fraction == 1.0 or trace.entity == entity then
                
                    self:DoDamage(kSporesDustDamagePerSecond * kDamageInterval, entity, trace.endPoint, (attackPoint - trace.endPoint):GetUnit(), "organic" )
                    
                    // Spores can't hurt this entity for kDamageInterval
                    SetEntityRecentlyHurt(entity:GetId())
                    
                end
                
            end
            
        end
        
    end
end
function SporeCloud:SetTravelDestination(position)
    self.destination = position
end
function SporeCloud:OnUpdate(deltaTime)

    if self.destination then
    
        local travelVector = self.destination - self:GetOrigin()
        if travelVector:GetLength() > 0.3 then
            local distanceFraction = (self.destination - self:GetOrigin()):GetLength() / kSporesMaxCloudRange
            self:SetOrigin( self:GetOrigin() + GetNormalizedVector(travelVector) * deltaTime * kSporesTravelSpeed * distanceFraction )
        end
        if travelVector:GetLength() < 3 and not self.soundplayed then
            StartSoundEffectAtOrigin(kSporesSound, self:GetOrigin())
            self.soundplayed = true
        end
    
    end
    
    local time = Shared.GetTime()
    if Server then 
        // we do damage until the spores have died away. 
        if time > self.nextDamageTime and time < self.endOfDamageTime then

            self:SporeDamage(time)
            self.nextDamageTime = time + kDamageInterval
        end
        
        if  time > self.destroyTime then
            DestroyEntity(self)
        end
     elseif Client then

        if self.sporeEffect then        
            self.sporeEffect:SetCoords(self:GetCoords())            
        else
        
            self.sporeEffect = Client.CreateCinematic(RenderScene.Zone_Default) 
            self.sporeEffect:SetCinematic(kLoopingEffect)
            self.sporeEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.sporeEffect:SetCoords(self:GetCoords())
        
        end
    
    end

end 
function SporeCloud:GetRemainingLifeTime()
    return math.min(0, self.endOfDamageTime - Shared.GetTime())
end

Shared.LinkClassToMap("SporeCloud", SporeCloud.kMapName, networkVars)
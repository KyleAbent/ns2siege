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

class 'SporeMeleeCloud' (Entity)

// Spores didn't stack in NS1 so consider that
SporeMeleeCloud.kMapName = "sporemeleecloud"

SporeMeleeCloud.kLoopingEffect = PrecacheAsset("cinematics/alien/lerk/spore_trail.cinematic")
SporeMeleeCloud.kLoopingEffectAlien = PrecacheAsset("cinematics/alien/lerk/spore_trail_alien.cinematic")
//SporeCloud.kFadeOutEffect = PrecacheAsset("cinematics/alien/lerk/spore_trail_fadeout.cinematic")

// Damage per think interval (from NS1)
// 0.5 in NS1, reducing to make sure sprinting machines take damage
local kDamageInterval = 0.25

// Keep table of entities that have been hurt by spores to make
// spores non-stackable. List of {entityId, time} pairs.

local gHurtBySpores = { }

// how fast we drop
SporeMeleeCloud.kDropSpeed = 0.6
// how far away from our drop-target before we slow down the speed
SporeMeleeCloud.kDropSlowDistance = 0.4
// minimum distance above floor we drop to
SporeMeleeCloud.kDropMinDistance = 1.1

local networkVars = { }

AddMixinNetworkVars(TeamMixin, networkVars)

function SporeMeleeCloud:OnCreate()

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

    function SporeMeleeCloud:OnDestroy()

        Entity.OnDestroy(self)
        
        if self.sporeEffect then
        
            Client.DestroyCinematic(self.sporeEffect)
            self.sporeEffect = nil
            
            /*
            local fadeOutCinemtic = Client.CreateCinematic(RenderScene.Zone_Default)
            fadeOutCinemtic:SetCinematic(SporeMeleeCloud.kFadeOutEffect)
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

function SporeMeleeCloud:GetDamageType()
    return kDamageType.Gas
end

function SporeMeleeCloud:GetDeathIconIndex()
    return kDeathMessageIcon.SporeCloud
end

// Have damage radius grow to maximum non-instantly
function SporeMeleeCloud:GetDamageRadius()
    
    local scalar = Clamp((Shared.GetTime() - self.createTime) * 3, 0, 1)
    return scalar * kMeleeSporesDustCloudRadius
    
end

// They stick around for a while - don't show the numbers. Too much.
function SporeMeleeCloud:GetShowHitIndicator()
    return false
end

function SporeMeleeCloud:SporeDamage(time)

    local enemies = GetEntitiesForTeam("Player", GetEnemyTeamNumber(self:GetTeamNumber()))
    local damageRadius = self:GetDamageRadius()
    
    // When checking if spore cloud can reach something, only walls and door entities will block the damage.
    local filterNonDoors = EntityFilterAllButIsa("Door")
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

function SporeMeleeCloud:OnUpdate(deltaTime)

    local time = Shared.GetTime()
    if Server then 
    
        if not self.targetY then
            local trace = Shared.TraceRay(self:GetOrigin(), self:GetOrigin() - Vector(0,10,0), CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAll())

            self.targetY = trace.endPoint.y + SporeMeleeCloud.kDropMinDistance
        end
    
        // drop by a constant speed until we get close to the target, at which time we slow down the drop
        local origin = self:GetOrigin()
        local remDrop = origin.y - self.targetY
        local speed = SporeMeleeCloud.kDropSpeed 
       if remDrop < SporeMeleeCloud.kDropSlowDistance then
            speed = SporeMeleeCloud.kDropSpeed * remDrop / SporeMeleeCloud.kDropSlowDistance
        end
        // cut bandwidth; when the speed is slow enough, we stop updating
        if speed > 0.05 then
            origin.y = origin.y - speed * deltaTime
            self:SetOrigin(origin)
        end  

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
            local effectName = SporeMeleeCloud.kLoopingEffect
            if not GetAreEnemies(self, Client.GetLocalPlayer()) then
                effectName = SporeMeleeCloud.kLoopingEffectAlien
            end
            
            self.sporeEffect:SetCinematic(effectName)
            self.sporeEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.sporeEffect:SetCoords(self:GetCoords())
        
        end
    
    end
    
end

function SporeMeleeCloud:GetMeleeCloudRemainingLifeTime()
    return math.min(0, self.endOfDamageTime - Shared.GetTime())
end

Shared.LinkClassToMap("SporeMeleeCloud", SporeMeleeCloud.kMapName, networkVars)
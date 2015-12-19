// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//    
// lua\CombatMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Tracks combat relevant stats (last time damage dealth, last time damage taken)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/DamageTypes.lua")

CombatMixin = { }
CombatMixin.type = "Combat"

// after X seconds of no "combat action" the entity is flagged as not in combat
local kCombatTimeOut = 3

local kDamageCameraShakeAmount = 0.10
local kDamageCameraShakeSpeed = 5
local kDamageCameraShakeTime = 0.25

CombatMixin.optionalCallbacks =
{
    GetDamagedAlertId = "Return techId for alert."
}

CombatMixin.networkVars =
{
    inCombat = "boolean",
    lastTakenDamageTime = "time (by 0.1)",
    lastTakenDamageOrigin = "private position(by 0.1)",
    lastTakenDamageAmount = "private integer (0 to 8191)",
    lastTargetId = "private entityid"
}

function CombatMixin:__initmixin()

    self.inCombat = false
    self.timeLastDamageDealt = 0
    self.lastTakenDamageTime = 0
    self.lastAttackerId = Entity.invalidId
    self.lastTargetId = Entity.invalidId
    self.lastTakenDamageOrigin = Vector()
    self.lastTakenDamageAmount = 0
    self.timeLastHealthChange = 0
    
    self:AddTimedCallback(CombatMixin.OnCombatUpdate, Server and 0 or kUpdateIntervalMedium)
    
end

function CombatMixin:OnDestroy()
end

function CombatMixin:OnHealed()
    self.timeLastHealthChange = Shared.GetTime()
end

function CombatMixin:OnEntityChange(oldId, newId)

    if self.lastAttackerId == oldId then
        if newId then
            self.lastAttackerId = newId
        else
            self.lastAttackerId = Entity.invalidId
        end
    end

    if self.lastTargetId == oldId then
        self.lastTargetId = Entity.invalidId
    end   

end

-- XXX add an OnUpdateLocalPlayer and let mixins use that

if Server then
  
    function CombatMixin:OnCombatUpdate(deltaTime)
       
        local inCombat = (self.timeLastDamageDealt + kCombatTimeOut > Shared.GetTime()) or (self.lastTakenDamageTime + kCombatTimeOut > Shared.GetTime())
        if inCombat ~= self.inCombat then
        
            self.inCombat = inCombat
            
            if inCombat and self.OnEnterCombat then
                self:OnEnterCombat()
            end
            
            if not inCombat and self.OnLeaveCombat then
                self:OnLeaveCombat()
            end
            
        end
        return true
    end
    
end

if Client then 
  
    function CombatMixin:OnCombatUpdate(deltaTime)
        // Special case for client side player combat effects.
        if self == Client.GetLocalPlayer() then
        
            self.clientLastTakenDamageTime = self.clientLastTakenDamageTime or 0
            if self.lastTakenDamageTime ~= self.clientLastTakenDamageTime then
            
                self.clientLastTakenDamageTime = self.lastTakenDamageTime
                
                self:AddTakeDamageIndicator(self.lastTakenDamageOrigin)
                
                // Shake the camera if this player supports it.
                if self.SetCameraShake ~= nil then
                
                    local amountScalar = self.lastTakenDamageAmount / self:GetMaxHealth()
                    self:SetCameraShake(amountScalar * kDamageCameraShakeAmount, kDamageCameraShakeSpeed, kDamageCameraShakeTime)
                    
                end
                
            end            
            return true
            
        end
        return false
        
    end
    
end


function CombatMixin:OnDamageDone(doer, target)

    if doer and (doer:isa("Projectile") or doer:isa("PredictedProjectile") or doer:isa("Weapon") or doer:isa("Minigun") or doer:isa("Claw") or doer:isa("Railgun")) then

        self.timeLastDamageDealt = Shared.GetTime()
        
        if target then    
            self.lastTargetId = target:GetId()        
        end
    
    end

end

function CombatMixin:GetIsInCombat()
    return self.inCombat
end
if Server then
function CombatMixin:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
function CombatMixin:InsideMainRoom()

    for _, player in ipairs(GetEntitiesWithinRange("Marine", self:GetOrigin(), 999)) do
        if player:GetIsAlive() and not player:isa("Commander") then
           player:GiveOrder(kTechId.Move, self:GetId(), self:GetOrigin(), nil, true, true)
        end
              
    end   // Create marine order
    
    // if entity:isa("Player") or entity:isa("PowerPoint") then - not here yet
      CreatePheromone(kTechId.ThreatMarker, self:GetOrigin(), 2)  //Make alien threat
      
      /*
         // Make drifters useful // just enzyme for now
   for _, drifter in ipairs(GetEntitiesWithinRange("Drifter", self:GetOrigin(), 30)) do
        if self:GetIsAlive() and not self:isa("Commander") and self:GetTeamNumber() == 2 then  
           drifter:GiveOrder(kTechId.EnzymeCloud, self:GetId(), self:GetOrigin(), nil, true, true)
        end
              
    end
             //Disabled because crashing error relating to particle effects etc not knowing what to do with the enzyme or something?
       */
                                                      //flicker marine lights
    //   for _, powerpoint in ipairs(GetEntitiesWithinRange("PowerPoint", self:GetOrigin(), 999)) do
    //    if powerpoint:GetIsAlive() and self:GetLocationName() == powerpoint:GetLocationName() then
    //       powerpoint:SetMainRoom()
    //    end
              
   // end


end
end//server  
function CombatMixin:GetTimeLastDamageDealt()
    return self.timeLastDamageDealt
end

function CombatMixin:GetTimeLastDamageTaken()
    return self.lastTakenDamageTime
end

function CombatMixin:GetLastAttacker()
    if self.lastAttackerId ~= Entity.invalidId then
        return Shared.GetEntity(self.lastAttackerId)
    end
end

function CombatMixin:GetLastTarget()    
    if self.lastTargetId ~= Entity.invalidId then
        return Shared.GetEntity(self.lastTargetId)
    end    
end

local function GetDamageAlert(self)

    local alert = nil
    
    if self.GetDamagedAlertId then
        alert = self:GetDamagedAlertId()
    end

    return alert    

end

if Server then

    function CombatMixin:OnTakeDamage(damage, attacker, doer, point, direction, damageType, preventAlert)

        local notifiyTarget = not doer or not doer.GetNotifiyTarget or doer:GetNotifiyTarget(self)
        local isHallucination = false

        if attacker then
            isHallucination = attacker:isa("Hallucination") or attacker.isHallucination
            
            if damage > 0 then
                self.lastAttackerId = attacker:GetId()  
                self.lastAttackerDidDamageTime = Shared.GetTime()
            end
        end

        if notifiyTarget and (damage > 0 or isHallucination) then
        
            local team = self:GetTeam()
            if team and team.TriggerAlert and not preventAlert then
            
                local alert = GetDamageAlert(self)
                if alert then
                    team:TriggerAlert(alert, self)
                end
                
            end
        
            self.lastTakenDamageTime = Shared.GetTime()
            self.timeLastHealthChange = Shared.GetTime()
            self.lastTakenDamageAmount = Clamp(damage, 0, 8191)

            if point ~= nil then
            
                self.lastTakenDamageOrigin = doer and doer:GetOrigin() or self:GetOrigin()
                local doerParent = doer and doer:GetParent() or nil
                if doerParent then
                    self.lastTakenDamageOrigin = doerParent:GetOrigin()
                end
                
            end
            
        end    
        
    end

end

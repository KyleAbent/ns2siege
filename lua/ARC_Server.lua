--Kyle Abent
--modified by
/*
function ARC:SetSiegeArcDmgBonus(amount)
      local arc = GetEntitiesWithinRange("ARC", self:GetOrigin(), 999999)
      if #arc == 0 then return end
       for i = 1, #arc do
         local entity = arc[i]
        if entity:GetIsInSiege() then
           entity:AddDmgBonus(amount)
         end
       end
end
*/
function ARC:GetIsSiegeEnabled()
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   return true
               end
            end
            return false
end
function ARC:OnConstructionComplete()
    if self:GetIsSiegeEnabled() and self:GetIsInSiege() then
        self:AddTimedCallback(ARC.AcquireSiegeTarget, math.random(4,8))
    else
        self:AddTimedCallback(ARC.AcquireTarget, 4)
    
    end
end
function ARC:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
if Server then
function ARC:GetCanBeUsedConstructed(byPlayer)
    return  not byPlayer:isa("Exo") and not byPlayer:GetHasLayStructure() and not self:GetIsInSiege() and byPlayer:GetHasWelderPrimary()
end 
function ARC:OnUse(player, elapsedTime, useSuccessTable)

    if self:GetIsBuilt() and self:GetCanBeUsedConstructed(player) then
           local laystructure = player:GiveItem(LayStructures.kMapName)
           laystructure:SetTechId(kTechId.ARC)
           laystructure:SetMapName(ARC.kMapName)
           laystructure.originalposition = self:GetOrigin()
           DestroyEntity(self)
     end
    
end
end
function ARC:GetIsInSiege()
if string.find(self:GetLocationName(), "siege") or string.find(self:GetLocationName(), "Siege") then return true end
return false
end
function ARC:GetEntitiesInHiveRoom()
local hiventity = nil
local hitentities = {}
            for index, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
                   if hive then
                     hiventity = hive
                     break
                   end
                end 
    -- Print("hivelocation is %s", hivelocation)
    if hiventity ~= nil then
    local entities = GetEntitiesWithMixinForTeamWithinRange("Live", 2, hiventity:GetOrigin(), ARC.kFireRange)
          table.insert(hitentities,hiventity)
      
           if #entities == 0 then return end
           for i = 1, #entities do
             local possibletarget = entities[i]
                 if self:GetCanFireAtTarget(possibletarget) then
                   table.insert(hitentities,possibletarget)
                 end
           end
    end
    
    return hitentities 
    
end
function ARC:AcquireTarget()
    --Print("Arc acquiring target")
    
    local targets = GetEntitiesWithMixinForTeamWithinRange("Live", 2, self:GetOrigin(), ARC.kFireRange)
    local finalTarget = nil
    
      for i = 1, #targets do
        local entity = targets[i]
        if self:GetCanFireAtTarget(entity) then 
        finalTarget = entity 
         --Print("Finaltarget is a %s", finalTarget:GetClassName()) break end
         end
      end

    if finalTarget ~= nil then
        self:SetMode(ARC.kMode.Targeting)
        self:PerformAttack(self, finalTarget)
    end
    
    
    return self:GetIsAlive() and not (self:GetIsSiegeEnabled() and self:GetIsInSiege())
end
function ARC:PerformAttack(self, finalTarget)
  if finalTarget then
    local origin = finalTarget:GetOrigin()  
        GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(origin)})
        
        local hitEntities = GetEntitiesWithMixinWithinRange("Live", origin, ARC.kSplashRadius)
        RadiusDamage(hitEntities, origin, ARC.kSplashRadius, ARC.kAttackDamage, self, true)
        for index, target in ipairs(hitEntities) do
        
            if HasMixin(target, "Effects") then
                target:TriggerEffects("arc_hit_secondary")
            end 
           
        end
   end 
end
function ARC:AcquireSiegeTarget()
    --Print("Arc acquiring siege target")
    
    local targets = self:GetEntitiesInHiveRoom()
    local finalTarget = nil
    
      for i = 1, #targets do
        local entity = targets[i]
        if self:GetCanFireAtTarget(entity) then 
        finalTarget = entity 
        -- Print("Siege Finaltarget is a %s", finalTarget:GetClassName()) break end
        end
      end

    if finalTarget ~= nil then
       self:TriggerEffects("arc_firing")  
        self:SetMode(ARC.kMode.Targeting)
        self:PerformSiegeAttack(self, finalTarget)
    end
    
    
    return self:GetIsAlive() and (self:GetIsSiegeEnabled() and self:GetIsInSiege())
end
function ARC:PerformSiegeAttack(self, finalTarget)
  if finalTarget then  
             local entity = finalTarget
             local arcsinsiege = self:GetArcsInSiege()
             local damage = math.random(arcsinsiege*16,arcsinsiege*32)
             local builtscalar = Clamp(entity:GetHealthScalar(), 0.10, 1)
             local unbuiltscalar = Clamp(entity:GetHealthScalar(), 0.35, 1)
             local healthscalar = ConditionalValue(entity.GetIsBuilt and entity:GetIsBuilt(), builtscalar, unbuiltscalar)
              damage = (damage * healthscalar)
             -- damage = damage * self.dmgbonus
            --  damage = ConditionalValue(not entity:isa("Hive"), damage * 0.9, damage)
              
            local hitEntities = GetEntitiesWithMixinWithinRange("Live", entity:GetOrigin(), ARC.kSplashRadius)
            RadiusDamage(hitEntities, entity:GetOrigin(), ARC.kSplashRadius, damage, self, true)
           GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(entity:GetOrigin())})
          for index, target in ipairs(hitEntities) do
            if HasMixin(target, "Effects") then
                target:TriggerEffects("arc_hit_secondary")
            end 
        end
  end         
end
function ARC:SetMode(mode)

    if self.mode ~= mode then
    
        local triggerEffectName = "arc_" .. string.lower(EnumToString(ARC.kMode, mode))        
        self:TriggerEffects(triggerEffectName)
        
        self.mode = mode
    end
    
end

function ARC:OnTag(tagName)

    PROFILE("ARC:OnTag")
    
   if tagName == "target_start" then
        self:TriggerEffects("arc_charge")
    elseif tagName == "attack_end" then
        self:SetMode(ARC.kMode.Targeting)
    end
    
end
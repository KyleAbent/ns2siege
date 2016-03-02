Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/SpawnBlockMixin.lua")
Script.Load("lua/IdleMixin.lua")

Script.Load("lua/CommAbilities/Alien/EnzymeCloud.lua")
Script.Load("lua/CommAbilities/Alien/Rupture.lua")

class 'Cyst' (ScriptActor)

Cyst.kMaxEncodedPathLength = 30
Cyst.kMapName = "cyst"
Cyst.kModelName = PrecacheAsset("models/alien/cyst/cyst.model")

Cyst.kAnimationGraph = PrecacheAsset("models/alien/cyst/cyst.animation_graph")

Cyst.kEnergyCost = 25
Cyst.kPointValue = 5
// how fast the impulse moves
Cyst.kImpulseSpeed = 8

Cyst.kImpulseColor = Color(1,1,0)
Cyst.kImpulseLightIntensity = 8


Cyst.MaxLevel = 99
Cyst.GainXP = 4
Cyst.ScaleSize = 4

local kImpulseLightRadius = 1.5

Cyst.kExtents = Vector(0.2, 0.1, 0.2)

Cyst.kBurstDuration = 3

// range at which we can be a parent
Cyst.kCystMaxParentRange = kCystMaxParentRange

// size of infestation patch
Cyst.kInfestationRadius = kInfestationRadius
Cyst.kInfestationGrowthDuration = Cyst.kInfestationRadius / kCystInfestDuration

Cyst.MinimumKingShifts = 4

local networkVars =
{

    // Since cysts don't move, we don't need the fields to be lag compensated
    // or delta encoded
    m_origin = "position (by 0.05 [], by 0.05 [], by 0.05 [])",
    m_angles = "angles (by 0.1 [], by 10 [], by 0.1 [])",
    isKing = "boolean",
    level = "float (0 to " .. Cyst.MaxLevel .. " by .1)",
    wasking = "boolean",
    lastumbra = "time",
    MinKingShifts = "float (0 to " .. Cyst.MinimumKingShifts .. " by 1)",
    UpdatedEggs = "boolean",
    occupiedid = "entityid",
    spawnedbabblers = "float",

}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(PointGiverMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)

if Server then
    Script.Load("lua/Cyst_Server.lua")
end

function Cyst:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, UmbraMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, CloakableMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, DetectableMixin)
    
    if Server then
    
        InitMixin(self, SpawnBlockMixin)
        self:UpdateIncludeRelevancyMask()
        
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
    end

    self:SetPhysicsCollisionRep(CollisionRep.Move)
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
    self:SetLagCompensated(false)
    self.isKing = false
    self.level = 0
    self.wasking = false
    self.lastumbra = 0
    self.MinKingShifts = 0
    self.UpdatedEggs = false
    self.occupiedid =  Entity.invalidI
    self.spawnedbabblers = 0
end


function Cyst:GetShowSensorBlip()
    return false
end


function Cyst:OnInitialized()

    InitMixin(self, InfestationMixin)
    
    ScriptActor.OnInitialized(self)
    


    if Server then
        InitMixin(self, SleeperMixin)
        InitMixin(self, StaticTargetMixin)
        
        self:SetModel(Cyst.kModelName, Cyst.kAnimationGraph)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then    
    
        InitMixin(self, UnitStatusMixin)
        self:AddTimedCallback(Cyst.OnTimedUpdate, 0)
        // note that even though a Client side cyst does not do OnUpdate, its mixins (cloakable mixin) requires it for
        // now. If we can change that, then cysts _may_ be able to skip OnUpdate
         
    end   
    
    
    InitMixin(self, IdleMixin)
    
end

function Cyst:GetPlayIdleSound()
    return self:GetIsBuilt() and self:GetCurrentInfestationRadiusCached() < 1
end



function Cyst:GetInfestationGrowthRate()
    return Cyst.kInfestationGrowthDuration
end
function Cyst:OnConstructionComplete()
    self:AddTimedCallback(Cyst.EnergizeInRange, 4)
    self:AttractWhipsCrags()
   -- self:AddTimedCallback(Cyst.AttractWhipsCrags, 8)
end
function Cyst:AttractWhipsCrags()
   local mate = Shared.GetEntity(self.occupiedid)
    if not self.isking and not mate then
       --Print("Mating Ritual Attempting.. :O ")
     local kingcyst = GetNearest(self:GetOrigin(), "Cyst", 2, function(ent) return ent.isking and GetLocationForPoint(ent:GetOrigin()) == GetLocationForPoint(self:GetOrigin()) end)
           if kingcyst then
                 self:MagnetizeStructures()
               --  Print("Non King found King, therefore calculating checkers  board appropriately... (fuck chess ;) )")
           end
    end
    return false
end
function Cyst:EnergizeInRange()
    if self:GetIsBuilt() and not self:GetIsOnFire() and self.isking and self:GetLevel() == self:GetMaxLevel() then
    
        local energizeAbles = GetEntitiesWithMixinForTeamWithinRange("Energize", self:GetTeamNumber(), self:GetOrigin(), kEnergizeRange)
        
        for _, entity in ipairs(energizeAbles) do
        
            if entity ~= self then
                entity:Energize(self)
                entity:SetMucousShield()
            end
            
        end
    
    end
    
    return self:GetIsAlive() and self.isking
end
function Cyst:GetLevel()
        return Round(self.level, 2)
end
function Cyst:GetExtentsOverride()
local kXZExtents = 0.2 * self:GetLevelPercentage()
local kYExtents = 0.1 * self:GetLevelPercentage()
local crouchshrink = 0
     return Vector(kXZExtents, kYExtents, kXZExtents)
end
function Cyst:ReturnFreeCystSpaceOrigin()  
     



end
 function Cyst:FindFreeSpace()  
     local spotfound = self:ReturnFreeCystSpaceOrigin()
       if spotfound ~= nil then return spotfound end 
       
      return self:FindAlternateSpace()
end
function Cyst:FindAlternateSpace()
 
        for index = 1, 100 do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), .5, 24, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == self:GetLocationName()
        
           if spawnPoint ~= nil and sameLocation then
           return spawnPoint
           end
        end
        Print("No valid spot found for kingcyst find alternatespace")
        return self:GetOrigin()
end
function Cyst:SmashCyst(exo, exo, origin, vectors)
       if self:GetIsAlive() and not self.isking and not self.wasking then
       self:Kill(exo, exo, origin, vectors)
       self:TriggerEffects("egg_death")
       DestroyEntity(self)
       end
end
function Cyst:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
 function Cyst:FindFreeSpawn()    
        for index = 1, 100 do
           local extents = Vector(0.2, 0.2, 0.2)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), kCystRedeployRange, kCystRedeployRange * 4, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == self:GetLocationName()
        
           if spawnPoint ~= nil and sameLocation then
           return spawnPoint
           end
        end
        Print("No valid spot found for cyst brother spawn!")
        return self:GetOrigin()
end
function Cyst:Derp()
                self:UpdateModelCoords()
                self:UpdatePhysicsModel()
               if (self._modelCoords and self.boneCoords and self.physicsModel) then
              self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
               end  
               self:MarkPhysicsDirty()    
end
function Cyst:OnKill(attacker, doer, point, direction)
       self:TriggerEffects("egg_death")
self:SetIsVisible(false)
if self.isking then  CreateEntity(Rupture.kMapName, self:GetOrigin(), self:GetTeamNumber()) self.isking = false self.level = 0 self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup) self:Derp() end
end
function Cyst:SetKing(whom)
   self.king = true
end 
function Cyst:GetHealthbarOffset()
    return 0.5
end 
function Cyst:ActivateMagnetize()
--Kyle Abent
                      self:Magnetize()
                      self:AddTimedCallback(Cyst.Magnetize, 8)
end
if Server then

    function Cyst:GetHasUmbra(position)
        return #GetEntitiesWithinRange("CragUmbra", self:GetOrigin(), 17) > 0
    end
    
    function Cyst:OnTakeDamage(damage, attacker, doer, point, direction, damageType)
              --suppose to be for king but kinda fits the role for all cysts
           if self:GetIsAlive() and not self:GetHasUmbra() and self:GetIsBuilt() and self:GetHealthScalar()<= 0.5 and (self.lastumbra + math.random(4,8)) < Shared.GetTime() then
                    CreateEntity(CragUmbra.kMapName,  self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
                    self:TriggerEffects("crag_trigger_umbra")
                    self.lastumbra = Shared.GetTime()
           end
           
           if self.isking then
              if self.spawnedbabblers <= 3 then
                  for i = 1, 4 - self.spawnedbabblers do
                  local babbler = CreateEntity(Babbler.kMapName,  self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
                  babbler.scale = math.random(50,100)
                  self.spawnedbabblers = Clamp(self.spawnedbabblers + 1, 0, 4)
                  end
              end
           
           end
        
    end
end
function Cyst:Synchronize()
--Kyle Abent
                     local whips, crags = self:DoICreateShadeWhipCrag()
                    if Server then
            local gameRules = GetGamerules()
            if gameRules then
                  gameRules:SynrhonizeCystEntities(whips, crags, self, self:FindFreeSpace())
                end
                end

end
function Cyst:DoICreateShadeWhipCrag()
 local whips = GetEntitiesForTeamWithinRange("Whip", 2, self:GetOrigin(), 999999)
 local crags = GetEntitiesForTeamWithinRange("Crag", 2, self:GetOrigin(), 999999)
return whips, crags
end
function Cyst:GetCanAffordEgg()
  return self:GetTeam():GetTeamResources() >= 4
end

function Cyst:GetAddXPAmount()
local value = Cyst.GainXP / 4
if Server then value = value * (GetRoundLengthToSiege()) + value end
 if self.isking then return value else return 0 end
end 
function Cyst:UpdateEggSpawn()
    
        for _, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
            if hive:GetIsAlive() then
                hive:GenerateEggSpawns(true, self:GetLocationName(), self)
                break
            end
        end
end
function Cyst:Magnetize()
--Kyle Abent
 if self:GetLevel() ~= self:GetMaxLevel() then return true end--Be fully grown king first
 
         --   Print("Kingcyst Magnetsize Activated")
            
   for _, cyst in ipairs(GetEntitiesForTeamWithinRange("Cyst", 2, self:GetOrigin(), 48)) do
               if cyst:GetIsAlive() then 
              -- Print("Kingcyst telling cyst to attact whips crags")
                 cyst:AddTimedCallback(Cyst.AttractWhipsCrags, math.random(1,4) )
               end
      end
          
          
          self:AddTimedCallback(Cyst.Cook, 4)
          self:Synchronize()
          self.MinKingShifts = Clamp(self.MinKingShifts + 1, 0, Cyst.MinimumKingShifts)
          if not self.UpdatedEggs then self.UpdatedEggs = true self:UpdateEggSpawn()  end
          return self.isking
end

function Cyst:GetCanDethrone()
      return self.MinKingShifts == Cyst.MinimumKingShifts
end
function Cyst:Dethrone()
                      self.isking = false
                      self.wasking = true
                      self.UpdatedEggs = false
end
function Cyst:MagnetizeStructures()

      if self.isking then
         return self:KingRules()
      else
        return self:NonKingRules()
     end          

end
function Cyst:KingRules()
          for index, Tunnel in ipairs(GetEntitiesForTeam("TunnelEntrance", 2)) do
               if Tunnel:GetIsBuilt() and self:GetDistance(Tunnel) >= 24 then 
               Tunnel:GiveOrder(kTechId.Move, self:GetId(), self:GetOrigin(), nil, true, true) 
                end
          end
          for index, crag in ipairs(GetEntitiesForTeam("Crag", 2)) do
               if crag:GetIsBuilt() and self:GetDistance(crag) >= 24 then 
               crag:GiveOrder(kTechId.Move, self:GetId(), self:GetOrigin(), nil, true, true) 
                end
          end
          for index, whip in ipairs(GetEntitiesForTeam("Whip", 2)) do
               if whip:GetIsBuilt() and self:GetDistance(whip) >= 24 then 
               whip:GiveOrder(kTechId.Move, self:GetId(), self:GetOrigin(), nil, true, true) 
                end
          end
end  
function Cyst:SetOccupied(who, istrue)
--It's True, It's True!

if istrue then
   self.occupiedid = who:GetId()
else
self.occupiedid =  Entity.invalidI
end



end
function Cyst:NonKingRules()
--Kyle Abent
  -- Print("Non king rules")
    local mate = Shared.GetEntity(self.occupiedid)
   if not mate then
     local entities = {}
       
          for index, crag in ipairs(GetEntitiesForTeam("Crag", 2)) do
                  if  crag:GetCanOccupy(self) and crag:GetEligableForBeacon(self) then 
                local success = false 
                success = table.insert(entities,crag)
                   if  success then break end
                end
          end
    
          for index, whip in ipairs(GetEntitiesForTeam("Whip", 2)) do
                  if  whip:GetCanOccupy(self) and whip:GetEligableForBeacon(self) then 
                 local success = false 
                success = table.insert(entities,whip)
                   if success then break end
                end
          end
      
       
    if #entities == 0 then return end  
     
      local entity = table.random(entities)
      
       if entity then
           if entity:GetCanOccupy(self) and entity:GetEligableForBeacon(self) then 
             local success = false 
             success = entity:TriggerBeacon(self:GetOrigin()) 
             if success then self:SetOccupied(entity, true)  entity:SetIsOccupying(self, true) end --Print("Cyst `ing entity!!!")  end
            end
        end
        
 end
   
   
   return self:GetIsAlive()
   
end  
  function Cyst:Cook()
         for index, Egg in ipairs(GetEntitiesForTeam("Egg", 2)) do
               if self:GetDistance(Egg) >= 22 and (self.isking and self:GetLevel() == self:GetMaxLevel()) and self:GetCanAffordEgg() and Egg:GetCanBeacon() then 
               Egg:TriggerEggBeacon(self:FindEggSpawn())
              self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources()  - 4)
                end
          end
  
     return false
  end
       function Cyst:FindEggSpawn()    
        for index = 1, 100 do
           local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), .5, 7, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == self:GetLocationName()
        
           if spawnPoint ~= nil and sameLocation then
           return spawnPoint
           end
       end
           Print("No valid spot found for egg beacon!")
           return self:GetOrigin()
    end
  /*
    function Cyst:CookThisOneSlow(egg)
           if egg then egg:SetOrigin(self:FindFreeSpace(false)) end
    end
    
   */
  function Cyst:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
        if self.isking == true then
            unitName = string.format(Locale.ResolveString("King Cyst"))
        else
        unitName = string.format(Locale.ResolveString("Cyst"))
   end
return unitName
end 
function Cyst:GetLevelPercentage()
return self.level / Cyst.MaxLevel * Cyst.ScaleSize
end
function Cyst:GetMaxLevel()
return Cyst.MaxLevel
end
function Cyst:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self:GetLevelPercentage()
       if scale >= 1 then
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    end
    return coords
end
function Cyst:AddXP(amount)

    local xpReward = 0
        xpReward = math.min(amount, Cyst.MaxLevel - self.level)
        self.level = self.level + xpReward
        local bonus = (420 * (self.level/100) + 420)
        bonus = Clamp(bonus, 420, 1000)
        bonus = bonus * 4 
        self:AdjustMaxHealth( bonus )
      //  self:AdjustMaxArmor(Clamp(420 * (self.level/100) + 420), 420, 500)
        
   
    return xpReward
    
end
function Cyst:LoseXP(amount)

        self.level = Clamp(self.level - amount, 0, 50)
        
        local bonus = (420 * (self.level/100) + 420)
        bonus = Clamp(bonus, 420, 1000)
        self:AdjustMaxHealth( bonus )
    
end
/**
 * Infestation never sights nearby enemy players.
 */
function Cyst:OverrideCheckVision()
    return false
end

function Cyst:GetIsFlameAble()
    return true
end
function Cyst:GetCanSleep()
    return true
end    

function Cyst:GetTechButtons(techId)
  
    return  { kTechId.Infestation,  kTechId.None, kTechId.None, kTechId.None,
              kTechId.None, kTechId.None, kTechId.None, kTechId.None }

end

function Cyst:GetInfestationRadius()
    return kInfestationRadius
end

function Cyst:GetInfestationMaxRadius()
    return kInfestationRadius
end


function Cyst:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end




function Cyst:OnOverrideSpawnInfestation(infestation)

    infestation.maxRadius = kInfestationRadius
    // New infestation starts partially built, but this allows it to start totally built at start of game 
    local radiusPercent = math.max(infestation:GetRadius(), .2)
    infestation:SetRadiusPercent(radiusPercent)
    
end

function Cyst:GetReceivesStructuralDamage()
    return true
end

local function ServerUpdate(self, deltaTime)

    if not self:GetIsAlive() then
        return
    end
    
    if self.bursted then    
        self.bursted = self.timeBursted + Cyst.kBurstDuration > Shared.GetTime()    
    end
    
end


if Server then
  
    function Cyst:OnUpdate(deltaTime)

        PROFILE("Cyst:OnUpdate")
        
        ScriptActor.OnUpdate(self, deltaTime)
        
        if self:GetIsAlive() then
            
            ServerUpdate(self, deltaTime)
            
            local time = Shared.GetTime()
            if self.timeoflastkingdate == nil or (time > self.timeoflastkingdate + 1) then
               if self.isking then
                self:AddXP(Cyst.GainXP)
                self:Derp()
                elseif self.wasking then
                self:LoseXP(Cyst.GainXP)
                self:Derp()
                end
                self.timeoflastkingdate = time
            end
            
               
        else
        
            local destructionAllowedTable = { allowed = true }
            if self.GetDestructionAllowed then
                self:GetDestructionAllowed(destructionAllowedTable)
            end
            
            if destructionAllowedTable.allowed then
                DestroyEntity(self)
            end
        
        end
        
    end
    
elseif Client then
    
    // avoid using OnUpdate for cysts, instead use a variable timed callback
    function Cyst:OnTimedUpdate(deltaTime)
      
      PROFILE("Cyst:OnTimedUpdate")
      return kUpdateIntervalLow
      
    end

end

function Cyst:GetIsHealableOverride()
  return self:GetIsAlive() 
end



function Cyst:SetIncludeRelevancyMask(includeMask)

    includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)    
    ScriptActor.SetIncludeRelevancyMask(self, includeMask)    

end


Shared.LinkClassToMap("Cyst", Cyst.kMapName, networkVars)

class 'AttachedCyst' (Cyst)
AttachedCyst.kMapName = "attached_cyst"

function AttachedCyst:GetInfestationRadius()
    return 0
end

Shared.LinkClassToMap("AttachedCyst", AttachedCyst.kMapName, { })
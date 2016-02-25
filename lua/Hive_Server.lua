// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Hive_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Send out an impulse to maintain infestations every 10 seconds.
local kImpulseInterval = 10

local kHiveDyingThreshold = 0.4

local kCheckLowHealthRate = 12

// A little bigger than we might expect because the hive origin isn't on the ground
local kEggMinRange = 4
local kEggMaxRange = 22
function Hive:HasShadeHive()
      local hives = GetEntitiesWithinRange("ShadeHive", self:GetOrigin(), 999)
   if #hives >=1 then return true end
   return false
end
function Hive:OnResearchComplete(researchId)

    local success = false
    local hiveTypeChosen = false
    self.biomassResearchFraction = 0
    
    local newTechId = kTechId.Hive
    
    if researchId == kTechId.UpgradeToCragHive then
    
        success = self:UpgradeToTechId(kTechId.CragHive)
        newTechId = kTechId.CragHive
        hiveTypeChosen = true
        
    elseif researchId == kTechId.UpgradeToShadeHive then
        success = self:UpgradeToTechId(kTechId.ShadeHive)
        newTechId = kTechId.ShadeHive
        hiveTypeChosen = true
    elseif researchId == kTechId.UpgradeToShiftHive then
    
        success = self:UpgradeToTechId(kTechId.ShiftHive)
        newTechId = kTechId.ShiftHive
        hiveTypeChosen = true
    end
    
    if success and hiveTypeChosen then

        // Let gamerules know for stat tracking.
        GetGamerules():SetHiveTechIdChosen(self, newTechId)
        
    end   
    
end

local kResearchTypeToHiveType =
{
    [kTechId.UpgradeToCragHive] = kTechId.CragHive,
    [kTechId.UpgradeToShadeHive] = kTechId.ShadeHive,
    [kTechId.UpgradeToShiftHive] = kTechId.ShiftHive,
}
function Hive:OnResearchCancel(researchId)

    if kResearchTypeToHiveType[researchId] then
    
        local hiveTypeTechId = kResearchTypeToHiveType[researchId]
        local team = self:GetTeam()
        
        if team then
        
            local techTree = team:GetTechTree()
            local researchNode = techTree:GetTechNode(hiveTypeTechId)
            if researchNode then
            
                researchNode:ClearResearching()
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
         
            end
            
        end    
        
    end

end


function Hive:SetFirstLogin()
    self.isFirstLogin = true
end

function Hive:OnCommanderLogin( commanderPlayer, forced )
    CommandStructure.OnCommanderLogin( self, commanderPlayer, forced )
    
    if self.isFirstLogin then
        for i = 1, kInitialDrifters do
            self:CreateManufactureEntity(kTechId.Drifter)
        end
        
        self.isFirstLogin = false
    end
    
end
function Hive:MarineOrders()
    for _, player in ipairs(GetEntitiesWithinRange("Marine", self:GetOrigin(), 999)) do
        if player:GetIsAlive() and not player:isa("Commander") then
           player:GiveOrder(kTechId.Attack, self:GetId(), self:GetOrigin(), nil, true, true)
        end
              
    end   // Create marine order
end
function Hive:OnDestroy()

    local team = self:GetTeam()
    
    if team then
        team:OnHiveDestroyed(self)
    end
    
    CommandStructure.OnDestroy(self)
    self:UpdateAliensWeaponsManually()
    
    local team = self:GetTeam()
        if team then
            team:OnUpgradeChamberDestroyed(self)
        end
        
end
function Hive:GetCanBeUsedConstructed(byPlayer)
    return false
end
function Hive:GetTeamType()
    return kAlienTeamType
end

// Aliens log in to hive instantly
function Hive:GetWaitForCloseToLogin()
    return false
end

// Hives building can't be sped up
function Hive:GetCanConstructOverride(player)
    return false
end

local function UpdateHealing(self)
    if GetIsUnitActive(self) and not self:GetGameEffectMask(kGameEffect.OnFire) then
    
        if self.timeOfLastHeal == nil or Shared.GetTime() > (self.timeOfLastHeal + Hive.kHealthUpdateTime) then
            
            local players = GetEntitiesForTeam("Player", self:GetTeamNumber())
            
            for index, player in ipairs(players) do
            
                if player:GetIsAlive() and ((player:GetOrigin() - self:GetOrigin()):GetLength() < Hive.kHealRadius) then   
                    // min healing, affects skulk only         
                      //if player.GetLocationName and not ( string.find(player:GetLocationName(), "siege") or string.find(player:GetLocationName(), "Siege") ) then
                    player:AddHealth(math.max(10, player:GetMaxHealth() * Hive.kHealthPercentage), true )                
                     // end
                end
                
            end
            
            self.timeOfLastHeal = Shared.GetTime()
            
        end
        
    end
    
end

local function GetNumEggs(self)

    local numEggs = 0
    local eggs = GetEntitiesForTeam("Egg", self:GetTeamNumber())
    
    for index, egg in ipairs(eggs) do
    
        if egg:GetLocationName() == self:GetLocationName() and egg:GetIsAlive() and egg:GetIsFree() and not egg.manuallySpawned then
            numEggs = numEggs + 1
        end
        
    end
    
    return numEggs
    
end

local function SpawnEgg(self, eggCount)

    if self.eggSpawnPoints == nil or #self.eggSpawnPoints == 0 then
    
        //Print("Can't spawn egg. No spawn points!")
        return nil
        
    end

    if not eggCount then
        eggCount = 0
    end

    for i = 1, #self.eggSpawnPoints do

        local position = eggCount == 0 and table.random(self.eggSpawnPoints) or self.eggSpawnPoints[i]  

        // Need to check if this spawn is valid for an Egg and for a Skulk because
        // the Skulk spawns from the Egg.
        local validForEgg = GetIsPlacementForTechId(position, false, kTechId.Egg)
        local validForSkulk = GetIsPlacementForTechId(position, false, kTechId.Skulk)

        // Prevent an Egg from spawning on top of a Resource Point.
        local notNearResourcePoint = #GetEntitiesWithinRange("ResourcePoint", position, 2) == 0
        
        if validForEgg and validForSkulk and notNearResourcePoint then
        
            local egg = CreateEntity(Egg.kMapName, position, self:GetTeamNumber())
            egg:SetHive(self)
            

            if egg ~= nil then
            
                // Randomize starting angles
                local angles = self:GetAngles()
                angles.yaw = math.random() * math.pi * 2
                egg:SetAngles(angles)
                
                // To make sure physics model is updated without waiting a tick
                egg:UpdatePhysicsModel()
                
                self.timeOfLastEgg = Shared.GetTime()
                
                return egg
                
            end
            
        end

    
    end
    
    return nil
    
end

local function CreateDrifter(self, commander)

    local drifter = CreateEntity(Drifter.kMapName, self:GetOrigin(), self:GetTeamNumber())
    drifter:SetOwner(commander)
    drifter:ProcessRallyOrder(self)
    
    local function RandomPoint()
        local angle = math.random() * math.pi*2
        local startPoint = drifter:GetOrigin() + Vector( math.cos(angle)*Drifter.kStartDistance , Drifter.kHoverHeight, math.sin(angle)*Drifter.kStartDistance )
        return startPoint
    end
    
    local direction = Vector(drifter:GetAngles():GetCoords().zAxis)

    local finalPoint = Pathing.GetClosestPoint(RandomPoint())
    
    local points = {}    
    local isBlocked = Pathing.IsBlocked(self:GetModelOrigin(), finalPoint)
    
    local maxTries = 100
    local numTries = 0
    
    while (isBlocked and numTries < maxTries) do        
        finalPoint = Pathing.GetClosestPoint(RandomPoint())
        isBlocked = Pathing.IsBlocked(self:GetModelOrigin(), finalPoint)
        numTries = numTries + 1
    end

    drifter:SetOrigin(finalPoint)
    local angles = Angles()
    angles.yaw = math.random() * math.pi * 2
    drifter:SetAngles(angles) 
    
    return drifter

end

function Hive:GetIsHealableOverride()

return self:GetCanBeHealedOverride()

end
function Hive:GetIsSuddenDeathEnabled()
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetIsSuddenDeath() then 
                   return true
               end
            end
            return false
end
function Hive:GetGameStartedHive()
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() then 
                   return true
               end
            end
            return false
end
/*
function Hive:GetCanBeHealedOverride()
    return not self:GetIsSuddenDeathEnabled() and self:GetIsAlive()
end
function Hive:GetAddConstructHealth()
return not self:GetIsSuddenDeathEnabled()
end
*/
function Hive:PerformActivation(techId, position, normal, commander)

    local success = false
    local continue = true
    

    if techId == kTechId.ShiftHatch then
    
        local egg = nil
    
        for j = 1, kEggsPerHatch do    
            egg = SpawnEgg(self, eggCount)        
        end
        
        success = egg ~= nil
        continue = not success
        
        if egg then
            egg.manuallySpawned = true
        end
        
        if success then
            self:TriggerEffects("hatch")
        end
        
    elseif techId == kTechId.Drifter then
    
        success = CreateDrifter(self, commander) ~= nil
        continue = not success
    
    end
    
    return success, continue

end

function Hive:UpdateSpawnEgg()

    local success = false
    local egg = nil

    local eggCount = GetNumEggs(self)
    if eggCount < 8 then  
         for i = 1, 8 - eggCount do
        SpawnEgg(self, eggCount)
         end
    end
    
    return true

end

// Spawn a new egg around the hive if needed. Returns true if it did.
local function UpdateEggs(self)

    local createdEgg = false
    
    // Count number of eggs nearby and see if we need to create more, but only every so often
    local eggCount = GetNumEggs(self)
    if GetCanSpawnEgg(self) and eggCount < kAlienEggsPerHive then
        createdEgg = SpawnEgg(self) ~= nil
    end 
    
    return createdEgg
    
end

local function FireImpulses(self) 

    local now = Shared.GetTime()
    
    if not self.lastImpulseFireTime then
        self.lastImpulseFireTime = now
    end    
    
    if now - self.lastImpulseFireTime > kImpulseInterval then
    
        local removals = {}
        for key, id in pairs(self.cystChildren) do
        
            local child = Shared.GetEntity(id)
            if child == nil then
                removals[key] = true
            else
                if child.TriggerImpulse and child:isa("Cyst") then
                    child:TriggerImpulse(now)
                else
                    Print("Hive.cystChildren contained a: %s", ToString(child))
                    removals[key] = true
                end
            end
            
        end
        
        for key,_ in pairs(removals) do
            self.cystChildren[key] = nil
        end
        
        self.lastImpulseFireTime = now
        
    end
    
end

local function CheckLowHealth(self)

    if not self:GetIsAlive() then
        return
    end
    
    local inCombat = self:GetIsInCombat()
    if inCombat and (self:GetHealth() / self:GetMaxHealth() < kHiveDyingThreshold) then
    
        // Don't send too often.
        self.lastLowHealthCheckTime = self.lastLowHealthCheckTime or 0
        if Shared.GetTime() - self.lastLowHealthCheckTime >= kCheckLowHealthRate then
        
            self.lastLowHealthCheckTime = Shared.GetTime()
            
            // Notify the teams that this Hive is close to death.
            SendGlobalMessage(kTeamMessageTypes.HiveLowHealth, self:GetLocationId())
            
        end
        
    end
    
end

function Hive:OnEntityChange(oldId, newId)

    CommandStructure.OnEntityChange(self, oldId, newId)
    
end
function Hive:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)
local damage = 1
          local gameRules = GetGamerules()
          if not gameRules:GetSiegeDoorsOpen() and not gameRules:GetFrontDoorsOpen() and attacker:GetTeamNumber() == 1 then
             damage = self:GetHealth()
           end
  damageTable.damage = damageTable.damage * damage 
end
function Hive:OnUpdate(deltaTime)

    PROFILE("Hive:OnUpdate")
    
    CommandStructure.OnUpdate(self, deltaTime)
    
    UpdateHealing(self)
    
    FireImpulses(self)
    
    CheckLowHealth(self)
    //if Server then self:UpdatePassive() end
    if not self:GetIsAlive() then
    
        local destructionAllowedTable = { allowed = true }
        if self.GetDestructionAllowed then
            self:GetDestructionAllowed(destructionAllowedTable)
        end
        
        if destructionAllowedTable.allowed then
            DestroyEntity(self)
        end
        
    end    
    
end
function Hive:OnKill(attacker, doer, point, direction)

    CommandStructure.OnKill(self, attacker, doer, point, direction)
    self:UpdateAliensWeaponsManually()
    --Destroy the attached evochamber
    local evoChamber = self:GetEvolutionChamber()
    if evoChamber then
        evoChamber:OnKill()
        DestroyEntity(evoChamber)
        self.evochamberid = -1
    end
   
        
    -- Notify the teams that this Hive was destroyed.
    SendGlobalMessage(kTeamMessageTypes.HiveKilled, self:GetLocationId())
    self.bioMassLevel = 0
    
    self:SetModel(nil)    
    
    /*
                   local team = self:GetTeam()
        if team then
         team:UpdateBioMassLevel()
           team:OnUpgradeChamberDestroyed(self)
         end
    */
    
     GetGamerules():SpawnNewHive(self:GetOrigin())
     
end

function Hive:GenerateEggSpawns(haskingcyst, kingcystlocation,saidcyst)
    PROFILE("Hive:GenerateEggSpawns")
    self.eggSpawnPoints = { }
    local minNeighbourDistance = 1.5
    local maxEggSpawns = 20
    local maxAttempts = maxEggSpawns * 10
    for index = 1, maxAttempts do
        local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
        local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
        local whichtochoose = self:GetModelOrigin()
        whichtochoose = ConditionalValue(haskingcyst, saidcyst:GetModelOrigin(), whichtochoose)
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, whichtochoose, kEggMinRange, kEggMaxRange, EntityFilterAll())
        
        if spawnPoint ~= nil then
            spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
        end
        
        local location = spawnPoint and GetLocationForPoint(spawnPoint)
        local locationName = location and location:GetName() or ""
        
        local sameLocation = spawnPoint ~= nil and locationName == ConditionalValue(haskingcyst, saidcyst:GetLocationName(), self:GetLocationName())
        
        if spawnPoint ~= nil and sameLocation then
        
            local tooCloseToNeighbor = false
            for _, point in ipairs(self.eggSpawnPoints) do
            
                if (point - spawnPoint):GetLengthSquared() < (minNeighbourDistance * minNeighbourDistance) then
                
                    tooCloseToNeighbor = true
                    break
                    
                end
                
            end
            
            if not tooCloseToNeighbor then
            
                table.insert(self.eggSpawnPoints, spawnPoint)
                if #self.eggSpawnPoints >= maxEggSpawns then
                    break
                end
                
            end
            
        end
        
    end
    
    if #self.eggSpawnPoints < kAlienEggsPerHive then
        Print("Hive in location \"%s\" only generated %d egg spawns (needs %d). Make room more open.", hiveLocationName, table.count(self.eggSpawnPoints), kAlienEggsPerHive)
    end
    
end
 function Hive:FindFreeSpace()    
        for index = 1, 24 do
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
        Print("No valid spot found for hive FindFreeSpace")
        return self:GetModelOrigin()
end
function Hive:GetDefenseEntsInRange()
 local shifts = GetEntitiesForTeamWithinRange("Shift", 2, self:GetOrigin(), 24)
 local crags = GetEntitiesForTeamWithinRange("Crag", 2, self:GetOrigin(), 24)
 local shades = GetEntitiesForTeamWithinRange("Shade", 2, self:GetOrigin(), 24)
return shifts, crags, shades
end

function Hive:OnOverrideSpawnInfestation(infestation)

    infestation.hostAlive = true
    infestation:SetMaxRadius(kHiveInfestationRadius)
    
end

function Hive:GetDamagedAlertId()

    // Trigger "hive dying" on less than 40% health, otherwise trigger "hive under attack" alert every so often
    if self:GetHealth() / self:GetMaxHealth() < kHiveDyingThreshold then
        return kTechId.AlienAlertHiveDying
    else
        return kTechId.AlienAlertHiveUnderAttack
    end
    
end

function Hive:OnTakeDamage(damage, attacker, doer, point)

    if damage > 0 then

        local time = Shared.GetTime()
        if self:GetIsAlive() and self.lastHiveFlinchEffectTime == nil or (time > (self.lastHiveFlinchEffectTime + 1)) then

            // Play freaky sound for team mates
            local team = self:GetTeam()
            team:PlayPrivateTeamSound(Hive.kWoundAlienSound, self:GetModelOrigin())
            
            // ...and a different sound for enemies
            local enemyTeamNumber = GetEnemyTeamNumber(team:GetTeamNumber())
            local enemyTeam = GetGamerules():GetTeam(enemyTeamNumber)
            if enemyTeam ~= nil then
                enemyTeam:PlayPrivateTeamSound(Hive.kWoundSound, self:GetModelOrigin())
            end
            
            // Trigger alert for Commander
            team:TriggerAlert(kTechId.AlienAlertHiveUnderAttack, self)
            
            self.lastHiveFlinchEffectTime = time
            
        end
        
        // Update objective markers because OnSighted isn't always called
        local attached = self:GetAttached()
        if attached then
            attached.showObjective = true
        end
    
    end
    
end

function Hive:OnTeleportEnd()

    local attachedTechPoint = self:GetAttached()
    if attachedTechPoint then
        attachedTechPoint:SetIsSmashed(true)
    end
    
    // lets the old infestation die and creates a new one
    self:SpawnInfestation()
    
    local commander = self:GetCommander()
    
    if commander then
    
        // we assume onos extents for now, save lastExtents in commander
        local extents = LookupTechData(kTechId.Onos, kTechDataMaxExtents, nil)
        local randomSpawn = GetRandomSpawnForCapsule(extents.y, extents.x, self:GetOrigin(), 2, 4, EntityFilterAll())
        commander.lastGroundOrigin = randomSpawn
        
    end
    
    for key, id in pairs(self.cystChildren) do
    
        local child = Shared.GetEntity(id)
        if child then
            child.parentId = Entity.invalidId
        end
        
    end
    
    self.cystChildren = { }
    
end

function Hive:GetCompleteAlertId()
    return kTechId.AlienAlertHiveComplete
end

function Hive:SetAttached(structure)

    CommandStructure.SetAttached(self, structure)
    
    self.extendAmount = structure:GetExtendAmount()
    
    if self:GetIsBuilt() then
        structure:SetIsSmashed(true)
    end
    
end

function Hive:UpdateAliensWeaponsManually() ///Seriously this makes more sense than spamming some complicated formula every 0.5 seconds no?
    if not self:GetGameStartedHive() then return end
 for _, alien in ientitylist(Shared.GetEntitiesWithClassname("Alien")) do 
        alien:HiveCompleteSoRefreshTechsManually() 
   end
end
function Hive:AutoUpgrade()
        if GetShellLevel(2) == 0  then
           self:UpgradeToTechId(kTechId.CragHive)
           local team = self:GetTeam()
           if team then
           team:OnUpgradeChamberConstructed(self)
           end
        else 
           self:UpgradeToTechId(kTechId.ShadeHive)
           local team = self:GetTeam()
           if team then
           team:OnUpgradeChamberConstructed(self)
           end
        end
        return false
end
function Hive:SpawnTunnel()

local count = 0 

             for index, pherome in ientitylist(Shared.GetEntitiesWithClassname("TunnelEntrance")) do
                   count = count + 1
              end
              
              if count <= 2 then
                                  local entranceorigin = self:FindFreeSpace()
                                  local entrance = CreateEntity(TunnelEntrance.kMapName, entranceorigin, 2) 
                                  local exitorigin = self:FindFreeSpace()
                                  local exit = CreateEntity(TunnelEntrance.kMapName, exitorigin, 2) 
              end
              
              return true
              
              
              
end
function Hive:OnConstructionComplete()

    self.bioMassLevel = 4   

         local commander = self:GetTeam():GetCommander()
       if commander ~= nil then
       commander:AddScore(8) 
       end
               local team = self:GetTeam()
        if team then
         team:UpdateBioMassLevel()
         end
       --  self:AddTimedCallback(Hive.SpawnTunnel, 8)  
    if not GetGamerules():GetFrontDoorsOpen() then

  //  self:AddTimedCallback(Hive.AutoUpgrade, 4)
    end
    
    // Play special tech point animation at same time so it appears that we bash through it.
    local attachedTechPoint = self:GetAttached()
    if attachedTechPoint then
        attachedTechPoint:SetIsSmashed(true)
    else
        Print("Hive not attached to tech point")
    end
    
    local team = self:GetTeam()
    
    if team then
        team:OnHiveConstructed(self)
    end
    self:UpdateAliensWeaponsManually()
    
    --cheap maphack to raise height in ns2_epicsiege ;)
   --self:SetOrigin(self:GetOrigin() + Vector(0,kHiveMoveUpVector,0) )
    self:AddTimedCallback(Hive.UpdateSpawnEgg, 8)
   
    
end

function Hive:GetIsPlayerValidForCommander(player)
    return player ~= nil and player:isa("Alien") and CommandStructure.GetIsPlayerValidForCommander(self, player)
end

function Hive:GetCommanderClassName()
    return AlienCommander.kMapName   
end

function Hive:AddChildCyst(child)
    self.cystChildren["" .. child:GetId()] = child:GetId()
end
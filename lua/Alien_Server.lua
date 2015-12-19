// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Alien_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/AlienUpgradeManager.lua")


function Alien:TriggerEnzyme(duration)

    if not self:GetIsOnFire() then
        self.timeWhenEnzymeExpires = duration + Shared.GetTime()
    end
    
end
function Alien:TriggerFireProofEnzyme(duration)

        self.timeWhenEnzymeExpires = duration + Shared.GetTime()
    
end
function Alien:CancelEnzyme()

    if self.timeWhenEnzymeExpires > Shared.GetTime() then        
        self.timeWhenEnzymeExpires = Shared.GetTime()
    end
    
end
function Alien:TriggerInfiniteEnergy(duration)

        self.timeInfiniteEnergyExpires = duration + Shared.GetTime()
    
end

function Alien:Reset()

    Player.Reset(self)
    
    if self:GetTeamNumber() ~= kNeutralTeamType then
        self.oneHive = false
        self.twoHives = false
        self.threeHives = false
    end
    
end
function Alien:TunnelFailed(player)

end
function Alien:TunnelGood(player)

end
function Alien:HiveCompleteSoRefreshTechsManually()
   UpdateAbilityAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId())
end
function Alien:OnProcessMove(input)
    
    self.hasAdrenalineUpgrade = GetHasAdrenalineUpgrade(self)
    
    // need to clear this value or spectators would see the hatch effect every time they cycle through players
    if self.hatched and self.creationTime + 3 < Shared.GetTime() then
        self.hatched = false
    end
    
    Player.OnProcessMove(self, input)
    
    // In rare cases, Player.OnProcessMove() above may cause this entity to be destroyed.
    // The below code assumes the player is not destroyed.
    if not self:GetIsDestroyed() then
    
       
           self.canredeemorrebirth = Shared.GetTime() > self.lastredeemorrebirthtime  + kRedemptionCooldown 
 
        if  (GetHasRedemptionUpgrade(self) and self:GetHealthScalar() <= kRedemptionEHPThreshold ) then
                 if self.canredeemorrebirth then
                 self.canredeemorrebirth = false
                 self:RedemAlienToHive()
                 end         
           end
           
   
           
        // Calculate two and three hives so abilities for abilities      
                 
                 ///Why is this spammed every 0.5 seconds? Jesus.
     //   UpdateAbilityAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId())


        self.enzymed = self.timeWhenEnzymeExpires > Shared.GetTime()
        self.electrified = self.timeElectrifyEnds > Shared.GetTime()
        self.infiniteenergy = self.timeInfiniteEnergyExpires > Shared.GetTime()
        
        
       
         
        self:UpdateAutoHeal()
        self:UpdateSilenceLevel()
        
    end
    
end

function Alien:UpdateSilenceLevel()

    if GetHasSilenceUpgrade(self) then
        self.silenceLevel = ConditionalValue(self.RTDSilence == true, 3, GetVeilLevel(self:GetTeamNumber()))
    else
        self.silenceLevel = 0
    end

end

function Alien:UpdateAutoHeal()

    PROFILE("Alien:UpdateAutoHeal")

    if self:GetIsHealable() and ( not self.timeLastAlienAutoHeal or self.timeLastAlienAutoHeal + kAlienRegenerationTime <= Shared.GetTime() ) then

        local healRate = 1
        local hasRegenUpgrade = GetHasRegenerationUpgrade(self)
        local shellLevel = ConditionalValue(self.RTDRegen == true, 3, GetShellLevel(self:GetTeamNumber()))
        local maxHealth = self:GetBaseHealth()
        
        if hasRegenUpgrade and shellLevel > 0 then
            healRate = Clamp(kAlienRegenerationPercentage * maxHealth, kAlienMinRegeneration, kAlienMaxRegeneration) * (shellLevel/3) //* self.modelsize
        else
            healRate = Clamp(kAlienInnateRegenerationPercentage * maxHealth, kAlienMinInnateRegeneration, kAlienMaxInnateRegeneration) //* self.modelsize
        end
        
        if self:GetIsInCombat() then
            healRate = healRate * kAlienRegenerationCombatModifier
        end

        self:AddHealth(healRate, false, false, not hasRegenUpgrade)  
        self.timeLastAlienAutoHeal = Shared.GetTime()
    
    end 

end
local function GetRelocationHive(usedhive, origin, teamnumber)
    local hives = GetEntitiesForTeam("Hive", teamnumber)
	local selectedhive
	
    for i, hive in ipairs(hives) do
			selectedhive = hive
	end
	return selectedhive
end
function Alien:TeleportToHive(usedhive)
	local selectedhive = GetRelocationHive(usedhive, self:GetOrigin(), self:GetTeamNumber())
    local success = false
    if selectedhive then 
            local position = table.random(selectedhive.eggSpawnPoints)
                SpawnPlayerAtPoint(self, position)
//               Shared.Message("LOG - %s SuccessFully Redeemed", self:GetClient():GetControllingPlayer():GetUserId() )
                success = true
    end

end
function Alien:GetDamagedAlertId()
    return kTechId.AlienAlertLifeformUnderAttack
end
function Alien:OnRedeem(player)

//self:GiveItem(HallucinationCloud.kMapName)
self:AddScore(1, 0, false)
   if self:isa("Gorge") or self:isa("Lerk") then
     self.isriding = false
    
     self.drifterId = Entity.invalidI
   self.gorgeusingLerkID = Entity.invalidI
   self.lerkcarryingGorgeId = Entity.invalidI
   end
   
end
function Alien:RedemAlienToHive()
        self:TeleportToHive()
         self:OnRedeem(self:GetClient():GetControllingPlayer())
        self.lastredeemorrebirthtime = Shared:GetTime()
end
function Alien:TriggerRebirthCountDown(player)

end
function Alien:TriggerRebirth()

         //NS2Siege Writing Kyle Abent (Modified/Remixed Formula Function)
        local position = self:GetOrigin()
        local trace = Shared.TraceRay(position, position + Vector(0, -0.5, 0), CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOne(self))
        
            // Check for room
            local eggExtents = LookupTechData(kTechId.Embryo, kTechDataMaxExtents)
            local newLifeFormTechId = self:GetTechId() /// :P
            local upgradeManager = AlienUpgradeManager()
            upgradeManager:Populate(self)
             upgradeManager:AddUpgrade(lifeFormTechId)
            local newAlienExtents = LookupTechData(newLifeFormTechId, kTechDataMaxExtents)
            local physicsMask = PhysicsMask.Evolve
            
            -- Add a bit to the extents when looking for a clear space to spawn.
            local spawnBufferExtents = Vector(0.1, 0.1, 0.1)
            
             local evolveAllowed = self:GetIsOnGround() and GetHasRoomForCapsule(eggExtents + spawnBufferExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self)

            local roomAfter
            local spawnPoint
       
            // If not on the ground for the buy action, attempt to automatically
            // put the player on the ground in an area with enough room for the new Alien.
            if not evolveAllowed then
            
                for index = 1, 100 do
                
                    spawnPoint = GetRandomSpawnForCapsule(eggExtents.y, math.max(eggExtents.x, eggExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
  
                    if spawnPoint then
                        self:SetOrigin(spawnPoint)
                        position = spawnPoint
                        break 
                    end
                    
                end
            end   
            
            if not GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, self:GetOrigin() + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterOne(self)) then
           
                for index = 1, 100 do

                    roomAfter = GetRandomSpawnForCapsule(newAlienExtents.y, math.max(newAlienExtents.x, newAlienExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
                    
                    if roomAfter then
                        evolveAllowed = true
                        break
                    end

                end
                
            else
                roomAfter = position
                evolveAllowed = true
            end
            
            if evolveAllowed and roomAfter ~= nil then

                local newPlayer = self:Replace(Embryo.kMapName)
                position.y = position.y + Embryo.kEvolveSpawnOffset
                newPlayer:SetOrigin(position)
                // Clear angles, in case we were wall-walking or doing some crazy alien thing
                local angles = Angles(self:GetViewAngles())
                angles.roll = 0.0
                angles.pitch = 0.0
                newPlayer:SetOriginalAngles(angles)
                newPlayer:SetValidSpawnPoint(roomAfter)
                
                // Eliminate velocity so that we don't slide or jump as an egg
                newPlayer:SetVelocity(Vector(0, 0, 0))                
                newPlayer:DropToFloor()
                
               newPlayer:TriggerRebirthCountDown(newPlayer:GetClient():GetControllingPlayer())
               newPlayer:SetGestationData(upgradeManager:GetUpgrades(), newLifeFormTechId, 10, 10) //Skulk to X 
               
               //Spawn protective boneshield    
              //  local bonewall = CreateEntity(BoneWall.kMapName, newPlayer:GetOrigin(), 2)    
              //  bonewall.modelsize = .5
            //    StartSoundEffectForPlayer(AlienCommander.kBoneWallSpawnSound, newPlayer)
               // CreateEntity(NutrientMist.kMapName, newPlayer:GetOrigin(), 2)    
                success = true
                
                
            end    
            
    
    
    

end
function Alien:ProcessBuyAction(techIds)
    ASSERT(type(techIds) == "table")
    ASSERT(table.count(techIds) > 0)

    local success = false
    
    if GetGamerules():GetGameStarted() then
    
        local healthScalar = self:GetHealth() / self:GetMaxHealth()
        local armorScalar = self:GetMaxArmor() == 0 and 1 or self:GetArmor() / self:GetMaxArmor()
        local totalCosts = 0
        
        local upgradeIds = {}
        local lifeFormTechId = nil
        for _, techId in ipairs(techIds) do
            
            if LookupTechData(techId, kTechDataGestateName) then
                lifeFormTechId = techId
            else
                table.insertunique(upgradeIds, techId)
            end
            
        end

        local oldLifeFormTechId = self:GetTechId()
        
        local upgradesAllowed = true
        local upgradeManager = AlienUpgradeManager()
        upgradeManager:Populate(self)
        // add this first because it will allow switching existing upgrades
        if lifeFormTechId then
            upgradeManager:AddUpgrade(lifeFormTechId)
        end
        for _, newUpgradeId in ipairs(techIds) do

            if newUpgradeId ~= kTechId.None and not upgradeManager:AddUpgrade(newUpgradeId, true) then
                upgradesAllowed = false 
                break
            end
            
        end

        local position = self:GetOrigin()
        local trace = Shared.TraceRay(position, position + Vector(0, -0.5, 0), CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOne(self))
        
        if upgradesAllowed and trace.surface ~= "no_evolve" then
        
            // Check for room
            local eggExtents = LookupTechData(kTechId.Embryo, kTechDataMaxExtents)
            local newLifeFormTechId = upgradeManager:GetLifeFormTechId()
            local newAlienExtents = LookupTechData(newLifeFormTechId, kTechDataMaxExtents)
            local physicsMask = PhysicsMask.Evolve
            
            -- Add a bit to the extents when looking for a clear space to spawn.
            local spawnBufferExtents = Vector(0.1, 0.1, 0.1)
            
             local evolveAllowed = self:GetIsOnGround() and GetHasRoomForCapsule(eggExtents + spawnBufferExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self)

            local roomAfter
            local spawnPoint
       
            // If not on the ground for the buy action, attempt to automatically
            // put the player on the ground in an area with enough room for the new Alien.
            if not evolveAllowed then
            
                for index = 1, 100 do
                
                    spawnPoint = GetRandomSpawnForCapsule(eggExtents.y, math.max(eggExtents.x, eggExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
  
                    if spawnPoint then
                        self:SetOrigin(spawnPoint)
                        position = spawnPoint
                        break 
                    end
                    
                end
                

            end
            
            if not GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, self:GetOrigin() + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterOne(self)) then
           
                for index = 1, 100 do

                    roomAfter = GetRandomSpawnForCapsule(newAlienExtents.y, math.max(newAlienExtents.x, newAlienExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
                    
                    if roomAfter then
                        evolveAllowed = true
                        break
                    end

                end
                
            else
                roomAfter = position
                evolveAllowed = true
            end
            
            if evolveAllowed and roomAfter ~= nil then

                local newPlayer = self:Replace(Embryo.kMapName)
                position.y = position.y + Embryo.kEvolveSpawnOffset
                newPlayer:SetOrigin(position)
                
                // Clear angles, in case we were wall-walking or doing some crazy alien thing
                local angles = Angles(self:GetViewAngles())
                angles.roll = 0.0
                angles.pitch = 0.0
                newPlayer:SetOriginalAngles(angles)
                newPlayer:SetValidSpawnPoint(roomAfter)
                
                // Eliminate velocity so that we don't slide or jump as an egg
                newPlayer:SetVelocity(Vector(0, 0, 0))                
                newPlayer:DropToFloor()
                
                newPlayer:SetResources(upgradeManager:GetAvailableResources())
                newPlayer:SetGestationData(upgradeManager:GetUpgrades(), self:GetTechId(), self:GetHealthFraction(), self:GetArmorScalar())
                
                if oldLifeFormTechId and lifeFormTechId and oldLifeFormTechId ~= lifeFormTechId then
                    newPlayer.oneHive = false
                    newPlayer.twoHives = false
                    newPlayer.threeHives = false
                end
                
                success = true
                
            end    
            
        end
    
    end
    
    if not success then
        self:TriggerInvalidSound()
    end    
    
    return success
    
end

function Alien:GetTierOneTechId()
    return kTechId.None
end

function Alien:GetTierTwoTechId()
    return kTechId.None
end

function Alien:GetTierThreeTechId()
    return kTechId.None
end
function Alien:GetEligableForRebirth()
return Shared.GetTime() > self.lastredeemorrebirthtime  + kRedemptionCooldown 
end

function Alien:OnKill(attacker, doer, point, direction)

    Player.OnKill(self, attacker, doer, point, direction)
    
    self.storedHyperMutationCost = 0
    self.oneHive = false
    self.twoHives = false
    self.threeHives = false
    
    if self.isHallucination then
        self:TriggerEffects("death_hallucination")
        return // so it doesnt go to the death bonus. Kinda meant for them to be player only.
    end


    
end
function Alien:GetIsSiege()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   return true
               end
            end
        end
            return false
end
function Alien:CopyPlayerDataForReadyRoomFrom(player)

    local respawnMapName = ReadyRoomTeam.GetRespawnMapName(nil,player)
    local gestationMapName = respawnMapName == ReadyRoomEmbryo.kMapName and player.gestationClass or nil

    local charge = 
        ( respawnMapName == Onos.kMapName or gestationMapName == Onos.kMapName ) and 
        ( player.oneHive or GetIsTechUnlocked( player, kTechId.Charge ) )

    local sstep = 
        ( respawnMapName == Fade.kMapName or gestationMapName == Fade.kMapName ) and 
        ( player.oneHive or GetIsTechUnlocked( player, kTechId.ShadowStep ) )

    local leap = 
        ( respawnMapName == Skulk.kMapName or gestationMapName == Skulk.kMapName ) and 
        ( player.twoHives or GetIsTechUnlocked( player, kTechId.Leap ) )
        
    self.oneHive = charge or sstep
    self.twoHives = leap
    self.threeHives = not GetIsTechUnlocked( player, kTechId.Xenocide )
    self.gestationClass = gestationMapName
    
end

function Alien:CopyPlayerDataFrom(player)

    Player.CopyPlayerDataFrom(self, player)
    
    local selfInRR, playerInRR = self:GetTeamNumber() == kNeutralTeamType, player:GetTeamNumber() == kNeutralTeamType
    
    if selfInRR and not playerInRR then
        
        // copy for ready room, give the tech if they deserve it
        Alien.CopyPlayerDataForReadyRoomFrom( self, player )
        
    elseif not selfInRR and playerInRR then
        
       // don't copy Alien data from player while entering the game
       
    elseif player:isa("AlienSpectator") then
        
        // don't copy Alien data from an AlienSpectator if not going to the RR
        
    else
        
        // otherwise copy Alien data across
        
        self.oneHive = player.oneHive
        self.twoHives = player.twoHives
        self.threeHives = player.threeHives
        
      if GetHasRebirthUpgrade(self) and self.canredeemorrebirth then
      self:TriggerRebirthCountDown(self:GetClient():GetControllingPlayer())
     end
    
        self.enzymed =  player.enzymed
        
         
        /*
        if self:GetTeamType() == kAlienTeamType then
        
            self.storedHyperMutationTime = player.storedHyperMutationTime
            self.storedHyperMutationCost = player.storedHyperMutationCost
            
        end
        */        
    end
    
end
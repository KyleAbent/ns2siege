// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Marine_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local function UpdateUnitStatusPercentage(self, target)

    if HasMixin(target, "Construct") and not target:GetIsBuilt() then
        self:SetUnitStatusPercentage(target:GetBuiltFraction() * 100)
    elseif HasMixin(target, "Weldable") then
        self:SetUnitStatusPercentage(target:GetWeldPercentage() * 100)
    end

end
function Marine:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
function Marine:GetIsInSiege()
if string.find(self:GetLocationName(), "siege") or string.find(self:GetLocationName(), "Siege") then return true end
return false
end
function Marine:TriggerBeacon(location)
 if not self:GetCanBeacon() then return end
     local locationto = location      
            if HasMixin(self, "SmoothedRelevancy") then
            self:StartSmoothedRelevancy(locationto)
             end      
           self:SetOrigin(locationto)
           self.lastbeacontime = Shared.GetTime()
end
function Marine:OnConstructTarget(target)
    UpdateUnitStatusPercentage(self, target)
end

function Marine:OnWeldTarget(target)
    UpdateUnitStatusPercentage(self, target)
end


function Marine:SetUnitStatusPercentage(percentage)
    self.unitStatusPercentage = Clamp(math.round(percentage), 0, 100)
    self.timeLastUnitPercentageUpdate = Shared.GetTime()
end
function Marine:OnTakeDamage(damage, attacker, doer, point)

    if doer then
    
        if doer:isa("Grenade") and doer:GetOwner() == self then
        
            self.onGround = false
            local velocity = self:GetVelocity()
            local fromGrenade = self:GetOrigin() - doer:GetOrigin()
            local length = fromGrenade:Normalize()
            local force = Clamp(1 - (length / 4), 0, 1)
            
            if force > 0 then
                velocity:Add(force * fromGrenade)
                self:SetVelocity(velocity)
            end
            
        end

        if (doer:isa("Gore") or doer:isa("Shockwave")) then
        
            self.interruptAim = true
            self.interruptStartTime = Shared.GetTime()
            
        end
    
    end

end

function Marine:GetDamagedAlertId()
    return kTechId.MarineAlertSoldierUnderAttack
end
local function GetDroppackSoundName(techId)

    if techId == kTechId.MedPack then
        return MedPack.kHealthSound
    elseif techId == kTechId.AmmoPack then
        return AmmoPack.kPickupSound
   // elseif techId == kTechId.CatPack then
   //     return CatPack.kPickupSound
    end 
   
end
function Marine:TriggerDropPack(position, techId)

    local mapName = LookupTechData(techId, kTechDataMapName)
    local success = false
    if mapName then
    
        local droppack = CreateEntity(mapName, position, self:GetTeamNumber())
        StartSoundEffectForPlayer(GetDroppackSoundName(techId), self)
       // self:ProcessSuccessAction(techId)
        success = true
        
    end

    return success

end
function Marine:SetPoisoned(attacker)

    self.poisoned = true
    self.timePoisoned = Shared.GetTime()
    
    if attacker then
        self.lastPoisonAttackerId = attacker:GetId()
    end
    
end

function Marine:ApplyCatPack()

    self.catpackboost = true
    self.timeCatpackboost = Shared.GetTime()
    
end
function Marine:ApplyDurationCatPack(duration)

    self.catpackboost = true
    self.timeCatpackboost = Shared.GetTime() + duration
    
end
function Marine:OnEntityChange(oldId, newId)

    Player.OnEntityChange(self, oldId, newId)

    if oldId == self.lastPoisonAttackerId then
    
        if newId then
            self.lastPoisonAttackerId = newId
        else
            self.lastPoisonAttackerId = Entity.invalidId
        end
        
    end
 
end

function Marine:CopyPlayerDataFrom(player)

    Player.CopyPlayerDataFrom(self, player)
   if self:isa("JetpackMarine") then self.hasfirebullets = player.hasfirebullets end //May this prevent the always spawning with it if otherwise?
    if player.parasited and GetGamerules():GetGameStarted() then
        self.timeParasited = player.timeParasited
        self.parasited = player.parasited
        self:OnParasited()
    end
    self.timeLastBeacon = player.timeLastBeacon
end

function Marine:SetRuptured()

    self.timeRuptured = Shared.GetTime()
    self.ruptured = true
    
end

function Marine:OnSprintStart()
    if self:GetIsAlive() then
        if self:GetGenderString() == "female" then
             StartSoundEffectOnEntity(Marine.kSprintStartFemale, self)
        else 
             StartSoundEffectOnEntity(Marine.kSprintStart, self)
        end
    end
end
 
function Marine:OnSprintEnd(sprintDuration)
    if sprintDuration > 5 then
        if self:GetGenderString() == "female" then
             StartSoundEffectOnEntity(Marine.kSprintTiredEndFemale, self)
        else 
             StartSoundEffectOnEntity(Marine.kSprintTiredEnd, self)
        end
    end
end

function Marine:InitWeapons()

    Player.InitWeapons(self)
    
    self:GiveItem(Rifle.kMapName)
    self:GiveItem(Pistol.kMapName)
    self:GiveItem(Axe.kMapName)
    self:GiveItem(Builder.kMapName)
    
    self:SetQuickSwitchTarget(Pistol.kMapName)
    self:SetActiveWeapon(Rifle.kMapName)
    if GetHasTech(self, kTechId.RifleClip) then self:GetWeaponInHUDSlot(1):SetClip(75) end
end

local function GetHostSupportsTechId(forPlayer, host, techId)

    if Shared.GetCheatsEnabled() then
        return true
    end
    
    local techFound = false
    
    if host.GetItemList then
    
        for index, supportedTechId in ipairs(host:GetItemList(forPlayer)) do
        
            if supportedTechId == techId then
            
                techFound = true
                break
                
            end
            
        end
        
    end
    
    return techFound
    
end

function GetHostStructureFor(entity, techId)

    local hostStructures = {}
       table.copy(GetEntitiesForTeamWithinRange("ArmsLab", entity:GetTeamNumber(), entity:GetOrigin(), 2.5), hostStructures, true)
    table.copy(GetEntitiesForTeamWithinRange("Armory", entity:GetTeamNumber(), entity:GetOrigin(), Armory.kResupplyUseRange), hostStructures, true)
    table.copy(GetEntitiesForTeamWithinRange("PrototypeLab", entity:GetTeamNumber(), entity:GetOrigin(), PrototypeLab.kResupplyUseRange), hostStructures, true)
    
    if table.count(hostStructures) > 0 then
    
        for index, host in ipairs(hostStructures) do
        
            // check at first if the structure is hostign the techId:
            if GetHostSupportsTechId(entity,host, techId) then
                return host
            end
        
        end
            
    end
    
    return nil

end

function Marine:OnOverrideOrder(order)
    
    local orderTarget = nil
    
    if (order:GetParam() ~= nil) then
        orderTarget = Shared.GetEntity(order:GetParam())
    end
    
    // Default orders to unbuilt friendly structures should be construct orders
    if(order:GetType() == kTechId.Default and GetOrderTargetIsConstructTarget(order, self:GetTeamNumber())) then
    
        order:SetType(kTechId.Construct)
        
    elseif(order:GetType() == kTechId.Default and GetOrderTargetIsWeldTarget(order, self:GetTeamNumber())) and self:GetWeapon(Welder.kMapName) then
    
        order:SetType(kTechId.Weld)
        
    elseif order:GetType() == kTechId.Default and GetOrderTargetIsDefendTarget(order, self:GetTeamNumber()) then
    
        order:SetType(kTechId.Defend)

    // If target is enemy, attack it
    elseif (order:GetType() == kTechId.Default) and orderTarget ~= nil and HasMixin(orderTarget, "Live") and GetEnemyTeamNumber(self:GetTeamNumber()) == orderTarget:GetTeamNumber() and orderTarget:GetIsAlive() and (not HasMixin(orderTarget, "LOS") or orderTarget:GetIsSighted()) then
    
        order:SetType(kTechId.Attack)

    elseif order:GetType() == kTechId.Default then
        
        // Convert default order (right-click) to move order
        order:SetType(kTechId.Move)
        
    end
    
end

local function BuyExo(self, techId)

    local maxAttempts = 100
    for index = 1, maxAttempts do
    
        // Find open area nearby to place the big guy.
        local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
        local extents = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents)

        local spawnPoint        
        local checkPoint = self:GetOrigin() + Vector(0, 0.02, 0)
        
        if GetHasRoomForCapsule(extents, checkPoint + Vector(0, extents.y, 0), CollisionRep.Move, PhysicsMask.Evolve, self) then
            spawnPoint = checkPoint
        else
            spawnPoint = GetRandomSpawnForCapsule(extents.y, extents.x, checkPoint, 0.5, 5, EntityFilterOne(self))
        end    
            
        local weapons 

        if spawnPoint then
        
            self:AddResources(-GetCostForTech(techId))
            local weapons = self:GetWeapons()
            for i = 1, #weapons do            
                weapons[i]:SetParent(nil)            
            end
            
            local exo = nil
            
            if techId == kTechId.Exosuit then
                exo = self:GiveExo(spawnPoint)
            elseif techId == kTechId.DualMinigunExosuit then
                exo = self:GiveDualExo(spawnPoint)
            elseif techId == kTechId.ClawRailgunExosuit then
                exo = self:GiveClawRailgunExo(spawnPoint)
            elseif techId == kTechId.DualRailgunExosuit then
                exo = self:GiveDualRailgunExo(spawnPoint)
            end
            
            if exo then                
                for i = 1, #weapons do
                    exo:StoreWeapon(weapons[i])
                end            
            end
            
            exo:TriggerEffects("spawn_exo")
            
            return
            
        end
        
    end
    
    Print("Error: Could not find a spawn point to place the Exo")
    
end

kIsExoTechId = { [kTechId.Exosuit] = true, [kTechId.DualMinigunExosuit] = true,
                 [kTechId.ClawRailgunExosuit] = true, [kTechId.DualRailgunExosuit] = true }
function Marine:AttemptToBuy(techIds)

    local techId = techIds[1]
    
               if techId == kTechId.JumpPack then
                StartSoundEffectForPlayer(Marine.activatedsound, self)
            //    self:AddResources(-GetCostForTech(techId))
                self.hasjumppack = true
                return true
              elseif techId == kTechId.FireBullets then
              //  self:AddResources(-GetCostForTech(techId))
                self.hasfirebullets = true
                return true
              elseif techId == kTechId.Resupply then
                self.hasreupply = true
                return true
              elseif techId == kTechId.HeavyArmor then
               self.heavyarmor = true
                 self:SetArmorAmount()
                return true
               end
                
    local hostStructure = GetHostStructureFor(self, techId)

    if hostStructure then
    
        local mapName = LookupTechData(techId, kTechDataMapName)
        
        if mapName then
        
            Shared.PlayPrivateSound(self, Marine.kSpendResourcesSoundName, nil, 1.0, self:GetOrigin())
            
            if self:GetTeam() and self:GetTeam().OnBought then
                self:GetTeam():OnBought(techId)
            end
            
            if techId == kTechId.Jetpack then

                // Need to apply this here since we change the class.
                self:AddResources(-GetCostForTech(kJumpPackCost))
                self:GiveJetpack()
            elseif kIsExoTechId[techId] then
                BuyExo(self, techId)    
            else
            
                // Make sure we're ready to deploy new weapon so we switch to it properly.
                if self:GiveItem(mapName) then
                
                    StartSoundEffectAtOrigin(Marine.kGunPickupSound, self:GetOrigin())                    
                    return true
                    
                end
                
            end
            
            return false
            
        end
        
    end
    
    return false
    
end

// special threatment for mines and welders
function Marine:GiveItem(itemMapName)

    local newItem = nil

    if itemMapName then
        
        local continue = true
        local setActive = true
        
        if itemMapName == LayMines.kMapName then
        
            local mineWeapon = self:GetWeapon(LayMines.kMapName)
            
            if mineWeapon then
                mineWeapon:Refill(kNumMines)
                continue = false
                setActive = false
            end
            
        elseif itemMapName == Welder.kMapName then
        
            // since axe cannot be dropped we need to delete it before adding the welder (shared hud slot)
            local switchAxe = self:GetWeapon(Axe.kMapName)
            
            if switchAxe then
                self:RemoveWeapon(switchAxe)
                DestroyEntity(switchAxe)
                continue = true
            else
                continue = false // don't give a second welder
            end
        
        end
        
        if continue == true then
            return Player.GiveItem(self, itemMapName, setActive)
        end
        
    end
    
    return newItem
    
end

function Marine:DropAllWeapons()

    local weaponSpawnCoords = self:GetAttachPointCoords(Weapon.kHumanAttachPoint)
    local weaponList = self:GetHUDOrderedWeaponList()
    for w = 1, #weaponList do
    
        local weapon = weaponList[w]
        if weapon:GetIsDroppable() and LookupTechData(weapon:GetTechId(), kTechDataCostKey, 0) > 0 then
            self:Drop(weapon, true, true)
        end
        
    end
    
end
function Marine:PreOnKill(attacker, doer, point, direction)
if self.modelsize ~= 1 then self.modelsize = 1 end
end
function Marine:OnKill(attacker, doer, point, direction)
    
    local lastWeaponList = self:GetHUDOrderedWeaponList()
    self.lastWeaponList = { }
    for _, weapon in pairs(lastWeaponList) do
        table.insert(self.lastWeaponList, weapon:GetMapName())
        // If cheats are enabled, destroy the weapons so they don't drop
        if Shared.GetCheatsEnabled() and weapon:GetIsDroppable() and LookupTechData(weapon:GetTechId(), kTechDataCostKey, 0) > 0 then
            DestroyEntity(weapon)
        end
    end

    // Drop all weapons which cost resources
    self:DropAllWeapons()
    
    // Destroy remaining weapons
    self:DestroyWeapons()
    
    Player.OnKill(self, attacker, doer, point, direction)
    
    // Don't play alert if we suicide
    if attacker ~= self then
        self:GetTeam():TriggerAlert(kTechId.MarineAlertSoldierLost, self)
    end
    
    // Note: Flashlight is powered by Marine's beating heart. Eco friendly.
    self:SetFlashlightOn(false)
    self.originOnDeath = self:GetOrigin()
    
end

function Marine:GetOriginOnDeath()
    return self.originOnDeath
end

function Marine:GiveJetpack()

    local activeWeapon = self:GetActiveWeapon()
    local activeWeaponMapName = nil
    local health = self:GetHealth()
    
    if activeWeapon ~= nil then
        activeWeaponMapName = activeWeapon:GetMapName()
    end
    
    local jetpackMarine = self:Replace(JetpackMarine.kMapName, self:GetTeamNumber(), true, Vector(self:GetOrigin()))
    
    jetpackMarine:SetActiveWeapon(activeWeaponMapName)
    jetpackMarine:SetHealth(health)
    
end
function Marine:GiveMarine()

    local activeWeapon = self:GetActiveWeapon()
    local activeWeaponMapName = nil
    local health = self:GetHealth()
    
    if activeWeapon ~= nil then
        activeWeaponMapName = activeWeapon:GetMapName()
    end
    
    local jetpackMarine = self:Replace(Marine.kMapName, self:GetTeamNumber(), true, Vector(self:GetOrigin()))
    
    jetpackMarine:SetActiveWeapon(activeWeaponMapName)
    jetpackMarine:SetHealth(health)
end
    
local function StorePrevPlayer(self, exo)

    exo.prevPlayerMapName = self:GetMapName()
    exo.prevPlayerHealth = self:GetHealth()
    exo.prevPlayerMaxArmor = self:GetMaxArmor()
    exo.prevPlayerArmor = self:GetArmor()
    
end

function Marine:GiveExo(spawnPoint)

        local extraValues = {
            leftArmModuleType  = kExoModuleTypes.Claw,
            rightArmModuleType = kExoModuleTypes.Minigun,
            utilityModuleType = kExoModuleTypes.Nano,
            powerModuleType = kExoModuleTypes.None
        }
        self:Replace("exo", self:GetTeamNumber(), false, nil, extraValues)
    
end

function Marine:GiveDualExo(spawnPoint)

        local extraValues = {
            leftArmModuleType  = kExoModuleTypes.Minigun,
            rightArmModuleType = kExoModuleTypes.Minigun,
            utilityModuleType = kExoModuleTypes.Nano,
            powerModuleType = kExoModuleTypes.None,

        }
        self:Replace("exo", self:GetTeamNumber(), false, nil, extraValues)
    
end

function Marine:GiveClawRailgunExo(spawnPoint)

        local extraValues = {
            leftArmModuleType  = kExoModuleTypes.Claw,
            rightArmModuleType = kExoModuleTypes.Railgun,
            utilityModuleType = kExoModuleTypes.Nano,
            powerModuleType = kExoModuleTypes.None
        }
        self:Replace("exo", self:GetTeamNumber(), false, nil, extraValues)
    
end

function Marine:GiveDualRailgunExo(spawnPoint)

        local extraValues = {
            leftArmModuleType  = kExoModuleTypes.Railgun,
            rightArmModuleType = kExoModuleTypes.Railgun,
            utilityModuleType = kExoModuleTypes.Nano,
            powerModuleType = kExoModuleTypes.None
        }
        self:Replace("exo", self:GetTeamNumber(), false, nil, extraValues)
    
end

// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AlienUpgradeManager.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Used by client and server to determine if adding / removing upgrades is allowed.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'AlienUpgradeManager'

local function GetCanAfford(self, upgradeId)

    local cost = GetCostForTech(upgradeId)
    if cost then
        return table.contains(self.initialUpgrades, upgradeId) or self.availableResources >= cost
    end
    
    return true

end

function AlienUpgradeManager:GetLifeFormTechId()
    return self.lifeFormTechId
end

function AlienUpgradeManager:Populate(player)

    assert(player)
    assert(HasMixin(player, "Upgradable"))
    
    self.upgrades = player:GetUpgrades()
    table.insert(self.upgrades, player:GetTechId())
    
    self.availableResources = player:GetPersonalResources()
    self.initialResources = player:GetPersonalResources()
    self.lifeFormTechId = player:GetTechId()
    self.initialLifeFormTechId = player:GetTechId()
    self.teamNumber = player:GetTeamNumber()
    
    self.initialUpgrades = {}
    table.copy(self.upgrades, self.initialUpgrades)

end

function AlienUpgradeManager:UpdateResources(newResources)
    self.availableResources = self.availableResources + (newResources - self.initialResources)
    self.initialResources = newResources
end

local function GetHasCategory(currentUpgrades, categoryId)

    if not categoryId then
        return false
    end    

    for _, currentUpgradeId in ipairs(currentUpgrades) do
        
        local currentCategory = LookupTechData(currentUpgradeId, kTechDataCategory)
        if currentCategory and currentCategory == categoryId then
            return true
        end
        
    end
    
    return false

end

local function RemoveCategoryUpgrades(self, categoryId)

    local oldUpgrades = {}
    table.copy(self.upgrades, oldUpgrades)
    for _, oldUpgradeId in ipairs(oldUpgrades) do
        
        local oldCategoryId = LookupTechData(oldUpgradeId, kTechDataCategory)
        if oldCategoryId == categoryId then
            self:RemoveUpgrade(oldUpgradeId)
        end
        
    end
            
end

local function GetCostRecuperationFor(self, upgradeId)

    local costRecuperation = 0
    local categoryId = LookupTechData(upgradeId, kTechDataCategory)
    
    if LookupTechData(upgradeId, kTechDataGestateName) and not table.contains(self.initialUpgrades, self.lifeFormTechId) then
        costRecuperation = GetCostForTech(self.lifeFormTechId)
    elseif categoryId then
    
        for _, currentUpgradeId in ipairs(self.upgrades) do
        
            if LookupTechData(currentUpgradeId, kTechDataCategory) == categoryId and not table.contains(self.initialUpgrades, currentUpgradeId) then
                costRecuperation = costRecuperation + GetCostForTech(currentUpgradeId)
            end
            
        end
        
    end
    
    return costRecuperation
    
end

local function GetCostForUpgrade(self, upgradeId)

    if table.contains(self.initialUpgrades, upgradeId) and self.initialLifeFormTechId == self.lifeFormTechId then
        cost = 0
    else
        cost = LookupTechData(self.lifeFormTechId, kTechDataUpgradeCost, 0)
    end
    
    return cost
    
end

function AlienUpgradeManager:GetCanAffordUpgrade(upgradeId)

    local availableResources = self.availableResources + GetCostRecuperationFor(self, upgradeId)
    local cost = LookupTechData(upgradeId, kTechDataGestateName) and GetCostForTech(upgradeId) or GetCostForUpgrade(self, upgradeId)
    return cost <= availableResources

end

function AlienUpgradeManager:GetIsUpgradeAllowed(upgradeId, override)

    if not self.upgrades then
        self.upgrades = {}
    end

    local allowed = GetIsTechUseable(upgradeId, self.teamNumber)

    if allowed then
    
        // check if adding this upgrade is allowed
        local categoryId = LookupTechData(upgradeId, kTechDataCategory)
        if categoryId then
        
            if self.lifeFormTechId == self.initialLifeFormTechId then
                allowed = allowed and (override or table.contains(self.initialUpgrades, upgradeId) or not GetHasCategory(self.initialUpgrades, categoryId))
            end
            
        end
        
    end
    
    return allowed
    
end

function AlienUpgradeManager:RemoveUpgrade(upgradeId)

    if table.removevalue(self.upgrades, upgradeId) then

        if not table.contains(self.initialUpgrades, upgradeId) then
            self.availableResources = self.availableResources + GetCostForTech(upgradeId)
        end
    
    end

end

local function RemoveAbilities(self)

    local oldUpgrades = { }
    table.copy(self.upgrades, oldUpgrades)
    
    for _, upgradeId in ipairs(oldUpgrades) do
    
        if LookupTechData(upgradeId, kTechDataAbilityType) then
            self:RemoveUpgrade(upgradeId)
        end
        
    end
    
end

local function RestoreAbilities(self)

    for _, initialUpgradeId in ipairs(self.initialUpgrades) do
    
        if LookupTechData(initialUpgradeId, kTechDataAbilityType) then
            table.insertunique(self.upgrades, initialUpgradeId)
        end
        
    end
    
end

local function RestoreUpgrades(self)

    for _, initialUpgradeId in ipairs(self.initialUpgrades) do
    
        if not LookupTechData(initialUpgradeId, kTechDataAbilityType) and not LookupTechData(initialUpgradeId, kTechDataGestateName) then
            table.insertunique(self.upgrades, initialUpgradeId)
        end
        
    end
    
end

local function RemoveUpgrades(self)

    local oldUpgrades = self.upgrades
    self.upgrades = { }
    
    for _, upgradeId in ipairs(oldUpgrades) do
    
        if LookupTechData(upgradeId, kTechDataAbilityType) or LookupTechData(upgradeId, kTechDataGestateName) then
            table.insertunique(self.upgrades, upgradeId)
        end
        
    end
    
end

function AlienUpgradeManager:GetHasChanged()

    local changed = #self.upgrades ~= #self.initialUpgrades
    
    if not changed then
    
        for _, upgradeId in ipairs(self.upgrades) do
            
            if not table.contains(self.initialUpgrades, upgradeId) then
                changed = true
                break
            end    
            
        end
        
    end    
    
    return changed
end

function AlienUpgradeManager:AddUpgrade(upgradeId, override, iscredit)

    if not upgradeId or upgradeId == kTechId.None then
        return false
    end

    local categoryId = LookupTechData(upgradeId, kTechDataCategory)
    if override or not GetHasCategory(self.initialUpgrades, categoryId) or self.initialLifeFormTechId ~= self.lifeFormTechId then
        
        // simple remove overlapping upgrades first
        if categoryId then
            RemoveCategoryUpgrades(self, categoryId)
        end
        
    end
    
    local allowed = self:GetIsUpgradeAllowed(upgradeId, override)
    local canAfford = self:GetCanAffordUpgrade(upgradeId) or true
    
    if allowed and canAfford then
    
        local cost = 0
    
        if LookupTechData(upgradeId, kTechDataGestateName) then

            self:RemoveUpgrade(self.lifeFormTechId)
            RemoveAbilities(self)
            RemoveUpgrades(self)
            
            if table.contains(self.initialUpgrades, upgradeId) then
                RestoreAbilities(self)
                RestoreUpgrades(self)
            end
            
            self.lifeFormTechId = upgradeId
            cost = GetCostForTech(upgradeId)
            
        else        
            cost = GetCostForUpgrade(self, upgradeId)
        end
    
        table.insert(self.upgrades, upgradeId)
        self.availableResources = self.availableResources - cost

        return true
        
    end
    
    return false

end

function AlienUpgradeManager:GetHasUpgrade(upgradeId)
    return table.contains(self.upgrades, upgradeId)
end

function AlienUpgradeManager:GetUpgrades()
    return self.upgrades
end

function AlienUpgradeManager:GetAvailableResources()
    return self.availableResources
end
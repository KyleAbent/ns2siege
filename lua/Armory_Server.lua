// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Armory_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local function OnDeploy(self)

    self.deployed = true
    return false
    
end

local kDeployTime = 3
function GetCommanderForTeam(teamNumber)

    local commanders = GetEntitiesForTeam("Commander", teamNumber)
    if #commanders > 0 then
        return commanders[1]
    end    

end

function Armory:OnConstructionComplete()
    self:AddTimedCallback(OnDeploy, kDeployTime)
    
end

// west/east = x/-x
// north/south = -z/z

local indexToUseOrigin =
{
    // West
    Vector(Armory.kResupplyUseRange, 0, 0), 
    // North
    Vector(0, 0, -Armory.kResupplyUseRange),
    // South
    Vector(0, 0, Armory.kResupplyUseRange),
    // East
    Vector(-Armory.kResupplyUseRange, 0, 0)
}

function Armory:GetTimeToResupplyPlayer(player)

    assert(player ~= nil)
    
    local timeResupplied = self.resuppliedPlayers[player:GetId()]
    
    if timeResupplied ~= nil then
    
        // Make sure we haven't done this recently    
        if Shared.GetTime() < (timeResupplied + Armory.kResupplyInterval) then
            return false
        end
        
    end
    
    return true
    
end
function Armory:OnStun()
    
                local bonewall = CreateEntity(BoneWall.kMapName, self:GetOrigin(), 2)    
                bonewall.modelsize = 0.5
                bonewall:AdjustMaxHealth(bonewall:GetMaxHealth() / 2)
end
function Armory:GetShouldResupplyPlayer(player)

    if not player:GetIsAlive() then
        return false
    end
    
    if self:GetIsStunned() then
    return false
    end
    
    local isVortexed = self:GetIsVortexed() or ( HasMixin(player, "VortexAble") and player:GetIsVortexed() )
    if isVortexed then
        return false
    end    
    
    local stunned = HasMixin(player, "Stun") and player:GetIsStunned()
    
    if stunned then
        return false
    end
    
    local inNeed = false
    
    // Don't resupply when already full
    if (player:GetHealth() < player:GetMaxHealth()) or (player:GetArmor() < player:GetMaxArmor() ) then
        inNeed = true
    else

        // Do any weapons need ammo?
        for i, child in ientitychildren(player, "ClipWeapon") do
        
            if child:GetNeedsAmmo(false) then
                inNeed = true
                break
            end
            
        end
        
    end
    
    if inNeed then
    
        // Check player facing so players can't fight while getting benefits of armory
        local viewVec = player:GetViewAngles():GetCoords().zAxis

        local toArmoryVec = self:GetOrigin() - player:GetOrigin()
        
        if(GetNormalizedVector(viewVec):DotProduct(GetNormalizedVector(toArmoryVec)) > .75) then
        
            if self:GetTimeToResupplyPlayer(player) then
        
                return true
                
            end
            
        end
        
    end
    
    return false
    
end
function Armory:GetArmorLevel()

    
       local armorLevels = 1
    
        if GetHasTech(self, kTechId.Armor3, true) then
            armorLevels = 4
        elseif GetHasTech(self, kTechId.Armor2, true) then
            armorLevels = 3
        elseif GetHasTech(self, kTechId.Armor1, true) then
            armorLevels = 2
        end
    
    
    return armorLevels
    
end
function Armory:ResupplyPlayer(player)
    
    local resuppliedPlayer = false

    // Heal player first
    if (player:GetHealth() < player:GetMaxHealth()) or ( player:GetArmor() < player:GetMaxArmor() ) then

        // third param true = ignore armor
       // player:AddHealth(Armory.kHealAmount, false, not self.healarmor, nil, nil, true)
                   //Heal Health First, Then Armor, 3 armor per level of armor
                   //then add level bonus
           if ( player:GetHealth() == player:GetMaxHealth() ) then
           local addarmoramount = 3 * self:GetArmorLevel()
           local levelbonus = addarmoramount * (self.level/100) + addarmoramount
           
           player:AddHealth(levelbonus, false, not true, nil, nil, true)
           else
           player:AddHealth(Armory.kHealAmount, false, false, nil, nil, true)   
           end
           
        self:TriggerEffects("armory_health", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
        local kArmoryWeldGainXp =  0.30
        self:AddXP(kArmoryWeldGainXp)
        resuppliedPlayer = true
        /*
        if HasMixin(player, "ParasiteAble") and player:GetIsParasited() then
        
            player:RemoveParasite()

            
        end
        */
        
        if player:isa("Marine") and player.poisoned then
        
            player.poisoned = false
            
        end
        
    end

    // Give ammo to all their weapons, one clip at a time, starting from primary
    local weapons = player:GetHUDOrderedWeaponList()
    
    for index, weapon in ipairs(weapons) do
    
        if weapon:isa("ClipWeapon") then
        
            if weapon:GiveAmmo(1, false) then
            
                self:TriggerEffects("armory_ammo", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
                
                resuppliedPlayer = true
                
                
                break
                
            end 
                   
        end
        
    end
        
    if resuppliedPlayer then
    
        // Insert/update entry in table
        self.resuppliedPlayers[player:GetId()] = Shared.GetTime()
        
        // Play effect
        //self:PlayArmoryScan(player:GetId())

    end

end

function Armory:ResupplyPlayers()

    local playersInRange = GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), Armory.kResupplyUseRange)
    for index, player in ipairs(playersInRange) do
    
        if self:GetShouldResupplyPlayer(player) then
            self:ResupplyPlayer(player)
        end
            
    end

end
/*
function Armory:UpdateResearch()

    local researchId = self:GetResearchingId()

    if researchId == kTechId.AdvancedArmoryUpgrade then
    
        local techTree = self:GetTeam():GetTechTree()    
        local researchNode = techTree:GetTechNode(kTechId.AdvancedArmory)    
        researchNode:SetResearchProgress(self.researchProgress)
        techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
   elseif researchId == kTechId.ArmoryArmor then
    
        local techTree = self:GetTeam():GetTechTree()    
        local researchNode = techTree:GetTechNode(kTechId.ArmoryArmor)    
        researchNode:SetResearchProgress(self.researchProgress)
        techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
    end

end
*/
local function AddChildModel(self)

    local scriptActor = CreateEntity(ArmoryAddon.kMapName, nil, self:GetTeamNumber())
    scriptActor:SetParent(self)
    scriptActor:SetAttachPoint(Armory.kAttachPoint)
    
    return scriptActor
    
end


function Armory:OnResearch(researchId)



    if researchId == kTechId.ArmoryArmor then

        // Create visual add-on
        local advancedArmoryModule = AddChildModel(self)
    end
    
end

function Armory:OnResearchCancel(researchId)

    if researchId == kTechId.ArmoryArmor then
    
        local team = self:GetTeam()
        
        if team then
        
            local techTree = team:GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.AdvancedArmory)
            if researchNode then
            
                researchNode:ClearResearching()
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
         
            end
            
            for i = 0, self:GetNumChildren() - 1 do
            
                local child = self:GetChildAtIndex(i)
                if child:isa("ArmoryAddon") then
                    DestroyEntity(child)
                    break
                end
                
            end  

        end  
    
    end

end
function Armory:UpdateResearch(deltaTime)
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
    if researchNode then
        local gameRules = GetGamerules()
        local projectedminutemarktounlock = 60
        local currentroundlength = ( Shared.GetTime() - gameRules:GetGameStartTime() )

        if researchNode:GetTechId() == kTechId.MinesTech then
           projectedminutemarktounlock = kMinuteMarkToUnlockMines
        elseif researchNode:GetTechId() == kTechId.GrenadeTech then
          projectedminutemarktounlock = kMinuteMarkToUnlockGrenades
        elseif researchNode:GetTechId() == kTechId.ShotgunTech then
          projectedminutemarktounlock = kMinuteMarkToUnlockShotguns
        elseif researchNode:GetTechId() == kTechId.HeavyRifleTech then
          projectedminutemarktounlock = kMinuteMarkToUnlockHeavyRifle
         elseif researchNode:GetTechId() == kTechId.AdvancedArmoryUpgrade then
          projectedminutemarktounlock = kMinuteMarkToUnlockAA
         end
        
     /// kRecycleTime

        //1 minute = mines
        //so if building armory at 30 seconds
        //then progress will be 30 seconds
        //
       
       //mines 60
       //grenades 120
       //shotgun 180
       //onifle 240
       //AA 300
       
        local progress = Clamp(currentroundlength / projectedminutemarktounlock, 0, 1)
        //Print("%s", progress)
        if progress ~= self.researchProgress then
        
            self.researchProgress = progress

            researchNode:SetResearchProgress(self.researchProgress)
            
            local techTree = self:GetTeam():GetTechTree()
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
            
            // Update research progress
            if self.researchProgress == 1 then

                // Mark this tech node as researched
                researchNode:SetResearched(true)
                
                techTree:QueueOnResearchComplete(self.researchingId, self)
                
            end
        
        end
        
    end 

end

function Armory:UpdateLoggedIn()

    local players = GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), 2 * Armory.kResupplyUseRange)
    local armoryCoords = self:GetAngles():GetCoords()
    
    for i = 1, 4 do
    
        local newState = false
        if newState ~= self.loggedInArray[i] then
        
            if newState then
                self:TriggerEffects("armory_open")
            else
                self:TriggerEffects("armory_close")
            end
            
            self.loggedInArray[i] = newState
            
        end
        
    end
    
    // Copy data to network variables (arrays not supported)    
    self.loggedInWest = self.loggedInArray[1]
    self.loggedInNorth = self.loggedInArray[2]
    self.loggedInSouth = self.loggedInArray[3]
    self.loggedInEast = self.loggedInArray[4]

end


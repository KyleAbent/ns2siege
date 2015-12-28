// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\ArmsLab.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/PowerConsumerMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/ParasiteMixin.lua")



class 'ArmsLab' (ScriptActor)
ArmsLab.kMapName = "armslab"

ArmsLab.kModelName = PrecacheAsset("models/marine/arms_lab/arms_lab.model")

///Siege Random Automatic Passive Time Researches
ArmsLab.Weapons1ResearchTime = 0
ArmsLab.Weapons2ResearchTime = 0
ArmsLab.Weapons3ResearchTime = 0
ArmsLab.Armor1ResearchTime = 0
ArmsLab.Armor2ResearchTime = 0
ArmsLab.Armor3ResearchTime = 0
ArmsLab.RifleClipResearchTime = 0


ArmsLab.GainXP = .9


local kAnimationGraph = PrecacheAsset("models/marine/arms_lab/arms_lab.animation_graph")

local kHaloCinematic = PrecacheAsset("cinematics/marine/arms_lab/arms_lab_holo.cinematic")
local kHaloAttachPoint = "ArmsLab_hologram"

local networkVars =
{
}


AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(PowerConsumerMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

function ArmsLab:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
    
    if Client then
    
        InitMixin(self, CommanderGlowMixin)
        self.deployed = false
        
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)

end

function ArmsLab:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    if Server then
    
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        
    elseif Client then
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
    end
    
    self:SetModel(ArmsLab.kModelName, kAnimationGraph)
    self:GenerateResearchTimes()
end
local function GetArmorLevel(self)

    local armorLevels = 0
    
    local techTree = self:GetTechTree()
    if techTree then
    
        if techTree:GetHasTech(kTechId.Armor3) then
            armorLevels = 3
        elseif techTree:GetHasTech(kTechId.Armor2) then
            armorLevels = 2
        elseif techTree:GetHasTech(kTechId.Armor1) then
            armorLevels = 1
        end
    
    end
    
    return armorLevels

end
function ArmsLab:OnResearchComplete(researchId)
 if researchId ~= kTechId.kRifleClipSecondUnlockMax then
     local armorLevel = GetArmorLevel(self)
    for index, player in ipairs(GetEntitiesForTeam("Player", self:GetTeamNumber())) do
        player:UpdateArmorAmount(armorLevel)
    end
 end
end

function ArmsLab:GenerateResearchTimes()
    if ArmsLab.Weapons1ResearchTime ~= 0 then return end
    ArmsLab.Weapons1ResearchTime = math.random(kWeapons1SecondUnlockMin, kWeapons1SecondUnlockMax)
    ArmsLab.Weapons2ResearchTime = math.random(kWeapons2SecondUnlockMin, kWeapons2SecondUnlockMax)
    ArmsLab.Weapons3ResearchTime = math.random(kWeapons3SecondUnlockMin, kWeapons3SecondUnlockMax)
    ArmsLab.Armor1ResearchTime = math.random(kArmor1SecondUnlockMin, kArmor1SecondUnlockMax)
    ArmsLab.Armor2ResearchTime = math.random(kArmor2SecondUnlockMin, kArmor2SecondUnlockMax)
    ArmsLab.Armor3ResearchTime = math.random(kArmor3SecondUnlockMin, kArmor3SecondUnlockMax)
    ArmsLab.RifleClipResearchTime = math.random(kRifleClipSecondUnlockMin, kRifleClipSecondUnlockMax)
    Print("Times: W1 %s, W2 %s, W3 %s", ArmsLab.Weapons1ResearchTime,ArmsLab.Weapons2ResearchTime,ArmsLab.Weapons3ResearchTime)
    Print("Times: A1 %s, A2 %s, A3 %s", ArmsLab.Armor1ResearchTime,ArmsLab.Armor2ResearchTime,ArmsLab.Armor3ResearchTime)
    Print("rifle clip: %s", ArmsLab.RifleClipResearchTime)
end
   
function ArmsLab:GetArmsLabQualifications()
local amount = 0
        for index, armslab in ientitylist(Shared.GetEntitiesWithClassname("ArmsLab")) do
        
               amount  = amount + 1
            
        end
        
    
    return amount
    
end
function ArmsLab:GetReceivesStructuralDamage()
    return true
end

function ArmsLab:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end
  function ArmsLab:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    
    if self:GetIsResearching() then
    
    local w1time = string.TimeToString(ArmsLab.Weapons1ResearchTime)
    local w2time = string.TimeToString(ArmsLab.Weapons2ResearchTime)
    local w3time = string.TimeToString(ArmsLab.Weapons3ResearchTime)
    local a1time = string.TimeToString(ArmsLab.Armor1ResearchTime)
    local a2time = string.TimeToString(ArmsLab.Armor2ResearchTime)
    local a3time = string.TimeToString(ArmsLab.Armor3ResearchTime)
    local cliptime = string.TimeToString(ArmsLab.RifleClipResearchTime)


    local currentresearchtimetounlock = 0
      if self.researchingId == kTechId.Weapons1 then
        currentresearchtimetounlock = w1time
      elseif self.researchingId == kTechId.Weapons2 then
        currentresearchtimetounlock = w2time
      elseif self.researchingId == kTechId.Weapons3 then
        currentresearchtimetounlock = w3time
      elseif self.researchingId == kTechId.Armor1 then
        currentresearchtimetounlock = a1time
      elseif self.researchingId == kTechId.Armor2 then
        currentresearchtimetounlock = a2time
      elseif self.researchingId == kTechId.Armor3 then
        currentresearchtimetounlock = a3time
      elseif self.researchingId == kTechId.RifleClip then
        currentresearchtimetounlock = cliptime
      end
      
    unitName = string.format(Locale.ResolveString("%s"), currentresearchtimetounlock)
  end
return unitName
end 
function ArmsLab:OnUpdate(deltaTime)
   if Server then  
       if not self.timeLastUpdatePassiveCheck or self.timeLastUpdatePassiveCheck + 15 < Shared.GetTime() then 
     self:UpdatePassive()
       self.timeLastUpdatePassiveCheck = Shared.GetTime()
        end
   end
end
if Server then
function ArmsLab:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
       if GetHasTech(self, kTechId.RifleClip) or not GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return end
       
    local commander = GetCommanderForTeam(1)
    if not commander then return end
    

    local techid = nil  
    
    if not GetHasTech(self, kTechId.Weapons1) then
    techid = kTechId.Weapons1
    SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Weapons1Researching)
    elseif GetHasTech(self, kTechId.Weapons1) and not GetHasTech(self, kTechId.Armor1) then
    techid = kTechId.Armor1
    SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Armor1Researching)
   elseif GetHasTech(self, kTechId.Armor1) and not GetHasTech(self, kTechId.Weapons2) then
    techid = kTechId.Weapons2
   SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Weapons2Researching)
  elseif GetHasTech(self, kTechId.Weapons2) and not GetHasTech(self, kTechId.Armor2) then
    techid = kTechId.Armor2
    SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Armor2Researching)
   elseif GetHasTech(self, kTechId.Armor2) and not GetHasTech(self, kTechId.Weapons3) then
    techid = kTechId.Weapons3
    SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Weapons3Researching)
   elseif GetHasTech(self, kTechId.Weapons3) and not GetHasTech(self, kTechId.Armor3) then
    techid = kTechId.Armor3
    SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Armor3Researching)
  elseif GetHasTech(self, kTechId.Weapons3) and not GetHasTech(self, kTechId.RifleClip) then
    techid = kTechId.RifleClip
    else
       return  
    end
    
   local techNode = commander:GetTechTree():GetTechNode( techid ) 
   commander.isBotRequestedAction = true
   commander:ProcessTechTreeActionForEntity(techNode, self:GetOrigin(), Vector(0,1,0), true, 0, self, nil)
   
end
end
if Server then
function ArmsLab:UpdateResearch(deltaTime)
 if not self.timeLastUpdateCheck or self.timeLastUpdateCheck + 15 < Shared.GetTime() then 
   //Kyle Abent Siege 10.25.15 morning writing twtich.tv/kyleabent
   //11.10 updating to improve - Add in the adition of dynamic timers rather than set static timers
   //11.10 updating to improve - Performance via adding 15 seconds delay between reseearch updates rather than 25x per second.
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
    if researchNode then
        local gameRules = GetGamerules()
        local projectedminutemarktounlock = 60
        local currentroundlength = ( Shared.GetTime() - gameRules:GetGameStartTime() )

        if researchNode:GetTechId() == kTechId.Weapons1 then
           projectedminutemarktounlock = ArmsLab.Weapons1ResearchTime
        elseif researchNode:GetTechId() == kTechId.Weapons2 then
          projectedminutemarktounlock =  ArmsLab.Weapons2ResearchTime
        elseif researchNode:GetTechId() == kTechId.Weapons3 then
          projectedminutemarktounlock =  ArmsLab.Weapons3ResearchTime
        elseif researchNode:GetTechId() == kTechId.Armor1 then
          projectedminutemarktounlock = ArmsLab.Armor1ResearchTime
          elseif researchNode:GetTechId() == kTechId.Armor2 then
          projectedminutemarktounlock = ArmsLab.Armor2ResearchTime
         elseif researchNode:GetTechId() == kTechId.Armor3 then
          projectedminutemarktounlock = ArmsLab.Armor3ResearchTime
         elseif researchNode:GetTechId() == kTechId.RifleClip then
          projectedminutemarktounlock = ArmsLab.RifleClipResearchTime
        end
      
       
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
        self.timeLastUpdateCheck = Shared.GetTime()
    end
end
function ArmsLab:OnResearchComplete(researchId)
   if researchId ~= kTechId.RifleClip then 
   
            local enemyTeamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
            local enemyTeam = GetGamerules():GetTeam(enemyTeamNumber)
            
            if enemyTeam ~= nil then
                enemyTeam:UpdateAliensMaxHealth()

            end
   
   
   end
end
end // server
function ArmsLab:GetIsPoweredOverride()
    return ( self.powered or self.powerSurge and not self:GetIsVortexed() ) or self:GetHasSentryBatteryInRadius()
end
function ArmsLab:GetHasSentryBatteryInRadius()
      local battery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), SentryBattery.kRange)
   if #battery >=1 then return true end
   return false
end
function ArmsLab:GetCanBeUsedConstructed(byPlayer)
    return false //not byPlayer:isa("Exo")
end  
if Client then
function ArmsLab:OnUse(player, elapsedTime, useSuccessTable)
    
    if GetIsUnitActive(self) and not Shared.GetIsRunningPrediction() and not player.buyMenu then
    
        if Client.GetLocalPlayer() == player then
        
            Client.SetCursor("ui/Cursor_MarineCommanderDefault.dds", 0, 0)
            
            // Play looping "active" sound while logged in
            // Shared.PlayPrivateSound(player, Armory.kResupplySound, player, 1.0, Vector(0, 0, 0))
            
            MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", true)
            
            // Tell the player to show the lua menu.
            player:BuyMenu(self)
            
        end
        
    end
end  
end//client
function ArmsLab:GetItemList(forPlayer)
    

    local itemList = nil
    
        itemList = {   
            kTechId.None,
        }
 

   if not forPlayer.hasfirebullets then itemList[1] = kTechId.FireBullets end       
    return itemList
    
end
function ArmsLab:GetTechButtons(techId)

    return { kTechId.None, kTechId.None, kTechId.None, kTechId.None,
             kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    
end

if Client then

    function ArmsLab:OnTag(tagName)
    
        PROFILE("ArmsLab:OnTag")
        
        if tagName == "deploy_end" then
            self.deployed = true
        end
        
    end
    
    function ArmsLab:OnUpdateRender()
    
        if not self.haloCinematic then
        
            self.haloCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
            self.haloCinematic:SetCinematic(kHaloCinematic)
            self.haloCinematic:SetParent(self)
            self.haloCinematic:SetAttachPoint(self:GetAttachPointIndex(kHaloAttachPoint))
            self.haloCinematic:SetCoords(Coords.GetIdentity())
            self.haloCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
            
        end
        
        self.haloCinematic:SetIsVisible(self.deployed and self:GetIsPowered())
        
    end
    
end

function ArmsLab:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if Client and self.haloCinematic then
    
        Client.DestroyCinematic(self.haloCinematic)
        self.haloCinematic = nil
        
    end
    
end

function ArmsLab:GetRequiresPower()
    return true
end

Shared.LinkClassToMap("ArmsLab", ArmsLab.kMapName, networkVars)
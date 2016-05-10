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
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/ParasiteMixin.lua")



class 'ArmsLab' (ScriptActor)
ArmsLab.kMapName = "armslab"

ArmsLab.kModelName = PrecacheAsset("models/marine/arms_lab/arms_lab.model")


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
function ArmsLab:OnConstructionComplete()
self:AddTimedCallback(ArmsLab.UpdateManually, kMarineResearchDelay)
end
function ArmsLab:UpdateManually()
   if Server then  
     self:UpdatePassive()
   end
   return true
end
if Server then
function ArmsLab:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
       if GetHasTech(self, kTechId.RifleClip) or not GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return false end
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
       return  false
    end
    
   local techNode = self:GetTeam():GetTechTree():GetTechNode( techid ) 
                 self:SetResearching(techNode, self)
   --commander.isBotRequestedAction = true
   --commander:ProcessTechTreeActionForEntity(techNode, self:GetOrigin(), Vector(0,1,0), true, 0, self, nil)
   
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
        local percentageofround = 1
        if researchNode:GetTechId() == kTechId.Weapons1 then
           percentageofround = 0.15
        elseif researchNode:GetTechId() == kTechId.Weapons2 then
           percentageofround = 0.30
        elseif researchNode:GetTechId() == kTechId.Weapons3 then
           percentageofround = 0.50
        elseif researchNode:GetTechId() == kTechId.Armor1 then
           percentageofround = 0.25
          elseif researchNode:GetTechId() == kTechId.Armor2 then
           percentageofround = 0.40
         elseif researchNode:GetTechId() == kTechId.Armor3 then
           percentageofround = 0.60
         elseif researchNode:GetTechId() == kTechId.RifleClip then
          percentageofround = 0.85
        end
      
       
        local progress = Clamp( (currentroundlength/kSiegeDoorTimey) / percentageofround, 0, 1)
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
   
   elseif researchId == kTechId.ArmsLabInsure then
      self:InsureThisBitch()
         
   end
   /*   
    if researchId ~= kTechId.kRifleClipSecondUnlockMax then
     local armorLevel = GetArmorLevel(self)
    for index, player in ipairs(GetEntitiesForTeam("Player", self:GetTeamNumber())) do
        player:SetArmorAmount()
    end
 end
    */
end
end // server
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

    local techButtons = nil

    techButtons = { kTechId.None, kTechId.None, kTechId.None, kTechId.None, 
                    kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    
    
    if not self:GetIsInsured() then
    techButtons[1] = kTechId.ArmsLabInsure
    end
    return techButtons 
    
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
        
        self.haloCinematic:SetIsVisible(self.deployed) 
        
    end
    
end
function ArmsLab:OnUpdateAnimationInput(modelMixin)

    modelMixin:SetAnimationInput("powered", true)
    
end
function ArmsLab:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if Client and self.haloCinematic then
    
        Client.DestroyCinematic(self.haloCinematic)
        self.haloCinematic = nil
        
    end
    
end


Shared.LinkClassToMap("ArmsLab", ArmsLab.kMapName, networkVars)
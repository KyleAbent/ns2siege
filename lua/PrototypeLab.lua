// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\PrototypeLab.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/PowerConsumerMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/ParasiteMixin.lua")

local kAnimationGraph = PrecacheAsset("models/marine/prototype_lab/prototype_lab.animation_graph")

class 'PrototypeLab' (ScriptActor)

PrototypeLab.kMapName = "prototypelab"

local kUpdateLoginTime = 0.3
// Players can use menu and be supplied by PrototypeLab inside this range
PrototypeLab.kResupplyUseRange = 2.5

PrototypeLab.kModelName = PrecacheAsset("models/marine/prototype_lab/prototype_lab.model")

if Server then
    Script.Load("lua/PrototypeLab_Server.lua")
elseif Client then
    Script.Load("lua/PrototypeLab_Client.lua")
end    

local networkVars =
{
    // How far out the arms are for animation (0-1)
    loggedInEast = "boolean",
    loggedInNorth = "boolean",
    loggedInSouth = "boolean",
    loggedInWest = "boolean",
    deployed = "boolean"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
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
AddMixinNetworkVars(PowerConsumerMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

function PrototypeLab:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
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
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    self.loginEastAmount = 0
    self.loginNorthAmount = 0
    self.loginWestAmount = 0
    self.loginSouthAmount = 0
    
    self.timeScannedEast = 0
    self.timeScannedNorth = 0
    self.timeScannedWest = 0
    self.timeScannedSouth = 0

    self.loginNorthAmount = 0
    self.loginEastAmount = 0
    self.loginSouthAmount = 0
    self.loginWestAmount = 0
    
    self.deployed = false
    
end

function PrototypeLab:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(PrototypeLab.kModelName, kAnimationGraph)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    if Server then
    
        self.loggedInArray = {false, false, false, false}
        self:AddTimedCallback(PrototypeLab.UpdateLoggedIn, kUpdateLoginTime)
        
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
    
end

function PrototypeLab:GetTechButtons(techId)
    return { kTechId.None, kTechId.None, kTechId.None, kTechId.None, 
             kTechId.None, kTechId.None, kTechId.None, kTechId.None } // kTechId.DualRailgunTech
end

function PrototypeLab:GetRequiresPower()
    return true
end
/* // dont allow jp marines to use the prototype lab
function PrototypeLab:GetCanBeUsed(player, useSuccessTable)

    if (not self:GetIsBuilt() and player:isa("Exo")) or (player:isa("Exo") and player:GetHasDualGuns()) or (player:isa("JetpackMarine") and self:GetIsBuilt()) then
        useSuccessTable.useSuccess = false
    end
    
end
*/

function PrototypeLab:GetCanBeUsed(player, useSuccessTable)

    if not self:GetIsBuilt()  then
        useSuccessTable.useSuccess = false
    end
    
end

function PrototypeLab:GetCanBeUsedConstructed()
    return true
end 

local function UpdatePrototypeLabAnim(self, extension, loggedIn, scanTime, timePassed)

    local loggedInName = "log_" .. extension
    local loggedInParamValue = ConditionalValue(loggedIn, 1, 0)
    
    if extension == "n" then
    
        self.loginNorthAmount = Clamp(Slerp(self.loginNorthAmount, loggedInParamValue, timePassed*2), 0, 1)
        self:SetPoseParam(loggedInName, self.loginNorthAmount)
        
    elseif extension == "s" then
    
        self.loginSouthAmount = Clamp(Slerp(self.loginSouthAmount, loggedInParamValue, timePassed*2), 0, 1)
        self:SetPoseParam(loggedInName, self.loginSouthAmount)
        
    elseif extension == "e" then
    
        self.loginEastAmount = Clamp(Slerp(self.loginEastAmount, loggedInParamValue, timePassed*2), 0, 1)
        self:SetPoseParam(loggedInName, self.loginEastAmount)
        
    elseif extension == "w" then
    
        self.loginWestAmount = Clamp(Slerp(self.loginWestAmount, loggedInParamValue, timePassed*2), 0, 1)
        self:SetPoseParam(loggedInName, self.loginWestAmount)
        
    end
    
    local scannedName = "scan_" .. extension
    local scannedParamValue = ConditionalValue(scanTime == 0 or (Shared.GetTime() > scanTime + 3), 0, 1)
    self:SetPoseParam(scannedName, scannedParamValue)
    
end

function PrototypeLab:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function PrototypeLab:OnUpdate(deltaTime)

    if Client then
        self:UpdatePrototypeLabWarmUp()
    elseif Server then
        if not self.timeLastUpdatePassiveCheck or self.timeLastUpdatePassiveCheck + 15 < Shared.GetTime() then 
        self:UpdatePassive()
        end
    end
    if GetIsUnitActive(self) and self.deployed then
    
        // Set pose parameters according to if we're logged in or not
        UpdatePrototypeLabAnim(self, "e", self.loggedInEast, self.timeScannedEast, deltaTime)
        UpdatePrototypeLabAnim(self, "n", self.loggedInNorth, self.timeScannedNorth, deltaTime)
        UpdatePrototypeLabAnim(self, "w", self.loggedInWest, self.timeScannedWest, deltaTime)
        UpdatePrototypeLabAnim(self, "s", self.loggedInSouth, self.timeScannedSouth, deltaTime)
        
    end
    
    ScriptActor.OnUpdate(self, deltaTime)
    
end
function PrototypeLab:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
       if GetHasTech(self, kTechId.ExosuitTech) or not GetGamerules():GetGameStarted() or not self:GetIsBuilt() or self:GetIsResearching() then return end
       
    local commander = GetCommanderForTeam(1)
    if not commander then return end
    

    local techid = nil
    
    if not GetHasTech(self, kTechId.JetpackTech) then
    techid = kTechId.JetpackTech
    elseif GetHasTech(self, kTechId.JetpackTech) and not GetHasTech(self, kTechId.ExosuitTech) then
    techid = kTechId.ExosuitTech
    else
       return  
    end
    
   local techNode = commander:GetTechTree():GetTechNode( techid ) 
   commander.isBotRequestedAction = true
   commander:ProcessTechTreeActionForEntity(techNode, self:GetOrigin(), Vector(0,1,0), true, 0, self, nil)
   
end
if Server then
function PrototypeLab:UpdateResearch(deltaTime)
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
    if researchNode then
        local gameRules = GetGamerules()
        local projectedminutemarktounlock = 60
        local currentroundlength = ( Shared.GetTime() - gameRules:GetGameStartTime() )

        if researchNode:GetTechId() == kTechId.JetpackTech then
           projectedminutemarktounlock = kJetpackMinuteUnlockTime
        elseif researchNode:GetTechId() == kTechId.ExosuitTech then
          projectedminutemarktounlock = kExoSuitMinuteUnlockTime
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

end
end // server
function PrototypeLab:GetItemList(forPlayer)

    if forPlayer:isa("Exo") then
    
    local exobuttons = {}
       // if forPlayer:GetHasDualGuns() then
       //     return exobuttons
        //elseif forPlayer:GetHasRailgun() then
         if forPlayer:GetHasRailgun() then 
          exobuttons[1] = kTechId.UpgradeToDualRailgun
          exobuttons[2] = kTechId.ExoNanoArmor   
        elseif forPlayer:GetHasMinigun() then
          exobuttons[1] = kTechId.UpgradeToDualMinigun
          exobuttons[2] = kTechId.ExoNanoArmor  
        end    
        
        if forPlayer.nano then
          exobuttons[2] = kTechId.None  
        end
            return exobuttons
    end    
       local otherbuttons =  { kTechId.Jetpack, kTechId.Exosuit, kTechId.DualMinigunExosuit, kTechId.ClawRailgunExosuit, kTechId.DualRailgunExosuit, kTechId.JumpPack }
          
          if forPlayer.hasjumppack or forPlayer:isa("JetpackMarine")  then
              otherbuttons[1] = kTechId.None
              otherbuttons[6] = kTechId.None
           end
            
         return otherbuttons
    
end

function PrototypeLab:GetReceivesStructuralDamage()
    return true
end


Shared.LinkClassToMap("PrototypeLab", PrototypeLab.kMapName, networkVars)
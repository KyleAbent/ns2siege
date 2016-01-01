// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Observatory.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/Marine/Scan.lua")

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
Script.Load("lua/CommanderGlowMixin.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/DetectorMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/PowerConsumerMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")

class 'Observatory' (ScriptActor)

Observatory.kMapName = "observatory"

Observatory.kModelName = PrecacheAsset("models/marine/observatory/observatory.model")
Observatory.kCommanderScanSound = PrecacheAsset("sound/NS2.fev/marine/commander/scan_com")

local kObservatoryTechButtons = { kTechId.Scan, kTechId.None, kTechId.Detector, kTechId.None,
                                   kTechId.None, kTechId.None, kTechId.None, kTechId.None }

Observatory.kDetectionRange = 22 // From NS1 

///Siege Random Automatic Passive Time Researches
Observatory.kRandomnlyGeneratedTimeToUnlock = 0

local kAnimationGraph = PrecacheAsset("models/marine/observatory/observatory.animation_graph")

local networkVars = { 
                     lastscantime = "time",  
                     ignorelimit = "boolean", 
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
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

function Observatory:OnCreate()

    ScriptActor.OnCreate(self)
    
    if Server then
    
        
        self:AddTimedCallback(Observatory.RevealCysts, 4)

    end
    
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
    InitMixin(self, DetectorMixin)
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
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)  
    
    self.lastscantime = 0
    self.ignorelimit = false
end

function Observatory:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(Observatory.kModelName, kAnimationGraph)
    
    if Server then
    
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        InitMixin(self, SupplyUserMixin)
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    InitMixin(self, IdleMixin)
    self:Generate()
end
function Observatory:Generate()
if Observatory.kRandomnlyGeneratedTimeToUnlock ~= 0 then return end
Observatory.kRandomnlyGeneratedTimeToUnlock = math.random(kSecondMarkToUnlockPhaseTechMin, kSecondMarkToUnlockPhaseTechMax)
Print("Phasetech: %s",Observatory.kRandomnlyGeneratedTimeToUnlock)
end



function Observatory:GetTechButtons(techId)

    if techId == kTechId.RootMenu then
        return kObservatoryTechButtons
    end
    
    return nil
    
end

function Observatory:GetDetectionRange()

    if GetIsUnitActive(self) then
        return Observatory.kDetectionRange
    end
    
    return 0
    
end

function Observatory:GetRequiresPower()
    return true
end

function Observatory:GetReceivesStructuralDamage()
    return true
end

function Observatory:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function Observatory:RevealCysts()

    for _, cyst in ipairs(GetEntitiesForTeamWithinRange("Cyst", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Observatory.kDetectionRange)) do
        if self:GetIsBuilt() and self:GetIsPowered() then
            cyst:SetIsSighted(true)
        end
    end

    return self:GetIsAlive()

end

function Observatory:UpdateManually()
   if Server then 
     self:UpdatePassive() 
    end
    return true

end
function GetCheckObsyLimit(techId, origin, normal, commander)
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    
    if locationName then
    
        validRoom = true
        
        for index, obs in ientitylist(Shared.GetEntitiesWithClassname("Observatory")) do
        
            if obs:GetLocationName() == locationName and not obs.ignorelimit then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    
    return validRoom and numInRoom < 3
    
end
function Observatory:UpdatePassive()
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    if GetHasTech(self, kTechId.PhaseTech) or not  GetGamerules():GetGameStarted() or self:GetIsResearching() then return false end
    local commander = GetCommanderForTeam(1)
    if not commander then return true end
    

    local techid = nil
    
    if not GetHasTech(self, kTechId.PhaseTech) then
    techid = kTechId.PhaseTech
    else
       return  false
    end
    
   local techNode = commander:GetTechTree():GetTechNode( techid ) 
   commander.isBotRequestedAction = true
   commander:ProcessTechTreeActionForEntity(techNode, self:GetOrigin(), Vector(0,1,0), true, 0, self, nil)
end
if Server then
function Observatory:UpdateResearch(deltaTime)
 if not self.timeLastUpdateCheck or self.timeLastUpdateCheck + 15 < Shared.GetTime() then 
   //Kyle Abent Siege 10.24.15 morning writing twtich.tv/kyleabent
    local researchNode = self:GetTeam():GetTechTree():GetTechNode(self.researchingId)
    if researchNode then
        local gameRules = GetGamerules()
        local projectedminutemarktounlock = 60
        local currentroundlength = ( Shared.GetTime() - gameRules:GetGameStartTime() )

        if researchNode:GetTechId() == kTechId.PhaseTech then
           projectedminutemarktounlock = Observatory.kRandomnlyGeneratedTimeToUnlock
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
end//server
function Observatory:ScanAtOrigin()
         CreateEntity( Scan.kMapName, self:GetOrigin(), 1)
         self.lastscantime = Shared.GetTime()
end
  function Observatory:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    
  //  if self:GetIsSiege() then //and not self:GetCanAutomaticTriggerInkAgain() then
     local NowToInk = self:GetCoolDown() - (Shared.GetTime() - self.lastscantime)
     local ScanLength =  math.ceil( Shared.GetTime() + NowToInk - Shared.GetTime() )
     local time = ScanLength
     unitName = string.format(Locale.ResolveString("Observatory (%s)"), Clamp(time, 0, self:GetCoolDown()))
  //  end
 
return unitName
end 
function Observatory:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
function Observatory:GetCoolDown()
return kSiegeObsAutoScanCooldown
end
function Observatory:GetIsInSiege()
if string.find(self:GetLocationName(), "siege") or string.find(self:GetLocationName(), "Siege") then return true end
return false
end

function Observatory:OverrideVisionRadius()
    return Observatory.kDetectionRange
end

/*
if Server then

    function OnConsoleDistress()
    
        if Shared.GetCheatsEnabled() or Shared.GetDevMode() then
            local beacons = Shared.GetEntitiesWithClassname("Observatory")
            for i, beacon in ientitylist(beacons) do
                beacon:TriggerDistressBeacon()
            end
        end
        
    end
    
    Event.Hook("Console_distress", OnConsoleDistress)
    
end
*/
if Server then

    function Observatory:OnConstructionComplete()
        if self.phaseTechResearched then

            local techTree = GetTechTree(self:GetTeamNumber())
            if techTree then
                local researchNode = techTree:GetTechNode(kTechId.PhaseTech)
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.PhaseTech, self)
            end    
            
        else
        self:AddTimedCallback(Observatory.UpdateManually, kMarineResearchDelay)
        end
    end
    
end    

function Observatory:GetHealthbarOffset()
    return 0.9
end 


Shared.LinkClassToMap("Observatory", Observatory.kMapName, networkVars)
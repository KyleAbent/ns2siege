// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\RoboticsFactory.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/StunMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/PowerConsumerMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")

class 'RoboticsFactory' (ScriptActor)

RoboticsFactory.kAnimationGraph = PrecacheAsset("models/marine/robotics_factory/robotics_factory.animation_graph")

RoboticsFactory.kMapName = "roboticsfactory"

RoboticsFactory.kModelName = PrecacheAsset("models/marine/robotics_factory/robotics_factory.model")

RoboticsFactory.kAttachPoint = "target"

RoboticsFactory.kCloseDelay  = .5
RoboticsFactory.kActiveEffect = PrecacheAsset("cinematics/marine/roboticsfactory/active.cinematic")
RoboticsFactory.kAnimOpen   = "open"
RoboticsFactory.kAnimClose  = "close"

RoboticsFactory.kRolloutLength = 3

local kOpenSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_open")
local kCloseSound = PrecacheAsset("sound/NS2.fev/marine/structures/roboticsfactory_close")
PrecacheAsset("cinematics/vfx_materials/hallucination.surface_shader")
local kHallucinationMaterial = PrecacheAsset( "cinematics/vfx_materials/hallucination.material")

local networkVars =
{
    open = "boolean",
    automaticspawningmac = "boolean",
    automaticspawningarc = "boolean",
    stunned = "boolean",
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
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(PowerConsumerMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)

function RoboticsFactory:OnCreate()

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
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, StunMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end

    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
        
    self.open = false
   self.automaticspawningmac = false
   self.automaticspawningarc = false
   self.stunned = false
end

function RoboticsFactory:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, HiveVisionMixin)
    
    self:SetModel(RoboticsFactory.kModelName, RoboticsFactory.kAnimationGraph)
    
    self:SetPhysicsType(PhysicsType.Kinematic)
    
    self.researchId = Entity.invalidId
    
    if Server then
    
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        
    end

end

function RoboticsFactory:GetReceivesStructuralDamage()
    return true
end

function RoboticsFactory:GetRequiresPower()
    return true
end

function RoboticsFactory:GetNanoShieldOffset()
    return Vector(0, -0.8, 0)
end
if Server then
function RoboticsFactory:OnStun()   
              //  local bonewall = CreateEntity(BoneWall.kMapName, self:GetOrigin(), 2)    
               // bonewall.modelsize = 0.5
            //    bonewall:AdjustMaxHealth(bonewall:GetMaxHealth())
            //    bonewall.targetid = self:GetId()
                self:SetPhysicsGroup(PhysicsGroup.AlienWalkThroughHit)
                self.stunned = true
                self:AddTimedCallback(function() self.stunned = false self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup) end, 6)
end
end//server
if Client then

    function RoboticsFactory:OnUpdateRender()
          local showMaterial = GetAreEnemies(self, Client.GetLocalPlayer()) and self.stunned
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 0)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kHallucinationMaterial)
                end
                
                self:SetOpacity(0, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
   end //up render
    
end//client
function RoboticsFactory:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    
    // Do not allow tech while open or researching or we may lose res.
    // Research progress is checked here instead of GetIsResearching() because
    // there is a delay in the tech tree when tech is queued which causes
    // GetIsResearching() to return true before the research is 100% complete.
    // Checking the progress is 0 is the sure way to get around that limit.
    // $AU: Which causes the cancel button to not work anymore. I want to make the tech tree
    // finally entity based (this will also make both tech trees available for insight) with clearer API.
    allowed = allowed and not self.open and self:GetResearchProgress() == 0
    
    if techId == kTechId.ARC then
        allowed = allowed and self:GetTechId() == kTechId.ARCRoboticsFactory
    elseif techId == kTechId.Cancel then
        allowed = self:GetResearchProgress() < 1
    end
    
    return allowed, canAfford
    
end
function RoboticsFactory:GetIsStunAllowed()
    return  self:GetLastStunTime() + 8 < Shared.GetTime() and not self.stunned and GetAreFrontDoorsOpen() //and not self:GetIsVortexed()
end
function RoboticsFactory:GetTechButtons(techId)

    local techButtons = {  kTechId.None, kTechId.MAC, kTechId.None, kTechId.None, 
               kTechId.None, kTechId.None, kTechId.None, kTechId.None }
               
    if self:GetTechId() ~= kTechId.ARCRoboticsFactory then
        techButtons[5] = kTechId.UpgradeRoboticsFactory
    else
    
       if self:GetArcsAmount() <=12 then
       techButtons[1] = kTechId.ARC
       end
       
    end           

   if not self.automaticspawningmac and not self.automaticspawningarc then 
      techButtons[6] = kTechId.MacSpawnOn
   elseif self.automaticspawningmac then
      techButtons[6] = kTechId.MacSpawnOff
    end
   
    
       if not self.automaticspawningmac and not self.automaticspawningarc then 
      techButtons[7] = kTechId.ArcSpawnOn
   elseif self.automaticspawningarc then
      techButtons[7] = kTechId.ArcSpawnOff
    end
    
    return techButtons
    
end
 function RoboticsFactory:PerformActivation(techId, position, normal, commander)
 
     local success = false
    if techId == kTechId.MacSpawnOn then
    self.automaticspawningmac = true
    elseif techId == kTechId.MacSpawnOff then
    self.automaticspawningmac = false
    end
    
    if techId == kTechId.ArcSpawnOn then
    self.automaticspawningarc = true
    elseif techId == kTechId.ArcSpawnOff then
    self.automaticspawningarc = false
    end
        return success, true
end
local kRoboticsMinRange = 8
function GetRoboticsRangeLimit(techId, origin, normal, commander)

    local robotic = GetRoboticInRange(commander, origin)
    if robotic then
    
        if (robotic:GetOrigin() - origin):GetLength() < kRoboticsMinRange then
            return false
        end

    end
return true
    
end

function GetRoboticInRange(commander, origin)

local kClosestRoboticDistance = 99999
local closestrobotic
    for _, robotic in ipairs(GetEntitiesForTeam("RoboticsFactory", commander:GetTeamNumber())) do
local dist = (robotic:GetOrigin() - origin):GetLength()
        if dist < kClosestRoboticDistance then
            closestrobotic = robotic
kClosestRoboticDistance = dist
        end
    end
    
    return closestrobotic
    
end
function RoboticsFactory:GetMacsAmount()
    local macs = 0
        for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
                macs = macs + 1
         end
    return  macs
end
function RoboticsFactory:GetArcsAmount()
    local arcs = 0
        for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
              if not arc.ignorelimit then arcs = arcs + 1 end
         end
    return  arcs
end
function RoboticsFactory:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function RoboticsFactory:GetPositionForEntity(entity)
    
    local direction = Vector(self:GetAngles():GetCoords().zAxis)    
    local origin = self:GetOrigin() + direction * 3.2
    
    if entity:GetIsFlying() then
        origin = GetHoverAt(entity, origin)
    end
    
    return Coords.GetLookIn( origin, direction )

end
if Server then
   function RoboticsFactory:GetIsFront()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetFrontDoorsOpen() then 
                   return true
               end
            end
        end
            return false
end
function RoboticsFactory:GetCanBeUsedConstructed(byPlayer)
  return not self:GetIsFront() and not byPlayer:GetWeaponInHUDSlot(5)
end
function RoboticsFactory:OnUseDuringSetup(player, elapsedTime, useSuccessTable)

    // Play flavor sounds when using MAC.
    if Server then
    
        local time = Shared.GetTime()
        
       // if self.timeOfLastUse == nil or (time > (self.timeOfLastUse + 4)) then
        
           local laystructure = player:GiveItem(LayStructures.kMapName)
           laystructure:SetTechId(kTechId.RoboticsFactory)
           laystructure:SetMapName(RoboticsFactory.kMapName)
           laystructure.originalposition = self:GetOrigin()
           DestroyEntity(self)
           // self.timeOfLastUse = time
            
      //  end
       //self:PlayerUse(player) 
    end
    
end
end
function RoboticsFactory:ManufactureEntity()

    local mapName = LookupTechData(self.researchId, kTechDataMapName)    
    local owner = Shared.GetEntity(self.researchingPlayerId)
    
    local builtEntity = CreateEntity(mapName, self:GetOrigin(), self:GetTeamNumber())        
                
    if builtEntity ~= nil then             
    
        local newPosition = self:GetPositionForEntity(builtEntity)
        builtEntity:SetOwner(owner)
        builtEntity:SetCoords(newPosition)
        builtEntity:ProcessRallyOrder(self)
        
    end
    
end

// Actual creation of entity happens delayed.
function RoboticsFactory:OverrideCreateManufactureEntity(techId)

    if techId == kTechId.ARC or techId == kTechId.MAC then
    
        self.researchId = techId
        self.open = true
        
    end
    
end

function RoboticsFactory:OnResearchComplete(researchId)

    if researchId == kTechId.UpgradeRoboticsFactory then
        self:UpgradeToTechId(kTechId.ARCRoboticsFactory)
    end
        
end

function RoboticsFactory:OnTag(tagName)
    
    PROFILE("RoboticsFactory:OnTag")
                                                                                   //siege fix for autobuild
    if self.open and self.researchId ~= Entity.invalidId and tagName == "end" and self.builtEntity ~= nil then

        self.builtEntity:Rollout(self, RoboticsFactory.kRolloutLength)
        self.builtEntity = nil
        
    end
    
    if tagName == "open_start" then
        StartSoundEffectAtOrigin(kOpenSound, self:GetOrigin())
    elseif tagName == "close_start" then
        StartSoundEffectAtOrigin(kCloseSound, self:GetOrigin())
    end
    
end

function RoboticsFactory:OnUpdateAnimationInput(modelMixin)

    PROFILE("RoboticsFactory:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("open", self.open)

end

if Server then
  function RoboticsFactory:OnUpdate()
   if self.timeOfLastHealCheck == nil or Shared.GetTime() > self.timeOfLastHealCheck + 10 then
   if self.automaticspawningmac then
        if self:GetTeam():GetTeamResources() >= kMACCost and ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.MAC, kTechDataSupply, 0)) and self.deployed and GetIsUnitActive(self) and self:GetResearchProgress() == 0 and not self.open and self:GetMacsAmount() <= 8 then
        
            self:OverrideCreateManufactureEntity(kTechId.MAC)
            //self.spawnedFreeMAC = true
            self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - kMACCost )
        end
    end
    if self.automaticspawningarc then
        if self:GetTeam():GetTeamResources() >= kARCCost and ( kMaxSupply - GetSupplyUsedByTeam(1) >= LookupTechData(kTechId.ARC, kTechDataSupply, 0)) and self.deployed and GetIsUnitActive(self) and self:GetResearchProgress() == 0 and not self.open and self:GetArcsAmount() <= 12 - 1 then
        
            self:OverrideCreateManufactureEntity(kTechId.ARC)
            //self.spawnedFreeMAC = true
            self:GetTeam():SetTeamResources(self:GetTeam():GetTeamResources() - kARCCost )
        end
    end
    self.timeOfLastHealCheck = Shared.GetTime()  
    end
  end
    /*
    function RoboticsFactory:OnUpdate()
       
        // Create free MAC when built
        if self.deployed and GetIsUnitActive(self) and self.spawnedFreeMAC == nil and not self:GetIsResearching() and not self.open then
        
            self:OverrideCreateManufactureEntity(kTechId.MAC)
            self.spawnedFreeMAC = true
            
        end
        
    end
    */
    
    function RoboticsFactory:Deploy()
        self.deployed = true
        return false
    end
    
    function RoboticsFactory:OnConstructionComplete()    
       self:UpgradeToTechId(kTechId.ARCRoboticsFactory)
        self:AddTimedCallback(RoboticsFactory.Deploy, 3)      
        if self.arcFactory then
            self:UpgradeToTechId(kTechId.ARCRoboticsFactory)
        end
        
           if self:GetIsInSiege() then
          self.automaticspawningmac = false
          self.automaticspawningarc = true
         end
        
    end
    
end

function RoboticsFactory:OnOverrideOrder(order)

    // Convert default to set rally point.
    if order:GetType() == kTechId.Default then
        order:SetType(kTechId.SetRally)
    end
    
end

function RoboticsFactory:GetHealthbarOffset()
    return 1
end 

function RoboticsFactory:GetIsInSiege()
if string.find(self:GetLocationName(), "siege") or string.find(self:GetLocationName(), "Siege") then return true end
return false
end
function RoboticsFactory:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
function RoboticsFactory:ManufactureEntity()

    local mapName = LookupTechData(self.researchId, kTechDataMapName)    
    local owner = Shared.GetEntity(self.researchingPlayerId)
    
    local builtEntity = CreateEntity(mapName, self:GetOrigin(), self:GetTeamNumber())        
                
    if builtEntity ~= nil then             
    
        builtEntity:SetOwner(owner)
        builtEntity:SetAngles(self:GetAngles())
        builtEntity:SetIgnoreOrders(true)
       
    end
    
    return builtEntity
    
end


// Create entity but don't let the commander take control until it has rolled out
function RoboticsFactory:OverrideCreateManufactureEntity(techId)

    if techId == kTechId.ARC or techId == kTechId.MAC then
    
        self.researchId = techId
        self.open = true
        
        // Create entity inside ourselves, but wait until we are open before we move
        self.builtEntity = self:ManufactureEntity()
        
    end
    
end

function RoboticsFactory:CompleteRollout(entity)

    self:ClearResearch()
    self.open = false
    entity:SetIgnoreOrders(false)
    entity:ProcessRallyOrder(self)
    
end

Shared.LinkClassToMap("RoboticsFactory", RoboticsFactory.kMapName, networkVars, true)


class 'ARCRoboticsFactory' (RoboticsFactory)
ARCRoboticsFactory.kMapName = "arcroboticsfactory"
Shared.LinkClassToMap("ARCRoboticsFactory", ARCRoboticsFactory.kMapName, { })


class 'RoboticsAddon' (ScriptActor)

RoboticsAddon.kMapName = "RoboticsAddon"

local addonNetworkVars = { }

AddMixinNetworkVars(ModelMixin, addonNetworkVars)
AddMixinNetworkVars(TeamMixin, addonNetworkVars)

function RoboticsAddon:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)    
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    
end

Shared.LinkClassToMap("RoboticsAddon", RoboticsAddon.kMapName, addonNetworkVars)
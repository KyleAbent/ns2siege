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
Script.Load("lua/StunMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
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

//Siege
PrototypeLab.kJetpackTime = 0
PrototypeLab.kExoTime = 0


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
    deployed = "boolean",
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
AddMixinNetworkVars(DissolveMixin, networkVars)
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
    InitMixin(self, ParasiteMixin)
    InitMixin(self, StunMixin)
    
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
     self.stunned = false
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
    function PrototypeLab:OnConstructionComplete()
        self:AddTimedCallback(PrototypeLab.SpawnEntities, 8)      
    end
if Server then
function PrototypeLab:GetJPExoEntitiesCount()   
      local jps = 0
      local exos = 0
                    local entities = GetEntitiesForTeamWithinRange("ScriptActor", 1, self:GetOrigin(), 12)
                     for i = 1, #entities do
                     local ent = entities[i]
                           if ent:isa("Exosuit") then 
                             exos = exos + 1
                           elseif ent:isa("Jetpack") then
                                 jps = jps + 1
                           end
                     end
                     return jps, exos
end        
function PrototypeLab:SpawnEntities()   


                      local gameRules = GetGamerules()
            if gameRules then
                           gameRules:SpawnPrototypeEnts(self)  
            end
            
          return true

end
    function PrototypeLab:FindFreeSpace()
    
        for index = 1, 24 do
           local extents = Vector(1,1,1)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), .5, 10, EntityFilterAll())
        
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
           Print("No valid spot found for prototype spawn jp exo")
           return nil
    end
function PrototypeLab:OnStun()   
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

    function PrototypeLab:OnUpdateRender()
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
function PrototypeLab:GetIsStunAllowed()
    return  self:GetLastStunTime() + 16 < Shared.GetTime() and not self.stunned and GetAreFrontDoorsOpen() //and not self:GetIsVortexed()
end
function PrototypeLab:GetItemList(forPlayer)

    if forPlayer:isa("Exo") then
    
        if forPlayer:GetHasDualGuns() then
            return {}
        elseif forPlayer:GetHasRailgun() then
            return { kTechId.UpgradeToDualRailgun }    
        elseif forPlayer:GetHasMinigun() then
            return { kTechId.UpgradeToDualMinigun }
        end    

    end    
    
       local otherbuttons =  { kTechId.Jetpack, kTechId.Exosuit, kTechId.DualRailgunExosuit, kTechId.JumpPack, kTechId.HeavyArmor}
          
          if forPlayer.hasjumppack or forPlayer:isa("JetpackMarine")  or forPlayer:isa("Exo") or forPlayer.heavyarmor then
              otherbuttons[1] = kTechId.None
              otherbuttons[4] = kTechId.None
               otherbuttons[5] = kTechId.None
           end
           
           
         return otherbuttons
    
end

function PrototypeLab:GetReceivesStructuralDamage()
    return true
end


Shared.LinkClassToMap("PrototypeLab", PrototypeLab.kMapName, networkVars)
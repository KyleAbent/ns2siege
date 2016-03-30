Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/DetectorMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ParasiteMixin.lua")


class 'Dropship' (ScriptActor)

Dropship.kMapName = "dropship"

Dropship.kModelName = PrecacheAsset("models/marine/Dropship/dropship_animated.model")
Dropship.kCrashgedModelName = PrecacheAsset("models/marine/Dropship/dropship_crashed.model")


///Siege Random Automatic Passive Time Researches

local kAnimationGraph = PrecacheAsset("models/marine/Dropship/animated.animation_graph")
local kHallucinationMaterial = PrecacheAsset( "cinematics/vfx_materials/marine_highlight.material")
local networkVars = { 
                     flying = "boolean", 
    techId = "string (128)",
    mapname = "string (128)",
    isbeacon = "boolean",
     ipid = "entityid",
     flyspeed = "float (0 to 10 by .1)",
                     }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)

function Dropship:OnCreate()

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
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, DetectorMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, ParasiteMixin)

    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)  
    self.flying = true
    self.flyspeed = 1
    self.startsBuilt = true
    self.techId = kTechId.ARC
    self.mapname = ARC.kMapName
    self.isbeacon = false
    self.ipid = Entity.invalidI

end

function Dropship:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(Dropship.kModelName, kAnimationGraph)
    
    if Server then
    
        // This Mixin must be inited inside this OnInitialized() function.
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    InitMixin(self, IdleMixin)
        self:DoubleCheck()
    self:AddTimedCallback(Dropship.Derp, (14*self.flyspeed))
end
function Dropship:DoubleCheck()
    if self:isa("DropshipBeacon") then self.isbeacon = true end
end
function Dropship:GetDropStructureId()
    return self.techId
end
function Dropship:GetDropMapName()
    return self.mapname
end

function Dropship:SetTechId(techid)
     self.techId = techid
end
function Dropship:SetMapName(mapname)
     self.mapname = mapname
end
if Client then

    function Dropship:OnUpdateRender()
          local showMaterial = not GetAreEnemies(self, Client.GetLocalPlayer()) and self.isbeacon --and not self.flying
    
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
if Server then
 function Dropship:PreOnKill(attacker, doer, point, direction)
          /*
                  local gameRules = GetGamerules()
              if gameRules then
                 gameRules:DropshipDeath(self:GetOrigin(), self.flying, self.isbeacon)
               end  
          */
     self:ClearIPID()
                      
end
end
function Dropship:Derp()


    self.flying = false 
    self:SetModel(Dropship.kCrashgedModelName, kAnimationGraph)
    if self.isbeacon then 
       self:SetPhysicsGroup(PhysicsGroup.DropshipBeacon)  
                local ip = Shared.GetEntity(self.ipid)
             if ip then
                ip:FinishSpawn()
             end
       end
    
                self:UpdateModelCoords()
                self:UpdatePhysicsModel()
               if (self._modelCoords and self.boneCoords and self.physicsModel) then
              self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
               end  
               self:MarkPhysicsDirty()   
               
               
               
     if Server then 
     
              if not self.isbeacon then
              
               local entity = CreateEntity(self:GetDropMapName(), self:GetOrigin(), 1) 
               
                      if HasMixin(entity, "Construct") then
                       entity.isGhostStructure = false
                     end 
                     
               end
               
                   self:AddTimedCallback(Dropship.Delete, 1)      
       end   
 
return false
               
end


 if Server then
 
function Dropship:Delete()

        if self.isbeacon then
        self:ClearIPID()
        self:AddTimedCallback(Dropship.DeleteBeacon, 4)  
        else
        DestroyEntity(self)
        end
end
function Dropship:DeleteBeacon()
        DestroyEntity(self)
end   
function Dropship:ClearIPID()
             local ip = Shared.GetEntity(self.ipid)
             if ip then
                ip.spawnedship = Entity.invalidI
                ip:DeactivateBeacons()
             end
end             
end

function Dropship:GetTechButtons(techId)
local derp = {}
 derp = { kTechId.None, kTechId.None, kTechId.None, kTechId.None,
                                   kTechId.None, kTechId.None, kTechId.None, kTechId.None }    
    return derp
    
end
function Dropship:OnTag(tagName)
    if tagName == "stopflying" then
       self.flying = false
              local ip = Shared.GetEntity(self.ipid)
             if ip then
                ip:FinishSpawn()
             end
    end
end


function Dropship:GetReceivesStructuralDamage()
    return false
end
function Dropship:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
        coords.xAxis = coords.xAxis * .5
        coords.yAxis = coords.yAxis * .5
        coords.zAxis = coords.zAxis * .5
    return coords
end  
function Dropship:OnUpdateAnimationInput(modelMixin)

    PROFILE("Dropship:OnUpdateAnimationInput")
    
    modelMixin:SetAnimationInput("flying", self.flying)
    modelMixin:SetAnimationInput("speed", self.flyspeed)
    
end

if Server then
   function Dropship:GetIsFront()
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
end
function Dropship:GetLocationName()
        local location = GetLocationForPoint(self:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
function Dropship:GetCoolDown()
return kSiegeObsAutoScanCooldown
end
function Dropship:GetIsInSiege()
if string.find(self:GetLocationName(), "siege") or string.find(self:GetLocationName(), "Siege") then return true end
return false
end

function Dropship:GetHealthbarOffset()
    return 4
end 
function Dropship:GetDetectionRange()

    if GetIsUnitActive(self) then
        return Observatory.kDetectionRange
    end
    
    return 0
    
end

Shared.LinkClassToMap("Dropship", Dropship.kMapName, networkVars)


class 'DropshipBeacon' (Dropship)

DropshipBeacon.kMapName = "dropshipbeacon"


Shared.LinkClassToMap("DropshipBeacon", DropshipBeacon.kMapName, networkVars)
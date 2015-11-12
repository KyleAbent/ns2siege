// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\BoneWall.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/MapBlipMixin.lua")

class 'BoneWall' (CommanderAbility)

BoneWall.kMapName = "bonewall"

PrecacheAsset("cinematics/vfx_materials/hallucination.surface_shader")
local kHallucinationMaterial = PrecacheAsset( "cinematics/vfx_materials/hallucination.material")

BoneWall.kModelName = PrecacheAsset("models/alien/infestationspike/infestationspike.model")
local kAnimationGraph = PrecacheAsset("models/alien/infestationspike/infestationspike.animation_graph")

local kCommanderAbilityType = CommanderAbility.kType.OverTime
local kLifeSpan = 6

local kMoveOffset = 4
local kMoveDuration = 0.4

local networkVars =
{
    spawnPoint = "vector",
    modelsize = "float (0 to 10 by .1)",
    targetid = "entityid", 
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
local function TimeUp(self)
    self:OnKill()
    return false
end
local function Experiment(self)
                self:UpdateModelCoords()
                self:UpdatePhysicsModel()
               if (self._modelCoords and self.boneCoords and self.physicsModel) then
              self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
               end  
               self:MarkPhysicsDirty()   
               
               return false
end
function AlignBoneWalls(coords)

    local nearbyMarines = GetEntitiesWithinRange("Marine", coords.origin, 20)
    Shared.SortEntitiesByDistance(coords.origin, nearbyMarines)

    for _, marine in ipairs(nearbyMarines) do
    
        if marine:GetIsAlive() and marine:GetIsVisible() then

            local newZAxis = GetNormalizedVectorXZ(marine:GetOrigin() - coords.origin)
            local newXAxis = coords.yAxis:CrossProduct(newZAxis)
            coords.zAxis = newZAxis
            coords.xAxis = newXAxis
            break
        
        end
    
    end
    
    return coords

end
if Client then

    function BoneWall:OnUpdateRender()
          local showMaterial = not GetAreEnemies(self, Client.GetLocalPlayer())
    
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
function BoneWall:OnKill(attacker, doer, point, direction)
   local entity = Shared.GetEntity( self.targetid ) 
   if entity  then
  if entity:isa("Armory") or entity:isa("RoboticsFactory") then self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup) entity.stunned = false end 
  end
    self:TriggerEffects("death")
    if Server then
    if not self:GetIsDestroyed() then
    DestroyEntity(self)
    end
    end
end
function BoneWall:OnAdjustModelCoords(modelCoords)
    local coords = modelCoords
	local scale = self.modelsize
	local y = scale
	if y < 1 then y = 1 end
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * y
        coords.zAxis = coords.zAxis * scale
    return coords
end
function BoneWall:OnCreate()

    CommanderAbility.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, ObstacleMixin)
    
    if Server then
        InitMixin(self, MapBlipMixin)
    end
    self.modelsize = 1 
end

function BoneWall:OnInitialized()

    CommanderAbility.OnInitialized(self)
    
    self.spawnPoint = self:GetOrigin()
    self:SetModel(BoneWall.kModelName, kAnimationGraph)
    
    if Server then
        self:TriggerEffects("bone_wall_burst")
        local team = self:GetTeam()
        if team then
            local level = math.max(0, team:GetBioMassLevel() - 1)
            local newMaxHealth = kBoneWallHealth + level * kBoneWallHealthPerBioMass
            if newMaxHealth ~= self.maxHealth  then
                self:SetMaxHealth(newMaxHealth)
                self:SetHealth(self.maxHealth)
            end
        end
    end
    
    // Make the structure kinematic so that the player will collide with it.
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.AlienWalkThrough)
    
    if self.modelsize ~= 1 then 
     self:AddTimedCallback(Experiment, 0.5)
    end

   self:AddTimedCallback(TimeUp, self:GetLifeSpan())  
   self.targetid = Entity.invalidI
end


function BoneWall:OverrideCheckVision()
    return false
end

function BoneWall:GetSurfaceOverride()
    return "infestation"
end    

function BoneWall:GetType()
    return kCommanderAbilityType
end

function BoneWall:GetResetsPathing()
    return true
end

function BoneWall:GetLifeSpan()
    return kLifeSpan
end

function BoneWall:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function BoneWall:GetIsFlameAble()
    return true
end

Shared.LinkClassToMap("BoneWall", BoneWall.kMapName, networkVars)
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/SiegeMod/MoveableMixin.lua")
Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/MarineOutlineMixin.lua")

class 'SiegeDoor' (ScriptActor)

SiegeDoor.kMapName = "siegedoor"

local kOpeningEffect = PrecacheAsset("cinematics/environment/steamjet_ceiling.cinematic")

local networkVars =
{
    scale = "vector",
    model = "string (128)",
    moveSpeed = "float",
    isvisible = "boolean",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(MoveableMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)


function SiegeDoor:OnCreate()
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, MoveableMixin)
    InitMixin(self, TeamMixin)
    self.isvisible = true
end
function SiegeDoor:OnInitialized()

    ScriptActor.OnInitialized(self)  
    InitMixin(self, ScaledModelMixin)
    Shared.PrecacheModel(self.model) 
    self:SetModel(self.model)
	
    if Server then
    elseif Client then

    InitMixin(self, MarineOutlineMixin)
     InitMixin(self, HiveVisionMixin)
     
     /*
        	local model = self:GetRenderModel()
            HiveVision_AddModel( model )
            EquipmentOutline_AddModel( model ) 
     */
            /*
            self.OpeningEffect = Client.CreateCinematic(RenderScene.Zone_Default)
            self.OpeningEffect:SetCinematic(kOpeningEffect)
            self.OpeningEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.OpeningEffect:SetParent(self)
            self.OpeningEffect:SetCoords(self:GetCoords())
           // self.OpeningEffectSetAttachPoint(self:GetAttachPointIndex(attachPoint))
            self.OpeningEffect:SetIsActive(false)
            */
    end
    
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.FuncMoveable)
end

function SiegeDoor:Reset()
    ScriptActor.Reset(self)
    self.driving = false
    self:MakeSurePlayersCanGoThroughWhenMoving() 
end

function SiegeDoor:CreatePath(onUpdate) 
    local moveVector = Vector(kMoveXVector,kMoveUpVector,kMoveZVector)
    if self.direction == 1 then 
        moveVector = Vector(kMoveXVector,-kMoveUpVector,kMoveZVector)
    end
    self.waypoint = self:GetOrigin() + moveVector
end
/*
function SiegeDoor:ShowOpeningEffects()
  if self.OpeningEffect then
       self.OpeningEffect:SetIsActive(true)
  end
end
function SiegeDoor:DeleteOpeningEffects()
  if self.OpeningEffect then
       self.OpeningEffect:SetIsActive(false)
  end
end
*/
function SiegeDoor:GetSpeed()
    return kSiegeDoorSpeed
end

Shared.LinkClassToMap("SiegeDoor", SiegeDoor.kMapName, networkVars)

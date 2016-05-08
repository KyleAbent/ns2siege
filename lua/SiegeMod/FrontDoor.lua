Script.Load("lua/ScriptActor.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/SiegeMod/MoveableMixin.lua")
Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/MarineOutlineMixin.lua")

class 'FrontDoor' (ScriptActor)

FrontDoor.kMapName = "frontdoor"

local kOpeningEffect = PrecacheAsset("cinematics/environment/steamjet_ceiling.cinematic")

local networkVars =
{
    scale = "vector",
    model = "string (128)",
    moveSpeed = "float",
    isvisible = "boolean",
    cleaning = "boolean",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(MoveableMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)


function FrontDoor:OnCreate()
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, MoveableMixin)
    InitMixin(self, TeamMixin)
    self.isvisible = true
    self.cleaning = true
end
function FrontDoor:OnInitialized()

    ScriptActor.OnInitialized(self)  
    InitMixin(self, ScaledModelMixin)
    Shared.PrecacheModel(self.model) 
    self:SetModel(self.model)
	
    if Server then
    elseif Client then
    
     InitMixin(self, MarineOutlineMixin)
     InitMixin(self, HiveVisionMixin)
    end
    
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.FuncMoveable)
end

function FrontDoor:Reset()
    ScriptActor.Reset(self)
    self.driving = false
    self:MakeSurePlayersCanGoThroughWhenMoving() 
end

function FrontDoor:CreatePath(onUpdate) 
    local moveVector = Vector(kMoveXVector,kMoveUpVector,kMoveZVector)
    if self.direction == 1 then 
        moveVector = Vector(kMoveXVector,-kMoveUpVector,kMoveZVector)
    end
    self.waypoint = self:GetOrigin() + moveVector
end
/*
function FrontDoor:ShowOpeningEffects()
  if self.OpeningEffect then
       self.OpeningEffect:SetIsActive(true)
  end
end
function FrontDoor:DeleteOpeningEffects()
  if self.OpeningEffect then
       self.OpeningEffect:SetIsActive(false)
  end
end
*/
function FrontDoor:GetSpeed()
    return 0.25
end

function FrontDoor:SendLocationMessage()
        SendTeamMessage(1, kTeamMessageTypes.FrontDoorLocation, self:GetLocationId())
        SendTeamMessage(2, kTeamMessageTypes.FrontDoorLocation, self:GetLocationId())
end
Shared.LinkClassToMap("FrontDoor", FrontDoor.kMapName, networkVars)
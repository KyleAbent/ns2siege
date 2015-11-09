
Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'GravityTrigger' (Trigger)

GravityTrigger.kMapName = "gravity_trigger"

local networkVars =
{

}

AddMixinNetworkVars(LogicMixin, networkVars)


function GravityTrigger:OnCreate()
 
    Trigger.OnCreate(self)  
    
end
local function PushAllInTrigger(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        PushEntity(self, entity)
    end
    
end
local function PushEntity(self, entity)
if entity:isa("Player") then
          function entity:GetGravityForce(input)
          return -1
          end    
end
end
function GravityTrigger:OnInitialized()

    Trigger.OnInitialized(self) 
    if Server then
        InitMixin(self, LogicMixin)   
        self:SetUpdates(true)  
    end
    self:SetTriggerCollisionEnabled(true) 
    
end

function GravityTrigger:OnUpdate(deltaTime)
        PushAllInTrigger(self)
end

function GravityTrigger:OnTriggerEntered(enterEnt, triggerEnt) 
   if enterEnt:isa("Player") then
          function enterEnt:GetGravityForce(input)
          return -1
          end    
   end
end
    
function GravityTrigger:OnTriggerExited(exitEnt, triggerEnt)
/*
    if exitEnt:isa("Player") then
         function exitEnt:GetGravityForce(input)
            return exitEnt:GetMixinConstants().kGravity    
              end    
    end
    */
end


function GravityTrigger:OnLogicTrigger()
	self:OnTriggerAction()
end


Shared.LinkClassToMap("GravityTrigger", GravityTrigger.kMapName, networkVars)
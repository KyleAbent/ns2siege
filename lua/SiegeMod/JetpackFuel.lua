Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'JetpackFuel' (Trigger)

JetpackFuel.kMapName = "jetpack_fuel"

local networkVars =
{
}


AddMixinNetworkVars(LogicMixin, networkVars)

function JetpackFuel:OnCreate()
 
    Trigger.OnCreate(self)  
    
end
local function GiveFuel(self, entity)
 
    if entity:isa("JetpackMarine") then entity.infinitefuel = true end
    
end

local function FuelAllInTrigger(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        GiveFuel(self, entity)
    end
    
end

function JetpackFuel:OnInitialized()

    Trigger.OnInitialized(self) 
    if Server then
        InitMixin(self, LogicMixin)   
        self:SetUpdates(true)  
    end
    self:SetTriggerCollisionEnabled(true) 
    
end

function JetpackFuel:OnTriggerEntered(enterEnt, triggerEnt)

         GiveFuel(self, enterEnt)
    
end
function JetpackFuel:OnTriggerExited(exitEnt, triggerEnt)
    
    if exitEnt:isa("JetpackMarine") then exitEnt.infinitefuel = false end
end

//Addtimedcallback had not worked, so lets search it this way
function JetpackFuel:OnUpdate(deltaTime)

        FuelAllInTrigger(self)
    
end


function JetpackFuel:OnLogicTrigger()
	self:OnTriggerAction()
end



Shared.LinkClassToMap("JetpackFuel", JetpackFuel.kMapName, networkVars)
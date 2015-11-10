Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'WebTrigger' (Trigger)

WebTrigger.kMapName = "webtrigger"
    local dangersound = PrecacheAsset("sound/siegeroom.fev/webdanger/danger")
    local warningsound = PrecacheAsset("sound/siegeroom.fev/webdanger/warning")
local networkVars =
{
lastplayedsoundtime = "time",
}


AddMixinNetworkVars(LogicMixin, networkVars)

function WebTrigger:OnCreate()
 
    Trigger.OnCreate(self)  
    self.lastplayedsoundtime = 0
end
local function GiveWeb(self, entity)
 
    if entity:isa("Marine") then
     if Shared.GetTime() > self.lastplayedsoundtime + 2  then
        local roll = math.random(1,2)
        if roll == 1 and entity.hasjumppack then 
             StartSoundEffectForPlayer(dangersound, entity)
        elseif roll == 2 and entity.hasjumppack then 
             StartSoundEffectForPlayer(warningsound, entity)
        end
        self.lastplayedsoundtime = Shared.GetTime()
     end
     entity:SetWebbed(1) 
     elseif entity:isa("Exo") then 
    entity:SetWebbed(1) 
     end
    
end

local function WebAlInTrigger(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        GiveWeb(self, entity)
    end
    
end

function WebTrigger:OnInitialized()

    Trigger.OnInitialized(self) 
    if Server then
        InitMixin(self, LogicMixin)   
        self:SetUpdates(true)  
    end
    self:SetTriggerCollisionEnabled(true) 
    
end

function WebTrigger:OnTriggerEntered(enterEnt, triggerEnt)

         GiveWeb(self, enterEnt)
    
end
function WebTrigger:OnTriggerExited(exitEnt, triggerEnt)
/*
        if exitEnt:isa("Marine") then 
        local roll = math.random(1,2)
        if roll == 1 then
             StartSoundEffectForPlayer(dangersound, exitEnt)
        elseif roll == 2 then
             StartSoundEffectForPlayer(warningsound, exitEnt)
        end
     exitEnt:SetWebbed(1) 
     elseif exitEnt:isa("Exo") then 
    exitEnt:SetWebbed(1) 
     end
    */ 
end

//Addtimedcallback had not worked, so lets search it this way
function WebTrigger:OnUpdate(deltaTime)

        WebAlInTrigger(self)
    
end


function WebTrigger:OnLogicTrigger()
	self:OnTriggerAction()
end



Shared.LinkClassToMap("WebTrigger", WebTrigger.kMapName, networkVars)
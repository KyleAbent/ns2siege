//________________________________
//
//  NS2: Combat
//    Copyright 2014 Faultline Games Ltd.
//  and Unknown Worlds Ltd.
//
//________________________________

// FuncRotateable.lua
// Base entity for FuncRotateable things

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")

class 'FuncRotateable' (ScriptActor)

FuncRotateable.kMapName = "func_rotateable"
FuncRotateable.kMaxOpenDistance = 6
local kUpdateAutoOpenRate = 0.3
local kUpdateAutoCloseRate = 4

local networkVars =
{
    scale = "vector",
    model = "string (128)",
    rotationSpeed = "float",
    yaw = "float",
    pitch = "float",
    roll = "float",
    maxYaw = "float",
    maxPitch = "float",
    maxRoll = "float"
}

AddMixinNetworkVars(LogicMixin, networkVars)
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)



function FuncRotateable:OnCreate()
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    
    if Server then
        InitMixin(self, LogicMixin)
    end
    
end

function FuncRotateable:OnInitialized()

    ScriptActor.OnInitialized(self)  
    InitMixin(self, ScaledModelMixin)
    Shared.PrecacheModel(self.model) 
    self:SetModel(self.model)
	//self:SetScaledModel(self.model)
	
    self.savedAngles = Angles(self:GetAngles())
    self.rotatedYaw = 0
    self.rotatedPitch = 0
    self.rotatedRoll = 0  
end


function FuncRotateable:Reset()
    ScriptActor.Reset(self)
    self:SetAngles(self.savedAngles)
    self.rotatedYaw = 0
    self.rotatedPitch = 0
    self.rotatedRoll = 0  
end

if Server then
    function FuncRotateable:OnUpdate(deltaTime)
        if self.enabled then
            local angles = self:GetAngles() 

            local yawRotate = (self.yaw * self.rotationSpeed * deltaTime)
            local pitchRotate = (self.pitch * self.rotationSpeed * deltaTime)
            local rollRotate = (self.roll * self.rotationSpeed * deltaTime)
            
            if yawRotate > 0 and self.maxYaw > -1  and self.rotatedYaw < self.maxYaw then
                self.rotatedYaw = self.rotatedYaw +  yawRotate
                if self.rotatedYaw > self.maxYaw then
                    yawRotate = self.maxYaw - self.rotatedYaw 
                end
            else
                yawRotate = 0
            end
            
            if pitchRotate > 0 and self.maxPitch > -1  and self.rotatedPitch < self.maxPitch then
                self.rotatedPitch = self.rotatedPitch + pitchRotate 
                if self.rotatedPitch > self.maxPitch then
                    pitchRotate = self.maxPitch - self.rotatedPitch 
                end
            else
                pitchRotate = 0
            end
                
            if rollRotate > 0 and self.maxRoll > -1  and self.rotatedRoll < self.maxRoll then
                self.rotatedRoll = self.rotatedRoll + rollRotate 
                if self.rotatedRoll > self.maxPitch then
                    rollRotate = self.maxRoll - self.rotatedRoll 
                end
            else
                rollRotate = 0
            end
            
            if yawRotate == 0 and pitchRotate == 0 and rollRotate == 0 then
                // finished
                self.enabled = false
                self.rotatedYaw = 0
                self.rotatedPitch = 0
                self.rotatedRoll = 0  
                self:TriggerOutputs()
            else
                angles.yaw = angles.yaw + yawRotate
                angles.pitch = angles.pitch + pitchRotate
                angles.roll = angles.roll + rollRotate
                self:SetAngles(angles)
            end    
        end
        
    end
end

function FuncRotateable:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false   
end

function FuncRotateable:OnLogicTrigger(player)
	self:OnTriggerAction()  
end

Shared.LinkClassToMap("FuncRotateable", FuncRotateable.kMapName, networkVars)

Script.Load("lua/ExtraEntitiesMod/FuncTrain.lua")

class 'FuncPlatform' (FuncTrain)

FuncPlatform.kMapName = "func_platform"
FuncPlatform.kMoveSpeed = 15.0
FuncPlatform.kHoverHeight = 0.8

local networkVars =
{    
}

function FuncPlatform:OnCreate() 
    FuncTrain.OnCreate(self)    
end

function FuncPlatform:OnInitialized()
    FuncTrain.OnInitialized(self)
end

function FuncPlatform:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

//**********************************
// Driving things
//**********************************

function FuncPlatform:GetRotationEnabled()
    return false
end

function FuncPlatform:OnTargetReached()    
end

//**********************************
// Viewing things
//**********************************

function FuncPlatform:OnLogicTrigger(player)
    // if the elevator is moving, dont stop him
    if not self.driving then
        self:ChangeDrivingStatus()
    end
end


Shared.LinkClassToMap("FuncPlatform", FuncPlatform.kMapName, networkVars)
//________________________________
//
//  NS2: Combat
//    Copyright 2014 Faultline Games Ltd.
//  and Unknown Worlds Ltd.
//
//________________________________

// FuncTrain.lua
// Entity for mappers to create drivable trains

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/Mixins/SignalEmitterMixin.lua")
// needed for the MoveToTarget Command
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/TriggerMixin.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/SiegeMod/MoveableyMixin.lua")
Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")

class 'FuncTrain' (ScriptActor)

FuncTrain.kMapName = "func_train"
FuncTrain.kMoveSpeed = 15.0
FuncTrain.kHoverHeight = 0.8
FuncTrain.kDrivingState = enum( {'Stop', 'Forward1', 'Forward2', 'Forward3', 'Backwards'} )

local networkVars =
{    
    scale = "vector",
    model = "string (128)",
    moveSpeed = "float",
}

AddMixinNetworkVars(LogicMixin, networkVars)
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(MoveableyMixin, networkVars)
AddMixinNetworkVars(BaseMoveMixin, networkVars)


function FuncTrain:OnCreate()
 
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, SignalEmitterMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, BaseMoveMixin, { kGravity = 0})
    InitMixin(self, MoveableyMixin)
    
    self:SetUpdates(true)  
    
end

function FuncTrain:OnUpdate(deltaTime)

    if self.driving then
                
        if Server then
            //Print("Server, Time: " .. ToString(Shared.GetTime()) .. " " .. ToString(self.testorigin))
        elseif Client then
            //Print("Client, Time: " .. ToString(Shared.GetTime()) .. " " ..ToString(self.testorigin))
        end
        
    end
end


function FuncTrain:OnInitialized()

    ScriptActor.OnInitialized(self)
    InitMixin(self, TriggerMixin)
    InitMixin(self, ScaledModelMixin)
    Shared.PrecacheModel(self.model)
	self:SetModel(self.model)
    
    //self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsType(PhysicsType.Kinematic)
    // to prevent collision with whip bombs
    //self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    
    if Server then
        InitMixin(self, LogicMixin)
        
        if self.autoStart then
            self.driving = true
        else
            self.driving = false
        end
    end
   
end

function FuncTrain:Reset()
    self.nextWaypointNr = nil
end

function FuncTrain:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = true
end

function FuncTrain:OnUse(player, elapsedTime, useAttachPoint, usePoint, useSuccessTable)

    if Server then   
        self:ChangeDrivingStatus()
    elseif Client then
        //player:OnTrainUse(self) 
    end
    
end

//**********************************
// Driving things
//**********************************

function FuncTrain:ChangeDrivingStatus()

    if self.driving then
        self.driving = false
    else
        self.driving = true
    end  
    
    local driveString = "off"
    if self.driving then
        driveString = "on"
    end    
  
end 

function FuncTrain:GetSpeed()
    return self.moveSpeed or FuncTrain.kMoveSpeed
end

function FuncTrain:GetPushPlayers()
    return true
end

function FuncTrain:GetRotationEnabled()
    return not self.waiting
end


//**********************************
// Viewing things
//**********************************

function FuncTrain:GetViewOffset()
    return self:GetCoords().yAxis * 1.2
end

function FuncTrain:GetEyePos()
    return self:GetOrigin() + self:GetViewOffset()
end

function FuncTrain:GetViewAngles()
    local viewCoords = Coords.GetLookIn(self:GetEyePos(), self:GetOrigin())
    //local viewAngles = Angles()
    //return viewAngles:BuildFromCoords(viewCoords) or self:GetAngles().yaw
    local angles = Angles(0,0,0)
    angles.yaw = GetYawFromVector(viewCoords.zAxis)
    angles.pitch = GetPitchFromVector(viewCoords.xAxis)
    return angles
end

// will create a path so the train will know the next points
function FuncTrain:CreatePath(onUpdate)
    local origin = self:GetOrigin()
    local tempList = {}
    self.waypointList = {}
    for _, ent in ientitylist(Shared.GetEntitiesWithClassname("FuncTrainWaypoint")) do 
        // only search the waypoints for that train
        if ent.trainName == self.name then
            self.waypointList[ent.number] = {}
            self.waypointList[ent.number].origin = ent:GetOrigin()
            self.waypointList[ent.number].delay = ent.waitDelay
        end        
    end
    
    // then copy the wayPointList into a new List so its 1-n
    
    for i, wayPoint in pairs(self.waypointList) do
        table.insert(tempList, wayPoint)
    end
    
    // create a smooth path
    //self.waypointList = self:CreateSmoothPath(tempList, 1)      
    self.waypointList = tempList  

    tempList = nil
    
    if onUpdate then
        if (#self.waypointList  == 0) then
            self:SetUpdates(false)
            Print("Error: Train " .. self.name .. " found no waypoints!")
        end
    end
end

function FuncTrain:OnLogicTrigger(player)
    self:ChangeDrivingStatus()
end

function FuncTrain:OnTargetReached()
    self.driving = true
end

function FuncTrain:GetNextWaypoint()

    if self.waypointList and #self.waypointList > 0 then
    
        if not self.nextWaypointNr then
            self.nextWaypointNr = 1
            self.nextWaypoint = self.waypointList[self.nextWaypointNr].origin               
        else
            // check if the waypoint got a delay
            local delay = self.waypointList[self.nextWaypointNr].delay 
            local time = Shared.GetTime()

            if not self.nextWaypointCheck then
                self.nextWaypointCheck =  time + delay
            end
            
            if (self.waypointList[self.nextWaypointNr].delay == 0) or time >= self.nextWaypointCheck then 
                self.waiting = false
                self.nextWaypointNr = self.nextWaypointNr + 1
                // TODO: Dont start at one if last Waypoint
                if self.nextWaypointNr > #self.waypointList then
                    // end of track
                    //self.driving = false
                    //TODO : what happens then?
                    self.nextWaypointNr = 1
                end
                
                self.nextWaypoint = self.waypointList[self.nextWaypointNr].origin
                self.nextWaypointCheck = nil 
            else
                self.waiting = true
            end 
          
        end   

    else
        Print("Error: Train found no waypoints!")
    end
end

    
function FuncTrain:OnTriggerEntered(entity, triggerEnt)
end    

function FuncTrain:OnTriggerExited(entity, triggerEnt)
end       


Shared.LinkClassToMap("FuncTrain", FuncTrain.kMapName, networkVars)
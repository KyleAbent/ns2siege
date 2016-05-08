MoveableMixin = CreateMixin( MoveableMixin )
MoveableMixin.type = "Moveable"

kJitter = 0.1

MoveableMixin.expectedMixins =
{
}

MoveableMixin.expectedCallbacks =
{
    CreatePath = "Creates the path the moveable will move on",
    GetSpeed = "Movement speed of the moveable",
}

MoveableMixin.optionalCallbacks =
{
    GetNextWaypoint = "Returns the next waypoint, only called on Server"
}

MoveableMixin.networkVars =  
{
    driving = "boolean",
	savedOrigin = "vector",
    nextWaypoint = "vector",
}

function MoveableMixin:__initmixin() 
    self.driving = false
   if not self:isa("FuncMoveable") and not self:isa("func_train_nopushpull") then self.waypoint = self:GetOrigin() + Vector(0,10,0) end
end


function MoveableMixin:OnInitialized()

    self.savedOrigin = Vector(self:GetOrigin())
    self.savedAngles = Angles(self:GetAngles())        
    self:MakeSurePlayersCanGoThroughWhenMoving()
end

function MoveableMixin:OnUpdate(deltaTime) 
if Server then           
   if not self.driving and self.cleaning then //and self:isa("SiegeDoor") then
         if self:isa("FrontDoor") then
           for _, cysts in ipairs(GetEntitiesForTeamWithinRange("Cyst", 2, self:GetOrigin(), 15)) do
           DestroyEntity(cysts)
           end 
         end
     end  
        if self.driving then self:UpdatePosition(deltaTime)end
  end
end


function MoveableMixin:Reset()
    self:SetAngles(self.savedAngles)
    self:SetOrigin(self.savedOrigin)
    self.driving = false
                
    self.nextWaypoint = nil
    self.movementVector = nil
    
    // only the Server should generate the path
    if Server then
            self:CreatePath()
           if self:isa("FuncMoveable") or self:isa("func_train_nopushpull") then self.nextWaypoint = self:GetNextWaypoint() end
    end
    self:MakeSurePlayersCanGoThroughWhenMoving()
end

//**********************************
// Driving things
//**********************************

// TODO:Accept
// 1. Generate Path
// 2. Move
// called from OnUpdate when self.driving = true

function MoveableMixin:UpdatePosition(deltaTime)
    if self.driving then          
          local waypoint = nil          
              if self:isa("FuncMoveable") or self:isa("func_train_nopushpull") then 
                 wayPoint = self:GetWaypoint()
              else
                wayPoint = self.waypoint
              end
       self:MakeSurePlayersCanGoThroughWhenMoving()
       if  wayPoint then          
                local oldOrigin = self:GetOrigin()
                local movespeed = self:GetSpeed() 
                local directionVector = wayPoint - oldOrigin                
                local direction = GetNormalizedVector(wayPoint - oldOrigin)
                local endPoint = oldOrigin + direction * deltaTime * movespeed 

                // dont drive too far
                if directionVector:GetLength() <= (endPoint - oldOrigin):GetLength() then
                    endPoint = wayPoint
                end              

                self:SetOrigin(endPoint)
                //self:SetCoords(coords)                
                local movementVector = endPoint - oldOrigin
                self.movementVector = movementVector
                self:MakeSurePlayersCanGoThroughWhenMoving()
          end                   
                        
            if self:GetOrigin() == wayPoint then
                self.driving = false
                  if self:isa("FuncMoveable") or self:isa("func_train_nopushpull") then 
                  self.nextWaypoint = nil
                  self:OnTargetReached()
                  if Server then self.nextWaypoint = self:GetNextWaypoint() end
                  end
                 self:MakeSurePlayersCanGoThroughWhenMoving() 
            end
            
    end
            
end 
function MoveableMixin:GetWaypoint()
    if Server then
        if not self.nextWaypoint then
            self.nextWaypoint = self:GetNextWaypoint()
            return nil
        end
    end
    return self.nextWaypoint
end
function MoveableMixin:MakeSurePlayersCanGoThroughWhenMoving()
                self:UpdateModelCoords()
                self:UpdatePhysicsModel()
               if (self._modelCoords and self.boneCoords and self.physicsModel) then
              self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
               end  
               self:MarkPhysicsDirty()    
end

function AnglesToVector(self)            
    // y -1.57 in game is up in the air
    local angles =  self:GetAngles()
    local origin = self:GetOrigin()
    local directionVector = Vector(0,0,0)
    if angles then
        // get the direction Vector the pushTrigger should push you                
        
        // pitch to vector
        directionVector.z = math.cos(angles.pitch)
        directionVector.y = -math.sin(angles.pitch)
        
        // yaw to vector
        if angles.yaw ~= 0 then
            directionVector.x = directionVector.z * math.sin(angles.yaw)                   
            directionVector.z = directionVector.z * math.cos(angles.yaw)                                
        end  
    end
    return directionVector
end

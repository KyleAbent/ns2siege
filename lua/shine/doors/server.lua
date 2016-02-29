/*Kyle Abent Doors 
KyleAbent@gmail.com / 12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb - LOL
*/
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"

function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true

return true
end

function Plugin:OnFirstThink() 
 local neutralorigin = Vector(0, 0, 0)
 local count = 0 
 local time = kSiegeDoorTimey
     for _, tech in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
              neutralorigin = neutralorigin + tech:GetOrigin()
              count = count + 1
     end
     neutralorigin = neutralorigin/count
     Print("neutralorigin is %s", neutralorigin)
      local nearestdoor = GetNearestMixin(neutralorigin, "Moveable", nil, function(ent) return ent:isa("FrontDoor")  end)
           Print("nearestdoor is %s", nearestdoor)
        if nearestdoor then
                local points = PointArray()
                local isReachable = Pathing.GetPathPoints(neutralorigin, nearestdoor:GetOrigin(), points)
                if isReachable then
                    local distance = GetPointDistance(points)
                    Print("Distance is %s, isReachable", distance)
                    local time = Clamp(distance*12, 900, 1500)
                    Print("time is %s", time)
                else
                    local distance = (neutralorigin-nearestdoor:GetOrigin()):GetLength()
                     Print("Distance is %s, is not isReachable", distance)
                     time = Clamp(distance*12, 900, 1500)
                     Print("time is %s", time)
                end      
                
      local nearestotherdoor = GetNearestMixin(nearestdoor:GetOrigin(), "Moveable", nil, function(ent) return ent:isa("SiegeDoor")  end)    

                if nearestotherdoor then
                    local distance = nearestdoor:GetDistance(nearestotherdoor)
                    Print("to nearestotherdoor Distance is %s", distance)
                    time = time + Clamp(distance*4, 200, 900)
                    Print("time is %s", time)
                end
          end
             kFrontDoorTime = (300-60)+21
              time = Clamp(time,600, 1500)
             kSiegeDoorTimey = time
             self.siegetimer = time
               Print("time is %s", time)

end

function Plugin:AdjustTimer(Number)

local newtimer = 0
local calculation = kSiegeDoorTimey + (Number)
kSiegeDoorTimey = Clamp(calculation, 0, 1500)
self:UpdateGameInfo(kSiegeDoorTimey)                     
end
function Plugin:UpdateGameInfo(time)

    local entityList = Shared.GetEntitiesWithClassname("GameInfo")
    if entityList:GetSize() > 0 then
    
        local gameInfo = entityList:GetEntityAtIndex(0)
           gameInfo:SetSiegeTime(time)
   end
   
end    
function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end

function Plugin:CreateCommands()

local function AddSiegeTime( Client, Number, Boolean )

 self:AdjustTimer(Number)
end

local AddSiegeTimeCommand = self:BindCommand( "sh_addsiegetime", "addsiegetime", AddSiegeTime )
AddSiegeTimeCommand:AddParam{ Type = "number" }
AddSiegeTimeCommand:AddParam{ Type = "boolean", Optional = true, Default = false }
AddSiegeTimeCommand:Help( "adds timer to siegedoor and updates timer/countdown" )

end
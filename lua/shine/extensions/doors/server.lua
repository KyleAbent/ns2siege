/*Kyle Abent Doors 
KyleAbent@gmail.com / 12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb
*/
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"

//Shine.Hook.SetupClassHook( "NS2Gamerules", "ResetGame", "OnReset", "PassivePost" )


Shine.Hook.SetupClassHook( "NS2Gamerules", "OpenFrontDoors", "OnFrontDoor", "PassivePost" )
Shine.Hook.SetupClassHook( "NS2Gamerules", "OpenSideDoors", "OnSideDoor", "PassivePost" )
Shine.Hook.SetupClassHook( "NS2Gamerules", "OpenSiegeDoors", "OnSiegeDoor", "PassivePost" )



function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
self.GameStarted = false
self.siegetimer = 0
self.originalsiegetimer = 0
self.nextuse = 0

return true
end
/*
function Plugin:OnReset()
          if self:TimerExists(30) then self:DestroyTimer(30) end 
          if self:TimerExists(31) then self:DestroyTimer(31) end 
          if self:TimerExists(32) then self:DestroyTimer(32) end
end
*/

function Plugin:OnFrontDoor()
          if self:TimerExists(30) then self:DestroyTimer(30) end 
     Shine.ScreenText.End(6)
return 
end

function Plugin:OnFirstThink() 
 local neutralorigin = Vector(0, 0, 0)
 local count = 0 
 local time = kSiegeDoorTime
     for _, tech in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
              neutralorigin = neutralorigin + tech:GetOrigin()
              count = count + 1
     end
     neutralorigin = neutralorigin/count
     Print("neutralorigin is %s", neutralorigin)
      local nearestdoor = GetNearestMixin(neutralorigin, "Moveable", nil, function(ent) return ent:isa("FrontDoor")  end)
           Print("nearestdoor is %s", nearestdoor)
        if nearestdoor then
         --every 1 distance == 15 seconds?
                local points = PointArray()
                local isReachable = Pathing.GetPathPoints(neutralorigin, nearestdoor:GetOrigin(), points)
                if isReachable then
                    local distance = GetPointDistance(points)
                    Print("Distance is %s, isReachable", distance)
                    local time = Clamp(distance*15, 900, 1200)
                    Print("time is %s", time)
                else
                    local distance = (neutralorigin-nearestdoor:GetOrigin()):GetLength()
                     Print("Distance is %s, is not isReachable", distance)
                     time = Clamp(distance*15, 900, 1200)
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
             kFrontDoorTime = Clamp(kFrontDoorTime, 300, 301)
              time = Clamp(time,600, 1200)
             kSiegeDoorTime = time
             self.siegetimer = time
               Print("time is %s", time)

end

function Plugin:OnSideDoor()
          if self:TimerExists(33) then self:DestroyTimer(33) end 
     Shine.ScreenText.End(97)
return 
end
function Plugin:OnSiegeDoor()
          if self:TimerExists(31) then self:DestroyTimer(31) end 
     Shine.ScreenText.End(7)
return 
end

 function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end

      
  if GetGamerules():GetGameStarted() then
 
     
  if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kFrontDoorTime then
        if Shared.GetMapName() ~=  "ns2_rockdownsiege2" then
    local NowToFront = kFrontDoorTime - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local FrontLength =  math.ceil( Shared.GetTime() + NowToFront - Shared.GetTime() )
   Shine.ScreenText.Add( 6, {X = 0.40, Y = 0.75,Text = "Front Door(s) opens in %s",Duration = FrontLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
      else
    local NowToFront = kFrontDoorTime - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local FrontLength =  math.ceil( Shared.GetTime() + NowToFront - Shared.GetTime() )
   Shine.ScreenText.Add( 6, {X = 0.40, Y = 0.75,Text = "Secondary Door(s) opens in %s",Duration = FrontLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
   end
  end

   if  ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kSiegeDoorTime then
     local NowToSiege = kSiegeDoorTime - (Shared.GetTime() - GetGamerules():GetGameStartTime())
     local SiegeLength =  math.ceil( Shared.GetTime() + NowToSiege - Shared.GetTime() )
    Shine.ScreenText.Add( 7, {X = 0.60, Y = 0.95,Text = "Siege Door(s) opens in %s",Duration = SiegeLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
   end
                              if Shared.GetMapName() == "ns_siegeaholic_remade" or Shared.GetMapName() == "ns2_trainsiege2" then
               if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kSideDoorTime then
     local NowToSide = kSideDoorTime - (Shared.GetTime() - GetGamerules():GetGameStartTime())
     local SideLength =  math.ceil( Shared.GetTime() +  NowToSide - Shared.GetTime() )
              Shine.ScreenText.Add( 97, {X = 0.40, Y = 0.70,Text = "Side Doors opens in %s",Duration = SideLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
               end
               end

                     if Shared.GetMapName() ==  "ns2_rockdownsiege2" then
                                    if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kSideDoorTime then
     local NowToSide = kSideDoorTime - (Shared.GetTime() - GetGamerules():GetGameStartTime())
     local SideLength =  math.ceil( Shared.GetTime() +  NowToSide - Shared.GetTime() )
              Shine.ScreenText.Add( 97, {X = 0.40, Y = 0.70,Text = "Primary Doors opens in %s",Duration = SideLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
               end
               end
               
     

end
    
 end

function Plugin:SetGameState( Gamerules, State, OldState )

       if State == kGameState.Countdown then
          if self:TimerExists(30) then self:DestroyTimer(30) end 
          if self:TimerExists(31) then self:DestroyTimer(31) end 
          if self:TimerExists(32) then self:DestroyTimer(32) end
          if self:TimerExists(33) then self:DestroyTimer(33) end
          Shine.ScreenText.End(6)  
          Shine.ScreenText.End(7)  
          Shine.ScreenText.End(81)  
          Shine.ScreenText.End(82)  
          Shine.ScreenText.End(97)  
          Shine.ScreenText.End(98)  
          Shine.ScreenText.End(99)  
          Shine.ScreenText.End(100)  
          if self:TimerExists(20) then self:DestroyTimer(20) end
          if self:TimerExists(21) then self:DestroyTimer(21) end
          
        elseif State == kGameState.Started then 
          if self:TimerExists(30) then self:DestroyTimer(30) end 
          if self:TimerExists(31) then self:DestroyTimer(31) end 
          if self:TimerExists(32) then self:DestroyTimer(32) end
          if self:TimerExists(33) then self:DestroyTimer(33) end
        self.GameStarted = true
        
            if self.originalsiegetimer ~= 0 then
            kSiegeDoorTime = self.originalsiegetimer
           end
           
           self:CreateTimer(30, kFrontDoorTime, 1, function ()  Gamerules:OpenFrontDoors() end)
          self:CreateTimer(31, kSiegeDoorTime, 1, function ()  Gamerules:OpenSiegeDoors() end)
          self:CreateTimer(32, kSiegeDoorTime + kTimeAfterSiegeOpeningToEnableSuddenDeath, 1, function () Gamerules:EnableSuddenDeath() end)
           
           
        local DerpLength =  math.ceil( Shared.GetTime() + kFrontDoorTime - Shared.GetTime() )
       local SiegeLength =  math.ceil( Shared.GetTime() + kSiegeDoorTime - Shared.GetTime() )
       
       
                  if self.originalsiegetimer == 0 then
                 self.originalsiegetimer = kSiegeDoorTime
                  end


	 if  Shared.GetMapName() ~= "ns2_rockdownsiege2" then 
       Shine.ScreenText.Add( 6, {X = 0.40, Y = 0.75,Text = "Front Door(s) opens in %s",Duration = DerpLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
       else
        Shine.ScreenText.Add( 6, {X = 0.40, Y = 0.75,Text = "Secondary Door(s) opens in %s",Duration = DerpLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
       end
	   Shine.ScreenText.Add( 7, {X = 0.60, Y = 0.95,Text = "Siege Door(s) opens in %s",Duration = SiegeLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
	   
	   self:CreateTimer(20, kSiegeDoorTime + 1, 1, function ()
	   if self.GameStarted then
	   local SuddenDeathLength =  math.ceil( Shared.GetTime() + kTimeAfterSiegeOpeningToEnableSuddenDeath - Shared.GetTime() )
	   Shine.ScreenText.Add( 81, {X = 0.40, Y = 0.95,Text = "Sudden Death activates in %s",Duration = SuddenDeathLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
	   end
	   end)
	   
	   
	   self:CreateTimer(21,kSiegeDoorTime + kTimeAfterSiegeOpeningToEnableSuddenDeath, 1, function ()
	   if self.GameStarted then
	   Shine.ScreenText.Add( 82, {X = 0.40, Y = 0.95,Text = "Sudden Death is ACTIVE! (No CC/Hive Healing!)",Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
	   end
	   end)
	   
	                              if Shared.GetMapName() == "ns_siegeaholic_remade" or Shared.GetMapName() == "ns2_trainsiege2" then
	                       self:CreateTimer(33, kSideDoorTime, 1, function ()  Gamerules:OpenSideDoors() end)
              Shine.ScreenText.Add( 97, {X = 0.40, Y = 0.70,Text = "Side Doors opens in %s",Duration = kSideDoorTime,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
               end
               
               if Shared.GetMapName() == "ns2_rockdownsiege2" then
               	                       self:CreateTimer(33, kSideDoorTime, 1, function ()  Gamerules:OpenSideDoors() end)
              Shine.ScreenText.Add( 97, {X = 0.40, Y = 0.70,Text = "Primary Doors opens in %s",Duration = kSideDoorTime,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
               end
               
	   /*
         if Shared.GetMapName() == "ns2_biodome_siege" then
          local nineminlength = math.ceil( Shared.GetTime() + 540 - Shared.GetTime() )
          local fiteenminlength = math.ceil( Shared.GetTime() + 900 - Shared.GetTime() )
          local twentyminlength = math.ceil( Shared.GetTime() + 1200 - Shared.GetTime() )
          Shine.ScreenText.Add( 98, {X = 0.80, Y = 0.50,Text = "Bridge opens in %s",Duration = nineminlength,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
	      Shine.ScreenText.Add( 99, {X = 0.80, Y = 0.55,Text = "Vents opens in %s",Duration = fiteenminlength,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
	      Shine.ScreenText.Add( 100, {X = 0.80, Y = 0.60,Text = "Bamboo opens in %s",Duration = twentyminlength,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
         end
        */

              
      end        
              
     if State == kGameState.Team1Won or State == kGameState.Team2Won or State == kGameState.Draw then
     
      self.GameStarted = false
          if self:TimerExists(30) then self:DestroyTimer(30) end
          if self:TimerExists(31) then self:DestroyTimer(31) end 
          if self:TimerExists(32) then self:DestroyTimer(32) end
          if self:TimerExists(33) then self:DestroyTimer(33) end
          Shine.ScreenText.End(6) 
          Shine.ScreenText.End(7) 
          Shine.ScreenText.End(8)  
          Shine.ScreenText.End(9)  
          Shine.ScreenText.End(81) 
          Shine.ScreenText.End(82) 
          Shine.ScreenText.End(97)  
          Shine.ScreenText.End(98)  
          Shine.ScreenText.End(99)  
          Shine.ScreenText.End(100)  
          
      
   end
     
end

function Plugin:AdjustTimer(Number)
//Print("Adjust timer number is %s", Number)
self:DestroyTimer(31)
self:DestroyTimer(20)
Shine.ScreenText.End(7)  
Shine.ScreenText.End(81)  
local gameRules = GetGamerules()
local newtimer = 0
if kSiegeDoorTime == self.originalsiegetimer then
local gameLength = Shared.GetTime() - gameRules:GetGameStartTime()
local oldtimer = math.abs(kSiegeDoorTime - gameLength )
kSiegeDoorTime = oldtimer + (Number)
 newtimer = kSiegeDoorTime
else
local calculation = kSiegeDoorTime + (Number)
//Print("calculation is %s", calculation)
local gameLength = Shared.GetTime() - gameRules:GetGameStartTime()
calculation = Clamp(calculation, 1, self.originalsiegetimer - gameLength)
//Print("originalsiegetimer is %s", self.originalsiegetimer)
//Print("calculation is %s", calculation)
kSiegeDoorTime = calculation
 newtimer = kSiegeDoorTime
//Print("kSiegeDoorTime timer number is %s", kSiegeDoorTime)
//Print("newtimer timer number is %s", newtimer)
end
self:CreateTimer(31, newtimer, 1, function ()  gameRules:OpenSiegeDoors() end)
Shine.ScreenText.Add( 7, {X = 0.60, Y = 0.95,Text = "Siege Door(s) opens in %s",Duration = newtimer,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0, Size = 3, FadeIn = 0,} ) 

	   self:CreateTimer(20, newtimer + 1, 1, function ()
	   if self.GameStarted then
	   local SuddenDeathLength =  math.ceil( Shared.GetTime() + kTimeAfterSiegeOpeningToEnableSuddenDeath - Shared.GetTime() )
	   Shine.ScreenText.Add( 81, {X = 0.40, Y = 0.95,Text = "Sudden Death activates in %s",Duration = SuddenDeathLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
	   end
	   end)
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
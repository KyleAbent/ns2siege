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
               
                      if Shared.GetMapName() == "ns2_tram_siege" then
             
               if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < 1200 then
               local NowToNine = 1200 - (Shared.GetTime() - GetGamerules():GetGameStartTime())
               local NineLength =  math.ceil( Shared.GetTime() + NowToNine - Shared.GetTime() )
              Shine.ScreenText.Add( 97, {X = 0.80, Y = 0.50,Text = "Hub opens in %s",Duration = NineLength,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
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
        
           self:CreateTimer(30, kFrontDoorTime, 1, function ()  Gamerules:OpenFrontDoors() end)
          self:CreateTimer(31, kSiegeDoorTime, 1, function ()  Gamerules:OpenSiegeDoors() end)
          self:CreateTimer(32, kSiegeDoorTime + kTimeAfterSiegeOpeningToEnableSuddenDeath, 1, function () Gamerules:EnableSuddenDeath() end)
           
        local DerpLength =  math.ceil( Shared.GetTime() + kFrontDoorTime - Shared.GetTime() )
       local SiegeLength =  math.ceil( Shared.GetTime() + kSiegeDoorTime - Shared.GetTime() )

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
                  if Shared.GetMapName() == "ns2_tram_siege" then
          local tenminlength = math.ceil( Shared.GetTime() + 1200 - Shared.GetTime() )
    //      local fiteenminlength = math.ceil( Shared.GetTime() + 1200 - Shared.GetTime() )
    //      local twentyminlength = math.ceil( Shared.GetTime() + 1200 - Shared.GetTime() )
         // local twentyfiveminlength = math.ceil( Shared.GetTime() + 1500 - Shared.GetTime() )
          Shine.ScreenText.Add( 98, {X = 0.80, Y = 0.50,Text = "Hub opens in %s",Duration = tenminlength,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
	  //    Shine.ScreenText.Add( 99, {X = 0.80, Y = 0.55,Text = "South Tunnels opens in %s",Duration = fiteenminlength,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
	  //    Shine.ScreenText.Add( 100, {X = 0.80, Y = 0.60,Text = "Repair Room opens in %s",Duration = twentyminlength,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
	  //    Shine.ScreenText.Add( 97, {X = 0.80, Y = 0.65,Text = "Ore Processing opens in %s",Duration = twentyminlength,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
         end
           
              
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


function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end

function Plugin:CreateCommands()



end
/*Kyle Abent SiegeModCommands 
KyleAbent@gmail.com / 12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb
*/
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"

//Shine.Hook.SetupClassHook( "NS2Gamerules", "ResetGame", "OnReset", "PassivePost" )
/*
Shine.Hook.SetupClassHook( "NS2Gamerules", "FrontDoor", "OnFrontDoor", "Replace" )
Shine.Hook.SetupClassHook( "NS2Gamerules", "SiegeDoor", "OnSiegeDoor", "Replace" )
Shine.Hook.SetupClassHook( "NS2Gamerules", "SuddenDeath", "OnSuddenDeath", "Replace" )
*/

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
/*
function Plugin:OnFrontDoor()
return 
end
function Plugin:OnSiegeDoor()
return 
end
function Plugin:OnSuddenDeath()
return 
end
*/
 function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end

      
  if GetGamerules():GetGameStarted() then
 
     
  if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kFrontDoorTime then
    local NowToFront = kFrontDoorTime - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local FrontLength =  math.ceil( Shared.GetTime() + NowToFront - Shared.GetTime() )
   Shine.ScreenText.Add( 6, {X = 0.40, Y = 0.75,Text = "Front Door(s) opens in %s",Duration = FrontLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )

  end

   if  ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kSiegeDoorTime then
     local NowToSiege = kSiegeDoorTime - (Shared.GetTime() - GetGamerules():GetGameStartTime())
     local SiegeLength =  math.ceil( Shared.GetTime() + NowToSiege - Shared.GetTime() )
    Shine.ScreenText.Add( 7, {X = 0.60, Y = 0.95,Text = "Siege Door(s) opens in %s",Duration = SiegeLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
   end
   
   /*
      if  GetGamerules():GetSiegeDoorsOpen() then
     local NowToSuddendeath = kTimeAfterSiegeOpeningToEnableSuddenDeath - (Shared.GetTime() - GetGamerules():GetGameStartTime())
     local SuddenDeathLength =  math.ceil( Shared.GetTime() +  NowToSuddendeath - Shared.GetTime() )
	  Shine.ScreenText.Add( 81, {X = 0.40, Y = 0.95,Text = "Sudden Death activates in %s",Duration = SuddenDeathLength,R = 255, G = 255, B = 0,Alignment = 0,Size = 4,FadeIn = 0,} )
     end
     
     if  GetGamerules():GetIsSuddenDeath() then
	  Shine.ScreenText.Add( 82, {X = 0.40, Y = 0.95,Text = "Sudden Death is ACTIVE! (No Respawning)",Duration = 300,R = 255, G = 255, B = 0,Alignment = 0,Size = 4,FadeIn = 0,} )
     end
    */
    /*
             if Shared.GetMapName() == "ns2_biodome_siege" then
             
               if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < 540 then
               local NowToNine = 540 - (Shared.GetTime() - GetGamerules():GetGameStartTime())
               local NineLength =  math.ceil( Shared.GetTime() + NowToNine - Shared.GetTime() )
              Shine.ScreenText.Add( 98, {X = 0.80, Y = 0.50,Text = "Bridge opens in %s",Duration = NowToNine,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
               end
                              if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < 900 then
               local NowToFifteen = 900 - (Shared.GetTime() - GetGamerules():GetGameStartTime())
               local FifteenLength =  math.ceil( Shared.GetTime() + NowToFifteen - Shared.GetTime() )
               Shine.ScreenText.Add( 99, {X = 0.80, Y = 0.55,Text = "Vents opens in %s",Duration =  NowToFifteen,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
               end
                              if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < 1200 then
               local NowToTwenty = 1200 - (Shared.GetTime() - GetGamerules():GetGameStartTime())
               local TwentyLength =  math.ceil( Shared.GetTime() + TwentyLength - Shared.GetTime() )
                 Shine.ScreenText.Add( 100, {X = 0.80, Y = 0.60,Text = "Bamboo opens in %s",Duration = NowToTwenty,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
               end
         end
        */
                      if Shared.GetMapName() == "ns2_tram_siege" then
             
               if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < 1200 then
               local NowToNine = 1200 - (Shared.GetTime() - GetGamerules():GetGameStartTime())
               local NineLength =  math.ceil( Shared.GetTime() + NowToNine - Shared.GetTime() )
              Shine.ScreenText.Add( 97, {X = 0.80, Y = 0.50,Text = "Hub opens in %s",Duration = NowToNine,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
               end
               /*
                              if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < 1200 then
               local NowToFifteen = 1200 - (Shared.GetTime() - GetGamerules():GetGameStartTime())
               local FifteenLength =  math.ceil( Shared.GetTime() + NowToFifteen - Shared.GetTime() )
               Shine.ScreenText.Add( 99, {X = 0.80, Y = 0.55,Text = "South Tunnels opens in %s",Duration =  NowToFifteen,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
               end
                              if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < 1200 then
               local NowToTwenty = 1200 - (Shared.GetTime() - GetGamerules():GetGameStartTime())
               local TwentyLength =  math.ceil( Shared.GetTime() + NowToTwenty - Shared.GetTime() )
                 Shine.ScreenText.Add( 100, {X = 0.80, Y = 0.60,Text = "Repair Room opens in %s",Duration = NowToTwenty,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
                 Shine.ScreenText.Add( 98, {X = 0.80, Y = 0.65,Text = "Ore Processing opens in %s",Duration = NowToTwentyFive,R = 255, G = 255, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
               end
               */
         end      
     // */
     
                           if Shared.GetMapName() == "ns_siegeaholic_remade" then
             
               if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < 1200 then
     local NowToSide = kTimerAfterFrontOpeningToOpenSideDoor - (Shared.GetTime() - GetGamerules():GetGameStartTime())
     local SuddenSideLength =  math.ceil( Shared.GetTime() +  NowToSide - Shared.GetTime() )
              Shine.ScreenText.Add( 97, {X = 0.80, Y = 0.50,Text = "Side Door opens in %s",Duration = SuddenSideLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,} )
               end
               end
end
    
 end

function Plugin:SetGameState( Gamerules, State, OldState )

       if State == kGameState.Countdown then
          if self:TimerExists(30) then self:DestroyTimer(30) end 
          if self:TimerExists(31) then self:DestroyTimer(31) end 
          if self:TimerExists(32) then self:DestroyTimer(32) end
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
        self.GameStarted = true
        
           self:CreateTimer(30, kFrontDoorTime, 1, function ()  Gamerules:OpenFrontDoors() end)
          self:CreateTimer(31, kSiegeDoorTime, 1, function ()  Gamerules:OpenSiegeDoors() end)
          self:CreateTimer(32, kSiegeDoorTime + kTimeAfterSiegeOpeningToEnableSuddenDeath, 1, function () Gamerules:EnableSuddenDeath() end)
           
        local DerpLength =  math.ceil( Shared.GetTime() + kFrontDoorTime - Shared.GetTime() )
       local SiegeLength =  math.ceil( Shared.GetTime() + kSiegeDoorTime - Shared.GetTime() )

	
       Shine.ScreenText.Add( 6, {X = 0.40, Y = 0.75,Text = "Front Door(s) opens in %s",Duration = DerpLength,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,} )
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
	   
	                              if Shared.GetMapName() == "ns_siegeaholic_remade" then
	                       self:CreateTimer(30, kTimerAfterFrontOpeningToOpenSideDoor, 1, function ()  Gamerules:OpenSideDoors() end)
              Shine.ScreenText.Add( 97, {X = 0.80, Y = 0.50,Text = "Side Door opens in %s",Duration = kTimerAfterFrontOpeningToOpenSideDoor,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,} )
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
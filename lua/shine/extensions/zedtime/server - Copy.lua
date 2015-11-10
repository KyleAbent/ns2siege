/*Kyle Abent SiegeModCommands 
KyleAbent@gmail.com / 12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb
*/
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"
Plugin.HasConfig = true
Plugin.ConfigName = "zedtime.json"

Plugin.DefaultConfig = {
minimumtimeinsecondsbetweenzeds = 90,
thismanykilledwithinthatmanyseconds = 6,
thismuchtimebetweenthatmanykilled = 5,
minimumdurationzedtime = 3,
maximumdurationzedtime = 5,
zedtimeslowdownspeed = 0.5,
ignorethisteamnumberwhencheckingzedtime = 2,
minimumplayerstoactivatezedtime = 16
}
Plugin.CheckConfig = true
Plugin.CheckConfigTypes = true

function Plugin:Initialise()
self.Enabled = true
self.countofstructuresdestroyedwithinXtimespan = 0
self.minimumtimebetweenzeds = 0
self:CreateCommands()

return true
end
 function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[ZedTime]",  255, 0, 0, String, Format, ... )
end
 function Plugin:OnEntityKilled( Gamerules, Victim, Attacker, Inflictor, Point, Dir ) 
     if Shared.GetTime() > self.minimumtimebetweenzeds + self.Config.minimumtimeinsecondsbetweenzeds and Victim:GetTeamNumber() ~= self.Config.ignorethisteamnumberwhencheckingzedtime and not Victim:isa("Mine") then
          local gameRules = GetGamerules()
         if ( gameRules:GetGameStarted() and not gameRules:GetFrontDoorsOpen() ) or gameRules:GetIsSuddenDeath() and not Shared.GetCheatsEnabled() then return end
                      local add = 1
                      if Victim:isa("PowerPoint") then
                      add = 2
                      end
              self.countofstructuresdestroyedwithinXtimespan = self.countofstructuresdestroyedwithinXtimespan + add
               if self:TimerExists(1) then self:DestroyTimer(1) end         
           self:CreateTimer(1,self.Config.thismuchtimebetweenthatmanykilled, 1, function () self.countofstructuresdestroyedwithinXtimespan = 0 end) // self:NotifyGeneric( nil,  "5 sec timer reset destroyed count", true) end)
                   if self.countofstructuresdestroyedwithinXtimespan >= self.Config.thismanykilledwithinthatmanyseconds then
                   self:TriggerZedTime(self.Config.minimumdurationzedtime, self.Config.maximumdurationzedtime)
                   self.countofstructuresdestroyedwithinXtimespan = 0
                   self.minimumtimebetweenzeds = Shared.GetTime()
                   end
     end
end
function Plugin:TriggerZedTime(min, max)
   // if Shine.GetHumanPlayerCount() < self.Config.minimumplayerstoactivatezedtime then return end
     local duration = math.random(min,max)
     GetGamerules():SendZedTimeActivationMessage()
     Shared.ConsoleCommand(string.format("speed %s", self.Config.zedtimeslowdownspeed)) 
     Shine.ScreenText.Add( 73, {X = 0.45, Y = 0.70,Text = "Zed Time: %s",Duration = duration,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
     self:CreateTimer( 2, duration, 1, 
     function () 
     Shared.ConsoleCommand("speed 1" ) 
     GetGamerules():SendZedTimeDeActivationMessage()
      end )
end




function Plugin:CreateCommands()


local function ZedTime( Client )
local Gamerules = GetGamerules()
if not Gamerules then return end
self:TriggerZedTime(3,5)
Shine:Notify( Client, "Triggered Zed Time" )
end 

local ZedTimeCommand = self:BindCommand( "sh_zedtime", "zedtime", ZedTime )
ZedTimeCommand:Help( "triggers zed time" )




end


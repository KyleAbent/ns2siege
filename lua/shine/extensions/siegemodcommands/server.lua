/*Kyle Abent SiegeModCommands 
KyleAbent@gmail.com / 12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb
*/
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"
Shine.Hook.SetupClassHook( "MAC", "Notifyuse", "ReplaceUse", "Replace" )
Shine.Hook.SetupClassHook( "CommandStation", "ExperimentalBeacon", "PrintInfo", "Replace" )
Shine.Hook.SetupClassHook( "Alien", "OnRedeem", "OnRedemedHook", "PassivePre" )
Shine.Hook.SetupClassHook( "Alien", "TriggerRebirthCountDown", "TriggerRebirthCountDown", "PassivePre" )
Shine.Hook.SetupClassHook( "Player", "CopyPlayerDataFrom", "HookModelSize", "PassivePost" )
Shine.Hook.SetupClassHook( "Alien", "TunnelFailed", "FailMessage", "Replace" )
Shine.Hook.SetupClassHook( "Alien", "TunnelGood", "GoodMessage", "Replace" )


function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
self.GameStarted = false
self.playersize = {}
self.GlowClientsTime = {}
self.GlowClientsColor = {}
return true
end
function Plugin:ReplaceUse(player)

 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()
self:NotifySiege( Client, "Wait until front doors open to use macs.", true)
return
end
function Plugin:PrintInfo(anotheramt)
self:NotifySiege( nil, "MarineTeamBeacons Left: %s", true, anotheramt)
end
function Plugin:TunnelFailed(player)
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()
self:NotifySiege( Client, "Tunnel entrance failed to spawn. Try creating another. An entrance will spawn in the hive room location on infestation if theres room.", true)
end

function Plugin:GoodMessage(player)
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()
self:NotifySiege( Client, "Tunnel Entrnace placed at Hive.", true)
end
function Plugin:HookModelSize(player, origin, angles, mapName)
//if not self.playersize{Player:GetClient()} then return end
 local client = player:GetClient()
 if not client then return end
 local controlling = client:GetControllingPlayer()
 local size = self.playersize[controlling:GetClient()]
 local Time = Shared.GetTime()
 local Glow = self.GlowClientsTime[controlling:GetClient()]

 //self:NotifyGeneric( nil, "Glow = %s, time = %s", true, Glow, Time)
           //if Glow and Glow < Shared.GetTime() then controlling:GlowColor(Shared.GetTime() - 120) end
           if Glow and Glow > Time then   
           local color = self.GlowClientsColor[controlling:GetClient()]
            //self:NotifyGeneric( nil, "color = %s", true, color)
            //self:NotifyGeneric( nil, "Glow > Time", true)
                  self:SimpleTimer( 4, function () player:GlowColor(color, Glow - Time) end )     
                end
 //self:NotifyGeneric( nil, "playersize: %s", true,size)
                if not size or size == 1 then return end
                player.modelsize = size
             //  local defaulthealth = LookupTechData(player:GetTechId(), kTechDataMaxHealth, 1)
             //  player:AdjustMaxHealth(defaulthealth * size)
             //   player:AdjustMaxArmor(player:GetMaxArmor() * size)
    
   // self:NotifyGeneric( nil, "2", true)
   /*
   if not GetGamerules():GetGameStarted() and player.minemode then
   player.minemode = true
   Player:ApplyDurationCatPack(999) 
   end
   */
end

   function Plugin:OnRedemedHook(player) 
            Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.90,Text = "Redemption Cooldown: %s",Duration = kRedemptionCooldown,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, player ) 
 end
function Plugin:TriggerRebirthCountDown(player)
 Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.90,Text = "Rebirth Cooldown: %s",Duration = kRedemptionCooldown,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, player ) 
end

function Plugin:NotifyGiveRes( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[GiveRes]",  255, 0, 0, String, Format, ... )
end



function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Admin Abuse]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifySiege( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[NS2Siege]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyGiveRes( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[GiveRes]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyPoop( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[Bonewall Poop]", 144, 238, 144, String, Format, ... )
end
function Plugin:NotifyMines( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[MineMode]", 144, 238, 144, String, Format, ... )
end
function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end
function Plugin:GiveCyst(Player)
            local ent = CreateEntity(Cyst.kMapName, Player:GetOrigin(), Player:GetTeamNumber())  
             ent:SetConstructionComplete()
end
function Plugin:CreateCommands()
/*
local function MineMode( Client )
local Player = Client:GetControllingPlayer()
if GetGamerules():GetGameStarted() then 
self:NotifyMines(Client, "Minemode only allowed during pregame.", true)
return
end
    if Player.minemode == true then
    Player.minemode = false
    self:NotifyMines(Client, "Mine mode disabled. Removing infinite mines and allowing your mines to be blown up.", true)
    elseif Player.minemode == false then
    Player.minemode = true
    Player:ApplyDurationCatPack(999) 
    local mines = Player:GiveItem(LayMines.kMapName)
    self:NotifyMines(Client, "Minemode activated. Allowing infinite mines, and your mines will not blowup without your consent. Disable mine mode to have your mines detonate. Dying/changing class disables mine mode on you", true)
    end
end

local MineModeCommand = self:BindCommand( "sh_minemode", "minemode", MineMode, true)
MineModeCommand:Help( "Pregame only mine fun" )
*/

local function Stalemate( Client )
local Gamerules = GetGamerules()
if not Gamerules then return end
Gamerules:DrawGame()
//Shine:Notify( Client, "end the game." )
end 

local StalemateCommand = self:BindCommand( "sh_stalemate", "stalemate", Stalemate )
StalemateCommand:Help( "declares the round a draw." )local function Open( Client, String )
local Gamerules = GetGamerules()

     if String == "Front" or String == "front" then
       Gamerules:OpenFrontDoors()
     elseif String == "Side" or String == "side" then
       Gamerules:OpenSideDoors()
     elseif String == "Siege" or String == "siege" then
        Gamerules:OpenSiegeDoors()
     elseif String == "funcmoveable" or String == "FuncMoveable" then
        Gamerules:ToggleFuncMoveable()
         self:NotifyGeneric( nil, "toggled the %s doors", true, String)  
         return
    end 
  self:NotifyGeneric( nil, "Opened the %s doors", true, String)  
  
end 

local OpenCommand = self:BindCommand( "sh_open", "open", Open )
OpenCommand:AddParam{ Type = "string" }
OpenCommand:Help( "Opens <type> doors (Front/Side/Siege) (not case sensitive) - timer will still display." )

local function ThirdPerson( Client )
local Player = Client:GetControllingPlayer()
if not Player or not HasMixin( Player, "CameraHolder" ) then return end
Player:SetCameraDistance(3) //* ConditionalValue(not Player:isa("ReadyRoomPlayer") and Player.modelsize > 1, Player.modelsize * .5, 1))
end

local ThirdPersonCommand = self:BindCommand( "sh_thirdperson", { "thirdperson", "3rdperson" }, ThirdPerson, true)
ThirdPersonCommand:Help( "Triggers third person view" )
	
local function FirstPerson( Client )
local Player = Client:GetControllingPlayer()
if not Player or not HasMixin( Player, "CameraHolder" ) then return end
Player:SetCameraDistance(0)
end

local FirstPersonCommand = self:BindCommand( "sh_firstperson", { "firstperson", "1stperson" }, FirstPerson, true)
FirstPersonCommand:Help( "Triggers first person view" )

local function MainRoom( Client )
local Gamerules = GetGamerules()
Gamerules:PickMainRoom(true)
end

local MainRoomCommand = self:BindCommand( "sh_mainroom","mainroom", MainRoom)
MainRoomCommand:Help( "selects main room" )

local function GiveRes( Client, TargetClient, Number )
local Giver = Client:GetControllingPlayer()
local Reciever = TargetClient:GetControllingPlayer()
//local TargetName = TargetClient:GetName()
 //Only apply this formula to pres non commanders // If trying to give a number beyond the amount currently owned in pres, do not continue. Or If the reciever already has 100 resources then do not bother taking resources from the giver
  if Giver:GetTeamNumber() ~= Reciever:GetTeamNumber() or Giver:isa("Commander") or Reciever:isa("Commander") or Number > Giver:GetResources() or Reciever:GetResources() == 100 then
  self:NotifyGiveRes( Giver, "Unable to donate any amount of resources to %s", true, Reciever:GetName())
 return end 

 
            //If giving res to a person and that total amount exceeds 100. Only give what can fit before maxing to 100, and not waste the rest.
            if Reciever:GetResources() + Number > 100 then // for example 80 + 30 = 110
            local GiveBack = 0 //introduce x
            GiveBack = Reciever:GetResources() + Number // x = 80 + 30 (110)
            GiveBack = GiveBack - 100  // 110 = 110 - 100 (10)
            Giver:SetResources(Giver:GetResources () - Number + GiveBack) // Sets resources to the value wanting to donate + the portion to give back that's above 100
            local Show = Number - GiveBack
            Reciever:SetResources(100) // Set res to 100 anyway because the check above says if getres + num > 100. Therefore it would be 100 anyway.
              self:NotifyGiveRes( Giver, "%s has reached 100 res, therefore you've only donated %s resource(s)", true, Reciever:GetName(), Show)
              self:NotifyGiveRes( Reciever, "%s donated %s resource(s) to you", true, Giver:GetName(), Show)
            return //prevent from going through the process of handing out res again down below(?)
            end
            ////
 //Otherwise if the giver has the amount to give, and the reciever amount does not go beyond 100, complete the trade. (pres)     
 //Shine:Notify(Client, Number, TargetClient, "Successfully donated %s resource(s) to %s", nil)
Giver:SetResources(Giver:GetResources() - Number)
Reciever:SetResources(Reciever:GetResources() + Number)
self:NotifyGiveRes( Giver, "Succesfully donated %s resource(s) to %s", true, Number, Reciever:GetName())
self:NotifyGiveRes( Reciever, "%s donated %s resource(s) to you", true, Giver:GetName(), Number)
//Notify(StringFormat("[GiveRes] Succesfully donated %s resource(s) to %s.",  Number, TargetName) )


//Now for some fun and to expand on the potential of giveres within ns2 that ns1 did not reach?
//In particular, team res and commanders. 

//If the giver is a commander to a recieving teammate then take the resources out of team resources rather than personal.

//if Giver:GetTeamNumber() == Reciever:GetTeamNumber() and Giver:isa(Commander) then
end

local GiveResCommand = self:BindCommand( "sh_giveres", "giveres", GiveRes, true)
GiveResCommand:Help( "giveres <name> <amount> ~ (No commanders)" )
GiveResCommand:AddParam{ Type = "client",  NotSelf = true, IgnoreCanTarget = true }
GiveResCommand:AddParam{ Type = "number", Min = 1, Max = 100, Round = true }


local function Give( Client, Targets, String )
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
if Player and Player:GetIsAlive() and String ~= "alien" and not (Player:isa("Alien") and String == "armory") and not (Player:isa"ReadyRoomTeam" and String == "CommandStation" or String == "Hive") and not Player:isa("Commander") then
/*
Player:GiveItem(String)
        for index, target in ipairs(GetEntitiesWithMixinWithinRangeAreVisible("Construct", Player:GetOrigin(), 3, true )) do
              if not target:GetIsBuilt() then target:SetConstructionComplete() end
          end
 */
            
 local ent = CreateEntity(String, Player:GetOrigin(), Player:GetTeamNumber())  
if HasMixin(ent, "Construct") then  ent:SetConstructionComplete() end
             Shine:CommandNotify( Client, "gave %s an %s", true,
			 Player:GetName() or "<unknown>", String )  
end
end
end

local GiveCommand = self:BindCommand( "sh_give", "give", Give )
GiveCommand:AddParam{ Type = "clients" }
GiveCommand:AddParam{ Type = "string" }
GiveCommand:Help( "<player> Give item to player(s)" )

local function Glow( Client, Targets, Color, Duration )
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
   if HasMixin(Player, "Glow") and not Player:GetIsGlowing() then
            self.GlowClientsTime[Player:GetClient()] = Shared.GetTime() + Duration
            self.GlowClientsColor[Player:GetClient()] = Color
            Player:GlowColor(Color, Duration)
    end
end
end

local GlowCommand = self:BindCommand( "sh_glow", "glow", Glow )
GlowCommand:AddParam{ Type = "clients" }
GlowCommand:AddParam{ Type = "number" }
GlowCommand:AddParam{ Type = "number" }
GlowCommand:Help( "<player> " )
/*
local function NetworkVar( Client, Targets, String, Setting )
for i = 1, #Targets do
local Derp = Targets[ i ]:GetControllingPlayer()
 local client = Derp:GetClient()
 local Player = client:GetControllingPlayer()
      // local playervar = nil
      // if Player.String then playervar = Player.String end
         //  if playervar and Setting then
          // playervar = Setting
          Player.String = Setting
           self:NotifyGeneric( nil, "Changed %s networkvar %s to value %s", true, Player:GetName(), String, Setting)
         //  elseif playervar and Number then
         //  playervar = Number
       //    self:NotifyGeneric( nil, "Changed networkvar %s to value %s", true, playervar, Number)
     //      end
end
end

local NetworkVarCommand = self:BindCommand( "sh_nvar", "nvar", NetworkVar )
NetworkVarCommand:AddParam{ Type = "clients" }
NetworkVarCommand:AddParam{ Type = "string" }
NetworkVarCommand:AddParam{ Type = "string" }
//NetworkVarCommand:AddParam{ Type = "number", Optional = true }
NetworkVarCommand:Help( "<player> " )
*/
local function Cyst( Client, Targets )
     for i = 1, #Targets do
     local Player = Targets[ i ]:GetControllingPlayer()
         if Player and Player:GetIsAlive() and Player:isa("Alien") and not Player:isa("Commander") then
             self:GiveCyst(Player)
           self:NotifyGeneric( nil, "Gave %s an Cyst", true, Player:GetName())
          end
     end
end

local CystCommand = self:BindCommand( "sh_cyst", "cyst", Cyst )
CystCommand:AddParam{ Type = "clients" }
CystCommand:Help( "<player> Give cyst to player(s)" )

local function SlapBomb( Client, Targets, Number )
//local Giver = Client:GetControllingPlayer()
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
       if Player and Player:GetIsAlive() and not Player:isa("Commander") then
           self:NotifyGeneric( nil, "Commencing %s slaps on %s", true, Number, Player:GetName())
            self:CreateTimer( 13, 1, Number, 
            function () 
           if not Player:GetIsAlive()  and self:TimerExists( self.SlapMarineTimer ) then self:DestroyTimer( 13 ) return end
            Player:SetVelocity(  Player:GetVelocity() + Vector(math.random(-900,900),math.random(-900,900),math.random(-900,900)  ) )
            end )
end
end
end

local SlapBombCommand = self:BindCommand( "sh_slapbomb", "slapbomb", SlapBomb )
SlapBombCommand:Help ("sh_slapbomb <player(s)> <time> Sets a slap bomb on the player(s) with the number being iteration count")
SlapBombCommand:AddParam{ Type = "clients" }
SlapBombCommand:AddParam{ Type = "number" }



local function DiscoLights( Client )
 local Player = Client:GetControllingPlayer()
DiscoLights(Player:GetLocationName())
end

    
local DiscoLightsCommand = self:BindCommand( "sh_discolights", "discolights", DiscoLights )
DiscoLightsCommand:Help ("sh_discolights")


local function Construct( Client )
        local Player = Client:GetControllingPlayer()
        for index, constructable in ipairs(GetEntitiesWithMixinWithinRangeAreVisible("Construct", Player:GetEyePos(), 3, true )) do       
            if not constructable:GetIsBuilt() then
                constructable:SetConstructionComplete()
            end
            
        end
end

local ConstructCommand = self:BindCommand ("sh_construct", "construct", Construct)
ConstructCommand:Help ("Be close to the structure and use this to construct it")

local function Destroy( Client, String, StringTwo  )
        local player = Client:GetControllingPlayer()
        for _, entity in ipairs( GetEntitiesWithMixin( "Live" ) ) do
       // self:NotifyGeneric( Client, "Entities on map %s", true, entity:GetMapName())
            if string.find(entity:GetMapName(), String) and entity.GetLocationName then
         //   self:NotifyGeneric( Client, "Matching entities with string #1 and string#2(location name): %s, %s", true, entity:GetMapName(), String)
                if string.find(entity:GetLocationName(), StringTwo) then
                  self:NotifyGeneric( nil, "destroyed %s in %s", true, entity:GetMapName(), entity:GetLocationName())
                  DestroyEntity(entity) 
                 end
             end
         end
end

local DestroyCommand = self:BindCommand( "sh_destroy", "destroy", Destroy )
DestroyCommand:AddParam{ Type = "string" }
DestroyCommand:AddParam{ Type = "string" }
DestroyCommand:Help( "Destroy <entity> <location> (location is case sensitive where as entity is not)" )

local function Respawn( Client, Targets )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
	        	Shine:CommandNotify( Client, "respawned %s.", true,
				Player:GetName() or "<unknown>" )  
         Player:GetTeam():ReplaceRespawnPlayer(Player)
                 Player:SetCameraDistance(0)
     end
end

local RespawnCommand = self:BindCommand( "sh_respawn", "respawn", Respawn )
RespawnCommand:AddParam{ Type = "clients" }
RespawnCommand:Help( "<player> respawns said player" )
        
local function PlayerGravity( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("Commander") and Player:isa("Alien") or Player:isa("Marine") or Player:isa("ReadyRoomTeam") then
              self:NotifyGeneric( nil, "Adjusted %s players gravity to %s", true, Player:GetName(), Number)
              Player.gravity = Number
             end
//Glitchy way. There's resistance in the first person camera, to this. Perhaps try hooking with shine and changing that way, instead.
     end
end

local PlayerGravityCommand = self:BindCommand( "sh_playergravity", "playergravity", PlayerGravity )
PlayerGravityCommand:AddParam{ Type = "clients" }
PlayerGravityCommand:AddParam{ Type = "number" }
PlayerGravityCommand:Help( "sh_playergravity <player> <number> works differently than ns1. kinda glitchy. respawn to reset." )

local function BuildSpeed( Client, Number )

kDynamicBuildSpeed = Number
//self:NotifySiege( nil, "Adjusted Marine Construct Speed to %s percent (1 - (marineplayercount/12) + 1)", true, Number * 100)
end

local BuildSpeedCommand = self:BindCommand( "sh_buildspeed", "buildspeed", BuildSpeed )
BuildSpeedCommand:AddParam{ Type = "number" }
BuildSpeedCommand:Help( "sh_buildspeed adjust construct speed on demand." )


local function ModelSize( Client, Targets, Number )
  if Number > 10 then return end
    self:NotifyGeneric( nil, "Adjusted %s players size to %s percent", true, #Targets, Number * 100)
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("Commander") and not Player:isa("Spectator") and Player.modelsize and Player:GetIsAlive() then
             //  if not ( Player:isa("Exo") or Player:isa("Onos") and Number >= 2 ) or Number ~= 1 then Player:SetCameraDistance(Number) end
                Player.modelsize = Number
             //  local defaulthealth = LookupTechData(Player:GetTechId(), kTechDataMaxHealth, 1)
           //    Player:AdjustMaxHealth(defaulthealth * Number)
           //     Player:AdjustMaxArmor(Player:GetMaxArmor() * Number)
                self.playersize[Player:GetClient()] = Number
              //  self:NotifyGeneric( nil, "client modelsize set to %s", true, self.playersize[Player:GetClient()])
             end
     end
end

local ModelSizeCommand = self:BindCommand( "sh_modelsize", "modelsize", ModelSize )
ModelSizeCommand:AddParam{ Type = "clients" }
ModelSizeCommand:AddParam{ Type = "number" }
ModelSizeCommand:Help( "sh_playergravity <player> <number> works differently than ns1. kinda glitchy. respawn to reset." )

local function BringAll( Client )
    self:NotifyGeneric( nil, "Brought everyone to one locaiton/area", true)
    
        local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player and not Player:isa("Commander") and not Player:isa("Spectator") then
                       Player:SetOrigin(Client:GetControllingPlayer():GetOrigin())
                  end
              end
end

local BringAllCommand = self:BindCommand( "sh_bringall", "bringall", BringAll )
BringAllCommand:Help( "sh_bringall - teleports everyone to the same spot" )

local function TeamSize( Client, Number, NumberTwo )
  if NumberTwo > 10 or (Number ~= 1 and Number ~= 2) then return end
   if Number == 1 then
    self:NotifyGeneric( nil, "Adjusted Marines team size to %s", true, NumberTwo * 100)
    elseif Number == 2 then
        self:NotifyGeneric( nil, "Adjusted Aliens team size to %s", true, NumberTwo * 100)
    end
    
    local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player and Player:GetTeamNumber() == Number and not Player:isa("Commander") and not Player:isa("Spectator") and Player.modelsize then
                         Player.modelsize = NumberTwo
                     //    local defaulthealth = LookupTechData(Player:GetTechId(), kTechDataMaxHealth, 1)
                    //    Player:AdjustMaxHealth(defaulthealth * NumberTwo)
                    //   Player:AdjustMaxArmor(Player:GetMaxArmor() * NumberTwo)
                       self.playersize[Player:GetClient()] = NumberTwo
                  end
              end
end

local TeamSizeCommand = self:BindCommand( "sh_teamsize", "teamsize", TeamSize )
TeamSizeCommand:AddParam{ Type = "number" }
TeamSizeCommand:AddParam{ Type = "number" }
TeamSizeCommand:Help( "sh_teamsize." )

local function lights( Client )

   local lightnumber = math.random(1,4)
   local lightmode = nil
   if lightnumber == 1 then
   lightmode = kLightMode.Normal
   elseif lightnumber == 2 then
   lightmode = kLightMode.NoPower
   elseif lightnumber == 3 then
   lightmode = kLightMode.Damaged
   elseif lightnumber == 4 then
   lightmode = kLightMode.LowPower
   end
     for index, power in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
      power:SetLightMode(lightmode)
    end
  self:NotifyGeneric( nil, "turned all of the lights to setting of # %s", true, lightmode)
  
end

local LightsCommand = self:BindCommand( "sh_lights", "lights", lights )
LightsCommand:Help( "sh_lights - " )

/*
local function TimeBomb(Client, Targets)
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer() 
        if not Player:isa("Commander") and ( Player:isa("Alien") or Player:isa("Marine") ) and Player:GetIsAlive() then
        Shine.ScreenText.Add( "TimeBomb", {X = 0.50, Y = 0.50,Text = Player:GetName() .."will explode in %s", Duration = kTimeBombTimer,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,} )
                  self:SimpleTimer( kTimeBombTimer, 
                  function () 
                  if not Player:GetIsAlive() then return end
                  Player:TriggerEffects("xenocide", {effecthostcoords = Coords.GetTranslation(Player:GetOrigin())})
                  local hitEntities = GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(Player:GetTeamNumber()), Player:GetOrigin(), 12)
                  RadiusDamage(hitEntities, Targets:GetClient():GetOrigin(), 12, 1000, Targets:GetClient())
                  Player:Kill()
                  end )
             end
        end
end

local TimeBombCommand = self:BindCommand( "sh_timebomb", "timebomb", TimeBomb )
TimeBombCommand:AddParam{ Type = "clients" }
TimeBombCommand:Help( "sh_timebomb <player> makes the person xenocide basically" )

*/
/*
local function PlayerFriction( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("Commander") and Player:isa("Alien") or Player:isa("Marine") or Player:isa("ReadyRoomTeam") then
               //Player:GetMixinConstants().kGravity = Number    
               function Player:GetFriction(input, velocity)
               local friction = Number
               local frictionScalar = 1
               return friction * frictionScalar
               end    
             end
//Glitchy way. There's resistance in the first person camera, to this. Perhaps try hooking with shine and changing that way, instead.
     end
end

local PlayerFrictionCommand = self:BindCommand( "sh_playerfriction", "playerfriction", PlayerFriction )
PlayerFrictionCommand:AddParam{ Type = "clients" }
PlayerFrictionCommand:AddParam{ Type = "number" }
PlayerFrictionCommand:Help( "sh_playerfriction <player> <number> works differently than ns1. kinda glitchy. respawn to reset." )
*/

local function Pres( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("ReadyRoomTeam")  and Player:isa("Alien") or Player:isa("Marine") then
            Player:SetResources(Number)
           	 Shine:CommandNotify( Client, "set %s's resources to %s", true,
			 Player:GetName() or "<unknown>", Number )  
             end
     end
end

local PresCommand = self:BindCommand( "sh_pres", "pres", Pres)
PresCommand:AddParam{ Type = "clients" }
PresCommand:AddParam{ Type = "number" }
PresCommand:Help( "sh_pres <player> <number> sets player's pres to the number desired." )


local function RandomRR( Client )
        local rrPlayers = GetGamerules():GetTeam(kTeamReadyRoom):GetPlayers()
        for p = #rrPlayers, 1, -1 do
            JoinRandomTeam(rrPlayers[p])
        end
           Shine:CommandNotify( Client, "randomized the readyroom", true)  
end

local RandomRRCommand = self:BindCommand( "sh_randomrr", "randomrr", RandomRR )
RandomRRCommand:Help( "randomize's the ready room.") 


end
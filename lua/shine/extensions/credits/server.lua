/*Kyle Abent SiegeModCommands 
KyleAbent@gmail.com / 12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb
*/
local Shine = Shine
local Plugin = Plugin
local HTTPRequest = Shared.SendHTTPRequest

Shine.CreditData = {}
Shine.LinkFile = {}
Shine.BadgeFile = {}
Plugin.Version = "10.28"

local CreditsPath = "config://shine/plugins/credits.json"
local URLPath = "config://shine/CreditsLink.json"

Shine.Hook.SetupClassHook( "ScoringMixin", "AddScore", "OnScore", "PassivePost" )
Shine.Hook.SetupClassHook( "Marine", "OnCreate", "HookOnCareMarine", "PassivePost" )
Shine.Hook.SetupClassHook( "NS2Gamerules", "ResetGame", "OnReset", "PassivePost" )
Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyMist", "BecauseFuckSpammingCommanders", "Replace" )
Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyMed", "BuyMed", "Replace" )
Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyAmmo", "BuyAmmo", "Replace" )
Shine.Hook.SetupClassHook( "Marine", "TellMarine", "ToDropBlue", "Replace" )
Shine.Hook.SetupClassHook( "Marine", "UpdateCredits", "ToAmount", "Replace" )
Shine.Hook.SetupClassHook( "Player", "TogglePlayerAlltalk", "ToggleAlltalk", "Replace" )



function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
self.GameStarted = false
self.CreditAmount = 0
self.CreditUsers = {}
self.BuyUsersTimer = {}

self.MarineTotalSpent = 0
self.AlienTotalSpent = 0
self.Refunded = false

self.PlayerSpentAmount = {}

return true
end
function Plugin:HookOnCareMarine()
  self:AdjustBuildSpeed()
end
function Plugin:ToAmount(player)
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()
        local credits = self:GetPlayerCreditsInfo(Client)
        Print("User has %s credits", credits)
        local Player = Client:GetControllingPlayer()
        Player.credits = math.round(credits, 2)
end
function Plugin:ToDropBlue(player)
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()
if player:GetHasLayStructure() then
 self:NotifyBuy( Client, "Laystructure (hudslot 5) already active. Drop the blueprint before continuing.", true, player:GetResources())
end
end
function Plugin:GenereateTotalCreditAmount()
local credits = 0
Print("%s users", table.Count(self.CreditData.Users))
for i = 1, table.Count(self.CreditData.Users) do
    local table = self.CreditData.Users.credits
    credits = credits + table
end
Print("%s credits",credits)
end

function Plugin:BuyMed(player)
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()


        if player:GetResources() == 0 then
        self:NotifyBuy( Client, "Medpack costs 1 resource, you have %s resources. Purchase invalid.", true, player:GetResources())
        else
        local position = GetGamerules():FindCustomFreeSpace(player, 0, 4)
        self:SimpleTimer(2, function () if not player or not player:GetIsAlive() then return else CreateEntity(MedPack.kMapName, position, 1) player:SetResources(player:GetResources() - 1) end end)
        end
end
function Plugin:BuyAmmo(player)
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()

        if player:GetResources() < 1 then
        self:NotifyBuy( Client, "AmmoPack costs 1 resource, you have %s resources. Purchase invalid.", true, player:GetResources()) 
        else
        local position = GetGamerules():FindCustomFreeSpace(player, 0, 4)
       self:SimpleTimer(2, function () if not player or not player:GetIsAlive() then return else CreateEntity(AmmoPack.kMapName, position, 1) player:SetResources(player:GetResources() - 1) end end)
        end
end
function Plugin:ToggleAlltalk(player)
local controlling = player:GetControllingPlayer()
local Client = controlling:GetClient()

        if player.alltalktoggled == true then
        player.alltalktoggled = false
        self:NotifyBuy( Client, "[[2.16 UNTESTED]]Only your teammates can hear your microphone now.", true) 
        else
        player.alltalktoggled = true
        self:NotifyBuy( Client, "[[2.16 UNTESTED]]Everybody on the server can now hear your microphone", true) 
        end
end
local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end

function Plugin:HasResPoint(Player)
     for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do 
        if respoint.ParentId == Player:GetId() then return true end
    end
    return false
end

function Plugin:HasLimitOf(Player, classname, teamnumbber, limit)
local entitycount = 0
local entities = {}
    for _, entity in ipairs( GetEntitiesForTeam(classname, teamnumbber)) do
        if entity:GetOwner() == Player and entity.iscreditstructure == true then entitycount = entitycount + 1 end
        table.insert(entities, entity)
    end
    
     //             <
    if entitycount ~= limit then return false end

            if #entities > 0 then
            local entity = table.random(entities)
             if string.find(classname, "Sentry") or string.find(classname, "Observatory") or string.find(classname, "ARC") then return true end
                DestroyEntity(entity)
            end
     return true
end
function Plugin:BecauseFuckSpammingCommanders(player)
if not GetGamerules():GetGameStarted() then return end
local CreditCost = 1
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
player:GiveItem(NutrientMist.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 3
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
     self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end
local function GetIsAlienInSiege(Player)
   if  Player.GetLocationName and 
   string.find(Player:GetLocationName(), "siege") or string.find(Player:GetLocationName(), "Siege") then
   return true
    end
    return false
 end

function Plugin:OnScore( Player, Points, Res, WasKill )
if Points ~= nil and Points ~= 0 and Player and GetGamerules():GetGameStarted() then
 local client = Player:GetClient()
 if not client then return end
         
    local addamount = Points/(10/kCreditMultiplier)      
 local controlling = client:GetControllingPlayer()
 
self.CreditUsers[ controlling:GetClient() ] = self:GetPlayerCreditsInfo(controlling:GetClient()) + addamount
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(controlling:GetClient()) ), controlling:GetClient()) 
end
end
function Plugin:NotifySiege( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Siege]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end




function Plugin:OnReset()
  if self.GameStarted and not self.Refunded then
       self:NotifyCredits( nil, "Did you spend any credits only for the round to reset? If so, then no worries! - You have just been refunded!", true )
       
              Shine.ScreenText.End("Credits")  
              Shine.ScreenText.End(80)
              Shine.ScreenText.End(81)  
              Shine.ScreenText.End(82)  
              Shine.ScreenText.End(83)  
              Shine.ScreenText.End(84)  
              Shine.ScreenText.End(85)  
              Shine.ScreenText.End(86)   
              Shine.ScreenText.End(87)  
              self.MarineTotalSpent = 0 
              self.AlienTotalSpent = 0
              self.CreditUsers = {}
              self.PlayerSpentAmount = {}
          
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.95,Text = string.format( "%s Credits", self:GetPlayerCreditsInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
    self.Refunded = true
   end     
end

function Plugin:OnFirstThink() 
local CreditsFile = Shine.LoadJSONFile( CreditsPath )
self.CreditData = CreditsFile


        if not Shine.Timer.Exists("SeedTimer") then
        	Shine.Timer.Create( "SeedTimer", 600, -1, function() self:SeedCredits() end )
      end

end
 function Plugin:SeedCredits()
             
 self:GiveSeedCredits() 
 
 end
 function Plugin:GiveSeedCredits()
 local credits = 10 * kCreditMultiplier
   if kCreditMultiplier == 1 then
 self:NotifyCredits( nil, "%s Credits", true, credits)
 elseif kCreditMultiplier == 2 then
  self:NotifyCreditsDC( nil, "%s Credits", true, credits)
 end
 
  local Players = Shine.GetAllPlayers()
   for i = 1, #Players do
    local player = Players[ i ]
     if player then
      self.CreditUsers[ player:GetClient() ] = self:GetPlayerCreditsInfo(player:GetClient()) + credits
          if self.GameStarted then
          Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(player:GetClient()) ), player:GetClient()) 
          end
      end
   end
 end
 
function Plugin:SaveCredits(Client, notify)
       local Data = self:GetCreditData( Client )
       if Data and Data.credits then 
         if not Data.name or Data.name ~= Client:GetControllingPlayer():GetName() then
           Data.name = Client:GetControllingPlayer():GetName()
           end  //      

       

                    
                    
              local cap = kCreditsPerRoundCap 
          local creditstosave = self:GetPlayerCreditsInfo(Client)
          local earnedamount = math.max(creditstosave,Data.credits) - math.min(creditstosave,Data.credits)
          if earnedamount > cap then 
          creditstosave = Data.credits + cap
                if notify then
             self:NotifyCredits( Client, "%s Credit cap per round exceeded. You earned %s credits this round. Only %s are saved. So your new total is %s", true, kCreditsPerRoundCap, earnedamount, kCreditsPerRoundCap, creditstosave )
             Shine.ScreenText.SetText("Credits", string.format( "%s Credits", creditstosave ), Client) 
                end
           end
           
            Data.credits = creditstosave 
            
            //Data.credits = self:GetPlayerCreditsInfo(Client)
       else
      self.CreditData.Users[Client:GetUserId() ] = {credits = self:GetPlayerCreditsInfo(Client), name = Client:GetControllingPlayer():GetName() }
       end//
         //Shine.SaveJSONFile( self.CreditData, CreditsPath  ) 
end
function Plugin:ClientDisconnect(Client)
 if Client:isa("Marine") and Client:GetIsBuilding() then Client:GetWeaponInHudSlot(5):Dropped() end
self:SaveCredits(Client)
 self:AdjustBuildSpeed()
end
function Plugin:AdjustBuildSpeed()
       local team1PlayerCount = GetGamerules():GetTeam(kTeam1Index):GetNumPlayers()
        local team2PlayerCount = GetGamerules():GetTeam(kTeam2Index):GetNumPlayers()
        local active = (team1PlayerCount + team2PlayerCount)
        



          
              local ratio = (self:GetActivePlayers()/24)
              local bonus  = 1 -  ratio + 1
              if bonus ~= kDynamicBuildSpeed then
             Shared.ConsoleCommand(string.format("sh_buildspeed %s", math.round(bonus,1)))
              end 
              
              //kMaxSupply = kMaxSupply - ratio * kMaxSupply
          kMarineRespawnTime = GetFairRespawnLength()
//          kAlienSpawnTime = GetHandicapRespawnLength()

end
function Plugin:GetActivePlayers()
       local active = 0
               local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
                    local Player = Players[ i ]
                   if Player then
                   if Player:GetTeamNumber() == 1 or Player:GetTeamNumber() == 2 then active = active + 1 end
                    end
              end       
              kActivePlayers = active
              return kActivePlayers
end
function Plugin:GetPlayerCreditsInfo(Client)
   local Credits = 0
       if self.CreditUsers[ Client ] then
          Credits = self.CreditUsers[ Client ]
       elseif not self.CreditUsers[ Client ] then 
          local Data = self:GetCreditData( Client )
           if Data and Data.credits then 
           Credits = Data.credits 
           end
       end
return math.round(Credits, 2)
end
local function GetIDFromClient( Client )
	return Shine.IsType( Client, "number" ) and Client or ( Client.GetUserId and Client:GetUserId() ) // or nil //or nil was blocked but im testin
 end
function Plugin:GetCreditData(Client)
  if not self.CreditData then return nil end
  if not self.CreditData.Users then return nil end
  local ID = GetIDFromClient( Client )
  if not ID then return nil end
  local User = self.CreditData.Users[ tostring( ID ) ] 
  if not User then 
     local SteamID = Shine.NS2ToSteamID( ID )
     User = self.CreditData.Users[ SteamID ]
     if User then
     return User, SteamID
     end
     local Steam3ID = Shine.NS2ToSteam3ID( ID )
     User = self.CreditData.Users[ ID ]
     if User then
     return User, Steam3ID
     end
     return nil, ID
   end
return User, ID
end

 function Plugin:ClientConnect(Client)
     --SO I can seed and AFK  without being randomized onteam while afk :P
     if Client:GetUserId() == 22542592 then
     
     self:SimpleTimer( 4, function() 
     Shared.ConsoleCommand(string.format("sh_setteam %s 3", Client:GetUserId())) 
      end)

     end
 
 
 end
 function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end
 
 self:AdjustBuildSpeed()
 
   Client.credits = self:GetPlayerCreditsInfo(Client)
  if GetGamerules():GetGameStarted() then

  Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.85,Text = string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Client )
    self.PlayerSpentAmount[Client] = 0
    
end
    
 end

 function Plugin:SaveAllCredits()
               local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self:SaveCredits(Player:GetClient())
                  end
             end
                     
            local LinkFiley = Shine.LoadJSONFile( URLPath )
            self.LinkFile = LinkFiley

            
                            
                             
                 self:SimpleTimer( 2, function() 
                 Shine.SaveJSONFile( self.CreditData, CreditsPath  )
                 end)
                             
                 self:SimpleTimer( 4, function() 
                 HTTPRequest( self.LinkFile.LinkToUpload, "POST", {data = json.encode(self.CreditData)})
                 end)
                 
                 self:SimpleTimer( 14, function() 
                 self:NotifyCredits( nil, "http://credits.ns2siege.com - credit ranking updated", true)
                 end)        
                 

 end
function Plugin:SetGameState( Gamerules, State, OldState )
       if State == kGameState.Countdown then
      
          
        self.GameStarted = true
        self.Refunded = false
              Shine.ScreenText.End(80)
              Shine.ScreenText.End(81)  
          Shine.ScreenText.End("Credits")    
              self.MarineTotalSpent = 0
              self.AlienTotalSpent = 0
              self.PlayerSpentAmount = {}
              
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self.PlayerSpentAmount[Player:GetClient()] = 0
                  Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.95,Text = string.format( "%s Credits", self:GetPlayerCreditsInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
              
      end        
              
     if State == kGameState.Team1Won or State == kGameState.Team2Won or State == kGameState.Draw then
     
      self.GameStarted = false
      
             self:SimpleTimer(8, function ()
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                    local Data = self:GetCreditData( Player:GetClient() ) //Amount Saved 
                    local creditstosave = self:GetPlayerCreditsInfo(Player:GetClient()) //Amount InGame
                    local earnedamount = 0 
                    if Data then                //Saved - Ingame or Ingame - Saved == Earned?
                     earnedamount = math.max(creditstosave,Data.credits) - math.min(creditstosave,Data.credits)
                    end
                    local addamount = earnedamount  
                    addamount = math.round(addamount, 2)
                    Shine.ScreenText.Add( 80, {X = 0.40, Y = 0.15,Text = "Total Credits Earned:"..addamount, Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                    Shine.ScreenText.Add( 81, {X = 0.40, Y = 0.20,Text = "Total Credits Spent:".. self.PlayerSpentAmount[Player:GetClient()] or 0, Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                  end
             end
      end)
      
        self:SimpleTimer(16, function ()
        self:SaveAllCredits()
        end)
  end
     
end

function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Admin Abuse]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyLerkLift( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Lerk Lift]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyMarine( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[Credits]",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyAlien( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[Credits]", 144, 238, 144, String, Format, ... )
end
function Plugin:NotifyCredits( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Credits]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyCreditsDC( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Double Credits]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyBuy( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[NS2Siege]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end

function Plugin:CreateCommands()

local function Credits(Client, Targets)
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self:NotifyCredits( Client, "%s has a total of %s credits", true, Player:GetName(), self:GetPlayerCreditsInfo(Player:GetClient()))
end
end

local CreditsCommand = self:BindCommand("sh_credits", "credits", Credits, true, false)
CreditsCommand:Help("sh_credits <name>")
CreditsCommand:AddParam{ Type = "clients" }

local function AddCredits(Client, Targets, Number, Display)
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self.CreditUsers[ Player:GetClient() ] = self:GetPlayerCreditsInfo(Player:GetClient()) + Number
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Player:GetClient()) ), Player:GetClient()) 
   if Display == true then
   self:NotifyGeneric( nil, "gave %s credits to %s (who now has a total of %s)", true, Number, Player:GetName(), self:GetPlayerCreditsInfo(Player:GetClient()))
   end
end
end

local AddCreditsCommand = self:BindCommand("sh_addcredits", "addcredits", AddCredits)
AddCreditsCommand:Help("sh_addcredits <player> <number>")
AddCreditsCommand:AddParam{ Type = "clients" }
AddCreditsCommand:AddParam{ Type = "number" }
AddCreditsCommand:AddParam{ Type = "boolean", Optional = true, Default = true }

local function SaveCreditsCmd(Client)
self:SaveAllCredits()
end

local SaveCreditsCommand = self:BindCommand("sh_savecredits", "savecredits", SaveCreditsCmd)
SaveCreditsCommand:Help("sh_savecredits saves all credits online")

local function ToggleAllTalkMic( Client )
        self:ToggleAlltalk(Client)
end

local ToggleAllTalkMicCommand = self:BindCommand( "sh_togglemic", "togglemic", ToggleAllTalkMic )
ToggleAllTalkMicCommand:Help( "toggles clientside microphone to broadcast to only team, or to all server." )


local function Generate( Client )
        local credits = self:GetPlayerCreditsInfo(Client)
        Print("User has %s credits", credits)
        local Player = Client:GetControllingPlayer()
        Player.credits = math.round(credits, 2)
end

local GenerateCommand = self:BindCommand( "sh_generate", "generate", Generate, true )
GenerateCommand:Help( "bleh" )


local function GenerateCredits(Client)
  // self:NotifyGeneric( nil, "Current # of credits is: %s", true, self:GenereateTotalCreditAmount())
   self:GenereateTotalCreditAmount()
end

local GenerateCreditsCommand = self:BindCommand("sh_generatecredits", "generatecredits", GenerateCredits)
GenerateCreditsCommand:Help("sh_generatecredits - gets # of all credits active")

end
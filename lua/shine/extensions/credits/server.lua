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
local BadgeURLPath = "config://shine/BadgesLink.json"
local BadgesPath = "config://shine/UserConfig.json"

Shine.Hook.SetupClassHook( "ScoringMixin", "AddScore", "OnScore", "PassivePost" )
Shine.Hook.SetupClassHook( "NS2Gamerules", "ResetGame", "OnReset", "PassivePost" )
Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyMist", "BecauseFuckSpammingCommanders", "Replace" )



function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
self.GameStarted = false
self.CreditAmount = 0
self.CreditUsers = {}
self.BuyUsersTimer = {}
self.marinecredits = 0
self.aliencredits = 0
self.marinebonus = 0
self.alienbonus = 0

self.UserStartOfRoundCredits = {}
self.MarineTotalSpent = 0
self.AlienTotalSpent = 0
self.Refunded = false

self.PlayerSpentAmount = {}

return true
end

local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end
function Plugin:HasSentry(Player)
    for _, sentry in ipairs(GetEntitiesForTeam("Sentry", 1)) do
        if sentry:GetOwner() == Player and sentry.iscreditstructure == true then return true end
    end
    return false
end

function Plugin:HasExtractor(Player)
    for _, extractor in ipairs(GetEntitiesForTeam("Extractor", 1)) do
        if extractor.ParentId == Player:GetId() and extractor.iscreditstructure == true then return true end
    end
    return false
end


function Plugin:HasHarvester(Player)
    for _, harvester in ipairs(GetEntitiesForTeam("Harvester", 2)) do
        if harvester.ParentId == Player:GetId() then return true end
    end
    return false
end

function Plugin:HasArc(Player)
local arcs = 0
    for _, ARC in ipairs(GetEntitiesForTeam("ARC", 1)) do
        if ARC:GetOwner() == Player and ARC.iscreditstructure == true then arcs = arcs + 1 end
    end
   if arcs >=1 then return true end
    return false
end

function Plugin:HasResPoint(Player)
     for _, respoint in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do 
        if respoint.ParentId == Player:GetId() then return true end
    end
    return false
end

function Plugin:HasThreeHydras(Player)
local hydrascount = 0
local hydras = {}
    for _, hydra in ipairs(GetEntitiesForTeam("Hydra", 2)) do
        if hydra:GetOwner() == Player and hydra.iscreditstructure == true then hydrascount = hydrascount + 1 end
        table.insert(hydras, hydra)
    end
    
    
    if hydrascount ~= 3 then return false end

            if #hydras > 0 then
            local hydra = table.random(hydras)
                DestroyEntity(hydra)
            end
 
    return true
end
function Plugin:HasThreeMacs(Player)
local macs = 0
    for _, mac in ipairs(GetEntitiesForTeam("MAC", 1)) do
        if mac:GetOwner() == Player and mac.iscreditstructure == true then macs = macs + 1 end
    end
    if macs >=3 then return true end
    return false
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
 
function Plugin:LoadBadges()
     local function UsersResponse( Response )
		local UserData = json.decode( Response )
		self.UserData = UserData
		 Shine.SaveJSONFile( self.UserData, BadgesPath  )
		 
		         self:SimpleTimer(4, function ()
        Shared.ConsoleCommand("sh_reloadusers" ) 
        end)
        
      end
       local BadgeFiley = Shine.LoadJSONFile( BadgeURLPath )
        self.BadgeFile = BadgeFiley
        HTTPRequest( self.BadgeFile.LinkToBadges, "GET", UsersResponse)
end

function Plugin:OnScore( Player, Points, Res, WasKill )
if Points ~= nil and Points ~= 0 and Player and GetGamerules():GetGameStarted() then
 local client = Player:GetClient()
 if not client then return end
         
    local addamount = Points/(10/kCreditMultiplier)      
 local controlling = client:GetControllingPlayer()
 
         if Player:GetTeamNumber() == 1 then
         self.marinecredits = self.marinecredits + addamount
        elseif Player:GetTeamNumber() == 2 then
         self.aliencredits = self.aliencredits + addamount
         end
         
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
              self.marinecredits = 0
              self.aliencredits = 0
              self.marinebonus = 0
              self.alienbonus = 0
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

/*
     local function UsersResponse( Response )
		local UserData = json.decode( Response )
		self.UserData = UserData
		 Shine.SaveJSONFile( self.UserData, BadgesPath  )
		 
		         self:SimpleTimer(4, function ()
        Shared.ConsoleCommand("sh_reloadusers" ) 
        end)
        
      end
       local BadgeFiley = Shine.LoadJSONFile( BadgeURLPath )
        self.BadgeFile = BadgeFiley
        HTTPRequest( self.BadgeFile.LinkToBadges, "GET", UsersResponse)
        */
end
/*
        if not Shine.Timer.Exists("SeedTimer") then
        	Shine.Timer.Create( "SeedTimer", 300, -1, function() self:SeedCredits() end )
      end

end
 function Plugin:SeedCredits()
             
if Shine.GetHumanPlayerCount() <= 10 then self:GiveSeedCredits() end
 
 end
 function Plugin:GiveSeedCredits()
 local randomcredits = math.random(1,5)
 self:NotifyCredits( nil, "Playercount is less than or equal to 10. Therefore, as a thank you for seeding the server, here's %s credit(s) to everyone on the server. Thanks!", true, randomcredits)
 
  local Players = Shine.GetAllPlayers()
   for i = 1, #Players do
    local player = Players[ i ]
     if player then
      self.CreditUsers[ player:GetClient() ] = self:GetPlayerCreditsInfo(player:GetClient()) + randomcredits
          if self.GameStarted then
          Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(player:GetClient()) ), player:GetClient()) 
          end
      end
   end
 end
 */
function Plugin:SaveCredits(Client)
       local Data = self:GetCreditData( Client )
       if Data and Data.credits then 
         if not Data.name or Data.name ~= Client:GetControllingPlayer():GetName() then
           Data.name = Client:GetControllingPlayer():GetName()
           end        
       Data.credits = self:GetPlayerCreditsInfo(Client) 
       else 
      self.CreditData.Users[Client:GetUserId() ] = {credits = self:GetPlayerCreditsInfo(Client), name = Client:GetControllingPlayer():GetName() }
       end
     Shine.SaveJSONFile( self.CreditData, CreditsPath  )
end
function Plugin:CalculateEndofRoundCredits()

       self.marinebonus = Clamp(self.marinecredits / GetGamerules():GetTeam(kTeam1Index):GetNumPlayers(), 5*kCreditMultiplier, 100*kCreditMultiplier )
       self.alienbonus = Clamp( self.aliencredits / GetGamerules():GetTeam(kTeam2Index):GetNumPlayers(), 5*kCreditMultiplier, 100*kCreditMultiplier )
       local mtotal = math.round(self.marinebonus, 2)
       local atotal = math.round(self.alienbonus, 2)
       self:NotifyCredits( nil, "Marines: + %s credits", true, mtotal, mtotal2 )
       self:NotifyCredits( nil, "Aliens: + %s credits", true, atotal, atotal2)
       self.marinecredits = self.marinecredits + self.marinebonus
       self.aliencredits = self.aliencredits + self.alienbonus
       
        if kCreditMultiplier == 2 then
        self:NotifyCredits( nil, "Double Credit Weekend is ACTIVE. Credit Gain is set to 2x the normal amount.", true)
        end
end
function Plugin:DistributeEndofRoundCredits()

      local Players = Shine.GetAllPlayers()
  for i = 1, #Players do
      local player = Players[ i ]
      if player then
          if player:GetTeamNumber() == 1 then
             self.CreditUsers[ player:GetClient() ] = self:GetPlayerCreditsInfo(player:GetClient()) + self.marinebonus
             Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(player:GetClient()) ), player:GetClient()) 
          elseif player:GetTeamNumber() == 2 then
             self.CreditUsers[ player:GetClient() ] = self:GetPlayerCreditsInfo(player:GetClient()) + self.alienbonus
             Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(player:GetClient()) ), player:GetClient()) 
        end
        self:SimpleTimer(4, function ()
        self:SaveCredits(player:GetClient())
        end)
      end 
    end
            self:SimpleTimer( 15, function() 
       local LinkFiley = Shine.LoadJSONFile( URLPath )
        self.LinkFile = LinkFiley
            HTTPRequest( self.LinkFile.LinkToUpload, "POST", {data = json.encode(self.CreditData)}, function() 
            self:NotifyCredits( nil, "http://credits.ns2siege.com - credit ranking updated", true)
            end)
            end)
            
            /*
              local Time = Shared.GetTime()
             if not Time > kMaxServerAgeBeforeMapChange then
                        self:SimpleTimer( 25, function() 
                 self:LoadBadges()
            end)
            end
            */
            
          /*  
      self:SimpleTimer( 25, function() 
       local LinkFiley = Shine.LoadJSONFile( URLPath )
        self.LinkFile = LinkFiley
            HTTPRequest( self.LinkFile.LinkToUpload, "POST", {data = json.encode(self.UserData)}, function() 
            self:NotifyCredits( nil, "http://credits.ns2siege.com - badge ranking updated", true)
            end)
            end)
            */


end
function Plugin:ClientDisconnect(Client)
self:SaveCredits(Client)
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

 function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end
 
 /*
  if Client then
  Sabot.SendChatMessage("/help")
   end
   */

/*
self:NotifyCredits( Client, "Hi! Welcome To Siege! Around here, we run a custom Plugin titled Credits. ", true )
self:NotifyCredits( Client, "What Are Credits? Credits are points that allow you to purchase in game items, in return for playing Siege!", true )
self:NotifyCredits( Client, "It's simple, really. 10 in game score = 1 credit. You earn score by killing enemies, building structures, basically playing the game", true )
self:NotifyCredits( Client, "At the end of each round, there's a credit bonus based on how well your team performed.. and sometimes there's double credit weekends.", true )
self:NotifyCredits( Client, "To spend credits, press M and click Cerdits, or bind a key to sh_buy <item> - This message will go away once you start spending! Thanks & Enjoy Siege :D", true )
*/

  if GetGamerules():GetGameStarted() then

  Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.85,Text = string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Client )
    self.PlayerSpentAmount[Client] = 0
    
end
    
 end
function Plugin:SetGameState( Gamerules, State, OldState )
       if State == kGameState.Countdown then
      
          
        self.GameStarted = true
        self.Refunded = false
              Shine.ScreenText.End(80)
              Shine.ScreenText.End(81)  
              Shine.ScreenText.End(82)  
              Shine.ScreenText.End(83)  
              Shine.ScreenText.End(84)  
              Shine.ScreenText.End(85)  
              Shine.ScreenText.End(86)
              Shine.ScreenText.End(87)  
          Shine.ScreenText.End("Credits")    
              self.marinecredits = 0
              self.aliencredits = 0
              self.marinebonus = 0
              self.alienbonus = 0
              self.MarineTotalSpent = 0
              self.AlienTotalSpent = 0
              self.PlayerSpentAmount = {}
              
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self.PlayerSpentAmount[Player:GetClient()] = 0
                  //Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.95,Text = "Loading Credits...",Duration = 1800,R = 255, G = 0, B = 0,Alignment = 0,Size = 3,FadeIn = 0,}, Player )
                  Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.95,Text = string.format( "%s Credits", self:GetPlayerCreditsInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
              
      end        
              
     if State == kGameState.Team1Won or State == kGameState.Team2Won or State == kGameState.Draw then
     
      self.GameStarted = false
          
      self:CalculateEndofRoundCredits()
      
        self:SimpleTimer(2.5, function ()
       self:DistributeEndofRoundCredits()
        end)
       
       self:SimpleTimer(3, function ()
       
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self:SaveCredits(Player:GetClient())
                     if Player:GetTeamNumber() == 1 or Player:GetTeamNumber() == 2 then
                    Shine.ScreenText.Add( 80, {X = 0.40, Y = 0.15,Text = "Total Credits Earned:".. math.round((Player:GetScore() / 10 + ConditionalValue(Player:GetTeamNumber() == 1, self.marinebonus, self.alienbonus)), 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                    Shine.ScreenText.Add( 81, {X = 0.40, Y = 0.20,Text = "Total Credits Spent:".. self.PlayerSpentAmount[Player:GetClient()], Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                     end
                  end
             end
      end)
      self:SimpleTimer(3, function ()    
    //  Shine.ScreenText.Add( 82, {X = 0.40, Y = 0.10,Text = "End of round Stats:",Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    // Shine.ScreenText.Add( 83, {X = 0.40, Y = 0.25,Text = "(Server Wide)Total Credits Earned:".. math.round((self.marinecredits + self.aliencredits), 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 84, {X = 0.40, Y = 0.25,Text = "(Marine)Total Credits Earned:".. math.round(self.marinecredits, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 85, {X = 0.40, Y = 0.30,Text = "(Alien)Total Credits Earned:".. math.round(self.aliencredits, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 86, {X = 0.40, Y = 0.35,Text = "(Marine)Total Credits Spent:".. math.round(self.MarineTotalSpent, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 87, {X = 0.40, Y = 0.40,Text = "(Alien)Total Credits Spent:".. math.round(self.AlienTotalSpent, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
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

function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end

function Plugin:CreateCommands()


local function Buy(Client, String)
local Player = Client:GetControllingPlayer()

local Time = Shared.GetTime()
local NextUse = self.BuyUsersTimer[Client]
if NextUse and NextUse > Time and not Shared.GetCheatsEnabled() then
self:NotifyCredits( Client, "Please wait %s seconds before purchasing %s. Thanks.", true, string.TimeToString( NextUse - Time ), String)
return
end

if not GetGamerules():GetGameStarted() then
self:NotifyCredits( Client, "Buying in pregame is not supported right now. It's a waste of credits unless determined pregame to be free spending later on.", true)
return
end
/*
local gameRules = GetGamerules()
if gameRules:GetGameStarted() and gameRules:GetIsSuddenDeath() then
self:NotifyCredits( Client, "Buying in suddendeath is not supported right now.", true)
return
end
*/
if Player:isa("Commander") or not Player:GetIsAlive() then 
      self:NotifyCredits( Client, "Either you're dead, or a commander... Really no difference between the two.. anyway, no credit spending for you.", true)
return
end

/*
if Player then
 self:NotifyCredits( Client, "Purchases currently disabled. ", true)
 return
end
*/
local CreditCost = 1
local AddTime = 0

if Player:GetTeamNumber() == 1 then 

if String == "CatPack" then
CreditCost = 2
      if self:GetPlayerCreditsInfo(Client) < CreditCost then
      self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
      return
      end
   self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
   //self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   Shine.ScreenText.Add( 52, {X = 0.20, Y = 0.85,Text = "Catpack: %s",Duration = 30,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
   StartSoundEffectAtOrigin(CatPack.kPickupSound, Player:GetOrigin())
   Player:ApplyDurationCatPack(30) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 60
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
   self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
   return
end

if String == "Nano" then
CreditCost = 2
      if self:GetPlayerCreditsInfo(Client) < CreditCost then
      self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
      return
      end
   self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
   //self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   Shine.ScreenText.Add( 53, {X = 0.20, Y = 0.85,Text = "Nano: %s",Duration = 30,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
   Player:ActivateDurationNanoShield(30)
   self.BuyUsersTimer[Client] = Shared.GetTime() + 60
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
   return
end

if String == "AmmoPack" then
      if self:GetPlayerCreditsInfo(Client) < CreditCost then
      self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
      return
      end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveItem(AmmoPack.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 3
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "MedPack" then

if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end

self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
Player:GiveItem(MedPack.kMapName)
   self.BuyUsersTimer[Client] = Shared.GetTime() + 3
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "Scan" then
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
CreateEntity(Scan.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
StartSoundEffectForPlayer(Observatory.kCommanderScanSound, Player)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
      self.BuyUsersTimer[Client] = Shared.GetTime() + 3
      Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "Mac" then
CreditCost = 5

if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
if self:HasThreeMacs(Player) then
self:NotifyCredits(Client, "Three Credit Macs Max. Destroy the others to continue", true)
return
end

/*
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 */
 
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.MAC) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end


self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local mac = CreateEntity(MAC.kMapName, Player:GetOrigin(), Player:GetTeamNumber()) 
mac:SetOwner(Player)
mac:SetIsCreditStructure()
if Player:isa("Exo") then
mac:ProcessFollowAndWeldOrder(Shared.GetTime(), Player, Player:GetOrigin())    
end
Player:GetTeam():RemoveSupplyUsed(kMACSupply)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 5
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "Observatory"  then
CreditCost = 10
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end


if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Observatory) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end


self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local obs = CreateEntity(Observatory.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then
 obs:SetConstructionComplete()
 else
  self:NotifyCredits( Client, "%s placed ON infestation, therefore it is not autobuilt.", true, String)
obs.isGhostStructure = false
end
obs.iscreditstructure = true
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end
/*
if String == "CommandStation" then
CreditCost = 1000
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.CommandStation) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyMarine( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local cc = CreateEntity(CommandStation.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
cc:SetConstructionComplete()
cc.isGhostStructure = false
obs.iscreditstructure = true
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
return
end
*/
if String == "Armory"  then
CreditCost = 12
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 
if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Armory) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end


self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local armory = CreateEntity(Armory.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then
 armory:SetConstructionComplete()
 else
  self:NotifyCredits( Client, "%s placed ON infestation, therefore it is not autobuilt.", true, String)
armory.isGhostStructure = false
end
armory.iscreditstructure = true
Player:GetTeam():RemoveSupplyUsed(kArmorySupply)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 10
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "Sentry"  then
CreditCost = 8
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
if self:HasSentry(Player) then
self:NotifyCredits(Client, "One credit sentry per player at the moment.", true)
return
end
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 
if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Sentry) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end

self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local sentry = CreateEntity(Sentry.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
//sentry:SetConstructionComplete()
sentry.isGhostStructure = false
sentry.iscreditstructure = true
sentry.ignorelimit = true
sentry:SetOwner(Player)
Player:GetTeam():RemoveSupplyUsed(kSentrySupply)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 15
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "PhaseGate" then
CreditCost = 15
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end


if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.PhaseGate) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end


self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local pg = CreateEntity(PhaseGate.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then
  pg:SetConstructionComplete()
 else
  self:NotifyCredits( Client, "%s placed ON infestation, therefore it is not autobuilt.", true, String)
 pg.isGhostStructure = false
end
//pg.isGhostStructure = false
pg.iscreditstructure = true
//pg.channel = 2
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 10
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "InfantryPortal" then
CreditCost = 10
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end


if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.InfantryPortal) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end


self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local ip = CreateEntity(InfantryPortal.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then
  ip:SetConstructionComplete()
 else
  self:NotifyCredits( Client, "%s placed ON infestation, therefore it is not autobuilt.", true, String)
ip.isGhostStructure = false
end
ip.iscreditstructure = true
ip.creditstructre = true
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 10
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "RoboticsFactory" then
CreditCost = 10
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.RoboticsFactory) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
if Client:GetUserId() ~= "25542592" then self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost end
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local robo = CreateEntity(RoboticsFactory.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then
  robo:SetConstructionComplete()
 else
  self:NotifyCredits( Client, "%s placed ON infestation, therefore it is not autobuilt.", true, String)
robo.isGhostStructure = false
end
//robo.isGhostStructure = false
robo.iscreditstructure = true
Player:GetTeam():RemoveSupplyUsed(kRoboticsFactorySupply)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 15
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "ARC" then
CreditCost = 20
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
if self:HasArc(Player) then
self:NotifyCredits(Client, "One credit ARC per player at the moment.", true)
return
end
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.ARC) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end

self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local arc = CreateEntity(ARC.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
arc:GiveOrder(kTechId.ARCDeploy, arc:GetId(), arc:GetOrigin(), nil, false, false)

/*
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then
  arc:SetConstructionComplete()
 else
  self:NotifyCredits( Client, "%s placed ON infestation, therefore it is not autobuilt.", true, String)
arc.isGhostStructure = false
end
*/

arc:SetIsCreditStructure()
arc:SetOwner(Player)
arc.ignorelimit = true
Player:GetTeam():RemoveSupplyUsed(kARCSupply)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 30
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "LowerSupplyLimit" then
CreditCost = 5
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s lowered team supply limit by 10, with %s credits", true, Player:GetName(), CreditCost)
Player:GetTeam():RemoveSupplyUsed(5)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 10
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "Welder" then
CreditCost = 1
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveItem(Welder.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
      self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "Mines" then
CreditCost = 1.5
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveItem(LayMines.kMapName)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 15
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "GrenadeLauncher" then
CreditCost = 3
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveItem(GrenadeLauncher.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "FlameThrower" then
CreditCost = 3
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveItem(Flamethrower.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "FireBullets" then
CreditCost = 2
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player.hasfirebullets = true
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "ShotGun" then
CreditCost = 2
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveItem(Shotgun.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "JetPack" then
CreditCost = 10
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveJetpack()
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "MiniGunClawExo" then

if Player:isa("Exo") then 
self:NotifyCredits( Client, "Cannot buy exo while an exo. Even if you are a single trying to upgrade, it will error out. Though possible to fix. Easier to restrict.", true)
return
end
CreditCost = 30
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveExo(Player:GetOrigin())
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "RailGunClawExo" then

if Player:isa("Exo") then 
self:NotifyCredits( Client, "Cannot buy exo while an exo. Even if you are a single trying to upgrade, it will error out. Though possible to fix. Easier to restrict.", true)
return
end
CreditCost = 30
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveClawRailgunExo(Player:GetOrigin())
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end

if String == "DualMiniGunExo" then
if Player:isa("Exo") then 
self:NotifyCredits( Client, "Cannot buy exo while an exo. Even if you are a single trying to upgrade, it will error out. Though possible to fix. Easier to restrict.", true)
return
end
CreditCost = 45
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveDualExo(Player:GetOrigin())
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end
if String == "DualRailExo" then
if Player:isa("Exo") then 
self:NotifyCredits( Client, "Cannot buy exo while an exo. Even if you are a single trying to upgrade, it will error out. Though possible to fix. Easier to restrict.", true)
return
end
CreditCost = 45
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveDualRailgunExo(Player:GetOrigin())
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end
/*
if String == "TechPoint"  then
    CreditCost = 500
      if self.CreditUsers[ Client ] and self.CreditUsers[ Client ] < CreditCost then
      self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
      return
      end
      if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.CommandStation) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
  self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
  self:NotifyMarine( nil, "%s a purchased a %s for %s credits", true, Player:GetName(), String, CreditCost)
  CreateEntity(TechPoint.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
     Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
  return
end
*/
/*
if String == "ResPoint" then
CreditCost = 100
if self.CreditUsers[ Client ] and self.CreditUsers[ Client ] < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 
 if self:HasResPoint(Player) then
self:NotifyCredits(Client, "One Res Point per player at the moment.", true)
return
end

 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.ResourcePoint) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyMarine( nil, "%s a purchased a %s for %s credits", true, Player:GetName(), String, CreditCost)
local respoint = CreateEntity(ResourcePoint.kPointMapName, Player:GetOrigin(), Player:GetTeamNumber())   
respoint.ParentId = Player:GetId()
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 60
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end
if String == "Extractor" then
CreditCost = 150
if self.CreditUsers[ Client ] and self.CreditUsers[ Client ] < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end

if self:HasExtractor(Player) then
self:NotifyCredits(Client, "One credit Extractor per player at the moment.", true)
return
end

if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Extractor) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end

self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyCredits( nil, "%s a purchased a %s for %s credits", true, Player:GetName(), String, CreditCost)
local extractor = CreateEntity(Extractor.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
extractor.ParentId = Player:GetId()
extractor.iscreditstructure = true
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then
  extractor:SetConstructionComplete()
 else
  self:NotifyCredits( Client, "%s placed ON infestation, therefore it is not autobuilt.", true, String)
extractor.isGhostStructure = false
end
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 60
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end
*/

if String == "Badge" then
CreditCost = 1000
if self.CreditUsers[ Client ] and self.CreditUsers[ Client ] < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end
self:NotifyCredits( Client, "Email kyleabent@gmail.com (Avoca) with a 32x32 image (or ill resize it for you) and your username in the subject field (up to 10 badges)", true)
return
end

if String == "Shrink" then
CreditCost = 5
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end
if Player.modelsize <= .25 then
self:NotifyCredits( Player, "Cannot go below 25%")
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyCredits( Client, "Warning: Your size will reset when you die, and/or when you change class. Such as gestation, or changing from marine to jetpack, or exo to marine, etc.", true)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
Player.modelsize = Player.modelsize - .25 
self:NotifyCredits( Client, "Current size = %s percent", true, math.round(Player.modelsize * 100, 1))
self.BuyUsersTimer[Client] = Shared.GetTime() + 10
//local defaulthealth = LookupTechData(Player:GetTechId(), kTechDataMaxHealth, 1)
//Player:AdjustMaxHealth(defaulthealth * Player.modelsize)
//Player:AdjustMaxArmor(90 * Player.modelsize)
return
end
if String == "Grow" then
CreditCost = 5
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end

/*
if Client then 
self:NotifyCredits( Client, "This heavyily breaks balance and I have no idea how to balance it yet. So until then, growing via credits is disabled.", true)
return
end
*/
if Player:isa("Exo") and Player.modelsize >= 2.5 then
self:NotifyCredits( Player, "Cannot go above 250% as an exo")
return
elseif Player.modelsize >= 3 then 
self:NotifyCredits( Player, "Cannot go above 300%")
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyCredits( Client, "Warning: Your size will reset when you die, and/or when you change class. Such as gestation, or changing from marine to jetpack, or exo to marine, etc.", true)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
if Player:isa("Exo") then
Player.modelsize = Player.modelsize + .25
else
 Player.modelsize = Player.modelsize + .25
end
self:NotifyCredits( Client, "Current size = %s percent", true, math.round(Player.modelsize * 100, 1))
//local defaulthealth = LookupTechData(Player:GetTechId(), kTechDataMaxHealth, 1)
//Player:AdjustMaxHealth(defaulthealth * Player.modelsize)
//Player:AdjustMaxArmor(90 * Player.modelsize)
          
self.BuyUsersTimer[Client] = Shared.GetTime() + 10
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end
if String == "Taunt" then
CreditCost = 5
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end
Player:ToggleTaunt(8)
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end
if String == "GlowPurple" then
CreditCost = 5
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end
if Player:GetIsGlowing() then
self:NotifyCredits( Client, "You're already glowing. Wait until you cease to glow.", true)
 return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyCredits( Client, "Glowing purple for 2 minutes", true)
Shared.ConsoleCommand(string.format("sh_glow %s 1 120", Client:GetUserId())) 
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end
if String == "GlowGreen" then
CreditCost = 5
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end
if Player:GetIsGlowing() then
self:NotifyCredits( Client, "You're already glowing. Wait until you cease to glow.", true)
 return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyCredits( Client, "Glowing green for 2 minutes", true)
Shared.ConsoleCommand(string.format("sh_glow %s 2 120", Client:GetUserId())) 
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
return
end
elseif Player:GetTeamNumber() == 2 then

if String == "LowerSupplyLimit" then
CreditCost = 5
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s lowered team supply limit by 10, with %s credits", true, Player:GetName(), CreditCost)
Player:GetTeam():RemoveSupplyUsed(5)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 10
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "ResPoint" then
CreditCost = 100
if self.CreditUsers[ Client ] and self.CreditUsers[ Client ] < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
  if self:HasResPoint(Player) then
self:NotifyCredits(Client, "One Res Point per player at the moment.", true)
return
end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.ResourcePoint) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyAlien( nil, "%s a purchased a %s for %s credits", true, Player:GetName(), String, CreditCost)
local respoint = CreateEntity(ResourcePoint.kPointMapName, Player:GetOrigin(), Player:GetTeamNumber())  
respoint.ParentId = Player:GetId()
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client)   
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end
/*
if String == "TechPoint"  then
    CreditCost = 500
      if self.CreditUsers[ Client ] and self.CreditUsers[ Client ] < CreditCost then
      self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
      return
      end
      if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Hive) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
  self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
  self:NotifyAlien( nil, "%s a purchased a %s for %s credits", true, Player:GetName(), String, CreditCost)
  CreateEntity(TechPoint.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
     Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
  return
end
*/
if String == "Harvester" then
CreditCost = 150
if self.CreditUsers[ Client ] and self.CreditUsers[ Client ] < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end

if self:HasHarvester(Player) then
self:NotifyCredits(Client, "One credit Harvester per player at the moment.", true)
return
end

 if GetIsAlienInSiege(Player) then
self:NotifyCredits( Client, "Aliens Cannot Build Credit Structures In Siege.", true)
return 
end
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Harvester) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return 
end

self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyCredits( nil, "%s a purchased a %s for %s credits", true, Player:GetName(), String, CreditCost)
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then CreateEntity(Clog.kMapName, Player:GetOrigin(), Player:GetTeamNumber()) end
local harv = CreateEntity(Harvester.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
harv:SetConstructionComplete()
harv:SetIsCreditStructure()
harv.ParentId = Player:GetId()
//harv.isGhostStructure = false
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end
if String == "BadgeA" then
CreditCost = 1000
if self.CreditUsers[ Client ] and self.CreditUsers[ Client ] < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end
self:NotifyCredits( Client, "Bug Avoca for this.", true)
return
end
if String == "NutrientMist" then
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveItem(NutrientMist.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 3
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
     self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Contamination"  then
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( nil, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
 if GetIsAlienInSiege(Player) then
self:NotifyCredits( Client, "Aliens Cannot Build Credit Structures In Siege.", true)
return 
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveItem(Contamination.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 3
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "EnzymeCloud" then
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveItem(EnzymeCloud.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
         self.BuyUsersTimer[Client] = Shared.GetTime() + 3
         Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
         self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Enzyme" then
CreditCost = 2
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
Shine.ScreenText.Add( 53, {X = 0.20, Y = 0.85,Text = "Enzyme: %s",Duration = 30,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
Player:TriggerFireProofEnzyme(30)
self.BuyUsersTimer[Client] = Shared.GetTime() + 60
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Umbra" then
CreditCost = 2
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
Shine.ScreenText.Add( 53, {X = 0.20, Y = 0.85,Text = "Umbra: %s",Duration = 30,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 1,FadeIn = 0,}, Player )
Player:SetHasFireProofUmbra(true, 30)
self.BuyUsersTimer[Client] = Shared.GetTime() + 60
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Ink" then
CreditCost = 2

if Client then 
self:NotifyCredits( Client, "Nope. It's hard to test CragStack and ShadeInk when its combined with Credit Ink", true)
return
end

if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( Client, "purchased %s with %s credit(s). Please wait 30 seocnds before purchasing it again. Thanks.", true, String, CreditCost)
self.BuyUsersTimer[Client] = Shared.GetTime() + 60
Player:GiveItem(ShadeInk.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Hallucination" then
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
Player:GiveItem(HallucinationCloud.kMapName)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
      self.BuyUsersTimer[Client] = Shared.GetTime() + 15
      Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
      self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Drifter" then
CreditCost = 5
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Drifter) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local drifter = Player:GiveItem(Drifter.kMapName)
drifter:SetIsCreditStructure()
Player:GetTeam():RemoveSupplyUsed(kDrifterSupply)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 5
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Shade" then
CreditCost = 10
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
 if GetIsAlienInSiege(Player) then
self:NotifyCredits( Client, "Aliens Cannot Build Credit Structures In Siege.", true)
return 
end
/*
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Shade) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
*/
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then CreateEntity(Clog.kMapName, Player:GetOrigin(), Player:GetTeamNumber())  end
local shade = CreateEntity(Shade.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
shade:SetConstructionComplete()
shade:SetIsCreditStructure()
//shade.isGhostStructure = false
Player:GetTeam():RemoveSupplyUsed(kShadeSupply)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 10
   Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
   self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Crag" then
CreditCost = 10
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
 if GetIsAlienInSiege(Player) then
self:NotifyCredits( Client, "Aliens Cannot Build Credit Structures In Siege.", true)
return 
end
/*
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Crag) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
*/
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then CreateEntity(Clog.kMapName, Player:GetOrigin(), Player:GetTeamNumber())  end
local crag = CreateEntity(Crag.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
crag:SetConstructionComplete()
crag:SetIsCreditStructure()
//crag.isGhostStructure = false
Player:GetTeam():RemoveSupplyUsed(kCragSupply)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 10
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Whip" then
CreditCost = 10
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
 if GetIsAlienInSiege(Player) then
self:NotifyCredits( Client, "Aliens Cannot Build Credit Structures In Siege.", true)
return 
end
/*
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Whip) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
*/
local Time = Shared.GetTime()
local NextUse = self.BuyUsersTimer[Client]
if NextUse and NextUse > Time then
self:NotifyCredits( Client, "Please wait %s seconds before purchasing %s. Thanks.", true, string.TimeToString( NextUse - Time ), String)
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then CreateEntity(Clog.kMapName, Player:GetOrigin(), Player:GetTeamNumber()) end
local whip = CreateEntity(Whip.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
whip:SetIsCreditStructure()
whip:SetConstructionComplete()
//whip.isGhostStructure = false
whip:SetOwner(Player)
Player:GetTeam():RemoveSupplyUsed(kWhipSupply)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 10
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Shift" then
CreditCost = 10
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
 if GetIsAlienInSiege(Player) then
self:NotifyCredits( Client, "Aliens Cannot Build Credit Structures In Siege.", true)
return 
end
/*
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Shift) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
*/
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then CreateEntity(Clog.kMapName, Player:GetOrigin(), Player:GetTeamNumber()) end
local shift = CreateEntity(Shift.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
shift:SetConstructionComplete()
shift:SetIsCreditStructure()
//shift.isGhostStructure = false
Player:GetTeam():RemoveSupplyUsed(kShiftSupply)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 10
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Hydra" then
CreditCost = 1
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
 if GetIsAlienInSiege(Player) then
self:NotifyCredits( Client, "Aliens Cannot Build Credit Structures In Siege.", true)
return 
end
if self:HasThreeHydras(Player) then
self:NotifyCredits(Client, "Three Credit Hydras Detected. Deleting 1 to spawn a new one.", true)
end
/*
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Hydra) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
*/
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local hydra = CreateEntity(Hydra.kMapName, Player:GetOrigin(), Player:GetTeamNumber())    
hydra:SetConstructionComplete()
//hydra.isGhostStructure = false
hydra:SetOwner(Player)
hydra.iscreditstructure = true
hydra.hydraParentId = Client:GetId()
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
self.BuyUsersTimer[Client] = Shared.GetTime() + 5
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Egg" then
CreditCost = 2
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
 if GetIsAlienInSiege(Player) then
self:NotifyCredits( Client, "Aliens Cannot Build Credit Structures In Siege.", true)
return 
end
/*
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Egg) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
*/
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
              if not Player:GetGameEffectMask(kGameEffect.OnInfestation) then
                local clog = CreateEntity(Clog.kMapName, Player:GetOrigin() + Vector(0, .5, -2), Player:GetTeamNumber()) 
                clog:SetInfestationFullyGrown()
                 function clog:GetInfestationRadius()
                 return 2.5
                 end
              end
                CreateEntity(Egg.kMapName, Player:GetOrigin() + Vector(0, .5, 0), Player:GetTeamNumber())
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client)   
self.BuyUsersTimer[Client] = Shared.GetTime() + 5  
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end
/*
if String == "Hive" then
CreditCost = 1000
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Hive) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
local hive = CreateEntity(Hive.kMapName, Player:GetOrigin() + Vector(0, 3, 0), Player:GetTeamNumber())    
hive:SetConstructionComplete()
//hive.isGhostStructure = false
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
return
end
*/
if String == "Gorge" then
CreditCost = 10
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 

                  local newPlayer = Player:Replace(Gorge.kMapName, Player:GetTeamNumber(), nil, nil, extraValues)
                  if newPlayer.lastUpgradeList then
                    newPlayer.upgrade1 = newPlayer.lastUpgradeList[1] or 1
                    newPlayer.upgrade2 = newPlayer.lastUpgradeList[2] or 1
                    newPlayer.upgrade3 = newPlayer.lastUpgradeList[3] or 1
                  end
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Lerk" then
CreditCost = 15
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 

                  local newPlayer = Player:Replace(Lerk.kMapName, Player:GetTeamNumber(), nil, nil, extraValues)
                  if newPlayer.lastUpgradeList then
                    newPlayer.upgrade1 = newPlayer.lastUpgradeList[1] or 1
                    newPlayer.upgrade2 = newPlayer.lastUpgradeList[2] or 1
                    newPlayer.upgrade3 = newPlayer.lastUpgradeList[3] or 1
                    end
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost

return
end

if String == "Fade" then
CreditCost = 25
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 

                  local newPlayer = Player:Replace(Fade.kMapName, Player:GetTeamNumber(), nil, nil, extraValues)
                  if newPlayer.lastUpgradeList then
                    newPlayer.upgrade1 = newPlayer.lastUpgradeList[1] or 1
                    newPlayer.upgrade2 = newPlayer.lastUpgradeList[2] or 1
                    newPlayer.upgrade3 = newPlayer.lastUpgradeList[3] or 1
                    end
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost

return
end

if String == "Onos" then
CreditCost = 30
if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 

                  local newPlayer = Player:Replace(Onos.kMapName, Player:GetTeamNumber(), nil, nil, extraValues)
                  if newPlayer.lastUpgradeList then
                    newPlayer.upgrade1 = newPlayer.lastUpgradeList[1] or 1
                    newPlayer.upgrade2 = newPlayer.lastUpgradeList[2] or 1
                    newPlayer.upgrade3 = newPlayer.lastUpgradeList[3] or 1
                    end
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost

return
end

if String == "Shrink" then
CreditCost = 5
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end
if Player.modelsize <= .75 then
self:NotifyCredits( Player, "Cannot go below 75%")
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyCredits( Client, "Warning: Your size will reset when you die, and/or when you change class. Such as gestation, or changing from marine to jetpack, or exo to marine, etc.", true)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
Player.modelsize = Player.modelsize - .25 
self:NotifyCredits( Client, "Current size = %s percent", true, math.round(Player.modelsize * 100, 1))
self.BuyUsersTimer[Client] = Shared.GetTime() + 10
//local defaulthealth = LookupTechData(Player:GetTechId(), kTechDataMaxHealth, 1)
//local defaultarmor = LookupTechData(Player:GetTechId(), kTechDataMaxArmor, 1)
//Player:AdjustMaxHealth(defaulthealth * Player.modelsize)
//Player:AdjustMaxArmor(defaultarmor * Player.modelsize)
Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
return
end

if String == "Grow" then
CreditCost = 5
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
 
end

/*
if Client then 
self:NotifyCredits( Client, "This heavyily breaks balance and I have no idea how to balance it yet. So until then, growing via credits is disabled.", true)
return
end
*/

if Player:isa("Onos") and Player.modelsize >= 2 then
self:NotifyCredits( Player, "Cannot go above 200% as an onos")
return
elseif Player:isa("Fade") and Player.modelsize >= 2.5 then
self:NotifyCredits( Player, "Cannot go above 250% as an fade")
return
elseif Player:isa("Lerk") and Player.modelsize >= 4 then
self:NotifyCredits( Player, "Cannot go above 400% as an lerk")
return
elseif Player:isa("Gorge") and Player.modelsize >=7 then
self:NotifyCredits( Player, "Cannot go above 700% as an gorge")
return
elseif Player:isa("Skulk") and Player.modelsize >= 10 then
self:NotifyCredits( Player, "Cannot go above 1000% as an skulk")
return
end

self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
self:NotifyCredits( Client, "Warning: Your size will reset when you die, and/or when you change class. Such as gestation, or changing from marine to jetpack, or exo to marine, etc.", true)
Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 

if Player:isa("Onos") then
Player.modelsize = Player.modelsize + .25 
elseif Player:isa("Fade") then
Player.modelsize = Player.modelsize + .50
elseif Player:isa("Lerk") then
Player.modelsize = Player.modelsize + 1
elseif Player:isa("Gorge") then
Player.modelsize = Player.modelsize + 1
elseif Player:isa("Skulk") then
Player.modelsize = Player.modelsize + 1
end

self:NotifyCredits( Client, "Current size = %s percent", true, math.round(Player.modelsize * 100, 1))
//local defaulthealth = LookupTechData(Player:GetTechId(), kTechDataMaxHealth, 1)
//Player:AdjustMaxHealth(defaulthealth * Player.modelsize)
//Player:AdjustMaxArmor(90 * Player.modelsize)
          
self.BuyUsersTimer[Client] = Shared.GetTime() + 10
return
end
          if String == "TaxiDrifter" then 
          
          if self:GetPlayerCreditsInfo(Client) < CreditCost then 
self:NotifyCredits( Client, "%s costs %s credits, you have %s credit(s). Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
return
end
if not Player:GetIsOnGround() then
 self:NotifyCredits( Client, "You must be on the ground to purchase an %s", true, String)
 return
 end
 
if not GetPathingRequirementsMet(Vector( Player:GetOrigin() ),  GetExtents(kTechId.Armory) ) then
self:NotifyCredits( Client, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end

          CreditCost = 10
          self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
          Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
                    local newPlayer = Player:Replace(Gorge.kMapName, Player:GetTeamNumber(), nil, nil, extraValues)
                    newPlayer.upgrade1 = newPlayer.lastUpgradeList[1] or 1
                    newPlayer.upgrade2 = newPlayer.lastUpgradeList[2] or 1
                    newPlayer.upgrade3 = newPlayer.lastUpgradeList[3] or 1
                    
           local drifter = Player:GiveItem(Drifter.kMapName)
           Player:GetTeam():RemoveSupplyUsed(kDrifterSupply)
           drifter.modelsize = 50
           Player.isridingdrifter = true 
           Player.drifterId = drifter:GetId()
           drifter:GiveOrder(kTechId.Move, nil, GetTaxiDrifterCCLocation(self), nil, true, true, giver)
          end //of taxidrifter


end // end of team numbers




if String == "Gravity" and Player:GetTeamNumber() == 2 or Player:GetTeamNumber() == 1 then
CreditCost = 1
if self:GetPlayerCreditsInfo(Client) < CreditCost then
self:NotifyCredits( Client, "%s costs %s credit, you have %s credit. Purchase invalid.", true, String, CreditCost, self:GetPlayerCreditsInfo(Client))
 return
end
if Player:isa("JetpackMarine") then
self:NotifyCredits(Client, "Jetpack low gravity disabled", true)
return
end
self.CreditUsers[ Client ] = self:GetPlayerCreditsInfo(Client) - CreditCost
//self:NotifyCredits( nil, "%s purchased Low Gravity with %s credit(s)", true, Player:GetName(), CreditCost)
self:NotifyCredits( Client, "Low Gravity lasts until death/gestation", true)
   Shine.ScreenText.SetText("Credits", string.format( "%s Credits", self:GetPlayerCreditsInfo(Client) ), Client) 
  //function Player:GetGravityForce(input)
  //return -5
  // end    
  if Player:isa("Exo") then
  Player.gravity = -2
//  elseif Player:isa("JetpackMarine") then
 // Player.gravity = -10
  else 
  Player.gravity = -5
  end
  Shared.ConsoleCommand(string.format("sh_addpool %s", CreditCost)) 
  self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
  if Player:GetTeamNumber() == 2 then
  self.AlienTotalSpent = self.AlienTotalSpent + CreditCost
  else
  self.MarineTotalSpent = self.MarineTotalSpent + CreditCost
  end
return
end

self:NotifyCredits( Client, "Invalid Purchase Request of %s.", true, String)
end

local BuyCommand = self:BindCommand("sh_buy", "buy", Buy, true)
BuyCommand:Help("sh_buy <item name>")
BuyCommand:AddParam{ Type = "string" }

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
end
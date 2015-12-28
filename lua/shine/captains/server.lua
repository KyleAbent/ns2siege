local Shine = Shine
local Plugin = Plugin



Plugin.Version = "1.0"


function Plugin:Initialise()
self.Enabled = true
self:CreateCommands()

self.AlienCaptain = {}
self.MarineCaptain = {}

self.AlienCaptainPicked = false
self.MarineCaptainPicked = false

self.MarinesTurn = false
self.AliensTurn = false

self.PickedByCaptainToJoinMarines = {}
self.PickedByCaptainToJoinAliens = {}

self.CaptainsModeActive = false

self.VotesTorwardsCaptains = 0
self.VotedToCaptain = {}

self.NewlyConnectedPlayerAfterRoundStart = {}

return true
end

 function Plugin:ClientConfirmConnect(Client)
 if GetGamerules():GetGameStarted() and self.CaptainsModeActive == true then 
 self.NewlyConnectedPlayerAfterRoundStart[Client] = true
  end
end
function Plugin:NotifyMarine( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[Marine Captain]",  40, 248, 255, String, Format, ... )
end
function Plugin:NotifyAlien( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 250, 235, 215,  "[Alien Captain]", 144, 238, 144, String, Format, ... )
end
function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Captains]",  255, 0, 0, String, Format, ... )
end
function Plugin:JoinTeam( Gamerules, Player, NewTeam, Force, ShineForce ) 
  //  if self.GameStarted then return end
	if not self.CaptainsModeActive == true then return end
	if not Player then return end
	if ShineForce then return end

    if self.NewlyConnectedPlayerAfterRoundStart[Player:GetClient()] == true then return end
    if NewTeam == 1 and self.MarineCaptain[Player:GetClient()] == true or self.PickedByCaptainToJoinMarines[Player:GetClient()] == true then return end
    if NewTeam == 2 and self.AlienCaptain[Player:GetClient()] == true or self.PickedByCaptainToJoinAliens[Player:GetClient()] == true then return end
    
	local Message = GetGamerules():GetGameStarted()  and not self.AlienCaptain[Player:GetClient()] and not self.MarineCaptain[Player:GetClient()] and "Team Captains mode enabled. Captain picks players and players stay on picked team. No joining or leaving otherwise." or
	"Silly Team Captain trying to switch teams..."
	if Shine:CanNotify( Player  ) then
		Shine:NotifyColour( Player, 255, 160, 0, Message )
	end

	return false  
 
end
function Plugin:CreateCommands()

local function Pick(Client, Targets)
if #Targets > 1 then return end
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
   if not self.AlienCaptain[Client] and not self.MarineCaptain[Client] then 
   Shine:NotifyError( Client, "You are not a team captain", true )
   return 
   end
        if self.AlienCaptain[Client] and self.AliensTurn == true then
               if self.PickedByCaptainToJoinMarines[Player:GetClient()] == true or self.MarineCaptain[Player:GetClient()] == true then
               self:NotifyAlien( nil, "%s: Tried to steal a player from the other side (%s) Shame!", true, Client:GetControllingPlayer():GetName(), Player:GetName() )
               return
               end
        self:NotifyAlien( nil, "%s: Picked %s", true, Client:GetControllingPlayer():GetName(), Player:GetName() )
        self.PickedByCaptainToJoinAliens[Player:GetClient()] = true 
        GetGamerules():JoinTeam( Player, 2, nil, true, true )
        self.AliensTurn = false
        self.MarinesTurn = true
        elseif self.AlienCaptain[Client] and self.AliensTurn == false then
        self:NotifyAlien( Client, "Wait your turn! it's the Marine's Captain turn to choose a player, then yours!", true )
        elseif self.MarineCaptain[Client] and self.MarinesTurn == true then
               if self.PickedByCaptainToJoinAliens[Player:GetClient()] == true or self.AlienCaptain[Player:GetClient()] == true then
               self:NotifyMarine( nil, "%s: Tried to steal a player from the other side (%s) Shame!", true, Client:GetControllingPlayer():GetName(), Player:GetName() )
               return
               end
        self:NotifyMarine( nil, "%s: Picked %s", true, Client:GetControllingPlayer():GetName(), Player:GetName() )
        self.PickedByCaptainToJoinMarines[Player:GetClient()] = true
        GetGamerules():JoinTeam( Player, 1, nil, true, true )
        self.MarinesTurn = false
        self.AliensTurn = true
        elseif self.MarineCaptain[Client] and self.MarinesTurn == false then
        self:NotifyMarine( Client, "Wait your turn! it's the Alien's Captain turn to choose a player, then yours!", true )
        end
  end
end 
local PickCommand = self:BindCommand("sh_pick", "pick", Pick, true)
PickCommand:Help("sh_pick <name> - When its this teams captain to pick, type the name and it will choose this player.")
PickCommand:AddParam{ Type = "clients", NotSelf = true, IgnoreCanTarget = true }


local function SetCaptain(Client, Targets, String)
if GetGamerules():GetGameStarted() then 
   Shine:NotifyError( Client, "Game has already started. Picking a captain would be pointless.", true )
end
if #Targets > 1 then return end
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
      if String == "Marine" or String == "Marines" or String == "marine" or String == "marines" then
      self.MarineCaptainPicked = true
      self.MarineCaptain = {}
      self.MarineCaptain[Player:GetClient()] = true
      GetGamerules():JoinTeam( Player, 1, nil, true )
        self:NotifyMarine( nil, "%s Picked %s to be the Marine Captain", true, Client:GetControllingPlayer():GetName(), Player:GetName() )
        self:NotifyMarine( Player, "You have been picked as Marine Captain! now type /pick <name> to choose a player, but wait for your turn to do so.", true, Client:GetControllingPlayer():GetName(), Player:GetName() )
        self.MarinesTurn = true
      elseif String == "Alien" or String == "Aliens" or String == "alien" or String == "aliens" then
      self.AlienCaptainPicked = true
      self.AlienCaptain = {}
      self.AlienCaptain[Player:GetClient()] = true
      GetGamerules():JoinTeam( Player, 2, nil, true )
        self:NotifyAlien( nil, "%s Picked %s to be the Alien Captain", true, Client:GetControllingPlayer():GetName(), Player:GetName() )
        self:NotifyAlien( Player, "You have been picked as Alien Captain! now type /pick <name> to choose a player, but wait for your turn to do so.", true, Client:GetControllingPlayer():GetName(), Player:GetName() )

      end        
    if self.AlienCaptainPicked == true and self.MarineCaptainPicked == true then 
     self:NotifyGeneric( nil, "Both captains decided. Flipping coin to determine which side chooses first.", true )
     self.CaptainsModeActive = true
     self:ForcePlayersIntoReadyRoom()
      local random = math.random(1,2)
         if random == 1 then
         self:NotifyMarine( nil, "Coin Flipped. Marine's Captain chooses first.", true)
        self.MarinesTurn = true
         self.AliensTurn = false
         elseif random == 2 then
           self:NotifyAlien( nil, "Coin Flipped, Alien's Captain Chooses First.", true)
           self.AliensTurn = true
           self.MarinesTurn = false
         end
    end
  end  
end 
local SetCaptainCommand = self:BindCommand("sh_setcaptain", "setcaptain", SetCaptain, true, false)
SetCaptainCommand:Help("sh_setcaptain <name> (<marines> or <aliens>) - Sets the teams captain.")
SetCaptainCommand:AddParam{ Type = "clients", IgnoreCanTarget = true }
SetCaptainCommand:AddParam{ Type = "string"}


local function VoteCaptains( Client )
local Player = Client:GetControllingPlayer()
      if GetGamerules():GetGameStarted() then 
       self:NotifyGeneric( Client, "Game already started. Vote before then.", true ) 
       return 
      end 
            if self.CaptainsModeActive == true  then 
       self:NotifyGeneric( Client, "Captains already active !", true ) 
       return 
      end 
      if self.VotedToCaptain[Player:GetClient()] then 
       self:NotifyGeneric( Client, "You already voted !", true ) 
       return 
      end 
self.VotedToCaptain[Player:GetClient()] = true
self.VotesTorwardsCaptains = self.VotesTorwardsCaptains + 1
  local playercount = Shine.GetHumanPlayerCount()
  local goal = playercount * (playercount/2) / playercount
  
      if self.VotesTorwardsCaptains >= math.round(goal) then 
      self:NotifyGeneric( nil, "Voting to enforce captains has passed! (Nothing here yet. Just testing votes)", true )
     // self:PickRandomCaptains()
      else
        self:NotifyGeneric( nil, "%s Voted to enforce Captains. %s more votes required", true, Player:GetName(), math.round(goal) - self.VotesTorwardsCaptains )
      end

end

local VoteCaptainsCommand = self:BindCommand( "sh_votecaptains", "votecaptains", VoteCaptains, true)
VoteCaptainsCommand:Help( "Vote to enforce captains" )

end
function Plugin:ForcePlayersIntoReadyRoom()
	local Gamerules = GetGamerules()
	local Players = Shine.GetAllPlayers()

	for i = 1, #Players do
		local Ply = Players[ i ]

		if Ply and not self.AlienCaptain[Ply:GetClient()] == true and not self.MarineCaptain[Ply:GetClient()] == true then
			Gamerules:JoinTeam( Ply, 0, nil, true )
		end
	end
end
function Plugin:SetGameState( Gamerules, State, OldState )
     
     if State == kGameState.Started and self.CaptainsModeActive == true then
     self.MarineCaptain = {}
     self.AlienCaptain = {}
     self.AlienCaptainPicked = false
     self.VotedToCaptain = {}
     self.VotesTorwardsCaptains = 0
     self:NotifyGeneric( nil, "Game Started. Removing Captains and allowing NEW players to join any team. While restricting picked players to picked teams", true )
     elseif State == kGameState.Team1Won or State == kGameState.Team2Won or State == kGameState.Draw and self.CaptainsModeActive == true then
    self:NotifyGeneric( nil, "Captains mode disabled", true )
    self.MarineCaptain = {}
    self.AlienCaptain = {}
    self.NewlyConnectedPlayerAfterRoundStart = {}
   self.CaptainsModeActive = false
   self.PickedByCaptainToJoinMarines = {}
   self.PickedByCaptainToJoinAliens = {}
   self.VotedToCaptain = {}
   self.VotesTorwardsCaptains = 0
     end
end
function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end
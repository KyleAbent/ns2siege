local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end

Shine.VoteMenu:EditPage( "Main", function( self ) 
if not self.GameStarted then self:AddSideButton( "Vote Captains", function() Shared.ConsoleCommand ("sh_votecaptains")end) end
end)



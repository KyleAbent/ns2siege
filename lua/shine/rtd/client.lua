local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end


Shine.VoteMenu:EditPage( "Main", function( self ) 
self:AddSideButton( "RollTheDice", function() Shared.ConsoleCommand ("sh_rtd")end) 
end)




local Shine = Shine

local Plugin = {}

function Plugin:Initialise()
self.Enabled = true
return true
end



Shine:RegisterExtension( "zedtime", Plugin )
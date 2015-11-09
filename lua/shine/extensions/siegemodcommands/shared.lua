local Shine = Shine

local Plugin = {}

function Plugin:Initialise()
self:SetupAdminMenuCommands()
self.Enabled = true
return true
end

function Plugin:SetupAdminMenuCommands() // might not work
local Category = "Siege Commands"
self:AddAdminMenuCommand( Category, "Random RR", "sh_randomrr", false, nil, "randomize's the ready room" )
self:AddAdminMenuCommand( Category, "Give",    "sh_give",    true, {
"JP", "jetpack",
"GL", "grenadelauncher",
"FL", "flamethrower",
"Armory", "armory",
"Whip", "whip",
"Clog", "clog",
"Crag", "crag"
}, "Give selected entity to player(s)." )
self:AddAdminMenuCommand( Category, "PlayerGravity",    "sh_playergravity",    true, {
"Zero", "1",
"Super Low", "-1",
"Low", "-5",
"High Jump", "-8",
"Slighter Jump", "-12",
"Still Air", "-16"
}, "works differently than ns1. kinda glitchy. respawn to reset." )
self:AddAdminMenuCommand( Category, "Pres",    "sh_pres",    true, {
"0", "0",
"25", "25",
"50", "50",
"75", "75",
"100", "100"
}, "Sets player res to desired amount." )
self:AddAdminMenuCommand( Category, "Destroy", "sh_destroy", false, nil, "Destroy structure in small, close eye radius." )
self:AddAdminMenuCommand( Category, "Construct", "sh_construct", false, nil, "Construct's any structure within small & close eye sight radius." )
self:AddAdminMenuCommand( Category, "DeConstruct", "sh_deconstruct", false, nil, "DeConstruct's any structure within small & close eye sight radius." )
self:AddAdminMenuCommand( Category, "Respawn", "sh_respawn", true, nil, "Respawn's selected player(s)" )
self:AddAdminMenuCommand( Category, "Stalemate", "sh_stalemate", false, nil, "Declares the round a draw." )
//" 
end

//Shine.VoteMenu:EditPage( "Main", function( self )
    //self:AddSideButton( "Change Camera", ChangeCamera)
    //end _
  //  self:AddSideButton( "3rdperson", function(ThirdPerson)
   // end)
   // self:AddSideButton( "1stperson", function(FirstPerson)
   // end) 
//end) 


Shine:RegisterExtension( "siegemodcommands", Plugin )
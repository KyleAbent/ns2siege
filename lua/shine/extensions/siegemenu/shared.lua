
--[[
	Siege menu shared.
]]
local Plugin = {}
local Shine = Shine

Shared.RegisterNetworkMessage( "Shine_SiegeMenu_Open", {} )

if Client then return end

Shine:RegisterCommand( "sh_siegemenu", "help", function( Client ) Shine.SendNetworkMessage( Client, "Shine_SiegeMenu_Open", {}, true ) end, true)
/*
 function Plugin:ClientConfirmConnect(Client)
 Shine.SendNetworkMessage( Client, "Shine_SiegeMenu_Open", {}, true )
 end
 */
Shine:RegisterExtension( "siegemenu", Plugin )
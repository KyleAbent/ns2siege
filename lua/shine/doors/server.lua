/*Kyle Abent Doors 
KyleAbent@gmail.com / 12XNLDBRNAXfBCqwaBfwcBn43W3PkKUkUb - LOL
*/
local Shine = Shine
local Plugin = Plugin


Plugin.Version = "1.0"

function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true

return true
end

function Plugin:AdjustTimer(Number)
local newtimer = 0
local calculation = kSiegeDoorTimey + (Number)
kSiegeDoorTimey = Clamp(calculation, 0, 1500)
self:UpdateGameInfo(kSiegeDoorTimey)                     
end
function Plugin:UpdateGameInfo(time)

    local entityList = Shared.GetEntitiesWithClassname("GameInfo")
    if entityList:GetSize() > 0 then
    
        local gameInfo = entityList:GetEntityAtIndex(0)
           gameInfo:SetSiegeTime(time)
   end
   
end    
function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end

function Plugin:CreateCommands()

local function AddSiegeTime( Client, Number, Boolean )

 self:AdjustTimer(Number)
end

local AddSiegeTimeCommand = self:BindCommand( "sh_addsiegetime", "addsiegetime", AddSiegeTime )
AddSiegeTimeCommand:AddParam{ Type = "number" }
AddSiegeTimeCommand:AddParam{ Type = "boolean", Optional = true, Default = false }
AddSiegeTimeCommand:Help( "adds timer to siegedoor and updates timer/countdown" )

end
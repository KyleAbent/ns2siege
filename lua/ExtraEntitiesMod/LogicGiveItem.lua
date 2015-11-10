//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// LogicGiveItem.lua
// Base entity for LogicGiveItem things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'LogicGiveItem' (Entity)

LogicGiveItem.kMapName = "logic_give_item"
    local activatedsound = PrecacheAsset("sound/siegeroom.fev/webactivate/activated")
local networkVars = 
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicGiveItem:OnCreate()
end

function LogicGiveItem:OnInitialized()    
    if Server then
        InitMixin(self, LogicMixin)
    end
end

function LogicGiveItem:OnLogicTrigger(player)    

    if player then
            if not player:isa("Marine") then
            return 
            end
            player.hasjumppack = true
            StartSoundEffectForPlayer(activatedsound, player)
    end
    
end


Shared.LinkClassToMap("LogicGiveItem", LogicGiveItem.kMapName, networkVars)
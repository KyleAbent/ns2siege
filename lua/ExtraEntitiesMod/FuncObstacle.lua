//________________________________
//
//   	NS2 SiegeMod  
//	    Made by RinesRool 2014
//
//________________________________

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/ObstacleMixin.lua")

class 'FuncObstacle' (ScriptActor)

FuncObstacle.kMapName = "func_obstacle"

local networkVars =
{
    scale = "vector",
}

AddMixinNetworkVars(LogicMixin, networkVars)

function FuncObstacle:OnCreate()
    ScriptActor.OnCreate(self)
    InitMixin(self, ObstacleMixin)
end

Shared.LinkClassToMap("FuncObstacle", FuncObstacle.kMapName, networkVars)
// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ReadyRoomPlayer.lua
//
//    Created by:   Brian Cronin (brainc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Player.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/Mixins/LadderMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/ScoringMixin.lua")
Script.Load("lua/Marine.lua")
//Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")

/**
 * ReadyRoomPlayer is a simple Player class that adds the required Move type mixin
 * to Player. Player should not be instantiated directly.
 */
class 'ReadyRoomPlayer' (Player)

ReadyRoomPlayer.kModelName = PrecacheAsset("models/props/biodome/biodome_flower_02_high.model")
ReadyRoomPlayer.kMapName = "ready_room_player"

local networkVars = 
{ 

   // scale = "vector",
}

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(LadderMoveMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(ScoringMixin, networkVars)

function ReadyRoomPlayer:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = -5})
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, LadderMoveMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    
    Player.OnCreate(self)
    
end
local function InitModel(self)

    self.model = ReadyRoomPlayer.kModelName
       
end
function ReadyRoomPlayer:OnInitialized()

    Player.OnInitialized(self)
    InitModel(self)    
   // InitMixin(self, ScaledModelMixin)
   // self.scale = Vector(0.5,0.5,0.5)
	self:SetModel(ReadyRoomPlayer.kModelName)
    
    
end
function ReadyRoomPlayer:OnAdjustModelCoords(modelCoords)

    local coords = modelCoords
    coords.xAxis = coords.xAxis * 1
    coords.yAxis = coords.yAxis * 1
    coords.zAxis = coords.zAxis * 1
    
    modelCoords.origin = modelCoords.origin + modelCoords.yAxis * .30
      
    return coords
    
end
function ReadyRoomPlayer:GetExtentsOverride()
    return Vector(Player.kXZExtents * .10, Player.kYExtents * .10, Player.kXZExtents * .10)
end
function ReadyRoomPlayer:GetPlayerStatusDesc()
    return kPlayerStatus.Void
end

if Client then

    function ReadyRoomPlayer:OnCountDown()
    end
    
    function ReadyRoomPlayer:OnCountDownEnd()
    end
    
end

function ReadyRoomPlayer:GetHealthbarOffset()
    return 0.85
end

Shared.LinkClassToMap("ReadyRoomPlayer", ReadyRoomPlayer.kMapName, networkVars)

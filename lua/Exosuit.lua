// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Exosuit.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com.at)
//
//    Pickupable entity.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PickupableMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ExoVariantMixin.lua")

class 'Exosuit' (ScriptActor)

Exosuit.kMapName = "exosuit"

Exosuit.kModelName = PrecacheAsset("models/marine/exosuit/exosuit_cm.model")
local kAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_spawn_only.animation_graph")
local kAnimationGraphEject = PrecacheAsset("models/marine/exosuit/exosuit_spawn_animated.animation_graph")

local kAnimationGraphSpawnOnly = PrecacheAsset("models/marine/exosuit/exosuit_spawn_only.animation_graph")
local kAnimationGraphEject = PrecacheAsset("models/marine/exosuit/exosuit_spawn_animated.animation_graph")

local kLayoutModels =
{
    ["MinigunMinigun"] = PrecacheAsset("models/marine/exosuit/exosuit_mm.model"),
    ["ClawRailgun"] = PrecacheAsset("models/marine/exosuit/exosuit_cr.model"),
    ["RailgunRailgun"] = PrecacheAsset("models/marine/exosuit/exosuit_rr.model"),
}

local networkVars =
{
    powerModuleType    = "enum kExoModuleTypes",
	rightArmModuleType = "enum kExoModuleTypes",
	leftArmModuleType  = "enum kExoModuleTypes",
    utilityModuleType  = "enum kExoModuleTypes",
    ownerId = "entityid",

}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(ExoVariantMixin, networkVars)

function Exosuit:OnCreate ()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ExoVariantMixin)
    
    InitMixin(self, PickupableMixin, { kRecipientType = "Marine" })

    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
    if Client then
        InitMixin(self, UnitStatusMixin)
    end

    
    self.leftArmModuleType  = kExoModuleTypes.Welder
    self.rightArmModuleType = kExoModuleTypes.Welder
    self.utilityModuleType = kExoModuleTypes.Nano
    self.powerModuleType = kExoModuleTypes.None
    
            
end
/*
function Exosuit:GetCheckForRecipient()
    return false
end
*/

function Exosuit:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    if Server then
        
        self:SetModel(Exosuit.kModelName, kAnimationGraph)
        
        self:SetIgnoreHealth(true)
        self:SetMaxArmor(kExosuitArmor)
        self:SetArmor(kExosuitArmor)
     //   Exo.InitExoModel(self, kAnimationGraphEject)
    end
    
    InitMixin(self, HiveVisionMixin)
    InitMixin(self, WeldableMixin)
    
end
function Exosuit:OnWeldOverride(doer, elapsedTime)

    // macs weld marines by only 50% of the rate
    local macMod = (HasMixin(self, "Combat") and self:GetIsInCombat()) and 0.1 or 0.5    
    local weldMod = ( doer ~= nil and doer:isa("MAC") ) and macMod or 1

    if self:GetArmor() < self:GetMaxArmor() then
    
        local addArmor = kPlayerArmorWeldRate * elapsedTime * weldMod
        self:SetArmor(self:GetArmor() + addArmor)
        
    end
    
end

if Server then
    
    function Exosuit:OnKill()
    
        self:TriggerEffects("death")
        DestroyEntity(self)
        
    end
    
end

function Exosuit:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = self:GetIsValidRecipient(player)
end

function Exosuit:_GetNearbyRecipient()
end

function Exosuit:SetLayout(layout)

    local model = kLayoutModels[layout] or Exosuit.kModelName
    self:SetModel(model, kAnimationGraphEject)
    self.layout = layout
    
end
function GetExoLimit(techId, origin, normal, commander)
    local exos = 0
        for index, Exosuit in ientitylist(Shared.GetEntitiesWithClassname("ExoSuit")) do
                exos = exos + 1 
         end
    return  exos <= 3
    
end
function Exosuit:OnOwnerChanged(prevOwner, newOwner)

    if not newOwner or not (newOwner:isa("Marine") or newOwner:isa("JetpackMarine")) then
        self.resetOwnerTime = Shared.GetTime() + 0.1
    else
        self.resetOwnerTime = Shared.GetTime() + kItemStayTime
    end
    
end

function Exosuit:OnTouch(recipient)    
end

function Exosuit:GetArmorUseFractionOverride()
    return 1.0
end
function Exosuit:GetLeftArmModuleType()
return self.leftArmModuleType
end
function Exosuit:GetRightArmModuleType()
return self.rightArmModuleType
end
function Exosuit:GetExoUtilityModuleType()
return self.utilityModuleType
end
function Exosuit:GetPowerModuleType()
return self.powerModuleType
end
if Server then

    function Exosuit:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
        
        if self.resetOwnerTime and self.resetOwnerTime < Shared.GetTime() then
            self:SetOwner(nil)
            self.resetOwnerTime = nil
        end
        
    end
    
    function Exosuit:OnUseDeferred()
        
        local player = self.useRecipient 
        self.useRecipient = nil
        
        if player and not player:GetIsDestroyed() and self:GetIsValidRecipient(player) then
        
            local weapons = player:GetWeapons()
            for i = 1, #weapons do            
                weapons[i]:SetParent(nil)            
            end

            local exoPlayer = nil
             local extraValues = {
            leftArmModuleType  = self:GetLeftArmModuleType(),
            rightArmModuleType = self:GetRightArmModuleType(),
            utilityModuleType = self:GetExoUtilityModuleType(),
            powerModuleType = self:GetPowerModuleType(),
                 }
            exoPlayer = player:Replace("exo", player:GetTeamNumber(), false, nil, extraValues)
            exoPlayer.inventoryWeight = exoPlayer:CalculateWeight()
       /*
            if self.layout == "MinigunMinigun" then
                exoPlayer = player:GiveDualExo()            
            elseif self.layout == "RailgunRailgun" then
                exoPlayer = player:GiveDualRailgunExo()
            elseif self.layout == "ClawRailgun" then
                exoPlayer = player:GiveClawRailgunExo()
            else
                exoPlayer = player:GiveExo()
            end  
        */
        
            if exoPlayer then
                           
                for i = 1, #weapons do
                    exoPlayer:StoreWeapon(weapons[i])
                end 

                exoPlayer:SetMaxArmor(self:GetMaxArmor())  
                exoPlayer:SetArmor(self:GetArmor())
                
                local newAngles = player:GetViewAngles()
                newAngles.pitch = 0
                newAngles.roll = 0
                newAngles.yaw = GetYawFromVector(self:GetCoords().zAxis)
                exoPlayer:SetOffsetAngles(newAngles)
                // the coords of this entity are the same as the players coords when he left the exo, so reuse these coords to prevent getting stuck
                exoPlayer:SetCoords(self:GetCoords())
                
                self:TriggerEffects("pickup")
                DestroyEntity(self)
                
            end
            
        end
    
    end

    function Exosuit:OnUse(player, elapsedTime, useSuccessTable)
    
        if self:GetIsValidRecipient( player ) and ( not self.useRecipient or self.useRecipient:GetIsDestroyed() ) then
            
            self.useRecipient = player
            self:AddTimedCallback( self.OnUseDeferred, 0 )
            
        end
        
    end
    
end

/* // only give Exosuits to standard marines
function Exosuit:GetIsValidRecipient(recipient)
    return not recipient:isa("Exo") and not recipient:isa("JetpackMarine") and (self.ownerId == Entity.invalidId or self.ownerId == recipient:GetId())
end */

function Exosuit:GetIsValidRecipient(recipient)
    return not recipient:isa("Exo") and (self.ownerId == Entity.invalidId or self.ownerId == recipient:GetId())
end

function Exosuit:GetIsPermanent()
    return true
end

Shared.LinkClassToMap("Exosuit", Exosuit.kMapName, networkVars)
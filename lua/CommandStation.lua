// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CommandStation.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/Marine/NanoShield.lua")

Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/RecycleMixin.lua")

Script.Load("lua/CommandStructure.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/IdleMixin.lua")

class 'CommandStation' (CommandStructure)

CommandStation.kMapName = "commandstation"

CommandStation.kModelName = PrecacheAsset("models/marine/command_station/command_station.model")
local kAnimationGraph = PrecacheAsset("models/marine/command_station/command_station.animation_graph")

CommandStation.kUnderAttackSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/command_station_under_attack")

PrecacheAsset("models/marine/command_station/command_station_display.surface_shader")

local kLoginAttachPoint = "login"
CommandStation.kCommandStationKillConstant = 1.05


if Server then
    Script.Load("lua/CommandStation_Server.lua")
end

local networkVars = 
{
}

AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)

function CommandStation:OnCreate()

    CommandStructure.OnCreate(self)
    
    InitMixin(self, CorrodeMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, ParasiteMixin)


end

function CommandStation:OnInitialized()

    CommandStructure.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, HiveVisionMixin)
    
    self:SetModel(CommandStation.kModelName, kAnimationGraph)
    
    if Server then
    
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        
    end
    
    InitMixin(self, IdleMixin)
end

function CommandStation:GetIsWallWalkingAllowed()
    return false
end
/*
function CommandStation:GetCanBeWeldedOverride()
return not self:GetIsSuddenDeath()
end

function CommandStation:GetAddConstructHealth()

return not self:GetIsSuddenDeath()
end
*/
function CommandStation:GetCanBeNanoShieldedOverride()
return not self:GetIsVortexed()
end
function CommandStation:GetIsSuddenDeath()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetIsSuddenDeath() then 
                   return true
               end
            end
        end
            return false
end
local kHelpArrowsCinematicName = PrecacheAsset("cinematics/marine/commander_arrow.cinematic")
PrecacheAsset("models/misc/commander_arrow.model")
          
if Client then

    function CommandStation:GetHelpArrowsCinematicName()
        return kHelpArrowsCinematicName
    end
    
end
if Server then

   function CommandStation:GetCanBeUsedConstructed(byPlayer)
   return not self:GetIsSiege() and not byPlayer:GetHasLayStructure() and byPlayer:GetHasWelderPrimary()
   end
   
   function CommandStation:GetIsSiege()
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   return true
               end
            end
            return false
      end
      
function CommandStation:OnUse(player, elapsedTime, useSuccessTable)
     if self:GetIsBuilt() and self:GetCanBeUsedConstructed(player) then
           local laystructure = player:GiveItem(LayStructures.kMapName)
           laystructure:SetTechId(kTechId.CommandStation)
           laystructure:SetMapName(CommandStation.kMapName)
           laystructure.originalposition = self:GetOrigin()
           DestroyEntity(self)
    end
end

end
function CommandStation:GetRequiresPower()
    return false
end

function CommandStation:GetNanoShieldOffset()
    return Vector(0, -0.3, 0)
end

function CommandStation:GetUsablePoints()

    local loginPoint = self:GetAttachPointOrigin(kLoginAttachPoint)
    return { loginPoint }
    
end

function CommandStation:GetTechButtons()
    return { kTechId.None, kTechId.Recycle } //kTechId.BluePrintTech }
end
function CommandStation:GetIsSiege()
        if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   return true
               end
            end
        end
            return false
end
function CommandStation:ModifyDamageTaken(damageTable, attacker, doer, damageType)

      if self:GetIsSiege() then 
      damageTable.damage = damageTable.damage * .7
      end
 
    
end
function CommandStation:GetCCAmount()
local amount = 0
        for index, CC in ientitylist(Shared.GetEntitiesWithClassname("CommandStation")) do
        
               amount  = amount + 1
            
        end
        
    
    return amount
    
end
if Server then
function GetCCQualifications(techId, origin, normal, commander)
 if CommandStation:GetCCAmount() >= 3 then return false end
          /*
             local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetIsSuddenDeath() then 
                   return false
               end
            end
          */
            return true
end
end
function CommandStation:GetCanBeUsed(player, useSuccessTable)

    // Cannot be used if the team already has a Commander (but can still be used to build).
    if player:isa("Exo") or (self:GetIsBuilt() and GetTeamHasCommander(self:GetTeamNumber())) then
        useSuccessTable.useSuccess = false
    end
    
end

function CommandStation:GetCanRecycleOverride()
    return not self:GetIsOccupied() and self:GetCanBeWeldedOverride()
end

function CommandStation:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = CommandStructure.GetTechAllowed(self, techId, techNode, player)

    if techId == kTechId.Recycle then
        allowed = allowed and not self:GetIsOccupied()
    end
    
    return allowed, canAfford
    
end 
function CommandStation:GetIsPlayerInside(player)

    // Check to see if we're in range of the visible center of the login platform
    local vecDiff = (player:GetModelOrigin() - self:GetKillOrigin())
    return vecDiff:GetLength() < CommandStation.kCommandStationKillConstant
    
end

local kCommandStationState = enum( { "Normal", "Locked", "Welcome", "Unbuilt" } )
function CommandStation:OnUpdateRender()

    PROFILE("CommandStation:OnUpdateRender")

    CommandStructure.OnUpdateRender(self)
    
    local model = self:GetRenderModel()
    if model then
    
        local state = kCommandStationState.Normal
        
        if self:GetIsGhostStructure() then
            state = kCommandStationState.Unbuilt
        elseif self:GetIsOccupied() then
            state = kCommandStationState.Welcome
        elseif GetTeamHasCommander(self:GetTeamNumber()) then
            state = kCommandStationState.Locked
        end
        
        model:SetMaterialParameter("state", state)
        
    end
    
end
function CommandStation:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    
end
function CommandStation:GetHealthbarOffset()
    return 2
end


Shared.LinkClassToMap("CommandStation", CommandStation.kMapName, networkVars)
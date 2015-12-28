//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//   Modified by Kyle Abent SiegeMod 2015
//________________________________
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PathingMixin.lua")
//Script.Load("lua/ObstacleMixin.lua")
//Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/StaticTargetMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")

class 'FuncDoor' (ScriptActor)

FuncDoor.kMapName = "func_door"


FuncDoor.kLockSound = PrecacheAsset("sound/NS2.fev/common/door_lock")
FuncDoor.kUnlockSound = PrecacheAsset("sound/NS2.fev/common/door_unlock")
FuncDoor.kCloseSound = PrecacheAsset("sound/NS2.fev/common/door_close")

FuncDoor.kState = enum( {'Open', 'Close', 'Locked', 'Welded'} )
FuncDoor.kStateSound = { [FuncDoor.kState.Open] = FuncDoor.kOpenSound, 
                          [FuncDoor.kState.Close] = FuncDoor.kCloseSound, 
                          [FuncDoor.kState.Locked] = FuncDoor.kLockSound,
                           [FuncDoor.kState.Welded] = FuncDoor.kLockSound, 
                        }


local kUpdateAutoOpenRate = 1
local kWeldDelay = 10



local kModelNameDefault = PrecacheAsset("models/misc/door/door.model")
//local kModelNameClean = PrecacheAsset("models/misc/door/door_clean.model")
local kModelNameDestroyed = PrecacheAsset("models/misc/door/door_destroyed.model")

local kDoorAnimationGraph = PrecacheAsset("models/misc/door/door.animation_graph")
kMaxBreakableHealth = 99999

local networkVars =
{
     state = "enum FuncDoor.kState",
     scale = "vector",
     team = "integer (0 to 2)",
     damageFrontPose = "float (0 to 100 by 0.1)",
     timeOfDestruction  = "time",
     canbewelded = "boolean",
     isvisible = "boolean",

}
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(LogicMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)

//AddMixinNetworkVars(ObstacleMixin, networkVars)
networkVars.health = string.format("float (0 to %f by 1)", kMaxBreakableHealth)
networkVars.maxHealth = string.format("float (0 to %f by 1)", kMaxBreakableHealth)
function FuncDoor:GetPointValue()  

    local points = 5
    
    // give additional points for enemies which got alot of score in their current life
    // but don't give more than twice the default point value
    if HasMixin(self, "Scoring") then
    
        local scoreGained = self:GetScoreGainedCurrentLife() or 0
        points = points + math.min(points, scoreGained * 0.1)
        
    end

    return points
end
function FuncDoor:HandoutPoints()
        local totalDamageDone = self:GetMaxHealth() + self:GetMaxArmor() * 2        
        local points = self:GetPointValue()
        local resReward = self:isa("Player") and kPersonalResPerKill or 0
        
        // award partial res and score to players who assisted
        for attackerId, damageDone in pairs(self.damagePoints) do  
        
            local currentAttacker = Shared.GetEntity(attackerId)
            if currentAttacker and HasMixin(currentAttacker, "Scoring") then
                
                local damageFraction = Clamp(damageDone / totalDamageDone, 0, 1)                
                local scoreReward = points >= 1 and math.max(1, math.round(points * damageFraction)) or 0    
         
                currentAttacker:AddScore(scoreReward, resReward * damageFraction, attacker == currentAttacker)
                
                if self:isa("Player") and currentAttacker ~= attacker then
                    currentAttacker:AddAssistKill()
                end
                
            end
        
        end
end
local function UpdateAutoOpen(self, timePassed)

    // If any players are around, have door open if possible, otherwise close it
    local state = self:GetState()
    if not self:GetAreFrontDoorsOpen() then self:SetState(FuncDoor.kState.Open) self.isvisible = false return true end
    self.damageFrontPose = Clamp( (self.maxHealth / self.health ) * 10, 0, 100)
    if self.health == 0 then 
               if self.canbewelded then
                self.canbewelded = false
                self.timeOfDestruction = Shared.GetTime() 
                self.isvisible = false
                self:HandoutPoints()
                end
               self:AddTimedCallback(function() self:SetPhysicsGroup(PhysicsGroup.OpenDoor) end, 2) 
      self:SetState(FuncDoor.kState.Open) 
       return true 
        end
   // if state == FuncDoor.kState.Open or state == FuncDoor.kState.Close then
    
        local desiredOpenState = false
        local entities = Shared.GetEntitiesWithTagInRange("Door", self:GetOrigin(), 3)
        for index = 1, #entities do
            
            local entity = entities[index]
            local opensForEntity, openDistance = entity:GetCanDoorInteract(self)
			
            if opensForEntity then
            
                local distSquared = self:GetDistanceSquared(entity)
                if (not HasMixin(entity, "Live") or entity:GetIsAlive()) and entity:GetIsVisible() and distSquared < (openDistance * openDistance) then
                
                    desiredOpenState = true
                    break
                
                end
            
            end
            
        end
        
        if desiredOpenState and self:GetState() ~= FuncDoor.kState.Open then
            self:SetState(FuncDoor.kState.Open)
        elseif not desiredOpenState and self:GetState() == FuncDoor.kState.Open then
            self:SetState(FuncDoor.kState.Welded)  
        end
        
   //end
    if not self.canbewelded then self.canbewelded = true  self:ActivateNanoShield(16) end
    if not self.isvisible then self.isvisible = true end
    if self:GetPhysicsGroup() ~= PhysicsGroup.FuncMoveable then self:SetPhysicsGroup(PhysicsGroup.FuncMoveable) end
    return true

end


function FuncDoor:OnCreate()

        ScriptActor.OnCreate(self)
       InitMixin(self, BaseModelMixin)
       InitMixin(self, ModelMixin)
       InitMixin(self, PathingMixin)
       InitMixin(self, ObstacleMixin)
       InitMixin(self, LiveMixin)
       InitMixin(self, CombatMixin)
       InitMixin(self, SelectableMixin)
       InitMixin(self, TeamMixin)
       InitMixin(self, PointGiverMixin)
        
            if Server then
    
        self:AddTimedCallback(UpdateAutoOpen, kUpdateAutoOpenRate)
        
    end
    
   // self.state = Door.kState.Open
   self.damageFrontPose = 0
   self.team = 1
   self.timeOfDestruction = 0
   self.canbewelded = true
   self.isvisible = true

end
FuncDoor.HealthScaleCallbacks = {}
FuncDoor.HasHealthScaleCallbacks = false

function FuncDoor:OnInitialized()
    // Don't call Door OnInit, we want to create or own Model
        ScriptActor.OnInitialized(self)
    self:SetModel(kModelNameDefault, kDoorAnimationGraph)  
//    InitMixin(self, ScaledModelMixin)
        InitMixin(self, WeldableMixin)
        InitMixin(self, NanoShieldMixin)
    
   
    
  //  self:SetState(Door.kState.Close)
    
    
    if not self.scale then
        self.scale = Vector(1,1,1)
    end
    
	//self:SetScaledModel(kModelNameDefault, kDoorAnimationGraph)
    
    if self.startsOpen then
        self:SetState(FuncDoor.kState.Open)
    else
        self:SetState(FuncDoor.kState.Welded)
    end
    
    if Server then
            self:SetPhysicsType(PhysicsType.Kinematic)
            self:SetPhysicsGroup(PhysicsGroup.FuncMoveable)
       // self:SetPhysicsGroup(PhysicsGroup.CommanderUnitGroup)
        
//         This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
           InitMixin(self, MapBlipMixin)
        end
        InitMixin(self, LogicMixin) 
         self:Stuff()
            InitMixin(self, StaticTargetMixin)
                    self:SetUpdates(true)
        if self.stayOpen then  
            self.timedCallbacks = {}
            
     end
      elseif Client then
        InitMixin(self, HiveVisionMixin)
        InitMixin(self, UnitStatusMixin)
    	local model = self:GetRenderModel()
            EquipmentOutline_AddModel( model )
        end

        // the ObsticleMixin includes the object automatically to the mesh
        //self.AddedToMesh = true
      //  self:SetPhysicsType(PhysicsType.Kinematic)
     //   self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
     //    self:SetPhysicsGroup(PhysicsGroup.FuncMoveable)
        //Pathing.CreatePathingObject(self.model, self:GetCoords())
        
            self.health = tonumber(self.health)    
    self.unscaledHealth = self.health
    self.maxHealth = self.health
    self:RecalculateHealth()    
end
function FuncDoor:Stuff()
                if (self.team and self.team > 0) then
            self:SetTeamNumber(self.team)

            -- Hook into the team add/remove player functions
            if self.scaleHealthOnTeamSize then

                if not FuncDoor.HasHealthScaleCallbacks then
                    Team.AddPlayer = HealthScaleUpdateCallback(Team.AddPlayer)
                    Team.RemovePlayer = HealthScaleUpdateCallback(Team.RemovePlayer)
                    Event.Hook("ClientDisconnected", function ()
                        for _, breakable in ipairs(FuncDoor.HealthScaleCallbacks) do
                            breakable:RecalculateHealth()
                        end
                    end)
                    FuncDoor.HasHealthScaleCallbacks = true
                end

                table.insert(FuncDoor.HealthScaleCallbacks, self)

            end
            
        end
end
function FuncDoor:GetResetsPathing()
    return true
end
    function FuncDoor:GetMapBlipType()
        return kMinimapBlipType.Door
    end
function FuncDoor:GetWeldPercentageOverride()
           return self.health / self.maxHealth
end
function FuncDoor:GetCanTakeDamageOverride()
    if self.health == 0 then 
    return false
    else
    return true
    end
end
function FuncDoor:OnWeldOverride(doer, elapsedTime, player)

    if self:GetCanBeWelded(doer) and not GetPowerFuncDoorRecentlyDestroyed(self) then
    
        if doer:isa("MAC") then
            self:AddHealth(MAC.kRepairHealthPerSecond * elapsedTime)
        elseif doer:isa("Welder") then
            self:AddHealth(doer:GetRepairRate(self)  * elapsedTime)
       elseif doer:isa("ExoWelder") then
            self:AddHealth( kExoPlayerWeldRate  * elapsedTime)
        end
        
        if player and player.OnWeldTarget then
            player:OnWeldTarget(self)
        end
        
    end
    
end
function FuncDoor:GetCanBeWeldedOverride()
    return not GetPowerFuncDoorRecentlyDestroyed(self)
end
function GetPowerFuncDoorRecentlyDestroyed(self)
    return (self.timeOfDestruction + kWeldDelay) > Shared.GetTime()
end
function HealthScaleUpdateCallback(f)

    return function(team, player)

        for _, door in ipairs(FuncDoor.HealthScaleCallbacks) do
            door:RecalculateHealth()
        end

        return f(team, player)

    end

end
function FuncDoor:GetExtents()
    local min, max = self:GetModelExtents()
    return max
end
function FuncDoor:Reset() 
       self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(0)
    
  //  self:SetState(Door.kState.Close)
    
    self:SetModel(kModelNameDefault, kDoorAnimationGraph)  
   // self:SetScaledModel(kModelNameDefault, kDoorAnimationGraph)
    
    if self.startsOpen then
        self:SetState(FuncDoor.kState.Open)
    else
        self:SetState(FuncDoor.kState.Welded)
    end
	//self.AddedToMesh = false
        self.health = self.maxHealth
    self:RecalculateHealth()
end
function FuncDoor:GetCanTakeDamageOverride()
    return true
end
/*
function FuncDoor:OnGetMapBlipInfo()

    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    local isParasited = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
    
    
            blipType = kMinimapBlipType.Door
        blipTeam = self:GetTeamNumber()
    
    return blipType, blipTeam, isAttacked, isParasited
end
*/
/*
function Door:GetShowHealthFor(player)
    return false
end
*/
/*
function Door:GetIsWeldedShut()
    return self:GetState() == Door.kState.Welded
end
*/
function Door:GetDescription()

    local state = self:GetState()
    
    if state == Door.kState.Welded then
        doorDescription = string.format("Locked")
    else
            doorDescription = string.format("Opened")
    end
    
    return doorDescription
    
end

function FuncDoor:SetState(state, commander)

    if self.state ~= state then
    
        self.state = state
        /*
        if Server then
        
            local sound = FuncDoor.kStateSound[self.state]
            if sound ~= "" then
            
                self:PlaySound(sound)
                
                if commander ~= nil then
                    Server.PlayPrivateSound(commander, sound, nil, 1.0, commander:GetOrigin())
                end
                
            end
            
        end
        */
    end
    
end
function FuncDoor:GetState()
    return self.state
end
function FuncDoor:GetReceivesStructuralDamage()
    return true
end
/*
function FuncDoor:OnUpdate(deltaTime)
self.damageFrontPose = Clamp( (self.maxHealth / self.health ) * 10, 0, 100)
end
*/
function FuncDoor:OnUpdatePoseParameters()
 self:SetPoseParam("damage_f", self.damageFrontPose)
end
function FuncDoor:GetCanDieOverride() 
return false
end
function FuncDoor:GetCanBeUsed(player, useSuccessTable)
   if player:GetTeamNumber() == 1 and self.health > 0 then 
    useSuccessTable.useSuccess = true  
   else    
   useSuccessTable.useSuccess = false
    end  
end
  function FuncDoor:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
     local state = self:GetState()
    if self.health == 0 then
          if not GetPowerFuncDoorRecentlyDestroyed(self) then
          unitName = string.format(Locale.ResolveString("Open Door"))
          elseif  GetPowerFuncDoorRecentlyDestroyed(self) then
          local NowToWeld = kWeldDelay - (Shared.GetTime() - self.timeOfDestruction)
          local WeldLength =  math.ceil( Shared.GetTime() + NowToWeld - Shared.GetTime() )
          local time = WeldLength
          unitName = string.format(Locale.ResolveString("%s seconds"), time)
          end
     elseif state == FuncDoor.kState.Welded then
         unitName = string.format(Locale.ResolveString("Locked Door"))
     elseif FuncDoor.kState.Open then
    unitName = string.format(Locale.ResolveString("Open Door"))
     end
return unitName
end  
function FuncDoor:GetCanDamageGoThrough()
return self.health == 0
end
function FuncDoor:OnUse(player, elapsedTime, useSuccessTable)

    local state = self:GetState()
    if state ~= FuncDoor.kState.Welded then
        self:SetState(FuncDoor.kState.Welded)
    else
        self:SetState(FuncDoor.kState.Open)
    end
    
end
function FuncDoor:GetHealthbarOffset()
    return 0.45
end 
function FuncDoor:OnUpdateAnimationInput(modelMixin)

    PROFILE("FuncDoor:OnUpdateAnimationInput")
    
    local open = self.state == FuncDoor.kState.Open //and self.health >= 1
    local lock = self.state == FuncDoor.kState.Locked or self.state == FuncDoor.kState.Welded //and self.health >= 1
    local speed = open and self.health > 0 and Clamp(self:GetHealthScalar(), 0.001, 1) or
                  open and self.health == 0 and .25 or
                  lock and Clamp(self:GetHealthScalar(), 000.1, 1)
    
    modelMixin:SetAnimationInput("open", open)
    modelMixin:SetAnimationInput("lock", lock)
   // modelMixin:SetAnimationInput("opened", self.health == 0)
    modelMixin:SetAnimationInput("lock_speed", speed)
   // modelMixin:SetAnimationInput("health", self.health)
    
end
function FuncDoor:GetTechButtons(techId)

    local techButtons = {  kTechId.None, kTechId.None, kTechId.None, kTechId.None, 
               kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    return techButtons
    
end

function FuncDoor:GetShowHitIndicator()
    return true
end
function FuncDoor:GetSendDeathMessageOverride()
    return false
end
function FuncDoor:OnDestroy()
    table.removevalue(FuncDoor.HealthScaleCallbacks, self)
end

/*
function FuncDoor:OnWeldOverride(doer, elapsedTime)
end
*/
/*
function FuncDoor:GetCanBeWeldedOverride()
    return true
end
*/
function FuncDoor:GetCanTakeDamageOverride()
    return true
end
/*
function FuncDoor:OnKill(damage, attacker, doer, point, direction)

    ScriptActor.OnKill(self, damage, attacker, doer, point, direction)
    BaseModelMixin.OnDestroy(self)
   
    self:SetPhysicsGroup(PhysicsGroup.DroppedWeaponGroup)
    self:SetPhysicsGroupFilterMask(PhysicsMask.None)
    
    if Server then
        self:TriggerOutputs(attacker)  
        Print("Trigger ouputs")
    end
    
 //self:SetModel(kModelNameDestroyed, kDoorAnimationGraph)
 self:SetScaledModel(kModelNameDefault, kDoorAnimationGraph)
end
*/
local function GetNumPlayersIgnoringCommander(team)

    local numPlayers = 0

    local function CountPlayers( player )
    	local client = Server.GetOwner(player)
	if client and not player:isa("Commander") then
	    numPlayers = numPlayers + 1
	end
    end
    team:ForEachPlayer( CountPlayers )

    return numPlayers

end
function FuncDoor:RecalculateHealth()

    if self.scaleHealthOnTeamSize then
        local healthFraction = self.health / self.maxHealth
        self.maxHealth = self.unscaledHealth * math.max(GetNumPlayersIgnoringCommander(GetGamerules():GetTeam(GetEnemyTeamNumber(self:GetTeamNumber()))), 1)
        self.health = self.maxHealth * healthFraction
    end

end
function FuncDoor:OnLogicTrigger(player)

    local state = self:GetState()
    if state ~= FuncDoor.kState.Welded then
        self:SetState(FuncDoor.kState.Welded)
    else
        self:SetState(FuncDoor.kState.Open)
    end
    
end

// only way to scale the model

function FuncDoor:OnAdjustModelCoords(modelCoords)

    local coords = modelCoords
    coords.xAxis = coords.xAxis * self.scale.x
    coords.yAxis = coords.yAxis * self.scale.y
    coords.zAxis = coords.zAxis * self.scale.z
      
    return coords
    
end

function FuncDoor:GetAreFrontDoorsOpen()
  if Server then
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and not gameRules:GetFrontDoorsOpen() and not ( Shared.GetMapName() == "ns2_rockdownsiege2" and gameRules:GetSideDoorsOpen() ) then 
                   return false
               end
            end
            return true
  end
end

Shared.LinkClassToMap("FuncDoor", FuncDoor.kMapName, networkVars)
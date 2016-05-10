// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TunnelEntrance.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Entrance to a gorge tunnel. A "GorgeTunnel" entity is created once both entrances are completed.
//    In case both tunnel entrances are destroyed, the tunnel will collapse.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/DigestMixin.lua")
Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")

Script.Load("lua/Tunnel.lua")

class 'TunnelEntrance' (ScriptActor)

TunnelEntrance.kMapName = "tunnelentrance"

local kDigestDuration = 1.5
local kTunnelInfestationRadius = 7

TunnelEntrance.kModelName = PrecacheAsset("models/alien/tunnel/mouth.model")
TunnelEntrance.kModelNameShadow = PrecacheAsset("models/alien/tunnel/mouth_shadow.model")
local kAnimationGraph = PrecacheAsset("models/alien/tunnel/mouth.animation_graph")

local networkVars = { 
    connected = "boolean",
    beingUsed = "boolean",
    timeLastExited = "time",
    ownerId = "entityid",
    allowDigest = "boolean",
    destLocationId = "entityid",
    //otherSideInfested = "boolean"
    movedbycommander = "boolean",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(TeleportMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(AlienStructureMoveMixin, networkVars)

local function UpdateInfestationStatus(self)

    local wasOnInfestation = self.onNormalInfestation
    self.onNormalInfestation = false
    
    local origin = self:GetOrigin()
    // use hives and cysts as "normal" infestation
    local infestationEnts = GetEntitiesForTeamWithinRange("Hive", self:GetTeamNumber(), origin, 25)
    table.copy(GetEntitiesForTeamWithinRange("Cyst", self:GetTeamNumber(), origin, 25), infestationEnts, true)
    
    // update own infestation status
    for i = 1, #infestationEnts do
    
        if infestationEnts[i]:GetIsPointOnInfestation(origin) then
            self.onNormalInfestation = true
            break
        end
    
    end
    
    local otherSideInfested = false
    local tunnel = self:GetTunnelEntity()
    
    if tunnel then
    
        local exitA = tunnel:GetExitA()
        local exitB = tunnel:GetExitB()
        local otherSide = (exitA and exitA ~= self) and exitA or exitB
        otherSideInfested = (otherSide and otherSide.onNormalInfestation) and true or false
        
    end
        
    if otherSideInfested ~= self.otherSideInfested then
    
        self.otherSideInfested = otherSideInfested
        self:SetDesiredInfestationRadius(self:GetInfestationMaxRadius())
    
    end

    return true

end

function TunnelEntrance:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, CloakableMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ObstacleMixin)    
    InitMixin(self, FireMixin)
    InitMixin(self, CatalystMixin)  
    InitMixin(self, UmbraMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, DigestMixin)
    InitMixin(self, InfestationMixin)
    InitMixin(self, TeleportMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, AlienStructureMoveMixin, { kAlienStructureMoveSound = Whip.kWalkingSound })
    
    if Server then
    
        InitMixin(self, InfestationTrackerMixin)
        self.connected = false
        self.tunnelId = Entity.invalidId
        
    elseif Client then
        InitMixin(self, CommanderGlowMixin)     
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    self.timeLastInteraction = 0
    self.timeLastExited = 0
    self.destLocationId = Entity.invalidId
    self.movedbycommander = false
    //self.otherSideInfested = false
end

function TunnelEntrance:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(TunnelEntrance.kModelName, kAnimationGraph)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, SleeperMixin)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        self.onNormalInfestation = false
        //self:AddTimedCallback(UpdateInfestationStatus, 1)
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end

end

function TunnelEntrance:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if Client then
    
        Client.DestroyRenderDecal(self.decal)
        self.decal = nil
        
    end
    
end

function TunnelEntrance:SetVariant(gorgeVariant)

    if gorgeVariant == kGorgeVariant.shadow then
        self:SetModel(TunnelEntrance.kModelNameShadow, kAnimationGraph)
    else
        self:SetModel(TunnelEntrance.kModelName, kAnimationGraph)
    end
    
end

function TunnelEntrance:GetInfestationRadius()
    return kTunnelInfestationRadius
end

function TunnelEntrance:GetInfestationMaxRadius()
    return kTunnelInfestationRadius // self.otherSideInfested and kTunnelInfestationRadius or 0
end

if not Server then
    function TunnelEntrance:GetOwner()
        return self.ownerId ~= nil and Shared.GetEntity(self.ownerId)
    end
end

function TunnelEntrance:GetOwnerClientId()
    return self.ownerClientId
end

function TunnelEntrance:GetDigestDuration()
    return kDigestDuration
end

function TunnelEntrance:GetCanDigest(player)
    return self.allowDigest and player == self:GetOwner() and player:isa("Gorge") and (not HasMixin(self, "Live") or self:GetIsAlive())
end

function TunnelEntrance:SetOwner(owner)

    if owner and not self.ownerClientId then
    
        local client = Server.GetOwner(owner)    
        self.ownerClientId = client:GetUserId()

        if Server then
            self:UpdateConnectedTunnel()
        end
    
        if self.tunnelId and self.tunnelId ~= Entity.invalidId then
        
            local tunnelEnt = Shared.GetEntity(self.tunnelId)
            tunnelEnt:SetOwnerClientId(self.ownerClientId)
        
        end

    end
    
end
function TunnelEntrance:GetCanAutoBuild()
    return self:GetGameEffectMask(kGameEffect.OnInfestation)
end

function TunnelEntrance:GetReceivesStructuralDamage()
    return true
end

function TunnelEntrance:GetIsWallWalkingAllowed()
    return false
end

function TunnelEntrance:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function TunnelEntrance:GetCanSleep()
    return not self.moving
end

function TunnelEntrance:GetTechButtons(techId)
    local techButtons = nil
    
        techButtons = { kTechId.Move, kTechId.None, kTechId.None, kTechId.None,  
                    kTechId.None, kTechId.None, kTechId.None, kTechId.None }
                    
      if self.moving then
      techButtons[2] = kTechId.Stop
      end
    
    return techButtons
end
function TunnelEntrance:GetMaxSpeed()
    return kAlienStructureMoveSpeed
end

function TunnelEntrance:OnOverrideOrder(order)
    if order:GetType() == kTechId.Default or order:GetType() == kTechId.Move then
             if not self.movedbycommander then self.movedbycommander = true end
             order:SetType(kTechId.Move)
             self:SetInfestationRadius(0)
    elseif order:GetType() == kTechId.Stop then
             order:SetType(kTechId.Stop)
             //UpdateInfestationStatus(self)
           //  InitMixin(self, InfestationMixin)
             self:SetInfestationRadius(0)
           //  self.movedbycommander = false
    end
             
end
function TunnelEntrance:GetIsConnected()
    return self.connected
end

function TunnelEntrance:Interact()

    self.beingUsed = true
    self.clientBeingUsed = true
    self.timeLastInteraction = Shared.GetTime()
    
end

if Server then
 
    function TunnelEntrance:FindFreeSpace(hive)
     if not hive then return nil end
        for index = 1, 16 do
           local extents = Vector(1.3,1.3,1.3)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, hive:GetOrigin(), .5, 24, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == hive:GetLocationName()
        
           if spawnPoint ~= nil and sameLocation and GetIsPointOnInfestation(spawnPoint) then
           return spawnPoint
           end
       end
           Print("No valid spot found for gorge tunnel auto hive spawn!")
           return nil
    end
    function TunnelEntrance:IsInRangeOfHive()
      local hives = GetEntitiesWithinRange("Hive", self:GetOrigin(), Shade.kCloakRadius)
   if #hives >=1 then return true end
   return false
end
  
    function TunnelEntrance:DestroyOther()
    for _, tunnelent in ipairs( GetEntitiesForTeam("TunnelEntrance", 2)) do
        if tunnelent:GetOwner() == self:GetOwner() and tunnelent ~= self then
        DestroyEntity(tunnelent)
        end
    end
    end
    
    function TunnelEntrance:OnCreatedByGorge(gorge)
     
      // if not self.connected and not self:IsInRangeOfHive() then
      self:DestroyOther()
             local origin = self:FindFreeSpace(self:GetTeam():GetHive())
               if origin then
                    local tunnelent = CreateEntity(TunnelEntrance.kMapName, origin, 2)   
                    tunnelent:SetOwner(self:GetOwner())
                    tunnelent:SetConstructionComplete()
                    self:GetOwner():TunnelGood(self:GetOwner())
                 return tunnelent
               end
           self:GetOwner():TunnelFailed(self:GetOwner())
     //  end
        
    
    end
    
    
    function TunnelEntrance:OnTeleportEnd()
    
        local tunnel = Shared.GetEntity(self.tunnelId)
        if tunnel then
            tunnel:UpdateExit(self)
        end
        
        self:SetInfestationRadius(0)
        
    end

    local function ComputeDestinationLocationId(self)
    
        local destLocationId = Entity.invalidId
        
        if self.connected then
        
            local tunnel = Shared.GetEntity(self.tunnelId)
            local exitA = tunnel:GetExitA()
            local exitB = tunnel:GetExitB()
            local oppositeExit = ((exitA and exitA ~= self) and exitA) or ((exitB and exitB ~= self) and exitB)
            
            if oppositeExit then
                local location = GetLocationForPoint(oppositeExit:GetOrigin())
                if location then
                    destLocationId = location:GetId()
                end       
            end
        
        end
        
        return destLocationId
    
    end

    function TunnelEntrance:OnUpdate(deltaTime)

        ScriptActor.OnUpdate(self, deltaTime)    

        local tunnel = self:GetTunnelEntity()
        self.connected = tunnel ~= nil and not tunnel:GetIsDeadEnd()
        self.beingUsed = self.timeLastInteraction + 0.1 > Shared.GetTime()  
        self.destLocationId = ComputeDestinationLocationId(self)
        
        if not self.timeLastMoveUpdateCheck or self.timeLastMoveUpdateCheck + 15 < Shared.GetTime() then 
            if self:CheckSpaceAboveForJump() then 
            self:MoveToUnstuck()
            end
            self.timeLastMoveUpdateCheck = Shared.GetTime()
        end
        
        
        local destructionAllowedTable = { allowed = true }
        if self.GetDestructionAllowed then
            self:GetDestructionAllowed(destructionAllowedTable)
        end
        
        if destructionAllowedTable.allowed then
            DestroyEntity(self)
        end

    end

    function TunnelEntrance:GetTunnelEntity()
    
        if self.tunnelId and self.tunnelId ~= Entity.invalidId then
            return Shared.GetEntity(self.tunnelId)
        end
    
    end

    function TunnelEntrance:UpdateConnectedTunnel()

        local hasValidTunnel = self.tunnelId ~= nil and Shared.GetEntity(self.tunnelId) ~= nil

        if hasValidTunnel or self:GetOwnerClientId() == nil or not self:GetIsBuilt() then
            return
        end

        // register if a tunnel entity already exists or a free tunnel has been found
        for index, tunnel in ientitylist( Shared.GetEntitiesWithClassname("Tunnel") ) do
        
            if tunnel:GetOwnerClientId() == self:GetOwnerClientId() or tunnel:GetOwnerClientId() == nil then
                
                tunnel:AddExit(self)
                self.tunnelId = tunnel:GetId()
                tunnel:SetOwnerClientId(self:GetOwnerClientId())
                return
                
            end
            
        end
        
        // no tunnel entity present, check if there is another tunnel entrance to connect with
        local tunnel = CreateEntity(Tunnel.kMapName, nil, self:GetTeamNumber())
        tunnel:SetOwnerClientId(self:GetOwnerClientId()) 
        tunnel:AddExit(self)
        self.tunnelId = tunnel:GetId()

    end

    function TunnelEntrance:OnConstructionComplete()
        self:UpdateConnectedTunnel()
    end
    
    function TunnelEntrance:OnKill(attacker, doer, point, direction)
       // self:DestroyOther()
        ScriptActor.OnKill(self, attacker, doer, point, direction)
        self:TriggerEffects("death")
        self:SetModel(nil)
        
        local team = self:GetTeam()
        if team then
            team:UpdateClientOwnedStructures(self:GetId())
        end
        
        local tunnel = Shared.GetEntity(self.tunnelId)
        if tunnel then
            tunnel:RemoveExit(self)
        end
    
    end  

end

function TunnelEntrance:GetHealthbarOffset()
    return 1
end

function TunnelEntrance:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = self.connected and useSuccessTable.useSuccess and self:GetCanDigest(player)  
end

function TunnelEntrance:GetCanBeUsedConstructed()
    return true
end

if Server then

    function TunnelEntrance:SuckinEntity(entity)
    
        if entity and HasMixin(entity, "TunnelUser") and self.tunnelId then
        
            local tunnelEntity = Shared.GetEntity(self.tunnelId)
            if tunnelEntity then
            
                tunnelEntity:MovePlayerToTunnel(entity, self)
                entity:SetVelocity(Vector(0, 0, 0))
                
                if entity.OnUseGorgeTunnel then
                    entity:OnUseGorgeTunnel()
                end

            end
            
        end
    
    end
    
    function TunnelEntrance:OnEntityExited(entity)
        self.timeLastExited = Shared.GetTime()
        self:TriggerEffects("tunnel_exit_3D")
    end

end   
function TunnelEntrance:CheckSpaceAboveForJump()

    local startPoint = self:GetOrigin() 
    local endPoint = startPoint + Vector(1.2, 1.2, 1.2)
    
    return GetWallBetween(startPoint, endPoint, self)
    
end
function TunnelEntrance:MoveToUnstuck()
        local extents = LookupTechData(kTechId.GorgeTunnel, kTechDataMaxExtents, nil)
        local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), .5, 7, EntityFilterAll())
        
        if spawnPoint ~= nil then
            spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
        end
        
        if spawnPoint then
        self:SetOrigin(spawnPoint)
        end
end
if Server then
              function TunnelEntrance:FindFreeSpawn() 
         if not self:CheckSpaceAboveForJump() then Print("Valid spot - not finding free spawn")  return self:GetOrigin() + Vector(0, 0.2, 0) end
        for index = 1, 25 do
           local extents = LookupTechData(kTechId.Onos, kTechDataMaxExtents, nil)
           local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
           local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), .5, 12, EntityFilterAll())
        
           if spawnPoint ~= nil then
             spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
           end
        
           local location = spawnPoint and GetLocationForPoint(spawnPoint)
           local locationName = location and location:GetName() or ""
           local sameLocation = spawnPoint ~= nil and locationName == self:GetLocationName()
        
           if spawnPoint ~= nil and sameLocation then//and GetIsPointOnInfestation(spawnPoint) then
           return spawnPoint
           end
       end
           Print("No valid spot found for tunnel exit!")
           return self:GetOrigin() + Vector(0, 0.2, 0)
    end 
end
function TunnelEntrance:CheckSpaceAboveForJump()

    local startPoint = self:GetOrigin() 
    local endPoint = startPoint + Vector(1.2, 1.2, 1.2)
    local trace = Shared.TraceRay(self:GetOrigin(), self:GetOrigin() + Vector(0,1,0),  CollisionRep.Default,  PhysicsMask.All,  EntityFilterOne(self))
       if trace.fraction < 1 or trace.entity then
            return false
        end
    return GetWallBetween(startPoint, endPoint, self)
    
end
function TunnelEntrance:OnUpdateAnimationInput(modelMixin)

    local sucking = self.beingUsed or (self.clientBeingUsed and self.timeLastInteraction and self.timeLastInteraction + 0.1 > Shared.GetTime())
    -- sucking will be nil when self.clientBeingUsed is nil. Handle this case here.
    sucking = sucking or false

    modelMixin:SetAnimationInput("open", self.connected)
    modelMixin:SetAnimationInput("player_in", sucking)
    modelMixin:SetAnimationInput("player_out", self.timeLastExited + 0.2 > Shared.GetTime())
    
end

function TunnelEntrance:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, 0.25, 0)
end

function TunnelEntrance:OnUpdateRender()

    local showDecal = self:GetIsVisible() and not self:GetIsCloaked() and self:GetIsAlive()

    if not self.decal and showDecal then
        self.decal = CreateSimpleInfestationDecal(1.9, self:GetCoords())
    elseif self.decal and not showDecal then
        Client.DestroyRenderDecal(self.decal)
        self.decal = nil
    end

end


function TunnelEntrance:GetDestinationLocationName()

    local location = Shared.GetEntity(self.destLocationId)   
    if location then
        return location:GetName()
    end
    
end


function TunnelEntrance:GetUnitNameOverride(viewer)

    local unitName = GetDisplayName(self)    
    
    if not GetAreEnemies(self, viewer) and self.ownerId then        
        local ownerName
        for _, playerInfo in ientitylist(Shared.GetEntitiesWithClassname("PlayerInfoEntity")) do
            if playerInfo.playerId == self.ownerId then
                ownerName = playerInfo.playerName
                break
            end
        end
        if ownerName then
            
            local lastLetter = ownerName:sub(-1)
            if lastLetter == "s" or lastLetter == "S" then
                return string.format( Locale.ResolveString( "TUNNEL_ENTRANCE_OWNER_ENDS_WITH_S" ), ownerName )
            else
                return string.format( Locale.ResolveString( "TUNNEL_ENTRANCE_OWNER" ), ownerName )
            end
        end
        
    end

    return unitName

end

function TunnelEntrance:OverrideHintString( hintString, forEntity )
    
    if not GetAreEnemies(self, forEntity) then
        local locationName = self:GetDestinationLocationName()
        if locationName and locationName~="" then
            return string.format(Locale.ResolveString( "TUNNEL_ENTRANCE_HINT_TO_LOCATION" ), locationName )
        end
    end

    return hintString
    
end

Shared.LinkClassToMap("TunnelEntrance", TunnelEntrance.kMapName, networkVars)

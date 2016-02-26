// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Web.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// Spit attack on primary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/OwnerMixin.lua")
Script.Load("lua/Mixins/BaseModelMixin.lua")
Script.Load("lua/Mixins/ModelMixin.lua")

class 'Web' (Entity)

Web.kMapName = "web"

Web.kRootModelName = PrecacheAsset("models/alien/gorge/web_helper.model")
Web.kModelName = PrecacheAsset("models/alien/gorge/web.model")
local kAnimationGraph = PrecacheAsset("models/alien/gorge/web.animation_graph")

local networkVars =
{
    length = "float",
}

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)

PrecacheAsset("models/alien/gorge/web.surface_shader")
local kWebMaterial = PrecacheAsset("models/alien/gorge/web.material")
local kWebWidth = 0.1

function EntityFilterNonWebables()
    return function(test) return not HasMixin(test, "Webable") end
end

function Web:SpaceClearForEntity(location)
    return true
end

local function CheckWebablesInRange(self)

    local webables = GetEntitiesWithMixinForTeamWithinRange("Webable", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), self.checkRadius)
    self.enemiesInRange = #webables > 0

    return true

end

function Web:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, EffectsMixin)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, LiveMixin)
    
    if Server then
    
        InitMixin(self, InvalidOriginMixin)
        InitMixin(self, EntityChangeMixin)
        InitMixin(self, OwnerMixin)
        
        self.nearbyWebAbleIds = {}
        self:SetTechId(kTechId.Web)
        
        self:AddTimedCallback(CheckWebablesInRange, 0.3)
        
        self.triggerSpawnEffect = false
        
    end
    
    self:SetUpdates(true)
    self:SetRelevancyDistance(kMaxRelevancyDistance)
    
end

function Web:OnInitialized()

    self:SetModel(Web.kModelName, kAnimationGraph)
    
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.WebsGroup)  
  
end

if Server then

    function Web:SetEndPoint(endPoint)
    
        self.endPoint = Vector(endPoint)
        self.length = Clamp((self:GetOrigin() - self.endPoint):GetLength(), kMinWebLength, kMaxWebLength)
        
        local coords = Coords.GetIdentity()
        coords.origin = self:GetOrigin()
        coords.zAxis = GetNormalizedVector(self:GetOrigin() - self.endPoint)
        coords.xAxis = coords.zAxis:GetPerpendicular()
        coords.yAxis = coords.zAxis:CrossProduct(coords.xAxis)
        
        self:SetCoords(coords)
        
        self.checkRadius = (self:GetOrigin() - self.endPoint):GetLength() * .5 + 1
        
    end

end

function Web:GetIsFlameAble()
    return true
end    

function Web:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    // webs can't be destroyed with bullet weapons
    if doer ~= nil and not (doer:isa("Grenade") or doer:isa("ClusterGrenade") or damageType == kDamageType.Flame) then
        damageTable.damage = 0
    end

end

if Server then

    function Web:OnKill()

        self:TriggerEffects("death")
        DestroyEntity(self)
    
    end

end

local function TriggerWebDestroyEffects(self)

    local startPoint = self:GetOrigin()
    local zAxis = -self:GetCoords().zAxis
    local coords = self:GetCoords()
    
    for i = 1, 20 do

        local effectPoint = startPoint + zAxis * 0.36 * i
        
        if (effectPoint - startPoint):GetLength() >= self.length then
            break
        end
        
        coords.origin = effectPoint

        self:TriggerEffects("web_destroy", { effecthostcoords = coords })    
    
    end

end

function Web:OnDestroy()

    Entity.OnDestroy(self)
    
    if self.webRenderModel then
    
        DynamicMesh_Destroy(self.webRenderModel)
        self.webRenderModel = nil
        
    end
    
    if Server then
        TriggerWebDestroyEffects(self)
    end

end

if Client then

    function Web:OnUpdateRender()

        // we are smart and do that only once.
        // old code generated model
        /*
        if not self.webRenderModel then
        
            self.webRenderModel = DynamicMesh_Create()
            self.webRenderModel:SetMaterial(kWebMaterial)
            
            local length = (self.endPoint - self:GetOrigin()):GetLength()
            local coords = Coords.GetIdentity()
            coords.origin = self:GetOrigin()
            coords.zAxis = GetNormalizedVector(self.endPoint - self:GetOrigin())
            coords.xAxis = coords.zAxis:GetPerpendicular()
            coords.yAxis = coords.zAxis:CrossProduct(coords.xAxis)
            
            DynamicMesh_SetTwoSidedLine(self.webRenderModel, coords, kWebWidth, length)
        
        end
        */

    end

end   

local function GetDistance(self, fromPlayer)

    local tranformCoords = self:GetCoords():GetInverse()
    local relativePoint = tranformCoords:TransformPoint(fromPlayer:GetOrigin())    

    return math.abs(relativePoint.x), relativePoint.y

end

local function CheckForIntersection(self, fromPlayer)

    if not self.endPoint then
        self.endPoint = self:GetOrigin() + self.length * self:GetCoords().zAxis
    end
    
    if fromPlayer then
    
        // need to manually check for intersection here since the local players physics are invisible and normal traces would fail
        local playerOrigin = fromPlayer:GetOrigin()
        local extents = fromPlayer:GetExtents()
        local fromWebVec = playerOrigin - self:GetOrigin()
        local webDirection = -self:GetCoords().zAxis
        local dotProduct = webDirection:DotProduct(fromWebVec)

        local minDistance = - extents.z
        local maxDistance = self.length + extents.z
        
        if dotProduct >= minDistance and dotProduct < maxDistance then
        
            local horizontalDistance, verticalDistance = GetDistance(self, fromPlayer)
            
            local horizontalOk = horizontalDistance <= extents.z
            local verticalOk = verticalDistance >= 0 and verticalDistance <= extents.y * 2         

            //DebugPrint("horizontalDistance %s  verticalDistance %s", ToString(horizontalDistance), ToString(verticalDistance))   

            if horizontalOk and verticalOk then
              
                fromPlayer:SetWebbed(kWebbedDuration)
                if Server then
                    DestroyEntity(self)
                end
          
            end
        
        end
    
    elseif Server then
    
        local trace = Shared.TraceRay(self:GetOrigin(), self.endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterNonWebables())
        if trace.entity and not trace.entity:isa("Player") then
            trace.entity:SetWebbed(kWebbedDuration)
            DestroyEntity(self)
        end    
    
    end

end 

// TODO: somehow the pose params dont work here when using clientmodelmixin. should figure out why this is broken and switch to clientmodelmixin
function Web:OnUpdatePoseParameters()
    self:SetPoseParam("scale", self.length)    
end

// called by the players so they can predict the web effect
function Web:UpdateWebOnProcessMove(fromPlayer)
    CheckForIntersection(self, fromPlayer)
end

if Server then

    local function TriggerWebSpawnEffects(self)

        local startPoint = self:GetOrigin()
        local zAxis = -self:GetCoords().zAxis
        
        for i = 1, 20 do

            local effectPoint = startPoint + zAxis * 0.36 * i
            
            if (effectPoint - startPoint):GetLength() >= self.length then
                break
            end

            self:TriggerEffects("web_create", { effecthostcoords = Coords.GetTranslation(effectPoint) })    
        
        end
    
    end

    // OnUpdate is only called when entities are in interest range, players are ignored here since they need to predict the effect  
    function Web:OnUpdate(deltaTime)

        if self.enemiesInRange then        
            CheckForIntersection(self)            
        end
        
        if not self.triggerSpawnEffect then
            TriggerWebSpawnEffects(self)
            self.triggerSpawnEffect = true
        end

    end

end

Shared.LinkClassToMap("Web", Web.kMapName, networkVars)
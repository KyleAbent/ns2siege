Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")

class 'LayStructures' (Weapon)

LayStructures.kMapName = "lay_structures"

local kDropModelName = PrecacheAsset("models/marine/welder/builder.model")
local kHeldModelName = PrecacheAsset("models/marine/welder/builder.model")

local kViewModels = GenerateMarineViewModelPaths("welder")
local kAnimationGraph = PrecacheAsset("models/marine/welder/laystructure_view.animation_graph")

local kPlacementDistance = 4
local kNumStructures = 1

local networkVars =
{
    structuresLeft = string.format("integer (0 to %d)", kNumStructures),
    droppingStructure = "boolean",
    techId = "string (128)",
    mapname = "string (128)",
    tellstructuretocredit = "boolean",
    originalposition = "vector",
}

AddMixinNetworkVars(PickupableWeaponMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(PointGiverMixin, networkVars)

function LayStructures:OnCreate()

    Weapon.OnCreate(self)
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, PointGiverMixin)
    
    self.structuresLeft = kNumStructures
    self.droppingStructure = false
    self.techId = kTechId.Armory
    self.mapname = Armory.kMapName
    self.originalposition = Vector(0,0,0)
    
end

function LayStructures:OnInitialized()

    Weapon.OnInitialized(self)
    
    self:SetModel(kDropModelName)
    
end

function LayStructures:GetIsValidRecipient(recipient)

    if self:GetParent() == nil and recipient and not GetIsVortexed(recipient) and recipient:isa("Marine") then
    
        local LayStructures = recipient:GetWeapon(LayStructures.kMapName)
        return LayStructures == nil
        
    end
    
    return false
    
end

function LayStructures:GetDropStructureId()
    return self.techId
end
function LayStructures:SetTechId(techid)
     self.techId = techid
end
function LayStructures:SetMapName(mapname)
     self.mapname = mapname
end
function LayStructures:GetstructuresLeft()
    return self.structuresLeft
end

function LayStructures:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function LayStructures:GetAnimationGraphName()
    return kAnimationGraph
end

function LayStructures:GetSuffixName()
    return "armory"
end

function LayStructures:GetDropClassName()
    return "Armory"
end

function LayStructures:GetWeight()
    return kLayMineWeight
end

function LayStructures:GetDropMapName()
    return self.mapname
end

function LayStructures:GetHUDSlot()
    return 5
end

function LayStructures:OnTag(tagName)

    PROFILE("LayStructures:OnTag")
    
    ClipWeapon.OnTag(self, tagName)
    
    if tagName == "deploy_structure" then
    
        local player = self:GetParent()
        if player then
        
            self:PerformPrimaryAttack(player)
            
            if self.structuresLeft == 0 then
            
                self:OnHolster(player)
                player:RemoveWeapon(self)
                player:SwitchWeapon(1)
                
                if Server then                
                    DestroyEntity(self)
                end
                
            end
            
        end
        
        self.droppingStructure = false
        
    end
    
end

function LayStructures:OnPrimaryAttackEnd(player)
    self.droppingStructure = false
end

function LayStructures:GetIsDroppable()
    return true
end
function LayStructures:GetIsCreditStructure()
   return self.tellstructuretocredit
end
function LayStructures:SetIsCreditStructure(boolean)
    self.tellstructuretocredit = boolean
end
function LayStructures:OnPrimaryAttack(player)

    // Ensure the current location is valid for placement.
    if not player:GetPrimaryAttackLastFrame() then
    
        local showGhost, coords, valid = self:GetPositionForStructure(player)
        if valid then
        
            if self.structuresLeft > 0 then
                self.droppingStructure = true
            else
            
                self.droppingStructure = false
                
                if Client then
                    player:TriggerInvalidSound()
                end
                
            end
            
        else
        
            self.droppingStructure = false
            
            if Client then
                player:TriggerInvalidSound()
            end
            
        end
        
    end
    
end

local function DropStructure(self, player)

    if Server then
    
        local showGhost, coords, valid = self:GetPositionForStructure(player)
        if valid then
        
            // Create mine.
            local structure = CreateEntity(self:GetDropMapName(), coords.origin, player:GetTeamNumber())
            if structure then
            
                structure:SetOwner(player)
                if not structure:isa("ARC") then structure:SetConstructionComplete()
                else
                structure.isGhostStructure = false
                end
                structure:SetOwner(player)
                if self:GetIsCreditStructure() == true then 
                   if structure.ignorelimit then structure.ignorelimit = true end
                end
                
                // Check for space
                if structure:SpaceClearForEntity(coords.origin) then
                
                    local angles = Angles()
                    angles:BuildFromCoords(coords)
                    structure:SetAngles(angles)
                    
                    player:TriggerEffects("create_" .. self:GetSuffixName())
                    
                    // Jackpot.
                    return true
                    
                else
                
                    player:TriggerInvalidSound()
                    DestroyEntity(structure)
                    
                end
                
            else
                player:TriggerInvalidSound()
            end
            
        else
        
            if not valid then
                player:TriggerInvalidSound()
            end
            
        end
        
    elseif Client then
        return true
    end
    
    return false
    
end

function LayStructures:Refill(amount)
    self.structuresLeft = amount
end

function LayStructures:PerformPrimaryAttack(player)

    local success = true
    
    if self.structuresLeft > 0 then
    
        player:TriggerEffects("start_create_" .. self:GetSuffixName())
        
        local viewAngles = player:GetViewAngles()
        local viewCoords = viewAngles:GetCoords()
        
        success = DropStructure(self, player)
        
        if success and not player:GetDarwinMode() then
            self.structuresLeft = Clamp(self.structuresLeft - 1, 0, kNumStructures)
        end
        
    end
    
    return success
    
end

function LayStructures:OnHolster(player, previousWeaponMapName)

    Weapon.OnHolster(self, player, previousWeaponMapName)
    
    self.droppingStructure = false
    
end

function LayStructures:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)
    
    // Attach weapon to parent's hand
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    
    self.droppingStructure = false
    
    self:SetModel(kHeldModelName)
    
end

function LayStructures:Dropped(prevOwner)

    //Weapon.Dropped(self, prevOwner)
           if self.originalposition ~= Vector(0,0,0) then
           local structure = CreateEntity(self:GetDropMapName(), self.originalposition, 1)
           structure:SetConstructionComplete()
           end
       
   DestroyEntity(self)
    
end
local kExtents = Vector(1, 1, 1) // 0.5 to account for pathing being too high/too low making it hard to palce tunnels
local function IsPathable(position)

    local noBuild = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end
// Given a gorge player's position and view angles, return a position and orientation
// for structure. Used to preview placement via a ghost structure and then to create it.
// Also returns bool if it's a valid position or not.
function LayStructures:GetPositionForStructure(player)

    local isPositionValid = false
    local foundPositionInRange = false
    local structPosition = nil
    local isonstructure = false
    
    local origin = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * kPlacementDistance
    
    // Trace short distance in front
    local trace = Shared.TraceRay(player:GetEyePos(), origin, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
    
    local displayOrigin = trace.endPoint
    
    // If we hit nothing, trace down to place on ground
    if trace.fraction == 1 then
    
        origin = player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * kPlacementDistance
        trace = Shared.TraceRay(origin, origin - Vector(0, kPlacementDistance, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
        
    end

    
    // If it hits something, position on this surface (must be the world or another structure)
    if trace.fraction < 1 then
        
        foundPositionInRange = true
    
        if trace.entity == nil then
            isPositionValid = true
        elseif HasMixin(trace.entity, "Construct") and trace.entity:GetTeamNumber() == 1  then
            isPositionValid = true
            isonstructure = true
        end
        
        displayOrigin = trace.endPoint
        
        // Can not be built on infestation
        if GetIsPointOnInfestation(displayOrigin) then
            isPositionValid = false
        end
    
          if not IsPathable(displayOrigin) then
                    isPositionValid = false or isonstructure
                end
          local entsnearby = GetEntitiesWithMixinForTeamWithinRange("Construct", 1, player:GetOrigin(), 12) 
          
          if #entsnearby >= 20 then
           isPositionValid = false
           end
           
           if  self.techId == kTechId.Sentry then
                 local nearsentrys = GetEntitiesForTeamWithinRange("Sentry", 1, player:GetOrigin(), 24)
                 if #nearsentrys >= 8 then
                 isPositionValid = false
                 end
           elseif self.techId == kTechId.ARC then
                 local neararcs = GetEntitiesForTeamWithinRange("ARC", 1, player:GetOrigin(), 48)
                 if #neararcs >= 4 then
                 isPositionValid = false
                 end
                   if string.find(player:GetLocationName(), "siege") or string.find(player:GetLocationName(), "Siege") then
                  isPositionValid = false
                  end
          end
          
        if GetPointBlocksAttachEntities(displayOrigin) then
            isPositionValid = false
        end
    
        if trace.surface == "nocling" then       
            isPositionValid = false
        end
        
        local structureFacing = player:GetViewAngles():GetCoords().zAxis
    
        if math.abs(Math.DotProduct(trace.normal, structureFacing)) > 0.9 then
            structureFacing = trace.normal:GetPerpendicular()
        end
    
        local perp = Math.CrossProduct(trace.normal, structureFacing)
        structureFacing = Math.CrossProduct(perp, trace.normal)
    
        structPosition = Coords.GetLookIn(displayOrigin, structureFacing, trace.normal)
        
    end
    
    return foundPositionInRange, structPosition, isPositionValid
    
end

function LayStructures:GetGhostModelName()
    return LookupTechData(self:GetDropStructureId(), kTechDataModel)
end

function LayStructures:OnUpdateAnimationInput(modelMixin)

    PROFILE("LayStructures:OnUpdateAnimationInput")
    
    modelMixin:SetAnimationInput("activity", ConditionalValue(self.droppingStructure, "primary", "none"))
    
end

if Client then

    function LayStructures:OnProcessIntermediate(input)
    
        local player = self:GetParent()
        
        if player then
        
            self.showGhost, self.ghostCoords, self.placementValid = self:GetPositionForStructure(player)
            self.showGhost = self.showGhost and self.structuresLeft > 0
            
        end
        
    end
    
    function LayStructures:GetUIDisplaySettings()
        return { xSize = 256, ySize = 417, script = "lua/GUIMineDisplay.lua" }
    end
    
end

function LayStructures:GetShowGhostModel()
    return self.showGhost
end

function LayStructures:GetGhostModelCoords()
    return self.ghostCoords
end   

function LayStructures:GetIsPlacementValid()
    return self.placementValid
end

function LayStructures:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
    
end

function LayStructures:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function LayStructures:OnKill()
        DestroyEntity(self)
    end
    
    function LayStructures:GetSendDeathMessageOverride()
        return false
    end 
    
end

Shared.LinkClassToMap("LayStructures", LayStructures.kMapName, networkVars)

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/ClogAbility.lua")



class 'DropClogAbility' (Ability)

local kMaxStructuresPerType = 20
local kDropCooldown = 1

DropClogAbility.kMapName = "drop_structure_ability"

local kCreateFailSound = PrecacheAsset("sound/NS2.fev/alien/gorge/create_fail")
local kAnimationGraph = PrecacheAsset("models/alien/gorge/gorge_view.animation_graph")

DropClogAbility.kSupportedStructures = { ClogAbility }

local networkVars =
{
    numClogsLeft = string.format("private integer (0 to %d)", kMaxStructuresPerType),
}

function DropClogAbility:GetAnimationGraphName()
    return kAnimationGraph
end

function DropClogAbility:GetActiveStructure()

    if self.activeStructure == nil then
        return nil
    else
        return DropClogAbility.kSupportedStructures[self.activeStructure]
    end

end

function DropClogAbility:OnCreate()

    Ability.OnCreate(self)
    
    self.dropping = false
    self.mouseDown = false
    self.activeStructure = nil
    
    if Server then
        self.lastCreatedId = Entity.invalidId
    end
        
    // for GUI
    self.numClogsLeft = 0
    self.lastClickedPosition = nil
    self:SetActiveStructure(1)
    
end

function DropClogAbility:GetDeathIconIndex()
    return kDeathMessageIcon.Consumed
end

function DropClogAbility:SetActiveStructure(structureNum)

    self.activeStructure = structureNum
    self.lastClickedPosition = nil
    
end

function DropClogAbility:GetHasDropCooldown()
    return self.timeLastDrop ~= nil and self.timeLastDrop + kDropCooldown > Shared.GetTime()
end

function DropClogAbility:GetSecondaryTechId()
    return kTechId.Spray
end

function DropClogAbility:GetNumStructuresBuilt(techId)

    if techId == kTechId.Clog then
        return self.numClogsLeft
    end
    // unlimited
    return -1
end

function DropClogAbility:OnPrimaryAttack(player)

    if Client then

        if self.activeStructure ~= nil
        and not self.dropping
        and not self.mouseDown then
        
            self.mouseDown = true
        
            if player:GetEnergy() >= kDropStructureEnergyCost then
            
                if self:PerformPrimaryAttack(player) then
                    self.dropping = true
                end

            else
                player:TriggerInvalidSound()
            end

        end
    
    end

end

function DropClogAbility:OnPrimaryAttackEnd(player)

    if not Shared.GetIsRunningPrediction() then
    
        if Client and self.dropping then
            self:OnSetActive()
        end

        self.dropping = false
        self.mouseDown = false
        
    end
    
end

function DropClogAbility:GetIsDropping()
    return self.dropping
end

function DropClogAbility:GetEnergyCost(player)
    return kDropStructureEnergyCost
end

function DropClogAbility:GetDamageType()
    return kHealsprayDamageType
end

function DropClogAbility:GetHUDSlot()
    return 5
end

function DropClogAbility:GetHasSecondary(player)
    return true
end

function DropClogAbility:OnSecondaryAttack(player)

    if player and self.previousWeaponMapName and player:GetWeapon(self.previousWeaponMapName) then
        player:SetActiveWeapon(self.previousWeaponMapName)
    end
    
end

function DropClogAbility:GetSecondaryEnergyCost(player)
    return 0
end

function DropClogAbility:PerformPrimaryAttack(player)

    if self.activeStructure == nil then
        return false
    end 

    local success = false

    // Ensure the current location is valid for placement.
    local coords, valid = self:GetPositionForStructure(player:GetEyePos(), player:GetViewCoords().zAxis, self:GetActiveStructure(), self.lastClickedPosition)
    local secondClick = true
    
    if LookupTechData(self:GetActiveStructure().GetDropStructureId(), kTechDataSpecifyOrientation, false) then
        secondClick = self.lastClickedPosition ~= nil
    end
    
    if secondClick then
    
        if valid then

            // Ensure they have enough resources.
            local cost = GetCostForTech(self:GetActiveStructure().GetDropStructureId())
            if player:GetResources() >= cost and not self:GetHasDropCooldown() then

                local message = BuildGorgeDropStructureMessage(player:GetEyePos(), player:GetViewCoords().zAxis, self.activeStructure, self.lastClickedPosition)
                Client.SendNetworkMessage("GorgeBuildStructure", message, true)
                self.timeLastDrop = Shared.GetTime()
                success = true

            end
        
        end

        self.lastClickedPosition = nil

    elseif valid then
        self.lastClickedPosition = Vector(coords.origin)
    end
    
    if not valid then
        player:TriggerInvalidSound()
    end
        
    return success
    
end

local function DropStructure(self, player, origin, direction, structureAbility, lastClickedPosition)

    // If we have enough resources
    if Server then
    
        local coords, valid, onEntity = self:GetPositionForStructure(origin, direction, structureAbility, lastClickedPosition)
        local techId = structureAbility:GetDropStructureId()
        
        local maxStructures = -1
        
        if not LookupTechData(techId, kTechDataAllowConsumeDrop, false) then
            maxStructures = LookupTechData(techId, kTechDataMaxAmount, 0) 
        end
        
        valid = valid and self:GetNumStructuresBuilt(techId) ~= maxStructures // -1 is unlimited
        
        local cost = LookupTechData(structureAbility:GetDropStructureId(), kTechDataCostKey, 0)
        local enoughRes = player:GetResources() >= cost
        local enoughEnergy = player:GetEnergy() >= kDropStructureEnergyCost
        
        if valid and enoughRes and structureAbility:IsAllowed(player) and enoughEnergy and not self:GetHasDropCooldown() then
        
            // Create structure
            local structure = self:CreateStructure(coords, player, structureAbility)
            if structure then
            
                structure:SetOwner(player)
                player:GetTeam():AddGorgeStructure(player, structure)
                
                if onEntity and HasMixin(onEntity, "ClogFall") and HasMixin(structure, "ClogFall") then
                    onEntity:ConnectToClog(structure)
                end
                
                // Check for space
                if structure:SpaceClearForEntity(coords.origin) then
                
                    local angles = Angles()                    
                    
                    if structure:isa("BabblerEgg") and coords.yAxis.y > 0.8 then
                        angles.yaw = math.random() * math.pi * 2
                    
                    elseif structure:isa("Clog") then
                    
                        angles.yaw = math.random() * math.pi * 2
                        angles.pitch = math.random() * math.pi * 2
                        angles.roll = math.random() * math.pi * 2
                        
                    elseif structure:isa("TunnelEntrance") then

                        angles:BuildFromCoords(coords) 
                        angles.roll = 0
                        angles.pitch = 0
                        
                    else
                        angles:BuildFromCoords(coords)
                    end
                    
                    structure:SetAngles(angles)
                    
                    if structure.OnCreatedByGorge then
                        structure:OnCreatedByGorge(self.lastCreatedId)
                    end
                    
                    player:AddResources(-cost)
                    
                    if structureAbility:GetStoreBuildId() then
                        self.lastCreatedId = structure:GetId()
                    end
                    
                    player:DeductAbilityEnergy(kDropStructureEnergyCost)
                    self:TriggerEffects("spit_structure", {effecthostcoords = Coords.GetLookIn(origin, direction)} )
                    
                    if structureAbility.OnStructureCreated then
                        structureAbility:OnStructureCreated(structure, lastClickedPosition)
                    end
                    
                    self.timeLastDrop = Shared.GetTime()
                    
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
            elseif not enoughRes then
                player:TriggerInvalidSound()
            end
            
        end
        
    end
    
    return true
    
end

function DropClogAbility:OnDropStructure(origin, direction, structureIndex, lastClickedPosition)

    local player = self:GetParent()
        
    if player then
    
        local structureAbility = DropClogAbility.kSupportedStructures[structureIndex]        
        if structureAbility then        
             DropStructure(self, player, origin, direction, structureAbility, lastClickedPosition)
        end
        
    end
    
end

function DropClogAbility:CreateStructure(coords, player, structureAbility, lastClickedPosition)
    local created_structure = structureAbility:CreateStructure(coords, player, lastClickedPosition)
    if created_structure then 
        return created_structure
    else
        return CreateEntity(structureAbility:GetDropMapName(), coords.origin, player:GetTeamNumber())
    end
end

local function FilterBabblersAndTwo(ent1, ent2)
    return function (test) return test == ent1 or test == ent2 or test:isa("Babbler") end
end

// Given a gorge player's position and view angles, return a position and orientation
// for structure. Used to preview placement via a ghost structure and then to create it.
// Also returns bool if it's a valid position or not.
function DropClogAbility:GetPositionForStructure(startPosition, direction, structureAbility, lastClickedPosition)

    PROFILE("DropClogAbility:GetPositionForStructure")

    local validPosition = false
    local range = structureAbility.GetDropRange()
    local origin = startPosition + direction * range
    local player = self:GetParent()

    // Trace short distance in front
    local trace = Shared.TraceRay(player:GetEyePos(), origin, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, FilterBabblersAndTwo(player, self))
    
    local displayOrigin = trace.endPoint
    
    // If we hit nothing, trace down to place on ground
    if trace.fraction == 1 then
    
        origin = startPosition + direction * range
        trace = Shared.TraceRay(origin, origin - Vector(0, range, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, FilterBabblersAndTwo(player, self))
        
    end
    
    // If it hits something, position on this surface (must be the world or another structure)
    if trace.fraction < 1 then
    
        if trace.entity == nil then
            validPosition = true
            
        elseif trace.entity:isa("Infestation") or trace.entity:isa("Clog") or (trace.entity:isa("Cyst") and trace.entity.isking) then
            validPosition = true
        end
        
        displayOrigin = trace.endPoint
        
    end

    if not structureAbility.AllowBackfacing() and trace.normal:DotProduct(GetNormalizedVector(startPosition - trace.endPoint)) < 0 then
        validPosition = false
    end    
    
    // Don't allow dropped structures to go too close to techpoints and resource nozzles
    if GetPointBlocksAttachEntities(displayOrigin) then
        validPosition = false
    end
    
    if not structureAbility:GetIsPositionValid(displayOrigin, player, trace.normal, lastClickedPosition, trace.entity) then
        validPosition = false
    end    
    
    if trace.surface == "nocling" then          
        validPosition = false
    end
    
    // Don't allow placing above or below us and don't draw either
    local structureFacing = Vector(direction)
    
    if math.abs(Math.DotProduct(trace.normal, structureFacing)) > 0.9 then
        structureFacing = trace.normal:GetPerpendicular()
    end
    
    // Coords.GetLookIn will prioritize the direction when constructing the coords,
    // so make sure the facing direction is perpendicular to the normal so we get
    // the correct y-axis.
    local perp = Math.CrossProduct( trace.normal, structureFacing )
    structureFacing = Math.CrossProduct( perp, trace.normal )
    
    local coords = Coords.GetLookIn( displayOrigin, structureFacing, trace.normal )
    
    if structureAbility.ModifyCoords then
        structureAbility:ModifyCoords(coords, lastClickedPosition)
    end
    
    return coords, validPosition, trace.entity

end

function DropClogAbility:OnDraw(player, previousWeaponMapName)

    Ability.OnDraw(self, player, previousWeaponMapName)

    self.previousWeaponMapName = previousWeaponMapName
    self.dropping = false
    self:SetActiveStructure(1)
end

function DropClogAbility:OnTag(tagName)
    if tagName == "shoot" then
        self.dropping = false
    end
end

function DropClogAbility:OnUpdateAnimationInput(modelMixin)

    PROFILE("DropClogAbility:OnUpdateAnimationInput")

    modelMixin:SetAnimationInput("ability", "chamber")
    
    local activityString = "none"
    if self.dropping then
        activityString = "primary"
    end
    modelMixin:SetAnimationInput("activity", activityString)
    
end

function DropClogAbility:ProcessMoveOnWeapon(input)

    // Show ghost if we're able to create structure, and if menu is not visible
    local player = self:GetParent()
    if player then
    
        if Server then

            local team = player:GetTeam()
            local hiveCount = team:GetNumHives()
            local numAllowedClogs = LookupTechData(kTechId.Clog, kTechDataMaxAmount, -1)             
            if numAllowedClogs >= 0 then     
                self.numClogsLeft = team:GetNumDroppedGorgeStructures(player, kTechId.Clog)           
            end
            
            
        end
        
    end    
    
end

function DropClogAbility:GetShowGhostModel()
    return self.activeStructure ~= nil and not self:GetHasDropCooldown()
end

function DropClogAbility:GetGhostModelCoords()
    return self.ghostCoords
end   

function DropClogAbility:GetIsPlacementValid()
    return self.placementValid
end

function DropClogAbility:GetIgnoreGhostHighlight()
    if self.activeStructure ~= nil and self:GetActiveStructure().GetIgnoreGhostHighlight then
        return self:GetActiveStructure():GetIgnoreGhostHighlight()
    end
    
    return false
    
end  

function DropClogAbility:GetGhostModelTechId()

    if self.activeStructure == nil then
        return nil
    else
        return self:GetActiveStructure():GetDropStructureId()
    end

end

function DropClogAbility:GetGhostModelName(player)

    if self.activeStructure ~= nil and self:GetActiveStructure().GetGhostModelName then
        return self:GetActiveStructure():GetGhostModelName(self)
    end
    
    return nil
    
end

if Client then

    function DropClogAbility:OnProcessIntermediate(input)

        local player = self:GetParent()
        local viewDirection = player:GetViewCoords().zAxis

        if player and self.activeStructure then

            self.ghostCoords, self.placementValid = self:GetPositionForStructure(player:GetEyePos(), viewDirection, self:GetActiveStructure(), self.lastClickedPosition)
            
            if player:GetResources() < LookupTechData(self:GetActiveStructure():GetDropStructureId(), kTechDataCostKey) then
                self.placementValid = false
            end
        
        end
        
    end
    

    function DropClogAbility:OnDestroy()
         
        Ability.OnDestroy(self)
        
    end
    
    function DropClogAbility:OnKillClient()
        self.menuActive = false
    end
    
    function DropClogAbility:OnDrawClient()
    
        Ability.OnDrawClient(self)
        
        // We need this here in case we switch to it via Prev/NextWeapon keys
        
        // Do not show menu for other players or local spectators.
        local player = self:GetParent()
        if player:GetIsLocalPlayer() and self:GetActiveStructure() == nil and Client.GetIsControllingPlayer() then
            self.menuActive = true
        end
        
    end
   

    function DropClogAbility:OnHolsterClient()
    
        self.menuActive = false
        Ability.OnHolsterClient(self)
        
    end
    
    function DropClogAbility:OnSetActive()
    end
    
    
end

Shared.LinkClassToMap("DropClogAbility", DropClogAbility.kMapName, networkVars)
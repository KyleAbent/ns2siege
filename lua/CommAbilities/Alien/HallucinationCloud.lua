// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CommAbilities\Alien\HallucinationCloud.lua
//
//      Created by: Andreas Urwalek (andi@unknownworlds.com)
//
//      Creates a hallucination of every affected alien.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'HallucinationCloud' (CommanderAbility)

HallucinationCloud.kMapName = "hallucinationcloud"

HallucinationCloud.kSplashEffect = PrecacheAsset("cinematics/alien/hallucinationcloud.cinematic")
HallucinationCloud.kType = CommanderAbility.kType.Instant

HallucinationCloud.kRadius = 8

local gTechIdToHallucinateTechId = nil
function GetHallucinationTechId(techId)

    if not gTechIdToHallucinateTechId then
    
        gTechIdToHallucinateTechId = {}
        gTechIdToHallucinateTechId[kTechId.Drifter] = kTechId.HallucinateDrifter
        gTechIdToHallucinateTechId[kTechId.Skulk] = kTechId.HallucinateSkulk
        gTechIdToHallucinateTechId[kTechId.Gorge] = kTechId.HallucinateGorge
        gTechIdToHallucinateTechId[kTechId.Lerk] = kTechId.HallucinateLerk
        gTechIdToHallucinateTechId[kTechId.Fade] = kTechId.HallucinateFade
        gTechIdToHallucinateTechId[kTechId.Onos] = kTechId.HallucinateOnos
        
        gTechIdToHallucinateTechId[kTechId.Hive] = kTechId.HallucinateHive
        gTechIdToHallucinateTechId[kTechId.Whip] = kTechId.HallucinateWhip
        gTechIdToHallucinateTechId[kTechId.Shade] = kTechId.HallucinateShade
        gTechIdToHallucinateTechId[kTechId.Crag] = kTechId.HallucinateCrag
        gTechIdToHallucinateTechId[kTechId.Shift] = kTechId.HallucinateShift
        gTechIdToHallucinateTechId[kTechId.Harvester] = kTechId.HallucinateHarvester
        gTechIdToHallucinateTechId[kTechId.Hydra] = kTechId.HallucinateHydra
    
    end
    
    return gTechIdToHallucinateTechId[techId]

end

local networkVars = { }

function HallucinationCloud:OnInitialized()
    
    if Server then
        // sound feedback
        self:TriggerEffects("enzyme_cloud")    
    end
    
    CommanderAbility.OnInitialized(self)

end

function HallucinationCloud:GetStartCinematic()
    return HallucinationCloud.kSplashEffect
end

function HallucinationCloud:GetType()
    return HallucinationCloud.kType
end

local function AllowedToHallucinate(entity)

    local allowed = true
    if entity.timeLastHallucinated and entity.timeLastHallucinated + kHallucinationCloudCooldown > Shared.GetTime() then
        allowed = false
    else
        entity.timeLastHallucinated = Shared.GetTime()
    end    
    
    return allowed

end

if Server then

    function HallucinationCloud:Perform()
        
        // kill all hallucinations before, to prevent unreasonable spam
        for _, hallucination in ipairs(GetEntitiesForTeam("Hallucination", self:GetTeamNumber())) do
            hallucination.consumed = true
            hallucination:Kill()
        end
        
        for _, playerHallucination in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do
        
            if playerHallucination.isHallucination then
                playerHallucination:TriggerEffects("death_hallucination")
                DestroyEntity(playerHallucination)
            end
        
        end
        
        local drifter = GetEntitiesForTeamWithinRange("Drifter", self:GetTeamNumber(), self:GetOrigin(), HallucinationCloud.kRadius)[1]
        if drifter then
        
            if AllowedToHallucinate(drifter) then
        
                local angles = drifter:GetAngles()
                angles.pitch = 0
                angles.roll = 0
                local origin = GetGroundAt(self, drifter:GetOrigin() + Vector(0, .1, 0), PhysicsMask.Movement, EntityFilterOne(drifter))
                
                local hallucination = CreateEntity(Hallucination.kMapName, origin, self:GetTeamNumber())
                hallucination:SetEmulation(GetHallucinationTechId(kTechId.Drifter))
                hallucination:SetAngles(angles)
                
                local randomDestinations = GetRandomPointsWithinRadius(drifter:GetOrigin(), 4, 10, 10, 1, 1, nil, nil)
                if randomDestinations[1] then            
                    hallucination:GiveOrder(kTechId.Move, nil, randomDestinations[1], nil, true, true)            
                end
            
            end
            
        end
        
        // search for alien in range, cloak them and create a hallucination
        local hallucinatePlayers = {}
        local numHallucinatePlayers = 0
        for _, alien in ipairs(GetEntitiesForTeamWithinRange("Alien", self:GetTeamNumber(), self:GetOrigin(), HallucinationCloud.kRadius)) do
        
            if alien:GetIsAlive() and not alien:isa("Embryo") and not HasMixin(alien, "PlayerHallucination") then
            
                table.insert(hallucinatePlayers, alien)
                numHallucinatePlayers = numHallucinatePlayers + 1
            
            end
            
        end
        
        // sort by techId, so the higher life forms are prefered
        local function SortByTechId(alienOne, alienTwo)
            return alienOne:GetTechId() > alienTwo:GetTechId()
        end
        
        table.sort(hallucinatePlayers, SortByTechId)
        
        // limit max num of hallucinations to 1/3 of team size
        local teamSize = self:GetTeam():GetNumPlayers()
        local maxAllowedHallucinations = math.max(1, math.floor(teamSize * kPlayerHallucinationNumFraction))
        local hallucinationsCreated = 0

        for index, alien in ipairs(hallucinatePlayers) do
        
            if AllowedToHallucinate(alien) then
            
                local newAlienExtents = LookupTechData(alien:GetTechId(), kTechDataMaxExtents)
                local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(newAlienExtents) 
                
                local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, alien:GetModelOrigin(), 0.5, 5)
                
                if spawnPoint then

                    local hallucinatedPlayer = CreateEntity(alien:GetMapName(), spawnPoint, self:GetTeamNumber())
                    if alien:isa("Alien") then
                        hallucinatedPlayer:SetVariant(alien:GetVariant())
                    end
                    hallucinatedPlayer.isHallucination = true
                    InitMixin(hallucinatedPlayer, PlayerHallucinationMixin)                
                    InitMixin(hallucinatedPlayer, SoftTargetMixin)                
                    InitMixin(hallucinatedPlayer, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance }) 

                    hallucinatedPlayer:SetName(alien:GetName())
                    hallucinatedPlayer:SetHallucinatedClientIndex(alien:GetClientIndex())
                
                    hallucinationsCreated = hallucinationsCreated + 1
                
                end 
            
            end
            
            if hallucinationsCreated >= maxAllowedHallucinations then
                break
            end    
        
        end
        
        for _, resourcePoint in ipairs(GetEntitiesWithinRange("ResourcePoint", self:GetOrigin(), HallucinationCloud.kRadius)) do
        
            if resourcePoint:GetAttached() == nil and GetIsPointOnInfestation(resourcePoint:GetOrigin()) then
            
                local hallucination = CreateEntity(Hallucination.kMapName, resourcePoint:GetOrigin(), self:GetTeamNumber())
                hallucination:SetEmulation(kTechId.HallucinateHarvester)
                hallucination:SetAttached(resourcePoint)
                
            end
        
        end
        
        for _, techPoint in ipairs(GetEntitiesWithinRange("TechPoint", self:GetOrigin(), HallucinationCloud.kRadius)) do
        
            if techPoint:GetAttached() == nil then
            
                local coords = techPoint:GetCoords()
                coords.origin = coords.origin + Vector(0, 2.494, 0)
                local hallucination = CreateEntity(Hallucination.kMapName, techPoint:GetOrigin(), self:GetTeamNumber())
                hallucination:SetEmulation(kTechId.HallucinateHive)
                hallucination:SetAttached(techPoint)
                hallucination:SetCoords(coords)
                
            end
        
        end

    end

end

Shared.LinkClassToMap("HallucinationCloud", HallucinationCloud.kMapName, networkVars)
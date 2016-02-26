//----------------------------------------
//  Collection of useful, bot-specific utility functions
//----------------------------------------

//----------------------------------------
//  
//----------------------------------------
function GetBestAimPoint( target )

    if target.GetEngagementPoint then

        return target:GetEngagementPoint()

    elseif HasMixin( target, "Model" ) then

        local min, max = target:GetModelExtents()
        local o = target:GetOrigin()
        return (min+max)*0.5 + o - Vector(0, 0.2, 0)

    else

        return target:GetOrigin()

    end

end

//----------------------------------------
//  
//----------------------------------------
function GetDistanceToTouch( from, target )

    local entSize = 0

    if HasMixin(target, "Extents") then
        entSize = target:GetExtents():GetLengthXZ()
    end

    local targetPos = target:GetOrigin()

    if HasMixin( target, "Target" ) then
        targetPos = target:GetEngagementPoint()
    end
    
    return math.max( 0.0, targetPos:GetDistance(from) - entSize )

end

//----------------------------------------
//  
//----------------------------------------
function GetNearestFiltered(from, ents, isValidFunc)

    local bestDist = nil
    local bestEnt = nil

    for i,ent in ipairs(ents) do

        if isValidFunc == nil or isValidFunc(ent) then

            local dist = GetDistanceToTouch( from, ent )
            if bestDist == nil or dist < bestDist then
                bestDist = dist
                bestEnt = ent
            end

        end

    end

    return bestDist, bestEnt

end

//----------------------------------------
//  
//----------------------------------------
function GetMaxEnt(ents, valueFunc)

    local maxEnt = nil
    local maxValue = nil
    for i, ent in ipairs(ents) do
        local value = valueFunc(ent)
        if maxValue == nil or value > maxValue then
            maxEnt = ent
            maxValue = value
        end
    end

    return maxValue, maxEnt
end

//----------------------------------------
//  
//----------------------------------------
function FilterTableEntries(ents, filterFunc)

    result = {}
    for key, entry in pairs(ents) do
        if filterFunc(entry) then
            table.insert(result, entry)
        end
    end
    
    return result
    
end

//----------------------------------------
//  
//----------------------------------------
function GetMaxTableEntry(table, valueFunc)

    local maxEntry = nil
    local maxValue = nil
    for key, entry in pairs(table) do
        local value = valueFunc(entry)
        if value == nil then
            // skip this
        elseif maxValue == nil or value > maxValue then
            maxEntry = entry
            maxValue = value
        end
    end

    return maxValue, maxEntry
end

function GetMinTableEntry(table, valueFunc)

    local minEntry = nil
    local minValue = nil
    for key, entry in pairs(table) do
        local value = valueFunc(entry)
        if value == nil then
            // skip this
        elseif minValue == nil or value < minValue then
            minEntry = entry
            minValue = value
        end
    end

    return minValue, minEntry
end

//----------------------------------------
//  
//----------------------------------------
function GetMinDistToEntities( fromEnt, toEnts )

    local minDist = nil
    local fromPos = fromEnt:GetOrigin()

    for _,toEnt in ipairs(toEnts) do

        local dist = toEnt:GetOrigin():GetDistance( fromPos )
        if minDist == nil or dist < minDist then
            minDist = dist
        end

    end

    return minDist
    
end

//----------------------------------------
//  
//----------------------------------------
function FilterArray(ents, keepFunc)

    local out = {}
    for i,ent in ipairs(ents) do
        if keepFunc(ent) then
            table.insert(out, ent)
        end
    end
    return out

end

//----------------------------------------
//  
//----------------------------------------
function GetPotentialTargetEntities(player)
    
    local origin = player:GetOrigin()
    local range = 20
    local teamNumber = GetEnemyTeamNumber(player:GetTeamNumber())
    
    local function filterFunction(entity)    
        return HasMixin(entity, "Team") and HasMixin(entity, "LOS") and HasMixin(entity, "Live")  and 
               entity:GetTeamNumber() == teamNumber and entity:GetIsSighted() and entity:GetIsAlive()     
    end
    return Shared.GetEntitiesWithTagInRange("class:ScriptActor", origin, range, filterFunction)
    
end

//----------------------------------------
//  
//----------------------------------------
function GetTeamMemories(teamNum)

    local team = GetGamerules():GetTeam(teamNum)
    assert(team)
    assert(team.brain)
    return team.brain:GetMemories()

end

//----------------------------------------
//  
//----------------------------------------
function GetTeamBrain(teamNum)

    local team = GetGamerules():GetTeam(teamNum)
    assert(team)
    return team:GetTeamBrain()

end

//----------------------------------------
//  
//----------------------------------------
function GetTableSize(t)
    local c = 0
    for _,_ in pairs(t) do
        c = c + 1
    end
    return c
end

//----------------------------------------
//  This is expensive.
//  It would be nice to piggy back off of LOSMixin, but that is delayed and also does not remember WHO can see what.
//----------------------------------------
function GetBotCanSeeTarget(attacker, target)

    local p0 = attacker:GetEyePos()
    local p1 = target:GetEngagementPoint()

    local trace = Shared.TraceRay( p0, p1,
            CollisionRep.Damage, PhysicsMask.Bullets,
            EntityFilterTwo(attacker, attacker:GetActiveWeapon()) )
    return trace.entity == target

end

function IsAimingAt(attacker, target)

    local toTarget = GetNormalizedVector(target:GetEngagementPoint() - attacker:GetEyePos())
    return toTarget:DotProduct(attacker:GetViewCoords().zAxis) > 0.99

end

//----------------------------------------
//  
//----------------------------------------
function FilterTable( dict, keepFunc )
    local out = {}
    for key,val in pairs(dict) do
        if keepFunc(val) then
            table.insert(out, val)
        end
    end
    return out
end

//----------------------------------------
//  
//----------------------------------------
function GetNumEntitiesOfType( className, teamNumber )
    local ents = GetEntitiesForTeam( className, teamNumber )
    return #ents
end

//----------------------------------------
//  
//----------------------------------------
function GetAvailableTechPoints()

    local tps = {}
    for _,tp in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do

        if not tp:GetAttached() then
            table.insert( tps, tp )
        end

    end

    return tps

end

function GetAvailableResourcePoints()

    local rps = {}
    for _,rp in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do

        if not rp:GetAttached() then
            table.insert( rps, rp )
        end

    end

    return rps

end

function GetServerContainsBots()

    local hasBots = false
    local players = Shared.GetEntitiesWithClassname("Player")
    for p = 0, players:GetSize() - 1 do
    
        local ownerClient = Server.GetOwner(players:GetEntityAtIndex(p))
        if ownerClient and ownerClient:GetIsVirtual() then
        
            hasBots = true
            break
            
        end
        
    end
    
    return hasBots
    
end
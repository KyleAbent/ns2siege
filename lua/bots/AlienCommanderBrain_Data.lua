Script.Load("lua/bots/CommonActions.lua")
Script.Load("lua/bots/BrainSenses.lua")

local kHiveBuildDist = 15.0

local function CreateBuildNearHiveAction( techId, className, numToBuild, weightIfNotEnough )

    return CreateBuildStructureAction(
            techId, className,
            {
            {-1.0, weightIfNotEnough},
            {numToBuild-1, weightIfNotEnough},
            {numToBuild, 0.0}
            },
            "Hive",
            kHiveBuildDist )
end

kAlienComBrainActions =
{
    -- By randomizing weights, each bot has its own "personality"
    CreateUpgradeStructureAction( kTechId.UpgradeToCragHive        , 5.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.UpgradeToShiftHive       , 5.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.UpgradeToShadeHive       , 5.0+math.random() ) ,

    CreateUpgradeStructureAction( kTechId.BileBomb       , 3.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Leap       , 3.0+math.random() ) ,

    CreateUpgradeStructureAction( kTechId.MetabolizeHealth       , 2.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Umbra       , 2.0+math.random() ) ,

    CreateUpgradeStructureAction( kTechId.MetabolizeHealth       , 1.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Stomp       , 1.0+math.random() ) ,

    CreateUpgradeStructureAction( kTechId.Xenocide       , 1.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Spores       , 1.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.BoneShield       , 1.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Stab       , 1.0+math.random() ) ,

    CreateUpgradeStructureAction( kTechId.WebTech       , 0.5+math.random() ) ,



    function(bot, brain)

        local function startUpgradeBuilding()
            -- Trait-giving structures
            table.insert( kAlienComBrainActions, CreateBuildNearHiveAction( kTechId.Veil  , "Veil"  , 2 , 7.0 + math.random() ) )
            table.insert( kAlienComBrainActions, CreateBuildNearHiveAction( kTechId.Shell , "Shell" , 2 , 7.0 + math.random() ) )
            table.insert( kAlienComBrainActions, CreateBuildNearHiveAction( kTechId.Spur  , "Spur"  , 2 , 7.0 + math.random() ) )

            table.insert( kAlienComBrainActions, CreateBuildNearHiveAction( kTechId.Veil  , "Veil"  , 3 , 2.0 + math.random()))
            table.insert( kAlienComBrainActions, CreateBuildNearHiveAction( kTechId.Shell  , "Shell"  , 3 , 2.0 + math.random() ) )
            table.insert( kAlienComBrainActions, CreateBuildNearHiveAction( kTechId.Spur  , "Spur"  , 3 , 2.0 + math.random() ) )
        end

        local name = "harvester"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local targetRP

        if doables[kTechId.Harvester] then

            targetRP = sdb:Get("resPointToTake")

            if targetRP then
                weight = EvalLPF( sdb:Get("numHarvesters"),
                    {
                        {0, 10},
                        {1, 8},
                        {2, 6},
                        {3, 4}
                    })
            end

        end

        return { name = name, weight = weight,
            perform = function(move)
                if targetRP then
                    local success = brain:ExecuteTechId( com, kTechId.Harvester, targetRP:GetOrigin(), com )
                    if success then
                        if not brain.firstHarvesterBuild then
                            startUpgradeBuilding()
                            brain.firstHarvesterBuild = true
                        end
                    end
                end
            end}
    end,

    function(bot, brain)

        local name = "cyst"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0.0
        local rb = sdb:Get("resPointToInfest")
        local position = rb and rb:GetOrigin()

        -- there is a res point ready to take, so do not build any more cysts to conserve TRes
        if not sdb:Get("resPointToTake") and position and #GetEntitiesForTeamWithinRange("Cyst", com:GetTeamNumber(), position, 4) == 0 then
            weight = 9
        end

        return { name = name, weight = weight,
            perform = function(move)

                local extents = GetExtents(kTechId.Cyst)
                local cystPos = GetRandomSpawnForCapsule(extents.y, extents.x, position + Vector(0,1,0), 1, 4, EntityFilterAll(), GetIsPointOffInfestation)

                if cystPos then
                    brain:ExecuteTechId( com, kTechId.Cyst, cystPos, com )
                end
            end }

    end,

    -- Trait upgrades
    CreateUpgradeStructureAction( kTechId.ResearchBioMassOne , 3.0, kTechId.BioMassFive) ,
    CreateUpgradeStructureAction( kTechId.ResearchBioMassTwo , 3.0, kTechId.BioMassFive ) ,

    function(bot, brain)

        return { name = "idle", weight = 0.01,
            perform = function(move)
                if brain.debug then
                    DebugPrint("idling..")
                end
            end}
    end,

    function (bot, brain)
        local name ="eggs"
        local com = bot:GetPlayer()
        local team = com:GetTeam()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0

        if team:GetEggCount() == 0 then
            weight = 11.0
        end

        return { name = name, weight = weight,
            perform = function(move)
                if doables[kTechId.ShiftHatch] then
                    brain:ExecuteTechId( com, kTechId.ShiftHatch, Vector(1,0,0), sdb:Get("hives")[1] )
                end
            end}
        end,

    function(bot, brain)
        local name = "drifters"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local drifters = sdb:Get("drifters")

        if sdb:Get("numDrifters") < sdb:Get("numHives") then
            weight = 10
        end

        local function IsBeingGrown(self, target)

            if target.hasDrifterEnzyme then
                return true
            end

            for _, drifter in ipairs(drifters) do

                if self ~= drifter then

                    local order = drifter:GetCurrentOrder()
                    if order and order:GetType() == kTechId.Grow then

                        local growTarget = Shared.GetEntity(order:GetParam())
                        if growTarget == target then
                            return true
                        end

                    end

                end

            end

            return false

        end

        for _, drifter in ipairs(sdb:Get("drifters")) do
            if not drifter:GetHasOrder() then
               -- find ungrown structures
               for _, structure in ipairs(GetEntitiesWithMixinForTeam("Construct", drifter:GetTeamNumber() )) do

                   if not structure:GetIsBuilt() and not IsBeingGrown(drifter, structure) and
                           (not structure.GetCanAutoBuild or structure:GetCanAutoBuild()) then

                       drifter:GiveOrder(kTechId.Grow, structure:GetId(), structure:GetOrigin(), nil, false, false)

                   end
               end
           end
        end

        return { name = name, weight = weight,
            perform = function(move)
                if doables[kTechId.DrifterEgg] then
                    local position = GetRandomBuildPosition(
                        kTechId.DrifterEgg, com:GetTeam():GetInitialTechPoint():GetOrigin(), 10
                    )
                    if position then
                        brain:ExecuteTechId( com, kTechId.DrifterEgg, GetRandomBuildPosition(
                            kTechId.DrifterEgg, com:GetTeam():GetInitialTechPoint():GetOrigin(), 10
                        ), com )
                    end
                else
                    -- we cannot build a drifter yet - wait for res to build up
                end
            end}
    end,

    function(bot, brain)

        local name = "hive"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local targetTP

        if sdb:Get("numHarvesters") >= sdb:Get("numHarvsForHive") 
            or sdb:Get("overdueForHive") or com:GetTeam():GetTeamResources() >= 90 then

            -- Find a hive slot!
            targetTP = sdb:Get("techPointToTake")

            if targetTP then
                weight = 7
            end
        end

        return { name = name, weight = weight,
            perform = function(move)
                if doables[kTechId.Hive] and targetTP then
                    local sucess = brain:ExecuteTechId( com, kTechId.Hive, targetTP:GetOrigin(), com )

                    if sucess then
                        --lets tell the team to protect it
                        CreatePheromone(kTechId.ThreatMarker, targetTP:GetOrigin(), com:GetTeamNumber())

                        if not brain.firstHiveBuild then
                            table.insert(kAlienComBrainActions, CreateUpgradeStructureAction( kTechId.Charge       , 1.0+math.random() ))
                            brain.firstHiveBuild = true
                        elseif sdb:Get("numHives") and not brain.thirdHiveBuild then
                            table.insert(kAlienComBrainActions, CreateBuildNearHiveAction( kTechId.Crag  , "Crag"  , 2 , 0.2 ))
                            table.insert(kAlienComBrainActions, CreateBuildNearHiveAction( kTechId.Shade , "Shade" , 2 , 0.2 ))
                            table.insert(kAlienComBrainActions, CreateBuildNearHiveAction( kTechId.Whip  , "Whip"  , 6 , 0.1 ))
                            brain.thirdHiveBuild = true
                        end
                    end
                else
                    -- we cannot build a hive yet - wait for res to build up
                end
            end}
    end
}

------------------------------------------
--  Build the senses database
------------------------------------------

function CreateAlienComSenses()

    local s = BrainSenses()
    s:Initialize()

    s:Add("gameMinutes", function(db)
            return (Shared.GetTime() - GetGamerules():GetGameStartTime()) / 60.0
            end)

    s:Add("doableTechIds", function(db)
            return db.bot.brain:GetDoableTechIds( db.bot:GetPlayer() )
            end)

    s:Add("hives", function(db)
            return GetEntitiesForTeam("Hive", kAlienTeamType)
            end)

    s:Add("cysts", function(db)
            return GetEntitiesForTeam("Cyst", kAlienTeamType)
            end)

    s:Add("drifters", function(db)
        return GetEntitiesForTeam("Drifter", kAlienTeamType)
    end)

    s:Add("numHarvesters", function(db)
            return GetNumEntitiesOfType("Harvester", kAlienTeamType)
            end)

    s:Add("numHarvsForHive", function(db)

            if db:Get("numHives") == 1 then
                return 3
            elseif db:Get("numHives") == 2 then
                return 5
            else
                return 8
            end
            
            return 0

            end)

    s:Add("overdueForHive", function(db)

            if db:Get("numHives") == 1 then
                return db:Get("gameMinutes") > 7
            elseif db:Get("numHives") == 2 then
                return db:Get("gameMinutes") > 14
            else
                return false
            end

            end)

    s:Add("numHives", function(db)
            return GetNumEntitiesOfType("Hive", kAlienTeamType)
            end)
    s:Add("numDrifters", function(db)
        return GetNumEntitiesOfType( "Drifter", kAlienTeamType ) + GetNumEntitiesOfType( "DrifterEgg", kAlienTeamType )
        end)

    s:Add("techPointToTake", function(db)
        local tps = GetAvailableTechPoints()
            local hives = db:Get("cysts")
            local dist, tp = GetMinTableEntry( tps, function(tp)
                return GetMinDistToEntities( tp, hives )
                end)
            return tp
            end)

    -- RPs that are not taken, not necessarily good or on infestation
    s:Add("availResPoints", function(db)
            return GetAvailableResourcePoints()
            end)

    s:Add("resPointToTake", function(db)
            local rps = db:Get("availResPoints")
            local hives = db:Get("hives")
            local dist, rp = GetMinTableEntry( rps, function(rp)
                -- Check infestation
                if GetIsPointOnInfestation(rp:GetOrigin()) then
                    return GetMinDistToEntities( rp, hives )
                end
                return nil
                end)
            return rp
            end)

    s:Add("resPointToInfest", function(db)
            local rps = db:Get("availResPoints")
            local hives = db:Get("hives")
            local dist, rp = GetMinTableEntry( rps, function(rp)
                -- Check infestation
                if not GetIsPointOnInfestation(rp:GetOrigin()) then
                    return GetMinDistToEntities( rp, hives )
                end
                return nil
                end)
            return rp
            end)

    return s
end

------------------------------------------
--  
------------------------------------------



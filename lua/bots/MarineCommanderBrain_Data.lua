Script.Load("lua/bots/CommonActions.lua")
Script.Load("lua/bots/BrainSenses.lua")

local kStationBuildDist = 15.0

local function CreateBuildNearStationAction( techId, className, numToBuild, weightIfNotEnough )

    return CreateBuildStructureAction(
            techId, className,
            {
            {-1.0, weightIfNotEnough},
            {numToBuild-1, weightIfNotEnough},
            {numToBuild, 0.0}
            },
            "CommandStation",
            kStationBuildDist )
end

kMarineComBrainActions =
{
    CreateBuildNearStationAction( kTechId.Armory         , "Armory"         , 1 , 4 ),
    CreateBuildNearStationAction( kTechId.Observatory    , "Observatory"    , 1 , 3+math.random() ) ,
    --CreateBuildNearStationAction( kTechId.PhaseGate      , "PhaseGate"      , 2 , 1+math.random() ) ,
    CreateBuildNearStationAction( kTechId.ArmsLab        , "ArmsLab"        , 1 , 3+math.random() ) ,
    CreateBuildNearStationAction( kTechId.PrototypeLab   , "PrototypeLab"   , 1 , 2+math.random() ) ,

    -- Upgrades from structures
    CreateUpgradeStructureAction( kTechId.ShotgunTech           , 2.0 ) ,
    CreateUpgradeStructureAction( kTechId.JetpackTech           , 1.5+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.ExosuitTech           , 1.5+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.MinesTech             , 1.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.AdvancedArmoryUpgrade , 1.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.ExosuitUpgradeTech             , 1.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.GrenadeTech             , 1.0+math.random() ) ,

    --CreateUpgradeStructureAction( kTechId.PhaseTech , 2.0+math.random() ),

    CreateUpgradeStructureAction( kTechId.Weapons1 , 3.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Weapons2 , 2.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Weapons3 , 1.0+math.random() ) , 
    CreateUpgradeStructureAction( kTechId.Armor1   , 3.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Armor2   , 2.0+math.random() ) ,
    CreateUpgradeStructureAction( kTechId.Armor3   , 1.0+math.random() ) ,

    function(bot, brain)

        local weight = 0
        local team = bot:GetPlayer():GetTeam()
        local numDead = team:GetNumPlayersInQueue()
        if numDead > 1 then
            weight = 5.0
        end

        return CreateBuildNearStationAction( kTechId.InfantryPortal , "InfantryPortal" , 3 , weight )(bot, brain)
    end,

    function(bot, brain)

        local name = "extractor"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local targetRP

        if doables[kTechId.Extractor] and (not bot.nextRTDrop or bot.nextRTDrop < Shared.GetTime()) then

            targetRP = sdb:Get("resPointToTake")

            if targetRP ~= nil then
                weight = EvalLPF( sdb:Get("numExtractors"),
                    {
                        {0, 10.0},
                        {1, 5.0},
                        {2, 3.0},
                        {3, 1.0},
                        })

            end
        end

        return { name = name, weight = weight,
            perform = function(move)
                if targetRP ~= nil then
                    local success = brain:ExecuteTechId( com, kTechId.Extractor, targetRP:GetOrigin(), com )
                    if success then
                        bot.nextRTDrop =  Shared.GetTime() + 5
                    end
                end
            end}
    end,

    function(bot, brain)

        return { name = "idle", weight = 1e-5,
            perform = function(move)
                if brain.debug then
                    DebugPrint("idling..")
                end 
            end}
    end
}

------------------------------------------
--  Build the senses database
------------------------------------------

function CreateMarineComSenses()

    local s = BrainSenses()
    s:Initialize()

    s:Add("gameMinutes", function(db)
            return (Shared.GetTime() - GetGamerules():GetGameStartTime()) / 60.0
            end)

    s:Add("doableTechIds", function(db)
            return db.bot.brain:GetDoableTechIds( db.bot:GetPlayer() )
            end)

    s:Add("stations", function(db)
            return GetEntitiesForTeam("CommandStation", kMarineTeamType)
            end)

    s:Add("availResPoints", function(db)
            return GetAvailableResourcePoints()
            end)

    s:Add("numExtractors", function(db)
            return GetNumEntitiesOfType("ResourceTower", kMarineTeamType)
            end)

    s:Add("numInfantryPortals", function(db)
        return GetNumEntitiesOfType("InfantryPortal", kMarineTeamType)
    end)

    s:Add("resPointToTake", function(db)
            local rps = db:Get("availResPoints")
            local stations = db:Get("stations")
            local dist, rp = GetMinTableEntry( rps, function(rp)
                return GetMinDistToEntities( rp, stations )
                end)
            return rp
            end)

    return s

end

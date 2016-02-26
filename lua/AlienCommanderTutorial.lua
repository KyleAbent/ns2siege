// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AlienCommanderTutorial.lua
//
// Created by: Andreas Urwalek (and@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommanderTutorialUtility.lua")

local Resolve = Locale.ResolveString

local buildCystString = Resolve("COMMANDER_TUT_BUILD_CYST")
buildCystSteps = 
{
    { CompletionFunc = GetHasMenuSelected(kTechId.BuildMenu), HighlightButton = kTechId.BuildMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Cyst), HighlightButton = kTechId.Cyst, HighlightWorld = GetPointBetween(GetCommandStructureOrigin, GetClosestFreeResourcePoint) },
}
AddCommanderTutorialEntry(0, kAlienTeamType, buildCystString, buildCystSteps)


local infestNode = Resolve("COMMANDER_TUT_INFEST_NODE")
buildHarvesterSteps = 
{
    { CompletionFunc = GetHasPointInfested(GetClosestFreeResourcePoint), HighlightButton = kTechId.Cyst, HighlightWorld = GetClosestFreeResourcePoint },
    { CompletionFunc = GetHasTechUsed(kTechId.Harvester), HighlightButton = kTechId.Harvester, HighlightWorld = GetClosestFreeResourcePoint },
}
AddCommanderTutorialEntry(kHarvesterCost, kAlienTeamType, infestNode, buildHarvesterSteps)


local drifterConstruct = Resolve("COMMANDER_TUT_CONSTRUCT_DRIFTER")
drifterConstructSteps = 
{
    { CompletionFunc = GetHasTechUsed(kTechId.DrifterEgg), HighlightButton = kTechId.DrifterEgg, HighlightWorld = GetClosestUnbuiltStructurePosition() },
}
AddCommanderTutorialEntry(kDrifterCost, kAlienTeamType, drifterConstruct, drifterConstructSteps)


local upgradeHive = Resolve("COMMANDER_TUT_UPGRADE_HIVE")
hiveUpgradeSteps =
{
    { CompletionFunc = GetHasUnitSelected(kTechId.Hive), HighlightWorld = GetCommandStructureOrigin },
    { CompletionFunc = GetHasTechUsed({kTechId.UpgradeToCragHive, kTechId.UpgradeToShiftHive, kTechId.UpgradeToShadeHive}), HighlightButton = {kTechId.UpgradeToCragHive, kTechId.UpgradeToShiftHive, kTechId.UpgradeToShadeHive} },
}
AddCommanderTutorialEntry(kUpgradeHiveCost, kAlienTeamType, upgradeHive, hiveUpgradeSteps, nil, GetHasUnit(kTechId.Hive), nil, "BUILD_CHAMBER")


local buildShell = Resolve("COMMANDER_TUT_BUILD_SHELL")
local buildShellSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Shell), HighlightButton = kTechId.Shell, HighlightWorld = GetAnchorPoint },
}
AddCommanderTutorialEntry(kShellCost, kAlienTeamType, buildShell, buildShellSteps, GetPlaceForUnit(kTechId.Shell, GetCommandStructureOrigin, GetIsPointOnInfestation), GetHasUnit(kTechId.CragHive), "BUILD_CHAMBER")


local buildVeil = Resolve("COMMANDER_TUT_BUILD_VEIL")
local buildVeilSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Veil), HighlightButton = kTechId.Veil, HighlightWorld = GetAnchorPoint },
}
AddCommanderTutorialEntry(kVeilCost, kAlienTeamType, buildVeil, buildVeilSteps, GetPlaceForUnit(kTechId.Veil, GetCommandStructureOrigin, GetIsPointOnInfestation), GetHasUnit(kTechId.ShadeHive), "BUILD_CHAMBER")


local buildSpur = Resolve("COMMANDER_TUT_BUILD_SPUR")
local buildSpurSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Spur), HighlightButton = kTechId.Spur, HighlightWorld = GetAnchorPoint },
}
AddCommanderTutorialEntry(kSpurCost, kAlienTeamType, buildSpur, buildSpurSteps, GetPlaceForUnit(kTechId.Spur, GetCommandStructureOrigin, GetIsPointOnInfestation), GetHasUnit(kTechId.ShiftHive), "BUILD_CHAMBER")


local buildSecondShell = Resolve("COMMANDER_TUT_BUILD_SECOND_SHELL")
local buildSecondShellSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Shell), HighlightButton = kTechId.Shell, HighlightWorld = GetAnchorPoint }
}
AddCommanderTutorialEntry(kShellCost, kAlienTeamType, buildSecondShell, buildSecondShellSteps, GetPlaceForUnit(kTechId.Shell, GetCommandStructureOrigin, GetIsPointOnInfestation), TutorialAlienChamberBuildSecond(kTechId.CragHive, kTechId.TwoShells))


local buildSecondSpur = Resolve("COMMANDER_TUT_BUILD_SECOND_SPUR")
local buildSecondSpurSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Spur), HighlightButton = kTechId.Spur, HighlightWorld = GetAnchorPoint }
}
AddCommanderTutorialEntry(kSpurCost, kAlienTeamType, buildSecondSpur, buildSecondSpurSteps, GetPlaceForUnit(kTechId.Spur, GetCommandStructureOrigin, GetIsPointOnInfestation), TutorialAlienChamberBuildSecond(kTechId.ShiftHive, kTechId.TwoSpurs))


local buildSecondVeil = Resolve("COMMANDER_TUT_BUILD_SECOND_VEIL")
local buildSecondVeilSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Veil), HighlightButton = kTechId.Veil, HighlightWorld = GetAnchorPoint }
}
AddCommanderTutorialEntry(kVeilCost, kAlienTeamType, buildSecondVeil, buildSecondVeilSteps, GetPlaceForUnit(kTechId.Veil, GetCommandStructureOrigin, GetIsPointOnInfestation), TutorialAlienChamberBuildSecond(kTechId.ShadeHive, kTechId.TwoVeils))


local viewTechMap = Resolve("COMMANDER_TUT_VIEW_TECH")
local viewTechMapSteps =
{
    { CompletionFunc = PlayerUI_GetIsTechMapVisible }
}
AddCommanderTutorialEntry(0, kAlienTeamType, viewTechMap, viewTechMapSteps)


local selectDrifter = Resolve("COMMANDER_TUT_SELECT_DRIFTER")
local selectDrifterSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AssistMenu), HighlightButton = kTechId.AssistMenu },
    { CompletionFunc = GetHasUnitSelected(kTechId.Drifter), HighlightButton = kTechId.SelectDrifter },
}
AddCommanderTutorialEntry(0, kAlienTeamType, selectDrifter, selectDrifterSteps, nil, GetHasUnit(kTechId.Drifter))


local orderDrifter = Resolve("COMMANDER_TUT_ORDER_DRIFTER")
local orderDrifterSteps =
{
    { CompletionFunc = GetSelectionHasOrder(kTechId.Move), HighlightButton = kTechId.Move },
    { CompletionFunc = GetHasTechUsed({kTechId.EnzymeCloud, kTechId.Hallucinate, kTechId.MucousMembrane}), HighlightButton = {kTechId.EnzymeCloud, kTechId.Hallucinate, kTechId.MucousMembrane} },
}
AddCommanderTutorialEntry(0, kAlienTeamType, orderDrifter, orderDrifterSteps, nil, GetHasUnitSelected(kTechId.Drifter))

local upgradeBioMass = Resolve("COMMANDER_TUT_UPGRADE_BIOMASS")
local upgradeBioMassSteps =
{
    { CompletionFunc = GetHasClassSelected("Hive"), HighlightWorld = GetCommandStructureOrigin },
    { CompletionFunc = GetHasTechUsed({kTechId.ResearchBioMassOne, kTechId.ResearchBioMassTwo}), HighlightButton = {kTechId.ResearchBioMassOne, kTechId.ResearchBioMassTwo} }
}
AddCommanderTutorialEntry(kResearchBioMassOneCost, kAlienTeamType, upgradeBioMass, upgradeBioMassSteps)

local upgradeBioMassTwo = Resolve("COMMANDER_TUT_UPGRADE_BIOMASS_TWO")
local upgradeBioMassTwoSteps =
{
    { CompletionFunc = GetHasClassSelected("Hive"), HighlightWorld = GetCommandStructureOrigin },
    { CompletionFunc = GetHasTechUsed(kTechId.ResearchBioMassTwo), HighlightButton = kTechId.ResearchBioMassTwo }
}
AddCommanderTutorialEntry(kResearchBioMassTwoCost, kAlienTeamType, upgradeBioMassTwo, upgradeBioMassTwoSteps)

local upgradeGorge = Resolve("COMMANDER_TUT_UPGRADE_GORGE")
local upgradeGorgeSteps =
{
    { CompletionFunc = GetHasClassSelected("Hive"), HighlightWorld = GetCommandStructureOrigin },
    { CompletionFunc = GetHasClassSelected("EvolutionChamber"), HighlightButton = kTechId.LifeFormMenu },
    { CompletionFunc = GetHasMenuSelected(kTechId.GorgeMenu), HighlightButton = kTechId.GorgeMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.BileBomb), HighlightButton = kTechId.BileBomb },
}
AddCommanderTutorialEntry(kUpgradeGorgeResearchCost, kAlienTeamType, upgradeGorge, upgradeGorgeSteps)


local buildHive = Resolve("COMMANDER_TUT_BUILD_HIVE")
local buildHiveSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.BuildMenu), HighlightButton = kTechId.BuildMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Hive), HighlightButton = kTechId.Hive, HighlightWorld = GetClosestFreeTechPoint }
}
AddCommanderTutorialEntry(kHiveCost, kAlienTeamType, buildHive, buildHiveSteps)


local orderDrifterToBuildHive = Resolve("COMMANDER_TUT_ORDER_DRIFTER_TO_HIVE")
local orderDrifterToBuildHiveSteps =
{
    { CompletionFunc = GetHasUnitSelected(kTechId.Drifter), HighlightButton = {kTechId.AssistMenu, kTechId.SelectDrifter} },
    { CompletionFunc = GetSelectionHasOrder(kTechId.Grow, kTechId.Hive), HighlightButton = kTechId.Grow, HighlightWorld = GetClosestUnbuiltStructurePosition(kTechId.Hive) },
}
AddCommanderTutorialEntry(0, kAlienTeamType, orderDrifterToBuildHive, orderDrifterToBuildHiveSteps, nil, GetHasUnbuiltStructure(kTechId.Hive), nil, nil, 7)
// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Balance.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/BalanceHealth.lua")
Script.Load("lua/BalanceMisc.lua")

kTransformResourcesTime = 15
kTransformResourcesCost = 15
kTransformResourcesRate = 1

// commander has  to stay in command structure for the first kCommanderMinTime seconds of each round
kCommanderMinTime = 30

kAutoBuildRate = 0.3

// setting to true will prevent any placement and construction of marine structures on infested areas
kPreventMarineStructuresOnInfestation = false
kCorrodeMarineStructureArmorOnInfestation = true

kInfestationCorrodeDamagePerSecond = 15

kMaxSupply = 200
kSupplyPerTechpoint = 100

// used as fallback
kDefaultBuildTime = 8

// MARINE COSTS
kCommandStationCost = 15

kExtractorCost = 10

kExtractorArmorCost = 5
kExtractorArmorResearchTime = 20

kInfantryPortalCost = 20

kArmoryCost = 10
kArmsLabCost = 15

kAdvancedArmoryUpgradeCost = 20
kPrototypeLabCost = 40

kSentryCost = 5
kPowerNodeCost = 0

kMACCost = 5
kMineCost = 15
kDropMineCost = 15
kMineResearchCost  = 10
kTechEMPResearchCost = 0
kTechMACSpeedResearchCost = 10

kWelderTechResearchTime = 15

kGrenadeTechResearchCost = 10
kGrenadeTechResearchTime = 45

kShotgunCost = 20
kShotgunDropCost = 20
kShotgunTechResearchCost = 20
kHeavyRifleTechResearchCost = 30



kClusterGrenadeCost = 3
kGasGrenadeCost = 3
kPulseGrenadeCost = 3

kGrenadeLauncherCost = 20
kGrenadeLauncherDropCost = 20
kGrenadeLauncherTechResearchCost = 15
kDetonationTimeTechResearchCost = 15

kAdvancedWeaponryResearchCost = 10

kFlamethrowerCost = 15
kFlamethrowerDropCost = 15
kFlamethrowerTechResearchCost = 20
kFlamethrowerRangeTechResearchCost = 10

kRoboticsFactoryCost = 10
kUpgradeRoboticsFactoryCost = 5
kUpgradeRoboticsFactoryTime = 20
kARCCost = 10
kARCSplashTechResearchCost = 15
kARCArmorTechResearchCost = 15
kWelderTechResearchCost = 0
kWelderCost = 3
kWelderDropCost = 5

kPulseGrenadeDamageRadius = 6
kPulseGrenadeEnergyDamageRadius = 10
kPulseGrenadeDamage = 110
kPulseGrenadeEnergyDamage = 0
kPulseGrenadeDamageType = kDamageType.Normal

kClusterGrenadeDamageRadius = 10
kClusterGrenadeDamage = 55
kClusterFragmentDamageRadius = 6
kClusterFragmentDamage = 20
kClusterGrenadeDamageType = kDamageType.Flame

kNerveGasDamagePerSecond = 50
kNerveGasDamageType = kDamageType.NerveGas

kJetpackCost = 15
kJetpackDropCost = 15
kJetpackTechResearchCost = 25
kJetpackFuelTechResearchCost = 15
kJetpackArmorTechResearchCost = 15

kExosuitTechResearchCost = 20
kExosuitLockdownTechResearchCost = 20

kExosuitCost = 40
kExosuitDropCost = 50
kClawRailgunExosuitCost = 40
kDualExosuitCost = 60
kDualRailgunExosuitCost = 60

kUpgradeToDualMinigunCost = 20
kUpgradeToDualRailgunCost = 20

kDualMinigunTechResearchCost = 30
kClawRailgunTechResearchCost = 30
kDualRailgunTechResearchCost = 30

kCatPackTechResearchCost = 15
kWeapons1ResearchCost = 20
kWeapons2ResearchCost = 30
kWeapons3ResearchCost = 40

kArmor1ResearchCost = 20
kArmor2ResearchCost = 30
kArmor3ResearchCost = 40
kNanoArmorResearchCost = 20

kRifleUpgradeTechResearchCost = 10

kObservatoryCost = 10
kPhaseGateCost = 15
kPhaseTechResearchCost = 10

kResearchBioMassOneCost = 15
kBioMassOneTime = 25
kResearchBioMassTwoCost = 20
kBioMassTwoTime = 40
kResearchBioMassThreeCost = 70
kBioMassThreeTime = 60
kResearchBioMassFourCost = 100
kBioMassFourTime = 80

kHiveCost = 40

kHarvesterCost = 8

kShellCost = 15
kCragCost = 13

kSpurCost = 15
kShiftCost = 13

kVeilCost = 15
kShadeCost = 13

kWhipCost = 13
kEvolveBombardCost = 5

kGorgeCost = 8
kGorgeEggCost = 15
kLerkCost = 20
kLerkEggCost = 30
kFadeCost = 35
kFadeEggCost = 70
kOnosCost = 55
kOnosEggCost = 100

kSkulkUpgradeCost = 0
kGorgeUpgradeCost = 1
kLerkUpgradeCost = 3
kFadeUpgradeCost = 5
kOnosUpgradeCost = 8

kHydraCost = 3
kClogCost = 0
kGorgeTunnelCost = 4
kGorgeTunnelBuildTime = 10

kEnzymeCloudDuration = 3

kCarapaceCost = 0
kRegenerationCost = 0
kCamouflageCost = 0
kAuraCost = 0
kSilenceCost = 0
kAdrenalineCost = 0
kCelerityCost = 0

kPlayingTeamInitialTeamRes = 60
kMaxTeamResources = 200

kMarineInitialIndivRes = 20
kAlienInitialIndivRes = 15
kCommanderInitialIndivRes = 0
kMaxPersonalResources = 100

kResourceTowerResourceInterval = 6
kTeamResourcePerTick = 1

kPlayerResPerInterval = 0.1 // was 1.25, but players now also get res while dead

kKillTeamReward = 0
kPersonalResPerKill = 0

// MARINE DAMAGE
kRifleDamage = 10
kRifleDamageType = kDamageType.Normal
kRifleClipSize = 50

kHeavyRifleCost = 30

kHeavyRifleDamage = 10
kHeavyRifleDamageType = kDamageType.Puncture
kHeavyRifleClipSize = 75

kRifleMeleeDamage = 10
kRifleMeleeDamageType = kDamageType.Normal

// 10 bullets per second
kPistolRateOfFire = 0.1
kPistolDamage = 25
kPistolDamageType = kDamageType.Light
kPistolClipSize = 10
// not used yet
kPistolMinFireDelay = 0.1

kPistolAltDamage = 40


kWelderDamagePerSecond = 30
kWelderDamageType = kDamageType.Flame
kWelderFireDelay = 0.2

kSelfWeldAmount = 5
kPlayerArmorWeldRate = 20

kAxeDamage = 25
kAxeDamageType = kDamageType.Structural


kGrenadeLauncherGrenadeDamage = 165
kGrenadeLauncherGrenadeDamageType = kDamageType.GrenadeLauncher
kGrenadeLauncherClipSize = 4
kGrenadeLauncherGrenadeDamageRadius = 4.8
kGrenadeLifetime = 2.0
kGrenadeUpgradedLifetime = 1.5

kShotgunFireRate = 0.88
kShotgunDamage = 10
kShotgunDamageType = kDamageType.Normal
kShotgunClipSize = 6
kShotgunBulletsPerShot = 17

kNadeLauncherClipSize = 4

kFlamethrowerDamage = 16
kFlameThrowerEnergyDamage = 3
kBurnDamagePerSecond = 2
kFlamethrowerDamageType = kDamageType.Flame
kFlamethrowerClipSize = 50
kFlamethrowerRange = 9
kFlamethrowerUpgradedRange = 11.5

kBurnDamagePerStackPerSecond = 3
kFlamethrowerMaxStacks = 20
kFlamethrowerBurnDuration = 6
kFlamethrowerStackRate = 0.4
kFlameRadius = 1.8
kFlameDamageStackWeight = 0.5

// affects dual minigun and dual railgun damage output
kExoDualMinigunModifier = 1
kExoDualRailgunModifier = 1

kMinigunDamage = 22
kMinigunDamageType = kDamageType.Heavy
kMinigunClipSize = 250

kClawDamage = 50
kClawDamageType = kDamageType.Structural

kRailgunDamage = 33
kRailgunChargeDamage = 140
kRailgunDamageType = kDamageType.Structural

kMACAttackDamage = 5
kMACAttackDamageType = kDamageType.Normal
kMACAttackFireDelay = 0.6


kMineDamage = 125
kMineDamageType = kDamageType.Light

kSentryAttackDamageType = kDamageType.Normal
kSentryAttackBaseROF = .15
kSentryAttackRandROF = 0.0
kSentryAttackBulletsPerSalvo = 1
kConfusedSentryBaseROF = 2.0

kSentryDamage = 5

kARCDamage = 450
kARCDamageType = kDamageType.Splash // splash damage hits friendly arcs as well
kARCRange = 26
kARCMinRange = 7

local kDamagePerUpgradeScalar = 0.1
kWeapons1DamageScalar = 1 + kDamagePerUpgradeScalar
kWeapons2DamageScalar = 1 + kDamagePerUpgradeScalar * 2
kWeapons3DamageScalar = 1 + kDamagePerUpgradeScalar * 3

kNanoShieldDamageReductionDamage = 0.68

// ALIEN DAMAGE
kBiteDamage = 75
kBiteDamageType = kDamageType.Normal
kBiteEnergyCost = 5.85

kLeapEnergyCost = 45

kParasiteDamage = 10
kParasiteDamageType = kDamageType.Normal
kParasiteEnergyCost = 30

kXenocideDamage = 200
kXenocideDamageType = kDamageType.Normal
kXenocideRange = 14
kXenocideEnergyCost = 30

kGorgeArmorTunnelDamagePerSecond = 5

kSpitDamage = 30
kSpitDamageType = kDamageType.Light
kSpitEnergyCost = 7

kBabblerPheromoneEnergyCost = 7
kBabblerDamage = 10

kBabblerCost = 1
kBabblerEggBuildTime = 8
kNumBabblerEggsPerGorge = 3
kNumBabblersPerEgg = 3

// Also see kHealsprayHealStructureRate
kHealsprayDamage = 8
kHealsprayDamageType = kDamageType.Biological
kHealsprayFireDelay = 0.8
kHealsprayEnergyCost = 12
kHealsprayRadius = 3.5

kBileBombDamage = 55 // per second
kBileBombDamageType = kDamageType.Corrode
kBileBombEnergyCost = 20
kBileBombDuration = 5
// 200 inches in NS1 = 5 meters
kBileBombSplashRadius = 6

kWebBuildCost = 1
kWebbedDuration = 2

kLerkBiteDamage = 60
kBitePoisonDamage = 6 // per second
kPoisonBiteDuration = 6
kLerkBiteEnergyCost = 5
kLerkBiteDamageType = kDamageType.Normal

kUmbraEnergyCost = 27
kUmbraDuration = 5
kUmbraRadius = 6

kUmbraShotgunModifier = 0.64
kUmbraBulletModifier = 0.75
kUmbraMinigunModifier = 0.70
kUmbraRailgunModifier = 0.68

kSpikeMaxDamage = 7
kSpikeMinDamage = 7
kSpikeDamageType = kDamageType.Puncture
kSpikeEnergyCost = 1.4
kSpikesAttackDelay = 0.07
kSpikeMinDamageRange = 9
kSpikeMaxDamageRange = 2
kSpikesRange = 50
kSpikesPerShot = 1

kSporesDamageType = kDamageType.Gas
kSporesDustDamagePerSecond = 20
kSporesDustFireDelay = 0.36
kSporesDustEnergyCost = 8
kSporesDustCloudRadius = 2.5
kSporesDustCloudLifetime = 8

kSwipeDamageType = kDamageType.StructuresOnlyLight
kSwipeDamage = 75
kSwipeEnergyCost = 7
kMetabolizeEnergyCost = 25

kStabDamage = 160
kStabDamageType = kDamageType.Normal
kStabEnergyCost = 30

kVortexEnergyCost = 20
kVortexDuration = 3

kStartBlinkEnergyCost = 14
kBlinkEnergyCost = 32
kHealthOnBlink = 0

kGoreDamage = 100
kGoreDamageType = kDamageType.Structural
kGoreEnergyCost = 12

kBoneShieldDamageReduction = 0.25
kBoneShieldEnergyPerSecond = 13
kStartBoneShieldCost = 10

kStompEnergyCost = 30
kStompDamageType = kDamageType.Heavy
kStompDamage = 40
kStompRange = 12
kDisruptMarineTime = 2
kDisruptMarineTimeout = 4

kDrifterAttackDamage = 5
kDrifterAttackDamageType = kDamageType.Normal
kDrifterAttackFireDelay = 0.6

kMelee1DamageScalar = 1.1
kMelee2DamageScalar = 1.2
kMelee3DamageScalar = 1.3

kWhipSlapDamage = 50
kWhipBombardDamage = 250
kWhipBombardDamageType = kDamageType.Corrode
kWhipBombardRadius = 6
kWhipBombardRange = 10
kWhipBombardROF = 6





// SPAWN TIMES
kMarineRespawnTime = 9

kAlienSpawnTime = 10
kEggGenerationRate = 13
kAlienEggsPerHive = 3

// BUILD/RESEARCH TIMES
kRecycleTime = 12
kArmoryBuildTime = 12
kAdvancedArmoryResearchTime = 90
kWeaponsModuleAddonTime = 40
kPrototypeLabBuildTime = 20
kArmsLabBuildTime = 17

kMACBuildTime = 5
kExtractorBuildTime = 11

kInfantryPortalBuildTime = 7

kShotgunTechResearchTime = 30
kHeavyRifleTechResearchTime = 60
kGrenadeLauncherTechResearchTime = 20
kAdvancedWeaponryResearchTime = 35

kCommandStationBuildTime = 15

kSentryBatteryCost = 10
kSentryBatteryBuildTime = 5

kRoboticsFactoryBuildTime = 8
kARCBuildTime = 7
kARCSplashTechResearchTime = 30
kARCArmorTechResearchTime = 30

kNanoShieldDuration = 5
kSentryBuildTime = 3

kNanoShieldResearchCost = 15
kNanoSnieldResearchTime = 60

kMineResearchTime  = 20
kTechEMPResearchTime = 60
kTechMACSpeedResearchTime = 15

kJetpackTechResearchTime = 90
kJetpackFuelTechResearchTime = 60
kJetpackArmorTechResearchTime = 60
kExosuitTechResearchTime = 90
kExosuitLockdownTechResearchTime = 60
kExosuitUpgradeTechResearchTime = 60

kFlamethrowerTechResearchTime = 60
kFlamethrowerAltTechResearchTime = 60
kFlamethrowerRangeTechResearchTime = 60

kDualMinigunTechResearchTime = 60
kClawRailgunTechResearchTime = 60
kDualRailgunTechResearchTime = 60
kCatPackTechResearchTime = 45

kObservatoryBuildTime = 15
kPhaseTechResearchTime = 45
kPhaseGateBuildTime = 12

kWeapons1ResearchTime = 60
kWeapons2ResearchTime = 90
kWeapons3ResearchTime = 120
kArmor1ResearchTime = 60
kArmor2ResearchTime = 90
kArmor3ResearchTime = 120

kNanoArmorResearchTime = 60

kHiveBuildTime = 180

kDrifterBuildTime = 4
kHarvesterBuildTime = 38

kShellBuildTime = 18
kCragBuildTime = 25

kWhipBuildTime = 20
kEvolveBombardResearchTime = 15

kSpurBuildTime = 16
kShiftBuildTime = 18

kVeilBuildTime = 14
kShadeBuildTime = 18
kEvolveHallucinationsResearchTime = 30

kHydraBuildTime = 13
kCystBuildTime = 5

kSkulkGestateTime = 3
kGorgeGestateTime = 7
kLerkGestateTime = 15
kFadeGestateTime = 25
kOnosGestateTime = 30

kEggGestateTime = 45

kEvolutionGestateTime = 3

// alien ability research cost / time

kAlienBrainResearchCost = 35
kAlienBrainResearchTime = 90

kAlienMusclesResearchCost = 35
kAlienMusclesResearchTime = 90

kDefensivePostureResearchCost = 35
kDefensivePostureResearchTime = 90

kOffensivePostureResearchCost = 35
kOffensivePostureResearchTime = 90

kUpgradeSkulkResearchCost = 20
kUpgradeSkulkResearchTime = 90
kUpgradeGorgeResearchCost = 30
kUpgradeGorgeResearchTime = 90
kUpgradeLerkResearchCost = 35
kUpgradeLerkResearchTime = 90
kUpgradeFadeResearchCost = 35
kUpgradeFadeResearchTime = 120
kUpgradeOnosResearchCost = 35
kUpgradeOnosResearchTime = 120


kGorgeTunnelResearchCost = 15
kGorgeTunnelResearchTime = 40
kChargeResearchCost = 15
kChargeResearchTime = 40
kLeapResearchCost = 15
kLeapResearchTime = 40
kBileBombResearchCost = 15
kBileBombResearchTime = 40
kShadowStepResearchCost = 15
kShadowStepResearchTime = 40
kUmbraResearchCost = 20
kUmbraResearchTime = 45
kBoneShieldResearchCost = 20
kBoneShieldResearchTime = 40
kSporesResearchCost = 20
kSporesResearchTime = 60
kStompResearchCost = 25
kStompResearchTime = 60
kStabResearchCost = 25
kStabResearchTime = 60
kMetabolizeEnergyResearchCost = 20
kMetabolizeEnergyResearchTime = 40
kMetabolizeHealthResearchCost = 20
kMetabolizeHealthResearchTime = 45
kXenocideResearchCost = 25
kXenocideResearchTime = 60
kVortexResearchCost = 15
kVortexResearchTime = 60
kWebResearchCost = 10
kWebResearchTime = 60


kCommandStationInitialEnergy = 100  kCommandStationMaxEnergy = 250
kNanoShieldCost = 5
kNanoShieldCooldown = 10
kEMPCost = 50

kPowerSurgeCooldown = 20
kPowerSurgeDuration = 20
kPowerSurgeCost = 5

kArmoryInitialEnergy = 100  kArmoryMaxEnergy = 150

kAmmoPackCost = 1
kMedPackCost = 1
kMedPackCooldown = 0
kCatPackCost = 3
kCatPackMoveAddSpeed = 1.25
kCatPackWeaponSpeed = 1.5
kCatPackDuration = 12

kHiveInitialEnergy = 50  kHiveMaxEnergy = 200
kMatureHiveMaxEnergy = 250
kCystCost = 1
kCystCooldown = 0.0

kDrifterInitialEnergy = 50
kDrifterMaxEnergy = 200

kEnzymeCloudCost = 2
kHallucinationCloudCost = 2
kMucousMembraneCost = 2
kStormCost = 2

kMucousShieldCooldown = 5
kMucousShieldPercent = 0.15
kMucousShieldDuration = 5

kHallucinationLifeTime = 30

// only allow x% of affected players to create a hallucination
kPlayerHallucinationNumFraction = 0.34
// cooldown per entity
kHallucinationCloudCooldown = 3
kDrifterAbilityCooldown = 0

kNutrientMistCost = 2
kNutrientMistCooldown = 2
// Note: If kNutrientMistDuration changes, there is a tooltip that needs to be updated.
kNutrientMistDuration = 15

kRuptureCost = 2
kRuptureCooldown = 2

kBoneWallCost = 3
kBoneWallCooldown = 10

kContaminationCost = 5
kContaminationCooldown = 5



// 100% + X (increases by 66%, which is 10 second reduction over 15 seconds)
kNutrientMistPercentageIncrease = 66
kNutrientMistMaturingIncrease = 66

kObservatoryInitialEnergy = 25  kObservatoryMaxEnergy = 100
kObservatoryScanCost = 3
kObservatoryDistressBeaconCost = 10

kMACInitialEnergy = 50  kMACMaxEnergy = 150
kDrifterCost = 8
kDrifterCooldown = 0
kDrifterHatchTime = 7

kCragInitialEnergy = 25  kCragMaxEnergy = 100 
kCragHealWaveCost = 3
kHealWaveCooldown = 6
kMatureCragMaxEnergy = 150

kHydraDamage = 15 // From NS1
kHydraAttackDamageType = kDamageType.Normal

kWhipInitialEnergy = 25  kWhipMaxEnergy = 100
kMatureWhipMaxEnergy = 150

kShiftInitialEnergy = 50  kShiftMaxEnergy = 150
kShiftHatchCost = 5
kShiftHatchRange = 11
kMatureShiftMaxEnergy = 200

kEchoHydraCost = 1
kEchoWhipCost = 2
kEchoTunnelCost = 5
kEchoCragCost = 1
kEchoShadeCost = 1
kEchoShiftCost = 1
kEchoVeilCost = 1
kEchoSpurCost = 1
kEchoShellCost = 1
kEchoHiveCost = 10
kEchoEggCost = 2
kEchoHarvesterCost = 2

kShadeInitialEnergy = 25  kShadeMaxEnergy = 100
kShadeInkCost = 3
kShadeInkCooldown = 16
kShadeInkDuration = 6.3
kMatureShadeMaxEnergy = 150

kEnergyUpdateRate = 0.5

// This is for CragHive, ShadeHive and ShiftHive
kUpgradeHiveCost = 10
kUpgradeHiveResearchTime = 20

kHiveBiomass = 1

kCragBiomass = 0
kShadeBiomass = 0
kShiftBiomass = 0
kWhipBiomass = 0
kHarvesterBiomass = 0
kShellBiomass = 0
kVeilBiomass = 0
kSpurBiomass = 0

// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\BalanceMisc.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kAlienStructureMoveSpeed = 1.5
kShiftStructurespeedScalar = 1

kPoisonDamageThreshhold = 5

kSpawnBlockRange = 5

kInfestationBuildModifier = 0.75

// Time spawning alien player must be in egg before hatching
kAlienSpawnTime = 2
kInitialMACs = 0
// Construct at a slower rate than players
kMACConstructEfficacy = .3
kFlamethrowerAltTechResearchCost = 20
kDefaultFov = 90
kEmbryoFov = 100
kSkulkFov = 105
kGorgeFov = 95
kLerkFov = 100
kFadeFov = 90
kOnosFov = 90
kExoFov = 95

kNanoArmorHealPerSecond = 0.5

kResearchMod = 1

kMinSupportedRTs = 0
kRTsPerTechpoint = 3

kEMPBlastEnergyDamage = 50

kEnzymeAttackSpeed = 1.25
kElectrifiedAttackSpeed = 0.8
kElectrifiedDuration = 5

kHallucinationHealthFraction = 0.20
kHallucinationArmorFraction = 0
kHallucinationMaxHealth = 700

// set to -1 for no time limit
kParasiteDuration = 44

// increases max speed by 1.5 m/s
kCelerityAddSpeed = 1.5

kHydrasPerHive = 3
kClogsPerHive = 10
kNumWebsPerGorge = 10
kCystInfestDuration = 37.5

kSentriesPerBattery = 3

kStructureCircleRange = 4
kInfantryPortalAttachRange = 10
kArmoryWeaponAttachRange = 10
// Minimum distance that initial IP spawns away from team location
kInfantryPortalMinSpawnDistance = 4
kItemStayTime = 30    // NS1
kWeaponStayTime = 25

// For power points
kMarineRepairHealthPerSecond = 600
// The base weapons need to cost a small amount otherwise they can
// be spammed.
kRifleCost = 0
kPistolCost = 0
kAxeCost = 0
kInitialDrifters = 0
kSkulkCost = 0

kMACSpeedAmount = .5
// How close should MACs/Drifters fly to operate on target
kCommandStationEngagementDistance = 4
kInfantryPortalEngagementDistance = 2
kArmoryEngagementDistance = 3
kArmsLabEngagementDistance = 3
kExtractorEngagementDistance = 2
kObservatoryEngagementDistance = 1
kPhaseGateEngagementDistance = 2
kRoboticsFactorEngagementDistance = 5
kARCEngagementDistance = 2
kSentryEngagementDistance = 2
kPlayerEngagementDistance = 1
kExoEngagementDistance = 1.5
kOnosEngagementDistance = 2
kLerkSporeShootRange = 10

// entrance and exit
kNumGorgeTunnels = 2

// maturation time for alien buildings
kHiveMaturationTime = 220
kHarvesterMaturationTime = 150
kWhipMaturationTime = 120
kCragMaturationTime = 120
kShiftMaturationTime = 90
kShadeMaturationTime = 120
kVeilMaturationTime = 60
kSpurMaturationTime = 60
kShellMaturationTime = 60
kCystMaturationTime = 120
kHydraMaturationTime = 140
kEggMaturationTime = 100
kTunnelEntranceMaturationTime = 135

kNutrientMistMaturitySpeedup = 2
kNutrientMistAutobuildMultiplier = 1

kMinBuildTimePerHealSpray = 0.9
kMaxBuildTimePerHealSpray = 1.8

// Marine buy costs
kFlamethrowerAltCost = 25

// Scanner sweep
kScanDuration = 10
kScanRadius = 20

// Distress Beacon (from NS1)
kDistressBeaconRange = 25
kDistressBeaconTime = 3

kEnergizeRange = 17
// per stack
kEnergizeEnergyIncrease = .25
kStructureEnergyPerEnergize = 0.15
kPlayerEnergyPerEnergize = 15
kEnergizeUpdateRate = 1

kEchoRange = 8

kSprayDouseOnFireChance = .5

// Players get energy back at this rate when on fire 
kOnFireEnergyRecuperationScalar = 1

// Players get energy back at this rate when electrified
kElectrifiedEnergyRecuperationScalar = .7

// Infestation
kStructureInfestationRadius = 2
kHiveInfestationRadius = 20
kInfestationRadius = 7.5
kGorgeInfestationLifetime = 60
kMarineInfestationSpeedScalar = .1

kDamageVelocityScalar = 2.5

// Each upgrade costs this much extra evolution time
kUpgradeGestationTime = 2

// Cyst parent ranges, how far a cyst can support another cyst
//
// NOTE: I think the range is a bit long for kCystMaxParentRange, there will be gaps between the
// infestation patches if the range is > kInfestationRadius * 1.75 (about).
// 
kHiveCystParentRange = 24 // distance from a hive a cyst can be connected
kCystMaxParentRange = 24 // distance from a cyst another cyst can be placed
kCystRedeployRange = 6 // distance from existing Cysts that will cause redeployment

// Damage over time that all cysts take when not connected
kCystUnconnectedDamage = 12

// Light shaking constants
kOnosLightDistance = 50
kOnosLightShakeDuration = .2
kLightShakeMaxYDiff = .05
kLightShakeBaseSpeed = 30
kLightShakeVariableSpeed = 30

// Jetpack
kUpgradedJetpackUseFuelRate = .19
kJetpackingAccel = 0.8
kJetpackUseFuelRate = .21
kJetpackReplenishFuelRate = .11

// Mines
kNumMines = 3
kMineActiveTime = 4
kMineAlertTime = 8
kMineDetonateRange = 5
kMineTriggerRange = 1.5

// Onos
kGoreMarineFallTime = 1
kDisruptTime = 5

kEncrustMaxLevel = 5
kSpitObscureTime = 8
kGorgeCreateDistance = 6.5

kMaxTimeToSprintAfterAttack = .2

// Welding variables
// Also: MAC.kRepairHealthPerSecond
// Also: Exo -> kArmorWeldRate
kWelderPowerRepairRate = 220
kBuilderPowerRepairRate = 110
kWelderSentryRepairRate = 150
kPlayerWeldRate = 30
kStructureWeldRate = 90
kDoorWeldTime = 15

kHatchCooldown = 4
kEggsPerHatch = 2

kAlienRegenerationTime = 2

kAlienInnateRegenerationPercentage  = 0.02
kAlienMinInnateRegeneration = 1
kAlienMaxInnateRegeneration = 20

// used for regeneration upgrade
kAlienRegenerationPercentage = 0.06
kAlienMinRegeneration = 6
kAlienMaxRegeneration = 80

kAlienHealRateTimeLimit = 1
kAlienHealRateLimit = 1000
kAlienHealRatePercentLimit = 1
kAlienHealRateOverLimitReduction = 1
kOnFireHealingScalar = 0.5

// when in combat self healing (innate healing or through upgrade) is multiplied with this value
kAlienRegenerationCombatModifier = 1

kCarapaceSpeedReduction = 0.0
kSkulkCarapaceSpeedReduction = 0 //0.08
kGorgeCarapaceSpeedReduction = 0 //0.08
kLerkCarapaceSpeedReduction = 0 //0.15
kFadeCarapaceSpeedReduction = 0 //0.15
kOnosCarapaceSpeedReduction = 0 //0.12

// Umbra blocks 1 out of this many bullet
kUmbraBlockRate = 3
// Carries the umbra cloud for x additional seconds
kUmbraRetainTime = 0.25

kBellySlideCost = 25
kLerkFlapEnergyCost = 3
kFadeShadowStepCost = 11
kChargeEnergyCost = 30 // per second

kAbilityMaxEnergy = 100
kAdrenalineAbilityMaxEnergy = 130

kPistolWeight = 0.0
kRifleWeight = 0.13
kHeavyRifleWeight = 0.25
kGrenadeLauncherWeight = 0.15
kFlamethrowerWeight = 0.14
kShotgunWeight = 0.14

kHandGrenadeWeight = 0.1
kLayMineWeight = 0.10

kClawWeight = 0.01
kMinigunWeight = 0.11
kRailgunWeight = 0.08

kDropStructureEnergyCost = 20

kMinWebLength = 0.5
kMaxWebLength = 8

kMACSupply = 10
kArmorySupply = 5
kARCSupply = 15
kSentrySupply = 10
kRoboticsFactorySupply = 5
kInfantryPortalSupply = 0
kPhaseGateSupply = 0

kDrifterSupply = 10
kWhipSupply = 5
kCragSupply = 5
kShadeSupply = 5
kShiftSupply = 5

kSearchFor = 45
kExpandCystInterval =  8
kStructureDropCost = 8
kCystSpawnCost = 1
kBuilderPowerRepairRate = 440
kWelderPowerRepairRate = 880
kMarineRepairHealthPerSecond = 2400
kLeapEnergyCost = 20
kSentryBatteryHealth = 1200
kHiveMoveUpVector = 0
kLightMode = enum( {'Normal', 'NoPower', 'LowPower', 'Damaged', 'MainRoom', } )
//kGorgeCost = 10
//kLerkCost = 20
//kFadeCost = 30
//kOnosCost = 40

kGorgeEggCost = 0
kLerkEggCost = 0
kFadeEggCost = 0
kOnosEggCost = 0

kMatureVeilHealth = 2000
kFireFlameCloudDamagePerSecond = 24
kExosuitCost = 10
kDualRailgunExosuitCost = 10
kARCArmor = 125
CCSiegeBeaconDelay = 10
kParasitesToDisable = 4
kFadeGravityMod = 1
kMarineResearchDelay = 15
kInfestationBuildModifier = .5
//kMaxTeamResources = 420

kBeaconDelay = 16
kCreditsPerRoundCap = 200
kCreditMultiplier = 1
kSBCooldown = 8
kDynamicBuildSpeed = 1
kActivePlayers = 0
//kCragSiegeBonus = 1.3
kMapStatsMarineBuild = 1
kMapStatsAlienBuild = 1
kMapStatsCragStacks = 1.3
kEtherealGateCoolDown = 20
kOnosEggCost = 150

////main room formula
kMainRoomPickEveryXSeconds = 30
kMainRoomTimeInSecondsOfCombatToCount = 7
kPercentofInCombatToQualify = .51
kMainRoomDamageMult = 2

kMaxAlienStructureRange = 25 
kMaxAlienStructuresofType = 8

kMACEMpCoolDown = 10
kEMPCost = 10

kPercentofPrimalBuildPointsAssistToGiveLerk = .5
kPercentofAssistKillPointsForPrimalLerk = .5
kShotgunCost = 15

//compmod remix
kHeavyMachineGunDamage = 7
kHeavyMachineGunDamageType = kDamageType.Puncture	
kHeavyMachineGunClipSize = 125	
kHeavyMachineGunWeight = 0.165		 
kHeavyMachineGunCost = 15			
kHeavyMachineGunDropCost = 25		
kHeavyMachineGunPointValue = 7		
kHeavyMachineGunSpread = Math.Radians(3.8)
////

/////These are all 0 because they're passive & automatically researched by the durations marked below
kPhaseTechResearchCost = 0
kCatPackTechResearchCost = 0
kNanoShieldResearchCost = 0
kArmor1ResearchCost = 0
kArmor2ResearchCost = 0
kArmor3ResearchCost = 0
kWeapons1ResearchCost = 0
kWeapons2ResearchCost = 0
kWeapons3ResearchCost = 0
kShotgunTechResearchCost = 0
kMineResearchCost = 0
kHeavyRifleTechResearchCost = 0
kAdvancedWeaponryResearchCost = 0
kJetpackTechResearchCost = 0
kExosuitTechResearchCost = 0
kGrenadeTechResearchCost = 0
kAdvancedArmoryUpgradeCost = 0

kWeapons1SecondUnlockMax  = 240
kArmor1SecondUnlockMax  = 310
kWeapons2SecondUnlockMax  = 480
kArmor2SecondUnlockMax  = 750
kArmor3SecondUnlockMax  = 690
kWeapons3SecondUnlockMax  = 660
kRifleClipSecondUnlockMax  = 780

//////////////////////////////
// For Siege doors for mappers
kMoveUpVector = 10   
kMoveZVector = 0
kMoveXVector = 0
///
kResupplyCost = 5
kFuncMoveableSpeed = 0.25
kSiegeDoorSpeed = 0.25
kFireBulletsCost = 5
kJumpPackCost = 7
kAdvancedArmoryHealth = 1800    kAdvancedArmoryArmor = 300    kAdvancedArmoryPointValue = 20
kShellHealth = 400
kFuncDoorHealth = 100
kFuncDoorWeldRate = 1
kAddAmountofFuncDoorBroken = .1
kSideDoorTime = 300 
kMarineRespawnProtection = 5.06
kFrontDoorTime = (300-61)+21
kSiegeDoorTimey = 1500 
kTimeAfterSiegeOpeningToEnableSuddenDeath = 300

kAlienTeamInitialTres = 60
kMarineTeamInitialTres = 60

kMarineTeamSetupBuildMultiplier = 1
kAlienTeamSetupBuildMultiplier = 1

kMarineTeamResearchMod = 1
kAlienTeamResearchMod = 1

kMaxEntitiesInRadius = 30 
kMaxEntityRadius = 10 


kRifleClipCost = 15
kRifleClipTime = 45
kArmoryArmorCost = 10
kArmoryArmorTime = 25

kMacWeldMacsCost = 15
kMacWeldMacsTime = 45 
        

kHeavyRifleDamage = 10
kHeavyRifleDamageType = kDamageType.Normal
kHeavyRifleClipSize = 75
kHeavyRifleCost = 10
kHeavyRifleTechResearchCost = 20
kHeavyRifleTechResearchTime = 30


kAcidRocketDamage = 25
kAcidRocketDamageType = kDamageType.Acid
kAcidRocketFireDelay = 0.5
kAcidRocketEnergyCost = 10
kAcidRocketRadius = 6

kDrifterGorgeResearchCost = 15
kDrifterGorgeResearchTime = 25
kLerkLiftResearchCost = 15 //999 //15
kLerkLiftResearchTime = 25
kLerkLiftLerkSpeedDecreaseMult = .25
kLerkLiftFlapEnergyMultiplier = 2
kSpiderGorgeResearchCost = 15
kSpiderGorgeResearchTime = 25
kWallWalkEnergyCost = 0 

kSentriesPerBattery = 6

kSentryBuildTime = 6
kObservatorySupply = 2
kPhaseGateSupply = 1
kARCSupply = 8
kRoboticsFactorySupply = 3
kSentrySupply = 5
//kMACSupply = 7

kXenocideDamageType = kDamageType.Xenocide


kNanoArmorHealPerSecond = 1

kSporesDamageType = kDamageType.Gas
kSporesDustDamagePerSecond = 20
kSporesDustFireDelay = 1
kSporesDustEnergyCost = 30
kSporesDustCloudRadius = 2.5
kSporesDustCloudLifetime = 5
kSporesMaxCloudRange = 20
kSporesTravelSpeed = 60
kMeleeSporesDustCloudRadius = 2.5
kMeleeSporesDustEnergyCost = 8
kMeleeSporesDustFireDelay = 0.86


kPrimalScreamEnergyCost = 25
kPrimalScreamRange = 10
kPrimalScreamDamageModifier = 1.3
kPrimalScreamDuration = 4
kPrimalScreamEnergyGain = 60
kPrimalScreamROF = 3
kPrimalScreamROFIncrease = .3
kResearchBioMassThreeCost = 25
kRangeBetweenkSentries = 12

kHydrasPerHive = 3


kCragUmbraCooldown = 10
kCragUmbraCost = 5
kCragUmbraRadius = 12
kStompUpgradeExoAddOverHTAmount = 0.25

kOnipoopResCost = 15


kPrimalScreamCostKey = 20


kPhasePriotityCooldown = 0
kPhasePriotityCost = 0

kRedemptionEHPThreshold = 0.35
kRedemptionTimeBase = 1.5
kRedemptionCooldown = 30
kRedemptionCost = 2
kRebirthCost = 2

kGorgeTunnelCost = 5
kGorgeTunnelBuildTime = 11

kDistressBeaconCooldown = 10
kAdvancedDistressBeaconCost = 15
kAdvancedBeaconTechResearchCost = 10
kAdvancedBeaconTechResearchTime = 1
kAdvancedDistressBeaconCooldown = 15

kLevelSentryCost = 1
kLevelSentryCooldown = 5
kLevelIPCost = 1
kLevelIPCoolDown = 5

kTunnelEntranceHealth = 1250    kTunnelEntranceArmor = 130  
kMatureTunnelEntranceHealth = 1412    kMatureTunnelEntranceArmor = 269


kSkulkHealth = 75
kMucousShieldCooldown = 10
kMucousShieldDuration = 10
kGorgeNoBuildNearDoorsRadius = 10


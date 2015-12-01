kEtherealGateCoolDown = 20
kOnosEggCost = 150

////main room formula
kMainRoomPickEveryXSeconds = 30
//kMainRoomWayPointMinimumSeconds = 25
kMainRoomTimeInSecondsOfCombatToCount = 7
kPercentofInCombatToQualify = .51
kMainRoomDamageMult = 2
//////

//kNumShadessPerGorge = 3
//kNumShiftsPerGorge 3

kMaxAlienStructureRange = 25 
kMaxAlienStructuresofType = 8

kMACEMpCoolDown = 10
kEMPCost = 10

kPercentofPrimalBuildPointsAssistToGiveLerk = .5
kPercentofAssistKillPointsForPrimalLerk = .5

kShellBuildTime = 4

kExosuitDropCost = 50

//compmod remix
kHeavyMachineGunDamage = 7
kHeavyMachineGunDamageType = kDamageType.Puncture	
kHeavyMachineGunClipSize = 125	
kHeavyMachineGunWeight = 0.55		 
kHeavyMachineGunCost = 20			
kHeavyMachineGunDropCost = 25		
kHeavyMachineGunPointValue = 7		
kHeavyMachineGunSpread = Math.Radians(3.8)
////

kSiegeObsAutoScanCooldown = 8 //Obs turns into siege mode while in siege room during siege and scans every this many seconds

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

////// duration of seconds to unlock each teach automatically & passively

//arms lab =
/*
weapons 1 = 1 min - 4 min
armor 1 = 1 min - 5 min 10 seconds
weapons 2 = 5 min 30 seconds - 8 min
armor 2 = 6 mins - 7 mins 30 seconds
weapons 3 = 8 min 10 sec - 11 min
armor 3 = 8 min 30 sec - 11 min 30 sec
heavyrifletech (extra dmg vs onos with rifle) - 13 min - 15 min

Phastech  = 1 min 15 sec - 4 mins

mines = 15s - 1min
grenades = 45s-1202min
shotgun = 1min-3min
aa = 1min-6min (LOL BAD LUCK NUB COM!)

catpack = 5min-11min (brutal right?)
nano = 1min15s-11min (brutal right?)
*/

/////////////min///////////////

kSecondMarkToUnlockCatPackTechMin  = 300 // front/side door average
kSecondMarkToUnlockNanoTechMin   = 300 // front/side door average
kSecondMarkToUnlockPhaseTechMin  = 75 // some teaams and maps need this early
kWeapons1SecondUnlockMin   = 60 
kWeapons2SecondUnlockMin   = 330
kWeapons3SecondUnlockMin   = 490 
kArmor1SecondUnlockMin   = 60
kArmor2SecondUnlockMin   = 360 
kArmor3SecondUnlockMin   = 450
kRifleClipSecondUnlockMin   = 480
kMinuteMarkToUnlockMinesMin   = 15
kMinuteMarkToUnlockGrenadesMin   = 45
kMinuteMarkToUnlockShotgunsMin   = 60
kMinuteMarkToUnlockHeavyRifleMin   = 780
kMinuteMarkToUnlockAAMin   = 60
kJetpackMinuteUnlockTimeMin   = 60
kExoSuitMinuteUnlockTimeMin   = 60
//////////////////////////////max////////////////////
kSecondMarkToUnlockCatPackTechMax  = 660
kSecondMarkToUnlockNanoTechMax  = 660
kSecondMarkToUnlockPhaseTechMax  = 240
kWeapons1SecondUnlockMax  = 240
kArmor1SecondUnlockMax  = 310
kWeapons2SecondUnlockMax  = 480
kArmor2SecondUnlockMax  = 750
kArmor3SecondUnlockMax  = 690
kWeapons3SecondUnlockMax  = 660
kRifleClipSecondUnlockMax  = 780
kMinuteMarkToUnlockMinesMax  = 60
kMinuteMarkToUnlockGrenadesMax  = 120
kMinuteMarkToUnlockShotgunsMax  = 180
kMinuteMarkToUnlockHeavyRifleMax  = 900
kMinuteMarkToUnlockAAMax  = 360
kJetpackMinuteUnlockTimeMax  = 300
kExoSuitMinuteUnlockTimeMax  = 300
//////////////////////////////
// For Siege doors for mappers
kMoveUpVector = 10   
kMoveZVector = 0
kMoveXVector = 0
///
kResupplyCost = 7
kFuncMoveableSpeed = 0.25
kSiegeDoorSpeed = 0.25
kFireBulletsCost = 5
kJumpPackCost = 7
kAdvancedArmoryHealth = 1800    kAdvancedArmoryArmor = 300    kAdvancedArmoryPointValue = 20
kShellHealth = 400
kFuncDoorHealth = 100
kFuncDoorWeldRate = 1
kAddAmountofFuncDoorBroken = .1
kShouldArcsFireAtCysts = false
//kAlienTeamPresBonusMult = 1
kCreditMultiplier = 1 // for double credit weekend change 1 to 2 :P
kSideDoorTime = 300 
kMarineRespawnProtection = 5.06
kFrontDoorTime = 360 //6 min
kSiegeDoorTime = 900 // 20 min
kTimeAfterSiegeOpeningToEnableSuddenDeath = 600

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
kObservatorySupply = 1
kPhaseGateSupply = 0
kARCSupply = 8
kRoboticsFactorySupply = 3
kSentrySupply = 5
kPhaseGateSupply = 1
//kMACSupply = 7
kObservastorySupply = 2

kXenocideDamageType = kDamageType.Xenocide



//kExosuitTechResearchCost = 30
kExoWelderDamagePerSecond = 28
kExoPlayerWeldRate = 15
kExoStructureWeldRate = 65
kExoFlamerDamage = 23
kExoWelderDamagePerSecond = 28
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

//kCystHealth = 91    kCystArmor = 0
//kMatureCystHealth = 585    kMatureCystArmor = 0    kCystPointValue = 1

//kContaminationHealth = 1300

kSecondMarkToUnlockCatPackTech = 480
kSecondMarkToUnlockNanoTech = 660

kCragUmbraCooldown = 10
kCragUmbraCost = 5
kCragUmbraRadius = 12
kStompUpgradeExoAddOverHTAmount = 0.25

kOnipoopResCost = 15


kPrimalScreamCostKey = 20


//kBioMassOneTime = 15
//kBioMassTwoTime = 20
kBioMassThreeTime = 30


kOnosHealtPerBioMass = 18
kWhipSupply = 7
kCragSupply = 7

kPhasePriotityCooldown = 0
kPhasePriotityCost = 0

kRedemptionEHPThreshold = 0.35
kRedemptionTimeBase = 1.5
kRedemptionCooldown = 45
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


kBluePrintTechResearchCost = 10
kBluePrintTechResearchTime = 30


kPresBonusResearchCost = 25
kPresBonusResearchTime = 90

kOnifleDamageBonusMin = 1.15
kOnifleDamageBonusMax = 1.20

kWhipFlameThrowerCost = 15
kWhipFlameThrowerTime = 45

//kLerkHealth = 163
//kLerkArmor = 60
//kLerkArmorFullyUpgradedAmount = 78

kWhipCost = 10
kShiftCost = 10
kShadeCost = 10
kWhipCost = 10
kCragCost = 10

kEchoHydraCost = 10
kEchoWhipCost = 10
kEchoTunnelCost = 10
kEchoCragCost = 10
kEchoShadeCost = 10
kEchoShiftCost = 10
kEchoVeilCost = 10
kEchoSpurCost = 10
kEchoShellCost = 10
kEchoHiveCost = 10
kEchoEggCost = 10
kEchoHarvesterCost = 10

kTunnelEntranceHealth = 1250    kTunnelEntranceArmor = 130  
kMatureTunnelEntranceHealth = 1412    kMatureTunnelEntranceArmor = 269


//kPowerPointHealth = 2300 
//kPowerPointArmor = 1100
//kWelderPowerRepairRate = 264
//kBuilderPowerRepairRate = 132
kSkulkHealth = 75
kMucousShieldCooldown = 10
kMucousShieldDuration = 10
kGorgeNoBuildNearDoorsRadius = 10

kARCHealth = 2200    kARCArmor = 500    kARCPointValue = 5
kARCDeployedHealth = 2200    kARCDeployedArmor = 50


//kMatureHydraHealth = 675    kMatureHydraArmor = 100  <- Buffed value
///////////////////Removed MaturityMixin and set the Default values as Mature

kCystHealth = 450 
kEggHealth = 400    kEggArmor = 0   
kHiveHealth = 6000    kHiveArmor = 1400    
kHarvesterHealth = 2300 kHarvesterArmor = 320  
kShellHealth = 700 kShellArmor = 200 
kCragHealth = 700    kCragArmor = 340         
kWhipHealth = 720    kWhipArmor = 240         
kSpurHealth = 900     kSpurArmor = 100 
kShiftHealth = 1100    kShiftArmor = 150    
kVeilHealth = 1100     kVeilArmor = 0   
kShadeHealth = 1500  
kHydraHealth = 450    kHydraArmor = 50    

// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======        
//        
// lua\BalanceHealth.lua        
//        
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)            
//        
// ========= For more information, visit us at http://www.unknownworlds.com =====================        
        
// HEALTH AND ARMOR        
kMarineHealth = 100    kMarineArmor = 30    kMarinePointValue = 5
kJetpackHealth = 100    kJetpackArmor = 30    kJetpackPointValue = 10
kExosuitHealth = 100    kExosuitArmor = 320    kExosuitPointValue = 20

kLayMinesPointValue = 1
kGrenadeLauncherPointValue = 2
kShotgunPointValue = 5
kFlamethrowerPointValue = 7

kMinigunPointValue = 5
kRailgunPointValue = 5
        
kSkulkHealth = 70    kSkulkArmor = 10    kSkulkPointValue = 5    kSkulkHealthPerBioMass = 3
kGorgeHealth = 160    kGorgeArmor = 75    kGorgePointValue = 7    kGorgeHealthPerBioMass = 2
kLerkHealth = 125    kLerkArmor = 45        kLerkPointValue = 15    kLerkHealthPerBioMass = 2
kFadeHealth = 250    kFadeArmor = 80     kFadePointValue = 20    kFadeHealthPerBioMass = 5
kOnosHealth = 900    kOnosArmor = 450    kOnosPointValue = 30    kOnosHealtPerBioMass = 25

kMarineWeaponHealth = 400
        
kEggHealth = 350    kEggArmor = 0    kEggPointValue = 1
kMatureEggHealth = 400    kMatureEggArmor = 0

kBabblerHealth = 10    kBabblerArmor = 0    kBabblerPointValue = 0
kBabblerEggHealth = 300    kBabblerEggArmor = 0    kBabblerEggPointValue = 0
        
kArmorPerUpgradeLevel = 20
kExosuitArmorPerUpgradeLevel = 45
kArmorHealScalar = 1 // 0.75

kParasitePlayerPointValue = 1
kBuildPointValue = 5
kRecyclePaybackScalar = 0.75

kCarapaceHealReductionPerLevel = 0.0

kSkulkArmorFullyUpgradedAmount = 30
kGorgeArmorFullyUpgradedAmount = 100
kLerkArmorFullyUpgradedAmount = 60
kFadeArmorFullyUpgradedAmount = 120
kOnosArmorFullyUpgradedAmount = 650

kBalanceInfestationHurtPercentPerSecond = 2
kMinHurtPerSecond = 20

// used for structures
kStartHealthScalar = 0.3

kArmoryHealth = 1800    kArmoryArmor = 300    kArmoryPointValue = 5
kAdvancedArmoryHealth = 3000    kAdvancedArmoryArmor = 500    kAdvancedArmoryPointValue = 20
kCommandStationHealth = 3000    kCommandStationArmor = 1500    kCommandStationPointValue = 25
kObservatoryHealth = 700    kObservatoryArmor = 500    kObservatoryPointValue = 5
kPhaseGateHealth = 2000    kPhaseGateArmor = 550    kPhaseGatePointValue = 10
kRoboticsFactoryHealth = 2800    kRoboticsFactoryArmor = 600    kRoboticsFactoryPointValue = 10
kARCRoboticsFactoryHealth = 2800    kARCRoboticsFactoryArmor = 600    kARCRoboticsFactoryPointValue = 15
kPrototypeLabHealth = 3000    kPrototypeLabArmor = 500    kPrototypeLabPointValue = 20
kInfantryPortalHealth = 1525    kInfantryPortalArmor = 500    kInfantryPortalPointValue = 10
kArmsLabHealth = 1650    kArmsLabArmor = 500    kArmsLabPointValue = 15
kSentryBatteryHealth = 600    kSentryBatteryArmor = 200    kSentryBatteryPointValue = 2

// 5000/1000 is good average (is like 7,000 health from NS1)
kHiveHealth = 4000    kHiveArmor = 750    kHivePointValue = 25
kMatureHiveHealth = 6000 kMatureHiveArmor = 1400
        
kDrifterHealth = 300    kDrifterArmor = 20    kDrifterPointValue = 2
kMACHealth = 300    kMACArmor = 50    kMACPointValue = 2
kMineHealth = 80    kMineArmor = 10    kMinePointValue = 0
        
kExtractorHealth = 2400 kExtractorArmor = 1050 kExtractorPointValue = 15
kExtractorArmorAddAmount = 700 // not used

// (2500 = NS1)
kHarvesterHealth = 2000 kHarvesterArmor = 200 kHarvesterPointValue = 15
kMatureHarvesterHealth = 2300 kMatureHarvesterArmor = 320

kSentryHealth = 500    kSentryArmor = 100    kSentryPointValue = 2
kARCHealth = 2000    kARCArmor = 500    kARCPointValue = 5
kARCDeployedHealth = 2000    kARCDeployedArmor = 0
        
kShellHealth = 600     kShellArmor = 150     kShellPointValue = 10
kMatureShellHealth = 700     kMatureShellArmor = 200     kShellPointValue = 10

kCragHealth = 600    kCragArmor = 200    kCragPointValue = 10
kMatureCragHealth = 700    kMatureCragArmor = 340    kMatureCragPointValue = 10
        
kWhipHealth = 650    kWhipArmor = 175    kWhipPointValue = 10
kMatureWhipHealth = 720    kMatureWhipArmor = 240    kMatureWhipPointValue = 10
        
kSpurHealth = 800     kSpurArmor = 50     kSpurPointValue = 10
kMatureSpurHealth = 900  kMatureSpurArmor = 100  kMatureSpurPointValue = 10

kShiftHealth = 750    kShiftArmor = 75    kShiftPointValue = 10
kMatureShiftHealth = 1100    kMatureShiftArmor = 150    kMatureShiftPointValue = 10

kVeilHealth = 900     kVeilArmor = 0     kVeilPointValue = 10
kMatureVeilHealth = 1100     kMatureVeilArmor = 0     kVeilPointValue = 10

kShadeHealth = 750    kShadeArmor = 0    kShadePointValue = 10
kMatureShadeHealth = 1500    kMatureShadeArmor = 0    kMatureShadePointValue = 10

kHydraHealth = 350    kHydraArmor = 10    kHydraPointValue = 2
kMatureHydraHealth = 450    kMatureHydraArmor = 50    kMatureHydraPointValue = 2

kClogHealth = 250  kClogArmor = 0 kClogPointValue = 0
kWebHealth = 50

kCystHealth = 70    kCystArmor = 0
kMatureCystHealth = 450    kMatureCystArmor = 0    kCystPointValue = 1

kBoneWallHealth = 100 kBoneWallArmor = 0    kBoneWallHealthPerBioMass = 100
kContaminationHealth = 1000 kContaminationArmor = 0    kContaminationPointValue = 1

kPowerPointHealth = 2000    kPowerPointArmor = 1000    kPowerPointPointValue = 10
kDoorHealth = 2000    kDoorArmor = 1000    kDoorPointValue = 0

kTunnelEntranceHealth = 1000    kTunnelEntranceArmor = 100    kTunnelEntrancePointValue = 5
kMatureTunnelEntranceHealth = 1250    kMatureTunnelEntranceArmor = 200



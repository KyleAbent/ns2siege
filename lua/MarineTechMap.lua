// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MarineTechMap.lua
//
// Created by: Andreas Urwalek (and@unknownworlds.com)
//
// Formatted marine tech tree.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIUtility.lua")

kMarineTechMapYStart = 2
kMarineTechMap =
{

        { kTechId.Extractor, 5, 1 },{ kTechId.CommandStation, 7, 1 },{ kTechId.InfantryPortal, 9, 1 },
        
        { kTechId.RoboticsFactory, 9, 3 },{ kTechId.ARCRoboticsFactory, 10, 2 },{ kTechId.ARC, 11, 2 },
                                          { kTechId.MAC, 10, 3 },
                                          { kTechId.MacWeldMacs, 10, 4 },{ kTechId.Sentry, 11, 4 },
                                          
                                          
        { kTechId.GrenadeTech, 2, 3 },{ kTechId.MinesTech, 3, 3 },{ kTechId.ShotgunTech, 4, 3 },{ kTechId.HeavyRifleTech, 4, 3 },{ kTechId.Welder, 6, 3 },
        
        { kTechId.Armory, 3.5, 4 }, 
         
        { kTechId.AdvancedWeaponry, 2.5, 5.5 }, { kTechId.AdvancedArmory, 3.5, 5.5 }, { kTechId.ArmoryArmor, 4.5, 5.5 },
        
        { kTechId.PrototypeLab, 3.5, 7 },

        { kTechId.ExosuitTech, 3, 8 },{ kTechId.JetpackTech, 4, 8 }, 
    //    { kTechId.DualMinigunTech, 3, 9 },{ kTechId.TwoCommandStations, 5, 9 },
        
        
        { kTechId.ArmsLab, 9, 7 },{ kTechId.Weapons1, 10, 6.5 },{ kTechId.Weapons2, 11, 6.5 },{ kTechId.Weapons3, 12, 6.5 }, { kTechId.RifleClip, 13, 6.5 },
                                  { kTechId.Armor1, 10, 7.5 },{ kTechId.Armor2, 11, 7.5 },{ kTechId.Armor3, 12, 7.5 },
                                  
                                  
        { kTechId.NanoShieldTech, 8, 4.5 },
        { kTechId.CatPackTech, 8, 5.5 },
    //    { kTechId.BluePrintTech, 8, 6.5 },

        { kTechId.Observatory, 6, 5 },{ kTechId.PhaseTech, 6, 6 },{ kTechId.PhaseGate, 6, 7 }, { kTechId.AdvancedBeaconTech, 6, 8 }
                 

}

kMarineLines = 
{
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.Extractor),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.InfantryPortal),
    
    { 7, 1, 7, 7 },
    { 7, 4, 3.5, 4 },
    // observatory:
    { 6, 5, 7, 5 },
    { 7, 7, 9, 7 },
    // nano shield:
    { 7, 4.5, 8, 4.5},
    // cat pack tech:
    { 7, 5.5, 8, 5.5},
    
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.GrenadeTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.MinesTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.ShotgunTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.Welder),

    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.AdvancedArmory),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.AdvancedWeaponry),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.PrototypeLab),
    
    GetLinePositionForTechMap(kMarineTechMap, kTechId.PrototypeLab, kTechId.ExosuitTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.PrototypeLab, kTechId.JetpackTech),
   // GetLinePositionForTechMap(kMarineTechMap, kTechId.ExosuitTech, kTechId.DualMinigunTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.DualMinigunTech, kTechId.TwoCommandStations),
    
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Observatory, kTechId.PhaseTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.PhaseTech, kTechId.PhaseGate),
    
    GetLinePositionForTechMap(kMarineTechMap, kTechId.ArmsLab, kTechId.Weapons1),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Weapons1, kTechId.Weapons2),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Weapons2, kTechId.Weapons3),
    
    GetLinePositionForTechMap(kMarineTechMap, kTechId.ArmsLab, kTechId.Armor1),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armor1, kTechId.Armor2),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armor2, kTechId.Armor3),
    
    { 7, 3, 9, 3 },
    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.ARCRoboticsFactory, kTechId.ARC),

    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.MAC),
 //   GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.SentryBattery),
 //   GetLinePositionForTechMap(kMarineTechMap, kTechId.SentryBattery, kTechId.Sentry),
    
}
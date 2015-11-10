// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AlienTechMap.lua
//
// Created by: Andreas Urwalek (and@unknownworlds.com)
//
// Formatted alien tech tree.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIUtility.lua")

kAlienTechMapYStart = 2
local function CheckHasTech(techId)

    local techTree = GetTechTree()
    return techTree ~= nil and techTree:GetHasTech(techId)

end

local function SetShellIcon(icon)

    if CheckHasTech(kTechId.ThreeShells) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.ThreeShells)))
    elseif CheckHasTech(kTechId.TwoShells) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.TwoShells)))
    else
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.Shell)))
    end    

end

local function SetVeilIcon(icon)

    if CheckHasTech(kTechId.ThreeVeils) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.ThreeVeils)))
    elseif CheckHasTech(kTechId.TwoVeils) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.TwoVeils)))
    else
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.Veil)))
    end
    
end

local function SetSpurIcon(icon)    

    if CheckHasTech(kTechId.ThreeSpurs) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.ThreeSpurs)))
    elseif CheckHasTech(kTechId.TwoSpurs) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.TwoSpurs)))
    else
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.Spur)))
    end 

end

kAlienTechMap =
{
/*
                    { kTechId.Whip, 5.5, 0.5 },          { kTechId.Shift, 6.5, 0.5 },          { kTechId.Shade, 7.5, 0.5 }, { kTechId.Crag, 8.5, 0.5 }, 
                    
                    { kTechId.Harvester, 4, 1.5 },                           { kTechId.Hive, 7, 1.5 },                         { kTechId.UpgradeGorge, 10, 1.5 }, 
  
                   { kTechId.CragHive, 4, 3 },                               { kTechId.ShadeHive, 7, 3 },                            { kTechId.ShiftHive, 10, 3 },
              { kTechId.Shell, 4, 4, SetShellIcon },                     { kTechId.Veil, 7, 4, SetVeilIcon },                    { kTechId.Spur, 10, 4, SetSpurIcon },
  { kTechId.Carapace, 4, 4.5 },{ kTechId.Regeneration, 4.5, 4.5 }, { kTechId.Phantom, 6.5, 5 },{ kTechId.Aura, 7.5, 5 },{ kTechId.Celerity, 9.5, 5 },{ kTechId.Adrenaline, 10.5, 5 },
    //{ kTechId.CragStackOne, 4.3, 5.5 },{ kTechId.CragStackTwo, 5, 5.5 },
            //  { kTechId.CragStackThree, 4.6, 6}, 
           //   { kTechId.CragArcBonus, 4.6, 6.5},
           
           */
                                                               { kTechId.Hive, 4, 1.5 }, { kTechId.Hive, 7, 1.5 },  { kTechId.Hive, 10, 1.5 }, 
                                                               
                                                                {kTechId.BabblerEgg, 4, 2},
                                                                {kTechId.Umbra, 4, 2.5},    {kTechId.Leap, 7, 2},     {kTechId.Xenocide, 10, 2},
                                                                                          {kTechId.BileBomb, 7, 2.5}, {kTechId.SpiderGorge, 10, 2.5},
                                                                                          {kTechId.Spores, 7, 3},     {kTechId.PrimalScream, 10, 3},
                                                                                          {kTechId.MetabolizeHealth, 7, 3.5}, {kTechId.AcidRocket, 10, 3.5},
                                                                                          {kTechId.Charge, 7, 4},       {kTechId.Stomp, 10, 4},
                                                                                          
                                                                                          
                                                  { kTechId.CragHive, 5, 6 },     { kTechId.Regeneration, 5.5, 6 },   { kTechId.Carapace, 6, 6 }, { kTechId.Redemption, 6.5, 6 },   { kTechId.Crag, 7, 6 },   
                                                  { kTechId.ShiftHive, 5, 9 }, { kTechId.Adrenaline, 5.5, 9 },   { kTechId.Celerity, 6, 9 },                                       { kTechId.Shift, 7, 9 },   
                                                  { kTechId.ShadeHive, 5, 12 }, { kTechId.Phantom, 5.5, 12 },   { kTechId.Aura, 6, 12 },                                               { kTechId.Shade, 7, 12 },  
           
  { kTechId.EggBeaconChoiceTwo, 0, 7, nil, "1" }, { kTechId.BioMassOne, 1, 7, nil, "1" }, //{ kTechId.BabblerEgg, 3, 8 }, 
  
 { kTechId.Shell, 0, 8, nil, "2" },  { kTechId.BioMassTwo, 1, 8, nil, "2" }, // {kTechId.Rupture, 4, 8},  { kTechId.Charge, 4, 9 },  
  
 { kTechId.BioMassThree, 1, 9, nil, "3" }, //{kTechId.BoneWall, 5, 8}, {kTechId.BileBomb, 5, 9}, //{ kTechId.MetabolizeEnergy, 5, 10 },

{ kTechId.BioMassFour, 1, 10, nil, "4" },  //{kTechId.Leap, 6, 8}, {kTechId.Umbra, 6, 9},
  
  { kTechId.SmellOrder, 0, 11, nil, "5" },{ kTechId.BioMassFive, 1, 11, nil, "5" }, // {kTechId.BoneShield, 7, 8}, {kTechId.MetabolizeHealth, 7, 10},
  
  { kTechId.ControlledHallucination, 0, 12, nil, "7" }, { kTechId.BioMassSix, 1, 12, nil, "6" },   //{kTechId.Spores, 8, 8},
  
   { kTechId.BioMassSeven, 2, 7, nil, "7" },  //{kTechId.Stab, 9, 8}, 
  
  { kTechId.BioMassEight, 2, 8, nil, "8" }, 
  
  { kTechId.BioMassNine, 2, 9, nil, "9" }, { kTechId.WhipFlameThrowerChanceDrop, 3, 9, nil, "9" }, //{kTechId.Contamination, 11, 8}, {kTechId.Xenocide, 11, 9},
  
 { kTechId.BioMassTen, 2, 10, nil, "10" }, 
 { kTechId.BioMassEleven, 2, 11, nil, "11" }, { kTechId.EggBeaconChoiceOne, 3, 11, nil, "11" },  //{kTechId.PrimalScream, 13, 8},
 { kTechId.BioMassTwelve, 2, 12, nil, "12" },   //{kTechId.AcidRocket, 14, 8}, // {kTechId.PresBonus, 14, 9}, 

}

kAlienLines = 
{
  //  GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.BabblerEgg),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.BabblerEgg, kTechId.Umbra),
    
   // GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Leap),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Leap, kTechId.BileBomb),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.BileBomb, kTechId.Spores),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Spores, kTechId.MetabolizeHealth),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.MetabolizeHealth, kTechId.Charge),
    
   // GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Xenocide),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Xenocide, kTechId.SpiderGorge),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.SpiderGorge, kTechId.PrimalScream),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.PrimalScream, kTechId.AcidRocket),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.AcidRocket, kTechId.Stomp),
  
    GetLinePositionForTechMap(kAlienTechMap, kTechId.CragHive, kTechId.Regeneration),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Regeneration, kTechId.Carapace),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Carapace, kTechId.Redemption),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Redemption, kTechId.Crag),  
    
        GetLinePositionForTechMap(kAlienTechMap, kTechId.ShiftHive, kTechId.Adrenaline),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Adrenaline, kTechId.Celerity),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Celerity, kTechId.Shift),


        GetLinePositionForTechMap(kAlienTechMap, kTechId.ShadeHive, kTechId.Phantom),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Phantom, kTechId.Aura),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Aura, kTechId.Shade),
    
    
    
        GetLinePositionForTechMap(kAlienTechMap, kTechId.BioMassTwo, kTechId.Shell),
        GetLinePositionForTechMap(kAlienTechMap, kTechId.BioMassOne, kTechId.EggBeaconChoiceTwo),
        
        GetLinePositionForTechMap(kAlienTechMap, kTechId.BioMassSix, kTechId.ControlledHallucination),
        GetLinePositionForTechMap(kAlienTechMap, kTechId.BioMassFive, kTechId.SmellOrder),
        
         GetLinePositionForTechMap(kAlienTechMap, kTechId.BioMassEleven, kTechId.EggBeaconChoiceOne),
                                                  
/*
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Crag),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Shift),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Shade),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Whip),
    
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Harvester, kTechId.Hive),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.UpgradeGorge),
    { 7, 1.5, 7, 2.5 },
    { 4, 2.5, 10, 2.5},
    { 4, 2.5, 4, 3},{ 7, 2.5, 7, 3},{ 10, 2.5, 10, 3},
    GetLinePositionForTechMap(kAlienTechMap, kTechId.CragHive, kTechId.Shell),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShadeHive, kTechId.Veil),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShiftHive, kTechId.Spur),
    
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shell, kTechId.Carapace),GetLinePositionForTechMap(kAlienTechMap, kTechId.Shell, kTechId.Regeneration),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Veil, kTechId.Phantom),GetLinePositionForTechMap(kAlienTechMap, kTechId.Veil, kTechId.Aura),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Spur, kTechId.Celerity),GetLinePositionForTechMap(kAlienTechMap, kTechId.Spur, kTechId.Adrenaline),
 */

}






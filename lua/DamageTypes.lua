// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Flamethrower.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Contains all rules regarding damage types. New types behavior can be defined BuildDamageTypeRules().
//
//    Important callbacks for classes:
//
//    ComputeDamageAttackerOverride(attacker, damage, damageType)
//    ComputeDamageAttackerOverrideMixin(attacker, damage, damageType)
//
//    for target:
//    ComputeDamageOverride(attacker, damage, damageType)
//    ComputeDamageOverrideMixin(attacker, damage, damageType)
//    GetArmorUseFractionOverride(damageType, armorFractionUsed)
//    GetReceivesStructuralDamage(damageType)
//    GetReceivesBiologicalDamage(damageType)
//    GetHealthPerArmorOverride(damageType, healthPerArmor)
//
//
//
// Damage types 
// 
// In NS2 - Keep simple and mostly in regard to armor and non-armor. Can't see armor, but players
// and structures spawn with an intuitive amount of armor.
// http://www.unknownworlds.com/ns2/news/2010/6/damage_types_in_ns2
// 
// Normal - Regular damage
// Light - Reduced vs. armor
// Heavy - Extra damage vs. armor
// Puncture - Extra vs. players
// Structural - Double against structures
// GrenadeLauncher - Double against structures with 20% reduction in player damage
// Flamethrower - 5% increase for player damage from structures
// Gas - Breathing targets only (Spores, Nerve Gas GL). Ignores armor.
// StructuresOnly - Doesn't damage players or AI units (ARC)
// Falling - Ignores armor for humans, no damage for some creatures or exosuit
// Door - Like Structural but also does damage to Doors. Nothing else damages Doors.
// Flame - Like normal but catches target on fire and plays special flinch animation
// Corrode - deals normal damage to structures but armor only to non structures
// ArmorOnly - always affects only armor
// Biological - only organic, biological targets (non mechanical)
// StructuresOnlyLight - same as light damage but will not harm players or units which are not valid for structural damage
// Xenocide - +5% against players, +%25 against exo and structure
// Acid - If has armor, then damage armor only. Otherwise if 0 armor, then attack health.
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// utility functions

function GetReceivesStructuralDamage(entity)
    return entity.GetReceivesStructuralDamage and entity:GetReceivesStructuralDamage()
end

function GetReceivesBiologicalDamage(entity)
    return entity.GetReceivesBiologicalDamage and entity:GetReceivesBiologicalDamage()
end

function NS2Gamerules_GetUpgradedDamageScalar( attacker )

    if GetHasTech(attacker, kTechId.Weapons3, true) then            
        return kWeapons3DamageScalar                
    elseif GetHasTech(attacker, kTechId.Weapons2, true) then            
        return kWeapons2DamageScalar                
    elseif GetHasTech(attacker, kTechId.Weapons1, true) then            
        return kWeapons1DamageScalar                
    end
    
    return 1.0

end

// Use this function to change damage according to current upgrades
function NS2Gamerules_GetUpgradedDamage(attacker, doer, damage, damageType, hitPoint)

    local damageScalar = 1

    if attacker ~= nil then
    
        // Damage upgrades only affect weapons, not ARCs, Sentries, MACs, Mines, etc.
        if doer.GetIsAffectedByWeaponUpgrades and doer:GetIsAffectedByWeaponUpgrades() then
        
            damageScalar = NS2Gamerules_GetUpgradedDamageScalar( attacker )
            
        end
        
    end
        
     if attacker:isa("Alien") and GetHasFocusUpgrade(attacker) and not doer:isa("DotMarker") then
      if doer:isa("Spit") or attacker:QualifiesForFocus() then
          damage =  damage + ( (damage/2) * (attacker:GetFocousLevel()) )
      end
    end
    
    return damage * damageScalar
    
end

function Gamerules_GetDamageMultiplier()

    if Server and Shared.GetCheatsEnabled() then
        return GetGamerules():GetDamageMultiplier()
    end

    return 1
    
end

kDamageType = enum( {'Acid', 'Xenocide', 'Normal', 'Light', 'Heavy', 'Puncture', 'PunctureFlame', 'Structural', 'StructuralHeavy', 'Splash', 'Gas', 'NerveGas',
           'StructuresOnly', 'Falling', 'Door', 'Flame', 'Infestation', 'Corrode', 'ArmorOnly', 'Biological', 'StructuresOnlyLight', 'Spreading', 'GrenadeLauncher', 'Flamethrower' } )

// Describe damage types for tooltips
kDamageTypeDesc = {
    "",
    "Light damage: reduced vs. armor",
    "Heavy damage: extra vs. armor",
    "Puncture damage: extra vs. players",
    "PunctureFlame: same as above but with flame damage additions",
    "Structural damage: Double vs. structures",
    "StructuralHeavy damage: Double vs. structures and double vs. armor",
    "Gas damage: affects breathing targets only",
    "NerveGas damage: affects biological units, player will take only armor damage",
    "Structures only: Doesn't damage players or AI units",
    "Falling damage: Ignores armor for humans, no damage for aliens",
    "Door: Can also affect Doors",
    "Corrode damage: Damage structures or armor only for non structures",
    "Armor damage: Will never reduce health",
    "StructuresOnlyLight: Damages structures only, light damage.",
    "Splash: same as structures only but always affects ARCs (friendly fire).",
    "Spreading: Does less damage against small targets.",
    "GrenadeLauncher: Double structure damage, 20% reduction in player damage",
    "Flamethrower: 5% increase from player damage for structures",
    "AlienLifeFormScale: Scaled based on the lifeform it hits.",
    "Xenocide: +5% against players(marine) and +25% against exo/structure.",
    "Acid: if has armor, then do armor dmg only, otherwise effect hp."
}

kSpreadingDamageScalar = 0.75

kBaseArmorUseFraction = 0.7
kExosuitArmorUseFraction = 1 // exos have no health
kStructuralDamageScalar = 2
kPuncturePlayerDamageScalar = 2
kGLPlayerDamageReduction = 0.8
kFTStructureDamage = 1.125

kLightHealthPerArmor = 4
kHealthPointsPerArmor = 2
kHeavyHealthPerArmor = 1

kFlameableMultiplier = 2.5

kCorrodeDamagePlayerArmorScalar = 0.23
kCorrodeDamageExoArmorScalar = 0.3

kStructureLightHealthPerArmor = 9
kStructureLightArmorUseFraction = 0.9

// deal only 33% of damage to friendlies
kFriendlyFireScalar = 0.33

local function ApplyDefaultArmorUseFraction(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, kBaseArmorUseFraction, healthPerArmor
end

local function ApplyHighArmorUseFractionForExos(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    
    if target:isa("Exo") then
        armorFractionUsed = kExosuitArmorUseFraction
    end
    
    return damage, armorFractionUsed, healthPerArmor
    
end

local function ApplyDefaultHealthPerArmor(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, armorFractionUsed, kHealthPointsPerArmor
end

local function DoubleHealthPerArmor(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, armorFractionUsed, healthPerArmor * (kLightHealthPerArmor / kHealthPointsPerArmor)
end

local function HalfHealthPerArmor(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, armorFractionUsed, healthPerArmor * (kHeavyHealthPerArmor / kHealthPointsPerArmor)
end
local function XenocideScale(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
local scale = 1

/*
if  target:isa("Marine") or target:isa("JetpackMarine") and not target:isa("Exo") then
scale = scale * (12/100) + scale
elseif target:isa("Exo") or target.GetReceivesStructuralDamage then
scale = scale * (31/100) + scale
end
*/

damage = damage * scale
 return damage, armorFractionUsed, healthPerArmor 
end

local function Acid(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
if target:GetArmor() >= 1 then
armorFractionUsed = 1
if target.GetReceivesStructuralDamage then
damage = damage * 3
end
end

 return damage, armorFractionUsed, healthPerArmor 
end

local function ApplyAttackerModifiers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)

    damage = NS2Gamerules_GetUpgradedDamage(attacker, doer, damage, damageType, hitPoint)
    damage = damage * Gamerules_GetDamageMultiplier()
    
    if attacker and attacker.ComputeDamageAttackerOverride then
        damage = attacker:ComputeDamageAttackerOverride(attacker, damage, damageType, doer, hitPoint)
    end
    
    if doer and doer.ComputeDamageAttackerOverride then
        damage = doer:ComputeDamageAttackerOverride(attacker, damage, damageType)
    end
    
    if attacker and attacker.ComputeDamageAttackerOverrideMixin then
        damage = attacker:ComputeDamageAttackerOverrideMixin(attacker, damage, damageType, doer, hitPoint)
    end
    
    if doer and doer.ComputeDamageAttackerOverrideMixin then
        damage = doer:ComputeDamageAttackerOverrideMixin(attacker, damage, damageType, doer, hitPoint)
    end

    return damage, armorFractionUsed, healthPerArmor

end


local function ApplyTargetModifiers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor,  damageType, hitPoint)

    // The host can provide an override for this function.
    if target.ComputeDamageOverride then
        damage = target:ComputeDamageOverride(attacker, damage, damageType, hitPoint)
    end

    // Used by mixins.
    if target.ComputeDamageOverrideMixin then
        damage = target:ComputeDamageOverrideMixin(attacker, damage, damageType, hitPoint)
    end
    
    if target.GetArmorUseFractionOverride then
        armorFractionUsed = target:GetArmorUseFractionOverride(damageType, armorFractionUsed, hitPoint)
    end
    
    if target.GetHealthPerArmorOverride then
        healthPerArmor = target:GetHealthPerArmorOverride(damageType, healthPerArmor, hitPoint)
    end
    
    local damageTable = {}
    damageTable.damage = damage
    damageTable.armorFractionUsed = armorFractionUsed
    damageTable.healthPerArmor = healthPerArmor
    
    if target.ModifyDamageTaken then
        target:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)
    end
    
         
    return damageTable.damage, damageTable.armorFractionUsed, damageTable.healthPerArmor

end

local function ApplyFriendlyFireModifier(target, attacker, doer, damage, armorFractionUsed, healthPerArmor,  damageType, hitPoint)

    if target and attacker and target ~= attacker and HasMixin(target, "Team") and HasMixin(attacker, "Team") and target:GetTeamNumber() == attacker:GetTeamNumber() then
        damage = damage * kFriendlyFireScalar
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function IgnoreArmor(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, 0, healthPerArmor
end

local function MaximizeArmorUseFraction(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return damage, 1, healthPerArmor
end

local function MultiplyForStructures(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
        if doer:isa("Flamethrower") then
            damage = damage * kFTStructureDamage
        else
            damage = damage * kStructuralDamageScalar
        end
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function ReduceForPlayersDoubleStructure(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
        damage = damage * kStructuralDamageScalar
   elseif target:isa("Player") and not target:isa("Onos") then
        damage = damage * 1
   elseif target:isa("Onos") then
       damage = damage * kGLPlayerDamageReduction
   end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function FlamethrowerDamage(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
        damage = damage * kFTStructureDamage
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function MultiplyForPlayers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(target:isa("Player") or target:isa("Exosuit"), damage * kPuncturePlayerDamageScalar, damage), armorFractionUsed, healthPerArmor
end
local function MultiplyForPlayersModified(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
   
     if target:isa("Player") or target:isa("Exosuit") then
     damage = damage * kPuncturePlayerDamageScalar
     end
     
     if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) or target:isa("Clog") or target:isa("Egg") then
        damage = damage * 1.10
    end
    
    if HasMixin(target, "Fire") then target:SetOnFire(attacker, doer) end
    
              //  if target.GetEnergy and target.SetEnergy then
              //   target:SetEnergy(target:GetEnergy() - 0.1 * 10) // too much lol
              //  end
                
           if Server and target:isa("Alien") then
                target:CancelEnzyme()
                target:CancelPrimal()
            end
            
    return damage, armorFractionUsed, healthPerArmor
end
local function ReducedDamageAgainstSmall(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)

    if target.GetIsSmallTarget and target:GetIsSmallTarget() then
        damage = damage * kSpreadingDamageScalar
    end

    return damage, armorFractionUsed, healthPerArmor
end

local function IgnoreHealthForPlayers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target:isa("Player") then    
        local maxDamagePossible = healthPerArmor * target.armor
        damage = math.min(damage, maxDamagePossible) 
        armorFractionUsed = 1
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function IgnoreHealthForPlayersUnlessExo(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target:isa("Player") and not target:isa("Exo") then
        local maxDamagePossible = healthPerArmor * target.armor
        damage = math.min(damage, maxDamagePossible) 
        armorFractionUsed = 1
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function IgnoreHealth(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)  
    local maxDamagePossible = healthPerArmor * target.armor
    damage = math.min(damage, maxDamagePossible)
    
    return damage, 1, healthPerArmor
end

local function ReduceGreatlyForPlayers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target:isa("Exo") or target:isa("Exosuit") then
        damage = damage * kCorrodeDamageExoArmorScalar
    elseif target:isa("Player") then
        damage = damage * kCorrodeDamagePlayerArmorScalar
    end
    return damage, armorFractionUsed, healthPerArmor
end

local function IgnorePlayersUnlessExo(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(target:isa("Player") and not target:isa("Exo") , 0, damage), armorFractionUsed, healthPerArmor
end

local function DamagePlayersOnly(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(target:isa("Player") or target:isa("Exosuit"), damage, 0), armorFractionUsed, healthPerArmor
end

local function DamageAlienOnly(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(HasMixin(target, "Team") and target:GetTeamType() == kAlienTeamType, damage, 0), armorFractionUsed, healthPerArmor
end

local function DamageStructuresOnly(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage(damageType) then
        damage = 0
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function IgnoreDoors(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    return ConditionalValue(target:isa("Door"), 0, damage), armorFractionUsed, healthPerArmor
end

local function DamageBiologicalOnly(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if not target.GetReceivesBiologicalDamage or not target:GetReceivesBiologicalDamage(damageType) then
        damage = 0
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function DamageBreathingOnly(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if not target.GetReceivesVaporousDamage or not target:GetReceivesVaporousDamage(damageType) then
        damage = 0
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function MultiplyFlameAble(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) or target:isa("Clog") or target:isa("Egg") then
        damage = damage * 1.10
    end
    
    if HasMixin(target, "Fire") then target:SetOnFire(attacker, doer) end
    
              //  if target.GetEnergy and target.SetEnergy then
              //   target:SetEnergy(target:GetEnergy() - 0.1 * 10) // too much lol
              //  end
                
           if Server and target:isa("Alien") then
                target:CancelEnzyme()
                target:CancelPrimal()
            end
            
    return damage, armorFractionUsed, healthPerArmor
end

local function DoubleHealthPerArmorForStructures(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
        healthPerArmor = healthPerArmor * (kStructureLightHealthPerArmor / kHealthPointsPerArmor)
        armorFractionUsed = kStructureLightArmorUseFraction
    end
    return damage, armorFractionUsed, healthPerArmor
end

kDamageTypeGlobalRules = nil
kDamageTypeRules = nil

/*
 * Define any new damage type behavior in this function
 */
local function BuildDamageTypeRules()

    kDamageTypeGlobalRules = {}
    kDamageTypeRules = {}
    
    // global rules
    table.insert(kDamageTypeGlobalRules, ApplyDefaultArmorUseFraction)
    table.insert(kDamageTypeGlobalRules, ApplyHighArmorUseFractionForExos)
    table.insert(kDamageTypeGlobalRules, ApplyDefaultHealthPerArmor)
    table.insert(kDamageTypeGlobalRules, ApplyAttackerModifiers)
    table.insert(kDamageTypeGlobalRules, ApplyTargetModifiers)
    table.insert(kDamageTypeGlobalRules, ApplyFriendlyFireModifier)
    // ------------------------------
    
    // normal damage rules
    kDamageTypeRules[kDamageType.Normal] = {}
    
    // light damage rules
    kDamageTypeRules[kDamageType.Light] = {}
    table.insert(kDamageTypeRules[kDamageType.Light], DoubleHealthPerArmor)
    // ------------------------------
    
    // heavy damage rules
    kDamageTypeRules[kDamageType.Heavy] = {}
    table.insert(kDamageTypeRules[kDamageType.Heavy], HalfHealthPerArmor)
    // ------------------------------
    // Acid
    kDamageTypeRules[kDamageType.Acid] = {}
    table.insert(kDamageTypeRules[kDamageType.Acid], Acid)
    // ------------------------------
        // Xenocide
    kDamageTypeRules[kDamageType.Xenocide] = {}
    table.insert(kDamageTypeRules[kDamageType.Xenocide], XenocideScale)
    // ------------------------------
    // Puncture damage rules
    kDamageTypeRules[kDamageType.Puncture] = {}
    table.insert(kDamageTypeRules[kDamageType.Puncture], MultiplyForPlayers)
    // ------------------------------
   // Puncture flame rules
    kDamageTypeRules[kDamageType.PunctureFlame] = {}
    table.insert(kDamageTypeRules[kDamageType.PunctureFlame], MultiplyForPlayersModified)
    // ---------
    // Spreading damage rules
    kDamageTypeRules[kDamageType.Spreading] = {}
    table.insert(kDamageTypeRules[kDamageType.Spreading], ReducedDamageAgainstSmall)
    // ------------------------------

    // structural rules
    kDamageTypeRules[kDamageType.Structural] = {}
    table.insert(kDamageTypeRules[kDamageType.Structural], MultiplyForStructures)
    // ------------------------------ 
    
    // Grenade Launcher rules
    kDamageTypeRules[kDamageType.GrenadeLauncher] = {}
    table.insert(kDamageTypeRules[kDamageType.GrenadeLauncher], ReduceForPlayersDoubleStructure)
    // ------------------------------ 
    
    // Grenade Launcher rules
    kDamageTypeRules[kDamageType.Flamethrower] = {}
    table.insert(kDamageTypeRules[kDamageType.Flamethrower], FlamethrowerDamage)
    // ------------------------------ 
    
    // structural heavy rules
    kDamageTypeRules[kDamageType.StructuralHeavy] = {}
    table.insert(kDamageTypeRules[kDamageType.StructuralHeavy], HalfHealthPerArmor)
    table.insert(kDamageTypeRules[kDamageType.StructuralHeavy], MultiplyForStructures)
    // ------------------------------ 
    
    // gas damage rules
    kDamageTypeRules[kDamageType.Gas] = {}
    table.insert(kDamageTypeRules[kDamageType.Gas], IgnoreArmor)
    table.insert(kDamageTypeRules[kDamageType.Gas], DamageBreathingOnly)
    // ------------------------------
   
    // structures only rules
    kDamageTypeRules[kDamageType.StructuresOnly] = {}
    table.insert(kDamageTypeRules[kDamageType.StructuresOnly], DamageStructuresOnly)
    // ------------------------------
    
     // Splash rules
    kDamageTypeRules[kDamageType.Splash] = {}
    table.insert(kDamageTypeRules[kDamageType.Splash], DamageStructuresOnly)
    // ------------------------------
 
    // fall damage rules
    kDamageTypeRules[kDamageType.Falling] = {}
    table.insert(kDamageTypeRules[kDamageType.Falling], IgnoreArmor)
    // ------------------------------

    // Door damage rules
    kDamageTypeRules[kDamageType.Door] = {}
    table.insert(kDamageTypeRules[kDamageType.Door], MultiplyForStructures)
    table.insert(kDamageTypeRules[kDamageType.Door], HalfHealthPerArmor)
    // ------------------------------
    
    // Flame damage rules
    kDamageTypeRules[kDamageType.Flame] = {}
    table.insert(kDamageTypeRules[kDamageType.Flame], MultiplyFlameAble)
   // table.insert(kDamageTypeRules[kDamageType.Flame], MultiplyForStructures)
    // ------------------------------
    
    // Corrode damage rules
    kDamageTypeRules[kDamageType.Corrode] = {}
    table.insert(kDamageTypeRules[kDamageType.Corrode], ReduceGreatlyForPlayers)
    table.insert(kDamageTypeRules[kDamageType.Corrode], IgnoreHealthForPlayersUnlessExo)
    
    // ------------------------------
    // nerve gas rules
    kDamageTypeRules[kDamageType.NerveGas] = {}
    table.insert(kDamageTypeRules[kDamageType.NerveGas], DamageAlienOnly)
    table.insert(kDamageTypeRules[kDamageType.NerveGas], IgnoreHealth)
    // ------------------------------
    
    // StructuresOnlyLight damage rules
    kDamageTypeRules[kDamageType.StructuresOnlyLight] = {}
    table.insert(kDamageTypeRules[kDamageType.StructuresOnlyLight], DoubleHealthPerArmorForStructures)
    // ------------------------------
    
    // ArmorOnly damage rules
    kDamageTypeRules[kDamageType.ArmorOnly] = {}
    table.insert(kDamageTypeRules[kDamageType.ArmorOnly], ReduceGreatlyForPlayers)
    table.insert(kDamageTypeRules[kDamageType.ArmorOnly], IgnoreHealth)    
    // ------------------------------
    
    // Biological damage rules
    kDamageTypeRules[kDamageType.Biological] = {}
    table.insert(kDamageTypeRules[kDamageType.Biological], DamageBiologicalOnly)
    // ------------------------------


end

// applies all rules and returns damage, armorUsed, healthUsed
function GetDamageByType(target, attacker, doer, damage, damageType, hitPoint)

    assert(target)
    
    if not kDamageTypeGlobalRules or not kDamageTypeRules then
        BuildDamageTypeRules()
    end
    
    // at first check if damage is possible, if not we can skip the rest
    if not CanEntityDoDamageTo(attacker, target, Shared.GetCheatsEnabled(), Shared.GetDevMode(), GetFriendlyFire(), damageType) 
       then
        return 0, 0, 0
    end
          
      if Server and not target:isa("PowerPoint") and not target:isa("LogicBreakable") and not target:isa("CommandStructure") and not target:isa("BoneWall") then
            local gameRules = GetGamerules()
            if gameRules then
               if (gameRules:GetGameStarted() and not Shared.GetCheatsEnabled() ) and not ConditionalValue(Shared.GetMapName() == "ns_siegeaholic_remade" or Shared.GetMapName() == "ns2_trainsiege2" or Shared.GetMapName() ==  "ns2_rockdownsiege2", gameRules:GetSideDoorsOpen(), gameRules:GetFrontDoorsOpen()) then 
                   return 0, 0, 0
               end
            end
          end
          if attacker:isa("Player") and not target:isa("FuncDoor") then
          local trace = Shared.TraceRay(attacker:GetOrigin(), target:GetOrigin(), CollisionRep.Move, PhysicsMask.FuncMoveable, EntityFilterAllButIsa("FuncDoor"))  
                if trace.entity ~= nil and ( trace.entity:isa("FuncDoor") and ( trace.entity:GetState() == FuncDoor.kState.Welded or trace.entity:GetState() == FuncDoor.kState.Locked ) )then 
        return 0, 0,0
      end
          end
    local armorUsed = 0
    local healthUsed = 0
    
    local armorFractionUsed, healthPerArmor = 0
    
    // apply global rules at first
    for _, rule in ipairs(kDamageTypeGlobalRules) do
        damage, armorFractionUsed, healthPerArmor = rule(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    end
    
    // apply damage type specific rules
    for _, rule in ipairs(kDamageTypeRules[damageType]) do
        damage, armorFractionUsed, healthPerArmor = rule(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    end
    
    if damage > 0 and healthPerArmor > 0 then

        // Each point of armor blocks a point of health but is only destroyed at half that rate (like NS1)
        // Thanks Harimau!
        local healthPointsBlocked = math.min(healthPerArmor * target.armor, armorFractionUsed * damage)
        armorUsed = healthPointsBlocked / healthPerArmor
        
        // Anything left over comes off of health
        healthUsed = damage - healthPointsBlocked

    end
    
    return damage, armorUsed, healthUsed

end
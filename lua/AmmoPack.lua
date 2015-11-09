// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AmmoPack.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/DropPack.lua")

class 'AmmoPack' (DropPack)

AmmoPack.kMapName = "ammopack"

AmmoPack.kModelName = PrecacheAsset("models/marine/ammopack/ammopack.model")
AmmoPack.kPickupSound = PrecacheAsset("sound/NS2.fev/marine/common/pickup_ammo")

AmmoPack.kNumClips = 5

function AmmoPack:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel(AmmoPack.kModelName)
	
end

function AmmoPack:OnTouch(recipient)

    local weapon = recipient:GetActiveWeapon()
    
    local consumedPack = false
    
    for i = 0, recipient:GetNumChildren() - 1 do
    
        local child = recipient:GetChildAtIndex(i)
        if child:isa("ClipWeapon") then
        
            if child:GiveAmmo(AmmoPack.kNumClips, false) then
                consumedPack = true
            end
            
        end
        
    end  
    
    if consumedPack then
        StartSoundEffectAtOrigin(AmmoPack.kPickupSound, recipient:GetOrigin())
    end
    
end
function GetAmmoPackLimit(techId, origin, normal, commander)
    local ammopacks = 0
        for index, ammopack in ientitylist(Shared.GetEntitiesWithClassname("AmmoPack")) do
                ammopacks = ammopacks + 1 
         end
    return  ammopacks <= 9
    
end
function AmmoPack:GetIsValidRecipient(recipient)

	if not recipient:isa("Marine") then
		return false
	end
	
    local needsAmmo = false
    
    for i = 0, recipient:GetNumChildren() - 1 do
    
        local child = recipient:GetChildAtIndex(i)
        if child:isa("ClipWeapon") and child:GetNeedsAmmo(false) then
        
            needsAmmo = true
            break
            
        end
        
    end 

    // Ammo packs give ammo to clip as well (so pass true to GetNeedsAmmo())
    return needsAmmo
    
end

Shared.LinkClassToMap("AmmoPack", AmmoPack.kMapName)

class 'WeaponAmmoPack' (AmmoPack)
WeaponAmmoPack.kMapName = "weapoanammopack"

function WeaponAmmoPack:SetAmmoPackSize(size)
    self.ammoPackSize = size
end

function WeaponAmmoPack:OnTouch(recipient)

    local weapon = recipient:GetActiveWeapon()
    weapon:GiveReserveAmmo(self.ammoPackSize)
    StartSoundEffectAtOrigin(AmmoPack.kPickupSound, recipient:GetOrigin())
    
end

function WeaponAmmoPack:GetIsValidRecipient(recipient)
	
    local weapon = recipient:GetActiveWeapon()
    local correctWeaponType = weapon and weapon:isa(self:GetWeaponClassName())    
    return self.ammoPackSize ~= nil and correctWeaponType and AmmoPack.GetIsValidRecipient(self, recipient)
    
end

Shared.LinkClassToMap("WeaponAmmoPack", WeaponAmmoPack.kMapName)

// -------------

class 'RifleAmmo' (WeaponAmmoPack)
RifleAmmo.kMapName = "rifleammo"
RifleAmmo.kModelName = PrecacheAsset("models/marine/rifle/rifleammo.model")

function RifleAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)
    self:SetModel(RifleAmmo.kModelName)

end

function RifleAmmo:GetWeaponClassName()
    return "Rifle"
end  

Shared.LinkClassToMap("RifleAmmo", RifleAmmo.kMapName)

// -------------

class 'ShotgunAmmo' (WeaponAmmoPack)
ShotgunAmmo.kMapName = "shotgunammo"
ShotgunAmmo.kModelName = PrecacheAsset("models/marine/shotgun/shotgunammo.model")

function ShotgunAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)    
    self:SetModel(ShotgunAmmo.kModelName)

end

function ShotgunAmmo:GetWeaponClassName()
    return "Shotgun"
end    

Shared.LinkClassToMap("ShotgunAmmo", ShotgunAmmo.kMapName)

// -------------

class 'FlamethrowerAmmo' (WeaponAmmoPack)
FlamethrowerAmmo.kMapName = "flamethrowerammo"
FlamethrowerAmmo.kModelName = PrecacheAsset("models/marine/flamethrower/flamethrowerammo.model")

function FlamethrowerAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)    
    self:SetModel(FlamethrowerAmmo.kModelName)

end

function FlamethrowerAmmo:GetWeaponClassName()
    return "Flamethrower"
end

Shared.LinkClassToMap("FlamethrowerAmmo", FlamethrowerAmmo.kMapName)

// -------------

class 'GrenadeLauncherAmmo' (WeaponAmmoPack)
GrenadeLauncherAmmo.kMapName = "grenadelauncherammo"
GrenadeLauncherAmmo.kModelName = PrecacheAsset("models/marine/grenadelauncher/grenadelauncherammo.model")

function GrenadeLauncherAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)    
    self:SetModel(GrenadeLauncherAmmo.kModelName)

end

function GrenadeLauncherAmmo:GetWeaponClassName()
    return "GrenadeLauncher"
end

Shared.LinkClassToMap("GrenadeLauncherAmmo", GrenadeLauncherAmmo.kMapName)
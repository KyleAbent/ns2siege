// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\PickupableWeaponMixin.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

PickupableWeaponMixin = CreateMixin(PickupableWeaponMixin)
PickupableWeaponMixin.type = "Pickupable"

PickupableWeaponMixin.expectedCallbacks =
{
    GetParent = "Returns the parent entity of this pickupable."
}

function PickupableWeaponMixin:__initmixin()
end

function PickupableWeaponMixin:GetIsValidRecipient(recipient)
    return recipient:isa("Marine") and self.weaponWorldState == true
end

function PickupableWeaponMixin:OnUpdate(deltaTime)
    PROFILE("PickupableWeaponMixin:OnUpdate")
    if Client then
        EquipmentOutline_UpdateModel(self)
    end
    
end

function PickupableWeaponMixin:OnProcessMove(input)

    if Client then
        EquipmentOutline_UpdateModel(self)
    end
    
end
// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\OnosVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")

OnosVariantMixin = CreateMixin(OnosVariantMixin)
OnosVariantMixin.type = "OnosVariant"

OnosVariantMixin.kModelNames = {}
OnosVariantMixin.kViewModelNames = {}

for variant, data in pairs(kOnosVariantData) do
    OnosVariantMixin.kModelNames[variant] = PrecacheAsset("models/alien/onos/onos" .. data.modelFilePart .. ".model" )
end

OnosVariantMixin.kViewModelNames = {}
for variant, data in pairs(kOnosVariantData) do
    OnosVariantMixin.kViewModelNames[variant] = PrecacheAsset("models/alien/onos/onos" .. data.viewModelFilePart .. "_view.model" )
end

OnosVariantMixin.kDefaultModelName = OnosVariantMixin.kModelNames[kDefaultOnosVariant]
local kOnosAnimationGraph = PrecacheAsset("models/alien/onos/onos.animation_graph")

OnosVariantMixin.networkVars =
{
    variant = "enum kOnosVariant",
}

function OnosVariantMixin:__initmixin()

    self.variant = kDefaultOnosVariant
    
end

function OnosVariantMixin:GetVariant()
    return self.variant
end

function OnosVariantMixin:SetVariant(variant)
    self.variant = variant
    self:SetModel(self:GetVariantModel(), kOnosAnimationGraph)
end

function OnosVariantMixin:GetVariantModel()
    return OnosVariantMixin.kModelNames[ self.variant ]
end

function OnosVariantMixin:GetVariantViewModel()
    return OnosVariantMixin.kViewModelNames[ self.variant ]
end

if Server then

    // Usually because the client connected or changed their options
    function OnosVariantMixin:OnClientUpdated(client)

        Player.OnClientUpdated( self, client )

        local data = client.variantData
        if data == nil then
            return
        end

        local changed = data.onosVariant ~= self.variant

        if self.GetIgnoreVariantModels and self:GetIgnoreVariantModels() then
            return
        end
        
        if GetHasVariant( kOnosVariantData, data.onosVariant, client ) or client:GetIsVirtual() then

            // cleared, pass info to clients
            self.variant = data.onosVariant
            assert( self.variant ~= -1 )
            local modelName = self:GetVariantModel()
            assert( modelName ~= "" )
            self:SetModel(modelName, kOnosAnimationGraph)

        else
            Print("ERROR: Client tried to request onos variant they do not have yet")
        end

        if changed then
        
            // Trigger a weapon switch, to update the view model
            if self:GetActiveWeapon() ~= nil then
                self:GetActiveWeapon():OnDraw(self)
            end        
            
        end
            
    end

end

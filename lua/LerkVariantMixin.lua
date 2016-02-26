// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\LerkVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")

LerkVariantMixin = CreateMixin(LerkVariantMixin)
LerkVariantMixin.type = "LerkVariant"

LerkVariantMixin.kModelNames = {}
LerkVariantMixin.kViewModelNames = {}

for variant, data in pairs(kLerkVariantData) do
    LerkVariantMixin.kModelNames[variant] = PrecacheAsset("models/alien/lerk/lerk" .. data.modelFilePart .. ".model" )
end

LerkVariantMixin.kViewModelNames = {}
for variant, data in pairs(kLerkVariantData) do
    LerkVariantMixin.kViewModelNames[variant] = PrecacheAsset("models/alien/lerk/lerk" .. data.viewModelFilePart .. "_view.model" )
end

LerkVariantMixin.kDefaultModelName = LerkVariantMixin.kModelNames[kDefaultLerkVariant]
local kLerkAnimationGraph = PrecacheAsset("models/alien/lerk/lerk.animation_graph")

LerkVariantMixin.networkVars =
{
    variant = "enum kLerkVariant",
}

function LerkVariantMixin:__initmixin()

    self.variant = kDefaultLerkVariant
    
end

function LerkVariantMixin:GetVariant()
    return self.variant
end

function LerkVariantMixin:SetVariant(variant)
    self.variant = variant
    self:SetModel(self:GetVariantModel(), kLerkAnimationGraph)
end

function LerkVariantMixin:GetVariantModel()
    return LerkVariantMixin.kModelNames[ self.variant ]
end

function LerkVariantMixin:GetVariantViewModel()
    return LerkVariantMixin.kViewModelNames[ self.variant ]
end

if Server then

    // Usually because the client connected or changed their options
    function LerkVariantMixin:OnClientUpdated(client)

        Player.OnClientUpdated( self, client )

        local data = client.variantData
        if data == nil then
            return
        end

        local changed = data.lerkVariant ~= self.variant

        if self.GetIgnoreVariantModels and self:GetIgnoreVariantModels() then
            return
        end
        
        if GetHasVariant( kLerkVariantData, data.lerkVariant, client ) or client:GetIsVirtual() then

            // cleared, pass info to clients
            self.variant = data.lerkVariant
            assert( self.variant ~= -1 )
            local modelName = self:GetVariantModel()
            assert( modelName ~= "" )
            self:SetModel(modelName, kLerkAnimationGraph)

        else
            Print("ERROR: Client tried to request lerk variant they do not have yet")
        end

        if changed then
        
            // Trigger a weapon switch, to update the view model
            if self:GetActiveWeapon() ~= nil then
                self:GetActiveWeapon():OnDraw(self)
            end        
            
        end
            
    end

end

// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\SkulkVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")

SkulkVariantMixin = CreateMixin(SkulkVariantMixin)
SkulkVariantMixin.type = "SkulkVariant"

SkulkVariantMixin.kModelNames = {}
SkulkVariantMixin.kViewModelNames = {}

for variant, data in pairs(kSkulkVariantData) do
    SkulkVariantMixin.kModelNames[variant] = PrecacheAsset("models/alien/skulk/skulk" .. data.modelFilePart .. ".model" )
end

SkulkVariantMixin.kViewModelNames = {}
for variant, data in pairs(kSkulkVariantData) do
    SkulkVariantMixin.kViewModelNames[variant] = PrecacheAsset("models/alien/skulk/skulk" .. data.viewModelFilePart .. "_view.model" )
end

SkulkVariantMixin.kDefaultModelName = SkulkVariantMixin.kModelNames[kDefaultSkulkVariant]
local kSkulkAnimationGraph = PrecacheAsset("models/alien/skulk/skulk.animation_graph")

SkulkVariantMixin.networkVars =
{
    variant = "enum kSkulkVariant",
}

function SkulkVariantMixin:__initmixin()

    self.variant = kDefaultSkulkVariant
    
end

function SkulkVariantMixin:GetVariant()
    return self.variant
end

function SkulkVariantMixin:SetVariant(variant)
    self.variant = variant
    self:SetModel(self:GetVariantModel(), kSkulkAnimationGraph)
end

function SkulkVariantMixin:GetVariantModel()
    return SkulkVariantMixin.kModelNames[ self.variant ]
end

function SkulkVariantMixin:GetVariantViewModel()
    return SkulkVariantMixin.kViewModelNames[ self.variant ]
end

if Server then

    // Usually because the client connected or changed their options
    function SkulkVariantMixin:OnClientUpdated(client)

        Player.OnClientUpdated( self, client )

        local data = client.variantData
        if data == nil then
            return
        end

        local changed = data.skulkVariant ~= self.variant

        if self.GetIgnoreVariantModels and self:GetIgnoreVariantModels() then
            return
        end
        
        if GetHasVariant( kSkulkVariantData, data.skulkVariant, client ) or client:GetIsVirtual() then

            // cleared, pass info to clients
            self.variant = data.skulkVariant
            assert( self.variant ~= -1 )
            local modelName = self:GetVariantModel()
            assert( modelName ~= "" )
            self:SetModel(modelName, kSkulkAnimationGraph)

        else
            Print("ERROR: Client tried to request skulk variant they do not have yet")
        end

        if changed then
        
            // Trigger a weapon switch, to update the view model
            if self:GetActiveWeapon() ~= nil then
                self:GetActiveWeapon():OnDraw(self)
            end        
            
        end
            
    end

end

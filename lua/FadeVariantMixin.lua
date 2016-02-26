// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\FadeVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")

FadeVariantMixin = CreateMixin(FadeVariantMixin)
FadeVariantMixin.type = "FadeVariant"

FadeVariantMixin.kModelNames = {}
FadeVariantMixin.kViewModelNames = {}

for variant, data in pairs(kFadeVariantData) do
    FadeVariantMixin.kModelNames[variant] = PrecacheAsset("models/alien/fade/fade" .. data.modelFilePart .. ".model" )
end

FadeVariantMixin.kViewModelNames = {}
for variant, data in pairs(kFadeVariantData) do
    FadeVariantMixin.kViewModelNames[variant] = PrecacheAsset("models/alien/fade/fade" .. data.viewModelFilePart .. "_view.model" )
end

FadeVariantMixin.kDefaultModelName = FadeVariantMixin.kModelNames[kDefaultFadeVariant]
local kFadeAnimationGraph = PrecacheAsset("models/alien/fade/fade.animation_graph")

FadeVariantMixin.networkVars =
{
    variant = "enum kFadeVariant",
}

function FadeVariantMixin:__initmixin()

    self.variant = kDefaultFadeVariant
    
end

function FadeVariantMixin:GetVariant()
    return self.variant
end

function FadeVariantMixin:SetVariant(variant)
    self.variant = variant
    self:SetModel(self:GetVariantModel(), kFadeAnimationGraph)
end

function FadeVariantMixin:GetVariantModel()
    return FadeVariantMixin.kModelNames[ self.variant ]
end

function FadeVariantMixin:GetVariantViewModel()
    return FadeVariantMixin.kViewModelNames[ self.variant ]
end

if Server then

    // Usually because the client connected or changed their options
    function FadeVariantMixin:OnClientUpdated(client)

        Player.OnClientUpdated( self, client )

        local data = client.variantData
        if data == nil then
            return
        end

        local changed = data.fadeVariant ~= self.variant

        if self.GetIgnoreVariantModels and self:GetIgnoreVariantModels() then
            return
        end
        
        if GetHasVariant( kFadeVariantData, data.fadeVariant, client ) or client:GetIsVirtual() then

            // cleared, pass info to clients
            self.variant = data.fadeVariant
            assert( self.variant ~= -1 )
            local modelName = self:GetVariantModel()
            assert( modelName ~= "" )
            self:SetModel(modelName, kFadeAnimationGraph)

        else
            Print("ERROR: Client tried to request fade variant they do not have yet")
        end

        if changed then
        
            // Trigger a weapon switch, to update the view model
            if self:GetActiveWeapon() ~= nil then
                self:GetActiveWeapon():OnDraw(self)
            end        
            
        end
            
    end

end

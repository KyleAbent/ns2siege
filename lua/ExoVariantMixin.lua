// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\ExoVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

ExoVariantMixin = CreateMixin(ExoVariantMixin)
ExoVariantMixin.type = "ExoVariant"

local kDefaultVariantData = kExoVariantData[ kDefaultExoVariant ]

// precache models for all variants
ExoVariantMixin.kModelNames = { cm = { }, cr = { }, rr = {}, mm = { } }

local function MakeModelPath( weapon, suffix )
    return "models/marine/exosuit/exosuit_"..weapon..suffix..".model"
end

for variant, data in pairs(kExoVariantData) do
    ExoVariantMixin.kModelNames.cm[variant] = PrecacheAssetSafe( MakeModelPath("cm", data.modelFilePart), MakeModelPath("cm", kDefaultVariantData.modelFilePart) )
end
for variant, data in pairs(kExoVariantData) do
    ExoVariantMixin.kModelNames.cr[variant] = PrecacheAssetSafe( MakeModelPath("cr", data.modelFilePart), MakeModelPath("cr", kDefaultVariantData.modelFilePart) )
end
for variant, data in pairs(kExoVariantData) do
    ExoVariantMixin.kModelNames.rr[variant] = PrecacheAssetSafe( MakeModelPath("rr", data.modelFilePart), MakeModelPath("rr", kDefaultVariantData.modelFilePart) )
end
for variant, data in pairs(kExoVariantData) do
    ExoVariantMixin.kModelNames.mm[variant] = PrecacheAssetSafe( MakeModelPath("mm", data.modelFilePart), MakeModelPath("mm", kDefaultVariantData.modelFilePart) )
end

ExoVariantMixin.kDefaultModelName = ExoVariantMixin.kModelNames.cm[kDefaultExoVariant]

ExoVariantMixin.kExoAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit.animation_graph")

ExoVariantMixin.networkVars =
{
    exoVariant = "enum kExoVariant",
    clientUserId = "integer"
}

function ExoVariantMixin:__initmixin()

    self.exoVariant = kDefaultExoVariant
    self.clientUserId = 0
    
end

function ExoVariantMixin:GetExoVariant()
    return self.exoVariant
end

function ExoVariantMixin:GetClientId()
    return self.clientUserId
end

function ExoVariantMixin:SetExoVariant(variant)
    self.exoVariant = variant
end

if Server then

    // Usually because the client connected or changed their options.
    function ExoVariantMixin:OnClientUpdated(client)
    
        Player.OnClientUpdated(self, client)
        
        local data = client.variantData
        if data == nil then
            return
        end

        if GetHasVariant(kExoVariantData, data.exoVariant, client) then
        
            // Cleared, pass info to clients.
            self.exoVariant = data.exoVariant
            self.clientUserId = client:GetUserId()
            
        else
            Print("ERROR: Client tried to request Exo variant they do not have yet")
        end
        
    end
    
end

if Client then

    function ExoVariantMixin:OnUpdateRender()

        if self:GetRenderModel() ~= nil then
            self:GetRenderModel():SetMaterialParameter("textureIndex", self.exoVariant-1)
        end
        
		if self:isa("Player") and self:GetIsLocalPlayer() then
		
			local viewModel = self:GetViewModelEntity()
			if viewModel and viewModel:GetRenderModel() then
				viewModel:GetRenderModel():SetMaterialParameter("textureIndex", self.exoVariant-1)
			end
            
        end

    end

end
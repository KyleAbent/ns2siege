// ======= Copyright (c) 2016, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\ShotgunVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

ShotgunVariantMixin = CreateMixin(ShotgunVariantMixin)
ShotgunVariantMixin.type = "ShotgunVariant"

local kDefaultVariantData = kShotgunVariantData[ kDefaultShotgunVariant ]

// precache models for all variants
ShotgunVariantMixin.kModelNames = { shotgun = { } }

local function MakeModelPath( suffix )
    return "models/marine/shotgun/shotgun" .. suffix .. ".model"
end

for variant, data in pairs(kShotgunVariantData) do
    ShotgunVariantMixin.kModelNames.shotgun[variant] = PrecacheAssetSafe( MakeModelPath( data.modelFilePart), MakeModelPath( kDefaultVariantData.modelFilePart) )
end

ShotgunVariantMixin.kDefaultModelName = ShotgunVariantMixin.kModelNames.shotgun[kDefaultShotgunVariant]

ShotgunVariantMixin.kShotgunAnimationGraph = PrecacheAsset("models/marine/shotgun/shotgun_view.animation_graph")

ShotgunVariantMixin.networkVars = 
{
    shotgunVariant = "enum kShotgunVariant",
    clientUserId = "integer"
}

function ShotgunVariantMixin:__initmixin()

    self.shotgunVariant = kDefaultShotgunVariant
    self.clientUserId = 0
    
end

function ShotgunVariantMixin:GetShotgunVariant()
    return self.shotgunVariant
end

function ShotgunVariantMixin:GetClientId()
    return self.clientUserId
end

function ShotgunVariantMixin:GetVariantModel()
    return ShotgunVariantMixin.kModelNames.shotgun[ self.shotgunVariant ]
end

if Server then
    
    // Usually because the client connected or changed their options.
    function ShotgunVariantMixin:UpdateWeaponSkins(client)
        local data = client.variantData
        if data == nil then
            return
        end
        
        if GetHasVariant(kShotgunVariantData, data.shotgunVariant, client) or client:GetIsVirtual() then
            // Cleared, pass info to clients.
            self.shotgunVariant = data.shotgunVariant
            self.clientUserId = client:GetUserId()
            
            assert(self.shotgunVariant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel( modelName )
            
        else
            Print("ERROR: Client tried to request Shotgun variant they do not have yet")
        end
    end
    
end

function ShotgunVariantMixin:OnUpdateRender()
                
    if self:GetRenderModel() ~= nil then
        self:GetRenderModel():SetMaterialParameter("textureIndex", self.shotgunVariant-1)
    end

    local player = self:GetParent()
    if player and player:GetIsLocalPlayer() then
        
        local viewModel = player:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() and player:isa("Marine") then
            viewModel:GetRenderModel():SetMaterialParameter("textureIndex", self.shotgunVariant-1)
        end
        
    end
end
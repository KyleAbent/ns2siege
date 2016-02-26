// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\MarineVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

MarineVariantMixin = CreateMixin(MarineVariantMixin)
MarineVariantMixin.type = "MarineVariant"

local kDefaultVariantData = kMarineVariantData[ kDefaultMarineVariant ]

// Utiliy function for other models that are dependent on marine variant
function GenerateMarineViewModelPaths(weaponName)

    local viewModels = { male = { }, female = { } }
    
    local function MakePath( prefix, suffix )
        return "models/marine/"..weaponName.."/"..prefix..weaponName.."_view"..suffix..".model"
    end
    
    for variant, data in pairs(kMarineVariantData) do
        viewModels.male[variant] = PrecacheAssetSafe( MakePath("", data.viewModelFilePart), MakePath("", kDefaultVariantData.viewModelFilePart) )
    end
    
    for variant, data in pairs(kMarineVariantData) do
        viewModels.female[variant] = PrecacheAssetSafe( MakePath("female_", data.viewModelFilePart), MakePath("female_", kDefaultVariantData.viewModelFilePart) )
    end
    
    return viewModels
    
end

// precache models fror all variants
MarineVariantMixin.kModelNames = { male = { }, female = { } }

local function MakeModelPath( gender, suffix )
    return "models/marine/"..gender.."/"..gender..suffix..".model"
end

for variant, data in pairs(kMarineVariantData) do
    MarineVariantMixin.kModelNames.male[variant] = PrecacheAssetSafe( MakeModelPath("male", data.modelFilePart), MakeModelPath("male", kDefaultVariantData.modelFilePart) )
end

for variant, data in pairs(kMarineVariantData) do
    MarineVariantMixin.kModelNames.female[variant] = PrecacheAssetSafe( MakeModelPath("female", data.modelFilePart), MakeModelPath("female", kDefaultVariantData.modelFilePart) )
end

MarineVariantMixin.kDefaultModelName = MarineVariantMixin.kModelNames.male[kDefaultMarineVariant]

MarineVariantMixin.kMarineAnimationGraph = PrecacheAsset("models/marine/male/male.animation_graph")

MarineVariantMixin.networkVars =
{
    shoulderPadIndex = string.format("integer (0 to %d)",  #kShoulderPad2ItemId),
    isMale = "boolean",
    variant = "enum kMarineVariant",
}

function MarineVariantMixin:__initmixin()

    self.isMale = true
    self.variant = kDefaultMarineVariant
    self.shoulderPadIndex = 0
    
end

function MarineVariantMixin:GetGenderString()
    return self.isMale and "male" or "female"
end

function MarineVariantMixin:GetIsMale()
    return self.isMale
end

function MarineVariantMixin:GetVariant()
    return self.variant
end

function MarineVariantMixin:GetEffectParams(tableParams)
    tableParams[kEffectFilterSex] = self:GetGenderString()
end

function MarineVariantMixin:GetVariantModel()
    return MarineVariantMixin.kModelNames[ self:GetGenderString() ][ self.variant ]
end

if Server then

    // Usually because the client connected or changed their options.
    function MarineVariantMixin:OnClientUpdated(client)
    
        Player.OnClientUpdated(self, client)
        
        local data = client.variantData
        if data == nil then
            return
        end
        
        local changed = data.isMale ~= self.isMale or data.marineVariant ~= self.variant
        
        self.isMale = data.isMale
        
        self.shoulderPadIndex = 0
        
        local selectedIndex = client.variantData.shoulderPadIndex
        
        if GetHasShoulderPad(selectedIndex, client) then
            self.shoulderPadIndex = selectedIndex
        end
        
        // Trigger a weapon skin update, to update the view model
        if self:GetActiveWeapon() ~= nil then
            self:UpdateWeaponSkin(client)
        end
        
        // Some entities using MarineVariantMixin don't care about model changes.
        if self.GetIgnoreVariantModels and self:GetIgnoreVariantModels() then
            return
        end
        
        if GetHasVariant(kMarineVariantData, data.marineVariant, client) or client:GetIsVirtual() then
        
            // Cleared, pass info to clients.
            self.variant = data.marineVariant
            assert(self.variant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel(modelName, MarineVariantMixin.kMarineAnimationGraph)
            
        else
            Print("ERROR: Client tried to request marine variant they do not have yet")
        end

        if changed then
        
            // Trigger a weapon switch, to update the view model
            if self:GetActiveWeapon() ~= nil then
                self:GetActiveWeapon():OnDraw(self)
                self:UpdateWeaponSkin(client)
            end
            
        end
        
    end
    
end

if Client then

    function MarineVariantMixin:OnUpdateRender()

        // update player patch
        if self:GetRenderModel() ~= nil then
            self:GetRenderModel():SetMaterialParameter("patchIndex", self.shoulderPadIndex-2)
        end

    end

end
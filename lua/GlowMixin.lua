//SiegeMod Kyle abent 2015
GlowMixin = CreateMixin( GlowMixin )
GlowMixin.type = "Glow"


----------------------Glow Purple----------------------
PrecacheAsset("Glow/purple/GlowTP.surface_shader")
PrecacheAsset("Glow/purple/GlowViewMarine.surface_shader")
PrecacheAsset("Glow/purple/GlowViewExo.surface_shader")
local kMaterialPurple = PrecacheAsset("Glow/purple/purple.material")
local kExoViewMaterialPurple = PrecacheAsset("Glow/purple/exoview_purple.material")
local kViewMaterialPurple = PrecacheAsset("Glow/purple/view_purple.material")
----------------------Glow Purple----------------------

----------------------Glow Green----------------------
PrecacheAsset("Glow/green/GlowTP.surface_shader")
PrecacheAsset("Glow/green/GlowViewMarine.surface_shader")
PrecacheAsset("Glow/green/GlowViewExo.surface_shader")
local kMaterialGreen = PrecacheAsset("Glow/green/green.material")
local kExoViewMaterialGreen = PrecacheAsset("Glow/green/exoview_green.material")
local kViewMaterialGreen = PrecacheAsset("Glow/green/view_green.material")
----------------------Glow Green----------------------

GlowMixin.overrideFunctions =
{
}

GlowMixin.expectedMixins =
{
}

GlowMixin.optionalCallbacks =
{
}

GlowMixin.networkVars =
{
    Glowing = "boolean",
    Color = "float (1 to 2 by 1)",
}

function GlowMixin:__initmixin()

    if Server then
        kNumberofGlows = 2 // for rtd
        self.timeofStartGlow = 0
        self.Glowing = false
        self.Color = 1
        
    end
    
end

local function ClearGlow(self)

    self.Glowing = false
    self.timeofStartGlow = 0    
    
    if Client then
        self:_RemoveGlow()
    end
   
    
end

function GlowMixin:OnDestroy()

    if self:GetIsGlowing() then
        ClearGlow(self)
    end
    
end
function GlowMixin:GlowColor(color, duration)

        self.Color = color
        self.timeofStartGlow = Shared.GetTime() + duration
        self.Glowing = true
    
end
function GlowMixin:ClearGlow()

        ClearGlow(self)
    
end
function GlowMixin:GetIsGlowing()
    return self.Glowing
end
local function UpdateClientGlowEffects(self)

    assert(Client)
    
    if self:GetIsGlowing() and self:GetIsAlive() then //and not (not self:GetHasRespawnProtection() and self:GetIsNanoShielded() ) then
        self:_CreateGlow()
    else
        self:_RemoveGlow() 
    end
    
end

local function SharedUpdate(self)

    if Server then
    
        if not self:GetIsGlowing() then
            return
        end
        

        if self.timeofStartGlow < Shared.GetTime() then
            ClearGlow(self)
        end
       
    elseif Client and not Shared.GetIsRunningPrediction() then
        UpdateClientGlowEffects(self)
    end
    
end
function GlowMixin:OnUpdate(deltaTime)   
    SharedUpdate(self)
end

function GlowMixin:OnProcessMove(input)   
    SharedUpdate(self)
end

if Client then

    local function AddGlow(entity, material, viewMaterial, entities)
    
        local numChildren = entity:GetNumChildren()
        
        if HasMixin(entity, "Model") then
            local model = entity._renderModel
            if model ~= nil then
                if model:GetZone() == RenderScene.Zone_ViewModel then
                    model:AddMaterial(viewMaterial)
                else
                    model:AddMaterial(material)
                end
                table.insert(entities, entity:GetId())
            end
        end
        
        for i = 1, entity:GetNumChildren() do
            local child = entity:GetChildAtIndex(i - 1)
            AddGlow(child, material, viewMaterial, entities)
        end
    
    end
    
    local function RemoveGlow(entities, material, viewMaterial)
    
        for i =1, #entities do
            local entity = Shared.GetEntity( entities[i] )
            if entity ~= nil and HasMixin(entity, "Model") then
                local model = entity._renderModel
                if model ~= nil then
                    if model:GetZone() == RenderScene.Zone_ViewModel then
                        model:RemoveMaterial(viewMaterial)
                    else
                        model:RemoveMaterial(material)
                    end
                end                    
            end
        end
        
    end

    function GlowMixin:_CreateGlow()
   
        if not self.ColorMaterial then
        
            local material = Client.CreateRenderMaterial()
            if self.Color == 1 then
            material:SetMaterial(kMaterialPurple)
            elseif self.Color == 2 then
            material:SetMaterial(kMaterialGreen)
            end

            local viewMaterial = Client.CreateRenderMaterial()
            
            if self:isa("Exo") then
                if self.Color == 1 then
                viewMaterial:SetMaterial(kExoViewMaterialPurple)
                elseif self.Color == 2 then
                 viewMaterial:SetMaterial(kExoViewMaterialGreen)
                 end
            else
                if self.Color == 1 then
                viewMaterial:SetMaterial(kViewMaterialPurple)
                elseif self.Color == 2 then
                viewMaterial:SetMaterial(kViewMaterialGreen)
                end
            end    
            
            self.GlowingEntities = {}
            self.ColorMaterial = material
            self.ColorViewMaterial = viewMaterial
            AddGlow(self, material, viewMaterial, self.GlowingEntities)
            
        end    
        
    end

    function GlowMixin:_RemoveGlow()

        if self.ColorMaterial then
            RemoveGlow(self.GlowingEntities, self.ColorMaterial, self.ColorViewMaterial)
            Client.DestroyRenderMaterial(self.ColorMaterial)
            Client.DestroyRenderMaterial(self.ColorViewMaterial)
            self.ColorMaterial = nil
            self.ColorViewMaterial = nil
            self.GlowingEntities = nil
        end            

    end
    
end
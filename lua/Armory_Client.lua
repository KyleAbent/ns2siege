// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Armory_Client.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// A Flash buy menu for marines to purchase weapons and armory from.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kHealthIndicatorModelName = PrecacheAsset("models/marine/armory/health_indicator.model")
PrecacheAsset("cinematics/vfx_materials/hallucination.surface_shader")
local kHallucinationMaterial = PrecacheAsset( "cinematics/vfx_materials/hallucination.material")

function GetResearchPercentage(techId)

    local techNode = GetTechTree():GetTechNode(techId)
    
    if(techNode ~= nil) then
    
        if(techNode:GetAvailable()) then
            return 1
        elseif(techNode:GetResearching()) then
            return techNode:GetResearchProgress()
        end    
        
    end
    
    return 0
    
end

function Armory_Debug()

    // Draw armory points
    
    local indexToUseOrigin = {
        Vector(Armory.kResupplyUseRange, 0, 0), 
        Vector(0, 0, Armory.kResupplyUseRange),
        Vector(-Armory.kResupplyUseRange, 0, 0),
        Vector(0, 0, -Armory.kResupplyUseRange)
    }
    
    local indexToColor = {
        Vector(1, 0, 0),
        Vector(0, 1, 0),
        Vector(0, 0, 1),
        Vector(1, 1, 1)
    }
    
    function isaArmory(entity) return entity:isa("Armory") end
    
    for index, armory in ientitylist(Shared.GetEntitiesWithClassname("Armory")) do
    
        local startPoint = armory:GetOrigin()
        
        for loop = 1, 4 do
            
            local endPoint = startPoint + indexToUseOrigin[loop]
            local color = indexToColor[loop]
            DebugLine(startPoint, endPoint, .2, color.x, color.y, color.z, 1)
            
        end
        
    end
    
end

function Armory:OnInitClient()

    if not self.clientConstructionComplete then
        self.clientConstructionComplete = self.constructionComplete
    end    


end

function Armory:GetWarmupCompleted()
    return not self.timeConstructionCompleted or (self.timeConstructionCompleted + 0.7 < Shared.GetTime())
end

function Armory:OnUse(player, elapsedTime, useSuccessTable)

    self:UpdateArmoryWarmUp()
    
    if GetIsUnitActive(self) and not Shared.GetIsRunningPrediction() and not player.buyMenu and self:GetWarmupCompleted() then
    
        if Client.GetLocalPlayer() == player then
        
            Client.SetCursor("ui/Cursor_MarineCommanderDefault.dds", 0, 0)
            
            // Play looping "active" sound while logged in
            // Shared.PlayPrivateSound(player, Armory.kResupplySound, player, 1.0, Vector(0, 0, 0))
            
            MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", true)
            
            // tell the player to show the lua menu
            player:BuyMenu(self)
            
        end
        
    end
    
end

function Armory:SetOpacity(amount, identifier)

    for i = 0, self:GetNumChildren() - 1 do
    
        local child = self:GetChildAtIndex(i)
        if HasMixin(child, "Model") then
            child:SetOpacity(amount, identifier)
        end
    
    end
    
end

function Armory:UpdateArmoryWarmUp()

    if self.clientConstructionComplete ~= self.constructionComplete and self.constructionComplete then
        self.clientConstructionComplete = self.constructionComplete
        self.timeConstructionCompleted = Shared.GetTime()
    end
    
end

local kUpVector = Vector(0, 1, 0)

function Armory:OnUpdateRender()

    PROFILE("Armory:OnUpdateRender")

    local player = Client.GetLocalPlayer()
    local showHealthIndicator = false
    
    if player then    
        showHealthIndicator = GetIsUnitActive(self) and GetAreFriends(self, player) and (player:GetHealth()/player:GetMaxHealth()) ~= 1 and player:GetIsAlive() and not player:isa("Commander") 
    end

    if not self.healthIndicator then
    
        self.healthIndicator = Client.CreateRenderModel(RenderScene.Zone_Default)  
        self.healthIndicator:SetModel(kHealthIndicatorModelName)
        
    end
    
    self.healthIndicator:SetIsVisible(showHealthIndicator)
    
    // rotate model if visible
    if showHealthIndicator then
    
        local time = Shared.GetTime()
        local zAxis = Vector(math.cos(time), 0, math.sin(time))

        local coords = Coords.GetLookIn(self:GetOrigin() + 2.9 * kUpVector, zAxis)
        self.healthIndicator:SetCoords(coords)
    
    end


          local showMaterial = GetAreEnemies(self, Client.GetLocalPlayer()) and self.stunned
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 0)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kHallucinationMaterial)
                end
                
                self:SetOpacity(0, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
        
        
end

function Armory:OnDestroy()

    if self.healthIndicator then
        Client.DestroyRenderModel(self.healthIndicator)
        self.healthIndicator = nil
    end

    ScriptActor.OnDestroy(self)

end
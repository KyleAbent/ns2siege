// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MarineGhostModel.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Shows an additional rotating circle.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Hud/Commander/GhostModel.lua")

local kCircleModelName = PrecacheAsset("models/misc/circle/placement_circle_marine.model")

class 'MarineGhostModel' (GhostModel)

local kTextName = Fonts.kAgencyFB_Small
local kElectricTexture = "ui/electric.dds"

function MarineGhostModel:Initialize()

    GhostModel.Initialize(self)
    
    if not self.circleModel then    
        self.circleModel = Client.CreateRenderModel(RenderScene.Zone_Default)
        self.circleModel:SetModel(kCircleModelName)
    end
    
    if not self.powerIcon then
    
        self.powerIcon = GUI.CreateItem()
        self.powerIcon:SetTexture(kElectricTexture)
        self.powerIcon:SetSize(GUIScale(Vector(32, 32, 0)))
        self.powerIcon:SetIsVisible(false)
    
    end
    
    if not self.powerLocationText then    
        self.powerLocationText = GetGUIManager():CreateTextItem()
        self.powerLocationText:SetTextAlignmentY(GUIItem.Align_Center)
        self.powerLocationText:SetFontName(kTextName)
        self.powerLocationText:SetScale(GetScaledVector())
        GUIMakeFontScale(self.powerLocationText)
        
        self.powerIcon:AddChild(self.powerLocationText)
    end
    
end

function MarineGhostModel:Destroy()

    GhostModel.Destroy(self)   
    
    if self.circleModel then 
    
        Client.DestroyRenderModel(self.circleModel)
        self.circleModel = nil
    
    end
    
    if self.powerIcon then
    
        GUI.DestroyItem(self.powerIcon)
        self.powerIcon = nil
        
    end
    
end

function MarineGhostModel:SetIsVisible(isVisible)

    self.circleModel:SetIsVisible(isVisible)
    GhostModel.SetIsVisible(self, isVisible)
    
end

function MarineGhostModel:LoadValidMaterial(isValid)
    GhostModel.LoadValidMaterial(self, isValid)
end

function MarineGhostModel:Update()

    local modelCoords = GhostModel.Update(self)
    
    if modelCoords then
        
        local time = Shared.GetTime()
        local zAxis = Vector(math.cos(time), 0, math.sin(time))

        local coords = Coords.GetLookIn(modelCoords.origin, zAxis)
        self.circleModel:SetCoords(coords)
        
        self.powerIcon:SetIsVisible(true)

        local location = GetLocationForPoint(modelCoords.origin)
        local powerNode = location ~= nil and GetPowerPointForLocation(location:GetName())            
        local powered = false
        
        if powerNode then
            local player = Client.GetLocalPlayer()
            local showPowerIndicator = player.currentTechId and player.currentTechId ~= kTechId.None and LookupTechData(player.currentTechId, kTechDataRequiresPower, false)

            self.powerIcon:SetIsVisible(showPowerIndicator)
            powered = powerNode:GetIsPowering()
            
            local screenPos = Client.WorldToScreen(modelCoords.origin)
            local powerNodeScreenPos = Client.WorldToScreen(powerNode:GetOrigin())
            local iconPos = screenPos + GetNormalizedVectorXY(powerNodeScreenPos - screenPos) * GUIScale(100) - GUIScale(Vector(32, 32, 0))
        
            self.powerIcon:SetPosition(iconPos)    

            local animation = (1 + math.sin(Shared.GetTime() * 8)) * 0.5
            local useColor = Color()
            
            if powered then
            
                useColor = Color(
                    (1 - kMarineTeamColorFloat.r) * animation + kMarineTeamColorFloat.r,
                    (1 - kMarineTeamColorFloat.g) * animation + kMarineTeamColorFloat.g,
                    (1 - kMarineTeamColorFloat.b) * animation + kMarineTeamColorFloat.b,
                    1
                )
        
            else
                useColor = Color(0.5 + 0.5 * animation, 0, 0, 1)            
            end
            
            self.powerIcon:SetColor(useColor)
            
            if showPowerIndicator then
                local screenPos = Client.WorldToScreen(modelCoords.origin)
                local textPos = self.powerIcon:GetPosition()
                local powerPoint = GetPowerPointForLocation(location:GetName())
                local text = ""
                local text = string.format("%s", location:GetName())
                local builtFraction = powerPoint:GetBuiltFraction()
                local healthFraction = powerPoint:GetHealthScalar()
                if builtFraction < 1 then
                    text = StringReformat(Locale.ResolveString("POWER_BUILT"),
                                            { location = location:GetName(),
                                              percentage = builtFraction*100 })
                elseif builtFraction > 0 and healthFraction < 1 then
                    text = StringReformat(Locale.ResolveString("POWER_HEALTH"),
                                            { location = location:GetName(),
                                              percentage = healthFraction*100 })
                end
                self.powerLocationText:SetText(text)
                self.powerLocationText:SetColor(useColor)
                
                if screenPos.x > textPos.x then
                    self.powerLocationText:SetAnchor(GUIItem.Left, GUIItem.Center)
                    self.powerLocationText:SetTextAlignmentX(GUIItem.Align_Max)
                    self.powerLocationText:SetPosition(GUIScale(Vector(-10, 0, 0)))
                else
                    self.powerLocationText:SetAnchor(GUIItem.Right, GUIItem.Center)
                    self.powerLocationText:SetTextAlignmentX(GUIItem.Align_Min)
                    self.powerLocationText:SetPosition(GUIScale(Vector(10, 0, 0)))
                end
            else
                self.powerLocationText:SetText("")
            end
        
        else        
            self.powerIcon:SetIsVisible(false)
        end        
        
    else
    
        self.powerIcon:SetIsVisible(false)
    
    end
    
end



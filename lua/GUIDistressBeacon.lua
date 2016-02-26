// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIDistressBeacon.lua
//
// Created by: Charlie Cleveland (charlie@unknownworlds.com)
//
// Draw distress beacon alert for marines, dead players and marine commander.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIDistressBeacon' (GUIScript)

GUIDistressBeacon.kTextFontName = Fonts.kMicrogrammaDMedExt_Medium

local function UpdateItemsGUIScale(self)
    GUIDistressBeacon.kBeaconTextOffset = GUIScale(Vector(0, -50, 0))
    GUIDistressBeacon.kCommanderBeaconTextOffset = GUIScale(Vector(0, -290, 0))
end

function GUIDistressBeacon:Initialize()

    UpdateItemsGUIScale(self)

    self.beacon = GUIManager:CreateTextItem()
    self.beacon:SetFontName(GUIDistressBeacon.kTextFontName)
    self.beacon:SetScale(GetScaledVector())
    GUIMakeFontScale(self.beacon)
    self.beacon:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.beacon:SetTextAlignmentX(GUIItem.Align_Center)
    self.beacon:SetTextAlignmentY(GUIItem.Align_Center)
    self.beacon:SetIsVisible(false)
    
end

function GUIDistressBeacon:Uninitialize()

    GUI.DestroyItem(self.beacon)
    self.beacon = nil
    
end

function GUIDistressBeacon:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUIDistressBeacon:UpdateDistressBeacon(deltaTime)

    PROFILE("GUIDistressBeacon:Update")

    local localPlayer = Client.GetLocalPlayer()
    
    if localPlayer then
    
        local beaconing = PlayerUI_GetIsBeaconing()
        local alpha = 0
        
        if self.beacon:GetIsVisible() ~= beaconing then
        
            self.beacon:SetIsVisible(beaconing)
            
            if beaconing then
                self.beaconTime = Shared.GetTime()
            end
            
        end
        
        if self.beacon:GetIsVisible() then
        
            if localPlayer:isa("Commander") then
            
                self.beacon:SetPosition(GUIDistressBeacon.kCommanderBeaconTextOffset)
                self.beacon:SetText(Locale.ResolveString("BEACONING_COMMANDER"))
                
            else
            
                self.beacon:SetPosition(GUIDistressBeacon.kBeaconTextOffset)
                self.beacon:SetText(Locale.ResolveString("BEACONING"))
                
            end
            
            // Fade alpha in and out dramatically
            local sin = math.sin((Shared.GetTime() - self.beaconTime) * 5/(math.pi/2))
            alpha = math.abs(sin)
            
            self.beacon:SetColor(Color(kMarineTeamColorFloat.r, kMarineTeamColorFloat.g, kMarineTeamColorFloat.b, alpha))
            
        end
        
    else
        self.beacon:SetIsVisible(false)
    end
    
end

function GUIDistressBeacon:Update(deltaTime)
                  
    PROFILE("GUIDistressBeacon:Update")
    
    self:UpdateDistressBeacon(deltaTime)
    
end


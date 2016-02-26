
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIMinimapButtons.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Buttons for minimap action (commander ping).
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")

class 'GUIMinimapButtons' (GUIScript)

local kButtonBackgroundTexture =
{
    [kMarineTeamType] = "ui/marine_buildmenu_buttonbg.dds",
    [kAlienTeamType] = "ui/alien_buildmenu_buttonbg.dds",
}

local kBackgroundPos = {}
local kButtonSize

local kIconTexture = "ui/buildmenu.dds"

local function CreateButtonBackground(self, position, child)

    local buttonBackground = GetGUIManager():CreateGraphicItem()
    buttonBackground:SetTexture(kButtonBackgroundTexture[PlayerUI_GetTeamType()])
    buttonBackground:SetPosition(position)
    buttonBackground:SetSize(kButtonSize)
    buttonBackground:AddChild(child)
    
    self.background:AddChild(buttonBackground)
    
    return buttonBackground
    
end

local function UpdateItemsGUIScale(self)
    kBackgroundPos[kMarineTeamType] = GUIScale(Vector(-130, 15, 0))
    kBackgroundPos[kAlienTeamType] = GUIScale(Vector(-80, 160, 0))
    kButtonSize = GUIScale(Vector(60, 60, 0))
end

function GUIMinimapButtons:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateItemsGUIScale(self)
    
    self.background:SetPosition(kBackgroundPos[self.teamType])
    self.pingButton:SetSize(kButtonSize)
    self.pingButtonBg:SetSize(kButtonSize)
    self.techMapButton:SetSize(kButtonSize)
    self.techMapButtonBg:SetSize(kButtonSize)
    self.techMapButtonBg:SetPosition(Vector(0, kButtonSize.y, 0))
end

function GUIMinimapButtons:Initialize()

    UpdateItemsGUIScale(self)
    
    self.pingButtonActive = false
    
    self.teamType = PlayerUI_GetTeamType()
    
    self.background = GetGUIManager():CreateGraphicItem()
    self.background:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.background:SetColor(Color(1,1,1,0))
    self.background:SetPosition(kBackgroundPos[self.teamType])
  
    self.pingButton = GetGUIManager():CreateGraphicItem()
    self.pingButton:SetSize(kButtonSize)
    self.pingButton:SetTexture(kIconTexture)
    self.pingButton:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.PingLocation)))
    self.pingButtonBg = CreateButtonBackground(self, Vector(0,0,0), self.pingButton)

    self.techMapButton = GetGUIManager():CreateGraphicItem()
    self.techMapButton:SetSize(kButtonSize)
    self.techMapButton:SetTexture(kIconTexture)
    self.techMapButton:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.Research)))
    self.techMapButtonBg = CreateButtonBackground(self, Vector(0, kButtonSize.y, 0), self.techMapButton)
    
end

function GUIMinimapButtons:GetBackground()
    return self.background
end

function GUIMinimapButtons:Uninitialize()

    if self.background then
    
        GUI.DestroyItem(self.background)
        self.background = nil
        
    end
    
end

function GUIMinimapButtons:Update(deltaTime)
    PROFILE("GUIMinimapButtons:Update")
    local teamColor = kIconColors[self.teamType]
    local useColor = Color(
        teamColor.r,
        teamColor.g,
        teamColor.b,
        GetCommanderPingEnabled() and 1 or 0.7
    )
    
    self.pingButton:SetColor(useColor)
    
    local techMapScript = ClientUI.GetScript("GUITechMap")
    if techMapScript then
   
        local mapActive = techMapScript.background:GetIsVisible() 
        useColor.a = mapActive and 1 or 0.7
        self.techMapButton:SetColor(useColor)
        
    end    
    
end

function GUIMinimapButtons:ContainsPoint(pointX, pointY)
    return GUIItemContainsPoint(self.pingButton, pointX, pointY) or GUIItemContainsPoint(self.techMapButton, pointX, pointY)
end

function GUIMinimapButtons:SendKeyEvent(key, down)

    local mouseX, mouseY = Client.GetCursorPosScreen()
    
    -- Don't respond to clicks if the big map is open
    if key == InputKey.MouseButton0 and CommanderUI_GetUIClickable() and self.background:GetParent():GetIsVisible() then
    
        if GUIItemContainsPoint(self.pingButton, mouseX, mouseY) then
        
            SetCommanderPingEnabled(true)
            return true
            
        elseif GUIItemContainsPoint(self.techMapButton, mouseX, mouseY) then
        
            local techMapScript = ClientUI.GetScript("GUITechMap")
            if techMapScript and not down then
                
                local showMap = not techMapScript.background:GetIsVisible()
                techMapScript:ShowTechMap(showMap)
                
            end
            
            return true
            
        end
        
    elseif key == InputKey.Escape or (GetIsBinding(key, "ShowTechMap") and not down) then
    
        local showingMap = false 
        local techMapScript = ClientUI.GetScript("GUITechMap")
        if techMapScript and techMapScript.background:GetIsVisible() then
        
            techMapScript:ShowTechMap(false)
            return true
            
        elseif GetCommanderPingEnabled() then
        
            SetCommanderPingEnabled(false)
            return true
            
        end
    
    end
    
end
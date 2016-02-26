// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIHoverTooltip.lua
//
//    Created by:   Brian Arneson (samusdroid@gmail.com)
//                  Juanjo Alfaro
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIHoverTooltip' (GUIAnimatedScript)

local offset
local textCutoff = 400
local kBorderWidth
local kBackgroundColor = Color(0, 0, 0, 0.9)
local kDefaultBorderColor = ColorIntToColor(kMarineTeamColor)

function GUIHoverTooltip:Initialize()
    GUIAnimatedScript.Initialize(self)
    
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetLayer(kGUILayerOptionsTooltips)
    self.background:SetColor(kBackgroundColor)
    self.background:SetIsVisible(false)
    self.background:SetIsScaling(false)
    
    self.tooltip = GetGUIManager():CreateTextItem()
    self.tooltip:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.tooltip:SetFontName(Fonts.kAgencyFB_Small)
    self.tooltip:SetTextAlignmentX(GUIItem.Align_Min)
    self.tooltip:SetTextAlignmentY(GUIItem.Align_Min)
    self.tooltip:SetInheritsParentAlpha(true)
    self.background:AddChild(self.tooltip)
    
    self.borderTop = GetGUIManager():CreateGraphicItem()
    self.borderTop:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.borderTop:SetColor(kDefaultBorderColor)
    self.borderTop:SetInheritsParentAlpha(true)
    self.background:AddChild(self.borderTop)
    
    self.borderBottom = GetGUIManager():CreateGraphicItem()
    self.borderBottom:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.borderBottom:SetColor(kDefaultBorderColor)
    self.borderBottom:SetInheritsParentAlpha(true)
    self.background:AddChild(self.borderBottom)
    
    self.borderLeft = GetGUIManager():CreateGraphicItem()
    self.borderLeft:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.borderLeft:SetColor(kDefaultBorderColor)
    self.borderLeft:SetInheritsParentAlpha(true)
    self.background:AddChild(self.borderLeft)
    
    self.borderRight = GetGUIManager():CreateGraphicItem()
    self.borderRight:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.borderRight:SetColor(kDefaultBorderColor)
    self.borderRight:SetInheritsParentAlpha(true)
    self.background:AddChild(self.borderRight)
    
    self.targetTime = 0
end

function GUIHoverTooltip:Uninitialize()
    GUIAnimatedScript.Uninitialize(self)
    
    GUI.DestroyItem(self.background)
    self.background = nil
end

function GUIHoverTooltip:Update(deltaTime)
    PROFILE("GUIHoverTooltip:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)
    
    if self.targetTime > -1 then
        if self.targetTime > 0 then
            if self.targetTime > Shared.GetTime() - 0.3 then
                self:Hide()
            elseif self.targetTime < Shared.GetTime() then
                self:Hide(0)
                self.targetTime = -1
            end
        end

        local mouseX, mouseY = Client.GetCursorPosScreen()
        local xPos, yPos
        if mouseX > Client.GetScreenWidth() - self.background:GetSize().x - GUIScale(20) then
            xPos = mouseX - self.background:GetSize().x - GUIScale(10)
        else
            xPos = mouseX + GUIScale(20)
        end
        
        if mouseY > Client.GetScreenHeight() - self.background:GetSize().y then
            yPos = mouseY - self.background:GetSize().y - GUIScale(5)
        else
            yPos = mouseY
        end
        
        self.background:SetPosition(Vector(xPos, yPos, 0))
    end
end

local function UpdateBorders(self)
    local borderSize = Vector(self.background:GetSize())
    borderSize.x = borderSize.x + 2 * kBorderWidth
    borderSize.y = borderSize.y
    
    self.borderTop:SetPosition(Vector(-kBorderWidth, -kBorderWidth, 0))
    self.borderTop:SetSize(Vector(borderSize.x, kBorderWidth, 0))
    
    self.borderBottom:SetPosition(Vector(-kBorderWidth, 0, 0))
    self.borderBottom:SetSize(Vector(borderSize.x, kBorderWidth, 0))

    self.borderLeft:SetPosition(Vector(-kBorderWidth, 0, 0))
    self.borderLeft:SetSize(Vector(kBorderWidth, borderSize.y, 0))

    self.borderRight:SetPosition(Vector(0, 0, 0))
    self.borderRight:SetSize(Vector(kBorderWidth, borderSize.y, 0))
end

function GUIHoverTooltip:SetText(string)
    
    kBorderWidth = GUIScale(2)
    offset = GUIScale(10)
    
    local wrappedText = WordWrap(self.tooltip, string, 0, GUIScale(textCutoff))
    local width = self.tooltip:GetTextWidth(wrappedText) * self.tooltip:GetScale().x + offset*2
    local height = self.tooltip:GetTextHeight(wrappedText) * self.tooltip:GetScale().y + offset*2
    
    self.tooltip:SetText(wrappedText)
    self.tooltip:SetPosition(Vector(offset, offset, 0))
    self.tooltip:SetScale(GetScaledVector())
    self.tooltip:SetFontName(Fonts.kAgencyFB_Small)
    GUIMakeFontScale(self.tooltip)
    
    self.background:SetSize(Vector(width, height, 0))
    
    UpdateBorders(self)
    
end

function GUIHoverTooltip:SendKeyEvent(key, down)

    if key == InputKey.Escape then
        self:Hide()
        self.targetTime = 0
    end
    
end

function GUIHoverTooltip:SetIsVisible(visible)
    self.background:SetIsVisible(visible)
end

function GUIHoverTooltip:Show(displayTime)
    if self.background:GetHasAnimation("TOOLTIP_HIDE") then
        self.background:DestroyAnimations()
    end
    if not self.background:GetHasAnimation("TOOLTIP_SHOW") then
        self.background:SetIsVisible(true)
        self.background:SetColor(kBackgroundColor, 0.25, "TOOLTIP_SHOW")
        
        if displayTime then
            self.targetTime = Shared.GetTime() + displayTime
        else
            self.targetTime = 0
        end
    end
end

function GUIHoverTooltip:Hide(hideTime)
    if self.background:GetHasAnimation("TOOLTIP_SHOW") then
        self.background:DestroyAnimations()
    end
    if not self.background:GetHasAnimation("TOOLTIP_HIDE") then
        local fadeTime = 0.25
        if hideTime then
            fadeTime = hideTime
        end
        
        self.background:FadeOut(fadeTime, "TOOLTIP_HIDE")
    end
end
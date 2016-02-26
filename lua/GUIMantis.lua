// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\GUIMantis.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local mantisGUIScript = nil
function DisplayMantisBug(bugId, summary, accepts, rejects)

    if not mantisGUIScript then
        mantisGUIScript = GetGUIManager():CreateGUIScript("GUIMantis")
    end
    
    mantisGUIScript:SetIsVisible(true)
    mantisGUIScript:SetBug(bugId, summary, accepts, rejects)
    
end

function HideMantisBug()

    if mantisGUIScript then
        mantisGUIScript:SetIsVisible(false)
    end
    
end

class 'GUIMantis' (GUIScript)

local kFontName = Fonts.kAgencyFB_Small
local kTextScrollSpeed = 40

local function UpdateSizeOfUI(self, screenWidth, screenHeight)

    local size = Vector(screenWidth * 0.25, screenHeight * 0.1, 0)
    self.background:SetSize(size)
    self.background:SetPosition(Vector(-size.x / 2, 10, 0))
    
    self.backgroundStencil:SetSize(size)
    
    self.accepts:SetPosition(Vector(10, 0, 0))
    self.rejects:SetPosition(Vector(-10, 0, 0))
    
end

function GUIMantis:Initialize()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.background:SetColor(Color(0, 0, 0, 0.8))
    
    self.backgroundStencil = GUIManager:CreateGraphicItem()
    self.backgroundStencil:SetIsStencil(true)
    self.backgroundStencil:SetClearsStencilBuffer(true)
    self.background:AddChild(self.backgroundStencil)
    
    self.idText = GUIManager:CreateTextItem()
    self.idText:SetFontName(kFontName)
    self.idText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.idText)
    self.idText:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.idText:SetTextAlignmentX(GUIItem.Align_Center)
    self.idText:SetTextAlignmentY(GUIItem.Align_Min)
    self.background:AddChild(self.idText)
    
    self.titleText = GUIManager:CreateTextItem()
    self.titleText:SetFontName(kFontName)
    self.titleText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.titleText)
    self.titleText:SetPosition(Vector(0, self.idText:GetTextHeight("1234") * self.idText:GetScale().y, 0))
    self.titleText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.titleText:SetTextAlignmentX(GUIItem.Align_Min)
    self.titleText:SetTextAlignmentY(GUIItem.Align_Min)
    self.titleText:SetText("Title")
    self.titleText:SetStencilFunc(GUIItem.NotEqual)
    self.background:AddChild(self.titleText)
    
    self.accepts = GUIManager:CreateTextItem()
    self.accepts:SetFontName(kFontName)
    self.accepts:SetScale(GetScaledVector())
    GUIMakeFontScale(self.accepts)
    self.accepts:SetColor(Color(0, 1, 0, 1))
    self.accepts:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.accepts:SetTextAlignmentX(GUIItem.Align_Min)
    self.accepts:SetTextAlignmentY(GUIItem.Align_Max)
    self.background:AddChild(self.accepts)
    
    self.rejects = GUIManager:CreateTextItem()
    self.rejects:SetFontName(kFontName)
    self.rejects:SetScale(GetScaledVector())
    GUIMakeFontScale(self.rejects)
    self.rejects:SetColor(Color(1, 0, 0, 1))
    self.rejects:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.rejects:SetTextAlignmentX(GUIItem.Align_Max)
    self.rejects:SetTextAlignmentY(GUIItem.Align_Max)
    self.background:AddChild(self.rejects)
    
    self.keybindText = GUIManager:CreateTextItem()
    self.keybindText:SetFontName(kFontName)
    self.keybindText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.keybindText)
    self.keybindText:SetColor(Color(1, 1, 1, 1))
    self.keybindText:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local width = -self.keybindText:GetTextWidth("Accept: F6 | Reject: F7") * self.keybindText:GetScale().x / 2
    self.keybindText:SetPosition(Vector(width, 0, 0))
    self.keybindText:SetTextAlignmentX(GUIItem.Align_Min)
    self.keybindText:SetTextAlignmentY(GUIItem.Align_Max)
    self.keybindText:SetText("Accept: F6 | Reject: F7")
    self.background:AddChild(self.keybindText)
    
    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
    self.updateInterval = kUpdateIntervalMedium
    
end

function GUIMantis:Uninitialize()

    GUI.DestroyItem(self.rejects)
    self.rejects = nil
    
    GUI.DestroyItem(self.accepts)
    self.accepts = nil
    
    GUI.DestroyItem(self.titleText)
    self.titleText = nil
    
    GUI.DestroyItem(self.idText)
    
    GUI.DestroyItem(self.backgroundStencil)
    self.backgroundStencil = nil
    
    GUI.DestroyItem(self.background)
    self.background = nil
    
end

function GUIMantis:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
end

function GUIMantis:SetIsVisible(visible)
    self.background:SetIsVisible(visible)
end

function GUIMantis:SetBug(bugId, summary, accepts, rejects)

    self.bugId = bugId
    self.idText:SetText(tostring(bugId))
    self.titleText:SetText(summary)
    local pos = self.titleText:GetPosition()
    pos.x = 0
    self.titleText:SetPosition(pos)
    
    self.accepts:SetText("Accepts: " .. accepts)
    self.rejects:SetText(tostring(rejects) .. " :Rejects")
    
end

function GUIMantis:GetBugId()
    return self.bugId
end

function GUIMantis:Update(deltaTime)
  
    PROFILE("GUIMantis:Update")
    
    local textWidth = self.titleText:GetTextWidth(self.titleText:GetText()) * self.titleText:GetScale().x
    if textWidth then
    
        local newPosition = self.titleText:GetPosition() - Vector(deltaTime * kTextScrollSpeed, 0, 0)
        
        if newPosition.x < -textWidth then
            newPosition.x = self.background:GetSize().x
        end
        
        self.titleText:SetPosition(newPosition)
        
    end
    
end

function GUIMantis:SendKeyEvent(key, down)

    if self.background:GetIsVisible() == true then
        if down and key == InputKey.F6 then
            Shared.ConsoleCommand("mantis_accept " .. ToString(self:GetBugId()))
        elseif down and key == InputKey.F7 then
            Shared.ConsoleCommand("mantis_reject " .. ToString(self:GetBugId()))
        end
    end

end
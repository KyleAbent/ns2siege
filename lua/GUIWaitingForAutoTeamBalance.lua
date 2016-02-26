// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\GUIWaitingForAutoTeamBalance.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIWaitingForAutoTeamBalance' (GUIScript)

local kFontName = Fonts.kAgencyFB_Medium
local kFontColor = Color(0.8, 0.8, 0.8, 1)

local clientIsWaitingForAutoTeamBalance = false

function GUIWaitingForAutoTeamBalance:Initialize()

    self.waitingText = GUIManager:CreateTextItem()
    self.waitingText:SetFontName(kFontName)
    self.waitingText:SetScale(GetScaledVector())
    self.waitingText:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.waitingText:SetPosition(Vector(0, 120, 0))
    self.waitingText:SetTextAlignmentX(GUIItem.Align_Center)
    self.waitingText:SetTextAlignmentY(GUIItem.Align_Center)
    self.waitingText:SetColor(kFontColor)
    self.waitingText:SetText(string.format(Locale.ResolveString("AUTO_TEAM_BALANCE_TOOLTIP"), BindingsUI_GetInputValue("ReadyRoom")))
    GUIMakeFontScale(self.waitingText)
    self.waitingText:SetIsVisible(false)
    
end

function GUIWaitingForAutoTeamBalance:Uninitialize()

    assert(self.waitingText)
    
    GUI.DestroyItem(self.waitingText)
    self.waitingText = nil
    
end

function GUIWaitingForAutoTeamBalance:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUIWaitingForAutoTeamBalance:Update(deltaTime)
    self.waitingText:SetIsVisible(PlayerUI_GetIsWaitingForTeamBalance())
end
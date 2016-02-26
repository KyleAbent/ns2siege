
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUINotifications.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages the displaying any text notifications on the screen.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

class 'GUINotifications' (GUIAnimatedScript)

GUINotifications.kTooltipTextColor = Color(1, 1, 1, 1)

// Score popup constants.
GUINotifications.kScoreDisplayFontName = Fonts.kAgencyFB_Medium
GUINotifications.kScoreDisplayTextColor = Color(0.75, 0.75, 0.1, 1)
GUINotifications.kScoreDisplayKillTextColor = Color(0.1, 1, 0.1, 1)
GUINotifications.kScoreDisplayFontHeight = 80
GUINotifications.kScoreDisplayMinFontHeight = 60
GUINotifications.kScoreDisplayYOffset = -96
GUINotifications.kScoreDisplayPopTimer = 0.15
GUINotifications.kScoreDisplayFadeoutTimer = 2

GUINotifications.kMarineColor = Color(205/255, 245/255, 1, 1)

GUINotifications.kGeneralFont = Fonts.kArial_15 
GUINotifications.kMarineFont = Fonts.kAgencyFB_Small

local kAlienFont = Fonts.kAgencyFB_Small

function GUINotifications:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUINotifications:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.locationText = GUIManager:CreateTextItem()
    self.locationText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.locationText:SetTextAlignmentX(GUIItem.Align_Min)
    self.locationText:SetTextAlignmentY(GUIItem.Align_Min)
    self.locationText:SetPosition(GUIScale(Vector(20, 20, 0)))
    self.locationText:SetColor(Color(1, 1, 1, 1))
    self.locationText:SetText(PlayerUI_GetLocationName())
    self.locationText:SetScale(GetScaledVector())
    self.locationText:SetLayer(kGUILayerLocationText)
    
    self:InitializeScoreDisplay()
    
    if PlayerUI_GetTeamType() == kAlienTeamType then
        self:EnableAlienStyle()
    else
        self:EnableMarineStyle()
    end
    
    GUIMakeFontScale(self.locationText)
    
end

function GUINotifications:EnableMarineStyle()

    PROFILE("GUINotifications:EnableMarineStyle")

    self.locationText:SetColor(GUINotifications.kMarineColor)
    self.locationText:SetFontName(GUINotifications.kMarineFont)
    self.scoreDisplay:SetColor(GUINotifications.kMarineColor)
    
end

function GUINotifications:EnableAlienStyle()

    PROFILE("GUINotifications:EnableAlienStyle")

    self.locationText:SetColor(kAlienTeamColorFloat)
    self.locationText:SetFontName(kAlienFont)
    self.scoreDisplay:SetColor(GUINotifications.kScoreDisplayTextColor)
    
end

function GUINotifications:EnableGeneralStyle()

    PROFILE("GUINotifications:EnableGeneralStyle")

    self.locationText:SetColor(GUINotifications.kTooltipTextColor)
    self.locationText:SetFontName(GUINotifications.kGeneralFont)
    self.scoreDisplay:SetColor(GUINotifications.kScoreDisplayTextColor)
    
end

function GUINotifications:Uninitialize()

    GUI.DestroyItem(self.locationText)
    self.locationText = nil
    
    self:UninitializeScoreDisplay()
    
    GUIAnimatedScript.Uninitialize(self)
    
end

function GUINotifications:InitializeScoreDisplay()

    self.scoreDisplay = GUIManager:CreateTextItem()
    self.scoreDisplay:SetFontName(GUINotifications.kScoreDisplayFontName)
    self.scoreDisplay:SetScale(GetScaledVector())
    self.scoreDisplay:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.scoreDisplay:SetPosition(GUIScale(Vector(0, GUINotifications.kScoreDisplayYOffset, 0)))
    self.scoreDisplay:SetTextAlignmentX(GUIItem.Align_Center)
    self.scoreDisplay:SetTextAlignmentY(GUIItem.Align_Center)
    self.scoreDisplay:SetColor(GUINotifications.kScoreDisplayTextColor)
    self.scoreDisplay:SetIsVisible(false)
    
    self.scoreDisplayPopupTime = 0
    self.scoreDisplayPopdownTime = 0
    self.scoreDisplayFadeoutTime = 0

end

function GUINotifications:UninitializeScoreDisplay()

    GUI.DestroyItem(self.scoreDisplay)
    self.scoreDisplay = nil
    
end

local function UpdateScoreDisplay(self, deltaTime)

    PROFILE("GUINotifications:UpdateScoreDisplay")
    self.updateInterval = kUpdateIntervalFull
    
    if self.scoreDisplayFadeoutTime > 0 then
        self.scoreDisplayFadeoutTime = math.max(0, self.scoreDisplayFadeoutTime - deltaTime)
        local fadeRate = 1 - (self.scoreDisplayFadeoutTime / GUINotifications.kScoreDisplayFadeoutTimer)
        local fadeColor = self.scoreDisplay:GetColor()
        fadeColor.a = 1
        fadeColor.a = fadeColor.a - (fadeColor.a * fadeRate)
        self.scoreDisplay:SetColor(fadeColor)
        if self.scoreDisplayFadeoutTime == 0 then
            self.scoreDisplay:SetIsVisible(false)
        end
        
    end
    
    if self.scoreDisplayPopdownTime > 0 then
        self.scoreDisplayPopdownTime = math.max(0, self.scoreDisplayPopdownTime - deltaTime)
        local popRate = self.scoreDisplayPopdownTime / GUINotifications.kScoreDisplayPopTimer
        local fontSize = GUINotifications.kScoreDisplayMinFontHeight + ((GUINotifications.kScoreDisplayFontHeight - GUINotifications.kScoreDisplayMinFontHeight) * popRate)
        local scale = GUIScale(fontSize / GUINotifications.kScoreDisplayFontHeight)
        self.scoreDisplay:SetScale(Vector(scale, scale, scale))
        if self.scoreDisplayPopdownTime == 0 then
            self.scoreDisplayFadeoutTime = GUINotifications.kScoreDisplayFadeoutTimer
        end
        
    end
    
    if self.scoreDisplayPopupTime > 0 then
        self.scoreDisplayPopupTime = math.max(0, self.scoreDisplayPopupTime - deltaTime)
        local popRate = 1 - (self.scoreDisplayPopupTime / GUINotifications.kScoreDisplayPopTimer)
        local fontSize = GUINotifications.kScoreDisplayMinFontHeight + ((GUINotifications.kScoreDisplayFontHeight - GUINotifications.kScoreDisplayMinFontHeight) * popRate)
        local scale = GUIScale(fontSize / GUINotifications.kScoreDisplayFontHeight)
        self.scoreDisplay:SetScale(Vector(scale, scale, scale))
        if self.scoreDisplayPopupTime == 0 then
            self.scoreDisplayPopdownTime = GUINotifications.kScoreDisplayPopTimer
        end
        
    end
    
    local newScore, resAwarded, wasKill = ScoreDisplayUI_GetNewScore()
    if newScore > 0 then
    
        // Restart the animation sequence.
        self.scoreDisplayPopupTime = GUINotifications.kScoreDisplayPopTimer
        self.scoreDisplayPopdownTime = 0
        self.scoreDisplayFadeoutTime = 0
        
        local resAwardedString = ""
        if resAwarded > 0 then
            resAwarded = math.round(resAwarded * 10) / 10
            resAwardedString = string.format(" (+%s res)", ToString(resAwarded))
        end
        
        self.scoreDisplay:SetText(string.format("+%s%s", tostring(newScore), resAwardedString))
        self.scoreDisplay:SetScale(GUIScale(Vector(0.5, 0.5, 0.5)))
        
        local color = 
        
        self.scoreDisplay:SetColor(wasKill and GUINotifications.kScoreDisplayKillTextColor or GUINotifications.kScoreDisplayTextColor)
        self.scoreDisplay:SetIsVisible(true)
        
    end
    
end

function GUINotifications:Update(deltaTime)

    PROFILE("GUINotifications:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)
    
    // The commander has their own location text.
    if PlayerUI_IsACommander() or PlayerUI_IsOnMarineTeam() then
        self.locationText:SetIsVisible(false)
    else
        self.locationText:SetIsVisible(true)
        self.locationText:SetText(PlayerUI_GetLocationName())
    end
    
    UpdateScoreDisplay(self, deltaTime)
    
end
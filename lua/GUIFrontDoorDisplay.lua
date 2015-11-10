
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIFrontDoorDisplay.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages displaying resources and number of resource towers.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")

class 'GUIFrontDoorDisplay' (GUIScript)

GUIFrontDoorDisplay.kBackgroundTextureAlien = "ui/alien_commander_textures.dds"
GUIFrontDoorDisplay.kBackgroundTextureMarine = "ui/marine_commander_textures.dds"
GUIFrontDoorDisplay.kBackgroundTextureCoords = { X1 = 755, Y1 = 342, X2 = 990, Y2 = 405 }


GUIFrontDoorDisplay.kTeamResourceIcon = { Width = 0, Height = 0, X = 0, Y = 0, Coords = { X1 = 192, Y1 = 363, X2 = 240, Y2 = 411} }

local kFontName = Fonts.kAgencyFB_Small
local kFontScale

local kColorWhite = Color(1, 1, 1, 1)
local kColorRed = Color(1, 0, 0, 1)

local kBackgroundNoiseTexture =  "ui/alien_commander_bg_smoke.dds"
local kSmokeyBackgroundSize

local function UpdateItemsGUIScale(self)
    GUIFrontDoorDisplay.kBackgroundWidth = GUIScale(128)
    GUIFrontDoorDisplay.kBackgroundHeight = GUIScale(63)
    GUIFrontDoorDisplay.kBackgroundYOffset = GUIScale(10)

    GUIFrontDoorDisplay.kPersonalResourceIcon.Width = GUIScale(48)
    GUIFrontDoorDisplay.kPersonalResourceIcon.Height = GUIScale(48)

    GUIFrontDoorDisplay.kTeamResourceIcon.Width = GUIScale(48)
    GUIFrontDoorDisplay.kTeamResourceIcon.Height = GUIScale(48)

    GUIFrontDoorDisplay.kResourceTowerIcon.Width = GUIScale(48)
    GUIFrontDoorDisplay.kResourceTowerIcon.Height = GUIScale(48)

    GUIFrontDoorDisplay.kWorkerIcon.Width = GUIScale(48)
    GUIFrontDoorDisplay.kWorkerIcon.Height = GUIScale(48)

    GUIFrontDoorDisplay.kIconTextXOffset = GUIScale(5)
    GUIFrontDoorDisplay.kIconXOffset = GUIScale(30)

    GUIFrontDoorDisplay.kEggsIcon.Width = GUIScale(57)
    GUIFrontDoorDisplay.kEggsIcon.Height = GUIScale(57)
    
    kSmokeyBackgroundSize = GUIScale(Vector(375, 100, 0))
    kFontScale = GetScaledVector()
end

function GUIFrontDoorDisplay:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUIFrontDoorDisplay:Initialize(settingsTable)

    UpdateItemsGUIScale(self)
    
    self.textureName = ConditionalValue(PlayerUI_GetTeamType() == kAlienTeamType, GUIFrontDoorDisplay.kBackgroundTextureAlien, GUIFrontDoorDisplay.kBackgroundTextureMarine)
    
    // Background, only used for positioning
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(GUIFrontDoorDisplay.kBackgroundWidth, GUIFrontDoorDisplay.kBackgroundHeight, 0))
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.background:SetPosition(Vector(-GUIFrontDoorDisplay.kBackgroundWidth / 2, GUIFrontDoorDisplay.kBackgroundYOffset, 0))
    self.background:SetColor(Color(1, 1, 1, 0))
    
    if PlayerUI_GetTeamType() == kAlienTeamType then
        self:InitSmokeyBackground()
    end
    
    // Team display.
    self.teamIcon = GUIManager:CreateGraphicItem()
    self.teamIcon:SetSize(Vector(GUIFrontDoorDisplay.kTeamResourceIcon.Width, GUIFrontDoorDisplay.kTeamResourceIcon.Height, 0))
    self.teamIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    local teamIconX = GUIFrontDoorDisplay.kTeamResourceIcon.X + -GUIFrontDoorDisplay.kTeamResourceIcon.Width - GUIFrontDoorDisplay.kIconXOffset
    local teamIconY = GUIFrontDoorDisplay.kTeamResourceIcon.Y + -GUIFrontDoorDisplay.kPersonalResourceIcon.Height / 2
    self.teamIcon:SetPosition(Vector(teamIconX, teamIconY, 0))
    self.teamIcon:SetTexture(self.textureName)
    GUISetTextureCoordinatesTable(self.teamIcon, GUIFrontDoorDisplay.kTeamResourceIcon.Coords)
    self.background:AddChild(self.teamIcon)

    self.teamText = GUIManager:CreateTextItem()
    self.teamText:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.teamText:SetTextAlignmentX(GUIItem.Align_Min)
    self.teamText:SetTextAlignmentY(GUIItem.Align_Center)
    self.teamText:SetPosition(Vector(GUIFrontDoorDisplay.kIconTextXOffset, 0, 0))
    self.teamText:SetColor(Color(1, 1, 1, 1))
    self.teamText:SetFontName(kFontName)
    self.teamText:SetScale(kFontScale)
    GUIMakeFontScale(self.teamText)
    self.teamIcon:AddChild(self.teamText)

end

function GUIFrontDoorDisplay:Uninitialize()
    
    if self.background then
        GUI.DestroyItem(self.background)
    end
    self.background = nil
    
end

function GUIFrontDoorDisplay:InitSmokeyBackground()

    self.smokeyBackground = GUIManager:CreateGraphicItem()
    self.smokeyBackground:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.smokeyBackground:SetSize(kSmokeyBackgroundSize)
    self.smokeyBackground:SetPosition(-kSmokeyBackgroundSize * .5)
    self.smokeyBackground:SetShader("shaders/GUISmoke.surface_shader")
    self.smokeyBackground:SetTexture("ui/alien_ressources_smkmask.dds")
    self.smokeyBackground:SetAdditionalTexture("noise", kBackgroundNoiseTexture)
    self.smokeyBackground:SetFloatParameter("correctionX", 0.9)
    self.smokeyBackground:SetFloatParameter("correctionY", 0.1)
    
    self.background:AddChild(self.smokeyBackground)

end

local kWhite = Color(1,1,1,1)
local kRed = Color(1,0,0,1)

function GUIFrontDoorDisplay:Update(deltaTime)

    PROFILE("GUIFrontDoorDisplay:Update")
    
    local CurrentTimeLeft = PlayerUI_GetFrontDoorCountDown()
    if not self.displayDoorTimer then
        self.displayDoorTimer = CurrentTimeLeft
    else

        if self.displayDoorTimer > CurrentTimeLeft then
            self.displayDoorTimer = CurrentTimeLeft
        else
            self.displayDoorTimer = Slerp(self.displayDoorTimer, CurrentTimeLeft, deltaTime * 40)
        end    
            
    end

    self.teamText:SetText(ToString(math.round(self.displayDoorTimer)))
    
end

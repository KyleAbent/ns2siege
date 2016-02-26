// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIPlayerRanking.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/PlayerRanking.lua")

class 'GUIPlayerRanking' (GUIScript)

local kFontScale = GUIScale(Vector(1,1,1))
local kFontName = Fonts.kAgencyFB_Medium
local kFontOffset = GUIScale(Vector(-26, 0, 0))

local kBarTexture = "ui/unitstatus_neutral.dds"
local kBarSize = GUIScale(Vector(256, 64, 0))

local kBarTexCoords = { 256, 0, 256 + 512, 64 }

local kRelativeSkillPos = GUIScale(Vector(300, 300, 0))
local kLevelPos = GUIScale(Vector(300, 380, 0))

local kBarOffset = Vector(-1, -1, 0)

local kLevelBarColor = Color(0, 0.7, 1, 1)

local kYellow = Color(1, 1, 0)
local kGreen = Color(0, 1, 0)
local kRed = Color(1, 0 ,0)
local kBlack = Color(0, 0, 0)
local function GetColorForFraction(fraction)
    
    local color = Color()
    
    if fraction > 0.5 then        
        color = LerpColor(kYellow, kGreen, fraction)        
    else
        color = LerpColor(kRed, kYellow, fraction)
    end
    
    return color

end

function GUIPlayerRanking:Initialize()

    self.relativeSkillBackground = GetGUIManager():CreateGraphicItem()
    self.relativeSkillBackground:SetTexture(kBarTexture)
    self.relativeSkillBackground:SetSize(kBarSize)
    self.relativeSkillBackground:SetPosition(kRelativeSkillPos)
    self.relativeSkillBackground:SetTexturePixelCoordinates(unpack(kBarTexCoords))
    self.relativeSkillBackground:SetColor(kBlack)
    
    self.skillBar = GetGUIManager():CreateGraphicItem()
    self.skillBar:SetTexture(kBarTexture)
    self.skillBar:SetSize(kBarSize)
    self.skillBar:SetPosition(kBarOffset)
    
    self.relativeSkillBackground:AddChild(self.skillBar)

    self.relativeSkillText = GetGUIManager():CreateTextItem()
    self.relativeSkillText:SetScale(kFontScale)
    self.relativeSkillText:SetFontName(kFontName)
    GUIMakeFontScale(self.relativeSkillText)
    self.relativeSkillText:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.relativeSkillText:SetTextAlignmentX(GUIItem.Align_Max)
    self.relativeSkillText:SetTextAlignmentY(GUIItem.Align_Center)
    self.relativeSkillText:SetText(Locale.ResolveString("RELATIVE_SKILL"))
    self.relativeSkillText:SetPosition(kFontOffset)
    
    self.relativeSkillBackground:AddChild(self.relativeSkillText)
    
    self.levelBackground = GetGUIManager():CreateGraphicItem()
    self.levelBackground:SetTexture(kBarTexture)
    self.levelBackground:SetSize(kBarSize)
    self.levelBackground:SetPosition(kLevelPos)
    self.levelBackground:SetTexturePixelCoordinates(unpack(kBarTexCoords))
    self.levelBackground:SetColor(kBlack)
    
    self.levelBar = GetGUIManager():CreateGraphicItem()
    self.levelBar:SetTexture(kBarTexture)
    self.levelBar:SetSize(kBarSize)
    self.levelBar:SetPosition(kBarOffset)
    self.levelBar:SetColor(kLevelBarColor)
    
    self.levelBackground:AddChild(self.levelBar)
    
    self.levelText = GetGUIManager():CreateTextItem()
    self.levelText:SetScale(kFontScale)
    self.levelText:SetFontName(kFontName)
    GUIMakeFontScale(self.levelText)
    self.levelText:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.levelText:SetTextAlignmentX(GUIItem.Align_Max)
    self.levelText:SetTextAlignmentY(GUIItem.Align_Center)
    self.levelText:SetText(Locale.ResolveString("EXPERIENCE_LEVEL"))
    self.levelText:SetPosition(kFontOffset)
    
    self.levelBackground:AddChild(self.levelText)

end


function GUIPlayerRanking:Uninitialize()

    if self.relativeSkillBackground then
    
        GUI.DestroyItem(self.relativeSkillBackground)
        self.relativeSkillBackground = nil
        
    end    
    
    if self.levelBackground then
    
        GUI.DestroyItem(self.levelBackground)
        self.levelBackground = nil
        
    end    

end

function GUIPlayerRanking:Update(deltaTime)
    PROFILE("GUIPlayerRanking:Update")
    
    local relativeSkillFraction = PlayerRankingUI_GetRelativeSkillFraction()
    
    self.skillBar:SetSize(Vector(kBarSize.x * relativeSkillFraction, kBarSize.y, 0))
    self.skillBar:SetColor(GetColorForFraction(relativeSkillFraction))
    
    local skillBarTexCoords = {}
    skillBarTexCoords[1] = kBarTexCoords[1]
    skillBarTexCoords[2] = kBarTexCoords[2]
    skillBarTexCoords[3] = kBarTexCoords[1] + (kBarTexCoords[3] - kBarTexCoords[1]) * relativeSkillFraction
    skillBarTexCoords[4] = kBarTexCoords[4]
    
    self.skillBar:SetTexturePixelCoordinates(unpack(skillBarTexCoords))
    
    local levelFraction = PlayerRankingUI_GetLevelFraction()
    
    self.levelBar:SetSize(Vector(kBarSize.x * levelFraction, kBarSize.y, 0))
    
    local levelBarTexCoords = {}
    levelBarTexCoords[1] = kBarTexCoords[1]
    levelBarTexCoords[2] = kBarTexCoords[2]
    levelBarTexCoords[3] = kBarTexCoords[1] + (kBarTexCoords[3] - kBarTexCoords[1]) * levelFraction
    levelBarTexCoords[4] = kBarTexCoords[4]
    
    self.levelBar:SetTexturePixelCoordinates(unpack(levelBarTexCoords))

end


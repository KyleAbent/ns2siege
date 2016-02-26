// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIGatherOverlay.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworld.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIGatherOverlay' (GUIAnimatedScript)

local kBackgroundSize = Vector(300, 40, 0)
local kFontName = Fonts.kAgencyFB_Small
local kFontScale = GUIScale(Vector(1,1,1))

local kStatusColor = Color(1,1,1,1)
local kChatColor = Color(0.6, 0.6, 0.6)

local kTextOffset = Vector(10, 4, 0)

local kAnimatedArrowTexture = "ui/menu/blinking_arrow.dds"
local kAnimatedArrowSize = Vector(64, 32, 0)
local kAnimatedArrowPosition = Vector(-68, 4, 0)
local kAnimatedArrowPixelCoords = {0, 0, 64, 32}

local kSpectatorOffset = 100

local function AnimateArrow(script, arrow)

    arrow:SetTexturePixelCoordinates(unpack(kAnimatedArrowPixelCoords))
    arrow:SetTextureAnimation(15, 1.6, "ARROW", nil, AnimateArrow)

end

function GUIGatherOverlay:Initialize()

    GUIAnimatedScript.Initialize(self)

    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetColor(Color(0,0,0,0.5))
    self.background:SetSize(kBackgroundSize)
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Top)
    
    self.chatMessage = self:CreateAnimatedTextItem()
    self.chatMessage:SetFontName(kFontName)
    self.chatMessage:SetColor(kChatColor)
    self.chatMessage:SetScale(kFontScale)
    GUIMakeFontScale(self.chatMessage)
    self.chatMessage:SetPosition(kTextOffset)
    self.chatMessage:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    
    self.statusMessage = self:CreateAnimatedTextItem()
    self.statusMessage:SetFontName(kFontName)
    self.statusMessage:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.statusMessage:SetTextAlignmentX(GUIItem.Align_Center)
    self.statusMessage:SetColor(kStatusColor)    
    self.statusMessage:SetScale(kFontScale)
    GUIMakeFontScale(self.statusMessage)
    self.statusMessage:SetPosition(kTextOffset)
    
    self.lastChatMessage = ""
    self.timeChatMessage = 0
    self.textColor = Color(0.7, 0.7, 0.7, 0)
    
    self.animatedArrow = self:CreateAnimatedGraphicItem()
    self.animatedArrow:SetTexture(kAnimatedArrowTexture)
    self.animatedArrow:SetSize(kAnimatedArrowSize)
    self.animatedArrow:SetPosition(kAnimatedArrowPosition)
    
    AnimateArrow(self, self.animatedArrow)
    
    self.background:SetIsVisible(false)
    self.background:AddChild(self.chatMessage)
    self.background:AddChild(self.statusMessage)
    self.background:AddChild(self.animatedArrow)
    
end 

function GUIGatherOverlay:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)

    self.background = nil
    self.chatMessage = nil
    self.statusMessage = nil
    self.animatedArrow = nil

end

function GUIGatherOverlay:Update(deltaTime)
                  
    PROFILE("GUIGatherOverlay:Update")
    
    if Sabot.GetIsInGather() then
    
        if MainMenu_IsInGame() and not MainMenu_GetIsOpened() then
            self.background:SetIsVisible(true)
        end
    
        GUIAnimatedScript.Update(self, deltaTime)

        local status = Sabot.GetGatherStatusMessage() or ""
        local chatMessage = Sabot.GetLastChatMessage()
        local gatherInfo = Sabot.GetGatherInfo(Sabot.GetGatherId())
        
        if self.lastChatMessage ~= chatMessage then
        
            self.lastChatMessage = chatMessage
            self.timeChatMessage = Shared.GetTime()
            
        end    
        
        self.textColor.a = 1 - math.max(0, Shared.GetTime() - self.timeChatMessage - 6)
        self.chatMessage:SetColor(self.textColor)
        self.chatMessage:SetText(self.lastChatMessage or "")
        
        if gatherInfo then
            
            if gatherInfo.playerNumber and gatherInfo.playerSlots then
                status = string.format("%d/%d  %s", gatherInfo.playerNumber, gatherInfo.playerSlots, status)
            end
        
        end
        
        self.statusMessage:SetText(status)  
        
        if MainMenu_IsInGame() then
        
            if PlayerUI_GetIsSpecating() or not Client.GetIsControllingPlayer() then
                self.background:SetPosition(Vector(-kBackgroundSize.x * 0.5, kSpectatorOffset, 0))
            else
                self.background:SetPosition(Vector(-kBackgroundSize.x * 0.5, 0, 0))
            end
            
        else
            self.background:SetPosition(Vector(-kBackgroundSize.x * 0.5, 0, 0))
        end
    
    else
        self.background:SetIsVisible(false)
    end

end
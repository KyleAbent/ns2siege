// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIScreenFade.lua
//
// Created by: Andreas Urwalek (andi@unkownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIScreenFade' (GUIAnimatedScript)

local animated = false
local kFontName = Fonts.kAgencyFB_Medium

function GUIScreenFade:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetColor(Color(0,0,0,0))
    self.background:SetIsScaling(false)
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(),0))
    self.background:SetLayer(kGUILayerDeathScreen)
    
    self.updateInterval = kUpdateIntervalAnimation
    
    animated = false
end

function GUIScreenFade:Reset()
    
    GUIAnimatedScript.Reset(self)
    
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(),0))
    animated = false
    
end

function GUIScreenFade:Update(deltaTime)

    PROFILE("GUIScreenFade:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)
    if animated == false then
        self.background:FadeIn(0.1, "SCREEN_FADE")
        
        if self.background:GetColor().a > 0.99 then
            animated = true 
        end

    end
    
    if animated == true then
        self.background:FadeOut(0.5, "SCREEN_FADE")
    end
end
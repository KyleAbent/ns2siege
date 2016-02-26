// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUISpeedDebug.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
//    UI display for console command "debugspeed". Shows a red bar + number indicating the current
//    velocity and white bar indicating any special move/initial timing (like skulk jump, marine
//    sprint, onos momentum)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local gMomentumBarHeight = 150
local kFontName = Fonts.kArial_17

class 'GUISpeedDebug' (GUIScript)

function GUISpeedDebug:Initialize()

    self.momentumBackGround = GetGUIManager():CreateGraphicItem()
    self.momentumBackGround:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.momentumBackGround:SetPosition(Vector(60, -235, 0))
    self.momentumBackGround:SetSize(Vector(gMomentumBarHeight, 30, 0))    
    self.momentumBackGround:SetColor(Color(1, 0.2, 0.2, 0.4))
    
    self.momentumFraction = GetGUIManager():CreateGraphicItem()
    self.momentumFraction:SetSize(Vector(0, 30, 0))
    self.momentumFraction:SetColor(Color(1, 0.2, 0.2, 0.6))
    
    self.debugText = GetGUIManager():CreateTextItem()
    self.debugText:SetScale(GetScaledVector())
    self.debugText:SetFontName(kFontName)
    GUIMakeFontScale(self.debugText)
    self.debugText:SetPosition(Vector(0, -65, 0))
    
    self.airAccel = GetGUIManager():CreateTextItem()
    self.airAccel:SetScale(GetScaledVector())
    self.airAccel:SetFontName(kFontName)
    GUIMakeFontScale(self.airAccel)
    self.airAccel:SetPosition(Vector(0, -45, 0))
    
    self.xzSpeed = GetGUIManager():CreateTextItem()
    self.xzSpeed:SetScale(GetScaledVector())
    self.xzSpeed:SetFontName(kFontName)
    GUIMakeFontScale(self.xzSpeed)
    self.xzSpeed:SetPosition(Vector(0, -25, 0))
    
    self.momentumBackGround:AddChild(self.debugText)
    self.momentumBackGround:AddChild(self.momentumFraction)
    self.momentumBackGround:AddChild(self.xzSpeed)
    self.momentumBackGround:AddChild(self.airAccel)
    
    Shared.Message("Enabled speed meter")

end

function GUISpeedDebug:Uninitialize()

    if self.momentumBackGround then
        GUI.DestroyItem(self.momentumBackGround)
        self.momentumBackGround = nil
    end
    
    Shared.Message("Disabled speed meter")

end

function GUISpeedDebug:SetDebugText(text)
    self.debugText:SetText(text)
end

function GUISpeedDebug:Update(deltaTime)
    PROFILE("GUISpeedDebug:Update")
    local player = Client.GetLocalPlayer()
    
    if player then

        local velocity = player:GetVelocity()
        local speed = velocity:GetLengthXZ()
        local bonusSpeedFraction
        
        if player:isa("Lerk") or player:isa("Fade") then
            bonusSpeedFraction = speed / player:GetMaxSpeed(false)
        else
            bonusSpeedFraction = speed / player:GetMaxSpeed(true)
        end
        
        self.momentumFraction:SetSize(Vector(gMomentumBarHeight * bonusSpeedFraction, 30, 0))
        self.xzSpeed:SetText( string.format( "current speed: %s  vertical speed: %s", ToString(RoundVelocity(speed)), ToString(RoundVelocity(velocity.y)) ) )
        
        local airAccelText = "air control value: " .. ToString(player:GetAirControl())
        self.airAccel:SetText(airAccelText)
    
    end

end
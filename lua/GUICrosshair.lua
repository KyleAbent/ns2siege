
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUICrosshair.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages the crosshairs for aliens and marines.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")
Script.Load("lua/GUIAssets.lua")

class 'GUICrosshair' (GUIAnimatedScript)

GUICrosshair.kCrosshairSize = 64
GUICrosshair.kCrosshairPos = Vector(-GUICrosshair.kCrosshairSize / 2, -GUICrosshair.kCrosshairSize / 2, 0)

function GUICrosshair:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUICrosshair:Initialize()

    GUIAnimatedScript.Initialize(self)

    self.crosshairs = GUIManager:CreateGraphicItem()
    self.crosshairs:SetSize(Vector(GUICrosshair.kCrosshairSize, GUICrosshair.kCrosshairSize, 0))
    self.crosshairs:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.crosshairs:SetPosition(GUICrosshair.kCrosshairPos)
    self.crosshairs:SetTexture(Textures.kCrosshairs)
    self.crosshairs:SetIsVisible(false)
    self.crosshairs:SetScale(GetScaledVector())
    self.crosshairs:SetLayer(kGUILayerPlayerHUD)
    
    self.damageIndicator = GUIManager:CreateGraphicItem()
    self.damageIndicator:SetSize(Vector(GUICrosshair.kCrosshairSize, GUICrosshair.kCrosshairSize, 0))
    self.damageIndicator:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.damageIndicator:SetPosition(Vector(0, 0, 0))
    self.damageIndicator:SetTexture(Textures.kCrosshairsHit)
    local yCoord = PlayerUI_GetCrosshairDamageIndicatorY()
    self.damageIndicator:SetTexturePixelCoordinates(0, yCoord,
                                                    64, yCoord + 64)
    self.damageIndicator:SetIsVisible(false)
    self.crosshairs:AddChild(self.damageIndicator)

end

function GUICrosshair:Uninitialize()

    // Destroying the crosshair will destroy all it's children too.
    GUI.DestroyItem(self.crosshairs)
    self.crosshairs = nil
    
    GUIAnimatedScript.Uninitialize(self)
    
end

local crosshairPos = Vector(0,0,0)

function GUICrosshair:Update(deltaTime)
    
    PROFILE("GUICrosshair:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)

    // Update crosshair image.
    local xCoord = PlayerUI_GetCrosshairX()
    local yCoord = PlayerUI_GetCrosshairY()
    
    local showCrossHair = not PlayerUI_GetIsDead() and PlayerUI_GetIsPlaying() and not PlayerUI_GetIsThirdperson() and not PlayerUI_IsACommander() and not PlayerUI_GetBuyMenuDisplaying() and not MainMenu_GetIsOpened()
                          //and not PlayerUI_GetIsConstructing() and not PlayerUI_GetIsRepairing()
    
    self.crosshairs:SetIsVisible(showCrossHair)
    
    if showCrossHair then
        if xCoord and yCoord then
        
            self.crosshairs:SetTexturePixelCoordinates(xCoord, yCoord,
                                                       xCoord + PlayerUI_GetCrosshairWidth(), yCoord + PlayerUI_GetCrosshairHeight())
            
            self.damageIndicator:SetTexturePixelCoordinates(xCoord, yCoord,
                                                       xCoord + PlayerUI_GetCrosshairWidth(), yCoord + PlayerUI_GetCrosshairHeight())

        end
    end
    
    local animSpeed = 3
    
    // Update give damage indicator.
    local indicatorVisible, timePassedPercent = PlayerUI_GetShowGiveDamageIndicator()
    self.damageIndicator:SetIsVisible(indicatorVisible and showCrossHair)
    self.damageIndicator:SetColor(Color(1, 1, 1, 1 - timePassedPercent * animSpeed))

end

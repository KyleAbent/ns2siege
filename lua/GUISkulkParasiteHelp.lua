// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUISkulkParasiteHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kParasiteTextureName = "ui/parasite.dds"

local kIconHeight = 128
local kIconWidth = 128

class 'GUISkulkParasiteHelp' (GUIAnimatedScript)

function GUISkulkParasiteHelp:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUISkulkParasiteHelp:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.keyBackground = GUICreateButtonIcon("Weapon" .. kParasiteHUDSlot)
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + GUIScale(kHelpBackgroundYOffset), 0))
    
    self.attackKeyBackground = GUICreateButtonIcon("PrimaryAttack")
    self.attackKeyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    size = self.attackKeyBackground:GetSize()
    self.attackKeyBackground:SetPosition(Vector(-size.x / 2, -size.y + GUIScale(kHelpBackgroundYOffset), 0))
    self.attackKeyBackground:SetIsVisible(false)
    
    self.parasiteImage = self:CreateAnimatedGraphicItem()
    self.parasiteImage:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.parasiteImage:SetSize(Vector(kIconWidth, kIconHeight, 0))
    self.parasiteImage:SetPosition(Vector(-kIconWidth / 2, -kIconHeight, 0))
    self.parasiteImage:SetTexture(kParasiteTextureName)
    self.parasiteImage:SetIsVisible(false)
    self.parasiteImage:AddAsChildTo(self.keyBackground)
    
end

function GUISkulkParasiteHelp:Update(dt)
    PROFILE("GUISkulkParasiteHelp:Update")
    GUIAnimatedScript.Update(self, dt)
    
    self.keyBackground:SetIsVisible(false)
    self.attackKeyBackground:SetIsVisible(false)
    
    if not self.parasiteUsed then
    
        local player = Client.GetLocalPlayer()
        if player then
        
            if not self.parasiteImage:GetIsVisible() then
                HelpWidgetAnimateIn(self.parasiteImage)
            end
            self.parasiteImage:SetIsVisible(true)
            
            // Show the switch weapon key until they change to the parasite.
            local parasiteEquipped = player:GetActiveWeapon() and player:GetActiveWeapon():isa("Parasite")
            self.keyBackground:SetIsVisible(parasiteEquipped ~= true)
            self.attackKeyBackground:SetIsVisible(parasiteEquipped == true)
            self.parasiteImage:AddAsChildTo(parasiteEquipped and self.attackKeyBackground or self.keyBackground)
            if parasiteEquipped and player:GetPrimaryAttackLastFrame() then
            
                self.keyBackground:SetIsVisible(false)
                self.attackKeyBackground:SetIsVisible(false)
                self.parasiteImage:SetIsVisible(false)
                self.parasiteUsed = true
                HelpWidgetIncreaseUse(self, "GUISkulkParasiteHelp")
                
            end
            
        end
        
    end
    
end

function GUISkulkParasiteHelp:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)
    
    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
    GUI.DestroyItem(self.attackKeyBackground)
    self.attackKeyBackground = nil
    
    GUI.DestroyItem(self.parasiteImage)
    self.parasiteImage = nil
    
end
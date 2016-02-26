// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUILerkSporesHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kSporesTextureName = "ui/lerk_spores.dds"

local kIconHeight = 128
local kIconWidth = 128

class 'GUILerkSporesHelp' (GUIAnimatedScript)

function GUILerkSporesHelp:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUILerkSporesHelp:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.keyBackground = GUICreateButtonIcon("Weapon" .. kSporesHUDSlot)
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + GUIScale(kHelpBackgroundYOffset), 0))
    
    self.attackKeyBackground = GUICreateButtonIcon("PrimaryAttack")
    self.attackKeyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    size = self.attackKeyBackground:GetSize()
    self.attackKeyBackground:SetPosition(Vector(-size.x / 2, -size.y + GUIScale(kHelpBackgroundYOffset), 0))
    self.attackKeyBackground:SetIsVisible(false)
    
    self.sporesImage = self:CreateAnimatedGraphicItem()
    self.sporesImage:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.sporesImage:SetSize(Vector(kIconWidth, kIconHeight, 0))
    self.sporesImage:SetPosition(Vector(-kIconWidth / 2, -kIconHeight, 0))
    self.sporesImage:SetTexture(kSporesTextureName)
    self.sporesImage:SetIsVisible(false)
    self.sporesImage:AddAsChildTo(self.keyBackground)
    
end

function GUILerkSporesHelp:Update(dt)
    
    PROFILE("GUILerkSporesHelp:Update")
    
    GUIAnimatedScript.Update(self, dt)
    
    self.keyBackground:SetIsVisible(false)
    self.attackKeyBackground:SetIsVisible(false)
    
    if not self.sporesUsed then
    
        local player = Client.GetLocalPlayer()
        if player then
        
            local sporesWeapon = player:GetWeaponInHUDSlot(kSporesHUDSlot)
            local displayWidget = not self.sporesUsed and sporesWeapon
            
            if displayWidget then
            
                if not self.sporesImage:GetIsVisible() then
                    HelpWidgetAnimateIn(self.sporesImage)
                end
                self.sporesImage:SetIsVisible(true)
                
                // Show the switch weapon key until they change to the spores.
                local sporesEquipped = player:GetActiveWeapon() == sporesWeapon
                self.keyBackground:SetIsVisible(sporesEquipped ~= true)
                self.attackKeyBackground:SetIsVisible(sporesEquipped == true)
                self.sporesImage:AddAsChildTo(sporesEquipped and self.attackKeyBackground or self.keyBackground)
                if sporesEquipped and player:GetPrimaryAttackLastFrame() then
                
                    self.keyBackground:SetIsVisible(false)
                    self.attackKeyBackground:SetIsVisible(false)
                    self.sporesImage:SetIsVisible(false)
                    self.sporesUsed = true
                    HelpWidgetIncreaseUse(self, "GUILerkSporesHelp")
                    
                end
                
            end
            
        end
        
    end
    
end

function GUILerkSporesHelp:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)
    
    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
    GUI.DestroyItem(self.attackKeyBackground)
    self.attackKeyBackground = nil
    
    GUI.DestroyItem(self.sporesImage)
    self.sporesImage = nil
    
    GUI.DestroyItem(self.background)
    self.background = nil
    
end
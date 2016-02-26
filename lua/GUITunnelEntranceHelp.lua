// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUITunnelEntranceHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kBlinkTextureName = "ui/enter_tunnel.dds"

local kIconWidth = 128
local kIconHeight = 128

class 'GUITunnelEntranceHelp' (GUIAnimatedScript)

function GUITunnelEntranceHelp:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUITunnelEntranceHelp:Initialize()

    GUIAnimatedScript.Initialize(self)

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetColor(Color(0, 0, 0, 0))
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.background:SetSize(GUIScale(Vector(32, 32, 0)))
    self.background:SetPosition(GUIScale(Vector(-16, -16 + kHelpBackgroundYOffset, 0)))
    
    self.tunnelImage = self:CreateAnimatedGraphicItem()
    self.tunnelImage:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.tunnelImage:SetSize(Vector(kIconWidth, kIconHeight, 0))
    self.tunnelImage:SetPosition(Vector(0, 0, 0))
    self.tunnelImage:SetTexture(kBlinkTextureName)
    self.tunnelImage:SetIsVisible(false)
    self.tunnelImage:AddAsChildTo(self.background)
    
    self.wasInTunnel = false
    
end

function GUITunnelEntranceHelp:Update(dt)
    PROFILE("GUITunnelEntranceHelp:Update")
    GUIAnimatedScript.Update(self, dt)
    
    local player = Client.GetLocalPlayer()
    if player and not self.wasInTunnel then
    
        if GetIsPointInGorgeTunnel(player:GetOrigin()) then
        
            HelpWidgetIncreaseUse(self, "GUITunnelEntranceHelp")
            self.tunnelImage:SetIsVisible(false)
            self.wasInTunnel = true 
            
        else
        
            local entrances = GetEntitiesWithinRange("TunnelEntrance", player:GetOrigin(), 4)
            local showWidget = #entrances > 0 and entrances[1]:GetIsBuilt()
            if showWidget and not self.tunnelImage:GetIsVisible() then
                HelpWidgetAnimateIn(self.tunnelImage)
            end
            
            self.tunnelImage:SetIsVisible(showWidget)
            
        end
        
    end
    
end

function GUITunnelEntranceHelp:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)
    
    GUI.DestroyItem(self.background)
    self.background = nil
    
end
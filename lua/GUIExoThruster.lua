// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/GUIExoThruster.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIExoThruster' (GUIScript)

local kBackgroundSize
local kBackgroundOffset
local kPadding

local kPadWidth
local kPadHeight

local kPadActiveColor = Color(0.8, 0.9, 1, 0.8)
local kPadInactiveColor = Color(0.0, 0.0, 0.1, 0.4)

local kBackgroundPadding

local kBackgroundColor = Color(0.8, 0.9, 1, 0.1)

local kNumPads = 12

local function UpdateItemsGUIScale(self)
    kBackgroundSize = GUIScale(Vector(256, 70, 0))
    kBackgroundOffset = GUIScale(Vector(0, -80, 0))
    kPadding = math.max(1, math.round( GUIScale(3) ))

    kPadWidth = math.round( GUIScale(13) )
    kPadHeight = GUIScale(9)

    kBackgroundPadding = GUIScale(10)
end

function GUIExoThruster:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateItemsGUIScale(self)
    
    self:Uninitialize()
    self:Initialize()
end

function GUIExoThruster:Initialize()

    UpdateItemsGUIScale(self)

    self.background = GetGUIManager():CreateGraphicItem()
    self.pads = {}
    
    local backgroundSize = Vector(kNumPads * kPadWidth + (kNumPads - 1) * kPadding + 2 * kBackgroundPadding, 2 * kBackgroundPadding + kPadHeight, 0)
    
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.background:SetSize(backgroundSize)
    self.background:SetPosition(-backgroundSize * 0.5 + kBackgroundOffset)
    self.background:SetColor(kBackgroundColor)
    
    self.thrusterFraction = 1
    
    for i = 1, kNumPads do
    
        local pos = Vector((i - 1) * (kPadding + kPadWidth) + kBackgroundPadding, -kPadHeight * 0.5, 0)
        local pad = GetGUIManager():CreateGraphicItem()
        pad:SetPosition(pos)
        pad:SetIsVisible(true)
        pad:SetColor(kPadActiveColor)
        pad:SetAnchor(GUIItem.Left, GUIItem.Center)
        pad:SetSize(Vector(kPadWidth, kPadHeight, 0))
    
        self.background:AddChild(pad)
        
        table.insert(self.pads, pad)
    
    end

end

function GUIExoThruster:Uninitialize()

    if self.background then
    
        GUI.DestroyItem(self.background)
        self.background = nil
    
    end
    
    self.pads = nil

end

function GUIExoThruster:Update(deltaTime)
                  
    PROFILE("GUIExoThruster:Update")
    
    local player = Client.GetLocalPlayer()
    local desiredThrusterFraction = (player and player.GetFuel) and player:GetFuel() or 0
    
    self.thrusterFraction = Slerp(self.thrusterFraction, desiredThrusterFraction, deltaTime * 1.7)

    for i = 1, kNumPads do

        local padFraction = i / kNumPads
        self.pads[i]:SetColor(padFraction <= self.thrusterFraction and kPadActiveColor or kPadInactiveColor )

    end

end
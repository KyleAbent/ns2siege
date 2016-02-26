//======= Copyright (c) 2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIExoEject.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kButtonPos
local kTextOffset

local kFontName = Fonts.kAgencyFB_Small

class 'GUIExoEject' (GUIScript)

local function UpdateItemsGUIScale(self)
    kButtonPos = GUIScale(Vector(180, -120, 0))
    kTextOffset = GUIScale(Vector(0, 20, 0))
end

function GUIExoEject:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateItemsGUIScale(self)
    
    self:Uninitialize()
    self:Initialize()
end

function GUIExoEject:Initialize()

    UpdateItemsGUIScale(self)
    
    self.button = GUICreateButtonIcon("Drop")
    self.button:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.button:SetPosition(kButtonPos)
    
    self.text = GetGUIManager():CreateTextItem()
    self.text:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.text:SetTextAlignmentX(GUIItem.Align_Center)
    self.text:SetTextAlignmentY(GUIItem.Align_Center)
    self.text:SetText(Locale.ResolveString("EJECT_FROM_EXO"))
    self.text:SetPosition(kTextOffset)
    self.text:SetScale(GetScaledVector())
    self.text:SetFontName(kFontName)
    GUIMakeFontScale(self.text)
    self.text:SetColor(kMarineFontColor)

    self.button:AddChild(self.text)
    self.button:SetIsVisible(false)

end


function GUIExoEject:Uninitialize()

    if self.button then
        GUI.DestroyItem(self.button)
    end

end

function GUIExoEject:Update(deltaTime)
                  
    PROFILE("GUIExoEject:Update")
    
    local player = Client.GetLocalPlayer()
    local showEject = player ~= nil and Client.GetIsControllingPlayer() and player:GetCanEject() and not MainMenu_GetIsOpened()
    
    self.button:SetIsVisible(showEject)

end
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\menu\MenuButton.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load('lua/menu/MenuElement.lua')

local kDefaultMenuButtonFontSize = 24
local kDefaultSize = Vector(16, 16, 0)
local kDefaultBorderWidth = 1
local kDefaultMenuButtonFontName = Fonts.kArial_15 
local kDefaultFontSize = 18
local kDefaultFontColor = Color(0.77, 0.44, 0.22)

class 'MenuButton' (MenuElement)

function MenuButton:GetTagName()
    return "button"
end

function MenuButton:Initialize()

    MenuElement.Initialize(self)
    
    self:SetBackgroundSize(kDefaultSize)
    self:SetBorderWidth(kDefaultBorderWidth)
    
    self.text = CreateTextItem(self)
    self.text:SetColor(kDefaultFontColor)
    self.text:SetFontName(kDefaultMenuButtonFontName)
    self.text:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.text:SetTextAlignmentX(GUIItem.Align_Center)
    self.text:SetTextAlignmentY(GUIItem.Align_Center)
    self:GetBackground():AddChild(self.text)
    
    self:EnableHighlighting()
    
    local eventCallbacks = {
      
    OnClick = function (self)
        MainMenu_OnButtonClicked()
    end, 
    }
    
    self:AddEventCallbacks(eventCallbacks)
    
end

function MenuButton:SetTextColor(color, time, animateFunc, animName, callBack)
    self.text:SetColor(color, time, animName, animateFunc, callBack)
end

function MenuButton:SetText(text, time, animateFunc, animName, callBack)
    self.text:SetText(text, time, animName, animateFunc, callBack)
end

function MenuButton:SetFontSize(fontSize, time, animateFunc, animName, callBack)
    self.text:SetFontSize(fontSize, time, animName, animateFunc, callBack)
end

function MenuButton:SetFontName(fontName)
    self.text:SetFontName(fontName)
end

function MenuButton:SetIsScaling(isScaling)

    MenuElement.SetIsScaling(self, isScaling)
    
    self.text:SetIsScaling(isScaling)
    
end
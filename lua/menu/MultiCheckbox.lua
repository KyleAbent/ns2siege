// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\menu\MultiCheckbox.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/FormElement.lua")
Script.Load("lua/menu/MultiCheckboxList.lua")

class 'MultiCheckbox' (FormElement)

local kDefaultOptionFontSize = 24
local kDefaultOptionFontName = Fonts.kArial_15 
local kDefaultOptionFontColor = Color(1,1,1,1)
local kDefaultSize = Vector(32, 32, 0)
local kDefaultBackgroundColor = Color(0,0,0,1)
local textureCoordinates = { 0, 95, 30, 125 }

function MultiCheckbox:Initialize()

    FormElement.Initialize(self)
    
    self:SetBorderHighlightColor( Color(0, 0, 0, 0) )
    
    self.optionTextColor = kDefaultOptionFontColor
    self.optionFontSize = kDefaultOptionFontSize
    self.optionFontName = kDefaultOptionFontName
    
    self:GetBackground():SetColor(Color(0, 0, 0, 0))
    
    self.multicheckboxlist = CreateMenuElement(self, "MultiCheckboxList", false)
    self.multicheckboxlist:SetIsVisible(false)
    self.multicheckboxlist:SetInitialVisible(false)
    
    self.activeOption = CreateMenuElement(self, "MenuButton", false)
    self.activeOption:SetBorderWidth(0)
    self.activeOption:SetBackgroundColor(Color(0, 0, 0, 1))
    self.activeOption:SetBackgroundTexture("")
    
    self.checkedImage = CreateMenuElement(self, "Image", false)
    
    self.checkedImage:AddEventCallbacks({ 
        OnClick = function(self) 
            self:GetParent():CicleMultiCheckbox() 
            MainMenu_OnCheckboxOff()
        end 
    })
    
    self.options = { }
    
    self:SetBackgroundColor(kDefaultBackgroundColor)
    
    self:SetIsScaling(true)
    
    self:SetBackgroundSize(kDefaultSize, true)
    
    self:SetHeight(self.activeOption:GetHeight())
    
    self:SetChildrenIgnoreEvents(false)
end

function MultiCheckbox:SetBackgroundSize(sizeVector, absolute, time, animateFunc, animName, callBack)
    
    FormElement.SetBackgroundSize(self, sizeVector, absolute, time, animateFunc, animName, callBack)
    
    local widthMinusButtons = self:GetWidth()
    self.activeOption:SetWidth(widthMinusButtons)
    self.activeOption:SetHeight(sizeVector.y)

    self.multicheckboxlist:SetWidth(widthMinusButtons)
    self.multicheckboxlist:SetHeight(sizeVector.y)
    
end

function MultiCheckbox:OnChildChanged(child)

    if child == self.activeOption then
        self.multicheckboxlist:SetTopOffset(self.activeOption:GetHeight())
    end
    
end

function MultiCheckbox:GetTagName()
    return "multicheckbox"
end

function MultiCheckbox:SetValue(value)

    FormElement.SetValue(self, value)
    
    if self.activeOption then
        if self:GetActiveOptionIndex() == 1 then
            self.checkedImage:SetCSSClass("unchecked", true)
        elseif self:GetActiveOptionIndex() == 2 then
            self.checkedImage:SetCSSClass("partialchecked", true)
        elseif self:GetActiveOptionIndex() == 3 then
            self.checkedImage:SetCSSClass("checked", true)
        end
    end
    
    
end

function MultiCheckbox:SetOptions(options)

    self.options = options
    self.multicheckboxlist:_Reload()
    
end

function MultiCheckbox:GetOptions(options)
    return self.options
end

function MultiCheckbox:SetOptionActive(index)

    self:SetValue(self.options[index])
    
end

function MultiCheckbox:GetActiveOptionIndex()

    local currentValue = self:GetValue()
    local currentIndex = 1
    
    for index, option in ipairs(self.options) do
    
        if option == currentValue then
        
            currentIndex = index
            break
            
        end
        
    end
    
    return currentIndex
    
end

function MultiCheckbox:SetBackgroundColor(color, time, animateFunc, animName, callBack)

    if self.multicheckboxlist then
        self.multicheckboxlist:SetBackgroundColor(color, time, animateFunc, animName, callBack)
    end
    
    if self.activeOption then
        self.activeOption:SetBackgroundColor(color, time, animateFunc, animName, callBack)
    end
    
end

function MultiCheckbox:CicleMultiCheckbox()

    local optionsLength = table.getn(self.options)
    local currentIndex = self:GetActiveOptionIndex()
    
    currentIndex = currentIndex % optionsLength + 1
    self:SetValue(self.options[currentIndex])

end
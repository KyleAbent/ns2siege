// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\menu\MultiCheckboxList.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")

class 'MultiCheckboxList' (MenuElement)

local kOptionTextSpacing = 6
local kDefaultSize = Vector(24, 24, 0)

local function ClearOptionsText(self)

    for index, optionText in ipairs(self.optionsText) do    
        optionText:Destroy()    
    end

    self.optionsText = {}
    
end

local function ReloadOptions(self)



end

function MultiCheckboxList:Initialize()

    MenuElement.Initialize(self)
    
    self.contentBox = CreateMenuElement(self, "ContentBox", false)
    
    self:SetBackgroundSize(kDefaultSize, true)
    
    self.optionsText = {}

end

function MultiCheckboxList:GetTagName()
    return "multicheckboxlist"
end

function MultiCheckboxList:OnOptionClicked(index)
    self:GetParent():SetOptionActive(index)
end

function MultiCheckboxList:_Reload()

    ClearOptionsText(self)
    
    local height = 24
    local totalheight = 0
    
    for index, option in ipairs(self:GetParent():GetOptions()) do
    
        local font = CreateMenuElement(self.contentBox, "Font", false)
        font:SetText(ToString(option))
        font.index = index
        font.multicheckboxHandle = self
        font:SetTopOffset( (index-1) * height )
        font:AddEventCallbacks({ OnClick = function (self) self.multicheckboxHandle:OnOptionClicked(self.index)  end })
        font:SetCSSClass("dropdownentry")
        
        totalheight = totalheight + height
    
    
    end
    
    totalheight = totalheight + 4
    self:SetHeight(totalheight)

end

function MultiCheckboxList:SetBackgroundSize(sizeVector, absolute, time, animateFunc, animName, callBack)

    MenuElement.SetBackgroundSize(self, sizeVector, absolute, time, animateFunc, animName, callBack)

    self.contentBox:SetBackgroundSize(self:GetBackground():GetSize(), absolute, time, animateFunc, animName, callBack)

end
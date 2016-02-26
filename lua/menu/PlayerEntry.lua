// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. ======
//
// lua\menu\PlayerEntry.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more inTableation, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/WindowUtility.lua")

kPlayerEntryHeight = 28
local kPlayerEntryDefaultWidth = 530

class 'PlayerEntry' (MenuElement)

function PlayerEntry:Initialize()

    self:DisableBorders()
    
    MenuElement.Initialize(self)
    
    self:SetChildrenIgnoreEvents(true)
    
    self.playerName = CreateTextItem(self, true)
    
    self.timePlayed = CreateTextItem(self, true)
    self.timePlayed:SetTextAlignmentX(GUIItem.Align_Max)
    
    self.score = CreateTextItem(self, true)
    self.score:SetTextAlignmentX(GUIItem.Align_Max)
    
    self:SetFontName(Fonts.kAgencyFB_Tiny)
    
    self:SetTextColor(kWhite)
    self:SetHeight(kPlayerEntryHeight)
    self:SetWidth(kPlayerEntryDefaultWidth)
    self:SetBackgroundColor(kNoColor)

end

function PlayerEntry:SetParentList(parentList)
    self.parentList = parentList
end

function PlayerEntry:SetFontName(fontName)

    self.playerName:SetFontName(fontName)
    self.timePlayed:SetFontName(fontName)
    self.score:SetFontName(fontName)

end

function PlayerEntry:SetTextColor(color)

    self.playerName:SetColor(color)
    self.timePlayed:SetColor(color)
    self.score:SetColor(color)
    
end

local function FormatTime(time)

    local seconds = math.round(time)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    minutes = minutes - hours * 60
    seconds = seconds - minutes * 60 - hours * 3600
    return string.format("%d:%.2d:%.2d", hours, minutes, seconds)
    
end

function PlayerEntry:SetPlayerData(playerData)

    PROFILE("PlayerEntry:SetPlayerData")

    if self.playerData ~= playerData then
    
        self.playerName:SetText(playerData.name)
        self.timePlayed:SetText(FormatTime(playerData.timePlayed))
        self.score:SetText(ToString(playerData.score))

        self.playerData = { }
        for name, value in pairs(playerData) do
            self.playerData[name] = value
        end
        
    end
    
end

local kUseVector = Vector(1, 0, 0)
function PlayerEntry:SetWidth(width, isPercentage, time, animateFunc, callBack)

    if width ~= self.storedWidth then

        MenuElement.SetWidth(self, width, isPercentage, time, animateFunc, callBack)

        self.playerName:SetPosition(kUseVector * width * 0.02)
        self.timePlayed:SetPosition(kUseVector * width * 0.72)
        self.score:SetPosition(kUseVector * width * 0.98)
        
        self.storedWidth = width
    
    end

end

function PlayerEntry:SetBackgroundTexture()
    Print("PlayerEntry:SetBackgroundTexture")
end

// do nothing, save performance, save the world
function PlayerEntry:SetCSSClass(cssClassName, updateChildren)
end

function PlayerEntry:GetTagName()
    return "playerentry"
end

// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. ======
//
// lua\menu\ServerTabs.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more inTableation, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/WindowUtility.lua")
Script.Load("lua/menu/ServerList.lua")

class 'ServerTabs' (MenuElement)

local kDefaultButtons = {

    {
        name = "ALL",
        filters = { [1] = FilterServerMode(""), [8] = FilterFavoriteOnly(false), [11] = FilterHistoryOnly(false) },
    },
    
    {
        name = "NS2",
        filters = { [1] = FilterServerMode("ns2"), [8] = FilterFavoriteOnly(false), [11] = FilterHistoryOnly(false) },
    },
    
}

local kSuffixButtons = {

    {
        name = Locale.ResolveString("SERVERBROWSER_HISTORY"),
        suffix = true,
        filters = { [1] = FilterServerMode(""), [8] = FilterFavoriteOnly(false), [11] = FilterHistoryOnly(true) },
    },

    {
        name = Locale.ResolveString("SERVERBROWSER_FAVORITES"),
        suffix = true,
        filters = { [1] = FilterServerMode(""), [8] = FilterFavoriteOnly(true), [11] = FilterHistoryOnly(false) },
    },

}

local function UpdateTabHighlight(self)

    local pointX, pointY = Client.GetCursorPosScreen()
    local highlighted = false
    
    local allTabs = {}
    table.copy(self.tabs, allTabs, true)
    table.copy(self.suffixTabs, allTabs, true)

    for _, tab in ipairs(allTabs) do
    
        if not highlighted and GUIItemContainsPoint(tab.guiItem, pointX, pointY) then
        
            if self.highLightColor then
                tab:SetColor(self.highLightColor)
            end
            
            highlighted = true
            
        elseif tab:GetText() == self.selectedTab then    
            
            if self.highLightColor then
                tab:SetColor(self.highLightColor)
            end
            
        else
        
            if self.textColor then
                tab:SetColor(self.textColor)
            end
        
        end

    end

end

local function GetFiltersByTabName(name, definitions)

    for _, tabDef in ipairs(definitions) do
    
        if tabDef.name == name then
            return tabDef.filters
        end
    
    end
    
    return {}

end

function ServerTabs:Initialize()

    self:DisableBorders()
    
    MenuElement.Initialize(self)

    local eventCallbacks =
    {
        
        OnMouseOver = function(self)
            
            UpdateTabHighlight(self)
            
        end,
        
        OnClick = function(self)
        
            local success = false
        
            for index, tab in ipairs(self.tabs) do
                
                local pointX, pointY = Client.GetCursorPosScreen()
                if GUIItemContainsPoint(tab.guiItem, pointX, pointY) then
                
                    self:EnableFilter(self.layout[index].filters)
                    self.selectedTab = tab.guiItem:GetText()
                    self:UpdateTabSelector()
                    MainMenu_OnMouseClick()
                    
                    success = true
                    
                    break
                
                end
                
            end

            if not success then

                for index, tab in ipairs(self.suffixTabs) do
                    
                    local pointX, pointY = Client.GetCursorPosScreen()
                    if GUIItemContainsPoint(tab.guiItem, pointX, pointY) then
                    
                        local filters = GetFiltersByTabName(tab:GetText(), kSuffixButtons)
                    
                        self:EnableFilter(filters)
                        self.selectedTab = tab.guiItem:GetText()
                        self:UpdateTabSelector()
                        MainMenu_OnMouseClick()
                        
                        success = true
                        
                        break
                    
                    end
                    
                end

            end        
        
        end,

    }
    
    self:AddEventCallbacks(eventCallbacks)
    
    self.tabs = {}
    self.suffixTabs = {}
    
    self.tabSelector = CreateGraphicItem(self)
    self.tabSelector:SetColor(Color(0.49, 0.9, 0.98, 0.2))
    self.tabSelector:SetInheritsParentScaling(false)
    self.tabSelector:SetAnchor(GUIItem.Middle, GUIItem.Top)
    
    self.selectedTab = "ALL"
    
    self.tabSelector:SetIsVisible(false)

end

function ServerTabs:GetTagName()
    return "servertabs"
end

local function SortByPlayerCount(entry1, entry2)
    return entry1.count > entry2.count
end

function ServerTabs:SetServerList(serverList)
    self.serverList = serverList
end

function ServerTabs:EnableFilter(filters)

    if self.serverList then
    
        for index, filterFunc in pairs(filters) do        
            self.serverList:SetFilter(index, filterFunc)        
        end
    
    
    else
        Print("Warning: No server list set for ServerTabs item.")
    end

end

function ServerTabs:SetGameTypes(gameTypes)

    local types = {}
    for gameType, playerCount in pairs(gameTypes) do
        table.insert(types, {name = gameType, count = playerCount})
    end
    
    table.sort(types, SortByPlayerCount)

    self.layout = {}
    for _, type in ipairs(kDefaultButtons) do
        table.insert(self.layout, type)
    end

    for _, type in ipairs(types) do
    
        local gameType = type.name
        
        if gameType == "ns2" then
        
            self.layout[2].playerCount = type.count
        
        elseif gameType ~= "?" then

            local button = 
            {
                name = string.upper(gameType),
                filters = { [1] = FilterServerMode(gameType), [8] = FilterFavoriteOnly(false), [11] = FilterHistoryOnly(false) },
                playerCount = type.count,
            }
            
            table.insert(self.layout, button)
        
        end
    
    end
    
    self:Render()

end

function ServerTabs:SetFontName(fontName)
    self.fontName = fontName
end

function ServerTabs:SetTextColor(color)
    self.textColor = color
end

function ServerTabs:SetHoverTextColor(color)
    self.highLightColor = color
end

function ServerTabs:ClearTabs()

    for _, tab in ipairs(self.tabs) do    
        DestroyGUIItem(tab)    
    end
    
    self.tabs = {}

end

local function UpdateTabNum(self)

    local currentTabNum = #self.tabs
    local desiredTabNum = #self.layout

    if currentTabNum < desiredTabNum then
        
        for i = 1, desiredTabNum - currentTabNum do
            table.insert(self.tabs, CreateTextItem(self, true))
            self.tabs[#self.tabs]:SetAnchor(GUIItem.Left, GUIItem.Center)
            self.tabs[#self.tabs]:SetTextAlignmentY(GUIItem.Align_Center)
        end
    
    end

end

function ServerTabs:Reset()

    local tabSelectorParent = self.tabSelector.guiItem:GetParent()
    if tabSelectorParent then
        tabSelectorParent:RemoveChild(self.tabSelector.guiItem)
    end
    
    self:ClearTabs()
    self.layout = {}
    self.tabSelector:SetIsVisible(false)

end

function ServerTabs:UpdateTabSelector()

    local tabParent = self.tabSelector.guiItem:GetParent()
    if not tabParent or tabParent:GetText() ~= self.selectedTab then
    
        if tabParent then
            tabParent:RemoveChild(self.tabSelector.guiItem)
        end
        
        local allTabs = {}
        table.copy(self.tabs, allTabs, true)
        table.copy(self.suffixTabs, allTabs, true)
        
        for _, tab in ipairs(allTabs) do
        
            local tabText = tab:GetText()
            if tabText == self.selectedTab then
            
                tab.guiItem:AddChild(self.tabSelector.guiItem)
                self.tabSelector:SetIsVisible(true)
                local width = tab:GetTextWidth(tabText) + 20
                local height = tab:GetTextHeight(tabText) + 5
                self.tabSelector:SetSize(GUIScale(Vector(width, height, 0)))
                self.tabSelector:SetPosition(GUIScale(Vector(-width/2, -height/2, 0)))
            
            end
        
        end
    
    end

end

function ServerTabs:Render()

    local offset = GUIScale(15)
    local maxWidth = self.background.guiItem:GetSize().x
    
    local pointX, pointY = Client.GetCursorPosScreen()
    
    UpdateTabNum(self)
    
    local suffixTabSpace = 0
    
    for index, tabDef in ipairs(kSuffixButtons) do
        
        local tab = self.suffixTabs[index]
        
        if not tab then
        
            self.suffixTabs[index] = CreateTextItem(self, true)
            self.suffixTabs[index]:SetAnchor(GUIItem.Right, GUIItem.Center)
            self.suffixTabs[index]:SetTextAlignmentY(GUIItem.Align_Center)
            tab = self.suffixTabs[index]
            
        end
        
        tab:SetText(tabDef.name)
        tab:SetScale(GetScaledVector())

        local width = tab:GetTextWidth(tabDef.name)
        suffixTabSpace = GUIScale(15 + width) + suffixTabSpace
        tab:SetPosition(Vector(-suffixTabSpace, 0, 0 ))
        
        local useHighLightColor = text == self.selectedTab or GUIItemContainsPoint(tab.guiItem, pointX, pointY)
        
        if useHighLightColor then
        
            if self.highLightColor then
                tab:SetColor(self.highLightColor)
            end
            
        else
        
            if self.textColor then
                tab:SetColor(self.textColor)
            end
        
        end
        
        if self.fontName then
            tab:SetFontName(self.fontName)
        end
    
    end
    
    maxWidth = maxWidth - suffixTabSpace

    for index, tabDefinition in ipairs(self.layout) do

        local tab = self.tabs[index]
        local additionalOffset = 0

        local text = tabDefinition.name
        tab:SetText(text)
        tab:SetScale(GetScaledVector())
        tab:SetPosition(Vector(offset, 0, 0))
        
        local useHighLightColor = text == self.selectedTab or GUIItemContainsPoint(tab.guiItem, pointX, pointY)
        
        if useHighLightColor then
        
            if self.highLightColor then
                tab:SetColor(self.highLightColor)
            end
            
        else
        
            if self.textColor then
                tab:SetColor(self.textColor)
            end
        
        end
        
        if self.fontName then
            tab:SetFontName(self.fontName)
        end
        
        tab:SetIsVisible(offset < maxWidth)
        
        offset = offset + GUIScale(25 + tab:GetTextWidth(text))

    end
    
    self:UpdateTabSelector()

end


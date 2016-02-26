// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\GUIStartVoteMenu.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIStartVoteMenu' (GUIScript)

local kBackgroundColor = Color(0.0, 0.0, 0.0, 0.7)
local kTitleColor = Color(0.08, 0.16, 0.26, 1)
local kEscapeColor = Color(0.7, 0.7, 0.7, 1)
local kEscapeBackgroundColor = Color(0.0, 0.0, 0.0, 1)
local kEscapeBackgroundSelectedColor = Color(0.2, 0.2, 0.2, 1)
local kEscapeOffset = Vector(10, 0, 0)
local kNextColor = Color(0.7, 0.7, 0.7, 1)
local kNextBackgroundColor = Color(0.0, 0.0, 0.0, 1)
local kNextBackgroundSelectedColor = Color(0.2, 0.2, 0.2, 1)
local kPrevColor = Color(0.7, 0.7, 0.7, 1)
local kPrevBackgroundColor = Color(0.0, 0.0, 0.0, 1)
local kPrevBackgroundSelectedColor = Color(0.2, 0.2, 0.2, 1)
local kStartVoteColor = Color(0.28, 0.36, 0.46, 1)
local kStartVoteOffset = Vector(10, 0, 0)
local kOptionColor = Color(0.7, 0.7, 0.7, 1)
local kOptionSelectedColor = Color(1, 1, 1, 1)
local kOptionOffset = Vector(10, 4, 0)
local kFonts = { tiny = Fonts.kAgencyFB_Tiny, small = Fonts.kAgencyFB_Small, large = Fonts.kAgencyFB_Large }

local function GetMenuItemFontHeight(screenHeight)
    return GUIScale(30)
end

local function GetNumItemsOnPage(self, screenHeight)
    return math.floor((self.background:GetSize().y - self.titleBackground:GetSize().y - self.escapeBackground:GetSize().y - self.nextBackground:GetSize().y - 4) / GetMenuItemFontHeight(screenHeight))
end

local function UpdateSizeOfUI(self, screenWidth, screenHeight)

    local size = Vector(screenWidth * 0.25, screenHeight * 0.5, 0)
    self.background:SetSize(size)
    self.background:SetPosition(-size / 2)
    
    local titleSize = Vector(size.x - 4, size.y * 0.1, 0)
    self.titleBackground:SetSize(titleSize)
    self.titleBackground:SetPosition(Vector(2, 2, 0))
    
    local escapeSize = Vector(size.x - 4, size.y * 0.08, 0)
    self.escapeBackground:SetSize(escapeSize)
    local escapePos = Vector(2, -escapeSize.y - 2, 0)
    self.escapeBackground:SetPosition(escapePos)
    
    local nextPrevSize = Vector(escapeSize.x / 2 - 1, escapeSize.y, 0)
    self.nextBackground:SetSize(nextPrevSize)
    self.nextBackground:SetPosition(escapePos + Vector(nextPrevSize.x + 2, -escapeSize.y - 2, 0))
    
    self.prevBackground:SetSize(nextPrevSize)
    self.prevBackground:SetPosition(escapePos + Vector(0, -escapeSize.y - 2, 0))
    
    local fontName = kFonts.small
    local titleFontName = kFonts.large
    local optionFontHeight = GetMenuItemFontHeight(screenHeight)
    local optionFontName = kFonts.small
    
    self.escapeText:SetFontName(fontName)
    self.titleText:SetFontName(titleFontName)
    self.nextText:SetFontName(fontName)
    self.prevText:SetFontName(fontName)
    
    self.escapeText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.escapeText)
    self.titleText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.titleText)
    self.nextText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.nextText)
    self.prevText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.prevText)
    
    local menu = self.menus[#self.menus]
    
    -- Start by hiding all items. We will display certain ones based on the current page.
    for i = 1, #menu do
        menu[i].item:SetIsVisible(false)
    end
    
    local numMenuItems = #menu
    if numMenuItems > 0 then
    
        local numToDisplay = GetNumItemsOnPage(self, screenHeight)
        local startingIndex = ((self.currentPage - 1) * numToDisplay) + 1
        local untilIndex = math.min(startingIndex + numToDisplay - 1, #menu)
        
        for i = startingIndex, untilIndex do
        
            local menuItem = menu[i]
            menuItem.item:SetFontName(optionFontName)
            menuItem.item:SetScale(GetScaledVector())
            GUIMakeFontScale(menuItem.item)
            local yOffset = i - startingIndex + 1
            menuItem.item:SetPosition(kOptionOffset + Vector(0, yOffset * optionFontHeight, 0))
            menuItem.item:SetIsVisible(true)
            
        end
        
    end
    
end

function GUIStartVoteMenu:Initialize()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetIsVisible(false)
    self.background:SetColor(kBackgroundColor)
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetLayer(kGUILayerMainMenu)
    
    self.titleBackground = GUIManager:CreateGraphicItem()
    self.titleBackground:SetColor(kTitleColor)
    self.background:AddChild(self.titleBackground)
    
    self.titleText = GUIManager:CreateTextItem()
    self.titleText:SetColor(kStartVoteColor)
    self.titleText:SetText(Locale.ResolveString("START_VOTE"))
    self.titleText:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.titleText:SetTextAlignmentX(GUIItem.Align_Min)
    self.titleText:SetTextAlignmentY(GUIItem.Align_Center)
    self.titleText:SetPosition(kStartVoteOffset)
    self.titleBackground:AddChild(self.titleText)
    
    self.escapeBackground = GUIManager:CreateGraphicItem()
    self.escapeBackground:SetColor(kEscapeBackgroundColor)
    self.escapeBackground:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.background:AddChild(self.escapeBackground)
    
    self.escapeText = GUIManager:CreateTextItem()
    self.escapeText:SetColor(kEscapeColor)
    self.escapeText:SetText(Locale.ResolveString("ESCAPE"))
    self.escapeText:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.escapeText:SetTextAlignmentX(GUIItem.Align_Min)
    self.escapeText:SetTextAlignmentY(GUIItem.Align_Center)
    self.escapeText:SetPosition(kEscapeOffset)
    self.escapeBackground:AddChild(self.escapeText)
    
    self.nextBackground = GUIManager:CreateGraphicItem()
    self.nextBackground:SetColor(kNextBackgroundColor)
    self.nextBackground:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.background:AddChild(self.nextBackground)
    
    self.nextText = GUIManager:CreateTextItem()
    self.nextText:SetColor(kNextColor)
    self.nextText:SetText(Locale.ResolveString("NEXT"))
    self.nextText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.nextText:SetTextAlignmentX(GUIItem.Align_Center)
    self.nextText:SetTextAlignmentY(GUIItem.Align_Center)
    self.nextBackground:AddChild(self.nextText)
    
    self.prevBackground = GUIManager:CreateGraphicItem()
    self.prevBackground:SetColor(kPrevBackgroundColor)
    self.prevBackground:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.background:AddChild(self.prevBackground)
    
    self.prevText = GUIManager:CreateTextItem()
    self.prevText:SetColor(kPrevColor)
    self.prevText:SetText(Locale.ResolveString("PREV"))
    self.prevText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.prevText:SetTextAlignmentX(GUIItem.Align_Center)
    self.prevText:SetTextAlignmentY(GUIItem.Align_Center)
    self.prevBackground:AddChild(self.prevText)
    
    self.menus = { }
    
    local mainMenu = { }
    table.insert(self.menus, mainMenu)
    
    self.currentPage = 1
    
    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
end

local function DestroyMenu(self, menuIndex)

    local menuItems = self.menus[menuIndex]
    if menuItems then
    
        for m = #menuItems, 1, -1 do
            GUI.DestroyItem(menuItems[m].item)
        end
        
        table.remove(self.menus, menuIndex)
        
    end
    
end

function GUIStartVoteMenu:Uninitialize()

    for m = #self.menus, 1, -1 do
        DestroyMenu(self, m)
    end
    self.menus = nil
    
    GUI.DestroyItem(self.escapeText)
    self.escapeText = nil
    
    GUI.DestroyItem(self.nextText)
    self.nextText = nil
    
    GUI.DestroyItem(self.nextBackground)
    self.nextBackground = nil
    
    GUI.DestroyItem(self.prevText)
    self.prevText = nil
    
    GUI.DestroyItem(self.prevBackground)
    self.prevBackground = nil
    
    GUI.DestroyItem(self.escapeBackground)
    self.escapeBackground = nil
    
    GUI.DestroyItem(self.titleText)
    self.titleText = nil
    
    GUI.DestroyItem(self.titleBackground)
    self.titleBackground = nil
    
    GUI.DestroyItem(self.background)
    self.background = nil
    
end

local function AddMenuOption(menuItems, background, option, generateMenuFunc, startVoteFunc)

    local newOption = GUIManager:CreateTextItem()
    newOption:SetColor(kOptionColor)
    newOption:SetText(option.text)
    newOption:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    newOption:SetTextAlignmentX(GUIItem.Align_Min)
    newOption:SetTextAlignmentY(GUIItem.Align_Max)
    background:AddChild(newOption)
    
    table.insert(menuItems, { item = newOption, text = option.text, generator = generateMenuFunc, start = startVoteFunc, extraData = option.extraData })
    
end

function GUIStartVoteMenu:AddMainMenuOption(option, generateMenuFunc, startVoteFunc)

    AddMenuOption(self.menus[1], self.titleBackground, { text = option }, generateMenuFunc, startVoteFunc)
    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
end

local function SetMenuVisible(menuItems, visible)

    for m = 1, #menuItems do
        menuItems[m].item:SetIsVisible(visible)
    end
    
end

function GUIStartVoteMenu:SetIsVisible(visible)

    self.background:SetIsVisible(visible)
    MouseTracker_SetIsVisible(visible, "ui/Cursor_MenuDefault.dds", true)
    
    if visible then
    
        -- Destroy all but the root menu when visible again.
        for m = #self.menus, 2, -1 do
            DestroyMenu(self, m)
        end
        SetMenuVisible(self.menus[1], true)
        
        self.currentPage = 1
        
    end
    
end

function GUIStartVoteMenu:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
end

local function CheckButtonHighlight(background, color, selectedColor)

    if GUIItemContainsPoint(background, Client.GetCursorPosScreen()) then
        background:SetColor(selectedColor)
    else
        background:SetColor(color)
    end
    
end

function GUIStartVoteMenu:Update(deltaTime)

    PROFILE("GUIStartVoteMenu:Update")
    if self.background:GetIsVisible() then
    
        local activeMenu = self.menus[#self.menus]
        
        -- Check if the next/prev buttons should be displayed.
        local numPages = math.ceil(#activeMenu / GetNumItemsOnPage(self, Client.GetScreenHeight()))
        self.nextBackground:SetIsVisible(numPages > 1 and self.currentPage < numPages)
        self.prevBackground:SetIsVisible(self.currentPage > 1)
        
        CheckButtonHighlight(self.escapeBackground, kEscapeBackgroundColor, kEscapeBackgroundSelectedColor)
        CheckButtonHighlight(self.nextBackground, kNextBackgroundColor, kNextBackgroundSelectedColor)
        CheckButtonHighlight(self.prevBackground, kPrevBackgroundColor, kPrevBackgroundSelectedColor)
        
        for i = 1, #activeMenu do
        
            local menuItem = activeMenu[i].item
            if GUIItemContainsPoint(menuItem, Client.GetCursorPosScreen()) then
                menuItem:SetColor(kOptionSelectedColor)
            else
                menuItem:SetColor(kOptionColor)
            end
            
        end
        
    end
    
end

local function MenuItemPressed(self, menuIndex, menuItemIndex)

    local activeMenu = self.menus[menuIndex]
    local pressedItem = activeMenu[menuItemIndex]
    if pressedItem.generator then
    
        local newMenu = { }
        local list = pressedItem.generator()
        for l = 1, #list do
            AddMenuOption(newMenu, self.titleBackground, list[l], nil, pressedItem.start)
        end
        
        SetMenuVisible(activeMenu, false)
        table.insert(self.menus, newMenu)
        
    else
    
        -- Initiate the vote.
        pressedItem.start(pressedItem.extraData)
        
        if #self.menus > 1 then
            DestroyMenu(self, #self.menus)
        end
        self:SetIsVisible(false)
        
    end
    
    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
end

function GUIStartVoteMenu:SendKeyEvent(key, down)

    if self.background:GetIsVisible() then
    
        if down then
        
            if key == InputKey.Escape then
            
                self:SetIsVisible(false)
                return true
                
            end
            
        else
        
            if key == InputKey.MouseButton0 then
            
                if GUIItemContainsPoint(self.escapeBackground, Client.GetCursorPosScreen()) then
                
                    self:SetIsVisible(false)
                    return false
                    
                elseif GUIItemContainsPoint(self.nextBackground, Client.GetCursorPosScreen()) then
                
                    local maxPage = math.ceil(#self.menus[#self.menus] / GetNumItemsOnPage(self, Client.GetScreenHeight()))
                    self.currentPage = math.min(maxPage, self.currentPage + 1)
                    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
                    return false
                    
                elseif GUIItemContainsPoint(self.prevBackground, Client.GetCursorPosScreen()) then
                
                    self.currentPage = math.max(1, self.currentPage - 1)
                    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
                    return false
                    
                else
                
                    local activeMenu = self.menus[#self.menus]
                    for i = 1, #activeMenu do
                    
                        local menuItem = activeMenu[i].item
                        if menuItem:GetIsVisible() and GUIItemContainsPoint(menuItem, Client.GetCursorPosScreen()) then
                        
                            MenuItemPressed(self, #self.menus, i)
                            break
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
        -- Eat all mouse input while this menu is visible.
        if down and key == InputKey.MouseButton0 or key == InputKey.MouseButton1 then
            return true
        end
        
    end
    
    return false
    
end

function OpenVoteMenu()
    ClientUI.GetScript("GUIStartVoteMenu"):SetIsVisible(true)
end
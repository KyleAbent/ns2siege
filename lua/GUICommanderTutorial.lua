// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUICommanderTutorial.lua
//
// Created by: Andreas Urwalek (and@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommanderTutorialUtility.lua")
Script.Load("lua/AlienCommanderTutorial.lua")
Script.Load("lua/MarineCommanderTutorial.lua")

class 'GUICommanderTutorial' (GUIScript)

local kBackgroundPos
local kBackgroundWidth
local kTextPadding
local kFontName = Fonts.kAgencyFB_Small

local kItemSpacing
local kLineHeight

local kSlideInSecs = 0.5

local kIconSize

local kTokenType = enum({'Text', 'Icon'})

local kNeutralColor = Color(1,1,1,1)
local kHighlightColor = Color(0.4, 1, 0.4, 1)

local kBackgroundColor = Color(0, 0, 0, 0.5)

function GUICommanderTutorial:Initialize()

    kBackgroundPos = GUIScale(Vector(32, 200, 0))
    kBackgroundWidth = GUIScale(600)
    kTextPadding = GUIScale(20)
    kIconSize = GUIScale(Vector(32, 32, 0))
    kItemSpacing = GUIScale(4)
    kLineHeight = GUIScale(24)

    self.background = GetGUIManager():CreateGraphicItem()
    self.background:SetPosition(kBackgroundPos)
    
    self.currentIndex = 0
    self.teamType = PlayerUI_GetTeamType()
    
    self.items = {}
    self.tokens = {}
    
    self.alpha = 0

end

function GUICommanderTutorial:Uninitialize()

    if self.background then
    
        GUI.DestroyItem(self.background)
        self.background = nil
    
    end
    
    HighlightPosition(nil)
    HighlightButton(nil)

end

function GUICommanderTutorial:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUICommanderTutorial:ClearCurrentDisplay()

    self.currentIndex = 0
    
    for i = 1, #self.items do
        local item = self.items[i]
        GUI.DestroyItem(item)
    end
    
    self.items = {}
    self.tokens = {}
    
end

local function RenderTokens(self)

    local xPos = kTextPadding
    local line = 0    
    local lineWidth = kBackgroundWidth - 2 * kTextPadding

    for tokenIndex, token in ipairs(self.tokens) do
    
        local itemWidth = 0
        local yOffset = 0
        local item = nil
    
        if token.Type == kTokenType.Text then
        
           item = GetGUIManager():CreateTextItem()
           item:SetFontName(kFontName)
           item:SetScale(GetScaledVector())
           item:SetText(token.String)
           GUIMakeFontScale(item)
           
           itemWidth = item:GetTextWidth(token.String) * item:GetScale().x

        elseif token.Type == kTokenType.Icon then
        
            item = GetGUIManager():CreateGraphicItem()
            item:SetSize(kIconSize)
            item:SetTexture("ui/buildmenu.dds")
            
            local texCoords = GetTextureCoordinatesForIcon(token.TechId)
            item:SetTexturePixelCoordinates(unpack(texCoords))
            
            yOffset = 0
            itemWidth = kIconSize.x
        
        end
        
        self.background:AddChild(item)
        local endXPos = xPos + itemWidth
        if endXPos > lineWidth then
        
            line = line + 1
            xPos = kTextPadding
        
        end
        
        item:SetPosition(Vector(xPos, kTextPadding + line * kLineHeight + yOffset, 0))
        
        xPos = xPos + itemWidth + kItemSpacing
        self.items[tokenIndex] = item
    
    end
    
    self.background:SetSize(Vector(kBackgroundWidth, (line+1) * kLineHeight + 2 * kTextPadding, 0))

end

function GUICommanderTutorial:Setup(entry)
    
    local words = StringSplit(StringTrim(entry.Text), " ")
    
    self.tokens = {}
    
    for i = 1, #words do
        
        local trimmedWord = StringTrim(words[i])
        if string.find(trimmedWord, "%[") and string.find(trimmedWord, "%]") then
            
            local startPos = string.find(trimmedWord, "%[") + 1
            local endPos = string.find(trimmedWord, "%]") - 1
            
            local noBrackets = string.sub(trimmedWord, startPos, endPos)
            
            local techIdString = "None"
            local stepNum = -1
            
            if string.find(noBrackets, ":") then
            
                local splitted = StringSplit(noBrackets, ":")
                stepNum = tonumber(splitted[1])
                techIdString = splitted[2]
            
            else
                techIdString = noBrackets
            end

            local techId = StringToTechId(techIdString)
            
            table.insert(self.tokens, { Type = kTokenType.Icon, TechId = techId, Step = stepNum })
            
        else
            table.insert(self.tokens, { Type = kTokenType.Text, String = trimmedWord })
        end
        
    end

    RenderTokens(self)
    
end

function GUICommanderTutorial:Update(deltaTime)
        
    PROFILE("GUICommanderTutorial:Update")
    
    local showTutorial = CommanderHelp_GetShowTutorial()
    self.background:SetIsVisible(showTutorial)

    if showTutorial then

        local entry = CommanderTutorial_GetEntry(self.teamType)
        local activeStep = -1
        
        if entry then
        
            self.alpha = 1
        
            if entry.Index ~= self.currentIndex then
        
                self:ClearCurrentDisplay()
                self:Setup(entry)
                self.currentIndex = entry.Index
                
                self.timeEntryLoaded = Shared.GetTime()
                
            end

            CommanderTutorial_UpdateCurrent(self.teamType)
            activeStep = entry.ActiveStep

        else
            self.alpha = math.max(0, self.alpha - deltaTime * 2)
        end
        
        for i = 1, #self.tokens do
        
            local token = self.tokens[i]
            local useColor = Color(kNeutralColor)
            if token.Type == kTokenType.Icon then

                if token.Step == activeStep then
                    useColor = Color(kHighlightColor)
                end

            end
            
            useColor.a = useColor.a * self.alpha
            self.items[i]:SetColor(useColor)
        
        end
        
        self.background:SetColor(Color(kBackgroundColor.r, kBackgroundColor.g, kBackgroundColor.b, kBackgroundColor.a * self.alpha))
        
        local animTime = self.timeEntryLoaded == nil and 0 or (Shared.GetTime() - self.timeEntryLoaded)
        animTime = math.min(kSlideInSecs, animTime)
        
        local animation = Easing.outBounce(animTime, 0.0, 1.0, kSlideInSecs)
        
        local startX = GUIScale(-20)
        local endX = kBackgroundPos.x
        
        local posX = startX + (endX - startX) * animation        
        self.background:SetPosition(Vector(posX, kBackgroundPos.y, 0))
    
    else
        HighlightPosition(nil)
        HighlightButton(nil)
    end

end
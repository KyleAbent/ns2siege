// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIChat.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages chat messages that players send to each other.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIChat' (GUIScript)

local kOffset = Vector(100, -430, 0)
local kInputModeOffset = Vector(-5, 0, 0)
local kInputOffset = Vector(0, -10, 0)
local kBackgroundColor = Color(0.4, 0.4, 0.4, 0.0)
// This is the buffer x space between a player name and their chat message.
local kChatTextBuffer = 5
local kTimeStartFade = Client.GetOptionInteger("chat-time", 6)
local kTimeEndFade = Client.GetOptionInteger("chat-time", 6) + 1
local cutoffAmount = Client.GetOptionInteger("chat-wrap", 25)

local kFontName = Fonts.kAgencyFB_Small

local function UpdateSizeOfUI(self, screenWidth, screenHeight)

    self.inputItem:SetPosition((kOffset * GUIScale(1)) + (kInputOffset * GUIScale(1)))

end

function GUIChat:Initialize()

    self.messages = { }
    self.reuseMessages = { }
    
    // Input mode (Team/All) indicator text.
    self.inputModeItem = GUIManager:CreateTextItem()
    self.inputModeItem:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.inputModeItem:SetTextAlignmentX(GUIItem.Align_Max)
    self.inputModeItem:SetTextAlignmentY(GUIItem.Align_Center)
    self.inputModeItem:SetIsVisible(false)
    self.inputModeItem:SetLayer(kGUILayerChat)
    
    // Input text item.
    self.inputItem = GUIManager:CreateTextItem()
    self.inputItem:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.inputItem:SetTextAlignmentX(GUIItem.Align_Min)
    self.inputItem:SetTextAlignmentY(GUIItem.Align_Center)
    self.inputItem:SetIsVisible(false)
    self.inputItem:SetLayer(kGUILayerChat)
    
    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
end

function GUIChat:Uninitialize()

    GUI.DestroyItem(self.inputModeItem)
    self.inputModeItem = nil
    
    GUI.DestroyItem(self.inputItem)
    self.inputItem = nil
    
    for index, message in ipairs(self.messages) do
        GUI.DestroyItem(message["Background"])
    end
    self.messages = nil
    
    for index, message in ipairs(self.reuseMessages) do
        GUI.DestroyItem(message["Background"])
    end
    self.reuseMessages = nil
    
end

function GUIChat:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

local function GetStyle()
    return PlayerUI_IsOnMarineTeam() and "marine" or "alien"
end

function GUIChat:Update(deltaTime)
        
    PROFILE("GUIChat:Update")
    
    local style = GetStyle()
    
    local addChatMessages = ChatUI_GetMessages()
    local numberElementsPerMessage = 8
    local numberMessages = table.count(addChatMessages) / numberElementsPerMessage
    local currentIndex = 1
    
    while numberMessages > 0 do
    
        local playerColor = addChatMessages[currentIndex]
        local playerName = addChatMessages[currentIndex + 1]
        local messageColor = addChatMessages[currentIndex + 2]
        local messageText = addChatMessages[currentIndex + 3]
        local isCommander = addChatMessages[currentIndex + 4]
        local isRookie = addChatMessages[currentIndex + 5]
        
        self:AddMessage(playerColor, playerName, messageColor, messageText, isCommander, isRookie)
        currentIndex = currentIndex + numberElementsPerMessage
        numberMessages = numberMessages - 1
        
    end
    
    self.updateInterval = #self.messages > 0 and 0 or 0.2
    
    local removeMessages = { }
    local totalMessageHeight = 0
    // Update existing messages.
    for i, message in ipairs(self.messages) do
    
        local messageHeight = message["Background"]:GetSize().y
        local currentPosition = Vector(message["Background"]:GetPosition())
        currentPosition.y = GUIScale(kOffset.y) + totalMessageHeight
        totalMessageHeight = totalMessageHeight + messageHeight
        
        message["Background"]:SetPosition(currentPosition)
        message["Time"] = message["Time"] + deltaTime
        
        if message["Time"] >= kTimeStartFade then
        
            local timePassed = kTimeEndFade - message["Time"]
            local timeToFade = kTimeEndFade - kTimeStartFade
            local fadeAmount = timePassed / timeToFade
            local currentColor = message["Player"]:GetColor()
            currentColor.a = fadeAmount
            message["Player"]:SetColor(currentColor)
            currentColor = message["Rookie"]:GetColor()
            currentColor.a = fadeAmount
            message["Rookie"]:SetColor(currentColor)
            currentColor = message["Commander"]:GetColor()
            currentColor.a = fadeAmount
            message["Commander"]:SetColor(currentColor)
            currentColor = message["Message"]:GetColor()
            currentColor.a = fadeAmount
            message["Message"]:SetColor(currentColor)
            message["Message2"]:SetColor(currentColor)
            
            if message["Time"] >= kTimeEndFade then
                table.insert(removeMessages, message)
            end
            
        end
        
    end
    
    // Remove faded out messages.
    for i, removeMessage in ipairs(removeMessages) do
    
        removeMessage["Background"]:SetIsVisible(false)
        table.insert(self.reuseMessages, removeMessage)
        table.removevalue(self.messages, removeMessage)
        
    end
    
    // Handle showing/hiding the input item.
    if ChatUI_EnteringChatMessage() then
    
        if not self.inputItem:GetIsVisible() then
        
            self.inputModeItem:SetFontName(kFontName)
            self.inputModeItem:SetScale(GetScaledVector())
            GUIMakeFontScale(self.inputModeItem)
            self.inputItem:SetFontName(kFontName)
            self.inputItem:SetScale(GetScaledVector())
            GUIMakeFontScale(self.inputItem)
            
            self.inputModeItem:SetText(ChatUI_GetChatMessageType())
            self.inputModeItem:SetPosition((kOffset * GUIScale(1)) + (kInputOffset * GUIScale(1)) + (kInputModeOffset * GUIScale(1)))
            self.inputModeItem:SetIsVisible(true)
            self.inputItem:SetIsVisible(true)
            
        end
        
    else
    
        if self.inputItem:GetIsVisible() then
        
            self.inputModeItem:SetIsVisible(false)
            self.inputItem:SetIsVisible(false)
            
        end
        
    end
    
end

function GUIChat:SendKeyEvent(key, down)

    if ChatUI_EnteringChatMessage() and down then
    
        if key == InputKey.Return then
        
            ChatUI_SubmitChatMessageBody(self.inputItem:GetText())
            self.inputItem:SetText("")
            
        elseif key == InputKey.Back then
        
            // Only remove text if there is more to remove.
            local currentText = self.inputItem:GetWideText()
            local currentTextLength = currentText:length()
            
            if currentTextLength > 0 then
            
                currentText = currentText:sub(1, currentTextLength - 1)
                self.inputItem:SetWideText(currentText)
                
            end
            
        elseif key == InputKey.Escape then
        
            ChatUI_SubmitChatMessageBody("")
            self.inputItem:SetText("")
            
        end
        
        return true
        
    end
    
    return false
    
end

function GUIChat:SendCharacterEvent(character)
    
    character = ConvertWideStringToString(character)
    local enteringChatMessage = ChatUI_EnteringChatMessage()
    
    if Shared.GetTime() ~= ChatUI_GetStartedChatTime() and enteringChatMessage then
    
        local currentText = self.inputItem:GetText()
        if string.UTF8Length(currentText) < kMaxChatLength then
        
            self.inputItem:SetText( string.format("%s%s", currentText, character))
            return true
            
        end
        
    end
    
    return false
    
end

function GUIChat:AddMessage(playerColor, playerName, messageColor, messageText, isCommander, isRookie)

    local style = GetStyle()
    local commanderText = "[C] "
    local rookieText = Locale.ResolveString("ROOKIE_CHAT") .. " "
    
    local insertMessage = { Background = nil, Player = nil, Message = nil, Message2 = nil, Commander = nil, Rookie = nil, Time = 0 }
    
    // Check if we can reuse an existing message.
    if table.count(self.reuseMessages) > 0 then
    
        insertMessage = self.reuseMessages[1]
        insertMessage["Time"] = 0
        insertMessage["Background"]:SetIsVisible(true)
        table.remove(self.reuseMessages, 1)
        
    end
    
    if insertMessage["Commander"] == nil then
        insertMessage["Commander"] = GUIManager:CreateTextItem()
    end
    
    insertMessage["Commander"]:SetFontName(kFontName)
    insertMessage["Commander"]:SetScale(GetScaledVector())
    GUIMakeFontScale(insertMessage["Commander"])
    insertMessage["Commander"]:SetAnchor(GUIItem.Left, GUIItem.Center)
    insertMessage["Commander"]:SetTextAlignmentX(GUIItem.Align_Min)
    insertMessage["Commander"]:SetTextAlignmentY(GUIItem.Align_Center)
    insertMessage["Commander"]:SetColor(ColorIntToColor(kCommanderColor))
    insertMessage["Commander"]:SetPosition(Vector(0, 0, 0))
    insertMessage["Commander"]:SetIsVisible(isCommander)
    insertMessage["Commander"]:SetText(commanderText)
    
    if insertMessage["Rookie"] == nil then
        insertMessage["Rookie"] = GUIManager:CreateTextItem()
    end
    
    local commTextWidth = ConditionalValue(isCommander, insertMessage["Commander"]:GetTextWidth(commanderText) * insertMessage["Commander"]:GetScale().x, 0)
    
    insertMessage["Rookie"]:SetFontName(kFontName)
    insertMessage["Rookie"]:SetScale(GetScaledVector())
    GUIMakeFontScale(insertMessage["Rookie"])
    insertMessage["Rookie"]:SetAnchor(GUIItem.Left, GUIItem.Center)
    insertMessage["Rookie"]:SetTextAlignmentX(GUIItem.Align_Min)
    insertMessage["Rookie"]:SetTextAlignmentY(GUIItem.Align_Center)
    insertMessage["Rookie"]:SetColor(ColorIntToColor(kNewPlayerColor))
    insertMessage["Rookie"]:SetPosition(Vector(commTextWidth, 0, 0))
    insertMessage["Rookie"]:SetIsVisible(isRookie)
    insertMessage["Rookie"]:SetText(rookieText)
    
    if insertMessage["Player"] == nil then
        insertMessage["Player"] = GUIManager:CreateTextItem()
    end
    
    local rookieTextWidth = ConditionalValue(isRookie, insertMessage["Rookie"]:GetTextWidth(rookieText) * insertMessage["Rookie"]:GetScale().x, 0)
    
    insertMessage["Player"]:SetFontName(kFontName)
    insertMessage["Player"]:SetScale(GetScaledVector())
    GUIMakeFontScale(insertMessage["Player"])
    insertMessage["Player"]:SetAnchor(GUIItem.Left, GUIItem.Center)
    insertMessage["Player"]:SetTextAlignmentX(GUIItem.Align_Min)
    insertMessage["Player"]:SetTextAlignmentY(GUIItem.Align_Center)
    insertMessage["Player"]:SetColor(ColorIntToColor(playerColor))
    insertMessage["Player"]:SetPosition(Vector(commTextWidth + rookieTextWidth, 0, 0))
    insertMessage["Player"]:SetText(playerName)
    
    if insertMessage["Message"] == nil then
        insertMessage["Message"] = GUIManager:CreateTextItem()
    end
    
    local playerTextWidth = insertMessage["Player"]:GetTextWidth(playerName) * insertMessage["Player"]:GetScale().x
    local messagePrefix = playerTextWidth + commTextWidth + rookieTextWidth
    local defaultHeight = insertMessage["Message"]:GetTextHeight("!") * insertMessage["Message"]:GetScale().x
    
    insertMessage["Message"]:SetFontName(kFontName)
    insertMessage["Message"]:SetScale(GetScaledVector())
    GUIMakeFontScale(insertMessage["Message"])
    insertMessage["Message"]:SetAnchor(GUIItem.Left, GUIItem.Center)
    insertMessage["Message"]:SetTextAlignmentX(GUIItem.Align_Min)
    insertMessage["Message"]:SetTextAlignmentY(GUIItem.Align_Center)
    insertMessage["Message"]:SetPosition(Vector(messagePrefix + GUIScale(kChatTextBuffer), 0, 0))
    insertMessage["Message"]:SetColor(messageColor)

    local cutoff = Client.GetScreenWidth() * (cutoffAmount/100)
    -- Account for the width of the player's name and other stuff in the first line for the line break
    local textWrap1, textWrap2 = WordWrap(insertMessage["Message"], messageText, messagePrefix, cutoff, 1)

    if textWrap2 then
        -- Get the substring for the text after the first one and redo the word wrap without the offset
        textWrap2 = WordWrap(insertMessage["Message"], textWrap2, 0, cutoff)
    end
    
    insertMessage["Message"]:SetText(textWrap1)
    
    if insertMessage["Message2"] == nil then
        insertMessage["Message2"] = GUIManager:CreateTextItem()
    end
    
    insertMessage["Message2"]:SetFontName(kFontName)
    insertMessage["Message2"]:SetScale(GetScaledVector())
    GUIMakeFontScale(insertMessage["Message2"])
    insertMessage["Message2"]:SetAnchor(GUIItem.Left, GUIItem.Center)
    insertMessage["Message2"]:SetPosition(Vector(0, math.max(defaultHeight, insertMessage["Message"]:GetTextHeight(textWrap1) * insertMessage["Message"]:GetScale().x), 0))
    insertMessage["Message2"]:SetTextAlignmentX(GUIItem.Align_Min)
    insertMessage["Message2"]:SetTextAlignmentY(GUIItem.Align_Center)
    insertMessage["Message2"]:SetColor(messageColor)
    
    insertMessage["Message2"]:SetText(textWrap2)
    
    local textWrap1Height = math.max(insertMessage["Message"]:GetTextHeight(textWrap1) * insertMessage["Message"]:GetScale().x, defaultHeight)
    local textWrap2Height = insertMessage["Message2"]:GetTextHeight(textWrap2) * insertMessage["Message2"]:GetScale().x
    
    local textHeight = textWrap1Height + textWrap2Height
    local textWidth = math.max(insertMessage["Message"]:GetTextWidth(textWrap1) * insertMessage["Message"]:GetScale().x + messagePrefix, insertMessage["Message2"]:GetTextWidth(textWrap2) * insertMessage["Message2"]:GetScale().x)
    
    -- If we had to wrap the text, we have to reposition as anchors are set up for one line only
    if textWrap2 ~= "" then
        insertMessage["Commander"]:SetPosition(Vector(0, textWrap1Height/2-textHeight/2, 0))
        insertMessage["Rookie"]:SetPosition(Vector(commTextWidth, textWrap1Height/2-textHeight/2, 0))
        insertMessage["Player"]:SetPosition(Vector(commTextWidth + rookieTextWidth, textWrap1Height/2-textHeight/2, 0))
        insertMessage["Message"]:SetPosition(Vector(messagePrefix + GUIScale(kChatTextBuffer), textWrap1Height/2-textHeight/2, 0))
        
        insertMessage["Message2"]:SetPosition(Vector(0, textWrap1Height*1.5-textHeight/2, 0))
    end
    
    if insertMessage["Background"] == nil then
    
        insertMessage["Background"] = GUIManager:CreateGraphicItem()
        insertMessage["Background"]:SetLayer(kGUILayerChat)
        insertMessage["Background"]:AddChild(insertMessage["Player"])
        insertMessage["Background"]:AddChild(insertMessage["Message"])
        insertMessage["Background"]:AddChild(insertMessage["Message2"])
        insertMessage["Background"]:AddChild(insertMessage["Commander"])
        insertMessage["Background"]:AddChild(insertMessage["Rookie"])
        
    end
    
    insertMessage["Background"]:SetSize(Vector(textWidth + GUIScale(kChatTextBuffer), textHeight, 0))
    insertMessage["Background"]:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    insertMessage["Background"]:SetPosition(kOffset * GUIScale(1))
    insertMessage["Background"]:SetColor(kBackgroundColor)
    
    table.insert(self.messages, insertMessage)
    
end

local function OnCommandChatTime(time)

    if Client.GetOptionInteger("chat-time", -1) == -1 then
        Client.SetOptionInteger("chat-time", kTimeStartFade)
    elseif tonumber(time) >= 3 then
        Shared.Message("Chat messages will now show for " .. time .. " seconds. The default is 6 seconds.")
        Client.SetOptionInteger("chat-time", tonumber(time))
        kTimeStartFade = tonumber(time)
        kTimeEndFade = kTimeStartFade + 1
    elseif tonumber(time) < 3 then
        Shared.Message("Chat messages must show for at least 3 seconds. The default is 6 seconds.")
    end
    
end

Event.Hook("Console_chattime", OnCommandChatTime)

local function OnCommandChatWrap(amount)
    amount = amount and tonumber(amount)
    
    if amount then
        amount = Round(amount)
        local cutoff = Clamp( amount, 10, 40 )
        if cutoff == amount then
            Client.SetOptionInteger("chat-wrap", cutoff)
            Shared.Message(string.format("Chat messages will now wrap to %s %% of the screen. The default is 25%%", cutoff))
            cutoffAmount = cutoff
        else
            Shared.Message("Warning: Chat wrapping amount must be between 10 and 40")
        end
    else
        Shared.Message(string.format("Chat wrapping cutoff is %s %% of the screen.", cutoffAmount))
    end
end

Event.Hook("Console_chatwrapamount", OnCommandChatWrap)
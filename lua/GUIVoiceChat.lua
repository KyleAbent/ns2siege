// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIVoiceChat.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages displaying names of players using voice chat.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIVoiceChat' (GUIScript)

local kBackgroundSize
local kBackgroundOffset
local kBackgroundYSpace
local kBackgroundAlpha = 0.8

local kVoiceChatIconSize
local kVoiceChatIconOffset

local kNameOffsetFromChatIcon

-- And how well does this work with prechaching? Tsk, tsk...
local kBackgroundTexture = "ui/%s_HUD_presbg.dds"

local kGlobalSpeakerIcon = PrecacheAsset("ui/speaker.dds")
-- TODO: should use different icons here to represent local/global chat. 
-- But then we also need to update GUICommunicationStatusIcons (and GUIScoreboard?) and deal with art assets.
-- Too much work for something that we may not actually activate anyhow ... leave it until we decide to actually activate it
-- local kWorldSpeakerIcon = PrecacheAsset("ui/sb-voice-muted.dds") 
local kWorldSpeakerIcon = kGlobalSpeakerIcon

GUIVoiceChat.kCommanderFontColor = Color(1, 1, 0, 1)
GUIVoiceChat.kMarineFontColor = Color(147/255, 206/255, 1, 1)
GUIVoiceChat.kAlienFontColor = Color(207/255, 139/255, 41/255, 1)
GUIVoiceChat.kSpectatorFontColor = Color(1, 1, 1, 1)

local loggedIn = false

local function UpdateItemsGUIScale(self)
    kBackgroundSize = Vector(GUIScale(250), GUIScale(28), 0)
    kBackgroundOffset = Vector(-kBackgroundSize.x , 0, 0)
    kBackgroundYSpace = GUIScale(4)

    kVoiceChatIconSize = kBackgroundSize.y
    kVoiceChatIconOffset = Vector(-kBackgroundSize.y * 2, -kVoiceChatIconSize / 2, 0)

    kNameOffsetFromChatIcon = -kBackgroundSize.y - GUIScale(6)
end

function GUIVoiceChat:Initialize()
    UpdateItemsGUIScale(self)
    
    self.chatBars = { }
end

local function DestroyChatBar(destroyBar)

    GUI.DestroyItem(destroyBar.Name)
    destroyBar.Name = nil
    
    GUI.DestroyItem(destroyBar.Icon)
    destroyBar.Icon = nil
    
    GUI.DestroyItem(destroyBar.Background)
    destroyBar.Background = nil

end

function GUIVoiceChat:Uninitialize()

    for i, bar in ipairs(self.chatBars) do
        DestroyChatBar(bar)
    end
    self.chatBars = { }
    
end

local function ClearAllBars(self)

    for i, bar in ipairs(self.chatBars) do
        bar.Background:SetIsVisible(false)
    end

end

local function CreateChatBar()

    local background = GUIManager:CreateGraphicItem()
    background:SetSize(kBackgroundSize)
    background:SetAnchor(GUIItem.Right, GUIItem.Center)
    background:SetPosition(kBackgroundOffset)
    background:SetIsVisible(false)
    
    local chatIcon = GUIManager:CreateGraphicItem()
    chatIcon:SetSize(Vector(kVoiceChatIconSize, kVoiceChatIconSize, 0))
    chatIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
    chatIcon:SetPosition(kVoiceChatIconOffset)
    chatIcon:SetTexture(kGlobalSpeakerIcon)
    background:AddChild(chatIcon)
    
    local nameText = GUIManager:CreateTextItem()
    nameText:SetFontName(Fonts.kAgencyFB_Small)
    nameText:SetAnchor(GUIItem.Right, GUIItem.Center)
    nameText:SetScale(GetScaledVector())
    nameText:SetTextAlignmentX(GUIItem.Align_Max)
    nameText:SetTextAlignmentY(GUIItem.Align_Center)
    nameText:SetPosition(Vector(kNameOffsetFromChatIcon, 0, 0))
    GUIMakeFontScale(nameText)
    chatIcon:AddChild(nameText)
    
    return { Background = background, Icon = chatIcon, Name = nameText }
    
end

local function GetFreeBar(self)

    for i, bar in ipairs(self.chatBars) do
    
        if not bar.Background:GetIsVisible() then
            return bar
        end
        
    end
    
    local newBar = CreateChatBar()
    table.insert(self.chatBars, newBar)
    
    return newBar

end

function GUIVoiceChat:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateItemsGUIScale(self)
    
    self:Uninitialize()
    self:Initialize()
end

function GUIVoiceChat:Update(deltaTime)

    PROFILE("GUIVoiceChat:Update")

    local time = Shared.GetTime()
    
    -- Delayed Push-To-Talk Release
    if self.recordEndTime and self.recordEndTime < time then
        Client.VoiceRecordStop()
        self.recordEndTime = nil
    end
        
    ClearAllBars(self)
    
    local allPlayers = ScoreboardUI_GetAllScores()
    // How many items per player.
    local numPlayers = table.count(allPlayers)
    local currentBar = 0
    
    for i = 1, numPlayers do
    
        local playerName = allPlayers[i].Name
        local clientIndex = allPlayers[i].ClientIndex
        local clientTeam = allPlayers[i].EntityTeamNumber
        local voiceChannel = clientIndex and ChatUI_GetVoiceChannelForClient(clientIndex) or VoiceChannel.Invalid
        
        if voiceChannel ~= VoiceChannel.Invalid then
        
            local chatBar = GetFreeBar(self)
            local isSpectator = false

            local texture = voiceChannel == VoiceChannel.Global and kGlobalSpeakerIcon or kWorldSpeakerIcon
            chatBar.Icon:SetTexture(texture)            
            chatBar.Background:SetIsVisible(true)
            
            -- Show voice chat over death screen
            chatBar.Background:SetLayer(kGUILayerDeathScreen+1)
            
            local textureSet, fontColor
            if clientTeam == kTeam1Index then
                textureSet = "marine"
                fontColor = GUIVoiceChat.kMarineFontColor
            elseif clientTeam == kTeam2Index then
                textureSet = "alien"
                fontColor = GUIVoiceChat.kAlienFontColor
            else
                textureSet = "marine"
                fontColor = GUIVoiceChat.kSpectatorFontColor
                isSpectator = true
            end

            chatBar.Background:SetTexture(string.format(kBackgroundTexture, textureSet))
            // Apply a tint to the marine background for spectator so it looks a bit more different
            if isSpectator then
                chatBar.Background:SetColor(Color(1, 200/255, 150/255, 1))
            else
                chatBar.Background:SetColor(Color(1, 1, 1, 1))
            end
            
            chatBar.Name:SetText(playerName)
            chatBar.Name:SetColor( ConditionalValue(allPlayers[i].IsCommander, GUIVoiceChat.kCommanderFontColor, ConditionalValue(allPlayers[i].IsRookie, kNewPlayerColorFloat, fontColor) ) )
            chatBar.Icon:SetColor( ConditionalValue(allPlayers[i].IsCommander, GUIVoiceChat.kCommanderFontColor, fontColor ) )
            
            local currentBarPosition = Vector(0, (kBackgroundSize.y + kBackgroundYSpace) * currentBar, 0)
            chatBar.Background:SetPosition(kBackgroundOffset + currentBarPosition)
            
            currentBar = currentBar + 1
            
        end
    end
    
end

function GUIVoiceChat:SendKeyEvent(key, down, amount)

    local player = Client.GetLocalPlayer()
    
    if down then
        if not ChatUI_EnteringChatMessage() then
            if not player:isa("Commander") then
                if GetIsBinding(key, "VoiceChat") then
                    self.recordBind = "VoiceChat"
                    self.recordEndTime = nil
                    Client.VoiceRecordStartGlobal()
                end
            else
                if GetIsBinding(key, "VoiceChatCom") then
                    self.recordBind = "VoiceChatCom"
                    self.recordEndTime = nil
                    Client.VoiceRecordStartGlobal()
                end
            end
        end
    else
        if self.recordBind and GetIsBinding( key, self.recordBind ) then
            self.recordBind = nil
            self.recordEndTime = Shared.GetTime() + Client.GetOptionFloat("recordingReleaseDelay", 0.15)
        end
    end
    
end
// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\GUIVoteMenu.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIVoteMenu' (GUIScript)

local kBackgroundColor = Color(0.0, 0.0, 0.0, 0.6)
local kTitleBackgroundColor = Color(0.2, 0.2, 0.2, 0.2)
local kVotedBackgroundColor = Color(0.2, 0.2, 0.2, 0.5)
local kTitleTextColor = Color(1, 1, 1, 1)
local kYesTextColor = Color(0, 0.6, 0, 1)
local kNoTextColor = Color(0.6, 0, 0, 1)
local kChoiceTextColor = Color(1, 1, 1, 1)
local kFonts = { tiny = Fonts.kAgencyFB_Tiny, small = Fonts.kAgencyFB_Small, large = Fonts.kAgencyFB_Large }

local function GetFontHeight(screenHeight)
    return GUIScale(30)
end

local function UpdateSizeOfUI(self, screenWidth, screenHeight)

    local titleFontName = kFonts.small
    self.titleText:SetFontName(titleFontName)
    self.titleText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.titleText)
    self.timeText:SetFontName(titleFontName)
    self.timeText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.timeText)
    
    local minWidth = self.titleText:GetTextWidth(self.titleText:GetText()) * self.titleText:GetScale().x + self.timeText:GetTextWidth(" ##") * self.timeText:GetScale().x + GUIScale(20)
    local size = Vector(math.max(screenWidth * 0.15, minWidth), screenHeight * 0.1, 0)
    self.background:SetSize(size)
    self.background:SetPosition(Vector(GUIScale(2), -size.y, 0))
    
    local titleSize = Vector(size.x - GUIScale(4), size.y * 0.36 - GUIScale(4), 0)
    self.titleBackground:SetSize(titleSize)
    self.titleBackground:SetPosition(GUIScale(Vector(2, 2, 0)))
    
    local choiceSize = Vector(size.x - GUIScale(4), size.y * 0.32 - GUIScale(2), 0)
    self.yesBackground:SetSize(choiceSize)
    local yesPos = Vector(GUIScale(2), titleSize.y + GUIScale(4), 0)
    self.yesBackground:SetPosition(yesPos)
    self.yesText:SetFontName(titleFontName)
    self.yesText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.yesText)
    self.yesCount:SetFontName(titleFontName)
    self.yesCount:SetScale(GetScaledVector())
    GUIMakeFontScale(self.yesCount)
    
    self.noBackground:SetSize(choiceSize)
    self.noBackground:SetPosition(Vector(GUIScale(2), yesPos.y + choiceSize.y + GUIScale(2), 0))
    self.noText:SetFontName(titleFontName)
    self.noText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.noText)
    self.noCount:SetFontName(titleFontName)
    self.noCount:SetScale(GetScaledVector())
    GUIMakeFontScale(self.noCount)
    
    self.titleText:SetPosition(GUIScale(Vector(4, 0, 0)))
    self.timeText:SetPosition(GUIScale(Vector(-8, 0, 0)))
    self.yesText:SetPosition(GUIScale(Vector(4, 0, 0)))
    self.yesCount:SetPosition(GUIScale(Vector(-8, 0, 0)))
    self.noText:SetPosition(GUIScale(Vector(4, 0, 0)))
    self.noCount:SetPosition(GUIScale(Vector(-8, 0, 0)))
    
end

function GUIVoteMenu:Initialize()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetIsVisible(false)
    self.background:SetColor(kBackgroundColor)
    self.background:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.background:SetLayer(kGUILayerMainMenu)
    
    self.titleBackground = GUIManager:CreateGraphicItem()
    self.titleBackground:SetColor(kTitleBackgroundColor)
    self.background:AddChild(self.titleBackground)
    
    self.titleText = GUIManager:CreateTextItem()
    self.titleText:SetColor(kTitleTextColor)
    self.titleText:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.titleText:SetTextAlignmentX(GUIItem.Align_Min)
    self.titleText:SetTextAlignmentY(GUIItem.Align_Center)
    self.titleBackground:AddChild(self.titleText)

    self.timeText = GUIManager:CreateTextItem()
    self.timeText:SetColor(kTitleTextColor)
    self.timeText:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.timeText:SetTextAlignmentX(GUIItem.Align_Max)
    self.timeText:SetTextAlignmentY(GUIItem.Align_Center)
    self.titleBackground:AddChild(self.timeText)
        
    self.yesBackground = GUIManager:CreateGraphicItem()
    self.yesBackground:SetColor(kTitleBackgroundColor)
    self.background:AddChild(self.yesBackground)
    
    self.yesText = GUIManager:CreateTextItem()
    self.yesText:SetColor(kChoiceTextColor)
    self.yesText:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.yesText:SetTextAlignmentX(GUIItem.Align_Min)
    self.yesText:SetTextAlignmentY(GUIItem.Align_Center)
    self.yesText:SetText(StringReformat(Locale.ResolveString("VOTE_YES"), { key = GetPrettyInputName("VoteYes") }))
    self.yesBackground:AddChild(self.yesText)
    
    self.yesCount = GUIManager:CreateTextItem()
    self.yesCount:SetColor(kYesTextColor)
    self.yesCount:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.yesCount:SetTextAlignmentX(GUIItem.Align_Max)
    self.yesCount:SetTextAlignmentY(GUIItem.Align_Center)
    self.yesCount:SetText("0")
    self.yesBackground:AddChild(self.yesCount)
    
    self.noBackground = GUIManager:CreateGraphicItem()
    self.noBackground:SetColor(kTitleBackgroundColor)
    self.background:AddChild(self.noBackground)
    
    self.noText = GUIManager:CreateTextItem()
    self.noText:SetColor(kChoiceTextColor)
    self.noText:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.noText:SetTextAlignmentX(GUIItem.Align_Min)
    self.noText:SetTextAlignmentY(GUIItem.Align_Center)
    self.noText:SetText(StringReformat(Locale.ResolveString("VOTE_NO"), { key = GetPrettyInputName("VoteNo") }))
    self.noBackground:AddChild(self.noText)
    
    self.noCount = GUIManager:CreateTextItem()
    self.noCount:SetColor(kNoTextColor)
    self.noCount:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.noCount:SetTextAlignmentX(GUIItem.Align_Max)
    self.noCount:SetTextAlignmentY(GUIItem.Align_Center)
    self.noCount:SetText("0")
    self.noBackground:AddChild(self.noCount)
    
    self.votedYes = nil
    
    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
end

function GUIVoteMenu:Uninitialize()

    GUI.DestroyItem(self.noCount)
    self.noCount = nil
    
    GUI.DestroyItem(self.noText)
    self.noText = nil
    
    GUI.DestroyItem(self.noBackground)
    self.noBackground = nil
    
    GUI.DestroyItem(self.yesCount)
    self.yesCount = nil
    
    GUI.DestroyItem(self.yesText)
    self.yesText = nil
    
    GUI.DestroyItem(self.yesBackground)
    self.yesBackground = nil

    GUI.DestroyItem(self.timeText)
    self.timeText = nil
        
    GUI.DestroyItem(self.titleText)
    self.titleText = nil
    
    GUI.DestroyItem(self.titleBackground)
    self.titleBackground = nil
    
    GUI.DestroyItem(self.background)
    self.background = nil
    
end

function GUIVoteMenu:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
end

function GUIVoteMenu:Update(deltaTime)

    PROFILE("GUIVoteMenu:Update")
    
    local currentVoteQuery = GetCurrentVoteQuery()
    local visible = currentVoteQuery ~= nil
    self.background:SetIsVisible(visible)
    
    local changed = self.lastCurrentVoteQuery ~= currentVoteQuery
    
    if changed and visible then
    
        self.lastCurrentVoteQuery = currentVoteQuery
        self.votedYes = nil
        self.titleText:SetText(currentVoteQuery)
        self.titleText:SetColor(kTitleTextColor)

        UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
        
    end
    
    if visible then
    
        if self.yesText then
            self.yesText:SetText(StringReformat(Locale.ResolveString("VOTE_YES"), { key = GetPrettyInputName("VoteYes") }))
        end

        if self.noText then
            self.noText:SetText(StringReformat(Locale.ResolveString("VOTE_NO"), { key = GetPrettyInputName("VoteNo") }))
        end
    
        if self.votedYes ~= nil then
        
            if self.votedYes then
            
                self.yesBackground:SetColor(kVotedBackgroundColor)
                self.noBackground:SetColor(kTitleBackgroundColor)
                
            else
            
                self.noBackground:SetColor(kVotedBackgroundColor)
                self.yesBackground:SetColor(kTitleBackgroundColor)
                
            end
            
        else
        
            self.yesBackground:SetColor(kTitleBackgroundColor)
            self.noBackground:SetColor(kTitleBackgroundColor)
            
        end
        
        local yes, no, required = GetVoteResults()
        local yesString = ToString(yes)
        if required > 0 then
            yesString = yesString .. "/" .. required
        end
        
        self.yesCount:SetText(yesString)
        self.noCount:SetText(ToString(no))
        
        local lastVoteResults = GetLastVoteResults()
        if lastVoteResults ~= nil then
        
            self.titleText:SetText(((lastVoteResults and Locale.ResolveString("VOTE_PASSED")) or Locale.ResolveString("VOTE_FAILED")))
            self.titleText:SetColor(lastVoteResults and kYesTextColor or kNoTextColor)
            
            --UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
            
            self.timeText:SetText("")
            
        else
            local voteTimeLeft = GetCurrentVoteTimeLeft()
            self.timeText:SetText(ToString(math.ceil(voteTimeLeft)))
        end
        
    else
        self.lastCurrentVoteQuery = nil
    end

end

function GUIVoteMenu:SendKeyEvent(key, down)

    local voteId = GetCurrentVoteId()
    if down and self.votedYes == nil and voteId ~= self.lastVotedId and voteId > 0 then
    
        if GetIsBinding(key, "VoteYes") then
        
            self.votedYes = true
            self.timeLastVoted = Shared.GetTime()
            SendVoteChoice(true)
            self.lastVotedId = voteId
            
            return true
            
        elseif GetIsBinding(key, "VoteNo") then
        
            self.votedYes = false
            self.timeLastVoted = Shared.GetTime()
            SendVoteChoice(false)
            self.lastVotedId = voteId
            
            return true
            
        end
        
    end
    
    return false
    
end
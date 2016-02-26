// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUIReadyVideoList.lua
//
// Created by: Steven An (steve@unknownworlds.com)
//
// This interacts with GUITipVideo, making it play videos when the player requests them in the ready room
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUITipVideo.lua")

local kSlideInSecs = 0.5
local kFadeOutSecs = 0.5
local kWidgetRightMargin = 20
local kBackgroundAlpha = 0.75

local kPageSound = "sound/NS2.fev/common/hovar"
local kPlaySound = "sound/NS2.fev/common/open"
Client.PrecacheLocalSound(kPageSound)
Client.PrecacheLocalSound(kPlaySound)

gReadyVideoUrlPrefix = "file:///ns2/readyvideos/"
Script.Load("lua/GUITipVideo_ReadyVideos.lua")
local kVids = gReadyTipVideos

local kEntryKeyCodes = { InputKey.Num5, InputKey.Num6 , InputKey.Num7 , InputKey.Num8 , InputKey.Num9 }
local kEntryKeyLabels = { "5", "6", "7", "8", "9" }
local kNextPageKeyCode = InputKey.Num0
local kNextPageKeyLabel = "0"

//----------------------------------------
//  Pagination helpers
//----------------------------------------
local function GetNumPerPage()
    return #kEntryKeyCodes
end

local function GetNumPages()
    return math.ceil(#kVids / GetNumPerPage())
end

local function GetNumVidsForPage(pageNum)
    if pageNum == GetNumPages() then
        return #kVids % GetNumPerPage()
    else
        return GetNumPerPage()
    end
end

local function GetFirstVideo(pageNum)
    return ((pageNum-1) * GetNumPerPage())+1
end

//----------------------------------------
//  
//----------------------------------------
class "GUIReadyVideoList" (GUIScript)

GUIReadyVideoList.main = nil

function GUIReadyVideoList:UpdateEntries()

    for i,label in ipairs(kEntryKeyLabels) do
        local vidNum = GetFirstVideo(self.pageNum) + (i-1)
        if vidNum <= #kVids then
            s = string.format("%s. %s", label, kVids[vidNum].key)
            if GetNumTipVideoPlays(kVids[vidNum].key) > 0 then
                self.entries[i]:SetColor(Color(0.5, 0.5, 0.5, 1.0))
            else
                self.entries[i]:SetColor(Color(1.0, 1.0, 1.0, 1.0))
            end
        else
            s = ""
        end
        self.entries[i]:SetText(s)

    end
    self.pageText:SetText(string.format("Page %d/%d (Press %s for more)", self.pageNum, GetNumPages(), kNextPageKeyLabel))

end

function CreateTextLine(x, y, color)
    local item = GUI.CreateItem()
    item:SetOptionFlag(GUIItem.ManageRender)
    item:SetAnchor( GUIItem.Left, GUIItem.Top )
    item:SetPosition(Vector(x, y, 0))
    item:SetTextAlignmentX(GUIItem.Align_Min)
    item:SetTextAlignmentY(GUIItem.Align_Min)
    item:SetFontName(Fonts.kAgencyFB_Small)
    if color then
        item:SetColor(color)
    else
        item:SetColor( Color(1, 1, 1, 1) )
    end
    item:SetInheritsParentAlpha( true )
    return item
end

function GUIReadyVideoList:Initialize()

    GUIScript.Initialize(self)

    assert( GUIReadyVideoList.main == nil )
    GUIReadyVideoList.main = self
    
    // Compute size/pos
    local wt = 250
    local ht = 220
    local textPad = 10

    local posY = textPad
    local stepY = 25

    local title = CreateTextLine(textPad, posY, Color(0, 1, 0))
    posY = posY + stepY + 10
    title:SetText("Press a number to play a video:")

    // create list entries
    self.entries = {}
    for i = 1,GetNumPerPage() do
        local entry = CreateTextLine(textPad, posY)
        table.insert(self.entries, entry)
        posY = posY + stepY
    end
    posY = posY + 10

    self.pageText = CreateTextLine(textPad, posY, Color(0,1,0))
    posY = posY + stepY + 10
    self.pageText:SetText("---")

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetColor( Color(0.0, 0.0, 0.0, kBackgroundAlpha) )
    self.background:SetInheritsParentAlpha( true )
    self.background:SetAnchor( GUIItem.Left, GUIItem.Top )
    self.background:SetPosition(Vector(0, 0, 0))
    self.background:SetSize( Vector(wt, ht, 0) )

    self.widget = GUIManager:CreateGraphicItem()
    self.widget:SetColor( Color(1.0, 1.0, 1.0, 1.0) )
    self.widget:SetAnchor( GUIItem.Right, GUIItem.Top )
    local x = -wt
    local y = Client.GetScreenHeight()/2.0 - ht/2.0
    self.widget:SetPosition(Vector(x, y, 0))
    self.widget:SetSize( Vector(0, 0, 0) )
    self.widget:AddChild(self.background)
    for i,entry in ipairs(self.entries) do
        self.widget:AddChild(entry)
    end
    self.widget:AddChild(title)
    self.widget:AddChild(self.pageText)

    self.widget:SetIsVisible(false)
    self.widget:SetLayer(kGUILayerTipVideos)

    self.pageNum = 1

    if not self:GetMustHide() then
        self:Show()
    end

end

local function Destroy(self)

    if self.widget then
        GUI.DestroyItem( self.widget )
        self.widget = nil
    end

end

function GUIReadyVideoList:Uninitialize()
    Destroy(self)
end

function GUIReadyVideoList:Show()

    if self.state ~= "shown" then
        self.state = "shown"
        self.sinceShow = 0
        local color = self.widget:GetColor()
        color.a = 1.0
        self.widget:SetColor( color )
        self:UpdateEntries()
    end

end

function GUIReadyVideoList:Hide()

    if self.state ~= "hiding" and self.state ~= "hidden" then
        self.state = "hiding"
        self.sinceHide = 0.0
    end

end

// Returns true if we must hide the video asap - ie. the player disabled hints, or player is playing the game
function GUIReadyVideoList:GetMustHide()

    local hintsEnabled = Client.GetOptionBoolean("showHints", true)

    if not hintsEnabled then
        return true
    end

    if Client.GetLocalPlayer():GetTeamNumber() == kNeutralTeamType then
        return false
    end

    return GetGameInfoEntity():GetState() == kGameState.Started

end

function GUIReadyVideoList:Update(dt)
    PROFILE("GUIReadyVideoList:Update")
    GUIScript.Update(self, dt)
    
    if self.state == "shown" then
   
        if self:GetMustHide() then
            self:Hide()
        else

            // Fancy tweened animation

            self.sinceShow = self.sinceShow + dt
            local pos = self.widget:GetPosition()

            // Note that position is relative to screen right
            local widgetWidth = self.background:GetSize().x
            local startX = 0
            local endX = -widgetWidth - kWidgetRightMargin

            if self.sinceShow < kSlideInSecs then
                local alpha = Easing.outBack( self.sinceShow, 0.0, 1.0, kSlideInSecs )
                pos.x = (1-alpha)*startX + alpha*endX
            else
                pos.x = endX
            end
            
            self.widget:SetPosition(pos)
            self.widget:SetIsVisible(true)  // set vis here rather than in loadingHtml, to avoid position-related flash

        end

    elseif self.state == "hiding" then
    
        self.sinceHide = self.sinceHide + dt

        local alpha = 1.0 - math.min( self.sinceHide / kFadeOutSecs, 1.0 )
        local color = self.widget:GetColor()
        color.a = alpha
        self.widget:SetColor( color )
        
        if alpha <= 0.0 then
            self.widget:SetIsVisible(false)
            self.state = "hidden"
        end
        
    elseif self.state == "hidden" then

        if not GUITipVideo.singleton:GetIsPlaying() and not self:GetMustHide() then
            self:Show()
        end

    end
    
end

function GUIReadyVideoList:TriggerVideo(vidIndex)

    self:Hide()
    GUITipVideo.singleton:TriggerReadyVideo(kVids[vidIndex])
    IncNumTipVideoPlays(kVids[vidIndex].key)

end

function GUIReadyVideoList:SendKeyEvent(key, down)

    if self.state == "shown" and down then

        if key == kNextPageKeyCode then
            self.pageNum = ((self.pageNum-1+1) % GetNumPages())+1
            self:UpdateEntries()
            StartSoundEffect(kPageSound)
            return true
        end

        for i,keyCode in ipairs(kEntryKeyCodes) do
            if key == keyCode then
                local vidNum = GetFirstVideo(self.pageNum) + i-1
                if vidNum <= #kVids then
                    self:TriggerVideo(vidNum)
                    StartSoundEffect(kPlaySound)
                    return true
                end
            end
        end

    end

    return false

end


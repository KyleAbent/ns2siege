// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIMainMenu_Gather.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworld.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local gSelectedGatherId = -1
local gWasInGather = false

function GUIMainMenu:ProcessJoinGather(gatherId)
end

local function UpdateGatherRoomContentSize(self)

    local contentSize = self.gatherWindow:GetContentBox().contentStencil:GetSize()
    self.gatherFrame:SetBackgroundSize(contentSize)
    
end    

function GUIMainMenu:CreateGatherWindow()

    self.gatherWindow = self:CreateWindow()
    self:SetupWindow(self.gatherWindow, "ORGANIZED PLAY")
    self.gatherWindow:AddCSSClass("gather_window")
    self.gatherWindow:ResetSlideBar()    // so it doesn't show up mis-drawn
    self.gatherWindow:GetContentBox():SetCSSClass("gather_content")
    self.gatherWindow:DisableSlideBar()
    
    local hideTickerCallbacks =
    {
        OnShow = function(self)
            self.scriptHandle.tweetText:SetIsVisible(false)
            UpdateGatherRoomContentSize(self.scriptHandle)
        end,
        
        OnHide = function(self)
            self.scriptHandle.tweetText:SetIsVisible(true)
        end
    }
    
    self.gatherWindow:AddEventCallbacks( hideTickerCallbacks )
    
    local back = CreateMenuElement(self.gatherWindow, "MenuButton")
    back:SetCSSClass("back")
    back:SetText("BACK")
    back:AddEventCallbacks( { OnClick = function() self.gatherWindow:SetIsVisible(false) end } )
    
    self.gatherFrame = CreateMenuElement(self.gatherWindow:GetContentBox(), "GatherFrame")
    
end
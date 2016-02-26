// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. ======
//
// lua\menu\GatherFrame.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/WindowUtility.lua")
Script.Load("lua/MainMenu.lua")

class 'GatherFrame' (MenuElement)

local kGatherUrl = "http://gathers.naturalselection2.com/"
local kTextureName = "*gather_view"

local function UpdateWebViewItem(self)

    local backgroundSize = self:GetBackground().guiItem:GetSize()
    local sizeChanged = backgroundSize.x ~= self.webViewSize.x or backgroundSize.y ~= self.webViewSize.y

    if not self.webView or sizeChanged then  
    
        if self.webView then
            Client.DestroyWebView(self.webView)
        end

        self.webView = Client.CreateWebView(backgroundSize.x, backgroundSize.y)
        self.webView:SetTargetTexture(kTextureName)
        self.webView:LoadUrl(kGatherUrl)
        
        self.webViewSize.x = backgroundSize.x
        self.webViewSize.y = backgroundSize.y
    
    end

end

function GatherFrame:GetTagName()
    return "gatherframe"
end

function GatherFrame:OnParentVisibilityChanged(isVisible)

    if self.webView and not isVisible then

        Client.DestroyWebView(self.webView)
        self.webView = nil

    end

end

function GatherFrame:SetIsVisible(isVisible)
    
    MenuElement.SetIsVisible(isVisible)
    
    if self.webView and not isVisible then

        Client.DestroyWebView(self.webView)
        self.webView = nil

    end
    
end

function GatherFrame:Initialize()

    MenuElement.Initialize(self)
    
    self.webViewSize = Vector(0,0,0)
    
    UpdateWebViewItem(self)
    self:SetBackgroundTexture(kTextureName)

    local eventCallBacks = {
    
        OnMouseOver = function(self, buttonPressed)

            UpdateWebViewItem(self)
            local mouseX, mouseY = Client.GetCursorPosScreen()
            local containsPoint, withinX, withinY = GUIItemContainsPoint(self:GetBackground().guiItem, mouseX, mouseY)
            self.webView:OnMouseMove(withinX, withinY)
        
        end,
    
        OnShow = function(self)
            UpdateWebViewItem(self)
            self.webView:LoadUrl(kGatherUrl)
        end,

        OnEscape = function (self)
        
            UpdateWebViewItem(self)    
            self.webView:OnEscape(true)
            
        end,
        
        OnEnter = function (self)
        
            UpdateWebViewItem(self) 
            self.webView:OnEnter(true)
            
        end,
        
        OnMouseDown = function (self, key)
        
            UpdateWebViewItem(self)
            local buttonCode = key - InputKey.MouseButton0
            self.webView:OnMouseDown(buttonCode)
        
        end,
        
        OnMouseUp = function (self, key)

            UpdateWebViewItem(self)
            local buttonCode = key - InputKey.MouseButton0
            self.webView:OnMouseUp(buttonCode)
            
        end,
        
        OnMouseOut = function (self)

            if self.webView then
                self.webView:OnMouseUp(0)
                self.webView:OnMouseUp(1)
            end

        end,
        
        OnMouseWheel = function (self, up)     

            UpdateWebViewItem(self) 
            
            if up then
                self.webView:OnMouseWheel(30, 0)   
            else
                self.webView:OnMouseWheel(-30, 0)
            end
    
        end,

    
    }
    
    self:AddEventCallbacks(eventCallBacks)

end

function GatherFrame:Uninitialize()

    if self.webView then
    
        Client.DestroyWebView(self.webView)
        self.webView = nil
        
    end
    
    MenuElement.Uninitialize(self)

end

function GatherFrame:OnSendKey(key, down)

    UpdateWebViewItem(self) 
    
    if key == InputKey.Back then
        self.webView:OnBackSpace(down)
        
    elseif key == InputKey.Space then
        self.webView:OnSpace(down)
    end 

end

function GatherFrame:OnSendCharacter(wideString)

    UpdateWebViewItem(self) 
    local char = string.byte(ConvertWideStringToString(wideString))
    self.webView:OnSendCharacter(char)

end
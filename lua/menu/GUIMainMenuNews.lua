-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenuNews.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local widthFraction = 0.4
local newsAspect = 1.2/1
local kTextureName = "*mainmenu_news"
local fadeColor = Color(1,1,1,0)
local lastUpdatedtime = 0
local playAnimation = ""

-- Non local so modders can easily change the URL.
kMainMenuNewsURL = "http://ns2siege.com/viewforum.php?f=13"

class 'GUIMainMenuNews' (GUIScript)

function GUIMainMenuNews:Initialize()

    
    local layer = kGUILayerMainMenuNews

    self.logo = GUIManager:CreateGraphicItem()
    self.logo:SetTexture("ui/menu/logo.dds")
    self.logo:SetLayer(layer)
    
    local width = widthFraction * Client.GetScreenWidth()
    local newsHt = width/newsAspect
    self.webView = Client.CreateWebView(width, newsHt)
    self.webView:SetTargetTexture(kTextureName)
    self.webView:LoadUrl(kMainMenuNewsURL)
    self.webContainer = GUIManager:CreateGraphicItem()
    self.webContainer:SetTexture(kTextureName)
    self.webContainer:SetLayer(layer)

    self.buttonDown = { [InputKey.MouseButton0] = false, [InputKey.MouseButton1] = false, [InputKey.MouseButton2] = false }


        self.isVisible = true

end

function GUIMainMenuNews:Uninitialize()

    GUI.DestroyItem(self.webContainer)
    self.webContainer = nil
    
    Client.DestroyWebView(self.webView)
    self.webView = nil

    GUI.DestroyItem(self.logo)
    self.logo = nil
    
end

function GUIMainMenuNews:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end



function GUIMainMenuNews:SendKeyEvent(key, down, amount)

    if not self.isVisible or not MainMenu_GetIsOpened() then
        return
    end

    local isReleventKey = false
    
    if type(self.buttonDown[key]) == "boolean" then
        isReleventKey = true
    end
    
    local mouseX, mouseY = Client.GetCursorPosScreen()
    if isReleventKey then
    
        local containsPoint, withinX, withinY = GUIItemContainsPoint(self.webContainer, mouseX, mouseY)
        
        -- If we pressed the button inside the window, always send it the button up
        -- even if the cursor was outside the window.
        if containsPoint or (not down and self.buttonDown[key]) then
        
            local buttonCode = key - InputKey.MouseButton0
            if down then
                self.webView:OnMouseDown(buttonCode)
            else
                self.webView:OnMouseUp(buttonCode)
            end
            
            self.buttonDown[key] = down
            
            return true
            
        end
    
    -- This isn't working currently as the input is blocked by the main menu code in
    -- MouseTracker_SendKeyEvent(). But it is a nice thought.  
    elseif key == InputKey.MouseWheelUp then
        self.webView:OnMouseWheel(30, 0)
        MainMenu_OnSlide()
    elseif key == InputKey.MouseWheelDown then
        self.webView:OnMouseWheel(-30, 0)
        MainMenu_OnSlide()
    end
    
    return false
    
end

function GUIMainMenuNews:Update(deltaTime)
    
    if not self.isVisible then
        return
    end

    local mouseX, mouseY = Client.GetCursorPosScreen()
    local containsPoint, withinX, withinY = GUIItemContainsPoint(self.webContainer, mouseX, mouseY)
    if containsPoint or self.buttonDown[InputKey.MouseButton0] or self.buttonDown[InputKey.MouseButton1] or self.buttonDown[InputKey.MouseButton2] then
        self.webView:OnMouseMove(withinX, withinY)
    end

    if GUIItemContainsPoint( self.webContainer, mouseX, mouseY ) then
        SetKeyEventBlocker(self)
    else
        SetKeyEventBlocker(nil)
    end
    


    local width = widthFraction * Client.GetScreenWidth()
    local newsHt = width/newsAspect

    local rightMargin = math.min( 150, Client.GetScreenWidth()*0.05 )
    local y = 10    // top margin

    local logoAspect = 600/192

    self.logo:SetSize( Vector(width, width/logoAspect, 0) )
    self.logo:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.logo:SetPosition(Vector( -width-rightMargin, y, 0))
    y = y + width/logoAspect

    local logoAspect = 300/100
    local buttonSpacing = 10
    local logoWidth = width/2.0 - buttonSpacing/2
    y = y - 8
	
    //
    self.webContainer:SetSize(Vector(width, newsHt, 0))
    self.webContainer:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.webContainer:SetPosition(Vector(-width-rightMargin, y, 0))
	
    y = y + newsHt
    
end

function GUIMainMenuNews:SetIsVisible(visible)
    self.webContainer:SetIsVisible(visible)
    self.logo:SetIsVisible(visible)
    self.isVisible = visible
    
    if visible == false then
        SetKeyEventBlocker(nil)
    end
    
end


function GUIMainMenuNews:LoadURL(url)
    self.webView:LoadUrl(url)
end

Event.Hook("Console_refreshnews", function() MainMenu_LoadNewsURL(kMainMenuNewsURL) end)
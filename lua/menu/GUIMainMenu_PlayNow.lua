-- ======= Copyright (c) 2003-2015, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenu_PlayNow.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

function UpdateAutoJoin()

    if not Client.GetServerListRefreshed() then return end

    if Client.GetNumServers() > 0 then

        local allValidServers = { }
        for s = 0, Client.GetNumServers() - 1 do

            if not Client.GetServerRequiresPassword(s) then

                local serverEntry = BuildServerEntry(s)

                --determ if the local client is a rookie or not
                local rookie = Client.GetLevel() ~= -1 and Client.GetLevel() < kRookieLevel

                --only rookies can join rookie only servers
                --players below level 1 can't join normal servers
                local rookieOnly = serverEntry.rookieOnly and rookie or not serverEntry.rookieOnly and Client.GetLevel() >= 1

                if not serverEntry.ignorePlayNow and rookieOnly and serverEntry.numPlayers < (serverEntry.maxPlayers - serverEntry.numRS) and serverEntry.mode == "ns2" then
                    table.insert(allValidServers, serverEntry)
                end

            end

        end

        if #allValidServers > 0 then
            table.sort(allValidServers, function(a , b) return a.rating > b.rating end)

            local bestServer = allValidServers[1]

            Client.SetAchievement("First_0_2")

            MainMenu_SBJoinServer(bestServer.address, nil, bestServer.map , true)
        end

    else

        Client.RebuildServerList()

    end

end

function UpdatePlayNowWindowLogic(playNowWindow, mainMenu)

    PROFILE("GUIMainMenu:UpdatePlayNowWindowLogic")

    if playNowWindow:GetIsVisible() then
    
        playNowWindow.searchingForGameText.animateTime = playNowWindow.searchingForGameText.animateTime or Shared.GetTime()
        if Shared.GetTime() - playNowWindow.searchingForGameText.animateTime > 0.85 then
        
            playNowWindow.searchingForGameText.animateTime = Shared.GetTime()
            playNowWindow.searchingForGameText.numberOfDots = playNowWindow.searchingForGameText.numberOfDots or 3
            playNowWindow.searchingForGameText.numberOfDots = playNowWindow.searchingForGameText.numberOfDots + 1
            if playNowWindow.searchingForGameText.numberOfDots > 3 then
                playNowWindow.searchingForGameText.numberOfDots = 0
            end

            local serverFound = Client.GetNumServers()
            local serverFoundMessage = serverFound == 0 and
                    string.rep(".", playNowWindow.searchingForGameText.numberOfDots) or
                    string.format(Locale.ResolveString("SERVER_FOUND"), serverFound)

            playNowWindow.searchingForGameText:SetText(string.format( "%s %s", Locale.ResolveString("SEARCHING"), serverFoundMessage))
            
        end
        
        UpdateAutoJoin()
        
    end
    
end

local function CreatePlayNowPage(self)

    self.playNowWindow = self:CreateWindow()
    self.playNowWindow:SetWindowName("PLAY NOW")
    self.playNowWindow:SetInitialVisible(false)
    self.playNowWindow:SetIsVisible(false)
    self.playNowWindow:DisableResizeTile()
    self.playNowWindow:DisableSlideBar()
    self.playNowWindow:DisableContentBox()
    self.playNowWindow:SetCSSClass("playnow_window")
    self.playNowWindow:DisableCloseButton()
    
    self.playNowWindow.UpdateLogic = UpdatePlayNowWindowLogic

    local eventCallbacks =
    {
        OnShow = function(self)

            MainMenu_OnWindowOpen()

            Client.RebuildServerList()

        end
    }
    self.playNowWindow:AddEventCallbacks(eventCallbacks)

    self.playNowWindow.searchingForGameText = CreateMenuElement(self.playNowWindow.titleBar, "Font", false)
    self.playNowWindow.searchingForGameText:SetCSSClass("playnow_title")
    self.playNowWindow.searchingForGameText:SetText(Locale.ResolveString("SERVERBROWSER_SEARCHING"))
    
    local cancelButton = CreateMenuElement(self.playNowWindow, "MenuButton")
    cancelButton:SetCSSClass("playnow_cancel")
    cancelButton:SetText(Locale.ResolveString("AUTOJOIN_CANCEL"))
    
    cancelButton:AddEventCallbacks({ OnClick =
    function() self.playNowWindow:SetIsVisible(false) end })
    
end

local function CreateJoinServerPage(self)

    self:CreateServerListWindow()
    self:CreateServerDetailsWindow()
    
end

local function CreateHostGamePage(self)

    self.createGame = CreateMenuElement(self.playWindow:GetContentBox(), "Image")
    self.createGame:SetCSSClass("play_now_content")
    self:CreateHostGameWindow()
    
end

local function ShowServerWindow(self)

    self.playWindow.updateButton:SetIsVisible(true)
    self.playWindow.detailsButton:SetIsVisible(true)
    self.joinServerButton:SetIsVisible(true)
    self.highlightServer:SetIsVisible(true)
    self.selectServer:SetIsVisible(true)
    self.serverRowNames:SetIsVisible(true)
    self.serverTabs:SetIsVisible(true)
    self.serverList:SetIsVisible(true)
    self.filterForm:SetIsVisible(true)
    
    -- Re-enable slide bar.
    self.playWindow:SetSlideBarVisible(true)
    self.playWindow:ResetSlideBar()
    
end

local function HideServerWindow(self)

    self.playWindow.updateButton:SetIsVisible(false)
    self.playWindow.detailsButton:SetIsVisible(false)
    self.joinServerButton:SetIsVisible(false)
    self.highlightServer:SetIsVisible(false)
    self.selectServer:SetIsVisible(false)
    self.serverRowNames:SetIsVisible(false)
    self.serverTabs:SetIsVisible(false)
    self.serverList:SetIsVisible(false)
    self.filterForm:SetIsVisible(false)
    
    -- Hide it, but make sure it's at the top position.
    self.playWindow:SetSlideBarVisible(false)
    self.playWindow:ResetSlideBar()
    
end

function GUIMainMenu:SetPlayContentInvisible(cssClass)

    HideServerWindow(self)
    self.createGame:SetIsVisible(false)
    self.playNowWindow:SetIsVisible(false)
    self.hostGameButton:SetIsVisible(false)
    
    if cssClass then
        self.playWindow:GetContentBox():SetCSSClass(cssClass)
    end
    
end

function GUIMainMenu:CreatePlayWindow()

    self.playWindow = self:CreateWindow()
    self:SetupWindow(self.playWindow, "SERVER BROWSER")
    self.playWindow:AddCSSClass("play_window")
    self.playWindow:ResetSlideBar()    -- so it doesn't show up mis-drawn
    self.playWindow:GetContentBox():SetCSSClass("serverbrowse_content")
    
    local hideTickerCallbacks =
    {
        OnShow = function(self)
            self.scriptHandle.tweetText:SetIsVisible(false)
        end,
        
        OnHide = function(self)
            self.scriptHandle.tweetText:SetIsVisible(true)
        end
    }
    
    self.playWindow:AddEventCallbacks( hideTickerCallbacks )
    
    local back = CreateMenuElement(self.playWindow, "MenuButton")
    back:SetCSSClass("back")
    back:SetText(Locale.ResolveString("BACK"))
    back:AddEventCallbacks( { OnClick = function()
        self.playNowWindow:SetIsVisible(false)
        self.playWindow:SetIsVisible(false)
    end } )
    
    local tabs = 
        {
            { label = Locale.ResolveString("JOIN"), func = function(self) self.scriptHandle:SetPlayContentInvisible("serverbrowse_content") ShowServerWindow(self.scriptHandle) end },
            --{ label = Locale.ResolveString("QUICK_JOIN"), func = function(self) self.scriptHandle:SetPlayContentInvisible("play_content") self.scriptHandle.playNowWindow:SetIsVisible(true) end },
            { label = Locale.ResolveString("START_SERVER"), func = function(self) self.scriptHandle:SetPlayContentInvisible("play_content") self.scriptHandle.createGame:SetIsVisible(true) self.scriptHandle.hostGameButton:SetIsVisible(true) end }
        }
        
    local xTabWidth = 256

    local tabBackground = CreateMenuElement(self.playWindow, "Image")
    tabBackground:SetCSSClass("tab_background_playnow")
    tabBackground:SetIgnoreEvents(true)
    
    local tabAnimateTime = 0.1
        
    for i = 1,#tabs do
    
        local tab = tabs[i]
        local tabButton = CreateMenuElement(self.playWindow, "MenuButton")
        
        local function ShowTab()
            for j =1,#tabs do
                local tabPosition = tabButton.background:GetPosition()
                tabBackground:SetBackgroundPosition( tabPosition, false, tabAnimateTime ) 
            end
        end
    
        tabButton:SetCSSClass("tab_playnow")
        tabButton:SetText(tab.label)
        tabButton:AddEventCallbacks({ OnClick = tab.func })
        tabButton:AddEventCallbacks({ OnClick = ShowTab })
        
        local tabWidth = tabButton:GetWidth()
        tabButton:SetBackgroundPosition( Vector(tabWidth * (i - 1), 0, 0) )
        
    end
    
    CreateJoinServerPage(self)
    CreatePlayNowPage(self)
    CreateHostGamePage(self)
    
    self:SetPlayContentInvisible()
    ShowServerWindow(self)
    
end

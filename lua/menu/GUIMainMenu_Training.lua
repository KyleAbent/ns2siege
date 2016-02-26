// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIMainMenu_Tutorial.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/GUIVideoTutorialIntro.lua")

local function GetPageSize()
    return Vector(Client.GetScreenWidth() * 0.9, Client.GetScreenHeight() * 0.9, 0)
end

local kOrderedVideoCategories = 
{
    "General",
    "Marine Basics",
    "Marine Advanced",
    "Marine Weapons",
    "Marine Items",
    "Alien Basics",
    "Alien Advanced",
    "Skulk & Lerk",
    "Gorge",
    "Fade & Onos",
    "Evolution Traits",
}

local function FindIn( list, query )

    for i,item in ipairs(list) do
        if item == query then
            return i
        end
    end

    return -1

end

// for a given category
function GUIMainMenu:ShowVideoLinksForCategory(cat)

    self:ClearVideoLinks()

    // find all videos for this cat

    local vids = {}
    for _,video in ipairs(gSpawnTipVideos) do

        if video.category == cat then
            table.insert( vids, video )
        end

    end

    // first link is BACK

    self.videoLinks[1]:SetText(Locale.ResolveString("BACK"))
    self.videoLinks[1].OnClick = function()
        self:ShowVideoCategoryLinks()
        MainMenu_OnButtonClicked()
    end

    // setup links

    for i,vid in ipairs(vids) do

        if i+1 > #self.videoLinks then
            Print("Too many vids in category "..cat)
            break
        end

        local link = self.videoLinks[i+1]
        link:SetText(Locale.ResolveString(string.format("%s_TITEL", vid.subKey)))
        link.OnClick = function()
            Analytics.RecordEvent("training_tipvid")
            self.videoPlayer:TriggerVideo(vid, 8)
            MainMenu_OnTrainingLinkedClicked()
        end

    end

end

function GUIMainMenu:ShowVideoCategoryLinks()

    self:ClearVideoLinks()

    for i,cat in ipairs(kOrderedVideoCategories) do

        local link = self.videoLinks[i]
        link:SetText(Locale.ResolveString( string.format("TUT_CAT_%s", i) ))
        link.OnClick = function()
            self:ShowVideoLinksForCategory(cat)
            MainMenu_OnButtonClicked()
        end

    end

end

function GUIMainMenu:ClearVideoLinks()

    for i,link in ipairs(self.videoLinks) do
        link:SetText("")
        link.OnClick = nil
    end

end

local function CreateVideosPage(self)
    self.videosPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.videosPage:SetCSSClass("play_now_content")
    self.videosPage:AddEventCallbacks({
            OnHide = function()
                self.videoPlayer:Hide()
            end
            })

    self.videoLinks = {}

    // gather unique categories, make sure they are all in our ordered list

    local categorySet = {}
    for _,data in ipairs(gSpawnTipVideos) do

        local cat = data.category

        if not categorySet[ cat ] then
            categorySet[ cat ] = true
            if FindIn(kOrderedVideoCategories, cat) == -1 then
                Print("** ERROR: Could not find category "..cat.." in kOrderedVideoCategories" )
            end
        end

    end

    // verify other direction
    // make sure all categories in our list are accounted for
    for _,cat in ipairs(kOrderedVideoCategories) do
        if categorySet[cat] == nil then
            Print("** ERROR: Could not find category "..cat.." in the video data")
        end
    end

    // create link elements

    for linkId = 0,13 do

        local link = CreateMenuElement(self.videosPage, "Link")
        table.insert( self.videoLinks, link )

        link:SetCSSClass("vid_link_"..linkId)
        link:SetText("link "..linkId)
        link:EnableHighlighting()

    end

    self:ShowVideoCategoryLinks()
    
end

local function CreateTutorialPage(self)

    self.tutorialPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.tutorialPage:SetCSSClass("play_now_content")
    
    self.replayIntroButton = CreateMenuElement(self.trainingWindow, "MenuButton")
    self.replayIntroButton:SetCSSClass("replay_intro_video")
    self.replayIntroButton:SetText(Locale.ResolveString("REPLAY_INTRO_VIDEO"))
    
    self.replayIntroButton:AddEventCallbacks({
            OnClick = function (self)
                if not gVideoPlaying then
                    Analytics.RecordEvent("training_introvid")
                    GUIVideoTutorialIntro_Play(nil, nil)
                end
            end
        })
    
    self.playTutorialButton = CreateMenuElement(self.trainingWindow, "MenuButton")
    self.playTutorialButton:SetCSSClass("play_tutorial")
    self.playTutorialButton:SetText(Locale.ResolveString("PLAY_TUT"))
    
    self.playTutorialButton:AddEventCallbacks({
            OnClick = function (self)
                if not gVideoPlaying then
                    Analytics.RecordEvent("training_tutorial")
                    self.scriptHandle:StartTutorial() 
                end
            end
        })

    local note = CreateMenuElement( self.tutorialPage, "Font", false )
    note:SetCSSClass("tutorial_note")
    note:SetText(Locale.ResolveString("TUT_MESSAGE_1"))
    
end

function GUIMainMenu:StartTutorial()

    local modIndex = Client.GetLocalModId("tutorial")
    
    if modIndex == -1 then
        Shared.Message("Tutorial mod does not exist!")
        return
    end

    local password      = "dummypassword"..ToString(math.random())
    local port          = 27015
    local maxPlayers    = 24    -- need room for bots
    local serverName    = "private tutorial server"
    local mapName       = "ns2_docking"
    Client.SetOptionString("lastServerMapName", mapName)
    
    if Client.StartServer(modIndex, mapName, serverName, password, port, 1, true, true) then
        LeaveMenu()
    end
    
end

local function CreateSandboxPage(self)

    self.sandboxPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.sandboxPage:SetCSSClass("play_now_content")

    local formOptions = {
        {
            name  = "Map",
            label = Locale.ResolveString("SERVERBROWSER_MAP"),
            type  = "select",
            value = "Docking",
        },
    }
    
    local createdElements = {}
    self.sandboxPage.optionsForm = GUIMainMenu.CreateOptionsForm(self, self.sandboxPage, formOptions, createdElements)
    local mapList = createdElements.Map:SetOptions( MainMenu_GetMapNameList() );

    self.playSandboxButton = CreateMenuElement(self.trainingWindow, "MenuButton")
    self.playSandboxButton:SetCSSClass("play_sandbox")
    self.playSandboxButton:SetText(Locale.ResolveString("PLAY_SANDBOX"))
    
    self.playSandboxButton:AddEventCallbacks({
             OnClick = function (self)
                 Analytics.RecordEvent("training_sandbox")
                 self.scriptHandle:CreateSandboxServer() end
        })

    local note = CreateMenuElement( self.sandboxPage, "Font", false )
    note:SetCSSClass("sandbox_note")
    note:SetText(Locale.ResolveString("TUT_MESSAGE_2"))
    
end

function GUIMainMenu:CreateSandboxServer()
    
    local password      = "dummypassword"
    local port          = 27015
    local maxPlayers    = 24
    local serverName    = "private tutorial server"
    local mapName       = "ns2_"..string.lower(self.sandboxPage.optionsForm:GetFormData().Map)
    Client.SetOptionString("lastServerMapName", mapName)
    
    if Client.StartServer(mapName, serverName, password, port, 1, false, true) then
        Client.SetOptionBoolean("sandboxMode", true)
        LeaveMenu()
    end
    
end

local function CreateBotsPage(self)

    self.botsPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.botsPage:SetCSSClass("play_now_content")
    
    local minPlayers            = 2
    local maxPlayers            = 32
    local playerLimitOptions    = { }
    
    for i = minPlayers, maxPlayers do
        table.insert(playerLimitOptions, i)
    end

    local hostOptions = 
    {
        {   
            name   = "ServerName",            
            label  = Locale.ResolveString("SERVERBROWSER_SERVERNAME"),
            value  = "Training vs. Bots"
        },
        {   
            name   = "Password",            
            label  = Locale.ResolveString("SERVERBROWSER_CREATE_PASSWORD"),
        },
        {
            name    = "Map",
            label   = Locale.ResolveString("SERVERBROWSER_MAP"),
            type    = "select",
            value  = "Descent",
        },
        {
            name    = "PlayerLimit",
            label   = Locale.ResolveString("SERVERBROWSER_CREATE_PLAYER_LIMIT"),
            type    = "select",
            values  = playerLimitOptions,
            value   = 16
        },
        {
            name    = "NumMarineBots",
            label   = Locale.ResolveString("TUT_MBOTNUMBER"),
            value   = "8"
        },
        {
            name = "MarineSkillLevel",
            label = Locale.ResolveString("TUT_MBOTSKILL"),
            type = "select",
            values = {"Beginner", "Intermediate", "Expert"},
            value = "Intermediate"
        },
        {
            name    = "AddMarineCommander",
            label   = Locale.ResolveString("TUT_MCOMMBOT"),
            value   = "false",
            type    = "checkbox"
        },
        {
            name    = "NumAlienBots",
            label   = Locale.ResolveString("TUT_ABOTNUMBER"),
            value   = "8"
        },
        {
            name    = "AddAlienCommander",
            label   = Locale.ResolveString("TUT_ACOMMBOT"),
            value   = "true",
            type    = "checkbox"
        }
    }
        
    local createdElements = {}
    local content = self.botsPage
    local form = GUIMainMenu.CreateOptionsForm(self, content, hostOptions, createdElements)
    form:SetCSSClass("createserver")
    
    local mapList = createdElements.Map
    
    self.playBotsButton = CreateMenuElement(self.trainingWindow, "MenuButton")
    self.playBotsButton:SetCSSClass("apply")
    self.playBotsButton:SetText(Locale.ResolveString("PLAY"))
    
    self.playBotsButton:AddEventCallbacks(
    {
        OnClick = function()

            local formData = form:GetFormData()

            // validate
            if tonumber(formData.NumMarineBots) == nil then
                MainMenu_SetAlertMessage("Not a valid number for # MARINE BOTS: "..formData.NumMarineBots)
            elseif tonumber(formData.NumAlienBots) == nil then
                MainMenu_SetAlertMessage("Not a valid number for # ALIEN BOTS: "..formData.NumAlienBots)
            else

                 Analytics.RecordEvent("training_vsbots")
                 
                // start server!
                local password   = formData.Password
                local port       = 27015
                local maxPlayers = formData.PlayerLimit
                local serverName = formData.ServerName
                local mapName    = "ns2_" .. string.lower(formData.Map)
                Client.SetOptionString("lastServerMapName", mapName)

                Client.SetOptionBoolean("sendBotsCommands", true)
                Client.SetOptionInteger("botsSettings_numMarineBots", tonumber(formData.NumMarineBots))
                Client.SetOptionString("botsSettings_marineSkillLevel", formData.MarineSkillLevel)
                Client.SetOptionInteger("botsSettings_numAlienBots", tonumber(formData.NumAlienBots))
                Client.SetOptionBoolean("botsSettings_marineCom", formData.AddMarineCommander)
                Client.SetOptionBoolean("botsSettings_alienCom", formData.AddAlienCommander)
                
                if Client.StartServer(mapName, serverName, password, port, maxPlayers) then
                    LeaveMenu()
                end

            end
            
        end
    })

    local note = CreateMenuElement( form, "Font", false )
    note:SetCSSClass("bot_note")
    note:SetText(Locale.ResolveString("TUT_MESSAGE_3"))

    self.botsPage:AddEventCallbacks(
    {
     OnShow = function (self)
            mapList:SetOptions( MainMenu_GetMapNameList() )
        end
    })
    
end

function GUIMainMenu:HideAll()

    self.videosPage:SetIsVisible(false)
    self.tutorialPage:SetIsVisible(false)
    self.botsPage:SetIsVisible(false)
    self.trainingWindow:DisableSlideBar()
    self.trainingWindow:ResetSlideBar()
    self.replayIntroButton:SetIsVisible(false)
    self.playTutorialButton:SetIsVisible(false)
    self.playBotsButton:SetIsVisible(false)
    self.playSandboxButton:SetIsVisible(false)
    self.sandboxPage:SetIsVisible(false)

end

function GUIMainMenu:CreateTrainingWindow()

    self.trainingWindow = self:CreateWindow()
    self.trainingWindow:DisableCloseButton()
    self:SetupWindow(self.trainingWindow, "TRAINING")
    self.trainingWindow:SetCSSClass("tutorial_window")
    
    if not self.videoPlayer then
        self.videoPlayer = GetGUIManager():CreateGUIScriptSingle("GUITipVideo")
    end
    
    local back = CreateMenuElement(self.trainingWindow, "MenuButton")
    back:SetCSSClass("back")
    back:SetText(Locale.ResolveString("BACK"))
    back:AddEventCallbacks( { OnClick = function()
            if not gVideoPlaying then
                self.trainingWindow:SetIsVisible(false)
                self.videoPlayer:Hide()
            end
        end } )
    
    local tabs = 
    {
        { label = Locale.ResolveString("TUTORIAL"), func = function(self)
                    if not gVideoPlaying then
                        self.scriptHandle:HideAll()
                        self.scriptHandle.tutorialPage:SetIsVisible(true)
                        self.scriptHandle.replayIntroButton:SetIsVisible(true)
                        self.scriptHandle.playTutorialButton:SetIsVisible(true)
                    end
                end },
        { label = Locale.ResolveString("TIP_CLIPS"), func = function(self)
                    if not gVideoPlaying then
                        self.scriptHandle:HideAll()
                        self.scriptHandle.videosPage:SetIsVisible(true)
                    end
                end },
        { label = Locale.ResolveString("VS_BOTS"), func = function(self)
                if not gVideoPlaying then
                        self.scriptHandle:HideAll()
                        self.scriptHandle.botsPage:SetIsVisible(true)
                        self.scriptHandle.playBotsButton:SetIsVisible(true)
                    end
                end },
        { label = Locale.ResolveString("SANDBOX"), func = function(self)
                    if not gVideoPlaying then
                        self.scriptHandle:HideAll()
                        self.scriptHandle.sandboxPage:SetIsVisible(true)
                        self.scriptHandle.playSandboxButton:SetIsVisible(true)
                    end
                end },
    }
        
    local xTabWidth = 256

    local tabBackground = CreateMenuElement(self.trainingWindow, "Image")
    tabBackground:SetCSSClass("tab_background")
    tabBackground:SetIgnoreEvents(true)
    
    local tabAnimateTime = 0.1
        
    for i = 1,#tabs do
    
        local tab = tabs[i]
        local tabButton = CreateMenuElement(self.trainingWindow, "MenuButton")
        
        local function ShowTab()
            for j =1,#tabs do
                local tabPosition = tabButton.background:GetPosition()
                tabBackground:SetBackgroundPosition( tabPosition, false, tabAnimateTime ) 
            end
        end
    
        tabButton:SetCSSClass("tab")
        tabButton:SetText(tab.label)
        tabButton:AddEventCallbacks({ OnClick = tab.func })
        tabButton:AddEventCallbacks({ OnClick = ShowTab })
        
        local tabWidth = tabButton:GetWidth()
        tabButton:SetBackgroundPosition( Vector(tabWidth * (i - 1), 0, 0) )
        
    end

    CreateBotsPage(self)
    CreateTutorialPage(self)
    CreateSandboxPage(self)
    CreateVideosPage(self)
    
    self:HideAll()
    self.tutorialPage:SetIsVisible(true)
    self.replayIntroButton:SetIsVisible(true)
    self.playTutorialButton:SetIsVisible(true)

end
class "GUIInsight_TopBar" (GUIScript)

local isVisible

local kBackgroundTexture = "ui/topbar.dds"
local kIconTextureAlien = "ui/alien_commander_textures.dds"
local kIconTextureMarine = "ui/marine_commander_textures.dds"
local kBuildMenuTexture = "ui/buildmenu.dds"

local kTimeFontName = Fonts.kAgencyFB_Medium
local kMarineFontName = Fonts.kAgencyFB_Medium
local kAlienFontName = Fonts.kAgencyFB_Medium

local kInfoFontName = Fonts.kAgencyFB_Small

local kIconSize
local kButtonSize
local kButtonOffset

local background
local gameTime
local frontDoor
local siegeDoor

local scoresBackground
local teamsSwapButton
local marinePlusButton
local marineMinusButton
local alienPlusButton
local alienMinusButton

local marineTeamScore
local alienTeamScore

local marineNameBackground
local marineTeamName

local alienNameBackground
local alienTeamName


local function CreateIconTextItem(team, parent, position, texture, coords)

    local background = GUIManager:CreateGraphicItem()
    if team == kTeam1Index then
        background:SetAnchor(GUIItem.Left, GUIItem.Top)
    else
        background:SetAnchor(GUIItem.Right, GUIItem.Top)
    end
    background:SetColor(Color(0,0,0,0))
    background:SetSize(kIconSize)
    parent:AddChild(background)

    local icon = GUIManager:CreateGraphicItem()
    icon:SetSize(kIconSize)
    icon:SetAnchor(GUIItem.Left, GUIItem.Top)
    icon:SetPosition(position)
    icon:SetTexture(texture)
    icon:SetTexturePixelCoordinates(unpack(coords))
    background:AddChild(icon)
    
    local value = GUIManager:CreateTextItem()
    value:SetFontName(kInfoFontName)
    value:SetScale(GetScaledVector())
    value:SetAnchor(GUIItem.Left, GUIItem.Center)
    value:SetTextAlignmentX(GUIItem.Align_Min)
    value:SetTextAlignmentY(GUIItem.Align_Center)
    value:SetColor(Color(1, 1, 1, 1))
    value:SetPosition(position + Vector(kIconSize.x + GUIScale(5), 0, 0))
    GUIMakeFontScale(value)
    background:AddChild(value)
    
    return value
    
end

local function CreateButtonItem(parent, position, color)

    local button = GUIManager:CreateGraphicItem()
    button:SetSize(kButtonSize)
    button:SetPosition(position - kButtonSize/2)
    button:SetColor(color)
    button:SetIsVisible(false)
    parent:AddChild(button)
    
    return button
    
end


function GUIInsight_TopBar:Initialize()

    kIconSize = GUIScale(Vector(32, 32, 0))
    kButtonSize = GUIScale(Vector(8, 8, 0))
    kButtonOffset = GUIScale(Vector(0,20,0))
    
    isVisible = true
        
    local texSize = GUIScale(Vector(512,57,0))
    local texCoord = {0,0,512,57}
    local texPos = Vector(-texSize.x/2,0,0)
    background = GUIManager:CreateGraphicItem()
    background:SetAnchor(GUIItem.Middle, GUIItem.Top)
    background:SetTexture(kBackgroundTexture)
    background:SetTexturePixelCoordinates(unpack(texCoord))
    background:SetSize(texSize)
    background:SetPosition(texPos)
    background:SetLayer(kGUILayerInsight)
    
    gameTime = GUIManager:CreateTextItem()
    gameTime:SetFontName(kTimeFontName)
    gameTime:SetScale(GetScaledVector())
    gameTime:SetAnchor(GUIItem.Middle, GUIItem.Top)
    gameTime:SetPosition(GUIScale(Vector(0, 5, 0)))
    gameTime:SetTextAlignmentX(GUIItem.Align_Center)
    gameTime:SetTextAlignmentY(GUIItem.Align_Min)
    gameTime:SetColor(Color(1, 1, 1, 1))
    gameTime:SetText("")
    GUIMakeFontScale(gameTime)
    background:AddChild(gameTime)
    
    frontDoor = GUIManager:CreateTextItem()
    frontDoor:SetFontName(kTimeFontName)
    frontDoor:SetScale(GetScaledVector())
    frontDoor:SetAnchor(GUIItem.Middle, GUIItem.Top)
    frontDoor:SetPosition(Vector(GUIScale(130),GUIScale(4),0))
    frontDoor:SetTextAlignmentX(GUIItem.Align_Center)
    frontDoor:SetTextAlignmentY(GUIItem.Align_Min)
    frontDoor:SetColor(Color(1, 1, 1, 1))
    frontDoor:SetText("")
    GUIMakeFontScale(frontDoor)
    background:AddChild(frontDoor)
    
    
    siegeDoor = GUIManager:CreateTextItem()
    siegeDoor:SetFontName(kTimeFontName)
    siegeDoor:SetScale(GetScaledVector())
    siegeDoor:SetAnchor(GUIItem.Middle, GUIItem.Top)
       
    
    siegeDoor:SetPosition(Vector(-GUIScale(130),GUIScale(4),0))
    siegeDoor:SetTextAlignmentX(GUIItem.Align_Center)
    siegeDoor:SetTextAlignmentY(GUIItem.Align_Min)
    siegeDoor:SetColor(Color(1, 1, 1, 1))
    siegeDoor:SetText("")
    GUIMakeFontScale(siegeDoor)
    background:AddChild(siegeDoor)
    
    local scoresTexSize = GUIScale(Vector(512,71,0))
    local scoresTexCoord = {0,57,512,128}    
    
    scoresBackground = GUIManager:CreateGraphicItem()
    scoresBackground:SetTexture(kBackgroundTexture)
    scoresBackground:SetTexturePixelCoordinates(unpack(scoresTexCoord))
    scoresBackground:SetSize(scoresTexSize)
    scoresBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
    scoresBackground:SetPosition(Vector(-scoresTexSize.x/2, texSize.y - GUIScale(15), 0))
    scoresBackground:SetIsVisible(false)
    background:AddChild(scoresBackground)
    
    marineTeamScore = GUIManager:CreateTextItem()
    marineTeamScore:SetFontName(kTimeFontName)
    marineTeamScore:SetScale(GetScaledVector() * 1.2)
    marineTeamScore:SetAnchor(GUIItem.Middle, GUIItem.Center)
    marineTeamScore:SetTextAlignmentX(GUIItem.Align_Center)
    marineTeamScore:SetTextAlignmentY(GUIItem.Align_Center)
    marineTeamScore:SetPosition(GUIScale(Vector(-30, -5, 0)))
    marineTeamScore:SetColor(Color(1, 1, 1, 1))
    GUIMakeFontScale(marineTeamScore)
    scoresBackground:AddChild(marineTeamScore)
    
    alienTeamScore = GUIManager:CreateTextItem()
    alienTeamScore:SetFontName(kTimeFontName)
    alienTeamScore:SetScale(GetScaledVector() * 1.2)
    alienTeamScore:SetAnchor(GUIItem.Middle, GUIItem.Center)
    alienTeamScore:SetTextAlignmentX(GUIItem.Align_Center)
    alienTeamScore:SetTextAlignmentY(GUIItem.Align_Center)
    alienTeamScore:SetPosition(GUIScale(Vector(30, -5, 0)))
    alienTeamScore:SetColor(Color(1, 1, 1, 1))
    GUIMakeFontScale(alienTeamScore)
    scoresBackground:AddChild(alienTeamScore)
    
    marineTeamName = GUIManager:CreateTextItem()
    marineTeamName:SetFontName(kMarineFontName)
    marineTeamName:SetScale(GetScaledVector())
    marineTeamName:SetAnchor(GUIItem.Middle, GUIItem.Center)
    marineTeamName:SetTextAlignmentX(GUIItem.Align_Max)
    marineTeamName:SetTextAlignmentY(GUIItem.Align_Center)
    marineTeamName:SetPosition(GUIScale(Vector(-60, -7, 0)))
    marineTeamName:SetColor(Color(1, 1, 1, 1))
    GUIMakeFontScale(marineTeamName)
    scoresBackground:AddChild(marineTeamName)
    
    alienTeamName = GUIManager:CreateTextItem()
    alienTeamName:SetFontName(kAlienFontName)
    alienTeamName:SetScale(GetScaledVector())
    alienTeamName:SetAnchor(GUIItem.Middle, GUIItem.Center)
    alienTeamName:SetTextAlignmentX(GUIItem.Align_Min)
    alienTeamName:SetTextAlignmentY(GUIItem.Align_Center)
    alienTeamName:SetPosition(GUIScale(Vector(60, -7, 0)))
    alienTeamName:SetColor(Color(1, 1, 1, 1))
    GUIMakeFontScale(alienTeamName)
    scoresBackground:AddChild(alienTeamName)

    teamsSwapButton = CreateButtonItem(scoresBackground, kButtonOffset, Color(1,1,1,0.5))
    teamsSwapButton:SetAnchor(GUIItem.Middle, GUIItem.Center)
    
    marinePlusButton = CreateButtonItem(scoresBackground, kButtonOffset + Vector(-kButtonSize.x,-kButtonSize.y,0), Color(0,1,0,0.5))
    marinePlusButton:SetAnchor(GUIItem.Middle, GUIItem.Center)
    
    alienPlusButton = CreateButtonItem(scoresBackground, kButtonOffset + Vector(kButtonSize.x,-kButtonSize.y,0), Color(0,1,0,0.5))
    alienPlusButton:SetAnchor(GUIItem.Middle, GUIItem.Center)
    
    marineMinusButton = CreateButtonItem(scoresBackground, kButtonOffset + Vector(-kButtonSize.x,kButtonSize.y,0), Color(1,0,0,0.5))
    marineMinusButton:SetAnchor(GUIItem.Middle, GUIItem.Center)
    
    alienMinusButton = CreateButtonItem(scoresBackground, kButtonOffset + Vector(kButtonSize.x,kButtonSize.y,0), Color(1,0,0,0.5))
    alienMinusButton:SetAnchor(GUIItem.Middle, GUIItem.Center)
        
    self:SetTeams(InsightUI_GetTeam1Name(), InsightUI_GetTeam2Name())
    self:SetScore(InsightUI_GetTeam1Score(), InsightUI_GetTeam2Score())
        
end


function GUIInsight_TopBar:Uninitialize()

    GUI.DestroyItem(background)
    background = nil

end

function GUIInsight_TopBar:OnResolutionChanged(oldX, oldY, newX, newY)

    self:Uninitialize()
    
    self:Initialize()

end

function GUIInsight_TopBar:SetIsVisible(bool)

    isVisible = bool
    background:SetIsVisible(bool)

end

function GUIInsight_TopBar:SendKeyEvent(key, down)

    if isVisible then
        local cursor = MouseTracker_GetCursorPos()
        local inBackground, posX, posY = GUIItemContainsPoint(scoresBackground, cursor.x, cursor.y)
        if inBackground then
        
            if key == InputKey.MouseButton0 and down then

                local inSwap, posX, posY = GUIItemContainsPoint(teamsSwapButton, cursor.x, cursor.y)
                if inSwap then
                    Shared.ConsoleCommand("teams swap")
                end
                local inMPlus, posX, posY = GUIItemContainsPoint(marinePlusButton, cursor.x, cursor.y)
                if inMPlus then
                    Shared.ConsoleCommand("score1 +")
                end
                local inMMinus, posX, posY = GUIItemContainsPoint(marineMinusButton, cursor.x, cursor.y)
                if inMMinus then
                    Shared.ConsoleCommand("score1 -")
                end
                local inAPlus, posX, posY = GUIItemContainsPoint(alienPlusButton, cursor.x, cursor.y)
                if inAPlus then
                    Shared.ConsoleCommand("score2 +")
                end
                local inAMinus, posX, posY = GUIItemContainsPoint(alienMinusButton, cursor.x, cursor.y)
                if inAMinus then
                    Shared.ConsoleCommand("score2 -")
                end
                --Shared.ConsoleCommand("teams reset")
                return true
                
            end
            
        end    
    
    end

    return false

end

function GUIInsight_TopBar:Update(deltaTime)
    
    PROFILE("GUIInsight_TopBar:Update")
                                              --Update every 1 second rather than 25 times per second :x
    if self.lastupdatedtime == nil or self.lastupdatetime + 1 < Shared.GetTime() then 
    local startTime = PlayerUI_GetGameStartTime()
        
    if startTime ~= 0 then
        startTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
    end

    local seconds = math.round(startTime)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    minutes = minutes - hours * 60
    seconds = seconds - minutes * 60 - hours * 3600
    

    
    local gameTimeText = string.format("%d:%02d", minutes, seconds)
    
    
        local frontTimeText = nil
        local open = false
        
        
    if not PlayerUI_GetFrontOpen() then
        local timerlength = PlayerUI_GetFrontLength()
        local NowToFront = timerlength - (Shared.GetTime() - PlayerUI_GetGameStartTime())
        local FrontLength =  math.ceil( Shared.GetTime() + NowToFront - Shared.GetTime() )
        frontTime = FrontLength
    local seconds = math.round(frontTime)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    minutes = minutes - hours * 60
    seconds = seconds - minutes * 60 - hours * 3600
    
     frontTimeText = string.format("FrontDoor: %d:%02d", minutes, seconds)
    else
      frontTimeText = string.format("FrontDoor: Open", minutes, seconds)
      open = true
     end


        local siegeTimeText = nil
      if siegeTime ~= 0 then  
          if open then
           local timerlength = PlayerUI_GetSiegeLength()
           local NowToSiege = timerlength - (Shared.GetTime() - PlayerUI_GetGameStartTime())
           local SiegeLength =  math.ceil( Shared.GetTime() + NowToSiege - Shared.GetTime() )
           siegeTime = SiegeLength
           local seconds = math.round(siegeTime)
           local minutes = math.floor(seconds / 60)
           local hours = math.floor(minutes / 60)
           minutes = minutes - hours * 60
           seconds = seconds - minutes * 60 - hours * 3600
          siegeTimeText = string.format("SiegeDoor: %d:%02d", minutes, seconds)
        else
       siegeTimeText = string.format("SiegeDoor: 25:00")
       end
     else
       siegeTimeText = string.format("SiegeDoor: Open")
      end

    gameTime:SetText(gameTimeText)
    siegeDoor:SetText(siegeTimeText)
    frontDoor:SetText(frontTimeText)


    self.lastupdatetime = Shared.GetTime()
    
    end
   
    local cursor = MouseTracker_GetCursorPos()
    local inBackground, posX, posY = GUIItemContainsPoint(scoresBackground, cursor.x, cursor.y)
    teamsSwapButton:SetIsVisible(inBackground)
    marinePlusButton:SetIsVisible(inBackground)
    marineMinusButton:SetIsVisible(inBackground)
    alienPlusButton:SetIsVisible(inBackground)
    alienMinusButton:SetIsVisible(inBackground)

end

function GUIInsight_TopBar:SetTeams(team1Name, team2Name)

    if team1Name == nil and team2Name == nil then
    
        scoresBackground:SetIsVisible(false)
            
    else

        scoresBackground:SetIsVisible(true)
        if team1Name == nil then
            alienTeamName:SetText(team2Name)
        elseif team2Name == nil then
            marineTeamName:SetText(team1Name)
        else        
            marineTeamName:SetText(team1Name)
            alienTeamName:SetText(team2Name)
        end
        
    end
    
end

function GUIInsight_TopBar:SetScore(team1Score, team2Score)

    marineTeamScore:SetText(tostring(team1Score))
    alienTeamScore:SetText(tostring(team2Score))

end
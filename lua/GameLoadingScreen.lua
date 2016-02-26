
Script.Load("lua/Utility.lua")
Script.Load("lua/GUIAssets.lua")
Script.Load("lua/GUIUtility.lua")
Script.Load("lua/Table.lua")

kFontAgencyFB_Large = PrecacheAsset("fonts/AgencyFB_large_bold.fnt")
kIntroScreen = "screens/IntroScreen.jpg"
kSpinner = PrecacheAsset("ui/loading/spinner.dds")

local spinner = nil
local statusText = nil
local statusTextShadow = nil
local dotsText = nil
local dotsTextShadow = nil

function OnUpdateRender()
  
    local spinnerSpeed  = 2
    local dotsSpeed     = 0.5
    local maxDots       = 4
    
    local time = Shared.GetTime()

    if spinner ~= nil then
        local angle = -time * spinnerSpeed
        spinner:SetRotation( Vector(0, 0, angle) )
    end
    
    if statusText ~= nil then
        
        text = Locale.ResolveString("LOADING_2")        
        statusText:SetText(text)
        statusTextShadow:SetText(text)
        
        // Add animated dots to the text.
        local numDots = math.floor(time / dotsSpeed) % (maxDots + 1)
        dotsText:SetText(string.rep(".", numDots))
        dotsTextShadow:SetText(string.rep(".", numDots))
        
    end
    
    
end

function OnLoadComplete(main)

    // Make the mouse visible so that the user can alt-tab out in Windowed mode.
    Client.SetMouseVisible(true)
    Client.SetMouseClipped(false)

    local backgroundAspect = 16.0/9.0

    local ySize = Client.GetScreenHeight()
    local xSize = ySize * backgroundAspect
    
    bgSize = Vector( xSize, ySize, 0 )
    bgPos = Vector( (Client.GetScreenWidth() - xSize) / 2, (Client.GetScreenHeight() - ySize) / 2, 0 ) 
    
    loadscreen = GUI.CreateItem()
    loadscreen:SetSize( bgSize )
    loadscreen:SetPosition( bgPos )
    loadscreen:SetTexture( kIntroScreen )
    
    local spinnerSize   = GUIScale(192)
    local spinnerOffset = GUIScale(50)

    spinner = GUI.CreateItem()
    spinner:SetTexture( kSpinner )
    spinner:SetSize( Vector( spinnerSize, spinnerSize, 0 ) )
    spinner:SetPosition( Vector( Client.GetScreenWidth() - spinnerSize - spinnerOffset, Client.GetScreenHeight() - spinnerSize - spinnerOffset, 0 ) )
    spinner:SetBlendTechnique( GUIItem.Add )
    spinner:SetLayer(3)
   
    local statusOffset = GUIScale(5)
    local shadowOffset = 2

    statusTextShadow = GUI.CreateItem()
    statusTextShadow:SetOptionFlag(GUIItem.ManageRender)
    statusTextShadow:SetPosition( Vector( Client.GetScreenWidth() - spinnerSize - spinnerOffset - statusOffset+shadowOffset, Client.GetScreenHeight() - spinnerSize / 2 - spinnerOffset+shadowOffset, 0 ) )
    statusTextShadow:SetTextAlignmentX(GUIItem.Align_Max)
    statusTextShadow:SetTextAlignmentY(GUIItem.Align_Center)
    statusTextShadow:SetFontName(kFontAgencyFB_Large)
    statusTextShadow:SetColor(Color(0,0,0,1))
    statusTextShadow:SetScale(GetScaledVector())
    GUIMakeFontScale(statusTextShadow)
    statusTextShadow:SetLayer(3)
        
    statusText = GUI.CreateItem()
    statusText:SetOptionFlag(GUIItem.ManageRender)
    statusText:SetPosition( Vector( Client.GetScreenWidth() - spinnerSize - spinnerOffset - statusOffset, Client.GetScreenHeight() - spinnerSize / 2 - spinnerOffset, 0 ) )
    statusText:SetTextAlignmentX(GUIItem.Align_Max)
    statusText:SetTextAlignmentY(GUIItem.Align_Center)
    statusText:SetFontName(kFontAgencyFB_Large)
    statusText:SetScale(GetScaledVector())
    GUIMakeFontScale(statusText)
    statusText:SetLayer(3) 
    
    
    dotsTextShadow = GUI.CreateItem()
    dotsTextShadow:SetOptionFlag(GUIItem.ManageRender)
    dotsTextShadow:SetPosition( Vector( Client.GetScreenWidth() - spinnerSize - spinnerOffset - statusOffset+shadowOffset, Client.GetScreenHeight() - spinnerSize / 2 - spinnerOffset+shadowOffset, 0 ) )
    dotsTextShadow:SetTextAlignmentX(GUIItem.Align_Min)
    dotsTextShadow:SetTextAlignmentY(GUIItem.Align_Center)
    dotsTextShadow:SetFontName(kFontAgencyFB_Large)
    dotsTextShadow:SetColor(Color(0,0,0,1))
    dotsTextShadow:SetScale(GetScaledVector())
    GUIMakeFontScale(dotsTextShadow)
    dotsTextShadow:SetLayer(3)
    
    dotsText = GUI.CreateItem()
    dotsText:SetOptionFlag(GUIItem.ManageRender)
    dotsText:SetPosition( Vector( Client.GetScreenWidth() - spinnerSize - spinnerOffset - statusOffset, Client.GetScreenHeight() - spinnerSize / 2 - spinnerOffset, 0 ) )
    dotsText:SetTextAlignmentX(GUIItem.Align_Min)
    dotsText:SetTextAlignmentY(GUIItem.Align_Center)
    dotsText:SetFontName(kFontAgencyFB_Large)
    dotsText:SetScale(GetScaledVector())
    GUIMakeFontScale(dotsText)
    dotsText:SetLayer(3)
    
end

Event.Hook("LoadComplete", OnLoadComplete)
Event.Hook("UpdateRender", OnUpdateRender)

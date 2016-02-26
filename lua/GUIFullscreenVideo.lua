// ======= Copyright (c) 2016, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUIFullscreenVideo.lua
//
// Written by Trevor Harris (trevor@naturalselection2.com)
//
// Adopted from GUITipVideo.lua, this is intended to play the tutorial intro video
// in full screen, right before a player begins the tutorial.  Theoretically could
// be used to play any full screen video... did someone say singleplayer content?
// (can we just have a dump truck full of money now?)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class "GUIFullscreenVideo" (GUIScript)

local kTextureName = "*fullscreen_video_webview_texture"
local kBlankUrl = "temptemp"
local kFullscreenViewURL = "file:///ns2/web/client_game/fullscreenvideo_widget_html5.html"

local mouseVis = true

local oldSoundVolume = nil
local oldMusicVolume = nil
local oldVoiceVolume = nil

local function CalculatePositioning()
    
    // Calculate exact width and height, preserving 16:9 aspect ratio of video
    // via letterboxing or pillarboxing, as appropriate
    
    local videoX = 1920
    local videoY = 1080
    local clientX = Client.GetScreenWidth()
    local clientY = Client.GetScreenHeight()
    
    local videoAspect = videoX/videoY
    local clientAspect = clientX/clientY
    
    local offsetX = 0
    local offsetY = 0
    local sizeX = 1920
    local sizeY = 1080
    
    if videoAspect == clientAspect then
        sizeX = clientX
        sizeY = clientY
    elseif videoAspect > clientAspect then
        //letterbox
        sizeX = clientX
        sizeY = clientX / videoAspect
        offsetX = 0
        offsetY = (clientY - sizeY) / 2
    else
        //pillarbox
        sizeX = clientY * videoAspect
        sizeY = clientY
        offsetX = (clientX - sizeX) / 2
        offsetY = 0
    end
    
    return offsetX, offsetY, sizeX, sizeY
    
end

function GUIFullscreenVideo:Initialize()
    GUIScript:Initialize()
    
    local offsetX = 0
    local offsetY = 0
    local sizeX = 1920
    local sizeY = 1080
    
    offsetX, offsetY, sizeX, sizeY = CalculatePositioning()
    
    self.video = GUI.CreateItem()
    self.video:SetColor( Color(1.0, 1.0, 1.0, 1.0) )
    self.video:SetInheritsParentAlpha( true )
    self.video:SetPosition(Vector(offsetX, offsetY, 0))
    self.video:SetSize(Vector(sizeX, sizeY, 0))
    self.video:SetTexture( kTextureName )
    self.videoWebView = Client.CreateWebView( Client.GetScreenWidth(), Client.GetScreenHeight() )
    self.videoWebView:SetTargetTexture( kTextureName )
    
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetColor( Color( 0.0, 0.0, 0.0, 1.0 ) )
    self.background:SetPosition(Vector(0,0,0))
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.background:SetInheritsParentAlpha( true )
    
    self.widget = GUIManager:CreateGraphicItem()
    self.widget:SetColor( Color( 1.0, 1.0, 1.0, 1.0 ))
    self.widget:SetPosition(Vector(0,0,0))
    self.widget:SetSize( Vector(0,0,0))
    self.widget:SetLayer(kGUILayerTipVideos) //may need to go higher...
    self.widget:AddChild(self.background)
    self.widget:AddChild(self.video)
    //subtitles?
    self.widget:SetIsVisible(false)
    
    self.state = "hidden"
    self.videoWebView:SetIsVisible(false)
    
end

function GUIFullscreenVideo:PlayVideo(videoFile, videoLength, onEndFunc)
    mouseVis = Client.GetMouseVisible()
    Client.SetMouseVisible(false)
    
    self.videoFile = videoFile
    self.length = videoLength
    self.onEndFunc = onEndFunc
    
    gVideoPlaying = true
    
    oldSoundVolume = OptionsDialogUI_GetSoundVolume() / 100.0
    oldMusicVolume = OptionsDialogUI_GetMusicVolume() / 100.0
    oldVoiceVolume = OptionsDialogUI_GetVoiceVolume() / 100.0
    
    Client.SetSoundVolume(0)
    Client.SetMusicVolume(0)
    Client.SetVoiceVolume(0)
end

function GUIFullscreenVideo:Uninitialize()
    
    if self.widget then
        self.widget:SetIsVisible(false)
    end
    
    if self.videoWebView then
        self.videoWebView:SetIsVisible(false)
        self.videoWebView:LoadUrl(kBlankUrl)
    end
    
    if self.widget then
        GUI.DestroyItem( self.widget )
        self.widget = nil
    end
    
    if self.videoWebView then
        Client.DestroyWebView( self.videoWebView )
        self.videoWebView = nil
    end
end


function GUIFullscreenVideo:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end


function GUIFullscreenVideo:End()
    // video ended or was skipped by user
    
    // set mouse visible again if it was before video started
    Client.SetMouseVisible(mouseVis)
    
    if self.onEndFunc then
        local watchedTime = self.length - (self.endTime - Shared.GetTime())
        self.onEndFunc( watchedTime )
    end
    self:Uninitialize()
    self.state = 'destroyed'
    
    gVideoPlaying = nil
    
    Client.SetSoundVolume(oldSoundVolume)
    Client.SetMusicVolume(oldMusicVolume)
    Client.SetVoiceVolume(oldVoiceVolume)
end


function GUIFullscreenVideo:Update(dt)
    if not self.videoWebView then
        // did not init successfully
        return
    end
    
    if self.state == "hidden" then
        if self.videoFile then
            // Play video immediately
            self.videojson = 
            {
                videoUrl = self.videoFile,
                volume = oldSoundVolume,
                videoWidth = Client.GetScreenWidth(),
                videoHeight = Client.GetScreenHeight(),
            }
            self.videoWebView:LoadUrl(kFullscreenViewURL.."?"..json.encode(self.videojson))
            self.state = "loadingHtml"
        else
            Log("could not load video file!")
        end
        
    elseif self.state == "loadingHtml" then
        if self.videoWebView:GetUrlLoaded() then
            self.endTime = Shared.GetTime() + self.length
            self.state = "playing"
            self.widget:SetIsVisible(true)
            self.videoWebView:SetIsVisible(true)
        end
        
    elseif self.state == "playing" then
        if Shared.GetTime() > self.endTime then
            self:End()
        end
    end
end


function GUIFullscreenVideo:SendKeyEvent(key, down)

    if self.state == "playing" 
        and ( key == InputKey.Escape 
            or key == InputKey.Return
            or key == InputKey.Space )
    then
        self:End()
        return true
    end

    return false

end


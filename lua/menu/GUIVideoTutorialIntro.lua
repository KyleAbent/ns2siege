
Script.Load("lua/GUIFullscreenVideo.lua")

local kVideoName = "file:///ns2/tipvideos/ns2_tutorial_intro.webm"
local kVideoLength = 78

local finishFunction = nil
local finishMessageParam = nil

local videoPlayer

function GUIVideoTutorialIntro_Play(onFinishedFunction, messageParameter)

    videoPlayer = GetGUIManager():CreateGUIScript("GUIFullscreenVideo")
    
    finishFunction = onFinishedFunction
    finishMessageParam = messageParameter
    
    videoPlayer:PlayVideo(kVideoName, kVideoLength, GUIVideoTutorialIntro_End)
end

function GUIVideoTutorialIntro_End( watchedTime )
    if finishFunction then
        finishFunction(finishMessageParam, watchedTime)
    end
    GetGUIManager():DestroyGUIScript(videoPlayer)
end
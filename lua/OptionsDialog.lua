//=============================================================================
//
// lua/OptionsDialog.lua
// 
// Created by Henry Kropf and Charlie Cleveland
// Copyright 2011, Unknown Worlds Entertainment
//
//=============================================================================

Script.Load("lua/Globals.lua")

function BuildResolutionList()

    local resolutions = { }
    local numResolutions = Client.GetNumResolutions()
    
    for resolutionIndex = 1, numResolutions do
        resolutions[resolutionIndex] = Client.GetResolution(resolutionIndex)
    end

    return resolutions
    
end

/**
 * Get player nickname. Use previously set name if available, otherwise use Steam name, otherwise use "NSPlayer"
 */
function OptionsDialogUI_GetNickname()

    local playerName = Client.GetUserName()
    
    if(playerName == "") then
        playerName = kDefaultPlayerName
    end
    
    return Client.GetOptionString( kNicknameOptionsKey, playerName )
    
end

function OptionsDialogUI_GetMouseSensitivity()
    return Client.GetMouseSensitivity()
end

function OptionsDialogUI_SetMouseSensitivity(sensitivity)
    Client.SetMouseSensitivity( sensitivity  )
end

function OptionsDialogUI_GetDisplays()

    local displays = { "DEFAULT" }
    local numDisplays = Client.GetNumDisplays()
    
    for index = 1, numDisplays do
        table.insert(displays, 'DISPLAY ' .. index)
    end    
    
    return displays
    
end

function OptionsDialogUI_GetWindowModes()

    local numWindowModes = Client.GetNumWindowModes()
    local result = {}

    for index = 1, numWindowModes do
        table.insert(result, Client.GetWindowMode(index) + 1)
    end

    return result
    
end

/**
 * Get linear array of screen resolutions (strings)
 */
function OptionsDialogUI_GetScreenResolutions()

    // Determine the aspect ratio of the monitor based on the startup resolution.
    // We use this to flag modes that have the same aspect ratio.
    
    local resolution = Client.GetStartupResolution()
    local nativeAspect = resolution.xResolution / resolution.yResolution

    local resolutions = { }
    
    for resolutionIndex = 1, table.maxn(gResolutions) do
    
        local resolution = gResolutions[resolutionIndex]
        local aspect = resolution.xResolution / resolution.yResolution
        
        local resolution = string.format('%dx%d', resolution.xResolution, resolution.yResolution)
        
        if (aspect == nativeAspect) then
            resolution = resolution .. " *"
        end
        
        resolutions[resolutionIndex] = resolution
        
    end

    return resolutions
    
end

function OptionsDialogUI_GetSoundDeviceNames(deviceType)

    local numDevices = Client.GetSoundDeviceCount(deviceType)
    local deviceNames = { }
    deviceNames[1] = 'Default'
    
    for id = 1, numDevices do
        deviceNames[id + 1] = Client.GetSoundDeviceName(deviceType, id - 1) 
    end
    
    return deviceNames
    
end

/**
 * Get current index for screen res (assuming lua indexing for script convenience)
 */
function OptionsDialogUI_GetScreenResolutionsIndex()

    local xResolution = Client.GetOptionInteger( kGraphicsXResolutionOptionsKey, 1280 )
    local yResolution = Client.GetOptionInteger( kGraphicsYResolutionOptionsKey, 800 )

    for resolutionIndex = 1, table.maxn(gResolutions) do
    
        local resolution = gResolutions[resolutionIndex]
        
        if (resolution.xResolution == xResolution and resolution.yResolution == yResolution) then
            return resolutionIndex
        end
    
    end
    
    return 1

end

/**
 * Get linear array of visual detail settings (strings)
 */
function OptionsDialogUI_GetVisualDetailSettings()
    return { "LOW", "MEDIUM", "HIGH" }
end

/**
 * Get current index for detail settings (assuming lua indexing for script convenience)
 */
function OptionsDialogUI_GetVisualDetailSettingsIndex()
    return 1 + Client.GetOptionInteger(kDisplayQualityOptionsKey, 0)
end


/**
 * Get sound volume
 * 0 = min volume
 * 100 = max volume
 */
function OptionsDialogUI_GetSoundVolume()
    // Defaulting sound and music to 90% as requested by Simon on 10/26/10.
    // If too loud as a default, we can go back to 75% and 65%.
    return Client.GetOptionInteger( kSoundVolumeOptionsKey, 90 )
end

function OptionsDialogUI_SetSoundVolume(volume)
    Client.SetOptionInteger( kSoundVolumeOptionsKey, volume )
    Client.SetSoundVolume( volume / 100 )
end

/**
 * Get music volume
 * 0 = min volume
 * 100 = max volume
 */
function OptionsDialogUI_GetMusicVolume()
    return Client.GetOptionInteger( kMusicVolumeOptionsKey, 90 )
end

function OptionsDialogUI_SetMusicVolume(volume)
    Client.SetOptionInteger( kMusicVolumeOptionsKey, volume )
    Client.SetMusicVolume( volume / 100 )
end

function OptionsDialogUI_SetVoiceVolume(volume)
    Client.SetOptionInteger( kVoiceVolumeOptionsKey, volume )
    Client.SetVoiceVolume( volume / 100 )
end

function OptionsDialogUI_GetVoiceVolume()
    return Client.GetOptionInteger( kVoiceVolumeOptionsKey, 90 )
end


/**
 * Get all the values from the form
 * nickname - string for nick
 * mouseSens - 0 - 100
 * display - 0 - ?  index of the display to use (0 = primary)
 * screenResIdx - 1 - ? index of choice
 * visualDetailIdx - 1 - ? index of choice
 * soundVol - 0 - 100 - sound volume
 * musicVol - 0 - 100 - music volume
 * windowed - true/false run in windowed mode
 * invMouse - true/false (true == mouse is inverted)
 */
function OptionsDialogUI_SetValues(nickname, mouseSens, display, screenResIdx, visualDetailIdx, soundVol, musicVol, windowModeId, shadows, bloom, atmospherics, anisotropicFiltering, antiAliasing, invMouse, voiceVol)

    local oldName = Client.GetOptionString( kNicknameOptionsKey, Client.GetUserName() )
    Client.SetOptionString( kNicknameOptionsKey, nickname )
    if oldName ~= nickname and Client.GetIsConnected() then
        Client.SendNetworkMessage("SetName", { name = nickname }, true)
    end
    
    OptionsDialogUI_SetMouseSensitivity( mouseSens )
    
    Client.SetOptionInteger( kDisplayOptionsKey, display )
    
    // Save screen res and visual detail
    Client.SetOptionInteger( kGraphicsXResolutionOptionsKey, gResolutions[screenResIdx].xResolution )
    Client.SetOptionInteger( kGraphicsYResolutionOptionsKey, gResolutions[screenResIdx].yResolution )
    Client.SetOptionInteger( kDisplayQualityOptionsKey, visualDetailIdx - 1 )     // set the value as 0-based index

    // Save sound and music options 
    OptionsDialogUI_SetSoundVolume( soundVol )
    OptionsDialogUI_SetMusicVolume( musicVol )
    OptionsDialogUI_SetVoiceVolume( voiceVol )
    
    Client.SetOptionString ( kWindowModeOptionsKey, windowModeId )
    
    Client.SetOptionBoolean ( kShadowsOptionsKey, shadows )
    Client.SetOptionBoolean ( kBloomOptionsKey, bloom )
    Client.SetOptionBoolean ( kAtmosphericsOptionsKey, atmospherics )
    Client.SetOptionBoolean ( kAnisotropicFilteringOptionsKey, anisotropicFiltering )
    Client.SetOptionBoolean ( kAntiAliasingOptionsKey, antiAliasing )
    
    // Handle invMouse
    Client.SetOptionBoolean ( kInvertedMouseOptionsKey, invMouse )
    
end

function OptionsDialogUI_SyncSoundVolumes()

    local soundVol = OptionsDialogUI_GetSoundVolume()
    local musicVol = OptionsDialogUI_GetMusicVolume()
    local voiceVol = OptionsDialogUI_GetVoiceVolume()
    local recordingGain = Client.GetOptionFloat("recordingGain", 0.5)
    
    // Set current levels (0-1)
    Client.SetSoundVolume( soundVol/100 )
    Client.SetMusicVolume( musicVol/100 )
    Client.SetVoiceVolume( voiceVol/100 )
    Client.SetRecordingGain( recordingGain )
end

function OptionsDialogUI_OnInit()

    gResolutions = BuildResolutionList()
    
end

function OptionsDialogUI_GetDisplay()
    return Client.GetOptionInteger( kDisplayOptionsKey, 0 )
end

/**
 * Get windowed or not
 */
function OptionsDialogUI_GetWindowModeId()
    return Client.GetOptionString( kWindowModeOptionsKey, "windowed" )
end

/**
 * Get shadows or not
 */
function OptionsDialogUI_GetShadows()
    return Client.GetOptionBoolean( kShadowsOptionsKey, false )    
end

/**
 * Get shadows fading or not
 */
function OptionsDialogUI_GetShadowFading()
    return Client.GetOptionBoolean( kShadowFadingOptionsKey, false )    
end

/**
 * Get bloom or not
 */
function OptionsDialogUI_GetBloom()
    return Client.GetOptionBoolean( kBloomOptionsKey, false )    
end

/**
 * Get anisotropic filtering or not
 */
function OptionsDialogUI_GetAnisotropicFiltering()
    return Client.GetOptionBoolean( kAnisotropicFilteringOptionsKey, false )    
end

/**
 * Get atmospherics or not
 */
function OptionsDialogUI_GetAtmospherics()
    return Client.GetOptionBoolean( kAtmosphericsOptionsKey, false )    
end

/**
 * Get anti aliasing or not
 */
function OptionsDialogUI_GetAntiAliasing()
    return Client.GetOptionBoolean( kAntiAliasingOptionsKey, false )    
end

/**
 * Get mouse inversion
 */
function OptionsDialogUI_GetMouseInverted()
    return Client.GetOptionBoolean ( kInvertedMouseOptionsKey, false )
end

/**
 * Signal that the user has exited the options dialog with display options changed
 */
function OptionsDialogUI_ExitDialog()
    
    Client.ReloadGraphicsOptions()
    
end

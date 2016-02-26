//=============================================================================
//
// lua/MenuManager.lua
// 
// Created by Max McGuire (max@unknownworlds.com)
// Copyright 2012, Unknown Worlds Entertainment
//
//=============================================================================

MenuManager = { }
MenuManager.menuCinematic = nil
MenuManager.storedCinematic = nil

/**
 * Sets the cinematic that's displayed behind the main menu.
 */

function MenuManager.SetMenuCinematic(fileName, storeMenu)

    if MenuManager.menuCinematic ~= nil then
    
        Client.DestroyCinematic(MenuManager.menuCinematic)
        MenuManager.menuCinematic = nil
        storedCinematic = nil
        
    end
    
    if fileName ~= nil then
    
        MenuManager.menuCinematic = Client.CreateCinematic()
        MenuManager.menuCinematic:SetRepeatStyle(Cinematic.Repeat_Loop)
        MenuManager.menuCinematic:SetCinematic(fileName)
        if storeMenu and storeMenu == true then
            MenuManager.storedCinematic = fileName
        end
    end
    
end

function MenuManager.RestoreMenuCinematic()

    if MenuManager.menuCinematic ~= nil then
    
        Client.DestroyCinematic(MenuManager.menuCinematic)
        MenuManager.menuCinematic = nil
        
    end
    
    if MenuManager.storedCinematic ~= nil then
    
        MenuManager.menuCinematic = Client.CreateCinematic()
        MenuManager.menuCinematic:SetRepeatStyle(Cinematic.Repeat_Loop)
        MenuManager.menuCinematic:SetCinematic(MenuManager.storedCinematic)

    end
    
end


function MenuManager.GetCinematicCamera()

    // Try to get the camera from the cinematic.
    if MenuManager.menuCinematic ~= nil then
        return MenuManager.menuCinematic:GetCamera()
    else
        return false
    end
    
end

function MenuManager.PlaySound(fileName)
    StartSoundEffect(fileName)
end
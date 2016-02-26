// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIManager.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Client only.
assert(Server == nil)

Script.Load("lua/UtilityShared.lua")
Script.Load("lua/GUIAssets.lua")



kGUILayerDebugText = 0
kGUILayerDeathScreen = 1
kGUILayerChat = 3
kGUILayerPlayerNameTags = 4
kGUILayerPlayerHUDBackground = 5
kGUILayerPlayerHUD = 6
kGUILayerPlayerHUDForeground1 = 7
kGUILayerPlayerHUDForeground2 = 8
kGUILayerPlayerHUDForeground3 = 9
kGUILayerPlayerHUDForeground4 = 10
kGUILayerCommanderAlerts = 11
kGUILayerCommanderHUD = 12
kGUILayerLocationText = 13
kGUILayerMinimap = 14
kGUILayerScoreboard = 15
kGUILayerCountDown = 16
kGUILayerTestEvents = 17
kGUILayerMainMenuNews = 19
kGUILayerMainMenu = 20
kGUILayerMainMenuDialogs = 30
kGUILayerTipVideos = 60
kGUILayerOptionsTooltips = 100

// The Web layer must be much higher than the MainMenu layer
// because the MainMenu layer inserts items above
// kGUILayerMainMenu procedurally.
kGUILayerMainMenuWeb = 50

// Check required because of material scripts.
if Client and Event then

    Script.Load("lua/menu/WindowManager.lua")
    Script.Load("lua/InputHandler.lua")
    
end

Script.Load("lua/GUIScript.lua")
Script.Load("lua/GUIUtility.lua")

local function CreateManager()
    local manager = GUIManager()
    manager:Initialize()
    return manager
end

class 'GUIManager'

-- 25 Hz default update interval. Should be enough for all animations
-- to be reasonably smooth.
-- Scripts running at default update interval are also spread out by
-- the gui manager to help balancing frame time
GUIManager.kUpdateInterval = 0.04
-- used to control the update interval from the console
GUIManager.kUpdateIntervalMultipler = 1

function GUIManager:Initialize()

    self.scripts = { }
    self.scriptsSingle = { }
end

function GetGUIManager()
    return gGUIManager
end

function GUIManager:GetNumberScripts()
    return table.count(self.scripts) + table.count(self.scriptsSingle)
end



local function SharedCreate(scriptName)

    local scriptPath = scriptName

    local result = StringSplit(scriptName, "/")    
    scriptName = result[table.count(result)]
    
    local creationFunction = _G[scriptName]
    
    if not creationFunction then
    
        Script.Load("lua/" .. scriptPath .. ".lua")
        creationFunction = _G[scriptName]
        
    end
    
    if creationFunction == nil then
    
        DebugPrint("Error: Failed to load GUI script named %s", scriptName)
        return nil
        
    else
    
        local newScript = creationFunction()
        newScript._scriptName = scriptName
        newScript:Initialize()
        // set default update rate if not already set 
        if newScript.updateInterval == nil then
            newScript.updateInterval = GUIManager.kUpdateInterval
        end
        newScript.lastUpdateTime = 0
        return newScript
        
    end
    
end

function GUIManager:CreateGUIScript(scriptName)

    local createdScript = SharedCreate(scriptName)
    
    if createdScript ~= nil then
        table.insert(self.scripts, createdScript)
    end
    
    return createdScript
    
end

// Only ever create one of this named script.
// Just return the already created one if it already exists.
function GUIManager:CreateGUIScriptSingle(scriptName)
    
    // Check if it already exists
    for index, script in ipairs(self.scriptsSingle) do
    
        if script[2] == scriptName then
            return script[1]
        end
        
    end
    
    // Not found, create the single instance.
    local createdScript = SharedCreate(scriptName)
    
    if createdScript ~= nil then
    
        table.insert(self.scriptsSingle, { createdScript, scriptName })
        return createdScript
        
    end
    
    return nil
    
end

function GUIManager:SetHUDMapEnabled(enabled)

    for index, script in ipairs(self.scripts) do
    
        if script.SetHUDMapEnabled then
            script:SetHUDMapEnabled(enabled)
        end
    
    end
    
    for index, scriptSingle in ipairs(self.scriptsSingle) do
    
        if scriptSingle.SetHUDMapEnabled then
            scriptSingle:SetHUDMapEnabled(enabled)
        end
    
    end

end

function GUIManager:DestroyGUIScript(scriptInstance)

    // Only uninitialize it if the manager has a reference to it.
    local success = false
    if table.removevalue(self.scripts, scriptInstance) then
    
        scriptInstance:Uninitialize()
        success = true
        
    end
    
    return success

end

// Destroy a previously created single named script.
// Nothing will happen if it hasn't been created yet.
function GUIManager:DestroyGUIScriptSingle(scriptName)

    local success = false
    for index, script in ipairs(self.scriptsSingle) do
    
        if script[2] == scriptName then
        
            if table.removevalue(self.scriptsSingle, script) then
            
                script[1]:Uninitialize()
                success = true
                break
                
            end
            
        end
        
    end
    
    return success
    
end

function GUIManager:GetGUIScriptSingle(scriptName)

    for index, script in ipairs(self.scriptsSingle) do
    
        if script[2] == scriptName then
            return script[1]
        end
        
    end
    
    return nil

end

function GUIManager:NotifyGUIItemDestroyed(destroyedItem)

    if gDebugGUI then

        for index, script in ipairs(self.scripts) do
            script:NotifyGUIItemDestroyed(destroyedItem)
        end
        
        for index, script in ipairs(self.scriptsSingle) do
            script[1]:NotifyGUIItemDestroyed(destroyedItem)
        end
    
    end

end

function GUIManager:Update(deltaTime)

    PROFILE("GUIManager:Update")
    
    if gDebugGUI then
        Client.ScreenMessage(gDebugGUIMessage)
    end
    
    // Backwards iteration in case Update() causes a script to be removed.

    local numScripts = #self.scripts
    local allowedUpdatesForDefaultUpdateInterval = deltaTime * numScripts / (GUIManager.kUpdateIntervalMultipler * GUIManager.kUpdateInterval) 
    local numDefaultsUpdated = 0
    
    local now = Shared.GetTime()
    for s = numScripts, 1, -1 do
        local script = self.scripts[s]
        local dt = deltaTime

        if script then
            local txt = script.classname .. ", script " .. s .. ", numScripts " .. numScripts;
            Client.SetDebugText("Script  " .. txt)
            // avoid updating too many mods at default update interval
            if now > script.lastUpdateTime + (script.updateInterval or GUIManager.kUpdateInterval) * GUIManager.kUpdateIntervalMultipler then
                local isDefault = script.updateInterval == GUIManager.kUpdateInterval 
                if not isDefault or numDefaultsUpdated < allowedUpdatesForDefaultUpdateInterval then
                    numDefaultsUpdated = numDefaultsUpdated + (isDefault and 1 or 0)
                    dt = script.lastUpdateTime > 0 and now - script.lastUpdateTime or deltaTime
                    script.lastUpdateTime = now
                else
                    script = nil
                end
            else
                script = nil
            end
        else
            Client.SetDebugText("Null script " .. s .. ", numScripts " .. numScripts)
        end
    
        if script then
            // for tracking what script is running - have problems with game hanging here
            local txt = script.classname .. ", script " .. s .. ", numScripts " .. numScripts;
            Client.SetDebugText("Enter " .. txt)
            script:Update(dt)
            Client.SetDebugText("Exit  " .. txt)
        end
    
    end
  
    Client.SetDebugText("Do singleScripts")
            
    for s = #self.scriptsSingle, 1, -1 do
        self.scriptsSingle[s][1]:Update(deltaTime)
    end
    
    Client.SetDebugText("Exit GuiManager:Update")

end

function GUIManager:SendKeyEvent(key, down, amount)

    if not Shared.GetIsRunningPrediction() then

        for index, script in ipairs(self.scripts) do
        
            if script:SendKeyEvent(key, down, amount) then
                return true
            end
            
        end
        
        for index, script in ipairs(self.scriptsSingle) do
        
            if script[1]:SendKeyEvent(key, down, amount) then
                return true
            end
            
        end

    end
    
    return false
    
end

function GUIManager:SendCharacterEvent(character)

    for index, script in ipairs(self.scripts) do
    
        if script:SendCharacterEvent(character) then
            return true
        end
        
    end
    
    for index, script in ipairs(self.scriptsSingle) do
    
        if script[1]:SendCharacterEvent(character) then
            return true
        end
        
    end
    
    return false
    
end

function GUIManager:OnResolutionChanged(oldX, oldY, newX, newY)

    for index, script in ipairs(self.scripts) do
        script:OnResolutionChanged(oldX, oldY, newX, newY)
    end
    
    for index, script in ipairs(self.scriptsSingle) do
        script[1]:OnResolutionChanged(oldX, oldY, newX, newY)
    end

end

function GUIManager:CreateGraphicItem()
    return GUI.CreateItem()
end

function GUIManager:CreateTextItem()

    local item = GUI.CreateItem()

    // Text items always manage their own rendering.
    item:SetOptionFlag(GUIItem.ManageRender)

    return item

end 

function GUIManager:CreateLinesItem()

    local item = GUI.CreateItem()

    // Lines items always manage their own rendering.
    item:SetOptionFlag(GUIItem.ManageRender)

    return item
    
end

local function OnUpdateGUIManager(deltaTime)
    Client.SetDebugText("GUIManager.OnUpdateClient entry")
    if gGUIManager then
        gGUIManager:Update(deltaTime)
    end
    Client.SetDebugText("GUIManager.OnUpdateClient exit")
end

local function OnResolutionChanged(oldX, oldY, newX, newY)
    GetGUIManager():OnResolutionChanged(oldX, oldY, newX, newY)
end
function OnChangeHudUpdateRate(mul)
    if Client then
        if mul then
            GUIManager.kUpdateIntervalMultipler = Clamp(tonumber(mul), 0.001, 5)
        end
        Log("Hud update interval multiplier: %s", GUIManager.kUpdateIntervalMultipler)
    end
end


// check required because of material scripts
if Event then

    Event.Hook("Console_hud_rate", OnChangeHudUpdateRate)
    Event.Hook("UpdateClient", OnUpdateGUIManager, "GUIManager")
    Event.Hook("ResolutionChanged", OnResolutionChanged)

    gGUIManager = gGUIManager or CreateManager()

    local function OnCommandDumbGUIScripts(enabled)
        
        local guiManager = GetGUIManager()
        
        local scriptsCount = {}
        for s = #guiManager.scripts, 1, -1 do
            
            local script = guiManager.scripts[s]
            local count = scriptsCount[script._scriptName]
            
            scriptsCount[script._scriptName] = count ~= nil and count + 1 or 1
            
        end
        
        for s = #guiManager.scriptsSingle, 1, -1 do
            
            local script = guiManager.scriptsSingle[s]
            local count = scriptsCount[script._scriptName]
            
            scriptsCount[script._scriptName] = count ~= nil and count + 1 or 1
            
        end
        
        Print("script dump ----------------------")
        for name, count in pairs(scriptsCount) do
            Print("%s: %d", name, count)
        end
        Print("s------------------------------------")
        
        
    end
    Event.Hook("Console_dumpguiscripts", OnCommandDumbGUIScripts)

end

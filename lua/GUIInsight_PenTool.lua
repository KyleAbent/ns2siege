// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIInsight_PenTool.lua
//
// Created by: Jon Hughes (jon@jhuze.com)
//
// Allows the spectator to draw on the screen
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIInsight_PenTool' (GUIScript)

local lineColors
local screenLines
local lastMouse

function GUIInsight_PenTool:Initialize()

    lineColors = table.array(8)
    
    screenLines = GUIManager:CreateLinesItem()
    screenLines:SetLayer(kGUILayerCountDown)
    
    self.isDrawing = false
    self.hasDrawn = false
    
end

function GUIInsight_PenTool:Uninitialize()
    
    GUI.DestroyItem(screenLines)
    
end

function GUIInsight_PenTool:SetIsVisible(visible)

    screenLines:SetIsVisible(visible)
    
end

function GUIInsight_PenTool:SendKeyEvent(key, down)

    if down then
        if GetIsBinding(key, "Reload") and self.hasDrawn then
            self.hasDrawn = false
            lineColors = table.array(8)
            screenLines:ClearLines()
            return true
        end
    
        if GetIsBinding(key, "SecondaryAttack") then
            self.isDrawing = true
            return false
        end
    else
        lastMouse = nil
    end
    
    self.isDrawing = false
    return false

end

function GUIInsight_PenTool:Update(deltaTime)
  
    PROFILE("GUIInsight_PenTool:Update")
    
    if self.isDrawing then
        local mouseX, mouseY = Client.GetCursorPosScreen()
        local mouse = Vector(mouseX, mouseY, 0)
        if lastMouse then

            if mouse ~= lastMouse then
            
                self.hasDrawn = true
                screenLines:AddLine(lastMouse, mouse, kPenToolColor)
            
            end
            
        end
        lastMouse = mouse
    end
    
end

function GUIInsight_PenTool:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end
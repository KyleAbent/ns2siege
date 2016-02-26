// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIPropNames.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages text that is drawn in the world to annotate maps.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/dkjson.lua")
Script.Load("lua/Globals.lua")

class 'GUIPropNames' (GUIScript)

GUIPropNames.kMaxDisplayDistance = 10

function GUIPropNames:Initialize()

    self.visible = false
    self.annotations = { }
    self.getLatestAnnotationsTime = 0

end

function GUIPropNames:Uninitialize()
    self:ClearPropNames()
    self:SetIsVisible(false)
end

function GUIPropNames:ClearPropNames()

    for i, annotation in ipairs(self.annotations) do
        GUI.DestroyItem(annotation.Item)
    end
    self.annotations = { }
    self:SetIsVisible(false)
end

function GUIPropNames:SetIsVisible(setVisible)
    self.visible = setVisible
end

function GUIPropNames:GetIsVisible()
    return self.visible
end

function GUIPropNames:AddAnnotation(text, worldOrigin)

    local annotationItem = { Item = GUIManager:CreateTextItem(), Origin = Vector(worldOrigin) }
    annotationItem.Item:SetLayer(kGUILayerDebugText)
    annotationItem.Item:SetFontName("fonts/AgencyFB_tiny.fnt")
    annotationItem.Item:SetAnchor(GUIItem.Left, GUIItem.Top)
    annotationItem.Item:SetTextAlignmentX(GUIItem.Align_Center)
    annotationItem.Item:SetTextAlignmentY(GUIItem.Align_Center)
    annotationItem.Item:SetColor(Color(0.5, 0.75, 1, 1))
    annotationItem.Item:SetText(text)
    annotationItem.Item:SetIsVisible(true)
    table.insert(self.annotations, annotationItem)
    
end

function GUIPropNames:Update(deltaTime)

    PROFILE("GUIPropNames:Update")

    for i, annotation in ipairs(self.annotations) do
    
        if self.visible then
        
            self.updateInterval = kUpdateIntervalFull
        
            // Set position according to position/orientation of local player.
            local screenPos = Client.WorldToScreen(Vector(annotation.Origin.x, annotation.Origin.y, annotation.Origin.z))
            
            local playerOrigin = PlayerUI_GetEyePos()
            local direction = annotation.Origin - playerOrigin
            local normToAnnotationVec = GetNormalizedVector(direction)
            local normViewVec = PlayerUI_GetForwardNormal()
            local dotProduct = normToAnnotationVec:DotProduct(normViewVec)
            
            local visible = true
            
            if screenPos.x < 0 or screenPos.x > Client.GetScreenWidth() or
               screenPos.y < 0 or screenPos.y > Client.GetScreenHeight() or
               dotProduct < 0 then
               
                visible = false
                
            else
                annotation.Item:SetPosition(screenPos)
            end
            
            // Fade based on distance.
            local fadeAmount = (direction:GetLengthSquared()) / (GUIPropNames.kMaxDisplayDistance * GUIPropNames.kMaxDisplayDistance)
            if fadeAmount < 1 then
                //annotation.Item:SetColor(Color(0, 0.75, 1, 1 - fadeAmount))
            else
                visible = false
            end
            
            annotation.Item:SetIsVisible(visible)
            
        else
            self.updateInterval = kUpdateIntervalLow
        end
        
    end
    
end

function GUIPropNames:DisplayPropNames()

    local props = Client.propList
    if props ~= nil then
       for index, models in ipairs(Client.propList) do
            local model = models[1]
            local coords = model:GetCoords()
            self:AddAnnotation(ToString(model.model), Vector(coords.origin.x, coords.origin.y, coords.origin.z))
            self:SetIsVisible(true)
        end
    end
    
end
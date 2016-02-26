// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\graphs\ComparisonBarGraph.lua
//
// Created by: Jon Hughes (jon@jhuze.com)
//
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'ComparisonBarGraph'

local textureName = "ui/comparisonbar.dds"
local textureSize = Vector(512,64,0)
local kFontName = Fonts.kAgencyFB_Medium
local kFontScale
local fontColor = Color(1,1,1,1)
local textPadding

function ComparisonBarGraph:toGameTimeString(timeInt)
    local startTime = PlayerUI_GetGameStartTime()
    if startTime ~= 0 then
        startTime = math.floor(timeInt) - startTime
    end
    local minutes = math.floor(startTime/60)
    local seconds = startTime - minutes*60
    return string.format("%d:%02d", minutes, seconds)
end

function ComparisonBarGraph:refreshText()
    if self.valuesAreTime then
        self.leftLabelItem:SetText(self:toGameTimeString(self.leftValue))
        self.rightLabelItem:SetText(self:toGameTimeString(self.rightValue))
    else
        self.leftLabelItem:SetText(tostring(self.leftValue))
        self.rightLabelItem:SetText(tostring(self.rightValue))
    end
end

function ComparisonBarGraph:refreshBar()

    local sum = self.leftValue+self.rightValue
    local fraction = 0.5
    if sum ~= 0 then
        fraction = self.leftValue/sum
    end    

    local leftSize = Vector(fraction * self.graphSize.x, self.graphSize.y, 0)
    local rightSize = Vector((1-fraction) * self.graphSize.x, self.graphSize.y, 0)
    
    local leftCoords = {0,0,fraction*textureSize.x,textureSize.y}
    local rightCoords = {fraction*textureSize.x,0,textureSize.x,textureSize.y}
    
    self.leftBar:SetTexturePixelCoordinates(unpack(leftCoords))
    self.leftBar:SetSize(leftSize)
    
    self.rightBar:SetTexturePixelCoordinates(unpack(rightCoords))
    self.rightBar:SetSize(rightSize)
    self.rightBar:SetPosition(Vector(leftSize.x, 0, 0))

end

function ComparisonBarGraph:Initialize()
    kFontScale = GUIScale(Vector(1,1,0))
    textPadding = GUIScale(Vector(15,0,0))
    
    self.graphSize = GUIScale(Vector(400,40,0))
    self.leftValue = 0
    self.rightValue = 0
    self.valuesAreTime = false

    self.graphBackground = GUIManager:CreateGraphicItem()
    self.graphBackground:SetSize(self.graphSize)
    self.graphBackground:SetColor(Color(0,0,0.05,0.9))
    self.graphBackground:SetLayer(kGUILayerInsight)
    
    self.titleItem = GUIManager:CreateTextItem()
    self.titleItem:SetFontName(kFontName)
    self.titleItem:SetScale(kFontScale)
    GUIMakeFontScale(self.titleItem)
    self.titleItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.titleItem:SetTextAlignmentX(GUIItem.Align_Center)
    self.titleItem:SetTextAlignmentY(GUIItem.Align_Max)
    self.titleItem:SetColor(fontColor)
    self.graphBackground:AddChild(self.titleItem)
    
    self.leftLabelItem = GUIManager:CreateTextItem()
    self.leftLabelItem:SetFontName(kFontName)
    self.leftLabelItem:SetScale(kFontScale)
    GUIMakeFontScale(self.leftLabelItem)
    self.leftLabelItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.leftLabelItem:SetTextAlignmentX(GUIItem.Align_Max)
    self.leftLabelItem:SetTextAlignmentY(GUIItem.Align_Center)
    self.leftLabelItem:SetPosition(-textPadding)
    self.leftLabelItem:SetColor(fontColor)
    self.graphBackground:AddChild(self.leftLabelItem)
    
    self.rightLabelItem = GUIManager:CreateTextItem()
    self.rightLabelItem:SetFontName(kFontName)
    self.rightLabelItem:SetScale(kFontScale)
    GUIMakeFontScale(self.rightLabelItem)
    self.rightLabelItem:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.rightLabelItem:SetTextAlignmentX(GUIItem.Align_Min)
    self.rightLabelItem:SetTextAlignmentY(GUIItem.Align_Center)
    self.rightLabelItem:SetPosition(textPadding)
    self.rightLabelItem:SetColor(fontColor)
    self.graphBackground:AddChild(self.rightLabelItem)
    
    self.leftBar = GUIManager:CreateGraphicItem()
    self.leftBar:SetTexture(textureName)
    self.leftBar:SetColor(kBlueColor)
    self.graphBackground:AddChild(self.leftBar)
    
    self.rightBar = GUIManager:CreateGraphicItem()
    self.rightBar:SetTexture(textureName)
    self.rightBar:SetColor(kRedColor)
    self.graphBackground:AddChild(self.rightBar)
    
    self:refreshBar()
    self:refreshText()
    
end
function ComparisonBarGraph:GiveParent(p)
    p:AddChild(self.graphBackground)
end
function ComparisonBarGraph:SetIsVisible(b)
    self.graphBackground:SetIsVisible(b)
end
function ComparisonBarGraph:Destroy()
    GUI.DestroyItem(self.graphBackground)
end
function ComparisonBarGraph:SetPosition(p)
    self.graphBackground:SetPosition(p)
end
function ComparisonBarGraph:SetAnchor(x,y)
    self.graphBackground:SetAnchor(x,y)
end
function ComparisonBarGraph:SetSize(s)
    self.graphSize = s
    self.graphBackground:SetSize(self.graphSize)
    self:refreshBar()
end
function ComparisonBarGraph:SetTitle(t)
    self.titleItem:SetText(t)
end
function ComparisonBarGraph:SetValues(l,r)
    if self.leftValue ~= l or self.rightValue ~= r then
        self.leftValue = l
        self.rightValue = r
        self:refreshText()
        self:refreshBar()
    end
end
function ComparisonBarGraph:SetColors(l,r)
    self.leftBar:SetColor(l)
    self.rightBar:SetColor(r)
end
function LineGraph:SetValuesAreTime(bool)
    self.valuesAreTime = bool
    self:refreshText()
end
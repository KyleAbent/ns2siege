// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CystGhostModel.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Hud/Commander/GhostModel.lua")

class 'CystGhostModel' (GhostModel)

local kLineTexture = "ui/order_line.dds"

local kLineTextureCoord = { 0, 0, 32, 16}
local kLineColor = Color(kAlienTeamColorFloat.r, kAlienTeamColorFloat.g, kAlienTeamColorFloat.b, 0.5)
local kLineDisconnectedColor = Color(1, 0.35, 0, 0.5)

local kResourceIconTextureCoordinates = { 192, 363, 240, 411 }

local kResourceTextures =
{
    [kMarineTeamType] = "ui/marine_commander_textures.dds",
    [kAlienTeamType] = "ui/alien_commander_textures.dds"
}

local kTextName = Fonts.kAgencyFB_Small

local function CreateCostDisplay()

    local frame = GUI.CreateItem()
    frame:SetColor(Color(0,0,0,0.0))
    frame:SetSize(GUIScale(Vector(90, 130, 0)))

    local resIcon = GUI.CreateItem()
    resIcon:SetTexture(kResourceTextures[PlayerUI_GetTeamType()])
    resIcon:SetAnchor(GUIItem.Right, GUIItem.Top)
    resIcon:SetSize(GUIScale(Vector(40, 40, 0)))
    resIcon:SetTexturePixelCoordinates(unpack(kResourceIconTextureCoordinates))   
    
    local resText = GUI.CreateItem()
    resText:SetOptionFlag(GUIItem.ManageRender)
    resText:SetAnchor(GUIItem.Right, GUIItem.Top)
    resText:SetPosition(Vector(0, GUIScale(20), 0))
    resText:SetTextAlignmentX(GUIItem.Align_Max)
    resText:SetTextAlignmentY(GUIItem.Align_Center)
    resText:SetFontName(kTextName)
    resText:SetScale(GetScaledVector())
    GUIMakeFontScale(resText)
    
    frame:AddChild(resIcon)
    frame:AddChild(resText)
    
    return { Frame = frame, Icon = resIcon, Text = resText }

end

local function DestroyCostDisplay(table)
    GUI.DestroyItem(table.Frame)
end

function CystGhostModel:Initialize()

    self.isVisible = true

    GhostModel.Initialize(self)
    
    self.lines = {}
    self.cystModels = {}
    
    if not self.costDisplay then        
        self.costDisplay = CreateCostDisplay()        
    end
    
end

function CystGhostModel:Destroy() 

    GhostModel.Destroy(self)
    
    for i = 1, #self.lines do
        GUI.DestroyItem(self.lines[i])
    end
    
    self.lines = {}    
    
    for i = 1, #self.cystModels do
        Client.DestroyRenderModel(self.cystModels[i])    
    end
    
    self.cystModels = {}
    
    if self.costDisplay then
        DestroyCostDisplay(self.costDisplay)
        self.costDisplay = nil
    end
    
end

function CystGhostModel:SetIsVisible(isVisible)

    self.isVisible = isVisible

    GhostModel.SetIsVisible(self, isVisible)
    
    for i = 1, #self.lines do
        self.lines[i]:SetIsVisible(isVisible)
    end
    
    for i = 1, #self.cystModels do
        self.cystModels[i]:SetIsVisible(isVisible)
    end
    
    if self.costDisplay then
        self.costDisplay.Frame:SetIsVisible(isVisible)
    end
    
end

local function CreateLine()

    local line = GUI.CreateItem()
    line:SetTexture(kLineTexture)
    
    return line

end

local function UpdateLine(startPoint, endPoint, guiItem, connected)

    local direction = GetNormalizedVector(startPoint - endPoint)
    local rotation = math.atan2(direction.x, direction.y)
    if rotation < 0 then
        rotation = rotation + math.pi * 2
    end

    rotation = rotation + math.pi * 0.5

    local rotationVec = Vector(0, 0, rotation)
    
    local delta = endPoint - startPoint
    local length = math.sqrt(delta.x ^ 2 + delta.y ^ 2)
    
    guiItem:SetSize(Vector(length, GUIScale(10), 0))
    guiItem:SetPosition(startPoint)
    guiItem:SetRotationOffset(Vector(-length, 0, 0))
    guiItem:SetRotation(rotationVec)
    
    local animation = (Shared.GetTime() % 1) / 1
    
    local x1Coord = kLineTextureCoord[1] - animation * (kLineTextureCoord[3] - kLineTextureCoord[1])
    local x2Coord = x1Coord + length
    
    guiItem:SetTexturePixelCoordinates(x1Coord, kLineTextureCoord[2], x2Coord, kLineTextureCoord[4])
    
    if connected then
        guiItem:SetColor(kLineColor)
    else
        guiItem:SetColor(kLineDisconnectedColor)
    end
    
end

local function UpdateConnectionLines(self, cystPoints, connected)

    local numCurrentLines = #self.lines
    local numNewLines = math.max(0, #cystPoints - 1)
    
    if numNewLines <= 1 then
        numNewLines = 0
    end    
    
    if numCurrentLines < numNewLines then
    
        for i = 1, numNewLines - numCurrentLines do
            table.insert(self.lines, CreateLine())
        end
    
    elseif numCurrentLines > numNewLines then
    
        for i = 1, numCurrentLines - numNewLines do
            
            local lastIndex = #self.lines
            GUI.DestroyItem(self.lines[lastIndex])
            table.remove(self.lines, lastIndex)
            
        end
    
    end
    
    for i = 1, numNewLines do
    
        local startPoint = GetClampedScreenPosition(cystPoints[i], -300)
        local endPoint = GetClampedScreenPosition(cystPoints[i + 1], -300)
    
        UpdateLine(startPoint, endPoint, self.lines[i], connected)
        
    end

end

local function CreateCystModel(self)

    local model = Client.CreateRenderModel(RenderScene.Zone_Default) 
    model:SetModel(self.loadedModelIndex)
    model:AddMaterial(self.renderMaterial)
    
    return model

end

local function UpdateCystModels(self, cystPoints)

    if self.loadedModelIndex then
    
        local numCurrentCystModel = #self.cystModels
        local numDesiredCystModels = math.max(0, #cystPoints - 2)
    
        if numCurrentCystModel < numDesiredCystModels then
        
            for i = 1, numDesiredCystModels - numCurrentCystModel do
                table.insert(self.cystModels, CreateCystModel(self))
            end
        
        elseif numDesiredCystModels < numCurrentCystModel then
        
            for i = 1, numCurrentCystModel - numDesiredCystModels do
            
                local lastIndex = #self.cystModels
                Client.DestroyRenderModel(self.cystModels[lastIndex])
                table.remove(self.cystModels, lastIndex)
            
            end
        
        end
        
        for i = 2, #cystPoints - 1 do
        
            local point = cystPoints[i]
            local model = self.cystModels[i - 1]
            
            model:SetCoords(Coords.GetTranslation(point))
        
        end
        
        if #cystPoints > 0 then
        
            local player = Client.GetLocalPlayer()
            local lastcyst = Coords.GetTranslation(cystPoints[#cystPoints])
            
            player:AddGhostGuide(Vector(lastcyst.origin), kInfestationRadius)
            
        end
    
    end

end

function CystGhostModel:Update()

    local modelCoords = GhostModel.Update(self)
    
    local cystPoints = {}
    local parent = nil
    local normals = {}
    
    if modelCoords then        
        
        local player = Client.GetLocalPlayer()
        
        player:DestroyGhostGuides(true)
        
        cystPoints, parent, normals = GetCystPoints(modelCoords.origin)
        
        // use the last cyst point for the main ghost model
        if #cystPoints > 1 then
            self.renderModel:SetCoords(Coords.GetTranslation(cystPoints[#cystPoints]))
        end
        
        if self.costDisplay then
        
            local cost = (#cystPoints - 1) * kCystCost
        
            self.costDisplay.Frame:SetPosition( Client.WorldToScreen(modelCoords.origin) - GUIScale(Vector(45, 65, 0)) )
            self.costDisplay.Text:SetText(ToString(math.max(0, cost)))
            
            self.costDisplay.Frame:SetIsVisible(cost > 0 and self.isVisible)
            
        end
        
        local redeployCysts = GetEntitiesWithinRange("Cyst", modelCoords.origin, kCystRedeployRange)
        MarkPotentialDeployedCysts(redeployCysts, modelCoords.origin)
        
    end
    
    local connected = parent ~= nil and (not parent:isa("Cyst") or parent:GetIsConnected())
    
    UpdateConnectionLines(self, cystPoints, connected)
    UpdateCystModels(self, cystPoints)
    
end

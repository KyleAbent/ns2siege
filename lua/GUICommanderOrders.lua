// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUICommanderOrders.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Manages the orders that are drawn for selected units for the Commander.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUICommanderOrders' (GUIScript)

local kIconTexture = "ui/buildmenu.dds"
local kLineTexture = "ui/order_line.dds"

local kOrderIconSize = GUIScale(Vector(48, 48, 0))
local kOrderHalfSize = kOrderIconSize * 0.5
local kOrderColor = Color(1, 1, 1, 0.7)

local kLineWidth = GUIScale(10)
local kLineTextureCoord = { 0, 0, 32, 16}

local kOrderCinematic = {
    [kMarineTeamType] = PrecacheAsset("cinematics/marine/order.cinematic"),
    [kAlienTeamType] = PrecacheAsset("cinematics/alien/order.cinematic")
}

local kOrderLineColor = {
    [kMarineTeamType] = Color(kMarineTeamColorFloat.r, kMarineTeamColorFloat.g, kMarineTeamColorFloat.b, 0.5),
    [kAlienTeamType] = Color(kAlienTeamColorFloat.r, kAlienTeamColorFloat.g, kAlienTeamColorFloat.b, 0.5)
}

function GUICommanderOrders:Initialize()

    self.updateInterval = 0
    
    self.orders = {}

end

local function CreateOrderItem(teamType)

    local orderItem = {}
    
    orderItem.Icon = GetGUIManager():CreateGraphicItem()
    orderItem.Icon:SetTexture(kIconTexture)
    orderItem.Icon:SetSize(kOrderIconSize)
    orderItem.Icon:SetColor(kOrderColor)
    orderItem.Icon:SetLayer(1)
    
    orderItem.Line = GetGUIManager():CreateGraphicItem()
    orderItem.Line:SetTexture(kLineTexture)
    orderItem.Line:SetLayer(0)
    
    orderItem.Cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
    orderItem.Cinematic:SetCinematic(kOrderCinematic[teamType])
    orderItem.Cinematic:SetRepeatStyle(Cinematic.Repeat_Loop)
    
    return orderItem

end

local function DestroyOrderItem(orderItem)
      
    GUI.DestroyItem(orderItem.Icon)
    GUI.DestroyItem(orderItem.Line)
    Client.DestroyCinematic(orderItem.Cinematic)

end

local function UpdateOrderList(orderList, numOrders, teamType)

    local currentNumOrders = #orderList

    if currentNumOrders < numOrders then
    
        for i = 1, numOrders - currentNumOrders do        
            table.insert(orderList, CreateOrderItem(teamType))        
        end
    
    elseif numOrders < currentNumOrders then
    
        for i = 1, currentNumOrders - numOrders do        

            local lastIndex = #orderList

            DestroyOrderItem(orderList[lastIndex])
            table.remove(orderList, lastIndex)
     
        end
    
    end

end

function GUICommanderOrders:Uninitialize()

    for i = 1, #self.orders do    
        DestroyOrderItem(self.orders[i])    
    end
    
    self.orders = {}

end

local function UpdateLine(startPoint, endPoint, guiItem, teamType)

    local direction = GetNormalizedVector(startPoint - endPoint)
    local rotation = math.atan2(direction.x, direction.y)
    if rotation < 0 then
        rotation = rotation + math.pi * 2
    end

    rotation = rotation + math.pi * 0.5

    local rotationVec = Vector(0, 0, rotation)
    
    local delta = endPoint - startPoint
    local length = math.sqrt(delta.x ^ 2 + delta.y ^ 2)
    
    guiItem:SetSize(Vector(length, kLineWidth, 0))
    guiItem:SetPosition(startPoint)
    guiItem:SetRotationOffset(Vector(-length, 0, 0))
    guiItem:SetRotation(rotationVec)
    
    local animation = (Shared.GetTime() % 1) / 1
    
    local x1Coord = kLineTextureCoord[1] - animation * (kLineTextureCoord[3] - kLineTextureCoord[1])
    local x2Coord = x1Coord + length
    
    guiItem:SetTexturePixelCoordinates(x1Coord, kLineTextureCoord[2], x2Coord, kLineTextureCoord[4])
    guiItem:SetColor(kOrderLineColor[teamType])

end

local function GetIsOnScreen(position)
    return position.x >= 0 and position.y >= 0 and position.x <= Client.GetScreenWidth() and position.y <= Client.GetScreenHeigth()
end

function GUICommanderOrders:Update(deltaTime)
        
    PROFILE("GUICommanderOrders:Update")
    
    local newOrders = {}

    local player = Client.GetLocalPlayer()
    local teamType = kMarineTeamType
    local prevScreenPosition = Vector()
    
    if player then

        local selectedEntities = player:GetSelection()
        local firstEntity = selectedEntities[1]
        
        if not GetAreEnemies(player, firstEntity) and HasMixin(firstEntity, "Orders") then     
            newOrders = firstEntity:GetOrdersClient()
            prevScreenPosition = GetClampedScreenPosition(firstEntity:GetOrigin(), -300)
        end
        
        teamType = player:GetTeamType()
        
    end
    
    local newOrdersNum = #newOrders
    
    UpdateOrderList(self.orders, newOrdersNum, teamType)
    
    if newOrders[1] then    
        prevScreenPosition = GetClampedScreenPosition(newOrders[1]:GetOrderSource(), -300)    
    end
    
    for i = 1, newOrdersNum do
    
        local order = newOrders[i]
        local orderItem = self.orders[i]
        
        local orderPosition = order:GetLocation()        
        local screenPosition = GetClampedScreenPosition(orderPosition, -300)

        local showLine = newOrdersNum > 1 or order:GetShowLine()
        if showLine then
        
            UpdateLine(prevScreenPosition, screenPosition, orderItem.Line, teamType)        
            orderItem.Line:SetIsVisible(true)
            
        else
            orderItem.Line:SetIsVisible(false)
        end    
    
        orderItem.Icon:SetPosition(screenPosition -  kOrderHalfSize)
        orderItem.Icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(order:GetType())))
        
        orderItem.Cinematic:SetCoords(Coords.GetTranslation(orderPosition))
        
        VectorCopy(screenPosition, prevScreenPosition)
    
    end

end
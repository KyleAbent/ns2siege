// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIWaypoints.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages waypoints displayed on the HUD to show the player where to go.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Marine_Order.lua")
Script.Load("lua/Alien_Order.lua")
Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIWaypoints' (GUIAnimatedScript)

local resolutionChanged = false

local kMarineTextureName = PrecacheAsset("ui/marine_order.dds")
local kAlienTextureName = PrecacheAsset("ui/alien_order.dds")

local kOrderbackground = PrecacheAsset("ui/order_background.dds")
local kIconTexture = "ui/buildmenu.dds"

local kOrderPixelHeight = 128
local kOrderPixelWidth = 128

local kCircleBorderTexCoords = { 0, 128, 512, 640 }
local kCircleMaxSize
local kCircleMinSize
local kCircleMaxSizeCommander
local kCircleMinSizeCommander

local kRotationDuration = 7

local kMarineTextFontName = PrecacheAsset(Fonts.kAgencyFB_Small)
local kAlienTextFontName = PrecacheAsset(Fonts.kKartika_Small)
local kTextOffset

local kDefaultSize

local kEffectInterval = 1

local kArrowModel = PrecacheAsset("models/misc/waypoint_arrow.model")
local kArrowAlienModel = PrecacheAsset("models/misc/waypoint_arrow_alien.model")
local kArrowScaleSpeed = 8
local kArrowMoveToleranceSquared = 6 * 6
// This is the closest an arrow can be to the player.
local kArrowMinDistToPlayerSquared = 3 * 3
local kArrowMinDistToTargetSquared = 1.5 * 1.5

local kArrowTexture = PrecacheAsset("ui/marinewaypoint_arrow.dds")
local kArrowSize
// Distance the 2D arrow is displayed from the screen space waypoint.
local kArrowDistance

local function TriggerCircleInAnimation(self)

    local circleMaxSize = kCircleMaxSize
    local circleMinSize = kCircleMinSize
    
    local player = Client.GetLocalPlayer()
    if player and player:isa("Commander") then
    
        circleMaxSize = kCircleMaxSizeCommander
        circleMinSize = kCircleMinSizeCommander
        
    end
    
    self.animatedCircle:DestroyAnimations()
    self.animatedCircle:SetPosition(-circleMaxSize * 0.5)
    self.animatedCircle:SetSize(circleMaxSize)
    self.animatedCircle:SetRotation(Vector(0,0,0))

    self.animatedCircle:SetSize(circleMinSize, 1, nil, AnimateQuadratic)
    self.animatedCircle:SetPosition(-circleMinSize / 2, 1, nil, AnimateQuadratic)
    
end

local function TriggerCircleOutAnimation(self)

    self.animatedCircle:DestroyAnimations()
    
    local player = Client.GetLocalPlayer()
    local isCommander = player and player:isa("Commander")
    local circleMaxSize = ConditionalValue(isCommander, kCircleMaxSizeCommander, kCircleMaxSize)
    
    self.animatedCircle:SetColor(Color(1,1,1,0), 1, nil, AnimateSqRt)
    self.animatedCircle:SetSize(circleMaxSize, 1, nil, AnimateQuadratic)
    self.animatedCircle:SetPosition(-circleMaxSize * 0.5, 1, nil, AnimateQuadratic)
    
end

local function UpdateItemsGUIScale(self)
    kCircleMaxSize = GUIScale(Vector(800, 800, 0))
    kCircleMinSize = GUIScale(Vector(100, 100, 0))
    kCircleMaxSizeCommander = GUIScale(Vector(100, 100, 0))
    kCircleMinSizeCommander = GUIScale(Vector(50, 50, 0))

    kTextOffset = GUIScale(30)
    kDefaultSize = GUIScale(128)
    kArrowSize = GUIScale(Vector(24, 24, 0))
    // Distance the 2D arrow is displayed from the screen space waypoint.
    kArrowDistance = GUIScale(80)
end

function GUIWaypoints:Initialize()

    UpdateItemsGUIScale(self)
    
    GUIAnimatedScript.Initialize(self, 0)
    
    self.nextUpdatePathTime = 0
    
    self.screenDiagonalLength = math.sqrt(Client.GetScreenHeight()/2) ^ 2 + (Client.GetScreenWidth()/2)
    
    self.finalWaypoint = GUIManager:CreateGraphicItem()
    self.finalWaypoint:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.finalWaypoint:SetColor(Color(1, 1, 1, 0.0))
    self.finalWaypoint:SetRotation(Vector(0, 0, math.pi))
    self.finalWaypoint:SetBlendTechnique(GUIItem.Add)
    self.finalWaypoint:SetTexturePixelCoordinates(0, 0, 128, 128)
    
    self.animatedCircle = self:CreateAnimatedGraphicItem()
    self.animatedCircle:SetIsScaling(false)
    self.animatedCircle:SetTexturePixelCoordinates(unpack(kCircleBorderTexCoords))
    self.animatedCircle:SetColor(Color(1, 1, 1, 0))
    self.animatedCircle:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.animatedCircle:SetBlendTechnique(GUIItem.Add)
    self.animatedCircle:AddAsChildTo(self.finalWaypoint)
    
    self.waypointDirection = GUIManager:CreateGraphicItem()
    self.waypointDirection:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.waypointDirection:SetSize(kArrowSize)
    self.waypointDirection:SetTexture(kArrowTexture)
    self.waypointDirection:SetTexturePixelCoordinates(0, kOrderPixelHeight, 0, kOrderPixelWidth)
    self.finalWaypoint:AddChild(self.waypointDirection)
    
    self.finalDistanceText = GUIManager:CreateTextItem()
    self.finalDistanceText:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.finalDistanceText:SetTextAlignmentX(GUIItem.Align_Center)
    self.finalDistanceText:SetTextAlignmentY(GUIItem.Align_Min)
    self.finalDistanceText:SetIsVisible(false)
    self.finalDistanceText:SetPosition(Vector(0, kTextOffset, 0))
    self.finalWaypoint:AddChild(self.finalDistanceText)
    
    self.finalNameText = GUIManager:CreateTextItem()
    self.finalNameText:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.finalNameText:SetTextAlignmentX(GUIItem.Align_Center)
    self.finalNameText:SetTextAlignmentY(GUIItem.Align_Min)
    self.finalNameText:SetPosition(Vector(0, kTextOffset * 1.85, 0))
    self.finalNameText:SetIsVisible(false)
    self.finalWaypoint:AddChild(self.finalNameText)
    
    self.orderIcon = GUIManager:CreateGraphicItem()
    self.orderIcon:SetBlendTechnique(GUIItem.Add)
    self.orderIcon:SetInheritsParentAlpha(true)
    self.orderIcon:SetTexture(kIconTexture)
    self.finalWaypoint:AddChild(self.orderIcon)
    
    // All arrow assets are stored here.
    self.arrows = table.array(8)
    // The arrows currently being used in the world are stored here.
    self.worldArrows = table.array(8)
    self.hideArrows = table.array(8)
    
end

local function InitMarineTexture(self)

    self.arrowModelName = kArrowModel
    self.lightColor = Color(0.2, 0.2, 1, 1)
    self.animatedCircle:SetTexture(kMarineTextureName)
    self.finalWaypoint:SetTexture(kMarineTextureName)
    
    self.finalDistanceText:SetFontName(kMarineTextFontName)
    self.finalDistanceText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.finalDistanceText)
    self.finalNameText:SetFontName(kMarineTextFontName)
    self.finalNameText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.finalNameText)
    self.orderIcon:SetColor(kIconColors[kMarineTeamType])
    
    self.waypointDirection:SetColor(Color(1, 1, 1, 1))
    self.marineWaypointLoaded = true
    
    self.usedTexture = kMarineTextureName
    
end

local function InitAlienTexture(self)

    self.arrowModelName = kArrowAlienModel
    self.lightColor = Color(1, 0.2, 0.2, 1)
    self.animatedCircle:SetTexture(kAlienTextureName)
    self.finalWaypoint:SetTexture(kAlienTextureName)
    
    self.finalDistanceText:SetFontName(kAlienTextFontName)
    self.finalDistanceText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.finalDistanceText)
    self.finalNameText:SetFontName(kAlienTextFontName)
    self.finalNameText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.finalNameText)
    self.orderIcon:SetColor(kIconColors[kAlienTeamType])
    
    self.waypointDirection:SetColor(kAlienTeamColorFloat)
    self.marineWaypointLoaded = false
    
    self.usedTexture = kAlienTextureName
    
end

function GUIWaypoints:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)
    
    if self.finalWaypoint then
    
        GUI.DestroyItem(self.finalWaypoint)
        self.finalWaypoint = nil
        
    end
    
    for a = 1, #self.arrows do
    
        Client.DestroyRenderModel(self.arrows[a].model)
        Client.DestroyRenderLight(self.arrows[a].light)
        
    end
    
    self.arrows = nil
    self.worldArrows = nil
    self.orderIcon = nil
    
end

local function FindClosestWorldArrow(self, toPoint, playerOrigin)

    local closestArrow = nil
    local closestDist = math.huge
    local closestOrigin = nil
    for a = 1, #self.worldArrows do
    
        local checkArrow = self.worldArrows[a]
        local arrowOrigin = checkArrow.model:GetCoords().origin
        local dist = (arrowOrigin - toPoint):GetLengthSquared()
        if dist < closestDist then
        
            closestArrow = checkArrow
            closestDist = dist
            closestOrigin = arrowOrigin
            
        end
        
    end
    
    
    if closestDist < kArrowMoveToleranceSquared then
        return closestArrow
    end
    
    return nil
    
end

local function GetFreeArrow(self)

    for a = 1, #self.arrows do
    
        local arrow = self.arrows[a]
        if not arrow.model:GetIsVisible() then
        
            arrow.model:SetIsVisible(false)
            arrow.light:SetIsVisible(false)
            return arrow
            
        end
        
    end
    
    local renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)
    renderModel:SetModel(self.arrowModelName)
    renderModel:SetIsVisible(false)
    
    local renderLight = Client.CreateRenderLight()
    renderLight:SetType(RenderLight.Type_Point)
    renderLight:SetCastsShadows(false)
    renderLight:SetSpecular(false)
    renderLight:SetRadius(1)
    renderLight:SetIntensity(10)
    renderLight:SetColor(self.lightColor)
    renderLight:SetIsVisible(false)
    
    local arrow = { model = renderModel, light = renderLight }
    table.insert(self.arrows, arrow)
    
    return arrow
    
end

local function UpdateWorldArrows(self, dt)

    for a = #self.worldArrows, 1, -1 do
    
        local arrow = self.worldArrows[a]
        if not arrow.inWorld then
        
            table.remove(self.worldArrows, a)
            arrow.hideAmount = 0
            arrow.hideStartCoords = arrow.model:GetCoords()
            table.insert(self.hideArrows, arrow)
            
        else
        
            if arrow.showAmount < 1 then
            
                arrow.showAmount = math.min(1, arrow.showAmount + dt * kArrowScaleSpeed)
                
                local scaledCoords = Coords(arrow.showStartCoords)
                scaledCoords:Scale(arrow.showAmount)
                arrow.model:SetCoords(scaledCoords)
                
            end
            
        end
        
    end
    
end

local function UpdateHideArrows(self, dt)

    for a = #self.hideArrows, 1, -1 do
    
        local arrow = self.hideArrows[a]
        arrow.hideAmount = math.min(1, arrow.hideAmount + dt * kArrowScaleSpeed)
        
        local scaledCoords = Coords(arrow.hideStartCoords)
        scaledCoords:Scale(1 - arrow.hideAmount)
        arrow.model:SetCoords(scaledCoords)
        
        if arrow.hideAmount == 1 then
        
            arrow.model:SetIsVisible(false)
            arrow.light:SetIsVisible(false)
            table.remove(self.hideArrows, a)
            
        end
        
    end
    
end

local function UpdatePath(self, dt)

    PROFILE("UpdatePath")

    // Assume the arrows will be removed from the world.
    for a = 1, #self.worldArrows do
        self.worldArrows[a].inWorld = false
    end
    
    self.lastGetOrderPathTime = self.lastGetOrderPathTime or 0
    local now = Shared.GetTime()
    if now - self.lastGetOrderPathTime >= 1 then
    
        self.lastGetOrderPathTime = now
        self.pathPoints = PlayerUI_GetOrderPath()
        
    end
    
    local visible = self.pathPoints ~= nil and #self.pathPoints > 1
    if visible then
    
        local targetPoint = self.pathPoints[#self.pathPoints]
        local lastPoint = PlayerUI_GetOrigin()
        local arrowDist = 0
        local totalDist = 0
        for p = 1, #self.pathPoints do
        
            local point = self.pathPoints[p]
            local direction = lastPoint - point
            local dist = direction:GetLength()
            arrowDist = arrowDist + dist
            
            // Stop generating arrows when the path is big enough.
            totalDist = totalDist + dist
            if totalDist >= 30 then
                break
            end
            
            if arrowDist >= 5 then
            
                local trace = Shared.TraceRay(point, point - Vector(0, 100, 0), CollisionRep.Move, PhysicsMask.All)
                if trace.fraction ~= 1 then
                
                    // Move the arrow a bit off the ground.
                    local arrowOrigin = trace.endPoint + Vector(0, 0.2, 0)
                    
                    // Find closest world arrow to this point.
                    local arrow = FindClosestWorldArrow(self, arrowOrigin, PlayerUI_GetOrigin())
                    
                    // If one cannot be found, create a new one.
                    if not arrow then
                    
                        arrow = GetFreeArrow(self)
                        table.insert(self.worldArrows, arrow)
                        
                        arrow.showAmount = 0
                        local arrowCoords = Coords.GetLookIn(arrowOrigin, direction, Vector(0, 1, 0))
                        arrow.showStartCoords = Coords(arrowCoords)
                        arrowCoords:Scale(arrow.showAmount)
                        arrow.model:SetCoords(arrowCoords)
                        arrow.light:SetCoords(Coords.GetTranslation(arrowOrigin))
                        
                    end
                    
                    // Do not allow arrows to be too close to the player or target.
                    local distToPlayer = (PlayerUI_GetOrigin() - arrow.model:GetCoords().origin):GetLengthSquared()
                    local distToTarget = (targetPoint - arrow.model:GetCoords().origin):GetLengthSquared()
                    if distToPlayer > kArrowMinDistToPlayerSquared and distToTarget > kArrowMinDistToTargetSquared then
                    
                        arrow.inWorld = true
                        arrow.model:SetIsVisible(true)
                        arrow.light:SetIsVisible(true)
                        
                    end
                    
                    arrowDist = 0
                    
                end
                
            end
            
            lastPoint = point
            
        end
        
    end
    
    UpdateWorldArrows(self, dt)
    UpdateHideArrows(self, dt)
    
end

local gTimeLastWaypointSound = Shared.GetTime()
local function ShouldPlaySound(self)
    
    if not resolutionChanged and gTimeLastWaypointSound + kEffectInterval < Shared.GetTime() then
        gTimeLastWaypointSound = Shared.GetTime()
        return true
    end
    
    return false

end

local function AnimateOrderChanged(self, type)

    if ShouldPlaySound() then

        if self.marineWaypointLoaded then

            if type == kTechId.Attack then
                MarineOrder_OnOrderAttack()
                
            elseif type == kTechId.Move then
                MarineOrder_OnOrderMove()
                
            elseif type == kTechId.Construct or type == kTechId.AutoConstruct then 
                MarineOrder_OnOrderConstruct()
             
            elseif type == kTechId.Defend then
                MarineOrder_OnOrderDefend()
           
            elseif type == kTechId.Weld or type == kTechId.AutoWeld then
                MarineOrder_OnOrderRepair()
            
            end
        
        else
        
            if type == kTechId.Attack then
                AlienOrder_OnOrderAttack()
                
            elseif type == kTechId.Move then
                AlienOrder_OnOrderMove()
        
            elseif type == kTechId.Construct or type == kTechId.AutoConstruct then 
                AlienOrder_OnOrderConstruct()
                
            elseif type == kTechId.Heal or type == kTechId.AutoHeal then
                AlienOrder_OnOrderRepair()
            
            end
        
        end
    
    end
    
    self.orderIcon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(type)))
    TriggerCircleInAnimation(self)

end

function GUIWaypoints:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateItemsGUIScale(self)
    
    self:Uninitialize()
    self:Initialize()
    
    resolutionChanged = true
    local player = Client.GetLocalPlayer()
    if player then
        self:OnLocalPlayerChanged(player)
        if self.lastOrderType then
            AnimateOrderChanged(self, self.lastOrderType)
        end
    end
    resolutionChanged = false
end

local function AnimateOrderVanish(self)
    TriggerCircleOutAnimation(self)
end

local function AnimateFinalWaypoint(self)

    local finalWaypointData = PlayerUI_GetFinalWaypointInScreenspace()
    local showWayPoint = not PlayerUI_GetIsConstructing() and not PlayerUI_GetIsRepairing()
    
    local fullHUD = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
    
    self.animatedCircle:SetIsVisible(showWayPoint and fullHUD)
    self.finalWaypoint:SetIsVisible(showWayPoint)
    
    if finalWaypointData then
    
        local useTexture
    
        if not fullHUD then
            useTexture = kTransparentTexture    
        elseif PlayerUI_GetTeamType() == kAlienTeamType then
            useTexture = kAlienTextureName
        else
            useTexture = kMarineTextureName
        end    
    
        if self.usedTexture ~= useTexture then
            self.finalWaypoint:SetTexture(useTexture)
            self.usedTexture = useTexture
        end
    
        self.finalDistanceText:SetIsVisible(fullHUD)
        self.finalNameText:SetIsVisible(fullHUD)
        
        local x = finalWaypointData.x
        local y = finalWaypointData.y
        local scale = finalWaypointData.scale * kDefaultSize
        local name = finalWaypointData.name
        local distance = finalWaypointData.dist
        local type = finalWaypointData.type
        local id = finalWaypointData.id
        local showArrow = finalWaypointData.showArrow
        
        local screenCenter = Vector(Client.GetScreenWidth() / 2, Client.GetScreenHeight() / 2, 0)
        
        self.waypointDirection:SetIsVisible(showArrow == true)
        
        local alphaFraction = math.abs((Vector(x, y, 0) - screenCenter):GetLength()) / GUIScale(400) + 0.01
        
        self.finalWaypoint:SetColor(Color(1, 1, 1, alphaFraction))
        self.animatedCircle:SetColor(Color(1, 1, 1, alphaFraction))
        
        local size = Vector(scale, scale, 1)
        
        self.finalWaypoint:SetPosition(Vector(x - scale / 2, y - scale / 2, 0))
        self.finalWaypoint:SetSize(size)
        self.orderIcon:SetSize(size)
        
        local direction = self.finalWaypoint:GetPosition() - screenCenter
        
        if distance > 0 then
            self.finalDistanceText:SetText(tostring(math.floor(distance)) .. " " .. Locale.ResolveString("METERS"))
        else
            self.finalDistanceText:SetText("")
        end
        self.finalNameText:SetText(name)
        
        if showArrow then
        
            direction:Normalize()
            
            local angle = math.atan2(direction.x, direction.y)
            self.waypointDirection:SetPosition(-kArrowSize / 2 + direction * kArrowDistance)
            self.waypointDirection:SetRotation(Vector(0, 0, angle))
            
        end
        
        if self.lastOrderId ~= id or self.lastOrderType ~= type then
        
            AnimateOrderChanged(self, type)
            self.lastOrderId = id
            self.lastOrderType = type
            
        end
        
        local rotationPercentage = (Shared.GetTime() % kRotationDuration) / kRotationDuration
        self.animatedCircle:SetRotation(Vector(0, 0, 2 * math.pi * rotationPercentage))
        
    else
    
        self.finalWaypoint:SetColor(Color(1, 1, 1, 0))
        self.finalDistanceText:SetIsVisible(false)
        self.finalNameText:SetIsVisible(false)
        self.waypointDirection:SetIsVisible(false)
        
        if self.lastOrderId then
        
            self.lastOrderId = nil
            AnimateOrderVanish(self)
            
        end
        
    end
    
end

local kPathUpdateInterval = kUpdateIntervalMedium
function GUIWaypoints:Update(deltaTime)

    PROFILE("GUIWaypoints:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)
    -- always need full speed here... the final waypoint does not seem to be an animating item...
    self.updateInterval = kUpdateIntervalFull 
    
    local now = Shared.GetTime()
    if now > self.nextUpdatePathTime then
        UpdatePath(self, deltaTime)
        self.nextUpdatePathTime = now + kPathUpdateInterval
    end
    AnimateFinalWaypoint(self)
    
end

function GUIWaypoints:OnLocalPlayerChanged(newPlayer)

    if newPlayer:GetTeamNumber() == kTeam1Index then
        InitMarineTexture(self)
    elseif newPlayer:GetTeamNumber() == kTeam2Index then
        InitAlienTexture(self)
    end
    
end
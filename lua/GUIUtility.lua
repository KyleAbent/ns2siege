--======= Copyright (c) 2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIUtility.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

kTransparentTexture = "ui/transparent.dds"
kCommanderGUIsGlobalScale = 0.75

kYellow = Color(1, 1, 0)
kGreen = Color(0, 1, 0)
kRed = Color(1, 0 ,0)

-- this file is also used by GUIViews, which lack PrecacheAsset
PrecacheAsset = PrecacheAsset or function(name) return name end 

local kScreenScaleAspect = 1080
local kScreenScaleWeightAspect = 1920

local function ScreenSmallAspect()

    local screenWidth = Client.GetScreenWidth()
    local screenHeight = Client.GetScreenHeight()
    return ConditionalValue(screenWidth > screenHeight, screenHeight, screenWidth)

end

function GUIItemCalculateScreenPosition(guiItem)

    local itemScreenPosition = guiItem:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight())
    local itemText = guiItem:GetText()
    if itemText ~= "" then
    
        local addX = 0
        local alignX = guiItem:GetTextAlignmentX()
        if alignX == GUIItem.Align_Center then
            addX = -guiItem:GetTextWidth(guiItem:GetText()) / 2
        elseif alignX == GUIItem.Align_Max then
            addX = -guiItem:GetTextWidth(guiItem:GetText())
        end
        
        local addY = 0
        local alignY = guiItem:GetTextAlignmentY()
        if alignY == GUIItem.Align_Center then
            addY = -guiItem:GetTextHeight(guiItem:GetText()) / 2
        elseif alignY == GUIItem.Align_Max then
            addY = -guiItem:GetTextHeight(guiItem:GetText())
        end
        
        itemScreenPosition = itemScreenPosition + Vector(addX, addY, 0)
        
    end
    
    return itemScreenPosition
    
end


-- Returns true if the passed in point is contained within the passed in GUIItem.
-- Also returns the point inside the passed in GUIItem where that point is located.
-- Returns false if the point is not contained in the passed in GUIItem.
function GUIItemContainsPoint(guiItem, pointX, pointY)

    ASSERT(guiItem ~= nil)
    ASSERT(pointX ~= nil)
    ASSERT(pointY ~= nil)

    if not guiItem:GetIsVisible() then return false end

    local itemScreenPosition = GUIItemCalculateScreenPosition(guiItem)
    local itemSize = guiItem.GetScaledSize and guiItem:GetScaledSize() or guiItem:GetSize()
    
    if guiItem.GetIsScaling and guiItem:GetIsScaling() and guiItem.scale then
        itemSize = itemSize * guiItem.scale
    end
    
    local xWithin = pointX >= itemScreenPosition.x and pointX <= itemScreenPosition.x + itemSize.x
    local yWithin = pointY >= itemScreenPosition.y and pointY <= itemScreenPosition.y + itemSize.y
    if xWithin and yWithin then
        local xPositionWithin = pointX - itemScreenPosition.x
        local yPositionWithin = pointY - itemScreenPosition.y
        
        return true, xPositionWithin, yPositionWithin, itemSize, itemScreenPosition
    end
    return false, 0, 0

end

-- The following functions are global versions of the GUIItem member functions.
-- They are useful for animation operations.
function GUISetColor(item, color)
    item:SetColor(color)   
end

function GUISetSize(item, size)
    item:SetSize(size)
end

-- Pass in a GUIItem and a table with named X1, Y1, X2, Y2 elements.
-- These are pixel coordinates.
function GUISetTextureCoordinatesTable(item, coordinateTable)
    item:SetTexturePixelCoordinates(coordinateTable.X1, coordinateTable.Y1, coordinateTable.X2, coordinateTable.Y2)
end

-- Pass in a Column number, Row Number, Width, and Height.
-- For use in the GUIItem:SetTexturePixelCoordinates call.
function GUIGetSprite(col, row, width, height)

    assert(type(col) == 'number')
    assert(type(row) == 'number')
    assert(type(width) == 'number')
    assert(type(height) == 'number')
    
    return ((width * col) - width), ((height * row) - height), (width + (( width * col ) - width)), (height + (( height * row ) - height))
    
end

-- Reduces any input value based on user resolution
-- Usefull for scaling UI Sizes and positions so they never domainte the screen on small screen aspects.
-- See MenuManager for changing the resolution calculations
function GUIScale(size)
    if ScreenSmallAspect() > kScreenScaleAspect then
        return (ScreenSmallAspect() / kScreenScaleAspect)*size
    else
        return math.scaledown(size, ScreenSmallAspect(), kScreenScaleAspect) * (2 - (ScreenSmallAspect() / kScreenScaleAspect))
    end
end

function GUIScaleHeight(size)
    return size * Client.GetScreenHeight() / kScreenScaleAspect
end

function GUIScaleWeight(size)
    return size * Client.GetScreenWidth() / kScreenScaleWeightAspect
end

function GetScaledVector()
    return GUIScale(Vector(1, 1, 1))
end

local kMarineKeyIconsTextureName = PrecacheAsset("ui/key_mouse_marine.dds")
local kAlienKeyIconsTextureName = PrecacheAsset("ui/key_mouse_alien.dds")
local kBackgroundSmallCoords = { 7, 0, 38, 31 }
local kBackgroundBigCoords = { 53, 0, 116, 31 }
local kLeftClickCoords = { 11, 35, 33, 65 }
local kRightClickCoords = { 52, 34, 75, 65 }
local kMiddleClickCoords = { 93, 34, 115, 65 }
local kOverrideBackground = { }
kOverrideBackground["MouseButton0"] = { coords = kLeftClickCoords,
                                        size = Vector(kLeftClickCoords[3] - kLeftClickCoords[1], kLeftClickCoords[4] - kLeftClickCoords[2], 0),
                                        displayText = false }
kOverrideBackground["MouseButton1"] = { coords = kRightClickCoords,
                                        size = Vector(kRightClickCoords[3] - kRightClickCoords[1], kRightClickCoords[4] - kRightClickCoords[2], 0),
                                        displayText = false }
kOverrideBackground["MouseButton2"] = { coords = kMiddleClickCoords,
                                        size = Vector(kMiddleClickCoords[3] - kMiddleClickCoords[1], kMiddleClickCoords[4] - kMiddleClickCoords[2], 0),
                                        displayText = false }
local kKeyBackgroundHeight = 32
local kKeyBackgroundSmallWidth = 32
local kKeyBackgroundBigWidth = 64
local kKeyBackgroundWidthBuffer = 26
local kKeyFontSize = 22

function GUICreateButtonIcon(forAction, alienStyle)

    local forKey = GetPrettyInputName(forAction)
    local big = string.len(forKey) > 2
    
    local textureName = kMarineKeyIconsTextureName
    local fontColor = kMarineFontColor
    
    -- Default to the local player.
    if alienStyle == nil then
        alienStyle = GetIsAlienUnit(Client.GetLocalPlayer())
    end
    
    if alienStyle then
    
        textureName = kAlienKeyIconsTextureName
        fontColor = kAlienFontColor
        
    end    
    
    local keyBackground = GUIManager:CreateGraphicItem()
    keyBackground:SetTexture(textureName)
    
    local keyText = GUIManager:CreateTextItem()
    keyText:SetFontSize(kKeyFontSize)
    keyText:SetScale(GetScaledVector())
    keyText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    keyText:SetTextAlignmentX(GUIItem.Align_Center)
    keyText:SetTextAlignmentY(GUIItem.Align_Center)
    keyText:SetColor(fontColor)
    keyText:SetFontIsBold(true)
    keyText:SetText(forKey)
    keyText:SetFontName(Fonts.kAgencyFB_Small)
    keyText:SetInheritsParentAlpha(true)
    keyBackground:AddChild(keyText)
    
    local width = kKeyBackgroundSmallWidth
    
    if big then
    
        keyBackground:SetTexturePixelCoordinates(unpack(kBackgroundBigCoords))
        local buttonTextWidth = keyText:GetTextWidth(forKey)
        width = ((kKeyBackgroundBigWidth > buttonTextWidth + kKeyBackgroundWidthBuffer) and kKeyBackgroundBigWidth) or (buttonTextWidth + kKeyBackgroundWidthBuffer)
        
    else
        keyBackground:SetTexturePixelCoordinates(unpack(kBackgroundSmallCoords))
    end
    
    keyBackground:SetSize(GUIScale(Vector(width, kKeyBackgroundHeight, 0)))
    
    -- Handle special case overrides (mouse button graphic for example).
    local nonPrettyKeyName = BindingsUI_GetInputValue(forAction)
    local override = kOverrideBackground[nonPrettyKeyName]
    if override then
    
        keyBackground:SetTexturePixelCoordinates(unpack(override.coords))
        keyBackground:SetSize(GUIScale(override.size))
        if not override.displayText then
            keyText:SetIsVisible(false)
        end
        
    end
    
    return keyBackground, keyText
    
end

function GetTextureCoordinatesForIcon(techId)

    local xOffset, yOffset = GetMaterialXYOffset(techId)
    
    local x1 = 0
    local y1 = 0
    local x2 = 80
    local y2 = 80
    
    if xOffset and yOffset then
        x1 = xOffset * 80
        y1 = yOffset * 80
        x2 = x1 + 80
        y2 = y1 + 80
    end

    return { x1, y1, x2, y2 }

end

local kCommanderPingTexture = "ui/commanderping.dds"
function GUICreateCommanderPing()

    local frame = GetGUIManager():CreateGraphicItem()
    frame:SetTexture(kCommanderPingTexture)
    frame:SetTextureCoordinates(1,1,1,1) -- invisible
    
    local mark = GetGUIManager():CreateGraphicItem()
    mark:SetTexture(kCommanderPingTexture)
    mark:SetTextureCoordinates(0.5, 0, 1, 1)
    mark:SetInheritsParentAlpha(true)
    
    frame:AddChild(mark)
    
    local border = GetGUIManager():CreateGraphicItem()
    border:SetTexture(kCommanderPingTexture)
    border:SetTextureCoordinates(0.0, 0, 0.5, 1)
    border:SetInheritsParentAlpha(true)
    
    frame:AddChild(border)
    
    -- Add text label that displays location name
    local location = GUIManager:CreateTextItem()
    location:SetFontName(kNeutralFontName)
    location:SetAnchor(GUIItem.Middle, GUIItem.Center)
    
    location:SetTextAlignmentX(GUIItem.Align_Center)
    location:SetTextAlignmentY(GUIItem.Align_Center)
    
    location:SetColor(kNeutralFontColor)
    location:SetInheritsParentAlpha(true)
    
    frame:AddChild(location)

    return { Frame = frame, Mark = mark, Border = border, Location = location }
    
end

local kBorderAnimationDuration = 0.5
function GUIAnimateCommanderPing(markItem, borderItem, locationItem, defaultSize, timeSincePing, color1, color2)

    timeSincePing = math.min(timeSincePing, kCommanderPingDuration)  
  
    local borderAnimFraction = ConditionalValue(timeSincePing == kCommanderPingDuration, 0, 1 - ( (timeSincePing % kBorderAnimationDuration ) / kBorderAnimationDuration ) )
    local borderColor = Color(color1.r, color1.g, color1.b, borderAnimFraction)
    
    borderItem:SetColor(borderColor)
    borderItem:SetSize(defaultSize * borderAnimFraction)
    borderItem:SetPosition(-defaultSize*.5 * borderAnimFraction)
    
    local markColor = Color(color2.r, color2.g, color2.b, 1 - (timeSincePing / kCommanderPingDuration))
    
    markItem:SetSize(defaultSize)
    markItem:SetPosition(-defaultSize * .5)
    markItem:SetColor(markColor)
    
    locationItem:SetScale(GetScaledVector())
    locationItem:SetPosition(Vector(0, GUIScale(70), 0))
    locationItem:SetColor(markColor)
    
    return timeSincePing == kCommanderPingDuration

end

if Locale then

    local kPrettyInputNames = nil
    local function InitInputNames()
    
        kPrettyInputNames = { }
        kPrettyInputNames["MouseButton0"] = Locale.ResolveString("LEFT_MOUSE_BUTTON")
        kPrettyInputNames["MouseButton1"] = Locale.ResolveString("RIGHT_MOUSE_BUTTON")
        kPrettyInputNames["LeftShift"] = Locale.ResolveString("LEFT_SHIFT")
        kPrettyInputNames["RightShift"] = Locale.ResolveString("RIGHT_SHIFT")
        
    end
    
    function GetPrettyInputName(inputName)
    
        if not kPrettyInputNames then
            InitInputNames()
        end
        
        local prettyInputName = BindingsUI_GetInputValue(inputName)
        local foundPrettyInputName = kPrettyInputNames[prettyInputName]
        return foundPrettyInputName and foundPrettyInputName or prettyInputName
        
    end
    
end

function GetLinePositionForTechMap(techMap, fromTechId, toTechId)

    local positions = { 0, 0, 0, 0 }
    local foundFrom = false
    local foundTo = false

    for i = 1, #techMap do
    
        local entry = techMap[i]
        if entry[1] == fromTechId then
        
            positions[1] = entry[2]
            positions[2] = entry[3]
            foundFrom = true
            
        elseif entry[1] == toTechId then
        
            positions[3] = entry[2]
            positions[4] = entry[3]
            foundTo = true
            
        end

        if foundFrom and foundTo then
            break
        end 
    
    end
    
    return positions

end

-- Find the font that has to scale the least to achieve our desired size
local function ChooseFontAndSize(fontFamily, targetSize)
    local currentDiff
    local finalFont
    local finalScale
    for curFontName, curFontSize in pairs(fontFamily) do
        local diff = math.abs(1-(targetSize/curFontSize))
        if currentDiff == nil or currentDiff > diff then
            currentDiff = diff
            finalFont = curFontName
            finalScale = targetSize/curFontSize
        end
    end
    
    return finalFont, finalScale
end

function GUIItem:SetFontAndSize(fontFamily, targetSize)
    GUIMakeFontScale(self, fontFamily, targetSize)
end

-- Chooses appropriate font size and scale for the previous scaled size and font
-- When using this with just the GUI item it's required that you do it after setting font and scale
-- This function was created mainly as a workaround for blurry fonts for the Scaling UI patch
function GUIMakeFontScale(item, itemFontFamily, itemSize)
    -- Check if it's an animated item
    local guiItem = item.GetFontName and item or item.guiItem.GetFontName and item.guiItem or nil
    if guiItem == nil then
        return
    end
    
    if itemFontFamily and itemSize then
        if FontFamilies[itemFontFamily] then
            local finalFont, finalScale = ChooseFontAndSize(FontFamilies[itemFontFamily], itemSize)
            
            guiItem:SetScale(Vector(1,1,1)*finalScale)
            guiItem:SetFontName(finalFont)
        end
    elseif not itemFont and not itemSize then
        local fontName = guiItem:GetFontName()
        local fontFamily
        local size = 0
        
        -- If it has a font name, then we're 99% confident this is an actual text item
        if fontName then
            for _, family in pairs(FontFamilies) do
                if family[fontName] then
                    fontFamily = family
                    size = family[fontName]
                    break
                end
            end
            
            -- Exit if we didn't find a match, let nature run its course
            if not fontFamily then
                return
            end
            
            -- We're going to assume that it is scaled uniformily, because it's easier that way
            -- Don't judge me
            local currentScale = guiItem:GetScale().x
            local targetSize = size * currentScale
            
            local finalFont, finalScale = ChooseFontAndSize(fontFamily, targetSize)
            
            guiItem:SetScale(Vector(1,1,1)*finalScale)
            guiItem:SetFontName(finalFont)
        end
    end
end
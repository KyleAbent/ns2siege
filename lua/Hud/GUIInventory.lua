// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIInventory.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Displays the ability/weapon icons.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIInventory'

local kFontName = Fonts.kAgencyFB_Small

GUIInventory.kActiveColor = Color(1,1,1,1)
GUIInventory.kInactiveColor = Color(0.6, 0.6, 0.6, 0.6)

GUIInventory.kItemSize = Vector(96, 48, 0)
GUIInventory.kItemPadding = 20

local function UpdateItemsGUIScale(self)
    GUIInventory.kBackgroundYOffset = GUIScale(-120)
end

function CreateInventoryDisplay(scriptHandle, hudLayer, frame)

    local inventoryDisplay = GUIInventory()
    inventoryDisplay.script = scriptHandle
    inventoryDisplay.hudLayer = hudLayer
    inventoryDisplay.frame = frame
    inventoryDisplay:Initialize()
    
    return inventoryDisplay

end

local function CreateInventoryItem(self, index, alienStyle)

    local item = self.script:CreateAnimatedGraphicItem()
    
    item:SetSize(GUIInventory.kItemSize)
    item:SetTexture(kInventoryIconsTexture)
    item:AddAsChildTo(self.background)
    
    local key, keyText = GUICreateButtonIcon("Weapon1", alienStyle)
    key:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    key:SetInheritsParentAlpha(true)
    keyText:SetInheritsParentAlpha(true)
    keyText:SetFontName(kFontName)
    GUIMakeFontScale(keyText)
    
    local keySize = key:GetSize()    
    key:SetPosition(Vector(keySize.x * -.5, GUIScale(8), 0))
    
    item:AddChild(key)
    
    local result = { Graphic = item, KeyText = keyText }
    
    table.insert(self.inventoryIcons, result)
    
    return result

end

local function LocalAdjustSlot(self, index, hudSlot, techId, isActive, resetAnimations, alienStyle)

    local inventoryItem = nil

    if self.inventoryIcons[index] then
        inventoryItem = self.inventoryIcons[index]
    else
        inventoryItem = CreateInventoryItem(self, index)
        inventoryItem.Graphic:Pause(2, "ANIM_INVENTORY_ITEM_PAUSE", AnimateLinear, function(script, item) item:FadeOut(0.5, "ANIM_INVENTORY_ITEM") end )
    end
    
    inventoryItem.KeyText:SetText(BindingsUI_GetInputValue("Weapon" .. hudSlot))
    inventoryItem.Graphic:SetUniformScale(self.scale)
    inventoryItem.Graphic:SetTexturePixelCoordinates(GetTexCoordsForTechId(techId))
    inventoryItem.Graphic:SetPosition(Vector( (GUIInventory.kItemPadding + GUIInventory.kItemSize.x) * (index-1) , 0, 0) )
    
    if resetAnimations then
        inventoryItem.Graphic:Pause(2, "ANIM_INVENTORY_ITEM_PAUSE", AnimateLinear, function(script, item) item:FadeOut(0.5, "ANIM_INVENTORY_ITEM") end )    
    end
    
    if inventoryItem.Graphic:GetHasAnimation("ANIM_INVENTORY_ITEM_PAUSE") then
        inventoryItem.Graphic:SetColor(ConditionalValue(isActive, GUIInventory.kActiveColor, GUIInventory.kInactiveColor))
    end

end

function GUIInventory:Initialize()

    self.scale = 1
    
    UpdateItemsGUIScale(self)
    
    self.lastPersonalResources = 0
    
    self.background = GetGUIManager():CreateGraphicItem()
    self.background:SetColor(Color(0,0,0,0))
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.frame:AddChild(self.background)
    
    self.inventoryIcons = {}
    
    // Force it to display always
    self.forceAnimationReset = false

end

function GUIInventory:Reset(scale)

    self.scale = scale
    UpdateItemsGUIScale(self)
    self.background:SetPosition(Vector(0, GUIInventory.kBackgroundYOffset, 0) * self.scale)

end

function GUIInventory:SetIsVisible(visible)
    self.background:SetIsVisible(visible)
end

// Call this with true to force inventory to stay on screen instead of fading out
function GUIInventory:SetForceAnimationReset(state)
    self.forceAnimationReset = state
end

function GUIInventory:Update(deltaTime, parameters)

    PROFILE("GUIInventory:Update")
    
    local fullMode = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
    self.background:SetIsVisible(fullMode)
    
    if fullMode then
        
        local activeWeaponTechId, inventoryTechIds = unpack(parameters)
        
        if #self.inventoryIcons > #inventoryTechIds then
        
            self.inventoryIcons[#self.inventoryIcons].Graphic:Destroy()
            table.remove(self.inventoryIcons, #self.inventoryIcons)
            
        end
        
        local resetAnimations = false
        if activeWeaponTechId ~= self.lastActiveWeaponTechId and gTechIdPosition and gTechIdPosition[activeWeaponTechId] then

            self.lastActiveWeaponTechId = activeWeaponTechId
            resetAnimations = true
            
        end
        
        if self.forceAnimationReset then
            resetAnimations = true
        end
        
        local numItems = #inventoryTechIds
        self.background:SetPosition(Vector(
            self.scale * -0.5 * (numItems*GUIInventory.kItemSize.x + (numItems-1)*GUIInventory.kItemPadding),
            GUIInventory.kBackgroundYOffset,
            0))
        
        local alienStyle = PlayerUI_GetTeamType() == kAlienTeamType
        
        for index, inventoryItem in ipairs(inventoryTechIds) do
            LocalAdjustSlot(self, index, inventoryItem.HUDSlot, inventoryItem.TechId, inventoryItem.TechId == activeWeaponTechId, resetAnimations, alienStyle)
        end
    
    end
    
end

function GUIInventory:Destroy()

    if self.background then
        GUI.DestroyItem(self.background)
        self.background = nil
    end

end
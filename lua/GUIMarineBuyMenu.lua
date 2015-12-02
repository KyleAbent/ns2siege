// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIMarineBuyMenu.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Manages the marine buy/purchase menu.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")


class 'GUIMarineBuyMenu' (GUIAnimatedScript)

//////////////////////Modular



GUIMarineBuyMenu.kMenuWidth = GUIScale(190)
GUIMarineBuyMenu.kPadding = GUIScale(8)
GUIMarineBuyMenu.kBackgroundWidth = GUIScale(600)
GUIMarineBuyMenu.kBackgroundHeight = GUIScale(710)

GUIMarineBuyMenu.kConfigAreaXOffset = GUIMarineBuyMenu.kPadding
GUIMarineBuyMenu.kConfigAreaYOffset = GUIMarineBuyMenu.kPadding
GUIMarineBuyMenu.kUpgradeButtonAreaHeight = GUIScale(30)
--GUIMarineBuyMenu.kUpgradeButtonWidth = GUIScale(160)
--GUIMarineBuyMenu.kUpgradeButtonHeight = GUIScale(64)
GUIMarineBuyMenu.kConfigAreaWidth = (
        GUIMarineBuyMenu.kBackgroundWidth
    -   GUIMarineBuyMenu.kPadding*2
)
GUIMarineBuyMenu.kConfigAreaHeight = (
        GUIMarineBuyMenu.kBackgroundHeight
    -   GUIMarineBuyMenu.kUpgradeButtonAreaHeight
    -   GUIMarineBuyMenu.kPadding*3
)
GUIMarineBuyMenu.kSlotPanelBackgroundColor = Color(1, 1, 1, 0.5)

GUIMarineBuyMenu.kSmallModuleButtonSize = GUIScale(Vector(60, 60, 0))
GUIMarineBuyMenu.kWideModuleButtonSize = GUIScale(Vector(150, 60, 0))
GUIMarineBuyMenu.kMediumModuleButtonSize = GUIScale(Vector(100, 60, 0))
GUIMarineBuyMenu.kWeaponImageSize = GUIScale(Vector(80, 40, 0))
GUIMarineBuyMenu.kUtilityImageSize = GUIScale(Vector(39, 39, 0))
GUIMarineBuyMenu.kModuleButtonGap = GUIScale(7)
GUIMarineBuyMenu.kPanelTitleHeight = GUIScale(35)

GUIMarineBuyMenu.kExoSlotData = {
   /* [kExoModuleSlots.PowerSupply] = {
        label = "POWER SUPPLY",--label = "EXO_MODULESLOT_POWERSUPPLY", 
        xp = 0, yp = 0, anchorX = GUIItem.Left, gap = GUIMarineBuyMenu.kModuleButtonGap,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakePowerModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },*/
    StatusPanel = { -- the one that shows weight and power usage
        label = nil,
        xp = 0, yp = 0, anchorX = GUIItem.Left,
    },
    [kExoModuleSlots.LeftArm] = {
        label = "LEFT ARM",--label = "EXO_MODULESLOT_RIGHT_ARM",
        xp = 0, yp = 0.08, anchorX = GUIItem.Left, gap = GUIMarineBuyMenu.kModuleButtonGap*0.5,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.LeftArm)
        end,
    },
    [kExoModuleSlots.RightArm] = {
        label = "RIGHT ARM",--label = "EXO_MODULESLOT_LEFT_ARM",
        xp = 1, yp = 0.08, anchorX = GUIItem.Right, gap = GUIMarineBuyMenu.kModuleButtonGap*0.5,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.RightArm)
        end,
    },
  [kExoModuleSlots.Utility] = {
        label = "UTILITY",--label = "EXO_MODULESLOT_UTILITY",
        xp = 0.23, yp = 0.62, anchorX = GUIItem.Left, gap = GUIMarineBuyMenu.kModuleButtonGap,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeUtilityModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },
}
/////////////////////////////////

/*
GUIMarineBuyMenu.kJetpackSlotData = {
    StatusPanel = { -- the one that shows weight and power usage
        label = nil,
        xp = 0, yp = 0, anchorX = GUIItem.Left,
    },
    [kJetpackModuleSlots.LeftArm] = {
        label = "LEFT ARM",--label = "EXO_MODULESLOT_RIGHT_ARM",
        xp = 0, yp = 0.08, anchorX = GUIItem.Left, gap = GUIMarineBuyMenu.kModuleButtonGap*0.5,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kJetpackModuleSlots.LeftArm)
        end,
    },
    [kJetpackModuleSlots.RightArm] = {
        label = "RIGHT ARM",--label = "EXO_MODULESLOT_LEFT_ARM",
        xp = 1, yp = 0.08, anchorX = GUIItem.Right, gap = GUIMarineBuyMenu.kModuleButtonGap*0.5,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kJetpackModuleSlots.RightArm)
        end,
    },
  [kJetpackModuleSlots.Utility] = {
        label = "UTILITY",--label = "EXO_MODULESLOT_UTILITY",
        xp = 0.23, yp = 0.62, anchorX = GUIItem.Left, gap = GUIMarineBuyMenu.kModuleButtonGap,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeUtilityModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },
}

*/

GUIMarineBuyMenu.kBuyMenuTexture = "ui/marine_buy_textures.dds"
GUIMarineBuyMenu.kBuyHUDTexture = "ui/marine_buy_icons.dds"
GUIMarineBuyMenu.kRepeatingBackground = "ui/menu/grid.dds"
GUIMarineBuyMenu.kContentBgTexture = "ui/menu/repeating_bg.dds"
GUIMarineBuyMenu.kContentBgBackTexture = "ui/menu/repeating_bg_black.dds"
GUIMarineBuyMenu.kResourceIconTexture = "ui/pres_icon_big.dds"
GUIMarineBuyMenu.kBigIconTexture = "ui/marine_buy_bigicons.dds"
GUIMarineBuyMenu.kButtonTexture = "ui/marine_buymenu_button.dds"
GUIMarineBuyMenu.kMenuSelectionTexture = "ui/marine_buymenu_selector.dds"
GUIMarineBuyMenu.kScanLineTexture = "ui/menu/scanLine_big.dds"
GUIMarineBuyMenu.kArrowTexture = "ui/menu/arrow_horiz.dds"

GUIMarineBuyMenu.kFont = Fonts.kAgencyFB_Small

GUIMarineBuyMenu.kDescriptionFontName = Fonts.kAgencyFB_Small

GUIMarineBuyMenu.kScanLineAnimDuration = 5

GUIMarineBuyMenu.kArrowTexCoords = { 1, 1, 0, 0 }

local kEquippedMouseoverColor = Color(1, 1, 1, 1)
local kEquippedColor = Color(0.5, 0.5, 0.5, 0.5)

local gBigIconIndex = nil
local bigIconWidth = 400
local bigIconHeight = 300
local function GetBigIconPixelCoords(techId, researched)

    if not gBigIconIndex then
    
        gBigIconIndex = {}
        gBigIconIndex[kTechId.Axe] = 0
        gBigIconIndex[kTechId.Pistol] = 1
        gBigIconIndex[kTechId.Rifle] = 2
        gBigIconIndex[kTechId.Shotgun] = 3
        gBigIconIndex[kTechId.HeavyRifle] = 2
        gBigIconIndex[kTechId.GrenadeLauncher] = 4
        gBigIconIndex[kTechId.Flamethrower] = 5
        gBigIconIndex[kTechId.Jetpack] = 6
        gBigIconIndex[kTechId.JumpPack] = 6
        gBigIconIndex[kTechId.Exosuit] = 7
        gBigIconIndex[kTechId.Welder] = 8
        gBigIconIndex[kTechId.ExoNanoArmor] = 8
        gBigIconIndex[kTechId.LayMines] = 9
        gBigIconIndex[kTechId.DualMinigunExosuit] = 10
        gBigIconIndex[kTechId.UpgradeToDualMinigun] = 10
        gBigIconIndex[kTechId.ClawRailgunExosuit] = 11
        gBigIconIndex[kTechId.DualRailgunExosuit] = 11
        gBigIconIndex[kTechId.UpgradeToDualRailgun] = 11
        
        gBigIconIndex[kTechId.ClusterGrenade] = 12
        gBigIconIndex[kTechId.GasGrenade] = 13
        gBigIconIndex[kTechId.PulseGrenade] = 14
        
    
    end
    
    local index = gBigIconIndex[techId]
    if not index then
        index = 0
    end
    
    local x1 = 0
    local x2 = bigIconWidth
    
    if not researched then
    
        x1 = bigIconWidth
        x2 = bigIconWidth * 2
        
    end
    
    local y1 = index * bigIconHeight
    local y2 = (index + 1) * bigIconHeight
    
    return x1, y1, x2, y2

end

// Small Item Icons
local kSmallIconScale = 0.9

local smallIconHeight = 64
local smallIconWidth = 128
local gSmallIconIndex = nil
local function GetSmallIconPixelCoordinates(itemTechId)

    if not gSmallIconIndex then
    
        gSmallIconIndex = {}
        gSmallIconIndex[kTechId.Axe] = 4
        gSmallIconIndex[kTechId.Pistol] = 3
        gSmallIconIndex[kTechId.HeavyRifle] = 1
        gSmallIconIndex[kTechId.Rifle] = 1
        gSmallIconIndex[kTechId.Shotgun] = 5
        gSmallIconIndex[kTechId.GrenadeLauncher] = 35
        gSmallIconIndex[kTechId.Flamethrower] = 6
        gSmallIconIndex[kTechId.Jetpack] = 24
        gSmallIconIndex[kTechId.JumpPack] = 24
        gSmallIconIndex[kTechId.Exosuit] = 26
        gSmallIconIndex[kTechId.Welder] = 10
        gSmallIconIndex[kTechId.ExoNanoArmor] = 10
        gSmallIconIndex[kTechId.LayMines] = 21
        gSmallIconIndex[kTechId.DualMinigunExosuit] = 26
        gSmallIconIndex[kTechId.UpgradeToDualMinigun] = 26
        gSmallIconIndex[kTechId.ClawRailgunExosuit] = 38
        gSmallIconIndex[kTechId.DualRailgunExosuit] = 38
        gSmallIconIndex[kTechId.UpgradeToDualRailgun] = 38
        
        gSmallIconIndex[kTechId.ClusterGrenade] = 42
        gSmallIconIndex[kTechId.GasGrenade] = 43
        gSmallIconIndex[kTechId.PulseGrenade] = 44
    
    end
    
    local index = gSmallIconIndex[itemTechId]
    if not index then
        index = 0
    end
    
    local y1 = index * smallIconHeight
    local y2 = (index + 1) * smallIconHeight
    
    return 0, y1, smallIconWidth, y2

end
                            
GUIMarineBuyMenu.kTextColor = Color(kMarineFontColor)

GUIMarineBuyMenu.kDisabledColor = Color(0.5, 0.5, 0.5, 0.5)
GUIMarineBuyMenu.kCannotBuyColor = Color(1, 0, 0, 0.5)
GUIMarineBuyMenu.kEnabledColor = Color(1, 1, 1, 1)

GUIMarineBuyMenu.kCloseButtonColor = Color(1, 1, 0, 1)

function GUIMarineBuyMenu:SetHostStructure(hostStructure)

    self.hostStructure = hostStructure
    self:_InitializeItemButtons()
    
       if hostStructure:isa("PrototypeLab") then
       self:_InitializeExoModularButtons()
        self:_RefreshExoModularButtons()
        //self:_InitializeJetpackModularButtons()
      //  self:_RefreshJetpackModularButtons()
    end
    
end

function GUIMarineBuyMenu:OnClose()

    // Check if GUIMarineBuyMenu is what is causing itself to close.
    if not self.closingMenu then
        // Play the close sound since we didn't trigger the close.
        MarineBuy_OnClose()
    end

end

local function UpdateItemsGUIScale(self)
    GUIMarineBuyMenu.kDescriptionFontSize = GUIScale(20)
    GUIMarineBuyMenu.kScanLineHeight = GUIScale(256)
    GUIMarineBuyMenu.kArrowWidth = GUIScale(32)
    GUIMarineBuyMenu.kArrowHeight = GUIScale(32)

    // Big Item Icons
    GUIMarineBuyMenu.kBigIconSize = GUIScale( Vector(320, 256, 0) )
    GUIMarineBuyMenu.kBigIconOffset = GUIScale(20)

    GUIMarineBuyMenu.kSmallIconSize = GUIScale( Vector(100, 50, 0) )
    GUIMarineBuyMenu.kMenuIconSize = GUIScale( Vector(190, 80, 0) ) * kSmallIconScale
    GUIMarineBuyMenu.kSelectorSize = GUIScale( Vector(215, 110, 0) ) * kSmallIconScale
    GUIMarineBuyMenu.kIconTopOffset = GUIScale(10)
    GUIMarineBuyMenu.kItemIconYOffset = {}

    GUIMarineBuyMenu.kEquippedIconTopOffset = GUIScale(58)

    GUIMarineBuyMenu.kMenuWidth = GUIScale(190)
    GUIMarineBuyMenu.kPadding = GUIScale(8)

    GUIMarineBuyMenu.kEquippedWidth = GUIScale(128)

    GUIMarineBuyMenu.kBackgroundWidth = GUIScale(600)
    GUIMarineBuyMenu.kBackgroundHeight = GUIScale(640)
    // We want the background graphic to look centered around the circle even though there is the part coming off to the right.
    GUIMarineBuyMenu.kBackgroundXOffset = GUIScale(0)

    GUIMarineBuyMenu.kPlayersTextSize = GUIScale(24)
    GUIMarineBuyMenu.kResearchTextSize = GUIScale(24)

    GUIMarineBuyMenu.kResourceDisplayHeight = GUIScale(64)

    GUIMarineBuyMenu.kResourceIconWidth = GUIScale(32)
    GUIMarineBuyMenu.kResourceIconHeight = GUIScale(32)

    GUIMarineBuyMenu.kMouseOverInfoTextSize = GUIScale(20)
    GUIMarineBuyMenu.kMouseOverInfoOffset = Vector(GUIScale(-30), GUIScale(-20), 0)
    GUIMarineBuyMenu.kMouseOverInfoResIconOffset = Vector(GUIScale(-40), GUIScale(-60), 0)

    GUIMarineBuyMenu.kButtonWidth = GUIScale(160)
    GUIMarineBuyMenu.kButtonHeight = GUIScale(64)

    GUIMarineBuyMenu.kItemNameOffsetX = GUIScale(28)
    GUIMarineBuyMenu.kItemNameOffsetY = GUIScale(256)

    GUIMarineBuyMenu.kItemDescriptionOffsetY = GUIScale(300)
    GUIMarineBuyMenu.kItemDescriptionSize = GUIScale( Vector(450, 180, 0) )
end

function GUIMarineBuyMenu:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
    
    MarineBuy_OnClose()
end

function GUIMarineBuyMenu:Initialize()

    GUIAnimatedScript.Initialize(self)

    UpdateItemsGUIScale(self)
    
    self.mouseOverStates = { }
    self.equipped = { }
    
    self.selectedItem = kTechId.None
    
    self:_InitializeBackground()
    self:_InitializeContent()
    self:_InitializeResourceDisplay()
    self:_InitializeCloseButton()
    self:_InitializeEquipped()    

    // note: items buttons get initialized through SetHostStructure()
    MarineBuy_OnOpen()
    
end

/**
 * Checks if the mouse is over the passed in GUIItem and plays a sound if it has just moved over.
 */
local function GetIsMouseOver(self, overItem)

    local mouseOver = GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    if mouseOver and not self.mouseOverStates[overItem] then
        MarineBuy_OnMouseOver()
    end
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver
    
end

//McG: Should be updated to include Exo & JP (mainly its usage)
local function UpdateEquipped(self, deltaTime)

    self.hoverItem = nil
    for i = 1, #self.equipped do
    
        local equipped = self.equipped[i]
        if GetIsMouseOver(self, equipped.Graphic) then
        
            self.hoverItem = equipped.TechId
            equipped.Graphic:SetColor(kEquippedMouseoverColor)
            
        else
            equipped.Graphic:SetColor(kEquippedColor)
        end
        
    end
    
end

function GUIMarineBuyMenu:Update(deltaTime)
  
    PROFILE("GUIMarineBuyMenu:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)

    UpdateEquipped(self, deltaTime)
    self:_UpdateItemButtons(deltaTime)
    self:_UpdateContent(deltaTime)
    self:_UpdateResourceDisplay(deltaTime)
    self:_UpdateCloseButton(deltaTime)
    self:_UpdateExoModularButtons(deltaTime)
  //  self:_UpdateJetpackModularButtons(deltaTime)
end

function GUIMarineBuyMenu:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)

    self:_UninitializeItemButtons()
    self:_UninitializeBackground()
    self:_UninitializeContent()
    self:_UninitializeResourceDisplay()
    self:_UninitializeCloseButton()

end

local function MoveDownAnim(script, item)

    item:SetPosition( Vector(0, -GUIMarineBuyMenu.kScanLineHeight, 0) )
    item:SetPosition( Vector(0, Client.GetScreenHeight() + GUIMarineBuyMenu.kScanLineHeight, 0), GUIMarineBuyMenu.kScanLineAnimDuration, "MARINEBUY_SCANLINE", AnimateLinear, MoveDownAnim)

end

function GUIMarineBuyMenu:_InitializeBackground()

    // This invisible background is used for centering only.
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetColor(Color(0.05, 0.05, 0.1, 0.7))
    self.background:SetLayer(kGUILayerPlayerHUDForeground4)
    
    self.repeatingBGTexture = GUIManager:CreateGraphicItem()
    self.repeatingBGTexture:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.repeatingBGTexture:SetTexture(GUIMarineBuyMenu.kRepeatingBackground)
    self.repeatingBGTexture:SetTexturePixelCoordinates(0, 0, Client.GetScreenWidth(), Client.GetScreenHeight())
    self.background:AddChild(self.repeatingBGTexture)
    
    self.content = GUIManager:CreateGraphicItem()
    self.content:SetSize(Vector(GUIMarineBuyMenu.kBackgroundWidth, GUIMarineBuyMenu.kBackgroundHeight, 0))
    self.content:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.content:SetPosition(Vector((-GUIMarineBuyMenu.kBackgroundWidth / 2) + GUIMarineBuyMenu.kBackgroundXOffset, -GUIMarineBuyMenu.kBackgroundHeight / 2, 0))
    self.content:SetTexture(GUIMarineBuyMenu.kContentBgTexture)
    self.content:SetTexturePixelCoordinates(0, 0, GUIMarineBuyMenu.kBackgroundWidth, GUIMarineBuyMenu.kBackgroundHeight)
    self.content:SetColor( Color(1,1,1,0.8) )
    self.background:AddChild(self.content)
    
    self.scanLine = self:CreateAnimatedGraphicItem()
    self.scanLine:SetSize( Vector( Client.GetScreenWidth(), GUIMarineBuyMenu.kScanLineHeight, 0) )
    self.scanLine:SetTexture(GUIMarineBuyMenu.kScanLineTexture)
    self.scanLine:SetLayer(kGUILayerPlayerHUDForeground4)
    self.scanLine:SetIsScaling(false)
    
    self.scanLine:SetPosition( Vector(0, -GUIMarineBuyMenu.kScanLineHeight, 0) )
    self.scanLine:SetPosition( Vector(0, Client.GetScreenHeight() + GUIMarineBuyMenu.kScanLineHeight, 0), GUIMarineBuyMenu.kScanLineAnimDuration, "MARINEBUY_SCANLINE", AnimateLinear, MoveDownAnim)

end

function GUIMarineBuyMenu:_UninitializeBackground()

    GUI.DestroyItem(self.background)
    self.background = nil
    
    self.content = nil
    
end

function GUIMarineBuyMenu:_InitializeEquipped()

    self.equippedBg = GetGUIManager():CreateGraphicItem()
    self.equippedBg:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.equippedBg:SetPosition(Vector( GUIMarineBuyMenu.kPadding, -GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.equippedBg:SetSize(Vector(GUIMarineBuyMenu.kEquippedWidth, GUIMarineBuyMenu.kBackgroundHeight + GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.equippedBg:SetColor(Color(0,0,0,0))
    self.content:AddChild(self.equippedBg)
    
    self.equippedTitle = GetGUIManager():CreateTextItem()
    self.equippedTitle:SetFontName(GUIMarineBuyMenu.kFont)
    self.equippedTitle:SetScale(GetScaledVector())
    GUIMakeFontScale(self.equippedTitle)
    self.equippedTitle:SetFontIsBold(true)
    self.equippedTitle:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.equippedTitle:SetTextAlignmentX(GUIItem.Align_Center)
    self.equippedTitle:SetTextAlignmentY(GUIItem.Align_Center)
    self.equippedTitle:SetColor(kEquippedColor)
    self.equippedTitle:SetPosition(Vector(0, GUIMarineBuyMenu.kResourceDisplayHeight / 2, 0))
    self.equippedTitle:SetText(Locale.ResolveString("EQUIPPED"))
    self.equippedBg:AddChild(self.equippedTitle)
    
    self.equipped = { }
    
    local equippedTechIds = MarineBuy_GetEquipped()
    local selectorPosX = -GUIMarineBuyMenu.kSelectorSize.x + GUIMarineBuyMenu.kPadding
    
    for k, itemTechId in ipairs(equippedTechIds) do
    
        local graphicItem = GUIManager:CreateGraphicItem()
        graphicItem:SetSize(GUIMarineBuyMenu.kSmallIconSize)
        graphicItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        graphicItem:SetPosition(Vector(-GUIMarineBuyMenu.kSmallIconSize.x/ 2, GUIMarineBuyMenu.kEquippedIconTopOffset + (GUIMarineBuyMenu.kSmallIconSize.y) * k - GUIMarineBuyMenu.kSmallIconSize.y, 0))
        graphicItem:SetTexture(kInventoryIconsTexture)
        graphicItem:SetTexturePixelCoordinates(GetSmallIconPixelCoordinates(itemTechId))
        
        self.equippedBg:AddChild(graphicItem)
        table.insert(self.equipped, { Graphic = graphicItem, TechId = itemTechId } )
    
    end
    
end

function GUIMarineBuyMenu:_InitializeItemButtons()
    
    self.menu = GetGUIManager():CreateGraphicItem()
    self.menu:SetPosition(Vector( -GUIMarineBuyMenu.kMenuWidth - GUIMarineBuyMenu.kPadding, 0, 0))
    self.menu:SetTexture(GUIMarineBuyMenu.kContentBgTexture)
    self.menu:SetSize(Vector(GUIMarineBuyMenu.kMenuWidth, GUIMarineBuyMenu.kBackgroundHeight, 0))
    self.menu:SetTexturePixelCoordinates(0, 0, GUIMarineBuyMenu.kMenuWidth, GUIMarineBuyMenu.kBackgroundHeight)
    self.content:AddChild(self.menu)
    
    self.menuHeader = GetGUIManager():CreateGraphicItem()
    self.menuHeader:SetSize(Vector(GUIMarineBuyMenu.kMenuWidth, GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.menuHeader:SetPosition(Vector(0, -GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.menuHeader:SetTexture(GUIMarineBuyMenu.kContentBgBackTexture)
    self.menuHeader:SetTexturePixelCoordinates(0, 0, GUIMarineBuyMenu.kMenuWidth, GUIMarineBuyMenu.kResourceDisplayHeight)
    self.menu:AddChild(self.menuHeader) 
    
    self.menuHeaderTitle = GetGUIManager():CreateTextItem()
    self.menuHeaderTitle:SetFontName(GUIMarineBuyMenu.kFont)
    self.menuHeaderTitle:SetScale(GetScaledVector())
    GUIMakeFontScale(self.menuHeaderTitle)
    self.menuHeaderTitle:SetFontIsBold(true)
    self.menuHeaderTitle:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.menuHeaderTitle:SetTextAlignmentX(GUIItem.Align_Center)
    self.menuHeaderTitle:SetTextAlignmentY(GUIItem.Align_Center)
    self.menuHeaderTitle:SetColor(GUIMarineBuyMenu.kTextColor)
    self.menuHeaderTitle:SetText(Locale.ResolveString("BUY"))
    self.menuHeader:AddChild(self.menuHeaderTitle)
    
    self.itemButtons = { }
    
    local itemTechIdList = self.hostStructure:GetItemList(Client.GetLocalPlayer())
    local selectorPosX = -GUIMarineBuyMenu.kSelectorSize.x + GUIMarineBuyMenu.kPadding
    local fontScaleVector = GUIScale(Vector(0.8, 0.8, 0))
    
    for k, itemTechId in ipairs(itemTechIdList) do
    
        local graphicItem = GUIManager:CreateGraphicItem()
        graphicItem:SetSize(GUIMarineBuyMenu.kMenuIconSize)
        graphicItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        graphicItem:SetPosition(Vector(-GUIMarineBuyMenu.kMenuIconSize.x/ 2, GUIMarineBuyMenu.kIconTopOffset + (GUIMarineBuyMenu.kMenuIconSize.y) * k - GUIMarineBuyMenu.kMenuIconSize.y, 0))
        graphicItem:SetTexture(kInventoryIconsTexture)
        graphicItem:SetTexturePixelCoordinates(GetSmallIconPixelCoordinates(itemTechId))
        
        local graphicItemActive = GUIManager:CreateGraphicItem()
        graphicItemActive:SetSize(GUIMarineBuyMenu.kSelectorSize)
        
        graphicItemActive:SetPosition(Vector(selectorPosX, -GUIMarineBuyMenu.kSelectorSize.y / 2, 0))
        graphicItemActive:SetAnchor(GUIItem.Right, GUIItem.Center)
        graphicItemActive:SetTexture(GUIMarineBuyMenu.kMenuSelectionTexture)
        graphicItemActive:SetIsVisible(false)
        
        graphicItem:AddChild(graphicItemActive)
        
        local costIcon = GUIManager:CreateGraphicItem()
        costIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
        costIcon:SetAnchor(GUIItem.Right, GUIItem.Bottom)
        costIcon:SetPosition(Vector(-GUIScale(32), -GUIMarineBuyMenu.kResourceIconHeight * 0.5, 0))
        costIcon:SetTexture(GUIMarineBuyMenu.kResourceIconTexture)
        costIcon:SetColor(GUIMarineBuyMenu.kTextColor)
        
        local selectedArrow = GUIManager:CreateGraphicItem()
        selectedArrow:SetSize(Vector(GUIMarineBuyMenu.kArrowWidth, GUIMarineBuyMenu.kArrowHeight, 0))
        selectedArrow:SetAnchor(GUIItem.Left, GUIItem.Center)
        selectedArrow:SetPosition(Vector(-GUIMarineBuyMenu.kArrowWidth - GUIMarineBuyMenu.kPadding, -GUIMarineBuyMenu.kArrowHeight * 0.5, 0))
        selectedArrow:SetTexture(GUIMarineBuyMenu.kArrowTexture)
        selectedArrow:SetColor(GUIMarineBuyMenu.kTextColor)
        selectedArrow:SetTextureCoordinates(unpack(GUIMarineBuyMenu.kArrowTexCoords))
        selectedArrow:SetIsVisible(false)
        
        graphicItem:AddChild(selectedArrow) 
        
        local itemCost = GUIManager:CreateTextItem()
        itemCost:SetFontName(GUIMarineBuyMenu.kFont)
        itemCost:SetFontIsBold(true)
        itemCost:SetAnchor(GUIItem.Right, GUIItem.Center)
        itemCost:SetPosition(Vector(0, 0, 0))
        itemCost:SetTextAlignmentX(GUIItem.Align_Min)
        itemCost:SetTextAlignmentY(GUIItem.Align_Center)
        itemCost:SetScale(fontScaleVector)
        GUIMakeFontScale(itemCost)
        itemCost:SetColor(GUIMarineBuyMenu.kTextColor)
        itemCost:SetText(ToString(LookupTechData(itemTechId, kTechDataCostKey, 0)))
        
        costIcon:AddChild(itemCost)  
        
        graphicItem:AddChild(costIcon)  
        
        self.menu:AddChild(graphicItem)
        table.insert(self.itemButtons, { Button = graphicItem, Highlight = graphicItemActive, TechId = itemTechId, Cost = itemCost, ResourceIcon = costIcon, Arrow = selectedArrow } )
    
    end
    
    // to prevent wrong display before the first update
    self:_UpdateItemButtons(0)

end

local gResearchToWeaponIds = nil
local function GetItemTechId(researchTechId)

    if not gResearchToWeaponIds then
    
        gResearchToWeaponIds = { }
        gResearchToWeaponIds[kTechId.ShotgunTech] = kTechId.Shotgun
        gResearchToWeaponIds[kTechId.AdvancedWeaponry] = { kTechId.GrenadeLauncher, kTechId.Flamethrower }
        gResearchToWeaponIds[kTechId.WelderTech] = kTechId.Welder
        gResearchToWeaponIds[kTechId.MinesTech] = kTechId.LayMines
        gResearchToWeaponIds[kTechId.JetpackTech] = kTechId.Jetpack
        gResearchToWeaponIds[kTechId.ExosuitTech] = kTechId.Exosuit
        gResearchToWeaponIds[kTechId.DualMinigunTech] = kTechId.DualMinigunExosuit
        gResearchToWeaponIds[kTechId.ClawRailgunTech] = kTechId.ClawRailgunExosuit
        gResearchToWeaponIds[kTechId.DualRailgunTech] = kTechId.DualRailgunExosuit
        
    end
    
    return gResearchToWeaponIds[researchTechId]
    
end

function GUIMarineBuyMenu:_UpdateItemButtons(deltaTime)
    
    if self.itemButtons then
        for i, item in ipairs(self.itemButtons) do
        
            if GetIsMouseOver(self, item.Button) then
            
                item.Highlight:SetIsVisible(true)
                self.hoverItem = item.TechId
                
            else
                item.Highlight:SetIsVisible(false)
            end
            
            local useColor = Color(1, 1, 1, 1)
            
            // set grey if not researched
            if not MarineBuy_IsResearched(item.TechId) then
                useColor = Color(0.75, 0.25, 0.25, 0.35)
            // set red if can't afford
            elseif PlayerUI_GetPlayerResources() < MarineBuy_GetCosts(item.TechId) then
               useColor = Color(1, 0, 0, 1)
            // set normal visible
            elseif MarineBuy_GetHas( item.TechId ) then
                useColor = Color(0.6, 0.6, 0.6, 0.5)
            else

                local newResearchedId = GetItemTechId( PlayerUI_GetRecentPurchaseable() )
                local newlyResearched = false 
                if type(newResearchedId) == "table" then
                    newlyResearched = table.contains(newResearchedId, item.TechId)
                else
                    newlyResearched = newResearchedId == item.TechId
                end
                
                if newlyResearched then
                
                    local anim = math.cos(Shared.GetTime() * 9) * 0.4 + 0.6
                    useColor = Color(1, 1, anim, 1)
                    
                end
               
            end
            
            item.Button:SetColor(useColor)
            item.Highlight:SetColor(useColor)
            item.Cost:SetColor(useColor)
            item.ResourceIcon:SetColor(useColor)
            item.Arrow:SetIsVisible(self.selectedItem == item.TechId)
            
        end
    end

end

function GUIMarineBuyMenu:_UninitializeItemButtons()

    if self.itemButtons then
        for i, item in ipairs(self.itemButtons) do
            GUI.DestroyItem(item.Button)
        end
        self.itemButtons = nil
    end

end

function GUIMarineBuyMenu:_InitializeContent()

    self.itemName = GUIManager:CreateTextItem()
    self.itemName:SetFontName(GUIMarineBuyMenu.kFont)
    self.itemName:SetScale(GetScaledVector())
    self.itemName:SetFontIsBold(true)
    self.itemName:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.itemName:SetPosition(Vector(GUIMarineBuyMenu.kItemNameOffsetX , GUIMarineBuyMenu.kItemNameOffsetY , 0))
    self.itemName:SetTextAlignmentX(GUIItem.Align_Min)
    self.itemName:SetTextAlignmentY(GUIItem.Align_Min)
    self.itemName:SetColor(GUIMarineBuyMenu.kTextColor)
    GUIMakeFontScale(self.itemName)
    self.itemName:SetText("no selection")
    
    self.content:AddChild(self.itemName)
    
    self.portrait = GetGUIManager():CreateGraphicItem()
    self.portrait:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.portrait:SetPosition(Vector(-GUIMarineBuyMenu.kBigIconSize.x/2, GUIMarineBuyMenu.kBigIconOffset, 0))
    self.portrait:SetSize(GUIMarineBuyMenu.kBigIconSize)
    self.portrait:SetTexture(GUIMarineBuyMenu.kBigIconTexture)
    self.portrait:SetTexturePixelCoordinates(GetBigIconPixelCoords(kTechId.Axe))
    self.portrait:SetIsVisible(false)
    self.content:AddChild(self.portrait)
    
    self.itemDescription = GetGUIManager():CreateTextItem()
    self.itemDescription:SetFontName(GUIMarineBuyMenu.kDescriptionFontName)
    self.itemDescription:SetScale(GetScaledVector())
    self.itemDescription:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.itemDescription:SetPosition(Vector(-GUIMarineBuyMenu.kItemDescriptionSize.x / 2, GUIMarineBuyMenu.kItemDescriptionOffsetY, 0))
    self.itemDescription:SetTextAlignmentX(GUIItem.Align_Min)
    self.itemDescription:SetTextAlignmentY(GUIItem.Align_Min)
    self.itemDescription:SetColor(GUIMarineBuyMenu.kTextColor)
    self.itemDescription:SetTextClipped(true, (GUIMarineBuyMenu.kItemDescriptionSize.x - 2*GUIMarineBuyMenu.kPadding)/self.itemDescription:GetScale().x, (GUIMarineBuyMenu.kItemDescriptionSize.y - GUIMarineBuyMenu.kPadding)/self.itemDescription:GetScale().y)
    GUIMakeFontScale(self.itemDescription)
    
    self.content:AddChild(self.itemDescription)
    
end

function GUIMarineBuyMenu:_UpdateContent(deltaTime)

    if self.hoverItem == kTechId.Exosuit or (self.hoverItem == nil and self.hoveringExo) then
        self.hoveringExo = true
        self.portrait:SetIsVisible(true)
		self.portrait:SetTexturePixelCoordinates(GetBigIconPixelCoords(kTechId.DualMinigunExosuit))
        self.itemName:SetIsVisible(false)
        self.itemDescription:SetIsVisible(false)
        self.modularExoConfigActive = true
        for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
            element:SetIsVisible(true)
        end
        
        return
    end
    if self.modularExoGraphicItemsToDestroyList then
        self.hoveringExo = false
        self.modularExoConfigActive = false
        for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
            element:SetIsVisible(false)
        end
    end
    
    local techId = self.hoverItem
    if not self.hoverItem then
        techId = self.selectedItem
    end
    
    if techId then
    
        local researched, researchProgress, researching = self:_GetResearchInfo(techId)
        
        local itemCost = MarineBuy_GetCosts(techId)
        local canAfford = PlayerUI_GetPlayerResources() >= itemCost

        local color = Color(1, 1, 1, 1)
        if not canAfford and researched then
            color = Color(1, 0, 0, 1)
        elseif not researched then
            // Make it clear that we can't buy this
            color = Color(0.5, 0.5, 0.5, .6)
        end
    
        self.itemName:SetColor(color)
        self.portrait:SetColor(color)        
        self.itemDescription:SetColor(color)

        self.itemName:SetText(MarineBuy_GetDisplayName(techId))
        self.portrait:SetTexturePixelCoordinates(GetBigIconPixelCoords(techId, researched))
        self.itemDescription:SetText(MarineBuy_GetWeaponDescription(techId))
        self.itemDescription:SetTextClipped(true, (GUIMarineBuyMenu.kItemDescriptionSize.x - 2*GUIMarineBuyMenu.kPadding)/self.itemDescription:GetScale().x, (GUIMarineBuyMenu.kItemDescriptionSize.y - GUIMarineBuyMenu.kPadding)/self.itemDescription:GetScale().y)

    end
    
    local contentVisible = techId ~= nil and techId ~= kTechId.None
    
    self.portrait:SetIsVisible(contentVisible)
    self.itemName:SetIsVisible(contentVisible)
    self.itemDescription:SetIsVisible(contentVisible)
    
end

function GUIMarineBuyMenu:_UninitializeContent()

    GUI.DestroyItem(self.itemName)

end

function GUIMarineBuyMenu:_InitializeResourceDisplay()
    
    self.resourceDisplayBackground = GUIManager:CreateGraphicItem()
    self.resourceDisplayBackground:SetSize(Vector(GUIMarineBuyMenu.kBackgroundWidth, GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.resourceDisplayBackground:SetPosition(Vector(0, -GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.resourceDisplayBackground:SetTexture(GUIMarineBuyMenu.kContentBgBackTexture)
    self.resourceDisplayBackground:SetTexturePixelCoordinates(0, 0, GUIMarineBuyMenu.kBackgroundWidth, GUIMarineBuyMenu.kResourceDisplayHeight)
    self.content:AddChild(self.resourceDisplayBackground)
    
    self.resourceDisplayIcon = GUIManager:CreateGraphicItem()
    self.resourceDisplayIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth, GUIMarineBuyMenu.kResourceIconHeight, 0))
    self.resourceDisplayIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.resourceDisplayIcon:SetPosition(Vector(-GUIMarineBuyMenu.kResourceIconWidth * 2.2, -GUIMarineBuyMenu.kResourceIconHeight / 2, 0))
    self.resourceDisplayIcon:SetTexture(GUIMarineBuyMenu.kResourceIconTexture)
    self.resourceDisplayIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    self.resourceDisplayBackground:AddChild(self.resourceDisplayIcon)

    self.resourceDisplay = GUIManager:CreateTextItem()
    self.resourceDisplay:SetFontName(GUIMarineBuyMenu.kFont)
    self.resourceDisplay:SetScale(GetScaledVector())
    self.resourceDisplay:SetFontIsBold(true)
    self.resourceDisplay:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.resourceDisplay:SetPosition(Vector(-GUIMarineBuyMenu.kResourceIconWidth * 1.1, 0, 0))
    self.resourceDisplay:SetTextAlignmentX(GUIItem.Align_Min)
    self.resourceDisplay:SetTextAlignmentY(GUIItem.Align_Center)
    GUIMakeFontScale(self.resourceDisplay)
    
    self.resourceDisplay:SetColor(GUIMarineBuyMenu.kTextColor)
    //self.resourceDisplay:SetColor(GUIMarineBuyMenu.kTextColor)
    
    self.resourceDisplay:SetText("")
    self.resourceDisplayBackground:AddChild(self.resourceDisplay)
    
    self.currentDescription = GUIManager:CreateTextItem()
    self.currentDescription:SetFontName(GUIMarineBuyMenu.kFont)
    self.currentDescription:SetScale(GetScaledVector())
    self.currentDescription:SetFontIsBold(true)
    self.currentDescription:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.currentDescription:SetPosition(Vector(-GUIMarineBuyMenu.kResourceIconWidth * 3 , GUIMarineBuyMenu.kResourceIconHeight, 0))
    self.currentDescription:SetTextAlignmentX(GUIItem.Align_Max)
    self.currentDescription:SetTextAlignmentY(GUIItem.Align_Center)
    self.currentDescription:SetColor(GUIMarineBuyMenu.kTextColor)
    self.currentDescription:SetText(Locale.ResolveString("CURRENT"))
    GUIMakeFontScale(self.currentDescription)
    
    self.resourceDisplayBackground:AddChild(self.currentDescription) 

end

function GUIMarineBuyMenu:_UpdateResourceDisplay(deltaTime)

    self.resourceDisplay:SetText(ToString(PlayerUI_GetPlayerResources()))
    
end

function GUIMarineBuyMenu:_UninitializeResourceDisplay()

    GUI.DestroyItem(self.resourceDisplay)
    self.resourceDisplay = nil
    
    GUI.DestroyItem(self.resourceDisplayIcon)
    self.resourceDisplayIcon = nil
    
    GUI.DestroyItem(self.resourceDisplayBackground)
    self.resourceDisplayBackground = nil
    
end

function GUIMarineBuyMenu:_InitializeCloseButton()

    self.closeButton = GUIManager:CreateGraphicItem()
    self.closeButton:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.closeButton:SetSize(Vector(GUIMarineBuyMenu.kButtonWidth, GUIMarineBuyMenu.kButtonHeight, 0))
    self.closeButton:SetPosition(Vector(-GUIMarineBuyMenu.kButtonWidth, GUIMarineBuyMenu.kPadding, 0))
    self.closeButton:SetTexture(GUIMarineBuyMenu.kButtonTexture)
    self.closeButton:SetLayer(kGUILayerPlayerHUDForeground4)
    self.content:AddChild(self.closeButton)
    
    self.closeButtonText = GUIManager:CreateTextItem()
    self.closeButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.closeButtonText:SetFontName(GUIMarineBuyMenu.kFont)
    self.closeButtonText:SetScale(GetScaledVector())
    self.closeButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.closeButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.closeButtonText:SetText(Locale.ResolveString("EXIT"))
    self.closeButtonText:SetFontIsBold(true)
    self.closeButtonText:SetColor(GUIMarineBuyMenu.kCloseButtonColor)
    GUIMakeFontScale(self.closeButtonText)
    self.closeButton:AddChild(self.closeButtonText)
    
end

function GUIMarineBuyMenu:_UpdateCloseButton(deltaTime)

    if GetIsMouseOver(self, self.closeButton) then
        self.closeButton:SetColor(Color(1, 1, 1, 1))
    else
        self.closeButton:SetColor(Color(0.5, 0.5, 0.5, 1))
    end
    
end

function GUIMarineBuyMenu:_UninitializeCloseButton()
    
    GUI.DestroyItem(self.closeButton)
    self.closeButton = nil

end

function GUIMarineBuyMenu:_GetResearchInfo(techId)

    local researched = MarineBuy_IsResearched(techId)
    local researchProgress = 0
    local researching = false
    
    if not researched then    
        researchProgress = MarineBuy_GetResearchProgress(techId)        
    end
    
    if not (researchProgress == 0) then
        researching = true
    end
    
    return researched, researchProgress, researching
end

local function HandleItemClicked(self, mouseX, mouseY)

/*
    if self.itemButtons then
        for i = 1, #self.itemButtons do
        
            local item = self.itemButtons[i]
            if GetIsMouseOver(self, item.Button) then
            
                local researched, researchProgress, researching = self:_GetResearchInfo(item.TechId)
                local itemCost = MarineBuy_GetCosts(item.TechId)
                local canAfford = PlayerUI_GetPlayerResources() >= itemCost
                local hasItem = PlayerUI_GetHasItem(item.TechId)
                
                if researched and canAfford and not hasItem then
                
                    MarineBuy_PurchaseItem(item.TechId)
                    MarineBuy_OnClose()
                    
                    return true, true
                    
                end
                
            end
            
        end
    end
    
    return false, false
    */
    
    ///modular
            for i = 1, #self.itemButtons do
            local item = self.itemButtons[i]
            if item.TechId ~= kTechId.Exosuit and GetIsMouseOver(self, item.Button) then
                local researched, researchProgress, researching = self:_GetResearchInfo(item.TechId)
                local itemCost = MarineBuy_GetCosts(item.TechId)
                local canAfford = PlayerUI_GetPlayerResources() >= itemCost
                local hasItem = PlayerUI_GetHasItem(item.TechId)
                if researched and canAfford and not hasItem then
                    MarineBuy_PurchaseItem(item.TechId)
                    MarineBuy_OnClose()
                    return true, true
                end
            end
        end
        if self.hoveringExo then
            if GetIsMouseOver(self, self.modularExoBuyButton) and MarineBuy_IsResearched(kTechId.Exosuit) then
                Client.SendNetworkMessage("ExoModularBuy", ModularExo_ConvertConfigToNetMessage(self.exoConfig))
                MarineBuy_OnClose()
                return true, true
            end
            for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
                if GetIsMouseOver(self, buttonData.buttonGraphic) then
                    if buttonData.state == "enabled" then
                        self.exoConfig[buttonData.slotType] = buttonData.moduleType
                        if buttonData.forceToDefaultConfig then
                            self.exoConfig[kExoModuleSlots.RightArm] = kExoModuleTypes.Minigun
                            self.exoConfig[kExoModuleSlots.LeftArm ] = kExoModuleTypes.Claw
                            self.exoConfig[kExoModuleSlots.Armor   ] = kExoModuleTypes.None
                            self.exoConfig[kExoModuleSlots.Utility ] = kExoModuleTypes.None
                        end
                        if buttonData.forceLeftToClaw then
                            self.exoConfig[kExoModuleSlots.LeftArm] = kExoModuleTypes.Claw
                        end
                        self:_RefreshExoModularButtons()
                    end
                end
            end
        end
        
        return false, false
        
end

function GUIMarineBuyMenu:SendKeyEvent(key, down)

    local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then
    
        self.mousePressed = down
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if down then
        
            inputHandled, closeMenu = HandleItemClicked(self, mouseX, mouseY)
            
            if not inputHandled then
            
                // Check if the close button was pressed.
                if GetIsMouseOver(self, self.closeButton) then
                
                    closeMenu = true
                    MarineBuy_OnClose()
                    
                end
                
            end
            
        end
        
    end
    
    // No matter what, this menu consumes MouseButton0/1.
    if key == InputKey.MouseButton0 or key == InputKey.MouseButton1 then
        inputHandled = true
    end
    
    if InputKey.Escape == key and not down then
    
        closeMenu = true
        inputHandled = true
        MarineBuy_OnClose()
        
    end
    
    if closeMenu then
    
        self.closingMenu = true
        MarineBuy_Close()
        
    end
    
    return inputHandled
    
end

function  GUIMarineBuyMenu:_InitializeExoModularButtons()
    self.activeExoConfig = nil
    local player = Client.GetLocalPlayer()
    if player and player:isa("Exo") then
        self.activeExoConfig = ModularExo_ConvertNetMessageToConfig(player)
        local isValid, badReason, resourceCost, powerSupply = ModularExo_GetIsConfigValid(self.activeExoConfig)
        self.activeExoConfigResCost = resourceCost
        self.activeExoConfigPowerSupply = powerSupply
        self.exoConfig = self.activeExoConfig
    else
        self.activeExoConfig = {}
        self.activeExoConfigResCost = 0
        self.activeExoConfigPowerSupply = 0
        self.exoConfig = {
            [kExoModuleSlots.PowerSupply] = kExoModuleTypes.Power1,
            [kExoModuleSlots.RightArm   ] = kExoModuleTypes.Minigun,
            [kExoModuleSlots.LeftArm    ] = kExoModuleTypes.Claw,
            [kExoModuleSlots.Armor      ] = kExoModuleTypes.None,
            [kExoModuleSlots.Utility    ] = kExoModuleTypes.None,
        }
    end
    
    self.modularExoConfigActive = false
    self.modularExoGraphicItemsToDestroyList = {} -- WWHHYY UWE, WWWHHHHYYYYYY?!?!¿!?
    self.modularExoModuleButtonList = {}
    
    self.modularExoBuyButton = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoBuyButton)
    self.modularExoBuyButton:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.modularExoBuyButton:SetSize(Vector(GUIMarineBuyMenu.kButtonWidth*1.5, GUIMarineBuyMenu.kButtonHeight, 0))
    self.modularExoBuyButton:SetPosition(Vector(
        GUIMarineBuyMenu.kBackgroundWidth-GUIMarineBuyMenu.kButtonWidth*2.5-GUIMarineBuyMenu.kPadding,
        GUIMarineBuyMenu.kBackgroundHeight+GUIMarineBuyMenu.kPadding, 0
    ))
    self.modularExoBuyButton:SetTexture(GUIMarineBuyMenu.kButtonTexture)
    self.modularExoBuyButton:SetLayer(kGUILayerPlayerHUDForeground4)
    self.content:AddChild(self.modularExoBuyButton)
    
    self.modularExoBuyButtonText = GUIManager:CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoBuyButtonText)
    self.modularExoBuyButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.modularExoBuyButtonText:SetPosition(Vector(-GUIMarineBuyMenu.kPadding*5, 0, 0))
    self.modularExoBuyButtonText:SetFontName(GUIMarineBuyMenu.kFont)
    self.modularExoBuyButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.modularExoBuyButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.modularExoBuyButtonText:SetText("UPGRADE")
    self.modularExoBuyButtonText:SetFontIsBold(true)
    self.modularExoBuyButtonText:SetColor(GUIMarineBuyMenu.kCloseButtonColor)
    self.modularExoBuyButton:AddChild(self.modularExoBuyButtonText)
    
    self.modularExoCostText = GUIManager:CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoCostText)
    self.modularExoCostText:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.modularExoCostText:SetPosition(Vector(-GUIMarineBuyMenu.kPadding*7, 0, 0))
    self.modularExoCostText:SetFontName(GUIMarineBuyMenu.kFont)
    self.modularExoCostText:SetTextAlignmentX(GUIItem.Align_Min)
    self.modularExoCostText:SetTextAlignmentY(GUIItem.Align_Center)
    self.modularExoCostText:SetText("69")
    self.modularExoCostText:SetFontIsBold(true)
    self.modularExoCostText:SetColor(GUIMarineBuyMenu.kTextColor)
    self.modularExoBuyButton:AddChild(self.modularExoCostText)
    
    self.modularExoCostIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoCostIcon)
    self.modularExoCostIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    self.modularExoCostIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.modularExoCostIcon:SetPosition(Vector(-GUIMarineBuyMenu.kPadding*11, -GUIMarineBuyMenu.kResourceIconHeight*0.4, 0))
    self.modularExoCostIcon:SetTexture(GUIMarineBuyMenu.kResourceIconTexture)
    self.modularExoCostIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    self.modularExoBuyButton:AddChild(self.modularExoCostIcon)
    
    for slotType, slotGUIDetails in pairs(GUIMarineBuyMenu.kExoSlotData) do
        local panelBackground = GUIManager:CreateGraphicItem()
        table.insert(self.modularExoGraphicItemsToDestroyList, panelBackground)
        --panelBackground:SetSize()
        --panelBackground:SetAnchor(slotGUIDetails.anchorX or GUIItem.Left, slotGUIDetails.anchorY or GUIItem.Top)
        --panelBackground:SetTexture(GUIMarineBuyMenu.kMenuSelectionTexture)
        panelBackground:SetTexture(GUIMarineBuyMenu.kButtonTexture)
        panelBackground:SetColor(GUIMarineBuyMenu.kSlotPanelBackgroundColor)
        local panelSize = nil
        if slotType == "StatusPanel" then
            local weightLabel = GetGUIManager():CreateTextItem()
            table.insert(self.modularExoGraphicItemsToDestroyList, weightLabel)
            weightLabel:SetFontName(GUIMarineBuyMenu.kFont)
            weightLabel:SetFontIsBold(true)
            weightLabel:SetPosition(Vector(0, GUIMarineBuyMenu.kPadding*1, 0))
            weightLabel:SetAnchor(GUIItem.Center, GUIItem.Top)
            weightLabel:SetTextAlignmentX(GUIItem.Align_Min)
            weightLabel:SetTextAlignmentY(GUIItem.Align_Min)
            weightLabel:SetColor(GUIMarineBuyMenu.kTextColor)
            weightLabel:SetText("FATTY")--(Locale.ResolveString("BUY"))
            panelBackground:AddChild(weightLabel)
			
			local note = GetGUIManager():CreateTextItem()
            table.insert(self.modularExoGraphicItemsToDestroyList, note)
            note:SetFontName(GUIMarineBuyMenu.kFont)
            note:SetFontIsBold(true)
            note:SetPosition(Vector(GUIMarineBuyMenu.kPadding*3, GUIMarineBuyMenu.kPadding*68, 0))
            note:SetAnchor(GUIItem.Center, GUIItem.Bottom)
            note:SetTextAlignmentX(GUIItem.Align_Min)
            note:SetTextAlignmentY(GUIItem.Align_Min)
            note:SetColor(Color(2, 1, 1, 0.5))
            note:SetText("WEAPON ARMS AND UTILITIES USE PERSONAL RESOURCES")
            panelBackground:AddChild(note)
			
			local weight = GetGUIManager():CreateTextItem()
            table.insert(self.modularExoGraphicItemsToDestroyList, weight)
            weight:SetFontName(GUIMarineBuyMenu.kFont)
            weight:SetFontIsBold(true)
            weight:SetPosition(Vector(0, GUIMarineBuyMenu.kPadding*1, 0))
            weight:SetAnchor(GUIItem.Center, GUIItem.Top)
            weight:SetTextAlignmentX(GUIItem.Align_Max)
            weight:SetTextAlignmentY(GUIItem.Align_Min)
            weight:SetColor(GUIMarineBuyMenu.kTextColor)
            weight:SetText("WEIGHT: ")
            panelBackground:AddChild(weight)
            
            panelSize = GUIScale(Vector(GUIScale(174), GUIMarineBuyMenu.kPanelTitleHeight+GUIMarineBuyMenu.kSmallModuleButtonSize.y+GUIMarineBuyMenu.kPadding*-6.0, 0))
            
            self.modularExoWeightLabel = weightLabel
        else
            local slotTypeData = kExoModuleSlotsData[slotType]
            
            local panelTitle = GetGUIManager():CreateTextItem()
            table.insert(self.modularExoGraphicItemsToDestroyList, panelTitle)
            panelTitle:SetFontName(GUIMarineBuyMenu.kFont)
            panelTitle:SetFontIsBold(true)
            panelTitle:SetPosition(Vector(GUIMarineBuyMenu.kPadding*2, GUIMarineBuyMenu.kPadding, 0))
            panelTitle:SetAnchor(GUIItem.Left, GUIItem.Top)
            panelTitle:SetTextAlignmentX(GUIItem.Align_Min)
            panelTitle:SetTextAlignmentY(GUIItem.Align_Min)
            panelTitle:SetColor(GUIMarineBuyMenu.kTextColor)
            panelTitle:SetText(slotGUIDetails.label)--(Locale.ResolveString("BUY"))
            panelBackground:AddChild(panelTitle)
            
            local buttonCount = 0
            local startOffsetX = GUIMarineBuyMenu.kPadding*1
            local startOffsetY = GUIMarineBuyMenu.kPanelTitleHeight
            local offsetX, offsetY = startOffsetX, startOffsetY
            for moduleType, moduleTypeName in ipairs(kExoModuleTypes) do
                local moduleTypeData = kExoModuleTypesData[moduleType]
                local isSameType = (moduleTypeData and moduleTypeData.category == slotTypeData.category)
                if moduleType == kExoModuleTypes.None and not slotTypeData.required then
                    isSameType = true
                    moduleTypeData = {}
                end
                if isSameType then
                    local buttonGraphic, newOffsetX, newOffsetY = slotGUIDetails.makeButton(self, moduleType, moduleTypeData, offsetX, offsetY)
                    if newOffsetX ~= offsetX then offsetX = offsetX+slotGUIDetails.gap end
                    if newOffsetY ~= offsetY then offsetY = offsetY+slotGUIDetails.gap end
                    offsetX, offsetY = newOffsetX, newOffsetY
                    panelBackground:AddChild(buttonGraphic)
                end
            end
            if offsetX == startOffsetX then offsetX = offsetX+GUIMarineBuyMenu.kWideModuleButtonSize.x end -- yolo
            if offsetY == startOffsetY then
                offsetY = offsetY+GUIMarineBuyMenu.kSmallModuleButtonSize.y+GUIMarineBuyMenu.kPadding*0
                panelTitle:SetPosition(Vector(GUIMarineBuyMenu.kPadding*1.85, GUIMarineBuyMenu.kPadding, 0))
            end
            panelSize = Vector(offsetX+GUIMarineBuyMenu.kPadding*1.5, offsetY+GUIMarineBuyMenu.kPadding*1, 0)
            
        end
        panelBackground:SetSize(panelSize)
        local panelX = slotGUIDetails.xp*GUIMarineBuyMenu.kConfigAreaWidth
        local panelY = slotGUIDetails.yp*GUIMarineBuyMenu.kConfigAreaHeight
        if slotGUIDetails.anchorX == GUIItem.Right then
            panelX = panelX-panelSize.x
        end
        panelBackground:SetPosition(Vector(
            GUIMarineBuyMenu.kConfigAreaXOffset+panelX,
            GUIMarineBuyMenu.kConfigAreaYOffset+panelY, 0
        ))
        self.content:AddChild(panelBackground)
    end
end



function GUIMarineBuyMenu:MakePowerModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    local powerSupply = moduleTypeData.powerSupply
    local disabled = false
    if powerSupply < self.activeExoConfigPowerSupply then
        disabled = true
    end
    local buttonGraphic = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetSize(GUIMarineBuyMenu.kSmallModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(offsetX, offsetY, 0))
    buttonGraphic:SetTexture(GUIMarineBuyMenu.kMenuSelectionTexture)
    
    local powerSupplyLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerSupplyLabel)
    powerSupplyLabel:SetPosition(Vector(GUIMarineBuyMenu.kPadding*1, GUIMarineBuyMenu.kPadding*0.3, 0))
    powerSupplyLabel:SetFontName(GUIMarineBuyMenu.kFont)
    powerSupplyLabel:SetAnchor(GUIItem.Left, GUIItem.Top)
    powerSupplyLabel:SetTextAlignmentX(GUIItem.Align_Min)
    powerSupplyLabel:SetTextAlignmentY(GUIItem.Align_Min)
    powerSupplyLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    powerSupplyLabel:SetText(disabled and "---" or "+"..tostring(powerSupply-self.activeExoConfigPowerSupply))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(powerSupplyLabel)
    
    local powerIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerIcon)
    powerIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    powerIcon:SetAnchor(GUIItem.Left, GUIItem.Top)
    powerIcon:SetPosition(Vector(GUIMarineBuyMenu.kPadding*4, GUIMarineBuyMenu.kPadding*0.4, 0))
    powerIcon:SetTexture("ui/buildmenu.dds")
    local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
    powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    powerIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    powerIcon:SetIsVisible(not disabled)
    buttonGraphic:AddChild(powerIcon)
    
    local resCostLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, resCostLabel)
    resCostLabel:SetPosition(Vector(GUIMarineBuyMenu.kPadding*4, GUIMarineBuyMenu.kPadding*-0.3, 0))
    resCostLabel:SetFontName(GUIMarineBuyMenu.kFont)
    resCostLabel:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    resCostLabel:SetTextAlignmentX(GUIItem.Align_Min)
    resCostLabel:SetTextAlignmentY(GUIItem.Align_Max)
    resCostLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    resCostLabel:SetText(disabled and "---" or tostring(moduleTypeData.resourceCost-self.activeExoConfigResCost))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(resCostLabel)
    
    local resIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, resIcon)
    resIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    resIcon:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    resIcon:SetPosition(Vector(GUIMarineBuyMenu.kPadding*0.8, GUIMarineBuyMenu.kPadding*0.15+GUIMarineBuyMenu.kResourceIconHeight*-1, 0))
    resIcon:SetTexture(GUIMarineBuyMenu.kResourceIconTexture)
    resIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    resIcon:SetIsVisible(not disabled)
    buttonGraphic:AddChild(resIcon)
    
    table.insert(self.modularExoModuleButtonList, { -- we need to keep this list so it can change their colour
        powerSupply = moduleTypeData.powerSupply,
        slotType = kExoModuleSlots.PowerSupply,
        moduleType = moduleType,
        buttonGraphic = buttonGraphic,
        powerSupplyLabel = powerSupplyLabel, powerIcon = powerIcon,
        costLabel = resCostLabel, costIcon = resIcon,
        thingsToRecolor = { powerSupplyLabel, powerIcon, resCostLabel, resIcon },
    })
    
    offsetX = offsetX+GUIMarineBuyMenu.kSmallModuleButtonSize.x
    return buttonGraphic, offsetX, offsetY
end

function GUIMarineBuyMenu:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY, slotType)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    
    local buttonGraphic = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetSize(GUIMarineBuyMenu.kWideModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(offsetX, offsetY, 0))
    buttonGraphic:SetTexture(GUIMarineBuyMenu.kMenuSelectionTexture)
    
    local weaponLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, weaponLabel)
    weaponLabel:SetFontName(GUIMarineBuyMenu.kFont)
    weaponLabel:SetPosition(Vector(GUIMarineBuyMenu.kModuleButtonGap*2.3, 0, 0))
    weaponLabel:SetAnchor(GUIItem.Left, GUIItem.Top)
    weaponLabel:SetTextAlignmentX(GUIItem.Align_Min)
    weaponLabel:SetTextAlignmentY(GUIItem.Align_Min)
    weaponLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    weaponLabel:SetText(tostring(moduleTypeGUIDetails.label))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(weaponLabel)
    
    local weaponImage = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, weaponImage)
    weaponImage:SetPosition(Vector(GUIMarineBuyMenu.kWeaponImageSize.x*-0.85, GUIMarineBuyMenu.kWeaponImageSize.y*-1, 0))
    weaponImage:SetSize(GUIMarineBuyMenu.kWeaponImageSize)
    weaponImage:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    weaponImage:SetTexture(moduleTypeGUIDetails.image)
    weaponImage:SetTexturePixelCoordinates(unpack(moduleTypeGUIDetails.imageTexCoords))
    weaponImage:SetColor(Color(1, 1, 1, 1))
    buttonGraphic:AddChild(weaponImage)
    
    local powerCostLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerCostLabel)
    powerCostLabel:SetPosition(Vector(GUIMarineBuyMenu.kModuleButtonGap*2.3, -GUIMarineBuyMenu.kPadding*0.5, 0))
    powerCostLabel:SetFontName(GUIMarineBuyMenu.kFont)
    powerCostLabel:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerCostLabel:SetTextAlignmentX(GUIItem.Align_Min)
    powerCostLabel:SetTextAlignmentY(GUIItem.Align_Max)
    powerCostLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    powerCostLabel:SetText(tostring(moduleTypeData.resourceCost))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(powerCostLabel)
    
    local powerIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerIcon)
    powerIcon:SetPosition(Vector(GUIMarineBuyMenu.kModuleButtonGap*5.3, -GUIMarineBuyMenu.kPadding*0.8+GUIMarineBuyMenu.kResourceIconHeight * -0.8, 0))
    powerIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    powerIcon:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerIcon:SetTexture(GUIMarineBuyMenu.kResourceIconTexture)
    //local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
   // powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    powerIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    buttonGraphic:AddChild(powerIcon)
    
    table.insert(self.modularExoModuleButtonList, {
        slotType = slotType,
        moduleType = moduleType,
        buttonGraphic = buttonGraphic,
        weaponLabel = weaponLabel, weaponImage = weaponImage,
        costLabel = powerCostLabel, costIcon = powerIcon,
        thingsToRecolor = { weaponLabel, --[[weaponImage,]] powerCostLabel, powerIcon},
    })
    
    offsetY = offsetY+GUIMarineBuyMenu.kWideModuleButtonSize.y
    return buttonGraphic, offsetX, offsetY
end

function GUIMarineBuyMenu:MakeUtilityModuleButton(moduleType, moduleTypeData, offsetX, offsetY, slotType)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    
    local buttonGraphic = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetSize(GUIMarineBuyMenu.kMediumModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(offsetX, offsetY, 0))
    buttonGraphic:SetTexture(GUIMarineBuyMenu.kMenuSelectionTexture)
    
    local utilityLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, utilityLabel)
    utilityLabel:SetFontName(GUIMarineBuyMenu.kFont)
    utilityLabel:SetPosition(Vector(GUIMarineBuyMenu.kModuleButtonGap*1.7, 0, 0))
    utilityLabel:SetAnchor(GUIItem.Left, GUIItem.Top)
    utilityLabel:SetTextAlignmentX(GUIItem.Align_Min)
    utilityLabel:SetTextAlignmentY(GUIItem.Align_Min)
    utilityLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    utilityLabel:SetText(tostring(moduleTypeGUIDetails.label))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(utilityLabel)
    
    local utilityImage = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, utilityImage)
    utilityImage:SetPosition(Vector(GUIMarineBuyMenu.kWeaponImageSize.x*-0.45, GUIMarineBuyMenu.kWeaponImageSize.y*-1, 0))
    utilityImage:SetSize(GUIMarineBuyMenu.kUtilityImageSize)
    utilityImage:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    utilityImage:SetTexture(moduleTypeGUIDetails.image)
    utilityImage:SetTexturePixelCoordinates(unpack(moduleTypeGUIDetails.imageTexCoords))
    utilityImage:SetColor(Color(1, 1, 1, 1))
    buttonGraphic:AddChild(utilityImage)
    
    local powerCostLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerCostLabel)
    powerCostLabel:SetPosition(Vector(GUIMarineBuyMenu.kModuleButtonGap*2.3, -GUIMarineBuyMenu.kPadding*0.5, 0))
    powerCostLabel:SetFontName(GUIMarineBuyMenu.kFont)
    powerCostLabel:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerCostLabel:SetTextAlignmentX(GUIItem.Align_Min)
    powerCostLabel:SetTextAlignmentY(GUIItem.Align_Max)
    powerCostLabel:SetColor(GUIMarineBuyMenu.kTextColor)
    powerCostLabel:SetText(tostring(moduleTypeData.resourceCost or "0"))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(powerCostLabel)
    
    local powerIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerIcon)
    powerIcon:SetPosition(Vector(GUIMarineBuyMenu.kModuleButtonGap*4.3, -GUIMarineBuyMenu.kPadding*0.5+GUIMarineBuyMenu.kResourceIconHeight * -0.8, 0))
    powerIcon:SetSize(Vector(GUIMarineBuyMenu.kResourceIconWidth * 0.8, GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
    powerIcon:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerIcon:SetTexture(GUIMarineBuyMenu.kResourceIconTexture)
    //local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
   // powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    powerIcon:SetColor(GUIMarineBuyMenu.kTextColor)
    buttonGraphic:AddChild(powerIcon)
    
    table.insert(self.modularExoModuleButtonList, {
        slotType = kExoModuleSlots.Utility,
        moduleType = moduleType,
        buttonGraphic = buttonGraphic,
        utilityLabel = utilityLabel, utilityImage = utilityImage,
        costLabel = powerCostLabel, costIcon = powerIcon,
        thingsToRecolor = { utilityLabel, --[[utilityImage,]] powerCostLabel, powerIcon},
    })
    
    offsetX = offsetX+GUIMarineBuyMenu.kMediumModuleButtonSize.x
    return buttonGraphic, offsetX, offsetY
end
function GUIMarineBuyMenu:_UpdateExoModularButtons(deltaTime)
    if self.hoveringExo then
        self:_RefreshExoModularButtons()
        if not MarineBuy_IsResearched(kTechId.Exosuit) or PlayerUI_GetPlayerResources() < self.exoConfigResourceCost-self.activeExoConfigResCost then
            self.modularExoBuyButton:SetColor(Color(1, 0, 0, 1))
            
            self.modularExoBuyButtonText:SetColor(Color(0.5, 0.5, 0.5, 1))
            self.modularExoCostText:SetColor(GUIMarineBuyMenu.kCannotBuyColor)
            self.modularExoCostIcon:SetColor(GUIMarineBuyMenu.kCannotBuyColor)
        else
            if GetIsMouseOver(self, self.modularExoBuyButton) then
                self.modularExoBuyButton:SetColor(Color(1, 1, 1, 1))
            else
                self.modularExoBuyButton:SetColor(Color(0.5, 0.5, 0.5, 1))
            end
            
            self.modularExoBuyButtonText:SetColor(GUIMarineBuyMenu.kCloseButtonColor)
            self.modularExoCostText:SetColor(GUIMarineBuyMenu.kTextColor)
            self.modularExoCostIcon:SetColor(GUIMarineBuyMenu.kTextColor)
        end
        for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
            if GetIsMouseOver(self, buttonData.buttonGraphic) then
                if buttonData.state == "enabled" then
                    buttonData.buttonGraphic:SetColor(Color(0, 0.7, 1, 1))
                end
            else
                buttonData.buttonGraphic:SetColor(buttonData.col)
            end
        end
    end
end

function GUIMarineBuyMenu:_RefreshExoModularButtons()
    local isValid, badReason, resourceCost, powerSupply, powerCost, texturePath = ModularExo_GetIsConfigValid(self.exoConfig)
    resourceCost = resourceCost or 0
    self.exoConfigResourceCost = resourceCost
    if not self.activeExoConfigResCost then self.activeExoConfigResCost = 0 end
    self.modularExoCostText:SetText(tostring(resourceCost-self.activeExoConfigResCost))
    //self.modularExoPowerUsageLabel:SetText(tostring(powerCost).." of "..tostring(powerSupply))
    self.exoConfigWeight = ModularExo_GetConfigWeight(self.exoConfig)
    local weightLabel, weightCol = "?!?", Color(1, 0.7, 0.7, 1)
    for weightClassI, weightClass in ipairs(GUIMarineBuyMenu.kWeightLabelData) do
        if self.exoConfigWeight >= weightClass.min then
            weightLabel, weightCol = weightClass.label, weightClass.col
        end
    end
    self.modularExoWeightLabel:SetText(tostring(weightLabel))
    self.modularExoWeightLabel:SetColor(weightCol)
    
    for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
        local current = self.exoConfig[buttonData.slotType]
        local col = nil
        local canAfford = true
        if current == buttonData.moduleType then
            if PlayerUI_GetPlayerResources() < self.exoConfigResourceCost-self.activeExoConfigResCost then
                //buttonData.state = "disabled"
               /// buttonData.buttonGraphic:SetColor(GUIMarineBuyMenu.kDisabledColor)
                col = GUIMarineBuyMenu.kDisabledColor
                //canAfford = false
            else
                buttonData.state = "selected"
                buttonData.buttonGraphic:SetColor(GUIMarineBuyMenu.kEnabledColor)
                col = GUIMarineBuyMenu.kEnabledColor
            end
        else
            self.exoConfig[buttonData.slotType] = buttonData.moduleType
            local isValid, badReason, resourceCost, powerSupply, powerCost, texturePath = ModularExo_GetIsConfigValid(self.exoConfig)
            if buttonData.slotType == kExoModuleSlots.PowerSupply then
                if buttonData.powerSupply < self.activeExoConfigPowerSupply then
                    isValid = false
                    badReason = "no refunds!"
                elseif isValid then
                    resourceCost = resourceCost-self.activeExoConfigResCost
                    if PlayerUI_GetPlayerResources() < resourceCost then
                        isValid = false
                        canAfford = false
                    end
                elseif badReason == "not enough power" then
                    isValid = true
                    buttonData.forceToDefaultConfig = true
                else
                    buttonData.forceToDefaultConfig = false
                end
            end
            if buttonData.slotType == kExoModuleSlots.RightArm and badReason == "bad model left" then
                isValid = true
                buttonData.forceLeftToClaw = true
            else
                buttonData.forceLeftToClaw = false
            end
            if isValid then
                buttonData.state = "enabled"
                buttonData.buttonGraphic:SetColor(GUIMarineBuyMenu.kDisabledColor)
                col = GUIMarineBuyMenu.kDisabledColor
            else
                buttonData.state = "disabled"
                buttonData.buttonGraphic:SetColor(GUIMarineBuyMenu.kDisabledColor)
                col = GUIMarineBuyMenu.kDisabledColor
                if badReason == "not enough power" then
                    canAfford = false
                end
            end
            if not isValid and (badReason == "bad model right" or badReason == "bad model left") then
                col = Color(0.2, 0.2, 0.2, 0.4)
                buttonData.weaponImage:SetColor(Color(0.2, 0.2, 0.2, 0.4))
            elseif buttonData.weaponImage ~= nil then
                buttonData.weaponImage:SetColor(Color(1, 1, 1, 1))
            end
            self.exoConfig[buttonData.slotType] = current
        end
        buttonData.col = col
        for thingI, thing in ipairs(buttonData.thingsToRecolor) do
            thing:SetColor(col)
        end
        if not canAfford then
            if buttonData.costLabel then buttonData.costLabel:SetColor(GUIMarineBuyMenu.kCannotBuyColor) end
            if buttonData.costIcon then buttonData.costIcon:SetColor(GUIMarineBuyMenu.kCannotBuyColor) end
        end
    end
end
function GetIsMouseOver(self, overItem) -- WHY IS THIS NOT GLOBAL OR A CLASS METHOD?!?!?

    local mouseOver = GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    if mouseOver and not self.mouseOverStates[overItem] then
        MarineBuy_OnMouseOver()
    end
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver
    
end
//////////////data

GUIMarineBuyMenu.kWeightLabelData = {
    { min = 0.00, label = "LIGHT" , col = Color(0, 1, 0, 1), },
    { min = 0.10, label = "MEDIUM", col = Color(1, 1, 0, 1), },
    { min = 0.20, label = "HEAVY" , col = Color(1, 0, 0, 1), },
}


local function GetBuildIconPixelCoords(techId)
    local iconX, iconY = GetMaterialXYOffset(techId)
    return iconX*80, iconY*80, iconX*80+80, iconY*80+80
end

GUIMarineBuyMenu.kExoModuleData = {
    -- Power modules
    [kExoModuleTypes.Power1] = {
        label = "EXO_POWER_1", tooltip = "EXO_POWER_1_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    [kExoModuleTypes.Power2] = {
        label = "EXO_POWER_2", tooltip = "EXO_POWER_2_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    [kExoModuleTypes.Power3] = {
        label = "EXO_POWER_3", tooltip = "EXO_POWER_3_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    [kExoModuleTypes.Power4] = {
        label = "EXO_POWER_4", tooltip = "EXO_POWER_4_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    [kExoModuleTypes.Power5] = {
        label = "EXO_POWER_5", tooltip = "EXO_POWER_5_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
	[kExoModuleTypes.Power6] = {
        label = "EXO_POWER_6", tooltip = "EXO_POWER_6_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    
    -- Weapon modules
	[kExoModuleTypes.Claw] = {
        label = "CLAW", tooltip = "EXO_WEAPON_CLAW_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Claw)},
    },
    [kExoModuleTypes.Welder] = {
        label = "WELDER", tooltip = "EXO_WEAPON_WELDER_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Welder)},
    }, 
    [kExoModuleTypes.Minigun] = {
        label = "MINIGUN", tooltip = "EXO_WEAPON_MMINIGUN_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Exosuit)},
    }, 
	[kExoModuleTypes.Railgun] = {
        label = "RAILGUN", tooltip = "EXO_WEAPON_RAILGUN_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.ClawRailgunExosuit)},
    },
    [kExoModuleTypes.Flamethrower] = {
        label = "FLAMETHROWER", tooltip = "EXO_WEAPON_FLAMETHROWER_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Flamethrower)},
    },
    
    -- Armor modules
    [kExoModuleTypes.Armor1] = {
        label = "ARMOR", tooltip = "EXO_ARMOR_1_TOOLTIP",
        image = "ui/buildmenu.dds",
        imageTexCoords = {GetBuildIconPixelCoords(kTechId.FollowAndWeld)},
    },
    [kExoModuleTypes.Armor2] = {
        label = "EXO_ARMOR_2", tooltip = "EXO_ARMOR_2_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
	[kExoModuleTypes.Armor3] = {
        label = "EXO_ARMOR_3", tooltip = "EXO_ARMOR_3_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    
    -- Damage modules
    [kExoModuleTypes.Damage1] = {
        label = "EXO_DAMAGE_1", tooltip = "EXO_DAMAGE_1_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
	[kExoModuleTypes.Damage2] = {
        label = "EXO_DAMAGE_2", tooltip = "EXO_DAMAGE_2_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
	[kExoModuleTypes.Damage3] = {
        label = "EXO_DAMAGE_3", tooltip = "EXO_DAMAGE_3_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    
    -- Utility modules
    [kExoModuleTypes.PhaseGate] = {
        label = "PhaseGate", tooltip = "Use the phase gate!",
        image = "ui/buildmenu.dds",
        imageTexCoords = {GetBuildIconPixelCoords(kTechId.RootMenu)},
    },
        [kExoModuleTypes.Nano] = {
        label = "Regen", tooltip = "Self repairing armor",
        image = "ui/buildmenu.dds",
        imageTexCoords = {GetBuildIconPixelCoords(kTechId.RootMenu)},
    },
    [kExoModuleTypes.None] = {
        label = "NONE", tooltip = "It appears to be a lot of nothing.",
        image = "ui/buildmenu.dds",
        imageTexCoords = {GetBuildIconPixelCoords(kTechId.Stop)},
    },
}

/////////////////////////
/*
GUIMarineBuyMenu.kJetpackModuleData = {
    -- Power modules
    [kJetpackModuleTypes.Power1] = {
        label = "EXO_POWER_1", tooltip = "EXO_POWER_1_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    [kJetpackModuleTypes.Power2] = {
        label = "EXO_POWER_2", tooltip = "EXO_POWER_2_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    [kJetpackModuleTypes.Power3] = {
        label = "EXO_POWER_3", tooltip = "EXO_POWER_3_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    [kJetpackModuleTypes.Power4] = {
        label = "EXO_POWER_4", tooltip = "EXO_POWER_4_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    [kJetpackModuleTypes.Power5] = {
        label = "EXO_POWER_5", tooltip = "EXO_POWER_5_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
	[kJetpackModuleTypes.Power6] = {
        label = "EXO_POWER_6", tooltip = "EXO_POWER_6_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    
    -- Weapon modules
	[kJetpackModuleTypes.Claw] = {
        label = "CLAW", tooltip = "EXO_WEAPON_CLAW_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Claw)},
    },
    [kJetpackModuleTypes.Welder] = {
        label = "WELDER", tooltip = "EXO_WEAPON_WELDER_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Welder)},
    }, 
    [kJetpackModuleTypes.Minigun] = {
        label = "MINIGUN", tooltip = "EXO_WEAPON_MMINIGUN_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Exosuit)},
    }, 
	[kJetpackModuleTypes.Railgun] = {
        label = "RAILGUN", tooltip = "EXO_WEAPON_RAILGUN_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.ClawRailgunExosuit)},
    },
    [kJetpackModuleTypes.Flamethrower] = {
        label = "FLAMETHROWER", tooltip = "EXO_WEAPON_FLAMETHROWER_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Flamethrower)},
    },
    
    -- Armor modules
    [kJetpackModuleTypes.Armor1] = {
        label = "ARMOR", tooltip = "EXO_ARMOR_1_TOOLTIP",
        image = "ui/buildmenu.dds",
        imageTexCoords = {GetBuildIconPixelCoords(kTechId.FollowAndWeld)},
    },
    [kJetpackModuleTypes.Armor2] = {
        label = "EXO_ARMOR_2", tooltip = "EXO_ARMOR_2_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
	[kJetpackModuleTypes.Armor3] = {
        label = "EXO_ARMOR_3", tooltip = "EXO_ARMOR_3_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    
    -- Damage modules
    [kJetpackModuleTypes.Damage1] = {
        label = "EXO_DAMAGE_1", tooltip = "EXO_DAMAGE_1_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
	[kJetpackModuleTypes.Damage2] = {
        label = "EXO_DAMAGE_2", tooltip = "EXO_DAMAGE_2_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
	[kJetpackModuleTypes.Damage3] = {
        label = "EXO_DAMAGE_3", tooltip = "EXO_DAMAGE_3_TOOLTIP",
        image = kInventoryIconsTexture,
        imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Axe)},
    },
    
    -- Utility modules
    [kJetpackModuleTypes.PhaseGate] = {
        label = "PhaseGate", tooltip = "Use the phase gate!",
        image = "ui/buildmenu.dds",
        imageTexCoords = {GetBuildIconPixelCoords(kTechId.RootMenu)},
    },
        [kJetpackModuleTypes.Nano] = {
        label = "Regen", tooltip = "Self repairing armor",
        image = "ui/buildmenu.dds",
        imageTexCoords = {GetBuildIconPixelCoords(kTechId.RootMenu)},
    },
    [kJetpackModuleTypes.None] = {
        label = "NONE", tooltip = "It appears to be a lot of nothing.",
        image = "ui/buildmenu.dds",
        imageTexCoords = {GetBuildIconPixelCoords(kTechId.Stop)},
    },
}
*/

Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIMarineCreditMenu' (GUIAnimatedScript)


GUIMarineCreditMenu.kMenuWidth = GUIScale(190)
GUIMarineCreditMenu.kPadding = GUIScale(8)
GUIMarineCreditMenu.kBackgroundWidth = GUIScale(600)
GUIMarineCreditMenu.kBackgroundHeight = GUIScale(720)

GUIMarineCreditMenu.kConfigAreaXOffset = GUIMarineCreditMenu.kPadding
GUIMarineCreditMenu.kConfigAreaYOffset = GUIMarineCreditMenu.kPadding
GUIMarineCreditMenu.kUpgradeButtonAreaHeight = GUIScale(30)
--GUIMarineCreditMenu.kUpgradeButtonWidth = GUIScale(160)
--GUIMarineCreditMenu.kUpgradeButtonHeight = GUIScale(64)
GUIMarineCreditMenu.kConfigAreaWidth = (
        GUIMarineCreditMenu.kBackgroundWidth
    -   GUIMarineCreditMenu.kPadding*2
)
GUIMarineCreditMenu.kConfigAreaHeight = (
        GUIMarineCreditMenu.kBackgroundHeight
    -   GUIMarineCreditMenu.kUpgradeButtonAreaHeight
    -   GUIMarineCreditMenu.kPadding*3
)
GUIMarineCreditMenu.kSlotPanelBackgroundColor = Color(1, 1, 1, 0.5)

GUIMarineCreditMenu.kWideModuleButtonSize = GUIScale(Vector(150, 60, 0))
GUIMarineCreditMenu.kMediumModuleButtonSize = GUIScale(Vector(100, 60, 0))
GUIMarineCreditMenu.kWeaponImageSize = GUIScale(Vector(80, 40, 0))
GUIMarineCreditMenu.kUtilityImageSize = GUIScale(Vector(39, 39, 0))
GUIMarineCreditMenu.kModuleButtonGap = GUIScale(7)
GUIMarineCreditMenu.kPanelTitleHeight = GUIScale(35)











GUIMarineCreditMenu.kBuyMenuTexture = "ui/marine_buy_textures.dds"
GUIMarineCreditMenu.kBuyHUDTexture = "ui/marine_buy_icons.dds"
GUIMarineCreditMenu.kRepeatingBackground = "ui/menu/grid.dds"
GUIMarineCreditMenu.kContentBgTexture = "ui/menu/repeating_bg.dds"
GUIMarineCreditMenu.kContentBgBackTexture = "ui/menu/repeating_bg_black.dds"
GUIMarineCreditMenu.kResourceIconTexture = "ui/pres_icon_big.dds"
GUIMarineCreditMenu.kBigIconTexture = "ui/creditbuy.dds"
GUIMarineCreditMenu.kButtonTexture = "ui/marine_buymenu_button.dds"
GUIMarineCreditMenu.kMenuSelectionTexture = "ui/marine_buymenu_selector.dds"
GUIMarineCreditMenu.kScanLineTexture = "ui/menu/scanLine_big.dds"
GUIMarineCreditMenu.kArrowTexture = "ui/menu/arrow_horiz.dds"
GUIMarineCreditMenu.kSmallIcons = "ui/creditmenu.dds"

GUIMarineCreditMenu.kFont = Fonts.kAgencyFB_Small


GUIMarineCreditMenu.kScanLineAnimDuration = 5

GUIMarineCreditMenu.kArrowTexCoords = { 1, 1, 0, 0 }


local gBigIconIndex = nil
local bigIconWidth = 400
local bigIconHeight = 300
local function GetBigIconPixelCoords(techId, researched)

    if not gBigIconIndex then
    
        gBigIconIndex = {}
        gBigIconIndex[kTechId.LayStructures] = 0
        gBigIconIndex[kTechId.LayStructureIP] = 1
        gBigIconIndex[kTechId.LayStructurePG] = 2
        gBigIconIndex[kTechId.LayStructureRobo] = 3
        gBigIconIndex[kTechId.LayStructureSentry] = 2
        gBigIconIndex[kTechId.LayStructureObs] = 4

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
        
        gSmallIconIndex[kTechId.LayStructures] = 4
        gSmallIconIndex[kTechId.LayStructureIP] = 3
        gSmallIconIndex[kTechId.LayStructurePG] = 1
        gSmallIconIndex[kTechId.LayStructureRobo] = 1
        gSmallIconIndex[kTechId.LayStructureSentry] = 5
        gSmallIconIndex[kTechId.LayStructureObs] = 35
    end
    
    local index = gSmallIconIndex[itemTechId]
    if not index then
        index = 0
    end
    
    local y1 = index * smallIconHeight
    local y2 = (index + 1) * smallIconHeight
    
    return 0, y1, smallIconWidth, y2

end
                            
GUIMarineCreditMenu.kTextColor = Color(kMarineFontColor)

GUIMarineCreditMenu.kDisabledColor = Color(0.5, 0.5, 0.5, 0.5)
GUIMarineCreditMenu.kCannotBuyColor = Color(1, 0, 0, 0.5)
GUIMarineCreditMenu.kEnabledColor = Color(1, 1, 1, 1)

GUIMarineCreditMenu.kCloseButtonColor = Color(1, 1, 0, 1)

function GUIMarineCreditMenu:OnClose()

    // Check if GUIMarineCreditMenu is what is causing itself to close.
    if not self.closingMenu then
        // Play the close sound since we didn't trigger the close.
        MarineBuy_OnClose()
    end

end

local function UpdateItemsGUIScale(self)
    GUIMarineCreditMenu.kScanLineHeight = GUIScale(256)
    GUIMarineCreditMenu.kArrowWidth = GUIScale(32)
    GUIMarineCreditMenu.kArrowHeight = GUIScale(32)

    // Big Item Icons
    GUIMarineCreditMenu.kBigIconSize = GUIScale( Vector(320, 256, 0) )
    GUIMarineCreditMenu.kBigIconOffset = GUIScale(20)

    GUIMarineCreditMenu.kSmallIconSize = GUIScale( Vector(100, 50, 0) )
    GUIMarineCreditMenu.kMenuIconSize = GUIScale( Vector(190, 80, 0) ) * kSmallIconScale
    GUIMarineCreditMenu.kSelectorSize = GUIScale( Vector(215, 110, 0) ) * kSmallIconScale
    GUIMarineCreditMenu.kIconTopOffset = GUIScale(10)
    GUIMarineCreditMenu.kItemIconYOffset = {}


    GUIMarineCreditMenu.kMenuWidth = GUIScale(190)
    GUIMarineCreditMenu.kPadding = GUIScale(8)



    GUIMarineCreditMenu.kBackgroundWidth = GUIScale(600)
    GUIMarineCreditMenu.kBackgroundHeight = GUIScale(640)
    // We want the background graphic to look centered around the circle even though there is the part coming off to the right.
    GUIMarineCreditMenu.kBackgroundXOffset = GUIScale(0)

    GUIMarineCreditMenu.kPlayersTextSize = GUIScale(24)
    GUIMarineCreditMenu.kResearchTextSize = GUIScale(24)

    GUIMarineCreditMenu.kResourceDisplayHeight = GUIScale(64)

    GUIMarineCreditMenu.kResourceIconWidth = GUIScale(32)
    GUIMarineCreditMenu.kResourceIconHeight = GUIScale(32)

    GUIMarineCreditMenu.kMouseOverInfoTextSize = GUIScale(20)
    GUIMarineCreditMenu.kMouseOverInfoOffset = Vector(GUIScale(-30), GUIScale(-20), 0)
    GUIMarineCreditMenu.kMouseOverInfoResIconOffset = Vector(GUIScale(-40), GUIScale(-60), 0)

    GUIMarineCreditMenu.kButtonWidth = GUIScale(160)
    GUIMarineCreditMenu.kButtonHeight = GUIScale(64)

    GUIMarineCreditMenu.kItemNameOffsetX = GUIScale(28)
    GUIMarineCreditMenu.kItemNameOffsetY = GUIScale(256)

end

function GUIMarineCreditMenu:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
    
    MarineBuy_OnClose()
end

function GUIMarineCreditMenu:Initialize()

    GUIAnimatedScript.Initialize(self)

    UpdateItemsGUIScale(self)
    
    self.mouseOverStates = { }

    
    self.selectedItem = kTechId.None
    
    self:_InitializeBackground()
    self:_InitializeContent()
    self:_InitializeResourceDisplay()
    self:_InitializeCloseButton()
    self:_InitializeItemButtons()

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

function GUIMarineCreditMenu:Update(deltaTime)
  
    PROFILE("GUIMarineCreditMenu:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)

    self:_UpdateItemButtons(deltaTime)
    self:_UpdateContent(deltaTime)
    self:_UpdateResourceDisplay(deltaTime)
    self:_UpdateCloseButton(deltaTime)
    
end

function GUIMarineCreditMenu:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)

    self:_UninitializeItemButtons()
    self:_UninitializeBackground()
    self:_UninitializeContent()
    self:_UninitializeResourceDisplay()
    self:_UninitializeCloseButton()

end

local function MoveDownAnim(script, item)

    item:SetPosition( Vector(0, -GUIMarineCreditMenu.kScanLineHeight, 0) )
    item:SetPosition( Vector(0, Client.GetScreenHeight() + GUIMarineCreditMenu.kScanLineHeight, 0), GUIMarineCreditMenu.kScanLineAnimDuration, "MARINEBUY_SCANLINE", AnimateLinear, MoveDownAnim)

end

function GUIMarineCreditMenu:_InitializeBackground()

    // This invisible background is used for centering only.
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetColor(Color(0.05, 0.05, 0.1, 0.7))
    self.background:SetLayer(kGUILayerPlayerHUDForeground4)
    
    self.repeatingBGTexture = GUIManager:CreateGraphicItem()
    self.repeatingBGTexture:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.repeatingBGTexture:SetTexture(GUIMarineCreditMenu.kRepeatingBackground)
    self.repeatingBGTexture:SetTexturePixelCoordinates(0, 0, Client.GetScreenWidth(), Client.GetScreenHeight())
    self.background:AddChild(self.repeatingBGTexture)
    
    self.content = GUIManager:CreateGraphicItem()
    self.content:SetSize(Vector(GUIMarineCreditMenu.kBackgroundWidth, GUIMarineCreditMenu.kBackgroundHeight, 0))
    self.content:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.content:SetPosition(Vector((-GUIMarineCreditMenu.kBackgroundWidth / 2) + GUIMarineCreditMenu.kBackgroundXOffset, -GUIMarineCreditMenu.kBackgroundHeight / 2, 0))
    self.content:SetTexture(GUIMarineCreditMenu.kContentBgTexture)
    self.content:SetTexturePixelCoordinates(0, 0, GUIMarineCreditMenu.kBackgroundWidth, GUIMarineCreditMenu.kBackgroundHeight)
    self.content:SetColor( Color(1,1,1,0.8) )
    self.background:AddChild(self.content)
    
    self.scanLine = self:CreateAnimatedGraphicItem()
    self.scanLine:SetSize( Vector( Client.GetScreenWidth(), GUIMarineCreditMenu.kScanLineHeight, 0) )
    self.scanLine:SetTexture(GUIMarineCreditMenu.kScanLineTexture)
    self.scanLine:SetLayer(kGUILayerPlayerHUDForeground4)
    self.scanLine:SetIsScaling(false)
    
    self.scanLine:SetPosition( Vector(0, -GUIMarineCreditMenu.kScanLineHeight, 0) )
    self.scanLine:SetPosition( Vector(0, Client.GetScreenHeight() + GUIMarineCreditMenu.kScanLineHeight, 0), GUIMarineCreditMenu.kScanLineAnimDuration, "MARINEBUY_SCANLINE", AnimateLinear, MoveDownAnim)

end

function GUIMarineCreditMenu:_UninitializeBackground()

    GUI.DestroyItem(self.background)
    self.background = nil
    
    self.content = nil
    
end

function GUIMarineCreditMenu:_InitializeItemButtons()
    
    self.menu = GetGUIManager():CreateGraphicItem()
    self.menu:SetPosition(Vector( -GUIMarineCreditMenu.kMenuWidth - GUIMarineCreditMenu.kPadding, 0, 0))
    self.menu:SetTexture(GUIMarineCreditMenu.kContentBgTexture)
    self.menu:SetSize(Vector(GUIMarineCreditMenu.kMenuWidth, GUIMarineCreditMenu.kBackgroundHeight, 0))
    self.menu:SetTexturePixelCoordinates(0, 0, GUIMarineCreditMenu.kMenuWidth, GUIMarineCreditMenu.kBackgroundHeight)
    self.content:AddChild(self.menu)
    
    self.menuHeader = GetGUIManager():CreateGraphicItem()
    self.menuHeader:SetSize(Vector(GUIMarineCreditMenu.kMenuWidth, GUIMarineCreditMenu.kResourceDisplayHeight, 0))
    self.menuHeader:SetPosition(Vector(0, -GUIMarineCreditMenu.kResourceDisplayHeight, 0))
    self.menuHeader:SetTexture(GUIMarineCreditMenu.kContentBgBackTexture)
    self.menuHeader:SetTexturePixelCoordinates(0, 0, GUIMarineCreditMenu.kMenuWidth, GUIMarineCreditMenu.kResourceDisplayHeight)
    self.menu:AddChild(self.menuHeader) 
    
    self.menuHeaderTitle = GetGUIManager():CreateTextItem()
    self.menuHeaderTitle:SetFontName(GUIMarineCreditMenu.kFont)
    self.menuHeaderTitle:SetScale(GetScaledVector())
    GUIMakeFontScale(self.menuHeaderTitle)
    self.menuHeaderTitle:SetFontIsBold(true)
    self.menuHeaderTitle:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.menuHeaderTitle:SetTextAlignmentX(GUIItem.Align_Center)
    self.menuHeaderTitle:SetTextAlignmentY(GUIItem.Align_Center)
    self.menuHeaderTitle:SetColor(GUIMarineCreditMenu.kTextColor)
    self.menuHeaderTitle:SetText(Locale.ResolveString("BUY"))
    self.menuHeader:AddChild(self.menuHeaderTitle)
    
    self.itemButtons = { }
    
    local itemTechIdList = {   
            kTechId.LayStructures,
            kTechId.LayStructureIP,
            kTechId.LayStructurePG,
            kTechId.LayStructureRobo,
            kTechId.LayStructureSentry,
            kTechId.LayStructureObs,
                     }
    local selectorPosX = -GUIMarineCreditMenu.kSelectorSize.x + GUIMarineCreditMenu.kPadding
    local fontScaleVector = GUIScale(Vector(0.8, 0.8, 0))
    
    for k, itemTechId in ipairs(itemTechIdList) do
    
        local graphicItem = GUIManager:CreateGraphicItem()
        graphicItem:SetSize(GUIMarineCreditMenu.kMenuIconSize)
        graphicItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        graphicItem:SetPosition(Vector(-GUIMarineCreditMenu.kMenuIconSize.x/ 2, GUIMarineCreditMenu.kIconTopOffset + (GUIMarineCreditMenu.kMenuIconSize.y) * k - GUIMarineCreditMenu.kMenuIconSize.y, 0))
        graphicItem:SetTexture(GUIMarineCreditMenu.kSmallIcons)
        graphicItem:SetTexturePixelCoordinates(GetSmallIconPixelCoordinates(itemTechId))
        
        local graphicItemActive = GUIManager:CreateGraphicItem()
        graphicItemActive:SetSize(GUIMarineCreditMenu.kSelectorSize)
        
        graphicItemActive:SetPosition(Vector(selectorPosX, -GUIMarineCreditMenu.kSelectorSize.y / 2, 0))
        graphicItemActive:SetAnchor(GUIItem.Right, GUIItem.Center)
        graphicItemActive:SetTexture(GUIMarineCreditMenu.kMenuSelectionTexture)
        graphicItemActive:SetIsVisible(false)
        
        graphicItem:AddChild(graphicItemActive)
        
        local costIcon = GUIManager:CreateGraphicItem()
        costIcon:SetSize(Vector(GUIMarineCreditMenu.kResourceIconWidth * 0.8, GUIMarineCreditMenu.kResourceIconHeight * 0.8, 0))
        costIcon:SetAnchor(GUIItem.Right, GUIItem.Bottom)
        costIcon:SetPosition(Vector(-GUIScale(32), -GUIMarineCreditMenu.kResourceIconHeight * 0.5, 0))
        costIcon:SetTexture(GUIMarineCreditMenu.kResourceIconTexture)
        costIcon:SetColor(GUIMarineCreditMenu.kTextColor)
        
        local selectedArrow = GUIManager:CreateGraphicItem()
        selectedArrow:SetSize(Vector(GUIMarineCreditMenu.kArrowWidth, GUIMarineCreditMenu.kArrowHeight, 0))
        selectedArrow:SetAnchor(GUIItem.Left, GUIItem.Center)
        selectedArrow:SetPosition(Vector(-GUIMarineCreditMenu.kArrowWidth - GUIMarineCreditMenu.kPadding, -GUIMarineCreditMenu.kArrowHeight * 0.5, 0))
        selectedArrow:SetTexture(GUIMarineCreditMenu.kArrowTexture)
        selectedArrow:SetColor(GUIMarineCreditMenu.kTextColor)
        selectedArrow:SetTextureCoordinates(unpack(GUIMarineCreditMenu.kArrowTexCoords))
        selectedArrow:SetIsVisible(false)
        
        graphicItem:AddChild(selectedArrow) 
        
        local itemCost = GUIManager:CreateTextItem()
        itemCost:SetFontName(GUIMarineCreditMenu.kFont)
        itemCost:SetFontIsBold(true)
        itemCost:SetAnchor(GUIItem.Right, GUIItem.Center)
        itemCost:SetPosition(Vector(0, 0, 0))
        itemCost:SetTextAlignmentX(GUIItem.Align_Min)
        itemCost:SetTextAlignmentY(GUIItem.Align_Center)
        itemCost:SetScale(fontScaleVector)
        GUIMakeFontScale(itemCost)
        itemCost:SetColor(GUIMarineCreditMenu.kTextColor)
        itemCost:SetText(ToString(LookupTechData(itemTechId, kTechDataCreditCostKey, 0)))
        
        costIcon:AddChild(itemCost)  
        
        graphicItem:AddChild(costIcon)  
        
        self.menu:AddChild(graphicItem)
        table.insert(self.itemButtons, { Button = graphicItem, Highlight = graphicItemActive, TechId = itemTechId, Cost = itemCost, ResourceIcon = costIcon, Arrow = selectedArrow } )
    
    end
    
    // to prevent wrong display before the first update
    self:_UpdateItemButtons(0)

end

function GUIMarineCreditMenu:_UpdateItemButtons(deltaTime)
    
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
            elseif PlayerUI_GetPlayerCredits() < MarineBuy_GetCreditCosts(item.TechId) then
               useColor = Color(1, 0, 0, 1)
            // set normal visible
            elseif MarineBuy_GetHas( item.TechId ) then
                useColor = Color(0.6, 0.6, 0.6, 0.5) 
            end
            
            item.Button:SetColor(useColor)
            item.Highlight:SetColor(useColor)
            item.Cost:SetColor(useColor)
            item.ResourceIcon:SetColor(useColor)
            item.Arrow:SetIsVisible(self.selectedItem == item.TechId)
            
        end
    end

end

function GUIMarineCreditMenu:_UninitializeItemButtons()

    if self.itemButtons then
        for i, item in ipairs(self.itemButtons) do
            GUI.DestroyItem(item.Button)
        end
        self.itemButtons = nil
    end

end

function GUIMarineCreditMenu:_InitializeContent()

    self.itemName = GUIManager:CreateTextItem()
    self.itemName:SetFontName(GUIMarineCreditMenu.kFont)
    self.itemName:SetScale(GetScaledVector())
    self.itemName:SetFontIsBold(true)
    self.itemName:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.itemName:SetPosition(Vector(GUIMarineCreditMenu.kItemNameOffsetX , GUIMarineCreditMenu.kItemNameOffsetY , 0))
    self.itemName:SetTextAlignmentX(GUIItem.Align_Min)
    self.itemName:SetTextAlignmentY(GUIItem.Align_Min)
    self.itemName:SetColor(GUIMarineCreditMenu.kTextColor)
    GUIMakeFontScale(self.itemName)
    self.itemName:SetText("no selection")
    
    self.content:AddChild(self.itemName)
    
    self.portrait = GetGUIManager():CreateGraphicItem()
    self.portrait:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.portrait:SetPosition(Vector(-GUIMarineCreditMenu.kBigIconSize.x/2, GUIMarineCreditMenu.kBigIconOffset, 0))
    self.portrait:SetSize(GUIMarineCreditMenu.kBigIconSize)
    self.portrait:SetTexture(GUIMarineCreditMenu.kBigIconTexture)
    self.portrait:SetTexturePixelCoordinates(GetBigIconPixelCoords(kTechId.Axe))
    self.portrait:SetIsVisible(false)
    self.content:AddChild(self.portrait)

    
end

function GUIMarineCreditMenu:_UpdateContent(deltaTime)


    if self.hoverItem == kTechId.Exosuit or (self.hoverItem == nil and self.hoveringExo) then
        self.hoveringExo = true
        self.portrait:SetIsVisible(true)
		self.portrait:SetTexturePixelCoordinates(GetBigIconPixelCoords(kTechId.DualMinigunExosuit))
        self.itemName:SetIsVisible(false)
        
        return
    end
    
    local techId = self.hoverItem
    if not self.hoverItem then
        techId = self.selectedItem
    end
    
    if techId then
    
        local researched, researchProgress, researching = self:_GetResearchInfo(techId)
        
        local itemCost = MarineBuy_GetCreditCosts(techId)
        local canAfford = PlayerUI_GetPlayerCredits() >= itemCost

        local color = Color(1, 1, 1, 1)
        if not canAfford and researched then
            color = Color(1, 0, 0, 1)
        elseif not researched then
            // Make it clear that we can't buy this
            color = Color(0.5, 0.5, 0.5, .6)
        end
    
        self.itemName:SetColor(color)
        self.portrait:SetColor(color)        

        self.itemName:SetText(MarineBuy_GetDisplayName(techId))
        self.portrait:SetTexturePixelCoordinates(GetBigIconPixelCoords(techId, researched))

    end
    
    local contentVisible = techId ~= nil and techId ~= kTechId.None
    
    self.portrait:SetIsVisible(contentVisible)
    self.itemName:SetIsVisible(contentVisible)
    
end

function GUIMarineCreditMenu:_UninitializeContent()

    GUI.DestroyItem(self.itemName)

end

function GUIMarineCreditMenu:_InitializeResourceDisplay()
    
    self.resourceDisplayBackground = GUIManager:CreateGraphicItem()
    self.resourceDisplayBackground:SetSize(Vector(GUIMarineCreditMenu.kBackgroundWidth, GUIMarineCreditMenu.kResourceDisplayHeight, 0))
    self.resourceDisplayBackground:SetPosition(Vector(0, -GUIMarineCreditMenu.kResourceDisplayHeight, 0))
    self.resourceDisplayBackground:SetTexture(GUIMarineCreditMenu.kContentBgBackTexture)
    self.resourceDisplayBackground:SetTexturePixelCoordinates(0, 0, GUIMarineCreditMenu.kBackgroundWidth, GUIMarineCreditMenu.kResourceDisplayHeight)
    self.content:AddChild(self.resourceDisplayBackground)
    
    self.resourceDisplayIcon = GUIManager:CreateGraphicItem()
    self.resourceDisplayIcon:SetSize(Vector(GUIMarineCreditMenu.kResourceIconWidth, GUIMarineCreditMenu.kResourceIconHeight, 0))
    self.resourceDisplayIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.resourceDisplayIcon:SetPosition(Vector(-GUIMarineCreditMenu.kResourceIconWidth * 2.2, -GUIMarineCreditMenu.kResourceIconHeight / 2, 0))
    self.resourceDisplayIcon:SetTexture(GUIMarineCreditMenu.kResourceIconTexture)
    self.resourceDisplayIcon:SetColor(GUIMarineCreditMenu.kTextColor)
    self.resourceDisplayBackground:AddChild(self.resourceDisplayIcon)

    self.resourceDisplay = GUIManager:CreateTextItem()
    self.resourceDisplay:SetFontName(GUIMarineCreditMenu.kFont)
    self.resourceDisplay:SetScale(GetScaledVector())
    self.resourceDisplay:SetFontIsBold(true)
    self.resourceDisplay:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.resourceDisplay:SetPosition(Vector(-GUIMarineCreditMenu.kResourceIconWidth * 1.1, 0, 0))
    self.resourceDisplay:SetTextAlignmentX(GUIItem.Align_Min)
    self.resourceDisplay:SetTextAlignmentY(GUIItem.Align_Center)
    GUIMakeFontScale(self.resourceDisplay)
    
    self.resourceDisplay:SetColor(GUIMarineCreditMenu.kTextColor)
    //self.resourceDisplay:SetColor(GUIMarineCreditMenu.kTextColor)
    
    self.resourceDisplay:SetText("")
    self.resourceDisplayBackground:AddChild(self.resourceDisplay)

end

function GUIMarineCreditMenu:_UpdateResourceDisplay(deltaTime)

    self.resourceDisplay:SetText(ToString(PlayerUI_GetPlayerCredits()))
    
end

function GUIMarineCreditMenu:_UninitializeResourceDisplay()

    GUI.DestroyItem(self.resourceDisplay)
    self.resourceDisplay = nil
    
    GUI.DestroyItem(self.resourceDisplayIcon)
    self.resourceDisplayIcon = nil
    
    GUI.DestroyItem(self.resourceDisplayBackground)
    self.resourceDisplayBackground = nil
    
end

function GUIMarineCreditMenu:_InitializeCloseButton()

    self.closeButton = GUIManager:CreateGraphicItem()
    self.closeButton:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.closeButton:SetSize(Vector(GUIMarineCreditMenu.kButtonWidth, GUIMarineCreditMenu.kButtonHeight, 0))
    self.closeButton:SetPosition(Vector(-GUIMarineCreditMenu.kButtonWidth, GUIMarineCreditMenu.kPadding, 0))
    self.closeButton:SetTexture(GUIMarineCreditMenu.kButtonTexture)
    self.closeButton:SetLayer(kGUILayerPlayerHUDForeground4)
    self.content:AddChild(self.closeButton)
    
    self.closeButtonText = GUIManager:CreateTextItem()
    self.closeButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.closeButtonText:SetFontName(GUIMarineCreditMenu.kFont)
    self.closeButtonText:SetScale(GetScaledVector())
    self.closeButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.closeButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.closeButtonText:SetText(Locale.ResolveString("EXIT"))
    self.closeButtonText:SetFontIsBold(true)
    self.closeButtonText:SetColor(GUIMarineCreditMenu.kCloseButtonColor)
    GUIMakeFontScale(self.closeButtonText)
    self.closeButton:AddChild(self.closeButtonText)
    
end

function GUIMarineCreditMenu:_UpdateCloseButton(deltaTime)

    if GetIsMouseOver(self, self.closeButton) then
        self.closeButton:SetColor(Color(1, 1, 1, 1))
    else
        self.closeButton:SetColor(Color(0.5, 0.5, 0.5, 1))
    end
    
end

function GUIMarineCreditMenu:_UninitializeCloseButton()
    
    GUI.DestroyItem(self.closeButton)
    self.closeButton = nil

end

function GUIMarineCreditMenu:_GetResearchInfo(techId)

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
   
    if self.itemButtons then
        for i = 1, #self.itemButtons do
        
            local item = self.itemButtons[i]
            if GetIsMouseOver(self, item.Button) then
            
                local researched, researchProgress, researching = self:_GetResearchInfo(item.TechId)
                local itemCost = MarineBuy_GetCreditCosts(item.TechId)
                local canAfford = PlayerUI_GetPlayerCredits() >= itemCost
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
        
end

function GUIMarineCreditMenu:SendKeyEvent(key, down)

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

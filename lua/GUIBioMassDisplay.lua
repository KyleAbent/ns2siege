// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/GUIBioMassDisplay.lua
//
// Used to display a progress bar with unlocked abilities as milestones. min biomass is 0, max is 9.
//
// Created by Andreas Urwalek (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Globals.lua")
Script.Load("lua/GUIScript.lua")

class 'GUIBioMassDisplay' (GUIScript)

local kMinBioMass = 0
local kMaxBioMass = 12

local kBackgroundTexture = "ui/biomass_bar.dds"

local kBioMassBackgroundPos
local kBioMassBarSize

local kBioMassIconSize

local kBackgroundCoords = { 0, 160, 1200, 320 }
local kForegroundCoords = { 0, 0, 1200, 160 }

local kBackgroundColor = Color(1, 1, 1, 1)
local kForegroundColor = Color(1, 1, 1, 1)
local kTotalColor = Color(1, 0.7, 0.7, 0.35)
local kTextColor = Color(0,0,0,1)

local kUnlocked = Color(kIconColors[kAlienTeamType])
local kLocked = Color(0.4,0.4,0.4,1)

local kFontName = Fonts.kStamp_Medium
local kLevelTextPos

local kBackgroundNoiseTexture = PrecacheAsset("ui/alien_commander_bg_smoke.dds")
local kSmokeyBackgroundSize
local kSmokeyBackgroundPos

local kBioMassTechIds =
{
    kTechId.BioMassOne,
    kTechId.BioMassTwo,
    kTechId.BioMassThree,
    kTechId.BioMassFour,
    kTechId.BioMassFive,
    kTechId.BioMassSix,
    kTechId.BioMassSeven,
    kTechId.BioMassEight,
    kTechId.BioMassNine,
    kTechId.BioMassTen,
    kTechId.BioMassEleven,
    kTechId.BioMassTwelve
}

local function GetTechIdsWithPrereq(prereqTechId)

    local techIds = {}
    local techTree = GetTechTree()
    if techTree then
    
        for techId, node in pairs(techTree.nodeList) do
        
            if (node:GetPrereq1() == prereqTechId or node:GetPrereq2() == prereqTechId) and node:GetAddOnTechId() == kTechId.AllAliens then
                table.insert(techIds, techId)
            end
        
        end
    
    end
    
    return techIds

end

local function UpdateAbilityList(self, currentBioMassLevel, bioMassAlertLevel, alertColor)
    
    if not self.abilityIcons then
        self.abilityIcons = {}
    end
    
    local player = Client.GetLocalPlayer()
    local mouseX, mouseY = Client.GetCursorPosScreen()
    self.hoverTechId = nil
    
    for i = 1, 9 do
    
        local xPos = (i - 1) * kBioMassIconSize
        if not self.abilityIcons[i] then 
            self.abilityIcons[i] = {}
        end
        
        local levelIcons = self.abilityIcons[i]             
        for j, techId in ipairs(GetTechIdsWithPrereq(kBioMassTechIds[i])) do
            
            local yPos = (j - 1) * kBioMassIconSize - kBioMassIconSize * 0.5
            if not levelIcons[j] then
                levelIcons[j] = {}
            end
            
            local levelIcon = levelIcons[j]
            
            if not levelIcon.Graphic then
            
                levelIcon.Graphic = GetGUIManager():CreateGraphicItem()
                levelIcon.Graphic:SetSize(Vector(kBioMassIconSize, kBioMassIconSize, 0))
                levelIcon.Graphic:SetPosition(Vector(xPos, yPos, 0))
                levelIcon.Graphic:SetAnchor(GUIItem.Left, GUIItem.Bottom)
                levelIcon.Graphic:SetTexture("ui/buildmenu.dds")
                levelIcon.Graphic:SetInheritsParentAlpha(true)
                self.background:AddChild(levelIcon.Graphic)
                
            end
            
            if not self.hoverTechId and GUIItemContainsPoint(levelIcon.Graphic, mouseX, mouseY) then
                self.hoverTechId = techId
            end

            local hasTech = GetIsTechUnlocked(player, techId)
            if hasTech then
            
                if i > currentBioMassLevel - bioMassAlertLevel then
                    levelIcon.Graphic:SetColor(alertColor)
                else
                    levelIcon.Graphic:SetColor(kUnlocked)
                end    
            
            else
                levelIcon.Graphic:SetColor(kLocked)
            end
            
            levelIcon.TechId = techId            
            levelIcon.Graphic:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(techId)))
            
            
        end
    
    end

end

local function UpdateItemsGUIScale(self)
    kBioMassBackgroundPos = GUIScale(Vector(20, 70, 0))
    kBioMassBarSize = GUIScale(Vector(480, 64, 0))
    kBioMassIconSize = kBioMassBarSize.x / 12

    kLevelTextPos = GUIScale(Vector(300, 18, 0))

    kSmokeyBackgroundSize = GUIScale(Vector(700, 300, 0))
    kSmokeyBackgroundPos = GUIScale(Vector(-100, -20, 0))

    self.smokeyBackground:SetSize(kSmokeyBackgroundSize)
    self.smokeyBackground:SetPosition(kSmokeyBackgroundPos)
    
    self.background:SetSize(kBioMassBarSize)
    self.background:SetPosition(kBioMassBackgroundPos)
    
    self.foreground:SetSize(kBioMassBarSize)
    
    self.effectiveBiomass:SetSize(kBioMassBarSize)
    
    self.levelText:SetFontName(kFontName)
    self.levelText:SetScale(GetScaledVector()*0.8)
    GUIMakeFontScale(self.levelText)
    self.levelText:SetPosition(kLevelTextPos)
end

function GUIBioMassDisplay:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateItemsGUIScale(self)
    
    -- Clear the array with the icons so they get rebuilt on the next update
    for _, levelTable in ipairs(self.abilityIcons) do
        for _, icon in ipairs(levelTable) do
            GUI.DestroyItem(icon.Graphic)
        end
    end
    
    self.abilityIcons = {}
end

function GUIBioMassDisplay:Initialize()

    GUIScript.Initialize(self)
    
    self.nextBiomassUpdateTime = 0
    
    self.backgroundColor = Color(kBackgroundColor)
    self.backgroundColor.a = 0.01 -- causes it to fade out, avoids a problem with initialization
    
    self.smokeyBackground = GUIManager:CreateGraphicItem()
    self.smokeyBackground:SetShader("shaders/GUISmoke.surface_shader")
    self.smokeyBackground:SetTexture("ui/alien_logout_smkmask.dds")
    self.smokeyBackground:SetAdditionalTexture("noise", kBackgroundNoiseTexture)
    self.smokeyBackground:SetFloatParameter("correctionX", 0.7)
    self.smokeyBackground:SetFloatParameter("correctionY", 0.4)
    self.smokeyBackground:SetLayer(0)
    
    self.background = GetGUIManager():CreateGraphicItem()
    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetColor(kBackgroundColor)
    self.background:SetTexture(kBackgroundTexture)
    self.background:SetTexturePixelCoordinates(unpack(kBackgroundCoords))
    self.background:SetLayer(kGUILayerPlayerHUD)
    
    self.foreground = GetGUIManager():CreateGraphicItem()
    self.foreground:SetColor(kTotalColor)
    self.foreground:SetTexture(kBackgroundTexture)
    self.foreground:SetInheritsParentAlpha(true)
    
    self.effectiveBiomass = GetGUIManager():CreateGraphicItem()
    self.effectiveBiomass:SetColor(kForegroundColor)
    self.effectiveBiomass:SetTexture(kBackgroundTexture)
    self.effectiveBiomass:SetInheritsParentAlpha(true)
    
    self.alertTexture = GetGUIManager():CreateGraphicItem()
    self.alertTexture:SetTexture(kBackgroundTexture)
    self.alertTexture:SetIsVisible(false)
    self.alertTexture:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.alertTexture:SetInheritsParentAlpha(true)
    
    self.levelText = GetGUIManager():CreateTextItem()
    self.levelText:SetInheritsParentAlpha(true)
    self.levelText:SetTextAlignmentY(GUIItem.Align_Max)
    self.levelText:SetColor(kAlienFontColor)
    
    self.background:AddChild(self.foreground)
    self.background:AddChild(self.effectiveBiomass)
    self.background:AddChild(self.alertTexture)
    self.background:AddChild(self.levelText)
    
    UpdateItemsGUIScale(self)
    
end

function GUIBioMassDisplay:Uninitialize()

    if self.background then
        GUI.DestroyItem(self.background)
        self.background = nil
    end
    
    if self.smokeyBackground then
        GUI.DestroyItem(self.smokeyBackground)
        self.smokeyBackground = nil    
    end

end

function GUIBioMassDisplay:Update(deltaTime)
        
    PROFILE("GUIBioMassDisplay:Update")
    
    local player = Client.GetLocalPlayer()
    local teamNum = player and player:GetTeamNumber() or 0
    local teamInfo = GetTeamInfoEntity(teamNum)
    local bioMass = (teamInfo and teamInfo.GetBioMassLevel) and teamInfo:GetBioMassLevel() or 0
    local maxBioMass = (teamInfo and teamInfo.GetMaxBioMassLevel) and teamInfo:GetMaxBioMassLevel() or 0
    local bioMassAlert = (teamInfo and teamInfo.GetBioMassAlertLevel) and teamInfo:GetBioMassAlertLevel() or 0
    local showGUI = player and (player:isa("Commander") or player:GetIsMinimapVisible() or player:GetBuyMenuIsDisplaying() or bioMassAlert > 0) or PlayerUI_GetIsTechMapVisible()
 
    // if we are animating, we update all the time. If not animating, we only update twice per sec
    local transp = self.backgroundColor.a
    local animating = ( transp > 0 and transp < 1 ) or bioMassAlert > 0 or (showGUI and transp == 0)
    // update if animating or - if fully visible - twice per second
    if not animating and (transp < 1 or Shared.GetTime() < self.nextBiomassUpdateTime) then
        return
    end
    self.nextBiomassUpdateTime = Shared.GetTime() + 0.5

    if player:isa("Commander") then
        
        if not self.registered then
        
            local script = GetGUIManager():GetGUIScriptSingle("GUICommanderTooltip")
            if script then
                script:Register(self)
                self.registered = true
            end
        
        end
        
    else
        self.registered = false
    end
    
    local overflow = math.max(0, bioMass - maxBioMass)
    local activeBioMass = math.min(maxBioMass, bioMass)
    
    self.levelText:SetText(string.format("%s: %d / 12", Locale.ResolveString("BIOMASS_LEVEL"), activeBioMass))
    
    local rate = showGUI and 5 or -1
    self.backgroundColor.a = Clamp(self.backgroundColor.a + deltaTime * rate, 0, 1)
    self.background:SetColor(self.backgroundColor)
    self.smokeyBackground:SetColor(self.backgroundColor)

    local fraction = Clamp(bioMass, kMinBioMass, kMaxBioMass) / kMaxBioMass
    self.foreground:SetSize(Vector(kBioMassBarSize.x * fraction, kBioMassBarSize.y, 0))    
    local x2PixelCoord = kForegroundCoords[1] + (kForegroundCoords[3] - kForegroundCoords[1]) * fraction
    self.foreground:SetTexturePixelCoordinates(kForegroundCoords[1], kForegroundCoords[2], x2PixelCoord, kForegroundCoords[4])
    
    self.alertTexture:SetIsVisible(bioMassAlert > 0)
    local alertAnim = (math.cos(Shared.GetTime() * 5) + 1) * 0.5
    
    if bioMassAlert > 0 then
        
        local alertStartFraction = Clamp(bioMass - bioMassAlert, kMinBioMass, kMaxBioMass) / kMaxBioMass
        local alertWidth = kBioMassBarSize.x * (fraction - alertStartFraction)    
        local x1AlertPixelCoord = kForegroundCoords[1] + (kForegroundCoords[3] - kForegroundCoords[1]) * alertStartFraction
        
        self.alertTexture:SetColor(Color(1, 0, 0, alertAnim * 0.7 + 0.1))
        self.alertTexture:SetSize(Vector(alertWidth, kBioMassBarSize.y, 0))
        self.alertTexture:SetPosition(Vector(kBioMassBarSize.x * fraction - alertWidth, 0, 0))
        self.alertTexture:SetTexturePixelCoordinates(x1AlertPixelCoord, kForegroundCoords[2], x2PixelCoord, kForegroundCoords[4])
    
    end
    
    fraction = Clamp(math.min(maxBioMass, bioMass), kMinBioMass, kMaxBioMass) / kMaxBioMass
    self.effectiveBiomass:SetSize(Vector(kBioMassBarSize.x * fraction, kBioMassBarSize.y, 0))
    x2PixelCoord = kForegroundCoords[1] + (kForegroundCoords[3] - kForegroundCoords[1]) * fraction
    self.effectiveBiomass:SetTexturePixelCoordinates(kForegroundCoords[1], kForegroundCoords[2], x2PixelCoord, kForegroundCoords[4])
    
    UpdateAbilityList(self, bioMass, bioMassAlert, Color((1 - alertAnim) + kUnlocked.r * alertAnim, kUnlocked.g * alertAnim, kUnlocked.b * alertAnim, 1))


end

function GUIBioMassDisplay:GetTooltipData()

    if self.hoverTechId then
        return PlayerUI_GetTooltipDataFromTechId(self.hoverTechId)
    end    

    return nil

end
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIFlamethrowerDisplay.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Displays the ammo counter for the shotgun.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")
Script.Load("lua/Utility.lua")

// Global state that can be externally set to adjust the display.
weaponClip     = 0
weaponAmmo     = 0
weaponAuxClip  = 0
globalTime     = 0
lowAmmoWarning = true

bulletDisplay  = nil

//GUIFlamethrowerDisplay.kClipDisplay = { 0, 198, 20, 103 }
local kTexture = "ui/FlamethrowerDisplay.dds"
local kBgTexCoords = { 0, 0, 128, 256 }
local kBarTexCoords = { 147, 55, 232, 238 }
local kAmmoTexCoords = { 147, 28, 160, 50 }
local kClipHeight = 183
local kNumAmmo = 4
local kAmmoHeight = 20
local kAmmoOffset = 6
local kAmmoWidth = 10
local kAmmoStartPos = Vector(19, 24, 0)

class 'GUIFlamethrowerDisplay' (GUIScript)

function GUIFlamethrowerDisplay:Initialize()

    self.weaponClip = 0
    self.weaponAmmo = 0
    self.maxClip = 4
    self.globalTime = 0
    self.lowAmmoWarning = true
    
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetAnchor(GUIItem.Top, GUIItem.Left)
    self.background:SetSize( Vector(128, 256, 0) )
    self.background:SetPosition( Vector(0, 0, 0))    
    self.background:SetTexture(kTexture)
    self.background:SetTexturePixelCoordinates(unpack(kBgTexCoords))
    
    self.lowAmmoOverlay = GUIManager:CreateGraphicItem()
    self.lowAmmoOverlay:SetSize( Vector(128, 256, 0) )
    self.lowAmmoOverlay:SetPosition( Vector(0, 0, 0))
    
    self.clipDisplay = GUIManager:CreateGraphicItem()
    self.clipDisplay:SetAnchor(GUIItem.Top, GUIItem.Left)
    self.clipDisplay:SetSize(Vector(85, -kClipHeight, 0))
    self.clipDisplay:SetPosition(Vector(20, 230, 0) )
    self.clipDisplay:SetTexture(kTexture)
    self.clipDisplay:SetTexturePixelCoordinates(unpack(kBarTexCoords))

    self.background:AddChild(self.clipDisplay)
    self.background:SetIsVisible(true)
    
        self.ammoIcons = {}
    
    for i = 1, kNumAmmo do
    
        local ammoIcon = GUIManager:CreateGraphicItem()
        ammoIcon:SetTexture(kTexture)
        ammoIcon:SetSize(Vector(kAmmoWidth, kAmmoHeight, 0))
        ammoIcon:SetAnchor(GUIItem.Top, GUIItem.Left)
        ammoIcon:SetPosition(Vector(kAmmoStartPos.x + (kAmmoWidth + kAmmoOffset)*i, kAmmoStartPos.y, 0))
        ammoIcon:SetTexturePixelCoordinates(unpack(kAmmoTexCoords))
        ammoIcon:SetBlendTechnique(GUIItem.Add)
        
        self.background:AddChild(ammoIcon)
        
        table.insert(self.ammoIcons, ammoIcon)
    
    end
    
    // Force an update so our initial state is correct.
    self:Update(0)

end

function GUIFlamethrowerDisplay:Update(deltaTime)

    PROFILE("GUIFlamethrowerDisplay:Update")
    
    // Update the clip and ammo counter.
    local clipFraction = self.weaponClip / self.maxClip
    local clipHeigth = kClipHeight * clipFraction * -1
  
    self.clipDisplay:SetSize( Vector(85, clipHeigth, 0) )
    
    local y1 = (kBarTexCoords[2] - kBarTexCoords[4]) * clipFraction + kBarTexCoords[4]
    
    self.clipDisplay:SetTexturePixelCoordinates(kBarTexCoords[1], y1, kBarTexCoords[3], kBarTexCoords[4]  )

    local alpha = 0
    local pulseSpeed = 5
    
    if clipFraction <= 0.4 then
        
        if clipFraction == 0 then
            pulseSpeed = 25
        elseif clipFraction < 0.25 then
            pulseSpeed = 10
        end
        
        alpha = (math.sin(self.globalTime * pulseSpeed) + 1) / 2
    end
    
    for i = 1, kNumAmmo do
    
        local ammoIcon = self.ammoIcons[i]
        ammoIcon:SetIsVisible(kNumAmmo - self.weaponAmmo/self.maxClip < i)
    
    end
    
    if not self.lowAmmoWarning then alpha = 0 end
    
    self.lowAmmoOverlay:SetColor(Color(1, 0, 0, alpha * 0.25))
    
end

function GUIFlamethrowerDisplay:SetClip(weaponClip)
    self.weaponClip = weaponClip
end

function GUIFlamethrowerDisplay:SetClipSize(weaponClipSize)
    self.weaponClipSize = weaponClipSize
end

function GUIFlamethrowerDisplay:SetAmmo(weaponAmmo)
    self.weaponAmmo = weaponAmmo
end

function GUIFlamethrowerDisplay:SetGlobalTime(globalTime)
    self.globalTime = globalTime
end

function GUIFlamethrowerDisplay:SetLowAmmoWarning(lowAmmoWarning)
    self.lowAmmoWarning = ConditionalValue(lowAmmoWarning == "true", true, false)
end

/**
 * Called by the player to update the components.
 */
function Update(deltaTime)

    bulletDisplay:SetClip(weaponClip)
    bulletDisplay:SetAmmo(weaponAmmo)
    bulletDisplay:SetGlobalTime(globalTime)
    bulletDisplay:SetLowAmmoWarning(lowAmmoWarning)
    bulletDisplay:Update(deltaTime)
        
end

/**
 * Initializes the player components.
 */
function Initialize()

    GUI.SetSize( 128, 256 )

    bulletDisplay = GUIFlamethrowerDisplay()
    bulletDisplay:Initialize()
    bulletDisplay:SetClipSize(4)
    bulletDisplay:SetGlobalTime(globalTime)
    bulletDisplay:SetLowAmmoWarning(lowAmmoWarning)

end

Initialize()

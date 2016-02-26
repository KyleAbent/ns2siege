// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIFadeVortex.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)  
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIFadeVortex' (GUIScript)

local kPosition = GUIScale(Vector(-170, -220, 0))
local kSize = GUIScale(Vector(120, 120, 0))

function GUIFadeVortex:Initialize()

    self.vortexIcon = GetGUIManager():CreateGraphicItem()
    self.vortexIcon:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.vortexIcon:SetTexture("ui/buildmenu.dds")
    self.vortexIcon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.Vortex)))
    
    self.vortexIcon:SetIsVisible(false)

end

function GUIFadeVortex:Uninitialize()
    
    if self.vortexIcon then
        GUI.DestroyItem(self.vortexIcon)
    end
    
end

function GUIFadeVortex:Update(deltaTime)
                  
    PROFILE("GUIFadeVortex:Update")
    
    local player = Client.GetLocalPlayer()
    local showVortex = false
    
    if player and player:isa("Fade") then
    
        local vortexAbility = player:GetWeapon(Vortex.kMapName)
        if vortexAbility and vortexAbility.etherealGateId then
        
            local gate = Shared.GetEntity(vortexAbility.etherealGateId)
            if gate then
            
                showVortex = true
                local fraction = math.max(0, gate.endTime - Shared.GetTime()) / kEtherealGateLifeTime
                local size = math.max(0.4, fraction) * kSize
                
                local useColor = Color(kIconColors[kAlienTeamType])
                
                if fraction < 0.3 then
                    useColor.a = (1 + math.sin(Shared.GetTime() * 8)) * 0.5
                end
                
                local rotationAnim = (Shared.GetTime() % 2) / 2
                local rotation = Vector(0, 0, -rotationAnim * math.pi * 2)
                
                self.vortexIcon:SetSize(size)
                self.vortexIcon:SetPosition(-size * 0.5 + kPosition)
                self.vortexIcon:SetRotation(rotation)
                self.vortexIcon:SetColor(useColor)
            
            end
        
        end
    
    end

    self.vortexIcon:SetIsVisible(showVortex)

end
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ScriptActor_Client.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Base class for all visible entities that aren't players. 
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local Client_GetLocalPlayer = Client.GetLocalPlayer

function ScriptActor:OnDestroy()
    
    self:DestroyAttachedEffects() 

    Entity.OnDestroy(self)
    
end

function ScriptActor:DestroyAttachedEffects()

    if self.attachedEffects ~= nil then
    
        for index, attachedEffect in ipairs(self.attachedEffects) do
        
            Client.DestroyCinematic(attachedEffect[1])
            
        end
        
        self.attachedEffects = nil
        
    end
    
end

function ScriptActor:RemoveEffect(effectName)
    
    if self.attachedEffects then
    
        for index, attachedEffect in ipairs(self.attachedEffects) do
        
            if attachedEffect[2] == effectName then
            
                Client.DestroyCinematic(attachedEffect[1])
                
                local success = table.removevalue(self.attachedEffects, attachedEffect)
                
                return true
                
            end
            
        end
        
    end
    
    return false

end

function ScriptActor:SetEffectVisible(effectName, visible)

    if self.attachedEffects ~= nil then
    
        for index, attachedEffect in ipairs(self.attachedEffects) do
            
            if attachedEffect[2] == effectName then               
                attachedEffect[1]:SetIsVisible(visible)                                                
                return true
                
            end
            
        end
        
    end
    
    return false
    
end

function ScriptActor:HideAllEffects()

   if self.attachedEffects ~= nil then
   
        for index, attachedEffect in ipairs(self.attachedEffects) do
            attachedEffect[1]:SetIsVisible(false)
        end
        
    end
    
end

function ScriptActor:ShowAllEffects()

    if self.attachedEffects ~= nil then
    
        for index, attachedEffect in ipairs(self.attachedEffects) do
            attachedEffect[1]:SetIsVisible(true)
        end
        
    end
    
end

// Uses loopmode endless by default
function ScriptActor:AttachEffect(effectName, coords, loopMode)

    if self.attachedEffects == nil then
        self.attachedEffects = {}
    end

    // Don't create it if already created    
    for index, attachedEffect in ipairs(self.attachedEffects) do
        if attachedEffect[2] == effectName then
            return false
        end
    end

    local cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
    
    cinematic:SetCinematic( effectName )
    cinematic:SetCoords( coords )
    
    if loopMode == nil then
        loopMode = Cinematic.Repeat_Endless
    end
    
    cinematic:SetRepeatStyle(loopMode)

    table.insert(self.attachedEffects, {cinematic, effectName})
    
    if not self.callbackActive then
        self.callbackActive = true
        self:AddTimedCallback(ScriptActor.OnUpdateAttachedEffects, 0)
    end
    
    return true
    
end

// -- hmm.. this may be to be done AFTER the OnUpdate? Or moving entities may end up with trailing attached effects?
function ScriptActor:OnUpdateAttachedEffects(deltaTime)

    if self.attachedEffects then

        for index, effectPair in ipairs(self.attachedEffects) do
    
            local coords = self:GetAngles():GetCoords()
            coords.origin = self:GetOrigin()
            effectPair[1]:SetCoords(coords)
            
        end
        return true
        
    end
    
    self.callbackActive = false
    return false
    
end


function ScriptActor:GetIsVisible()

    local visible = Entity.GetIsVisible(self)
    local localPlayer = Client_GetLocalPlayer()
    
    local self_OnGetIsVisible = self.OnGetIsVisible
    
    if self_OnGetIsVisible and localPlayer ~= nil then    
        
        local visibleTable = {Visible = visible}    
        self_OnGetIsVisible(self, visibleTable, localPlayer:GetTeamNumber())
        return visibleTable.Visible
        
    end
    
    return visible
            
end